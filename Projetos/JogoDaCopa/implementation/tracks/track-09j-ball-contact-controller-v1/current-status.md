# Track 09J - Ball Contact Controller V1

- Date: `2026-06-19`
- Status: `LOCAL_VALIDATED_PUBLICATION_BLOCKED_REMOTE_HEAP`
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

## Publication Attempt

- Candidate deploy: `v1.2.1+4678fbea`, `web/v1-copa-arena-futebol-20260619-4678fbea`, `https://ff5e2d51.copa-arena-futebol.pages.dev`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: FAIL twice on JS/WASM heap growth (`+15.96%`, then `+15.22%`; gate limit `<10%`).
- Godot counters/caches and FPS remained green in both stability runs.
- Production rollback: restored approved 09I public baseline `v1.2.1+7995b06c`, `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Evidence: `docs/playtest-reports/track-09j-publication.md` and `docs/playtest-reports/track-09j-data/`.

## Next Step

Open a focused remote heap investigation/hotfix before republication or further `FootballRoot` reduction. Fabio pushes local commits via GitHub Desktop when ready.
