[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory = $true)][string]$WorktreePath,
    [Parameter(Mandatory = $true)][string]$Branch,
    [string]$BaseBranch = 'main',
    [switch]$MergeFfOnly,
    [ValidateSet('Auto', 'Docs', 'QA', 'Runtime', 'Build')]
    [string]$ValidationTier = 'Auto',
    [Parameter(Mandatory = $true)][string]$ValidationProject,
    [string]$GodotExe = '',
    [switch]$DeleteBranch,
    [switch]$Prune,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if (-not $MergeFfOnly) { throw '-MergeFfOnly is mandatory; non-fast-forward integration is outside this helper.' }
if (-not $DeleteBranch -or -not $Prune) { throw '-DeleteBranch and -Prune are mandatory for a complete local lifecycle.' }

$target = (Resolve-Path -LiteralPath $WorktreePath).Path
if (-not (Test-Path -LiteralPath $target -PathType Container)) { throw "WorktreePath is not a directory: $target" }

function Invoke-Git([string]$WorkingDirectory, [string[]]$Arguments, [switch]$AllowFailure) {
    $output = & git -C $WorkingDirectory @Arguments 2>&1
    $code = $LASTEXITCODE
    if ($code -ne 0 -and -not $AllowFailure) { throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)" }
    return [pscustomobject]@{ code = $code; output = @($output) }
}

function Assert-Clean([string]$WorkingDirectory, [string]$Label) {
    $status = @((Invoke-Git $WorkingDirectory @('status', '--porcelain=v1', '--untracked-files=all')).output | Where-Object { $_ })
    if ($status.Count -gt 0) { throw "$Label is not clean: $($status -join '; ')" }
}

$actualRoot = ((Invoke-Git $target @('rev-parse', '--show-toplevel')).output | Select-Object -First 1).Trim()
if ((Resolve-Path -LiteralPath $actualRoot).Path -ne $target) { throw "WorktreePath must be the Git top level: $actualRoot" }
$actualBranch = ((Invoke-Git $target @('branch', '--show-current')).output | Select-Object -First 1).Trim()
if ($actualBranch -ne $Branch) { throw "Target worktree is on '$actualBranch', expected '$Branch'." }
Assert-Clean $target 'Target worktree'

$records = (Invoke-Git $target @('worktree', 'list', '--porcelain')).output
$basePath = $null
$currentPath = $null
foreach ($line in $records) {
    if ($line -like 'worktree *') { $currentPath = $line.Substring(9) }
    elseif ($line -eq "branch refs/heads/$BaseBranch") { $basePath = $currentPath }
}
if (-not $basePath -or -not (Test-Path -LiteralPath $basePath -PathType Container)) { throw "No live worktree found for base branch '$BaseBranch'." }
$basePath = (Resolve-Path -LiteralPath $basePath).Path
if ($basePath -eq $target) { throw 'Target and base worktrees must be distinct.' }
Assert-Clean $basePath 'Base worktree'

