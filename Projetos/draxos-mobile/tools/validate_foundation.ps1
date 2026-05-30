param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [ValidateSet("Quick", "Client", "Release", "Full")]
    [string]$Profile = "Quick",
    [string]$GodotExe = "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe",
    [switch]$RequireClean,
    [switch]$IncludeRemoteReadOnly,
    [switch]$AllowCloudflareAccess,
    [switch]$RemoteFullHash,
    [string]$JsonReportPath = "",
    [string]$MarkdownReportPath = ""
)

$ErrorActionPreference = "Stop"

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
$RepoPath = (Resolve-Path -LiteralPath (Join-Path $ProjectPath "..\..")).Path
$ValidationDir = Join-Path $ProjectPath "build\validation"
if ($JsonReportPath.Trim().Length -eq 0) {
    $JsonReportPath = Join-Path $ValidationDir "foundation-validation-latest.json"
}
if ($MarkdownReportPath.Trim().Length -eq 0) {
    $MarkdownReportPath = Join-Path $ValidationDir "foundation-validation-latest.md"
}

$Results = New-Object System.Collections.Generic.List[object]
$HadFailure = $false

function Add-StepResult {
    param(
        [string]$Name,
        [string]$Stage,
        [string]$Status,
        [double]$DurationMs,
        [string]$Command,
        [string]$Reason
    )
    $script:Results.Add([pscustomobject]@{
        name = $Name
        stage = $Stage
        status = $Status
        duration_ms = [math]::Round($DurationMs, 2)
        command = $Command
        reason = $Reason
    }) | Out-Null
}

function Invoke-Step {
    param(
        [string]$Name,
        [string]$Stage,
        [string]$Command,
        [scriptblock]$ScriptBlock
    )
    Write-Host "[RUN][$Stage] $Name" -ForegroundColor Cyan
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        & $ScriptBlock
        $timer.Stop()
        Add-StepResult -Name $Name -Stage $Stage -Status "PASS" -DurationMs $timer.Elapsed.TotalMilliseconds -Command $Command -Reason ""
        Write-Host "[PASS][$Stage] $Name" -ForegroundColor Green
    } catch {
        $timer.Stop()
        $script:HadFailure = $true
        $message = $_.Exception.Message
        Add-StepResult -Name $Name -Stage $Stage -Status "FAIL" -DurationMs $timer.Elapsed.TotalMilliseconds -Command $Command -Reason $message
        Write-Host "[FAIL][$Stage] $Name - $message" -ForegroundColor Red
    }
}

function Skip-Step {
    param(
        [string]$Name,
        [string]$Stage,
        [string]$Command,
        [string]$Reason
    )
    Add-StepResult -Name $Name -Stage $Stage -Status "SKIP" -DurationMs 0 -Command $Command -Reason $Reason
    Write-Host "[SKIP][$Stage] $Name - $Reason" -ForegroundColor Yellow
}

function Invoke-External {
    param(
        [string]$Command,
        [string]$WorkingDirectory,
        [scriptblock]$ScriptBlock
    )
    Push-Location -LiteralPath $WorkingDirectory
    try {
        & $ScriptBlock
        if ($LASTEXITCODE -ne 0) {
            throw "$Command exited with code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
}

function Assert-FileExists {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "$Label is missing: $Path"
    }
}

function Assert-DirectoryExists {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label is missing: $Path"
    }
}

function Assert-ClientSafeValue {
    param([string]$Value, [string]$Label)
    $normalized = $Value.Trim().ToLowerInvariant()
    if ($normalized.Length -eq 0) {
        return
    }
    if ($normalized.Contains("service_role") -or
        $normalized.StartsWith("sb_secret_") -or
        $normalized.StartsWith("sb_service_") -or
        $normalized.Contains("database_password") -or
        $normalized.Contains("db_password") -or
        $normalized.Contains("keystore_password")) {
        throw "$Label contains a secret-like value and cannot be used by client/release validation."
    }
}

