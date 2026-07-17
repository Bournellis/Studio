[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [string]$WorktreePath = (Get-Location).Path,
    [Parameter(Mandatory = $true)][string]$Message,
    [Parameter(Mandatory = $true)][string[]]$Paths,
    [string]$ExpectedBranch = '',
    [switch]$RequireCleanAfter,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Message)) { throw 'Commit message cannot be empty.' }
if ($Paths.Count -eq 0) { throw 'At least one explicit path is required.' }
$worktree = (Resolve-Path -LiteralPath $WorktreePath).Path
if (-not (Test-Path -LiteralPath $worktree -PathType Container)) { throw "WorktreePath is not a directory: $worktree" }

function Invoke-Git([string[]]$Arguments, [switch]$AllowFailure) {
    # Native stderr is expected for probes such as `git ls-files
    # --error-unmatch`.  Capture it and decide by exit code instead of letting
    # ErrorActionPreference=Stop turn an allowed miss into an exception.
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $output = & git -C $worktree @Arguments 2>&1
        $code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousErrorAction
    }
    if ($code -ne 0 -and -not $AllowFailure) { throw "git $($Arguments -join ' ') failed: $($output -join [Environment]::NewLine)" }
    return [pscustomobject]@{ code = $code; output = @($output) }
}

$top = ((Invoke-Git @('rev-parse', '--show-toplevel')).output | Select-Object -First 1).Trim()
if ((Resolve-Path -LiteralPath $top).Path -ne $worktree) { throw "WorktreePath must be the Git top-level directory: $top" }
$branch = ((Invoke-Git @('branch', '--show-current')).output | Select-Object -First 1).Trim()
if ([string]::IsNullOrWhiteSpace($branch)) { throw 'Detached HEAD is not supported.' }
if ($ExpectedBranch -and $branch -ne $ExpectedBranch) { throw "Current branch is '$branch', expected '$ExpectedBranch'." }

$registered = @((Invoke-Git @('worktree', 'list', '--porcelain')).output | Where-Object { $_ -like 'worktree *' } | ForEach-Object { [System.IO.Path]::GetFullPath($_.Substring(9)).TrimEnd('\', '/').ToLowerInvariant() })
$normalized = [System.IO.Path]::GetFullPath($worktree).TrimEnd('\', '/').ToLowerInvariant()
if ($registered -notcontains $normalized) { throw 'WorktreePath is not registered by git worktree list.' }

$staged = Invoke-Git @('diff', '--cached', '--quiet') -AllowFailure
if ($staged.code -eq 1) { throw 'The index already contains staged changes; commit or unstage them before using this helper.' }
if ($staged.code -ne 0) { throw 'Could not inspect the Git index.' }

$safePaths = New-Object System.Collections.Generic.List[string]
foreach ($item in $Paths) {
    $value = $item.Replace('\', '/').Trim()
    if ([string]::IsNullOrWhiteSpace($value) -or [System.IO.Path]::IsPathRooted($value)) { throw "Path must be non-empty and repository-relative: $item" }
    if (@($value.Split('/') | Where-Object { $_ -eq '..' }).Count -gt 0) { throw "Parent traversal is forbidden: $item" }
    $candidate = Join-Path $worktree $value
    $tracked = Invoke-Git @('ls-files', '--error-unmatch', '--', $value) -AllowFailure
    if (-not (Test-Path -LiteralPath $candidate) -and $tracked.code -ne 0) { throw "Path does not exist and is not a tracked deletion: $value" }
    $safePaths.Add($value) | Out-Null
}
$safePaths = @($safePaths | Sort-Object -Unique)

Write-Host "Commit helper: branch=$branch worktree=$worktree"
Write-Host "Message: $Message"
Write-Host "Explicit paths: $($safePaths -join ', ')"
if ($DryRun) {
    $preview = (Invoke-Git (@('status', '--short', '--') + $safePaths)).output
    foreach ($line in $preview) { Write-Host "  $line" }
    Write-Host 'Dry run: no staging or commit performed.'
    exit 0
}
if (-not $PSCmdlet.ShouldProcess($worktree, "stage explicit paths and create local commit on $branch")) {
    Write-Host 'Confirmation declined; no staging or commit performed.'
    exit 0
}

$null = Invoke-Git (@('add', '--') + $safePaths)
$candidate = Invoke-Git @('diff', '--cached', '--quiet') -AllowFailure
if ($candidate.code -eq 0) { throw 'Explicit paths produced no staged changes.' }
if ($candidate.code -ne 1) { throw 'Could not inspect staged changes.' }
(Invoke-Git @('diff', '--cached', '--stat')).output | Write-Host
$null = Invoke-Git @('commit', '-m', $Message)
$sha = ((Invoke-Git @('rev-parse', 'HEAD')).output | Select-Object -First 1).Trim()

if ($RequireCleanAfter) {
    $remaining = @((Invoke-Git @('status', '--porcelain=v1', '--untracked-files=all')).output | Where-Object { $_ })
    if ($remaining.Count -gt 0) { throw "Commit $sha succeeded but the worktree is not clean: $($remaining -join '; ')" }
}

Write-Host '== Commit receipt =='
Write-Host "- branch: $branch"
Write-Host "- worktree: $worktree"
Write-Host "- commit: $sha"
Write-Host '- remote_mutation: none'
exit 0
