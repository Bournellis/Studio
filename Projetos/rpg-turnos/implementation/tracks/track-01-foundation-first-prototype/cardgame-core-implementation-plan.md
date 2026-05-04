# Cardgame Core Implementation Plan

- Last Updated: `2026-05-04`
- Status: `C1_BATTLE_MODES_PASS_01_IMPLEMENTED`

## Summary

C1 is the current game. Implementation work now targets official battle modes rather than variants.

The old phase-based duel and A/B alternatives are historical only and must not be exposed in runtime UI.

## Implemented Pass 01 - Core C1 And `limpar_mesa`

Implemented:

- public phases `manutencao`, `compra`, `fase_principal`
- internal cleanup after two consecutive passes
- `controladores` for player and enemy side
- controller-specific energy, deck, hand, discard, hero state, and hero power usage
- 3 max energy, initial hand 4, hand limit 8
- 20-card deck setup
- deck command limit of 4 command cards
- `Preparar Defesa` hero power
- armor before hero health
- data-driven cards, boards, and encounters
- `Emboscada na Ponte` as `limpar_mesa`
- enemy automatic decisions until priority returns to the player
- simple visual events for attack, damage, summon, armor, buff, and destruction

## Current Runtime Mode

`limpar_mesa`:

- no enemy hero
- enemy side still has turns, upkeep, attacks, and priority
- player attacks require an occupied route target unless the encounter later defines an objective fallback
- victory when all relevant enemy permanents are removed
- defeat when player hero reaches 0 HP

## Next Pass - `duelo`

Implement as official runtime mode after `limpar_mesa` testing:

- entry selection or encounter progression
- enemy hero at 20 HP
- enemy deck, hand, draw, energy, and discard visible in engine state
- simple duel AI
- empty-lane attacks can hit enemy hero
- victory when enemy hero reaches 0 HP

## Future Modes

Prepare through data and encounter rules, not variant branches:

- `ondas`
- `defesa`
- `chefe_multiparte`
- `quebra_cabeca`

## Acceptance

- `res://tools/validate.gd` passes.
- UI has no variant selector or `Duelo antigo`.
- Battle HUD remains usable at `960x540`, `1100x619`, and `1280x720`.
- GUT covers turn/priority, resources, deck rules, attacks, terrain, automatic enemy behavior, modes, and UI layout.
