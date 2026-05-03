# RPG Turnos Game Design Document

- Version: `0.1`
- Last Updated: `2026-05-03`
- Status: `INITIAL DESIGN DRAFT`
- Source Material: `C:/Users/Fabio/Downloads/sistema_base_combate_card_rpg.md`

## 1. Purpose

This document is the initial Game Design Document for `rpg-turnos`.

It captures the first concrete combat direction for the project and turns it into a working design reference for future Codex sessions. It is not final canon. Many rules are expected to change during prototyping.

When this document marks something as `TBD`, agents must not silently decide it during implementation.

## 2. Project Identity

`rpg-turnos` is a separate Godot RPG project that may share the broader studio lore with RPG Isometrico.

Mechanically, it is not RPG Isometrico. It is not a real-time action RPG.

The project combines:

- free exploration on a map
- NPC conversations
- route and encounter choices
- character level, stats, items, equipment, passives, and progression
- turn-based battles built around cards and fixed board slots

The current combat identity is:

> The player is an RPG hero inside a card battle. The hero does not move on the battle board. The player uses creatures, spells, permanents, hero abilities, equipment, and campaign stats to control fixed confrontation lanes, special slots, terrain, and encounter objectives.

## 3. Current Design Commitments

These decisions are stable enough to guide the first design pass.

- Battles are turn-based.
- Exploration and battle are separate modes.
- The visible exploration character is not directly moved on the combat board.
- In battle, the player character functions as the hero/player of the match.
- The combat board is an arena of fixed slots, not a tactical movement grid.
- Positioning matters through where cards and permanents are placed.
- Cards are central combat tools.
- Creatures, structures, and support permanents can occupy slots.
- Spells and commands usually do not occupy slots.
- Each encounter owns its board shape, enemy setup, special rules, and victory condition.
- Boards do not need to be fair or symmetrical.
- Some encounters may have an enemy hero/player; others may be scripted encounters without one.
- Sidequests can make future encounters easier by giving options, information, cards, passives, equipment, or board advantages.

## 4. Explicit Non-Commitments

These areas are not decided yet.

- final project name
- 2D, 3D, or hybrid presentation
- exact camera model
- exact exploration map structure
- final party model, if any; the current play baseline is singleplayer, with possible future co-op
- final card acquisition model
- final command or presence resource, if promoted after the first prototype
- exact hero stat list
- exact first hero identity
- exact first faction, enemy set, or campaign arc
- exact save/load structure
- exact UI layout
- exact tuning values

Any prototype may use temporary values, but those values must be documented as provisional.

## 5. Core Player Loop

The intended high-level loop is:

1. explore the map freely
2. talk to NPCs and inspect routes, threats, or opportunities
3. accept or ignore sidequests
4. gain cards, equipment, passives, information, or encounter advantages
5. choose the combat setup/deck loadout for the next encounter
6. choose an encounter or route
7. resolve a card-slot battle
8. reload to the pre-combat state on defeat, with no negative consequence
9. gain rewards after victory and return to exploration with updated state

## 6. Combat Overview

Combat has four primary layers.

### Hero

The hero represents the player's campaign character.

The hero may have:

- max health
- temporary armor
- active hero power
- passive hero ability
- RPG stats
- equipment
- affinities with card types
- bonuses from campaign choices

If hero health reaches zero, the battle normally ends in defeat unless a specific encounter rule says otherwise.

### Cards

Cards are tools used during battle.

Initial card categories:

- creatures
- structures
- support permanents
- spells
- board spells
- commands

Equipment cards, techniques, and special effects are possible but not yet defined.

### Board

The board is a fixed slot arena.

Slots are not free movement cells. A slot is a rule-bearing position where a valid card or encounter object may exist.

### Encounter

An encounter defines:

- board layout
- starting enemies or objects
- victory condition
- defeat condition
- enemy behavior
- waves or reinforcements
- boss parts
- special rules
- rewards

Not every encounter needs an enemy hero.

