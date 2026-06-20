# Track 10C - Publication

- Date: 2026-06-20
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Candidate deployment URL: `https://c50815e2.copa-arena-futebol.pages.dev`
- Candidate release: `Super Campeao v1.2.1+39054f31`
- Candidate release root: `web/v1-copa-arena-futebol-20260620-39054f31`
- Status: published; remote automated gates passed; human retest pending.

## Scope

Published Track 10C, the heap-safe Web goal feedback reintroduction.

The public Web default now restores goal visual feedback with the lightweight three-marker pooled sphere path, while keeping goal audio out of the default path. `goal_audio` and legacy `goal` remain explicit diagnostic opt-ins via `jdc_web_feedback`; PC/Windows keeps the full goal package.

## Package

- Publication script: `tools/publish_web.ps1`.
- Candidate publish command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-39054f31 -VisibleVersion v1.2.1 -EvidenceSubdir track-10c-data -EvidencePrefix 10c -DeployMessage "Track 10C Web goal feedback heap-safe" -ConfirmRemoteMutation`.
- Candidate raw `index.pck`: `28013492` bytes.
- Candidate raw `index.wasm`: `37695054` bytes.
- Candidate packaged `index.pck` Brotli: `20838619` bytes.
- Candidate packaged `index.wasm` Brotli: `6608968` bytes.
- Candidate Pages zip: `27639070` bytes.

## Gates

- Local validation before publication: PASS, `108/108` tests, `1840` asserts, `62` source files checked.
- Local Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- Local Chrome Web visual-only smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Local Chrome 5min stability: PASS, `js_heap_growth -8.10%`, peak `+1.10%`, worst 5s FPS `137.4`, goal mode `visual=true audio=false`.
- Remote menu: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, release root matched, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth -0.59%`, peak `+2.31%`, `wasmSampleCount=0`, Godot counters/caches stable, worst 5s FPS `142.2`.
- Remote goal mode: PASS, observed `feedback.web_goal_mode visual=true audio=false`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.
- Stable URL confirmation: PASS, `https://copa-arena-futebol.pages.dev/` served `web/v1-copa-arena-futebol-20260620-39054f31` with `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.

## Evidence

- Publication: `docs/playtest-reports/track-10c-data/10c-publication-report-39054f31.json`.
- Remote menu: `docs/playtest-reports/track-10c-data/10c-remote-menu-39054f31.json` and `docs/playtest-reports/track-10c-data/10c-remote-menu-39054f31.png`.
- Remote first minute: `docs/playtest-reports/track-10c-data/10c-remote-first-minute-39054f31.json` and `docs/playtest-reports/track-10c-data/10c-remote-first-minute-39054f31.png`.
- Remote stability: `docs/playtest-reports/track-10c-data/10c-remote-stability-5min-39054f31.json` and `docs/playtest-reports/track-10c-data/10c-remote-stability-5min-39054f31.png`.
- Remote luma: `docs/playtest-reports/track-10c-data/10c-remote-night-luma-gate-39054f31.json`.
- Stable URL confirmation: `docs/playtest-reports/track-10c-data/10c-stable-confirm-39054f31.json` and `docs/playtest-reports/track-10c-data/10c-stable-confirm-39054f31.png`.

## Interpretation

Track 10C fixed the risk profile that blocked 10B: the public Web default keeps visual goal punch while avoiding default goal audio. The remote heap gate now has wide margin, with negative retained JS heap growth over the 5-minute window and no runtime errors.

Human retest is still required before marking 10C as an approved baseline. Until then, Track 10A remains the latest human-approved fallback.
