# Multi-Agent Done: DraxosMobile Local Edge RPC Smokes

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Rodar e criar smokes HTTP locais das Supabase Edge Functions sobre os adapters RPC v1 promovidos, provando que o caminho `/functions/v1` usa os contratos transacionais antes de liberar tuning de base builder/autobattler/social/minigame.

## Entrega

- Criado `server/tests/transactional_edge_rpc_smoke.ts`.
- Smoke cobre `base/collect`, `base/upgrade`, `battle/request`, `build/equip`, `crafting/crush-bones`, `crafting/craft`, `monetization/rewards/claim`, `monetization/alpha-purchase`, `guild/create` e `guild/join`.
- Smoke confirma em Postgres local que os adapters criam `idempotency_keys` com `status = completed`, `request_hash` calculado e `response_payload` persistido.
- `validate_foundation.ps1` ganhou `-IncludeLocalEdgeRpc`.
- `check_foundation_expansion_readiness.ps1` passou a exigir o smoke HTTP local.
- `server/tests/README.md`, status local, Track 17 e portfolio foram atualizados.

## Bugs Encontrados E Corrigidos

- `battle/request` em modo `FIRST_SLICE_SIM` incluia `battle_id` aleatorio no hash canonico, quebrando retry com o mesmo `request_id`.
- `crafting/crush-bones` e `crafting/craft` faziam precheck de recurso no adapter antes da RPC, impedindo replay idempotente quando o estado mudava depois da primeira aplicacao.
- `battle_request_smoke.ts` ainda validava recompensa legacy fixa; agora compara contra o payload de recompensa retornado.

## Validacao Executada

- `npx -y deno fmt --check` nos tests tocados.
- `npx -y deno fmt --check --config server/functions/deno.json` nos adapters `server/functions`.
- `npx -y deno fmt --check --config supabase/functions/deno.json` nos adapters `supabase/functions`.
- `npx -y deno check server/tests/transactional_edge_rpc_smoke.ts server/tests/battle_request_smoke.ts server/tests/first_slice_battle_smoke.ts server/functions/battle/index.ts supabase/functions/battle/index.ts server/functions/crafting/index.ts supabase/functions/crafting/index.ts`.
- `npx -y deno run --allow-net --allow-env server/tests/transactional_edge_rpc_smoke.ts`.
- `npx -y deno run --allow-net --allow-env server/tests/first_slice_battle_smoke.ts`.
- `npx -y deno run --allow-net --allow-env server/tests/battle_request_smoke.ts`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -IncludeLocalSupabaseRpc -IncludeLocalEdgeRpc`.

## Resultado

`validate_foundation.ps1 -Profile Quick -IncludeLocalSupabaseRpc -IncludeLocalEdgeRpc` passou com proof local de RPC transacional e smoke HTTP local das Edge Functions.

## Fora Do Escopo

- Nenhuma publicacao remota.
- Nenhuma migracao remota.
- Nenhuma feature nova de gameplay, social ou minigame.

## Proximo Handoff

Continuar o split de servicos de dominio portaveis para battle/base/progression/economy, agora com o caminho HTTP local das Edge Functions coberto por smoke de regressao.
