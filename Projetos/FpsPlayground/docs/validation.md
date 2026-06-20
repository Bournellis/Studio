# FpsPlayground Validation

## Automated

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest gameplay validation baseline:

```text
PASS, GUT 53/53, 496 asserts
```

Latest Track 13 documentation validation:

```text
git diff --check: PASS
check_doc_drift.ps1: PASS
validate.gd: PASS, GUT 53/53, 496 asserts
```

Latest Track 11 human smoke:

```text
PASS, telemetry session C:\Users\Fabio\AppData\Roaming\Godot\app_userdata\FpsPlayground\telemetry\arena_20260619_202922_2301377
events.jsonl and summary.json matched at 1344 events
```

Profiles:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=quick
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=structure
```

## Manual Smoke

- Open `Projetos/FpsPlayground/project.godot` in Godot 4.6.2.
- Press Play.
- Launch `Arena Shooter`.
- Confirm mouse look, WASD, jump, rifle, Plasma Bolt, pickups, bot shots, jump pads, restart with `R`, pause menu and return to menu.

## Track 01 Combat Readability Smoke

- Confirm rifle shots give readable tracer and hit feedback without obscuring aim.
- Confirm bot damage feedback is distinct from wall/floor impact feedback.
- Confirm player damage intake is visible and brief.
- Confirm bot shot windup/tell is readable before damage is resolved.
- Confirm Plasma Bolt trajectory and impact are visible during motion.
- Confirm overcharged Plasma Bolt reads differently from the normal Plasma Bolt.
- Confirm health and overcharge pickups remain readable in combat.
- Confirm jump pad launch/landing readability is improved without changing `Duel Pit V2` route contract.
- Confirm kill/win/loss state remains understandable after the feedback pass.
- Confirm `R`, pause and return to menu still work.

## Track 02 Bot Tactical Movement Smoke

- Confirm the bot can kill a passive player without needing unfair instant aim.
- Confirm the bot pressures when it has line of sight and the player is exposed.
- Confirm the bot does not repeat the same route forever.
- Confirm the bot seeks health when critically damaged and the pickup is available.
- Confirm the bot contests overcharge when it is safe and useful.
- Confirm the bot uses jump pad/high routes when vertical route scoring is valuable.
- Confirm the bot recovers from blocked movement or poor route choices.
- Confirm bot shot windup remains readable before damage is resolved.
- Confirm changing tactical points in the arena context does not leave the bot with no valid route.

## Track 03 Arena Tactical Context Smoke

- Launch `Arena Shooter - Duel Pit V2` from the menu and confirm the accepted baseline still works.
- Launch `Arena Shooter - Relay Foundry V1` from the menu and confirm the match starts in the new arena.
- In both arenas, confirm player and bot spawns are readable and not blocked by geometry.
- In both arenas, confirm health and overcharge pickups are reachable and still trigger feedback.
- In both arenas, confirm jump pads launch toward their intended route targets.
- In both arenas, confirm the bot pressures, flanks or retreats through arena-specific routes instead of freezing in place.
- In both arenas, confirm the bot does not repeat one route forever during a passive-player smoke.
- In both arenas, confirm restart with `R`, pause menu and return to menu still work.

## Track 04 Arena Movement Flow And Bot Navigation Smoke

- Launch `Arena Shooter - Duel Pit V2` and run a full ground loop without stopping on geometry.
- Launch `Arena Shooter - Relay Foundry V1` and run a full ground loop without stopping on geometry.
- In both arenas, approach each jump pad from natural movement speed and confirm the pad is easy to enter.
- In both arenas, confirm each jump pad landing has clear space and does not throw the player into cover, ceiling or platform edges.
- In both arenas, confirm high platforms are reachable through readable routes instead of awkward edge jumps.
- In both arenas, stand passive and watch the bot for repeated wall, ceiling or platform-edge collisions.
- In both arenas, confirm the bot uses staged vertical routes instead of jumping at high destinations from the floor.
- In both arenas, confirm bot pressure still feels fair: better movement, not instant/unreadable aim.
- Confirm pickups still create movement reasons and do not sit inside blocked/snappy geometry.
- Confirm restart with `R`, pause menu and return to menu still work.

## Track 04B Bot Pickup Commitment Smoke

- Damage the bot moderately, stand near a visible health pickup and confirm the bot commits to collecting it instead of ignoring it.
- Leave the bot without overcharge, stand near the overcharge pickup and confirm the bot commits to collecting it even when it has line of sight.
- Confirm the bot does not abandon all combat pressure for distant pickups.
- Confirm pickup commitment does not make windup shots unreadable or instant.
- Confirm restart with `R`, pause menu and return to menu still work.

## Track 05 Quake Duel Route Control Bot Smoke

- In `Relay Foundry V1`, watch the bot use the long jump pad and confirm it completes the landing instead of strafing away mid-air.
- With bot health high, confirm it favors the overcharge/damage boost route instead of only strafing or cover-peeking.
- With bot health low, confirm it favors health/reset routes over forcing bad fights.
- Confirm the bot still shoots when it has a visible target, but the shot does not cancel the map route.
- Confirm strafe/cover still exists as local fight correction, not the dominant behavior every time the bot sees the player.
- Confirm bot shot windup remains readable and fair.
- Confirm restart with `R`, pause menu and return to menu still work.

## Track 05B Long Jump Pad First Try Smoke

- In `Relay Foundry V1`, watch the bot approach each long jump pad from ground movement and confirm the first trigger reaches the landing platform.
- Confirm the bot does not need to fall, reset or trigger the same jump pad a second time before reaching the high route.
- Confirm the bot enters the pad cleanly instead of cutting across the edge and launching from a poor angle.
- Confirm the player can still use both long jump pads without feeling over-launched or snapped unnaturally.
- Confirm combat overlay still works: the bot may shoot during the route, but it does not cancel the jump pad approach or flight.
- Confirm restart with `R`, pause menu and return to menu still work.

## Track 06 Arena Variety And Bot Generalization Smoke

- Launch all three arenas from the menu and confirm each match starts with readable spawns.
- In the new arena, run one full low-ground loop without catching on walls, cover, platform edges or pickups.
- In the new arena, use every jump pad or vertical connector from natural movement speed and confirm first-use reliability.
- Confirm health and overcharge sit on different route decisions instead of the same awkward pocket.
- Stand passive and confirm the bot rotates through arena-specific routes without freezing, wall-rubbing or repeating one route forever.
- Confirm the bot still shoots during movement without canceling its route objective.
- Confirm `Duel Pit V2` and `Relay Foundry V1` still preserve their accepted movement and bot behavior.
- Confirm restart with `R`, pause menu and return to menu still work.

## Track 07 Match Flow And Duel UX Smoke

- Launch each arena from the menu and confirm score starts `0 - 0`.
- Win one round and confirm player score increments once.
- Lose one round and confirm bot score increments once.
- Press `R` after a round result and confirm next round starts clean with score preserved.
- Reach match win/loss target and confirm final result is readable.
- Press `R` after match over and confirm a fresh match starts with score reset.
- Pause during active play, resume, then return to menu.
- Return to menu after a match and select a different arena; confirm score does not leak.
- Confirm bot movement/combat still feels like Track 06: route-first, item-aware and able to shoot as overlay.

## Track 09 Combat Sandbox Smoke

- Confirm rifle and direct Plasma Bolt still feel unchanged.
- Fire Plasma Bolt into floor/walls near the bot and confirm a readable partial blast.
- Confirm overcharged Plasma Bolt blast is more visible and stronger.
- Confirm the blast does not create player self-damage or rocket-jump behavior.
- Confirm player movement, jump pads and all three arena routes feel unchanged.
- Confirm bot remains route-first and does not gain unfair aim or reaction.
- Confirm round flow, score, restart and pause-menu reset still work.

## Track 10 Combat Balance And Weapon Roles Smoke

- Confirm rifle remains the primary precision and finishing weapon.
- Confirm direct Plasma feels stronger per hit than rifle, but slower and higher-commitment.
- Confirm Plasma Blast pressures cover and near misses without becoming stronger than direct hits or rifle timing.
- Confirm overcharge makes rifle/plasma meaningfully stronger without deciding every duel instantly.
- Confirm bot shot pressure remains readable, fair and below player burst.
- Confirm movement, sensitivity, jump pads, maps, bot route-control and pickups feel unchanged.
- Confirm round flow, score, restart and pause-menu reset still work.

## Track 11 Complete Telemetry Smoke

- Launch `Arena Shooter`, play at least one full round and close or restart the arena.
- Confirm telemetry output is created under Godot `user://telemetry/<session_id>/`.
- Open `events.jsonl` and confirm it includes session, round, combat, pickup, bot, movement and jump pad events.
- Open `summary.json` and confirm it reports winner counts, damage by actor/source, weapon accuracy, Plasma contribution, pickup usage, bot route data and movement/jump pad metrics.
- Confirm `player:plasma_blast` does not appear as a fired weapon accuracy row; blast contribution belongs to Plasma and damage-source metrics.
- Confirm `summary.json` stays aligned with the latest written events after arena reset, new match or interrupted session.
- Press `R` during active play and confirm `events.jsonl` shows `round_reset` with `reason=manual_restart` before the next `round_start`.
- Confirm the data helps answer why a round was won without needing to watch the whole match again.
- Confirm player movement, sensitivity, jump pads, maps, bot route-control, pickups and Track 10 weapon roles feel unchanged.

## Track 12 Telemetry Readout Smoke

- Run `res://tools/telemetry_readout.gd -- --latest` after a fresh arena session.
- Run `res://tools/telemetry_readout.gd -- --session="<path>"` against the approved Track 11 smoke session.
- Confirm the report shows integrity, lifecycle, rounds, combat, Plasma, pickups, bot, movement and alerts.
- Confirm the report calls out useful balance watch items without requiring raw JSON inspection.
- Confirm `--json` emits a structured readout for future automation.
- Confirm no gameplay feel changed.

## Known Noise

GUT UID/text-path warnings can appear after fresh worktree imports. They are accepted when tests pass.
