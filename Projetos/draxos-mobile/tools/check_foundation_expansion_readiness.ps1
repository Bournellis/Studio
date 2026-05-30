param(
  [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$ProjectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
$Failures = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) {
  $Failures.Add($Message) | Out-Null
  Write-Host "[FAIL] $Message" -ForegroundColor Red
}

function Add-Ok([string]$Message) {
  Write-Host "[OK] $Message" -ForegroundColor Green
}

function Test-FileRequired([string]$RelativePath) {
  $path = Join-Path $ProjectPath $RelativePath
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    Add-Ok "required file exists: $RelativePath"
  } else {
    Add-Failure "required file missing: $RelativePath"
  }
}

function Test-DirectoryRequired([string]$RelativePath) {
  $path = Join-Path $ProjectPath $RelativePath
  if (Test-Path -LiteralPath $path -PathType Container) {
    Add-Ok "required directory exists: $RelativePath"
  } else {
    Add-Failure "required directory missing: $RelativePath"
  }
}

function Test-FileContains([string]$RelativePath, [string]$Needle) {
  $path = Join-Path $ProjectPath $RelativePath
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

function Test-DirectoriesMirror([string]$LeftRelativePath, [string]$RightRelativePath, [string]$Label) {
  $leftPath = Join-Path $ProjectPath $LeftRelativePath
  $rightPath = Join-Path $ProjectPath $RightRelativePath
  if (-not (Test-Path -LiteralPath $leftPath -PathType Container) -or -not (Test-Path -LiteralPath $rightPath -PathType Container)) {
    Add-Failure "$Label mirror directory missing"
    return
  }

  $left = Get-DirectoryHashMap $leftPath
  $right = Get-DirectoryHashMap $rightPath
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

function Test-PowerShellParses([string[]]$RelativePaths) {
  foreach ($relative in $RelativePaths) {
    $path = Join-Path $ProjectPath $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
      Add-Failure "PowerShell script missing: $relative"
      continue
    }
    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors -and $errors.Count -gt 0) {
      $details = ($errors | ForEach-Object { "$($_.Extent.StartLineNumber):$($_.Extent.StartColumnNumber) $($_.Message)" }) -join '; '
      Add-Failure "$relative has parse errors: $details"
    } else {
      Add-Ok "$relative parses"
    }
  }
}

Write-Host "DraxosMobile foundation expansion readiness check"
Write-Host "Project: $ProjectPath"

$requiredFiles = @(
  'docs\foundation-expansion-readiness.md',
  'docs\contracts\account-save.md',
  'docs\contracts\ruleset-registry.md',
  'docs\contracts\minigame-integration.md',
  'docs\contracts\admin-ops.md',
  'docs\contracts\api-endpoints.md',
  'docs\contracts\database-schema.md',
  'docs\contracts\content-definitions.md',
  'server\schema\migrations\202605280001_behavior_crafting.sql',
  'supabase\migrations\202605280001_behavior_crafting.sql',
  'server\schema\migrations\202605300001_foundation_expansion_readiness.sql',
  'supabase\migrations\202605300001_foundation_expansion_readiness.sql',
  'server\schema\migrations\202605300002_transactional_domain_enforcement.sql',
  'supabase\migrations\202605300002_transactional_domain_enforcement.sql',
  'server\schema\migrations\202605300003_remaining_transactional_domain_enforcement.sql',
  'supabase\migrations\202605300003_remaining_transactional_domain_enforcement.sql',
  'data\rulesets\foundation_ruleset_v0.json',
  'data\definitions\battle_fixtures.json',
  'data\definitions\rewards.json',
  'data\definitions\base_structures.json',
  'data\definitions\potions.json',
  'data\definitions\crafting_recipes.json',
  'data\definitions\power_bands.json',
  'data\definitions\bot_builds.json',
  'tools\generate_foundation_ruleset.ts',
  'tools\content_generator.gd',
  'modes\boot\ui\app_shell_action_router.gd',
  'modes\boot\ui\operation_state.gd',
  'server\functions\_shared\foundation_ruleset.ts',
  'supabase\functions\_shared\foundation_ruleset.ts',
  'server\functions\_shared\transactional_mutation.ts',
  'supabase\functions\_shared\transactional_mutation.ts',
  'server\functions\_shared\battle_simulator.ts',
  'supabase\functions\_shared\battle_simulator.ts',
  'server\tests\foundation_ruleset_test.ts',
  'server\tests\foundation_expansion_schema_test.ts',
  'server\tests\transactional_domain_enforcement_schema_test.ts',
  'server\tests\remaining_transactional_domain_enforcement_schema_test.ts',
  'server\tests\foundation_contracts_test.ts',
  'server\tests\integer_bones_contract_test.ts',
  'server\tests\build_equip_smoke.ts',
  'tests\client\test_foundation_shell_contracts.gd',
  'tests\client\test_content_foundation.gd',
  'tools\validate.gd',
  'tools\smoke_foundation_loop.gd',
  'tools\check_foundation_expansion_readiness.ps1'
)

