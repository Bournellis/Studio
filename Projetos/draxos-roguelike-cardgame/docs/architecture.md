# Architecture

- Last Updated: `2026-05-12`
- Status: `Track 01 linear slice architecture`

## Goal

Keep roguelike run rules, card battle rules, data, and presentation separated so the project can iterate quickly without inheriting RPG Turnos systems by accident.

## Runtime Areas

### `ShipHub`

Main Draxos ship surface.

Responsibilities:

- class/run start choices;
- mission map access;
- souls and paid healing;
- visible current run state, including passive/active unlock status.

### `RunMap`

Linear 10-node route.

Responsibilities:

- node availability;
- current selected node;
- route rendering from visual manifest;
- automatic reward status presentation.

### `RunSession`

Single source of current run state.

Responsibilities:

- active run flag and seed;
- selected class;
- current node and completed nodes;
- current deck;
- current/max health;
- max mana;
- soul total;
- passive and active unlock flags;
- automatic reward ids.

### `Battle`

Card battle rules and encounter objectives.

Responsibilities:

- front-lane combat;
- `iniciativa` and `regeneracao`;
- class passive/active gating;
- waves, duel, defense position, survive turns, and summoner boss;
- visual events and UI refresh.

### `Data`

Authored JSON and generated Godot resources.

Responsibilities:

- cards and keywords;
- classes and starter decks;
- encounters and soul reward bands;
- run map nodes and automatic rewards;
- visual manifest references.

### `UI`

Reusable controls and player-facing screens.

Responsibilities:

- card tokens;
- battle slots and hero targets;
- hub/menu components;
- run map node presentation;
- reward/estado text for the automatic reward slice.

## Current Checkpoint

The current BattleEngine is now the local Draxos cardgame rules baseline for Track 01. Remaining design work is content and balance, not reusing tactical RPG board contracts.
