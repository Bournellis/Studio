[CmdletBinding()]
param(
    [string]$Project = 'AllOfficial',
    [string]$BaseRef = 'main',
    [switch]$AuditOnly
)

# Backward-compatible alias. Governance v2 centralizes docs validation so the
# legacy command cannot silently run a weaker gate.
$arguments = @(
    '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
    (Join-Path $PSScriptRoot 'validate_estudio.ps1'),
    '-Profile', 'DocsOnly',
    '-Project', $Project,
    '-BaseRef', $BaseRef
)
if ($AuditOnly) {
    $arguments += '-AuditOnly'
}
& powershell @arguments
exit $LASTEXITCODE
