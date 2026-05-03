# Cardgame Core Experiments

- Last Updated: `2026-05-03`
- Status: `DESIGN_EXPERIMENTS_DEFINED`
- Scope: `turn structure, priority model, combat resolution, continuous attack actions, board complexity, and position attributes`

This document records the current cardgame-first design session.

These rules are not final combat canon. They are experiment targets for the next implementation passes.

## Design Goal

The next project focus is to test whether the combat can stand as a strong cardgame before expanding RPG progression, character stats, lore, inventory, or campaign systems.

## Candidate Turn Structure

The current candidate turn/round structure is:

1. `Round Start`
2. `Draw`
3. `Main Phase 1`
4. `Combat`
5. `Main Phase 2`
6. `Turn End`

### Round Start

Automatic phase.

Expected responsibilities:

- trigger start-of-round effects
- refresh or adjust round state
- prepare encounter timers or enemy intent if needed

### Draw

Automatic phase.

Expected responsibilities:

- draw cards
- trigger effects that care about drawing
- trigger effects that care about hand size or deck state

### Main Phase 1

Interactive phase.

The active player, or players depending on the priority model being tested, may:

- play cards
- deploy permanents
- cast spells
- use hero powers
- use card abilities
- change board state before combat
- choose when to pass the phase

### Combat

Interactive or automatic depending on the combat resolution model being tested.

This phase is the main unresolved design axis.

### Main Phase 2

Interactive phase after combat.

This phase may allow:

- rebuilding board position
- playing post-combat spells
- using abilities after damage has resolved
- preparing for the opponent or next round
- choosing when to pass the phase

### Turn End

Automatic phase.

Expected responsibilities:

- trigger end-of-turn effects
- reduce durations
- clean temporary effects
- resolve delayed damage, hazards, or encounter timers

## Experiment Axis A - Priority Model

This axis tests how much each player can play during the other player's turn.

### A1 - Active Player Plus Responses

The active player can play normal cards and abilities.

The opponent can only play response-speed spells or abilities during response windows.

Why test it:

- easier to understand
- easier to implement
- easier to balance
- gives a baseline against more ambitious interaction

Risks:

- may feel too conventional
- may make the non-active player too passive
- may reduce tactical back-and-forth

### A2 - Shared Initiative

Both players can act more broadly during shared windows.

The difference is who currently has initiative or priority. A player with priority can act, then the other player can respond, act, or pass depending on the phase rules.

Why test it:

- closer to the current preferred direction
- creates more tactical back-and-forth
- makes every phase feel contested
- may create a stronger identity for the game

Risks:

- can become confusing without strong UI
- can create long decision chains
- requires strict pass and priority rules

## Experiment Axis B - Combat Resolution

This axis tests how much control players have during combat.

### B1 - Automated Combat

Players prepare positions, attack intent, and targets before combat.

When combat starts, attacks resolve automatically.

Why test it:

- faster turn rhythm
- board setup matters more
- easier to simulate and validate
- useful baseline for comparison

Risks:

- may make the most exciting phase feel passive
- may hide too much strategy in pre-combat planning
- may reduce dramatic response moments

### B2 - Interactive Combat

During combat, players choose attacks, targets, spells, and abilities through priority windows.

Why test it:

- closer to the current preferred direction
- gives more control during the highest-stakes phase
- supports bluffing, responses, and tactical play
- can make position attributes matter more moment-to-moment

Risks:

- can make rounds too long
- may require substantial UI clarity
- needs careful priority rules to avoid confusion

## Prototype Matrix

The next cardgame lab should test the four A/B combinations plus the C variant:

| Prototype | Priority Model | Combat Resolution | Purpose |
| --- | --- | --- | --- |
| `A1_B1` | Active plus responses | Automated combat | Simple baseline |
| `A1_B2` | Active plus responses | Interactive combat | Traditional interactive comparison |
| `A2_B1` | Shared initiative | Automated combat | Contested setup with fast combat |
| `A2_B2` | Shared initiative | Interactive combat | Main candidate direction |
| `C1` | Shared priority for all card types | No combat phase; attacks are main-phase actions | Different structural test |

Current leaning:

- priority model: `A2 - Shared Initiative`
- combat resolution: `B2 - Interactive Combat`
- structural wildcard: `C1 - Shared Priority With Attack Actions`

This leaning should not be treated as final until the prototypes are playable.

## Experiment Axis C - Continuous Main Phase

This axis tests a substantially different turn structure.

Instead of having a separate `Combat` phase, attacks happen as actions during a shared `Main Phase`.

Candidate flow:

1. `Round Start`
2. `Draw`
3. `Main Phase`
4. `Turn End`

### C1 - Shared Priority With Attack Actions

`Round Start` is automatic and triggers start-of-round effects.

`Draw` is automatic, draws cards, and triggers draw effects.

`Main Phase` alternates priority between the active player and the other player.

Any player may use any card type on any turn if they have priority and meet the card's requirements.

Available priority-spending actions may include:

- play a creature
- attack with an eligible creature
- cast a non-instant spell
- use a character power
- use a card ability
- pass priority

Attacking rules to test:

- there is no dedicated combat phase
- each creature without summoning sickness may attack when its controller has priority
- each creature may attack once per turn by default
- card effects may allow extra attacks or change attack restrictions
- attack choice and target choice happen at the moment of the attack action

Priority rules to test:

- playing a creature passes priority
- attacking passes priority
- casting a normal spell passes priority
- using a character power passes priority
- instant-speed spells do not spend priority
- the exact response window for instant-speed spells must be explicit in implementation

Why test it:

- may make turns feel more fluid
- removes the separation between preparation and combat
- makes attacking part of the main tactical exchange
- gives both players access to all card types whenever they have priority
- may create a stronger back-and-forth than a separate combat phase

Risks:

- could become harder to read than phase-based combat
- needs very clear UI for priority, active player, and available actions
- instant-speed effects may create confusing chains if not constrained
- attack availability must be visible per creature

## Board And Position Experiments

The current 3-route board is not final.

Upcoming prototypes should also test:

- boards with more than 3 routes
- asymmetrical boards
- support rows
- objective slots
- neutral slots
- blocked or conditional routes
- encounter-specific slots

Positions may have attributes such as:

- defense bonus
- attack bonus
- spell cost modifier
- deployment restriction
- route modifier
- protection
- hazard damage
- healing
- control value
- objective value

Position attributes should be represented as combat rules, not only visual labels.

## Terms To Define In Implementation

The implementation plan should establish explicit definitions for:

- `phase`
- `priority`
- `initiative`
- `active_player`
- `passed_priority`
- `both_players_passed`
- `response_window`
- `combat_action`
- `attack_intent`
- `attack_action`
- `once_per_turn_attack`
- `instant_speed`
- `priority_spending_action`
- `non_priority_spending_action`
- `position_attribute`
- `automatic_trigger`

## Success Signals

A prototype is promising if:

- the player understands why they can or cannot act
- passing priority is clear
- combat does not feel like waiting through hidden rules
- board positions create meaningful decisions
- the same deck plays differently across board layouts
- the log explains the result without becoming a wall of text

## Deferred

Do not spend implementation effort on these during the cardgame lab:

- RPG stats
- level progression
- equipment progression
- lore-heavy content
- real campaign structure
- save/load
- final 2D/3D visual direction
