# Track 01 - Foundation Contracts And First Prototype

- Status: `PHASE_03_CARDGAME_CORE_PASS_01_DONE`
- Last Updated: `2026-05-03`
- Goal: `prove the standalone cardgame combat loop before expanding RPG progression, character stats, lore, or campaign systems`

## Implemented Slice

- Menu with `Novo jogo` and `Sair`.
- Session-only game state.
- Small 2D top-down map with player movement, NPC, and encounter marker.
- NPC one-time card reward.
- Encounter gate that requires NPC reward first.
- Full 10-card deck setup with drag-and-drop.
- Turn-based 3-lane enemy-hero duel.
- Scripted enemy behavior.
- Victory result returning to map.
- Defeat result restoring the pre-combat snapshot with no penalty.
- JSON-driven content catalog and generated Godot resource.
- Generated playable scenes.
- GUT validation coverage.

## Phase 2 Polish Scope

- Improve deck setup clarity.
- Add button alternatives for common deck and battle actions.
- Show clearer player feedback for valid and invalid actions.
- Keep UI refreshes safe during drag/drop.
- Add UI-level regression tests for setup and battle.

## Implemented Phase 2 Polish Pass 01

- Setup counters for available and selected cards.
- Setup quick actions: `Limpar deck` and `Auto preencher`.
- Battle card action buttons for player slots, enemy slots, and enemy hero where valid.
- Battle feedback label for action results.
- GUT UI tests for deck setup and first battle play.

## Implemented Phase 2 Polish Pass 02

- Fixed top combat action bar with `Resolver turno`.
- Improved board/log/hand presentation.
- Compact battle cards and slots for the current debug viewport.
- UI test for resolving the turn after energy reaches zero.

## Implemented Phase 2 Polish Pass 03

- Fixed the combat layout so the hand panel remains visible inside the current debug viewport.

## Implemented Phase 3 Combat Pass 01

- Added the basic hero power `Preparar`.
- `Preparar` draws 1 card and can be used once per round.
- Added top-bar `Poder heroico` action and feedback.
- Added engine/UI regression tests.

## Cardgame-First Direction

- The next implementation focus is the cardgame core.
- RPG progression, character stats, lore-heavy content, inventory, and campaign structure remain deferred.
- The complete turn structure must be re-evaluated before being locked.
- Upcoming prototypes should test more elaborate turns if they improve decision density or pacing.
- Upcoming prototypes should test different board shapes, including boards more complex than the current 3 direct routes.
- Board positions may have attributes and should be explored as part of combat identity.
- Position attributes may affect targeting, routes, defense, attack, card costs, hazards, control, deployment rules, or encounter-specific objectives.
- A no-combat-phase variant should also be tested, where attacks happen as priority-spending actions during a shared main phase.
- Instant-speed actions may be tested as actions that do not spend priority.

## Cardgame Core Experiment Plan

Design reference:

- `../../../docs/cardgame-core-experiments.md`

Implementation reference:

- `cardgame-core-implementation-plan.md`

Immediate next pass:

- `Pass 02 - Phase State Machine`

Experiment matrix:

- `A1_B1`: active player plus responses, automated combat
- `A1_B2`: active player plus responses, interactive combat
- `A2_B1`: shared initiative, automated combat
- `A2_B2`: shared initiative, interactive combat
- `C1`: shared priority, no combat phase, attacks as main-phase actions

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Current expected result:

- `19` GUT tests passing.

## Next Decision Sessions

Open a design session before implementing any of these:

- final 2D versus 3D/isometric presentation
- real save/load
- Command/Presence resource
- first real narrative content pass
- RPG progression beyond card unlocks
- expanded enemy AI beyond deterministic scripts
- locked turn structure
- board topology and position attribute rules
