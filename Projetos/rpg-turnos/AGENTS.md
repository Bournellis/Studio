# AGENTS.md

This file governs agent behavior for the Godot implementation of RPG Turnos.

## Project Role

`Projetos/rpg-turnos/` is a new Godot project for a 2D RPG with turn-based card-and-board battles.

The project is independent from `Projetos/rpg-isometrico/` at the mechanics and runtime level, but it may share the same broader lore and setting territory from the studio canon.

Current premise:

- provisional project name: `rpg-turnos`
- complete Godot project, started clean
- shared lore: far-future galaxy, post-nuclear Earth, human factions, celestial/intergalactic beings, and Draxos as arcane astral conquerors
- initial story: a novice Draxos mage joins a respected strike team invading an elemental planet from an ether-plasm base
- current runtime names are placeholders unless promoted by `docs/lore-campaign.md`
- RPG exploration with a freely moving map character
- NPC conversations, route choices, items, stats, level, and progression are expected pillars
- combat is turn-based, card-driven, and separated from exploration
- current slice is 2D; broader final visual direction can remain open until explicitly decided

Current active combat rule:

- C1 is the game, not a runtime variant
- battle modes are encounter rules such as `limpar_mesa` and `duelo`
- old A/B experiments and the phase-based duel are historical documentation only

## Read Order

Before substantial work:

1. `../../canon/canon-brief.md`
2. `../../canon/lore/shared-lore.md`
3. `../../canon/product/product-vision.md` for shared setting and lore context only
4. `docs/lore-campaign.md`
5. `docs/project-brief.md`
6. `docs/game-design-document.md`
7. `docs/architecture.md`
8. `implementation/current-status.md`
9. this file
10. touched files

For bounded work:

1. `../../canon/canon-brief.md`
2. `implementation/current-status.md`
3. this file
4. touched files

## Canon Rule

Shared lore and setting canon may inform this project.

Do not silently import RPG Isometrico mechanics as RPG Turnos canon. The action loadout, real-time combat, fixed action camera, and campaign progression rules from RPG Isometrico are references only unless a local RPG Turnos document explicitly adopts them.

If local RPG Turnos design conflicts with shared lore, shared lore wins until the canon is explicitly updated.

## Godot Rule

- Engine: Godot `4.6.2-stable`
- Language: GDScript only
- Tests: GUT `9.6.0` when test runtime is introduced
- Content source of truth: JSON definitions that generate Godot resources when content catalogs are introduced
- Playable scenes are editor-owned by default

Agents must not hand-edit `.tscn` files as raw text. If a scene must be created or changed without the editor, use a Godot script or tool.

## Architecture Rule

Keep the rules layer visual-agnostic while 2D and 3D are undecided.

Initial boundaries:

- `core/`: identifiers, contracts, snapshots, results, and domain-neutral helpers
- `systems/`: RPG rules such as character stats, inventory, dialogue, encounters, and save data
- `modes/`: boot, exploration/world, and turn-based card-slot battle mode assembly
- `world/`: exploration controllers and camera/presentation adapters; split into agnostic, 2D, and 3D lanes
- `battle/`: card-slot combat rules, turn order, action resolution, combatant state, rewards, and battle presentation contracts
- `ui/`: player-facing menus, dialogue UI, battle commands, inventory, and character sheets
- `data/`: authored definitions and generated resources
- `docs/`: local design and technical references
- `implementation/`: active status, tracks, handoffs, and execution notes

## Reuse Rule

`Projetos/rpg-isometrico/` may be used as a reference for Godot organization, validation patterns, input conventions, and isolated helpers.

Do not copy broad runtime systems before checking that they fit a turn-based RPG. Reuse should be explicit, narrow, and documented in `implementation/current-status.md` or the active track.
