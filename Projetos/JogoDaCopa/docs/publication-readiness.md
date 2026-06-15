# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+a75cfe57` is published publicly on Cloudflare Pages. The technical gates for the cumulative Track 09F `FootballRoot` reduction rollup passed after a stability rerun; the next gate is human retest by Fabio + external tester.

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

## Known Limitations

- Human retest is still pending for the public `Super Campeao v1.2.1+a75cfe57` URL.
- Web heap margin is green on rerun but tight; keep the 5-minute stability gate mandatory for every release and treat near-threshold attempts as audit signals.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
