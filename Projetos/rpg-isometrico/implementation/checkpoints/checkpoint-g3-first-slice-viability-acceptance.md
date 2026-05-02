# Checkpoint G3 - First Slice Viability Acceptance

## Purpose

Checkpoint G3 exists to decide whether the current Godot implementation has moved beyond
"promising prototype" and become a proven first slice for the migration.

## Current Snapshot

- Status: `CLOSED - ACCEPTED AS PROVEN FIRST SLICE`
- Covered Work:
  - `Phase G1 - Combat Foundation`
  - `Phase G2 - Slice Stabilization`
  - `Phase G3 - Combat Productionization`
- Slice: `frontend -> arena -> result/return`
- Content Package: `Heroic + Martelo + 4 skills + 2 potions`
- Runtime Scope: `solo local only`
- Arena State: `larger enclosed battlefield with perimeter walls and interior blocks`
- Validation:
  - `tools/validate.gd` passes
  - GUT passes with `15/15` tests and `119` asserts
  - the slice was tested manually and refined through repeated play feedback

## What Is Now Proven

- the core loop works end to end in Godot as a real playable flow
- the canonical loadout contract is represented clearly in data, UI, and runtime
- the Godot project supports real iteration through authored scenes, runtime modules, and validation tooling
- desktop manual aim for projectile and leap skills works as intentional input, not target lock bias
- combat readability, hit feel, and arena presentation are strong enough to judge future work honestly
- the project no longer depends on Unity to keep evolving this core slice

## What Is Not Yet Proven

- production scale under a much larger content surface
- long-term progression and economy loops
- mobile UX and input model
- multiplayer or online architecture
- final visual production values

## Acceptance Questions

- Does the Godot project now feel like a valid implementation home, not just a migration experiment?
- Can we judge future decisions inside Godot without needing to "prove the engine" again?
- Are the current remaining problems mostly quality, scope, and planning questions rather than engine-fit risk?
- Has the first slice shown enough technical and gameplay confidence to justify planning the next phase from this baseline?

## Acceptance Criteria

- the full `frontend -> arena -> result/return` loop is stable
- the player can move, attack, dash, cast `4` skills, and use `2` potions reliably
- the bot can pressure, telegraph, reposition, and conclude the match on death
- the camera, HUD, aim previews, and floor readability are good enough for honest combat judgment
- the arena layout now supports a larger enclosed battlefield without collapsing the simple combat loop
- automated validation stays green after repeated polish passes
- the user has tested the slice and considers it proven

## Decision Output

Use one of these outcomes before opening the next planning pass:

- `ACCEPTED AS PROVEN FIRST SLICE`
- `NEEDS ONE MORE PRODUCTIONIZATION PASS`
- `HOLD AND RETHINK NEXT PHASE`

## Current Decision

- Decision: `ACCEPTED AS PROVEN FIRST SLICE`
- Reason: the Godot migration now has a real, tested, and iterated gameplay slice that proves viability, supports continued development, and no longer depends on Unity to validate the core loop.

## Planning Handoff

The next planning conversation should assume:

- Godot viability is accepted
- Unity remains paused and consultation-only
- the next phase should focus on deliberate expansion rather than re-proving the first slice
- future planning should explicitly choose between breadth expansion, systems architecture, or platform preparation instead of continuing indefinite polish
