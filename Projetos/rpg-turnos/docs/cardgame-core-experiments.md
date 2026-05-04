# Cardgame Core Experiments

- Last Updated: `2026-05-03`
- Status: `C1_SELECTED_AS_PRIMARY_FOCUS`
- Scope: `turn structure, priority model, combat resolution, continuous attack actions, board complexity, and position attributes`

This document records the cardgame-first design session.

## Direction Decision (2026-05-03)

The project will pursue `C1 - Continuous Main Phase With Shared Priority And Attack Actions` as the **primary combat direction**.

The other A/B priority and combat-resolution variants are **preserved as design ideas** in this document for future reference, but they are **not active implementation targets**. The combat lab matrix has been collapsed to focus implementation effort on a single coherent variant: C1.

Reasons for the decision:

- C1 fits the studio's stated preferred direction better than phase-based combat: shared priority, continuous tactical exchange, all card types available whenever priority is held.
- Implementing five lab variants in playable parity is expensive and risks diluting playtest signal.
- C1 is the most structurally different variant; if it works, it defines the game's identity. If it does not, falling back to a more conventional A/B variant is cheaper than the reverse.
- The Pass 02 phase state machine already supports configurable phase sequences, so C1 can use a shorter sequence (`round_start, draw, main, turn_end`) without removing the existing infrastructure.

This decision is the active direction, not final canon. C1 still needs prototyping and playtest before being locked in the GDD.

## Active Direction - C1 - Shared Priority With Attack Actions

The candidate flow is:

1. `Round Start` (automatic)
2. `Draw` (automatic)
3. `Main Phase` (interactive, shared priority)
4. `Turn End` (automatic)

### Round Start

Automatic phase. Triggers start-of-round effects, refreshes round state, prepares encounter timers or enemy intent if needed.

### Draw

Automatic phase. Draws cards, triggers draw effects, applies effects that care about hand size or deck state.

### Main Phase

Interactive phase with alternating priority between active player and opponent.

Any player may use any card type during the turn if they have priority and meet the card's requirements.

Available priority-spending actions:

- play a creature
- attack with an eligible creature
- cast a non-instant spell
- use a hero power
- use a card ability
- pass priority

Non-priority-spending actions:

- cast an instant-speed spell
- trigger automatic effects

Both players passing priority in succession ends the active player's main phase and advances the turn to `Turn End`.

### Turn End

Automatic phase. Triggers end-of-turn effects, reduces durations, cleans temporary effects, resolves delayed damage, hazards, or encounter timers.

### Attack Rules

- there is no dedicated combat phase
- a creature without summoning sickness may attack when its controller has priority
- each creature may attack once per turn by default unless a card effect says otherwise
- attack choice and target choice happen at the moment of the attack action

### Priority Rules

- playing a creature passes priority
- attacking passes priority
- casting a non-instant spell passes priority
- using a hero power passes priority
- using a non-instant card ability passes priority
- instant-speed spells do not spend priority
- the response window for instant-speed spells must be explicit in implementation

### Why C1

- may make turns feel more fluid than phase-based combat
- removes the artificial separation between preparation and combat
- makes attacking part of the main tactical exchange
- gives both players access to all card types whenever they have priority
- can create a stronger back-and-forth than a separate combat phase
- makes position attributes matter moment-to-moment instead of only at combat resolution

### Risks To Watch In Playtest

- could become harder to read than phase-based combat
- needs very clear UI for priority, active player, and available actions
- instant-speed effects may create confusing chains if not constrained
- attack availability must be visible per creature
- shared priority can create long decision chains; the UI must keep them legible

### Success Signals For C1

A C1 prototype is promising if:

- the player understands at a glance whose priority window is active
- the player understands why they can or cannot act
- passing priority is clear and low-friction
- attacking does not feel hidden behind unrelated actions
- board positions create meaningful decisions during attack and response
- the same deck plays differently across board layouts
- the log explains the result without becoming a wall of text

## Preserved Design Ideas (Not Active)

The following variants are intentionally **not being implemented**. They remain on record so that, if C1 fails playtest or generates issues we cannot resolve, we have a documented fallback set instead of starting from scratch.

### Preserved Phase Structure

The phase-based candidate flow:

1. `Round Start`
2. `Draw`
3. `Main Phase 1`
4. `Combat`
5. `Main Phase 2`
6. `Turn End`

Round Start, Draw, and Turn End would be automatic; Main Phase 1, Combat, and Main Phase 2 would be interactive. This is the structure the Pass 02 default sequence already supports and remains available as a fallback configuration if C1 needs to be replaced.

### Preserved Priority Model A1 - Active Player Plus Responses

The active player can play normal cards and abilities. The opponent can only play response-speed spells or abilities during response windows.

Strengths: easier to understand, easier to implement, easier to balance, gives a baseline against more ambitious interaction.

Weaknesses: may feel too conventional, may make the non-active player too passive, may reduce tactical back-and-forth.

### Preserved Priority Model A2 - Shared Initiative

Both players can act more broadly during shared windows. The difference is who currently has initiative or priority.

Strengths: more tactical back-and-forth, every phase feels contested, stronger identity.

Weaknesses: can become confusing without strong UI, can create long decision chains, requires strict pass and priority rules.

Note: C1 inherits A2's shared-priority spirit while removing the dedicated combat phase. In practice, C1 already covers most of what A2 would have tested.

### Preserved Combat Resolution B1 - Automated Combat

Players prepare positions, attack intent, and targets before combat. When combat starts, attacks resolve automatically.

Strengths: faster turn rhythm, board setup matters more, easier to simulate and validate.

Weaknesses: may make the most exciting phase feel passive, may hide too much strategy in pre-combat planning, may reduce dramatic response moments.

### Preserved Combat Resolution B2 - Interactive Combat

During combat, players choose attacks, targets, spells, and abilities through priority windows.

Strengths: more control during the highest-stakes phase, supports bluffing, responses, and tactical play.

Weaknesses: can make rounds too long, may require substantial UI clarity, needs careful priority rules.

### Preserved Lab Matrix

The original A/B/C lab matrix:

| Prototype | Priority Model | Combat Resolution | Status |
| --- | --- | --- | --- |
| `A1_B1` | Active plus responses | Automated combat | preserved as design idea |
| `A1_B2` | Active plus responses | Interactive combat | preserved as design idea |
| `A2_B1` | Shared initiative | Automated combat | preserved as design idea |
| `A2_B2` | Shared initiative | Interactive combat | preserved as design idea |
| `C1` | Shared priority for all card types | No combat phase; attacks are main-phase actions | **ACTIVE** |

If a future evaluation rejects C1, this matrix is the fallback exploration set.

## Board And Position Experiments

The current 3-route board is not final.

Future prototypes should also test:

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

These experiments are still planned regardless of which turn-structure variant is active. They live in `Pass 06 - Board Topology And Position Attributes` in the implementation plan.

## Terms To Define In C1 Implementation

The implementation must establish explicit definitions for:

- `phase`
- `priority`
- `initiative`
- `active_player`
- `passed_priority`
- `both_players_passed`
- `response_window`
- `attack_action`
- `once_per_turn_attack`
- `summoning_sickness` (or equivalent attack eligibility tracking)
- `instant_speed`
- `priority_spending_action`
- `non_priority_spending_action`
- `position_attribute`
- `automatic_trigger`

## Deferred

Do not spend implementation effort on these during the cardgame lab:

- RPG stats
- level progression
- equipment progression
- lore-heavy content
- real campaign structure
- save/load
- final 2D/3D visual direction
