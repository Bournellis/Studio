# Track 06 - Feature Registry

Every Track 06 feature must declare the fields below before implementation:

- `Feature ID`
- `Owner`
- `Surface`
- `Status`
- `Endpoints affected`
- `Service scope`
- `Client files`
- `Backend files`
- `Validation`
- `Fallback`
- `Rollback`
- `Guardrail notes`

## Features

| Feature ID | Owner | Surface | Status | Endpoints affected | Service scope | Required validation |
|---|---|---|---|---|---|---|
| `T06-FEATURE-RAILS` | T06-B | docs/coordination | `PLANNED` | none | none | `git diff --check` |
| `RUNTIME_CONFIG_V1` | T06-C | release/client boot | `PLANNED` | `GET /release/config` | `release` | Deno checks, runtime config smoke, GUT/client validation |
| `PROFILE_ACCOUNT_PANEL` | T06-D | Hub account/session | `PLANNED` | existing `GET /account/state` only | `account-scoped` existing read | profile GUT/smoke, `validate.gd`, GUT |
| `BATTLE_HISTORY_REPLAY` | T06-E | Battle tab | `PLANNED` | `GET /battle/history`, `GET /battle/replay?battle_id=...` | `save-scoped` | Deno checks, battle history/replay smoke, `smoke_battle_replay.gd` |
| `BASE_ROUTINE_PANEL` | T06-F | Base tab | `PLANNED` | existing `GET /base/state` only | `save-scoped` existing read | focused GUT/smoke, `smoke_foundation_surfaces.gd` |
| `SOCIAL_QOL_READABILITY` | T06-G | Social tab | `PLANNED` | existing `GET /social/state` and current social actions only | `save-scoped`/`account-scoped` existing behavior | focused GUT/smoke, `smoke_foundation_surfaces.gd` |
| `ASSET_PACK_01_SAFE` | T06-H | shared UI/battle visuals | `PLANNED` | none | none | AssetIds/fallback GUT, `validate.gd`, `smoke_exports.gd` |

## Feature Template

```text
Feature ID:
Owner:
Surface:
Status:
Endpoints affected:
Service scope:
Client files:
Backend files:
Validation:
Fallback:
Rollback:
Guardrail notes:
```

## Rollback Rule

Each feature must be removable by disabling UI entry points or feature flags and reverting its isolated files. Runtime config flags must default to conservative behavior when the service is unreachable.
