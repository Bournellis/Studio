# DraxosMobile - T08-B App Shell Lifecycle

- Data: `2026-05-27`
- Agente: `Codex`
- Projeto: `Projetos/draxos-mobile/`
- Branch: `codex/draxos-mobile/t08-app-shell-lifecycle`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t08-app-shell-lifecycle`
- Objetivo: consolidar o contrato interno de rotas, back stack e orientacao pos-Track 07 mantendo `boot.gd` como orquestrador.
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
- `08_Coordenacao_Agentes/Kanban/Doing/2026-05-27_codex_draxos-mobile_t08-coordenacao.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/ui/` ou `Projetos/draxos-mobile/core/` se helper pequeno reduzir risco
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/implementation/tracks/track-08-foundation-review-and-hardening/current-status.md`
- Este Doing

## Validacao Planejada

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-app-shell-lifecycle\Projetos\draxos-mobile -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t08-app-shell-lifecycle\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `git diff --check`

## Handoff Esperado

Entregar T08-B com contrato de rotas/back/orientacao coberto por teste, preservando guardrails: sem backend, schema, gameplay, economia, UI visual ampla, assets finais ou publicacao remota.

## Handoff

Entregas:

- `DraxosAppShellRouteContract` criado em `modes/boot/ui/` para normalizar aliases legacy, declarar root/back, orientar `battle_running` como landscape, mapear titulos e manipular historico de rotas.
- `boot.gd` continua orquestrando renderizacao, network/session, telemetria e acoes; agora delega apenas o contrato de rotas/back/orientacao ao helper.
- `tests/client/test_boot_mobile_ui.gd` cobre aliases legacy, Refugio como root, stack aninhada, preferencia landscape de `battle_running`, summary sem landscape e retorno do summary ao Refugio com stack/overlay/replay limpos.
- Guardrails preservados: sem backend, schema, gameplay, economia, simulador, endpoints, assets finais, publicacao remota ou rework visual amplo.

Validacao:

- `tools/validate.gd`: passou.
- GUT completo `res://tests/client`: passou com `88/88` testes e `1003` asserts.
- `git diff --check`: passou.

Proximo ponto de handoff: T08-E pode iniciar sobre este contrato; T08-G deve reaproveitar o helper no smoke final de hardening.
