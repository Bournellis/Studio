# JogoDaCopa - Track 09N Publication V1

Data: 2026-06-19
Agente: Codex
Projeto: `Projetos/JogoDaCopa`
Branch alvo local: `main`
Worktree: `D:\Estudio`
Branch fonte: `codex/jogodacopa/track09n-render-settings-controller-v1`

## Objetivo

Publicar a Track 09N como tentativa controlada de Cloudflare Pages, depois do A/B pre-publicacao aprovado contra 09I.

## Escopo

- Fazer merge local da branch 09N na `main`.
- Gerar pacote Web e publicar em `copa-arena-futebol`.
- Rodar gates remotos completos: menu, primeiro minuto, estabilidade 5min com `js_heap_growth` e luma.
- Registrar evidencia e status.

## Fora de escopo

- `git push`, `git fetch`, `git pull` ou login GitHub.
- Nova reducao de `FootballRoot`.
- Mudanca de gameplay, tuning, bot, fisica, scoring ou assets.

## Validacao planejada

- `tools/validate.gd`.
- Web export/package/publication via `tools/publish_web.ps1`.
- Chrome probe remoto menu.
- Chrome probe remoto primeiro minuto.
- Chrome probe remoto estabilidade 5min.
- Gate remoto de luminancia noturna.
- `tools/check_doc_drift.ps1`.
- `git diff --check`.

## Gate de decisao

Se qualquer gate remoto falhar, restaurar producao para a 09I aprovada. Se todos passarem, registrar a 09N como baseline publicado aguardando reteste humano.

## Resultado

- Merge local na `main`: PASS, commit `5c6520ba`.
- `tools/validate.gd`: PASS, `104/104` testes, `1826` asserts, `58` fontes.
- Package/export Web: PASS, release root `web/v1-copa-arena-futebol-20260619-5c6520ba`, Web gzip `30.60 MiB / 50.00 MiB`.
- FullPublish Cloudflare Pages: PASS, preview `https://97957745.copa-arena-futebol.pages.dev`, URL estavel `https://copa-arena-futebol.pages.dev/`.
- Menu remoto: PASS, `menu.ready.end`, release root conferiu, page errors `0`, console errors `0`.
- Primeiro minuto remoto: PASS, `event.visible_match_start`, `firstMinuteHitches=0`, page errors `0`, console errors `0`.
- Estabilidade remota 5min: PASS, `js_heap_growth +0.41%`, pico `+6.05%`, `wasmSampleCount=0`.
- Luma remota: PASS, `6.525 < 90`.
- Decisao: sem rollback; Track 09N publicada com gates automaticos PASS e aguardando reteste humano.
- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-publication.md`.
- Evidencias: `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-data/`.

## Handoff final

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
