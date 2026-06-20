# FpsPlayground Arena Tactical Layouts

Track 03 introduced a small arena layout catalog so the Arena Shooter can host multiple layouts without teaching the bot about one specific map. Track 06 extends that proof with a third arena that stresses different movement rhythm and route timing.

## Layout Contract

Each layout should provide:

- `id`: stable layout identifier used by tests, menu selection and bot context labels.
- `display_name`: player-facing name.
- `map_name`: short HUD/status name.
- `floor_size`, `wall_height`, `wall_thickness`: basic arena bounds.
- `player_spawn` and `bot_spawn`: round start positions.
- `health_pickup_position` and `overcharge_pickup_position`: objective positions.
- `jump_pads`: route affordances with `id`, `position`, `target`, `roles` and cooldown fields.
- `tactical_points`: bot movement affordances with `position`, `role`, `weight` and `route`.

The arena root owns runtime spawning, pickups, jump pad physics and bot context delivery. Layout builders own geometry.

## Current Layouts

`Duel Pit V2`

- Default baseline from Track 02.
- Symmetric duel space with two high-route jump pads.
- Used to protect the accepted combat feel.

`Relay Foundry V1`

- New Track 03 proof arena.
- Asymmetric relay/foundry shape with offset cover, high catwalk routes and distinct pickup pressure.
- Used to prove the bot can consume a different tactical context without map-specific behavior.

`Crossfire Crucible V1`

- Track 06 proof arena.
- Compact cross-shaped fight space with a low-ground loop, diagonal high route, central sightline break and separated health/overcharge routes.
- Uses one shorter lift pad and one longer diagonal pad to prove route contracts generalize beyond the previous two arenas.
- Used to smoke-test bot route-first movement without adding map-specific behavior.

## Authoring Rules

- Do not put combat decision rules in layout builders.
- Do not put geometry coordinates directly in bot behavior.
- Favor roles and route labels over one-off conditionals.
- Keep tactical points readable and sparse enough for debugging.
- Every new arena must expose at least pressure, flank, cover, retreat and one objective route.
- Vertical arenas should expose `jump_pad_entry`, `jump_pad_landing` and `high_ground` roles.

## Track 04 Movement Flow Rules

Track 04 treats arena layouts as movement spaces first and tactical contexts second. A map can expose good bot points only after the player route feels good.

Use these rules when changing or adding arenas:

- A 1x1 arena needs at least one continuous ground loop around the main combat space.
- Vertical spaces need a readable route chain: entry, connector, landing and high-ground continuation.
- A jump pad should sit on a clear floor pocket, not directly against a high platform, wall or ceiling hazard.
- A jump pad target should land on a generous platform area with enough horizontal margin to recover movement.
- High-ground tactical points should share a route label with their entry/landing points so the bot can stage navigation.
- Avoid cover pieces in jump pad approach lanes and landing lanes.
- Avoid low ceilings above expected bot jump arcs.
- Prefer ramps, drops and broad connector lanes over isolated platform islands.
- Pickups should pull players through routes; they should not sit in awkward corners that break the loop.

## Track 04 Minimum Layout Checks

Automated tests should protect these contracts:

- each layout publishes a ground-loop route;
- each jump pad has an entry tactical point using the same route label;
- each jump pad has a landing tactical point using the same route label;
- each high-ground tactical point belongs to a route that has either a jump pad entry or another explicit connector;
- jump pads keep minimum flat distance from their target so the pad does not feel glued to the platform;
- jump pads keep enough flat approach clearance from nearby high platforms.

## Future Arena Checklist

Before implementing a new arena, define:

- intended duel rhythm: compact pressure, wide timing, vertical control or risk/reward route race;
- one primary ground loop that the player can run without stopping on geometry;
- at least two meaningful item decisions, usually health and overcharge on different routes;
- spawn positions that are readable, safe enough to start and fast enough to re-engage;
- sightline breaks that create choices without turning every fight into corner peeking;
- jump pad approach lanes with no cover pieces, low ceilings or platform edges in the natural entry path;
- landing zones with enough horizontal margin to recover movement;
- route labels shared by jump pad entries, landings and high-ground tactical points;
- telemetry expectations for pickup contest, route diversity, jump pad trigger/landing parity and combat source mix.

Do not add an arena only to increase count. Each new layout should teach the bot and player a different movement rhythm from the existing three.

## Track 03 Validation

- Tests must assert that both active layouts publish different context labels.
- Tests must assert that each layout publishes useful tactical roles.
- Manual smoke must cover bot movement in both `Duel Pit V2` and `Relay Foundry V1`.

## Track 06 Validation

- Tests must assert that all three layouts are selectable and expose stable ids.
- Tests must assert that `Crossfire Crucible V1` publishes pressure, cover, flank, retreat, health, overcharge, jump pad entry, jump pad landing and high-ground roles.
- Tests must assert that the `Crossfire Crucible V1` jump pad routes are distinct enough to avoid copy/paste arena rhythm.
- Manual smoke must cover movement and bot generalization in `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1`.