function Assert-PowerShellParses {
    param([string[]]$RelativePaths)
    foreach ($relative in $RelativePaths) {
        $path = Join-Path $ProjectPath $relative
        Assert-FileExists -Path $path -Label $relative
        $tokens = $null
        $errors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors) | Out-Null
        if ($errors -and $errors.Count -gt 0) {
            $details = ($errors | ForEach-Object { "$($_.Extent.StartLineNumber):$($_.Extent.StartColumnNumber) $($_.Message)" }) -join "; "
            throw "$relative has PowerShell parse errors: $details"
        }
    }
}

function Get-DirectoryHashMap {
    param([string]$Path)
    $root = (Resolve-Path -LiteralPath $Path).Path.TrimEnd("\")
    $prefix = "$root\"
    $map = @{}
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File) {
        $relative = $file.FullName.Substring($prefix.Length).Replace("\", "/")
        $map[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
    }
    return $map
}

function Assert-DirectoriesMirror {
    param([string]$LeftPath, [string]$RightPath, [string]$Label)
    Assert-DirectoryExists -Path $LeftPath -Label "$Label left"
    Assert-DirectoryExists -Path $RightPath -Label "$Label right"
    $left = Get-DirectoryHashMap -Path $LeftPath
    $right = Get-DirectoryHashMap -Path $RightPath
    $allNames = @($left.Keys + $right.Keys | Sort-Object -Unique)
    $mismatch = @()
    foreach ($name in $allNames) {
        if (-not $left.ContainsKey($name) -or -not $right.ContainsKey($name) -or $left[$name] -ne $right[$name]) {
            $mismatch += $name
        }
    }
    if ($mismatch.Count -gt 0) {
        throw "$Label mirrors differ: $($mismatch -join ', ')"
    }
}

function Assert-BootBudget {
    $bootPath = Join-Path $ProjectPath "modes\boot\boot.gd"
    Assert-FileExists -Path $bootPath -Label "boot.gd"
    $lineCount = (Get-Content -LiteralPath $bootPath | Measure-Object -Line).Lines
    if ($lineCount -gt 1500) {
        throw "boot.gd has $lineCount lines; Track 12/13 budget is 1500."
    }
}

function Assert-StructuralReadiness {
    foreach ($relative in @(
        "tools\validate.gd",
        "tools\smoke_runtime_config.gd",
        "tools\smoke_foundation_hardening.gd",
        "tools\smoke_responsive_layout.gd",
        "tools\smoke_exports.gd",
        "server\functions\release\index.ts",
        "supabase\functions\release\index.ts",
        "server\tests\release_manifest_smoke.ts",
        "server\tests\release_artifacts_remote_smoke.ts",
        "server\tests\internal_alpha_remote_smoke.ts",
        "docs\agent-operating-manual.md",
        "docs\documentation-index.md",
        "docs\release-ops-checklist.md",
        "docs\foundation-expansion-readiness.md",
        "implementation\current-status.md"
    )) {
        Assert-FileExists -Path (Join-Path $ProjectPath $relative) -Label $relative
    }
    Assert-BootBudget
}

function Assert-ClientSecretsAbsent {
    $filesToScan = New-Object System.Collections.Generic.List[string]
    foreach ($relative in @(
        "project.godot",
        "export_presets.cfg",
        "portal\internal-alpha\index.html",
        "portal\internal-alpha\manifest.example.json"
    )) {
        $path = Join-Path $ProjectPath $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $filesToScan.Add($path) | Out-Null
        }
    }
    foreach ($rootRelative in @(
        "build\internal-alpha\publish",
        "build\internal-alpha\cloudflare-pages"
    )) {
        $root = Join-Path $ProjectPath $rootRelative
        if (Test-Path -LiteralPath $root -PathType Container) {
            Get-ChildItem -LiteralPath $root -Recurse -File -Include *.json, *.html, *.js, *.txt |
                ForEach-Object { $filesToScan.Add($_.FullName) | Out-Null }
        }
    }
    foreach ($relative in @(
        "build\internal-alpha\publication-report.json",
        "build\internal-alpha\release-plan.json",
        "build\internal-alpha\release-plan.md"
    )) {
        $path = Join-Path $ProjectPath $relative
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $filesToScan.Add($path) | Out-Null
        }
    }

    $patterns = @(
        "service_role",
        "sb_secret_",
        "sb_service_",
        "SUPABASE_SERVICE_ROLE_KEY",
        "DATABASE_PASSWORD",
        "DB_PASSWORD",
        "KEYSTORE_PASSWORD",
        "DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD"
    )
    foreach ($file in $filesToScan) {
        $text = Get-Content -LiteralPath $file -Raw
        foreach ($pattern in $patterns) {
            if ($text.IndexOf($pattern, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                throw "secret-like token '$pattern' found in client/release artifact: $file"
            }
        }
    }

    foreach ($name in @(
        "DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY",
        "SUPABASE_PUBLISHABLE_KEY",
        "DRAXOS_MOBILE_UPDATE_MANIFEST_URL",
        "DRAXOS_MOBILE_RUNTIME_CONFIG_JSON"
    )) {
        $value = [Environment]::GetEnvironmentVariable($name, "Process")
        if ($value) {
            Assert-ClientSafeValue -Value $value -Label "environment variable $name"
        }
    }
}

function Write-Reports {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $JsonReportPath) | Out-Null
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $MarkdownReportPath) | Out-Null
    $summary = [ordered]@{
        pass = @($Results | Where-Object { $_.status -eq "PASS" }).Count
        fail = @($Results | Where-Object { $_.status -eq "FAIL" }).Count
        skip = @($Results | Where-Object { $_.status -eq "SKIP" }).Count
    }
    $report = [ordered]@{
        schema_version = "draxos_mobile_foundation_validation_v1"
        generated_at = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        project_dir = $ProjectPath
        repo_dir = $RepoPath
        profile = $Profile
        require_clean = $RequireClean.IsPresent
        include_remote_read_only = $IncludeRemoteReadOnly.IsPresent
        summary = $summary
        results = @($Results.ToArray())
    }
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $JsonReportPath -Encoding UTF8

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# DraxosMobile Foundation Validation") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Generated at: ``{0}``" -f $report.generated_at)) | Out-Null
    $lines.Add(("- Profile: ``{0}``" -f $Profile)) | Out-Null
    $lines.Add(("- Project: ``{0}``" -f $ProjectPath)) | Out-Null
    $lines.Add(("- Summary: PASS ``{0}``, FAIL ``{1}``, SKIP ``{2}``" -f $summary.pass, $summary.fail, $summary.skip)) | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("| Stage | Check | Status | Duration ms | Command | Reason |") | Out-Null
    $lines.Add("|---|---|---:|---:|---|---|") | Out-Null
    foreach ($result in $Results) {
        $reason = ($result.reason -replace "\|", "\|" -replace "`r?`n", " ")
        $command = ($result.command -replace "\|", "\|" -replace "`r?`n", " ")
        $lines.Add(("| {0} | {1} | {2} | {3} | ``{4}`` | {5} |" -f $result.stage, $result.name, $result.status, $result.duration_ms, $command, $reason)) | Out-Null
    }
    $lines | Set-Content -LiteralPath $MarkdownReportPath -Encoding UTF8
}

