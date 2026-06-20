# Track 14G - Surgical Expansion Hardening V1

- Status: `IN_PROGRESS`
- Date: `2026-06-20`
- Branch: `codex/fpsplayground/track14g-surgical-expansion-hardening-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track14g-surgical-expansion-hardening-v1`

## Goal

Reduce expansion risk in the approved Arena Shooter baseline through small structural boundaries around bot movement execution, projectile runtime, HUD feedback state and telemetry event emission.

## Non-Goals

- No gameplay tuning.
- No player movement feel changes.
- No map geometry changes.
- No jump pad force changes.
- No weapon value changes.
- No pickup behavior changes.
- No bot decision priority changes.
- No telemetry schema changes.

## Planned Stages

1. Extract `BotMovementExecutor` for pure bot movement helpers.
2. Extract arena projectile runtime helpers.
3. Isolate HUD transient feedback state.
4. Add an arena telemetry event facade.
5. Rebaseline code-size metrics and docs.

## Validation Target

```text
PASS git diff --check
PASS tools/check_doc_drift.ps1
PASS tools/validate.gd -- --profile=quick
PASS tools/validate.gd
```

## Next

After local validation, return to `Multi-Arena Balance Baseline V1`.
