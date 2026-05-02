# Godot Implementation

This directory contains the active operational state for RPG Isometrico in Godot.

## Structure

- `current-status.md` is the stable hub for active work.
- `tracks/` contains the live operational line.
- `phase-g1/` through `phase-g4/` preserve the closed Godot validation cycle.
- `checkpoints/` preserves the acceptance records for that validation cycle.
- `execution-log.md` preserves meaningful implementation handoffs. Older entries record the G4 validation cycle; newer entries may record track-level work when status or handoff context changes.

## Fast Entry

Start with:

1. `current-status.md`
2. `tracks/track-02-canonical-product-foundation/current-status.md`
3. `tracks/track-02-canonical-product-foundation/implementation-map.md`
4. the active gate named by `current-status.md`, only when one is explicitly selected
5. `../docs/validation.md`

When touching render quality, platform export strategy, or 3D asset budgets, also read:

1. `../docs/platform-art-and-export-guidance.md`

## Historical Read Path

Open the validation-cycle history only when a task explicitly needs it:

1. `phase-g4/current-status.md`
2. `checkpoints/checkpoint-g4-local-multi-mode-base-acceptance.md`
3. earlier `phase-g*` folders as needed
