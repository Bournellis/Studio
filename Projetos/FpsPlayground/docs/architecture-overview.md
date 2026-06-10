# FpsPlayground Architecture Overview

`FpsPlayground` is the FPS-only project after the split from `FpsShooter`.

## Ownership

- `modes/menu/`: project entry and Arena Shooter launch.
- `modes/arena/`: arena assembly, round state, player shot resolution, bot shot resolution, pickups and HUD snapshots.
- `modes/shared/`: runtime primitive creation.
- `gameplay/player/`: first-person player controller, camera, rifle and Plasma Bolt requests.
- `gameplay/combat/`: combatant health, damage and knockback.
- `gameplay/bot/`: arena duel bot, deterministic aim and visibility helpers.
- `gameplay/arena/`: pure arena rule helpers.
- `presentation/hud/`: arena HUD.
- `presentation/feedback/`: primitive effects and synthetic audio.
- `tools/`: scene generation and validation.
- `tests/`: GUT coverage for arena and helper contracts.

## Boundary

Football/TPS minigames are not part of this project. They live in `../JogoDaCopa`.