$currentLocation = [System.IO.Path]::GetFullPath((Get-Location).Path).TrimEnd('\', '/').ToLowerInvariant()
$normalizedTarget = [System.IO.Path]::GetFullPath($target).TrimEnd('\', '/').ToLowerInvariant()
if ($currentLocation -eq $normalizedTarget -or $currentLocation.StartsWith($normalizedTarget + [System.IO.Path]::DirectorySeparatorChar)) {
    throw 'Run the close helper from the base workspace or another worktree, never from the target being removed.'
}

$mergeBase = ((Invoke-Git $target @('merge-base', $BaseBranch, $Branch)).output | Select-Object -First 1).Trim()
$targetCommit = ((Invoke-Git $target @('rev-parse', $Branch)).output | Select-Object -First 1).Trim()
$baseBefore = ((Invoke-Git $basePath @('rev-parse', $BaseBranch)).output | Select-Object -First 1).Trim()
$ffCheck = Invoke-Git $target @('merge-base', '--is-ancestor', $BaseBranch, $Branch) -AllowFailure
if ($ffCheck.code -ne 0) { throw "$Branch is not a fast-forward descendant of $BaseBranch. Rebase locally before closure." }

$changed = @((Invoke-Git $target @('diff', '--name-only', "$mergeBase..$Branch")).output | Where-Object { $_ })
$effectiveTier = $ValidationTier
if ($effectiveTier -eq 'Auto') {
    if ($changed -match '(?i)(export_presets|(^|/)(build|android|web)(/|$)|\.apk$|\.aab$)') { $effectiveTier = 'Build' }
    elseif ($changed -match '(?i)(^|/)(qa|tests?)(/|$)|^tools/.+\.(py|ps1|psm1)$') { $effectiveTier = 'QA' }
    elseif ($changed -match '(?i)^Projetos/.+\.(gd|tscn|tres|ts|sql|ps1)$') { $effectiveTier = 'Runtime' }
    else { $effectiveTier = 'Docs' }
}
$profileMap = @{ Docs = 'DocsOnly'; QA = 'FastSuite'; Runtime = 'Runtime'; Build = 'Build' }
$profile = $profileMap[$effectiveTier]
$toolsChanged = @($changed | Where-Object { $_ -like 'tools/*' }).Count -gt 0

function Get-ValidationArgs([string]$WorkingDirectory) {
    $script = Join-Path $WorkingDirectory 'tools\validate_estudio.ps1'
    if (-not (Test-Path -LiteralPath $script -PathType Leaf)) { throw "Validation script is missing: $script" }
    $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $script, '-Profile', $profile, '-Project', $ValidationProject, '-BaseRef', $mergeBase)
    if ($GodotExe.Trim().Length -gt 0) { $args += @('-GodotExe', $GodotExe) }
    return $args
}

function Invoke-Validation([string]$WorkingDirectory, [string]$Label) {
    $args = Get-ValidationArgs $WorkingDirectory
    Write-Host "[$Label] powershell $($args -join ' ')"
    if ($DryRun) { return }
    & powershell @args
    if ($LASTEXITCODE -ne 0) { throw "$Label validation failed with exit code $LASTEXITCODE." }
    if ($toolsChanged) {
        & python -m unittest discover -s (Join-Path $WorkingDirectory 'tools\tests') -p 'test_*.py'
        if ($LASTEXITCODE -ne 0) { throw "$Label tooling unit tests failed with exit code $LASTEXITCODE." }
    }
    Assert-Clean $WorkingDirectory "$Label worktree after validation"
}

Write-Host "Closure plan: $Branch@$targetCommit -> $BaseBranch@$baseBefore"
Write-Host "Changed files: $($changed.Count); validation requested=$ValidationTier effective=$effectiveTier profile=$profile; BaseRef=$mergeBase"

$overlap = Join-Path $target 'tools\check_worktree_overlap.py'
if (-not (Test-Path -LiteralPath $overlap -PathType Leaf)) { throw "Worktree overlap checker is missing: $overlap" }
if (-not $DryRun) {
    & python $overlap --root $basePath --base-ref $mergeBase
    if ($LASTEXITCODE -ne 0) { throw 'Active worktree overlap gate failed.' }
}
Invoke-Validation $target 'Pre-merge'

if ($DryRun) {
    Write-Host '== Lifecycle receipt preview =='
    Write-Host '- merge_status: dry-run - not merged'
    Write-Host '- worktree_status: dry-run - not removed'
    Write-Host '- branch_cleanup: dry-run - not deleted'
    Write-Host '- post_merge_validation: dry-run - not executed'
    exit 0
}
if (-not $PSCmdlet.ShouldProcess($basePath, "fast-forward merge $Branch, validate, remove worktree and delete branch")) {
    Write-Host 'Confirmation declined; no merge or cleanup was performed.'
    exit 0
}

(Invoke-Git $basePath @('merge', '--ff-only', $Branch)).output | Write-Host
$mergedHead = ((Invoke-Git $basePath @('rev-parse', $BaseBranch)).output | Select-Object -First 1).Trim()
if ($mergedHead -ne $targetCommit) { throw "Fast-forward result mismatch: expected $targetCommit, got $mergedHead" }
Invoke-Validation $basePath 'Post-merge'
Assert-Clean $basePath 'Base worktree after post-merge validation'

(Invoke-Git $basePath @('worktree', 'remove', $target)).output | Write-Host
$mergedBranches = @((Invoke-Git $basePath @('branch', '--merged', $BaseBranch, '--format=%(refname:short)')).output)
if ($mergedBranches -notcontains $Branch) { throw "Refusing to delete $Branch because Git does not report it merged into $BaseBranch." }
(Invoke-Git $basePath @('branch', '-d', $Branch)).output | Write-Host
(Invoke-Git $basePath @('worktree', 'prune')).output | Write-Host
Assert-Clean $basePath 'Base worktree after lifecycle cleanup'

Write-Host '== Lifecycle receipt =='
Write-Host '- closure_contract: estudio_lifecycle_v1'
Write-Host "- commit: $targetCommit"
Write-Host "- merged_to: $BaseBranch@$mergedHead"
Write-Host '- merge_strategy: ff-only'
Write-Host '- merge_status: merged'
Write-Host '- worktree_status: removed'
Write-Host '- branch_cleanup: deleted'
Write-Host "- post_merge_validation: PASS - $profile $ValidationProject pre/post merge - BaseRef $mergeBase"
Write-Host "- closure_summary: technical branch integrated and locally cleaned; remote/publication unchanged"
Write-Host 'GIT_SYNC_NEXT: Codex global coordinator - follow GIT_SAFE_PUSH.md'
exit 0
