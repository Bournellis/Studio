# DraxosMobile Hardening Handoff: client-shell - Runtime Config Recovery UX v1

## Metadata

- from: `Codex`
- to: `Codex | Fabio`
- date: `2026-06-15`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `client-shell`
- mode_scope: `autobattler`
- branch: `codex/draxos-mobile/runtime-config-recovery-ux-v1`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--runtime-config-recovery-ux-v1`
- commits: `Improve Arena runtime config recovery UX`

## Contexto

Fabio enviou screenshot da Arena PVE bloqueada por `Configuracao remota indisponivel; acoes online de progresso estao pausadas.` durante a prova humana do pacote Arena UX Readability Recovery v1. O trabalho endurece a UX de recuperacao sem tuning, economia, conteudo novo, backend remoto ou publicacao.

## Current State

- Current published package: `Arena UX Readability Recovery v1`, aguardando prova humana.
- Current local implemented stage: `runtime config recovery UX v1`, implemented and validated locally.
- Preserved Arena context: Arena PVE segue o primeiro core aprovado, mas `ARENA_CORE_NOT_PROVEN` continua ate veredito humano.
- Open decision: nenhuma nova decisao de produto.
- runtime touched: `yes`
- remote mutation/publication run: `no`
- Validation profile: `ClientQuick` and `ReleaseDryRun` passed.
- worktree clean at handoff: `yes after commit`

## Intended Files

- `Projetos/draxos-mobile/modes/boot/boot_runtime_action_dispatcher.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_flow_facade.gd`
- `Projetos/draxos-mobile/modes/boot/boot_runtime_navigation_controller.gd`
- `Projetos/draxos-mobile/modes/boot/flows/account_session_flow.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/arena_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/ui/app_shell_action_contract.gd`
- `Projetos/draxos-mobile/modes/boot/ui/app_shell_action_router.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tests/client/test_foundation_shell_contracts.gd`
- `Projetos/draxos-mobile/tools/smoke_web_overlay_menu_actions.ps1`

## Implemented

- Added a shell/session action `sync_runtime_config` that bypasses required-update blocking and does not map to a mutation endpoint.
- Added manual runtime config sync in the account/session flow, with success/fallback messaging and screen refresh after config apply.
- Added Arena fallback UX: a compact `ArenaRuntimeConfigRecoveryPanel` with `Sincronizar configuracao`, placed after primary Arena actions so the existing CTAs remain above the fold.
- Added web diagnostics for runtime config fallback/mutation state and an optional strict gate in `smoke_web_overlay_menu_actions.ps1` via `-RequireRemoteRuntimeConfig` or `DRAXOS_WEB_OVERLAY_ACTIONS_REQUIRE_REMOTE_RUNTIME_CONFIG=1`.
- Added GUT coverage for the action routing contract and Arena active-attempt fallback recovery panel.

## Docs Read

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/docs/multi-agent-workflow.md`
- `Projetos/draxos-mobile/docs/pve-arena-initial-direction.md`
- `Projetos/draxos-mobile/docs/pve-arena-v1.md`
- `Projetos/draxos-mobile/docs/arena-pve-product-proof.md`
- `Projetos/draxos-mobile/docs/arena-ux-proof-release-discipline-plan.md`
- `Projetos/draxos-mobile/modes/boot/surfaces/README.md`

## Validation Plan

- `git diff --check` - PASS.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . --import` - PASS; used to rebuild the worktree import cache after the first validation reported missing global classes.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_responsive_layout.gd` - PASS.
- `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit` - PASS, 286/286.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ClientQuick -NoProjectWrites` - PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ReleaseDryRun -NoProjectWrites` - PASS.

## Next Handoff Point

PUSH PENDENTE: Fabio - GitHub Desktop - Push origin.
