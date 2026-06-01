# DraxosMobile - Hardening Platform V1 Readiness Report

- Status: `PUBLISHED_INTERNAL_ALPHA`
- Date: `2026-06-01`
- Integration branch: `codex/draxos-mobile/hardening-platform-v1`
- Integration worktree: `D:\Estudio-worktrees\draxos-mobile--codex--hardening-platform-v1`
- Release root: `internal-alpha/v0-hardening-platform-v1-20260601-19eb80d`
- Cloudflare preview: `https://68452eed.draxos-mobile-internal-alpha.pages.dev`
- Stable Portal: `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html`
- Stable Web: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`
- Remote manifest: `https://armxgipvnbbshzqawklw.supabase.co/functions/v1/release/manifest`

## Summary

Hardening Platform V1 is published as the new DraxosMobile multi-mode baseline.
It integrates the scroll drag release fix into `master`, establishes the
multi-agent worktree/lane protocol, modularizes shell/session/backend surfaces,
formalizes the official mode descriptors, adds audited mode admin operations,
protects the reward bridge and expands validation/release gates.

This package is intentionally a platform hardening release. It does not add new
gameplay, tuning, weapons, spells, economy expansion, PVP, social expansion or
playable Towerdefense/Cardgame content.

## Publication

Published artifacts:

| Artifact | URL |
|---|---|
| Android APK | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-hardening-platform-v1-20260601-19eb80d/downloads/draxos-mobile-alpha.apk` |
| PC ZIP | `https://armxgipvnbbshzqawklw.supabase.co/storage/v1/object/public/draxos-internal-alpha/internal-alpha/v0-hardening-platform-v1-20260601-19eb80d/downloads/draxos-mobile-alpha.zip` |
| Portal stable | `https://draxos-mobile-internal-alpha.pages.dev/portal/index.html` |
| Web stable | `https://draxos-mobile-internal-alpha.pages.dev/web/index.html` |
| Portal/Web preview | `https://68452eed.draxos-mobile-internal-alpha.pages.dev` |

Remote operations completed:

- Applied remote migration `202606010002_modes_admin_audit_hardening.sql`.
- Deployed Edge Function `modes`.
- Exported Android, Windows and Web artifacts.
- Packaged and uploaded Storage artifacts to the versioned release root.
- Built Cloudflare Pages package with remote `index.pck` and `index.wasm`
  size verification.
- Deployed Cloudflare Pages preview `68452eed`.
- Deployed manifest override through Edge Function `release`.

Android note: this package uses `android_export_mode: debug_fallback` because a
release keystore was not configured in the available environment.

## Validation Evidence

Local gates passed:

- `git diff --check`
- `deno task check` in `server/functions`
- `deno task check` in `supabase/functions`
- Focused Deno mode/admin/reward tests
- Godot headless import
- `tools/smoke_mode_hub.gd`
- `tools/validate_foundation.ps1 -Profile DocsOnly`
- `tools/validate_foundation.ps1 -Profile ServerQuick`
- `tools/validate_foundation.ps1 -Profile ModePlatform`
- `tools/validate_foundation.ps1 -Profile ClientQuick`
- `tools/validate_foundation.ps1 -Profile ReleaseDryRun`
- `tools/validate_foundation.ps1 -Profile DatabaseLocal`
- `tools/validate_foundation.ps1 -Profile FullLocal`

Publication and remote read-only gates passed:

- `tools/export_internal_alpha.ps1` with Android debug fallback
- `tools/publish_internal_alpha.ps1 -Mode Package`
- `tools/publish_internal_alpha.ps1 -Mode Upload -ConfirmRemoteMutation`
- `tools/build_cloudflare_pages_package.ps1`
- `wrangler pages deploy`
- `tools/publish_internal_alpha.ps1 -Mode DeployManifest -ConfirmRemoteMutation`
- `server/tests/release_manifest_smoke.ts`
- `server/tests/internal_alpha_remote_smoke.ts` with
  `DRAXOS_REMOTE_RELEASE_SMOKE=1`
- `tools/validate_foundation.ps1 -Profile RemoteReadOnly -AllowCloudflareAccess`
- Direct preview check: Portal `200`, Web `200`

Generated local reports are under `build/validation/` and
`build/internal-alpha/` in the integration worktree.

## Readiness By Lane

| Lane | Result |
|---|---|
| `coord-docs` | Complete. Multi-agent workflow, templates, mode docs and readiness report are in place. |
| `mode-scaffolds` | Complete. Five official mode descriptors and data definition scaffolds are aligned across docs/client/schema tests. |
| `client-shell` | Complete. Mode Hub and shell launch path are descriptor-driven, with hot file budgets enforced. |
| `session-data` | Complete. Session store responsibilities are split into account/save, arena, modes, telemetry and pending mutation slices. |
| `backend-schema` | Complete. `/modes` is modularized, admin mutations use audited RPCs and migrations/RLS/grants are validated locally and remotely applied. |
| `validation-release` | Complete. Validation profiles, budget checks, drift checks, release dry-run and remote read-only smokes are operational. |
| `integrator` | Complete. Integration branch was validated, published and is ready to become the `master` baseline. |

## Mode Readiness

| Mode | Current state | Next allowed work |
|---|---|---|
| `basebuilder` | Active foundation surface using existing core Base/Refugio ownership. | Mode-specific UI/docs work through a dedicated lane; no economy expansion without contract update. |
| `autobattler` | Active product core through Arena PVE. Track 18-21 remain the preserved Arena context. | Human playtest of tutorial -> first real Arena -> next difficulty, then targeted tuning package. |
| `openworld` | Internal alpha generic-session mode with limited reward bridge. | Isolated mode iteration only; no broad campaign/content expansion by default. |
| `towerdefense` | Staged/disabled scaffold. | Documentation, descriptor and disabled-card behavior only until a playable package is approved. |
| `cardgame` | Staged/disabled scaffold. It explicitly does not inherit mechanics from the Steam roguelike cardgame. | Documentation, descriptor and disabled-card behavior only until a separate package is approved. |

## Definition Of Ready For Multi-Mode Work

DraxosMobile is ready for heavy parallel work when new threads follow these
rules:

- branch from updated `master` after Hardening Platform V1 is merged;
- create a dedicated worktree under `D:\Estudio-worktrees`;
- register a Doing/Handoff card with lane, mode, write scope and validation;
- use `docs/multi-agent-workflow.md` as the lane authority;
- keep shared shell/session/backend/schema files under the platform/integrator
  lane unless explicitly coordinated;
- do not start gameplay/content expansion in staged modes without a selected
  package;
- preserve `account_profiles/game_saves`, ruleset registry, idempotency,
  audited admin RPCs and reward bridge boundaries;
- run at least the lane-specific validation profile before handoff.

## Remaining Human Checks

- Human review/playtest of the published Hardening Platform V1 build.
- Human playtest of the Autobattler Arena PVE flow:
  tutorial -> first real Arena complete -> next difficulty unlocked.
- Android release keystore decision if future alpha packages should stop using
  `debug_fallback`.