$RunClient = $Profile -eq "Client" -or $Profile -eq "Full"
$RunRelease = $Profile -eq "Release" -or $Profile -eq "Full"

Write-Host "DraxosMobile foundation validation"
Write-Host "Project: $ProjectPath"
Write-Host "Profile: $Profile"

Invoke-Step -Name "git diff --check" -Stage "Quick" -Command "git diff --check" -ScriptBlock {
    Invoke-External -Command "git diff --check" -WorkingDirectory $RepoPath -ScriptBlock {
        & git diff --check
    }
}

if ($RequireClean) {
    Invoke-Step -Name "git status clean" -Stage "Quick" -Command "git status --short" -ScriptBlock {
        Push-Location -LiteralPath $RepoPath
        try {
            $status = & git status --short
            if ($LASTEXITCODE -ne 0) {
                throw "git status exited with code $LASTEXITCODE."
            }
            if (@($status).Count -gt 0) {
                throw "worktree is not clean: $($status -join '; ')"
            }
        } finally {
            Pop-Location
        }
    }
} else {
    Skip-Step -Name "git status clean" -Stage "Quick" -Command "git status --short" -Reason "-RequireClean was not set."
}

Invoke-Step -Name "PowerShell parse" -Stage "Quick" -Command "[Parser]::ParseFile release/foundation scripts" -ScriptBlock {
    $scripts = @(
        "tools\export_internal_alpha.ps1",
        "tools\publish_internal_alpha.ps1",
        "tools\build_cloudflare_pages_package.ps1",
        "tools\validate_foundation.ps1"
    )
    foreach ($optional in @(
        "tools\check_release_safety.ps1",
        "tools\check_track13_readiness.ps1",
        "tools\check_agent_ops_foundation.ps1",
        "tools\check_foundation_expansion_readiness.ps1"
    )) {
        if (Test-Path -LiteralPath (Join-Path $ProjectPath $optional) -PathType Leaf) {
            $scripts += $optional
        }
    }
    Assert-PowerShellParses -RelativePaths $scripts
}

