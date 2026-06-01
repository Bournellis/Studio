param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$EnvFile = "",
    [ValidateSet("InternalAlpha", "ReleaseCandidate")]
    [string]$Mode = "InternalAlpha",
    [switch]$RequireReleaseKeystore
)

$ErrorActionPreference = "Stop"

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
if ($EnvFile.Trim().Length -eq 0) {
    $EnvFile = Join-Path $ProjectPath ".env.internal-alpha.local"
}

$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
    $Failures.Add($Message) | Out-Null
    Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Add-Ok([string]$Message) {
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Add-Warn([string]$Message) {
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Read-DotEnv {
    param([string]$Path)
    $values = @{}
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $values
    }
    foreach ($rawLine in Get-Content -LiteralPath $Path) {
        $line = $rawLine.Trim()
        if ($line.Length -eq 0 -or $line.StartsWith("#") -or -not $line.Contains("=")) {
            continue
        }
        $parts = $line.Split("=", 2)
        $key = $parts[0].Trim()
        $value = $parts[1].Trim().Trim('"').Trim("'")
        if ($key.Length -gt 0) {
            $values[$key] = $value
        }
    }
    return $values
}

function Env-Value {
    param(
        [hashtable]$Values,
        [string[]]$Keys
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
    return ""
}

function Assert-FileContains {
    param([string]$RelativePath, [string]$Needle, [string]$Label)
    $path = Join-Path $ProjectPath $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-Failure "$Label missing: $RelativePath"
        return
    }
    $text = Get-Content -LiteralPath $path -Raw
    if ($text.Contains($Needle)) {
        Add-Ok "$Label includes $Needle"
    } else {
        Add-Failure "$Label does not include $Needle"
    }
}

function Test-TrackedEnvFileAbsent {
    Push-Location -LiteralPath $ProjectPath
    try {
        $tracked = & git ls-files -- ".env.internal-alpha.local"
        if ($LASTEXITCODE -ne 0) {
            Add-Failure "git ls-files failed while checking .env.internal-alpha.local"
            return
        }
        if (@($tracked).Count -eq 0) {
            Add-Ok ".env.internal-alpha.local is not tracked"
        } else {
            Add-Failure ".env.internal-alpha.local must remain untracked"
        }
    } finally {
        Pop-Location
    }
}

function Test-TrackedPasswordLeakAbsent {
    Push-Location -LiteralPath $ProjectPath
    try {
        $leaks = New-Object System.Collections.Generic.List[string]
        $passwordKeys = @(
            "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD",
            "DRAXOS_MOBILE_ANDROID_KEYSTORE_PASSWORD",
            "GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD"
        )
        $pattern = "^\s*($($passwordKeys -join '|'))\s*="
        $matches = & git grep -n -E $pattern -- .
        $exitCode = $LASTEXITCODE
        if ($exitCode -gt 1) {
            Add-Failure "git grep failed while scanning tracked keystore password values"
            return
        }
        foreach ($match in @($matches)) {
            $parts = $match.Split(":", 3)
            if ($parts.Count -lt 3) {
                continue
            }
            $line = $parts[2]
            if ($line -match "^\s*[^=]+\s*=\s*(.+)$") {
                $value = $Matches[1].Trim().Trim('"').Trim("'")
                $normalized = $value.ToLowerInvariant()
                $allowedPlaceholder = $normalized.StartsWith("<") -or
                    $normalized.Contains("placeholder") -or
                    $normalized.Contains("senha-local") -or
                    $normalized.Contains("redacted") -or
                    $normalized.Contains("local-only")
                if (-not $allowedPlaceholder) {
                    $leaks.Add("$($parts[0]):$($parts[1])") | Out-Null
                }
            }
        }
        if ($leaks.Count -eq 0) {
            Add-Ok "tracked files do not contain concrete Android keystore passwords"
        } else {
            Add-Failure "tracked Android keystore password-like values found: $($leaks -join ', ')"
        }
    } finally {
        Pop-Location
    }
}

Write-Host "DraxosMobile Android release keystore gate"
Write-Host "Project: $ProjectPath"
Write-Host "Mode: $Mode"

$envValues = Read-DotEnv -Path $EnvFile
$releaseKeystorePath = Env-Value $envValues @(
    "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH",
    "DRAXOS_MOBILE_ANDROID_KEYSTORE_PATH",
    "GODOT_ANDROID_KEYSTORE_RELEASE_PATH"
)
$releaseKeystoreUser = Env-Value $envValues @(
    "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_USER",
    "DRAXOS_MOBILE_ANDROID_KEYSTORE_ALIAS",
    "GODOT_ANDROID_KEYSTORE_RELEASE_USER"
)
$releaseKeystorePassword = Env-Value $envValues @(
    "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD",
    "DRAXOS_MOBILE_ANDROID_KEYSTORE_PASSWORD",
    "GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD"
)

$configuredFields = @($releaseKeystorePath, $releaseKeystoreUser, $releaseKeystorePassword) |
    Where-Object { $_ -and $_.Trim().Length -gt 0 }
$hasReleaseKeystore = $configuredFields.Count -eq 3

if ($configuredFields.Count -gt 0 -and -not $hasReleaseKeystore) {
    Add-Failure "Android release keystore config must provide path, user/alias and password together"
} elseif ($hasReleaseKeystore) {
    Add-Ok "Android release keystore tuple is configured"
    if (Test-Path -LiteralPath $releaseKeystorePath -PathType Leaf) {
        Add-Ok "Android release keystore file exists"
    } else {
        Add-Failure "Android release keystore file was configured but not found"
    }
} else {
    Add-Warn "Android release keystore is not configured; internal alpha may use debug_fallback only"
}

if (($Mode -eq "ReleaseCandidate" -or $RequireReleaseKeystore) -and -not $hasReleaseKeystore) {
    Add-Failure "ReleaseCandidate mode requires Android release keystore configuration"
}

Assert-FileContains "tools\export_internal_alpha.ps1" "Android release keystore config must provide path, user/alias and password together." "export script"
Assert-FileContains "tools\export_internal_alpha.ps1" "android_release_keystore_configured" "export metadata"
Assert-FileContains "tools\export_internal_alpha.ps1" "debug_fallback" "export fallback marker"
Assert-FileContains "tools\publish_internal_alpha.ps1" "debug_fallback" "publish plan known issue"
Assert-FileContains "docs\release-ops-checklist.md" "check_android_release_keystore.ps1" "release ops checklist"
Assert-FileContains "docs\release-ops-checklist.md" "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PATH" "release ops checklist"
Test-TrackedEnvFileAbsent
Test-TrackedPasswordLeakAbsent

if ($Failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Android release keystore gate failed with $($Failures.Count) issue(s)." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Android release keystore gate OK." -ForegroundColor Green
