param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$GodotExe = "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe",
    [string]$EnvFile = "",
    [switch]$AllowAndroidDebugFallback
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
        throw "DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY or SUPABASE_PUBLISHABLE_KEY is required."
    }
    if ($normalized.StartsWith("sb_secret_") -or
        $normalized.StartsWith("sb_service_") -or
        $normalized.Contains("service_role") -or
        $normalized.Contains("secret")) {
        throw "Client export refuses service role or secret-like Supabase keys."
    }
}

function Escape-GdString {
    param([string]$Value)
    return $Value.Replace("\", "\\").Replace('"', '\"')
}

function Invoke-Checked {
    param([string[]]$CommandLine)
    & $CommandLine[0] @($CommandLine | Select-Object -Skip 1)
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code $LASTEXITCODE`: $($CommandLine -join ' ')"
    }
}

function File-HashRecord {
    param(
        [string]$Path,
        [string]$Label
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Expected artifact was not generated: $Path"
    }
    $item = Get-Item -LiteralPath $Path
    return [ordered]@{
        label = $Label
        path = $item.FullName
        bytes = $item.Length
        sha256 = (Get-FileHash -LiteralPath $item.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    }
}

function Clear-BuildDirectory {
    param(
        [string]$Path,
        [string]$BuildRoot
    )
    $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
    $resolvedBuildRoot = (Resolve-Path -LiteralPath $BuildRoot).Path
    if (-not $resolvedPath.StartsWith($resolvedBuildRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean path outside build root: $resolvedPath"
    }
    Get-ChildItem -LiteralPath $resolvedPath -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force
}

$ProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
if ($EnvFile -eq "") {
    $EnvFile = Join-Path $ProjectDir ".env.internal-alpha.local"
}

$envValues = Read-DotEnv -Path $EnvFile
$supabaseUrl = Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_URL", "SUPABASE_URL")
$publishableKey = Env-Value $envValues @("DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY", "SUPABASE_PUBLISHABLE_KEY")
$manifestUrl = Env-Value $envValues @("DRAXOS_MOBILE_UPDATE_MANIFEST_URL") "$supabaseUrl/functions/v1/release/manifest"
$backendEnv = Env-Value $envValues @("DRAXOS_MOBILE_BACKEND_ENV") "internal_alpha_v0"
$releaseKeystorePath = Env-Value $envValues @("DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH", "DRAXOS_MOBILE_ANDROID_KEYSTORE_PATH", "GODOT_ANDROID_KEYSTORE_RELEASE_PATH")
$releaseKeystoreUser = Env-Value $envValues @("DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER", "DRAXOS_MOBILE_ANDROID_KEYSTORE_ALIAS", "GODOT_ANDROID_KEYSTORE_RELEASE_USER")
$releaseKeystorePassword = Env-Value $envValues @("DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD", "DRAXOS_MOBILE_ANDROID_KEYSTORE_PASSWORD", "GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD")

if (-not $supabaseUrl.StartsWith("https://")) {
    throw "Internal alpha exports require an https Supabase URL."
}
Assert-Client-Key -Key $publishableKey

$releaseKeystoreFields = @($releaseKeystorePath, $releaseKeystoreUser, $releaseKeystorePassword) |
    Where-Object { $_ -and $_.Trim().Length -gt 0 }
$hasReleaseKeystore = $releaseKeystoreFields.Count -eq 3
if ($releaseKeystoreFields.Count -gt 0 -and -not $hasReleaseKeystore) {
    throw "Android release keystore config must provide path, user/alias and password together."
}
if ($hasReleaseKeystore -and -not (Test-Path -LiteralPath $releaseKeystorePath)) {
    throw "Android release keystore was configured but not found: $releaseKeystorePath"
}

$buildRoot = Join-Path $ProjectDir "build"
$androidDir = Join-Path $buildRoot "android"
$pcDir = Join-Path $buildRoot "pc"
$webDir = Join-Path $buildRoot "web"
$metaDir = Join-Path $buildRoot "internal-alpha"
New-Item -ItemType Directory -Force -Path $androidDir, $pcDir, $webDir, $metaDir | Out-Null

$runtimeConfigPath = Join-Path $ProjectDir "online\internal_alpha_runtime_config.gd"
$runtimeConfig = @"
extends RefCounted

func config() -> Dictionary:
	return {
		"backend_environment": "$(Escape-GdString $backendEnv)",
		"supabase_url": "$(Escape-GdString $supabaseUrl)",
		"publishable_key": "$(Escape-GdString $publishableKey)",
		"update_manifest_url": "$(Escape-GdString $manifestUrl)",
	}
"@

$pcZip = Join-Path $pcDir "draxos-mobile-alpha.zip"
$pcExe = Join-Path $pcDir "draxos-mobile-alpha.exe"
$androidApk = Join-Path $androidDir "draxos-mobile-alpha.apk"
$webIndex = Join-Path $webDir "index.html"

try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($runtimeConfigPath, $runtimeConfig, $utf8NoBom)

    Clear-BuildDirectory -Path $androidDir -BuildRoot $buildRoot
    Clear-BuildDirectory -Path $pcDir -BuildRoot $buildRoot
    Clear-BuildDirectory -Path $webDir -BuildRoot $buildRoot
    Clear-BuildDirectory -Path $metaDir -BuildRoot $buildRoot

    Invoke-Checked @($GodotExe, "--headless", "--path", $ProjectDir, "--export-release", "PC Windows Alpha", $pcExe)
    if (Test-Path -LiteralPath $pcZip) {
        Remove-Item -LiteralPath $pcZip -Force
    }
    $pcFiles = Get-ChildItem -LiteralPath $pcDir -File |
        Where-Object { $_.Name -ne "draxos-mobile-alpha.zip" }
    Compress-Archive -LiteralPath $pcFiles.FullName -DestinationPath $pcZip -Force

    Invoke-Checked @($GodotExe, "--headless", "--path", $ProjectDir, "--export-release", "PC Browser Alpha", $webIndex)

    if ($hasReleaseKeystore) {
        $env:GODOT_ANDROID_KEYSTORE_RELEASE_PATH = $releaseKeystorePath
        $env:GODOT_ANDROID_KEYSTORE_RELEASE_USER = $releaseKeystoreUser
        $env:GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD = $releaseKeystorePassword
        Invoke-Checked @($GodotExe, "--headless", "--path", $ProjectDir, "--export-release", "Android Alpha", $androidApk)
        $androidMode = "release"
    } else {
        if (-not $AllowAndroidDebugFallback) {
            throw "Android release keystore is not configured. Pass -AllowAndroidDebugFallback for local internal APKs or configure release keystore env vars."
        }
        Write-Host "[export-internal-alpha] Android release keystore not configured; exporting debug-signed APK fallback."
        Invoke-Checked @($GodotExe, "--headless", "--path", $ProjectDir, "--export-debug", "Android Alpha", $androidApk)
        $androidMode = "debug_fallback"
    }

    $records = @(
        File-HashRecord -Path $androidApk -Label "Android APK"
        File-HashRecord -Path $pcZip -Label "PC Windows ZIP"
        File-HashRecord -Path $webIndex -Label "Web Index"
    )

    $metadata = [ordered]@{
        schema_version = "internal_alpha_artifacts_v1"
        channel = "internal_alpha"
        app_version = "0.0.22-alpha.0"
        app_version_code = 22
        generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        supabase_url = $supabaseUrl
        update_manifest_url = $manifestUrl
        android_export_mode = $androidMode
        android_release_keystore_configured = $hasReleaseKeystore
        artifacts = $records
    }

    $metadataPath = Join-Path $metaDir "release-artifacts.json"
    $metadata | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $metadataPath -Encoding UTF8

    $sumsPath = Join-Path $metaDir "SHA256SUMS.txt"
    $records | ForEach-Object { "$($_.sha256)  $($_.path)" } |
        Set-Content -LiteralPath $sumsPath -Encoding UTF8

    Write-Host "[export-internal-alpha] OK"
    Write-Host "Android mode: $androidMode"
    Write-Host "Metadata: $metadataPath"
} finally {
    Remove-Item -LiteralPath $runtimeConfigPath -Force -ErrorAction SilentlyContinue
}
