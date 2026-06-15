# FpsPlayground Validation

## Automated

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Latest Track 04B local result:

```text
PASS, GUT 25/25, 211 asserts
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

## Known Noise

GUT UID/text-path warnings can appear after fresh worktree imports. They are accepted when tests pass.
