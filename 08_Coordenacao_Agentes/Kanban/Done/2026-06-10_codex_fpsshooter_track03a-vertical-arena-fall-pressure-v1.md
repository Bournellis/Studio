# FpsShooter - Track 03A Vertical Arena And Fall Pressure V1

- Data: `2026-06-10`
- Agente: `codex`
- Branch: `codex/fpsshooter/track03a-vertical-arena-fall-pressure-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track03a-vertical-arena-fall-pressure-v1`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `DONE`

## Objetivo

Implementar a primeira expansao explicita de verticalidade/hazards do `FpsShooter`, transformando o duelo atual em uma arena com jump pads, plataformas suspensas, void/queda e knockback como pressao posicional real.

## Escopo Pretendido

- Evoluir o mapa runtime para `Duel Pit V2`.
- Adicionar plataformas elevadas/suspensas simples por primitivas.
- Adicionar jump pads com impulso previsivel, feedback visual/audio e suporte para player e bot.
- Adicionar zonas de queda/void com dano, reposicionamento seguro e feedback claro.
- Fazer knockback poder empurrar combatentes para queda de forma legivel.
- Ensinar o bot a considerar destinos altos, pads e risco de queda de forma simples, sem `NavigationAgent3D`.
- Atualizar HUD/feedback/status/validacao.
- Commitar e mergear na `main`.

## Fora Do Escopo

- Novas armas, ammo, reload ou inventario.
- Multiplayer/export/Web/mobile/backend.
- Pathfinding pesado.
- Visual final ou assets finais.
- Tuning amplo de dano/cadencia.
- Sistemas canonicos/economicos/progressao Draxos.

## Arquivos Pretendidos

- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/gameplay/player/fps_player_controller.gd`
- `Projetos/FpsShooter/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsShooter/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/FpsShooter/presentation/hud/arena_hud.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-03a-vertical-arena-fall-pressure-v1/current-status.md`
- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `08_Coordenacao_Agentes/Painel_Visual_Estudio.html`
- `Projetos/README.md`
- `AGENTS.md`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/FpsShooter/AGENTS.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`

## Validacao Planejada

- `tools/validate.gd`
- `git diff --check`
- editor headless filtrado para warnings/erros GDScript nos scripts tocados
- `git status --short`

## Entrega

- `Duel Pit V2` com plataformas altas, jump pads, void/fall zones e pickups elevados.
- Player e bot com launch de jump pad e reset de impulso para recuperacao.
- Bot com rotas por jump pad para objetivos altos e penalidade/evitacao de fall zones.
- HUD/feedback para jump pad e fall penalty.
- Cobertura automatizada expandida para `35/35` testes e `294` asserts.

## Validacao Executada

- `tools/validate.gd`: PASS (`35/35`, `294` asserts).
- `git diff --check`: PASS.
- Godot headless curto: PASS sem warnings/erros dos scripts tocados.
- Observacao: `tools/validate.gd` ainda imprime warnings conhecidos de UID/text path do addon GUT durante headless, sem falha e sem warnings de scripts do projeto.

## Proximo Handoff

Commit da branch, merge na `main` e resumo da Track 03A.
