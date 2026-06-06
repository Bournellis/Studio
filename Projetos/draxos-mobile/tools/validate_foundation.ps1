param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [ValidateSet(
        "DocsOnly",
        "ClientQuick",
        "ServerQuick",
        "ModePlatform",
        "DatabaseLocal",
        "FullLocal",
        "ReleaseDryRun",
        "RemoteReadOnly",
        "FullPublish",
        "Quick",
        "Client",
        "Release",
        "Full"
    )]
    [string]$Profile = "DocsOnly",
    [string]$GodotExe = "D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe",
    [switch]$RequireClean,
    [switch]$IncludeRemoteReadOnly,
    [switch]$IncludeLocalSupabaseRpc,
    [switch]$IncludeLocalEdgeRpc,
    [switch]$IncludeLocalAdminRls,
    [switch]$AllowCloudflareAccess,
    [switch]$RemoteFullHash,
    [switch]$ConfirmRemoteMutation,
    [string]$RemoteWebUrl = "",
    [string]$ExpectedReleaseRoot = "",
    [string]$ExpectedPortalUrl = "https://draxos-mobile-internal-alpha.pages.dev/",
    [string]$ExpectedWebUrl = "https://draxos-mobile-internal-alpha.pages.dev/web/index.html",
    [string]$RemoteDiagnosticsDir = "",
    [switch]$NoProjectWrites,
    [switch]$KeepDiagnostics,
    [string]$JsonReportPath = "",
    [string]$MarkdownReportPath = ""
)

$ErrorActionPreference = "Stop"

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
$RepoPath = (Resolve-Path -LiteralPath (Join-Path $ProjectPath "..\..")).Path
$ValidationRoot = if ($NoProjectWrites.IsPresent) {
    Join-Path ([System.IO.Path]::GetTempPath()) "draxos-mobile-foundation-validation"
} else {
    Join-Path $ProjectPath "build\validation"
}
$ValidationDir = $ValidationRoot
if ($JsonReportPath.Trim().Length -eq 0) {
    $JsonReportPath = Join-Path $ValidationDir "foundation-validation-latest.json"
}
if ($MarkdownReportPath.Trim().Length -eq 0) {
    $MarkdownReportPath = Join-Path $ValidationDir "foundation-validation-latest.md"
}

$Results = New-Object System.Collections.Generic.List[object]
$HadFailure = $false
$RequestedProfile = $Profile
$LegacyProfileMap = @{
    Quick = "ServerQuick"
    Client = "ClientQuick"
    Release = "ReleaseDryRun"
    Full = "FullLocal"
}
$EffectiveProfile = if ($LegacyProfileMap.ContainsKey($Profile)) { $LegacyProfileMap[$Profile] } else { $Profile }

if ($EffectiveProfile -eq "FullPublish") {
    throw "Profile FullPublish is disabled in validate_foundation.ps1. Run validation with -Profile FullLocal or -Profile ReleaseDryRun, then publish only through tools\publish_internal_alpha.ps1 -Mode FullPublish -ReleaseRoot <versioned-root> -ConfirmRemoteMutation in an approved publication task."
}

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

function Assert-FilesMirror {
    param([string]$LeftPath, [string]$RightPath, [string]$Label)
    Assert-FileExists -Path $LeftPath -Label "$Label left"
    Assert-FileExists -Path $RightPath -Label "$Label right"
    $leftHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $LeftPath).Hash
    $rightHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $RightPath).Hash
    if ($leftHash -ne $rightHash) {
        throw "$Label files differ."
    }
}

function Assert-RelativeFileContains {
    param([string]$BasePath, [string]$RelativePath, [string]$Needle)
    $path = Join-Path $BasePath $RelativePath
    Assert-FileExists -Path $path -Label $RelativePath
    $text = Get-Content -LiteralPath $path -Raw
    if (-not $text.Contains($Needle)) {
        throw "$RelativePath does not contain required text: $Needle"
    }
}

function Assert-RelativeFileDoesNotContain {
    param([string]$BasePath, [string]$RelativePath, [string]$Needle)
    $path = Join-Path $BasePath $RelativePath
    Assert-FileExists -Path $path -Label $RelativePath
    $text = Get-Content -LiteralPath $path -Raw
    if ($text.Contains($Needle)) {
        throw "$RelativePath contains forbidden legacy text: $Needle"
    }
}

function Assert-LineBudget {
    param([string]$RelativePath, [int]$MaxLines, [string]$Label)
    $path = Join-Path $ProjectPath $RelativePath
    Assert-FileExists -Path $path -Label $RelativePath
    $lineCount = (Get-Content -LiteralPath $path | Measure-Object -Line).Lines
    if ($lineCount -gt $MaxLines) {
        throw "$Label has $lineCount lines; budget is $MaxLines."
    }
}

function Assert-BootBudget {
    $failures = New-Object System.Collections.Generic.List[string]
    foreach ($budget in @(
        @{ Path = "modes\boot\boot.gd"; Max = 1200; Label = "boot.gd scene-facing facade" },
        @{ Path = "modes\boot\boot_runtime.gd"; Max = 900; Label = "boot_runtime.gd strict shell runtime" },
        @{ Path = "modes\boot\boot_runtime_state.gd"; Max = 700; Label = "boot runtime state module" },
        @{ Path = "modes\boot\boot_runtime_surface_api.gd"; Max = 700; Label = "boot runtime surface API module" },
        @{ Path = "modes\boot\boot_runtime_status_controller.gd"; Max = 700; Label = "boot runtime status controller" },
        @{ Path = "modes\boot\boot_runtime_labs_controller.gd"; Max = 700; Label = "boot runtime labs controller" },
        @{ Path = "modes\boot\boot_runtime_flow_facade.gd"; Max = 700; Label = "boot runtime flow facade" },
        @{ Path = "modes\boot\boot_runtime_navigation_controller.gd"; Max = 700; Label = "boot runtime navigation controller" },
        @{ Path = "modes\boot\boot_runtime_action_dispatcher.gd"; Max = 700; Label = "boot runtime action dispatcher" },
        @{ Path = "modes\boot\surfaces\hub_surface_presenter.gd"; Max = 900; Label = "hub_surface_presenter.gd facade" },
        @{ Path = "modes\boot\surfaces\hub_surface_full_presenter.gd"; Max = 900; Label = "hub_surface_full_presenter.gd strict hub presenter" },
        @{ Path = "modes\boot\surfaces\hub_surface_common_presenter.gd"; Max = 700; Label = "hub surface common presenter" },
        @{ Path = "modes\boot\surfaces\hub_surface_entry_presenter.gd"; Max = 700; Label = "hub surface entry presenter" },
        @{ Path = "modes\boot\surfaces\hub_surface_preparation_presenter.gd"; Max = 700; Label = "hub surface preparation presenter" },
        @{ Path = "modes\boot\surfaces\hub_surface_refuge_popup_presenter.gd"; Max = 700; Label = "hub surface refuge popup presenter" },
        @{ Path = "modes\boot\surfaces\hub_surface_refuge_scene_presenter.gd"; Max = 700; Label = "hub surface refuge scene presenter" }
    )) {
        try {
            Assert-LineBudget -RelativePath $budget.Path -MaxLines $budget.Max -Label $budget.Label
        } catch {
            $failures.Add($_.Exception.Message) | Out-Null
        }
    }
    if (Test-Path -LiteralPath (Join-Path $ProjectPath "modes\boot\boot_runtime_facade.gd")) {
        $failures.Add("boot_runtime_facade.gd must not exist; split responsibilities into bounded modules instead.") | Out-Null
    }
    if ($failures.Count -gt 0) {
        throw ($failures -join " | ")
    }
}

function Assert-JsonObjectKeys {
    param([object]$Object, [string[]]$ExpectedKeys, [string]$Label)
    $actual = @($Object.PSObject.Properties.Name | Sort-Object)
    $expected = @($ExpectedKeys | Sort-Object)
    $missing = @($expected | Where-Object { $actual -notcontains $_ })
    $extra = @($actual | Where-Object { $expected -notcontains $_ })
    if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
        throw "$Label has invalid keys. Missing: $($missing -join ', '); extra: $($extra -join ', ')."
    }
}

function Assert-JsonStringValue {
    param([object]$Object, [string]$Key, [string]$Expected, [string]$Label)
    $actual = [string]$Object.$Key
    if ($actual -ne $Expected) {
        throw "$Label $Key must be '$Expected'; found '$actual'."
    }
}

function Assert-JsonBooleanValue {
    param([object]$Object, [string]$Key, [bool]$Expected, [string]$Label)
    $actual = [bool]$Object.$Key
    if ($actual -ne $Expected) {
        throw "$Label $Key must be $Expected; found $actual."
    }
}

