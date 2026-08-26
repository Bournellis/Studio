# AGENTS.md

## Metadata

- status: living
- authority: operational_contract
- last_verified: 2026-08-26
- review_when: governança, arquitetura ou gates locais mudarem
- supersedes: AGENTS.md anterior ao cutover de governança v2
- superseded_by: none

This file governs agent behavior for the Godot implementation of RPG Turnos.

## Project Role

`Projetos/rpg-turnos/` is a new Godot project for a 2D RPG with turn-based card-and-board battles.

The project is independent from `Projetos/rpg-isometrico/` at the mechanics and runtime level. It adopts only the Studio Core domains declared in `STUDIO_CORE.md`.

Current premise:

- provisional project name: `rpg-turnos`
- complete Godot project, started clean
- shared lore: only the `lore.v2` thematic authorities explicitly adopted in `STUDIO_CORE.md`
- the adopted expedition window is the sole authority for lore, characters, classes, narrative and the general expedition objective shared with Draxos Roguelike
- mechanics, runtime, encounter rules, progression, presentation and implementation remain local to RPG Turnos
- initial story: the Draxos commander leads the shared expedition against an elemental planet from an ether-plasm base under the Grande Mestre's strategic authority
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

1. `../../08_Coordenacao_Agentes/Prioridades_Estudio.md`
2. `implementation/current-status.md`
3. this file
4. `STUDIO_CORE.md`, then `../../STUDIO_CORE.md`, only when lore or universe is relevant
5. `docs/lore-campaign.md`
6. `docs/resume-brief.md`
7. `docs/game-design-document.md`
8. `docs/architecture.md`
9. `docs/class-catalog-schema.md`
10. touched files

For bounded work:

1. `implementation/current-status.md`
2. this file
3. `STUDIO_CORE.md` when lore or universe is relevant
4. touched files

## Canon Rule

Only the Core domains declared in `STUDIO_CORE.md` inform this project. The
expedition window there defines the exact shared scope with Draxos Roguelike;
neither project's local document becomes a second shared authority.

Do not silently import RPG Isometrico mechanics as RPG Turnos canon. The action
loadout, real-time combat, fixed action camera, and campaign progression rules
from RPG Isometrico are references only unless a local RPG Turnos document
explicitly adopts them.

If local RPG Turnos lore conflicts with an adopted Core fact, the Core fact wins until either the binding or Core canon is explicitly updated. Product and mechanics remain local.

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
- `implementation/`: active status, compact history, debt baseline and execution records

## Reuse Rule

`Projetos/rpg-isometrico/` may be used as a reference for Godot organization, validation patterns, input conventions, and isolated helpers.

Do not copy broad runtime systems before checking that they fit a turn-based RPG. Reuse should be explicit, narrow, and documented in an active local card and technical contract.
