# Track 09S - Publication Report

- Date: 2026-06-20
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Deployment URL: `https://7744dc3b.copa-arena-futebol.pages.dev`
- Release: `Super Campeao v1.2.1+925f3b9f`
- Release root: `web/v1-copa-arena-futebol-20260620-925f3b9f`
- Status: automated remote gates PASS, human retest approved

## Scope

Published Track 09S, a presentation-only camera hotfix for the residual quick `A/D` tap discomfort reported after Track 09R. The build smooths the visual chase-camera ball-focus weight and focus point while preserving setup/reset snaps and goal-focus punch.

No gameplay collision, physics, movement, bot, ball, scoring, SUPER, HUD, assets or match tuning changed.

## Package

- Publication script: `tools/publish_web.ps1`
- Package command: `tools/publish_web.ps1 -Mode Package -ReleaseRoot web/v1-copa-arena-futebol-20260620-925f3b9f -VisibleVersion v1.2.1 -EvidenceSubdir track-09s-data -EvidencePrefix 09s`
- Publish command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-925f3b9f -VisibleVersion v1.2.1 -EvidenceSubdir track-09s-data -EvidencePrefix 09s -DeployMessage "JogoDaCopa Track 09S Super Campeao v1.2.1 web/v1-copa-arena-futebol-20260620-925f3b9f" -ConfirmRemoteMutation -SkipExport`
- Raw `index.pck`: `27999584` bytes.
- Raw `index.wasm`: `37695054` bytes.
- Packaged `index.pck` Brotli: `20826188` bytes.
- Packaged `index.wasm` Brotli: `6608968` bytes.
- Pages zip: `27626664` bytes.

## Gates

- Local validation: PASS, `107/107` tests, `1835` asserts, `60` source files checked.
- Local Chrome Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `stabilityPassed=true`, `firstMinuteHitches=0`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, release root matched, `event.visible_match_start` observed, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth +8.63%`, peak `+13.66%`, `wasmSampleCount=0`, counters/caches stable, worst 5s FPS window `136.6`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.

## Evidence

- Package: `docs/playtest-reports/track-09s-data/09s-package-artifacts-925f3b9f.json`
- Publication: `docs/playtest-reports/track-09s-data/09s-publication-report-925f3b9f.json`
- Remote menu: `docs/playtest-reports/track-09s-data/09s-remote-menu-925f3b9f.json` and `docs/playtest-reports/track-09s-data/09s-remote-menu-925f3b9f.png`
- Remote first minute: `docs/playtest-reports/track-09s-data/09s-remote-first-minute-925f3b9f.json` and `docs/playtest-reports/track-09s-data/09s-remote-first-minute-925f3b9f.png`
- Remote stability: `docs/playtest-reports/track-09s-data/09s-remote-stability-5min-925f3b9f.json` and `docs/playtest-reports/track-09s-data/09s-remote-stability-5min-925f3b9f.png`
- Remote luma: `docs/playtest-reports/track-09s-data/09s-remote-night-luma-gate-925f3b9f.json`

## Follow-Up

Fabio/tester approved the public URL on 2026-06-20 after testing quick `A/D` taps and normal movement. Track 09S is the current human-approved public baseline.
