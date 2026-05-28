# T05-C - DraxosMobile Hub Foundation

- Data: `2026-05-27`
- Agente: `Codex`
- Branch: `codex/draxos-mobile/t05-hub-foundation`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Reduzir risco estrutural do Hub pos-Track 04 sem mudanca funcional, mantendo `boot.gd` como dono de actions, network, session e telemetria, e mantendo presenters de `modes/boot/surfaces/` render-only.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `canon/canon-brief.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/agent-prompts.md`
- `Projetos/draxos-mobile/implementation/tracks/track-04-post-handoff-hardening-and-hub-modularization/hub-modularization-plan.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/`
- `Projetos/draxos-mobile/tests/client/`
- `Projetos/draxos-mobile/implementation/tracks/track-05-foundation-stabilization-and-asset-service-readiness/hub-foundation-notes.md`
- Este registro Doing.

## Validacao Planejada

- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation\Projetos\draxos-mobile -s res://tools/validate.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd`
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t05-hub-foundation\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd`
- `git diff --check`

## Proximo Handoff

Entregar commit com auditoria, cobertura e notas T05-C; listar qualquer wrapper ou arquivo aposentado e confirmar que nenhum contrato/backend/schema/economia foi alterado.

## Resultado

- `battle_surface_presenter.gd` aposentado porque o Hub usa `battle_replay_presenter.gd` e nao havia preload ativo no Boot.
- Manifest URL fallback movido para metodo host-side em `boot.gd`, mantendo presenter sem dependencia direta de Supabase.
- GUT passou a validar que presenters em `modes/boot/surfaces/` continuam render-only.
- Validado com `tools/validate.gd`, GUT client, `smoke_session_shell.gd`, `smoke_battle_replay.gd` e `git diff --check`.
