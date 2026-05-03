# RPG Turnos

`rpg-turnos` is a provisional Godot project for a turn-based RPG-cardgame that shares studio lore while remaining mechanically independent from RPG Isometrico.

## Current Shape

- clean Godot project skeleton
- RPG systems first, presentation second
- exploration mode with a freely moving map character
- NPC dialogue, route choice, encounters, stats, level, items, and inventory as expected pillars
- combat as a separate turn-based card-slot mode
- 2D/3D direction intentionally undecided

## Directory Map

- `core/`: engine-light contracts, snapshots, result objects, and shared helpers
- `systems/`: visual-agnostic RPG systems
- `modes/`: boot, world, and battle mode composition
- `world/`: exploration movement, camera, and interaction presentation lanes
- `battle/`: turn-based card-slot combat contracts and runtime
- `ui/`: dialogue, inventory, character sheet, and battle command presentation
- `data/`: authored definitions and generated resources
- `docs/`: local design and technical documentation
- `implementation/`: status, tracks, and execution handoffs
- `tests/`: future GUT tests
- `tools/`: future validation, generation, and import tools

## Start Here

Read `AGENTS.md`, `docs/project-brief.md`, `docs/game-design-document.md`, `docs/architecture.md`, and `implementation/current-status.md` before making meaningful changes.
