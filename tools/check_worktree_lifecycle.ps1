[CmdletBinding()]
param(
    [string]$Root = '',
    [string]$WorktreeRoot = 'D:\Estudio-worktrees',
    [string]$BaseBranch = 'main',
    [string]$BranchPattern = 'codex/*',
    [string[]]$OrphanDirectoryExclusions = @('*-reports'),
    [switch]$FailOnDirty,
    [switch]$FailOnOpenWorktrees,
    [switch]$FailOnMergedBranches,
    [switch]$FailOnBehindOpenWorktrees,
    [switch]$FailOnOrphanDirs,
    [switch]$AuditOnly,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Root)) {
    $candidate = & git rev-parse --show-toplevel 2>$null
    $Root = if ($LASTEXITCODE -eq 0 -and $candidate) { $candidate.Trim() } else { Split-Path -Parent $PSScriptRoot }
}
$Root = (Resolve-Path -LiteralPath $Root).Path

function Invoke-Git([string[]]$Arguments) {
    $output = & git -C $Root @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) { throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)" }
    return @($output)
}

function Normalize-Path([string]$Value) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return '' }
    return [System.IO.Path]::GetFullPath($Value).TrimEnd('\', '/').ToLowerInvariant()
}

function Get-Worktrees {
    $items = New-Object System.Collections.Generic.List[object]
    $current = [ordered]@{}
    foreach ($line in (Invoke-Git @('worktree', 'list', '--porcelain'))) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if ($current.Contains('path')) { $items.Add([pscustomobject]$current) | Out-Null }
            $current = [ordered]@{}
        }
        elseif ($line.StartsWith('worktree ')) { $current.path = $line.Substring(9) }
        elseif ($line.StartsWith('HEAD ')) { $current.head = $line.Substring(5) }
        elseif ($line.StartsWith('branch ')) { $current.branch = $line.Substring(7) -replace '^refs/heads/', '' }
        elseif ($line -eq 'detached') { $current.branch = '(detached)' }
        elseif ($line.StartsWith('locked')) { $current.locked = $true }
        elseif ($line.StartsWith('prunable')) { $current.prunable = $true }
    }
    if ($current.Contains('path')) { $items.Add([pscustomobject]$current) | Out-Null }
    return $items.ToArray()
}

function Get-Counts([string]$Branch) {
    if ([string]::IsNullOrWhiteSpace($Branch) -or $Branch -eq '(detached)') { return @(0, 0) }
    $line = (Invoke-Git @('rev-list', '--left-right', '--count', "$BaseBranch...$Branch") | Select-Object -First 1)
    $parts = @($line -split '\s+' | Where-Object { $_ })
    return @([int]$parts[0], [int]$parts[1])
}

$issues = New-Object System.Collections.Generic.List[string]
$worktrees = New-Object System.Collections.Generic.List[object]
$registered = New-Object System.Collections.Generic.HashSet[string]
foreach ($item in Get-Worktrees) {
    $normalized = Normalize-Path $item.path
    $registered.Add($normalized) | Out-Null
    $status = if (Test-Path -LiteralPath $item.path) { @(& git -C $item.path status --porcelain=v1 --untracked-files=all 2>$null) } else { @('missing path') }
    $status = @($status | Where-Object { $_ })
    $counts = Get-Counts $item.branch
    $isBase = $item.branch -eq $BaseBranch
    $record = [pscustomobject]@{
        path = $item.path
        branch = if ($item.branch) { $item.branch } else { '(unknown)' }
        head = $item.head
        is_base = $isBase
        dirty = $status.Count -gt 0
        dirty_entries = $status.Count
        behind = $counts[0]
        ahead = $counts[1]
        locked = [bool]$item.locked
        prunable = [bool]$item.prunable
    }
    $worktrees.Add($record) | Out-Null
    if ($FailOnDirty -and $record.dirty) { $issues.Add("dirty worktree: $($record.path) [$($record.branch)]") | Out-Null }
    if ($FailOnOpenWorktrees -and -not $isBase) { $issues.Add("open worktree: $($record.path) [$($record.branch)]") | Out-Null }
    if ($FailOnBehindOpenWorktrees -and -not $isBase -and $record.behind -gt 0) { $issues.Add("behind open worktree: $($record.branch) behind=$($record.behind)") | Out-Null }
}

$orphanDirs = New-Object System.Collections.Generic.List[string]
if (Test-Path -LiteralPath $WorktreeRoot -PathType Container) {
    foreach ($directory in Get-ChildItem -LiteralPath $WorktreeRoot -Directory -Force) {
        $excluded = @($OrphanDirectoryExclusions | Where-Object { $directory.Name -like $_ }).Count -gt 0
        if ($excluded) { continue }
        if (-not $registered.Contains((Normalize-Path $directory.FullName))) {
            $orphanDirs.Add($directory.FullName) | Out-Null
            if ($FailOnOrphanDirs) { $issues.Add("orphan worktree directory: $($directory.FullName)") | Out-Null }
        }
    }
}

$merged = @(Invoke-Git @('branch', '--merged', $BaseBranch, '--format=%(refname:short)') | Where-Object { $_ -like $BranchPattern -and $_ -ne $BaseBranch } | Sort-Object -Unique)
$unmerged = @(Invoke-Git @('branch', '--no-merged', $BaseBranch, '--format=%(refname:short)') | Where-Object { $_ -like $BranchPattern } | Sort-Object -Unique)
if ($FailOnMergedBranches) {
    foreach ($branch in $merged) { $issues.Add("merged branch not cleaned: $branch") | Out-Null }
}

$statusName = if ($issues.Count -eq 0) { 'pass' } elseif ($AuditOnly) { 'audit_fail' } else { 'fail' }
$report = [pscustomobject]@{
    schema = 'estudio_worktree_lifecycle_v1'
    status = $statusName
    root = $Root
    worktree_root = $WorktreeRoot
    base_branch = $BaseBranch
    worktrees = $worktrees.ToArray()
    merged_branches = $merged
    unmerged_branches = $unmerged
    orphan_directories = $orphanDirs.ToArray()
    issues = $issues.ToArray()
}

if ($Json) {
    $report | ConvertTo-Json -Depth 8
}
else {
    Write-Host "Worktree lifecycle: $($statusName.ToUpperInvariant()) worktrees=$($worktrees.Count) dirty=$(@($worktrees | Where-Object dirty).Count) merged_branches=$($merged.Count) orphan_dirs=$($orphanDirs.Count)"
    foreach ($issue in $issues) { Write-Host " - $issue" }
}
if ($issues.Count -gt 0 -and -not $AuditOnly) { exit 1 }
exit 0
