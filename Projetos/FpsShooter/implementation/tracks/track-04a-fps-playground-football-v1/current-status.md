# Track 04A - FPS Playground Menu & Futebol V1

- Last updated: `2026-06-10`
- Status: `COMPLETE_WITH_FIRST_FIXES`
- Portfolio marker: `FPS_PLAYGROUND_TRACK_04A_FOOTBALL_FIRST_FIXES_COMPLETE`
- Branch: `codex/fpsshooter/track04a-fps-playground-football-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track04a-fps-playground-football-v1`
- First fixes branch: `codex/fpsshooter/track04a-football-first-fixes`
- First fixes worktree: `D:\Estudio-worktrees\FpsShooter--codex--track04a-football-first-fixes`

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

## First Fixes

- Main menu layout now uses explicit centered anchors and offsets so `FPS Playground` is stable in the first viewport.
- `Futebol` now opens into a paused `Como Jogar` overlay with hotkeys/basic rules and a `Começar` button before mouse capture.
- Goal mouths now have north/south collision floor extensions, preventing the player/ball from dropping through the goal area.
- Tests now also cover menu offsets, the paused football intro panel and goal safety floors.

## Validation

PASS:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path Projetos\FpsShooter -s res://tools/validate.gd
```

Result:

- GUT `42/42`.
- `351` asserts.

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
4. Enter `Futebol`, confirm the paused `Como Jogar` panel appears before play.
5. Press `Começar`, then confirm mouse look, WASD, jump, LMB kick and RMB strong kick.
6. Enter both goal mouths and confirm there is no map hole/fall.
7. Score and concede at least one goal.
8. Confirm match ends at 3 goals and `R` restarts.
9. Confirm `Esc` sensitivity and `Menu inicial` work in Futebol.

## Next Recommended Work

Run the human smoke and tune the football feel before adding new football mechanics. The likely next track is `Track 04B - Futebol Feel & Bot Tuning V1`, focused on ball friction/bounce, kick reach, bot positioning and first-person readability.
