# Done: JogoDaCopa Publish Track 09P

- Data: `2026-06-19`
- Agente: `Codex`
- Branch: `codex/jogodacopa/publish-track09p`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09p`
- Objetivo: publicar a Track 09P Session UI Controller V1 na Cloudflare Pages para reteste humano.
- Commit candidato: `8863c5b9`
- Release root publicado: `web/v1-copa-arena-futebol-20260619-8863c5b9`
- Versao visivel: `Super Campeao v1.2.1+8863c5b9`

## Escopo

- Revalidar localmente a 09P ja mergeada na `main`.
- Gerar pacote Web e publicar em `copa-arena-futebol`.
- Rodar gates remotos completos: menu, primeiro minuto, estabilidade 5min com heap e gate de luma.
- Registrar evidencias, release history, readiness, current status e coordenacao.

## Fora de escopo

- `git push`, `git fetch`, `git pull` ou login GitHub.
- Nova reducao de `FootballRoot`.
- Mudanca de gameplay, tuning, bot, fisica, scoring, HUD, assets ou input.

## Resultado

- Import headless editor: PASS.
- `tools/validate.gd`: PASS, `104/104` testes, `1826` asserts, `59` fontes.
- Web export/package: PASS.
- Web gzip transfer: PASS, `30.60 MiB / 50.00 MiB`.
- `node --check tools/track04f_chrome_probe.mjs`: PASS.
- Package: PASS, evidencia `Projetos/JogoDaCopa/docs/playtest-reports/track-09p-data/09p-package-artifacts-8863c5b9.json`.
- FullPublish Cloudflare Pages: PASS, preview `https://5a1325e4.copa-arena-futebol.pages.dev`, URL estavel `https://copa-arena-futebol.pages.dev/`.
- Menu remoto: PASS, `menu.ready.end`, release root conferiu, page errors `0`, console errors `0`.
- Primeiro minuto remoto: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, console errors `0`.
- Estabilidade remota 5min: PASS, `js_heap_growth +2.15%`, pico `+7.18%`, `total_js_heap_growth -0.37%`, `wasmSampleCount=0`.
- Luma remota: PASS, `6.525 < 90`.
- Decisao: sem rollback; Track 09P publicada com gates automaticos PASS e reteste humano pendente.
- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-09p-publication.md`.
- Evidencias: `Projetos/JogoDaCopa/docs/playtest-reports/track-09p-data/`.

## Handoff final

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
