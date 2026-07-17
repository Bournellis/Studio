param(
    [Parameter(Mandatory = $true)]
    [string[]]$Path,
    [string]$Root = (Split-Path -Parent $PSScriptRoot),
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

function Invoke-GitText([string[]]$Arguments) {
    $output = (& git -C $script:RepoRoot @Arguments 2>&1 | Out-String).Trim()
    if ($LASTEXITCODE -ne 0) { throw "Git command failed: git $($Arguments -join ' ')" }
    return $output
}

function Test-LiteralRelativePath([string]$Candidate) {
    if ([string]::IsNullOrWhiteSpace($Candidate)) { throw "Path cannot be empty." }
    if ([System.IO.Path]::IsPathRooted($Candidate) -or $Candidate.StartsWith('\\') -or $Candidate -match '[\x00-\x1f:]') {
        throw "Path must be a safe repository-relative path."
    }
    $relative = ($Candidate -replace '\\', '/')
    while ($relative.StartsWith('./')) { $relative = $relative.Substring(2) }
    $parts = @($relative -split '/')
    if ($relative -match '[*?\[\]{}]' -or $parts -contains '..' -or $parts -contains '.git' -or $parts[-1] -eq '.gitattributes') {
        throw "Path is not an eligible literal asset path."
    }
    return $relative
}

function Test-BroadLfsRule([string]$Line) {
    $trimmed = $Line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#') -or $trimmed -notmatch '(?:^|\s)filter=lfs(?:\s|$)') {
        return $false
    }
    $pattern = ($trimmed -split '\s+')[0]
    $index = 0
    while ($index -lt $pattern.Length) {
        if ($pattern[$index] -eq '\') { $index += 2; continue }
        if ($pattern[$index] -in @('*', '?', '[')) { return $true }
        $index++
    }
    return $pattern.StartsWith('[attr]') -or $pattern.EndsWith('/')
}

function Get-AttributeMap([string]$Relative) {
    $output = Invoke-GitText @('check-attr', 'filter', 'diff', 'merge', 'text', '--', $Relative)
    $map = @{}
    foreach ($line in ($output -split "`r?`n")) {
        if ($line -match '^[^:]+:\s*([^:]+):\s*(.+)$') { $map[$Matches[1].Trim()] = $Matches[2].Trim() }
    }
    return $map
}

function Test-CompleteLfsAttributes($Map) {
    return $Map['filter'] -eq 'lfs' -and $Map['diff'] -eq 'lfs' -and $Map['merge'] -eq 'lfs' -and $Map['text'] -eq 'unset'
}

function Test-GitPathInIndex([string]$Relative) {
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & git -C $script:RepoRoot ls-files --error-unmatch -- $Relative 2>$null | Out-Null
        return $LASTEXITCODE -eq 0
    }
    finally { $ErrorActionPreference = $previousPreference }
}

