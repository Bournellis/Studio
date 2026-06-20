# Track 10A - Publication Report

- Date: 2026-06-20
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Deployment URL: `https://7a022fe8.copa-arena-futebol.pages.dev`
- Release: `Super Campeao v1.2.1+fc3c72bb`
- Release root: `web/v1-copa-arena-futebol-20260620-fc3c72bb`
- Status: automated remote gates PASS, human retest approved

## Scope

Published Track 10A, a HUD-only decomposition that moves pause menu construction, tabs, restart confirmation and pause settings synchronization from `football_hud.gd` into `football_hud_pause_menu_controller.gd`.

No gameplay, camera, physics, movement, bot, ball, scoring, SUPER, field builder, assets or tuning changed.

## Package

- Publication script: `tools/publish_web.ps1`
- Publish command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-fc3c72bb -VisibleVersion v1.2.1 -EvidenceSubdir track-10a-data -EvidencePrefix 10a -DeployMessage "Track 10A HUD pause menu decomposition" -ConfirmRemoteMutation`
- Raw `index.pck`: `28011764` bytes.
- Raw `index.wasm`: `37695054` bytes.
- Packaged `index.pck` Brotli: `20838016` bytes.
- Packaged `index.wasm` Brotli: `6608968` bytes.
- Pages zip: `27638497` bytes.

## Gates

- Local validation: PASS, `107/107` tests, `1835` asserts, `62` source files checked.
- Local Chrome Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`, `firstMinuteHitches=0`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, release root matched, `event.visible_match_start` observed, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.34%`, peak `+13.88%`, `wasmSampleCount=0`, counters/caches stable, worst 5s FPS window `129.8`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Local reduction report: `docs/playtest-reports/track-10a-hud-pause-menu-decomposition.md`
- Publication: `docs/playtest-reports/track-10a-data/10a-publication-report-fc3c72bb.json`
- Remote menu: `docs/playtest-reports/track-10a-data/10a-remote-menu-fc3c72bb.json` and `docs/playtest-reports/track-10a-data/10a-remote-menu-fc3c72bb.png`
- Remote first minute: `docs/playtest-reports/track-10a-data/10a-remote-first-minute-fc3c72bb.json` and `docs/playtest-reports/track-10a-data/10a-remote-first-minute-fc3c72bb.png`
- Remote stability: `docs/playtest-reports/track-10a-data/10a-remote-stability-5min-fc3c72bb.json` and `docs/playtest-reports/track-10a-data/10a-remote-stability-5min-fc3c72bb.png`
- Remote luma: `docs/playtest-reports/track-10a-data/10a-remote-night-luma-gate-fc3c72bb.json`

## Follow-Up

Fabio/tester human retest approved the public URL on 2026-06-20. Track 10A is the current human-approved public baseline, and Track 09S remains the latest approved fallback behind it.
