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
| Ruleset/Content | `foundation_ruleset_v0`, deterministic generator, server/supabase mirrors and Deno test |
| Client Shell | `DraxosOperationState`, `DraxosAppShellActionRouter`, GUT shell contract test |
| QA/Golden Tests | structural checker integrated into `validate_foundation.ps1`; schema/ruleset/client tests |
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
- `server/functions/_shared/foundation_ruleset.ts`
- `supabase/functions/_shared/foundation_ruleset.ts`
- `modes/boot/ui/operation_state.gd`
- `modes/boot/ui/app_shell_action_router.gd`
- `server/tests/foundation_expansion_schema_test.ts`
- `server/tests/foundation_ruleset_test.ts`
- `tests/client/test_foundation_shell_contracts.gd`

## Current Limits

- Existing endpoints still use several REST multi-step mutations. The foundation reserves v1 transactional RPCs, but the full domain-service rewrite is the next backend hardening step.
- Migration is additive and not pushed remotely in this package.
- No new gameplay, balance, social expansion or minigame is included.

## Validation Targets

```powershell
npx -y deno test --allow-read server/tests/foundation_expansion_schema_test.ts
npx -y deno test --allow-read server/tests/foundation_ruleset_test.ts
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\check_foundation_expansion_readiness.ps1 -ProjectDir .
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile Quick
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/client/test_foundation_shell_contracts.gd -gexit
git diff --check
```

Full release/client validation remains `validate_foundation.ps1 -Profile Full` before any publication or merge gate.
