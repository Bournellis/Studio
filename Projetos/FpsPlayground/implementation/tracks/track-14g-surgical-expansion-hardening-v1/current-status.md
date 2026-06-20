# Track 14G - Surgical Expansion Hardening V1

- Status: `READY_FOR_REVIEW`
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

## Delivered

- Extracted `BotMovementExecutor` for pure bot movement execution helpers.
- Extracted `ArenaProjectileRuntime` for player Plasma bolt creation, stepping and cleanup.
- Extracted `ArenaHudFeedbackState` for transient HUD timers, event messages and crosshair feedback view.
- Added `ArenaTelemetryEvents` facade for context assembly and event emission.
- Added focused unit coverage for each new boundary.
- Rebaselined hotspot size: `arena_root.gd` 1487 lines, `basic_duel_bot.gd` 1077 lines, `arena_hud.gd` 535 lines.

## Validation Target

```text
PASS git diff --check
PASS tools/check_doc_drift.ps1
PASS tools/validate.gd -- --profile=quick (`66/66`, `593 asserts`)
PASS tools/validate.gd (`66/66`, `593 asserts`)
```

## Next

After review/merge, execute `Multi-Arena Balance Baseline V1`.
