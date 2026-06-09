# DraxosMobile Hardening Program

- Status: `VIVO`
- Last updated: `2026-06-09`
- Scope: long-term hardening/refactor guardrails for DraxosMobile after
  `Bosque Diegetic Launcher Foundation v1`.

## Purpose

This document is the operational matrix for hardening work. It does not approve
new gameplay, economy, PVP, broad Openworld expansion, remote mutation or a new
Internal Alpha package. It tells agents which contracts and gates must protect
each kind of refactor.

## Non-Negotiable Boundaries

- `account_profiles` remains account authority.
- `game_saves` remains save/progression authority.
- `players.save_type` remains compatibility only, never new authority.
- Idempotent mutations must keep `request_hash`, `scope_id` and
  `pending/completed/failed` lifecycle semantics.
- Client code may preview feel and local UI state, but server functions own
  durable progress, rewards, completion, cooldown, ledger and audit.
- Labs remain evidence, not runtime authority.
- `FullPublish` stays disabled in `validate_foundation.ps1`.
- Remote upload, deploy, manifest mutation, `supabase db push`, secret changes
  and `FullPublish` require explicit approval, a versioned `ReleaseRoot` plus
  `-ConfirmRemoteMutation`.

## Change Matrix

| Change type | Primary owner | Minimum gate |
|---|---|---|
| Docs, coordination or live-status sync | `coord-docs` | `git diff --check`; `DocsOnly`; targeted drift checks. |
| Account/save/idempotency/RLS | `session-data` | `ServerQuick`; account/save contract tests; `DatabaseLocal` when local Supabase is available. |
| Edge Function or schema mirror | `backend-schema` | `ServerQuick`; Deno check/test for both `server/functions` and `supabase/functions`; mirror check. |
| Client shell, routing, `SessionStore`, `SupabaseClient` | `client-shell` | Godot validate, GUT client, `ClientQuick`, route/back focused smoke. |
| Bosque/Openworld bridge, checkpoints or launcher routing | `openworld-platform` | `ClientQuick`, `smoke_openworld_forest.gd`, `smoke_modes_visual_layout.gd`, targeted `test_openworld_*`. |
| Mode platform or official mode boundary | `platform-v1` | `ModePlatform`; mode contract tests; no playable promotion for disabled modes. |
| Arena client/backend flow | `arena-client-labs` + `backend-schema` | `ClientQuick` or `ServerQuick` by side; preserve `/arena/pve/claim` as summary/ack, not new economy mutation. |
| Battle Lab or Progression Lab | `arena-client-labs` | Lab tests and UI GUT; keep generated evidence isolated from save `normal`. |
| Release scripts, manifest, artifact checks or keystore | `validation-release-security` | `ReleaseDryRun`, `check_release_safety.ps1`, `check_android_release_keystore.ps1 -Mode InternalAlpha`. |
| Full integration before merge | coordinator | `FullLocal -RequireClean` when environment permits; otherwise document missing environment and run all available targeted gates. |
| Remote artifact verification | `validation-release-security` | `RemoteReadOnly` with expected release root and publishable credentials only; no mutation. |

## Refactor Order

1. Freeze contracts and run baseline validation.
2. Harden account/save/idempotency and release safety first.
3. Refactor backend/client/Openworld/Arena in small slices with unchanged
   contracts.
4. Split UI and labs only with visual or report parity.
5. Update live docs only when observable status changes.

## Current Package Guard

The current package is `Bosque Diegetic Launcher Foundation v1`:

- release root `internal-alpha/v0-bosque-diegetic-launcher-foundation-v1-20260609-e55ed0c`;
- version `0.0.16-alpha.0`;
- version code `16`;
- minimum supported version code `13`.

The next operational step remains focused human playtest of the published
Web/APK package. Hardening bugs can return to normal bugfix flow, but this
program does not create a new release package by itself.
