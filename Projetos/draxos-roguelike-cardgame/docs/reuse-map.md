# Reuse Map

- Last Updated: `2026-05-07`
- Status: `active bootstrap record`

## Copied From `rpg-turnos`

- Godot project shell and GUT setup.
- `tools/validate.gd`, `tools/content_generator.gd`, `tools/scene_generator.gd`, then adapted locally.
- `core/ui_tokens.gd` and `core/asset_ids.gd`.
- `data/content_library.gd` and `data/resources/`, then adapted locally.
- `ui/controls/` reusable card and slot controls.
- `battle/battle_engine.gd` as a temporary fork.

## Not Copied As Official Gameplay

- Free 2D world exploration.
- NPC reward progression.
- RPG Turnos deck size and deck validation.
- RPG Turnos mana/energy, hand, draw, and discard commitments.
- RPG Turnos route, terrain, elevation, neutral-slot, and movement board model.

## Required Cleanup

Track 00 must simplify the forked battle engine before combat is treated as a local baseline.

Target local battle model:

- per-encounter `player_slots_count`
- per-encounter `enemy_slots_count`
- encounter objective type
- boss and wave spawning rules
- local deck/resource rules after design decisions are made

## Reference Only

`rpg-turnos` remains useful for validation patterns, data generation, UI conventions, and Draxos lore migration examples. It is not an authority for this game's mechanics.
