# FpsPlayground Bot Tactical Context

Track 02 moved the Arena Shooter bot from a single-arena reposition list toward an arena-provided tactical context.

Track 03 proves the contract with multiple playable arena layouts.

## Goal

The bot should remain useful when `Duel Pit V2` changes or when a future arena supplies a different layout.

The arena owns geometry knowledge. The bot owns combat decision-making.

## Arena Contract

Each arena can publish tactical points with:

- `position`: world position.
- `role`: tactical role such as `pressure`, `flank`, `cover`, `retreat`, `health`, `overcharge`, `high_ground`, `jump_pad_entry` or `jump_pad_landing`.
- `weight`: optional local priority multiplier.
- `route`: optional grouping label for route memories and jump pad chains.

Each arena can also publish jump pad routes with:

- `id`
- `position`
- `target`
- optional `roles`

Track 03 layouts are catalog-driven. The arena root loads the active layout, asks its builder to create geometry, and passes the active layout's tactical points and jump pad routes to the bot.

## Bot Contract

The bot scores available tactical points against its live duel state:

- own health;
- target distance;
- line of sight;
- shot cooldown/reaction;
- recent routes;
- vertical route cooldown;
- objective cooldown;
- projectile threat.

The bot must prefer movement quality before raw aim buffs.

## Track 04 Movement Route Contract

Track 04 adds a stronger interpretation layer on top of tactical points.

The bot should not treat every tactical point as directly walkable. Vertical goals need staged navigation:

1. `jump_pad_entry`: move toward a safe floor approach point.
2. jump pad trigger: enter the pad radius intentionally.
3. `jump_pad_landing`: allow the launch to land before choosing a new high objective.
4. `high_ground`: move along the elevated route only after reaching the route.

Rules:

- From the floor, high-ground destinations are not direct movement targets when their route has a jump pad entry.
- If a route has a jump pad entry and landing, the bot should navigate to the entry/trigger before the high point.
- A bot jump should be used for short obstacle recovery only when forward and overhead clearance are reasonable.
- Repeated collisions on the same vertical route should temporarily blacklist that route.
- Stuck recovery should pick a different movement route, not retry the same blocked high destination immediately.
- Arena authors should use route labels consistently so the bot can infer movement chains without map-specific code.

## Track 02 Acceptance

- The bot no longer depends on a hardcoded `BOT_REPOSITION_POINTS` list inside combat behavior.
- `Duel Pit V2` publishes tactical roles for its existing geometry.
- Unit tests can build an alternate tactical context and verify bot choices without creating a new arena.
- Human smoke confirms pressure, vertical routes, objective choices and anti-repeat movement.

## Track 03 Acceptance

- `Duel Pit V2` and `Relay Foundry V1` publish distinct context labels.
- Both arenas expose tactical roles through the same data contract.
- The bot receives the active context after spawn and restart.
- Jump pad routes come from the active arena rather than one hardcoded Duel Pit list.
- Human smoke confirms that bot movement remains useful in both arenas.