function Assert-ModeDescriptorSchemaStrict {
    $modeRoot = Join-Path $ProjectPath "data\definitions\modes"
    Assert-DirectoryExists -Path $modeRoot -Label "mode descriptor root"
    $officialModes = @("basebuilder", "autobattler", "openworld", "towerdefense", "cardgame")
    $expectedMetadataKeys = @(
        "schema_version",
        "mode_id",
        "display_name",
        "summary",
        "default_slice_id",
        "status",
        "release_channel",
        "public_cta",
        "fullscreen",
        "entry",
        "ruleset",
        "ownership",
        "docs",
        "scaffold"
    )
    $expectedEntryKeys = @("route_id", "action_id", "surface", "client_screen_path", "enabled_setting")
    $expectedRulesetKeys = @("ruleset_id", "ruleset_version", "status", "session_model")
    $expectedOwnershipKeys = @("build_owner", "data_strategy", "economy_authority", "reward_bridge")
    $expectedDocsKeys = @("mode_doc", "catalog", "contract")
    $expectedScaffoldKeys = @("placeholder_path", "playable_from_placeholder", "freeze")
    $expectedPlaceholderKeys = @(
        "schema_version",
        "mode_id",
        "placeholder_id",
        "playable",
        "launchable",
        "reward_enabled",
        "runtime",
        "entry_action",
        "purpose",
        "blocked_until",
        "non_goals"
    )

    foreach ($modeId in $officialModes) {
        $metadataRelative = "data\definitions\modes\$modeId\metadata.json"
        $placeholderRelative = "data\definitions\modes\$modeId\placeholder.json"
        $metadataPath = Join-Path $ProjectPath $metadataRelative
        $placeholderPath = Join-Path $ProjectPath $placeholderRelative
        Assert-FileExists -Path $metadataPath -Label $metadataRelative
        Assert-FileExists -Path $placeholderPath -Label $placeholderRelative

        $metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
        $placeholder = Get-Content -LiteralPath $placeholderPath -Raw | ConvertFrom-Json

        Assert-JsonObjectKeys -Object $metadata -ExpectedKeys $expectedMetadataKeys -Label $metadataRelative
        Assert-JsonObjectKeys -Object $metadata.entry -ExpectedKeys $expectedEntryKeys -Label "$metadataRelative entry"
        Assert-JsonObjectKeys -Object $metadata.ruleset -ExpectedKeys $expectedRulesetKeys -Label "$metadataRelative ruleset"
        Assert-JsonObjectKeys -Object $metadata.ownership -ExpectedKeys $expectedOwnershipKeys -Label "$metadataRelative ownership"
        Assert-JsonObjectKeys -Object $metadata.docs -ExpectedKeys $expectedDocsKeys -Label "$metadataRelative docs"
        Assert-JsonObjectKeys -Object $metadata.scaffold -ExpectedKeys $expectedScaffoldKeys -Label "$metadataRelative scaffold"
        Assert-JsonObjectKeys -Object $placeholder -ExpectedKeys $expectedPlaceholderKeys -Label $placeholderRelative

        Assert-JsonStringValue -Object $metadata -Key "schema_version" -Expected "mode_descriptor_v1" -Label $metadataRelative
        Assert-JsonStringValue -Object $metadata -Key "mode_id" -Expected $modeId -Label $metadataRelative
        Assert-JsonStringValue -Object $placeholder -Key "schema_version" -Expected "mode_placeholder_v1" -Label $placeholderRelative
        Assert-JsonStringValue -Object $placeholder -Key "mode_id" -Expected $modeId -Label $placeholderRelative
        Assert-JsonStringValue -Object $placeholder -Key "runtime" -Expected "none" -Label $placeholderRelative
        Assert-JsonStringValue -Object $placeholder -Key "entry_action" -Expected "" -Label $placeholderRelative
        Assert-JsonBooleanValue -Object $placeholder -Key "playable" -Expected $false -Label $placeholderRelative
        Assert-JsonBooleanValue -Object $placeholder -Key "launchable" -Expected $false -Label $placeholderRelative
        Assert-JsonBooleanValue -Object $placeholder -Key "reward_enabled" -Expected $false -Label $placeholderRelative
        Assert-JsonBooleanValue -Object $metadata.scaffold -Key "playable_from_placeholder" -Expected $false -Label "$metadataRelative scaffold"

        $declaredPlaceholder = [string]$metadata.scaffold.placeholder_path
        if ($declaredPlaceholder -ne $placeholderRelative.Replace("\", "/")) {
            throw "$metadataRelative scaffold placeholder_path must point to $($placeholderRelative.Replace('\', '/')); found $declaredPlaceholder."
        }
        foreach ($docKey in $expectedDocsKeys) {
            $docPath = Join-Path $ProjectPath ([string]$metadata.docs.$docKey)
            Assert-FileExists -Path $docPath -Label "$metadataRelative docs.$docKey"
        }
        if (@($placeholder.blocked_until).Count -lt 3 -or @($placeholder.non_goals).Count -lt 3) {
            throw "$placeholderRelative must keep explicit blocked_until and non_goals lists."
        }
    }
}

function Assert-ModeHandlerModularity {
    $entry = Join-Path $ProjectPath "server\functions\modes\index.ts"
    $handler = Join-Path $ProjectPath "server\functions\modes\mode_handler.ts"
    $support = Join-Path $ProjectPath "server\functions\modes\mode_support.ts"
    $supabaseEntry = Join-Path $ProjectPath "supabase\functions\modes\index.ts"
    $supabaseHandler = Join-Path $ProjectPath "supabase\functions\modes\mode_handler.ts"
    $supabaseSupport = Join-Path $ProjectPath "supabase\functions\modes\mode_support.ts"
    Assert-FilesMirror -LeftPath $entry -RightPath $supabaseEntry -Label "modes edge entrypoint"
    Assert-FilesMirror -LeftPath $handler -RightPath $supabaseHandler -Label "modes handler"
    Assert-FilesMirror -LeftPath $support -RightPath $supabaseSupport -Label "modes support"
    Assert-LineBudget -RelativePath "server\functions\modes\index.ts" -MaxLines 80 -Label "server modes edge entrypoint"
    Assert-LineBudget -RelativePath "server\functions\modes\mode_handler.ts" -MaxLines 1100 -Label "server modes handler"
    Assert-LineBudget -RelativePath "server\functions\modes\mode_support.ts" -MaxLines 700 -Label "server modes support"
    $entryText = Get-Content -LiteralPath $entry -Raw
    $handlerText = Get-Content -LiteralPath $handler -Raw
    $supportText = Get-Content -LiteralPath $support -Raw
    $modeText = "$handlerText`n$supportText"
    if (-not $entryText.Contains('import { modeHandler } from "./mode_handler.ts";') -or -not $entryText.Contains("Deno.serve(modeHandler)")) {
        throw "server/functions/modes/index.ts must only delegate to mode_handler.ts."
    }
    foreach ($needle in @("export class ModeHandler", "modeHandler(request: Request)", "handleAdminRoute", "mutationRequestHash", "verifiedAuthContext")) {
        if (-not $modeText.Contains($needle)) {
            throw "server/functions/modes mode modules are missing modularity marker: $needle"
        }
    }
}

function Assert-HotFileBudgets {
    $failures = New-Object System.Collections.Generic.List[string]
    foreach ($budget in @(
        @{ Path = "server\functions\modes\index.ts"; Max = 80; Label = "server modes entrypoint" },
        @{ Path = "server\functions\modes\mode_handler.ts"; Max = 1100; Label = "server modes handler" },
        @{ Path = "server\functions\arena\index.ts"; Max = 1800; Label = "server arena endpoint" },
        @{ Path = "server\functions\arena\arena_types.ts"; Max = 220; Label = "server arena type module" },
        @{ Path = "server\functions\battle\index.ts"; Max = 1350; Label = "server battle endpoint" },
        @{ Path = "modes\boot\flows\surface_action_flow.gd"; Max = 850; Label = "client surface action flow" },
        @{ Path = "modes\boot\flows\arena_lifecycle_flow.gd"; Max = 550; Label = "client arena lifecycle flow" },
        @{ Path = "modes\boot\flows\account_session_flow.gd"; Max = 500; Label = "client account session flow" },
        @{ Path = "modes\boot\surfaces\base_surface_presenter.gd"; Max = 850; Label = "client base surface presenter" },
        @{ Path = "modes\boot\surfaces\battle_replay_presenter.gd"; Max = 750; Label = "client battle replay presenter" },
        @{ Path = "online\session_store.gd"; Max = 1000; Label = "session store facade" },
        @{ Path = "online\session\arena_slice.gd"; Max = 260; Label = "session arena slice" },
        @{ Path = "online\session\pending_mutation_queue.gd"; Max = 250; Label = "session pending mutation queue" },
        @{ Path = "online\session\account_save_slice.gd"; Max = 150; Label = "session account/save slice" },
        @{ Path = "online\session\mode_slice.gd"; Max = 80; Label = "session mode slice" },
        @{ Path = "online\session\telemetry_slice.gd"; Max = 80; Label = "session telemetry slice" }
    )) {
        try {
            Assert-LineBudget -RelativePath $budget.Path -MaxLines $budget.Max -Label $budget.Label
        } catch {
            $failures.Add($_.Exception.Message) | Out-Null
        }
    }
    if ($failures.Count -gt 0) {
        throw ($failures -join " | ")
    }
}

function Assert-DirectModeMutationsAbsent {
    $failures = New-Object System.Collections.Generic.List[string]
    foreach ($relative in @(
        "server\functions\modes\mode_handler.ts",
        "supabase\functions\modes\mode_handler.ts"
    )) {
        $path = Join-Path $ProjectPath $relative
        Assert-FileExists -Path $path -Label $relative
        $text = Get-Content -LiteralPath $path -Raw
        foreach ($pattern in @(
            'method:\s*"PATCH"',
            'method:\s*"PUT"',
            'method:\s*"DELETE"',
            'mode_(registry|progress|sessions|reward_claims|limit_policies)[^"`r`n]+method:\s*"POST"'
        )) {
            if ([regex]::IsMatch($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor [System.Text.RegularExpressions.RegexOptions]::Singleline)) {
                $failures.Add("$relative contains forbidden direct mode mutation pattern: $pattern") | Out-Null
            }
        }
    }
    if ($failures.Count -gt 0) {
        throw ($failures -join " | ")
    }
}

function Assert-DependencyLockSanity {
    Assert-FilesMirror -LeftPath (Join-Path $ProjectPath "server\functions\deno.json") -RightPath (Join-Path $ProjectPath "supabase\functions\deno.json") -Label "Deno function config"
    $denoConfig = Get-Content -LiteralPath (Join-Path $ProjectPath "server\functions\deno.json") -Raw | ConvertFrom-Json
    if ($denoConfig.compilerOptions.strict -ne $true) {
        throw "server/functions/deno.json must keep compilerOptions.strict=true."
    }
    $checkTask = [string]$denoConfig.tasks.check
    foreach ($entrypoint in @("arena/index.ts", "lab-runner/index.ts", "modes/index.ts")) {
        if (-not $checkTask.Contains($entrypoint)) {
            throw "Deno check task must include $entrypoint."
        }
    }

    Push-Location -LiteralPath $RepoPath
    try {
        $trackedFiles = & git ls-files
        if ($LASTEXITCODE -ne 0) {
            throw "git ls-files exited with code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
    $projectTracked = @($trackedFiles | Where-Object { $_.StartsWith("Projetos/draxos-mobile/") })
    $nodePackageFiles = @($projectTracked | Where-Object { $_ -match '(^|/)package\.json$' })
    $nodeLockFiles = @($projectTracked | Where-Object { $_ -match '(^|/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock)$' })
    if ($nodePackageFiles.Count -gt 0 -and $nodeLockFiles.Count -eq 0) {
        throw "package.json is tracked without a package lock: $($nodePackageFiles -join ', ')"
    }
    if (@($projectTracked | Where-Object { $_ -match '(^|/)node_modules/' }).Count -gt 0) {
        throw "node_modules must not be tracked."
    }

    $remoteImportPattern = 'from\s+["''](https?:|npm:|jsr:)|import\s+["''](https?:|npm:|jsr:)'
    $tsRoots = @("server\functions", "supabase\functions", "server\tests", "tools")
    $remoteImports = New-Object System.Collections.Generic.List[string]
    foreach ($rootRelative in $tsRoots) {
        $root = Join-Path $ProjectPath $rootRelative
        if (-not (Test-Path -LiteralPath $root -PathType Container)) {
            continue
        }
        foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Include *.ts) {
            $text = Get-Content -LiteralPath $file.FullName -Raw
            if ([regex]::IsMatch($text, $remoteImportPattern)) {
                $remoteImports.Add($file.FullName.Substring($ProjectPath.Length + 1)) | Out-Null
            }
        }
    }
    if ($remoteImports.Count -gt 0 -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath "deno.lock") -PathType Leaf)) {
        throw "remote Deno imports require deno.lock. Files: $($remoteImports -join ', ')"
    }
}

