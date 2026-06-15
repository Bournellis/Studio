# FpsPlayground - Current Status

- Last updated: `2026-06-15`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 03 - Arena Tactical Context Proof V1`
- Active stage status: `IN_PROGRESS`
- Status marker: `FPS_PLAYGROUND_TRACK03_ARENA_TACTICAL_CONTEXT_PROOF_IN_PROGRESS`

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

Track 01 is approved. Track 02 is approved after human smoke focused on bot tactical movement, arena-agnostic route context, pressure and fairness without new map or weapon scope.

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

## Active Track

`Track 03 - Arena Tactical Context Proof V1`

- Prove the Track 02 tactical context with more than one playable arena.
- Extract arena layout data into a catalog/provider instead of keeping all Duel Pit assumptions in `arena_root.gd`.
- Preserve `Duel Pit V2` as the default baseline.
- Add `Relay Foundry V1`, a second arena with distinct shape, routes, pickups, jump pads and tactical points.
- Add a simple arena selection path from the main menu.
- Keep bot improvement focused on movement/context usage, not unfair aim/damage tuning.
- Avoid new weapons, export, Web/mobile, multiplayer and backend.

## Validation

Latest result:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 18/18, 135 asserts
```

Manual smoke lives in `docs/validation.md`.

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
