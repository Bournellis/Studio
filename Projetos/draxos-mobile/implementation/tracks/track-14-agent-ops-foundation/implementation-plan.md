# Track 14 - Agent Operations Foundation Implementation Plan

## Reconciliation

1. Use `codex/draxos-mobile/track-13-validation-release-safety` as base.
2. Confirm Track 11 Kanban cleanup is preserved.
3. Confirm Track 12 boot decomposition is preserved.
4. Confirm Track 13 validation/release safety scripts are preserved.

## Agent Entrypoints

1. Rewrite `AGENTS.md` as the fast operating manual.
2. Rewrite `README.md` as a short portal.
3. Condense `implementation/current-status.md`.
4. Add `docs/agent-operating-manual.md`.

## Documentation Classification

1. Add `docs/documentation-index.md`.
2. Classify live docs, contracts, runbooks, history and design archive.
3. Point agents away from stale Track 04/08/10 entrypoints.

## Coordination

1. Create a single active Doing card for Track 14.
2. Keep old DraxosMobile cards in Done.
3. Update `Prioridades_Estudio.md`, `Estado_Atual.md`, `Projetos/README.md` and `Painel_Visual_Estudio.html`.

## Product Terminology

1. Keep `product-vision.md` as the local product canon.
2. Update `product-brief.md` and `game-design-document.md` to use Instrumento Ritual, Doutrina and Familiar as product/design language.
3. Preserve `weapon/passive/pet` only where needed as legacy technical field names.
4. Keep unresolved decisions only in `design-pending.md`.

## Validation And Release

1. Keep `tools/validate_foundation.ps1` as the primary runner.
2. Add a Track 14 agent-ops readiness check.
3. Keep Track 13 release safety checks intact.
4. Run Full validation, Godot validate, GUT, Deno checks, `git diff --check` and `git status --short`.

## Commit Shape

1. `docs: reorganize draxos mobile agent entrypoints`
2. `docs: classify live docs and archive historical context`
3. `coordination: clean draxos mobile kanban and portfolio state`
4. `tools: adopt foundation validation and release safety checks`
5. `docs: align product terminology and pending decisions`
6. `validation: record final foundation verification`
