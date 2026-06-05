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

function Test-FilesEqual([string]$LeftRelativePath, [string]$RightRelativePath, [string]$Label) {
  $left = Join-Path $ProjectPath $LeftRelativePath
  $right = Join-Path $ProjectPath $RightRelativePath
  if (-not (Test-Path -LiteralPath $left -PathType Leaf) -or -not (Test-Path -LiteralPath $right -PathType Leaf)) {
    Add-Failure "$Label files are missing"
    return
  }
  $leftHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $left).Hash
  $rightHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $right).Hash
  if ($leftHash -eq $rightHash) {
    Add-Ok "$Label files are aligned"
  } else {
    Add-Failure "$Label files differ"
  }
}

function Invoke-CapturedProcess {
  param([string]$Command, [scriptblock]$ScriptBlock, [int]$ExpectedExitCode)
  Push-Location -LiteralPath $ProjectPath
  $previousErrorActionPreference = $ErrorActionPreference
  $hadNativePreference = Test-Path Variable:\PSNativeCommandUseErrorActionPreference
  if ($hadNativePreference) {
    $previousNativePreference = $PSNativeCommandUseErrorActionPreference
  }
  try {
    $ErrorActionPreference = 'Continue'
    if ($hadNativePreference) {
      $PSNativeCommandUseErrorActionPreference = $false
    }
    $output = & $ScriptBlock *>&1
    $exitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
    if ($hadNativePreference) {
      $PSNativeCommandUseErrorActionPreference = $previousNativePreference
    }
    Pop-Location
  }
  if ($exitCode -eq $ExpectedExitCode) {
    Add-Ok "$Command exited with $ExpectedExitCode"
  } else {
    Add-Failure "$Command exited with $exitCode, expected $ExpectedExitCode. Output: $($output -join ' ')"
  }
  return ($output -join [Environment]::NewLine)
}

function Test-MutatingCommandsGuarded {
  $path = Join-Path $ProjectPath 'tools\publish_internal_alpha.ps1'
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure 'publish_internal_alpha.ps1 missing'
    return
  }
  $lines = Get-Content -LiteralPath $path
  $guardLine = 0
  $planExitLine = 0
  $uploadGuardLine = 0
  $deployGuardLine = 0
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $lineNumber = $i + 1
    if ($lines[$i] -match 'if \(\$IsRemoteMutation -and -not \$ConfirmRemoteMutation\)') {
      $guardLine = $lineNumber
    }
    if ($lines[$i] -match 'if \(\$Mode -eq "Plan"\)') {
      $planExitLine = $lineNumber
    }
    if ($uploadGuardLine -eq 0 -and $lines[$i] -match 'if \(\$ShouldUpload -and -not \$SkipUpload\)') {
      $uploadGuardLine = $lineNumber
    }
    if ($deployGuardLine -eq 0 -and $lines[$i] -match 'if \(\$ShouldDeployManifest\)') {
      $deployGuardLine = $lineNumber
    }
  }

  if ($guardLine -eq 0) {
    Add-Failure 'ConfirmRemoteMutation guard is missing'
  } else {
    Add-Ok "ConfirmRemoteMutation guard found at line $guardLine"
  }
  if ($planExitLine -eq 0) {
    Add-Failure 'Mode Plan exit block is missing'
  } else {
    Add-Ok "Mode Plan exit block found at line $planExitLine"
  }
  if ($uploadGuardLine -eq 0) {
    Add-Failure 'upload guard block is missing'
  } else {
    Add-Ok "upload guard block found at line $uploadGuardLine"
  }
  if ($deployGuardLine -eq 0) {
    Add-Failure 'deploy guard block is missing'
  } else {
    Add-Ok "deploy guard block found at line $deployGuardLine"
  }

  $mutatingPatterns = @(
    @{ Name = 'storage rm'; Pattern = '"storage", "rm"'; ExpectedAfter = $uploadGuardLine },
    @{ Name = 'storage cp'; Pattern = '"storage", "cp"'; ExpectedAfter = $uploadGuardLine },
    @{ Name = 'secrets set'; Pattern = '"secrets", "set"'; ExpectedAfter = $deployGuardLine },
    @{ Name = 'functions deploy'; Pattern = '"functions", "deploy"'; ExpectedAfter = $deployGuardLine }
  )
  foreach ($item in $mutatingPatterns) {
    $matches = @()
    for ($i = 0; $i -lt $lines.Count; $i++) {
      if ($lines[$i].Contains($item.Pattern)) {
        $matches += ($i + 1)
      }
    }
    if ($matches.Count -eq 0) {
      Add-Failure "mutating command missing from publish script: $($item.Name)"
      continue
    }
    $bad = @($matches | Where-Object { $_ -le $guardLine -or $_ -le $item.ExpectedAfter -or $_ -le $planExitLine })
    if ($bad.Count -eq 0) {
      Add-Ok "$($item.Name) appears only after confirmation and mode guard lines"
    } else {
      Add-Failure "$($item.Name) appears before guard lines: $($bad -join ', ')"
    }
  }

  $directMutations = @($lines | Where-Object {
    $_ -match 'npx\s+-y\s+supabase\s+(storage|functions|secrets)'
  })
  if ($directMutations.Count -eq 0) {
    Add-Ok 'publish script has no direct npx supabase mutation calls outside helpers'
  } else {
    Add-Failure "direct npx supabase calls found: $($directMutations -join '; ')"
  }

  $wranglerCalls = @($lines | Where-Object { $_ -match '\bwrangler\b' })
  if ($wranglerCalls.Count -eq 0) {
    Add-Ok 'publish script does not call wrangler'
  } else {
    Add-Failure "publish script calls wrangler: $($wranglerCalls -join '; ')"
  }
}