function Assert-CorsAllowedOrigins {
    $serverHttp = Join-Path $ProjectPath "server\functions\_shared\http.ts"
    $supabaseHttp = Join-Path $ProjectPath "supabase\functions\_shared\http.ts"
    Assert-FilesMirror -LeftPath $serverHttp -RightPath $supabaseHttp -Label "shared CORS helper"
    $text = Get-Content -LiteralPath $serverHttp -Raw
    foreach ($header in @("authorization", "apikey", "content-type", "x-draxos-save-type", "x-draxos-api-version")) {
        if (-not $text.ToLowerInvariant().Contains($header)) {
            throw "CORS helper must allow header $header."
        }
    }
    if ([regex]::IsMatch($text, '"access-control-allow-origin"\s*:\s*"\*"')) {
        throw "CORS helper uses wildcard origin; V2 requires an explicit allowed-origin policy."
    }
    foreach ($originMarker in @("aeec7403.draxos-mobile-internal-alpha.pages.dev", "draxos-mobile-internal-alpha.pages.dev", "localhost", "127.0.0.1")) {
        if (-not $text.Contains($originMarker)) {
            throw "CORS helper must declare allowed origin marker: $originMarker"
        }
    }
}

function Assert-LiveDocsReleaseRootFreshness {
    $currentRoot = "internal-alpha/v0-bosque-world-hub-domain-separation-v1-20260606-81ecf05"
    $currentPreview = "https://d1872010.draxos-mobile-internal-alpha.pages.dev"
    $previousStationRoot = "internal-alpha/v0-bosque-fogueira-potion-crafting-v1-20260606-cad6d2c"
    $previousStationPreview = "https://08d00f24.draxos-mobile-internal-alpha.pages.dev"
    $previousDurableRoot = "internal-alpha/v0-bosque-durable-bau-mochila-v1-20260606-6e7ca6b"
    $previousDurablePreview = "https://39198a35.draxos-mobile-internal-alpha.pages.dev"
    $previousMenuRoot = "internal-alpha/v0-arena-pve-menu-flow-simplification-v1-20260606-5d03a68"
    $previousMenuPreview = "https://fdf44707.draxos-mobile-internal-alpha.pages.dev"
    $previousCheckpointRoot = "internal-alpha/v0-bosque-offline-first-checkpoint-v1-20260606-f649d22"
    $previousCheckpointPreview = "https://fa84e109.draxos-mobile-internal-alpha.pages.dev"
    $previousSyncRoot = "internal-alpha/v0-bosque-sync-responsiveness-v1-20260605-a5f8c95"
    $previousSyncPreview = "https://60e2d4be.draxos-mobile-internal-alpha.pages.dev"
    $previousVisibleRoot = "internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5"
    $previousVisiblePreview = "https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev"
    $previousRegressionRoot = "internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f"
    $previousRegressionPreview = "https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev"
    $previousSeasonRoot = "internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32"
    $previousSeasonPreview = "https://d7333659.draxos-mobile-internal-alpha.pages.dev"
    $previousHotfixRoot = "internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174"
    $previousHotfixPreview = "https://0536635b.draxos-mobile-internal-alpha.pages.dev"
    $previousArenaRoot = "internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a"
    $previousArenaPreview = "https://2c020d09.draxos-mobile-internal-alpha.pages.dev"
    $previousContentRoot = "internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45"
    $previousContentPreview = "https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev"
    $previousOpenworldRoot = "internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8"
    $previousOpenworldPreview = "https://aeec7403.draxos-mobile-internal-alpha.pages.dev"
    $hardeningRoot = "internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4"
    $hardeningPreview = "https://ca946749.draxos-mobile-internal-alpha.pages.dev"
    foreach ($entry in @(
        @{ Base = $ProjectPath; Path = "AGENTS.md"; Needles = @("Bosque World Hub Domain Separation v1 is the latest remote Internal Alpha publication", $currentRoot, $currentPreview, "Bosque Fogueira Potion Crafting v1 remains the previous station-craft package", $previousStationRoot, $previousStationPreview, "Bosque Durable Bau Mochila v1", "Arena PVE Menu Flow Simplification v1", "Bosque Offline-First Checkpoint v1", "Bosque Sync Responsiveness v1", "Arena/Bosque Visible V2", "Arena/Bosque Regression Hotfix") },
        @{ Base = $ProjectPath; Path = "README.md"; Needles = @("Current release root:", $currentRoot, "Current verified preview:", $currentPreview, "Previous station-craft release root:", $previousStationRoot, "Previous station-craft verified preview:", $previousStationPreview, "Previous durable Openworld release root:", $previousDurableRoot, "Previous durable Openworld verified preview:", $previousDurablePreview, "Previous Arena menu release root:", $previousMenuRoot, "Previous Arena menu verified preview:", $previousMenuPreview, "Previous Openworld policy release root:", $previousCheckpointRoot, "Previous Openworld policy verified preview:", $previousCheckpointPreview, "Previous Bosque sync release root:", $previousSyncRoot, "Previous Bosque sync verified preview:", $previousSyncPreview, "Previous visible release root:", $previousVisibleRoot, "Previous visible verified preview:", $previousVisiblePreview, "Previous hardening release root:", $hardeningRoot, "Previous hardening verified preview:", $hardeningPreview) },
        @{ Base = $ProjectPath; Path = "implementation\current-status.md"; Needles = @("Latest published remote package:", "Bosque World Hub Domain Separation v1", $currentRoot, $currentPreview, "Previous station-craft package:", "Bosque Fogueira Potion Crafting v1", $previousStationRoot, $previousStationPreview, "Previous durable Openworld package:", "Bosque Durable Bau Mochila v1", $previousDurableRoot, $previousDurablePreview, "Previous Arena menu package:", "Arena PVE Menu Flow Simplification v1", $previousMenuRoot, $previousMenuPreview, "Previous Openworld/Bosque policy package:", "Bosque Offline-First Checkpoint v1", $previousCheckpointRoot, $previousCheckpointPreview, "Previous Bosque sync package:", "Bosque Sync Responsiveness v1", $previousSyncRoot, $previousSyncPreview, "Previous visible package:", "Arena/Bosque Visible V2", $previousVisibleRoot, $previousVisiblePreview, "Previous hardening baseline:", "Foundation Hardening V2", $hardeningRoot, $hardeningPreview) },
        @{ Base = $ProjectPath; Path = "docs\agent-operating-manual.md"; Needles = @("Bosque World Hub Domain Separation v1 is the latest remote Internal Alpha publication", $currentRoot, $currentPreview, "Bosque Fogueira Potion Crafting v1 remains the previous station-craft package", $previousStationRoot, $previousStationPreview, "Bosque Durable Bau Mochila v1 remains the previous durable Openworld progress package", $previousDurableRoot, $previousDurablePreview, "Arena PVE Menu Flow Simplification v1 remains the previous Arena menu package", $previousMenuRoot, $previousMenuPreview, "Bosque Offline-First Checkpoint v1 remains the previous Openworld policy package", $previousCheckpointRoot, $previousCheckpointPreview, "Bosque Sync Responsiveness v1 remains the previous Bosque sync package", "Arena/Bosque Visible V2", "Arena/Bosque Regression Hotfix", "Arena PVE Season 1 Loop v1", "Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline") },
        @{ Base = $ProjectPath; Path = "docs\foundation-hardening-v2-readiness-report.md"; Needles = @("Status:", "HISTORICO_BASELINE", $hardeningRoot, $hardeningPreview, "not the latest remote Internal Alpha package") },
        @{ Base = $RepoPath; Path = "08_Coordenacao_Agentes\Prioridades_Estudio.md"; Needles = @("BOSQUE_WORLD_HUB_DOMAIN_SEPARATION_V1_PUBLISHED_INTERNAL_ALPHA", $currentRoot, $currentPreview, $previousStationRoot, $previousStationPreview, "Bosque Durable Bau Mochila v1", "Arena PVE Menu Flow Simplification v1", "Bosque Offline-First Checkpoint v1", "Track 13 release safety", "Track 14 agent ops") },
        @{ Base = $RepoPath; Path = "08_Coordenacao_Agentes\Estado_Atual.md"; Needles = @("BOSQUE_WORLD_HUB_DOMAIN_SEPARATION_V1_PUBLISHED_INTERNAL_ALPHA", $currentRoot, $currentPreview, $previousStationRoot, $previousStationPreview, $previousDurableRoot, $previousDurablePreview, $previousMenuRoot, $previousMenuPreview, $previousCheckpointRoot, $previousCheckpointPreview, $previousSyncRoot, $previousSyncPreview, $previousVisibleRoot, $previousVisiblePreview, "FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA", $hardeningRoot, $hardeningPreview) },
        @{ Base = $RepoPath; Path = "Projetos\README.md"; Needles = @("Current published package:", "Bosque World Hub Domain Separation v1", $currentRoot, $currentPreview, "Previous station-craft package:", $previousStationRoot, $previousStationPreview, "Previous durable Openworld package:", $previousDurableRoot, $previousDurablePreview, "Previous Arena menu package:", $previousMenuRoot, $previousMenuPreview, "Previous Openworld policy package:", $previousCheckpointRoot, $previousCheckpointPreview) }
    )) {
        foreach ($needle in $entry.Needles) {
            Assert-RelativeFileContains -BasePath $entry.Base -RelativePath $entry.Path -Needle $needle
        }
    }

    $readme = Get-Content -LiteralPath (Join-Path $ProjectPath "README.md") -Raw
    foreach ($staleLinePattern in @(
        'Latest verified preview:\s*`',
        'Latest release root:\s*`',
        'Latest APK:\s*`',
        'Latest PC ZIP:\s*`',
        'Foundation Hardening V2 is the latest remote Internal Alpha publication'
    )) {
        if ([regex]::IsMatch($readme, $staleLinePattern)) {
            throw "README.md has a stale latest release line matching: $staleLinePattern"
        }
    }
}

