# check_doc_drift.ps1
# Verifies that pointer documents carry no operational state and that living
# snapshots stay compact. See AGENTS.md "Single Source Of State".
# Usage: powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_doc_drift.ps1
# Exit code 0 = PASS, 1 = violations found.

[CmdletBinding()]
param()

$root = Split-Path -Parent $PSScriptRoot

# Pointer documents: must never contain package markers, release roots,
# deploy URLs, build versions or "active stage" lines.
$pointerFiles = @(
    'README.md',
    'CLAUDE.md',
    'AGENTS.md',
    'canon\canon-brief.md',
    'canon\README.md',
    'Projetos\README.md',
    'Projetos\draxos-mobile\AGENTS.md',
    'Projetos\draxos-mobile\docs\agent-operating-manual.md'
)

$forbiddenPatterns = @(
    '_PUBLISHED_INTERNAL_ALPHA',
    'internal-alpha/v0-',
    '\.pages\.dev',
    '\d+\.\d+\.\d+-alpha',
    'Track ativa:',
    'Active stage:',
    'JOGO_DA_COPA_TRACK_',
    'FPS_PLAYGROUND_PROJECT_SPLIT'
)

# Living snapshots: allowed to carry state, but lines must stay short.
# Long run-on lines are the signature of history accumulating in a snapshot.
$snapshotFiles = @(
    '08_Coordenacao_Agentes\Estado_Atual.md',
    '08_Coordenacao_Agentes\Prioridades_Estudio.md'
)
$maxSnapshotLineLength = 700

$violations = @()

foreach ($rel in $pointerFiles) {
    $path = Join-Path $root $rel
    if (-not (Test-Path $path)) {
        $violations += "missing pointer file: $rel"
        continue
    }
    $lineNumber = 0
    foreach ($line in Get-Content -Path $path) {
        $lineNumber++
        foreach ($pattern in $forbiddenPatterns) {
            if ($line -match $pattern) {
                $violations += ("{0}:{1} matches forbidden pattern '{2}'" -f $rel, $lineNumber, $pattern)
            }
        }
    }
}

foreach ($rel in $snapshotFiles) {
    $path = Join-Path $root $rel
    if (-not (Test-Path $path)) {
        $violations += "missing snapshot file: $rel"
        continue
    }
    $lineNumber = 0
    foreach ($line in Get-Content -Path $path) {
        $lineNumber++
        if ($line.Length -gt $maxSnapshotLineLength) {
            $violations += ("{0}:{1} line has {2} chars (max {3}) - move history to the project history files" -f $rel, $lineNumber, $line.Length, $maxSnapshotLineLength)
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host ("[check_doc_drift] FAIL - {0} violation(s):" -f $violations.Count)
    foreach ($v in $violations) {
        Write-Host ("  " + $v)
    }
    exit 1
}

Write-Host '[check_doc_drift] PASS - pointer docs are state-free and snapshots are compact.'
exit 0
