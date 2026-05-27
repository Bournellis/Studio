# Track 06 - Current Status

- Last Updated: `2026-05-27`
- Status: `ACTIVE_FEATURE_INSTALLATION`
- Depends On: `T05_INTEGRATED_FOUNDATION_READY`
- Current Stage: `T06_C_READY_FOR_INTEGRATION`
- Next Action: integrate T06-C runtime config, then integrate T06-D to T06-H feature slices in small batches.

## Estado

Track 06 is active as the first feature installation package after the Track 05 foundation baseline.

The track deliberately prioritizes solid installation rails and small visible feature slices over tuning. Progression Lab remains available, but economy, power, bots, rewards, shop and combat numbers are not active objectives in this track.

## Ordem Atual

1. `T06-A` Coordenacao: complete.
2. `T06-B` Feature Rails: ready for handoff; feature registry now defines the standard install contract, smoke/GUT rule by surface, fallback and rollback checklist.
3. `T06-C` Runtime Config: ready for integration.
4. `T06-D` Perfil/Conta: pending after T06-B merge; must fill feature card before runtime.
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
