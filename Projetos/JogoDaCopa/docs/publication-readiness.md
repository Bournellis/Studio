# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+7995b06c` is published publicly on Cloudflare Pages. Track 09I is the current public baseline after passing automated remote menu, first-minute, 5-minute stability and night luma gates. Human retest on the public 09I build is pending.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 09I - 2026-06-16

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://76b6f219.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260616-7995b06c`.
- Visible footer: `Super Campeao v1.2.1+7995b06c`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260616-7995b06c -VisibleVersion v1.2.1 -EvidenceSubdir track-09i-data -EvidencePrefix 09i -DeployMessage "JogoDaCopa Track 09I Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260616-7995b06c" -ConfirmRemoteMutation -SkipExport`.
- Publication evidence: `docs/playtest-reports/track-09i-data/09i-publication-report-7995b06c.json`.
- Package evidence: `docs/playtest-reports/track-09i-data/09i-package-artifacts-7995b06c.json`.
- Remote menu evidence: `docs/playtest-reports/track-09i-data/09i-remote-menu-7995b06c.json` and `docs/playtest-reports/track-09i-data/09i-remote-menu-7995b06c.png`.
- Remote first-minute evidence: `docs/playtest-reports/track-09i-data/09i-remote-first-minute-7995b06c.json` and `docs/playtest-reports/track-09i-data/09i-remote-first-minute-7995b06c.png`.
- Remote 5-minute stability evidence: `docs/playtest-reports/track-09i-data/09i-remote-stability-5min-7995b06c.json` and `docs/playtest-reports/track-09i-data/09i-remote-stability-5min-7995b06c.png`.
- Remote night luma evidence: `docs/playtest-reports/track-09i-data/09i-remote-night-luma-gate-7995b06c.json`.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Track 09I artifact sizes:
  - raw `index.pck`: `27986352` bytes
  - raw `index.wasm`: `37695054` bytes
  - packaged `index.pck`: `20818039` bytes, SHA256 `4e83cdf88e7ed0648711329838292075d0dd8953cf3668c46bcf3aa2de61603b`
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - Pages zip: `27618461` bytes, SHA256 `7ddd627c7d94a07443152d881d9877088b7af964071eef2831905bc7e9b6570c`

## Validation

- `tools/validate.gd`: PASS, 104 tests, 1826 asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: PASS, heap retained `43,925,492 -> 48,010,927` bytes (`+9.30%`) under the `<10%` gate, Godot object/node counters and caches stable, worst 5s window `132.6 FPS`.
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

- Candidate status: published as the current public baseline; human retest on the public 09I build is pending.
- Change: published the already validated extraction of player kick, charged/strong kick, SUPER spend/gain helpers and bot kick routing to `football_kick_super_controller.gd`.
- `tools/validate.gd`: PASS, `104` tests, `1826` asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Web gzip gate: PASS, `30.60 MiB / 50.00 MiB`.
- Remote menu: PASS, release root matched, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, heap final `+9.30%`, counters/caches stable, worst 5s window `132.6 FPS`.
- Remote night luma: PASS, `6.525 < 90`.
- Evidence: `docs/playtest-reports/track-09i-publication.md` and `docs/playtest-reports/track-09i-data/`.
- Publication follow-up: Fabio/tester human retest on the public URL is required before opening the next reduction.

## Known Limitations

- Track 09I is published and automated remote gates are green; human retest is pending.
- Web heap margin is green but tight (`+9.30%` against `<10%`); keep the 5-minute stability gate mandatory for every release and treat near-threshold attempts as audit signals.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
