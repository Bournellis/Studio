# Track 09R Publication - Foot And Camera Hotfix V1

- Date: `2026-06-20`
- Product: `Super Campeao`
- Published version: `v1.2.1+33ba1a2b`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Preview URL: `https://8fedfdea.copa-arena-futebol.pages.dev`
- Release root: `web/v1-copa-arena-futebol-20260619-33ba1a2b`
- Status: `AUTOMATED_REMOTE_GATES_PASS - HUMAN_RETEST_PENDING`

## Scope

Published the already validated Track 09R hotfix. The gameplay code change fixes two playtest findings: visible avatar feet entering the field plane and odd chase-camera pull/tilt during lateral A/D strafe.

No gameplay collision, physics, scoring, bot, SUPER, HUD, asset or match tuning change was intended.

## Local Gates

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `106/106` tests, `1831` asserts, `60` source files checked.
- Web export/package: PASS.
- Web gzip transfer gate: PASS, `30.61 MiB / 50.00 MiB` after publication export.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Package artifact: `track-09r-data/09r-package-artifacts-33ba1a2b.json`.

## Publication

Command:

```powershell
tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260619-33ba1a2b -VisibleVersion v1.2.1 -EvidenceSubdir track-09r-data -EvidencePrefix 09r -DeployMessage "JogoDaCopa Track 09R Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260619-33ba1a2b" -ConfirmRemoteMutation -SkipExport
```

Result: PASS. The stable URL served the expected release root after deployment.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, page errors `0`, console errors `0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, console errors `0`.
- Stability 5min gate: PASS, `js_heap_growth +8.33%` against the `+10%` limit, peak `+13.68%`, `wasmSampleCount=0`.
- `total_js_heap_growth`: `+8.04%`.
- Browser/Godot stability samples: `297 / 284`.
- Five-second FPS gate: PASS, worst average `136.6 FPS`.
- Godot counter stability: PASS.
- Night luma gate: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Package: `track-09r-data/09r-package-artifacts-33ba1a2b.json`.
- Publication: `track-09r-data/09r-publication-report-33ba1a2b.json`.
- Menu: `track-09r-data/09r-remote-menu-33ba1a2b.json` and `track-09r-data/09r-remote-menu-33ba1a2b.png`.
- First minute: `track-09r-data/09r-remote-first-minute-33ba1a2b.json` and `track-09r-data/09r-remote-first-minute-33ba1a2b.png`.
- Stability: `track-09r-data/09r-remote-stability-5min-33ba1a2b.json` and `track-09r-data/09r-remote-stability-5min-33ba1a2b.png`.
- Luma: `track-09r-data/09r-remote-night-luma-gate-33ba1a2b.json`.

## Interpretation

Track 09R is now the public Web candidate with all automated remote gates passing. It is not yet the human-approved baseline. Track 09Q remains the latest human-approved fallback until Fabio/tester completes and approves the public retest.

## Human Retest

Pending. Recommended focus: foot/boot visual clearance over the field plane, lateral A/D camera feel, camera horizon stability, normal match flow, goals, restart, ESC menu, normal kick, charged kick and SUPER.

## Next Gate

Fabio/tester should retest the public URL. If approved, record 09R as the approved public baseline; if rejected or if any regression is found, keep 09Q as the approved fallback and open a focused hotfix/rollback decision.
