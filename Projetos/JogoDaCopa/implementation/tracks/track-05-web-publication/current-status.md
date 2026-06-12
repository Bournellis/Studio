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

## Remaining Work

- 05B: create `tools/publish_web.ps1` with `Plan`, `Package` and `FullPublish`, including the Brotli Pages package.
- 05C: create/use project `copa-arena-futebol`, deploy with `-ConfirmRemoteMutation`, run remote smoke JSON+screenshot.
- 05D: update release history/readiness/status docs and handoff to Claude before merge.
