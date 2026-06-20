# FpsPlayground Work Plan

- Status: `FPS_PLAYGROUND_TRACK13_DOCS_REBASELINE_FUTURE_ROADMAP_COMPLETE`
- Current surface: FPS arena lab.
- Current baseline: Track 12 telemetry/readout approved; Track 13 docs rebaseline complete; current player movement feel preserved.

## North Star

Keep `FpsPlayground` as a focused first-person gameplay laboratory for arena movement, shooting, projectiles, bots, maps and combat feel.

The near-term direction is to grow the 1x1 Arena Shooter foundation without losing the approved feel. New maps, weapons, buffs and bot improvements should be introduced through small tracks with telemetry evidence and clear rollback points.

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
- Validation baseline: `tools/validate.gd` PASS `53/53`, `496 asserts`.
- Football/TPS scope belongs to `../JogoDaCopa`.

## Recommended Next Tracks

### 1. Track 14 - Multi-Arena Balance Baseline V1

Goal:

- Compare real sessions across `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` before tuning weapons, pickups, buffs, bot or maps.

Expected scope:

- Run/read telemetry per arena.
- Identify repeated rifle dominance, Plasma contribution, overcharge value, pickup route value, bot route diversity and jump pad reliability.
- Produce a short decision table: `no change`, `observe`, `candidate tuning`.
- No gameplay changes unless the track is explicitly expanded.

### 2. Track 15 - Arsenal And Buff Contracts V1

Goal:

- Define how future weapons, buffs and pickup rules can exist without breaking the duel baseline.

Expected scope:

- Weapon role matrix.
- Buff/pickup taxonomy.
- Per-weapon telemetry requirements.
- Guardrails for no movement changes and no UI-heavy weapon wheel until explicitly planned.

### 3. Track 16 - Combat Tuning V1

Goal:

- Apply the smallest evidence-backed weapon or buff tuning from Track 14 and Track 15.

Expected scope:

- Small value changes only.
- Preserve movement, jump pad force, map geometry and bot route-control by default.
- Add or update guardrail tests for the tuned role.

### 4. Track 17 - Arena Production Rules V1

Goal:

- Turn the existing arena authoring rules into a practical checklist for adding a fourth arena.

Expected scope:

- Map feeling checklist.
- Required telemetry/readout targets.
- Required bot tactical context roles.
- Required manual smoke script for player movement and bot routing.

### 5. Track 18 - Bot Duel Intelligence V2

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
- `balance-baseline.md`
- `telemetry-readout.md`
- `tuning-guide.md`
- `arena-tactical-layouts.md`
