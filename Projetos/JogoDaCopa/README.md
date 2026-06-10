# Jogo Da Copa

`JogoDaCopa` is the studio's PC Windows editor-first third-person football minigame project.

It starts from the accepted football prototype extracted from the former `FpsShooter` project. The FPS arena lab now lives in `../FpsPlayground`.

## Current Content

- Main menu with `Futebol 1x1`.
- Third-person chase camera inspired by Rocket League.
- 1x1 football against a bot, match to 3 goals.
- Runtime primitive stadium with closed goals.
- Loose arcade `RigidBody3D` ball.
- Lightweight possession, dribble nudges and near-front kick assist.
- Skin tone and country-inspired shirt selection.
- Procedural primitive avatars with basic animation states.
- Football HUD, kick/goal feedback and GUT validation.

## Run

Open `project.godot` in Godot `4.6.2-stable` and press Play.

## Validate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```
