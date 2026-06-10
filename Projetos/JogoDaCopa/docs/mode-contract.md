# JogoDaCopa Mode Contract

`JogoDaCopa` currently has one playable minigame: `Futebol 1x1`.

## Menu

- Main scene: `res://modes/menu/main_menu.tscn`.
- The menu launches `res://modes/football/football.tscn`.
- It must not expose FPS arena/shooter modes.

## Futebol 1x1

- Root: `res://modes/football/football_root.gd`.
- Owns player, bot, ball, field, score, goals, intro/how-to panel and HUD snapshot.
- Player movement/input is reused from the old FPS controller, but football root owns kick direction, loose-ball contact and kick assist.
- LMB means kick, with modest lift and stronger direct push.
- RMB means strong kick, with a clear lifted pop shot.
- `Shift` means temporary speed boost that spends stamina and then recharges.
- The ball must remain physically loose: no possession lock or automatic dribble steering.
- The arena is closed with high glass walls, roof collision and taller/narrower goals so the ball can rebound from walls and ceiling without leaving the play space.
- Match ends at 3 goals.

## Reset

- `R` restarts the match.
- Pause menu can return to the main menu.
