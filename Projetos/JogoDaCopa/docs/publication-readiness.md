# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+4a323fab` is published publicly on Cloudflare Pages. Track 09H is the current public baseline after passing remote menu, first-minute, 5-minute stability and night luma gates. Human retest by Fabio/tester is pending before the next reduction.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 09H - 2026-06-15

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://7f8dcde1.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260615-4a323fab`.
- Visible footer: `Super Campeao v1.2.1+4a323fab`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260615-4a323fab -VisibleVersion v1.2.1 -EvidenceSubdir track-09h-data -EvidencePrefix 09h -DeployMessage "JogoDaCopa Track 09H Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260615-4a323fab" -ConfirmRemoteMutation`.
- Publication evidence: `docs/playtest-reports/track-09h-data/09h-publication-report-4a323fab.json`.
- Remote menu evidence: `docs/playtest-reports/track-09h-data/09h-remote-menu-4a323fab.json` and `docs/playtest-reports/track-09h-data/09h-remote-menu-4a323fab.png`.
- Remote first-minute evidence: `docs/playtest-reports/track-09h-data/09h-remote-first-minute-4a323fab.json` and `docs/playtest-reports/track-09h-data/09h-remote-first-minute-4a323fab.png`.
- Remote 5-minute stability evidence: `docs/playtest-reports/track-09h-data/09h-remote-stability-5min-4a323fab.json` and `docs/playtest-reports/track-09h-data/09h-remote-stability-5min-4a323fab.png`.
- Remote night luma evidence: `docs/playtest-reports/track-09h-data/09h-remote-night-luma-gate-4a323fab.json`.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Track 09H artifact sizes:
  - raw `index.pck`: `27983140` bytes
  - raw `index.wasm`: `37695054` bytes
  - packaged `index.pck`: `20826996` bytes, SHA256 `68d8c7f838ea40d4208f2801baa7a50f90d39091c58c955d5c924938613723c4`
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - Pages zip: `27620523` bytes, SHA256 `84a6fd8df3f7c655b976b5cf16cc95ea15b6b3771a43171513d229dffeed9511`

## Validation

- `tools/validate.gd`: PASS, 104 tests, 1826 asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: PASS, heap retained `43,664,158 -> 48,016,205` bytes (`+9.97%`) under the `<10%` gate, Godot object/node counters and caches stable, worst 5s window `129.8 FPS`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

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

- Candidate status: published as the current public baseline; human retest pending.
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
- Next publication gate: human retest on the public URL before resuming reduction.

## Known Limitations

- Track 09H is published and automated remote gates are green; human retest is still pending.
- Web heap margin is green but tight (`+9.97%` against `<10%`); keep the 5-minute stability gate mandatory for every release and treat near-threshold attempts as audit signals.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
