param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$EnvFile = "",
    [string]$BucketName = "draxos-internal-alpha",
    [string]$ReleaseRoot = "internal-alpha/v0",
    [string]$StaticSiteBaseUrl = "",
    [switch]$UseManifestSecret,
    [switch]$SkipUpload,
    [switch]$SkipManifestSecret
)

$ErrorActionPreference = "Stop"

function Read-DotEnv {
    param([string]$Path)
    $values = @{}
    if (-not (Test-Path -LiteralPath $Path)) {
        return $values
    }
    foreach ($rawLine in Get-Content -LiteralPath $Path) {
        $line = $rawLine.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith("#") -or -not $line.Contains("=")) {
            continue
        }
        $parts = $line.Split("=", 2)
        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"')
        if ($key.Length -gt 0) {
            $values[$key] = $value
        }
    }
    return $values
}

function Env-Value {
    param(
        [hashtable]$Values,
        [string[]]$Keys,
        [string]$Fallback = ""
    )
    foreach ($key in $Keys) {
        $processValue = [Environment]::GetEnvironmentVariable($key, "Process")
        if ($processValue -and $processValue.Trim().Length -gt 0) {
            return $processValue.Trim()
        }
        if ($Values.ContainsKey($key) -and [string]$Values[$key] -ne "") {
            return ([string]$Values[$key]).Trim()
        }
    }
    return $Fallback
}

function Assert-Client-Key {
    param([string]$Key)
    $normalized = $Key.Trim().ToLowerInvariant()
    if ($normalized.Length -eq 0) {
        throw "SUPABASE_PUBLISHABLE_KEY or DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY is required."
    }
    if ($normalized.StartsWith("sb_secret_") -or
        $normalized.StartsWith("sb_service_") -or
        $normalized.Contains("service_role") -or
        $normalized.Contains("secret")) {
        throw "Publication refuses service role or secret-like Supabase keys for client/manifest validation."
    }
}

