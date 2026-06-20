# Refactor Hardening Roadmap

- Status: `Track 14G surgical expansion hardening in progress`
- Scope: code hardening and reduction sequence for the approved Arena Shooter baseline.
- Rule: Track 14 did not change gameplay, movement feel, jump pad force, map geometry, weapon values or bot decisions.

## Why Now

The project is approved enough to keep expanding again. Track 14 reduced the main risk around large files, but remaining hotspots should be handled only when they directly protect the next gameplay or telemetry track.

## Current Hotspots

- `modes/arena/arena_root.gd`: largest runtime authority; owns arena assembly, round state, shots, pickups, jump pads, HUD snapshots and telemetry calls.
- `gameplay/bot/basic_duel_bot.gd`: large behavior authority; owns route choice, local movement, item commitment, combat overlay and jump pad commitment.
- `tests/unit/test_bootstrap.gd`: broad safety net; useful, but too centralized for future refactors.
- `presentation/hud/arena_hud.gd`: acceptable now, but should not absorb more match/readout logic.

Post-Track-14F code-size baseline:

- `modes/arena/arena_root.gd`: 1524 lines.
- `gameplay/bot/basic_duel_bot.gd`: 1142 lines.
- `gameplay/bot/bot_decision_model.gd`: 295 lines.
- `modes/arena/arena_combat_pipeline.gd`: 358 lines.
- `modes/arena/arena_pickup_jump_pad_rules.gd`: 155 lines.
- `modes/arena/arena_hud_snapshot_builder.gd`: 75 lines.

## Track 14 Sequence

1. `Track 14A - Refactor Safety Net And Code Health Baseline V1`
   - Register hotspots and implementation order.
   - Keep tests aligned with the approved contracts.
   - No gameplay changes.
   - Next: `Track 14B - Arena Root Boundary V1`.

2. `Track 14B - Arena Root Boundary V1`
   - Delivered: `ArenaHudSnapshotBuilder` owns HUD snapshot/status assembly outside `arena_root.gd`.
   - Proved round flow, shots, pickups, jump pads, telemetry and HUD snapshots still pass validation.
   - No gameplay tuning.
   - Next: `Track 14C - Combat Pipeline Extraction V1`.

3. `Track 14C - Combat Pipeline Extraction V1`
   - Delivered: `ArenaCombatPipeline` owns combat telemetry payload construction and pure Plasma blast math.
   - Preserved Track 10 weapon roles and Track 11/12 telemetry fields.
   - No gameplay tuning.
   - Next: `Track 14D - Pickups And Jump Pads Extraction V1`.

4. `Track 14D - Pickups And Jump Pads Extraction V1`
   - Delivered: `ArenaPickupJumpPadRules` owns pickup state/respawn helpers and jump pad cooldown/launch math.
   - Preserved approved jump pad force, pickup behavior and bot route commitment.
   - No gameplay tuning.
   - Next: `Track 14E - Bot Decision Boundary V1`.

5. `Track 14E - Bot Decision Boundary V1`
   - Delivered: `BotDecisionModel` owns item priority, map route priority, tactical point scoring and route-hold checks.
   - Preserved route-first movement, combat overlay, aim difficulty and arena-aware tactical context.
   - Next: `Track 14F - Cleanup And Documentation V1`.

6. `Track 14F - Cleanup And Documentation V1`
   - Delivered: removed dead private bot wrappers left after Track 14E.
   - Rebaselined code-size metrics and docs.
   - Next: `Track 14G - Surgical Expansion Hardening V1`.

7. `Track 14G - Surgical Expansion Hardening V1`
   - Scope: small expansion boundaries for bot movement execution, projectile runtime, HUD feedback state and telemetry event emission.
   - Rule: no gameplay, movement feel, map, weapon, pickup, jump pad, bot decision or telemetry schema change.
   - Next: `Multi-Arena Balance Baseline V1`.

## Safety Gates

- Run `git diff --check`.
- Run workspace doc drift validation.
- Run quick and full Godot validation.
- Review changed files for gameplay constants before each commit.
- Keep each track reversible by isolating behavior movement from behavior tuning.