function Assert-BaselineDriftAbsent {
    $requiredMarkers = @(
        @{ Base = $ProjectPath; Path = "implementation\current-status.md"; Needles = @("Foundation Hardening V2", "TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE", "Track 18 - PVE Arena Initial", "Track 13 - Foundation Validation And Release Safety") },
        @{ Base = $ProjectPath; Path = "docs\agent-operating-manual.md"; Needles = @("FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA", "Track 13", "Track 14", "Track 18") },
        @{ Base = $ProjectPath; Path = "docs\documentation-index.md"; Needles = @("track-18-pve-arena-initial", "track-21-arena-loop-unlock-friction", "Arena PVE") },
        @{ Base = $ProjectPath; Path = "docs\pve-arena-initial-direction.md"; Needles = @("PVE_ARENA_INITIAL_DIRECTION_APPROVED", "Arena PVE", "PVP continua no plano") },
        @{ Base = $RepoPath; Path = "08_Coordenacao_Agentes\Prioridades_Estudio.md"; Needles = @("DraxosMobile", "P2_IMPLEMENTACAO", "Track 13 release safety", "Track 14 agent ops") },
        @{ Base = $RepoPath; Path = "08_Coordenacao_Agentes\Estado_Atual.md"; Needles = @("DraxosMobile", "FOUNDATION_HARDENING_V2_PUBLISHED_INTERNAL_ALPHA", "Track 13 release safety", "Track 14 agent ops") },
        @{ Base = $RepoPath; Path = "Projetos\README.md"; Needles = @("draxos-mobile/", "Track 13 release safety", "Track 14 agent ops", "Foundation Hardening V2") }
    )
    foreach ($entry in $requiredMarkers) {
        foreach ($needle in $entry.Needles) {
            Assert-RelativeFileContains -BasePath $entry.Base -RelativePath $entry.Path -Needle $needle
        }
    }

    $liveFiles = @(
        "AGENTS.md",
        "README.md",
        "implementation\current-status.md",
        "docs\agent-operating-manual.md",
        "docs\documentation-index.md",
        "docs\product-brief.md",
        "docs\pve-arena-initial-direction.md"
    )
    $forbiddenPhrases = @(
        "Fast Lane Atual - Track 04",
        "Fast Lane Atual - Track 08",
        "Fast Lane Atual - Track 10",
        "Track 03 Internal Alpha v0 completa",
        "Track 04 pos-handoff planejada"
    )
    foreach ($relative in $liveFiles) {
        foreach ($phrase in $forbiddenPhrases) {
            Assert-RelativeFileDoesNotContain -BasePath $ProjectPath -RelativePath $relative -Needle $phrase
        }
    }
}

function Assert-LegacyTermsAbsent {
    $targets = @(
        "AGENTS.md",
        "README.md",
        "implementation\current-status.md",
        "docs\agent-operating-manual.md",
        "docs\product-brief.md",
        "docs\pve-arena-initial-direction.md"
    )
    $forbiddenTerms = @(
        "Varinha Magica",
        "1 slot de passiva",
        "1 slot de pet",
        "RPGSuave",
        "Rpgsuave-centered"
    )
    foreach ($relative in $targets) {
        foreach ($term in $forbiddenTerms) {
            Assert-RelativeFileDoesNotContain -BasePath $ProjectPath -RelativePath $relative -Needle $term
        }
    }

    foreach ($term in @("Instrumento Ritual", "Doutrina", "Familiar")) {
        Assert-RelativeFileContains -BasePath $ProjectPath -RelativePath "docs\product-brief.md" -Needle $term
        Assert-RelativeFileContains -BasePath $ProjectPath -RelativePath "docs\game-design-document.md" -Needle $term
    }
}

