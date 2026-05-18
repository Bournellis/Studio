# Architecture

- Last Updated: `2026-05-15`
- Status: `Track 01 P05 playtest tuning architecture`

## Goal

Keep roguelike run rules, card battle rules, data, and presentation separated so the project can iterate quickly without inheriting RPG Turnos systems by accident.

## Runtime Areas

### `ShipHub`

Main Draxos ship surface.

Responsibilities:

- visual access to Deck, RunMap, and Souls screens;
- forced class choice modal only when a new save starts;
- visible floating run state, including class, next map, HP, mana, hand limit, and souls;
- ESC menu for main menu, quit, or cancel.

### `SaveManager`

Local 3-slot persistence layer.

Responsibilities:

- slot selection and summaries for the main menu;
- save/load/delete JSON files under `user://`;
- save version `4`, with older versions reported as invalid/stale but deletable and overwritable;
- autosave current `RunSession` outside battle;
- pending new-game handoff into the ShipHub class modal.

### `RunMap`

Linear 13-node route.

Responsibilities:

- node availability;
- current selected node;
- route rendering from visual manifest;
- automatic reward status presentation;
- pending 1-in-3 reward choice presentation when a reward is not resolved in battle.

### `Deck`

Run deck inspection surface.

Responsibilities:

- grouped card list for the current run deck;
- visible run state and unlocked upgrades;
- ESC return to ShipHub.

### `Souls`

Run soul shop surface.

Responsibilities:

- paid healing action;
- 3 card-upgrade offers from run-deck cards below Lvl 3, refreshed after victory;
- 20-soul upgrade purchases limited to 1 per combat;
- visible run state;
- ESC return to ShipHub.

### `RunSession`

Single source of current run state.

Responsibilities:

- active run flag and seed;
- selected class;
- current node and completed nodes;
- current deck;
- card upgrade counts by base card id, mapped to effective Lvl 2/Lvl 3 card ids at display/battle time;
- shop upgrade offer state and one-purchase-per-combat tracking;
- current/max health;
- max mana;
- soul total;
- passive and active unlock flags;
- automatic reward ids;
- stable seeded pending reward choices for upgrade/card rewards, including stored rarity data.

### `Battle`

Card battle rules and encounter objectives.

Responsibilities:

- front-lane combat;
- right-click discard marking during the main creature-play phase, with marked cards discarded/redrawn after combat resolution;
- `iniciativa`, `regeneracao`, `carnica`, keyword removal, adjacent damage, temporary mana, temporary spell power, and temporary all-ally buffs;
- `suicida` death hooks;
- class passive/active gating;
- delayed pending-choice presentation after combat FX for automatic death triggers;
- waves, duel, defense position, survive turns, and summoner boss;
- visual events and UI refresh.

### `Data`

Authored JSON and generated Godot resources.

Responsibilities:

- cards and keywords;
- classes and starter decks;
- class reward pools with 2 real cards per class for the current slice;
- encounters and soul reward bands;
- reward rarity rules and shop offer state;
- run map nodes, automatic rewards, and choice reward declarations;
- visual manifest references.

### `UI`

Reusable controls and player-facing screens.

Responsibilities:

- card tokens;
- battle slots and hero targets;
- hub/menu components;
- run map node presentation;
- reward/estado text for fixed rewards, upgrade choices, and new-card choices;
- translucent choice/reward modals using alpha target `0.72`.

## Current Checkpoint

The current BattleEngine is now the local Draxos cardgame rules baseline for Track 01. Remaining design work is balance, art coverage, future reward-pool expansion, and playtest tuning, not reusing tactical RPG board contracts.
