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
