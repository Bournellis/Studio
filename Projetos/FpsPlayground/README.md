# FpsPlayground

`FpsPlayground` is the studio's PC Windows editor-first first-person gameplay laboratory.

It preserves the accepted Arena Shooter baseline from the former `FpsShooter` project. Football/TPS work has been extracted to `../JogoDaCopa`.

## Current Content

- Main menu with `Arena Shooter`.
- `Duel Pit V2` 1x1 arena.
- Rifle hitscan and RMB Plasma Bolt.
- Health and overcharge pickups.
- Jump pads, high routes and no active void/fall zone in the current map.
- Vertical-aware bot with shot pressure, simple jump, pickup awareness and plasma dodge.
- HUD, feedback, synthetic audio and GUT validation.

## Run

Open `project.godot` in Godot `4.6.2-stable` and press Play.

## Validate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```
