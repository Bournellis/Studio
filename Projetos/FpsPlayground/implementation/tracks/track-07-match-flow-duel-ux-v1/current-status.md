# Track 07 - Match Flow And Duel UX V1

- Status: `APPROVED_BASELINE`
- Executed: `2026-06-19`
- Owner: Codex
- Branch: `codex/fpsplayground/track07-match-flow-duel-ux-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track07-match-flow-duel-ux-v1`
- Base: Track 06 approved by Fabio on `2026-06-19`.

## Goal

Turn the Arena Shooter lab into a repeatable 1x1 duel without changing weapons, maps, bot aim/damage or movement balance.

## Delivered

- Added explicit round/match state in `arena_root.gd`.
- Added player/bot score, round index, first-to-3 target, last round winner and match winner.
- Made round-end scoring idempotent so duplicate death signals cannot double-score.
- Kept `R` as the fast flow input: next round after round result, fresh match after match over.
- Added pause-menu `Novo duelo` reset.
- Added persistent HUD labels for score, arena/round and result.
- Reset projectiles, pickups, jump pads, bot awareness and HUD feedback on round start.
- Added automated coverage for score progression, match completion, reset and clean starts across all three arenas.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 34/34, 340 asserts
```

Also required before merge/handoff:

```powershell
git diff --check
powershell -ExecutionPolicy Bypass -File D:\Estudio\tools\check_doc_drift.ps1
```

## Human Smoke

- Launch each arena and confirm score starts `0 - 0`.
- Win/lose rounds and confirm only the winner score increments.
- Press `R` after a round result and confirm next round keeps score.
- Reach first to 3 and confirm match result is readable.
- Press `R` after match over and confirm score resets.
- Use pause resume, `Novo duelo`, return to menu and arena reselection.
- Confirm Track 06 bot/map feel did not regress.

## Non-Goals Preserved

- No new weapons, pickups, maps, bot tuning, export, multiplayer/backend, progression or final art pass.

## Handoff

Track 07 is ready for Fabio/tester smoke. If approved, the recommended next track remains `Track 08 - Player Movement Feel Polish V1`.
