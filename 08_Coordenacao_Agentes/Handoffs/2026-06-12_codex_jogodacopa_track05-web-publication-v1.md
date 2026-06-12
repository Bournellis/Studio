# Handoff: JogoDaCopa - Track 05 Web Publication V1

## Metadata

- from: `Codex`
- to: `Claude`
- date: `2026-06-12`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track05-web-publication-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track05-web-publication-v1`

## Contexto

Fabio autorizou a publicacao remota de `Copa Arena Futebol` em Cloudflare Pages pela decisao `08_Coordenacao_Agentes/Decisoes/2026-06-12_jogodacopa_publicacao-web-cloudflare.md`. Esta track cria o pipeline local seguro, publica o Web V1 publico e pede review antes de qualquer merge local.

## Current State

- Cloudflare Pages project: `copa-arena-futebol`.
- Stable public URL: `https://copa-arena-futebol.pages.dev/`.
- Published preview URL: `https://7a19a00f.copa-arena-futebol.pages.dev`.
- Release root: `web/v1-copa-arena-futebol-20260612-31e23ea3`.
- Remote smoke official: `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05c-remote-menu-smoke.json`.
- Screenshot: `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05c-remote-menu-smoke.png`.
- Status: ready for Claude review; not merged; Kanban card is in `Review`.

## Changed Files

- `08_Coordenacao_Agentes/Kanban/Review/2026-06-12_codex_jogodacopa_track05-web-publication-v1.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-12_codex_jogodacopa_track05-web-publication-v1.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05a-release-artifacts.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05b-package-artifacts.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05c-publication-report.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05c-remote-menu-smoke.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-05-data/05c-remote-menu-smoke.png`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/implementation/tracks/track-05-web-publication/current-status.md`
- `Projetos/JogoDaCopa/tools/publish_web.ps1`
- `Projetos/JogoDaCopa/tools/track04f_chrome_probe.mjs`

## Decisions Made

- `Pages packaging`: `index.pck` and `index.wasm` are Brotli-compressed under their original names and served with `Content-Encoding: br` because raw files exceed the Cloudflare Pages `25 MiB` asset limit.
- `Remote mutation guard`: `FullPublish` requires `-ConfirmRemoteMutation`; `Plan` and `Package` stay local.
- `Review gate`: merge is intentionally pending Claude review.

## Open Questions

- Claude review approval is pending.
- Fabio may still do a human first-access smoke on the stable URL before or after merge.

## Recommended Next Step

Claude should review the branch scope and evidence. If approved, merge locally into `main`, move the Kanban card to `Done`, keep the status snapshots as updated by this branch, and close with `PUSH PENDENTE: Fabio - GitHub Desktop - Push origin`.

## Validation

- `Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path .`: PASS, import cache generated.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"`: PASS.
- `tools/publish_web.ps1 -Mode Package -ReleaseRoot web/v1-copa-arena-futebol-20260612-b0bf6766`: PASS local package and hashes.
- `tools/publish_web.ps1 -Mode FullPublish -ReleaseRoot web/v1-copa-arena-futebol-20260612-31e23ea3 -ConfirmRemoteMutation`: PASS remote deploy.
- Remote Chrome smoke on `https://7a19a00f.copa-arena-futebol.pages.dev/index.html?jdc_perf=1`: PASS, release root matched, `menu.ready.end` observed, page errors `0`, runtime console errors `0`.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`: PASS, 86 tests, 1264 asserts, Web gzip transfer `30.30 MiB / 50.00 MiB`.
