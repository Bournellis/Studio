# Cardgame Core Implementation Plan

- Last Updated: `2026-05-03`
- Status: `READY_FOR_PASS_03_C1`
- Source Design: `../../../docs/cardgame-core-experiments.md`
- Active Goal: `implement and prototype the C1 combat variant before locking the cardgame core`

This plan turns the current cardgame design session into implementation gates.

## Direction Decision (2026-05-03)

The project will prototype `C1 - Continuous Main Phase With Shared Priority And Attack Actions` as the **single active combat direction**.

The A/B priority and combat-resolution variants and the phase-based combat structure with a dedicated `combat` phase are **preserved as design ideas** in `../../../docs/cardgame-core-experiments.md`. They are **not** active implementation targets in this plan.

If C1 fails playtest in Pass 08, the preserved ideas are the documented fallback set.

## Implementation Rules

- Keep RPG progression, character stats, lore, inventory, and campaign systems deferred.
- Keep the rules layer visual-agnostic.
- Do not treat C1 as final canon until it is playtested.
- Prefer data-driven battle variant configuration over hardcoded one-off branches.
- Preserve the current playable slice while adding the C1 variant.
- The Pass 02 phase state machine is already configurable; C1 should plug in as a registered phase sequence rather than replacing the engine.
- Add GUT coverage for rules that can be tested without UI.
- Add UI regression coverage when a phase, priority, or action can lock the player out.

## Pass 02 - Phase State Machine

Status: `DONE`

Purpose: replace the current single `Resolver turno` mental model with explicit phases.

Implemented:

- phase enum or constants for `round_start`, `draw`, `main`, `main_1`, `combat`, `main_2`, `turn_end`
- phase sequence configuration per combat variant
- automatic phase advancement for `round_start`, `draw`, and `turn_end`
- player-controlled advancement for `main`, `main_1`, `combat`, and `main_2`
- phase label in battle UI
- log entries for phase transitions
- tests for phase order and automatic triggers

## Pass 03 - C1 Variant: Continuous Main Phase With Shared Priority And Attack Actions

Status: `NEXT - ACTIVE IMPLEMENTATION TARGET`

Purpose: implement and make playable the C1 variant defined in `cardgame-core-experiments.md` and `game-design-document.md` section 9.

### Scope

C1 is a single coherent combat variant. Implementation must deliver:

- a registered battle variant identifier `C1`
- a phase sequence for C1: `round_start -> draw -> main -> turn_end`
- shared priority during `main`, alternating between active player and opponent
- attacks as priority-spending actions inside `main`, with no dedicated `combat` phase
- per-creature once-per-turn attack tracking
- summoning sickness or equivalent attack eligibility tracking
- priority-spending action set: play creature, attack, cast non-instant spell, use hero power, use non-instant card ability, pass priority
- non-priority-spending action: instant-speed spell
- both-players-passed resolution rule that ends the active player's `main` and advances to `turn_end`
- explicit response window for instant-speed spells
- UI: priority owner indicator, attack-eligibility indicator per creature, action buttons gated by priority, log entries for priority pass and attack actions
- variant entry point so the C1 battle can be reached from the existing playable slice (via temporary menu branch, debug encounter selector, or a data-driven encounter flag)

### Detailed Implementation Targets

Engine layer (visual-agnostic, GDScript only, no Node2D/Node3D dependencies):

- battle variant configuration:
  - extend the existing variant config so each variant declares its phase sequence and rule profile
  - register `C1` with sequence `[round_start, draw, main, turn_end]`
  - register a `priority_model` field set to `shared` for C1
  - register a `combat_model` field set to `actions_in_main` for C1
- priority state:
  - `active_player_id`
  - `priority_owner_id`
  - `consecutive_passes` counter that resolves the phase when both players pass in a row
  - reset rules between phases
- action types:
  - `play_creature`
  - `attack`
  - `cast_non_instant_spell`
  - `use_hero_power`
  - `use_card_ability` (non-instant)
  - `pass_priority`
  - `cast_instant_spell` (does not spend priority)
- attack eligibility:
  - per-creature `summoning_sickness` flag set on entry, cleared at the start of the controller's next `round_start` (or equivalent rule, document the chosen one)
  - per-creature `attacks_used_this_turn` counter
  - default cap is 1 attack per turn unless an effect raises the cap
  - eligibility check covers: not summoning-sick, attacks remaining > 0, controller has priority, target is legal
- priority transitions:
  - any priority-spending action sets `priority_owner_id` to the opponent and resets `consecutive_passes` to 0
  - `pass_priority` increments `consecutive_passes` and flips `priority_owner_id`
  - when `consecutive_passes == 2`, the `main` phase ends and the engine advances to `turn_end`
- instant-speed window:
  - define and document a single explicit moment when instant-speed spells may be cast
  - the simplest defensible rule: any player may cast an instant-speed spell whenever it is legal and the engine is not in the middle of resolving an automatic effect
  - instant-speed casts do not change `priority_owner_id` and do not reset `consecutive_passes`

UI layer:

