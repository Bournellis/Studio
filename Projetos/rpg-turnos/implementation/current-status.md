# Current Status

- Last Updated: `2026-05-03`
- Active Surface: `initial design documentation`
- Active Project Name: `rpg-turnos`
- Active Track: `TBD`
- Active Track Status: `NOT_STARTED`
- Current Operational Baseline: `clean Godot 4.6.2 project skeleton with documentation, separated system directories, and initial GDD for a turn-based RPG-cardgame of fixed board slots; no playable scene, no final 2D/3D decision, and no battle runtime yet`
- Active Goal: `preserve a visual-agnostic RPG-cardgame foundation while the project identity, combat model, and exploration presentation are still being defined`
- Read Next:
  - `../AGENTS.md`
  - `../docs/project-brief.md`
  - `../docs/game-design-document.md`
  - `../docs/architecture.md`
  - `tracks/README.md`
- Shared Canon Note: `this project may share lore with RPG Isometrico, but RPG Isometrico mechanics are not automatically RPG Turnos canon`
- Godot Baseline: `Godot 4.6.2-stable, GDScript only`
- Presentation Decision: `2D/3D/hybrid remains undecided`
- Validation Target: `structural documentation, GDD coherence, and Godot project shape only until runtime code and tests are introduced`
- Automated Validation: `not configured yet`
- Manual Smoke: `open the project in Godot and confirm the project metadata loads`
- Reuse Posture: `RPG Isometrico may be consulted for organization and isolated helpers after review; no broad runtime copy has been approved`
- Next Gate: `choose the first implementation track before adding runtime code`

## Initial Premises

- RPG Turnos is a new complete Godot project.
- It is mechanically independent from RPG Isometrico.
- It shares the broader studio lore direction.
- The baseline play mode is singleplayer; future co-op is possible but not active scope.
- Exploration uses a freely moving map character.
- NPC conversations, route choices, encounters, items, stats, level, and inventory are expected pillars.
- The deck evolves with RPG progression, and the player chooses the setup/deck loadout before each combat.
- Energy starts at 1, scales by round, and may be changed by hero choice or abilities.
- Defeat reloads to the pre-combat state with no negative consequence.
- Command/Presence is deferred; it remains a future optional design suggestion and is not required for prototype 0.1.
- Combat is turn-based, card-driven, and separated from exploration.
- The current combat direction is a cardgame of fixed board slots where the hero does not move on the combat board.
- Creatures, structures, and support permanents can occupy slots; spells and commands usually do not.
- Encounters own board shape, special rules, enemy behavior, and victory conditions.
- RPG systems should stay visual-agnostic until 2D/3D direction is chosen.

## Suggested First Track

`Track 01 - Foundation Contracts And First Prototype`

Possible gates:

1. define pure data contracts for character profile, stats, inventory, dialogue state, encounter definition, and battle state
2. define pure data contracts for cards, decks, hands, board slots, routes, hero battle state, and encounter objectives
3. add minimal GUT test setup
4. create a non-playable boot scene through the editor or a Godot generation tool
5. prototype one abstract 3-slot battle with energy starting at 1 and scaling by round, without committing to 2D/3D presentation
