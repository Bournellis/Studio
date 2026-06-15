# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+6ef3074c` is published publicly on Cloudflare Pages. The technical gates for Track 08A passed; the next gate is human retest by Fabio + external tester.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 08A - 2026-06-14

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://3ad7e578.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260614-6ef3074c`.
- Visible footer: `Super Campeao v1.2.1+6ef3074c`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260614-6ef3074c -ConfirmRemoteMutation`.
- Publication evidence: `docs/playtest-reports/track-08a-data/08a-publication-report-6ef3074c.json`.
- Remote menu evidence: `docs/playtest-reports/track-08a-data/08a-remote-menu-6ef3074c.json` and `docs/playtest-reports/track-08a-data/08a-remote-menu-6ef3074c.png`.
- Remote first-minute evidence: `docs/playtest-reports/track-08a-data/08a-remote-first-minute-6ef3074c.json`.
- Remote 5-minute stability evidence: `docs/playtest-reports/track-08a-data/08a-remote-stability-5min-6ef3074c.json`.
- Remote night luma evidence: `docs/playtest-reports/track-08a-data/08a-remote-night-luma-gate-6ef3074c.json`.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Track 08A artifact sizes:
  - raw `index.pck`: `27950088` bytes
  - raw `index.wasm`: `37695054` bytes
  - packaged `index.pck`: `20791212` bytes, SHA256 `6df853bcf3b09c9c7d3bcf1084cd3f5cc0e40a0bd76362aeb113709f238f4c4d`
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - Pages zip: `27591627` bytes, SHA256 `f7f9cf2642dd7eba8d146a59afb092d88ae9d6f0d2341459008221b02f6722ce`

## Validation

- `tools/validate.gd`: PASS, 104 tests, 1825 asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: PASS, heap retained `+7.34%` under the `<10%` gate, Godot object/node counters and caches stable.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Known Limitations

- Human retest is still pending for the public `Super Campeao v1.2.1+6ef3074c` URL.
- Web heap margin is green but remains guarded by the 5-minute stability gate for every release.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
