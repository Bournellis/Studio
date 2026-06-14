param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$Check,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"

if (-not $Check.IsPresent -and -not $Apply.IsPresent) {
    $Check = $true
}
if ($Check.IsPresent -and $Apply.IsPresent) {
    throw "Use only one mode: -Check or -Apply."
}

function Get-FullPath {
    param([string]$Path)
    return [System.IO.Path]::GetFullPath($Path).TrimEnd("\", "/")
}

function Test-IsPathInside {
    param(
        [string]$Path,
        [string]$Root
    )
    $fullPath = Get-FullPath $Path
    $fullRoot = Get-FullPath $Root
    return $fullPath.Equals($fullRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
        $fullPath.StartsWith("$fullRoot\", [System.StringComparison]::OrdinalIgnoreCase)
}

function Assert-PathInside {
    param(
        [string]$Path,
        [string]$Root,
        [string]$Label
    )
    $fullPath = Get-FullPath $Path
    if (-not (Test-IsPathInside -Path $fullPath -Root $Root)) {
        throw "$Label is outside the expected root. Path: $fullPath Root: $(Get-FullPath $Root)"
    }
    return $fullPath
}

function Assert-NoReparsePoint {
    param(
        [string]$Path,
        [string]$Label
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }
    $item = Get-Item -LiteralPath $Path -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "$Label must not be a reparse point: $Path"
    }
}

function Resolve-ProjectDir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "ProjectDir does not exist: $Path"
    }
    $resolved = (Resolve-Path -LiteralPath $Path).Path
    Assert-NoReparsePoint -Path $resolved -Label "ProjectDir"
    return (Get-FullPath $resolved)
}

function Resolve-RequiredDirectory {
    param(
        [string]$ProjectPath,
        [string]$RelativePath,
        [string]$Label
    )
    $expectedPath = Join-Path $ProjectPath $RelativePath
    Assert-PathInside -Path $expectedPath -Root $ProjectPath -Label $Label | Out-Null
    if (-not (Test-Path -LiteralPath $expectedPath -PathType Container)) {
        throw "$Label directory is missing: $expectedPath"
    }
    $resolvedPath = (Resolve-Path -LiteralPath $expectedPath).Path
    Assert-PathInside -Path $resolvedPath -Root $ProjectPath -Label $Label | Out-Null
    Assert-NoReparsePoint -Path $resolvedPath -Label $Label
    return (Get-FullPath $resolvedPath)
}

