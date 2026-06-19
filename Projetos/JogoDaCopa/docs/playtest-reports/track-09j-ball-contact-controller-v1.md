# Track 09J - Ball Contact Controller V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Status: `LOCAL_VALIDATED`
- Branch: `codex/jogodacopa/track09j-ball-contact-controller-v1`

## Scope

Extracted the remaining low-risk ball-contact orchestration from `football_root.gd` into `modes/football/football_ball_contact_controller.gd`.

The track moved player ball-control state, passive player-ball contact, ball collision audio, arcade slide-ball contact and arcade body-contact knockback/stun. No gameplay, input, physics, bot decision, scoring, HUD, tuning, asset or publication change was intended.

## Measurement

- `football_root.gd`: `943 -> 832` lines.
- New `football_ball_contact_controller.gd`: `125` lines.
- Net `FootballRoot` reduction: `111` lines.

## Local Gates

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `57` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`, raw `63.07 MiB`, `9` files.
- Chrome local Web boot: PASS with `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## Evidence

- Chrome local Web boot: `track-09j-data/09j-local-web-boot.json`.
- Screenshot: `track-09j-data/09j-local-web-boot.png`.

## Interpretation

The extracted controller preserves existing behavior while removing another cohesive responsibility from `FootballRoot`. The full GUT suite and Web boot gate cover the moved player control/contact, arcade dash contact, match flow side effects and browser runtime surface.

## Next Gate

This is a local reduction track. Fabio should push the local merge via GitHub Desktop. Public release should be handled by a separate publication track with remote menu, first-minute, 5-minute stability and night luma gates.
