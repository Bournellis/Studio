# Track 06C - Football Feel & Possession V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Target status marker: `FPS_PLAYGROUND_TRACK_06C_FOOTBALL_FEEL_POSSESSION_COMPLETE`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track06c-football-feel-possession-v1`
- Branch: `codex/fpsshooter/track06c-football-feel-possession-v1`

## Goal

Make the third-person `Futebol` mode feel more like its own playable football prototype after Track 06B by improving close ball control, body-forward kick assist, camera focus, HUD readability and simple bot approach behavior.

## Confirmed Direction

- Preserve `Arena Shooter` as the first-person baseline.
- Keep `Futebol` 1x1 against a bot, no weapons, no boost/stamina system and no final assets.
- Improve feel with lightweight arcade rules rather than adding a heavy football simulation.
- Keep all authority local/editor-first with runtime primitives.

## Delivered

- Added football match-rule helpers for kick assist and possession state.
- Added `FootballBall3D.apply_dribble_control()` so close control can nudge the ball without counting as a kick.
- `FootballRoot` now tracks `free`, `reachable` and `possession` ball-control states.
- Close possession gently steers the ball along the player's body-forward/movement direction.
- LMB/RMB kicks use light assist for near front-side balls, improving reliability without adding lock-on.
- Football HUD now exposes a compact `Controle` line and distinguishes adjusted kicks.
- Chase camera now increases ball focus weight when the ball is farther away.
- Football bot now approaches behind the ball relative to the opponent goal, improving attack setup instead of always charging the ball center.
- Automated coverage validates possession state, assist reach, dribble control without kick count, assisted kick, dynamic camera focus, HUD control line and bot approach target.

## Acceptance

- Football close control can nudge the ball without firing kick feedback: done.
- Near front-side kicks connect with assist and record assist strength: done.
- HUD communicates ball control discreetly: done.
- Camera focus adapts when the ball is far: done.
- Bot approaches behind the ball before attacking: done.
- Existing scoring, avatar selection, kick/strong-kick and Arena Shooter regression remain green: done.

## Validation Snapshot

- Baseline `tools/validate.gd -- --profile=quick`: passed with `58/58` tests and `455` asserts after fresh-worktree editor import.
- Implementation `tools/validate.gd -- --profile=quick`: passed with `64/64` tests and `477` asserts.
- Final `tools/validate.gd -- --profile=full`: passed with `64/64` tests and `477` asserts before closeout.
