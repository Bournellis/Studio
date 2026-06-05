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

function Test-FileNotContains([string]$RelativePath, [string]$Needle, [string]$Reason) {
  $path = Join-Path $ProjectPath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "file missing for forbidden content check: $RelativePath"
    return
  }
  $text = Get-Content -LiteralPath $path -Raw
  if ($text.Contains($Needle)) {
    Add-Failure "$RelativePath contains forbidden text ($Reason): $Needle"
  } else {
    Add-Ok "$RelativePath excludes forbidden text: $Reason"
  }
}

function Test-LineBudget([string]$RelativePath, [int]$MaxLines, [string]$Label) {
  $path = Join-Path $ProjectPath $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "line-budget file missing: $RelativePath"
    return
  }
  $lineCount = (Get-Content -LiteralPath $path | Measure-Object -Line).Lines
  if ($lineCount -le $MaxLines) {
    Add-Ok "$Label line budget: $lineCount <= $MaxLines"
  } else {
    Add-Failure "$Label has $lineCount lines; budget is $MaxLines"
  }
}

function Test-JsonObjectKeys([object]$Object, [string[]]$ExpectedKeys, [string]$Label) {
  $actual = @($Object.PSObject.Properties.Name | Sort-Object)
  $expected = @($ExpectedKeys | Sort-Object)
  $missing = @($expected | Where-Object { $actual -notcontains $_ })
  $extra = @($actual | Where-Object { $expected -notcontains $_ })
  if ($missing.Count -eq 0 -and $extra.Count -eq 0) {
    Add-Ok "$Label has strict keys"
  } else {
    Add-Failure "$Label has invalid keys. Missing: $($missing -join ', '); extra: $($extra -join ', ')"
  }
}

