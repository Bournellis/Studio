# Track 09I Publication - Kick Super Controller V1

- Date: `2026-06-16`
- Product: `Super Campeao`
- Published version: `v1.2.1+7995b06c`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Preview URL: `https://76b6f219.copa-arena-futebol.pages.dev`
- Release root: `web/v1-copa-arena-futebol-20260616-7995b06c`
- Status: `AUTOMATED_REMOTE_GATES_PASS - HUMAN_RETEST_PENDING`

## Scope

Published the already validated Track 09I reduction. The gameplay code change extracted player kick routing, charged/strong kick handling, SUPER spend/gain helpers and bot kick routing from `football_root.gd` into `modes/football/football_kick_super_controller.gd`.

No gameplay, input, bot decision, physics, scoring, HUD, tuning, asset or branding change was intended.

## Local Gates

- Import headless: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `56` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`, raw `63.06 MiB`, `9` files.
- Chrome local Web boot: PASS with `event.visible_match_start`, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.

## Publication

Command:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260616-7995b06c -VisibleVersion v1.2.1 -EvidenceSubdir track-09i-data -EvidencePrefix 09i -DeployMessage "JogoDaCopa Track 09I Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260616-7995b06c" -ConfirmRemoteMutation -SkipExport
```

Result: PASS. The stable URL served the expected release root after deployment.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Stability 5min gate: PASS, retained JS/WASM heap `43,925,492 -> 48,010,927` bytes (`+9.30%`, limit `<10%`), peak `50,244,475` bytes (`+14.39%`).
- Godot counters/caches: PASS, stable object/node counts and material/mesh caches.
- Worst 5s FPS window: PASS, `132.6 FPS`.
- Night luma gate: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Package: `track-09i-data/09i-package-artifacts-7995b06c.json`.
- Publication: `track-09i-data/09i-publication-report-7995b06c.json`.
- Menu: `track-09i-data/09i-remote-menu-7995b06c.json` and `track-09i-data/09i-remote-menu-7995b06c.png`.
- First minute: `track-09i-data/09i-remote-first-minute-7995b06c.json` and `track-09i-data/09i-remote-first-minute-7995b06c.png`.
- Stability: `track-09i-data/09i-remote-stability-5min-7995b06c.json` and `track-09i-data/09i-remote-stability-5min-7995b06c.png`.
- Luma: `track-09i-data/09i-remote-night-luma-gate-7995b06c.json`.

## Interpretation

Track 09I is safe as the automated public baseline. The Web heap gate is green but still close enough to the threshold that every future public package must keep the 5-minute remote stability gate mandatory.

## Next Gate

Fabio/tester should retest the public 09I build. After approval, open Track 09J as the next local reduction.
