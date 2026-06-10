# FpsPlayground Bot Contract

The active bot is the `Arena Shooter` duel bot.

- Uses local deterministic behavior suitable for tests.
- Preserves vertical-aware line of sight.
- Preserves shot windup/readability, cooldown, strafe and reposition states.
- Can route to pickups and jump pads.
- Can dodge visible Plasma Bolt threats.
- `force_fire()` remains an immediate test hook.

Football bot behavior lives in `../JogoDaCopa`.
