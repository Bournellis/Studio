# DraxosMobile - T06-I Integracao

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-integration`
- Branch: `codex/draxos-mobile/t06-integration`
- Status: `IN_PROGRESS`

## Objetivo

Integrar as trilhas Track 06 sobre a fundacao Track 05 e os rails T06-A/B/C, resolver conflitos e validar o pacote completo.

## Base

- `master` em `43449dc` com T06-A, T06-B e T06-C integrados.
- Branches prontas recebidas: `t06-profile-account`, `t06-base-routine`, `t06-social-qol`, `t06-asset-pack-01`.
- Branch aguardada: `t06-battle-history`.

## Validacao Planejada

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://tools/smoke_session_shell.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://tools/smoke_runtime_config.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://tools/smoke_foundation_surfaces.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-integration\Projetos\draxos-mobile -s res://tools/smoke_exports.gd
npx -y deno task --cwd supabase/functions check
npx -y deno task --cwd server/functions check
git diff --check
```

## Guardrails

- Sem tuning numerico.
- Sem migration `account_profiles` + `game_saves`.
- Sem pagamento real, iOS, mobile browser, realtime social ou publicacao remota.
- Sem secrets em cliente/export/runtime config.
