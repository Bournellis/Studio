# Track 09P Publication - Football Session UI Controller V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Published version: `v1.2.1+8863c5b9`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Preview URL: `https://5a1325e4.copa-arena-futebol.pages.dev`
- Release root: `web/v1-copa-arena-futebol-20260619-8863c5b9`
- Status: `AUTOMATED_REMOTE_GATES_PASS - HUMAN_RETEST_PENDING`

## Scope

Published the already validated Track 09P reduction. The gameplay code change extracted intro/pause/menu session flow, ESC target routing, match start, main-menu return and mouse-capture policy from `football_root.gd` into `modes/football/football_session_ui_controller.gd`.

No gameplay, input, bot decision, physics, scoring, HUD visual, tuning, asset or branding change was intended.

## Local Gates

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `59` source files checked.
- Web export/package: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Package artifact: `track-09p-data/09p-package-artifacts-8863c5b9.json`.

## Publication

Command:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260619-8863c5b9 -VisibleVersion v1.2.1 -EvidenceSubdir track-09p-data -EvidencePrefix 09p -DeployMessage "JogoDaCopa Track 09P Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260619-8863c5b9" -ConfirmRemoteMutation -SkipExport
```

Result: PASS. The stable URL served the expected release root after deployment.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, page errors `0`, console errors `0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, console errors `0`.
- Stability 5min gate: PASS, `js_heap_growth +2.15%` against the `+10%` limit, peak `+7.18%`, `wasmSampleCount=0`.
- `total_js_heap_growth`: `-0.37%`.
- Browser/Godot stability samples: `302 / 290`.
- Night luma gate: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Package: `track-09p-data/09p-package-artifacts-8863c5b9.json`.
- Publication: `track-09p-data/09p-publication-report-8863c5b9.json`.
- Menu: `track-09p-data/09p-remote-menu-8863c5b9.json` and `track-09p-data/09p-remote-menu-8863c5b9.png`.
- First minute: `track-09p-data/09p-remote-first-minute-8863c5b9.json` and `track-09p-data/09p-remote-first-minute-8863c5b9.png`.
- Stability: `track-09p-data/09p-remote-stability-5min-8863c5b9.json` and `track-09p-data/09p-remote-stability-5min-8863c5b9.png`.
- Luma: `track-09p-data/09p-remote-night-luma-gate-8863c5b9.json`.

## Interpretation

Track 09P is now the public build with automated remote gates green. It is not yet the product-approved baseline because human retest is pending. Track 09N remains the approved fallback baseline until Fabio/tester approves 09P.

## Human Retest

Pending on 2026-06-19 using the public URL.

## Next Gate

Run human retest on `https://copa-arena-futebol.pages.dev/`. If approved, mark 09P as the approved public baseline. If rejected, restore or republish 09N and record the blocker before opening another reduction.
