# FpsPlayground - Current Status

- Last updated: `2026-06-16`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 06 - Arena Variety And Bot Generalization V1`
- Active stage status: `READY_FOR_HUMAN_SMOKE`
- Status marker: `FPS_PLAYGROUND_TRACK06_ARENA_VARIETY_BOT_GENERALIZATION_READY_FOR_SMOKE`

## Current Truth

`FpsPlayground` is the first-person project split from the former `Projetos/FpsShooter` workspace. It keeps the accepted Arena Shooter baseline and no longer owns football/TPS gameplay.

The football work moved to `Projetos/JogoDaCopa`.

Fabio reported the post-split human Arena Shooter regression as OK on 2026-06-15. Track 01 polished combat readability and was approved by Fabio after smoke.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1` 1x1 arenas against a bot.
- Rifle hitscan, RMB Plasma Bolt, pickups, jump pads, high-route flow and knockback.
- Vertical-aware bot with shot pressure, health/overcharge awareness, simple jump and plasma dodge.
- Runtime primitive visuals/audio and GUT validation.
- No football, no TPS minigames, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Track 01 is approved. Track 02 is approved after human smoke focused on bot tactical movement. Track 03 is locally validated. Track 04 map/movement changes were approved by Fabio after smoke. Track 04B fixed nearby pickup commitment. Track 05 route-control bot was approved by Fabio overall. Track 05B was approved by Fabio after smoke: the bot is good and the remaining first-attempt long jump pad failure is resolved. Track 06 is locally validated and ready for human smoke.

## Track 01 Delivered

- HUD event colors and messages for bot tell, player damage, Plasma hit and overcharge hit.
- Dedicated HUD contract for Plasma hit/kill instead of using only generic hit confirm.
- Readability beacons/halos for health and overcharge pickups.
- Launch direction cues on both jump pads.
- Focused GUT coverage for combat readability HUD events and scene nodes.

## Previous Track

`Track 02 - Bot Tactical Movement V1`

- Introduce a tactical context so arenas publish bot affordances instead of hardcoded one-arena reposition lists.
- Improve route selection between pressure, flank, cover, high ground, health, overcharge and jump pad routes.
- Improve bot pressure through movement quality first, then conservative aim/reaction tuning.
- Preserve current `Duel Pit V2` layout and weapon kit.
- Avoid new weapons, new map, export, Web/mobile, multiplayer and backend.

## Track 02 Delivered

- Added `BotTacticalContext` so arenas publish tactical points and jump pad routes to the bot.
- Replaced the one-arena reposition list in bot behavior with scored tactical roles.
- Added route roles for pressure, flank, cover, retreat, health, overcharge, high ground and jump pad flow.
- Added recent route memory/anti-repeat scoring and stronger stuck recovery through tactical reselection.
- Tuned bot reaction/cooldown/aim conservatively while preserving shot windup readability.
- Added focused tests for tactical context filtering, alternate arena context, health priority and Duel Pit role exposure.

## Human Approval

- Fabio approved the Track 02 bot smoke on 2026-06-15.
- Fabio approved executing Track 03 on 2026-06-15.

## Previous Track

`Track 03 - Arena Tactical Context Proof V1`

Delivered:

- Extracted arena layout data into `ArenaLayoutCatalog`.
- Preserved `Duel Pit V2` as the default baseline.
- Added `Relay Foundry V1`, a second arena with distinct shape, routes, pickups, jump pads and tactical points.
- Added main-menu selection for both arena layouts.
- Kept bot improvement focused on movement/context usage, not unfair aim/damage tuning.
- Added automated coverage for catalog, menu selection and runtime multi-arena bot context.

## Previous Track

`Track 05 - Quake Duel Route Control Bot V1`

Goal:

- Make movement objective, stack and item control govern bot movement.
- Keep visible-target shooting active as a combat overlay instead of canceling routes.
- Make jump pad routes committed through approach, flight and landing.

Delivered:

- Added `docs/bot-route-control.md` as the route-control contract.
- Changed bot windup/shooting into a combat overlay that preserves item/jump routes.
- Added health/overcharge scoring bias based on stack state.
- Reduced default strafe/cover dominance in engage/cooldown flow.
- Added jump pad flight and landing commitment state.
- Added tests for healthy overcharge priority, shooting without canceling item route and jump pad landing commitment.