function Test-ModeDescriptorSchemaStrict {
  $officialModes = @('basebuilder', 'autobattler', 'openworld', 'towerdefense', 'cardgame')
  $metadataKeys = @(
    'schema_version',
    'mode_id',
    'display_name',
    'summary',
    'default_slice_id',
    'status',
    'release_channel',
    'public_cta',
    'fullscreen',
    'entry',
    'ruleset',
    'ownership',
    'docs',
    'scaffold'
  )
  $entryKeys = @('route_id', 'action_id', 'surface', 'client_screen_path', 'enabled_setting')
  $rulesetKeys = @('ruleset_id', 'ruleset_version', 'status', 'session_model')
  $ownershipKeys = @('build_owner', 'data_strategy', 'economy_authority', 'reward_bridge')
  $docsKeys = @('mode_doc', 'catalog', 'contract')
  $scaffoldKeys = @('placeholder_path', 'playable_from_placeholder', 'freeze')
  $placeholderKeys = @(
    'schema_version',
    'mode_id',
    'placeholder_id',
    'playable',
    'launchable',
    'reward_enabled',
    'runtime',
    'entry_action',
    'purpose',
    'blocked_until',
    'non_goals'
  )

  foreach ($modeId in $officialModes) {
    $metadataRelative = "data\definitions\modes\$modeId\metadata.json"
    $placeholderRelative = "data\definitions\modes\$modeId\placeholder.json"
    $metadataPath = Join-Path $ProjectPath $metadataRelative
    $placeholderPath = Join-Path $ProjectPath $placeholderRelative
    if (-not (Test-Path -LiteralPath $metadataPath -PathType Leaf) -or -not (Test-Path -LiteralPath $placeholderPath -PathType Leaf)) {
      Add-Failure "mode descriptor files missing for $modeId"
      continue
    }

    try {
      $metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
      $placeholder = Get-Content -LiteralPath $placeholderPath -Raw | ConvertFrom-Json
    } catch {
      Add-Failure "mode descriptor JSON parse failed for ${modeId}: $($_.Exception.Message)"
      continue
    }

    Test-JsonObjectKeys $metadata $metadataKeys $metadataRelative
    Test-JsonObjectKeys $metadata.entry $entryKeys "$metadataRelative entry"
    Test-JsonObjectKeys $metadata.ruleset $rulesetKeys "$metadataRelative ruleset"
    Test-JsonObjectKeys $metadata.ownership $ownershipKeys "$metadataRelative ownership"
    Test-JsonObjectKeys $metadata.docs $docsKeys "$metadataRelative docs"
    Test-JsonObjectKeys $metadata.scaffold $scaffoldKeys "$metadataRelative scaffold"
    Test-JsonObjectKeys $placeholder $placeholderKeys $placeholderRelative

    if ([string]$metadata.schema_version -ne 'mode_descriptor_v1') {
      Add-Failure "$metadataRelative schema_version must be mode_descriptor_v1"
    }
    if ([string]$metadata.mode_id -ne $modeId -or [string]$placeholder.mode_id -ne $modeId) {
      Add-Failure "$modeId descriptor/placeholder mode_id mismatch"
    }
    if ([string]$placeholder.schema_version -ne 'mode_placeholder_v1') {
      Add-Failure "$placeholderRelative schema_version must be mode_placeholder_v1"
    }
    if ([bool]$placeholder.playable -or [bool]$placeholder.launchable -or [bool]$placeholder.reward_enabled) {
      Add-Failure "$placeholderRelative must keep playable/launchable/reward_enabled false"
    }
    if ([string]$placeholder.runtime -ne 'none' -or [string]$placeholder.entry_action -ne '') {
      Add-Failure "$placeholderRelative must keep runtime none and entry_action empty"
    }
    $expectedPlaceholder = $placeholderRelative.Replace('\', '/')
    if ([string]$metadata.scaffold.placeholder_path -ne $expectedPlaceholder) {
      Add-Failure "$metadataRelative scaffold placeholder_path must be $expectedPlaceholder"
    }
    foreach ($docKey in $docsKeys) {
      $docPath = Join-Path $ProjectPath ([string]$metadata.docs.$docKey)
      if (Test-Path -LiteralPath $docPath -PathType Leaf) {
        Add-Ok "$metadataRelative docs.$docKey exists"
      } else {
        Add-Failure "$metadataRelative docs.$docKey missing: $($metadata.docs.$docKey)"
      }
    }
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

function Test-ModeHandlerStrictness {
  Test-DirectoriesMirror 'server\functions\modes' 'supabase\functions\modes' 'server/supabase modes functions'
  Test-LineBudget 'server\functions\modes\index.ts' 80 'server modes edge entrypoint'
  Test-LineBudget 'server\functions\modes\mode_handler.ts' 1100 'server modes handler'
  Test-LineBudget 'server\functions\modes\mode_support.ts' 700 'server modes support'
  Test-LineBudget 'supabase\functions\modes\index.ts' 80 'supabase modes edge entrypoint'
  Test-LineBudget 'supabase\functions\modes\mode_handler.ts' 1100 'supabase modes handler'
  Test-LineBudget 'supabase\functions\modes\mode_support.ts' 700 'supabase modes support'

  $entry = Get-Content -LiteralPath (Join-Path $ProjectPath 'server\functions\modes\index.ts') -Raw
  if ($entry.Contains('mode_handler.ts') -and $entry.Contains('Deno.serve(modeHandler)')) {
    Add-Ok 'modes edge entrypoint delegates to mode_handler'
  } else {
    Add-Failure 'modes edge entrypoint must delegate to mode_handler'
  }

  foreach ($relative in @('server\functions\modes\mode_handler.ts', 'supabase\functions\modes\mode_handler.ts')) {
    $path = Join-Path $ProjectPath $relative
    $supportPath = Join-Path (Split-Path -Parent $path) 'mode_support.ts'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
      Add-Failure "mode handler missing: $relative"
      continue
    }
    if (-not (Test-Path -LiteralPath $supportPath -PathType Leaf)) {
      Add-Failure "mode support missing beside: $relative"
      continue
    }
    $text = Get-Content -LiteralPath $path -Raw
    $moduleText = "$text`n$(Get-Content -LiteralPath $supportPath -Raw)"
    foreach ($needle in @('export class ModeHandler', 'handleAdminRoute', 'mutationRequestHash', 'verifiedAuthContext')) {
      if ($moduleText.Contains($needle)) {
        Add-Ok "$relative module set contains modularity marker $needle"
      } else {
        Add-Failure "$relative module set missing modularity marker $needle"
      }
    }
    foreach ($pattern in @('method:\s*"PATCH"', 'method:\s*"PUT"', 'method:\s*"DELETE"')) {
      if ([regex]::IsMatch($text, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)) {
        Add-Failure "$relative contains forbidden direct mode mutation pattern: $pattern"
      } else {
        Add-Ok "$relative excludes direct mode mutation pattern: $pattern"
      }
    }
  }
}

function Test-HotFileBudgets {
  foreach ($budget in @(
    @{ Path = 'server\functions\arena\index.ts'; Max = 1800; Label = 'server arena endpoint' },
    @{ Path = 'server\functions\battle\index.ts'; Max = 1350; Label = 'server battle endpoint' },
    @{ Path = 'modes\boot\flows\surface_action_flow.gd'; Max = 850; Label = 'client surface action flow' },
    @{ Path = 'modes\boot\flows\arena_lifecycle_flow.gd'; Max = 550; Label = 'client arena lifecycle flow' },
    @{ Path = 'modes\boot\flows\account_session_flow.gd'; Max = 500; Label = 'client account session flow' },
    @{ Path = 'modes\boot\surfaces\base_surface_presenter.gd'; Max = 850; Label = 'client base surface presenter' },
    @{ Path = 'modes\boot\surfaces\battle_replay_presenter.gd'; Max = 750; Label = 'client battle replay presenter' },
    @{ Path = 'online\session_store.gd'; Max = 1000; Label = 'session store facade' },
    @{ Path = 'online\session\arena_slice.gd'; Max = 260; Label = 'session arena slice' },
    @{ Path = 'online\session\pending_mutation_queue.gd'; Max = 250; Label = 'session pending mutation queue' },
    @{ Path = 'online\session\account_save_slice.gd'; Max = 150; Label = 'session account/save slice' },
    @{ Path = 'online\session\mode_slice.gd'; Max = 80; Label = 'session mode slice' },
    @{ Path = 'online\session\telemetry_slice.gd'; Max = 80; Label = 'session telemetry slice' }
  )) {
    Test-LineBudget $budget.Path $budget.Max $budget.Label
  }
}

function Test-DependencyLockSanity {
  Test-DirectoriesMirror 'server\functions' 'supabase\functions' 'server/functions and supabase/functions'
  $serverDenoPath = Join-Path $ProjectPath 'server\functions\deno.json'
  $supabaseDenoPath = Join-Path $ProjectPath 'supabase\functions\deno.json'
  if ((Test-Path -LiteralPath $serverDenoPath -PathType Leaf) -and (Test-Path -LiteralPath $supabaseDenoPath -PathType Leaf)) {
    $serverHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $serverDenoPath).Hash
    $supabaseHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $supabaseDenoPath).Hash
    if ($serverHash -eq $supabaseHash) {
      Add-Ok 'Deno config mirrors are aligned'
    } else {
      Add-Failure 'server/functions/deno.json and supabase/functions/deno.json differ'
    }
    $deno = Get-Content -LiteralPath $serverDenoPath -Raw | ConvertFrom-Json
    if ($deno.compilerOptions.strict -eq $true) {
      Add-Ok 'Deno strict compiler option enabled'
    } else {
      Add-Failure 'Deno strict compiler option must stay enabled'
    }
    foreach ($entrypoint in @('arena/index.ts', 'lab-runner/index.ts', 'modes/index.ts')) {
      if ([string]$deno.tasks.check -like "*$entrypoint*") {
        Add-Ok "Deno check task includes $entrypoint"
      } else {
        Add-Failure "Deno check task missing $entrypoint"
      }
    }
  } else {
    Add-Failure 'Deno config missing under server/functions or supabase/functions'
  }

  Push-Location -LiteralPath $RepoPath
  try {
    $tracked = & git ls-files
  } finally {
    Pop-Location
  }
  $projectTracked = @($tracked | Where-Object { $_.StartsWith('Projetos/draxos-mobile/') })
  $packageFiles = @($projectTracked | Where-Object { $_ -match '(^|/)package\.json$' })
  $lockFiles = @($projectTracked | Where-Object { $_ -match '(^|/)(package-lock\.json|pnpm-lock\.yaml|yarn\.lock)$' })
  if ($packageFiles.Count -gt 0 -and $lockFiles.Count -eq 0) {
    Add-Failure "package.json tracked without Node lockfile: $($packageFiles -join ', ')"
  } else {
    Add-Ok 'Node package/lock sanity is clean'
  }
  if (@($projectTracked | Where-Object { $_ -match '(^|/)node_modules/' }).Count -gt 0) {
    Add-Failure 'node_modules must not be tracked'
  } else {
    Add-Ok 'node_modules is not tracked'
  }

  $remoteImportPattern = 'from\s+["''](https?:|npm:|jsr:)|import\s+["''](https?:|npm:|jsr:)'
  $remoteImports = New-Object System.Collections.Generic.List[string]
  foreach ($rootRelative in @('server\functions', 'supabase\functions', 'server\tests', 'tools')) {
    $root = Join-Path $ProjectPath $rootRelative
    if (-not (Test-Path -LiteralPath $root -PathType Container)) {
      continue
    }
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Include *.ts) {
      $text = Get-Content -LiteralPath $file.FullName -Raw
      if ([regex]::IsMatch($text, $remoteImportPattern)) {
        $remoteImports.Add($file.FullName.Substring($ProjectPath.Length + 1)) | Out-Null
      }
    }
  }
  if ($remoteImports.Count -gt 0 -and -not (Test-Path -LiteralPath (Join-Path $ProjectPath 'deno.lock') -PathType Leaf)) {
    Add-Failure "remote Deno imports require deno.lock. Files: $($remoteImports -join ', ')"
  } else {
    Add-Ok 'Deno remote import lock sanity is clean'
  }
}

