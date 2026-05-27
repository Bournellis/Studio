# Track 08 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FOUNDATION_HARDENING`
- Depends On: `T07_INTEGRATED_PRESENTATION_READY`
- Current Stage: `T08_C_COMPLETE_PENDING_INTEGRATION`
- Next Action: continue T08-B/T08-D/T08-F parallel worktrees and integrate delivered T08-C during T08-H.

## Estado

Track 08 is active as the post-presentation foundation hardening pass.

The project now has a mobile-first Refugio home, route shell, internal surfaces and fullscreen landscape battle. The next risk is structural drift while adding future features: routes living only inside `boot.gd`, session/save boundary assumptions spread across client code, touch/layout rules copied per surface, battle fullscreen behavior needing mode-level contract, and validation becoming hard to remember.

## Ordem Atual

1. `T08-A` Coordenacao/Audit: complete; opened the track and recorded the foundation gap report.
2. `T08-B` App Shell Lifecycle: pending after T08-A.
3. `T08-C` Session/Save Boundary: complete in `codex/draxos-mobile/t08-session-save-boundary`; pending Track 08 integration.
4. `T08-D` Mobile UI Contract: pending after T08-A.
5. `T08-E` Battle Mode Contract: pending after T08-B.
6. `T08-F` Service/Asset Contract Checks: pending after T08-A.
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

Latest T08-C local validation:

- `res://tests/client/test_session_shell.gd` via GUT `-gtest`: passed as part of client run with `90/90` tests and `1001` asserts after one-time headless import.
- `tools/validate.gd`: passed; includes client GUT `90/90` tests and `1001` asserts.
- Full client GUT `-gdir=res://tests/client`: passed with `90/90` tests and `1001` asserts.
- `git diff --check`: passed.

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
