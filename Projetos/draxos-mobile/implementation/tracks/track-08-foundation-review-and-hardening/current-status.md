# Track 08 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FOUNDATION_HARDENING`
- Depends On: `T07_INTEGRATED_PRESENTATION_READY`
- Current Stage: `T08_B_T08_C_T08_D_COMPLETE`
- Next Action: continue integrating T08-E/T08-F, then create T08-G validation harness and close T08-H.

## Estado

Track 08 is active as the post-presentation foundation hardening pass.

The project now has a mobile-first Refugio home, route shell, internal surfaces and fullscreen landscape battle. The next risk is structural drift while adding future features: routes living only inside `boot.gd`, session/save boundary assumptions spread across client code, touch/layout rules copied per surface, battle fullscreen behavior needing mode-level contract, and validation becoming hard to remember.

T08-B App Shell Lifecycle is complete in `codex/draxos-mobile/t08-app-shell-lifecycle`. It introduced `DraxosAppShellRouteContract` as a small route/back/orientation helper under `modes/boot/ui/`, kept `boot.gd` as the orchestrator, and added GUT coverage for legacy aliases, Refugio root behavior, nested back stack, `battle_running` landscape preference and battle summary return to Refugio.

T08-C Session/Save Boundary is complete in `codex/draxos-mobile/t08-session-save-boundary`. It hardened `SessionStore`/`SupabaseClient` invariants for save-scoped response context, stale response rejection after save switches, surface snapshots, Progression Lab local-only cache and non-secret diagnostics without changing Auth, HTTP contracts, schema, `players.save_type` or public payloads.

T08-D Mobile UI Contract is complete in `codex/draxos-mobile/t08-mobile-ui-contract`. It adds `DraxosMobileUiContract` as the small shared contract for minimum touch target, touch-scroll drag threshold, scrollbar/touch policy and portrait/landscape layout columns. `DraxosTouchScrollContainer`, `boot.gd` and existing shell/base buttons now reuse the helper without redesign, new assets, backend/schema changes or gameplay changes.

## Ordem Atual

1. `T08-A` Coordenacao/Audit: complete; opened the track and recorded the foundation gap report.
2. `T08-B` App Shell Lifecycle: complete; route/back/orientation contract helper and tests delivered.
3. `T08-C` Session/Save Boundary: complete; session/save/cache/runtime config invariants and diagnostics delivered.
4. `T08-D` Mobile UI Contract: complete; centralized touch/scroll/button/layout rules and covered them in GUT plus mobile presentation smoke.
5. `T08-E` Battle Mode Contract: pending after T08-B.
6. `T08-F` Service/Asset Contract Checks: pending after T08-A.
7. `T08-G` Validation Harness: pending after T08-B to T08-F.
8. `T08-H` Integracao: pending after T08-B to T08-G.

## T08-D Validation

- GUT client command with `-gtest=res://tests/client/test_boot_mobile_ui.gd`: passed; project config loaded the full client suite, `85/85` tests and `985` asserts.
- `tools/smoke_mobile_presentation.gd`: passed.
- `tools/validate.gd`: passed; `DraxosMobile validate: OK`, `85/85` tests and `985` asserts.
- `git diff --check`: passed.

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

Latest T08-B validation:

- `tools/validate.gd`: passed.
- GUT client complete: passed, `88/88` tests and `1003` asserts.
- `git diff --check`: passed.

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
