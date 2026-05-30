# Done: DraxosMobile Portable Domain Services Slice

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar a Foundation Expansion Readiness com um primeiro split real de servicos de dominio portaveis, reduzindo logica pura dentro dos adapters Edge sem mudar UX, tuning, schema, contrato publico ou publicacao remota.

## Multiagentes

- Explorer `Zeno`: mapeou `battle/index.ts` e recomendou preservar replay como leitura de log salvo, com proximos cortes em combatant mapping e scoring.
- Explorer `Descartes`: mapeou Base/Economy/Progression e recomendou a Base como primeiro corte seguro para `_shared/base_domain.ts`.

## Entregue

- Criados modulos espelhados `server/functions/_shared/base_domain.ts` e `supabase/functions/_shared/base_domain.ts`.
- Criados modulos espelhados `server/functions/_shared/battle_log_projection.ts` e `supabase/functions/_shared/battle_log_projection.ts`.
- `base/index.ts` agora mantem apenas auth, HTTP, Supabase REST/RPC, idempotencia e erros; regras/projecao puras da Base foram extraidas.
- `battle/index.ts` agora projeta `battle_log_v1`, historico e metadata de ruleset pelo modulo compartilhado, sem rerodar simulador no replay.
- Criados testes Deno `server/tests/base_domain_test.ts` e `server/tests/battle_log_projection_test.ts`.
- `server/tests/integer_bones_contract_test.ts` foi atualizado para proteger a regra de Ossos no dominio portavel em vez de acoplar o contrato ao adapter antigo.
- `tools/check_foundation_expansion_readiness.ps1`, `tools/validate_foundation.ps1` e `server/tests/README.md` foram atualizados para incluir a nova fatia.
- Status vivos de DraxosMobile, Track 17, portfolio e runbook de readiness foram atualizados.

## Validacao Executada

- `npx -y deno fmt` nos arquivos TypeScript tocados: PASS.
- `npx -y deno check` nos adapters/modulos/testes tocados: PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- `npx -y deno test --allow-read server/tests/base_domain_test.ts server/tests/battle_log_projection_test.ts server/tests/foundation_ruleset_test.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts`: PASS.
- `npx -y deno test --allow-read server/tests/integer_bones_contract_test.ts server/tests/base_domain_test.ts server/tests/battle_log_projection_test.ts server/tests/foundation_ruleset_test.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts`: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .`: PASS.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick`: PASS.
- `npx -y deno check/run server/tests/transactional_edge_rpc_smoke.ts`: PASS contra Supabase local em `http://127.0.0.1:54321`.
- `npx -y deno check/run server/tests/battle_history_replay_smoke.ts`: PASS contra Supabase local.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -IncludeLocalEdgeRpc`: PASS.
- `git diff --check`: PASS.

## Bloqueios

- Nenhuma publicacao remota foi executada.
- Nenhuma migration nova foi criada nesta fatia.
- O split portavel ainda nao cobre battle combatant mapping, progression/power projection ou economy application.

## Proximo Handoff

Proximo owner seguro: continuar o split portavel em uma destas frentes, sem tuning ou feature nova:

1. battle combatant mapping e metadata de replay;
2. progression/power projection;
3. economy application/source-sink projection.
