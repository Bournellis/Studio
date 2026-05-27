# Track 06 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FEATURE_INSTALLATION`
- Depends On: `T05_INTEGRATED_FOUNDATION_READY`
- Current Stage: `T06_I_PARTIAL_INTEGRATION`
- Next Action: integrate T06-D/F/G/H client slices, then integrate T06-E Battle History when ready.

## Estado

Track 06 is active as the first feature installation package after the Track 05 foundation baseline.

The track deliberately prioritizes solid installation rails and small visible feature slices over tuning. Progression Lab remains available, but economy, power, bots, rewards, shop and combat numbers are not active objectives in this track.

T06-F Base Routine is ready for integration: the Base tab now has a render-only routine panel derived from existing `base/state` payloads, showing collect readiness, active jobs, free construction slots and a readable next upgrade without endpoint, schema, economy, queue or message contract changes.

## Ordem Atual

1. `T06-A` Coordenacao: complete.
2. `T06-B` Feature Rails: ready for handoff; feature registry now defines the standard install contract, smoke/GUT rule by surface, fallback and rollback checklist.
3. `T06-C` Runtime Config: integrated into the T06 integration base.
4. `T06-D` Perfil/Conta: ready for integration; panel renders existing session/account state, active save, username, level, power, auth method, update state and alpha status without a new endpoint.
5. `T06-E` Battle History: pending after T06-B merge; must fill feature card before runtime.
6. `T06-F` Base Routine: ready for integration; panel derives routine/next objective from existing Base payload and is covered by GUT plus `smoke_foundation_surfaces.gd`.
7. `T06-G` Social QoL: ready for integration; improves Social readability, empty states, refresh/polling clarity and current message formatting without endpoint/schema changes.
8. `T06-H` Asset Pack 01: pending after T06-B merge; must fill feature card before runtime.
9. `T06-I` Integracao: blocked until T06-C to T06-H are delivered.

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not create `account_profiles` + `game_saves`.
- Do not change economy, combat, reward, bot, shop or power numbers.
- Do not publish builds or mutate remote release state.
- Do not put secrets or service role data in client/export or runtime config.
- Keep missing art allowed.

## T06-C Runtime Config

Status: `READY_FOR_INTEGRATION`.

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

- Status: `READY_FOR_INTEGRATION`
- Delivered: Hub profile/account panel using existing `SessionStore`, current `account/state` snapshot, active save metadata and update gate state.
- Client files: `modes/boot/surfaces/hub_account_surface_presenter.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`.
- Tests/smoke: `tests/client/test_boot_mobile_ui.gd`, `tools/smoke_session_shell.gd`.
- Guardrails preserved: no endpoint, Auth, Supabase schema, persisted `SessionStore` contract, `BackendConfig`, economy, combat, ranking or remote manifest change.

## T06-G Delivery Note

Branch `codex/draxos-mobile/t06-social-qol` keeps Social QoL client-only. It updates the render-only Social presenter, focused GUT coverage and `smoke_foundation_surfaces.gd` assertions for current chat messages, guild members and structures. No new endpoint, schema, realtime, moderation, ranking behavior, backend mutation or Progression Lab leaderboard behavior was added.

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

## Expected Final Integration Validation

- `tools/validate.gd`
- GUT client completo
- `tools/smoke_session_shell.gd`
- `tools/smoke_battle_replay.gd`
- `tools/smoke_foundation_surfaces.gd`
- `tools/smoke_exports.gd`
- New runtime config smoke
- New battle history/replay smoke
- GUT for Profile, Base Routine, Social QoL and AssetIds/fallback as applicable
- Deno checks for `supabase/functions` and `server/functions`
- `git diff --check`

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