Invoke-Step -Name "server/supabase mirrors" -Stage "Quick" -Command "Compare server/supabase mirrors" -ScriptBlock {
    Assert-DirectoriesMirror -LeftPath (Join-Path $ProjectPath "server\functions") -RightPath (Join-Path $ProjectPath "supabase\functions") -Label "server/functions and supabase/functions"
    Assert-DirectoriesMirror -LeftPath (Join-Path $ProjectPath "server\schema\migrations") -RightPath (Join-Path $ProjectPath "supabase\migrations") -Label "server/schema/migrations and supabase/migrations"
}

Invoke-Step -Name "Deno release typecheck light" -Stage "Quick" -Command "npx -y deno check release function/tests" -ScriptBlock {
    Invoke-External -Command "npx -y deno check release function/tests" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno check server/functions/release/index.ts supabase/functions/release/index.ts server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/internal_alpha_remote_smoke.ts
    }
}

Invoke-Step -Name "structural readiness" -Stage "Quick" -Command "required files + boot.gd budget" -ScriptBlock {
    Assert-StructuralReadiness
}

$foundationExpansion = Join-Path $ProjectPath "tools\check_foundation_expansion_readiness.ps1"
if (Test-Path -LiteralPath $foundationExpansion -PathType Leaf) {
    Invoke-Step -Name "foundation expansion readiness" -Stage "Quick" -Command ".\tools\check_foundation_expansion_readiness.ps1 -ProjectDir ." -ScriptBlock {
        Invoke-External -Command "check_foundation_expansion_readiness.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
            & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_foundation_expansion_readiness.ps1" -ProjectDir "."
        }
    }
} else {
    Skip-Step -Name "foundation expansion readiness" -Stage "Quick" -Command ".\tools\check_foundation_expansion_readiness.ps1" -Reason "Foundation expansion readiness script not created yet."
}