- phase label updated to show `Main` (single) instead of `Main 1 / Combat / Main 2` when the active variant is C1
- explicit "Prioridade: voce" / "Prioridade: inimigo" indicator above the action area
- visible attack action button on each player creature when it is eligible to attack
- visible "Passar prioridade" button when the player has priority
- block all priority-spending actions when the player does not have priority
- log lines for: phase change, priority change, priority pass, attack declared, attack resolved, instant-speed cast, both-players-passed resolution
- ensure no action button can disappear off-screen or lock the player out (preserve Pass 02 Pass 03 layout invariants)

Variant entry:

- add the simplest path that lets the C1 battle be launched from the existing playable slice; a debug `Iniciar duelo C1` menu entry is acceptable for prototype purposes
- the existing phase-based duel must remain reachable for comparison until Pass 08 evaluation

Tests (GUT):

- engine tests:
  - C1 phase sequence runs `round_start -> draw -> main -> turn_end`
  - automatic phases resolve without input
  - playing a creature passes priority
  - attacking passes priority
  - casting a non-instant spell passes priority
  - using a hero power passes priority
  - casting an instant-speed spell does not pass priority
  - two consecutive passes end `main` and advance to `turn_end`
  - a creature without summoning sickness can attack during `main`
  - a creature with summoning sickness cannot attack during the turn it entered
  - a creature cannot attack twice in the same turn unless an effect grants extra attacks
  - attacks resolve while the attacker still has priority (priority is passed after the attack action resolves)
- UI regression tests:
  - the action buttons are disabled when the player does not have priority
  - attack buttons appear only on eligible creatures
  - the priority indicator updates after each priority-spending action
  - both-players-passed resolution updates the phase label to `Turn End`

### Keep Temporary

- enemy AI may stay deterministic and scripted; C1 only needs a "pass-aware" enemy that knows how to use priority-spending actions and can choose `pass_priority`
- the current 3-route board may remain unchanged for this pass
- the current 10-card setup and energy curve may remain unchanged
- the existing phase-based variant must remain playable for comparison

### Exit Criteria

- the C1 battle is reachable from the playable slice
- the C1 battle plays from `round_start` to victory or defeat without locking
- both-players-passed correctly ends `main`
- summoning sickness, once-per-turn attacks, and attack eligibility behave as specified
- instant-speed spells do not spend priority
- the player can read at any moment whose priority window is active and which actions are available
- engine and UI tests cover the rules above and pass under `tools/validate.gd`

## Pass 04 - Combat Resolution Experiment (Preserved Idea)

Status: `PRESERVED_AS_DESIGN_IDEA`

Original purpose: test `B1 - Automated Combat` against `B2 - Interactive Combat`.

Why preserved: C1 supersedes the B1/B2 question by removing the dedicated combat phase entirely. If C1 fails playtest, this pass is the documented place to compare automated and interactive combat models within a phase-based structure.

Reference: `../../../docs/cardgame-core-experiments.md` section "Preserved Combat Resolution B1 / B2".

## Pass 05 - Phase-Based Variant (Preserved Idea)

Status: `PRESERVED_AS_DESIGN_IDEA`

Original purpose: prototype phase-based combat with explicit `Main Phase 1 / Combat / Main Phase 2` and either `A1` or `A2` priority.

Why preserved: C1 is the active direction. The phase-based variant remains supported by the Pass 02 engine and can be revisited if C1 fails playtest.

Reference: `../../../docs/cardgame-core-experiments.md` sections "Preserved Phase Structure" and "Preserved Priority Model A1 / A2".

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

This pass remains active regardless of which turn-structure variant is chosen.

## Pass 07 - Combat Lab Encounters For C1

Status: `PLANNED`

Purpose: build a small set of C1 encounters that stress-test the variant beyond the single duel.

Implement lab entries:

- `C1_baseline_duel`: the existing 3-route enemy-hero duel running under C1
- `C1_asymmetric`: a small asymmetric board encounter under C1
- `C1_objective`: an encounter with an objective position under C1
- `C1_no_enemy_hero`: a clear-the-board encounter without an enemy hero under C1

Implementation options:

- temporary menu branch
- debug encounter selector
- data-driven encounter list

Exit criteria:

- each lab encounter can be started from the game or a debug path
- each lab encounter uses the same small card pool where possible
- each lab encounter can end in victory or defeat

## Pass 08 - Evaluation And Lock Decision

Status: `PLANNED`

Purpose: decide whether C1 becomes the locked combat direction or whether the team falls back to one of the preserved phase-based variants.

Record:

- whether shared priority and attack-as-action felt better than phase-based combat
- which board attributes created meaningful choices
- which rules confused the player
- which UI states need redesign
- whether C1 should be promoted to canon or whether a preserved variant should be revived

Exit criteria:

- update `docs/cardgame-core-experiments.md` with findings
- update `docs/game-design-document.md` with locked or rejected rules
- update `implementation/roadmap.md` with the next implementation phase

## Recommended Immediate Next Step

Implement `Pass 03 - C1 Variant`.

Reason:

- C1 is the chosen active direction
- the Pass 02 phase state machine is configurable enough to accept C1 as a registered variant without engine rewrites
- the existing playable slice keeps the phase-based variant available for comparison until Pass 08
- the preserved A/B/B1/B2 ideas are documented and can be revisited only if C1 fails playtest
