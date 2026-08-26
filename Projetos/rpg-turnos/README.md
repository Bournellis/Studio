# RPG Turnos

`rpg-turnos` is a provisional Godot project for a 2D RPG with turn-based card-and-board battles. It adopts only the Studio Core domains declared in `STUDIO_CORE.md` and remains mechanically independent from RPG Isometrico.

## Current Shape

- clean Godot project skeleton
- RPG systems first, presentation second
- exploration mode with a freely moving map character
- NPC dialogue, route choice, encounters, stats, level, items, and inventory as expected pillars
- combat as a separate C1 card-slot mode with battle modes like `limpar_mesa`
- 20-card deck setup and data-driven cards, boards, and encounters
- initial narrative focus on the Draxos commander leading the shared expedition against an elemental planet from an ether-plasm base under the Grande Mestre
- current runtime names are placeholders until migrated to the Draxos/elemental-planet lore
- final visual direction is currently 2D for the slice, with broader product presentation decisions still open

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
- `tests/`: GUT coverage for current runtime behavior
- `tools/`: validation, generation, and import tools

## Start Here

Read `AGENTS.md`, `STUDIO_CORE.md`, `docs/lore-campaign.md`, `docs/game-design-document.md`, `docs/architecture.md`, and `implementation/current-status.md` before making meaningful changes.
