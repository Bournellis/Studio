# FpsShooter - Current Status

- Last updated: `2026-06-09`
- Project: `FpsShooter`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS 3D tech probe`
- Active stage: `Track 00 - Project Bootstrap`
- Active stage status: `BOOTSTRAP_ACTIVE`

## Current Truth

`FpsShooter` is an official implementable Godot project for testing first-person 3D shooter fundamentals in the studio.

The project is a tech probe independent from Draxos Roguelike Cardgame, DraxosMobile, RPG Isometrico and RPG Turnos. It may use a light Draxos visual theme, but no other project gameplay system is inherited.

## Current Scope

- PC Windows editor-first.
- Traditional FPS baseline.
- Local 1x1 arena against a bot.
- Player movement, mouse look, jump, hitscan shot and knockback.
- Bot V1 walks and shoots.
- Simple arena, HUD and round state.
- No export, Web, mobile, multiplayer or online/backend scope.

## Active Goal

Complete bootstrap and then move into `Track 01 - Arena 1x1 V1` for the first editor-playable round.

## Current Gate

Run headless validation and then open the project in Godot editor for manual feel testing.

## Validation Snapshot

Expected command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Manual smoke lives in `docs/validation.md`.

Latest editor-input fix:

- editor import no longer reports `INT_AS_ENUM_WITHOUT_CAST` in `app_bootstrap.gd`;
- editor import no longer reports `SHADOWED_VARIABLE_BASE_CLASS` in `arena_root.gd`;
- HUD controls are mouse-pass-through so FPS look is not swallowed by UI;
- player mouse look is handled through `_input` and has a slightly stronger bootstrap sensitivity.

## Read Next

1. `AGENTS.md`
2. `docs/work-plan.md`
3. `docs/reuse-map.md`
4. `docs/validation.md`
5. `implementation/tracks/track-00-project-bootstrap/current-status.md`
