# Track 13 - Documentation Rebaseline And Future Roadmap V1

- Status: `COMPLETE`
- Executed: `2026-06-19`
- Owner: Codex
- Branch: `codex/fpsplayground/track13-docs-rebaseline-future-roadmap-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track13-docs-rebaseline-future-roadmap-v1`
- Base: Track 12 telemetry/readout approved by Fabio.

## Goal

Rebaseline the live documentation after Track 12 approval and prepare the next phase of `FpsPlayground` with a concise roadmap for maps, weapons, buffs, pickups, bot evolution and telemetry-first tuning.

## Guardrails

- No gameplay changes.
- No movement, jump pad, map, weapon, pickup or bot tuning.
- Preserve the current player movement feel.
- Keep football/TPS scope in `JogoDaCopa`.
- Keep Draxos progression/economy/backend systems out of this project.

## Delivered

- Updated studio snapshots from Track 12 smoke-pending to Track 13 documentation complete.
- Updated project entry docs: README, AGENTS guide, current status, documentation index and work plan.
- Added `docs/arena-shooter-future-roadmap.md`.
- Updated architecture, tuning, arena authoring, telemetry readout, balance baseline and validation docs.
- Normalized recent track record status headers so completed baseline work no longer reads as smoke-pending.

## Validation

```powershell
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\FpsPlayground--codex--track13-docs-rebaseline-future-roadmap-v1\Projetos\FpsPlayground -s res://tools/validate.gd
git status --short
```

Result:

- whitespace check PASS;
- document drift check PASS;
- `validate.gd` PASS, GUT `53/53`, `496 asserts` after one-time headless editor import for the fresh worktree.
- branch clean after commit.

## Next Recommendation

Prefer `Track 14 - Multi-Arena Balance Baseline V1` before gameplay tuning, unless Fabio explicitly chooses to define arsenal and buff contracts first.
