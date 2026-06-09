# FpsShooter Validation

- Last updated: `2026-06-09`
- Status: `VIVO`

## Headless Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\FpsShooter -s res://tools/validate.gd
```

When working from a dedicated worktree, run with that worktree path.

## What It Does

- regenerates `res://modes/arena/arena.tscn` from `tools/bootstrap_scene_generator.gd`;
- checks required project settings, autoloads and resources;
- checks the generated arena scene loads;
- runs the GUT suite under `res://tests/unit`;
- prints the manual editor follow-up instead of exporting.

## Manual Smoke

Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.

Expected:

- mouse is captured in the arena;
- `WASD` moves;
- mouse look rotates the camera;
- `Space` jumps;
- left click shoots;
- bot moves and shoots;
- health values change;
- `R` restarts the round;
- `Esc` releases/captures mouse.
