# FpsPlayground - Current Status

- Last updated: `2026-06-15`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 04 - Arena Movement Flow And Bot Navigation V1`
- Active stage status: `DOING`
- Status marker: `FPS_PLAYGROUND_TRACK04_ARENA_MOVEMENT_FLOW_BOT_NAVIGATION_DOING`

## Current Truth

`FpsPlayground` is the first-person project split from the former `Projetos/FpsShooter` workspace. It keeps the accepted Arena Shooter baseline and no longer owns football/TPS gameplay.

The football work moved to `Projetos/JogoDaCopa`.

Fabio reported the post-split human Arena Shooter regression as OK on 2026-06-15. Track 01 polished combat readability and was approved by Fabio after smoke.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- `Duel Pit V2` 1x1 arena against a bot.
- Rifle hitscan, RMB Plasma Bolt, pickups, jump pads, high-route flow and knockback.
- Vertical-aware bot with shot pressure, health/overcharge awareness, simple jump and plasma dodge.
- Runtime primitive visuals/audio and GUT validation.
- No football, no TPS minigames, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Track 01 is approved. Track 02 is approved after human smoke focused on bot tactical movement. Track 03 is locally validated, but human smoke found that bot aim improved while map movement flow and bot navigation quality are not good enough.

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

## Active Track

`Track 04 - Arena Movement Flow And Bot Navigation V1`

Goal:

- Rebuild arena movement flow around continuous 1x1 duel loops.
- Reposition jump pads and high platforms so player movement feels readable.
- Make the bot navigate through staged movement routes instead of raw vertical destinations.
- Add validation coverage for layout clearance and jump pad route contracts.

## Validation

Latest result:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 20/20, 175 asserts
```

Manual smoke lives in `docs/validation.md`; Track 04 smoke should focus on player movement feel, jump pad approach/landing and bot movement safety.

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