function Assert-RegistryMirrors {
    Assert-FileExists -Path (Join-Path $ProjectPath "data\rulesets\foundation_ruleset_v0.json") -Label "foundation ruleset JSON"
    Assert-FilesMirror -LeftPath (Join-Path $ProjectPath "server\functions\_shared\foundation_ruleset.ts") -RightPath (Join-Path $ProjectPath "supabase\functions\_shared\foundation_ruleset.ts") -Label "foundation ruleset shared module"
    Assert-FilesMirror -LeftPath (Join-Path $ProjectPath "server\functions\_shared\pve_arena_catalog.ts") -RightPath (Join-Path $ProjectPath "supabase\functions\_shared\pve_arena_catalog.ts") -Label "PVE arena catalog shared module"
    Assert-FilesMirror -LeftPath (Join-Path $ProjectPath "server\functions\_shared\pve_arena_combatants.ts") -RightPath (Join-Path $ProjectPath "supabase\functions\_shared\pve_arena_combatants.ts") -Label "PVE arena combatants shared module"
    Assert-FilesMirror -LeftPath (Join-Path $ProjectPath "server\functions\arena\arena_types.ts") -RightPath (Join-Path $ProjectPath "supabase\functions\arena\arena_types.ts") -Label "PVE arena type module"
    Assert-FilesMirror -LeftPath (Join-Path $ProjectPath "server\schema\migrations\202606050001_arena_reward_profiles_v1.sql") -RightPath (Join-Path $ProjectPath "supabase\migrations\202606050001_arena_reward_profiles_v1.sql") -Label "PVE arena reward profiles migration"
    Assert-RelativeFileContains -BasePath $ProjectPath -RelativePath "server\functions\_shared\foundation_ruleset.ts" -Needle "FOUNDATION_RULESET"
    Assert-RelativeFileContains -BasePath $ProjectPath -RelativePath "server\functions\_shared\pve_arena_catalog.ts" -Needle "PVE_ARENA_CATALOG"
    Assert-RelativeFileContains -BasePath $ProjectPath -RelativePath "server\functions\arena\arena_types.ts" -Needle "export interface ArenaAttemptRow"
    Assert-RelativeFileContains -BasePath $ProjectPath -RelativePath "server\schema\migrations\202606050001_arena_reward_profiles_v1.sql" -Needle "public.arena_reward_profiles"
}

