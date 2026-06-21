# Track 10D - Publication

- Date: 2026-06-20
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Candidate deployment URL: `https://6b9febae.copa-arena-futebol.pages.dev`
- Candidate release: `Super Campeao v1.2.1+45da58b1`
- Candidate release root: `web/v1-copa-arena-futebol-20260620-45da58b1`
- Status: published; remote automated gates passed; human retest pending.

## Scope

Published Track 10D, the Web goal golden-pop hotfix.

The public Web default now makes the visual goal moment more legible with a larger golden pop and quieter ambience, while keeping default Web goal audio disabled. `goal_audio` and legacy `goal` remain explicit diagnostic opt-ins via `jdc_web_feedback`; PC/Windows keeps the full goal package.

## Package

- Publication script: `tools/publish_web.ps1`.
- Candidate publish command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-45da58b1 -VisibleVersion v1.2.1 -EvidenceSubdir track-10d-data -EvidencePrefix 10d -DeployMessage "Track 10D Web goal golden pop hotfix" -ConfirmRemoteMutation`.
- Candidate raw `index.pck`: `28014420` bytes.
- Candidate raw `index.wasm`: `37695054` bytes.
- Candidate packaged `index.pck` Brotli: `20839510` bytes.
- Candidate packaged `index.wasm` Brotli: `6608968` bytes.
- Candidate Pages zip: `27639968` bytes.

## Gates

- Local validation before publication: PASS, `108/108` tests, `1844` asserts, `62` source files checked.
- Local Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- Local Chrome Web golden-pop smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Local Chrome 5min stability: PASS, `js_heap_growth +9.42%`, peak `+15.85%`, worst 5s FPS `127.6`, goal mode `visual=true audio=false`.
- Remote menu: PASS, release root matched, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, release root matched, `event.visible_match_start`, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: PASS, `js_heap_growth -5.35%`, peak `+0.04%`, `wasmSampleCount=0`, Godot counters/caches stable, worst 5s FPS `139.8`.
- Remote goal mode: PASS, observed `feedback.web_goal_mode visual=true audio=false`.
- Remote night luma: PASS, `luma_0_255=6.525 < 90`.
- Stable URL confirmation: PASS, `https://copa-arena-futebol.pages.dev/` served `web/v1-copa-arena-futebol-20260620-45da58b1` with `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.

## Evidence

- Publication: `docs/playtest-reports/track-10d-data/10d-publication-report-45da58b1.json`.
- Remote menu: `docs/playtest-reports/track-10d-data/10d-remote-menu-45da58b1.json` and `docs/playtest-reports/track-10d-data/10d-remote-menu-45da58b1.png`.
- Remote first minute: `docs/playtest-reports/track-10d-data/10d-remote-first-minute-45da58b1.json` and `docs/playtest-reports/track-10d-data/10d-remote-first-minute-45da58b1.png`.
- Remote stability: `docs/playtest-reports/track-10d-data/10d-remote-stability-5min-45da58b1.json` and `docs/playtest-reports/track-10d-data/10d-remote-stability-5min-45da58b1.png`.
- Remote luma: `docs/playtest-reports/track-10d-data/10d-remote-night-luma-gate-45da58b1.json`.
- Stable URL confirmation: `docs/playtest-reports/track-10d-data/10d-stable-confirm-45da58b1.json` and `docs/playtest-reports/track-10d-data/10d-stable-confirm-45da58b1.png`.

## Interpretation

Track 10D keeps the safe 10C audio posture and spends the goal-feel improvement on visual contrast instead. The local 5-minute heap result was near the `<10%` retained JS heap limit, so the remote 5-minute stability gate was treated as decisive. The remote run passed with negative retained JS heap growth and no runtime errors.

Human retest is still required before marking 10D as an approved baseline. Until then, Track 10A remains the latest human-approved fallback.
