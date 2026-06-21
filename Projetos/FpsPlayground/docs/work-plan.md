# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK14I_GODOT_DEBUGGER_CLEANUP_LOCAL`
- Current surface: FPS arena lab.
- Current baseline: Track 14I Godot debugger cleanup merged local baseline; current player movement feel preserved.

## North Star

Keep `FpsPlayground` as a focused first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

The Track 14 hardening sequence is complete enough to resume evidence-first gameplay work. New maps, weapons, buffs and bot improvements should be introduced through small tracks with telemetry evidence and clear rollback points.

## Approved Baseline

- Project split from `FpsShooter` into `FpsPlayground`.
- Menu launches three `Arena Shooter` layouts.
- `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` are the current arena set.
- Bot movement is route-first, item-aware and committed through jump pad routes.
- Track 07 added repeatable duel state and HUD clarity.
- Track 08 movement feel experiment was discarded before merge; keep current movement feel for now.
- Track 09 added Plasma Impact Blast V1 without movement, map or bot route-control changes.
- Track 10 tuned weapon roles without movement, map or bot route-control changes.
- Track 11 added local duel telemetry without movement, map, weapon or bot route-control changes.
- Track 12 added local telemetry readout and first balance baseline without gameplay changes; Fabio approved the readout usefulness.
- Track 13 rebaselined docs and added `arena-shooter-future-roadmap.md`; no gameplay changes.
- Track 14A starts the refactor/hardening sequence; no gameplay changes.
- Track 14B extracted HUD snapshot/status building from `arena_root.gd`; no gameplay changes.
- Track 14C extracted combat telemetry payloads and pure Plasma blast math from `arena_root.gd`; no gameplay changes.
- Track 14D extracted pickup and jump pad rules from `arena_root.gd`; no gameplay changes.
- Track 14E extracted bot decision scoring from `basic_duel_bot.gd`; no gameplay changes.
- Track 14F removed dead private bot wrappers and rebaselined code metrics; no gameplay changes.
- Track 14G extracted bot movement execution, projectile runtime, HUD feedback state and telemetry event facade; no gameplay changes.
- Track 14H restored bot-only route-aware long jump pad reliability while preserving player jump pad force.
- Track 14I cleaned GUT editor/debugger warnings; no gameplay changes.
- Validation baseline: `tools/validate.gd` PASS `67/67`, `599 asserts`.
- Football/TPS scope belongs to `../JogoDaCopa`.

## Recommended Next Tracks

Next active recommendation: execute `Multi-Arena Balance Baseline V1`.

### 1. Track 14A - Refactor Safety Net And Code Health Baseline V1

Goal:

- Register the code hardening sequence and align safety tests before moving responsibilities.

Expected scope:

- Documentation and test-name cleanup only.
- No gameplay, movement, map, weapon, pickup, jump pad or bot behavior changes.
- Next: `Track 14B - Arena Root Boundary V1`.

### 2. Track 14B - Arena Root Boundary V1

Goal:

- Create stable boundaries around `modes/arena/arena_root.gd` before extracting combat and item systems.

Expected scope:

- Delivered: `ArenaHudSnapshotBuilder` now owns HUD snapshot/status strings.
- Validation covered round flow, shots, pickups, jump pads, HUD snapshots and telemetry.
- No tuning.
- Next: `Track 14C - Combat Pipeline Extraction V1`.

### 3. Track 14C - Combat Pipeline Extraction V1

Goal:

- Extract weapon and damage resolution paths from the arena root without changing weapon roles.

Expected scope:

- Delivered: rifle, Plasma, blast and bot-shot payload/math boundary in `ArenaCombatPipeline`.
- Preserved Track 10 combat balance and Track 11/12 telemetry.
- Next: `Track 14D - Pickups And Jump Pads Extraction V1`.

### 4. Track 14D - Pickups And Jump Pads Extraction V1

Goal:

- Extract pickup and jump pad runtime handling while preserving approved movement contracts.

Expected scope:

- Delivered: health/overcharge pickup state, respawn, collection telemetry payload, jump pad cooldowns and launch vector helper.
- Guardrail tests cover approved jump pad force and pickup behavior.
- Next: `Track 14E - Bot Decision Boundary V1`.