function Test-CorsAllowedOrigins {
  $serverHttp = Join-Path $ProjectPath 'server\functions\_shared\http.ts'
  $supabaseHttp = Join-Path $ProjectPath 'supabase\functions\_shared\http.ts'
  if ((Test-Path -LiteralPath $serverHttp -PathType Leaf) -and (Test-Path -LiteralPath $supabaseHttp -PathType Leaf)) {
    $serverHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $serverHttp).Hash
    $supabaseHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $supabaseHttp).Hash
    if ($serverHash -eq $supabaseHash) {
      Add-Ok 'CORS helper mirror is aligned'
    } else {
      Add-Failure 'server/supabase CORS helpers differ'
    }
    $text = Get-Content -LiteralPath $serverHttp -Raw
    foreach ($header in @('authorization', 'apikey', 'content-type', 'x-draxos-save-type', 'x-draxos-api-version')) {
      if ($text.ToLowerInvariant().Contains($header)) {
        Add-Ok "CORS allows header $header"
      } else {
        Add-Failure "CORS must allow header $header"
      }
    }
    if ([regex]::IsMatch($text, '"access-control-allow-origin"\s*:\s*"\*"')) {
      Add-Failure 'CORS uses wildcard origin; V2 requires explicit allowed origins'
    } else {
      Add-Ok 'CORS does not use wildcard origin'
    }
    foreach ($origin in @('aeec7403.draxos-mobile-internal-alpha.pages.dev', 'draxos-mobile-internal-alpha.pages.dev', 'localhost', '127.0.0.1')) {
      if ($text.Contains($origin)) {
        Add-Ok "CORS declares allowed origin marker $origin"
      } else {
        Add-Failure "CORS missing allowed origin marker $origin"
      }
    }
  } else {
    Add-Failure 'CORS helper missing under server/functions/_shared or supabase/functions/_shared'
  }
}

