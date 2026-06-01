# Openworld Decision Pack V1

- Status: `DECISION_PACK`
- Mode id: `openworld`
- Current slice: `forest`
- Descriptor: `data/definitions/modes/openworld/metadata.json`
- Placeholder: `data/definitions/modes/openworld/placeholder.json`
- Pending design id: `DMOB-D071`

This pack records the current decision boundary for Openworld after Hardening
Platform V1. It does not expand gameplay.

## Decision Summary

Openworld Bosque remains the only approved Openworld slice. It can stay
clickable in Internal Alpha because it already exists as `openworld/forest`,
uses generic Mode sessions and has a limited existing Reward Bridge.

No Openworld expansion is approved by this pack.

Runtime/QoL exception approved on 2026-06-01: the Bosque runtime may migrate
from a drawn `Control` world to a `Control` wrapper plus internal `Node2D`
foundation for movement feel, free joystick, PC/Web input, collision, map
borders and visual depth. This exception is local client QoL/foundation work;
it does not approve new content, economy, backend or Reward Bridge changes.

## Locked For Now

- The mode identity is `openworld`, not `rpgsuave`.
- The current slice is `forest`.
- The current public entry is `open_mode_shell:openworld`.
- The current screen is `res://modes/openworld/openworld_forest_screen.gd`.
- Future Openworld slices must start from descriptor/schema changes and a live
  design contract before runtime work.

## Runtime QoL Allowed

- `OpenworldForestScreen` remains the official `Control` screen.
- Internal `SubViewport`/`Node2D` world is allowed for the existing `forest`
  slice.
- WASD/setas, free joystick, local blockers, border walls, resource pass-through
  and depth ordering are allowed as foundation QoL.
- `OpenworldForestModel` remains the local rules authority for collection,
  pocket, chest, craft and result payload.

## Not Approved

- No backend mutation.
- No new map.
- No enemies or combat.
- No broader RPG campaign scope.
- No new reward source or economy tuning.
- No Basebuilder ownership changes.
- No new public release/publication from this QoL package without separate
  approval.

## Decision Questions Before Expansion

1. What is the map model: single instanced area, connected zones or continuous
   world?
2. What is the risk model: timed run, stamina, hazards, enemies, extraction or
   pure exploration?
3. Does Openworld progression stay local to the mode or feed shared account/save
   progression?
4. Which resources can leave Openworld through Reward Bridge, and what caps
   prevent farming loops?
5. Where is the boundary between Openworld collection/crafting and Basebuilder
   structures/crafting?
6. Which telemetry events prove the slice is useful before adding combat?
7. How does disable/rollback preserve already-started sessions?

## Required Evidence For A Future Package

- Updated `docs/minigames/openworld.md`.
- Updated descriptor and placeholder, validated by
  `tools/validate_mode_definitions.ps1`.
- Ruleset/registry/rate policy update.
- Reward Bridge review if any shared resource leaves the mode.
- Mode session disable/rollback coverage.
- Mobile portrait smoke and ModePlatform validation.
- Human approval recorded in Doing/Handoff.
