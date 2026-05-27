# Track 08 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FOUNDATION_HARDENING`
- Depends On: `T07_INTEGRATED_PRESENTATION_READY`
- Current Stage: `T08_A_COMPLETE`; `T08_F_READY_FOR_INTEGRATION`
- Next Action: continue T08-B/T08-C/T08-D/T08-E/T08-G in their worktrees, then integrate T08-F in T08-H.

## Estado

Track 08 is active as the post-presentation foundation hardening pass.

The project now has a mobile-first Refugio home, route shell, internal surfaces and fullscreen landscape battle. The next risk is structural drift while adding future features: routes living only inside `boot.gd`, session/save boundary assumptions spread across client code, touch/layout rules copied per surface, battle fullscreen behavior needing mode-level contract, and validation becoming hard to remember.

T08-F is ready for integration in branch `codex/draxos-mobile/t08-service-asset-contracts`. It adds a no-network Deno test for `docs/contracts/api-endpoints.md` endpoint matrix scopes and Track 06 feature card completeness, plus focused GUT coverage that keeps optional `AssetIds` missing-art fallback stable apart from installed Asset Pack 01 ids. No endpoint, schema, migration, service or final asset was added.

## Ordem Atual

1. `T08-A` Coordenacao/Audit: complete; opened the track and recorded the foundation gap report.
2. `T08-B` App Shell Lifecycle: pending after T08-A.
3. `T08-C` Session/Save Boundary: pending after T08-A.
4. `T08-D` Mobile UI Contract: pending after T08-A.
5. `T08-E` Battle Mode Contract: pending after T08-B.
6. `T08-F` Service/Asset Contract Checks: ready for integration.
7. `T08-G` Validation Harness: pending after T08-B to T08-F.
8. `T08-H` Integracao: pending after T08-B to T08-G.

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not add gameplay, tuning, economy, reward, ranking, shop, bot, combat or power changes.
- Do not add public backend endpoints, Supabase schema, migrations or `account_profiles` + `game_saves`.
- Do not import final assets, publish builds or mutate remote release state.
- Keep `boot.gd` as orchestrator; only extract small helpers when low risk and testable.
- Keep presenters render-oriented; actions, session, network and telemetry remain host-owned unless explicitly documented.

## Validation Baseline

Client packages:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
git diff --check
```

Expected final smokes:

- `tools/smoke_session_shell.gd`
- `tools/smoke_runtime_config.gd`
- `tools/smoke_mobile_presentation.gd`
- `tools/smoke_foundation_hardening.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_exports.gd`

Backend/docs packages:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
npx -y deno check server/tests/foundation_contracts_test.ts
npx -y deno test --allow-read server/tests/foundation_contracts_test.ts
npx -y deno lint server/tests/foundation_contracts_test.ts
npx -y deno task --cwd supabase/functions check
npx -y deno task --cwd server/functions check
git diff --check
```

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Agent registry: `agent-registry.md`
- Prompts: `agent-prompts.md`
- Gap report: `foundation-gap-report.md`
- Track 07 status: `../track-07-mobile-presentation-loop-and-layout-rework/current-status.md`
- Product vision: `../../../docs/product-vision.md`
- Architecture: `../../../docs/architecture.md`
