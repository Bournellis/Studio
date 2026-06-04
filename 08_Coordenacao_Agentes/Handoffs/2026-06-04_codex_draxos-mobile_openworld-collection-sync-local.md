# Handoff: DraxosMobile Openworld Collection Sync Local Fix

## Metadata

- data: `2026-06-04`
- agente: `Codex`
- projeto: `draxos-mobile`
- branch final: `codex/draxos-mobile/openworld-local-validation`
- worktree final: `D:\Estudio-worktrees\draxos-mobile--codex--openworld-local-validation`
- escopo: local only, sem publicacao remota

## Resultado

Implementado localmente o pacote `Openworld Collection Sync Local Fix` para impedir rollback/pullback apos coleta no Bosque.

- SQL aceita os 26 `resource_nodes` do ruleset ativo.
- Apenas `move_heartbeat` persiste `player_position`.
- ACK de evento remove `player_position` e `active_collection` de patches/payload visual.
- Start/resume continuam aplicando posicao remota.
- Resync ativo da mesma sessao preserva a posicao local e aplica snapshot autoritativo de inventario/coleta/guidance.
- Resync que retorna outra sessao ativa aplica a posicao remota como retomada.

## Commits

- backend source branch `codex/draxos-mobile/openworld-backend-contract`:
  `defd5e6 Fix openworld collection backend sync contract`
- client source branch `codex/draxos-mobile/openworld-client-resync`:
  `0ddcb5e Preserve openworld position on active resync`
- validation branch:
  - `4a91cf2 Fix openworld collection backend sync contract`
  - `e15c98f Preserve openworld position on active resync`

## Validacao

- Baseline proof before fix:
  - `npx -y deno test --allow-read server/tests/openworld_ruleset_definition_test.ts`
  - resultado: falhou como esperado em `node_galho_02` ausente na SQL efetiva.
- Backend direcionado:
  - `npx -y deno test --allow-read server/tests/openworld_ruleset_definition_test.ts server/tests/modes_domain_test.ts server/tests/openworld_reward_bridge_test.ts`
  - resultado: `14 passed | 0 failed`.
- Client direcionado:
  - `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd`
  - resultado: `219/219`, `3481` asserts.
  - `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit`
  - resultado: `219/219`, `3481` asserts.
  - `Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/smoke_openworld_forest.gd`
  - resultado: `[smoke-openworld-forest] OK`.
- Official profiles:
  - `ClientQuick`: PASS.
  - `ServerQuick`: FAIL somente no blocker existente de Arena,
    `server/tests/arena_loop_unlock_friction_test.ts`, esperando
    `Proximo desafio\n`; Openworld dentro de `ServerQuick` passou.
  - `FullLocal -RequireClean`: FAIL pelo mesmo blocker de Arena; relatorio teve
    PASS em `git status clean`, `DatabaseLocal`, `ModePlatform`, `ClientQuick`
    e `ReleaseDryRun`.
- Supabase local:
  - `npx -y supabase start`: stack local running.
  - `npx -y supabase db reset`: aplicou
    `202606040002_openworld_bosque_collection_sync_v1.sql`.
  - prova SQL direta apos reset: `26/26` `resource_nodes` ativos reconhecidos
    por `public.openworld_forest_node_item_v1`.
  - `npx -y supabase functions serve`: servido localmente durante o gate e
    encerrado depois.

## Blocker Fora De Escopo

`ServerQuick` e `FullLocal` continuam vermelhos por falha em Arena:
`server/tests/arena_loop_unlock_friction_test.ts`, teste
`client Arena loop removes loadout click and continues inside Arena`, esperando
texto `Proximo desafio\n`. Isso nao foi alterado por este pacote e nao bloqueia
a evidencia direcionada de Openworld.

## Remote Safety

Nenhum comando remoto mutante foi executado. Nao houve `supabase db push`,
deploy de functions, Storage upload, Wrangler, RemoteReadOnly ou FullPublish.