$repoOutput = (& git -C $Root rev-parse --show-toplevel 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($repoOutput)) { throw "Root is not a Git worktree." }
$script:RepoRoot = [System.IO.Path]::GetFullPath($repoOutput).TrimEnd('\', '/')
$branch = Invoke-GitText @('branch', '--show-current')
if ([string]::IsNullOrWhiteSpace($branch)) { throw "Detached HEAD is not allowed." }
if ($Apply -and $branch -in @('main', 'master')) { throw "Apply requires an isolated task branch." }

$lfsVersion = (& git -C $script:RepoRoot lfs version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw "Git LFS is unavailable." }

$attributesRelative = '.gitattributes'
$attributesPath = Join-Path $script:RepoRoot $attributesRelative
if (-not (Test-Path -LiteralPath $attributesPath -PathType Leaf)) { throw "Missing tracked .gitattributes." }
if (-not (Test-GitPathInIndex $attributesRelative)) { throw ".gitattributes must already be tracked." }
$unmerged = (& git -C $script:RepoRoot ls-files -u -- $attributesRelative 2>&1 | Out-String).Trim()
if (-not [string]::IsNullOrWhiteSpace($unmerged)) { throw ".gitattributes is unmerged." }
& git -C $script:RepoRoot diff --cached --quiet -- $attributesRelative
if ($LASTEXITCODE -ne 0) { throw ".gitattributes has staged changes." }
& git -C $script:RepoRoot diff --quiet -- $attributesRelative
$attributesDirty = $LASTEXITCODE -ne 0

foreach ($line in [System.IO.File]::ReadAllLines($attributesPath)) {
    if (Test-BroadLfsRule $line) { throw "Existing broad LFS rules block literal registration." }
}

$validated = New-Object System.Collections.Generic.List[string]
$seen = @{}
foreach ($candidate in $Path) {
    $relative = Test-LiteralRelativePath $candidate
    if ($seen.ContainsKey($relative)) { throw "Duplicate path request: $relative" }
    $seen[$relative] = $true
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $script:RepoRoot ($relative -replace '/', '\')))
    $prefix = $script:RepoRoot + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) { throw "Path escapes the repository." }
    if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) { throw "Path must name an existing file: $relative" }
    $item = Get-Item -LiteralPath $fullPath -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse points are not eligible: $relative" }
    $cursor = $item.Directory
    while ($null -ne $cursor -and $cursor.FullName.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        if (($cursor.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Reparse points are not eligible: $relative" }
        $cursor = $cursor.Parent
    }
    & git -C $script:RepoRoot check-ignore -q -- $relative
    if ($LASTEXITCODE -eq 0) { throw "Ignored paths are not eligible: $relative" }
    if (Test-GitPathInIndex $relative) { throw "Tracked or staged paths are not new: $relative" }
    $historical = (& git -C $script:RepoRoot log --all --format=%H -- ":(icase,literal)$relative" 2>$null | Out-String).Trim()
    if (-not [string]::IsNullOrWhiteSpace($historical)) { throw "Path already exists in local repository history: $relative" }
    $attributes = Get-AttributeMap $relative
    $specifiedLfsFields = @(@('filter', 'diff', 'merge') | Where-Object { $attributes[$_] -notin @('unspecified', 'unset') })
    if ($specifiedLfsFields.Count -gt 0 -and -not (Test-CompleteLfsAttributes $attributes)) {
        throw "Conflicting attributes already apply to $relative"
    }
    $validated.Add($relative) | Out-Null
}

$allRegistered = $true
foreach ($relative in $validated) {
    if (-not (Test-CompleteLfsAttributes (Get-AttributeMap $relative))) { $allRegistered = $false; break }
}
if ($attributesDirty -and -not $allRegistered) { throw ".gitattributes has unrelated unstaged changes." }

if (-not $Apply) {
    foreach ($relative in $validated) {
        if (Test-CompleteLfsAttributes (Get-AttributeMap $relative)) {
            Write-Host "LFS_REGISTER_ALREADY_PRESENT path=$relative"
            continue
        }
        $preview = (& git -C $script:RepoRoot lfs track --dry-run --filename -- $relative 2>&1 | Out-String).Trim()
        if ($LASTEXITCODE -ne 0) { throw "Git LFS dry-run failed for $relative" }
        Write-Host "LFS_REGISTER_DRY_RUN path=$relative"
        if (-not [string]::IsNullOrWhiteSpace($preview)) { Write-Host $preview }
    }
    Write-Host "LFS_REGISTER_PASS mode=dry-run count=$($validated.Count)"
    exit 0
}

$beforeAttributes = [System.IO.File]::ReadAllBytes($attributesPath)
$beforeIndex = (& git -C $script:RepoRoot diff --cached --name-only 2>&1 | Out-String)
try {
    foreach ($relative in $validated) {
        if (-not (Test-CompleteLfsAttributes (Get-AttributeMap $relative))) {
            $result = (& git -C $script:RepoRoot lfs track --filename -- $relative 2>&1 | Out-String).Trim()
            if ($LASTEXITCODE -ne 0) { throw "Git LFS registration failed for $relative" }
        }
        if (-not (Test-CompleteLfsAttributes (Get-AttributeMap $relative))) { throw "Post-registration attributes are incomplete." }
        if (Test-GitPathInIndex $relative) { throw "Registration unexpectedly staged the asset." }
        Write-Host "LFS_REGISTER_APPLIED path=$relative"
    }
    $afterIndex = (& git -C $script:RepoRoot diff --cached --name-only 2>&1 | Out-String)
    if ($afterIndex -ne $beforeIndex) { throw "Registration changed the staged index." }
}
catch {
    [System.IO.File]::WriteAllBytes($attributesPath, $beforeAttributes)
    throw
}
Write-Host "LFS_REGISTER_PASS mode=apply count=$($validated.Count)"
