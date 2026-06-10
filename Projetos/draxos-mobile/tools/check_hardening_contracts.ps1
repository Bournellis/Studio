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

function Get-Text([string]$RelativePath) {
  $path = Join-Path $ProjectPath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "missing file: $RelativePath"
    return ''
  }
  return (Get-Content -LiteralPath $path -Raw)
}

function Test-Contains([string]$RelativePath, [string]$Needle, [string]$Label) {
  $text = Get-Text $RelativePath
  if ($text.Contains($Needle)) {
    Add-Ok "$Label contains $Needle"
  } else {
    Add-Failure "$Label missing $Needle"
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

function Test-DirectoriesMirror([string]$LeftRelative, [string]$RightRelative, [string]$Label) {
  $leftPath = Join-Path $ProjectPath $LeftRelative
  $rightPath = Join-Path $ProjectPath $RightRelative
  if (-not (Test-Path -LiteralPath $leftPath -PathType Container)) {
    Add-Failure "$Label left directory missing: $LeftRelative"
    return
  }
  if (-not (Test-Path -LiteralPath $rightPath -PathType Container)) {
    Add-Failure "$Label right directory missing: $RightRelative"
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

function Test-ValidationProfiles {
  foreach ($profile in @('DocsOnly', 'ClientQuick', 'ServerQuick', 'ModePlatform', 'DatabaseLocal', 'FullLocal', 'ReleaseDryRun', 'RemoteReadOnly')) {
    Test-Contains 'tools\validate_foundation.ps1' "`"$profile`"" "validate_foundation.ps1"
    Test-Contains 'tools\README.md' $profile 'tools README'
    Test-Contains 'docs\hardening-program.md' $profile 'hardening program'
  }
  Test-Contains 'tools\validate_foundation.ps1' 'Profile FullPublish is disabled in validate_foundation.ps1' 'validate_foundation.ps1'
  Test-Contains 'tools\validate_foundation.ps1' 'Publication is disabled in validate_foundation.ps1' 'validate_foundation.ps1'
  Test-Contains 'tools\publish_internal_alpha.ps1' 'ConfirmRemoteMutation' 'publish_internal_alpha.ps1'
}

function Test-AccountSaveAuthority {
  foreach ($needle in @('account_profiles', 'game_saves', 'players.save_type', 'idempotency', 'request_hash', 'scope_id')) {
    Test-Contains 'docs\hardening-program.md' $needle 'hardening program'
  }
  foreach ($needle in @('account_profiles', 'game_saves', 'players.save_type')) {
    Test-Contains 'docs\contracts\account-save.md' $needle 'account-save contract'
  }
  foreach ($needle in @('request_hash', 'scope_id', 'pending|completed|failed')) {
    Test-Contains 'docs\contracts\database-schema.md' $needle 'database schema contract'
  }
}

function Test-LabAuthority {
  Test-Contains 'docs\contracts\lab-heuristics.md' 'Eles nao sao fonte autoritativa de tuning em runtime.' 'lab heuristics contract'
  Test-Contains 'docs\contracts\lab-heuristics.md' 'nao aplica reward, XP, ranking, recursos, progresso, potion stock, save ou' 'lab heuristics contract'
  Test-Contains 'docs\contracts\lab-heuristics.md' 'ledger' 'lab heuristics contract'
  Test-Contains 'docs\hardening-program.md' 'Labs remain evidence, not runtime authority.' 'hardening program'
}

function Test-ReleaseSafety {
  foreach ($needle in @('FullPublish', 'ConfirmRemoteMutation', 'ReleaseRoot', 'check_release_safety.ps1', 'check_android_release_keystore.ps1')) {
    Test-Contains 'docs\hardening-program.md' $needle 'hardening program'
  }
  Test-Contains 'docs\contracts\update-manifest.md' '0.0.22-alpha.0' 'update manifest contract'
  Test-Contains 'docs\contracts\update-manifest.md' '10cdc2bc4f7ea25db7c05be917efe0a0d73baa1047b01311748857e6637dfc99' 'update manifest contract'
}

Write-Host 'DraxosMobile hardening contract check'
Write-Host "Project: $ProjectPath"

Test-ValidationProfiles
Test-AccountSaveAuthority
Test-LabAuthority
Test-ReleaseSafety
Test-DirectoriesMirror 'server\functions' 'supabase\functions' 'server/supabase functions'
Test-DirectoriesMirror 'server\schema\migrations' 'supabase\migrations' 'server/supabase migrations'

if ($Failures.Count -gt 0) {
  Write-Host ''
  Write-Host "Hardening contract check failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ''
Write-Host 'Hardening contract check OK.' -ForegroundColor Green
