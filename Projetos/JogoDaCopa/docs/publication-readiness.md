# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+7995b06c` is published publicly on Cloudflare Pages. Track 09I is the current public baseline after passing automated remote menu, first-minute, 5-minute stability and night luma gates and human retest. Track 09J was attempted on 2026-06-19, passed package/menu/first-minute gates, failed the 5-minute remote heap gate twice, and production was restored to the approved 09I baseline.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 09I Restored - 2026-06-19

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Current production deployment URL after 09J rollback: `https://0bed6091.copa-arena-futebol.pages.dev`.
- Original Track 09I deployment URL: `https://76b6f219.copa-arena-futebol.pages.dev`.
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
- Rollback publication evidence: `docs/playtest-reports/track-09j-data/09j-rollback-to-09i-publication-report-7995b06c.json`.
- Rollback stable URL confirmation: `docs/playtest-reports/track-09j-data/09j-rollback-remote-menu-7995b06c.json`.
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

- Track 09I is published, automated remote gates are green and human retest was approved before Track 09J.
- Track 09J is locally validated and merged locally, but its 2026-06-19 publication attempt failed the remote JS/WASM heap gate twice and was rolled back to 09I.
- Web heap margin is green but tight on 09I (`+9.30%` against `<10%`) and red on 09J (`+15.22%` to `+15.96%`); keep the 5-minute stability gate mandatory for every release and treat near-threshold attempts as audit signals.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
