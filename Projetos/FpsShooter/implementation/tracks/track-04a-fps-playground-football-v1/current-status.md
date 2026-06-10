# Track 04A - FPS Playground Menu & Futebol V1

- Last updated: `2026-06-10`
- Status: `COMPLETE`
- Portfolio marker: `FPS_PLAYGROUND_TRACK_04A_MENU_FOOTBALL_V1_COMPLETE`
- Branch: `codex/fpsshooter/track04a-fps-playground-football-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track04a-fps-playground-football-v1`

## Goal

Transform the accepted FPS arena tech probe into `FPS Playground` with a main menu and a first alternate mode: `Futebol`, a first-person 1x1 football prototype against a bot.

## Confirmed Decisions

- First-person football.
- 1x1 against a bot.
- No weapons in Futebol; LMB/RMB become kick actions.
- Loose arcade ball physics.
- Match to 3 goals.
- Festive World Cup-style presentation using runtime primitives.
- Fast 1x1 attack/defense inspired by Rocket League, adapted to first person.
- Preserve the `FpsShooter` folder name for now.

## Delivered

- `project.godot` now presents as `FPS Playground` and starts at `res://modes/menu/main_menu.tscn`.
- `FpsPlaygroundMainMenu` offers `Arena Shooter`, `Futebol` and `Sair`.
- `BootstrapSceneGenerator` now generates menu, arena and football scenes.
- Existing `Arena Shooter` mode is preserved and its pause menu can return to the main menu.
- New `FootballRoot` builds a primitive festive field, goal frames, walls, crowd color bands, player, bot, ball, HUD and feedback.
- New `FootballBall3D` provides arcade `RigidBody3D` ball behavior, velocity clamps, reset and debug helpers.
- New `FootballBot` chases, attacks, defends, jumps toward elevated ball positions and emits kick requests.
- New `FootballHud` shows score, mode state, bot state, kick/whiff/goal feedback, pause, sensitivity and return-to-menu.
- `FpsFeedbackController` now has football kick and goal effects/audio.
- Tests now cover menu routing, football scene boot, player kick, strong kick, no weapon damage, goal/match end and bot kick handoff.

## Validation

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path Projetos\FpsShooter -s res://tools/validate.gd
```

Result:

- GUT `42/42`.
- `341` asserts.

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --editor --quit --path Projetos\FpsShooter
```

Notes:

- The Godot editor headless run still reports known GUT plugin UID/text-path warnings.
- No new blocking errors from the touched FPS Playground scripts.

## Human Smoke

1. Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.
2. Confirm the first screen is `FPS Playground`.
3. Enter `Arena Shooter`, move/shoot, open `Esc`, return to menu.
4. Enter `Futebol`, confirm mouse look, WASD, jump, LMB kick and RMB strong kick.
5. Score and concede at least one goal.
6. Confirm match ends at 3 goals and `R` restarts.
7. Confirm `Esc` sensitivity and `Menu inicial` work in Futebol.

## Next Recommended Work

Run the human smoke and tune the football feel before adding new football mechanics. The likely next track is `Track 04B - Futebol Feel & Bot Tuning V1`, focused on ball friction/bounce, kick reach, bot positioning and first-person readability.