foreach ($relative in $requiredFiles) {
  Test-FileRequired $relative
}

foreach ($relative in @(
  'docs\contracts',
  'server\schema\migrations',
  'supabase\migrations',
  'data\rulesets',
  'data\definitions',
  'server\tests',
  'tests\client'
)) {
  Test-DirectoryRequired $relative
}

Test-DirectoriesMirror 'server\schema\migrations' 'supabase\migrations' 'server/schema/migrations and supabase/migrations'
Test-DirectoriesMirror 'server\functions' 'supabase\functions' 'server/functions and supabase/functions'

Test-FileContains 'docs\foundation-expansion-readiness.md' 'QA/OPS CONTRACTS'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'Matriz De Lanes'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'Minigame Antes De Feature'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'Admin Minimo Auditavel'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'Migration / Ruleset / Tests'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'foundation_ruleset_v0'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'check_foundation_expansion_readiness.ps1'

Test-FileContains 'docs\contracts\account-save.md' 'ACCOUNT_SAVE_CONTRACT_V1'
Test-FileContains 'docs\contracts\account-save.md' 'account_profiles'
Test-FileContains 'docs\contracts\account-save.md' 'game_saves'
Test-FileContains 'docs\contracts\account-save.md' 'players.save_type'

Test-FileContains 'docs\contracts\ruleset-registry.md' 'RULESET_REGISTRY_CONTRACT_V1'
Test-FileContains 'docs\contracts\ruleset-registry.md' 'foundation_ruleset_v0'
Test-FileContains 'docs\contracts\ruleset-registry.md' 'content_hash'
Test-FileContains 'docs\contracts\ruleset-registry.md' 'simulator_hash'

Test-FileContains 'docs\contracts\minigame-integration.md' 'MINIGAME_INTEGRATION_CONTRACT_V1'
Test-FileContains 'docs\contracts\minigame-integration.md' 'Contract-first'
Test-FileContains 'docs\contracts\minigame-integration.md' 'Migration'
Test-FileContains 'docs\contracts\minigame-integration.md' 'Ruleset'
Test-FileContains 'docs\contracts\minigame-integration.md' 'Checklist De Integracao'
Test-FileContains 'docs\contracts\minigame-integration.md' 'admin-ops.md'

Test-FileContains 'docs\contracts\admin-ops.md' 'ADMIN_OPS_CONTRACT_V1'
Test-FileContains 'docs\contracts\admin-ops.md' 'admin-future'
Test-FileContains 'docs\contracts\admin-ops.md' 'audit_id'
Test-FileContains 'docs\contracts\admin-ops.md' 'admin_audit_log'
Test-FileContains 'docs\contracts\admin-ops.md' 'ConfirmRemoteMutation'