if ($RunClient) {
    Invoke-Step -Name "Godot executable present" -Stage "Client" -Command "Test-Path $GodotExe" -ScriptBlock {
        Assert-FileExists -Path $GodotExe -Label "Godot executable"
    }
    Invoke-Step -Name "tools/validate.gd" -Stage "Client" -Command "$GodotExe --headless --path . -s res://tools/validate.gd" -ScriptBlock {
        Invoke-External -Command "Godot validate.gd" -WorkingDirectory $ProjectPath -ScriptBlock {
            & $GodotExe --headless --path . -s res://tools/validate.gd
        }
    }
    Invoke-Step -Name "GUT client" -Stage "Client" -Command "$GodotExe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit" -ScriptBlock {
        Invoke-External -Command "GUT client" -WorkingDirectory $ProjectPath -ScriptBlock {
            & $GodotExe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
        }
    }
    foreach ($smoke in @(
        "smoke_runtime_config.gd",
        "smoke_foundation_hardening.gd",
        "smoke_responsive_layout.gd",
        "smoke_exports.gd"
    )) {
        Invoke-Step -Name $smoke -Stage "Client" -Command "$GodotExe --headless --path . -s res://tools/$smoke" -ScriptBlock {
            Invoke-External -Command $smoke -WorkingDirectory $ProjectPath -ScriptBlock {
                & $GodotExe --headless --path . -s "res://tools/$smoke"
            }
        }
    }
} else {
    Skip-Step -Name "client Godot matrix" -Stage "Client" -Command "Godot validate/GUT/smokes" -Reason "Profile $Profile does not include Client."
}

if ($RunRelease) {
    Invoke-Step -Name "release manifest typecheck" -Stage "Release" -Command "npx -y deno check release smoke tests" -ScriptBlock {
        Invoke-External -Command "npx -y deno check release smoke tests" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno check server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/internal_alpha_remote_smoke.ts
        }
    }
    Invoke-Step -Name "release plan local" -Stage "Release" -Command ".\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan" -ScriptBlock {
        $publishScript = Join-Path $ProjectPath "tools\publish_internal_alpha.ps1"
        $publishText = Get-Content -LiteralPath $publishScript -Raw
        if (-not $publishText.Contains("ConfirmRemoteMutation") -or -not $publishText.Contains("Mode")) {
            throw "publish_internal_alpha.ps1 does not expose Track 13 safe Mode/ConfirmRemoteMutation yet."
        }
        Invoke-External -Command "publish_internal_alpha.ps1 -Mode Plan" -WorkingDirectory $ProjectPath -ScriptBlock {
            & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\publish_internal_alpha.ps1" -ProjectDir "." -Mode "Plan"
        }
    }
    Invoke-Step -Name "secrets/client safety scan" -Stage "Release" -Command "scan client env, manifest, portal and reports" -ScriptBlock {
        Assert-ClientSecretsAbsent
    }
    $releaseSafety = Join-Path $ProjectPath "tools\check_release_safety.ps1"
    if (Test-Path -LiteralPath $releaseSafety -PathType Leaf) {
        Invoke-Step -Name "release safety check" -Stage "Release" -Command ".\tools\check_release_safety.ps1 -ProjectDir ." -ScriptBlock {
            Invoke-External -Command "check_release_safety.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_release_safety.ps1" -ProjectDir "."
            }
        }
    } else {
        Skip-Step -Name "release safety check" -Stage "Release" -Command ".\tools\check_release_safety.ps1" -Reason "Track 13 safety script not created yet."
    }
    $track13Readiness = Join-Path $ProjectPath "tools\check_track13_readiness.ps1"
    if (Test-Path -LiteralPath $track13Readiness -PathType Leaf) {
        Invoke-Step -Name "Track 13 readiness" -Stage "Release" -Command ".\tools\check_track13_readiness.ps1 -ProjectDir ." -ScriptBlock {
            Invoke-External -Command "check_track13_readiness.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_track13_readiness.ps1" -ProjectDir "."
            }
        }
    } else {
        Skip-Step -Name "Track 13 readiness" -Stage "Release" -Command ".\tools\check_track13_readiness.ps1" -Reason "Track 13 readiness script not created yet."
    }
    $agentOpsFoundation = Join-Path $ProjectPath "tools\check_agent_ops_foundation.ps1"
    if (Test-Path -LiteralPath $agentOpsFoundation -PathType Leaf) {
        Invoke-Step -Name "agent operations foundation" -Stage "Release" -Command ".\tools\check_agent_ops_foundation.ps1 -ProjectDir ." -ScriptBlock {
            Invoke-External -Command "check_agent_ops_foundation.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_agent_ops_foundation.ps1" -ProjectDir "."
            }
        }
    } else {
        Skip-Step -Name "agent operations foundation" -Stage "Release" -Command ".\tools\check_agent_ops_foundation.ps1" -Reason "Track 14 agent ops script not created yet."
    }
} else {
    Skip-Step -Name "release validation matrix" -Stage "Release" -Command "manifest/release/secrets/readiness" -Reason "Profile $Profile does not include Release."
}