## 7. Board And Slot Model

The simplest board is:

```text
ENEMY
[E1] [E2] [E3]

[P1] [P2] [P3]
PLAYER
```

Each player slot faces an enemy slot:

- P1 attacks E1
- P2 attacks E2
- P3 attacks E3

If the facing enemy slot is empty, a ready creature may attack the enemy hero, objective, or boss target.

More advanced boards may be asymmetrical:

```text
ENEMY
      [E1 - High Shooter]
[E2 - Front] [E3 - Portal] [E4 - Front]

[P1 - Cover] [P2 - Front]
      [P3 - High Support]
PLAYER
```

## 8. Slot Definition

Each slot may define:

- owner: player, enemy, neutral, encounter
- role: front, support, objective, structure, summon, ritual, boss part
- terrain: normal, cover, fire, water, mud, ruin, sacred, corrupted, unstable, TBD
- elevation: low, normal, high
- restrictions: allowed card sizes, types, tags, or special occupancy rules
- attack route: target slots or targets, in priority order
- effect: local modifier applied to occupants, attacks, spells, or encounter rules

Example slot:

```text
Slot: P2
Owner: Player
Role: Front
Terrain: Cover
Elevation: Normal
Accepts: Creature or Structure
Attack Route: E2 -> Enemy Hero
Effect: Occupants take -1 damage from ranged attacks.
```

## 9. Round Structure

The current cardgame-first candidate round flow is:

1. Round Start
2. Draw
3. Main Phase 1
4. Combat
5. Main Phase 2
6. Turn End

This flow is not final combat canon yet. It is the next prototype target and is expanded in `cardgame-core-experiments.md`.

### Round Start

Automatic phase.

Likely responsibilities:

- trigger start-of-round effects
- refresh or adjust round state
- prepare encounter timers or enemy intent if needed

### Draw

Automatic phase.

Likely responsibilities:

- draw cards
- trigger effects that care about drawing
- trigger effects that care about hand size or deck state

### Main Phase 1

Interactive phase.

Depending on the priority model being tested, the active player or both players may:

- play creatures into valid slots
- play structures or support permanents into valid slots
- cast spells
- cast board spells
- use commands
- use hero power
- use equipment effects
- prepare defense
- pass the phase

### Combat

Combat has two candidate resolution models:

- automated combat, where players prepare positions or intent and the combat resolves at once
- interactive combat, where players choose attacks, targets, spells, and abilities through priority windows

The current leaning is toward interactive combat, but both models should be tested.

### Main Phase 2

Interactive phase after combat.

Likely responsibilities:

- rebuild board position after combat
- use post-combat spells or abilities
- prepare for the opponent, next turn, or next round
- pass the phase

### Turn End

Automatic phase.

Likely responsibilities:

- remove dead units
- resolve terrain damage or healing
- reduce durations
- trigger end-of-turn effects
- resolve encounter timers

### Priority Model Experiments

Two priority models should be tested before the turn rules are locked:

- active player plus responses, where the active player plays normal actions and the opponent mostly plays response-speed actions
- shared initiative, where both sides can act more broadly through priority windows

The current leaning is toward shared initiative, but it is still an experiment.

### No-Combat-Phase Experiment

A third structure should be tested because it is meaningfully different from the phase-based combat models:

1. Round Start
2. Draw
3. Main Phase
4. Turn End

In this variant:

- Round Start is automatic and triggers start-of-round effects.
- Draw is automatic, draws cards, and triggers draw effects.
- Main Phase alternates priority between the active player and the other player.
- There is no dedicated Combat phase.
- Any player may use any card type on any turn if they have priority and meet the card's requirements.
- A creature without summoning sickness may attack during Main Phase when its controller has priority.
- Each creature may attack once per turn by default unless a card effect says otherwise.
- Playing a creature, attacking, casting a non-instant spell, or using a character power passes priority.
- Instant-speed spells do not spend priority.
- Turn End is automatic and triggers end-of-turn effects.

