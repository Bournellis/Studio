param(
  [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
$RepoPath = (Resolve-Path -LiteralPath (Join-Path $ProjectPath '..\..')).Path
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
  $Failures.Add($Message) | Out-Null
  Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Add-Ok([string]$Message) {
  Write-Host "[OK] $Message" -ForegroundColor Green
}

function Test-FileRequired([string]$BasePath, [string]$RelativePath) {
  $path = Join-Path $BasePath $RelativePath
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    Add-Ok "required file exists: $RelativePath"
  } else {
    Add-Failure "required file missing: $RelativePath"
  }
}

function Test-FileContains([string]$BasePath, [string]$RelativePath, [string]$Needle) {
  $path = Join-Path $BasePath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "file missing for content check: $RelativePath"
    return
  }
  $text = Get-Content -LiteralPath $path -Raw
  if ($text.Contains($Needle)) {
    Add-Ok "$RelativePath contains $Needle"
  } else {
    Add-Failure "$RelativePath does not contain $Needle"
  }
}

function Get-DirectoryHashMap([string]$Path) {
  $root = (Resolve-Path -LiteralPath $Path).Path.TrimEnd('\')
  $prefix = "$root\"
  $map = @{}
  foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File) {
    $relative = $file.FullName.Substring($prefix.Length).Replace('\', '/')
    $map[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
  }
  return $map
}

function Test-DirectoriesMirror([string]$LeftPath, [string]$RightPath, [string]$Label) {
  if (-not (Test-Path -LiteralPath $LeftPath -PathType Container) -or -not (Test-Path -LiteralPath $RightPath -PathType Container)) {
    Add-Failure "$Label mirror directory missing"
    return
  }
  $left = Get-DirectoryHashMap $LeftPath
  $right = Get-DirectoryHashMap $RightPath
  $allNames = @($left.Keys + $right.Keys | Sort-Object -Unique)
  $mismatch = @()
  foreach ($name in $allNames) {
    if (-not $left.ContainsKey($name) -or -not $right.ContainsKey($name) -or $left[$name] -ne $right[$name]) {
      $mismatch += $name
    }
  }
  if ($mismatch.Count -eq 0) {
    Add-Ok "$Label mirrors are aligned"
  } else {
    Add-Failure "$Label mirrors differ: $($mismatch -join ', ')"
  }
}

function Test-BootBudget {
  $bootPath = Join-Path $ProjectPath 'modes\boot\boot.gd'
  if (-not (Test-Path -LiteralPath $bootPath -PathType Leaf)) {
    Add-Failure 'boot.gd missing'
    return
  }
  $lineCount = (Get-Content -LiteralPath $bootPath | Measure-Object -Line).Lines
  if ($lineCount -le 1500) {
    Add-Ok "boot.gd is under line budget: $lineCount/1500"
  } else {
    Add-Failure "boot.gd line budget exceeded: $lineCount/1500"
  }
}

function Test-DoingCards {
  $doingPath = Join-Path $RepoPath '08_Coordenacao_Agentes\Kanban\Doing'
  if (-not (Test-Path -LiteralPath $doingPath -PathType Container)) {
    Add-Ok 'Kanban/Doing is absent or empty'
    return
  }
  $draxosCards = @(Get-ChildItem -LiteralPath $doingPath -Filter '*draxos-mobile*' -File)
  $obsolete = @($draxosCards | Where-Object {
      $_.Name -notlike '*track-13-validation-release-safety*' -and
      $_.Name -notlike '*agent-ops-foundation*'
    })
  if ($obsolete.Count -eq 0) {
    Add-Ok 'Kanban/Doing has no obsolete DraxosMobile cards'
  } else {
    Add-Failure "obsolete DraxosMobile Doing cards remain: $($obsolete.Name -join ', ')"
  }
}

Write-Host "Track 13 readiness check"
Write-Host "Project: $ProjectPath"
Write-Host "Repo: $RepoPath"

$trackDir = 'implementation\tracks\track-13-validation-release-safety'
$requiredProjectFiles = @(
  'AGENTS.md',
  'README.md',
  'implementation\current-status.md',
  "$trackDir\scope.md",
  "$trackDir\implementation-plan.md",
  "$trackDir\current-status.md",
  "$trackDir\validation-matrix.md",
  "$trackDir\release-safety-contract.md",
  'docs\track-13-manual-walkthrough-gate.md',
  'docs\release-ops-checklist.md',
  'tools\README.md',
  'tools\validate_foundation.ps1',
  'tools\check_release_safety.ps1',
  'tools\check_track13_readiness.ps1',
  'tools\publish_internal_alpha.ps1'
)

foreach ($relative in $requiredProjectFiles) {
  Test-FileRequired $ProjectPath $relative
}

foreach ($mode in @('Mode Plan', 'Mode Package', 'Mode Upload', 'Mode DeployManifest', 'Mode FullPublish')) {
  Test-FileContains $ProjectPath 'docs\release-ops-checklist.md' $mode
}

Test-FileContains $ProjectPath 'tools\publish_internal_alpha.ps1' '[string]$Mode = "Plan"'
Test-FileContains $ProjectPath 'tools\publish_internal_alpha.ps1' 'ConfirmRemoteMutation'
Test-FileContains $ProjectPath 'tools\validate_foundation.ps1' 'foundation-validation-latest.json'
Test-FileContains $ProjectPath "$trackDir\current-status.md" 'TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'Track 13 - Foundation Validation And Release Safety'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED'
Test-FileContains $ProjectPath 'README.md' 'Track 13'
Test-FileContains $ProjectPath 'AGENTS.md' 'Track 13'
Test-FileContains $ProjectPath 'tools\README.md' 'validate_foundation.ps1'
Test-FileContains $ProjectPath 'docs\track-13-manual-walkthrough-gate.md' 'Android / Windows / Web preview / Web Access-protected'

Test-FileContains $RepoPath '08_Coordenacao_Agentes\Prioridades_Estudio.md' 'Track 13'
Test-FileContains $RepoPath '08_Coordenacao_Agentes\Estado_Atual.md' 'Track 13'
Test-FileContains $RepoPath 'Projetos\README.md' 'Track 13'
Test-FileContains $RepoPath '08_Coordenacao_Agentes\Painel_Visual_Estudio.html' 'Track 13'

Test-BootBudget

Test-DirectoriesMirror `
  (Join-Path $ProjectPath 'server\functions') `
  (Join-Path $ProjectPath 'supabase\functions') `
  'server/functions and supabase/functions'

Test-DirectoriesMirror `
  (Join-Path $ProjectPath 'server\schema\migrations') `
  (Join-Path $ProjectPath 'supabase\migrations') `
  'server/schema/migrations and supabase/migrations'

Test-DoingCards

$releaseSafetyScript = Join-Path $ProjectPath 'tools\check_release_safety.ps1'
if (Test-Path -LiteralPath $releaseSafetyScript -PathType Leaf) {
  Push-Location -LiteralPath $ProjectPath
  try {
    & powershell -NoProfile -ExecutionPolicy Bypass -File '.\tools\check_release_safety.ps1' -ProjectDir '.'
    if ($LASTEXITCODE -eq 0) {
      Add-Ok 'release safety check passes'
    } else {
      Add-Failure "release safety check exited with code $LASTEXITCODE"
    }
  } finally {
    Pop-Location
  }
} else {
  Add-Failure 'release safety check script missing'
}

if ($Failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Track 13 readiness failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host 'Track 13 readiness OK.' -ForegroundColor Green
