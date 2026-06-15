# FpsPlayground Bot Contract

The active bot is the `Arena Shooter` duel bot.

- Uses local deterministic behavior suitable for tests.
- Preserves vertical-aware line of sight.
- Preserves shot windup/readability, cooldown, strafe and reposition states.
- Can route to pickups and jump pads.
- Can dodge visible Plasma Bolt threats.
- Consumes arena tactical context when available instead of depending on a single hardcoded arena point list.
- Prefers movement quality over aim cheating: pressure, flank, retreat and vertical routes should create difficulty while preserving readable windup.
- Must remain valid when an arena changes its tactical points or a future arena supplies a different context.
- `force_fire()` remains an immediate test hook.

## Tactical Movement Contract

The bot may know arena affordances supplied by the active arena, but combat decisions should still respect target state, line of sight, cooldowns, health and projectile threats.

Supported tactical point roles:

- `pressure`: good positions to attack or re-acquire line of sight.
- `flank`: lateral routes that change the player angle.
- `cover`: positions that help break or contest line of sight.
- `retreat`: safer positions when the bot is hurt or recovering.
- `health`: health pickup objective.
- `overcharge`: overcharge objective.
- `high_ground`: vertical advantage positions.
- `jump_pad_entry`: jump pad entry points.
- `jump_pad_landing`: landing/route value points.

Difficulty must come from route quality, timing and pressure. Aim tuning remains conservative and deterministic for tests.

Football bot behavior lives in `../JogoDaCopa`.
