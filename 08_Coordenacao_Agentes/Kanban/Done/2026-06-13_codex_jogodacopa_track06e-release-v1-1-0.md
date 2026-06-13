# JogoDaCopa Track 06E - Release v1.1.0

- Data: `2026-06-13`
- Agente: `Codex`
- Branch: `codex/jogodacopa/track06e-release-v1-1-0`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06e`
- Projeto: `Projetos/JogoDaCopa`

## Objetivo

Fechar a fase pre-merge da Track 06E com bump visivel para `v1.1.0`, changelog da Serie 06 e evidencias locais obrigatorias, sem mudanca de gameplay e sem publicacao remota.

## Arquivos Pretendidos

- `Projetos/JogoDaCopa/tools/publish_web.ps1`
- Constantes/recursos locais de versao do `Projetos/JogoDaCopa`, se existirem
- Rodape do menu em `Projetos/JogoDaCopa/modes/menu/`
- `Projetos/JogoDaCopa/docs/release-history.md`
- Evidencias locais em `Projetos/JogoDaCopa/docs/playtest-reports/track-06e-data/`
- Screenshot local do rodape em `Projetos/JogoDaCopa/docs/screenshots/track-06e/`
- Handoff em `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06e-release-v1-1-0.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `AGENTS.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`
- `08_Coordenacao_Agentes/Decisoes/2026-06-12_jogodacopa_publicacao-web-cloudflare.md`
- `Projetos/JogoDaCopa/docs/publication-readiness.md`
- `Projetos/JogoDaCopa/docs/release-history.md`
- `Projetos/JogoDaCopa/tools/publish_web.ps1`

## Validacao Planejada

- `tools/validate.gd` PASS na main antes da worktree e na branch antes do handoff.
- Import headless de editor uma vez na worktree nova.
- Export Web release single-threaded PASS.
- Export Windows debug smoke PASS.
- Boot Web local em Chrome/probe com screenshot do rodape `v1.1.0`.
- Gate curto de primeiro minuto local PASS.
- Gate de luminancia noturna `< 90` PASS.
- `git diff --check` e `git status --short`.

## Execucao Pos-Merge

- Merge local em `main`: PASS, commit `ea15d5dd`.
- `tools/validate.gd` pos-merge: PASS, `101` testes / `1735` asserts.
- Publicacao `v1.1.0+ea15d5dd`: executada e depois bloqueada pelo gate remoto.
- Primeiro minuto remoto: PASS, `firstMinuteHitches=0`, `pageErrors=0`, `consoleErrorCount=0`.
- Estabilidade remota 5min: FAIL, `pageErrors=2`, heap JS/WASM `+19.43%` contra limite `<10%`.
- Rollback: PASS, URL estavel voltou para `v1.0.3+ef9c5baa` / `web/v1-copa-arena-futebol-20260612-ef9c5baa`.

## Proximo Handoff

Investigar a falha remota antes de qualquer nova publicacao ou retest humano de `v1.1.0`. Handoff: `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06e-release-v1-1-0-rollback.md`.
