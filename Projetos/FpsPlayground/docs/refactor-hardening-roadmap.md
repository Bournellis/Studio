# Refactor Hardening Roadmap

- Status: `Track 14D local validated pickups/jump pads baseline`
- Scope: code hardening and reduction sequence for the approved Arena Shooter baseline.
- Rule: Track 14A does not change gameplay, movement feel, jump pad force, map geometry, weapon values or bot decisions.

## Why Now

The project is approved enough to keep expanding, but the next maps, weapons, buffs and bot upgrades will touch systems that are currently concentrated in a few large files. Hardening first reduces the chance that future gameplay tracks accidentally change the approved feel.

## Current Hotspots

- `modes/arena/arena_root.gd`: largest runtime authority; owns arena assembly, round state, shots, pickups, jump pads, HUD snapshots and telemetry calls.
- `gameplay/bot/basic_duel_bot.gd`: large behavior authority; owns route choice, local movement, item commitment, combat overlay and jump pad commitment.
- `tests/unit/test_bootstrap.gd`: broad safety net; useful, but too centralized for future refactors.
- `presentation/hud/arena_hud.gd`: acceptable now, but should not absorb more match/readout logic.

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
   - Separate bot decision scoring from low-level movement execution where practical.
   - Keep behavior arena-aware through tactical context, not map-id hardcoding.
   - Next: `Track 14F - Cleanup And Documentation V1`.

6. `Track 14F - Cleanup And Documentation V1`
   - Remove duplicated transitional code.
   - Rebaseline code-size metrics and docs.
   - Decide whether to resume gameplay roadmap with multi-arena balance baseline or a smaller follow-up.

## Safety Gates

- Run `git diff --check`.
- Run workspace doc drift validation.
- Run quick and full Godot validation.
- Review changed files for gameplay constants before each commit.
- Keep each track reversible by isolating behavior movement from behavior tuning.
