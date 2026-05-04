# Current Status

- Last Updated: `2026-05-03`
- Active Surface: `cardgame-first combat core`
- Active Project Name: `rpg-turnos`
- Active Track: `Track 01 - Foundation Contracts And First Prototype`
- Active Track Status: `PHASE_03_CARDGAME_CORE_PASS_02_DONE`
- Current Operational Baseline: `playable Godot 4.6.2 first slice with menu, 2D top-down exploration, NPC card reward, polished 10-card deck setup, scripted enemy-hero duel with explicit phase state machine, improved combat presentation, basic hero power, result flow, generated scenes, JSON-driven catalog, and GUT validation`
- Active Goal: `prototype the C1 combat variant (continuous main phase, shared priority, attacks as actions) as the active cardgame direction, before expanding RPG progression, character stats, lore content, persistence, or final visual direction`
- Active Combat Direction: `C1 - Continuous Main Phase With Shared Priority And Attack Actions`
- Preserved Combat Ideas: `A1, A2, B1, B2, and the phase-based Combat phase structure are preserved as design ideas in docs/cardgame-core-experiments.md but are not active implementation targets`
- Read Next:
  - `../AGENTS.md`
  - `../docs/project-brief.md`
  - `../docs/game-design-document.md`
  - `../docs/cardgame-core-experiments.md`
  - `../docs/architecture.md`
  - `roadmap.md`
  - `tracks/README.md`
  - `tracks/track-01-foundation-first-prototype/cardgame-core-implementation-plan.md`
  - `../docs/first-playable-slice-smoke.md`
- Shared Canon Note: `this project may share lore with RPG Isometrico, but RPG Isometrico mechanics are not automatically RPG Turnos canon`
- Godot Baseline: `Godot 4.6.2-stable, GDScript only`
- Presentation Decision: `first slice uses 2D top-down presentation only; final 2D/3D/hybrid direction remains undecided`
- Validation Target: `generated content, generated scenes, first-slice contract, and GUT runtime tests`
- Automated Validation: `run Godot headless with res://tools/validate.gd`
- Manual Smoke: `../docs/first-playable-slice-smoke.md`
- Reuse Posture: `GUT and validation pattern were reused narrowly from RPG Isometrico; no action-RPG runtime systems were imported`
- Next Gate: `implement Cardgame Core Pass 03 - C1 Variant (continuous main phase, shared priority, attacks as actions)`

## Initial Premises

- RPG Turnos is a new complete Godot project.
- It is mechanically independent from RPG Isometrico.
- It shares the broader studio lore direction.
- The baseline play mode is singleplayer; future co-op is possible but not active scope.
- Exploration uses a freely moving map character.
- NPC conversations, route choices, encounters, items, stats, level, and inventory are expected future pillars, but they are deferred while the cardgame core is being proven.
- The deck evolves with RPG progression, and the player chooses the setup/deck loadout before each combat.
- Energy starts at 1, scales by round, and may be changed by hero choice or abilities.
- Defeat reloads to the pre-combat state with no negative consequence.
- Command/Presence is deferred; it remains a future optional design suggestion and is not required for prototype 0.1.
- Combat is turn-based, card-driven, and separated from exploration.
- The current combat direction is a cardgame of fixed board slots where the hero does not move on the combat board.
- Creatures, structures, and support permanents can occupy slots; spells and commands usually do not.
- Encounters own board shape, special rules, enemy behavior, and victory conditions.
- RPG systems should stay visual-agnostic until 2D/3D direction is chosen.
- Current implementation priority is the cardgame itself, not RPG character progression, stats, lore, or campaign systems.
- Turn rules are not final and must be re-evaluated through prototypes before being treated as combat canon.
- Board shape is not final; upcoming passes should test different and more complex boards.
- Board positions may have attributes, such as lane modifiers, terrain-like rules, targeting constraints, defense bonuses, attack bonuses, hazards, control effects, or encounter-specific behavior.

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

## Formal Roadmap

The active project roadmap is tracked in `roadmap.md`.

## Implemented Phase 2 Polish Pass 01

- Deck setup now shows available/selected card counts.
- Deck setup has `Limpar deck` and `Auto preencher` button actions.
- Battle hand cards expose button actions for valid slot/hero targets.
- Battle UI shows textual feedback for played cards and turn actions.
- Drag/drop refreshes stay deferred during UI rebuilds.
- UI regression tests cover setup population, deck actions, drop on occupied deck slots, and first battle card play.

## Implemented Phase 2 Polish Pass 02

- Combat layout is now split into fixed top status/action bar, center board/log area, and bottom hand/action area.
- `Resolver turno` remains visible after cards are played and energy reaches zero.
- Board presentation separates enemy hero, enemy slots, direct routes, player slots, and log panel.
- Battle cards and slots are more compact to fit the current debug viewport.
- UI regression tests cover turn resolution after spending all first-round energy.

## Implemented Phase 2 Polish Pass 03

- The central combat area no longer expands enough to push the hand panel below the visible viewport.
- The hand stays in the lower panel with scroll after the board/log presentation is shown.

## Implemented Phase 3 Combat Pass 01

- Added player hero power `Preparar`.
- `Preparar` draws 1 card once per round.
- Added `Poder heroico` button to the fixed top combat bar.
- Added engine and UI tests for hero power usage and round reset.

## Implemented Cardgame Core Pass 02

- Added explicit battle phases: `round_start`, `draw`, `main_1`, `combat`, `main_2`, and `turn_end`.
- Added phase sequence configuration support for future variants such as `C1`.
- Automatic phases now resolve without player input and land on the next interactive phase.
- Manual phase advancement now drives `main_1 -> combat -> main_2 -> next round`.
- The combat UI now displays the current phase and changes the main action button by phase.
- Main actions are currently restricted to main phases.
- Engine and UI tests cover phase order, automatic phase resolution, UI phase labels, and action blocking outside main phases.

## Cardgame-First Direction Update (2026-05-03)

- The active combat direction is `C1 - Continuous Main Phase With Shared Priority And Attack Actions`.
- The combat lab matrix has been collapsed: A1, A2, B1, B2, and the phase-based Combat phase structure are preserved as design ideas in `../docs/cardgame-core-experiments.md` but are not active implementation targets.
- Implementation effort focuses on a single coherent variant (C1) instead of five.
- If C1 fails playtest in Pass 08, the preserved ideas are the documented fallback set.
- Map, NPC, stats, character progression, items, and lore remain minimal placeholders until the cardgame loop is stronger.
- Current design session is registered in `../docs/cardgame-core-experiments.md`.
- Current implementation plan is registered in `tracks/track-01-foundation-first-prototype/cardgame-core-implementation-plan.md`.

## Next Implementation Plan

Use the cardgame lab plan instead of expanding RPG systems.

Immediate next pass:

- `Pass 03 - C1 Variant: Continuous Main Phase With Shared Priority And Attack Actions`

Planned follow-up passes:

- `Pass 04`: combat resolution experiment (PRESERVED_AS_DESIGN_IDEA)
- `Pass 05`: phase-based variant fallback (PRESERVED_AS_DESIGN_IDEA)
- `Pass 06`: board topology and position attributes (PLANNED, runs regardless of variant)
- `Pass 07`: combat lab encounters focused on C1 (PLANNED)
- `Pass 08`: evaluation and decision to promote C1 to canon or revive a preserved variant (PLANNED)

## Validation Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

After a fresh checkout or GUT update, run a one-time editor import before validation:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos --editor --quit
```
