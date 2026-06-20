# Publish Track 10B - Web Goal Feel Reintroduction

- Data: 2026-06-20
- Agente: Codex
- Branch: `codex/JogoDaCopa/publish-track10b`
- Worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--publish-track10b`
- Base local: `317999b0` (`merge(jogodacopa): approve track10b web goal feedback`)
- Resultado: publicacao tentada, bloqueada pelo gate remoto de heap, rollback para Track 10A confirmado.

## Escopo

- Tentou publicar `Super Campeao v1.2.1+317999b0`.
- Release root tentado: `web/v1-copa-arena-futebol-20260620-317999b0`.
- URL publica estavel: `https://copa-arena-futebol.pages.dev/`.
- Preview tentado: `https://35b5b340.copa-arena-futebol.pages.dev`.
- Rollback para Track 10A: `web/v1-copa-arena-futebol-20260620-fc3c72bb`.
- Preview do rollback: `https://f375997e.copa-arena-futebol.pages.dev`.

## Validacao

- Full publish 10B: PASS.
- Remote menu 10B: PASS, release root conferiu, `pageErrors=0`, `consoleErrorCount=0`.
- Remote first minute 10B: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Remote stability 5min 10B: FAIL somente em `js_heap_growth +13.85%` contra limite `<10%`; pico `+17.71%`, `wasmSampleCount=0`.
- Demais checks do stability 10B: PASS em counters/caches Godot, `pageErrors=0`, `consoleErrorCount=0`, `firstMinuteHitches=0`, pior janela 5s `117.2 FPS`.
- Remote night luma 10B: nao rodado porque o stability gate bloqueou.
- Rollback publish 10A: PASS.
- Rollback confirmation: PASS, URL publica voltou a servir `web/v1-copa-arena-futebol-20260620-fc3c72bb`, `pageErrors=0`, `consoleErrorCount=0`.
- `git diff --check`: PASS.
- `D:\Estudio\tools\check_doc_drift.ps1`: PASS.

## Evidencias

- Relatorio: `Projetos/JogoDaCopa/docs/playtest-reports/track-10b-publication.md`.
- Evidencias brutas: `Projetos/JogoDaCopa/docs/playtest-reports/track-10b-data/`.
- Candidate publication: `10b-publication-report-317999b0.json`.
- Remote menu: `10b-remote-menu-317999b0.json/png`.
- Remote first minute: `10b-remote-first-minute-317999b0.json/png`.
- Remote stability: `10b-remote-stability-5min-317999b0.json/png`.
- Rollback publication: `10b-rollback-to-10a-publication-report-fc3c72bb.json`.
- Rollback confirmation: `10b-rollback-confirm-10a-fc3c72bb.json/png`.

## Handoff

- 10B nao esta publicada como baseline; producao voltou para Track 10A.
- Track 10A continua baseline publico humano aprovado.
- Proxima decisao recomendada: investigar/hotfixar heap remoto da 10B ou descartar a reintroducao de feedback de gol Web antes de nova reducao estrutural.
- `PUSH PENDENTE`: Fabio - GitHub Desktop - Push origin.