This variant is identified as `C1` in the implementation plan.

## 10. Creature Timing And Keywords

Default creature timing:

- newly placed creatures enter as `Preparing`
- preparing creatures can block immediately
- preparing creatures do not attack until a later Confrontation Phase or a legal attack action, depending on the tested turn structure

Initial keyword candidates:

- `Fast`: attacks on the same turn it enters
- `Ambush`: attacks first when an enemy enters its facing route
- `Defender`: blocks well but does not attack enemy heroes
- `Trample`: excess damage can hit the next target in the route

These names and exact rules are provisional.

## 11. Card Types

### Creatures

Creatures occupy slots and participate in Confrontation.

They usually have:

- cost
- attack
- health
- tags
- size or occupancy category
- optional keyword
- optional effect

### Structures

Structures occupy slots but are not normal creatures.

They may block, fire along routes, protect objectives, or modify the board.

### Support Permanents

Support permanents occupy slots and provide ongoing effects.

They should compete for space with creatures rather than being free passive bonuses.

### Spells

Spells resolve and go to discard.

They may target units, heroes, objectives, or slots.

### Board Spells

Board spells modify slots, terrain, routes, restrictions, or local effects.

### Commands

Commands are tactical non-mystical actions.

They may buff units, coordinate attacks, prepare defense, draw cards, or manipulate timing.

## 12. Range And Targeting

Range is not measured as movement distance.

Range defines which routes or targets a card can affect.

Initial targeting categories:

- melee: attacks the directly facing slot
- reach/ranged: may target front or diagonal lanes depending on slot rules
- shooter: may target support slots, with possible cover penalties
- siege: prioritizes structures, objectives, or heroes
- flying: may ignore some ground blockers unless countered by reach or anti-air
- support: does not attack directly but strengthens other cards

These categories are provisional and may be renamed.

## 13. Terrain And Elevation

Terrain is a slot modifier.

Initial terrain candidates:

- normal
- cover
- high
- dangerous

Later terrain candidates:

- fire
- water
- mud
- ruin
- sacred
- corrupted
- unstable

Early encounters should avoid stacking too many slot rules. Each early board should have one main spatial lesson.

Elevation is also a slot property.

High slots may:

- expand targeting options
- strengthen ranged cards
- improve structures such as ballistae
- restrict melee cards
- interact with flying cards

Exact effects are TBD.

## 14. Encounter Types

Initial encounter types:

### Duel Against Enemy Hero

The enemy has health, cards or scripted card access, energy, a hero power, and a strategy.

Victory: reduce enemy hero health to zero.

### Clear The Board

There is no enemy hero.

Victory: remove all enemies and finish all pending waves or objectives.

### Survive Waves

Enemies enter through marked slots or rules over time.

Victory: survive a fixed number of rounds, protect something, or close the source.

### Defend Objective

The player protects an object, NPC, gate, wagon, crystal, ritual, bridge, or camp.

Victory and defeat depend on the objective rules.

### Multipart Boss

The boss occupies or controls multiple slots.

Victory may require destroying a main part, disabling supports, surviving phases, or solving board rules.

### Puzzle Or Challenge

The player enters with special constraints such as fixed hand, limited deck, strict timer, or required tactical solution.

## 15. Player Resources

Initial resources under consideration:

### Energy

Energy is used to play cards.

Current direction:

- combat starts with 1 energy
- energy scales by round
- hero choice, abilities, cards, equipment, or encounter rules may modify energy behavior

The exact scaling curve and cap are TBD.

### Hand

Cards remain in hand between turns unless discarded, played, or affected by rules.

### Command Or Presence

Command/Presence may limit how many strong creatures and permanents can be active at once.

This resource is optional and not required for prototype 0.1.

### Command/Presence Decision

`Command/Presence` would be a second strategic limiter beyond Energy and board slots.

Energy limits what the player can do this round.

Board slots limit where cards can be placed.

