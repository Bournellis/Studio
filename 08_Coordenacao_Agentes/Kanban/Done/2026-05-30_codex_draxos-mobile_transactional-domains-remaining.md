# Multi-Agent Done: DraxosMobile Remaining Transactional Domains

## Metadata

- data: `2026-05-30`
- agente: `Codex`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- branch: `codex/draxos-mobile/foundation-expansion-readiness`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--foundation-expansion-readiness`

## Objetivo

Continuar Foundation Expansion Readiness promovendo as mutations restantes de economia/social para o padrao transacional v1 depois da Base: battle rewards, monetization rewards/alpha-purchase, build/crafting e guild create/join.

## Base Lida

- `C:\Users\Fabio\.codex\skills\estudio-workspace\SKILL.md`
- `Projetos/draxos-mobile/AGENTS.md`
- `Projetos/draxos-mobile/docs/agent-operating-manual.md`
- `Projetos/draxos-mobile/docs/documentation-index.md`
- `Projetos/draxos-mobile/implementation/current-status.md`

## Escopo

- Incluir: nova migration espelhada, adapters HTTP/Supabase por dominio, testes Deno/static e docs/status/handoff.
- Fora do escopo: tuning numerico, nova UX, novo minigame, social expandido alem de guild create/join existentes, publicacao remota e secrets.

## Arquivos Pretendidos

- `Projetos/draxos-mobile/supabase/migrations/`
- `Projetos/draxos-mobile/server/schema/migrations/`
- `Projetos/draxos-mobile/server/functions/battle/index.ts`
- `Projetos/draxos-mobile/supabase/functions/battle/index.ts`
- `Projetos/draxos-mobile/server/functions/monetization/index.ts`
- `Projetos/draxos-mobile/supabase/functions/monetization/index.ts`
- `Projetos/draxos-mobile/server/functions/build/index.ts`
- `Projetos/draxos-mobile/supabase/functions/build/index.ts`
- `Projetos/draxos-mobile/server/functions/crafting/index.ts`
- `Projetos/draxos-mobile/supabase/functions/crafting/index.ts`
- `Projetos/draxos-mobile/server/functions/social/index.ts`
- `Projetos/draxos-mobile/supabase/functions/social/index.ts`
- `Projetos/draxos-mobile/server/tests/`
- `Projetos/draxos-mobile/docs/contracts/`
- `Projetos/draxos-mobile/implementation/current-status.md`
- `Projetos/draxos-mobile/implementation/tracks/track-17-foundation-expansion-readiness/current-status.md`

## Validacao

- `npx -y deno check server/functions/battle/index.ts server/functions/build/index.ts server/functions/crafting/index.ts server/functions/monetization/index.ts server/functions/social/index.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts` - passou.
- `npx -y deno test --allow-read server/tests/foundation_contracts_test.ts server/tests/foundation_expansion_schema_test.ts server/tests/transactional_domain_enforcement_schema_test.ts server/tests/remaining_transactional_domain_enforcement_schema_test.ts server/tests/foundation_ruleset_test.ts server/tests/integer_bones_contract_test.ts` - passou, `21/21`.
- `git diff --check` - passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .` - passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick` - passou.
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Full` - passou; GUT `128/128`, `2029` asserts; warnings de Orphans/ObjectDB ja conhecidos no gate.

## Entregue

- Nova migration espelhada `202605300003_remaining_transactional_domain_enforcement.sql`.
- Helper espelhado `transactional_mutation.ts` para resolver `game_saves`, calcular `request_hash` e mapear erros de RPC v1.
- `battle/request` no path `FIRST_SLICE_SIM` agora persiste battle row, rewards, consumiveis, ranking e idempotencia via `request_battle_v1`.
- `monetization/rewards/claim` e `monetization/alpha-purchase` agora aplicam claim/compra, saldos, progress e ledger via RPCs v1.
- `build/equip`, `crafting/craft`, `crafting/crush-bones`, `guild/create` e `guild/join` agora usam RPCs transacionais v1.
- Teste `remaining_transactional_domain_enforcement_schema_test.ts` cobre migration, grants, wrappers, mirrors e adapters.
- Docs/contratos/status/checkers atualizados para marcar a promocao como ativa.

## Multiagentes

- `Kant`: explorer para battle + monetization.
- `Goodall`: explorer para build/crafting + social.

## Proximo Handoff

Proximo passo seguro: commit por estagio e handoff. A lacuna tecnica restante e teste live/local de rollback/retry contra Supabase real para provar falha parcial em runtime, alem dos contratos estaticos ja adicionados.
