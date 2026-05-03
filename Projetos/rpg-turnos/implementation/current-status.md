# Current Status

- Last Updated: `2026-05-03`
- Active Surface: `first playable slice`
- Active Project Name: `rpg-turnos`
- Active Track: `Track 01 - Foundation Contracts And First Prototype`
- Active Track Status: `SLICE_01_PLAYABLE`
- Current Operational Baseline: `playable Godot 4.6.2 first slice with menu, 2D top-down exploration, NPC card reward, 10-card deck setup, scripted enemy-hero duel, result flow, generated scenes, JSON-driven catalog, and GUT validation`
- Active Goal: `stabilize the first playable RPG-cardgame loop while preserving visual-agnostic rules for a future 3D/isometric presentation decision`
- Read Next:
  - `../AGENTS.md`
  - `../docs/project-brief.md`
  - `../docs/game-design-document.md`
  - `../docs/architecture.md`
  - `tracks/README.md`
  - `../docs/first-playable-slice-smoke.md`
- Shared Canon Note: `this project may share lore with RPG Isometrico, but RPG Isometrico mechanics are not automatically RPG Turnos canon`
- Godot Baseline: `Godot 4.6.2-stable, GDScript only`
- Presentation Decision: `first slice uses 2D top-down presentation only; final 2D/3D/hybrid direction remains undecided`
- Validation Target: `generated content, generated scenes, first-slice contract, and GUT runtime tests`
- Automated Validation: `run Godot headless with res://tools/validate.gd`
- Manual Smoke: `../docs/first-playable-slice-smoke.md`
- Reuse Posture: `GUT and validation pattern were reused narrowly from RPG Isometrico; no action-RPG runtime systems were imported`
- Next Gate: `playtest this slice, then define the next design session for either battle depth, RPG progression, content authoring, or visual direction`

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

## Implemented First Playable Slice

- Menu: `Novo jogo` and `Sair`.
- Session: in-memory only; no disk save/load.
- Exploration: small 2D top-down placeholder map with `WASD` movement and `E` interaction.
- NPC: grants `Balista Improvisada` once, unlocking an 11th card for setup.
- Encounter gate: the duel opens only after the NPC reward.
- Deck setup: full 10-card setup from unlocked individual card entries, with drag-and-drop UI.
- Battle: enemy-hero duel with 3 player slots, 3 enemy slots, hand size 3, energy starting at 1 and scaling by round up to 6.
- Enemy AI: deterministic script.
- Defeat: restores the pre-combat snapshot with no penalty.
- Victory: marks the encounter complete and returns to the map.
- Command/Presence: still deferred.

## Validation Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

After a fresh checkout or GUT update, run a one-time editor import before validation:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos --editor --quit
```
