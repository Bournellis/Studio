# Current Status

- Last Updated: `2026-05-04`
- Active Surface: `cardgame-first C1 battle modes`
- Active Project Name: `rpg-turnos`
- Active Track: `Track 01 - Foundation Contracts And First Prototype`
- Active Track Status: `C1_BATTLE_MODES_PASS_01_CLEAR_BOARD_IMPLEMENTED`
- Current Operational Baseline: `playable Godot 4.6.2 slice with menu, 2D exploration placeholder, 20-card deck setup, C1 as the sole runtime combat model, limpar_mesa encounter mode, data-driven boards/encounters, automatic enemy priority, simple visual battle feedback, generated scenes, JSON-driven catalog, and GUT validation`
- Active Goal: `prove the cardgame battle modes before returning to RPG progression, lore, stats, persistence, or final visual direction`
- Active Combat Direction: `C1 - main game, not a variant`
- Preserved Combat Ideas: `A/B priority variants and the phase-based duel are historical only in docs/cardgame-core-experiments.md`

## Read Next

- `../AGENTS.md`
- `../docs/game-design-document.md`
- `../docs/architecture.md`
- `../docs/cardgame-core-experiments.md`
- `roadmap.md`
- `tracks/track-01-foundation-first-prototype/cardgame-core-implementation-plan.md`
- `../docs/first-playable-slice-smoke.md`

## Current Runtime

- Deck setup requires exactly 20 unlocked cards.
- Decks may include at most 4 command cards.
- The setup screen has one entry button: `Iniciar encontro`.
- The active encounter is `emboscada_na_ponte`.
- The active mode is `limpar_mesa`.
- The old `Duelo antigo` button has been removed.
- The battle engine uses `controladores`, `modo_batalha`, `tabuleiro`, `turno`, `fase_principal`, and shared priority.
- Public phases are `manutencao`, `compra`, and `fase_principal`.
- Cleanup is internal.
- Player hero starts at 25 HP.
- Duel enemy hero baseline is 20 HP, used by the next official mode.
- Energy max starts at 3 and refreshes on the controller's upkeep.
- Initial hand is 4 cards; later own draws are 1 card.
- Hand limit is 8.
- Hero power is `Preparar Defesa`: costs 1 energy and grants 2 persistent armor.
- Enemy decisions resolve automatically until priority returns to the player.
- UI emits simple no-asset feedback for attack, damage, summon, armor, buff, and destruction.

## Implemented Battle Mode Pass 01

- `limpar_mesa` implemented with `Emboscada na Ponte`.
- Enemy side has turns, upkeep, priority, attacks, and starting units, but no enemy hero.
- Player attacks in empty lanes have no hero fallback in `limpar_mesa`.
- Creature-vs-creature damage is simultaneous.
- Creatures use `enjoo`, `pronta`, and `exausta`.
- `rapido`, `defensor`, `atropelar`, and `alcance` are represented in the rules/data.
- `cobertura` reduces ranged damage.
- `queimando` ticks on the occupant controller's upkeep.
- `duelo` exists in the engine/data as the next official mode but is not the current entry flow.

## Validation Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\rpg-turnos -s res://tools/validate.gd
```

Latest validation: `34/34` GUT tests passing.
