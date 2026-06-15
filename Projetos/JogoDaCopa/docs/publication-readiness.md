# JogoDaCopa Publication Readiness

Current state: `Super Campeao v1.2.1+ff9cb389` is published publicly on Cloudflare Pages. The technical gates for Track 09A passed; the next gate is human retest by Fabio + external tester.

## Product Identity

- Product/module name: `Super Campeao`.
- Project/repository name: `JogoDaCopa`.
- Cloudflare Pages project name: `copa-arena-futebol` (legacy project slug preserved for stable URL continuity).
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/super_campeao_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Current Web Publication - Track 09A - 2026-06-15

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://17ea99ce.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260615-ff9cb389`.
- Visible footer: `Super Campeao v1.2.1+ff9cb389`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260615-ff9cb389 -VisibleVersion v1.2.1 -EvidenceSubdir track-09a-data -EvidencePrefix 09a -DeployMessage "JogoDaCopa Track 09A Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260615-ff9cb389" -ConfirmRemoteMutation -SkipExport`.
- Publication evidence: `docs/playtest-reports/track-09a-data/09a-publication-report-ff9cb389.json`.
- Remote menu evidence: `docs/playtest-reports/track-09a-data/09a-remote-menu-ff9cb389.json` and `docs/playtest-reports/track-09a-data/09a-remote-menu-ff9cb389.png`.
- Remote first-minute evidence: `docs/playtest-reports/track-09a-data/09a-remote-first-minute-ff9cb389.json` and `docs/playtest-reports/track-09a-data/09a-remote-first-minute-ff9cb389.png`.
- Remote 5-minute stability evidence: `docs/playtest-reports/track-09a-data/09a-remote-stability-5min-ff9cb389.json` and `docs/playtest-reports/track-09a-data/09a-remote-stability-5min-ff9cb389.png`.
- Remote night luma evidence: `docs/playtest-reports/track-09a-data/09a-remote-night-luma-gate-ff9cb389.json`.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Track 09A artifact sizes:
  - raw `index.pck`: `27959108` bytes
  - raw `index.wasm`: `37695054` bytes
  - packaged `index.pck`: `20799753` bytes, SHA256 `f4767cfa4629e94cbe545323e983b226304d7ebbd89c3be7146715a56f50cd2f`
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - Pages zip: `27600157` bytes, SHA256 `9a92105cbfb808e9bd3322a986a2f16719b74bd5d8f395841eefe9ce66507f8e`

## Validation

- `tools/validate.gd`: PASS, 104 tests, 1825 asserts.
- Web export: PASS, single-threaded `GODOT_THREADS_ENABLED=false`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote first minute: PASS, `firstMinuteHitches=0`, page errors `0`, runtime console errors `0`.
- Remote stability 5 min: PASS, heap retained `+8.37%` under the `<10%` gate, Godot object/node counters and caches stable, worst 5s window `116.8 FPS`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Known Limitations

- Human retest is still pending for the public `Super Campeao v1.2.1+ff9cb389` URL.
- Web heap margin is green but remains guarded by the 5-minute stability gate for every release.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Notes

- The original Web Publication V1 details from 2026-06-12 are preserved in `release-history.md`.
- Windows debug export remains a smoke target, but the current public release surface is Web.
