[CmdletBinding()]
param(
    [ValidateSet('Core', 'Godot', 'Web', 'Backend', 'Android', 'All')]
    [string]$Mode = 'Core',
    [string]$Project = 'AllOfficial',
    [string]$GodotExe = '',
    [string]$ChromePath = '',
    [string]$ReportPath = '',
    [switch]$Ci,
    [switch]$AuditOnly
)

$ErrorActionPreference = 'Stop'
if ($Ci -and $AuditOnly) {
    throw '-AuditOnly is forbidden with -Ci.'
}
$root = Split-Path -Parent $PSScriptRoot
$results = New-Object System.Collections.Generic.List[object]
$failed = $false

function Add-Result {
    param([string]$Name, [string]$Status, [string]$Detail, [double]$DurationMs)
    $script:results.Add([pscustomobject]@{
        name = $Name
        status = $Status
        detail = $Detail
        duration_ms = [math]::Round($DurationMs, 2)
    }) | Out-Null
    Write-Host ("[{0}] {1} - {2}" -f $Status.ToUpperInvariant(), $Name, $Detail)
}

function Invoke-Required {
    param([string]$Name, [scriptblock]$Action)
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $detail = & $Action
        $timer.Stop()
        $detailText = if ($null -eq $detail) { 'completed without pipeline output' } else { ([string]$detail).Trim() }
        $status = if ($detailText.StartsWith('WARN:')) { 'warn' } else { 'pass' }
        Add-Result -Name $Name -Status $status -Detail $detailText -DurationMs $timer.Elapsed.TotalMilliseconds
    } catch {
        $timer.Stop()
        $script:failed = $true
        $status = if ($AuditOnly) { 'audit_fail' } else { 'fail' }
        Add-Result -Name $Name -Status $status -Detail $_.Exception.Message -DurationMs $timer.Elapsed.TotalMilliseconds
    }
}

function Invoke-Optional {
    param([string]$Name, [scriptblock]$Action)
    $timer = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $detail = & $Action
        $timer.Stop()
        $detailText = if ($null -eq $detail) { 'completed without pipeline output' } else { ([string]$detail).Trim() }
        Add-Result -Name $Name -Status 'pass' -Detail $detailText -DurationMs $timer.Elapsed.TotalMilliseconds
    } catch {
        $timer.Stop()
        Add-Result -Name $Name -Status 'warn' -Detail $_.Exception.Message -DurationMs $timer.Elapsed.TotalMilliseconds
    }
}

function Assert-Command {
    param([string]$Command)
    $found = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $found) { throw "$Command is unavailable." }
    return $found.Source
}

function Invoke-PythonCheck {
    param([string]$Script, [string[]]$Arguments)
    $python = Assert-Command 'python'
    $all = @((Join-Path $PSScriptRoot $Script), '--root', $root) + $Arguments
    if ($AuditOnly) { $all += '--audit-only' }
    $output = & $python @all 2>&1
    if ($LASTEXITCODE -ne 0) { throw (($output | Select-Object -Last 20) -join [Environment]::NewLine) }
    if (($output -join [Environment]::NewLine) -match 'AUDIT_FAIL') {
        throw (($output | Select-Object -Last 20) -join [Environment]::NewLine)
    }
    $last = [string]($output | Select-Object -Last 1)
    if (($output -join [Environment]::NewLine) -match '\]\s+WARN\s') {
        return "WARN: $last"
    }
    return $last
}

$runCore = $Mode -in @('Core', 'All')
$runGodot = $Mode -in @('Godot', 'All')
$runWeb = $Mode -in @('Web', 'All')
$runBackend = $Mode -in @('Backend', 'All')
$runAndroid = $Mode -in @('Android', 'All')