Write-Host "DraxosMobile release safety check"
Write-Host "Project: $ProjectPath"

foreach ($relative in @(
  'tools\publish_internal_alpha.ps1',
  'tools\export_internal_alpha.ps1',
  'tools\build_cloudflare_pages_package.ps1',
  'tools\smoke_web_launch_remote.ps1',
  'tools\validate_foundation.ps1',
  'tools\check_android_release_keystore.ps1'
)) {
  Test-FileRequired $relative
}

Test-PowerShellParses @(
  'tools\publish_internal_alpha.ps1',
  'tools\export_internal_alpha.ps1',
  'tools\build_cloudflare_pages_package.ps1',
  'tools\smoke_web_launch_remote.ps1',
  'tools\validate_foundation.ps1',
  'tools\check_release_safety.ps1',
  'tools\check_android_release_keystore.ps1'
)

Test-FileContains 'tools\publish_internal_alpha.ps1' '[ValidateSet("Plan", "Package", "Upload", "DeployManifest", "FullPublish")]'
Test-FileContains 'tools\publish_internal_alpha.ps1' '[string]$Mode = "Plan"'
Test-FileContains 'tools\publish_internal_alpha.ps1' 'ConfirmRemoteMutation'
Test-FileContains 'tools\publish_internal_alpha.ps1' 'Assert-VersionedReleaseRoot'
Test-FileContains 'tools\publish_internal_alpha.ps1' '-SkipManifestSecret is disabled for DeployManifest/FullPublish'
Test-FileContains 'tools\publish_internal_alpha.ps1' 'Legacy publish flags were supplied without -Mode'
Test-FileContains 'tools\publish_internal_alpha.ps1' 'No local package, upload, secret update, deploy or remote verification was executed'
Test-FileContains 'tools\validate_foundation.ps1' 'Profile FullPublish is disabled in validate_foundation.ps1'
Test-FileContains 'tools\validate_foundation.ps1' 'Publication is disabled in validate_foundation.ps1'
Test-FileContains 'tools\export_internal_alpha.ps1' 'android_release_keystore_configured'
Test-FileContains 'tools\export_internal_alpha.ps1' 'Android release keystore config must provide path, user/alias and password together.'
Test-MutatingCommandsGuarded

