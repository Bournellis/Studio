# JogoDaCopa - Track 09N Prepublish A/B V1

Data: 2026-06-19
Agente: Codex
Projeto: `Projetos/JogoDaCopa`
Branch: `codex/jogodacopa/track09n-render-settings-controller-v1`
Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track09n-render-settings-controller-v1`
Base local: `1471402e`

## Objetivo

Executar uma comparacao pre-publicacao entre a producao aprovada 09I e a candidata local 09N usando o probe 09M, com foco em `js_heap_growth`, erros de runtime e entrada em partida.

## Escopo

- Rodar baseline remoto 09I em `https://copa-arena-futebol.pages.dev/`.
- Rodar candidata local 09N a partir de `Projetos/JogoDaCopa/builds/web`.
- Registrar JSON, screenshot e resumo comparativo em `docs/playtest-reports/track-09n-ab-data/`.
- Criar relatorio de decisao em `docs/playtest-reports/track-09n-prepublish-ab.md`.
- Atualizar estado minimo em `implementation/current-status.md`, `Estado_Atual.md` e `Prioridades_Estudio.md`.

## Fora de escopo

- Publicar Cloudflare Pages.
- Alterar codigo de jogo.
- Fazer push remoto.

## Validacao planejada

- Chrome probe 5min remoto 09I com `--stability-gate=1`.
- Chrome probe 5min local 09N com `--stability-gate=1`.
- `tools/check_doc_drift.ps1`.
- `git diff --check`.

## Resultado

- 09I remoto aprovado: PASS, release root `web/v1-copa-arena-futebol-20260616-7995b06c`, `event.visible_match_start=true`, page errors `0`, console errors `0`, first-minute hitches `0`, `js_heap_growth -5.32%`, `wasmSampleCount=0`.
- 09N local candidata: PASS, `event.visible_match_start=true`, page errors `0`, console errors `0`, first-minute hitches `0`, `js_heap_growth +9.25%`, `wasmSampleCount=0`.
- Decisao: Track 09N liberada para merge/publicacao tentativa; repetir gates remotos completos apos deploy porque a margem local de `js_heap_growth` ficou proxima do limite final de `+10%`.
- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-prepublish-ab.md`.
- Evidencias: `Projetos/JogoDaCopa/docs/playtest-reports/track-09n-ab-data/`.

## Handoff esperado

Se ambos os probes passarem, a 09N fica liberada para merge/publicacao com aviso de que a publicacao ainda precisa dos gates remotos pos-deploy. Se algum probe falhar, a publicacao fica bloqueada para investigacao direcionada.

## Handoff final

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
