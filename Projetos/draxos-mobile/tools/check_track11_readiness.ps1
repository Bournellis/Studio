param(
  [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
  [switch]$AllowActiveTrack11Doing
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

Write-Host "Track 11 historical recovery check"
Write-Host "Project: $ProjectPath"
Write-Host "Repo: $RepoPath"

$requiredProjectFiles = @(
  'AGENTS.md',
  'README.md',
  'implementation\current-status.md',
  'implementation\history.md',
  'implementation\history-ledger\2026-05.md',
  'implementation\history-ledger\2026-06.md',
  'docs\release-history.md',
  'docs\release-ops-checklist.md',
  'tools\check_track11_readiness.ps1',
  'modes\boot\ui\app_shell_error_contract.gd'
)

foreach ($relative in $requiredProjectFiles) {
  Test-FileRequired $ProjectPath $relative
}

Test-FileContains $ProjectPath 'implementation\current-status.md' 'docs/release-history.md'
Test-FileContains $ProjectPath 'implementation\history.md' '| 11 | Product foundation consolidation integrated |'
Test-FileContains $ProjectPath 'docs\release-history.md' 'single historical record'

foreach ($record in @(
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_scope_49b975c7ff' },
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_implementation_plan_4997dea04e' },
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_current_status_ad3ebd27dd' },
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_foundation_audit_08cc21d4dc' },
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_agent_registry_457f45f7ff' },
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_track_11_manual_walkthrough_bf445d6610' },
  @{ Ledger = 'implementation\history-ledger\2026-05.md'; Id = 'rec_internal_alpha_v0_publication_report_8c69e132bd' },
  @{ Ledger = 'implementation\history-ledger\2026-06.md'; Id = 'rec_internal_alpha_v0_handoff_7a30cd554f' }
)) {
  Test-FileContains $ProjectPath $record.Ledger $record.Id
  Test-FileContains $RepoPath '08_Coordenacao_Agentes\Receipts\DocumentationLite\local_draxosmobile.json' $record.Id
}
Test-FileContains $RepoPath '08_Coordenacao_Agentes\Receipts\DocumentationLite\local_draxosmobile.json' '52f52f7cd33d1711579f9cccbe4c848ab45a02e4'
Test-FileContains $ProjectPath 'server\tests\release_artifacts_remote_smoke.ts' 'DRAXOS_RELEASE_ALLOW_CLOUDFLARE_ACCESS'
Test-FileContains $ProjectPath 'server\tests\release_artifacts_remote_smoke.ts' 'DRAXOS_RELEASE_FULL_HASH'

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
  Write-Host "Track 11 historical recovery failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host 'Track 11 historical recovery OK.' -ForegroundColor Green
