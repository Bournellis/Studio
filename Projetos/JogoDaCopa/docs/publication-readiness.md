# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+fc3c72bb` is published publicly on Cloudflare Pages after automated remote menu, first-minute, 5-minute stability and night luma gates passed. Fabio/tester human retest is pending. Track 09S remains the latest human-approved fallback baseline.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 10A - 2026-06-20

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Current production deployment URL: `https://7a022fe8.copa-arena-futebol.pages.dev`.
- Approved fallback deployment URL: `https://7744dc3b.copa-arena-futebol.pages.dev` (Track 09S).
- Release root: `web/v1-copa-arena-futebol-20260620-fc3c72bb`.
- Visible footer: `Super Campeao v1.2.1+fc3c72bb`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-fc3c72bb -VisibleVersion v1.2.1 -EvidenceSubdir track-10a-data -EvidencePrefix 10a -DeployMessage "Track 10A HUD pause menu decomposition" -ConfirmRemoteMutation`.
- Publication evidence: `docs/playtest-reports/track-10a-data/10a-publication-report-fc3c72bb.json`.
- Remote menu evidence: `docs/playtest-reports/track-10a-data/10a-remote-menu-fc3c72bb.json` and `docs/playtest-reports/track-10a-data/10a-remote-menu-fc3c72bb.png`.
- Remote first-minute evidence: `docs/playtest-reports/track-10a-data/10a-remote-first-minute-fc3c72bb.json` and `docs/playtest-reports/track-10a-data/10a-remote-first-minute-fc3c72bb.png`.
- Remote 5-minute stability evidence: `docs/playtest-reports/track-10a-data/10a-remote-stability-5min-fc3c72bb.json` and `docs/playtest-reports/track-10a-data/10a-remote-stability-5min-fc3c72bb.png`.
- Remote night luma evidence: `docs/playtest-reports/track-10a-data/10a-remote-night-luma-gate-fc3c72bb.json`.
- Human retest: pending.
- Fallback evidence: Track 09S evidence remains in `docs/playtest-reports/track-09s-data/` as the latest human-approved fallback.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Track 10A artifact sizes:
  - raw `index.pck`: `28011764` bytes
  - raw `index.wasm`: `37695054` bytes
  - packaged `index.pck`: `20838016` bytes
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - Pages zip: `27638497` bytes

## Validation

- `tools/validate.gd`: PASS, 107 tests, 1835 asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: PASS, `js_heap_growth +8.34%` under the `<10%` gate, peak `+13.88%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Track 10A HUD Pause Menu Decomposition Publication - 2026-06-20

- Candidate status: public Web candidate with automated remote gates passed; human retest pending.
- Change: published the validated HUD pause menu decomposition into `football_hud_pause_menu_controller.gd`.
- Gameplay impact: HUD construction/refactor only; no gameplay, camera, physics, movement, bot, ball, scoring, SUPER, field builder, assets or tuning changes.
- `tools/validate.gd`: PASS, `107` tests, `1835` asserts, `62` source files checked.
- Web export/package: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web package assets: `index.pck` Brotli `20.84 MiB`, `index.wasm` Brotli `6.61 MiB`, each below the `25.00 MiB` Cloudflare Pages asset limit.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.34%`, peak `+13.88%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-10a-publication.md` and `docs/playtest-reports/track-10a-data/`.
- Publication follow-up: Fabio/tester human retest on the public URL; 09S remains the latest human-approved fallback until 10A is approved.

## Track 09S Camera Strafe Smoothing Hotfix Publication - 2026-06-20

- Candidate status: approved public baseline.
- Change: published the already validated hotfix for residual quick `A/D` chase-camera tremor/pull after 09R.
- Gameplay impact: presentation/camera only; no gameplay collision, physics, movement, scoring, bot, SUPER, HUD, assets or match tuning changes.
- `tools/validate.gd`: PASS, `107` tests, `1835` asserts, `60` source files checked.
- Web export/package: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web package assets: `index.pck` Brotli `20.83 MiB`, `index.wasm` Brotli `6.61 MiB`, each below the `25.00 MiB` Cloudflare Pages asset limit.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.63%`, peak `+13.66%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09s-publication.md` and `docs/playtest-reports/track-09s-data/`.
- Publication follow-up: Fabio/tester human retest approved the public URL on 2026-06-20; 09Q remains the latest approved fallback behind 09S.

