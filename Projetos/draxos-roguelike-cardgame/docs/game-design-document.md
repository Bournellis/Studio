# Game Design Document

- Last Updated: `2026-05-07`
- Status: `bootstrap design`

## Direction

This is a roguelike cardgame with Draxos lore and a simple board battle presentation.

Combat should feel like two sides facing each other across a table. The board currently defines only how many creatures or permanents fit on each side for a given encounter.

## Core Loop

1. Start in the Draxos ship hub.
2. Talk to NPCs or open ship systems.
3. Enter the mission map.
4. Choose the next available node.
5. Resolve encounter, event, rest, upgrade, reward, or boss.
6. Continue until the run succeeds or fails.

## Battle Board

The initial board contract is intentionally simple:

- `player_slots_count`
- `enemy_slots_count`

No active contract exists yet for:

- routes
- terrain
- elevation
- neutral slots
- tactical movement grid

Those RPG Turnos systems may remain in the temporary forked engine only as technical debt.

## Encounter Types

Initial encounter type vocabulary:

- `limpar_mesa`: win by clearing relevant enemy board presence.
- `duelo`: win by defeating an opposing character.
- `ondas`: fight sequential creature waves.
- `defesa_posicao`: protect a position or object.
- `sobreviver_turnos`: survive a configured number of turns.
- `chefe_summoner`: defeat a boss that summons multiple creatures.

## Pending Rule Decisions

These rules are intentionally not inherited from `rpg-turnos`:

- deck size
- starting hand
- draw model
- mana/resource model
- discard model
- reward choices
- card upgrade/removal
- run failure and meta progression

They must be designed locally before the first playable slice.
