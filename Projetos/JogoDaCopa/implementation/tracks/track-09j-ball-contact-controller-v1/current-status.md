# Track 09J - Ball Contact Controller V1

- Date: `2026-06-19`
- Status: `LOCAL_VALIDATED`
- Branch: `codex/jogodacopa/track09j-ball-contact-controller-v1`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09j-ball-contact-controller-v1`

## Objective

Reduce `FootballRoot` by extracting player ball-control/contact, ball collision audio and arcade dash/body contact into a dedicated helper without changing gameplay, input, physics, bot decisions, scoring, HUD or assets.

## Implementation

- Added `modes/football/football_ball_contact_controller.gd`.
- Moved player ball-control state refresh, passive player-ball contact, ball collision audio routing and arcade dash/body contact handling into the controller.
- Kept compatibility wrappers in `football_root.gd` for existing call sites and tests.
- Preserved existing `_physics_process` order and all tuning constants in `FootballRoot`.

## Measurement

- `football_root.gd`: `943 -> 832` lines in the current base.
- `football_ball_contact_controller.gd`: `125` lines.

## Validation

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `57` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`, raw `63.07 MiB`, `9` files.
- Chrome local Web boot: PASS, `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Evidence: `docs/playtest-reports/track-09j-data/09j-local-web-boot.json`, `docs/playtest-reports/track-09j-data/09j-local-web-boot.png`.

## Next Step

Merge locally into `main`; Fabio pushes via GitHub Desktop. If 09J should become public, open a short publication track with remote menu, first-minute, 5-minute stability and night luma gates.