## Track 09R Foot And Camera Hotfix Publication - 2026-06-20

- Candidate status: public Web candidate with automated remote gates passed; human retest pending.
- Change: published the already validated hotfix for visible avatar feet entering the field plane and odd chase-camera pull/tilt during lateral A/D strafe.
- Gameplay impact: presentation/camera only; no gameplay collision, physics, scoring, bot, SUPER, HUD, assets or match tuning changes.
- `tools/validate.gd`: PASS, `106` tests, `1831` asserts, `60` source files checked.
- Web export/package: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.61 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.33%`, peak `+13.68%`, `total_js_heap_growth +8.04%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09r-publication.md` and `docs/playtest-reports/track-09r-data/`.
- Publication follow-up: Fabio/tester human retest on the public URL; 09Q remains the latest human-approved fallback until 09R is approved.

## Track 09Q Presentation FX Controller Publication - 2026-06-19

- Candidate status: approved public baseline.
- Change: published the already validated extraction of presentation FX orchestration to `football_presentation_fx_controller.gd`.
- `FootballRoot`: `974 -> 919` lines in the local reduction.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts, `60` source files checked.
- Web export/package: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.41%`, peak `+12.61%`, `total_js_heap_growth +7.42%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09q-publication.md` and `docs/playtest-reports/track-09q-data/`.
- Publication follow-up: Fabio/tester human retest approved the public URL on 2026-06-19; 09P remains the latest fallback baseline behind 09Q.

## Track 09P Session UI Controller Publication - 2026-06-19

- Candidate status: approved public baseline.
- Change: published the already validated extraction of intro/pause/menu session flow, ESC target routing, match start, main-menu return and mouse-capture policy to `football_session_ui_controller.gd`.
- `FootballRoot`: `1051 -> 974` lines in the local reduction.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts, `59` source files checked.
- Web export/package: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +2.15%`, peak `+7.18%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09p-publication.md` and `docs/playtest-reports/track-09p-data/`.
- Publication follow-up: Fabio/tester human retest approved the public URL on 2026-06-19; 09N remains the historical approved fallback baseline behind 09P.

## Track 09N Render Settings Controller Publication - 2026-06-19

- Candidate status: historical approved fallback baseline behind 09P.
- Change: published the already validated extraction of render/settings orchestration to `football_render_settings_controller.gd`.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts.
- Web export/package: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +0.41%`, peak `+6.05%`, `wasmSampleCount=0`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09n-publication.md` and `docs/playtest-reports/track-09n-data/`.
- Publication follow-up: human retest on the public URL was approved; 09I remains the historical approved fallback.

## Track 09J Publication Attempt - 2026-06-19

- Candidate attempted: `v1.2.1+4678fbea`, release root `web/v1-copa-arena-futebol-20260619-4678fbea`.
- Candidate preview URL: `https://ff5e2d51.copa-arena-futebol.pages.dev`.
- Package evidence: `docs/playtest-reports/track-09j-data/09j-package-artifacts-4678fbea.json`.
- Publication evidence: `docs/playtest-reports/track-09j-data/09j-publication-report-4678fbea.json`.
- Local validation before publication: PASS, `104/104` tests, `1826` asserts, `57` source files checked.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `menu.ready.end`, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, release root matched, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: FAIL only on `js_wasm_heap_growth`, retained heap `43,740,045 -> 50,719,101` bytes (`+15.96%`, limit `<10%`), peak `64,046,786` bytes (`+46.43%`).
- Remote stability 5 min rerun: FAIL only on `js_wasm_heap_growth`, retained heap `44,045,553 -> 50,751,097` bytes (`+15.22%`, limit `<10%`), peak `64,104,862` bytes (`+45.54%`).
- Other stability checks: PASS, Godot object/node counters and caches stable, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`, worst 5s FPS windows `136.6` and `119.8`.
- Rollback: Cloudflare refused deletion of the active production deployment, so the approved 09I package was redeployed as production with release root `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Rollback confirmation: PASS, stable URL served `web/v1-copa-arena-futebol-20260616-7995b06c` with `menu.ready.end`, page errors `0`, runtime console errors `0`.
- Result: 09J did not remain the public baseline. Keep the preview URL only for diagnosis; open a focused heap hotfix/investigation before any republication or further `FootballRoot` reduction.

