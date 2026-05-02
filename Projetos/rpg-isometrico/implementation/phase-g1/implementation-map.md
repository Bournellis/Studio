# Phase G1 Implementation Map

This file summarizes the intended stable surface for the first Godot evaluation slice.

## Target Surface

- shared canon consulted through relative paths
- JSON definitions for race, weapon, skill, and potion data
- generated Godot resources and catalogs
- frontend scene for real loadout assembly
- arena scene for solo combat loop
- simple bot opponent
- PT-BR player-facing UI
- result and return flow to frontend
- minimal local persistence for saved loadout
- headless validation and GUT test execution

## Current Runtime Surface

- `modes/frontend/frontend.tscn` generated bootstrap scene with `frontend_root.gd`
- `modes/arena/arena.tscn` generated bootstrap scene with `arena_root.gd`
- `tools/content_generator.gd` for JSON -> `.tres` generation
- `tools/scene_generator.gd` for bootstrap scene generation
- `tools/validate.gd` for headless validation and GUT execution
- `resources/generated/` for first-slice catalogs and playable content resources