if ($runCore) {
    Invoke-Required 'Python 3.11+' {
        $path = Assert-Command 'python'
        $version = & $path -c "import sys; assert sys.version_info >= (3,11); print(sys.version.split()[0])"
        if ($LASTEXITCODE -ne 0) { throw 'Python 3.11+ is required.' }
        $version
    }
    Invoke-Required 'PowerShell 5.1+' {
        if ($PSVersionTable.PSVersion -lt [version]'5.1') { throw 'PowerShell 5.1+ is required.' }
        $PSVersionTable.PSVersion.ToString()
    }
    Invoke-Required 'Git' { $path = Assert-Command 'git'; (& $path --version) }
    Invoke-Required 'Git LFS' { $null = Assert-Command 'git'; $output = & git lfs version; if ($LASTEXITCODE -ne 0) { throw 'Git LFS is unavailable.' }; $output }
    Invoke-Required 'Execution lock contract' {
        $module = Join-Path $PSScriptRoot 'estudio_execution_lock.psm1'
        if (-not (Test-Path -LiteralPath $module -PathType Leaf)) { throw 'Execution lock module is missing.' }
        Import-Module $module -Force
        $lock = Enter-EstudioExecutionLock -Resource GodotQA -TimeoutSeconds 0
        try { 'Local\Estudio.GodotQA.v1 acquired and released' }
        finally { Exit-EstudioExecutionLock -Lock $lock -Resource GodotQA }
    }
    Invoke-Required 'Governance schema' { Invoke-PythonCheck 'check_governance_contract.py' @() }
    Invoke-Required 'Documentation, closure and Portfolio Sync' { Invoke-PythonCheck 'check_docs_contract.py' @('--project', $Project) }
    Invoke-Required 'Text integrity' { Invoke-PythonCheck 'check_text_integrity.py' @() }
    Invoke-Required 'Worktree overlap' { Invoke-PythonCheck 'check_worktree_overlap.py' @('--base-ref', 'main') }
    Invoke-Required 'Worktree lifecycle' {
        $output = & (Join-Path $PSScriptRoot 'check_worktree_lifecycle.ps1') -Root $root -FailOnOrphanDirs -Json 2>&1
        if ($LASTEXITCODE -ne 0) { throw (($output | Select-Object -Last 20) -join [Environment]::NewLine) }
        'registered worktrees and orphan directories checked'
    }
    Invoke-Required 'Repository storage' { Invoke-PythonCheck 'check_repository_storage.py' @('--base-ref', 'main') }
    Invoke-Required 'Tracked secret scan' {
        $output = & (Join-Path $PSScriptRoot 'check_secret_scan.ps1') -Root $root 2>&1
        if ($LASTEXITCODE -ne 0) { throw (($output | Select-Object -Last 20) -join [Environment]::NewLine) }
        if ($null -eq $output) { 'tracked files scanned; scanner emitted host-only output' }
        else { ($output | Select-Object -Last 1) }
    }
}

if ($runGodot) {
    Invoke-Required 'Godot 4.6.2-stable' {
        $candidates = New-Object System.Collections.Generic.List[string]
        if ($GodotExe.Trim().Length -gt 0) { $candidates.Add($GodotExe) }
        $candidates.Add((Join-Path $root '.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe'))
        $candidates.Add('D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe')
        $resolved = $candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
        if (-not $resolved) { throw 'Godot console executable was not found; pass -GodotExe.' }
        $version = (& $resolved --version | Select-Object -First 1).Trim()
        if ($version -notmatch '^4\.6\.2\.stable') { throw "Expected 4.6.2-stable, got $version" }
        $version
    }
    Invoke-Required 'QA manifests' { Invoke-PythonCheck 'check_qa_contract.py' @('--project', $Project) }
}

if ($runWeb) {
    Invoke-Required 'Node.js' { $path = Assert-Command 'node'; (& $path --version) }
    Invoke-Required 'npm' { $path = Assert-Command 'npm'; (& $path --version) }
    Invoke-Required 'Chromium/Chrome' {
        $candidates = @($ChromePath, "$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe")
        $resolved = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } | Select-Object -First 1
        if (-not $resolved) { throw 'Chrome/Chromium was not found; pass -ChromePath.' }
        $resolved
    }
    Invoke-Optional 'Wrangler CLI' { $path = Assert-Command 'wrangler'; (& $path --version) }
}

if ($runBackend) {
    Invoke-Required 'Node.js backend runtime' { $path = Assert-Command 'node'; (& $path --version) }
    Invoke-Required 'npx' { $path = Assert-Command 'npx'; (& $path --version) }
    Invoke-Optional 'Deno' { $path = Assert-Command 'deno'; (& $path --version | Select-Object -First 1) }
    Invoke-Optional 'Supabase CLI' { $path = Assert-Command 'supabase'; (& $path --version) }
    Invoke-Optional 'Docker' { $path = Assert-Command 'docker'; (& $path --version) }
}

if ($runAndroid) {
    Invoke-Required 'Java/JDK' { $path = Assert-Command 'java'; (& $path -version 2>&1 | Select-Object -First 1) }
    Invoke-Required 'Android adb' { $path = Assert-Command 'adb'; (& $path version | Select-Object -First 1) }
    Add-Result -Name 'Physical device' -Status 'skip' -Detail 'Physical-device QA is a human gate and is never probed by StudioDoctor.' -DurationMs 0
}

$summaryStatus = if ($failed -and $AuditOnly) { 'audit_fail' } elseif ($failed) { 'fail' } elseif (($results | Where-Object status -eq 'warn').Count -gt 0) { 'warn' } else { 'pass' }
$report = [pscustomobject]@{
    schema = 'estudio_doctor_report_v1'
    mode = $Mode
    project = $Project
    ci = $Ci.IsPresent
    audit_only = $AuditOnly.IsPresent
    status = $summaryStatus
    results = $results
}
if ($ReportPath.Trim().Length -gt 0) {
    $parent = Split-Path -Parent $ReportPath
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    $report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $ReportPath -Encoding UTF8
}
if ($failed -and -not $AuditOnly) { exit 1 }
exit 0
