# Track 05 - Current Status

- Last Updated: `2026-05-27`
- Status: `INTEGRATED_FOUNDATION_READY`
- Depends On: `T04_A_TO_H_INTEGRATED`
- Next Action: run the human Progression Lab review, then open follow-up tracks for real assets and new services on top of the stabilized foundation.

## Estado

Track 05 is integrated as a foundation stabilization package. Internal Alpha v0 passed, Track 04 integrated Hub render-only presenters, and Track 05 now provides a reproducible validation matrix, focused surface smoke coverage, Hub/presenter hardening, service scope contracts, an asset pipeline contract, a human Progression Lab review pack and release ops readiness.

No final art, new service, economy tuning, schema migration or gameplay expansion is approved in this track.

## Ordem Atual

1. `T05-A` Coordenacao: complete.
2. `T05-B` Validation Matrix: complete, with `quick/full/release/remote` matrix and `smoke_foundation_surfaces.gd`.
3. `T05-C` Hub Foundation: complete, with render-only presenter contract coverage and retired obsolete Battle scaffold.
4. `T05-D` Service Contracts: complete, with endpoint scopes classified as `save-scoped`, `account-scoped`, `release`, `telemetry` or `admin-future`.
5. `T05-E` Asset Pipeline: complete, with asset conventions, category ids, stable paths and missing-art fallback tests.
6. `T05-F` Progression Human Pack: complete, with human review runbook before tuning.
7. `T05-G` Release Ops: complete, with release-ready checklist and remote artifact smoke.
8. `T05-H` Integracao: complete, with final validation green.

## T05-F Progression Human Pack

Status: `READY_FOR_HUMAN_REVIEW` integrated through branch `codex/draxos-mobile/t05-integration`.

- Runbook: `../../../docs/progression-lab/2026-05-27-t05-progression-human-runbook.md`
- Track notes: `progression-human-pack.md`
- Focus cases: `spender_light_10h`, `max_spender_10h`, `max_spender_20h`, `free_100_rewards_20h`, `freemium_basic_20h`
- Decision criteria covered: premium gap, `20h` window, bridge bots, resources and power weights
- Guardrail: no economy, power, bot, shop, reward, resource or combat number changes in this package

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not create `account_profiles` + `game_saves`.
- Do not change economy, combat, reward, bot, shop or power numbers.
- Do not import final assets.
- Do not publish builds or mutate remote release state from Track 05 worktrees.

## Validation Baseline

Documentation-only packages:

```powershell
git diff --check
```

Client packages:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://tools/validate.gd
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path <WORKTREE>\Projetos\draxos-mobile -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/client -gexit
git diff --check
```

Backend/test packages:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
npx -y deno task --cwd supabase/functions check
npx -y deno task --cwd server/functions check
git diff --check
```

## Final Integration Validation

Validated on `2026-05-27` in `D:\Estudio-worktrees\draxos-mobile--codex--t05-integration`:

- Pass: `tools/validate.gd` with `63/63` tests and `696` asserts.
- Pass: GUT client with `63/63` tests and `696` asserts.
- Pass: `tools/smoke_session_shell.gd`.
- Pass: `tools/smoke_battle_replay.gd`.
- Pass: `tools/smoke_foundation_surfaces.gd`.
- Pass: `tools/smoke_dev_labs.gd`.
- Pass: `tools/smoke_dev_lab_ui.gd`.
- Pass: `tools/smoke_exports.gd`.
- Pass: `npx -y deno task --cwd supabase/functions check`.
- Pass: `npx -y deno task --cwd server/functions check`.
- Pass: `npx -y deno check server/tests/release_artifacts_remote_smoke.ts`.
- Pass: `npx -y deno lint server/tests/release_artifacts_remote_smoke.ts`.
- Pass: `git diff --check`.

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Prompts: `agent-prompts.md`
- Track 04 status: `../track-04-post-handoff-hardening-and-hub-modularization/current-status.md`
- Product vision: `../../../docs/product-vision.md`
- Design pending: `../../../docs/design-pending.md`
