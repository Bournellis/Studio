[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$Branch,
    [string]$BaseBranch = 'main',
    [switch]$MergeFfOnly,
    [ValidateSet('Auto', 'Docs', 'QA', 'Runtime', 'Build')]
    [string]$ValidationTier = 'Auto',
    [Parameter(Mandatory = $true)][string]$ValidationProject,
    [switch]$DeleteBranch,
    [switch]$Prune
)

$ErrorActionPreference = 'Stop'
if (-not $MergeFfOnly) { throw '-MergeFfOnly is mandatory; non-fast-forward integration is outside this helper.' }
if (-not $DeleteBranch -or -not $Prune) { throw '-DeleteBranch and -Prune are mandatory for a complete local lifecycle.' }

$target = (Resolve-Path -LiteralPath $WorktreePath).Path
$targetInfo = Get-Item -LiteralPath $target
if (-not $targetInfo.PSIsContainer) { throw "WorktreePath is not a directory: $target" }

function Invoke-Git {
    param([string]$WorkingDirectory, [string[]]$Arguments)
    $output = & git -C $WorkingDirectory @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)" }
    return $output
}

function Assert-Clean {
    param([string]$WorkingDirectory, [string]$Label)
    $status = Invoke-Git $WorkingDirectory @('status', '--porcelain=v1', '--untracked-files=all')
    if (($status -join '').Trim().Length -gt 0) { throw "$Label is not clean: $($status -join '; ')" }
}

$actualBranch = (Invoke-Git $target @('branch', '--show-current') | Select-Object -First 1).Trim()
if ($actualBranch -ne $Branch) { throw "Target worktree is on '$actualBranch', expected '$Branch'." }
Assert-Clean $target 'Target worktree'

$records = Invoke-Git $target @('worktree', 'list', '--porcelain')
$basePath = $null
$currentPath = $null
foreach ($line in $records) {
    if ($line -like 'worktree *') { $currentPath = $line.Substring(9) }
    elseif ($line -eq "branch refs/heads/$BaseBranch") { $basePath = $currentPath }
}
if (-not $basePath -or -not (Test-Path -LiteralPath $basePath -PathType Container)) {
    throw "No live worktree found for base branch '$BaseBranch'."
}
$basePath = (Resolve-Path -LiteralPath $basePath).Path
if ($basePath -eq $target) { throw 'Target and base worktrees must be distinct.' }
Assert-Clean $basePath 'Base worktree'

$effectiveTier = $ValidationTier
if ($effectiveTier -eq 'Auto') {
    $changed = Invoke-Git $target @('diff', '--name-only', "$BaseBranch...$Branch")
    if ($changed -match '(?i)(export_presets|build|web|android|\.apk$|\.aab$)') { $effectiveTier = 'Build' }
    elseif ($changed -match '(?i)^Projetos/.+\.(gd|tscn|tres|ts|sql|ps1)$') { $effectiveTier = 'Runtime' }
    elseif ($changed -match '(?i)(^|/)(qa|tests?)/') { $effectiveTier = 'QA' }
    else { $effectiveTier = 'Docs' }
}
$profileMap = @{ Docs = 'DocsOnly'; QA = 'FastSuite'; Runtime = 'Runtime'; Build = 'Build' }
$profile = $profileMap[$effectiveTier]

function Invoke-Validation {
    param([string]$WorkingDirectory, [string]$Label)
    $script = Join-Path $WorkingDirectory 'tools\validate_estudio.ps1'
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) { throw "$Label validation script is missing: $script" }
    & powershell -NoProfile -ExecutionPolicy Bypass -File $script -Profile $profile -Project $ValidationProject -BaseRef $BaseBranch
    if ($LASTEXITCODE -ne 0) { throw "$Label validation failed with exit code $LASTEXITCODE." }
    $toolsChanged = Invoke-Git $target @('diff', '--name-only', "$BaseBranch...$Branch") | Where-Object { $_ -like 'tools/*' }
    if ($toolsChanged) {
        & python -m unittest discover -s (Join-Path $WorkingDirectory 'tools\tests') -p 'test_*.py'
        if ($LASTEXITCODE -ne 0) { throw "$Label tooling unit tests failed with exit code $LASTEXITCODE." }
    }
    Assert-Clean $WorkingDirectory "$Label worktree after validation"
}

Invoke-Validation $target 'Pre-merge'

if (-not $PSCmdlet.ShouldProcess($basePath, "fast-forward merge $Branch, validate, remove worktree and delete branch")) {
    Write-Host 'WhatIf/confirmation declined; no merge or cleanup was performed.'
    exit 0
}

Invoke-Git $basePath @('merge', '--ff-only', $Branch) | Write-Host
Invoke-Validation $basePath 'Post-merge'
Invoke-Git $basePath @('worktree', 'remove', $target) | Write-Host
Invoke-Git $basePath @('branch', '-d', $Branch) | Write-Host
Invoke-Git $basePath @('worktree', 'prune') | Write-Host

Write-Host "Lifecycle complete: $Branch -> $BaseBranch"
Write-Host 'PUSH PENDENTE: Fabio - GitHub Desktop - Push origin'
exit 0