$validationRunnerText = Get-Content -LiteralPath (Join-Path $ProjectPath 'tools\validate_foundation.ps1') -Raw
if ($validationRunnerText.Contains('-File ".\tools\publish_internal_alpha.ps1"') -and $validationRunnerText.Contains('-Mode "FullPublish"')) {
  Add-Failure 'validate_foundation.ps1 must not call publish_internal_alpha.ps1 FullPublish directly'
} else {
  Add-Ok 'validate_foundation.ps1 does not call publish_internal_alpha.ps1 FullPublish directly'
}

$planOutput = Invoke-CapturedProcess `
  -Command 'publish_internal_alpha.ps1 default Plan' `
  -ExpectedExitCode 0 `
  -ScriptBlock {
    & powershell -NoProfile -ExecutionPolicy Bypass -File '.\tools\publish_internal_alpha.ps1' -ProjectDir '.'
  }
if ($planOutput.Contains('Plan generated') -and $planOutput.Contains('No local package, upload, secret update, deploy or remote verification')) {
  Add-Ok 'publish default generates Plan without remote mutation'
} else {
  Add-Failure 'publish default output did not confirm safe Plan behavior'
}

$blockedOutput = Invoke-CapturedProcess `
  -Command 'publish_internal_alpha.ps1 Upload without confirm' `
  -ExpectedExitCode 1 `
  -ScriptBlock {
    & powershell -NoProfile -ExecutionPolicy Bypass -File '.\tools\publish_internal_alpha.ps1' -ProjectDir '.' -Mode Upload
  }
if ($blockedOutput.Contains('ConfirmRemoteMutation')) {
  Add-Ok 'remote mutation mode is blocked without ConfirmRemoteMutation'
} else {
  Add-Failure 'remote mutation block message did not mention ConfirmRemoteMutation'
}

$missingRootOutput = Invoke-CapturedProcess `
  -Command 'publish_internal_alpha.ps1 Package without ReleaseRoot' `
  -ExpectedExitCode 1 `
  -ScriptBlock {
    & powershell -NoProfile -ExecutionPolicy Bypass -File '.\tools\publish_internal_alpha.ps1' -ProjectDir '.' -Mode Package
  }
if ($missingRootOutput.Contains('ReleaseRoot is required')) {
  Add-Ok 'package mode requires an explicit versioned ReleaseRoot'
} else {
  Add-Failure 'package mode without ReleaseRoot did not fail with the expected guard'
}

$fullPublishRunnerOutput = Invoke-CapturedProcess `
  -Command 'validate_foundation.ps1 FullPublish disabled' `
  -ExpectedExitCode 1 `
  -ScriptBlock {
    & powershell -NoProfile -ExecutionPolicy Bypass -File '.\tools\validate_foundation.ps1' -ProjectDir '.' -Profile FullPublish -ConfirmRemoteMutation
  }
if ($fullPublishRunnerOutput.Contains('Profile FullPublish is disabled')) {
  Add-Ok 'validation runner rejects FullPublish profile before publication'
} else {
  Add-Failure 'validation runner FullPublish rejection did not include the expected disabled-profile message'
}

Test-FilesEqual 'server\functions\release\index.ts' 'supabase\functions\release\index.ts' 'release function defaults'

Invoke-CapturedProcess `
  -Command 'check_android_release_keystore.ps1 InternalAlpha' `
  -ExpectedExitCode 0 `
  -ScriptBlock {
    & powershell -NoProfile -ExecutionPolicy Bypass -File '.\tools\check_android_release_keystore.ps1' -ProjectDir '.' -Mode InternalAlpha
  } | Out-Null

if ($Failures.Count -gt 0) {
  Write-Host ""
  Write-Host "Release safety failed with $($Failures.Count) issue(s)." -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host 'Release safety OK.' -ForegroundColor Green
