# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+a75cfe57` is published publicly on Cloudflare Pages and approved by Fabio. Track 09G was published as a candidate, passed remote menu and first-minute gates, failed the remote 5-minute stability gate twice on JS/WASM heap growth, and was rolled back to this 09F baseline. Track 09H is local validated as a heap-margin hotfix, but has not been published/retested remotely yet.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 09F - 2026-06-15

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://e3c82abc.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260615-a75cfe57`.
- Visible footer: `Super Campeao v1.2.1+a75cfe57`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260615-a75cfe57 -VisibleVersion v1.2.1 -EvidenceSubdir track-09f-data -EvidencePrefix 09f -DeployMessage "JogoDaCopa Track 09F Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260615-a75cfe57" -ConfirmRemoteMutation -SkipExport`.
- Publication evidence: `docs/playtest-reports/track-09f-data/09f-publication-report-a75cfe57.json`.
- Remote menu evidence: `docs/playtest-reports/track-09f-data/09f-remote-menu-a75cfe57.json` and `docs/playtest-reports/track-09f-data/09f-remote-menu-a75cfe57.png`.
- Remote first-minute evidence: `docs/playtest-reports/track-09f-data/09f-remote-first-minute-a75cfe57.json` and `docs/playtest-reports/track-09f-data/09f-remote-first-minute-a75cfe57.png`.
- Remote 5-minute stability evidence: `docs/playtest-reports/track-09f-data/09f-remote-stability-5min-rerun-a75cfe57.json` and `docs/playtest-reports/track-09f-data/09f-remote-stability-5min-rerun-a75cfe57.png`.
- Remote night luma evidence: `docs/playtest-reports/track-09f-data/09f-remote-night-luma-gate-a75cfe57.json`.
- Borderline stability attempt retained for audit: `docs/playtest-reports/track-09f-data/09f-remote-stability-5min-a75cfe57.json` failed only `js_wasm_heap_growth` at `+10.26%` retained heap against the `<10%` gate; rerun passed at `+9.88%`.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Track 09F artifact sizes:
  - raw `index.pck`: `27974336` bytes
  - raw `index.wasm`: `37695054` bytes
  - packaged `index.pck`: `20805040` bytes, SHA256 `42d557de82dc1695fa901d84e5848a63b579b7633496a38546d9b8e1dac974c5`
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - Pages zip: `27605187` bytes, SHA256 `b15739786ebfc850d8751d0220c0138c8d40a70af1239e107727752b73c8bd30`

## Validation

- `tools/validate.gd`: PASS, 104 tests, 1826 asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: PASS on rerun, heap retained `+9.88%` under the `<10%` gate, Godot object/node counters and caches stable, worst 5s window `138 FPS`.
- Remote night luma: PASS, `luma_0_255=6.501 < 90`.

## Track 09G Publication Attempt - 2026-06-15

- Candidate attempted: `v1.2.1+d1784ff9`, release root `web/v1-copa-arena-futebol-20260615-d1784ff9`.
- Candidate preview URL: `https://f4685a7e.copa-arena-futebol.pages.dev`.
- Publication evidence: `docs/playtest-reports/track-09g-data/09g-publication-report-d1784ff9.json`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: FAIL twice only on `js_wasm_heap_growth`: first run `+15.42%` retained heap, rerun `+15.35%`; Godot counters/caches and FPS passed, page/runtime console errors stayed `0`.
- Rollback: restored `web/v1-copa-arena-futebol-20260615-a75cfe57`; stable URL confirmation PASS in `docs/playtest-reports/track-09g-data/09g-rollback-confirm-a75cfe57.json`.
- Result: 09G did not remain public; investigate heap before republication or further reduction.

## Track 09H Local Heap Hotfix - 2026-06-15

- Candidate status: local validated only; no Cloudflare Pages mutation executed.
- Change: removed per-frame `Dictionary` allocation from `FootballMatchResolutionController.update_match_clock()`.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Local Chrome short stability 120s: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`, heap final `+0.26%`.
- Local Chrome stability 5min: PASS, heap final `+6.81%` under the `<10%` gate, Godot counters/caches stable, worst 5s window `140.2 FPS`.
- Evidence: `docs/playtest-reports/track-09h-web-heap-hotfix.md` and `docs/playtest-reports/track-09h-data/`.
- Next publication gate: publish/retest 09H candidate with remote menu, first minute, 5-minute stability and night luma before making it public baseline.

## Known Limitations

- Track 09H is local validated but not publishable until its own 5-minute remote stability gate passes.
- Web heap margin is green on rerun but tight; keep the 5-minute stability gate mandatory for every release and treat near-threshold attempts as audit signals.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