### 5. Track 14E - Bot Decision Boundary V1

Goal:

- Separate bot decision scoring from low-level movement execution where practical.

Expected scope:

- Delivered: `BotDecisionModel` owns item priority, route priority, tactical scoring and route-hold checks.
- No aim difficulty buffs.
- Preserved route-first, item-aware movement and arena tactical context.
- Next: `Track 14F - Cleanup And Documentation V1`.

### 6. Track 14F - Cleanup And Documentation V1

Goal:

- Remove transitional duplication and rebaseline code health after the extraction sequence.

Expected scope:

- Delivered: removed dead private bot wrappers left after Track 14E.
- Metrics: `arena_root.gd` 1524 lines, `basic_duel_bot.gd` 1142 lines, `bot_decision_model.gd` 295 lines.
- Validation target stays `62/62`, `564 asserts`.
- Next: `Multi-Arena Balance Baseline V1`.

### 7. Track 14G - Surgical Expansion Hardening V1

Goal:

- Add small implementation boundaries around the remaining expansion hotspots without changing gameplay.

Expected scope:

- Delivered: `BotMovementExecutor`, `ArenaProjectileRuntime`, `ArenaHudFeedbackState` and `ArenaTelemetryEvents`.
- Rebaselined hotspot metrics: `arena_root.gd` 1487 lines, `basic_duel_bot.gd` 1077 lines, `arena_hud.gd` 535 lines.
- Preserved gameplay, movement feel, jump pad force, maps, weapon values, pickups, aim difficulty, bot behavior and telemetry schema.
- Next: `Multi-Arena Balance Baseline V1`.

## Gameplay Roadmap After Track 14

### Multi-Arena Balance Baseline V1

Goal:

- Compare real sessions across `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` before tuning weapons, pickups, buffs, bot or maps.

Expected scope:

- Run/read telemetry per arena.
- Identify repeated rifle dominance, Plasma contribution, overcharge value, pickup route value, bot route diversity and jump pad reliability.
- Produce a short decision table: `no change`, `observe`, `candidate tuning`.
- No gameplay changes unless the track is explicitly expanded.

### Arsenal And Buff Contracts V1

Goal:

- Define how future weapons, buffs and pickup rules can exist without breaking the duel baseline.

Expected scope:

- Weapon role matrix.
- Buff/pickup taxonomy.
- Per-weapon telemetry requirements.
- Guardrails for no movement changes and no UI-heavy weapon wheel until explicitly planned.

### Combat Tuning V1

Goal:

- Apply the smallest evidence-backed weapon or buff tuning from the multi-arena baseline and arsenal contract.

Expected scope:

- Small value changes only.
- Preserve movement, jump pad force, map geometry and bot route-control by default.
- Add or update guardrail tests for the tuned role.

### Arena Production Rules V1

Goal:

- Turn the existing arena authoring rules into a practical checklist for adding a fourth arena.

Expected scope:

- Map feeling checklist.
- Required telemetry/readout targets.
- Required bot tactical context roles.
- Required manual smoke script for player movement and bot routing.

### Bot Duel Intelligence V2

Goal:

- Improve bot decisions after map/combat baselines are clearer.

Expected scope:

- More deliberate use of health, overcharge, Plasma and pressure routes.
- Arena-aware but not arena-hardcoded decision scoring.
- Preserve route-first movement and readable shot windup.

## Default Guardrails

- Do not change player movement feel unless Fabio explicitly starts a movement track.
- Do not change jump pad force unless a jump-pad-specific issue is reproduced.
- Do not tune all arenas from one arena's telemetry.
- Do not add new weapons before the arsenal contract exists.
- Do not add buffs that bypass route decisions.
- Do not add bot aim difficulty by cheating reaction/readability.
- Do not add export, multiplayer/backend, Web/mobile, progression or final art unless explicitly planned.

## Read Next

- `arena-shooter-future-roadmap.md`
- `refactor-hardening-roadmap.md`
- `balance-baseline.md`
- `telemetry-readout.md`
- `tuning-guide.md`
- `arena-tactical-layouts.md`
