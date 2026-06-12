param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GodotExe = "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe",
    [string]$ProjectName = "copa-arena-futebol",
    [string]$ReleaseRoot = "",
    [string]$Branch = "main",
    [ValidateSet("Plan", "Package", "FullPublish")]
    [string]$Mode = "Plan",
    [switch]$ConfirmRemoteMutation,
    [switch]$SkipExport
)

$ErrorActionPreference = "Stop"

$PagesAssetLimitBytes = 25 * 1024 * 1024

function Write-TextUtf8NoBom {
    param([string]$Path, [string]$Text)
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
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

function Get-GitShortSha {
    param([string]$Root)
    $sha = (& git -C $Root rev-parse --short=8 HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $sha.Length -eq 0) {
        throw "Unable to resolve git short SHA for $Root."
    }
    return $sha
}

function Get-GitFullSha {
    param([string]$Root)
    $sha = (& git -C $Root rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $sha.Length -eq 0) {
        throw "Unable to resolve git SHA for $Root."
    }
    return $sha
}

function Assert-VersionedReleaseRoot {
    param([string]$Root)
    $normalized = $Root.Trim().Trim("/")
    if ($normalized.Length -eq 0) {
        throw "ReleaseRoot is required for Mode $Mode. Use web/v1-copa-arena-futebol-YYYYMMDD-<shortsha>."
    }
    if ($normalized -notmatch '^web/v1-[a-z0-9][a-z0-9._-]*-[0-9]{8}-[0-9a-f]{7,}$') {
        throw "ReleaseRoot must match web/v1-<slug>-YYYYMMDD-<shortsha>. Got: $Root"
    }
    return $normalized
}

function Get-ArtifactRecord {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required artifact is missing: $Path"
    }
    $item = Get-Item -LiteralPath $Path
    return [ordered]@{
        label = $Label
        path = $item.FullName
        bytes = $item.Length
        sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

function ConvertTo-JavascriptStringLiteral {
    param([string]$Value)
    return ($Value | ConvertTo-Json -Compress)
}

function Write-WebReleaseDiagnostics {
    param(
        [string]$IndexPath,
        [string]$VersionedReleaseRoot,
        [string]$Name
    )
    if (-not (Test-Path -LiteralPath $IndexPath -PathType Leaf)) {
        throw "Web index is missing for release diagnostics: $IndexPath"
    }
    $html = Get-Content -LiteralPath $IndexPath -Raw
    $releaseRootLiteral = ConvertTo-JavascriptStringLiteral -Value $VersionedReleaseRoot
    $projectNameLiteral = ConvertTo-JavascriptStringLiteral -Value $Name
    $generatedAtLiteral = ConvertTo-JavascriptStringLiteral -Value ((Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"))
    $diagnostics = @"
<script>
window.JDC_WEB_RELEASE = Object.freeze({
	releaseRoot: $releaseRootLiteral,
	projectName: $projectNameLiteral,
	generatedAt: $generatedAtLiteral,
	packageStrategy: "cloudflare_pages_brotli_assets"
});
</script>
"@
    $diagnosticsPattern = '(?s)<script>\s*window\.JDC_WEB_RELEASE\s*=\s*Object\.freeze\(\{.*?\}\);\s*</script>'
    if ([regex]::IsMatch($html, $diagnosticsPattern)) {
        $html = [regex]::Replace($html, $diagnosticsPattern, $diagnostics)
    } elseif ($html.Contains("</head>")) {
        $html = $html.Replace("</head>", "$diagnostics`n`t</head>")
    } else {
        $html = $diagnostics + $html
    }
    Write-TextUtf8NoBom -Path $IndexPath -Text $html
}

function Invoke-NodeBrotli {
    param([string]$SourcePath, [string]$DestinationPath)
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
        throw "Node.js is required for Brotli packaging but was not found on PATH."
    }
    $tempScript = Join-Path ([System.IO.Path]::GetTempPath()) ("jdc-brotli-" + [guid]::NewGuid().ToString("N") + ".js")
    $code = @'
const fs = require("fs");
const zlib = require("zlib");
const source = process.argv[2];
const destination = process.argv[3];
const input = fs.readFileSync(source);
const output = zlib.brotliCompressSync(input, {
  params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 11 }
});
fs.writeFileSync(destination, output);
'@
    try {
        Write-TextUtf8NoBom -Path $tempScript -Text $code
        & node $tempScript $SourcePath $DestinationPath
        if ($LASTEXITCODE -ne 0) {
            throw "Node Brotli compression failed for $SourcePath."
        }
    } finally {
        if (Test-Path -LiteralPath $tempScript -PathType Leaf) {
            Remove-Item -LiteralPath $tempScript -Force
        }
    }
}

function Invoke-GodotWebExport {
    param([string]$Root, [string]$GodotPath)
    if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
        throw "Godot executable not found: $GodotPath"
    }
    $webDir = Join-Path $Root "builds\web"
    $logDir = Join-Path $Root "builds\web-publication"
    New-Item -ItemType Directory -Force -Path $webDir | Out-Null
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    $logPath = Join-Path $logDir "last-web-export.log"
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $GodotPath --headless --path $Root --export-release "Web" "builds/web/index.html" *> $logPath
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
    if ($exitCode -ne 0) {
        Get-Content -LiteralPath $logPath -Tail 80 | ForEach-Object { Write-Host $_ }
        throw "Godot Web release export failed with exit code $exitCode."
    }
    $script:LastWebExportLog = $logPath
    Write-Host "Godot Web release export passed. Log: $logPath"
}

function Copy-WebPackage {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )
    if (-not (Test-Path -LiteralPath $SourceDir -PathType Container)) {
        throw "Web export directory not found: $SourceDir"
    }
    if (Test-Path -LiteralPath $DestinationDir -PathType Container) {
        Remove-Item -LiteralPath $DestinationDir -Recurse -Force
    }
    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null

    foreach ($file in Get-ChildItem -LiteralPath $SourceDir -File) {
        if ($file.Extension.ToLowerInvariant() -eq ".import") {
            continue
        }
        $target = Join-Path $DestinationDir $file.Name
        if ($file.Name -in @("index.pck", "index.wasm")) {
            Invoke-NodeBrotli -SourcePath $file.FullName -DestinationPath $target
        } else {
            Copy-Item -LiteralPath $file.FullName -Destination $target -Force
        }
    }

    $headers = @'
/*
  X-Content-Type-Options: nosniff

/
  Cache-Control: no-store

/index.html
  Cache-Control: no-store

/index.js
  Cache-Control: no-store

/index.pck
  Content-Encoding: br
  Content-Type: application/octet-stream
  Cache-Control: public, max-age=31536000, immutable

/index.wasm
  Content-Encoding: br
  Content-Type: application/wasm
  Cache-Control: public, max-age=31536000, immutable
'@
    Write-TextUtf8NoBom -Path (Join-Path $DestinationDir "_headers") -Text ($headers + [Environment]::NewLine)
}

function New-ZipFromDirectory {
    param([string]$Directory, [string]$ZipPath)
    $zipParent = Split-Path -Parent $ZipPath
    if (-not (Test-Path -LiteralPath $zipParent -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $zipParent | Out-Null
    }
    if (Test-Path -LiteralPath $ZipPath -PathType Leaf) {
        Remove-Item -LiteralPath $ZipPath -Force
    }
    Compress-Archive -Path (Join-Path $Directory "*") -DestinationPath $ZipPath -Force
}

function New-Package {
    param(
        [string]$Root,
        [string]$VersionedReleaseRoot,
        [string]$GodotPath,
        [bool]$DoExport
    )
    $buildRoot = Join-Path $Root "builds\web-publication"
    New-Item -ItemType Directory -Force -Path $buildRoot | Out-Null
    $buildRoot = (Resolve-Path -LiteralPath $buildRoot).Path

    $releaseKey = $VersionedReleaseRoot -replace '[\\/]', '_'
    $releaseBuildDir = Join-Path $buildRoot $releaseKey
    $pagesDir = Join-Path $releaseBuildDir "pages"
    $zipPath = Join-Path $releaseBuildDir "copa-arena-futebol-pages.zip"
    Assert-UnderDirectory -Path $releaseBuildDir -Root $buildRoot -Label "ReleaseBuildDir"
    Assert-UnderDirectory -Path $pagesDir -Root $buildRoot -Label "PagesDir"
    Assert-UnderDirectory -Path $zipPath -Root $buildRoot -Label "ZipPath"
    if (Test-Path -LiteralPath $releaseBuildDir -PathType Container) {
        Remove-Item -LiteralPath $releaseBuildDir -Recurse -Force
    }
    Write-TextUtf8NoBom -Path (Join-Path $Root "builds\.gdignore") -Text ""

    if ($DoExport) {
        Invoke-GodotWebExport -Root $Root -GodotPath $GodotPath
    }

    $sourceDir = Join-Path $Root "builds\web"
    Copy-WebPackage -SourceDir $sourceDir -DestinationDir $pagesDir
    Write-WebReleaseDiagnostics `
        -IndexPath (Join-Path $pagesDir "index.html") `
        -VersionedReleaseRoot $VersionedReleaseRoot `
        -Name $ProjectName
    New-ZipFromDirectory -Directory $pagesDir -ZipPath $zipPath

    $oversizedFiles = Get-ChildItem -LiteralPath $pagesDir -Recurse -File |
        Where-Object { $_.Length -ge $script:PagesAssetLimitBytes }
    if ($oversizedFiles) {
        $details = ($oversizedFiles | ForEach-Object { "$($_.FullName) ($($_.Length) bytes)" }) -join "; "
        throw "Cloudflare Pages package has files >= 25 MiB: $details"
    }

    $rawRecords = @(
        (Get-ArtifactRecord -Path (Join-Path $sourceDir "index.html") -Label "raw index.html"),
        (Get-ArtifactRecord -Path (Join-Path $sourceDir "index.pck") -Label "raw index.pck"),
        (Get-ArtifactRecord -Path (Join-Path $sourceDir "index.wasm") -Label "raw index.wasm")
    )
    $packageRecords = @(
        (Get-ArtifactRecord -Path (Join-Path $pagesDir "index.html") -Label "pages index.html"),
        (Get-ArtifactRecord -Path (Join-Path $pagesDir "index.pck") -Label "pages index.pck brotli"),
        (Get-ArtifactRecord -Path (Join-Path $pagesDir "index.wasm") -Label "pages index.wasm brotli"),
        (Get-ArtifactRecord -Path (Join-Path $pagesDir "_headers") -Label "pages _headers"),
        (Get-ArtifactRecord -Path $zipPath -Label "pages zip")
    )
    $report = [ordered]@{
        schema_version = "jogodacopa_web_publication_package_v1"
        generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        project = "JogoDaCopa"
        product_name = "Copa Arena Futebol"
        cloudflare_pages_project = $ProjectName
        release_root = $VersionedReleaseRoot
        pages_asset_limit_bytes = $script:PagesAssetLimitBytes
        package_strategy = "index.pck and index.wasm are stored Brotli-compressed under original file names and served with Content-Encoding: br"
        source_dir = (Resolve-Path -LiteralPath $sourceDir).Path
        pages_dir = (Resolve-Path -LiteralPath $pagesDir).Path
        zip_path = $zipPath
        export_log = $script:LastWebExportLog
        raw_artifacts = $rawRecords
        package_artifacts = $packageRecords
    }
    $reportPath = Join-Path $releaseBuildDir "package-report.json"
    Write-TextUtf8NoBom -Path $reportPath -Text (($report | ConvertTo-Json -Depth 8) + [Environment]::NewLine)
    $report.package_report = $reportPath
    return $report
}

function Invoke-Wrangler {
    param([string[]]$Arguments)
    $oldCi = [Environment]::GetEnvironmentVariable("CI", "Process")
    [Environment]::SetEnvironmentVariable("CI", "1", "Process")
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & npx --yes wrangler@latest @Arguments 2>&1
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
        [Environment]::SetEnvironmentVariable("CI", $oldCi, "Process")
    }
    $text = ($output | Out-String).Trim()
    if ($exitCode -ne 0) {
        if ($text -match '(?i)login|log in|authentication|not authenticated|not logged in|unauthorized') {
            throw "Wrangler requires login/authentication. Stop here and ask Fabio to authenticate Wrangler. Output: $text"
        }
        throw "Wrangler failed with exit code $exitCode. Output: $text"
    }
    return $text
}

function Ensure-PagesProject {
    param([string]$Name, [string]$ProductionBranch)
    $listText = Invoke-Wrangler -Arguments @("pages", "project", "list", "--json")
    $projects = @()
    if ($listText.Length -gt 0) {
        $projects = @($listText | ConvertFrom-Json)
    }
    $existing = $projects | Where-Object { $_.name -eq $Name -or $_."Project Name" -eq $Name } | Select-Object -First 1
    if ($existing) {
        return [ordered]@{
            created = $false
            name = $Name
        }
    }

    try {
        $createText = Invoke-Wrangler -Arguments @(
            "pages", "project", "create", $Name,
            "--production-branch", $ProductionBranch
        )
    } catch {
        if ($_.Exception.Message -match '(?i)already exists|8000002') {
            return [ordered]@{
                created = $false
                name = $Name
                output = "Project already existed during create."
            }
        }
        throw
    }
    return [ordered]@{
        created = $true
        name = $Name
        output = $createText
    }
}

function Deploy-Pages {
    param(
        [string]$Directory,
        [string]$Name,
        [string]$DeployBranch,
        [string]$CommitHash,
        [string]$Message
    )
    $deployText = Invoke-Wrangler -Arguments @(
        "pages", "deploy", $Directory,
        "--project-name", $Name,
        "--branch", $DeployBranch,
        "--commit-hash", $CommitHash,
        "--commit-message", $Message,
        "--commit-dirty=false"
    )
    $urls = @([regex]::Matches($deployText, 'https://[^\s)"]+\.pages\.dev[^\s)"]*') | ForEach-Object { $_.Value.TrimEnd(".") } | Select-Object -Unique)
    return [ordered]@{
        output = $deployText
        urls = $urls
        url = $(if ($urls.Count -gt 0) { $urls[0] } else { "" })
    }
}

$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $ProjectDir "..\..")).Path
$shortSha = Get-GitShortSha -Root $repoRoot
$fullSha = Get-GitFullSha -Root $repoRoot
$today = Get-Date -Format "yyyyMMdd"
$suggestedReleaseRoot = "web/v1-copa-arena-futebol-$today-$shortSha"
$buildRoot = Join-Path $ProjectDir "builds\web-publication"
New-Item -ItemType Directory -Force -Path $buildRoot | Out-Null

$isRemoteMutation = $Mode -eq "FullPublish"
if ($isRemoteMutation -and -not $ConfirmRemoteMutation) {
    throw "Mode FullPublish mutates Cloudflare Pages. Re-run with -ConfirmRemoteMutation after reviewing Package output."
}

if ($Mode -eq "Plan") {
    $plan = [ordered]@{
        schema_version = "jogodacopa_web_publication_plan_v1"
        generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        mode = $Mode
        project_dir = $ProjectDir
        cloudflare_pages_project = $ProjectName
        production_branch = $Branch
        remote_mutation = $false
        suggested_release_root = $suggestedReleaseRoot
        pages_asset_limit_bytes = $PagesAssetLimitBytes
        package_strategy = "Package mode exports Web release, Brotli-compresses index.pck and index.wasm in-place for Pages, writes _headers, verifies every uploaded file is < 25 MiB."
        next_commands = @(
            ".\tools\publish_web.ps1 -Mode Package -ReleaseRoot $suggestedReleaseRoot",
            ".\tools\publish_web.ps1 -Mode FullPublish -ReleaseRoot $suggestedReleaseRoot -ConfirmRemoteMutation"
        )
    }
    $planPath = Join-Path $buildRoot "release-plan.json"
    Write-TextUtf8NoBom -Path $planPath -Text (($plan | ConvertTo-Json -Depth 8) + [Environment]::NewLine)
    Write-Host "[publish-web] Plan generated. No export, package, deploy or remote verification was executed."
    Write-Host "Suggested ReleaseRoot: $suggestedReleaseRoot"
    Write-Host "Plan: $planPath"
    exit 0
}

$ReleaseRoot = Assert-VersionedReleaseRoot -Root $ReleaseRoot
$package = New-Package -Root $ProjectDir -VersionedReleaseRoot $ReleaseRoot -GodotPath $GodotExe -DoExport (-not $SkipExport.IsPresent)

$evidenceDir = Join-Path $ProjectDir "docs\playtest-reports\track-05-data"
New-Item -ItemType Directory -Force -Path $evidenceDir | Out-Null
$evidenceName = if ($Mode -eq "FullPublish") { "05c-publication-report.json" } else { "05b-package-artifacts.json" }
$evidencePath = Join-Path $evidenceDir $evidenceName

if ($Mode -eq "Package") {
    Write-TextUtf8NoBom -Path $evidencePath -Text (($package | ConvertTo-Json -Depth 8) + [Environment]::NewLine)
    Write-Host "[publish-web] Package ready. No Cloudflare project creation or deploy was executed."
    Write-Host "ReleaseRoot: $ReleaseRoot"
    Write-Host "Pages dir: $($package.pages_dir)"
    Write-Host "Zip: $($package.zip_path)"
    Write-Host "Evidence: $evidencePath"
    exit 0
}

$projectResult = Ensure-PagesProject -Name $ProjectName -ProductionBranch $Branch
$deployResult = Deploy-Pages `
    -Directory $package.pages_dir `
    -Name $ProjectName `
    -DeployBranch $Branch `
    -CommitHash $fullSha `
    -Message "JogoDaCopa Track 05 Web Publication V1 $ReleaseRoot"

$publication = [ordered]@{
    schema_version = "jogodacopa_web_publication_v1"
    generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    cloudflare_pages_project = $ProjectName
    project_created = $projectResult.created
    branch = $Branch
    release_root = $ReleaseRoot
    commit_hash = $fullSha
    package = $package
    deployment_url = $deployResult.url
    deployment_urls = $deployResult.urls
    wrangler_deploy_output = $deployResult.output
}
Write-TextUtf8NoBom -Path $evidencePath -Text (($publication | ConvertTo-Json -Depth 12) + [Environment]::NewLine)
Write-Host "[publish-web] FullPublish complete."
Write-Host "Project: $ProjectName"
Write-Host "ReleaseRoot: $ReleaseRoot"
Write-Host "URL: $($deployResult.url)"
Write-Host "Evidence: $evidencePath"
