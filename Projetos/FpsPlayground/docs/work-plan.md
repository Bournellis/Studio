# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK07_MATCH_FLOW_DUEL_UX_READY_FOR_SMOKE`
- Current surface: FPS arena lab.
- Current baseline: Track 07 implemented locally; human smoke pending.

## North Star

Keep `FpsPlayground` as a focused first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

The near-term direction is to prove a solid 1x1 arena foundation before adding more combat toys. Each track should isolate one kind of risk so playtest feedback remains understandable.

## Approved Baseline

- Project split from `FpsShooter` into `FpsPlayground`.
- Menu launches three `Arena Shooter` layouts.
- `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` are the current arena set.
- Bot movement is route-first, item-aware and committed through jump pad routes.
- Track 07 adds repeatable duel state and HUD clarity without combat or map balance changes.
- Validation baseline: `tools/validate.gd` PASS `34/34`, `340 asserts`.
- Football/TPS scope belongs to `../JogoDaCopa`.

## Track Sequence

### 1. Track 07 - Match Flow And Duel UX V1

Status: ready for human smoke.

Delivered:

- round/match state;
- score and first-to-3 result flow;
- persistent HUD score/round/result labels;
- `R` next-round/new-match behavior;
- pause-menu `Novo duelo`;
- automated state and HUD tests.

### 2. Track 08 - Player Movement Feel Polish V1

Status: recommended next after Track 07 approval.

Goal:

- Refine player acceleration, air control, landing recovery, jump pad feel, collision comfort and readable speed across all approved arenas.

Why next:

- Movement tuning now has three arenas and a clearer duel loop as a test bench.
- It improves the FPS hand feel before combat variety adds more variables.

### 3. Track 09 - Combat Sandbox Expansion V1

Status: planned after movement feel.

Goal:

- Add one carefully scoped combat experiment after movement, bot and duel UX have stable coverage.

Expected scope:

- one new weapon, projectile variant or pickup rule;
- clear readability and counterplay contract;
- tests for damage, feedback and cooldown/resource behavior.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
- Final art pass.
- Large combat expansion before Track 09.
