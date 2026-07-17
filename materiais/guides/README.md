# Guides

## Metadata

- status: `active`
- authority: `router`
- last_verified: `2026-07-17`
- review_when: `a guide changes authority, classification or default-search visibility`
- supersedes: `materiais/guides/README.md before Documentation Lite`
- superseded_by: `none`

This directory routes operational guides, tutorials and preserved references. It never defines portfolio or project state.

## Classification

- `live`: current runbook, allowed in normal search and listed below.
- `reference`: stable technical material, read only when the task requires it.
- `historical_record`: superseded context, excluded from normal `rg`; use `rg --no-ignore` or an explicit path.
- `evidence`: non-regenerable decision, license, receipt or provenance; it does not belong in this guide directory by default.

## Current Agent Guides

Use these for new agent work. Resolve portfolio status from `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`:

- `estudio-agent-workflow-current.md`
- `thread-cheat-sheet-current.md`
- `direct-thread-templates-current.md`

## Historical References

These files are preserved for explicit historical consultation and are excluded from normal search by `.rgignore`:

- `art-pipeline.md`
- `art-tutorial-heroic.md`
- `codex-workflow-guide.md`
- `direct-thread-templates.md`
- `thread-cheat-sheet.md`
- `unity-legacy-surface.md`
