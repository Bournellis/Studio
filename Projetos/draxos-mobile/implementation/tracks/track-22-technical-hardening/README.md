# Track 22 - Technical Hardening

- Status: `TECHNICAL_HARDENING_PUBLISHED_INTERNAL_ALPHA`
- Started: `2026-06-05`
- Delivered locally: `2026-06-05`
- Published remotely: `2026-06-05`
- Branch: `codex/draxos-mobile/technical-hardening`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`

## Purpose

This track records the hardening package approved after the deep technical
audit of DraxosMobile. It is not a content expansion, tuning pass or new
playable mode.

## Scope

- Compact live documentation and keep `implementation/current-status.md` as a
  short decision snapshot.
- Move `Modes Ops` out of the client while preserving Battle Lab and Progression
  Lab.
- Keep release publication out of `validate_foundation.ps1`; remote mutation
  remains explicit through `publish_internal_alpha.ps1`.
- Refactor large hotspots before further implementation.
- Harden mutable backend auth, account reset idempotency and Arena reward
  authority.

## Current Context

Technical Hardening is the latest published Internal Alpha package:
`internal-alpha/v0-technical-hardening-20260605-8e54a1f`.

Openworld Main Menu Sync remains the previous content package:
`internal-alpha/v0-openworld-main-menu-sync-20260604-bc36cd8`.

Foundation Hardening V2 remains the previous hardening/live-doc enforcement
baseline. Track 18, Track 20 and Track 21 remain Arena/Autobattler context.

## Status Compaction Note

Before this track, `implementation/current-status.md` mixed live decision state
with long publication logs and stale historical blockers. The file is now
intended to hold only the current operational snapshot, boundaries, active gate
and validation summary. Detailed package history should remain in historical
track folders, readiness reports, Kanban Done cards, release docs or Git history.

## Remote Mutation

Published after merge to `master` with explicit user approval.

- Release root: `internal-alpha/v0-technical-hardening-20260605-8e54a1f`
- Preview evidence: `https://2fe9393e.draxos-mobile-internal-alpha.pages.dev`
- Official Portal URL: `https://draxos-mobile-internal-alpha.pages.dev/`
- Direct Web URL: `https://draxos-mobile-internal-alpha.pages.dev/web/index.html`

## Package Notes

- Package 3 isolates `Modes Ops` out of the Godot client: the `modes_ops` route
  normalizes to Entry, the refuge dev menu keeps Battle Lab/Progression Lab but
  no longer shows admin ops, and client-side admin/analytics wrappers were
  removed.
- Package 4a extracts Arena endpoint row/type contracts into mirrored
  `arena/arena_types.ts` modules. The Arena edge entrypoint is back under the
  1800-line hot-file budget and the claim handler has a static guard to remain
  read-only.
- Package 4b adds `arena_reward_profiles` as the DB-side seed table for Arena
  reward profiles. The migration is mirrored in `server/schema`, seeded from
  `data/definitions/arena_rewards.json`, protected by RLS read-only policy for
  enabled profiles, and guarded by ServerQuick/Arena tests.
- Package 4c promotes account save reset to `reset_player_save_v1` with
  required `request_hash`, `game_saves.id` scoping, DB-side cleanup for
  Arena/Modes/Track 16, preservation of account-wide social state and
  service-role revocation of the legacy no-hash reset RPC.
- Package 5a starts auth hardening with a mirrored shared auth helper. `account`
  and `telemetry` now call `verifiedAuthContext`, which validates the bearer
  through Supabase Auth before trusting `auth_user_id`; remaining endpoint
  migrations stay split into later packages.
- Package 5b migrates the mirrored `progression-lab` apply endpoint to
  `verifiedAuthContext`, removes its local JWT decoder and extends the auth
  contract test coverage for the migrated endpoint list.
- Package 6a starts hotspot refactoring by extracting battle replay summary,
  reward, history and textual log formatting into `battle_replay_summary.gd`.
  `battle_replay_presenter.gd` stays focused on fullscreen UI/timeline wiring
  and drops from 748 to 528 lines while preserving the public `summary_data`
  wrapper used by client tests.
- Package 6b extracts account form parsing, auth/signup validation and alpha
  username/invite normalization into `account_form_contract.gd`.
  `account_session_flow.gd` keeps compatibility wrappers for the runtime facade
  and drops from 489 to 409 measured nonblank lines.
- Package 6c extracts player-facing Preparation defaults and error contract
  into `preparation_action_contract.gd`, adds direct client coverage for the
  default potion/spell behavior and error messages, and drops
  `surface_action_flow.gd` to 743 measured nonblank lines.
- Package 6d extracts Base routine summary, structure lookup and resource/cost
  formatters into `base_surface_summary.gd`. `base_surface_presenter.gd` keeps
  compatibility wrappers for `surface_ui_helpers.gd` and drops from 773 to 588
  measured nonblank lines without moving panel/control rendering.
- Phase 2 package 7a extends the mirrored shared auth helper with
  email-account enforcement helpers and a canonical Supabase UUID subject guard.
- Phase 2 package 7b migrates `content` and `lab-runner` to shared verified
  auth while preserving the anonymous lab fast-fail path before config lookup.
- Phase 2 packages 7c-7e migrate `base`, `competition`, `build`, `crafting`,
  `monetization`, `social`, `battle` and `arena` to shared verified auth in
  mirrored `server/` and `supabase/` functions.
- Phase 2 package 7f migrates `modes` through `mode_handler.ts`, preserving the
  explicit `x-draxos-save-type` requirement for mode routes.
- Phase 2 package 7g migrates `release` to shared verified auth before service
  role download access and keeps alpha access checks intact.
- Phase 2 packages 8a-8d continue extract-only client refactors: Base text,
  Base visuals, Base crafting panel helpers and Arena pure text helpers now live
  in bounded helper modules while presenters remain render/control owners.

## Final Local Validation

- `ServerQuick`: PASS (`112` foundation tests, `19` PVE Arena tests, mirrored
  Deno function checks and foundation expansion readiness).
- `ClientQuick`: PASS (`223/223` GUT tests, `3608` asserts, runtime config,
  foundation hardening, responsive layout, modes visual layout and export
  smokes).
- `ModePlatform`: PASS (`38/38` mode contract tests plus Bosque/Openworld/Modes
  Ops Godot smokes).
- `DatabaseLocal`: PASS after starting Docker Desktop, local Supabase and local
  Edge Functions. Transactional RPC live proof, Edge transactional RPC adapter
  smoke, mode platform live proof and admin RLS live smoke passed.
- `ReleaseDryRun`: PASS after Kanban closeout; release plan, safety checks,
  Android internal-alpha keystore gate, Track 13 readiness and Track 14 agent
  operations checks are green. No remote mutation is allowed through
  `validate_foundation.ps1`.
