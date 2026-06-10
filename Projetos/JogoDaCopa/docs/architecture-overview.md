# JogoDaCopa Architecture Overview

`JogoDaCopa` is the TPS football minigame project after the split from `FpsShooter`.

## Ownership

- `modes/menu/`: project entry and football minigame launch.
- `modes/football/`: field assembly, stadium/arena primitive composition, score state, height-aware goal detection, loose-ball contact, kicks, boost snapshot and match lifecycle.
- `modes/shared/`: runtime primitive creation.
- `gameplay/avatar/`: procedural humanoid avatars, skin tones and country-inspired kits.
- `gameplay/combat/`: reused character body, health and knockback base.
- `gameplay/player/`: reused movement/input controller for the local player.
- `gameplay/football/`: ball, football bot and pure football rule helpers.
- `presentation/camera/`: third-person football chase camera.
- `presentation/hud/`: football HUD and intro/how-to panel.
- `presentation/feedback/`: primitive effects and synthetic audio.
- `tools/`: scene generation and validation.
- `tests/`: GUT coverage for football, avatar and helper contracts.

## Boundary

FPS arena/shooter work is not part of this project. It lives in `../FpsPlayground`.

## Arena Composition

`FootballFieldBuilder` owns the procedural stadium pass for now:

- pitch base, grass stripes and field markings;
- roofed goal shells with collision, glass tint and frame rails;
- glass arena walls/ceiling plus visual frame posts and roof ribs;
- primitive stadium seating, crowd color blocks, country-inspired banners, decorative scoreboards and light rigs.

Keep this runtime-primitive and replaceable until a future authored-asset track is explicitly approved.
