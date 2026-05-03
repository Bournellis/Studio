# Cardgame Core Implementation Plan

- Last Updated: `2026-05-03`
- Status: `READY_FOR_PASS_02`
- Source Design: `../../../docs/cardgame-core-experiments.md`
- Active Goal: `prototype turn, priority, combat, board, and position rules before locking the cardgame core`

This plan turns the current cardgame design session into implementation gates.

The goal is not to immediately replace the current battle with the final rule set. The goal is to build testable combat variants that can be compared.

## Implementation Rules

- Keep RPG progression, character stats, lore, inventory, and campaign systems deferred.
- Keep the rules layer visual-agnostic.
- Do not treat any experiment variant as final canon until it is playtested.
- Prefer data-driven experiment configuration over hardcoded one-off branches.
- Preserve the current playable slice while adding a combat lab path or variant selector.
- Add GUT coverage for rules that can be tested without UI.
- Add UI regression coverage when a phase, priority, or action can lock the player out.

## Pass 02 - Phase State Machine

Status: `NEXT`

Purpose: replace the current single `Resolver turno` mental model with explicit phases.

Implement:

- phase enum or constants for:
  - `round_start`
  - `draw`
  - `main`
  - `main_1`
  - `combat`
  - `main_2`
  - `turn_end`
- phase sequence configuration per combat variant
- automatic phase advancement for `round_start`, `draw`, and `turn_end`
- player-controlled advancement for `main`, `main_1`, `combat`, and `main_2`
- phase label in battle UI
- log entries for phase transitions
- tests for phase order and automatic triggers

Keep temporary:

- current enemy behavior may stay deterministic
- current board may remain 3 routes
- current combat may remain simple while phases are introduced
- the `C1` no-combat-phase variant may be configured after the initial explicit phase pass

Exit criteria:

- the player can advance from `main_1` to `combat` to `main_2`
- a variant can later use `main` without `combat` or `main_2`
- automatic phases resolve without manual input
- no action button disappears off screen or locks the battle

## Pass 03 - Priority Model Experiment

Status: `PLANNED`

Purpose: test `A1 - Active Player Plus Responses` against `A2 - Shared Initiative`.

Implement:

- battle variant config for priority model
- priority owner state
- pass-priority action
- both-players-passed resolution rule
- response window support
- log lines explaining who has priority
- test doubles for enemy/player decisions

Variants:

- `A1`: active player can play normal actions; opponent can only respond
- `A2`: both sides can act in shared windows according to priority

Exit criteria:

- both priority models can run the same phase structure
- tests prove priority passes and phase advancement
- UI clearly communicates whose action window is active

## Pass 04 - Combat Resolution Experiment

Status: `PLANNED`

Purpose: test `B1 - Automated Combat` against `B2 - Interactive Combat`.

Implement:

- battle variant config for combat model
- automated attack resolution path
- interactive combat action path
- attack target selection
- combat pass-priority or pass-action flow
- combat spell/ability window placeholder
- tests for automated and interactive resolution

Variants:

- `B1`: combat resolves from board/intent with minimal player input
- `B2`: combat allows attack choices, targets, and response windows

Exit criteria:

- automated combat and interactive combat can be compared in play
- combat cannot deadlock if both players pass
- log explains why attacks resolved the way they did

## Pass 05 - Continuous Main Phase Variant

Status: `PLANNED`

Purpose: test `C1 - Shared Priority With Attack Actions`, a structurally different turn model without a dedicated combat phase.

Implement:

- battle variant config for `C1`
- phase sequence: `round_start`, `draw`, `main`, `turn_end`
- priority alternation during `main`
- all card types playable by any player with priority when legal
- attack action available during `main`
- per-creature once-per-turn attack tracking
- summoning sickness or equivalent attack eligibility tracking
- priority-spending action rules
- instant-speed action rules that do not spend priority
- clear UI/log messages for priority, attack availability, and instant actions

Rules to test:

- playing a creature passes priority
- attacking passes priority
- casting a non-instant spell passes priority
- using a character power passes priority
- instant-speed spells do not spend priority
- all players can use all card types on any turn if they have priority

Exit criteria:

- `C1` can run without entering a combat phase
- an eligible creature can attack during `main`
- a creature cannot attack more than once per turn unless a test effect allows it
- priority advances correctly after priority-spending actions
- instant actions resolve without spending priority
- tests cover attack eligibility, priority passing, and instant-speed behavior

## Pass 06 - Board Topology And Position Attributes

Status: `PLANNED`

Purpose: stop assuming that the 3-route board is final.

Implement:

- board definition data model
- position definition data model
- route definition data model
- position attributes in authored content
- battle engine support for position modifiers
- at least three test boards:
  - simple 3-route baseline
  - asymmetrical board
  - board with objective or neutral positions

Initial position attributes to test:

- `cover`: reduces incoming attack damage
- `high_ground`: improves outgoing attack or targeting
- `hazard`: deals damage at a phase boundary
- `objective`: contributes to victory or pressure

Exit criteria:

- encounters can select a board definition
- position attributes affect rules, not just labels
- tests cover at least one modifier, one route difference, and one objective position

## Pass 07 - Combat Lab Encounters

Status: `PLANNED`

Purpose: make the matrix variants playable enough for comparison.

Implement lab entries:

- `A1_B1`: active plus responses, automated combat
- `A1_B2`: active plus responses, interactive combat
- `A2_B1`: shared initiative, automated combat
- `A2_B2`: shared initiative, interactive combat
- `C1`: shared priority, no combat phase, attacks as main-phase actions

Implementation options:

- temporary menu branch
- debug encounter selector
- data-driven encounter list

Exit criteria:

- each variant can be started from the game or a debug path
- each variant uses the same small card pool where possible
- each variant can end in victory or defeat

## Pass 08 - Evaluation And Lock Candidate

Status: `PLANNED`

Purpose: choose what should become the main cardgame direction.

Record:

- which priority model felt better
- which combat model felt better
- whether no-combat-phase attacks felt better than a dedicated combat phase
- which board attributes created meaningful choices
- which rules confused the player
- which UI states need redesign
- which variant should become the main implementation path

Exit criteria:

- update `docs/cardgame-core-experiments.md` with findings
- update `docs/game-design-document.md` with locked or rejected rules
- update `implementation/roadmap.md` with the next implementation phase

## Recommended Immediate Next Step

Implement `Pass 02 - Phase State Machine` first.

Reason:

- every later experiment needs explicit phases
- it can be built without deciding the final priority model
- it makes the current battle closer to the desired candidate turn structure
- it creates a stable place for automatic triggers and later response windows
