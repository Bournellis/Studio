# Track 06 - Current Status

- Last Updated: `2026-05-27`
- Status: `INTEGRATED_FEATURE_SLICES_READY`
- Depends On: `T05_INTEGRATED_FOUNDATION_READY`
- Current Stage: `T06_I_COMPLETE`
- Next Action: manual walkthrough of Track 06 slices in the app, then decide Track 07 feature/service package.

## Estado

Track 06 is integrated as the first feature installation package after the Track 05 foundation baseline.

The track deliberately prioritizes solid installation rails and small visible feature slices over tuning. Progression Lab remains available, but economy, power, bots, rewards, shop and combat numbers are not active objectives in this track.

T06-I integrated the feature rails, runtime config, profile/account panel, Battle History/replay, Base Routine, Social QoL and Asset Pack 01. The package keeps the Track 06 rule: visible slices and service rails only, without tuning, account/save migration, payment, realtime social or remote publication.

## Ordem Atual

1. `T06-A` Coordenacao: complete and on master.
2. `T06-B` Feature Rails: integrated; feature registry defines the standard install contract, smoke/GUT rule by surface, fallback and rollback checklist.
3. `T06-C` Runtime Config: integrated; `GET /release/config` and Godot fallback path are in the package.
4. `T06-D` Perfil/Conta: integrated; panel renders existing session/account state, active save, username, level, power, auth method, update state and alpha status without a new endpoint.
5. `T06-E` Battle History: integrated; delivered save-scoped read-only `GET /battle/history`, `GET /battle/replay?battle_id=...`, Battle tab history/replay UI and focused smokes/GUT without simulator/reward/schema changes.
6. `T06-F` Base Routine: integrated; panel derives routine/next objective from existing Base payload and is covered by GUT plus `smoke_foundation_surfaces.gd`.
7. `T06-G` Social QoL: integrated; improves Social readability, empty states, refresh/polling clarity and current message formatting without endpoint/schema changes.
8. `T06-H` Asset Pack 01: integrated; installs lightweight PNGs for selected UI, portrait and battle icon ids with native fallback still valid.
9. `T06-I` Integracao: complete; final validation passed with one operational note for local function refresh.

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not create `account_profiles` + `game_saves`.
- Do not change economy, combat, reward, bot, shop or power numbers.
- Do not publish builds or mutate remote release state.
- Do not put secrets or service role data in client/export or runtime config.
- Keep missing art allowed.

## T06-C Runtime Config

Status: `INTEGRATED`.

Entregas:

- `GET /release/config` no release service como endpoint `release`, read-only, sem JWT obrigatorio e sem `x-draxos-save-type`.
- Payload `runtime_config_v1` com flags T06 allowlisted e defaults conservadores.
- Overrides operacionais limitados a campos allowlisted; flags desconhecidas sao ignoradas.
- Cliente Godot com `RuntimeConfig`, URL derivada de `BackendConfig`, `SupabaseClient.fetch_runtime_config()`, fallback conservador no `SessionStore` e fetch inicial no Boot.
- Contrato e smokes focados documentados.

Guardrails preservados: sem schema/migration, sem economia, combate, tuning, secrets, service role, player/save state, publicacao remota ou mutacao de release remoto.

Validacao T06-C:

- `npx -y deno task --cwd supabase/functions check` passou.
- `npx -y deno task --cwd server/functions check` passou.
- `npx -y deno check server/tests/runtime_config_smoke.ts` passou.
- `tools/smoke_runtime_config.gd` passou.
- `tools/validate.gd` passou com `66/66` testes e `722` asserts.
- GUT client passou com `66/66` testes e `722` asserts.
- `release_manifest_smoke.ts` e `runtime_config_smoke.ts` passaram contra `server/functions/release/index.ts` servido localmente via Deno em `127.0.0.1:8000`.
- `runtime_config_smoke.ts` passou contra `supabase/functions/release/index.ts` servido localmente via Deno em `127.0.0.1:8000`.

Nota operacional: o Supabase local ja rodando em `127.0.0.1:54321` ainda servia a funcao antiga e retornou `404 Unknown release endpoint` para `/release/config`; o smoke HTTP da funcao nova foi validado por serve Deno isolado sem publicar ou tocar remoto.

