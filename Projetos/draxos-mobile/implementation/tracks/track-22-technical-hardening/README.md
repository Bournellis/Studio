# Track 22 - Technical Hardening

- Status: `ACTIVE_LOCAL_HARDENING`
- Started: `2026-06-05`
- Branch: `codex/draxos-mobile/technical-hardening`
- Worktree: `D:\Estudio-worktrees\draxos-mobile--codex--technical-hardening`

## Purpose

This track records the local hardening package approved after the deep
technical audit of DraxosMobile. It is not a content expansion, tuning pass,
remote publication package or new playable mode.

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

Openworld Main Menu Sync remains the latest published Internal Alpha package:
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

None. This track starts as local hardening only.
