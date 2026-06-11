# Tarefa: JogoDaCopa Track 03G Playtest Findings V1

## Metadata

- id: `2026-06-10_codex_jogodacopa_track03g-playtest-findings-v1`
- owner: `Codex`
- status: `Doing`
- projeto: `JogoDaCopa`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/jogodacopa/track03g-playtest-findings-v1`
- worktree: `D:\Estudio-worktrees\JogoDaCopa--codex--track03g-playtest-findings-v1`

## Goal

Corrigir os 6 achados do primeiro playtest humano completo de Fabio para `Copa Arena Futebol`, mantendo o escopo fechado da Track 03G e preservando contratos de fisica/chute/paridade de bot.

## Technical Scope

- `main_menu` responsive anchors/containers
- `appearance_selection` moved to pre-kickoff intro panel only
- `ARCADE_DASH_SPEED` and `ARCADE_DASH_DURATION` tuning with bot parity
- `football_bot` defensive kickoff hold and aerial goal defense
- `football_camera` collision/spawn safety during bot kickoff countdown
- `ball_reset` root cause investigation and safe reset/kickoff marker fix
- `tests` for menu visibility, avatar selection, dash ratio, bot kickoff/aerial defense and camera safety
- `tools/validate.gd` integrity validation

## Out of Scope

- Alterar fisica base da bola: massa, bounce, drag ou limites.
- Alterar contratos de tap LMB e RMB.
- Introduzir assets externos, multiplayer/backend, novo modo de jogo ou mecanicas de power-up.
- Reabrir decisoes de Fabio ja tomadas para esta track.

## Expected Files

- `modes/menu/`
- `modes/football/`
- `gameplay/football/`
- `presentation/camera/`
- `presentation/hud/`
- `tests/`
- `docs/arcade-upgrade-plan.md`
- `implementation/current-status.md`
- `implementation/tracks/track-03g-playtest-findings-v1/current-status.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`

## Acceptance Criteria

- [ ] Menu principal responsivo em 1920x1080, 1366x768 e 1280x720, com controles visiveis e clicaveis.
- [ ] Selecao de pele/camisa/aparencia existe somente no painel de intro antes do kickoff e persiste entre rematches da mesma sessao.
- [ ] Dash do player e bot usa `ARCADE_DASH_SPEED` ~19.0 e `ARCADE_DASH_DURATION` ~0.28, mantendo custo/cooldown, com pico >= 1.5x corrida com boost.
- [ ] Bot segura postura defensiva antes do primeiro toque em kickoff do player e reage a lob RMB/aerial defense com modulacao de dificuldade.
- [ ] Camera nao nasce nem atravessa geometria do gol no countdown com kickoff do bot.
- [ ] Causa raiz do reset visual/fisico da bola documentada e corrigida.
- [ ] `validate.gd` PASS com integrity check.
- [ ] Performance sample registrado na metodologia documentada.
- [ ] `Estado_Atual.md`, plano arcade e status da track atualizados no fechamento.
- [ ] Worktree principal verificada pos-merge com `WORKTREE_VERIFIED`.

## Handoff Needed

`No`

## Notes

Docs lidos na Fase 1: `Projetos/JogoDaCopa/AGENTS.md`, `implementation/current-status.md`, `docs/code-review-track03f-hotfix-v1.md` (incidente recorrente), `docs/arcade-upgrade-plan.md`, alem do gate de portfolio (`Prioridades_Estudio.md`, `Projetos/README.md`, `Estado_Atual.md`).
