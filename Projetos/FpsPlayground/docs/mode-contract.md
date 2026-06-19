# FpsPlayground Mode Contract

`FpsPlayground` currently has one playable mode: `Arena Shooter`.

## Menu

- Main scene: `res://modes/menu/main_menu.tscn`.
- The menu launches `res://modes/arena/arena.tscn`.
- It must not expose football/TPS minigames.

## Arena Shooter

- Root: `res://modes/arena/arena_root.gd`.
- Owns player, bot, projectiles, pickups, arena geometry, duel state and HUD snapshot.
- Player controller owns input/camera and emits shot/alt-fire requests.
- Arena root resolves rifle hits, plasma projectiles, pickup consumption and round restart.
- Bot behavior stays local and deterministic enough for tests.

## Duel Flow

- Match target: first to `3`.
- State: `playing`, `player_round_win`, `bot_round_win`, `match_over`.
- HUD shows arena, round, score and persistent result text.
- Round start resets actors, projectiles, pickups, jump pads, bot awareness and transient HUD feedback.

## Reset

- During a round result, `R` starts the next round and preserves score.
- After match over, `R` starts a fresh match and clears score.
- Pause menu has `Novo duelo` for immediate match reset.
- Pause menu can return to the main menu.
