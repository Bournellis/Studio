# JogoDaCopa Publication Readiness

Current state: `Copa Arena Futebol` Web Publication V1 is published publicly on Cloudflare Pages and is awaiting Claude review before local merge.

## Product Identity

- Product/module name: `Copa Arena Futebol`.
- Main scene: `res://modes/menu/main_menu.tscn`.
- Icon: `res://assets/branding/copa_arena_icon.svg`.
- Boot splash: `res://assets/branding/copa_arena_splash.png`.
- Windows preset: `Windows Desktop` in `export_presets.cfg`.
- Web preset: `Web` in `export_presets.cfg`, single-threaded.

## Web Publication V1 - 2026-06-12

- Cloudflare Pages project: `copa-arena-futebol`.
- Public stable URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://7a19a00f.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260612-31e23ea3`.
- Publication script: `tools/publish_web.ps1`.
- Publication command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-31e23ea3 -ConfirmRemoteMutation`.
- Publication evidence: `docs/playtest-reports/track-05-data/05c-publication-report.json`.
- Remote smoke evidence: `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.json` and `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.png`.
- No Cloudflare Access gate was observed; the public URL served the Godot app directly.

## Packaging

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the Pages package stores both files Brotli-compressed while preserving their public file names.
- `_headers` serves `index.pck` and `index.wasm` with `Content-Encoding: br`.
- Packaged asset sizes:
  - `index.pck`: `20570491` bytes, SHA256 `e146368591bf34821d23b8c5e0398b0562fad9b84d7958459d1b6c796ae75ec3`
  - `index.wasm`: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`

## Validation

- `tools/validate.gd`: PASS, 86 tests, 1264 asserts.
- Web gzip transfer gate: `30.30 MiB / 50.00 MiB`.
- Remote smoke: release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- Remote smoke frame stats: p50 `6.9ms`, p95 `7.0ms`, p99 `7.1ms`, max `3299.1ms`, hitch count `1`.

## Known Limitations

- A single first-use VFX/audio hitch per session remains known and documented for Track 04F.3.
- Desktop browser is the official Web V1 surface; mobile browser can be observed manually, but is not an official support target in this release.
- Country kits and branding are generic/inspired; no official FIFA, World Cup, federation or club logos are included.
- No multiplayer, backend, analytics, custom domain, itch.io page or signed Windows release is included in this track.

## Legacy Windows Smoke

- 2026-06-10 command: `Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-debug "Windows Desktop" "builds/windows/CopaArenaFutebol.exe"`.
- Result: PASS, exit code `0`.
- Generated files: `CopaArenaFutebol.exe` and `CopaArenaFutebol.console.exe` are generated artifacts ignored by git.
