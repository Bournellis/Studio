# Current Status

- Last Updated: `2026-05-02`
- Active Surface: `initial clean project skeleton`
- Active Project Name: `rpg-turnos`
- Active Track: `TBD`
- Active Track Status: `NOT_STARTED`
- Current Operational Baseline: `clean Godot 4.6.2 project skeleton with documentation and separated system directories; no playable scene, no final 2D/3D decision, and no turn-based battle runtime yet`
- Active Goal: `preserve a visual-agnostic RPG foundation while the project identity, combat model, and exploration presentation are still being defined`
- Read Next:
  - `../AGENTS.md`
  - `../docs/project-brief.md`
  - `../docs/architecture.md`
  - `tracks/README.md`
- Shared Canon Note: `this project may share lore with RPG Isometrico, but RPG Isometrico mechanics are not automatically RPG Turnos canon`
- Godot Baseline: `Godot 4.6.2-stable, GDScript only`
- Presentation Decision: `2D/3D/hybrid remains undecided`
- Validation Target: `structural documentation and Godot project shape only until runtime code and tests are introduced`
- Automated Validation: `not configured yet`
- Manual Smoke: `open the project in Godot and confirm the project metadata loads`
- Reuse Posture: `RPG Isometrico may be consulted for organization and isolated helpers after review; no broad runtime copy has been approved`
- Next Gate: `choose the first implementation track before adding runtime code`

## Initial Premises

- RPG Turnos is a new complete Godot project.
- It is mechanically independent from RPG Isometrico.
- It shares the broader studio lore direction.
- Exploration uses a freely moving map character.
- NPC conversations, route choices, encounters, items, stats, level, and inventory are expected pillars.
- Combat is turn-based and should be separated from exploration.
- RPG systems should stay visual-agnostic until 2D/3D direction is chosen.

## Suggested First Track

`Track 01 - Foundation Contracts And First Prototype`

Possible gates:

1. define pure data contracts for character profile, stats, inventory, dialogue state, encounter definition, and battle state
2. add minimal GUT test setup
3. create a non-playable boot scene through the editor or a Godot generation tool
4. prototype one world interaction that launches a mock battle state
5. prototype one turn cycle with placeholder combatants

