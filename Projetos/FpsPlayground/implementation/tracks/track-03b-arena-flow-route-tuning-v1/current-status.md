# Track 03B - Arena Flow & Route Tuning V1

- Last updated: `2026-06-10`
- Project: `FpsShooter`
- Branch: `codex/fpsshooter/track03b-arena-flow-route-tuning-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track03b-arena-flow-route-tuning-v1`
- Status: `COMPLETE`
- Portfolio marker: `FPS_SHOOTER_TRACK_03B_ARENA_FLOW_ROUTE_TUNING_COMPLETE`

## Goal

Consolidate `Duel Pit V2` as the first no-void vertical duel arena: readable jump-pad routes, elevated pickups that require commitment, high-platform risk/reward, bot route intent and discrete HUD playtest context.

## Delivered

- `Duel Pit V2` remains the active map and still has no void/fall zones.
- Health Shard moved to `Vector3(-7.6, 3.55, -8.6)` with `10s` respawn.
- Overcharge moved to `Vector3(7.6, 3.55, 8.6)` with `14s` respawn.
- Jump pad targets stay at `Vector3(-9.6, 3.05, -8.6)` and `Vector3(9.6, 3.05, 8.6)`, close enough to guide players but far enough from pickups to avoid automatic collection.
- Runtime primitive markers now identify pad approaches, landing zones and high objectives using cyan, health green and overcharge purple.
- High platforms gained light cover pieces that create short duel decisions without fully closing sightlines.
- Bot route selection now exposes route labels, high-route debug state and last score data.
- Vertical-route cooldown and objective-route interval reduce repeated jump-pad loops.
- Ready shot pressure remains above health/overcharge routes; health only wins when genuinely useful, and overcharge is contested when the bot lacks a clear pressure window.
- HUD now shows a compact line for bot state, route, line of sight and last jump pad id.

## Validation

Automated:

- `tools/validate.gd`: PASS, GUT `36/36`, `297` asserts.
- Coverage includes absent void wells, pickup-to-jump-target spacing, route marker count, high-platform cover, jump-pad launch, route labels, high-route cooldown, overcharge contest, ready-shot-over-health pressure and HUD flow text.

Manual:

- Run the 5-minute editor smoke in `docs/validation.md`.
- Focus on jump-pad readability, non-automatic high pickups, high-platform cover risk/reward, bot route variety and whether the no-void duel feel remains accepted.

## Out Of Scope

- Void/fall zones in `Duel Pit V2`.
- New weapons, ammo, reload, broad recoil/spread, multiplayer, export, Web/mobile or backend.
- `NavigationAgent3D`.
- Draxos gameplay, economy, progression or lore systems.

## Next Recommendation

After human smoke, use playtest notes to choose between combat readability polish, bot route weight tuning or a new dedicated map variant. Keep void/fall pressure reserved for a future map, not for this `Duel Pit V2` baseline.
