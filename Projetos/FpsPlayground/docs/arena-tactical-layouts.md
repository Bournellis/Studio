# FpsPlayground Arena Tactical Layouts

Track 03 introduces a small arena layout catalog so the Arena Shooter can host multiple layouts without teaching the bot about one specific map.

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

## Initial Layouts

`Duel Pit V2`

- Default baseline from Track 02.
- Symmetric duel space with two high-route jump pads.
- Used to protect the accepted combat feel.

`Relay Foundry V1`

- New Track 03 proof arena.
- Asymmetric relay/foundry shape with offset cover, high catwalk routes and distinct pickup pressure.
- Used to prove the bot can consume a different tactical context without map-specific behavior.

## Authoring Rules

- Do not put combat decision rules in layout builders.
- Do not put geometry coordinates directly in bot behavior.
- Favor roles and route labels over one-off conditionals.
- Keep tactical points readable and sparse enough for debugging.
- Every new arena must expose at least pressure, flank, cover, retreat and one objective route.
- Vertical arenas should expose `jump_pad_entry`, `jump_pad_landing` and `high_ground` roles.

## Track 03 Validation

- Tests must assert that both active layouts publish different context labels.
- Tests must assert that each layout publishes useful tactical roles.
- Manual smoke must cover bot movement in both `Duel Pit V2` and `Relay Foundry V1`.
