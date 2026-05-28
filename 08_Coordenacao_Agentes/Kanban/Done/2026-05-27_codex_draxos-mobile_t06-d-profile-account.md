# DraxosMobile - T06-D Profile Account

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-profile-account`
- Branch: `codex/draxos-mobile/t06-profile-account`
- Status: `READY_FOR_INTEGRATION`

## Objetivo

Instalar painel de perfil/conta no cliente usando estado existente: `SessionStore`, `account/state`, save ativo, username, level, power, auth method, update state e status alpha.

## Base Lida

- `08_Coordenacao_Agentes/Prioridades_Estudio.md`
- `AGENTS.md`
- `Projetos/README.md`
- `canon/canon-brief.md`
- `08_Coordenacao_Agentes/Estado_Atual.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/scope.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/implementation-plan.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-prompts.md`

## Arquivos Tocados

- `Projetos/draxos-mobile/modes/boot/surfaces/hub_account_surface_presenter.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/hub_surface_presenter.gd`
- `Projetos/draxos-mobile/tests/client/test_boot_mobile_ui.gd`
- `Projetos/draxos-mobile/tools/smoke_session_shell.gd`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/agent-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`

## Validacao Planejada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-profile-account\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-profile-account\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-profile-account\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd
git diff --check
```

## Validacao Executada

- `tools/validate.gd`: passou; GUT interno `65/65`, `709` asserts.
- GUT client completo: passou; `65/65`, `709` asserts.
- `tools/smoke_session_shell.gd`: passou com Auth anonimo, conta guest, `account/state` e resumo de perfil.
- `git diff --check`: passou.

## Handoff

Painel de perfil/conta entregue como read-only e save-aware. Integra `username`, save ativo, level, poder, auth method, estado de update e status alpha usando estado existente. Sem endpoint novo e sem alterar Auth, schema Supabase, contrato persistido do `SessionStore`, `BackendConfig`, economia, combate, ranking ou manifest remoto.
