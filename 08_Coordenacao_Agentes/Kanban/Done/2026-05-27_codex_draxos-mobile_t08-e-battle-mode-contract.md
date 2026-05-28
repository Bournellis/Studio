# DraxosMobile - T08-E Battle Mode Contract

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t08-battle-mode-contract`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-battle-mode-contract`
- Objetivo: formalizar batalha/replay como gameplay mode fullscreen landscape, sem app chrome, com skip seguro, summary obrigatorio, historico/replay read-only e retorno ao Refugio.
- Status: `COMPLETE`

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/implementation-plan.md`
- `08_Coordenacao_Agentes/Kanban/Doing/2026-05-27_codex_draxos-mobile_t08-b-app-shell-lifecycle.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`, se necessario
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- Este Doing

## Validacao Planejada

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-battle-mode-contract\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-battle-mode-contract\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-battle-mode-contract\Projetos\draxos-mobile -s res://tools/validate.gd`
- `git diff --check`

## Handoff Esperado

Entregar T08-E sem alterar simulador, `battle_log_v1`, recompensas, ranking ou endpoints `battle/*`, reutilizando o helper de rotas da T08-B para manter o contrato de modo.

## Handoff

Entregas:

- `DraxosAppShellRouteContract` agora declara o modo de batalha: fullscreen gameplay para `battle_running`/`battle_summary`, chrome do app oculto nessas rotas, summary obrigatorio para rotas de batalha, skip seguro e acoes read-only de historico/replay.
- `boot.gd` usa o contrato para esconder o chrome durante batalha/summary, manter `battle_running` em landscape via contrato existente, tratar Esc como skip seguro e finalizar replay sempre em `battle_summary`.
- `tests/client/test_boot_mobile_ui.gd` cobre o contrato de modo, ausencia de app chrome, skip fullscreen, summary obrigatorio, acoes read-only de replay/historico e retorno ao Refugio.
- Guardrails preservados: sem alteracao em simulador, `battle_log_v1`, recompensa, ranking ou endpoints `battle/*`.

Validacao:

- `tools/smoke_battle_replay.gd`: primeira tentativa no Edge Runtime local padrao falhou com `NOT_FOUND` em `/battle/history`; passou com `BATTLE_FUNCTION_URL=http://127.0.0.1:8000` apontando para a funcao `battle` atual servida deste worktree.
- GUT completo `res://tests/client`: passou com `89/89` testes e `1031` asserts.
- `tools/validate.gd`: passou, incluindo GUT `89/89` testes e `1031` asserts.
- `git diff --check`: passou.

Proximo ponto de handoff: T08-G pode reaproveitar o contrato de battle mode no smoke final quando T08-C/T08-D/T08-F tambem estiverem integradas.