Command/Presence would limit the total weight of active creatures, structures, and permanents. For example, a small creature might use 1 Presence, a large creature 3, and a powerful support permanent 2.

Adding it in prototype 0.1 means:

- the first prototype tests the intended pressure between many small cards, fewer large cards, and permanent board value
- card definitions need a command/presence cost immediately
- UI and tests must explain one more resource from the start
- early balance has more variables, which can hide whether Energy plus slots are already enough

Delaying it means:

- the first prototype is faster and easier to read
- the team can test whether slots, Energy, hand, and card costs already create enough tension
- card definitions can reserve an optional field without enforcing it yet
- later introduction may require retuning cards, UI, enemy behavior, and encounter balance

Decision status: `DEFERRED`.

Current decision:

- do not require Command/Presence in prototype 0.1
- keep it as a future design suggestion
- do not add mandatory Command/Presence costs to first-pass card definitions
- if useful, reserve optional data fields so the resource can be tested later without redefining every contract

## 16. RPG Progression

Progression should change options and battle style, not only raise numbers.

Stat candidates:

- Vigor: max health or initial armor
- Discipline: energy, draw, consistency, or card flow
- Leadership: command capacity or creature support
- Technique: physical cards, commands, and hero attacks
- Arcane: spells, magical terrain, and permanents
- Instinct: first-round options, fast cards, ambush, reactions
- Terrain Knowledge: bonuses tied to special slots or terrain

These stats are candidates, not final names.

Progression rewards may include:

- new cards
- card upgrades
- alternate card upgrades
- hero power upgrades
- alternate hero powers
- passives
- equipment
- command/presence improvements
- encounter information
- board advantages
- enemy-specific counters

Optional rewards should usually grant options or information before pure power.

## 17. Sidequests And Difficulty

The design direction supports optional sidequests that make hard encounters more manageable.

Examples:

- sabotage a fortress to remove enemy structures from a boss board
- save allied archers to unlock a high player slot
- find a secret map to reveal boss intent earlier
- help a blacksmith to unlock a siege card

The player may be allowed to rush main objectives with fewer resources for maximum difficulty.

This direction is promising, but exact campaign structure is TBD.

## 18. Complexity Progression

Suggested teaching order:

1. simple three-lane boards
2. hero power and permanents
3. terrain
4. elevation, reach, support, and diagonal pressure
5. asymmetrical encounters, portals, waves, and objectives
6. multipart bosses with unique slot rules

This is a suggested progression, not a locked campaign chapter list.

## 19. Prototype 0.1 Target

The first combat prototype should test the soul of the system with the smallest useful ruleset.

Suggested baseline:

- hero with 25 health
- energy starts at 1 and scales by round
- 1 hero power
- initial hand of 4 cards
- draw 1 card per round
- deck of 20 cards
- 3 player slots and 3 enemy slots
- direct facing routes
- creatures enter preparing
- ready creatures attack in Confrontation
- damage to creatures persists during battle
- excess damage does not overflow unless a keyword allows it

Initial card types:

- simple creature
- defensive creature
- fast creature
- ranged/reach creature
- defensive structure
- damage spell
- heal or shield spell
- terrain-changing spell
- buff command

Initial terrains:

- normal
- cover
- high
- dangerous

Initial encounter tests:

- clear the board
- duel against enemy hero
- portal that summons waves
- simple boss with one main part and two support parts

All numbers and scaling details in this section are provisional test values.

## 20. Example Encounter

```text
Encounter: Bridge Ambush

ENEMY
[E1: Goblin 2/2] [E2: Brute 4/5] [E3: Archer 1/3 - High]

PLAYER
[P1: Normal] [P2: Narrow Bridge] [P3: Cover]
```

Special rules:

- P2 accepts only a small or medium creature.
- E3 is high; the Archer may attack P2 or P3.
- P3 has cover; it reduces ranged damage.

Player decisions:

