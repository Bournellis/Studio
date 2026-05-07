# Game Design Document

- Last Updated: `2026-05-07`
- Status: `bootstrap design`

## Direction

This is a roguelike cardgame with Draxos lore and a simple board battle presentation.

Combat should feel like two sides facing each other across a table. The board currently defines only how many creatures or permanents fit on each side for a given encounter.

The player character is always a Draxos commander. Gameplay identity is selected through `Classe`, not race. The first release direction expects 3 initial classes, each with its own starter deck, class mechanic, and possible mana profile. Class details require a dedicated design session before implementation.

## Core Loop

1. Start in the Draxos ship hub.
2. Choose a class before the run.
3. Enter the mission map.
4. Choose the next available node.
5. Resolve encounter, event, rest, upgrade, reward, or boss.
6. Return to the ship after battles to spend souls or continue the campaign route.
7. Continue until the run succeeds or fails.

There is no meta-progression for now. Defeat resets the full run.

## Battle Board

The initial board contract is intentionally simple:

- `player_slots_count`
- `enemy_slots_count`

Early battles should start with about 3 player slots, a small deck, and low mana. As the campaign advances, boards, deck size, enemy scale, and mana budget can grow until late fights support large cards and long card sequences.

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

Initial enemy director vocabulary:

- `prefilled_board`: enemy creatures start on the board and attack until cleared.
- `waves`: enemy creatures appear through scripted waves.
- `scripted_boss`: a boss executes scripted summoning or pressure patterns.
- `player_like`: an opposing character has life, deck behavior, and player-like presence.

The final encounter chain and enemy definitions require a dedicated map/enemy design session.

## Battle Economy

- Starting hand is 5 cards.
- Playing a card draws 1 card, keeping the hand stable when possible.
- Played cards go to discard.
- When the deck is empty, shuffle the discard back into the deck.
- Mana does not increase during an encounter.
- Mana can increase between encounters through rare upgrades, mainline milestones, class effects, or soul purchases.
- Other resources may exist, but they are class-specific.
- The active player's creatures attack automatically at end of turn.
- During the enemy turn, player creatures only receive damage.
- All classes may replace a creature by summoning into an occupied friendly slot, sacrificing the previous creature. Specific cards or classes may benefit from sacrifice.

## Run Rewards

- Post-combat rewards alter the current run immediately.
- Key mainline combats can grant special upgrades.
- Souls are ship currency, not per-mob accounting.
- Healing is difficult and currently costs souls.
- Optional encounters are risk/reward: they can grant more souls and upgrades, but can leave the commander injured or dead.

Initial soul reward bands:

- `small`: 4-6
- `medium`: 7-10
- `elite_optional`: 11-16
- `boss`: 18-25

## Mission Map

The map represents ship navigation and mission execution focused on the elemental planet. It should support a mainline sequence where completing one node unlocks another, plus sidequests that can open from mainline progress without blocking the main route.

## Pending Rule Decisions

These rules are intentionally not inherited from `rpg-turnos`:

- deck size
- exact class list and class mechanics
- exact map chain and encounter roster
- exact enemy scripts
- card upgrade/removal

They must be designed locally before being treated as final content.
