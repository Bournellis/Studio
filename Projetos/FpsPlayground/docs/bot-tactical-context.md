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