- place a defender in P2 to hold the Brute
- use a spell to kill the Archer
- use a reach creature in P3 to answer E3
- ignore the Archer and race the front enemies
- use hero power to gain armor and survive an open lane

This encounter is not final content. It is a reference shape for prototype design.

## 21. Design Risks

### Open Lanes Deal Too Much Unavoidable Damage

Mitigation candidates:

- basic armor hero power
- weak barrier summon
- small lane damage
- card filtering
- temporary lane damage reduction

### Board Gets Stalled

Mitigation candidates:

- removal spells
- trample
- area damage
- dangerous terrain
- sacrifice
- permanent removal
- timed creatures

### Too Many Slot Rules

Mitigation:

- early boards should teach one spatial rule at a time

### RPG Stats Break The Cardgame

Mitigation:

- optional progression should favor new options, alternate answers, or information over raw numbers

## 22. Open Questions For The User

Answered design decisions:

- Player mode baseline: singleplayer.
- Future co-op: possible, not a current implementation requirement.
- Deck direction: the deck evolves as the RPG progresses.
- Combat setup: the player chooses the setup/deck loadout before entering each combat.
- Energy direction: starts at 1, scales by round, and may change through hero choice, abilities, cards, equipment, or encounter rules.
- Defeat consequence: reload to the pre-combat state with no negative effect.
- Command/Presence: optional future suggestion, not required for prototype 0.1.

First playable slice decisions:

- Presentation: 2D top-down placeholder map for the first slice; final 2D/3D/hybrid direction remains undecided.
- Flow: Menu -> map -> NPC reward -> deck setup -> enemy-hero duel -> result -> map/retry.
- NPC reward: one new card, `Balista Improvisada`.
- Combat setup: full setup before combat.
- Deck rule: choose a fixed 10-card deck from unlocked individual card entries.
- Hand size: 3.
- Enemy AI: scripted deterministic actions.
- Persistence: session-only, no disk save/load.
- Map scope: small free 2D area with NPC and encounter marker.
- Post-battle: victory result returns to map; defeat result retries from the pre-combat snapshot with no penalty.
- World controls: `WASD` movement and `E` interaction.
- Card interaction: drag-and-drop in setup and battle.
- Menu scope: `Novo jogo` and `Sair`.

First combat-depth implementation decisions:

- Player hero power: `Preparar`.
- `Preparar` draws 1 card.
- `Preparar` can be used once per round.
- Hero power does not cost Energy in the current prototype pass.

Cardgame-first design experiment decisions:

- Current candidate phase order: Round Start -> Draw -> Main Phase 1 -> Combat -> Main Phase 2 -> Turn End.
- Round Start, Draw, and Turn End are automatic phases.
- Main Phase 1 and Main Phase 2 are player-driven phases.
- Priority model is not locked; test active-player-plus-responses against shared initiative.
- Combat resolution is not locked; test automated combat against interactive combat.
- Current leaning is shared initiative plus interactive combat, but this must be playtested before becoming canon.
- Additional structural test: `C1`, with no combat phase, shared main-phase priority, attacks as actions, and instant-speed spells that do not spend priority.
- Board topology is not locked; test more complex boards and position attributes.

Open questions before implementation locks systems:

1. Is the playable combat hero always solo, or can singleplayer eventually control a party?
2. Can exploration events temporarily modify the deck/setup for a specific combat?
3. Should cards represent allies, summoned units, tactical commands, memories, equipment, magic, or all of these?
4. Is the enemy always visible before battle, or can encounters surprise the player?
5. Are card upgrades permanent, per-run, or both depending on source?
6. How much deck randomness is desired compared with deterministic RPG planning?
7. Should the first combat prototype be fully abstract UI, or already use placeholder board visuals?

## 23. Rule For Using This Document

Use this document when making design, architecture, data, or prototype decisions for `rpg-turnos`.

If implementation needs a rule that this document marks as TBD, ask the user or create a clearly marked temporary prototype rule in the active implementation track.
