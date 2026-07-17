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

function Test-FileDoesNotContain([string]$BasePath, [string]$RelativePath, [string]$Needle) {
  $path = Join-Path $BasePath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "file missing for negative content check: $RelativePath"
    return
  }
  $text = Get-Content -LiteralPath $path -Raw
  if ($text.Contains($Needle)) {
    Add-Failure "$RelativePath still contains forbidden entrypoint text: $Needle"
  } else {
    Add-Ok "$RelativePath does not contain forbidden entrypoint text: $Needle"
  }
}

function Test-DoingCards {
  $doingPath = Join-Path $RepoPath '08_Coordenacao_Agentes\Kanban\Doing'
  if (-not (Test-Path -LiteralPath $doingPath -PathType Container)) {
    Add-Ok 'Kanban/Doing is absent or empty'
    return
  }
  $draxosCards = @(Get-ChildItem -LiteralPath $doingPath -Filter '*draxos-mobile*' -File)
  $allowedActiveCards = @(
    '*agent-ops-foundation*',
    '*foundation-expansion-readiness*',
    '*foundation-closeout*',
    '*foundation-final-polish*',
    '*hardening-validation-release*',
    '*hardening-program*',
    '*docs-state-governance*',
    '*hardening-*'
  )
  $obsolete = @($draxosCards | Where-Object {
      $cardName = $_.Name
      -not @($allowedActiveCards | Where-Object { $cardName -like $_ }).Count
    })
  if ($obsolete.Count -eq 0) {
    Add-Ok 'Kanban/Doing has no obsolete DraxosMobile cards'
  } else {
    Add-Failure "obsolete DraxosMobile Doing cards remain: $($obsolete.Name -join ', ')"
  }
}

Write-Host "DraxosMobile agent operations foundation check"
Write-Host "Project: $ProjectPath"
Write-Host "Repo: $RepoPath"

$requiredProjectFiles = @(
  'AGENTS.md',
  'README.md',
  'implementation\current-status.md',
  '08_Coordenacao\README.md',
  '08_Coordenacao\TRIAGE.md',
  'qa\qa_manifest.json',
  'qa\QA_INDEX.md',
  'docs\agent-operating-manual.md',
  'docs\documentation-index.md',
  'docs\product-vision.md',
  'docs\product-brief.md',
  'docs\game-design-document.md',
  'docs\design-pending.md',
  'docs\track-13-manual-walkthrough-gate.md',
  'tools\validate_foundation.ps1',
  'tools\check_agent_ops_foundation.ps1',
  'tools\check_release_safety.ps1',
  'tools\check_track13_readiness.ps1',
  'implementation\tracks\track-14-agent-ops-foundation\scope.md',
  'implementation\tracks\track-14-agent-ops-foundation\implementation-plan.md',
  'implementation\tracks\track-14-agent-ops-foundation\current-status.md'
)

foreach ($relative in $requiredProjectFiles) {
  Test-FileRequired $ProjectPath $relative
}

foreach ($section in @('Authority map', 'Live contracts', 'Historical records', 'Classification rule')) {
  Test-FileContains $ProjectPath 'docs\documentation-index.md' $section
}
Test-FileContains $ProjectPath 'docs\documentation-index.md' 'authority: `router`'

foreach ($relative in @('AGENTS.md', 'README.md', 'implementation\current-status.md')) {
  Test-FileDoesNotContain $ProjectPath $relative 'Fast Lane Atual - Track 04'
  Test-FileDoesNotContain $ProjectPath $relative 'Fast Lane Atual - Track 08'
  Test-FileDoesNotContain $ProjectPath $relative 'Fast Lane Atual - Track 10'
}

Test-FileContains $ProjectPath 'AGENTS.md' 'docs/agent-operating-manual.md'
Test-FileContains $ProjectPath 'AGENTS.md' '08_Coordenacao/TRIAGE.md'
Test-FileContains $ProjectPath 'AGENTS.md' 'qa/qa_manifest.json'
Test-FileContains $ProjectPath 'AGENTS.md' 'validate_foundation.ps1'
Test-FileContains $ProjectPath 'AGENTS.md' 'No remote database, device, upload, deploy, publication or external mutation'
Test-FileContains $ProjectPath 'README.md' 'AGENTS.md'
Test-FileContains $ProjectPath 'README.md' 'docs/documentation-index.md'
Test-FileContains $ProjectPath '08_Coordenacao\README.md' 'global_sync_needed'
Test-FileContains $ProjectPath 'qa\QA_INDEX.md' 'Arena product proof'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'ARENA_CORE_NOT_PROVEN'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'TRACK_14_AGENT_OPS_FOUNDATION_ACTIVE'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'TRACK_13_VALIDATION_RELEASE_SAFETY_DELIVERED'
Test-FileContains $ProjectPath 'implementation\current-status.md' 'docs/release-history.md'

foreach ($term in @('Instrumento Ritual', 'Doutrina', 'Familiar')) {
  Test-FileContains $ProjectPath 'docs\product-brief.md' $term
  Test-FileContains $ProjectPath 'docs\game-design-document.md' $term
}
foreach ($legacy in @('Varinha Magica', '1 slot de passiva', '1 slot de pet')) {
  Test-FileDoesNotContain $ProjectPath 'docs\product-brief.md' $legacy
}

Test-FileContains $RepoPath '08_Coordenacao_Agentes\Prioridades_Estudio.md' 'DraxosMobile'
Test-FileContains $RepoPath '08_Coordenacao_Agentes\Prioridades_Estudio.md' 'P2_IMPLEMENTACAO'
Test-FileContains $RepoPath 'Projetos\README.md' 'draxos-mobile/'
Test-FileContains $RepoPath 'AGENTS.md' 'Projetos/draxos-mobile/'
Test-FileContains $RepoPath 'AGENTS.md' 'Prioridades_Estudio.md'
Test-FileContains $RepoPath 'AGENTS.md' 'Estado_Atual.md'
Test-FileDoesNotContain $RepoPath 'AGENTS.md' 'Track 03 Internal Alpha v0 completa'
Test-FileDoesNotContain $RepoPath 'AGENTS.md' 'Track 04 pos-handoff planejada'
Test-DoingCards

if ($Failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Agent operations foundation failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host 'Agent operations foundation OK.' -ForegroundColor Green
