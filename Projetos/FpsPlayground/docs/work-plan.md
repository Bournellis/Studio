# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK11_COMPLETE_TELEMETRY_HUMAN_APPROVED`
- Current surface: FPS arena lab.
- Current baseline: Track 11 approved in human smoke; current player movement feel preserved.

## North Star

Keep `FpsPlayground` as a focused first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

The near-term direction is to prove a solid 1x1 arena foundation before adding more combat toys. Each track should isolate one kind of risk so playtest feedback remains understandable.

## Approved Baseline

- Project split from `FpsShooter` into `FpsPlayground`.
- Menu launches three `Arena Shooter` layouts.
- `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` are the current arena set.
- Bot movement is route-first, item-aware and committed through jump pad routes.
- Track 07 adds repeatable duel state and HUD clarity without combat or map balance changes.
- Track 08 movement feel experiment was discarded before merge; keep current movement feel for now.
- Track 09 adds Plasma Impact Blast V1 without movement, map or bot route-control changes.
- Track 10 tunes weapon roles without movement, map or bot route-control changes.
- Track 11 adds local duel telemetry without movement, map, weapon or bot route-control changes.
- Validation baseline: `tools/validate.gd` PASS `49/49`, `464 asserts`.
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

Status: discarded before merge on `2026-06-19`.

Goal:

- Refine player acceleration, air control, landing recovery, jump pad feel, collision comfort and readable speed across all approved arenas.

Decision:

- Do not execute for now. Fabio approved the previous/current player movement feel.

### 3. Track 09 - Combat Sandbox Expansion V1

Status: ready for human smoke.

Goal:

- Add one carefully scoped combat experiment while preserving the current player movement feel.

Expected scope:

- one new weapon, projectile variant or pickup rule;
- clear readability and counterplay contract;
- tests for damage, feedback and cooldown/resource behavior.

Delivered:

- Plasma Bolt world impacts create a readable partial blast.
- Overcharged Plasma Bolt blast reaches farther and reads differently.
- Direct plasma hits, rifle behavior, player movement, jump pads, maps and bot route-control are preserved.

### 4. Track 10 - Combat Balance And Weapon Roles V1

Status: ready for human smoke.

Goal:

- Consolidate clear weapon roles after Plasma Impact Blast V1.

Delivered:

- Rifle remains the precision and sustained DPS tool.
- Direct Plasma is now a high-commitment impact shot at `24` damage.
- Plasma Blast remains pressure/near-miss value at `46%` max damage and `22%` min damage fraction.
- Bot shot pressure remains readable and below player burst.
- Player movement, sensitivity, jump pads, maps, bot route-control and pickups are preserved.

### 5. Track 11 - Complete Telemetry V1

Status: human smoke approved on `2026-06-19`.

Goal:

- Add complete local evidence for duel balance, bot movement, map routes, pickups and combat outcomes.

Delivered:

- Local `events.jsonl` plus `summary.json` under Godot `user://telemetry/<session_id>/`.
- Session, arena setup, round, combat, Plasma, pickup, bot, movement and jump pad events.
- Summary metrics for winners, damage, weapon accuracy, Plasma, overcharge, pickups, bot routes and movement samples.
- Hotfix V2 keeps the compact summary flushed with the event stream during interrupted or reset sessions.
- Hotfix V3 labels active manual restarts as `round_reset reason=manual_restart`.
- Automated schema, file-output, arena integration and Track 10 guardrail tests.

## Out Of Scope

- Football minigames.
- TPS camera/avatar football work.
- Multiplayer/backend/export unless explicitly planned.
- Final art pass.
- Large combat expansion before Track 09.