if ($IncludeRemoteReadOnly) {
    Invoke-Step -Name "remote read-only artifacts smoke" -Stage "RemoteReadOnly" -Command "npx -y deno run --allow-net --allow-env --allow-read server/tests/release_artifacts_remote_smoke.ts" -ScriptBlock {
        $remoteUrl = ([Environment]::GetEnvironmentVariable("DRAXOS_MOBILE_SUPABASE_URL", "Process"))
        if (-not $remoteUrl) {
            $remoteUrl = [Environment]::GetEnvironmentVariable("SUPABASE_URL", "Process")
        }
        $remoteKey = ([Environment]::GetEnvironmentVariable("DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY", "Process"))
        if (-not $remoteKey) {
            $remoteKey = [Environment]::GetEnvironmentVariable("SUPABASE_PUBLISHABLE_KEY", "Process")
        }
        if (-not $remoteUrl -or -not $remoteUrl.Trim().StartsWith("https://")) {
            throw "-IncludeRemoteReadOnly requires SUPABASE_URL or DRAXOS_MOBILE_SUPABASE_URL with an https remote URL."
        }
        if (-not $remoteKey) {
            throw "-IncludeRemoteReadOnly requires SUPABASE_PUBLISHABLE_KEY or DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY."
        }
        Assert-ClientSafeValue -Value $remoteKey -Label "remote publishable key"

        $oldUrl = $env:SUPABASE_URL
        $oldKey = $env:SUPABASE_PUBLISHABLE_KEY
        $oldAccess = $env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS
        $oldFullHash = $env:DRAXOS_RELEASE_FULL_HASH
        try {
            $env:SUPABASE_URL = $remoteUrl.Trim()
            $env:SUPABASE_PUBLISHABLE_KEY = $remoteKey.Trim()
            if ($AllowCloudflareAccess) {
                $env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS = "1"
            }
            if ($RemoteFullHash) {
                $env:DRAXOS_RELEASE_FULL_HASH = "1"
            }
            Invoke-External -Command "release_artifacts_remote_smoke.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
                & npx -y deno run --allow-net --allow-env --allow-read server/tests/release_artifacts_remote_smoke.ts
            }
        } finally {
            $env:SUPABASE_URL = $oldUrl
            $env:SUPABASE_PUBLISHABLE_KEY = $oldKey
            $env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS = $oldAccess
            $env:DRAXOS_RELEASE_FULL_HASH = $oldFullHash
        }
    }
} else {
    Skip-Step -Name "remote read-only artifacts smoke" -Stage "RemoteReadOnly" -Command "release_artifacts_remote_smoke.ts" -Reason "-IncludeRemoteReadOnly was not set."
}

Write-Reports
Write-Host "Report JSON: $JsonReportPath"
Write-Host "Report MD:   $MarkdownReportPath"

if ($HadFailure) {
    Write-Host "DraxosMobile foundation validation failed." -ForegroundColor Red
    exit 1
}

Write-Host "DraxosMobile foundation validation OK." -ForegroundColor Green