function Assert-StructuralReadiness {
    foreach ($relative in @(
        "tools\validate.gd",
        "tools\smoke_runtime_config.gd",
        "tools\smoke_foundation_hardening.gd",
        "tools\smoke_responsive_layout.gd",
        "tools\smoke_exports.gd",
        "tools\smoke_bosque_entry.gd",
        "tools\smoke_openworld_forest.gd",
        "tools\smoke_modes_visual_layout.gd",
        "tools\smoke_modes_ops_panel.gd",
        "data\rulesets\foundation_ruleset_v0.json",
        "server\functions\_shared\foundation_ruleset.ts",
        "supabase\functions\_shared\foundation_ruleset.ts",
        "server\functions\_shared\pve_arena_catalog.ts",
        "supabase\functions\_shared\pve_arena_catalog.ts",
        "server\functions\_shared\pve_arena_combatants.ts",
        "supabase\functions\_shared\pve_arena_combatants.ts",
        "server\functions\release\index.ts",
        "supabase\functions\release\index.ts",
        "server\tests\release_manifest_smoke.ts",
        "server\tests\release_artifacts_remote_smoke.ts",
        "server\tests\internal_alpha_remote_smoke.ts",
        "server\tests\foundation_admin_rls_live_smoke.ts",
        "server\tests\foundation_ruleset_test.ts",
        "server\tests\pve_arena_catalog_test.ts",
        "server\tests\pve_arena_difficulties_test.ts",
        "server\tests\arena_consistency_pass_schema_test.ts",
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

    Push-Location -LiteralPath $RepoPath
    try {
        $trackedFiles = & git ls-files
        if ($LASTEXITCODE -ne 0) {
            throw "git ls-files exited with code $LASTEXITCODE."
        }
    } finally {
        Pop-Location
    }
    $forbiddenTrackedNames = @(
        ".env.internal-alpha.local",
        ".env.local",
        ".env.production",
        ".env.remote",
        ".p12",
        ".pfx",
        ".keystore"
    )
    foreach ($file in $trackedFiles) {
        foreach ($forbidden in $forbiddenTrackedNames) {
            if ($file.EndsWith($forbidden, [System.StringComparison]::OrdinalIgnoreCase)) {
                throw "secret-bearing local file appears tracked: $file"
            }
        }
    }
}

$LegacyIncludesServerQuick = $RequestedProfile -in @("Quick", "Client", "Release", "Full")
$RunDocs = $true
$RunServer = $EffectiveProfile -in @("ServerQuick", "FullLocal", "FullPublish") -or $LegacyIncludesServerQuick
$RunClient = $EffectiveProfile -in @("ClientQuick", "FullLocal", "FullPublish") -or $RequestedProfile -in @("Client", "Full")
$RunModePlatform = $EffectiveProfile -in @("ModePlatform", "FullLocal", "FullPublish") -or $RequestedProfile -eq "Full"
$RunDatabaseLocal = $EffectiveProfile -in @("DatabaseLocal", "FullLocal", "FullPublish") -or $RequestedProfile -eq "Full"
$RunRelease = $EffectiveProfile -in @("ReleaseDryRun", "RemoteReadOnly", "FullLocal", "FullPublish") -or $RequestedProfile -in @("Release", "Full")
$RunRemoteReadOnly = $IncludeRemoteReadOnly.IsPresent -or $EffectiveProfile -in @("RemoteReadOnly", "FullPublish")
$RunFullPublish = $false
$RunLocalSupabaseRpc = $IncludeLocalSupabaseRpc.IsPresent -or $RunDatabaseLocal
$RunLocalEdgeRpc = $IncludeLocalEdgeRpc.IsPresent -or $RunDatabaseLocal
$RunLocalAdminRls = $IncludeLocalAdminRls.IsPresent -or $RunDatabaseLocal

function Get-EnabledStages {
    $stages = New-Object System.Collections.Generic.List[string]
    if ($RunDocs) { $stages.Add("DocsOnly") | Out-Null }
    if ($RunServer) { $stages.Add("ServerQuick") | Out-Null }
    if ($RunClient) { $stages.Add("ClientQuick") | Out-Null }
    if ($RunModePlatform) { $stages.Add("ModePlatform") | Out-Null }
    if ($RunDatabaseLocal) { $stages.Add("DatabaseLocal") | Out-Null }
    if ($RunRelease) { $stages.Add("ReleaseDryRun") | Out-Null }
    if ($RunRemoteReadOnly) { $stages.Add("RemoteReadOnly") | Out-Null }
    if ($RunFullPublish) { $stages.Add("FullPublish") | Out-Null }
    return @($stages.ToArray())
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
        requested_profile = $RequestedProfile
        effective_profile = $EffectiveProfile
        profile = $EffectiveProfile
        enabled_stages = @(Get-EnabledStages)
        require_clean = $RequireClean.IsPresent
        include_remote_read_only = $RunRemoteReadOnly
        include_local_supabase_rpc = $RunLocalSupabaseRpc
        include_local_edge_rpc = $RunLocalEdgeRpc
        include_local_admin_rls = $RunLocalAdminRls
        confirm_remote_mutation = $ConfirmRemoteMutation.IsPresent
        no_project_writes = $NoProjectWrites.IsPresent
        remote_web_url = $RemoteWebUrl
        expected_release_root = $ExpectedReleaseRoot
        expected_portal_url = $ExpectedPortalUrl
        expected_web_url = $ExpectedWebUrl
        summary = $summary
        results = @($Results.ToArray())
    }
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $JsonReportPath -Encoding UTF8

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# DraxosMobile Foundation Validation") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("## Summary") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add(("- Generated at: ``{0}``" -f $report.generated_at)) | Out-Null
    $lines.Add(("- Requested profile: ``{0}``" -f $RequestedProfile)) | Out-Null
    $lines.Add(("- Effective profile: ``{0}``" -f $EffectiveProfile)) | Out-Null
    $lines.Add(("- Enabled stages: ``{0}``" -f (@(Get-EnabledStages) -join ", "))) | Out-Null
    $lines.Add(("- Project: ``{0}``" -f $ProjectPath)) | Out-Null
    $lines.Add(("- Summary: PASS ``{0}``, FAIL ``{1}``, SKIP ``{2}``" -f $summary.pass, $summary.fail, $summary.skip)) | Out-Null
    $lines.Add("") | Out-Null
    $failedResults = @($Results | Where-Object { $_.status -eq "FAIL" })
    if ($failedResults.Count -gt 0) {
        $lines.Add("## Failed Or Blocked Steps") | Out-Null
        $lines.Add("") | Out-Null
        foreach ($failed in $failedResults) {
            $lines.Add(("- ``{0}`` / ``{1}``: {2}" -f $failed.stage, $failed.name, ($failed.reason -replace "`r?`n", " "))) | Out-Null
        }
        $lines.Add("") | Out-Null
    }
    $lines.Add("## Results") | Out-Null
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

Write-Host "DraxosMobile foundation validation"
Write-Host "Project: $ProjectPath"
Write-Host "Requested profile: $RequestedProfile"
Write-Host "Effective profile: $EffectiveProfile"
Write-Host "Enabled stages: $(@(Get-EnabledStages) -join ', ')"

Invoke-Step -Name "git diff --check" -Stage "DocsOnly" -Command "git diff --check" -ScriptBlock {
    Invoke-External -Command "git diff --check" -WorkingDirectory $RepoPath -ScriptBlock {
        & git diff --check
    }
}

if ($RequireClean) {
    Invoke-Step -Name "git status clean" -Stage "DocsOnly" -Command "git status --short" -ScriptBlock {
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
    Skip-Step -Name "git status clean" -Stage "DocsOnly" -Command "git status --short" -Reason "-RequireClean was not set."
}

Invoke-Step -Name "PowerShell parse" -Stage "DocsOnly" -Command "[Parser]::ParseFile release/foundation scripts" -ScriptBlock {
    $scripts = @(
        "tools\export_internal_alpha.ps1",
        "tools\publish_internal_alpha.ps1",
        "tools\build_cloudflare_pages_package.ps1",
        "tools\smoke_web_launch_remote.ps1",
        "tools\validate_foundation.ps1",
        "tools\validate_mode_definitions.ps1"
    )
    foreach ($optional in @(
        "tools\check_release_safety.ps1",
        "tools\check_android_release_keystore.ps1",
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

Invoke-Step -Name "structural readiness" -Stage "DocsOnly" -Command "required files + real shell/presenter budgets" -ScriptBlock {
    Assert-StructuralReadiness
}

Invoke-Step -Name "V2 descriptor schema strictness hook" -Stage "DocsOnly" -Command "strict mode descriptor JSON schema checks" -ScriptBlock {
    Assert-ModeDescriptorSchemaStrict
}

Invoke-Step -Name "V2 hot file budgets" -Stage "DocsOnly" -Command "server/client/session hot file line budgets" -ScriptBlock {
    Assert-HotFileBudgets
}

Invoke-Step -Name "V2 dependency lock sanity" -Stage "DocsOnly" -Command "Deno config mirror, no unpinned package manager drift" -ScriptBlock {
    Assert-DependencyLockSanity
}

Invoke-Step -Name "baseline drift guard" -Stage "DocsOnly" -Command "live docs/status baseline markers" -ScriptBlock {
    Assert-BaselineDriftAbsent
}

Invoke-Step -Name "V2 live-doc release root guard" -Stage "DocsOnly" -Command "live docs must separate current package and hardening baseline release roots" -ScriptBlock {
    Assert-LiveDocsReleaseRootFreshness
}

Invoke-Step -Name "legacy product terms guard" -Stage "DocsOnly" -Command "live product-facing terminology" -ScriptBlock {
    Assert-LegacyTermsAbsent
}

Invoke-Step -Name "secrets/client safety scan" -Stage "DocsOnly" -Command "scan client env, manifest, portal, reports and tracked local-secret filenames" -ScriptBlock {
    Assert-ClientSecretsAbsent
}

if ($RunServer) {
Invoke-Step -Name "server/supabase mirrors" -Stage "ServerQuick" -Command "Compare server/supabase mirrors" -ScriptBlock {
    Assert-DirectoriesMirror -LeftPath (Join-Path $ProjectPath "server\functions") -RightPath (Join-Path $ProjectPath "supabase\functions") -Label "server/functions and supabase/functions"
    Assert-DirectoriesMirror -LeftPath (Join-Path $ProjectPath "server\schema\migrations") -RightPath (Join-Path $ProjectPath "supabase\migrations") -Label "server/schema/migrations and supabase/migrations"
}

Invoke-Step -Name "V2 mode handler/security strictness" -Stage "ServerQuick" -Command "mode handler modularity, no direct mode mutations, CORS allowed origins" -ScriptBlock {
    Assert-ModeHandlerModularity
    Assert-DirectModeMutationsAbsent
    Assert-CorsAllowedOrigins
}

Invoke-Step -Name "Deno release typecheck light" -Stage "ServerQuick" -Command "npx -y deno check release function/tests" -ScriptBlock {
    Invoke-External -Command "npx -y deno check release function/tests" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno check server/functions/release/index.ts supabase/functions/release/index.ts server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/release_auth_contract_test.ts server/tests/internal_alpha_remote_smoke.ts
    }
}

Invoke-Step -Name "Deno transactional domain typecheck light" -Stage "ServerQuick" -Command "npx -y deno check transactional domain functions" -ScriptBlock {
    Invoke-External -Command "npx -y deno check transactional domain functions" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno check `
            server/functions/battle/index.ts `
            server/functions/build/index.ts `
            server/functions/crafting/index.ts `
            server/functions/monetization/index.ts `
            server/functions/social/index.ts
    }
}

Invoke-Step -Name "Deno foundation contract tests" -Stage "ServerQuick" -Command "npx -y deno test --allow-read foundation contracts" -ScriptBlock {
    Invoke-External -Command "npx -y deno test foundation contracts" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno test --allow-read `
            server/tests/foundation_contracts_test.ts `
            server/tests/foundation_expansion_schema_test.ts `
            server/tests/foundation_closeout_schema_test.ts `
            server/tests/api_version_contract_test.ts `
            server/tests/auth_context_contract_test.ts `
            server/tests/transactional_domain_enforcement_schema_test.ts `
            server/tests/remaining_transactional_domain_enforcement_schema_test.ts `
            server/tests/lab_heuristics_contract_test.ts `
            server/tests/progression_lab_apply_contract_test.ts `
            server/tests/account_reset_request_hash_contract_test.ts `
            server/tests/battle_combatants_test.ts `
            server/tests/base_domain_test.ts `
            server/tests/battle_log_projection_test.ts `
            server/tests/progression_domain_test.ts `
            server/tests/economy_domain_test.ts `
            server/tests/foundation_ruleset_test.ts `
            server/tests/integer_bones_contract_test.ts `
            server/tests/mode_definitions_schema_test.ts `
            server/tests/modes_domain_test.ts `
            server/tests/modes_platform_schema_test.ts `
            server/tests/modes_registry_contract_test.ts `
            server/tests/modes_rate_limit_test.ts `
            server/tests/modes_disable_rollback_test.ts `
            server/tests/modes_admin_ops_test.ts `
            server/tests/modes_analytics_test.ts `
            server/tests/openworld_ruleset_definition_test.ts `
            server/tests/openworld_reward_bridge_test.ts `
            server/tests/release_auth_contract_test.ts
    }
}

Invoke-Step -Name "registry mirrors" -Stage "ServerQuick" -Command "ruleset and generated catalog mirror checks" -ScriptBlock {
    Assert-RegistryMirrors
}

Invoke-Step -Name "Deno PVE Arena contract tests" -Stage "ServerQuick" -Command "npx -y deno test --allow-read PVE Arena contracts" -ScriptBlock {
    Invoke-External -Command "npx -y deno test PVE Arena contracts" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno test --allow-read `
            server/tests/pve_arena_catalog_test.ts `
            server/tests/pve_arena_difficulties_test.ts `
            server/tests/arena_consistency_pass_schema_test.ts `
            server/tests/arena_loop_unlock_friction_test.ts `
            server/tests/arena_pve_sequence_tuning_test.ts
    }
}

Invoke-Step -Name "Deno function tasks" -Stage "ServerQuick" -Command "npx -y deno task --cwd server/functions check; npx -y deno task --cwd supabase/functions check" -ScriptBlock {
    Invoke-External -Command "npx -y deno task --cwd server/functions check" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno task --cwd server/functions check
    }
    Invoke-External -Command "npx -y deno task --cwd supabase/functions check" -WorkingDirectory $ProjectPath -ScriptBlock {
        & npx -y deno task --cwd supabase/functions check
    }
}

$foundationExpansion = Join-Path $ProjectPath "tools\check_foundation_expansion_readiness.ps1"
if (Test-Path -LiteralPath $foundationExpansion -PathType Leaf) {
    Invoke-Step -Name "foundation expansion readiness" -Stage "ServerQuick" -Command ".\tools\check_foundation_expansion_readiness.ps1 -ProjectDir ." -ScriptBlock {
        Invoke-External -Command "check_foundation_expansion_readiness.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
            & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_foundation_expansion_readiness.ps1" -ProjectDir "."
        }
    }
} else {
    Skip-Step -Name "foundation expansion readiness" -Stage "ServerQuick" -Command ".\tools\check_foundation_expansion_readiness.ps1" -Reason "Foundation expansion readiness script not created yet."
}
} else {
    Skip-Step -Name "server quick matrix" -Stage "ServerQuick" -Command "mirrors, Deno checks, foundation and Arena contracts" -Reason "Profile $EffectiveProfile does not include ServerQuick."
}

if ($RunLocalSupabaseRpc) {
    Invoke-Step -Name "local Supabase transactional RPC live proof" -Stage "DatabaseLocal" -Command "npx -y deno check/run server/tests/transactional_rpc_live_test.ts" -ScriptBlock {
        Invoke-External -Command "transactional_rpc_live_test.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno check server/tests/transactional_rpc_live_test.ts
            if ($LASTEXITCODE -ne 0) {
                throw "deno check transactional_rpc_live_test.ts exited with code $LASTEXITCODE."
            }
            & npx -y deno run --allow-net --allow-env server/tests/transactional_rpc_live_test.ts
        }
    }
} else {
    Skip-Step -Name "local Supabase transactional RPC live proof" -Stage "DatabaseLocal" -Command "npx -y deno run --allow-net --allow-env server/tests/transactional_rpc_live_test.ts" -Reason "Profile $EffectiveProfile does not include DatabaseLocal and -IncludeLocalSupabaseRpc was not set."
}

if ($RunLocalEdgeRpc) {
    Invoke-Step -Name "local Edge transactional RPC adapter smoke" -Stage "DatabaseLocal" -Command "npx -y deno check/run server/tests/transactional_edge_rpc_smoke.ts" -ScriptBlock {
        Invoke-External -Command "transactional_edge_rpc_smoke.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno check server/tests/transactional_edge_rpc_smoke.ts
            if ($LASTEXITCODE -ne 0) {
                throw "deno check transactional_edge_rpc_smoke.ts exited with code $LASTEXITCODE."
            }
            & npx -y deno run --allow-net --allow-env server/tests/transactional_edge_rpc_smoke.ts
        }
    }
} else {
    Skip-Step -Name "local Edge transactional RPC adapter smoke" -Stage "DatabaseLocal" -Command "npx -y deno run --allow-net --allow-env server/tests/transactional_edge_rpc_smoke.ts" -Reason "Profile $EffectiveProfile does not include DatabaseLocal and -IncludeLocalEdgeRpc was not set."
}