## Track 09G Publication Attempt - 2026-06-15

- Candidate attempted: `v1.2.1+d1784ff9`, release root `web/v1-copa-arena-futebol-20260615-d1784ff9`.
- Candidate preview URL: `https://f4685a7e.copa-arena-futebol.pages.dev`.
- Publication evidence: `docs/playtest-reports/track-09g-data/09g-publication-report-d1784ff9.json`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: FAIL twice only on `js_wasm_heap_growth`: first run `+15.42%` retained heap, rerun `+15.35%`; Godot counters/caches and FPS passed, page/runtime console errors stayed `0`.
- Rollback: restored `web/v1-copa-arena-futebol-20260615-a75cfe57`; stable URL confirmation PASS in `docs/playtest-reports/track-09g-data/09g-rollback-confirm-a75cfe57.json`.
- Result: 09G did not remain public; investigate heap before republication or further reduction.

## Track 09H Web Heap Hotfix - 2026-06-15

- Candidate status: previous public baseline; human retest approved by Fabio/tester before Track 09I.
- Change: removed per-frame `Dictionary` allocation from `FootballMatchResolutionController.update_match_clock()`.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Local Chrome short stability 120s: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`, heap final `+0.26%`.
- Local Chrome stability 5min: PASS, heap final `+6.81%` under the `<10%` gate, Godot counters/caches stable, worst 5s window `140.2 FPS`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, heap final `+9.97%`, counters/caches stable, worst 5s window `129.8 FPS`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09h-web-heap-hotfix.md` and `docs/playtest-reports/track-09h-data/`.
- Publication follow-up: human retest on the public URL was approved before Track 09I; keep the same human gate for the next public release.

## Track 09I Kick Super Controller Publication - 2026-06-16

- Candidate status: published and restored as the current public baseline; human retest approved before Track 09J.
- Change: published the already validated extraction of player kick, charged/strong kick, SUPER spend/gain helpers and bot kick routing to `football_kick_super_controller.gd`.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, heap final `+9.30%`, counters/caches stable, worst 5s window `132.6 FPS`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09i-publication.md` and `docs/playtest-reports/track-09i-data/`.
- Publication follow-up: public 09I remains the approved fallback baseline after the 09J rollback.

## Known Limitations

- Track 09S is published and human-approved.
- Track 09R passed automated gates but was superseded by 09S before human approval because of the residual quick `A/D` camera perception issue.
- Track 09Q is the latest approved fallback baseline behind 09S.
- Track 09P remains the latest fallback baseline behind 09Q.
- Track 09N remains the historical approved fallback baseline behind 09P.
- Track 09I remains the historical approved fallback baseline behind 09N.
- Track 09J is locally validated and merged locally, but its 2026-06-19 publication attempt failed the remote JS/WASM heap gate twice and was rolled back to 09I.
- Web heap margin is green on 09S (`+8.63%` against `<10%`) but close enough to the gate to deserve caution; keep the 5-minute stability gate mandatory for every release and treat near-threshold attempts as audit signals.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
