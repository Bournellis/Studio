# JogoDaCopa Validation

## Automated

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Profiles:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=quick
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd -- --profile=structure
```

## Manual Smoke

- Open `Projetos/JogoDaCopa/project.godot` in Godot 4.6.2.
- Press Play.
- Launch `Futebol 1x1`.
- Confirm intro/how-to, avatar selection, third-person camera, movement, jump, `Shift` boost/stamina, LMB kick, RMB strong kick, loose ball without possession lock, wall/ceiling rebounds, bot, score to 3, restart with `R`, pause menu and return to menu.

## Known Noise

GUT UID/text-path warnings can appear after fresh worktree imports. They are accepted when tests pass.
