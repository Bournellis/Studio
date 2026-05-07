# Architecture

- Last Updated: `2026-05-07`
- Status: `bootstrap architecture`

## Goal

Keep roguelike run rules, card battle rules, data, and presentation separated so the project can iterate quickly without inheriting RPG Turnos systems by accident.

## Runtime Areas

### `ShipHub`

The main menu as a Draxos ship / ether-plasm base.

Responsibilities:

- NPC and ship-system entry points
- class/run start choices
- mission map access
- narrative state presentation

### `RunMap`

The run route.

Responsibilities:

- linear progression with optional nodes
- node type and availability
- current position in the run
- area/boss progression

### `RunSession`

Temporary state for the current run.

Responsibilities:

- active run flag
- seed
- current node
- current deck
- current/max health
- pending rewards

### `Battle`

Card battle rules and encounter objectives.

Responsibilities:

- simple slot capacity per side
- encounter objective resolution
- enemy board and boss summoning behavior
- visual events for presentation

### `Data`

Authored JSON and generated Godot resources.

Responsibilities:

- cards
- encounters
- run map placeholders
- future classes, rewards, bosses, events, and ship NPCs

### `UI`

Reusable controls and player-facing screens.

Responsibilities:

- card tokens
- battle slots
- hub/menu components
- run map components
- result/reward presentation

## Current Bootstrap

The current codebase still contains a fork of the RPG Turnos battle engine. Treat it as scaffolding until Track 00 simplifies it.
