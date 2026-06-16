# Track 09I - Kick Super Controller V1

- Date: `2026-06-16`
- Status: `LOCAL_VALIDATED`
- Branch: `codex/jogodacopa/track09i-kick-super-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09i-kick-super-controller-v1`

## Objective

Reduce `FootballRoot` by extracting kick and SUPER orchestration into a dedicated helper without changing gameplay, input, physics, bot decisions, HUD, assets or public Web deployment.

## Implementation

- Added `modes/football/football_kick_super_controller.gd`.
- Moved player kick request routing, charged kick scaling, strong/SUPER decision, connected kick side effects, bot kick handling and SUPER meter helpers into the controller.
- Kept compatibility wrappers in `football_root.gd` for existing signal connections and Web warmup call sites.
- Kept loose-ball contact, arcade dash contact, ball collision audio and `_physics_process` ordering in `football_root.gd`.

## Measurement

- `football_root.gd`: `995 -> 943` lines in the current base.
- `football_kick_super_controller.gd`: `76` lines.

## Validation

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `56` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` files.
- Chrome local Web boot: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidence: `docs/playtest-reports/track-09i-data/09i-local-web-boot.json`, `docs/playtest-reports/track-09i-data/09i-local-web-boot.png`.

## Next Step

Either publish 09I as a no-gameplay public package, or continue locally with Track 09J to extract the remaining ball-contact surface.
