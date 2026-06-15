# FpsPlayground Validation

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

- Open `Projetos/FpsPlayground/project.godot` in Godot 4.6.2.
- Press Play.
- Launch `Arena Shooter`.
- Confirm mouse look, WASD, jump, rifle, Plasma Bolt, pickups, bot shots, jump pads, restart with `R`, pause menu and return to menu.

## Track 01 Combat Readability Smoke

- Confirm rifle shots give readable tracer and hit feedback without obscuring aim.
- Confirm bot damage feedback is distinct from wall/floor impact feedback.
- Confirm player damage intake is visible and brief.
- Confirm bot shot windup/tell is readable before damage is resolved.
- Confirm Plasma Bolt trajectory and impact are visible during motion.
- Confirm overcharged Plasma Bolt reads differently from the normal Plasma Bolt.
- Confirm health and overcharge pickups remain readable in combat.
- Confirm jump pad launch/landing readability is improved without changing `Duel Pit V2` route contract.
- Confirm kill/win/loss state remains understandable after the feedback pass.
- Confirm `R`, pause and return to menu still work.

## Known Noise

GUT UID/text-path warnings can appear after fresh worktree imports. They are accepted when tests pass.
