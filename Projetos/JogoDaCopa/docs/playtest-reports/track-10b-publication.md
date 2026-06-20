# Track 10B - Publication Attempt

- Date: 2026-06-20
- Public URL: `https://copa-arena-futebol.pages.dev/`
- Candidate deployment URL: `https://35b5b340.copa-arena-futebol.pages.dev`
- Rollback deployment URL: `https://f375997e.copa-arena-futebol.pages.dev`
- Candidate release: `Super Campeao v1.2.1+317999b0`
- Candidate release root: `web/v1-copa-arena-futebol-20260620-317999b0`
- Restored release root: `web/v1-copa-arena-futebol-20260620-fc3c72bb`
- Status: blocked by remote 5-minute heap gate; production rolled back to Track 10A

## Scope

Attempted to publish Track 10B, the Web goal-feel reintroduction. The candidate restores default Web `goal` feedback through a lightweight path: three pooled visual markers plus the short `goal_jingle` after browser audio activation.

The heavy Web `crowd_goal`, particle burst and dynamic light package remains disabled. PC/Windows goal feedback remains unchanged.

## Package

- Publication script: `tools/publish_web.ps1`.
- Candidate publish command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-317999b0 -VisibleVersion v1.2.1 -EvidenceSubdir track-10b-data -EvidencePrefix 10b -DeployMessage "Track 10B Web goal feel reintroduction" -ConfirmRemoteMutation`.
- Rollback command: `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260620-fc3c72bb -VisibleVersion v1.2.1 -EvidenceSubdir track-10b-data -EvidencePrefix 10b-rollback-to-10a -DeployMessage "Rollback to Track 10A after Track 10B remote heap gate failure" -ConfirmRemoteMutation`.
- Candidate raw `index.pck`: `28012756` bytes.
- Candidate raw `index.wasm`: `37695054` bytes.
- Candidate packaged `index.pck` Brotli: `20836813` bytes.
- Candidate packaged `index.wasm` Brotli: `6608968` bytes.
- Candidate Pages zip: `27637264` bytes.

## Gates

- Local validation before publication: PASS, `108/108` tests, `1838` asserts, `62` source files checked.
- Local Web export/gzip: PASS, `30.62 MiB / 50.00 MiB`.
- Local Chrome Web smoke: PASS, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`.
- Local Chrome Web audio-unlock smoke: PASS, `goal_jingle` loaded in `0.6ms` and played.
- Local Chrome 5min stability: PASS, `firstMinuteHitches=0`, active-match goal windows `hitchCount=0`, `js_heap_growth -8.36%`, worst 5s FPS `121`.
- Remote menu: PASS, release root matched, `menu.ready.end` observed, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute: PASS, release root matched, `event.visible_match_start` observed, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min: FAIL only on `js_heap_growth +13.85%` against the `<10%` gate; peak `+17.71%`, `wasmSampleCount=0`.
- Remote stability non-heap checks: PASS, Godot counters/caches stable, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`, worst 5s FPS `117.2`.
- Remote night luma: not run because the stability gate blocked the candidate.
- Rollback confirmation: PASS, stable URL served `web/v1-copa-arena-futebol-20260620-fc3c72bb`, `menu.ready.end`, `pageErrors=0`, `consoleErrorCount=0`.

## Evidence

- Candidate publication: `docs/playtest-reports/track-10b-data/10b-publication-report-317999b0.json`.
- Remote menu: `docs/playtest-reports/track-10b-data/10b-remote-menu-317999b0.json` and `docs/playtest-reports/track-10b-data/10b-remote-menu-317999b0.png`.
- Remote first minute: `docs/playtest-reports/track-10b-data/10b-remote-first-minute-317999b0.json` and `docs/playtest-reports/track-10b-data/10b-remote-first-minute-317999b0.png`.
- Remote stability: `docs/playtest-reports/track-10b-data/10b-remote-stability-5min-317999b0.json` and `docs/playtest-reports/track-10b-data/10b-remote-stability-5min-317999b0.png`.
- Rollback publication: `docs/playtest-reports/track-10b-data/10b-rollback-to-10a-publication-report-fc3c72bb.json`.
- Rollback confirmation: `docs/playtest-reports/track-10b-data/10b-rollback-confirm-10a-fc3c72bb.json` and `docs/playtest-reports/track-10b-data/10b-rollback-confirm-10a-fc3c72bb.png`.

## Interpretation

Track 10B behaved correctly in local and short remote gates, but the remote 5-minute heap signal regressed above the release threshold. The candidate is blocked, and Track 10A remains the public human-approved baseline.

The next technical decision should be either a focused 10B heap investigation/hotfix or an explicit product decision to discard the Web goal-feel reintroduction before resuming structural reduction.
