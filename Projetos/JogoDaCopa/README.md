# JogoDaCopa

`JogoDaCopa` is the studio's PC Windows editor-first third-person football minigame project. Its first public playable surface is `Super Campeao`.

It starts from the accepted football prototype extracted from the former `FpsShooter` project. The FPS arena lab now lives in `../FpsPlayground`.

## Current Content

- Main menu launching `Super Campeao` / `Futebol 1x1`.
- Third-person chase camera inspired by Rocket League.
- 1x1 football against a bot.
- Default 3-minute match timer with golden goal on draw; `3 gols` remains selectable.
- Copa-style stadium with roofed/closed goals, glass frames, banners, crowd bands and light rigs.
- Loose arcade `RigidBody3D` ball.
- Loose-ball contact and near-front kick assist without possession lock.
- Skin tone and country-inspired shirt selection.
- Real Quaternius skinned humanoid avatars with UAL clips and authored kick/celebration hooks.
- Broadcast-style football HUD, kick/goal feedback, pause/settings flow and GUT validation.
- Single-threaded Web export/publication gate for the public browser build.

## Current State

Technical state lives in `implementation/current-status.md`. Publication history, release roots, attempts and rollbacks live only in `docs/release-history.md`. Work enters through `08_Coordenacao/`.

## Run

Open `project.godot` in Godot `4.6.2-stable` and press Play.

## Validate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```