Test-FileContains 'docs\contracts\api-endpoints.md' 'admin-future'
Test-FileContains 'docs\contracts\database-schema.md' 'Migrations atuais'
Test-FileContains 'docs\contracts\database-schema.md' 'admin-future'
Test-FileContains 'docs\contracts\database-schema.md' '202605300001_foundation_expansion_readiness.sql'
Test-FileContains 'docs\contracts\database-schema.md' '202605300002_transactional_domain_enforcement.sql'
Test-FileContains 'docs\contracts\api-endpoints.md' '202605300003_remaining_transactional_domain_enforcement.sql'
Test-FileContains 'docs\contracts\database-schema.md' 'pending|completed|failed'
Test-FileContains 'docs\contracts\content-definitions.md' 'Arquivos Esperados'
Test-FileContains 'docs\contracts\content-definitions.md' 'foundation_ruleset_v0'
Test-FileContains 'docs\contracts\api-endpoints.md' 'x-draxos-api-version: 1'
Test-FileContains 'docs\contracts\api-endpoints.md' 'request_hash'
Test-FileContains 'docs\contracts\battle-event-log.md' 'Metadata De Ruleset'
Test-FileContains 'docs\contracts\battle-event-log.md' 'simulator_hash'
Test-FileContains 'data\rulesets\foundation_ruleset_v0.json' 'foundation_ruleset_manifest_v1'
Test-FileContains 'data\rulesets\foundation_ruleset_v0.json' 'foundation_ruleset_v0'
Test-FileContains 'tools\generate_foundation_ruleset.ts' 'generate-foundation-ruleset'
Test-FileContains 'server\functions\_shared\foundation_ruleset.ts' 'FOUNDATION_RULESET'
Test-FileContains 'supabase\functions\_shared\foundation_ruleset.ts' 'FOUNDATION_RULESET'
Test-FileContains 'server\tests\foundation_ruleset_test.ts' 'foundation ruleset publishes deterministic metadata and hashes'
Test-FileContains 'server\tests\foundation_expansion_schema_test.ts' 'foundation expansion migration is mirrored in server schema'
Test-FileContains 'server\tests\transactional_domain_enforcement_schema_test.ts' 'base edge adapter calls transactional RPCs instead of direct multi-step writes'
Test-FileContains 'server\tests\remaining_transactional_domain_enforcement_schema_test.ts' 'remaining transactional domain RPC dispatcher applies real atomic effects'
Test-FileContains 'server\functions\base\index.ts' 'rpc/collect_base_v1'
Test-FileContains 'server\functions\base\index.ts' 'rpc/start_base_upgrade_v1'
Test-FileContains 'supabase\functions\base\index.ts' 'rpc/collect_base_v1'
Test-FileContains 'supabase\functions\base\index.ts' 'rpc/start_base_upgrade_v1'
Test-FileContains 'server\functions\battle\index.ts' 'rpc/request_battle_v1'
Test-FileContains 'server\functions\build\index.ts' 'rpc/equip_build_v1'
Test-FileContains 'server\functions\crafting\index.ts' 'rpc/craft_item_v1'
Test-FileContains 'server\functions\monetization\index.ts' 'rpc/claim_reward_v1'
Test-FileContains 'server\functions\monetization\index.ts' 'rpc/alpha_purchase_v1'
Test-FileContains 'server\functions\social\index.ts' 'rpc/guild_create_v1'
Test-FileContains 'server\functions\social\index.ts' 'rpc/guild_join_v1'
Test-FileContains 'tests\client\test_foundation_shell_contracts.gd' 'test_operation_state_tracks_busy_by_scope'
Test-FileContains 'server\tests\README.md' 'foundation_contracts_test.ts'
Test-FileContains 'server\tests\README.md' 'foundation_expansion_schema_test.ts'
Test-FileContains 'server\tests\README.md' 'transactional_domain_enforcement_schema_test.ts'
Test-FileContains 'server\tests\README.md' 'remaining_transactional_domain_enforcement_schema_test.ts'

Test-PowerShellParses @(
  'tools\check_foundation_expansion_readiness.ps1',
  'tools\validate_foundation.ps1',
  'tools\check_release_safety.ps1',
  'tools\check_track13_readiness.ps1',
  'tools\check_agent_ops_foundation.ps1'
)

if ($Failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Foundation expansion readiness failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host 'Foundation expansion readiness OK.' -ForegroundColor Green
