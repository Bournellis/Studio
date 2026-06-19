# Track 09K Web Heap Hotfix V1

- Date: `2026-06-19`
- Product: `Super Campeao`
- Candidate version: `v1.2.1+70a8ccd5`
- Candidate release root: `web/v1-copa-arena-futebol-20260619-70a8ccd5`
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Candidate preview URL: `https://385ff47e.copa-arena-futebol.pages.dev`
- Status: `REMOTE_STABILITY_HEAP_FAIL_ROLLBACK_TO_09I`
- Restored public baseline: `v1.2.1+7995b06c`, `web/v1-copa-arena-futebol-20260616-7995b06c`

## Scope

Track 09K investigated the remote JS/WASM heap failure introduced after the Track 09J ball-contact extraction.

The candidate removed hot `Dictionary` allocations from player possession/contact math, trimmed frame dispatch, then moved the hottest per-physics-frame ball-contact path back into `FootballRoot` while keeping the extracted controller for lower-frequency collision/audio and arcade helper work.

No gameplay, input, bot decision, physics tuning, scoring, HUD, asset or branding change was intended.

## Code Result

- `FootballRoot`: `832 -> 899` lines compared with 09J, still below the approved 09I baseline of `943`.
- `football_ball_contact_controller.gd`: `71` lines after keeping only lower-frequency helper responsibilities.
- Candidate implementation commit: `70a8ccd5`.

## Local Gates

- `tools/validate.gd`: PASS, `104/104` tests, `1826` asserts, `57` source files checked.
- Web export release: PASS.
- Web gzip transfer gate: PASS, `30.60 MiB / 50.00 MiB`.
- Local Chrome 5min 09K candidate: FAIL on local JS/WASM heap, `44,798,709 -> 50,234,431` bytes (`+12.13%`), with Godot counters/caches and FPS PASS.
- Local Chrome 5min approved 09I baseline, same machine/params: FAIL on local JS/WASM heap, `44,303,605 -> 50,147,862` bytes (`+13.19%`), with Godot counters/caches and FPS PASS.

Interpretation: the local 5min heap probe is useful for comparison, but not release-equivalent by itself because the approved 09I production baseline also fails locally while it previously passed the remote gate.

## Remote Gates

- Menu gate: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- First-minute gate: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Stability 5min gate: FAIL, retained JS/WASM heap `43,753,441 -> 50,033,782` bytes (`+14.35%`, limit `<10%`), peak `51,905,100` bytes (`+18.63%`).
- Godot counters/caches: PASS, stable object/node counts and material/mesh caches.
- Worst 5s FPS window: PASS, `141.2 FPS`.
- Night luma gate: not run because the stability gate blocked the release.

Compared with 09J remote failures (`+15.96%` and `+15.22%`), 09K improved the signal slightly but did not restore the required heap margin.

## Rollback

After the remote stability failure, the approved 09I package was redeployed as production.

Rollback result:

- Production deployment URL: `https://c7bd9024.copa-arena-futebol.pages.dev`.
- Stable URL confirmation: PASS, `https://copa-arena-futebol.pages.dev/` served `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Menu stage after rollback: PASS, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.

## Evidence

- Candidate package: `track-09k-data/09k-package-artifacts-70a8ccd5.json`.
- Candidate publication: `track-09k-data/09k-publication-report-70a8ccd5.json`.
- Candidate menu: `track-09k-data/09k-remote-menu-70a8ccd5.json` and `track-09k-data/09k-remote-menu-70a8ccd5.png`.
- Candidate first minute: `track-09k-data/09k-remote-first-minute-70a8ccd5.json` and `track-09k-data/09k-remote-first-minute-70a8ccd5.png`.
- Candidate stability fail: `track-09k-data/09k-remote-stability-5min-70a8ccd5.json` and `track-09k-data/09k-remote-stability-5min-70a8ccd5.png`.
- Local 09K comparison: `track-09k-data/09k-local-stability-5min-builds-web-70a8ccd5.json`.
- Local 09I comparison: `track-09k-data/09k-local-stability-5min-09i-baseline-7995b06c.json`.
- Rollback publication: `track-09k-data/09k-rollback-to-09i-publication-report-7995b06c.json`.
- Rollback confirmation: `track-09k-data/09k-rollback-remote-menu-7995b06c.json` and `track-09k-data/09k-rollback-remote-menu-7995b06c.png`.

## Interpretation

The failure is still browser/WASM-retained heap, not a scene-node/material/mesh leak visible through the current Godot counters. The focused 09K hotfix did not recover enough margin, so further `FootballRoot` reduction should stay paused until the heap source is instrumented more directly.

## Next Gate

Open Track 09L Web Heap Instrumentation V1 before another reduction or publication attempt:

1. Run controlled remote A/B probes against 09I and the 09K candidate shape to quantify variance.
2. Add optional, disabled-by-default allocation/heap diagnostics for the Web perf route.
3. Inspect CDP heap allocation data, not only total JS/WASM heap growth.
4. Check whether the `jdc_perf` probe path contributes retained browser heap.
5. Require two consecutive remote stability passes before promoting any new Web baseline.