## T06-D Handoff

- Status: `INTEGRATED`
- Delivered: Hub profile/account panel using existing `SessionStore`, current `account/state` snapshot, active save metadata and update gate state.
- Client files: `modes/boot/surfaces/hub_account_surface_presenter.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`.
- Tests/smoke: `tests/client/test_boot_mobile_ui.gd`, `tools/smoke_session_shell.gd`.
- Guardrails preserved: no endpoint, Auth, Supabase schema, persisted `SessionStore` contract, `BackendConfig`, economy, combat, ranking or remote manifest change.

## T06-G Delivery Note

Social QoL is integrated and remains client-only. It updates the render-only Social presenter, focused GUT coverage and `smoke_foundation_surfaces.gd` assertions for current chat messages, guild members and structures. No new endpoint, schema, realtime, moderation, ranking behavior, backend mutation or Progression Lab leaderboard behavior was added.

## T06-H Asset Pack 01 Update

`ASSET_PACK_01_SAFE` is integrated. The package adds lightweight
128x128 transparent PNGs for `icon_guest`, `icon_battle`, `icon_result`,
`portrait_draxos_mage`, `portrait_training_bot` and the existing
`battle_icon_*` ids. It also adds an optional `BattleSymbolIcon` texture hook for
the battle stage; if a texture is absent, the native symbol/circle fallback stays
active. No backend, schema, economy, tuning, remote asset or broad visual rework
was introduced.

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

Backend/service packages:

```powershell
cd <WORKTREE>\Projetos\draxos-mobile
npx -y deno task --cwd supabase/functions check
npx -y deno task --cwd server/functions check
git diff --check
```

## Final Integration Validation

- `tools/validate.gd`: passed with `73/73` tests and `843` asserts.
- GUT client completo: passed with `73/73` tests and `843` asserts.
- `tools/smoke_session_shell.gd`: passed.
- `tools/smoke_runtime_config.gd`: passed.
- `tools/smoke_battle_replay.gd`: passed against the worktree-served current `battle` function with `BATTLE_FUNCTION_URL=http://127.0.0.1:8000`.
- `tools/smoke_foundation_surfaces.gd`: passed.
- `tools/smoke_dev_labs.gd`: passed.
- `tools/smoke_dev_lab_ui.gd`: passed headless, with screenshots skipped by renderer as expected.
- `tools/smoke_exports.gd`: passed.
- `npx -y deno task --cwd supabase/functions check`: passed.
- `npx -y deno task --cwd server/functions check`: passed.
- `npx -y deno check server/tests/battle_history_replay_smoke.ts`: passed.
- `git diff --check`: passed.

Operational note: the already-running Supabase local Edge Runtime at `127.0.0.1:54321` still served an older `battle` function and returned `404 Unknown battle endpoint` for `/battle/history`. The new Track 06 battle function was validated by serving the worktree function locally on `127.0.0.1:8000`; restart/redeploy local functions before expecting `/battle/history` on the default Supabase local endpoint.

## T06-E Battle History Handoff

Status: `INTEGRATED`.

Delivered:

- `GET /battle/history` returns recent saved battle summaries for the active save.
- `GET /battle/replay?battle_id=...` returns the stored `battle_log_v1` for a battle owned by the active save.
- Battle tab now has a History action, renders recent saved battles and can replay a selected saved battle without rerunning simulation.
- `smoke_battle_replay.gd` validates history/replay when `BATTLE_FUNCTION_URL` points to the worktree-served battle function.

Guardrails preserved: no schema change, no simulator change, no reward/economy/ranking change, no `battle_log_v1` mutation and no remote publication.

## Fontes

- Escopo: `scope.md`
- Plano: `implementation-plan.md`
- Feature registry: `feature-registry.md`
- Agent registry: `agent-registry.md`
- Prompts: `agent-prompts.md`
- Track 05 status: `../track-05-foundation-stabilization-and-asset-service-readiness/current-status.md`
- Product vision: `../../../docs/product-vision.md`
- Contracts: `../../../docs/contracts/`
- Asset pipeline: `../../../assets/README.md`
