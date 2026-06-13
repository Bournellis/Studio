# 2026-06-13 - Codex - JogoDaCopa Track 06D HUD Broadcast V1

## Registro

- Branch: `codex/jogodacopa/track06d-hud-broadcast-v1`
- Worktree: `D:\Estudio-worktrees\jogodacopa-track06d`
- Status: `READY_FOR_REVIEW_PRE_MERGE`
- Objetivo: aplicar pele broadcast ao HUD de partida sem alterar gameplay nem contratos do menu ESC.
- Arquivos pretendidos: `Projetos/JogoDaCopa/presentation/hud/*`, `Projetos/JogoDaCopa/tests/unit/test_hud_visual.gd`, `Projetos/JogoDaCopa/docs/screenshots/track-06d/`.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/README.md`
- `Projetos/JogoDaCopa/AGENTS.md`
- `Projetos/JogoDaCopa/implementation/current-status.md`
- `Projetos/JogoDaCopa/docs/documentation-index.md`
- `Projetos/JogoDaCopa/docs/series-06-broadcast-polish-plan.md`
- `Projetos/JogoDaCopa/docs/architecture-overview.md`
- `Projetos/JogoDaCopa/tests/unit/test_pause_menu.gd`

## Plano De Validacao

- Import headless executado na worktree.
- `tests/unit/test_hud_visual.gd` + `tests/unit/test_pause_menu.gd` PASS, suite completa pela config: 98/98 testes, 1538 asserts.
- `validate.gd` full PASS: 98/98 testes, 1538 asserts.
- Capturas finais HUD em 1920x1080, 1280x720 e 960x540.
- Export Web release PASS e boot Chrome/local sem `pageErrors`.
- `git diff --check` PASS.

## Handoff

- Parar pre-merge com commit local e handoff em `08_Coordenacao_Agentes/Handoffs/2026-06-13_codex_jogodacopa_track06d-hud-broadcast-v1.md`.
