param(
    [string]$ProjectDir = "",
    [string]$PublishDir = "",
    [string]$OutputDir = "",
    [string]$ZipPath = "",
    [string]$StaticAssetBaseUrl = "",
    [string]$MainPackUrl = "",
    [string]$ReleaseRoot = "",
    [int64]$WasmChunkBytes = 20971520
)

$ErrorActionPreference = "Stop"

function Resolve-ExistingDirectory {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label not found: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Resolve-ParentDirectory {
    param([string]$Path)
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    return (Resolve-Path -LiteralPath $parent).Path
}

function Assert-UnderDirectory {
    param([string]$Path, [string]$Root, [string]$Label)
    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $fullRoot = [System.IO.Path]::GetFullPath($Root)
    if (-not $fullRoot.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $fullRoot = $fullRoot + [System.IO.Path]::DirectorySeparatorChar
    }
    if (-not $fullPath.StartsWith($fullRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label must stay under $fullRoot, got $fullPath"
    }
}

function Get-GodotWebFileSize {
    param([string]$Html, [string]$FileName)
    $pattern = '"' + [regex]::Escape($FileName) + '"\s*:\s*(\d+)'
    $match = [regex]::Match($Html, $pattern)
    if (-not $match.Success) {
        throw "Godot Web file size missing from publish web index for $FileName"
    }
    return [int64]$match.Groups[1].Value
}

function Get-RemoteContentLength {
    param([string]$Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing
        $contentLength = $response.Headers["Content-Length"]
        if ($contentLength -is [array]) {
            $contentLength = $contentLength[0]
        }
        if (-not [string]::IsNullOrWhiteSpace($contentLength)) {
            return [int64]$contentLength
        }
    } catch {
        throw "Unable to read remote asset size for $Url. $($_.Exception.Message)"
    }
    throw "Remote asset did not return Content-Length: $Url"
}

function Get-ShortSha256Text {
    param([string]$Text)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
        $hash = $sha.ComputeHash($bytes)
        return (($hash | ForEach-Object { $_.ToString("x2") }) -join "").Substring(0, 12)
    } finally {
        $sha.Dispose()
    }
}

function Get-ReleaseRootFromAssetBase {
    param([string]$AssetBase)
    $normalized = $AssetBase.Trim().TrimEnd("/")
    $pathText = $normalized
    $uri = $null
    if ([System.Uri]::TryCreate($normalized, [System.UriKind]::Absolute, [ref]$uri)) {
        $pathText = $uri.AbsolutePath
    }

    $segments = @($pathText.Trim("/") -split "/" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    for ($i = $segments.Count - 1; $i -ge 0; $i--) {
        if ($segments[$i] -eq "internal-alpha") {
            $end = $segments.Count - 1
            if ($segments[$end] -eq "web") {
                $end--
            }
            if ($end -ge $i) {
                return (@($segments[$i..$end]) -join "/")
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($normalized)) {
        return "unknown"
    }
    return "unknown-" + (Get-ShortSha256Text -Text $normalized)
}

function Get-CacheBustValue {
    param([string]$ReleaseRoot)
    $value = if ([string]::IsNullOrWhiteSpace($ReleaseRoot)) { "unknown" } else { $ReleaseRoot }
    return [System.Uri]::EscapeDataString($value)
}

function ConvertTo-JavascriptStringLiteral {
    param([string]$Value)
    return ($Value | ConvertTo-Json -Compress)
}

function Assert-WebHtmlContains {
    param([string]$Html, [string]$Needle, [string]$Label)
    if (-not $Html.Contains($Needle)) {
        throw "Web shell launch resilience injection missing: $Label"
    }
}

function Split-WasmForPages {
    param(
        [string]$SourcePath,
        [string]$DestinationDir,
        [int64]$ChunkBytes
    )
    if (-not (Test-Path -LiteralPath $SourcePath -PathType Leaf)) {
        throw "Required Godot Web runtime asset missing: $SourcePath"
    }
    if ($ChunkBytes -le 0 -or $ChunkBytes -ge 25MB) {
        throw "WasmChunkBytes must be greater than 0 and lower than 25 MiB. Got: $ChunkBytes"
    }

    $buffer = New-Object byte[] $ChunkBytes
    $chunks = New-Object System.Collections.Generic.List[string]
    $inputStream = [System.IO.File]::OpenRead($SourcePath)
    try {
        $index = 0
        while ($true) {
            $read = $inputStream.Read($buffer, 0, $buffer.Length)
            if ($read -le 0) {
                break
            }
            $chunkName = "index.wasm.part$index"
            $chunkPath = Join-Path $DestinationDir $chunkName
            $outputStream = [System.IO.File]::Open($chunkPath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            try {
                $outputStream.Write($buffer, 0, $read)
            } finally {
                $outputStream.Dispose()
            }
            $chunks.Add($chunkName) | Out-Null
            $index++
        }
    } finally {
        $inputStream.Dispose()
    }
    if ($chunks.Count -eq 0) {
        throw "WASM split produced no chunks: $SourcePath"
    }
    return @($chunks.ToArray())
}

function Convert-ChunkListToJavascriptArray {
    param([string[]]$Chunks, [string]$AssetBase, [string]$CacheBust)
    $values = @()
    foreach ($chunk in $Chunks) {
        $values += ConvertTo-JavascriptStringLiteral -Value ($AssetBase.TrimEnd("/") + "/" + $chunk + "?v=" + $CacheBust)
    }
    return "[" + ($values -join ",") + "]"
}

function Get-WasmChunkFetchShim {
    param([string[]]$Chunks, [string]$AssetBase, [string]$CacheBust)
    $chunkArray = Convert-ChunkListToJavascriptArray -Chunks $Chunks -AssetBase $AssetBase -CacheBust $CacheBust
    return @"
const DRAXOS_WASM_CHUNKS = Object.freeze($chunkArray);
(function installDraxosWasmChunkFetch() {
	const originalFetch = window.fetch.bind(window);
	function isGodotWasmRequest(input) {
		const rawUrl = typeof input === 'string' ? input : (input && input.url ? input.url : '');
		if (!rawUrl) {
			return false;
		}
		const url = new URL(rawUrl, window.location.href);
		return url.pathname.endsWith('/index.wasm') || url.pathname.endsWith('index.wasm');
	}
	window.fetch = async function draxosChunkedWasmFetch(input, init) {
		if (!isGodotWasmRequest(input)) {
			return originalFetch(input, init);
		}
		const chunks = [];
		let totalBytes = 0;
		for (const chunkUrl of DRAXOS_WASM_CHUNKS) {
			const response = await originalFetch(chunkUrl, { cache: 'no-store' });
			if (!response.ok) {
				throw new Error('DraxosMobile Web failed loading WASM chunk ' + chunkUrl + ' HTTP ' + response.status);
			}
			const bytes = new Uint8Array(await response.arrayBuffer());
			chunks.push(bytes);
			totalBytes += bytes.byteLength;
		}
		const merged = new Uint8Array(totalBytes);
		let offset = 0;
		for (const bytes of chunks) {
			merged.set(bytes, offset);
			offset += bytes.byteLength;
		}
		return new Response(merged, {
			status: 200,
			headers: {
				'Content-Type': 'application/wasm',
				'Content-Length': String(totalBytes),
				'Cache-Control': 'no-store',
			},
		});
	};
})();
"@
}

function Assert-WebShellMatchesRemoteAssets {
    param([string]$Html, [string]$AssetBase, [string]$PackUrl = "")
    if ($AssetBase -notmatch "^https?://") {
        return
    }
    $pckUrl = if ([string]::IsNullOrWhiteSpace($PackUrl)) { $AssetBase + "/index.pck" } else { $PackUrl }
    $remoteAssetUrls = @{
        "index.pck" = $pckUrl
        "index.wasm" = $AssetBase + "/index.wasm"
    }
    foreach ($fileName in @("index.pck", "index.wasm")) {
        $shellSize = Get-GodotWebFileSize -Html $Html -FileName $fileName
        $remoteUrl = $remoteAssetUrls[$fileName]
        $remoteSize = Get-RemoteContentLength -Url $remoteUrl
        if ($shellSize -ne $remoteSize) {
            throw "Web shell asset size mismatch for $fileName. publish/web/index.html says $shellSize bytes but $remoteUrl is $remoteSize bytes. Re-run export_internal_alpha.ps1 and publish_internal_alpha.ps1 -Mode Package in the same release worktree, or use a PublishDir generated from the uploaded Web asset root."
        }
    }
}

if ([string]::IsNullOrWhiteSpace($ProjectDir)) {
    $ProjectDir = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
} else {
    $ProjectDir = Resolve-ExistingDirectory -Path $ProjectDir -Label "ProjectDir"
}

if ([string]::IsNullOrWhiteSpace($PublishDir)) {
    $PublishDir = Join-Path $ProjectDir "build/internal-alpha/publish"
}
$PublishDir = Resolve-ExistingDirectory -Path $PublishDir -Label "PublishDir"

$alphaBuildRoot = Join-Path $ProjectDir "build/internal-alpha"
if (-not (Test-Path -LiteralPath $alphaBuildRoot -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $alphaBuildRoot | Out-Null
}
$alphaBuildRoot = (Resolve-Path -LiteralPath $alphaBuildRoot).Path

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    $OutputDir = Join-Path $alphaBuildRoot "cloudflare-pages"
}
Assert-UnderDirectory -Path $OutputDir -Root $alphaBuildRoot -Label "OutputDir"

if ([string]::IsNullOrWhiteSpace($ZipPath)) {
    $ZipPath = Join-Path $alphaBuildRoot "draxos-mobile-cloudflare-pages.zip"
}
$zipParent = Resolve-ParentDirectory -Path $ZipPath
Assert-UnderDirectory -Path $ZipPath -Root $alphaBuildRoot -Label "ZipPath"

$portalSource = Join-Path $PublishDir "portal"
$webSource = Join-Path $PublishDir "web"
$portalIndexSource = Join-Path $portalSource "index.html"
$webIndexSource = Join-Path $webSource "index.html"
foreach ($requiredPath in @($portalSource, $webSource, $portalIndexSource, $webIndexSource)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required publish artifact missing: $requiredPath"
    }
}

if (Test-Path -LiteralPath $OutputDir) {
    Remove-Item -LiteralPath $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $OutputDir "web") | Out-Null

Copy-Item -LiteralPath $portalSource -Destination (Join-Path $OutputDir "portal") -Recurse -Force
Get-ChildItem -LiteralPath $webSource -File |
    Where-Object { $_.Name -notin @("index.html", "index.wasm") } |
    ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $OutputDir "web/$($_.Name)") -Force
    }
$wasmChunks = Split-WasmForPages `
    -SourcePath (Join-Path $webSource "index.wasm") `
    -DestinationDir (Join-Path $OutputDir "web") `
    -ChunkBytes $WasmChunkBytes

$portalIndexPath = Join-Path $OutputDir "portal/index.html"
$portalHtml = Get-Content -Raw -LiteralPath $portalIndexPath
$portalHtml = $portalHtml.Replace("STATIC_HOST_PLACEHOLDER", "/web/index.html")
$portalHtml = $portalHtml.Replace("WEB_GAME_URL_PENDING_T03_P17", "/web/index.html")
$portalHtml = $portalHtml.Replace("STATIC_HOST_PENDING_T03_P17", "/web/index.html")
$portalHtml = [regex]::Replace(
    $portalHtml,
    "https://([a-f0-9]+\.)?draxos-mobile-internal-alpha\.pages\.dev/web/index\.html",
    "/web/index.html"
)
if ($portalHtml.Contains("WEB_GAME_URL_PENDING_T03_P17") -or
    $portalHtml.Contains("STATIC_HOST_PENDING_T03_P17") -or
    $portalHtml.Contains("STATIC_HOST_PLACEHOLDER")) {
    throw "Portal HTML still contains an unresolved Web game URL placeholder."
}
[System.IO.File]::WriteAllText($portalIndexPath, $portalHtml, [System.Text.UTF8Encoding]::new($false))

$assetBase = $StaticAssetBaseUrl.TrimEnd("/")
if ([string]::IsNullOrWhiteSpace($assetBase)) {
    $assetBase = "/web"
}
if (-not ($assetBase.StartsWith("http://") -or $assetBase.StartsWith("https://") -or $assetBase.StartsWith("/"))) {
    throw "StaticAssetBaseUrl must be an absolute URL or a root-relative path such as /web. Got: $assetBase"
}
$mainPack = $MainPackUrl.Trim()
$releaseRoot = $ReleaseRoot.Trim().Trim("/")
if ([string]::IsNullOrWhiteSpace($releaseRoot)) {
    $releaseRoot = Get-ReleaseRootFromAssetBase -AssetBase $assetBase
}
$cacheBust = Get-CacheBustValue -ReleaseRoot $releaseRoot
$webIndexPath = Join-Path $OutputDir "web/index.html"
$webHtml = Get-Content -Raw -LiteralPath $webIndexSource
$webHtml = [regex]::Replace(
    $webHtml,
    "(?s)\s*<script>\s*window\.DRAXOS_WEB_RELEASE\s*=\s*Object\.freeze\(\{.*?\}\);\s*</script>\s*",
    "`n"
)
$webHtml = $webHtml.Replace('href="index.icon.png"', ('href="/web/index.icon.png?v=' + $cacheBust + '"'))
$webHtml = $webHtml.Replace('href="index.apple-touch-icon.png"', ('href="/web/index.apple-touch-icon.png?v=' + $cacheBust + '"'))
$webHtml = $webHtml.Replace('src="index.png"', ('src="/web/index.png?v=' + $cacheBust + '"'))
$webHtml = $webHtml.Replace('<script src="index.js"></script>', ('<script src="/web/index.js?v=' + $cacheBust + '"></script>'))
$webHtml = $webHtml.Replace('"executable":"index"', ('"executable":"' + $assetBase + '/index"'))
if (-not [string]::IsNullOrWhiteSpace($mainPack)) {
    $webHtml = $webHtml.Replace('"experimentalVK":true', ('"mainPack":"' + $mainPack + '","experimentalVK":true'))
}
$releaseRootLiteral = ConvertTo-JavascriptStringLiteral -Value $releaseRoot
$assetBaseLiteral = ConvertTo-JavascriptStringLiteral -Value $assetBase
$wasmChunkFetchShim = Get-WasmChunkFetchShim -Chunks $wasmChunks -AssetBase $assetBase -CacheBust $cacheBust
$diagnosticsScript = @"
const DRAXOS_RELEASE_ROOT = $releaseRootLiteral;
const DRAXOS_WEB_ASSET_ROOT = $assetBaseLiteral;
window.DRAXOS_WEB_RELEASE = Object.freeze({
	releaseRoot: DRAXOS_RELEASE_ROOT,
	assetRoot: DRAXOS_WEB_ASSET_ROOT,
});
$wasmChunkFetchShim
"@
$webHtml = $webHtml.Replace("const GODOT_THREADS_ENABLED = false;", ($diagnosticsScript + "`nconst GODOT_THREADS_ENABLED = false;"))
$launchResilienceScript = @'
	const releaseStateKey = 'draxos.web.releaseRoot';
	const watchdogDelayMs = 20000;
	let launchWatchdog = 0;

	function clearLaunchWatchdog() {
		if (launchWatchdog !== 0) {
			window.clearTimeout(launchWatchdog);
			launchWatchdog = 0;
		}
	}

	function cleanupOldWebRuntimeCaches() {
		let previousRelease = '';
		try {
			previousRelease = window.localStorage.getItem(releaseStateKey) || '';
			window.localStorage.setItem(releaseStateKey, DRAXOS_RELEASE_ROOT);
		} catch (err) {
			console.warn('[DraxosMobile Web] Release cache marker unavailable:', err);
			return;
		}
		if (previousRelease === '' || previousRelease === DRAXOS_RELEASE_ROOT) {
			return;
		}
		console.info('[DraxosMobile Web] Release root changed; cleaning old Web runtime caches.', {
			previousRelease,
			currentRelease: DRAXOS_RELEASE_ROOT,
		});
		if ('caches' in window) {
			window.caches.keys().then((keys) => Promise.all(keys
				.filter((key) => /draxos|godot|internal-alpha|web/i.test(key))
				.map((key) => window.caches.delete(key))
			)).catch((err) => {
				console.warn('[DraxosMobile Web] Cache cleanup failed:', err);
			});
		}
		if ('serviceWorker' in navigator) {
			navigator.serviceWorker.getRegistrations().then((registrations) => Promise.all(registrations
				.filter((registration) => registration.scope.indexOf(window.location.origin) === 0)
				.map((registration) => registration.unregister())
			)).catch((err) => {
				console.warn('[DraxosMobile Web] Service worker cleanup failed:', err);
			});
		}
	}

	function startLaunchWatchdog() {
		clearLaunchWatchdog();
		launchWatchdog = window.setTimeout(() => {
			if (!initializing) {
				return;
			}
			const message = [
				'DraxosMobile ainda esta carregando.',
				'Se esta tela ficar parada, faca hard refresh, abra o preview hash da publicacao ou limpe os dados deste site.',
				'Release: ' + DRAXOS_RELEASE_ROOT,
				'Assets: ' + DRAXOS_WEB_ASSET_ROOT,
			].join('\n');
			console.warn('[DraxosMobile Web] Launch watchdog still sees the Godot splash.', window.DRAXOS_WEB_RELEASE);
			setStatusNotice(message);
			setStatusMode('notice');
		}, watchdogDelayMs);
	}

	cleanupOldWebRuntimeCaches();
'@
$webHtml = $webHtml.Replace("	let statusMode = '';", "	let statusMode = '';`n$launchResilienceScript")
$webHtml = $webHtml.Replace("		if (mode === 'hidden') {", "		if (mode === 'hidden') {`n			clearLaunchWatchdog();")
$webHtml = $webHtml.Replace("	function displayFailureNotice(err) {", "	function displayFailureNotice(err) {`n		clearLaunchWatchdog();")
$webHtml = $webHtml.Replace("		console.error(err);", "		console.error('[DraxosMobile Web] Godot start failed:', err);")
$webHtml = $webHtml.Replace("			setStatusNotice('An unknown error occurred.');", "			setStatusNotice('DraxosMobile nao conseguiu iniciar no navegador. Abra o console para detalhes e tente atualizar a pagina.');")
$webHtml = $webHtml.Replace("		setStatusMode('progress');", "		setStatusMode('progress');`n		startLaunchWatchdog();")
$webHtml = $webHtml.Replace("		}).then(() => {", "		}).then(() => {`n			console.info('[DraxosMobile Web] Godot start resolved.', window.DRAXOS_WEB_RELEASE);")
Assert-WebHtmlContains -Html $webHtml -Needle "/web/index.js?v=$cacheBust" -Label "index.js cache bust"
Assert-WebHtmlContains -Html $webHtml -Needle "/web/index.png?v=$cacheBust" -Label "splash cache bust"
Assert-WebHtmlContains -Html $webHtml -Needle "const DRAXOS_RELEASE_ROOT" -Label "release root diagnostic"
Assert-WebHtmlContains -Html $webHtml -Needle "const DRAXOS_WEB_ASSET_ROOT" -Label "asset root diagnostic"
Assert-WebHtmlContains -Html $webHtml -Needle "DRAXOS_WASM_CHUNKS" -Label "chunked wasm fetch shim"
Assert-WebHtmlContains -Html $webHtml -Needle "draxos.web.releaseRoot" -Label "release cache marker"
Assert-WebHtmlContains -Html $webHtml -Needle "startLaunchWatchdog();" -Label "launch watchdog call"
Assert-WebHtmlContains -Html $webHtml -Needle "Godot start failed" -Label "readable start failure log"
Assert-WebShellMatchesRemoteAssets -Html $webHtml -AssetBase $assetBase -PackUrl $mainPack
[System.IO.File]::WriteAllText($webIndexPath, $webHtml, [System.Text.UTF8Encoding]::new($false))

# Flat root files make Cloudflare direct upload more forgiving when a browser
# upload loses nested folders. The canonical Portal URL is /; /portal/index.html
# and /web/index.html remain compatibility paths through _redirects rewrites.
[System.IO.File]::WriteAllText((Join-Path $OutputDir "index.html"), $portalHtml, [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText((Join-Path $OutputDir "web.html"), $webHtml, [System.Text.UTF8Encoding]::new($false))

$redirects = @'
/portal/index.html / 302
/portal/ / 302
/portal / 302
/web/index.html /web 302
/web/ /web 302
'@
[System.IO.File]::WriteAllText((Join-Path $OutputDir "_redirects"), $redirects, [System.Text.UTF8Encoding]::new($false))

$headers = @'
/*
  Cache-Control: no-store

/portal/*
  Cache-Control: no-store

/web
  Cache-Control: no-store

/web/*
  Cache-Control: no-store
'@
[System.IO.File]::WriteAllText((Join-Path $OutputDir "_headers"), $headers, [System.Text.UTF8Encoding]::new($false))

$oversizedFiles = Get-ChildItem -LiteralPath $OutputDir -Recurse -File |
    Where-Object { $_.Length -ge 25MB } |
    Select-Object FullName, Length
if ($oversizedFiles) {
    $details = ($oversizedFiles | ForEach-Object { "$($_.FullName) ($($_.Length) bytes)" }) -join "; "
    throw "Cloudflare Pages package still has files >= 25 MiB: $details"
}

if (Test-Path -LiteralPath $ZipPath) {
    Remove-Item -LiteralPath $ZipPath -Force
}
Compress-Archive -Path (Join-Path $OutputDir "*") -DestinationPath $ZipPath -Force

$fileCount = (Get-ChildItem -LiteralPath $OutputDir -Recurse -File | Measure-Object).Count
$zipInfo = Get-Item -LiteralPath $ZipPath
Write-Host "Cloudflare Pages package ready:"
Write-Host "  Folder: $OutputDir"
Write-Host "  Zip:    $($zipInfo.FullName)"
Write-Host "  Files:  $fileCount"
Write-Host "  Zip bytes: $($zipInfo.Length)"
