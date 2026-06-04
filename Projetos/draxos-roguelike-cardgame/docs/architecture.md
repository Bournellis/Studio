# Architecture

- Last Updated: `2026-06-04`
- Status: `Track 02 foundation closeout baseline`

## Goal

Keep roguelike run rules, card battle rules, data, validation, and presentation separated so the project can iterate without inheriting RPG Turnos, RPG Isometrico, or DraxosMobile systems by accident.

The JSON Track 02 catalog is the authored source of truth for current content. Generated `.tres` resources must be deterministic and idempotent. `tools/catalog_source_loader.gd` now creates a domain seam for future composed sources while preserving the current single JSON semantics.

For closeout ownership and remaining debt, use `docs/foundation-closeout.md` together with this architecture file.

## Authority And Ownership

| Layer | Live owner | Rule |
|---|---|---|
| Product status | `implementation/current-status.md` and `docs/production-status.md` | Keep current state short; put historical detail in track docs. |
| Human playtest | `docs/playtest-track-02.md` | Human feedback decides balance and clarity after automated gates pass. |
| Run state | `core/run_session.gd` | Public run API and snapshot v5 stay here; services delegate internal work. |
| Rewards | `core/run_reward_service.gd` behind `RunSession` | Reward payloads, pending queues and category state remain compatible. |
| Souls shop | `core/run_shop_service.gd` behind `RunSession` | Offers, purchases, rerolls, costs and `shop_state` sync live here. |
| Battle rules | `battle/battle_engine.gd` facade plus directors | Callers keep using `BattleEngine`; extracted directors own internal slices. |
| Battle presentation | `modes/battle/battle_root.gd` plus pure presenters | Scene composition remains in `BattleRoot`; pure readouts stay in presenters. |
| Catalog | `data/definitions/slice_catalog.json` plus loader/generator | JSON is the live source; generated `.tres` must be semantic-hash idempotent. |
| Validation | `tools/validate.gd`, modular GUT suites | Validate data/scenes/contracts, route smoke and GUT together. |
| Telemetry | `tools/route_pacing_simulator.gd` and `tools/run_lab.gd` | Regression and tuning comparison only; not a playtest substitute. |

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

Foundation checkpoint: `RunSession` remains the public owner of run state while reward choice generation/application delegates to `core/run_reward_service.gd`; Souls shop offers, purchases, rerolls, max-HP buys, cost helpers and `shop_state` sync delegate to `core/run_shop_service.gd` behind compatible wrappers.

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

Foundation checkpoint: the public `BattleEngine` API remains stable while enemy commander turn resolution delegates to `battle/enemy_turn_director.gd`, enemy intent delegates to `battle/enemy_intent_director.gd`, staged combat/manual attack/slot damage/hero damage/destruction queues delegate to `battle/combat_resolution_director.gd`, and existing field-effect/encounter/boss hooks stay behavior-compatible behind the engine.

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

`ContentGenerator.generate_all()` loads definitions through `tools/catalog_source_loader.gd`, stores a stable semantic hash in `SliceCatalogResource.definition_hash`, and skips saving `data/generated/slice_catalog.tres` when the authored definition has not changed semantically. The loader currently assembles domains from `slice_catalog.json` and `visual_assets.json` without splitting source files; cards, enemies, classes, rewards, relics, encounters, run map, keywords and visuals are exposed as future split domains.

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

Foundation checkpoint: `BattleRoot` keeps current scene composition, anchors, layout and drag/drop behavior while pure battle preview/readout data delegates to `modes/battle/battle_preview_presenter.gd`, HUD/objective readouts delegate to `modes/battle/battle_hud_presenter.gd`, and combat FX filtering/text/state projection delegates to `modes/battle/battle_combat_fx_presenter.gd`. Board/hand and modal extraction remain future small validated steps.

### `Validation`

Local verification surface.

Responsibilities:

- generate data/scenes;
- validate bootstrap/data/visual contracts;
- smoke the 29-map route;
- run GUT;
- report playtest readiness and known non-fatal art alpha debts.

Expected baseline after 2026-06-03 hardening 8: GUT 105/105 with 1279 asserts, full-route smoke 29/29 through the shared route pacing simulator, Arcano seed `20260518` protected by exact golden metrics, Run Lab parity for class/seed sweeps, and repeated validation does not dirty generated content when the JSON is unchanged.

### `Run Lab`

Local simulation/telemetry tool.

Responsibilities:

- run route simulations by class and seed;
- emit CSV/JSON metrics for completed maps, HP, deck size, relics, shop actions, deaths and estimated turns;
- compare approved Track 02 golden metrics when run with `--compare-golden`;
- support regression and tuning comparison.

Run Lab is not a replacement for human playtest.

## Current Checkpoint

Track 02 is the live baseline. Track 01 / 13-map architecture notes are historical unless explicitly adopted by current docs or code.
