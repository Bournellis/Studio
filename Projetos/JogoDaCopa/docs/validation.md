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
- Confirm intro/how-to, avatar selection, third-person camera, movement, jump, `Shift` boost/stamina, LMB kick, RMB strong lifted kick, loose ball without possession lock, stronger ground grip while rolling, preserved speed in the air, higher bounce, narrower/taller roofed goals, no high-shot ghost goals above the crossbar, wall/ceiling/goal-roof rebounds, readable glass frames, Copa-style stadium seating/banners/lights, bot, score to 3, restart with `R`, pause menu and return to menu.

## Web Export Gate

Mandatory for every track closure from Track 04E onward:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

Then serve `builds/web/` over local HTTP, boot `index.html` in Chrome, verify the canvas appears, and save at least one Web screenshot under `docs/screenshots/<track>/`.

The Web preset is intentionally single-threaded for maximum host/browser compatibility: thread support OFF, no SharedArrayBuffer requirement and no COOP/COEP headers.

## Known Noise

GUT UID/text-path warnings can appear after fresh worktree imports. They are accepted when tests pass.