function Invoke-Supabase {
    param([string[]]$Arguments)
    & npx -y supabase @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Supabase CLI failed with exit code $LASTEXITCODE`: supabase $($Arguments -join ' ')"
    }
}

function Invoke-SupabaseOptional {
    param([string[]]$Arguments)
    $previousErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & npx -y supabase @Arguments *> $null
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }
}

function Content-TypeFor {
    param([string]$Path)
    $extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()
    switch ($extension) {
        ".html" { return "text/html; charset=utf-8" }
        ".js" { return "application/javascript; charset=utf-8" }
        ".json" { return "application/json; charset=utf-8" }
        ".wasm" { return "application/wasm" }
        ".pck" { return "application/octet-stream" }
        ".apk" { return "application/vnd.android.package-archive" }
        ".zip" { return "application/zip" }
        ".png" { return "image/png" }
        ".txt" { return "text/plain; charset=utf-8" }
        default { return "application/octet-stream" }
    }
}

function Copy-DirectoryFiles {
    param(
        [string]$SourceDir,
        [string]$DestinationDir,
        [string[]]$ExcludeExtensions = @()
    )
    New-Item -ItemType Directory -Force -Path $DestinationDir | Out-Null
    foreach ($file in Get-ChildItem -LiteralPath $SourceDir -File) {
        if ($ExcludeExtensions -contains $file.Extension.ToLowerInvariant()) {
            continue
        }
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $DestinationDir $file.Name) -Force
    }
}

function File-Record {
    param(
        [string]$Path,
        [string]$Label,
        [string]$Url
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Expected artifact is missing: $Path"
    }
    $item = Get-Item -LiteralPath $Path
    return [ordered]@{
        label = $Label
        path = $item.FullName
        url = $Url
        bytes = $item.Length
        sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

function Assert-UrlOk {
    param(
        [string]$Url,
        [string]$Label,
        [string]$ExpectedText = ""
    )
    $response = Invoke-WebRequest -Method Get -Uri $Url -UseBasicParsing
    if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
        throw "$Label returned HTTP $($response.StatusCode): $Url"
    }
    if ($ExpectedText -ne "" -and -not $response.Content.Contains($ExpectedText)) {
        throw "$Label does not contain expected text: $ExpectedText"
    }
}

function Assert-HeadOk {
    param(
        [string]$Url,
        [string]$Label,
        [long]$ExpectedMinimumBytes
    )
    $response = Invoke-WebRequest -Method Head -Uri $Url -UseBasicParsing
    if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
        throw "$Label returned HTTP $($response.StatusCode): $Url"
    }
    $lengthHeader = $response.Headers["Content-Length"]
    if ($lengthHeader -and [long]$lengthHeader -lt $ExpectedMinimumBytes) {
        throw "$Label content length is smaller than expected."
    }
}

$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
if ($EnvFile -eq "") {
    $EnvFile = Join-Path $ProjectDir ".env.internal-alpha.local"
}

$envValues = Read-DotEnv -Path $EnvFile
$projectRef = Env-Value $envValues @("SUPABASE_PROJECT_REF")
$supabaseUrl = (Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_URL", "SUPABASE_URL")).TrimEnd("/")
$publishableKey = Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY", "SUPABASE_PUBLISHABLE_KEY")

if ($projectRef.Trim().Length -eq 0) {
    throw "SUPABASE_PROJECT_REF is required."
}
if (-not $supabaseUrl.StartsWith("https://")) {
    throw "Publication requires an https Supabase URL."
}
Assert-Client-Key -Key $publishableKey

$buildDir = Join-Path $ProjectDir "build"
$androidApk = Join-Path $buildDir "android\draxos-mobile-alpha.apk"
$pcZip = Join-Path $buildDir "pc\draxos-mobile-alpha.zip"
$webDir = Join-Path $buildDir "web"
$portalDir = Join-Path $ProjectDir "portal\internal-alpha"
$publishDir = Join-Path $buildDir "internal-alpha\publish"
$portalPublishDir = Join-Path $publishDir "portal"
$webPublishDir = Join-Path $publishDir "web"
$downloadsPublishDir = Join-Path $publishDir "downloads"
New-Item -ItemType Directory -Force -Path $portalPublishDir, $webPublishDir, $downloadsPublishDir | Out-Null

$storageBaseUrl = "$supabaseUrl/storage/v1/object/public/$BucketName/$ReleaseRoot"
$normalizedStaticSiteBaseUrl = $StaticSiteBaseUrl.Trim().TrimEnd("/")
$portalUrl = ""
$webUrl = ""
if ($normalizedStaticSiteBaseUrl -ne "") {
    $portalUrl = "$normalizedStaticSiteBaseUrl/portal/index.html"
    $webUrl = "$normalizedStaticSiteBaseUrl/web/index.html"
}
$androidUrl = "$storageBaseUrl/downloads/draxos-mobile-alpha.apk"
$pcUrl = "$storageBaseUrl/downloads/draxos-mobile-alpha.zip"

Copy-DirectoryFiles -SourceDir $webDir -DestinationDir $webPublishDir -ExcludeExtensions @(".import")
Copy-Item -LiteralPath $androidApk -Destination (Join-Path $downloadsPublishDir "draxos-mobile-alpha.apk") -Force
Copy-Item -LiteralPath $pcZip -Destination (Join-Path $downloadsPublishDir "draxos-mobile-alpha.zip") -Force

$androidRecord = File-Record -Path (Join-Path $downloadsPublishDir "draxos-mobile-alpha.apk") -Label "Android APK" -Url $androidUrl
$pcRecord = File-Record -Path (Join-Path $downloadsPublishDir "draxos-mobile-alpha.zip") -Label "PC Windows ZIP" -Url $pcUrl
$webRecord = File-Record -Path (Join-Path $webPublishDir "index.html") -Label "Web Index" -Url $webUrl

$manifest = [ordered]@{
    schema_version = "internal_alpha_manifest_v1"
    channel = "internal_alpha"
    latest_version = "0.0.1-alpha.0"
    latest_version_code = 1
    minimum_supported_version = "0.0.1-alpha.0"
    minimum_supported_version_code = 1
    released_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    requires_save_reset = $false
    portal_url = $portalUrl
    notes = @(
        "Primeira release candidate interna.",
        "APK Android e PC ZIP compartilham o mesmo backend remoto.",
        "Portal/Web precisam de host estatico externo; Supabase Storage/Edge Functions nao servem HTML como pagina.",
        "Progression Lab usa save separado e nao pontua ranking."
    )
    artifacts = [ordered]@{
        android = [ordered]@{
            label = "Android APK"
            url = $androidUrl
            sha256 = $androidRecord.sha256
        }
        pc_windows = [ordered]@{
            label = "PC Windows ZIP"
            url = $pcUrl
            sha256 = $pcRecord.sha256
        }
        web = [ordered]@{
            label = "Web"
            url = $webUrl
        }
    }
    known_issues = @(
        "Layout Android paisagem ainda precisa de ergonomia real no aparelho.",
        "APK desta publicacao usa debug_fallback enquanto a keystore release dedicada nao estiver configurada.",
        "Link Web/Portal aguarda publicacao em host estatico externo."
    )
}

$manifestJson = $manifest | ConvertTo-Json -Depth 8 -Compress
$manifestPath = Join-Path $publishDir "manifest.json"
$manifestJson | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Get-ChildItem -LiteralPath $portalDir -File | Where-Object {
    @(".html", ".json") -contains $_.Extension.ToLowerInvariant()
} | ForEach-Object {
    $target = Join-Path $portalPublishDir $_.Name
    Copy-Item -LiteralPath $_.FullName -Destination $target -Force
}

$portalIndexPath = Join-Path $portalPublishDir "index.html"
$portalText = Get-Content -LiteralPath $portalIndexPath -Raw
$portalText = $portalText.Replace("WEB_GAME_URL_PENDING_T03_P17", $(if ($webUrl -ne "") { $webUrl } else { "STATIC_HOST_PENDING_T03_P17" }))
$portalText = $portalText.Replace("ANDROID_APK_URL_PENDING_T03_P17", $androidUrl)
$portalText = $portalText.Replace("PC_ZIP_URL_PENDING_T03_P17", $pcUrl)
$portalText | Set-Content -LiteralPath $portalIndexPath -Encoding UTF8

$portalManifestPath = Join-Path $portalPublishDir "manifest.example.json"
if (Test-Path -LiteralPath $portalManifestPath) {
    $manifestJson | Set-Content -LiteralPath $portalManifestPath -Encoding UTF8
}

if (-not $SkipUpload) {
    foreach ($file in Get-ChildItem -LiteralPath $publishDir -Recurse -File) {
        $relative = $file.FullName.Substring($publishDir.Length + 1).Replace("\", "/")
        $sourcePath = Resolve-Path -LiteralPath $file.FullName -Relative
        $destination = "ss:///$BucketName/$ReleaseRoot/$relative"
        $contentType = Content-TypeFor -Path $file.FullName
        [void](Invoke-SupabaseOptional -Arguments @(
            "storage", "rm",
            "--linked",
            "--experimental",
            "--yes",
            $destination
        ))
        Invoke-Supabase -Arguments @(
            "storage", "cp",
            "--linked",
            "--experimental",
            $sourcePath,
            $destination,
            "--content-type",
            $contentType,
            "--cache-control",
            "no-store"
        )
    }
}

if ($UseManifestSecret -and -not $SkipManifestSecret) {
    $manifestBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($manifestJson))
    Invoke-Supabase -Arguments @(
        "secrets", "set",
        "--project-ref",
        $projectRef,
        "RELEASE_MANIFEST_OVERRIDE_ENABLED=1",
        "RELEASE_MANIFEST_JSON_BASE64=$manifestBase64"
    )
}

Invoke-Supabase -Arguments @(
    "functions", "deploy",
    "release",
    "--project-ref",
    $projectRef,
    "--no-verify-jwt"
)

if ($portalUrl -ne "") {
    Assert-UrlOk -Url $portalUrl -Label "Portal" -ExpectedText "DraxosMobile"
}
if ($webUrl -ne "") {
    Assert-UrlOk -Url $webUrl -Label "Web build" -ExpectedText "GODOT_CONFIG"
}
Assert-HeadOk -Url $androidUrl -Label "Android APK" -ExpectedMinimumBytes 1000000
Assert-HeadOk -Url $pcUrl -Label "PC ZIP" -ExpectedMinimumBytes 1000000

$remoteManifestResponse = Invoke-WebRequest -Method Get -Uri "$supabaseUrl/functions/v1/release/manifest" -Headers @{
    apikey = $publishableKey
} -UseBasicParsing
$remoteManifest = $remoteManifestResponse.Content | ConvertFrom-Json
if ($remoteManifest.portal_url -ne $portalUrl) {
    throw "Remote manifest portal_url does not match published portal URL."
}
if ($remoteManifest.artifacts.android.url -ne $androidUrl -or $remoteManifest.artifacts.android.sha256 -ne $androidRecord.sha256) {
    throw "Remote manifest Android artifact does not match published artifact."
}
if ($remoteManifest.artifacts.pc_windows.url -ne $pcUrl -or $remoteManifest.artifacts.pc_windows.sha256 -ne $pcRecord.sha256) {
    throw "Remote manifest PC artifact does not match published artifact."
}
if ($remoteManifest.artifacts.web.url -ne $webUrl) {
    throw "Remote manifest Web artifact does not match published artifact."
}

$report = [ordered]@{
    schema_version = "internal_alpha_publication_v1"
    channel = "internal_alpha"
    app_version = "0.0.1-alpha.0"
    app_version_code = 1
    generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    bucket = $BucketName
    release_root = $ReleaseRoot
    portal_url = $portalUrl
    web_url = $webUrl
    manifest_url = "$supabaseUrl/functions/v1/release/manifest"
    artifacts = @($androidRecord, $pcRecord, $webRecord)
}
$reportPath = Join-Path $buildDir "internal-alpha\publication-report.json"
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host "[publish-internal-alpha] OK"
if ($portalUrl -ne "") {
    Write-Host "Portal: $portalUrl"
} else {
    Write-Host "Portal: pending external static host"
}
if ($webUrl -ne "") {
    Write-Host "Web: $webUrl"
} else {
    Write-Host "Web: pending external static host"
}
Write-Host "Android APK: $androidUrl"
Write-Host "PC ZIP: $pcUrl"
Write-Host "Manifest: $supabaseUrl/functions/v1/release/manifest"
Write-Host "Report: $reportPath"
