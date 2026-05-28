param(
  [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [switch]$AllowActiveTrack11Doing
)

$ErrorActionPreference = 'Stop'

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
$RepoPath = (Resolve-Path -LiteralPath (Join-Path $ProjectPath '..\..')).Path
$Failures = New-Object System.Collections.Generic.List[string]

$AndroidHash = 'ad6d2579ce003769cfce2536b788c1330abb283d0ae90cc785d1d016ae514ca6'
$PcHash = 'ad5fb8351bb001604479d95737fc702bb9b0ff6779afb9e3e31692b7bc189031'
$WebHash = '75fdd260b889582cb723256e87ca9867ae35b7cdd3411cbb2ca21ace5585366a'
$ReleasedAt = '2026-05-28T04:50:33Z'

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
    return
  }
  Add-Failure "required file missing: $RelativePath"
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
    return
  }
  Add-Failure "$RelativePath does not contain $Needle"
}

function Test-DirectoriesMirror([string]$LeftPath, [string]$RightPath, [string]$Label) {
  $left = (Resolve-Path -LiteralPath $LeftPath).Path.TrimEnd('\')
  $right = (Resolve-Path -LiteralPath $RightPath).Path.TrimEnd('\')
  $leftPrefix = "$left\"
  $rightPrefix = "$right\"
  $leftFiles = @{}
  $rightFiles = @{}

  foreach ($file in Get-ChildItem -LiteralPath $left -Recurse -File) {
    $relative = $file.FullName.Substring($leftPrefix.Length)
    $leftFiles[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
  }
  foreach ($file in Get-ChildItem -LiteralPath $right -Recurse -File) {
    $relative = $file.FullName.Substring($rightPrefix.Length)
    $rightFiles[$relative] = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
  }

  $allNames = @($leftFiles.Keys + $rightFiles.Keys | Sort-Object -Unique)
  $mismatch = @()
  foreach ($name in $allNames) {
    if (-not $leftFiles.ContainsKey($name) -or -not $rightFiles.ContainsKey($name)) {
      $mismatch += $name
      continue
    }
    if ($leftFiles[$name] -ne $rightFiles[$name]) {
      $mismatch += $name
    }
  }

  if ($mismatch.Count -eq 0) {
    Add-Ok "$Label mirrors are aligned"
    return
  }
  Add-Failure "$Label mirrors differ: $($mismatch -join ', ')"
}

Write-Host "Track 11 readiness check"
Write-Host "Project: $ProjectPath"
Write-Host "Repo: $RepoPath"

$requiredProjectFiles = @(
  'AGENTS.md',
  'README.md',
  'implementation\current-status.md',
  'implementation\tracks\track-11-product-foundation-consolidation\scope.md',
  'implementation\tracks\track-11-product-foundation-consolidation\implementation-plan.md',
  'implementation\tracks\track-11-product-foundation-consolidation\current-status.md',
  'implementation\tracks\track-11-product-foundation-consolidation\foundation-audit.md',
  'implementation\tracks\track-11-product-foundation-consolidation\agent-registry.md',
  'docs\track-11-manual-walkthrough.md',
  'docs\internal-alpha-v0-handoff.md',
  'docs\internal-alpha-v0-publication-report.md',
  'docs\release-ops-checklist.md',
  'tools\check_track11_readiness.ps1',
  'modes\boot\ui\app_shell_error_contract.gd'
)

foreach ($relative in $requiredProjectFiles) {
  Test-FileRequired $ProjectPath $relative
}

Test-FileContains $ProjectPath 'implementation\current-status.md' 'Track 11 - Product Foundation Consolidation'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'INTEGRATED_CONSOLIDATION_READY'
Test-FileContains $ProjectPath 'README.md' 'Track 11 INTEGRATED_CONSOLIDATION_READY'
Test-FileContains $ProjectPath 'AGENTS.md' 'Track 11 - Product Foundation Consolidation'
Test-FileContains $ProjectPath 'docs\track-11-manual-walkthrough.md' 'Android APK, PC Windows ZIP, Web'

foreach ($relative in @(
  'supabase\functions\release\index.ts',
  'server\functions\release\index.ts',
  'portal\internal-alpha\manifest.example.json',
  'docs\internal-alpha-v0-handoff.md',
  'docs\internal-alpha-v0-publication-report.md'
)) {
  Test-FileContains $ProjectPath $relative $AndroidHash
  Test-FileContains $ProjectPath $relative $PcHash
}

Test-FileContains $ProjectPath 'docs\internal-alpha-v0-handoff.md' $WebHash
Test-FileContains $ProjectPath 'docs\internal-alpha-v0-publication-report.md' $WebHash
Test-FileContains $ProjectPath 'supabase\functions\release\index.ts' $ReleasedAt
Test-FileContains $ProjectPath 'server\functions\release\index.ts' $ReleasedAt
Test-FileContains $ProjectPath 'portal\internal-alpha\manifest.example.json' $ReleasedAt
Test-FileContains $ProjectPath 'server\tests\release_artifacts_remote_smoke.ts' 'DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS'
Test-FileContains $ProjectPath 'server\tests\release_artifacts_remote_smoke.ts' 'DRAXOS_RELEASE_FULL_HASH'

Test-FileContains $RepoPath '08_Coordenacao_Agentes\Prioridades_Estudio.md' 'Track 11'
Test-FileContains $RepoPath '08_Coordenacao_Agentes\Estado_Atual.md' 'Track 11'
Test-FileContains $RepoPath 'Projetos\README.md' 'Track 11'
Test-FileContains $RepoPath 'AGENTS.md' 'Track 11'

Test-DirectoriesMirror `
  (Join-Path $ProjectPath 'server\functions') `
  (Join-Path $ProjectPath 'supabase\functions') `
  'server/functions and supabase/functions'

Test-DirectoriesMirror `
  (Join-Path $ProjectPath 'server\schema\migrations') `
  (Join-Path $ProjectPath 'supabase\migrations') `
  'server/schema/migrations and supabase/migrations'

$doingPath = Join-Path $RepoPath '08_Coordenacao_Agentes\Kanban\Doing'
$doingDraxos = @(Get-ChildItem -LiteralPath $doingPath -Filter '*draxos-mobile*' -File)
if ($AllowActiveTrack11Doing) {
  $unexpected = @($doingDraxos | Where-Object { $_.Name -notlike '*track-11-consolidation*' })
  if ($unexpected.Count -eq 0) {
    Add-Ok 'Kanban/Doing has no stale DraxosMobile cards'
  } else {
    Add-Failure "stale DraxosMobile Doing cards remain: $($unexpected.Name -join ', ')"
  }
} elseif ($doingDraxos.Count -eq 0) {
  Add-Ok 'Kanban/Doing has no DraxosMobile cards'
} else {
  Add-Failure "DraxosMobile Doing cards remain: $($doingDraxos.Name -join ', ')"
}

if ($Failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Track 11 readiness failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host 'Track 11 readiness OK.' -ForegroundColor Green
