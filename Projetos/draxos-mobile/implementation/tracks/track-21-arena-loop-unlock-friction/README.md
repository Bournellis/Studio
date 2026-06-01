# Track 21 - Arena Loop Unlock And Friction Pass

- Date: `2026-05-31`
- Branch: `codex/draxos-mobile/track21-arena-loop-unlock-friction`
- Base: `codex/draxos-mobile/s1-arena-calibration-integration`
- Status: `PACKAGED_INTERNAL_ALPHA_LOCAL`

## Purpose

Track 21 fixes the first real Arena PVE loop blocker found in human playtest:
the tutorial awarded XP but did not update `players.level`, so the next
3-duel Arena remained locked even when the save had enough XP.

It also removes two avoidable clicks from the normal Arena flow:

- `arena/start` now goes straight to the active Arena route; loadout remains
  locked, but it is shown as compact context instead of a separate required
  confirmation screen.
- The completed-attempt summary now uses `Continuar na Arena`, treats
  `/arena/pve/claim` as read-only ack and refreshes `arena/pve/state` before
  returning to Arena selection.

## Backend

- Added mirrored migration
  `202605310004_arena_loop_unlock_friction.sql` in `server/schema` and
  `supabase/migrations`.
- Added `foundation_level_for_xp_v1`, using the Season 1 XP formula with cap
  40.
- Updated `arena_record_duel_v1` so completion rewards update `players.xp`
  and `players.level` in the same transaction.
- Preserved idempotency: completed retries return the stored payload and do
  not duplicate XP, level, resources, potion consumption, first clear or
  progress.

## Client

- Arena start routes directly to `ROUTE_ARENA_ACTIVE`.
- Summary primary CTA is `Continuar na Arena`.
- Summary continue calls claim only as compatibility ack, fetches fresh Arena
  state and returns to Arena selection rather than Refugio.
- Arena selection highlights the next recommended unlocked tier above the
  full list and keeps locked tiers disabled with short reasons.

## Validation

- `git diff --check`: PASS.
- Focused Deno tests for Arena loop unlock, catalog, difficulties and schema:
  PASS.
- `npx -y deno task --cwd server/functions check`: PASS.
- `npx -y deno task --cwd supabase/functions check`: PASS.
- Godot `validate.gd`: PASS, 140 tests / 2376 asserts.
- `smoke_responsive_layout.gd`: PASS.
- `smoke_exports.gd`: PASS.
- `validate_foundation.ps1 -Profile Quick`: PASS.
- `export_internal_alpha.ps1`: PASS with Android `debug_fallback`.
- `publish_internal_alpha.ps1 -Mode Plan`: PASS.
- `publish_internal_alpha.ps1 -Mode Package`: PASS.

## Local Package

- Release root: `internal-alpha/v0-track21-arena-loop-20260531-local`
- Publish dir: `build/internal-alpha/publish`
- Remote deploy was not executed in this package. Remote mutation still requires
  explicit approval and `-ConfirmRemoteMutation`.

## Playtest Focus

1. New save: Arena -> tutorial -> victory summary -> `Continuar na Arena`.
2. Confirm the flow returns to Arena selection, not Refugio.
3. Confirm `arena_cinzas_curta:s1_d00_intro` is unlocked after the tutorial.
4. Start the 3-duel Arena and confirm there is no loadout confirmation step.
5. Confirm repeat summary does not imply a pending reward claim.
