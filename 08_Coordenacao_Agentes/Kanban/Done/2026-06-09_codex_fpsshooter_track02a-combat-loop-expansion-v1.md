# FpsShooter - Track 02A Combat Loop Expansion V1

- Data: `2026-06-09`
- Agente: `codex`
- Branch: `codex/fpsshooter/track02a-combat-loop-expansion-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track02a-combat-loop-expansion-v1`
- Projeto alvo: `Projetos/FpsShooter`
- Status: `DONE`

## Objetivo

Expandir a gameplay do duelo 1x1 depois do feel aprovado, adicionando uma primeira decisao ofensiva e controle simples de mapa sem abrir reload, ammo, multiplayer, export, jump pads, void ou sistemas Draxos.

## Escopo Pretendido

- Adicionar alt-fire `Plasma Bolt`: projetil visivel, lento/esquivavel, dano moderado e knockback maior que o rifle.
- Adicionar pickups runtime simples no `Duel Pit V1`:
  - `Health Shard`: cura pequena com respawn por timer;
  - `Overcharge`: buff temporario/proximo disparo com bonus leve de dano/knockback.
- Adicionar HUD/feedback para cooldown de alt-fire, overcharge e pickups sem transformar a tela em debug pesado.
- Fazer o bot considerar pickups em decisoes simples:
  - buscar health quando estiver ferido;
  - contestar overcharge quando disponivel;
  - desviar minimamente de Plasma Bolt visivel.
- Atualizar testes automatizados para projetil, pickups, buff, bot awareness e reset.
- Atualizar docs/status/portfolio ao concluir.

## Fora Do Escopo

- Ammo/reload.
- Recoil/spread numerico amplo.
- Nova arma completa com inventario.
- Jump pads, plataformas suspensas, void/fall.
- Multiplayer, export, backend, matchmaking.
- Sistemas canonicos Draxos, economia, progressao ou lore.

## Arquivos Pretendidos

- `Projetos/FpsShooter/gameplay/player/fps_player_controller.gd`
- `Projetos/FpsShooter/gameplay/bot/basic_duel_bot.gd`
- `Projetos/FpsShooter/gameplay/combat/combatant_3d.gd`
- `Projetos/FpsShooter/modes/arena/arena_root.gd`
- `Projetos/FpsShooter/presentation/hud/arena_hud.gd`
- `Projetos/FpsShooter/presentation/feedback/fps_feedback_controller.gd`
- `Projetos/FpsShooter/tests/unit/test_bootstrap.gd`
- `Projetos/FpsShooter/docs/work-plan.md`
- `Projetos/FpsShooter/docs/validation.md`
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/implementation/tracks/track-02a-combat-loop-expansion-v1/current-status.md`
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
- `Projetos/FpsShooter/implementation/current-status.md`
- `Projetos/FpsShooter/docs/work-plan.md`

## Validacao Planejada

- Rodar import headless se a worktree nova precisar preparar GUT.
- Rodar `Projetos/FpsShooter/tools/validate.gd`.
- Rodar `git diff --check`.
- Rodar editor headless filtrado para warnings GDScript nos scripts tocados.
- Conferir `git status --short`.

## Resultado

- `Plasma Bolt` RMB implementado com projetil runtime, feedback, cooldown e knockback mais forte.
- Pickups `Health Shard` e `Overcharge` implementados com respawn e HUD.
- Bot agora recebe awareness de pickups e Plasma Bolt, busca cura quando ferido, contesta overcharge e desvia de plasma proximo.
- Track/status/portfolio atualizados para `FPS_SHOOTER_TRACK_02A_COMBAT_LOOP_EXPANSION_COMPLETE`.

## Validacao Executada

- Import headless do editor: PASS.
- `tools/validate.gd`: PASS, GUT `26/26`, `239` asserts.
- `git diff --check`: PASS.
- Editor headless filtrado para scripts tocados: PASS, sem warnings/erros GDScript do FpsShooter.
- Warnings remanescentes observados sao do addon GUT por UID/text path, preservados da baseline.

## Proximo Handoff

Commit da branch e merge na `main` em seguida, se o workspace principal estiver limpo.
