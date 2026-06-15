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

Studio docs drift check:

```powershell
D:\Estudio\tools\check_doc_drift.ps1
```

## Manual Smoke

- Open `Projetos/JogoDaCopa/project.godot` in Godot 4.6.2.
- Press Play.
- Launch `Super Campeao` / `Futebol 1x1`.
- Confirm loading, main menu, version footer, avatar/kit/bot difficulty/match-mode selection and start button.
- Confirm direct `3, 2, 1, VAI!` kickoff countdown, third-person camera, movement, jump, `Shift` boost/stamina, LMB kick, RMB strong lifted kick, dash/flip, charged kick, SUPER/fireball, boost pads and jump pads.
- Confirm loose ball without possession lock, stronger ground grip while rolling, preserved air speed, higher bounce, narrower/taller roofed goals, no high-shot ghost goals above the crossbar, wall/ceiling/goal-roof rebounds and readable glass frames.
- Confirm Copa-style stadium seating/banners/lights, real player/bot avatars, bot behavior, broadcast HUD/scorebug, offscreen ball indicator and goal/result presentation.
- In default `3 minutos` mode, confirm clock countdown, final-30s double-goal behavior, golden goal on tied timer end, and match result.
- In optional `3 gols` mode, confirm match ends when either side reaches 3 goals.
- Confirm menu ESC, settings, restart only through pause menu confirmation, pause/resume and return to menu.

## Web Export Gate

Mandatory for every track closure from Track 04E onward:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --export-release "Web" "builds/web/index.html"
```

Then serve `builds/web/` over local HTTP, boot `index.html` in Chrome, verify the canvas appears, and save at least one Web screenshot under `docs/screenshots/<track>/`.

The Web preset is intentionally single-threaded for maximum host/browser compatibility: thread support OFF, no SharedArrayBuffer requirement and no COOP/COEP headers.

For night game-scene evidence, the capture script must verify the mounted scene uses the approved night environment (`WorldEnvironment`, ACES tonemap, `BG_SKY`, dark `ProceduralSkyMaterial`) and must sample the rendered sky region. The gate fails when captured sky-region luma is `>= 90.0` on a 0-255 scale. This check is permanent for desktop/Web capture parity from Track 04E onward.

## Known Noise

GUT UID/text-path warnings can appear after fresh worktree imports. They are accepted when tests pass.
