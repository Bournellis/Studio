# Checkpoint G1 - Balanced Evaluation

## Purpose

Checkpoint G1 exists to stop after the first playable Godot slice and judge it as a real baseline,
not just as a proof that migration is technically possible.

## Current Snapshot

- Status: `CLOSED - APPROVED FOR G2`
- Baseline: `Phase G1 - Combat Foundation`
- Slice: `frontend -> arena -> result/return`
- Content Package: `Heroic + Martelo + 4 skills + 2 potions`
- Runtime Scope: `solo local only`
- Validation:
  - `tools/validate.gd` passes
  - GUT passes
  - the slice has been played manually and iterated from real feedback

## Exit Questions

- Does the frontend feel stable enough to support more iteration without constant layout regressions?
- Is the arena readable enough that we can judge combat feel honestly?
- Is the canonical loadout contract represented clearly in both data and UI?
- Does the runtime feel like a real migration baseline instead of a brittle bootstrap demo?
- Are the current pain points mostly stabilization issues, or do they point to a deeper architectural mismatch with Godot?

## Approval Criteria

- the player can assemble a valid canonical loadout manually
- the player can start the arena reliably from the frontend
- the player can move, attack, cast `4` skills, and use `2` potions
- the bot can engage and the match can conclude on death
- the result flow returns cleanly to the frontend
- automated validation stays green after iteration
- the main remaining issues are quality/stabilization issues, not blocked core flow

## Known Focus Areas For Review

- frontend layout stability across normal desktop window sizes
- camera readability and combat legibility in the arena
- clarity of action feedback, cooldowns, and hit readability
- scene ownership and the balance between generated bootstrap content and editor-owned scenes
- confidence in the current automated checks

## Decision Output

Use one of these outcomes before opening new content breadth:

- `APPROVED FOR G2`
- `HOLD FOR ANOTHER G1 TIGHTENING PASS`
- `RETHINK DIRECTION BEFORE EXPANSION`

## Current Recommendation

- Recommendation: `APPROVED FOR G2`
- Reason: the first playable slice exists, was approved after testing, and successfully transitioned into stabilization work without reopening the bootstrap foundation.
