# DraxosMobile - T06-E Battle History

- Data: `2026-05-27`
- Agente: Codex
- Projeto: `Projetos/draxos-mobile/`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history`
- Branch: `codex/draxos-mobile/t06-battle-history`
- Status: `READY_FOR_HANDOFF`

## Objetivo

Implementar historico de batalhas e replay salvo read-only para a aba Batalha da Track 06, com `GET /battle/history` para lista recente e `GET /battle/replay?battle_id=...` para log completo do save ativo.

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
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`

## Arquivos Pretendidos

- `Projetos/draxos-mobile/supabase/functions/battle/index.ts`
- `Projetos/draxos-mobile/server/functions/battle/index.ts`
- `Projetos/draxos-mobile/server/tests/*battle_history*`
- `Projetos/draxos-mobile/online/supabase_client.gd`
- `Projetos/draxos-mobile/modes/boot/boot.gd`
- `Projetos/draxos-mobile/modes/boot/surfaces/battle_replay_presenter.gd`
- `Projetos/draxos-mobile/tools/smoke_battle_replay.gd`
- `Projetos/draxos-mobile/tests/client/*battle*`
- `Projetos/draxos-mobile/docs/contracts/api-endpoints.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md`
- `Projetos/draxos-mobile/implementation/tracks/track-06-feature-installation-rails-and-first-slices/current-status.md`

## Validacao Planejada

```powershell
npx -y deno task --cwd Projetos/draxos-mobile/supabase/functions check
npx -y deno task --cwd Projetos/draxos-mobile/server/functions check
npx -y deno run --allow-net --allow-env Projetos/draxos-mobile/server/tests/battle_history_replay_smoke.ts
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
git diff --check
```

## Handoff Planejado

Entregar endpoints read-only save-scoped, UI de historico/replay na aba Batalha e cobertura focada, sem alterar simulador, recompensa, economia, ranking, schema ou `battle_log_v1`.

## Validacao Executada

- `npx -y deno task --cwd Projetos/draxos-mobile/supabase/functions check`: passou.
- `npx -y deno task --cwd Projetos/draxos-mobile/server/functions check`: passou.
- `npx -y deno check server/tests/battle_history_replay_smoke.ts`: passou.
- `npx -y deno run --allow-net --allow-env server/tests/battle_history_replay_smoke.ts`: passou com `BATTLE_FUNCTION_URL=http://127.0.0.1:8000` e a funcao `battle` servida diretamente por Deno do worktree, sem reiniciar o Edge Runtime compartilhado.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history\Projetos\draxos-mobile -s res://tools/smoke_battle_replay.gd`: passou com `BATTLE_FUNCTION_URL=http://127.0.0.1:8000`.
- `D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio-worktrees\draxos-mobile--codex--t06-battle-history\Projetos\draxos-mobile -s res://tools/validate.gd`: passou; GUT `64/64`, `703` asserts.
- GUT client completo: passou; `64/64`, `703` asserts.

Observacao: o primeiro smoke contra `http://127.0.0.1:54321/functions/v1/battle/history` retornou `NOT_FOUND` porque o Edge Runtime local compartilhado estava montado em outra copia da funcao `battle`. Para nao interromper outros agentes, a validacao usou a funcao `battle` do worktree servida diretamente em `http://127.0.0.1:8000` e encerrou esse processo ao final.

## Handoff

T06-E esta pronta para integracao. T06-I deve integrar os arquivos da feature, repetir smoke contra o Edge Runtime integrado e confirmar que history/replay seguem read-only e save-scoped.
