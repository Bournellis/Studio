# Track 06 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FEATURE_INSTALLATION`
- Depends On: `T05_INTEGRATED_FOUNDATION_READY`
- Current Stage: `T06_D_READY_FOR_INTEGRATION`
- Next Action: continue T06-C and T06-E to T06-H in parallel, then integrate T06-D through T06-I.

## Estado

Track 06 is active as the first feature installation package after the Track 05 foundation baseline.

The track deliberately prioritizes solid installation rails and small visible feature slices over tuning. Progression Lab remains available, but economy, power, bots, rewards, shop and combat numbers are not active objectives in this track.

## Ordem Atual

1. `T06-A` Coordenacao: complete.
2. `T06-B` Feature Rails: ready for handoff; feature registry now defines the standard install contract, smoke/GUT rule by surface, fallback and rollback checklist.
3. `T06-C` Runtime Config: pending after T06-A.
4. `T06-D` Perfil/Conta: ready for integration; panel renders existing session/account state, active save, username, level, power, auth method, update state and alpha status without a new endpoint.
5. `T06-E` Battle History: pending after T06-B merge; must fill feature card before runtime.
6. `T06-F` Base Routine: pending after T06-B merge; must fill feature card before runtime.
7. `T06-G` Social QoL: pending after T06-B merge; must fill feature card before runtime.
8. `T06-H` Asset Pack 01: pending after T06-B merge; must fill feature card before runtime.
9. `T06-I` Integracao: blocked until T06-C to T06-H are delivered.

## Guardrails

- Do not edit directly in `D:\Estudio` for implementation.
- Do not create `account_profiles` + `game_saves`.
- Do not change economy, combat, reward, bot, shop or power numbers.
- Do not publish builds or mutate remote release state.
- Do not put secrets or service role data in client/export or runtime config.
- Keep missing art allowed.

## T06-D Handoff

- Status: `READY_FOR_INTEGRATION`
- Delivered: Hub profile/account panel using existing `SessionStore`, current `account/state` snapshot, active save metadata and update gate state.
- Client files: `modes/boot/surfaces/hub_account_surface_presenter.gd`, `modes/boot/surfaces/hub_surface_presenter.gd`.
- Tests/smoke: `tests/client/test_boot_mobile_ui.gd`, `tools/smoke_session_shell.gd`.
- Guardrails preserved: no endpoint, Auth, Supabase schema, persisted `SessionStore` contract, `BackendConfig`, economy, combat, ranking or remote manifest change.

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
