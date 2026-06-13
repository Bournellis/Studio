# 2026-06-13 - Codex - JogoDaCopa Track 06C Menu Broadcast V1

## Registro

- Branch: `codex/jogodacopa/track06c-menu-broadcast-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06c`
- Status: `READY_FOR_REVIEW_PRE_MERGE`
- Objetivo: transformar o menu principal em card de transmissao pre-jogo usando as fontes Kenney locais.
- Arquivos pretendidos: `Projetos/JogoDaCopa/modes/menu/*`, `Projetos/JogoDaCopa/tests/unit/test_menu_visual.gd`, `Projetos/JogoDaCopa/docs/asset-licenses.md`, `Projetos/JogoDaCopa/docs/screenshots/track-06c/`.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`

## Plano De Validacao

- Import headless executado na worktree.
- `validate.gd` full PASS: 98/98 testes, 1699 asserts.
- Capturas finais em `1920x1080`, `1366x768`, `1280x720`.
- Export Web release PASS e boot Chrome/local sem `pageErrors`.
- `git diff --check` PASS.

## Handoff

- Parar pre-merge com commit local e handoff em `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06c-menu-broadcast-v1.md`.