if ($RunLocalEdgeRpc) {
    Invoke-Step -Name "local mode platform live proof" -Stage "DatabaseLocal" -Command "npx -y deno check/run server/tests/modes_platform_live_test.ts" -ScriptBlock {
        Invoke-External -Command "modes_platform_live_test.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno check server/tests/modes_platform_live_test.ts
            if ($LASTEXITCODE -ne 0) {
                throw "deno check modes_platform_live_test.ts exited with code $LASTEXITCODE."
            }
            & npx -y deno run --allow-net --allow-env server/tests/modes_platform_live_test.ts
        }
    }
} else {
    Skip-Step -Name "local mode platform live proof" -Stage "DatabaseLocal" -Command "npx -y deno run --allow-net --allow-env server/tests/modes_platform_live_test.ts" -Reason "Profile $EffectiveProfile does not include DatabaseLocal and -IncludeLocalEdgeRpc was not set."
}

if ($RunLocalAdminRls) {
    Invoke-Step -Name "local admin RLS live smoke" -Stage "DatabaseLocal" -Command "npx -y deno check/run server/tests/foundation_admin_rls_live_smoke.ts" -ScriptBlock {
        Invoke-External -Command "foundation_admin_rls_live_smoke.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno check server/tests/foundation_admin_rls_live_smoke.ts
            if ($LASTEXITCODE -ne 0) {
                throw "deno check foundation_admin_rls_live_smoke.ts exited with code $LASTEXITCODE."
            }
            & npx -y deno run --allow-net --allow-env server/tests/foundation_admin_rls_live_smoke.ts
        }
    }
} else {
    Skip-Step -Name "local admin RLS live smoke" -Stage "DatabaseLocal" -Command "npx -y deno run --allow-net --allow-env server/tests/foundation_admin_rls_live_smoke.ts" -Reason "Profile $EffectiveProfile does not include DatabaseLocal and -IncludeLocalAdminRls was not set."
}

