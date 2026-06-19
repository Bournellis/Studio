# Track 09N Publication - Render Settings Controller V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Published version: `v1.2.1+5c6520ba`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Preview URL: `https://97957745.copa-arena-futebol.pages.dev`
- Release root: `web/v1-copa-arena-futebol-20260619-5c6520ba`
- Status: `AUTOMATED_REMOTE_GATES_PASS - AWAITING_HUMAN_RETEST`

## Scope

Published the already validated Track 09N reduction. The gameplay code change extracted menu/settings, `GameSettings`, render profile refresh, scoreboard SubViewport resize and sensitivity synchronization from `football_root.gd` into `modes/football/football_render_settings_controller.gd`.

No gameplay, input, bot decision, physics, scoring, HUD visual, tuning, asset or branding change was intended.

## Local Gates

- Merge into local `main`: PASS, commit `5c6520ba`.
- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `58` source files checked.
- Web package/export: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`.
- Package artifact: `track-09n-data/09n-package-artifacts-5c6520ba.json`.

## Publication

Command:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260619-5c6520ba -VisibleVersion v1.2.1 -EvidenceSubdir track-09n-data -EvidencePrefix 09n -DeployMessage "JogoDaCopa Track 09N Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260619-5c6520ba" -ConfirmRemoteMutation -SkipExport
```

Result: PASS. The stable URL served the expected release root after deployment.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, page errors `0`, console errors `0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, console errors `0`.
- Stability 5min gate: PASS, `js_heap_growth +0.41%` against the `+10%` limit, peak `+6.05%`, `wasmSampleCount=0`.
- `total_js_heap_growth`: `-5.52%`.
- Browser/Godot stability samples: `318 / 304`.
- Night luma gate: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Package: `track-09n-data/09n-package-artifacts-5c6520ba.json`.
- Publication: `track-09n-data/09n-publication-report-5c6520ba.json`.
- Menu: `track-09n-data/09n-remote-menu-5c6520ba.json` and `track-09n-data/09n-remote-menu-5c6520ba.png`.
- First minute: `track-09n-data/09n-remote-first-minute-5c6520ba.json` and `track-09n-data/09n-remote-first-minute-5c6520ba.png`.
- Stability: `track-09n-data/09n-remote-stability-5min-5c6520ba.json` and `track-09n-data/09n-remote-stability-5min-5c6520ba.png`.
- Luma: `track-09n-data/09n-remote-night-luma-gate-5c6520ba.json`.

## Interpretation

Track 09N is safe as an automated public baseline candidate. Unlike the local pre-publication A/B run, the production stability gate had wide margin (`+0.41%`), with no runtime errors and no first-minute hitch. Human retest is still required before treating the release as product-approved.

## Human Retest

Pending Fabio/tester retest on the public URL.

## Next Gate

If human retest approves the public 09N build, resume local `FootballRoot` reduction from the new baseline. If human retest finds a blocker, restore the approved 09I fallback and investigate before any new reduction.
