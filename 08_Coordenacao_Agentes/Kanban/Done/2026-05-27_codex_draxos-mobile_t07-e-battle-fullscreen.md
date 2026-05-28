# DraxosMobile - T07-E Battle Fullscreen

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t07-battle-fullscreen`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t07-battle-fullscreen`
- Objetivo: fazer batalha/replay do autobattler abrir em fullscreen landscape, com `Pular` fixo e summary full screen.
- Status: `COMPLETE_VALIDATED`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/agent-registry.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/tools/smoke_battle_replay.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-07-mobile-presentation-loop-and-layout-rework/`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-05-27_codex_draxos-mobile_t07-e-battle-fullscreen.md`

## Validacao Planejada

- `tools/smoke_battle_replay.gd`
- GUT client focado/completo
- `tools/validate.gd`
- `git diff --check`

## Guardrails

- Nao alterar simulador, recompensa, `battle_log_v1`, endpoints, backend, schema, economia ou ranking.
- Preservar `BattleLogPresenter`, `BattleVisualMockup`, `BattleStage2D` e replay existente.
- Evitar presenters de Hub/Base/Social/Competition/Shop.

## Proximo Handoff

Entregar battle/replay fullscreen landscape com summary e testes para a integracao T07-F/T07-G.

## Resultado

- `battle_running` agora abre um overlay full-screen landscape usando o replay existente.
- Android usa a fundacao T07-B para travar landscape em `battle_running` e restaurar orientacao ao sair.
- PC/Web recebem frame landscape 16:9 dentro da janela.
- Botao `Pular` fica fixo no canto inferior direito com alvo grande.
- Ao pular ou finalizar, `battle_summary` mostra vencedor, duracao, eventos, recompensa, recursos e botoes `Voltar ao Refugio`, `Rever replay`, `Historico`.
- Sem alteracao de simulador, recompensa, `battle_log_v1`, endpoints, backend, schema, economia ou ranking.

## Validacao

- GUT client: passou com `81/81` testes e `907` asserts.
- `tools/validate.gd`: passou com `81/81` testes e `907` asserts.
- `tools/smoke_battle_replay.gd`: passou com `BATTLE_FUNCTION_URL=http://127.0.0.1:8000` usando a funcao `battle` servida desta worktree; o endpoint padrao local ainda estava montado em outra worktree e retornou `NOT_FOUND` para `/battle/history`.
- `git diff --check`: passou.
