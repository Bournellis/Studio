# Track 17 - Foundation Expansion Readiness

- Status: `FOUNDATION_EXPANSION_READINESS_ACTIVE`
- Started: `2026-05-30`
- Branch: `codex/draxos-mobile/foundation-expansion-readiness`
- Goal: prepare DraxosMobile for production future, parallel expansion and multiple agents before base builder, autobattler, social expansion or a real minigame.

## Decisions

- Target is future production readiness, not only Internal Alpha convenience.
- Supabase remains the alpha backend, but contracts must stay portable to Backend Proprio + Postgres.
- Account/save authority moves to `account_profiles` + `game_saves`; `players.save_type` stays compatibility only.
- Ruleset uses generated repo artifact as source of authorship and database registry as publication record.
- Admin is minimum auditable, not a public panel.
- New minigames are blocked until contract-first integration is complete.

## Lanes

| Lane | Delivered |
|---|---|
| Docs/Contracts/Integration | `foundation-expansion-readiness.md`, account/save, ruleset registry, minigame and admin contracts, status/index updates |
| Backend/Data | additive migration, account/save tables, ruleset registry, admin audit log, idempotency v1 fields and RPC scaffolds |
| Backend/Domain Enforcement | Base collect/upgrade, battle rewards, monetization rewards/alpha purchase, build equip, crafting craft/crush-bones and guild create/join promoted from REST multi-step writes to v1 transactional RPCs; `base/state` uses atomic due-job completion |
| Ruleset/Content | `foundation_ruleset_v0`, deterministic generator, server/supabase mirrors and Deno test |
| Client Shell | `DraxosOperationState`, `DraxosAppShellActionRouter`, GUT shell contract test |
| QA/Golden Tests | structural checker integrated into `validate_foundation.ps1`; schema/ruleset/client tests; local Supabase transactional RPC live proof |
| Release/Ops/Admin | release checklist/admin contract updated for audited operations and no-secret guardrails |

## Implemented Files

- `docs/foundation-expansion-readiness.md`
- `docs/contracts/account-save.md`
- `docs/contracts/ruleset-registry.md`
- `docs/contracts/minigame-integration.md`
- `docs/contracts/admin-ops.md`
- `data/rulesets/foundation_ruleset_v0.json`
- `tools/generate_foundation_ruleset.ts`
- `tools/check_foundation_expansion_readiness.ps1`
- `server/schema/migrations/202605300001_foundation_expansion_readiness.sql`
- `supabase/migrations/202605300001_foundation_expansion_readiness.sql`
- `server/schema/migrations/202605300002_transactional_domain_enforcement.sql`
- `supabase/migrations/202605300002_transactional_domain_enforcement.sql`
- `server/schema/migrations/202605300003_remaining_transactional_domain_enforcement.sql`
- `supabase/migrations/202605300003_remaining_transactional_domain_enforcement.sql`
- `server/functions/_shared/foundation_ruleset.ts`
- `supabase/functions/_shared/foundation_ruleset.ts`
- `server/functions/_shared/transactional_mutation.ts`
- `supabase/functions/_shared/transactional_mutation.ts`
- `server/functions/battle/index.ts`
- `supabase/functions/battle/index.ts`
- `server/functions/build/index.ts`
- `supabase/functions/build/index.ts`
- `server/functions/crafting/index.ts`
- `supabase/functions/crafting/index.ts`
- `server/functions/monetization/index.ts`
- `supabase/functions/monetization/index.ts`
- `server/functions/social/index.ts`
- `supabase/functions/social/index.ts`
- `server/functions/base/index.ts`
- `supabase/functions/base/index.ts`
- `modes/boot/ui/operation_state.gd`
- `modes/boot/ui/app_shell_action_router.gd`
- `server/tests/foundation_expansion_schema_test.ts`
- `server/tests/transactional_domain_enforcement_schema_test.ts`
- `server/tests/remaining_transactional_domain_enforcement_schema_test.ts`
- `server/tests/transactional_rpc_live_test.ts`
- `server/tests/foundation_ruleset_test.ts`
- `tests/client/test_foundation_shell_contracts.gd`

## Current Limits

- Critical economy/social mutations no longer use REST multi-step writes for their core effects: Base collect/upgrade, `FIRST_SLICE_SIM` battle persistence/rewards/consumables/ranking, reward claim, alpha purchase, build equip, crafting craft/crush-bones and guild create/join now reserve/complete idempotency and mutate state in RPCs.
- Live database failure/retry/idempotency proof exists in `server/tests/transactional_rpc_live_test.ts` for battle rewards, build equip, crafting, reward claim, alpha purchase and guild create/join; it passed against a reset local Supabase stack on `2026-05-30`.
- Local Edge Function HTTP smokes over the promoted adapters are still useful before treating the adapter layer as fully production-grade.
- Migration is additive and not pushed remotely in this package.
- No new gameplay, balance, social expansion or minigame is included.

## Validation Targets

```powershell
npx -y deno test --allow-read server/tests/foundation_expansion_schema_test.ts
npx -y deno test --allow-read server/tests/transactional_domain_enforcement_schema_test.ts
npx -y deno test --allow-read server/tests/remaining_transactional_domain_enforcement_schema_test.ts
npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts
deno run --allow-net --allow-env server/tests/transactional_rpc_live_test.ts
npx -y deno task --cwd server/functions check
npx -y deno task --cwd supabase/functions check
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick -IncludeLocalSupabaseRpc
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/client/test_foundation_shell_contracts.gd -gexit
git diff --check
```

Full release/client validation remains `validate_foundation.ps1 -Profile Full` before any publication or merge gate.
