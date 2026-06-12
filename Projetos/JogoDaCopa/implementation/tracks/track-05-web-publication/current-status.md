# Track 05 - Web Publication V1

- Last updated: `2026-06-12`
- Status: `IN_PROGRESS`
- Branch/worktree: `codex/jogodacopa/track05-web-publication-v1` / `D:\Estudio-worktrees\JogoDaCopa--codex--track05-web-publication-v1`
- Goal: publish `Copa Arena Futebol` as a public Cloudflare Pages Web build at project `copa-arena-futebol`, with no Cloudflare Access.

## 05A Release Export

- Godot import cache was generated once in the new worktree with `--headless --editor --quit`.
- Web release export passed with `--export-release "Web" "builds/web/index.html"`.
- Exported HTML title: `Copa Arena Futebol`.
- Artifact evidence: `docs/playtest-reports/track-05-data/05a-release-artifacts.json`.
- Raw release artifact sizes/hashes:
  - `index.pck`: `27708956` bytes, SHA256 `4252509c6ff058e0a0a863daa9e348df84e320b4887f6eac91aad99d81a987fe`
  - `index.wasm`: `37695054` bytes, SHA256 `cca8bc7c462d348aaa3f318aecf3281d99bf219e182256412711b24f0d086d80`
  - `copa-arena-futebol-web-release.zip`: `31769419` bytes, SHA256 `5f5923a9add22105036067dd043fee4804d371134ac44f9966f5826fbc4d4bf0`

## Cloudflare Pages Packaging Constraint

- Cloudflare Pages direct upload has a `25 MiB` per-file asset limit.
- Raw `index.pck` and `index.wasm` exceed that limit, so the publication package must store those two files pre-compressed with Brotli while preserving the public file names and serving them with `Content-Encoding: br`.
- Local compression check:
  - `index.pck`: `27708956 -> 20569022` bytes
  - `index.wasm`: `37695054 -> 6608968` bytes

## 05B Publish Script

- Added `tools/publish_web.ps1`.
- `Mode Plan` default generates a local plan only and does not export, package, deploy or verify remote state.
- `Mode Package` requires a versioned `ReleaseRoot`, exports Web release locally, writes a Cloudflare Pages folder and zip, stores `index.pck`/`index.wasm` Brotli-compressed under their original names, and verifies every uploaded file is `< 25 MiB`.
- `Mode FullPublish` requires `-ConfirmRemoteMutation`, creates the Pages project if missing, treats an existing Pages project as idempotent, and deploys with Wrangler using branch `main`.
- Package HTML injects `window.JDC_WEB_RELEASE` so remote smoke can assert the deployed `releaseRoot`.
- Local package evidence: `docs/playtest-reports/track-05-data/05b-package-artifacts.json`.
- Package root tested: `web/v1-copa-arena-futebol-20260612-b0bf6766`.
- Pages package artifacts:
  - `index.html`: `5701` bytes, SHA256 `da266ff2a5a0c79725e5ee07edfe46692e63d677db831bbf43da19547afa6f5f`
  - `index.pck` Brotli: `20570491` bytes, SHA256 `e146368591bf34821d23b8c5e0398b0562fad9b84d7958459d1b6c796ae75ec3`
  - `index.wasm` Brotli: `6608968` bytes, SHA256 `6903dbdda02519655d94ef7fc0eb18e31336ac11b0f93a1abe696a654d2cf30f`
  - `copa-arena-futebol-pages.zip`: `27311751` bytes, SHA256 `20fe5d10c835de312cb6e97b26865342cbbca693e5575a01705c186e89e64732`

## 05C Cloudflare Pages Publication

- Remote mutation confirmed with `-ConfirmRemoteMutation`; Wrangler auth was already valid for `bournellis@gmail.com`.
- Cloudflare Pages project: `copa-arena-futebol`, public, no Cloudflare Access detected in smoke.
- Published release root: `web/v1-copa-arena-futebol-20260612-31e23ea3`.
- Preview URL: `https://7a19a00f.copa-arena-futebol.pages.dev`.
- Stable URL: `https://copa-arena-futebol.pages.dev/`.
- Publication evidence: `docs/playtest-reports/track-05-data/05c-publication-report.json`.
- Remote smoke evidence: `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.json` and `docs/playtest-reports/track-05-data/05c-remote-menu-smoke.png`.
- Remote smoke passed for `menu.ready.end`; release root matched; page errors `0`; runtime console errors `0`.
- Smoke frame stats: `3928` frames, p50 `6.9ms`, p95 `7.0ms`, p99 `7.1ms`, max `3299.1ms`, hitch count `1`.
- Console warnings were expected Godot `push_warning` compatibility notices for Web render/audio/save constraints.

## Remaining Work

- 05D: update release history/readiness/status docs and handoff to Claude before merge.
