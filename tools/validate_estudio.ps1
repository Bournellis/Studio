[CmdletBinding()]
param(
    [ValidateSet('DocsOnly', 'FastSuite', 'Runtime', 'Build', 'FullLocal')]
    [string]$Profile = 'DocsOnly',
    [string]$Project = '',
    [ValidateSet('Auto', 'Godot', 'Web', 'Backend', 'Android', 'Lab')]
    [string]$Lane = 'Auto',
    [string]$GodotExe = '',
    [string]$BaseRef = 'main',
    [string]$ReportPath = '',
    [switch]$AuditOnly
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$python = Get-Command python -ErrorAction SilentlyContinue
if (-not $python) {
    throw 'Python 3.11+ is required for validate_estudio.ps1.'
}

$arguments = @(
    (Join-Path $PSScriptRoot 'run_validation.py'),
    '--root', $root,
    '--profile', $Profile,
    '--lane', $Lane,
    '--base-ref', $BaseRef
)
if ($Project.Trim().Length -gt 0) {
    $arguments += @('--project', $Project)
}
if ($GodotExe.Trim().Length -gt 0) {
    $arguments += @('--godot-exe', $GodotExe)
}
if ($ReportPath.Trim().Length -gt 0) {
    $arguments += @('--report-path', $ReportPath)
}
if ($AuditOnly) {
    $arguments += '--audit-only'
}

& $python.Source @arguments
exit $LASTEXITCODE
