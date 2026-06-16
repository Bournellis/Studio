# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK06_ARENA_VARIETY_BOT_GENERALIZATION_PLANNED`
- Current surface: FPS arena lab.
- Current baseline: Track 05B approved by Fabio; bot and long jump pad reliability are accepted.

## North Star

Keep `FpsPlayground` as a clean first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

The near-term direction is to prove a solid 1x1 arena foundation before adding more combat toys. Each track should isolate one kind of risk so playtest feedback remains understandable.

## Approved Baseline

- Project split from `FpsShooter` into `FpsPlayground`.
- Menu launches `Arena Shooter` layouts.
- `Duel Pit V2` preserves the accepted baseline.
- `Relay Foundry V1` proves a second arena with route-control bot support.
- Track 05B is approved: bot movement is good and the long jump pad first-attempt failure is resolved.
- Validation baseline: `tools/validate.gd` PASS `30/30`, `238 asserts`.
- Football/TPS scope belongs to `../JogoDaCopa`.

## Planned Track Sequence

### 1. Track 06 - Arena Variety And Bot Generalization V1

Goal:

- Add a third arena with a different movement rhythm.
- Prove bot route-control generalizes beyond the current two arenas.
- Preserve the approved bot behavior without map-specific code.

Why first:

- The bot finally feels good. The highest-value next proof is that it remains good when the arena changes.
- A third arena will stress route contracts, item placement, vertical connectors and menu/runtime layout selection.
- It gives future tuning a broader test surface before new weapons or match systems add more variables.

Detailed plan:

- `implementation/tracks/track-06-arena-variety-bot-generalization-v1/current-status.md`

### 2. Track 07 - Match Flow And Duel UX V1

Goal:

- Turn the arena lab into a cleaner repeatable duel experience: rounds, score, win/loss clarity, restart flow, result state and possibly match timer options.

Why second:

- After three arenas prove the movement/bot foundation, repeated playtests need better structure.
- Better match UX makes feedback easier to gather because each smoke can start/end cleanly.
- It improves the product feel without changing combat balance.

Expected scope:

- round/match state clarity;
- score and result HUD;
- restart/new match flow;
- menu return and arena reselection polish;
- validation for round state transitions.

### 3. Track 08 - Player Movement Feel Polish V1

Goal:

- Refine player movement feel across the approved arenas: acceleration, air control, landing recovery, jump pad feel, collision comfort and readable speed.

Why third:

- Movement tuning should happen after arena variety exists, otherwise tuning can overfit one map.
- This track can use three arenas as a movement test bench.
- It improves the FPS "hand feel" before combat variety raises the intensity.

Expected scope:

- movement constants and air-control tuning;
- jump pad/player landing feel;
- collision and edge-catch polish;
- movement smoke checklist across all arenas;
- no new weapons or bot difficulty spike.

### 4. Track 09 - Combat Sandbox Expansion V1

Goal:

- Add one carefully scoped combat experiment after movement, bot and duel UX have stable coverage.

Why fourth:

- New combat tools are exciting, but they can hide whether problems come from map, bot, UX or player movement.
- Waiting until Track 09 keeps the foundation readable.
- The experiment can be evaluated across multiple arenas with a cleaner match loop.

Expected scope:

- one new weapon, projectile variant or pickup rule;
- clear readability and counterplay contract;
- tests for damage, feedback and cooldown/resource behavior;
- no broad arsenal expansion in the same track.

## Track 06 Execution Notes

Recommended arena concept: `Crossfire Crucible V1`.

It should be compact and distinct:

- cross-shaped central fight pressure;
- one fast low-ground loop;
- one diagonal high route;
- separated health and overcharge routes;
- at least one vertical connector that differs from the long pads in `Relay Foundry V1`;
- no dead-end pickup pockets.

Track 06 should not add new combat mechanics. It should end when the third arena is selectable, validated and ready for human smoke.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
- Final art pass.
- Large combat sandbox expansion before Track 09.
