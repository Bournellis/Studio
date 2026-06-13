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

## Proximo Handoff

Parar na branch apos os gates locais e registrar handoff para review da Claude e OK do Fabio antes de qualquer merge ou publicacao.
