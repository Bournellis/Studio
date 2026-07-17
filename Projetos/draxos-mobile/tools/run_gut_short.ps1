[CmdletBinding()]
param(
    [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path,
    [string]$GodotExe = 'D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe',
    [string]$TestPathCsv = 'res://tests/client/test_project_info.gd,res://tests/client/test_session_state_facade.gd,res://tests/client/test_mode_descriptor_registry.gd',
    [int]$ExpectedTests = 13,
    [int]$ExpectedAsserts = 170,
    [switch]$SkipImport
)

$ErrorActionPreference = 'Continue'
$projectPath = (Resolve-Path -LiteralPath $ProjectDir).Path
if (-not (Test-Path -LiteralPath $GodotExe -PathType Leaf)) {
    throw "Godot executable not found: $GodotExe"
}

$testPaths = @($TestPathCsv.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
if ($testPaths.Count -eq 0) {
    throw 'At least one GUT test path is required.'
}
foreach ($testPath in $testPaths) {
    if (-not $testPath.StartsWith('res://tests/client/')) {
        throw "GUT short path is outside tests/client: $testPath"
    }
    $relative = $testPath.Substring('res://'.Length).Replace('/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath (Join-Path $projectPath $relative) -PathType Leaf)) {
        throw "GUT short test does not exist: $testPath"
    }
}

$importSucceeded = $SkipImport.IsPresent
if ($SkipImport) {
    Write-Host '[SKIP] Godot import warm-up is owned by the Estudio orchestrator.'
} else {
    for ($attempt = 1; $attempt -le 2; $attempt++) {
        $importOutput = @(& $GodotExe --headless --path $projectPath --import 2>&1)
        $importCode = $LASTEXITCODE
        if ($importCode -eq 0) {
            Write-Host "[PASS] Godot import warm-up attempt $attempt"
            $importSucceeded = $true
            break
        }
        Write-Warning "Godot import warm-up attempt $attempt exited $importCode; retrying once."
    }
}
if (-not $importSucceeded) {
    $importOutput | Select-Object -Last 40 | ForEach-Object { Write-Host $_ }
    throw 'Godot import warm-up failed twice.'
}

$gutArgs = @('--headless', '--path', $projectPath, '-s', 'res://addons/gut/gut_cmdln.gd', '-gconfig=')
foreach ($testPath in $testPaths) {
    $gutArgs += "-gtest=$testPath"
}
$gutArgs += '-gexit'

$gutOutput = @(& $GodotExe @gutArgs 2>&1)
$gutCode = $LASTEXITCODE
$gutOutput | ForEach-Object { Write-Host $_ }
$gutText = $gutOutput -join "`n"

if ($gutCode -ne 0) {
    throw "GUT short suite exited $gutCode."
}
if ($gutText -match 'Missing class_names' -or $gutText -match '(?m)^(?:SCRIPT )?ERROR:') {
    throw 'GUT short suite emitted an engine or script error.'
}
if ($gutText -notmatch "Tests\s+$ExpectedTests(?:\D|$)" -or
    $gutText -notmatch "Passing Tests\s+$ExpectedTests(?:\D|$)" -or
    $gutText -notmatch "Asserts\s+$ExpectedAsserts(?:\D|$)" -or
    $gutText -notmatch 'All tests passed!') {
    throw "GUT short summary did not match $ExpectedTests tests / $ExpectedAsserts asserts."
}

Write-Host "GUT_SHORT_PASS tests=$ExpectedTests asserts=$ExpectedAsserts"