function Get-RelativePath {
    param(
        [string]$Root,
        [string]$Path
    )
    $rootPrefix = "$(Get-FullPath $Root)\"
    $fullPath = Get-FullPath $Path
    if (-not $fullPath.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Cannot make relative path. Path is outside root: $fullPath"
    }
    return $fullPath.Substring($rootPrefix.Length).Replace("\", "/")
}

function Get-MirrorFileMap {
    param(
        [string]$Root,
        [string]$Label
    )
    $map = @{}
    foreach ($file in Get-ChildItem -LiteralPath $Root -Recurse -Force -File | Sort-Object FullName) {
        Assert-NoReparsePoint -Path $file.FullName -Label "$Label file"
        $relative = Get-RelativePath -Root $Root -Path $file.FullName
        $map[$relative] = [pscustomobject]@{
            relative = $relative
            full_path = Get-FullPath $file.FullName
            sha256 = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
            length = $file.Length
        }
    }
    return $map
}

function Get-MirrorDirectorySet {
    param(
        [string]$Root,
        [string]$Label
    )
    $set = @{}
    foreach ($directory in Get-ChildItem -LiteralPath $Root -Recurse -Force -Directory | Sort-Object FullName) {
        Assert-NoReparsePoint -Path $directory.FullName -Label "$Label directory"
        $relative = Get-RelativePath -Root $Root -Path $directory.FullName
        $set[$relative] = $true
    }
    return $set
}

function Join-RelativePath {
    param(
        [string]$Root,
        [string]$RelativePath
    )
    return Join-Path $Root ($RelativePath.Replace("/", "\"))
}

function Compare-BackendMirror {
    param(
        [string]$SourceRoot,
        [string]$MirrorRoot,
        [string]$Label
    )
    $sourceFiles = Get-MirrorFileMap -Root $SourceRoot -Label "$Label source"
    $mirrorFiles = Get-MirrorFileMap -Root $MirrorRoot -Label "$Label mirror"
    $sourceDirectories = Get-MirrorDirectorySet -Root $SourceRoot -Label "$Label source"
    $mirrorDirectories = Get-MirrorDirectorySet -Root $MirrorRoot -Label "$Label mirror"

    $missing = New-Object System.Collections.Generic.List[string]
    $changed = New-Object System.Collections.Generic.List[string]
    $extraFiles = New-Object System.Collections.Generic.List[string]
    $extraDirectories = New-Object System.Collections.Generic.List[string]

    foreach ($name in @($sourceFiles.Keys | Sort-Object)) {
        if (-not $mirrorFiles.ContainsKey($name)) {
            $missing.Add($name) | Out-Null
        } elseif ($sourceFiles[$name].sha256 -ne $mirrorFiles[$name].sha256) {
            $changed.Add($name) | Out-Null
        }
    }
    foreach ($name in @($mirrorFiles.Keys | Sort-Object)) {
        if (-not $sourceFiles.ContainsKey($name)) {
            $extraFiles.Add($name) | Out-Null
        }
    }
    foreach ($name in @($mirrorDirectories.Keys | Sort-Object)) {
        if (-not $sourceDirectories.ContainsKey($name)) {
            $extraDirectories.Add($name) | Out-Null
        }
    }

    return [pscustomobject]@{
        label = $Label
        source_root = $SourceRoot
        mirror_root = $MirrorRoot
        source_files = $sourceFiles
        mirror_files = $mirrorFiles
        missing = @($missing)
        changed = @($changed)
        extra_files = @($extraFiles)
        extra_directories = @($extraDirectories)
        has_differences = ($missing.Count + $changed.Count + $extraFiles.Count + $extraDirectories.Count) -gt 0
    }
}

function Write-ItemList {
    param(
        [string]$Title,
        [string[]]$Items
    )
    if ($Items.Count -eq 0) {
        return
    }
    Write-Host "  $Title"
    foreach ($item in $Items) {
        Write-Host "    - $item"
    }
}

function Write-Comparison {
    param([object]$Comparison)
    if (-not $Comparison.has_differences) {
        Write-Host "[OK] $($Comparison.label) mirror is aligned." -ForegroundColor Green
        return
    }

    Write-Host "[DIFF] $($Comparison.label) mirror differs." -ForegroundColor Yellow
    Write-Host "  Missing: $($Comparison.missing.Count) Changed: $($Comparison.changed.Count) Extra files: $($Comparison.extra_files.Count) Extra dirs: $($Comparison.extra_directories.Count)"
    Write-ItemList -Title "missing in mirror" -Items $Comparison.missing
    Write-ItemList -Title "changed in mirror" -Items $Comparison.changed
    Write-ItemList -Title "extra files in mirror" -Items $Comparison.extra_files
    Write-ItemList -Title "extra directories in mirror" -Items $Comparison.extra_directories
}

function Assert-SafeMirrorTarget {
    param(
        [string]$TargetPath,
        [string]$MirrorRoot,
        [string]$ProjectPath,
        [string]$Label
    )
    $fullPath = Assert-PathInside -Path $TargetPath -Root $MirrorRoot -Label $Label
    Assert-PathInside -Path $fullPath -Root $ProjectPath -Label $Label | Out-Null
    $fullMirror = Get-FullPath $MirrorRoot
    if ($fullPath.Equals($fullMirror, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "$Label cannot target the mirror root itself: $fullPath"
    }
    return $fullPath
}

function Copy-SourceFileToMirror {
    param(
        [object]$Comparison,
        [string]$RelativePath,
        [string]$ProjectPath
    )
    $sourceFile = $Comparison.source_files[$RelativePath].full_path
    $targetPath = Join-RelativePath -Root $Comparison.mirror_root -RelativePath $RelativePath
    $targetFullPath = Assert-SafeMirrorTarget -TargetPath $targetPath -MirrorRoot $Comparison.mirror_root -ProjectPath $ProjectPath -Label "copy target"
    $targetParent = Split-Path -Parent $targetFullPath
    Assert-PathInside -Path $targetParent -Root $Comparison.mirror_root -Label "copy target parent" | Out-Null
    Assert-PathInside -Path $targetParent -Root $ProjectPath -Label "copy target parent" | Out-Null
    if (-not (Test-Path -LiteralPath $targetParent -PathType Container)) {
        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
    }
    Assert-NoReparsePoint -Path $targetParent -Label "copy target parent"
    Copy-Item -LiteralPath $sourceFile -Destination $targetFullPath -Force
    Write-Host "[COPY] $($Comparison.label): $RelativePath"
}

function Remove-MirrorFile {
    param(
        [object]$Comparison,
        [string]$RelativePath,
        [string]$ProjectPath
    )
    $targetPath = Join-RelativePath -Root $Comparison.mirror_root -RelativePath $RelativePath
    $targetFullPath = Assert-SafeMirrorTarget -TargetPath $targetPath -MirrorRoot $Comparison.mirror_root -ProjectPath $ProjectPath -Label "extra mirror file"
    if (Test-Path -LiteralPath $targetFullPath -PathType Leaf) {
        Assert-NoReparsePoint -Path $targetFullPath -Label "extra mirror file"
        Remove-Item -LiteralPath $targetFullPath -Force
        Write-Host "[REMOVE] $($Comparison.label): $RelativePath"
    }
}

function Remove-MirrorDirectoryIfEmpty {
    param(
        [object]$Comparison,
        [string]$RelativePath,
        [string]$ProjectPath
    )
    $targetPath = Join-RelativePath -Root $Comparison.mirror_root -RelativePath $RelativePath
    $targetFullPath = Assert-SafeMirrorTarget -TargetPath $targetPath -MirrorRoot $Comparison.mirror_root -ProjectPath $ProjectPath -Label "extra mirror directory"
    if (-not (Test-Path -LiteralPath $targetFullPath -PathType Container)) {
        return
    }
    Assert-NoReparsePoint -Path $targetFullPath -Label "extra mirror directory"
    $child = Get-ChildItem -LiteralPath $targetFullPath -Force | Select-Object -First 1
    if ($null -ne $child) {
        throw "Refusing to remove non-empty mirror directory after file cleanup: $targetFullPath"
    }
    Remove-Item -LiteralPath $targetFullPath -Force
    Write-Host "[RMDIR] $($Comparison.label): $RelativePath"
}

function Sync-Comparison {
    param(
        [object]$Comparison,
        [string]$ProjectPath
    )
    foreach ($relativePath in @($Comparison.missing + $Comparison.changed | Sort-Object -Unique)) {
        Copy-SourceFileToMirror -Comparison $Comparison -RelativePath $relativePath -ProjectPath $ProjectPath
    }
    foreach ($relativePath in @($Comparison.extra_files | Sort-Object)) {
        Remove-MirrorFile -Comparison $Comparison -RelativePath $relativePath -ProjectPath $ProjectPath
    }
    foreach ($relativePath in @($Comparison.extra_directories | Sort-Object { $_.Length } -Descending)) {
        Remove-MirrorDirectoryIfEmpty -Comparison $Comparison -RelativePath $relativePath -ProjectPath $ProjectPath
    }
}

$ProjectPath = Resolve-ProjectDir -Path $ProjectDir
$Mode = "Check"
if ($Apply.IsPresent) {
    $Mode = "Apply"
}

$Pairs = @(
    [pscustomobject]@{
        label = "functions"
        source = Resolve-RequiredDirectory -ProjectPath $ProjectPath -RelativePath "server\functions" -Label "server/functions"
        mirror = Resolve-RequiredDirectory -ProjectPath $ProjectPath -RelativePath "supabase\functions" -Label "supabase/functions"
    },
    [pscustomobject]@{
        label = "migrations"
        source = Resolve-RequiredDirectory -ProjectPath $ProjectPath -RelativePath "server\schema\migrations" -Label "server/schema/migrations"
        mirror = Resolve-RequiredDirectory -ProjectPath $ProjectPath -RelativePath "supabase\migrations" -Label "supabase/migrations"
    }
)

Write-Host "DraxosMobile backend mirror sync"
Write-Host "Project: $ProjectPath"
Write-Host "Mode: $Mode"
Write-Host "Authoritative source: server/functions and server/schema/migrations"
Write-Host "Mirror target: supabase/functions and supabase/migrations"

$comparisons = @()
foreach ($pair in $Pairs) {
    $comparisons += Compare-BackendMirror -SourceRoot $pair.source -MirrorRoot $pair.mirror -Label $pair.label
}

foreach ($comparison in $comparisons) {
    Write-Comparison -Comparison $comparison
}

$hasDifferences = @($comparisons | Where-Object { $_.has_differences }).Count -gt 0

if ($Check.IsPresent) {
    if ($hasDifferences) {
        Write-Host "Mirror check failed. Run this script with -Apply to copy server -> supabase after reviewing the differences." -ForegroundColor Red
        exit 1
    }
    Write-Host "Mirror check OK. No writes were performed." -ForegroundColor Green
    exit 0
}

if (-not $hasDifferences) {
    Write-Host "Mirror already aligned. No writes were required." -ForegroundColor Green
    exit 0
}

foreach ($comparison in $comparisons) {
    if ($comparison.has_differences) {
        Sync-Comparison -Comparison $comparison -ProjectPath $ProjectPath
    }
}

$postApplyComparisons = @()
foreach ($pair in $Pairs) {
    $postApplyComparisons += Compare-BackendMirror -SourceRoot $pair.source -MirrorRoot $pair.mirror -Label $pair.label
}
$postApplyHasDifferences = @($postApplyComparisons | Where-Object { $_.has_differences }).Count -gt 0
if ($postApplyHasDifferences) {
    foreach ($comparison in $postApplyComparisons) {
        Write-Comparison -Comparison $comparison
    }
    Write-Host "Mirror apply finished with remaining differences." -ForegroundColor Red
    exit 1
}

Write-Host "Mirror apply OK. supabase mirrors now match server sources." -ForegroundColor Green
