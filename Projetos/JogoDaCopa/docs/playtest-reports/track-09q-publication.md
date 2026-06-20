# Track 09Q Publication - Football Presentation FX Controller V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Published version: `v1.2.1+bb604c77`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Preview URL: `https://38e6cc7d.copa-arena-futebol.pages.dev`
- Release root: `web/v1-copa-arena-futebol-20260619-bb604c77`
- Status: `AUTOMATED_REMOTE_GATES_PASS - HUMAN_RETEST_PENDING`

## Scope

Published the already validated Track 09Q reduction. The gameplay code change extracted presentation-only arcade emote, boost/skid VFX, goal slow-mo/camera shake, appearance cycling and avatar movement-state updates from `football_root.gd` into `modes/football/football_presentation_fx_controller.gd`.

No gameplay, input, bot decision, physics, ball contact, kick/SUPER, scoring, HUD visual, tuning, asset, branding or Web loading change was intended.

## Local Gates

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `60` source files checked.
- Web export/package: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB` after publication export.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Package artifact: `track-09q-data/09q-package-artifacts-bb604c77.json`.

## Publication

Command:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260619-bb604c77 -VisibleVersion v1.2.1 -EvidenceSubdir track-09q-data -EvidencePrefix 09q -DeployMessage "JogoDaCopa Track 09Q Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260619-bb604c77" -ConfirmRemoteMutation -SkipExport
```

Result: PASS. The stable URL served the expected release root after deployment.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, page errors `0`, console errors `0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, console errors `0`.
- Stability 5min gate: PASS, `js_heap_growth +8.41%` against the `+10%` limit, peak `+12.61%`, `wasmSampleCount=0`.
- `total_js_heap_growth`: `+7.42%`.
- Browser/Godot stability samples: `302 / 290`.
- Five-second FPS gate: PASS, worst average `116.0 FPS`.
- Godot counter stability: PASS.
- Night luma gate: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Package: `track-09q-data/09q-package-artifacts-bb604c77.json`.
- Publication: `track-09q-data/09q-publication-report-bb604c77.json`.
- Menu: `track-09q-data/09q-remote-menu-bb604c77.json` and `track-09q-data/09q-remote-menu-bb604c77.png`.
- First minute: `track-09q-data/09q-remote-first-minute-bb604c77.json` and `track-09q-data/09q-remote-first-minute-bb604c77.png`.
- Stability: `track-09q-data/09q-remote-stability-5min-bb604c77.json` and `track-09q-data/09q-remote-stability-5min-bb604c77.png`.
- Luma: `track-09q-data/09q-remote-night-luma-gate-bb604c77.json`.

## Interpretation

Track 09Q is now the public Web candidate with all automated remote gates passing. It is not yet the human-approved baseline. Track 09P remains the latest human-approved fallback until Fabio/tester completes and approves the public retest.

## Human Retest

Pending. Recommended focus: intro/start, ESC/pause/menu/restart/main menu, goal slowmo, camera shake, emote, boost/skid VFX, skin/kit cycling, normal kick, charged kick, SUPER and ordinary match feel.

## Next Gate

Fabio/tester should retest the public URL. If approved, record 09Q as the approved public baseline; if rejected or if any regression is found, keep 09P as the approved fallback and open a focused hotfix/rollback decision.
