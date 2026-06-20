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
- `gameplay/telemetry/`: local arena event recording and readout analysis.
- `presentation/hud/`: arena HUD.
- `presentation/feedback/`: primitive effects and synthetic audio.
- `tools/`: scene generation and validation.
- `tests/`: GUT coverage for arena and helper contracts.

## Boundary

Football/TPS minigames are not part of this project. They live in `../JogoDaCopa`.

## Current Risk Areas

- `modes/arena/arena_root.gd` remains the largest runtime authority object.
- Future weapons, buffs and pickup rules should be planned before adding more combat branches to `arena_root.gd`.
- Telemetry should stay local and gameplay-neutral unless a future analytics track explicitly changes that.

## Future Direction

- Keep layout builders responsible for geometry.
- Keep bot behavior driven by arena tactical context, not map ids.
- Keep combat role contracts testable before adding new weapon inputs or UI.
- Prefer small extraction tracks when `arena_root.gd` receives a new responsibility.
