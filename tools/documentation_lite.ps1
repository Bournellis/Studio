[CmdletBinding()]
param(
    [ValidateSet('Audit', 'Prepare', 'Execute', 'Verify')]
    [string]$Mode = 'Audit',
    [string]$Batch = '',
    [string]$Project = 'AllOfficial',
    [string]$ConfirmManifestHash = '',
    [string]$ReportPath = '',
    [switch]$Ci,
    [switch]$AuditOnly
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$python = (Get-Command python -ErrorAction Stop).Source
$arguments = @(
    (Join-Path $PSScriptRoot 'documentation_lite.py'),
    '--root', $root,
    '--mode', $Mode,
    '--project', $Project
)
if ($Batch.Trim().Length -gt 0) { $arguments += @('--batch', $Batch) }
if ($ConfirmManifestHash.Trim().Length -gt 0) { $arguments += @('--confirm-manifest-hash', $ConfirmManifestHash) }
if ($ReportPath.Trim().Length -gt 0) { $arguments += @('--report-path', $ReportPath) }
if ($Ci) { $arguments += '--ci' }
if ($AuditOnly) { $arguments += '--audit-only' }

& $python @arguments
exit $LASTEXITCODE
