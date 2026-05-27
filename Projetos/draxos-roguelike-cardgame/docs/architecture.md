# Architecture

- Last Updated: `2026-05-27`
- Status: `Track 02 foundation hardening baseline`

## Goal

Keep roguelike run rules, card battle rules, data, validation, and presentation separated so the project can iterate without inheriting RPG Turnos, RPG Isometrico, or DraxosMobile systems by accident.

The JSON Track 02 catalog is the authored source of truth for current content. Generated `.tres` resources must be deterministic and idempotent.

## Runtime Areas

### `ShipHub`

Main Draxos ship surface.

Responsibilities:

- visual access to Deck, RunMap, Souls, and run-state surfaces;
- forced class choice modal only when a new save starts;
- visible run state, including class, next map, HP, mana, hand limit, Souls and progression;
- ESC menu for main menu, quit, or cancel.

### `SaveManager`

Local 3-slot persistence layer.

Responsibilities:

- slot selection and summaries for the main menu;
- save/load/delete JSON files under `user://`;
- save/snapshot version `5`, with older versions reported as invalid/stale but deletable and overwritable;
- autosave current `RunSession` outside battle;
- pending new-game handoff into the ShipHub class modal.

### `RunMap`

Fixed 29-node route.

Responsibilities:

- node availability;
- current selected node;
- route rendering from visual manifest;
- reward/status presentation;
- pending reward choice presentation when a reward is not resolved inside battle.

### `Deck`

Run deck inspection surface.

Responsibilities:

- grouped card list for the current run deck;
- effective Lvl 2/Lvl 3 display from base IDs and upgrade counts;
- visible run state and unlocked class/relic effects;
- ESC return to ShipHub.

### `Souls`

Expanded run shop surface.

Responsibilities:

- healing and max-HP purchases;
- card-upgrade offers from run-deck cards below Lvl 3;
- removal and duplication services;
- relic offers;
- reroll/cost/purchase-limit state;
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
- reward choice state, utility reward state, relic state and shop state;
- current/max health;
- max mana and hand limit;
- Soul total;
- passive and active unlock flags;
- stable seeded pending choices;
- save/snapshot payload v5.

Foundation direction: keep the public API stable while moving reward/shop logic into internal services.

### `Battle`

Card battle rules and encounter objectives.

Responsibilities:

- front-lane combat;
- discard marks during the main creature-play phase;
- all Track 02 keyword/status hooks;
- class passive/active gating;
- delayed pending-choice presentation after combat FX for automatic death triggers;
- waves, duel, defense position, survive turns, ambush, escort, invasion, and summoner boss;
- board formats and field effects;
- deterministic enemy commander AI;
- visible enemy intent;
- visual events and UI refresh.

Foundation direction: keep the public `BattleEngine` API stable while extracting enemy AI/intent, keyword/status hooks, encounter directors, boss directors and field-effect directors behind the engine.

### `Data`

Authored JSON and generated Godot resources.

Responsibilities:

- cards, classes, starter decks and reward pools;
- keywords/status tooltip contract;
- enemy galleries and AI profiles;
- encounters, soul reward bands, board formats, field effects and boss hooks;
- reward rarity rules and shop offer state;
- run map nodes and declarations;
- visual manifest references.

`ContentGenerator.generate_all()` stores a stable semantic hash in `SliceCatalogResource.definition_hash` and skips saving `data/generated/slice_catalog.tres` when the JSON definition has not changed semantically.

### `UI`

Reusable controls and player-facing screens.

Responsibilities:

- card tokens and keyword/status badges;
- battle slots, board/hand layout and hero targets;
- intent panel;
- choice/reward/relic/shop modals;
- hub/menu components;
- run map node presentation;
- reward/state text for fixed rewards, utility rewards, relics, upgrades and new-card choices.

Foundation direction: `BattleRoot` should trend toward composition/presenter code, with board/hand, intent panel and modals extracted in small validated steps.

### `Validation`

Local verification surface.

Responsibilities:

- generate data/scenes;
- validate bootstrap/data/visual contracts;
- smoke the 29-map route;
- run GUT;
- report playtest readiness and known non-fatal art alpha debts.

Expected baseline after 2026-05-27 hardening: GUT 94/94, full-route smoke 29/29, and repeated validation does not dirty generated content when the JSON is unchanged.

### `Run Lab`

Local simulation/telemetry tool.

Responsibilities:

- run route simulations by class and seed;
- emit CSV/JSON metrics for completed maps, HP, deck size, relics, shop actions, deaths and estimated turns;
- support regression and tuning comparison.

Run Lab is not a replacement for human playtest.

## Current Checkpoint

Track 02 is the live baseline. Track 01 / 13-map architecture notes are historical unless explicitly adopted by current docs or code.
