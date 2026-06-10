# FpsPlayground Mode Contract

`FpsPlayground` currently has one playable mode: `Arena Shooter`.

## Menu

- Main scene: `res://modes/menu/main_menu.tscn`.
- The menu launches `res://modes/arena/arena.tscn`.
- It must not expose football/TPS minigames.

## Arena Shooter

- Root: `res://modes/arena/arena_root.gd`.
- Owns player, bot, projectiles, pickups, arena geometry, round state and HUD snapshot.
- Player controller owns input/camera and emits shot/alt-fire requests.
- Arena root resolves rifle hits, plasma projectiles, pickup consumption and round restart.
- Bot behavior stays local and deterministic enough for tests.

## Reset

- `R` restarts the round.
- Pause menu can return to the main menu.
