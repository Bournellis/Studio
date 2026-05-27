# Track 08 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FOUNDATION_HARDENING`
- Depends On: `T07_INTEGRATED_PRESENTATION_READY`
- Current Stage: `T08_E_COMPLETE`
- Next Action: continue T08-C/T08-D/T08-F in parallel; T08-G remains blocked until T08-B to T08-F are all integrated.

## Estado

Track 08 is active as the post-presentation foundation hardening pass.

The project now has a mobile-first Refugio home, route shell, internal surfaces and fullscreen landscape battle. The next risk is structural drift while adding future features: routes living only inside `boot.gd`, session/save boundary assumptions spread across client code, touch/layout rules copied per surface, battle fullscreen behavior needing mode-level contract, and validation becoming hard to remember.

T08-B App Shell Lifecycle is complete in `codex/draxos-mobile/t08-app-shell-lifecycle`. It introduced `DraxosAppShellRouteContract` as a small route/back/orientation helper under `modes/boot/ui/`, kept `boot.gd` as the orchestrator, and added GUT coverage for legacy aliases, Refugio root behavior, nested back stack, `battle_running` landscape preference and battle summary return to Refugio.

T08-E Battle Mode Contract is complete in `codex/draxos-mobile/t08-battle-mode-contract`. It extended `DraxosAppShellRouteContract` with explicit battle gameplay-mode rules, hides app chrome for fullscreen `battle_running`/`battle_summary`, keeps skip as the only replay-safe action, forces completed replays through the summary route, and covers read-only history/replay actions plus return to Refugio in GUT. Guardrails preserved: no simulator, `battle_log_v1`, reward, ranking or `battle/*` endpoint changes.

## Ordem Atual

1. `T08-A` Coordenacao/Audit: complete; opened the track and recorded the foundation gap report.
2. `T08-B` App Shell Lifecycle: complete; route/back/orientation contract helper and tests delivered.
3. `T08-C` Session/Save Boundary: pending after T08-A.
4. `T08-D` Mobile UI Contract: pending after T08-A.
5. `T08-E` Battle Mode Contract: complete; fullscreen battle/replay contract and tests delivered.
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

Latest T08-E validation:

- `tools/smoke_battle_replay.gd`: default local Edge Runtime returned `NOT_FOUND` for `/battle/history`; passed after serving the current worktree `battle` function on `http://127.0.0.1:8000` and setting `BATTLE_FUNCTION_URL=http://127.0.0.1:8000`.
- GUT client complete: passed, `89/89` tests and `1031` asserts.
- `tools/validate.gd`: passed, including GUT `89/89` tests and `1031` asserts.
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
