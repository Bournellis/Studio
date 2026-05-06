# Cardgame Core Implementation Plan

- Last Updated: `2026-05-05`
- Status: `ONDAS_MODE_COMPLETE`

## Summary

C1 is the current game. Implementation work now targets official battle modes rather than variants.

The old phase-based duel and A/B alternatives are historical only and must not be exposed in runtime UI.

## Implemented Pass 01 - Core C1 And `limpar_mesa`

This is a historical implementation baseline. It records what Pass 01 shipped, not the full active GDD target.

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

Superseded by current GDD rules:

- initial hand `4` -> `5`
- fixed hand limit `8` -> `max_hand_size` 5..7 plus temporary ceiling 8
- draw 1 per turn -> draw up to current `max_hand_size`
- discard pile -> bottom-of-deck cyclic model
- fixed max energy 3 -> energy ramp 3..8
- no public `descarte` phase -> `descarte` as fourth public phase
- `size` / `size_limit` placement -> removed
- `manter_linha` present in catalog -> deleted

## Implemented Foundation Runtime Alignment

Completed on `2026-05-05`:

- stale `size` / `size_limit` runtime and tests removed
- `manter_linha` deleted from active catalog and generated resource
- energy ramp, hand progression, cyclic deck, and public `descarte` implemented
- validation and GUT coverage updated

## Current Runtime Modes

`limpar_mesa`:

- no enemy hero
- enemy side still has turns, upkeep, attacks, and priority
- player attacks require an occupied route target unless the encounter later defines an objective fallback
- victory when all relevant enemy permanents are removed
- defeat when player hero reaches 0 HP

## Implemented Official `duelo`

Implemented as the first hero-vs-hero runtime mode:

- enemy hero at 20 HP
- enemy deck, hand, draw, and energy visible in engine state
- simple aggressive duel AI
- empty-lane attacks can hit enemy hero
- victory when enemy hero reaches 0 HP

## Implemented World Progression And Rewards

- linear encounter chain on the world map
- completed encounters can be re-entered without duplicate rewards
- encounter rewards are claimed once
- NPC rewards progress from `first_npc_reward_card` into `npc_reward_choices`
- progression fields are included in `GameSession` snapshot/restore

## Implemented Minimum Save/Load

The linear slice persists before adding more content:

- unlocked cards
- selected deck
- completed encounters
- claimed rewards
- NPC reward index
- active encounter when needed
- corrupt/missing save fallback

## Implemented Visual/UX Hardening

Improved readability before content expansion:

- battle HUD
- slot and target states
- world markers
- reward/result feedback

## Implemented Art-Ready Placeholder Structure

Prepared screens for later asset import:

- `UiTokens`
- named art nodes
- card and battle art placeholders
- `AssetIds`

## Implemented Candidate Pass - `ondas`

Added the next small official mode through data and encounter rules:

- wave definitions
- spawn next wave after clearing current wave
- final-wave victory
- wave indicator in battle UI
- focused validation coverage

## Future Modes

Prepare through data and encounter rules, not variant branches:

- `defesa`
- `chefe_multiparte`
- `quebra_cabeca`

## Acceptance

- `res://tools/validate.gd` passes.
- UI has no variant selector or `Duelo antigo`.
- Battle HUD remains usable at `960x540`, `1100x619`, and `1280x720`.
- GUT covers turn/priority, resources, deck rules, attacks, terrain, automatic enemy behavior, modes, and UI layout.