if ($RunModePlatform) {
    Invoke-Step -Name "mode platform contracts" -Stage "ModePlatform" -Command "npx -y deno test --allow-read mode platform contracts" -ScriptBlock {
        Invoke-External -Command "npx -y deno test mode platform contracts" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno test --allow-read `
                server/tests/modes_domain_test.ts `
                server/tests/mode_definitions_schema_test.ts `
                server/tests/modes_platform_schema_test.ts `
                server/tests/modes_registry_contract_test.ts `
                server/tests/modes_rate_limit_test.ts `
                server/tests/modes_disable_rollback_test.ts `
                server/tests/modes_admin_ops_test.ts `
                server/tests/modes_analytics_test.ts `
                server/tests/openworld_reward_bridge_test.ts
        }
    }
    Invoke-Step -Name "Godot executable present for modes" -Stage "ModePlatform" -Command "Test-Path $GodotExe" -ScriptBlock {
        Assert-FileExists -Path $GodotExe -Label "Godot executable"
    }
    foreach ($smoke in @(
        "smoke_bosque_entry.gd",
        "smoke_openworld_forest.gd",
        "smoke_modes_visual_layout.gd",
        "smoke_modes_ops_panel.gd"
    )) {
        Invoke-Step -Name $smoke -Stage "ModePlatform" -Command "$GodotExe --headless --path . -s res://tools/$smoke" -ScriptBlock {
            Invoke-External -Command $smoke -WorkingDirectory $ProjectPath -ScriptBlock {
                & $GodotExe --headless --path . -s "res://tools/$smoke"
            }
        }
    }
} else {
    Skip-Step -Name "mode platform matrix" -Stage "ModePlatform" -Command "mode contracts and Godot mode smokes" -Reason "Profile $EffectiveProfile does not include ModePlatform."
}

if ($RunClient) {
    Invoke-Step -Name "Godot executable present" -Stage "ClientQuick" -Command "Test-Path $GodotExe" -ScriptBlock {
        Assert-FileExists -Path $GodotExe -Label "Godot executable"
    }
    Invoke-Step -Name "tools/validate.gd" -Stage "ClientQuick" -Command "$GodotExe --headless --path . -s res://tools/validate.gd" -ScriptBlock {
        Invoke-External -Command "Godot validate.gd" -WorkingDirectory $ProjectPath -ScriptBlock {
            & $GodotExe --headless --path . -s res://tools/validate.gd
        }
    }
    Invoke-Step -Name "GUT client" -Stage "ClientQuick" -Command "$GodotExe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit" -ScriptBlock {
        Invoke-External -Command "GUT client" -WorkingDirectory $ProjectPath -ScriptBlock {
            & $GodotExe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
        }
    }
    foreach ($smoke in @(
        "smoke_runtime_config.gd",
        "smoke_foundation_hardening.gd",
        "smoke_responsive_layout.gd",
        "smoke_modes_visual_layout.gd",
        "smoke_exports.gd"
    )) {
        Invoke-Step -Name $smoke -Stage "ClientQuick" -Command "$GodotExe --headless --path . -s res://tools/$smoke" -ScriptBlock {
            Invoke-External -Command $smoke -WorkingDirectory $ProjectPath -ScriptBlock {
                & $GodotExe --headless --path . -s "res://tools/$smoke"
            }
        }
    }
} else {
    Skip-Step -Name "client Godot matrix" -Stage "ClientQuick" -Command "Godot validate/GUT/smokes" -Reason "Profile $EffectiveProfile does not include ClientQuick."
}

if ($RunRelease) {
    Invoke-Step -Name "release manifest typecheck" -Stage "ReleaseDryRun" -Command "npx -y deno check release smoke tests" -ScriptBlock {
        Invoke-External -Command "npx -y deno check release smoke tests" -WorkingDirectory $ProjectPath -ScriptBlock {
            & npx -y deno check server/tests/release_manifest_smoke.ts server/tests/release_artifacts_remote_smoke.ts server/tests/release_auth_contract_test.ts server/tests/internal_alpha_remote_smoke.ts tools/ops_readonly.ts server/tests/ops_readonly_cli_test.ts
        }
    }
    Invoke-Step -Name "release plan dry-run" -Stage "ReleaseDryRun" -Command ".\tools\publish_internal_alpha.ps1 -ProjectDir . -Mode Plan" -ScriptBlock {
        $publishScript = Join-Path $ProjectPath "tools\publish_internal_alpha.ps1"
        $publishText = Get-Content -LiteralPath $publishScript -Raw
        if (-not $publishText.Contains("ConfirmRemoteMutation") -or -not $publishText.Contains("Mode")) {
            throw "publish_internal_alpha.ps1 does not expose Track 13 safe Mode/ConfirmRemoteMutation yet."
        }
        Invoke-External -Command "publish_internal_alpha.ps1 -Mode Plan" -WorkingDirectory $ProjectPath -ScriptBlock {
            & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\publish_internal_alpha.ps1" -ProjectDir "." -Mode "Plan"
        }
    }
    Invoke-Step -Name "secrets/client safety scan after release plan" -Stage "ReleaseDryRun" -Command "scan client env, manifest, portal and reports" -ScriptBlock {
        Assert-ClientSecretsAbsent
    }
    $releaseSafety = Join-Path $ProjectPath "tools\check_release_safety.ps1"
    if (Test-Path -LiteralPath $releaseSafety -PathType Leaf) {
        Invoke-Step -Name "release safety check" -Stage "ReleaseDryRun" -Command ".\tools\check_release_safety.ps1 -ProjectDir ." -ScriptBlock {
            Invoke-External -Command "check_release_safety.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_release_safety.ps1" -ProjectDir "."
            }
        }
    } else {
        Skip-Step -Name "release safety check" -Stage "ReleaseDryRun" -Command ".\tools\check_release_safety.ps1" -Reason "Track 13 safety script not created yet."
    }
    $androidKeystore = Join-Path $ProjectPath "tools\check_android_release_keystore.ps1"
    if (Test-Path -LiteralPath $androidKeystore -PathType Leaf) {
        Invoke-Step -Name "Android release keystore gate" -Stage "ReleaseDryRun" -Command ".\tools\check_android_release_keystore.ps1 -ProjectDir . -Mode InternalAlpha" -ScriptBlock {
            Invoke-External -Command "check_android_release_keystore.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_android_release_keystore.ps1" -ProjectDir "." -Mode "InternalAlpha"
            }
        }
    } else {
        Skip-Step -Name "Android release keystore gate" -Stage "ReleaseDryRun" -Command ".\tools\check_android_release_keystore.ps1" -Reason "Android keystore gate script not created yet."
    }
    $track13Readiness = Join-Path $ProjectPath "tools\check_track13_readiness.ps1"
    if (Test-Path -LiteralPath $track13Readiness -PathType Leaf) {
        Invoke-Step -Name "Track 13 readiness" -Stage "ReleaseDryRun" -Command ".\tools\check_track13_readiness.ps1 -ProjectDir ." -ScriptBlock {
            Invoke-External -Command "check_track13_readiness.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_track13_readiness.ps1" -ProjectDir "."
            }
        }
    } else {
        Skip-Step -Name "Track 13 readiness" -Stage "ReleaseDryRun" -Command ".\tools\check_track13_readiness.ps1" -Reason "Track 13 readiness script not created yet."
    }
    $agentOpsFoundation = Join-Path $ProjectPath "tools\check_agent_ops_foundation.ps1"
    if (Test-Path -LiteralPath $agentOpsFoundation -PathType Leaf) {
        Invoke-Step -Name "agent operations foundation" -Stage "ReleaseDryRun" -Command ".\tools\check_agent_ops_foundation.ps1 -ProjectDir ." -ScriptBlock {
            Invoke-External -Command "check_agent_ops_foundation.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell -NoProfile -ExecutionPolicy Bypass -File ".\tools\check_agent_ops_foundation.ps1" -ProjectDir "."
            }
        }
    } else {
        Skip-Step -Name "agent operations foundation" -Stage "ReleaseDryRun" -Command ".\tools\check_agent_ops_foundation.ps1" -Reason "Track 14 agent ops script not created yet."
    }
} else {
    Skip-Step -Name "release validation matrix" -Stage "ReleaseDryRun" -Command "manifest/release/secrets/readiness" -Reason "Profile $EffectiveProfile does not include ReleaseDryRun."
}

if ($RunRemoteReadOnly) {
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
        $effectiveExpectedReleaseRoot = $ExpectedReleaseRoot.Trim()
        if ($effectiveExpectedReleaseRoot.Length -eq 0 -and $env:DRAXOS_EXPECTED_RELEASE_ROOT) {
            $effectiveExpectedReleaseRoot = $env:DRAXOS_EXPECTED_RELEASE_ROOT.Trim()
        }
        if ($effectiveExpectedReleaseRoot.Length -eq 0) {
            throw "-Profile RemoteReadOnly requires -ExpectedReleaseRoot or DRAXOS_EXPECTED_RELEASE_ROOT so artifact/Web release-root validation cannot be skipped."
        }
        Assert-ClientSafeValue -Value $remoteKey -Label "remote publishable key"

        $oldUrl = $env:SUPABASE_URL
        $oldKey = $env:SUPABASE_PUBLISHABLE_KEY
        $oldAccess = $env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS
        $oldFullHash = $env:DRAXOS_RELEASE_FULL_HASH
        $oldRemoteRelease = $env:DRAXOS_REMOTE_RELEASE_SMOKE
        $oldExpectedReleaseRoot = $env:DRAXOS_EXPECTED_RELEASE_ROOT
        $oldExpectedPortalUrl = $env:DRAXOS_EXPECTED_PORTAL_URL
        $oldExpectedWebUrl = $env:DRAXOS_EXPECTED_WEB_URL
        try {
            $env:SUPABASE_URL = $remoteUrl.Trim()
            $env:SUPABASE_PUBLISHABLE_KEY = $remoteKey.Trim()
            $env:DRAXOS_EXPECTED_RELEASE_ROOT = $effectiveExpectedReleaseRoot
            if ($ExpectedPortalUrl.Trim().Length -gt 0) {
                $env:DRAXOS_EXPECTED_PORTAL_URL = $ExpectedPortalUrl.Trim()
            }
            if ($ExpectedWebUrl.Trim().Length -gt 0) {
                $env:DRAXOS_EXPECTED_WEB_URL = $ExpectedWebUrl.Trim()
            }
            if ($AllowCloudflareAccess) {
                $env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS = "1"
            }
            if ($RemoteFullHash) {
                $env:DRAXOS_RELEASE_FULL_HASH = "1"
            }
            $env:DRAXOS_REMOTE_RELEASE_SMOKE = "1"
            Invoke-External -Command "release_manifest_smoke.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
                & npx -y deno run --allow-net --allow-env server/tests/release_manifest_smoke.ts
            }
            Invoke-External -Command "release_artifacts_remote_smoke.ts" -WorkingDirectory $ProjectPath -ScriptBlock {
                & npx -y deno run --allow-net --allow-env --allow-read server/tests/release_artifacts_remote_smoke.ts
            }
            Invoke-External -Command "internal_alpha_remote_smoke.ts read-only release/CORS" -WorkingDirectory $ProjectPath -ScriptBlock {
                & npx -y deno run --allow-net --allow-env server/tests/internal_alpha_remote_smoke.ts
            }
        } finally {
            $env:SUPABASE_URL = $oldUrl
            $env:SUPABASE_PUBLISHABLE_KEY = $oldKey
            $env:DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS = $oldAccess
            $env:DRAXOS_RELEASE_FULL_HASH = $oldFullHash
            $env:DRAXOS_REMOTE_RELEASE_SMOKE = $oldRemoteRelease
            $env:DRAXOS_EXPECTED_RELEASE_ROOT = $oldExpectedReleaseRoot
            $env:DRAXOS_EXPECTED_PORTAL_URL = $oldExpectedPortalUrl
            $env:DRAXOS_EXPECTED_WEB_URL = $oldExpectedWebUrl
        }
    }
    if ($RemoteWebUrl.Trim().Length -gt 0) {
        Invoke-Step -Name "remote Web launch smoke" -Stage "RemoteReadOnly" -Command "tools\smoke_web_launch_remote.ps1 -WebUrl <remote>" -ScriptBlock {
            $webUrl = $RemoteWebUrl.Trim()
            if (-not $webUrl.StartsWith("https://")) {
                throw "-RemoteWebUrl must be an https URL."
            }
            $smokeArgs = @(
                "-NoProfile",
                "-ExecutionPolicy",
                "Bypass",
                "-File",
                ".\tools\smoke_web_launch_remote.ps1",
                "-WebUrl",
                $webUrl
            )
            $effectiveExpectedReleaseRoot = $ExpectedReleaseRoot.Trim()
            if ($effectiveExpectedReleaseRoot.Length -eq 0 -and $env:DRAXOS_EXPECTED_RELEASE_ROOT) {
                $effectiveExpectedReleaseRoot = $env:DRAXOS_EXPECTED_RELEASE_ROOT.Trim()
            }
            if ($effectiveExpectedReleaseRoot.Length -eq 0) {
                throw "-RemoteWebUrl validation requires -ExpectedReleaseRoot or DRAXOS_EXPECTED_RELEASE_ROOT."
            }
            $smokeArgs += @("-ExpectedReleaseRoot", $effectiveExpectedReleaseRoot)
            if ($RemoteDiagnosticsDir.Trim().Length -gt 0) {
                $smokeArgs += @("-DiagnosticsDir", $RemoteDiagnosticsDir.Trim())
            }
            if ($AllowCloudflareAccess) {
                $smokeArgs += "-AllowCloudflareAccess"
            }
            if ($NoProjectWrites) {
                $smokeArgs += "-NoProjectWrites"
            }
            if ($KeepDiagnostics) {
                $smokeArgs += "-KeepDiagnostics"
            }
            Invoke-External -Command "smoke_web_launch_remote.ps1" -WorkingDirectory $ProjectPath -ScriptBlock {
                & powershell @smokeArgs
            }
        }
    } else {
        Skip-Step -Name "remote Web launch smoke" -Stage "RemoteReadOnly" -Command "tools\smoke_web_launch_remote.ps1" -Reason "-RemoteWebUrl was not provided."
    }
} else {
    Skip-Step -Name "remote read-only artifacts smoke" -Stage "RemoteReadOnly" -Command "release_artifacts_remote_smoke.ts" -Reason "Profile $EffectiveProfile does not include RemoteReadOnly and -IncludeRemoteReadOnly was not set."
    Skip-Step -Name "remote Web launch smoke" -Stage "RemoteReadOnly" -Command "tools\smoke_web_launch_remote.ps1" -Reason "Profile $EffectiveProfile does not include RemoteReadOnly and -IncludeRemoteReadOnly was not set."
}

Skip-Step -Name "full publish handoff gate" -Stage "FullPublish" -Command "publish_internal_alpha.ps1 -Mode FullPublish" -Reason "Publication is disabled in validate_foundation.ps1; use publish_internal_alpha.ps1 directly with -ReleaseRoot and -ConfirmRemoteMutation after validation."

Write-Reports
Write-Host "Report JSON: $JsonReportPath"
Write-Host "Report MD:   $MarkdownReportPath"

if ($HadFailure) {
    Write-Host "DraxosMobile foundation validation failed." -ForegroundColor Red
    exit 1
}

Write-Host "DraxosMobile foundation validation OK." -ForegroundColor Green
