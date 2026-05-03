# RPG Turnos Architecture

## Goal

Start with separated systems so the project can choose 2D or 3D later without rewriting the RPG rules.

The first architecture rule is simple: data and game rules must not depend on Node2D, Node3D, camera specifics, collision shape choices, or final art direction.

## Layers

### Core

`core/` owns low-level contracts and neutral data shapes:

- stable identifiers
- result objects
- snapshots
- domain-neutral helpers
- shared base contracts

### Systems

`systems/` owns RPG rules that should survive any presentation choice:

- character profile
- level and stats
- decks, hands, discard piles, and card ownership
- inventory
- items and equipment
- dialogue state
- narrative flags
- encounter definitions
- board definitions and slot definitions
- save data

### World

`world/` owns exploration presentation and input adaptation:

- map movement
- camera behavior
- NPC interaction zones
- encounter triggers
- map exits and route choices

The `world/agnostic/` lane should hold contracts that can be shared by future `world_2d/` and `world_3d/` implementations.

### Battle

`battle/` owns turn-based card-slot combat:

- combatant state
- hero state
- card state
- deck, hand, discard, and resource state
- board slots and occupancy
- attack routes
- turn order
- action selection
- action resolution
- rewards
- transition back to world state

Battle logic should be mostly visual-agnostic. Presentation can be added through battle UI and scene adapters.

### Modes

`modes/` owns composition:

- `boot/`: project startup and handoff into the first mode
- `world/`: exploration mode assembly
- `battle/`: battle mode assembly

Each playable mode should eventually define equivalents of launch context, bootstrap, session manager, game loop, simulation context, HUD presenter, and results presenter.

### UI

`ui/` owns player-facing surfaces:

- character sheet
- inventory
- dialogue box
- choice lists
- battle command menu
- battle result panel

UI must present state. It must not own RPG rules.

### Data

`data/` owns authored definitions:

- characters
- cards
- decks
- items
- equipment
- NPCs
- dialogue
- encounters
- enemies
- boards
- slots
- battle actions

Small hand-authored JSON definitions are preferred early. Generated Godot resources can be introduced once the catalogs stabilize.

## Initial Contracts To Define Later

- `CharacterProfile`
- `StatsBlock`
- `InventoryState`
- `HeroBattleState`
- `CardDefinition`
- `DeckDefinition`
- `DeckState`
- `HandState`
- `BoardDefinition`
- `SlotDefinition`
- `AttackRouteDefinition`
- `ItemDefinition`
- `EquipmentDefinition`
- `DialogueState`
- `DialogueDefinition`
- `EncounterDefinition`
- `BattleState`
- `BattleActionDefinition`
- `RoundPhase`
- `ResourceState`
- `WorldActor`
- `SaveSnapshot`

## Reuse Policy

Reusable code from RPG Isometrico may be considered only after checking it against turn-based RPG needs.

Likely reusable references:

- project organization
- validation patterns
- settings or persistence helpers
- input naming conventions
- content generation workflow

Do not inherit:

- real-time action combat
- RPG Isometrico loadout contract
- Arena, Survival, Boss, or PvP mode assumptions
- fixed action-progression rules
