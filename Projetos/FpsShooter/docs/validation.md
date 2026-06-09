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

Latest automated baseline:

- GUT `16/16`;
- `127` asserts;
- Track 01B validates feedback controller, player hit/miss, bot line of sight, bot windup, bot hit/miss, strafe/reposition, windup cancellation, restart cleanup, immediate `force_fire()` and synthetic audio stream creation.

## Manual Smoke

Open `Projetos/FpsShooter/project.godot` in Godot 4.6.2 and press Play.

Expected:

- mouse is captured in the arena, or captured after the first click inside the game window;
- `WASD` moves;
- mouse look rotates the camera;
- `Space` jumps;
- left click shoots while mouse is captured;
- each player shot has muzzle/tracer feedback and a short synthetic shot sound;
- aiming at the bot and shooting reduces bot health, flashes the bot, shows hitmarker and plays hit feedback;
- missing the bot still shows shot/tracer feedback without false hit confirmation;
- bot moves, strafes and repositions instead of only walking straight;
- cover can break bot line of sight, preventing normal bot damage through obstacles;
- bot normal shots show a short amber tell before damage;
- bot shots can miss without damaging the player;
- receiving bot damage shows red overlay, player health change, knockback and feedback audio;
- health values change;
- round victory/defeat gives clear HUD feedback;
- `R` restarts the round;
- `Esc` opens the menu;
- the menu sensitivity slider changes mouse look speed;
- `Retomar` or `Esc` closes the menu and captures mouse again.
