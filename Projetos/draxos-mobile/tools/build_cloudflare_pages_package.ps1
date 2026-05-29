param(
    [string]$ProjectDir = "",
    [string]$PublishDir = "",
    [string]$OutputDir = "",
    [string]$ZipPath = "",
    [string]$StaticAssetBaseUrl = "https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0/web"
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

function Assert-WebShellMatchesRemoteAssets {
    param([string]$Html, [string]$AssetBase)
    if ($AssetBase -notmatch "^https?://") {
        return
    }
    foreach ($fileName in @("index.pck", "index.wasm")) {
        $shellSize = Get-GodotWebFileSize -Html $Html -FileName $fileName
        $remoteSize = Get-RemoteContentLength -Url ($AssetBase + "/" + $fileName)
        if ($shellSize -ne $remoteSize) {
            throw "Web shell asset size mismatch for $fileName. publish/web/index.html says $shellSize bytes but $AssetBase/$fileName is $remoteSize bytes. Re-run export_internal_alpha.ps1 and publish_internal_alpha.ps1 -Mode Package in the same release worktree, or use a PublishDir generated from the uploaded Web asset root."
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

$portalIndexPath = Join-Path $OutputDir "portal/index.html"
$portalHtml = Get-Content -Raw -LiteralPath $portalIndexPath
$portalHtml = $portalHtml.Replace("STATIC_HOST_PLACEHOLDER", "/web/index.html")
[System.IO.File]::WriteAllText($portalIndexPath, $portalHtml, [System.Text.UTF8Encoding]::new($false))

$assetBase = $StaticAssetBaseUrl.TrimEnd("/")
$webIndexPath = Join-Path $OutputDir "web/index.html"
$webHtml = Get-Content -Raw -LiteralPath $webIndexSource
$webHtml = $webHtml.Replace('href="index.icon.png"', ('href="' + $assetBase + '/index.icon.png"'))
$webHtml = $webHtml.Replace('href="index.apple-touch-icon.png"', ('href="' + $assetBase + '/index.apple-touch-icon.png"'))
$webHtml = $webHtml.Replace('src="index.png"', ('src="' + $assetBase + '/index.png"'))
$webHtml = $webHtml.Replace('<script src="index.js"></script>', ('<script src="' + $assetBase + '/index.js"></script>'))
$webHtml = $webHtml.Replace('"executable":"index"', ('"executable":"' + $assetBase + '/index"'))
Assert-WebShellMatchesRemoteAssets -Html $webHtml -AssetBase $assetBase
[System.IO.File]::WriteAllText($webIndexPath, $webHtml, [System.Text.UTF8Encoding]::new($false))

# Flat root files make Cloudflare direct upload more forgiving when a browser
# upload loses nested folders. The canonical URLs remain /portal/index.html and
# /web/index.html through _redirects rewrites.
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
