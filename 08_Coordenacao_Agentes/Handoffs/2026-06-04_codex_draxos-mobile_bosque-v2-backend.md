# DraxosMobile Hardening Handoff: backend-schema - Bosque V2 Guidance Persistence

## Metadata

- from: `Codex`
- to: `Usuario | client-shell | backend-schema`
- date: `2026-06-04`
- projeto: `draxos-mobile`
- prioridade_portfolio: `P2_IMPLEMENTACAO`
- lane: `backend-schema`
- mode_scope: `openworld`
- branch: `codex/draxos-mobile/bosque-v2-backend`
- worktree: `D:\Estudio-worktrees\draxos-mobile--codex--bosque-v2-backend`
- commits: `backend guidance persistence commit on this branch; final SHA reported in final response`

## Contexto

Backend-schema lane para Bosque Mecanico Basico v2 guidance persistence. A entrega preserva o Openworld Bosque v1 ativo, adicionando estado leve de orientacao no save normal e no fluxo de snapshot/event ACK sem mudar recompensa, caps, economia, ledger, completion authority, collect/deposit/craft/complete/abandon semantics ou Progression Lab/offline preview.

## Current State

- latest Arena loop package considered: `Track 21 - Arena Loop Unlock And Friction Pass`
- runtime touched: `yes, backend Edge/shared helpers and SQL migrations only`
- remote mutation/publication run: `no`
- worktree clean at handoff: `yes after backend guidance persistence commit`

## Changed Files

- `08_Coordenacao_Agentes/Kanban/Doing/2026-06-04_codex_draxos-mobile_bosque-v2-backend.md`
- `08_Coordenacao_Agentes/Handoffs/2026-06-04_codex_draxos-mobile_bosque-v2-backend.md`
- `Projetos/draxos-mobile/server/schema/migrations/202606040001_openworld_guidance_persistence_v1.sql`
- `Projetos/draxos-mobile/supabase/migrations/202606040001_openworld_guidance_persistence_v1.sql`
- `Projetos/draxos-mobile/server/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/mode_domain.ts`
- `Projetos/draxos-mobile/server/functions/_shared/transactional_mutation.ts`
- `Projetos/draxos-mobile/supabase/functions/_shared/transactional_mutation.ts`
- `Projetos/draxos-mobile/server/tests/modes_domain_test.ts`
- `Projetos/draxos-mobile/server/tests/modes_platform_schema_test.ts`
- `Projetos/draxos-mobile/server/tests/openworld_ruleset_definition_test.ts`

## Decisions Made

- `guidance_storage`: canonical lightweight state is persisted for `normal` saves at `game_saves.snapshot.openworld.forest.guidance`.
- `guidance_shape`: server normalizes `version=1`, `current_step`, `completed_steps`, `dismissed` and `last_seen_at`; invalid/missing values become safe defaults.
- `guidance_event`: `guidance_update` is an idempotent Openworld session event using the existing `modes/session/event` request hash and revision gate.
- `guidance_flow`: guidance is included in Openworld session snapshot payloads, event ACK `snapshot_patch`, `/modes/state` top-level `guidance`, and new session initial snapshots loaded from the normal save.
- `non_goals`: no reward bridge, ledger, caps, completion, collect/deposit/craft/abandon or Progression Lab persistence changes.

## Validation

- `git diff --check`: `PASS`
- `npx -y deno task --cwd server/functions check`: `PASS`
- `npx -y deno task --cwd supabase/functions check`: `PASS`
- `npx -y deno test --allow-read Projetos/draxos-mobile/server/tests/modes_domain_test.ts Projetos/draxos-mobile/server/tests/modes_platform_schema_test.ts Projetos/draxos-mobile/server/tests/openworld_ruleset_definition_test.ts Projetos/draxos-mobile/server/tests/openworld_reward_bridge_test.ts`: `PASS`, 29 passed
- `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\validate_foundation.ps1 -ProjectDir . -Profile ServerQuick`: `FAIL`, backend/foundation stages passed, but unrelated PVE Arena client contract test `client Arena loop removes loadout click and continues inside Arena` failed because `arena_loop_unlock_friction_test.ts` expected `Proximo desafio`

## Blockers

- Broad `ServerQuick` is not fully green because of the existing/out-of-scope PVE Arena client text expectation above. This lane did not touch Arena client files.
- No local database migration execution was run. Per task rule, no `supabase db push` or remote mutation was executed.

## Recommended Next Step

Client/guidance lane can consume `guidance_update` through existing `/modes/session/event`, read `guidance` from `active_session.snapshot_payload.guidance`, `snapshot_patch.guidance` or `/modes/state.guidance`, and avoid adding any separate server persistence path outside the normal save.