## Previous Track

`Track 05B - Long Jump Pad First Try V1`

Goal:

- Make the `Relay Foundry V1` long jump pad reliable on the first attempt.
- Preserve Track 05 route-first movement and combat overlay shooting.
- Keep long pad feel controlled for the player.

Delivered:

- Changed jump pad launch to derive horizontal speed from route distance and actor trigger position.
- Added a bot approach lock near jump pads so local dodge/strafe does not cut the entry angle.
- Reduced bot air steering during committed jump pad flight.
- Added automated coverage for route-distance launch and first-attempt long jump completion in `Relay Foundry V1`.
- Updated validation and smoke documentation for first-trigger long pad checks.

## Active Track

`Track 06 - Arena Variety And Bot Generalization V1`

Goal:

- Add a third arena with a distinct movement rhythm.
- Prove the approved bot behavior generalizes without map-specific bot code.
- Preserve route-first movement, item priorities and reliable vertical connectors.

Delivered:

- Added `Crossfire Crucible V1`, a compact crossfire arena with distinct low-ground loop, diagonal high route, two jump pad rhythms and separated health/overcharge routes.
- Added menu selection and layout catalog contract for the third arena.
- Published tactical roles and jump pad routes for the new arena without adding map-specific bot code.
- Added automated coverage for the menu, layout contract, required bot roles and distinct jump pad route lengths.
- Kept combat mechanics, weapons, bot aim/damage and export scope unchanged.

Next sequence:

- Track 07 - Match Flow And Duel UX V1.
- Track 08 - Player Movement Feel Polish V1.
- Track 09 - Combat Sandbox Expansion V1.

## Previous Track

`Track 04B - Bot Pickup Commitment V1`

Goal:

- Make the bot commit to useful nearby HP/boost pickups without becoming a passive distant-item collector.
- Preserve distant pickup contesting as tactical, not automatic.

Delivered:

- Added local pickup commitment thresholds for nearby health and overcharge.
- Let nearby useful pickups interrupt engage/strafe/cooldown decisions.
- Kept windup shots readable and distant item routes conservative.
- Added route-hold logic so the bot does not abandon a nearby pickup immediately after choosing it.
- Added tests for damaged nearby health pickup and nearby overcharge pickup even with line of sight.

## Previous Track

`Track 04 - Arena Movement Flow And Bot Navigation V1`

Goal:

- Rebuild arena movement flow around continuous 1x1 duel loops.
- Reposition jump pads and high platforms so player movement feels readable.
- Make the bot navigate through staged movement routes instead of raw vertical destinations.
- Add validation coverage for layout clearance and jump pad route contracts.

Delivered:

- Added movement-flow route contracts for jump pad entry, landing and high-ground continuation.
- Rebuilt `Relay Foundry V1` with wider footprint, clearer ground loop, separated jump pad approaches and less cramped high-platform placement.
- Normalized vertical route labels so jump pad entries, landings and high objectives share route ids.
- Updated `BasicDuelBot` so high destinations resolve through staged jump pad navigation while the bot is still on low ground.
- Added overhead jump clearance and temporary blocked-route penalties for stuck recovery.
- Added tests for staged vertical route contracts, Relay jump pad spacing and bot jump pad navigation target selection.

## Validation

Latest result:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 32/32, 289 asserts
```

Manual smoke lives in `docs/validation.md`; Track 06 should focus on three-arena menu selection, `Crossfire Crucible V1` movement flow and bot generalization.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/architecture-overview.md`
4. `docs/work-plan.md`
5. `docs/mode-contract.md`
6. `docs/validation.md`
7. `docs/bot-tactical-context.md`
8. `implementation/tracks/track-02-bot-tactical-movement-v1/current-status.md`
9. `implementation/tracks/track-03-arena-tactical-context-proof-v1/current-status.md`
10. `implementation/tracks/track-04-arena-movement-flow-bot-navigation-v1/current-status.md`
11. `implementation/tracks/track-04b-bot-pickup-commitment-v1/current-status.md`
12. `implementation/tracks/track-05-quake-duel-route-control-bot-v1/current-status.md`
13. `implementation/tracks/track-05b-long-jump-pad-first-try-v1/current-status.md`
14. `implementation/tracks/track-06-arena-variety-bot-generalization-v1/current-status.md`
