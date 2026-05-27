# DraxosMobile - T06-I Integracao

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-integration`
- Branch: `codex/draxos-mobile/t06-integration`
- Status: `COMPLETE`

## Objetivo

Integrar as trilhas Track 06 sobre a fundacao Track 05 e os rails T06-A/B/C, resolver conflitos e validar o pacote completo.

## Base

- `master` em `43449dc` com T06-A, T06-B e T06-C integrados.
- Branches integradas: `t06-profile-account`, `t06-base-routine`, `t06-social-qol`, `t06-asset-pack-01`, `t06-battle-history`.
- Base previa em master: T06-A/B/C.

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

## Resultado

T06-I integrou T06-D a T06-H sobre o baseline T06-A/B/C. A Track 06 agora entrega rails de feature, runtime config, painel Perfil/Conta, Battle History/replay read-only, rotina da Base, Social QoL e Asset Pack 01 seguro.

Correcao aplicada durante integracao: `BattleSymbolIcon` agora resolve `AssetIds` via autoload somente quando dentro da arvore ativa e usa fallback local fora dela, evitando erros de console nos smokes dev lab sem tornar arte obrigatoria.

Validacao final:

- `tools/validate.gd`: passou com `73/73` testes e `843` asserts.
- GUT client completo: passou com `73/73` testes e `843` asserts.
- `tools/smoke_session_shell.gd`: passou.
- `tools/smoke_runtime_config.gd`: passou.
- `tools/smoke_battle_replay.gd`: passou com `BATTLE_FUNCTION_URL=http://127.0.0.1:8000` apontando para a funcao `battle` servida da worktree atual.
- `tools/smoke_foundation_surfaces.gd`: passou.
- `tools/smoke_dev_labs.gd`: passou.
- `tools/smoke_dev_lab_ui.gd`: passou em headless, com screenshots ignoradas pelo renderer como esperado.
- `tools/smoke_exports.gd`: passou.
- `npx -y deno task --cwd supabase/functions check`: passou.
- `npx -y deno task --cwd server/functions check`: passou.
- `npx -y deno check server/tests/battle_history_replay_smoke.ts`: passou.
- `git diff --check`: passou.

Nota operacional: o Supabase local ja em execucao ainda servia uma funcao `battle` antiga em `127.0.0.1:54321` e retornou `404 Unknown battle endpoint` para `/battle/history`; a funcao nova foi validada por Deno serve isolado em `127.0.0.1:8000`. Reiniciar/redeployar as funcoes locais atualiza o endpoint padrao.
