# DraxosMobile Feature Registry And Installation Contract

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-17`
- review_when: `a feature is planned, installed, integrated, blocked or retired`
- supersedes: `implementation/tracks/track-06-feature-installation-rails-and-first-slices/feature-registry.md as live authority`
- superseded_by: `none`

This is the live contract for installing features in DraxosMobile. The original Track 06 registry remains historical evidence; new work updates this file before touching runtime, endpoint, schema, asset or test surfaces.

## Allowed Statuses

| Status | Meaning |
|---|---|
| `PLANNED` | Registered, with no implementation work started. |
| `IN_PROGRESS` | A dedicated worktree owns the bounded implementation. |
| `READY_FOR_INTEGRATION` | Delivered and validated for local integration. |
| `INTEGRATED` | Integrated into the local baseline. |
| `BLOCKED` | Stopped for a decision, dependency or failed validation. |
| `DEFERRED` | Removed from the current package without runtime delivery. |

## Required Feature Fields

Every feature card must declare:

- `Owner`, `Surface`, `Status` and affected client/backend files;
- affected endpoints and one service scope;
- auth, save-header, idempotency, read/write and fallback notes when a service is involved;
- focused smoke, GUT and other validation;
- fallback, rollback, guardrails and integration handoff.

Empty, `TBD` or `unknown` values block implementation. A discovered need for schema, tuning, real payment, realtime social, remote publication or account/save migration is a hard stop for an explicit decision.

## Service Scopes

| Scope | Installation rule |
|---|---|
| `save-scoped` | Resolve the active save; absence of `x-draxos-save-type` defaults to `normal` only where the endpoint contract permits it. |
| `account-scoped` | Operate canonical account identity without leaking Lab state into Normal. |
| `release` | Public/operational read surface; no gameplay state, rewards, secrets or publication control. |
| `telemetry` | Diagnostic evidence only; never grants progress, ranking, resources or rewards. |
| `mode` | Follow the mode registry/session/reward authority contracts. |
| `admin-internal` | Audited internal operation; never a player-facing default. |
| `admin-future` | Reserved and blocked until a separate decision authorizes it. |
| `none` | No backend service dependency. |

New or renamed endpoints update `api-endpoints.md` in the same feature delivery. Existing endpoints must be declared as existing and point to their focused regression.

## Validation By Surface

| Surface | Required proof |
|---|---|
| docs/coordination | `DocsOnly`, links and `git diff --check`; no runtime inference. |
| release/client boot | Runtime config smoke, focused client GUT and local release dry-run when packaging rules are touched. |
| account/session | Session/profile smoke plus facade/presenter GUT. |
| Arena/battle | Server authority tests, client attempt/replay smoke and focused GUT. |
| Base/Social | Foundation surface smoke plus presenter GUT. |
| shared UI/assets | Visual/export smoke and fallback coverage; human visual approval remains separate. |
| backend-only | Mirrored Deno checks and endpoint contract tests. |

If a docs-only change touches client or tooling, the validation tier expands to the affected runtime. Every runner must preserve tracked Git state.

## Fallback And Rollback

- Runtime config falls back to conservative flags.
- Read-only services show a clear empty/error state and do not mutate save data.
- Optional assets keep native/procedural fallback.
- Battle replay never reruns simulation or reapplies rewards.
- Rollback first disables the entry/flag, then reverts isolated files while preserving saves, rewards, ranking, manifests and remote state.

## Registry Summary

| Feature ID | Surface | Status | Service scope |
|---|---|---|---|
| `T06_FEATURE_RAILS` | docs/coordination | `INTEGRATED` | `none` |
| `RUNTIME_CONFIG_V1` | release/client boot | `INTEGRATED` | `release` |
| `PROFILE_ACCOUNT_PANEL` | account/session | `INTEGRATED` | `save-scoped` |
| `BATTLE_HISTORY_REPLAY` | battle | `INTEGRATED` | `save-scoped` |
| `BASE_ROUTINE_PANEL` | Base | `INTEGRATED` | `save-scoped` |
| `SOCIAL_QOL_READABILITY` | Social | `INTEGRATED` | `account-scoped` |
| `ASSET_PACK_01_SAFE` | shared UI/assets | `INTEGRATED` | `none` |

## Feature Cards

### `T06_FEATURE_RAILS`

- Owner: `T06-B Feature Rails`
- Surface: docs/coordination
- Status: `INTEGRATED`
- Endpoints affected: none
- Service scope: none
- Service contract notes: contract-only feature; no service changes.
- Client files: none
- Backend files: none
- Smoke required: `N/A docs-only`
- GUT required: `N/A docs-only`
- Other validation: `DocsOnly`, links and `git diff --check`
- Fallback: implementation is blocked when a later feature has no complete card.
- Rollback: revert the documentation change; no runtime state exists.
- Guardrail notes: no gameplay, schema, tuning, asset, publication or remote mutation.
- Handoff notes: every later feature copies the live template before implementation.

### `RUNTIME_CONFIG_V1`

- Owner: `T06-C Runtime Config`
- Surface: release/client boot
- Status: `INTEGRATED`
- Endpoints affected: existing `GET /release/config`
- Service scope: release
- Service contract notes: read-only, no player/save state or secret; fallback flags remain conservative.
- Client files: `online/runtime_config.gd`, boot/session integration
- Backend files: mirrored release functions and runtime config tests
- Smoke required: `tools/smoke_runtime_config.gd`
- GUT required: runtime config read/fallback coverage
- Other validation: mirrored Deno checks, client validation and `git diff --check`
- Fallback: all optional flags false, offline fallback allowed and no online action unlocked.
- Rollback: remove the route/helper integration while preserving release manifest behavior.
- Guardrail notes: no publication, manifest mutation, schema, secret, tuning or save state.
- Handoff notes: verify defaults before integrating a feature behind any flag.

### `PROFILE_ACCOUNT_PANEL`

- Owner: `T06-D Perfil/Conta`
- Surface: account/session
- Status: `INTEGRATED`
- Endpoints affected: existing `GET /account/state`
- Service scope: save-scoped
- Service contract notes: read-only active-save summary using the existing session contract.
- Client files: account/hub surface presenters
- Backend files: none
- Smoke required: session shell/profile summary smoke
- GUT required: profile/presenter coverage
- Other validation: client validation and `git diff --check`
- Fallback: show available session metadata and a clear missing-snapshot state.
- Rollback: remove the UI entry while preserving the account/session flow.
- Guardrail notes: no Auth, schema, economy, combat, ranking or manifest change.
- Handoff notes: keep actions, networking and telemetry in their existing owners.

### `BATTLE_HISTORY_REPLAY`

- Owner: `T06-E Battle History`
- Surface: battle
- Status: `INTEGRATED`
- Endpoints affected: existing `GET /battle/history`, `GET /battle/replay?battle_id=...`
- Service scope: save-scoped
- Service contract notes: JWT and active save required; read-only and idempotency-free GETs; never rerun simulation or rewards.
- Client files: Supabase client, boot flow and battle replay presenter
- Backend files: mirrored battle functions and history/replay tests
- Smoke required: battle history/replay Deno and Godot smokes
- GUT required: battle history/replay presenter coverage
- Other validation: mirrored Deno checks, client validation and `git diff --check`
- Fallback: readable empty history/load error; latest battle flow remains available.
- Rollback: disable history UI/endpoints while preserving battle request/latest and stored rows.
- Guardrail notes: no simulator, reward, ranking, economy, log schema or database change.
- Handoff notes: prove replay fetch does not change account/save state.

### `BASE_ROUTINE_PANEL`

- Owner: `T06-F Base Routine`
- Surface: Base
- Status: `INTEGRATED`
- Endpoints affected: existing `GET /base/state`
- Service scope: save-scoped
- Service contract notes: read-only presentation of existing Base readiness and jobs.
- Client files: Base surface presenter and focused tests
- Backend files: none
- Smoke required: foundation surface Base coverage
- GUT required: Base routine/presenter coverage
- Other validation: client validation and `git diff --check`
- Fallback: show no-ready-action state for empty/offline payload.
- Rollback: remove the routine panel and preserve existing Base actions.
- Guardrail notes: no economy tuning, endpoint, schema or queue rule change.
- Handoff notes: derive presentation only from the existing Base payload.

### `SOCIAL_QOL_READABILITY`

- Owner: `T06-G Social QoL`
- Surface: Social
- Status: `INTEGRATED`
- Endpoints affected: existing `GET /social/state` and current social actions
- Service scope: account-scoped
- Service contract notes: preserve polling, chat, ranking and account identity boundaries.
- Client files: Social surface presenter and focused tests
- Backend files: none
- Smoke required: foundation surface Social coverage
- GUT required: Social readability/presenter coverage
- Other validation: client validation and `git diff --check`
- Fallback: clear no-friends, no-guild, no-message and offline states.
- Rollback: remove readability changes while preserving existing social actions.
- Guardrail notes: no realtime, moderation, schema, endpoint or ranking expansion.
- Handoff notes: preserve account-wide identity and Lab leaderboard isolation.

### `ASSET_PACK_01_SAFE`

- Owner: `T06-H Asset Pack 01`
- Surface: shared UI/assets
- Status: `INTEGRATED`
- Endpoints affected: none
- Service scope: none
- Service contract notes: no backend service.
- Client files: selected UI/portrait/battle PNGs, `AssetIds` and optional icon hooks
- Backend files: none
- Smoke required: export smoke
- GUT required: `AssetIds` and missing-art fallback coverage
- Other validation: client validation, export smoke and `git diff --check`
- Fallback: missing textures retain native labels and procedural visuals.
- Rollback: remove optional PNG/hooks while keeping the native visual path.
- Guardrail notes: no backend, schema, tuning, remote asset or final visual approval.
- Handoff notes: verify origin/license separately for any new asset.

## Template For New Feature Cards

```text
### `FEATURE_ID`
- Owner:
- Surface:
- Status:
- Endpoints affected:
- Service scope:
- Service contract notes:
- Client files:
- Backend files:
- Smoke required:
- GUT required:
- Other validation:
- Fallback:
- Rollback:
- Guardrail notes:
- Handoff notes:
```

## Integration Checklist

- No required field is empty, `TBD` or `unknown`.
- Endpoint and service authority are documented before runtime.
- Focused smoke/GUT and proportional validation pass.
- Fallback and rollback are tested or explicitly reasoned.
- No product gate, tuning, migration, remote mutation, publication or secret is inferred.