function Test-ClientSecretsAbsent {
  $filesToScan = New-Object System.Collections.Generic.List[string]
  foreach ($relative in @(
    'export_presets.cfg',
    'portal\index.html',
    'portal\manifest.json',
    'build\internal-alpha\publication-report.json',
    'build\internal-alpha\release-plan.json',
    'build\internal-alpha\release-plan.md'
  )) {
    $path = Join-Path $ProjectPath $relative
    if (Test-Path -LiteralPath $path -PathType Leaf) {
      $filesToScan.Add($path) | Out-Null
    }
  }
  foreach ($rootRelative in @('build\internal-alpha\publish', 'build\internal-alpha\cloudflare-pages')) {
    $root = Join-Path $ProjectPath $rootRelative
    if (Test-Path -LiteralPath $root -PathType Container) {
      Get-ChildItem -LiteralPath $root -Recurse -File -Include *.json, *.html, *.js, *.txt |
        ForEach-Object { $filesToScan.Add($_.FullName) | Out-Null }
    }
  }

  $patterns = @(
    'service_role',
    'sb_secret_',
    'sb_service_',
    'SUPABASE_SERVICE_ROLE_KEY',
    'DATABASE_PASSWORD',
    'DB_PASSWORD',
    'KEYSTORE_PASSWORD',
    'DRAXOS_MOBILE_ANDROID_KEYSTORE_RELEASE_PASSWORD'
  )
  foreach ($file in $filesToScan) {
    $text = Get-Content -LiteralPath $file -Raw
    foreach ($pattern in $patterns) {
      if ($text.IndexOf($pattern, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        Add-Failure "secret-like token '$pattern' found in client/release artifact: $file"
      }
    }
  }

  foreach ($name in @(
    'DRAXOS_MOBILE_SUPABASE_PUBLISHABLE_KEY',
    'SUPABASE_PUBLISHABLE_KEY',
    'DRAXOS_MOBILE_UPDATE_MANIFEST_URL',
    'DRAXOS_MOBILE_RUNTIME_CONFIG_JSON'
  )) {
    $value = [Environment]::GetEnvironmentVariable($name, 'Process')
    if ($value) {
      $normalized = $value.Trim().ToLowerInvariant()
      if ($normalized.Contains('service_role') -or
          $normalized.StartsWith('sb_secret_') -or
          $normalized.StartsWith('sb_service_') -or
          $normalized.Contains('database_password') -or
          $normalized.Contains('db_password') -or
          $normalized.Contains('keystore_password')) {
        Add-Failure "environment variable $name contains a secret-like value"
      }
    }
  }

  Push-Location -LiteralPath $RepoPath
  try {
    $tracked = & git ls-files
  } finally {
    Pop-Location
  }
  foreach ($file in $tracked) {
    foreach ($forbidden in @('.env.internal-alpha.local', '.env.local', '.env.production', '.env.remote', '.p12', '.pfx', '.keystore')) {
      if ($file.EndsWith($forbidden, [System.StringComparison]::OrdinalIgnoreCase)) {
        Add-Failure "secret-bearing local file appears tracked: $file"
      }
    }
  }
  Add-Ok 'client/release secret scan completed'
}

function Test-LiveDocReleaseRootFreshness {
  $currentRoot = 'internal-alpha/v0-arena-bosque-visible-v2-20260605-01d80d5'
  $currentPreview = 'https://7b9c8f38.draxos-mobile-internal-alpha.pages.dev'
  $previousVisibleRoot = 'internal-alpha/v0-arena-bosque-regression-hotfix-20260605-a16ca4f'
  $previousVisiblePreview = 'https://bbd81ec5.draxos-mobile-internal-alpha.pages.dev'
  $previousSeasonRoot = 'internal-alpha/v0-arena-pve-season1-loop-v1-20260605-c8baf32'
  $previousSeasonPreview = 'https://d7333659.draxos-mobile-internal-alpha.pages.dev'
  $previousHotfixRoot = 'internal-alpha/v0-arena-duel-flow-hotfix-20260605-7ce5174'
  $previousHotfixPreview = 'https://0536635b.draxos-mobile-internal-alpha.pages.dev'
  $previousArenaRoot = 'internal-alpha/v0-arena-pve-first-real-run-20260605-b69108a'
  $previousArenaPreview = 'https://2c020d09.draxos-mobile-internal-alpha.pages.dev'
  $previousContentRoot = 'internal-alpha/v0-bosque-v3-ux-feel-20260605-782dc45'
  $previousContentPreview = 'https://dcf6eb15.draxos-mobile-internal-alpha.pages.dev'
  $previousOpenworldRoot = 'internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8'
  $previousOpenworldPreview = 'https://aeec7403.draxos-mobile-internal-alpha.pages.dev'
  $hardeningRoot = 'internal-alpha/v0-foundation-hardening-v2-hotfix2-20260601-58671a4'
  $hardeningPreview = 'https://ca946749.draxos-mobile-internal-alpha.pages.dev'
  foreach ($check in @(
    @{ Path = 'AGENTS.md'; Needles = @('Arena/Bosque Visible V2 is the latest remote Internal Alpha publication', $currentRoot, $currentPreview, 'Arena/Bosque Regression Hotfix remains the previous visibility hotfix package', $previousVisibleRoot, $previousVisiblePreview, 'Arena PVE Season 1 Loop v1 remains the previous Season 1 package', $previousSeasonRoot, $previousSeasonPreview, 'Arena Duel Flow Hotfix remains the previous duel-flow hotfix package', $previousHotfixRoot, $previousHotfixPreview, 'Arena PVE First Real Run + Update Recovery remains the previous Arena package', $previousArenaRoot, $previousArenaPreview, 'Bosque v3 UX/Feel remains the previous content/polish package', $previousContentRoot, $previousContentPreview, 'Openworld Main Menu Sync remains the previous Openworld content package', $previousOpenworldRoot, $previousOpenworldPreview, 'Foundation Hardening V2 remains the previous hardening/live-doc enforcement baseline', $hardeningRoot, $hardeningPreview) },
    @{ Path = 'README.md'; Needles = @(('Current release root: `' + $currentRoot + '`'), ('Current verified preview: `' + $currentPreview + '`'), ('Previous visibility hotfix release root: `' + $previousVisibleRoot + '`'), ('Previous visibility hotfix verified preview: `' + $previousVisiblePreview + '`'), ('Previous Season 1 release root: `' + $previousSeasonRoot + '`'), ('Previous Season 1 verified preview: `' + $previousSeasonPreview + '`'), ('Previous Arena release root: `' + $previousArenaRoot + '`'), ('Previous Arena verified preview: `' + $previousArenaPreview + '`'), ('Previous content/polish release root: `' + $previousContentRoot + '`'), ('Previous content/polish verified preview: `' + $previousContentPreview + '`'), ('Previous content release root: `' + $previousOpenworldRoot + '`'), ('Previous content verified preview: `' + $previousOpenworldPreview + '`'), ('Previous hardening release root: `' + $hardeningRoot + '`'), ('Previous hardening verified preview: `' + $hardeningPreview + '`')) },
    @{ Path = 'implementation\current-status.md'; Needles = @('Latest published remote package: `Arena/Bosque Visible V2`', $currentRoot, $currentPreview, 'Previous visibility hotfix package: `Arena/Bosque Regression Hotfix`', $previousVisibleRoot, $previousVisiblePreview, 'Previous Arena Season 1 package: `Arena PVE Season 1 Loop v1`', $previousSeasonRoot, $previousSeasonPreview, 'Previous duel-flow hotfix release root:', $previousHotfixRoot, $previousHotfixPreview, 'Previous Arena package: `Arena PVE First Real Run + Update Recovery`', $previousArenaRoot, $previousArenaPreview, 'Previous content/polish package: `Bosque v3 UX/Feel`', $previousContentRoot, $previousContentPreview, 'Previous Openworld content package: `Openworld Main Menu Sync`', $previousOpenworldRoot, $previousOpenworldPreview, 'Previous hardening baseline: `Foundation Hardening V2`', $hardeningRoot, $hardeningPreview) },
    @{ Path = 'docs\agent-operating-manual.md'; Needles = @('Arena/Bosque Visible V2 is the latest remote Internal Alpha publication', $currentRoot, $currentPreview, 'Arena/Bosque Regression Hotfix remains the previous visibility hotfix package', $previousVisibleRoot, $previousVisiblePreview, 'Arena PVE Season 1 Loop v1 remains the previous Season 1 package', $previousSeasonRoot, $previousSeasonPreview, 'Arena Duel Flow Hotfix remains the previous duel-flow hotfix package', $previousHotfixRoot, $previousHotfixPreview, 'Arena PVE First Real Run + Update Recovery remains the previous Arena package', $previousArenaRoot, $previousArenaPreview, 'Bosque v3 UX/Feel remains the previous content/polish package', $previousContentRoot, $previousContentPreview, 'Openworld Main Menu Sync remains the previous Openworld content package', $previousOpenworldRoot, $previousOpenworldPreview, 'Foundation Hardening V2 is the previous hardening/live-doc enforcement baseline', $hardeningRoot, $hardeningPreview) },
    @{ Path = 'docs\foundation-hardening-v2-readiness-report.md'; Needles = @('Status: `HISTORICO_BASELINE`', $hardeningRoot, $hardeningPreview, 'not the latest remote Internal Alpha package') }
  )) {
    foreach ($needle in $check.Needles) {
      Test-FileContains $check.Path $needle
    }
  }
}

Write-Host "DraxosMobile foundation expansion readiness check"
Write-Host "Project: $ProjectPath"

$requiredFiles = @(
  'docs\foundation-expansion-readiness.md',
  'docs\contracts\account-save.md',
  'docs\contracts\ruleset-registry.md',
  'docs\contracts\mode-integration.md',
  'docs\contracts\admin-ops.md',
  'docs\contracts\lab-heuristics.md',
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
  'server\schema\migrations\202605300004_foundation_closeout.sql',
  'supabase\migrations\202605300004_foundation_closeout.sql',
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
  'server\functions\_shared\battle_log_projection.ts',
  'supabase\functions\_shared\battle_log_projection.ts',
  'server\functions\_shared\battle_combatants.ts',
  'supabase\functions\_shared\battle_combatants.ts',
  'server\functions\_shared\base_domain.ts',
  'supabase\functions\_shared\base_domain.ts',
  'server\functions\_shared\progression_domain.ts',
  'supabase\functions\_shared\progression_domain.ts',
  'server\functions\_shared\economy_domain.ts',
  'supabase\functions\_shared\economy_domain.ts',
  'server\tests\battle_log_projection_test.ts',
  'server\tests\battle_combatants_test.ts',
  'server\tests\base_domain_test.ts',
  'server\tests\progression_domain_test.ts',
  'server\tests\economy_domain_test.ts',
  'server\tests\foundation_ruleset_test.ts',
  'server\tests\foundation_expansion_schema_test.ts',
  'server\tests\transactional_domain_enforcement_schema_test.ts',
  'server\tests\remaining_transactional_domain_enforcement_schema_test.ts',
  'server\tests\transactional_rpc_live_test.ts',
  'server\tests\transactional_edge_rpc_smoke.ts',
  'server\tests\foundation_admin_rls_live_smoke.ts',
  'server\tests\foundation_contracts_test.ts',
  'server\tests\lab_heuristics_contract_test.ts',
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
Test-LiveDocReleaseRootFreshness
Test-ModeDescriptorSchemaStrict
Test-ModeHandlerStrictness
Test-HotFileBudgets
Test-DependencyLockSanity
Test-CorsAllowedOrigins
Test-ClientSecretsAbsent

Test-FileContains 'docs\foundation-expansion-readiness.md' 'QA/OPS CONTRACTS'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'Matriz De Lanes'
Test-FileContains 'docs\foundation-expansion-readiness.md' 'Mode Antes De Feature'
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

Test-FileContains 'docs\contracts\mode-integration.md' 'MODE_INTEGRATION_CONTRACT_V1'
Test-FileContains 'docs\contracts\mode-integration.md' 'Contract-first'
Test-FileContains 'docs\contracts\mode-integration.md' 'Migration'
Test-FileContains 'docs\contracts\mode-integration.md' 'Ruleset'
Test-FileContains 'docs\contracts\mode-integration.md' 'Checklist De Integracao'
Test-FileContains 'docs\contracts\mode-integration.md' 'admin-ops.md'

Test-FileContains 'docs\contracts\admin-ops.md' 'ADMIN_OPS_CONTRACT_V1'
Test-FileContains 'docs\contracts\admin-ops.md' 'admin-internal'
Test-FileContains 'docs\contracts\admin-ops.md' 'audit_id'
Test-FileContains 'docs\contracts\admin-ops.md' 'admin_audit_log'
Test-FileContains 'docs\contracts\admin-ops.md' 'ConfirmRemoteMutation'

Test-FileContains 'docs\contracts\lab-heuristics.md' 'LAB_HEURISTICS_CONTRACT_V1'
Test-FileContains 'docs\contracts\lab-heuristics.md' 'draxos_mobile_battle_lab_v4_source_identity'
Test-FileContains 'docs\contracts\lab-heuristics.md' 'draxos_mobile_progression_lab_v1'
Test-FileContains 'docs\contracts\lab-heuristics.md' 'blocked until explicit package decision'
Test-FileContains 'docs\contracts\lab-heuristics.md' 'bot_power_offsets_percent'
Test-FileContains 'docs\battle-lab\README.md' 'O fluxo local/editor e offline'
Test-FileContains 'docs\battle-lab\README.md' 'POST /lab-runner/battle'
Test-FileContains 'docs\battle-lab\README.md' 'dev/internal-alpha gated'
Test-FileContains 'docs\progression-lab\README.md' 'Nao substitui Supabase como autoridade do jogo'
Test-FileContains 'docs\progression-lab\README.md' 'Nao vira tuning runtime sem pacote explicito'

Test-FileContains 'docs\contracts\api-endpoints.md' 'admin-internal'
Test-FileContains 'docs\contracts\database-schema.md' 'Migrations atuais'
Test-FileContains 'docs\contracts\database-schema.md' 'admin-internal'
Test-FileContains 'docs\contracts\database-schema.md' '202605300001_foundation_expansion_readiness.sql'
Test-FileContains 'docs\contracts\database-schema.md' '202605300002_transactional_domain_enforcement.sql'
Test-FileContains 'docs\contracts\api-endpoints.md' '202605300003_remaining_transactional_domain_enforcement.sql'
Test-FileContains 'docs\contracts\database-schema.md' '202605300004_foundation_closeout.sql'
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
Test-FileContains 'tools\generate_foundation_ruleset.ts' 'battle_combatants.ts'
Test-FileContains 'server\functions\_shared\foundation_ruleset.ts' 'FOUNDATION_RULESET'
Test-FileContains 'supabase\functions\_shared\foundation_ruleset.ts' 'FOUNDATION_RULESET'
Test-FileContains 'server\tests\foundation_ruleset_test.ts' 'foundation ruleset publishes deterministic metadata and hashes'
Test-FileContains 'server\tests\foundation_ruleset_test.ts' 'battle_combatants.ts'
Test-FileContains 'server\tests\lab_heuristics_contract_test.ts' 'lab heuristics contract records current lab model authority'
Test-FileContains 'server\tests\lab_heuristics_contract_test.ts' 'dev lab generators remain offline and adapter-free'
Test-FileContains 'server\tests\lab_heuristics_contract_test.ts' 'progression lab seeder remains local-only and explicit'
Test-FileContains 'server\tests\lab_heuristics_contract_test.ts' 'gameplay runtime does not import dev lab generators'
Test-FileContains 'server\tests\foundation_expansion_schema_test.ts' 'foundation expansion migration is mirrored in server schema'
Test-FileContains 'server\tests\transactional_domain_enforcement_schema_test.ts' 'base edge adapter calls transactional RPCs instead of direct multi-step writes'
Test-FileContains 'server\tests\remaining_transactional_domain_enforcement_schema_test.ts' 'remaining transactional domain RPC dispatcher applies real atomic effects'
Test-FileContains 'server\tests\transactional_rpc_live_test.ts' 'proveBattleRollbackRetryAndIdempotency'
Test-FileContains 'server\tests\transactional_rpc_live_test.ts' 'proveRewardClaimRollbackRetryAndIdempotency'
Test-FileContains 'server\tests\transactional_rpc_live_test.ts' 'proveAlphaPurchaseRollbackRetryAndIdempotency'
Test-FileContains 'server\tests\transactional_rpc_live_test.ts' 'proveGuildCreateRollbackRetryAndIdempotency'
Test-FileContains 'server\tests\transactional_edge_rpc_smoke.ts' 'proveBattleRequestAdapter'
Test-FileContains 'server\tests\transactional_edge_rpc_smoke.ts' 'proveCraftingAdapters'
Test-FileContains 'server\tests\transactional_edge_rpc_smoke.ts' 'assertCompletedIdempotency'
Test-FileContains 'server\tests\foundation_admin_rls_live_smoke.ts' 'proveServiceRoleAdminOps'
Test-FileContains 'server\tests\foundation_admin_rls_live_smoke.ts' 'admin_adjust_resource_balance_v1'
Test-FileContains 'server\tests\foundation_admin_rls_live_smoke.ts' 'admin_audit_log'
Test-FileContains 'tools\validate_foundation.ps1' 'IncludeLocalAdminRls'
Test-FileContains 'tools\validate_foundation.ps1' 'foundation_admin_rls_live_smoke.ts'
Test-FileContains 'server\functions\_shared\battle_log_projection.ts' 'battleLogFromRow'
Test-FileContains 'server\functions\_shared\battle_log_projection.ts' 'historyEntryFromRow'
Test-FileContains 'server\functions\_shared\battle_combatants.ts' 'playerCombatantFromState'
Test-FileContains 'server\functions\_shared\battle_combatants.ts' 'botCombatantFromRow'
Test-FileContains 'server\functions\_shared\battle_combatants.ts' 'potionSlotForBattle'
Test-FileContains 'server\functions\_shared\base_domain.ts' 'baseStatePayload'
Test-FileContains 'server\functions\_shared\base_domain.ts' 'calculateCollectable'
Test-FileContains 'server\functions\_shared\progression_domain.ts' 'buildStatePayload'
Test-FileContains 'server\functions\_shared\progression_domain.ts' 'resolveEquipRequest'
Test-FileContains 'server\functions\_shared\progression_domain.ts' 'calculatePower'
Test-FileContains 'server\functions\_shared\economy_domain.ts' 'monetizationStatePayload'
Test-FileContains 'server\functions\_shared\economy_domain.ts' 'craftingStatePayload'
Test-FileContains 'server\functions\_shared\economy_domain.ts' 'combineResourceDeltas'
Test-FileContains 'server\tests\battle_log_projection_test.ts' 'projection module must not depend on current simulator code'
Test-FileContains 'server\tests\battle_combatants_test.ts' 'battle combatants module is mirrored and adapter-free'
Test-FileContains 'server\tests\base_domain_test.ts' 'base domain module is mirrored and adapter-free'
Test-FileContains 'server\tests\progression_domain_test.ts' 'progression domain module is mirrored and adapter-free'
Test-FileContains 'server\tests\economy_domain_test.ts' 'economy domain module is mirrored and adapter-free'
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
Test-FileContains 'server\functions\build\index.ts' 'rpc/build_spell_behavior_v1'
Test-FileContains 'server\functions\build\index.ts' 'rpc/build_potion_equip_v1'
Test-FileContains 'server\functions\build\index.ts' 'rpc/build_potion_behavior_v1'
Test-FileContains 'server\functions\social\index.ts' 'rpc/social_friend_add_v1'
Test-FileContains 'server\functions\social\index.ts' 'rpc/social_chat_send_v1'
Test-FileContains 'tests\client\test_foundation_shell_contracts.gd' 'test_operation_state_tracks_busy_by_scope'
Test-FileContains 'server\tests\README.md' 'foundation_contracts_test.ts'
Test-FileContains 'server\tests\README.md' 'foundation_expansion_schema_test.ts'
Test-FileContains 'server\tests\README.md' 'transactional_domain_enforcement_schema_test.ts'
Test-FileContains 'server\tests\README.md' 'remaining_transactional_domain_enforcement_schema_test.ts'
Test-FileContains 'server\tests\README.md' 'transactional_rpc_live_test.ts'
Test-FileContains 'server\tests\README.md' 'transactional_edge_rpc_smoke.ts'
Test-FileContains 'server\tests\README.md' 'lab_heuristics_contract_test.ts'
Test-FileContains 'server\tests\README.md' 'battle_log_projection_test.ts'
Test-FileContains 'server\tests\README.md' 'battle_combatants_test.ts'
Test-FileContains 'server\tests\README.md' 'base_domain_test.ts'
Test-FileContains 'server\tests\README.md' 'economy_domain_test.ts'

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
