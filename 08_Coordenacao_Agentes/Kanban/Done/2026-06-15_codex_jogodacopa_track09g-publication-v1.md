# Multi-Agent Done: JogoDaCopa Track 09G Publication V1

## Metadata

- data: `2026-06-15`
- agente: `Codex`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/publish-track09g`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track09g`
- resultado: `PUBLICACAO_BLOQUEADA_ROLLBACK_EXECUTADO`

## Objetivo

Publicar a Track 09G de `Super Campeao` no Cloudflare Pages e registrar os gates remotos de release.

## Resultado

- Candidato 09G publicado como `v1.2.1+d1784ff9`, release root `web/v1-copa-arena-futebol-20260615-d1784ff9`.
- Menu remoto PASS: release root conferiu, `menu.ready.end` visto, `pageErrors=0`, `consoleErrorCount=0`.
- Primeiro minuto remoto PASS: `event.visible_match_start` visto, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min FAIL duas vezes apenas em `js_wasm_heap_growth`: `+15.42%` e `+15.35%`, limite `<10%`.
- Counters/caches Godot, FPS e erros de runtime ficaram verdes nos gates de estabilidade.
- Rollback executado para `web/v1-copa-arena-futebol-20260615-a75cfe57`; URL publica estavel confirmada novamente nesse root.

## Evidencias

- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-publication-report-d1784ff9.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-remote-menu-d1784ff9.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-remote-first-minute-d1784ff9.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-remote-stability-5min-d1784ff9.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-remote-stability-5min-rerun-d1784ff9.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-rollback-publication-report-a75cfe57.json`
- `Projetos/JogoDaCopa/docs/playtest-reports/track-09g-data/09g-rollback-confirm-a75cfe57.json`

## Validacao Final

- Cloudflare Pages rollback: PASS.
- Stable URL release-root confirm: PASS para `web/v1-copa-arena-futebol-20260615-a75cfe57`.
- Docs/coordination atualizados para marcar 09G como local validada, publicacao bloqueada e rollback executado.

## Proximo Passo

Investigar/corrigir a margem de heap remoto da 09G antes de nova publicacao ou de continuar a reducao de `FootballRoot`.
