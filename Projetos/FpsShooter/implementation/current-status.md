# FpsShooter - Current Status

- Last updated: `2026-06-09`
- Project: `FpsShooter`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS 3D tech probe`
- Active stage: `Track 00 - Project Bootstrap`
- Active stage status: `COMPLETE`

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

Bootstrap is complete. The project can now move into `Track 01 - Arena 1x1 V1` for the first stronger duel loop.

## Current Gate

Closed for Track 00. Continue with Track 01 planning and implementation decisions.

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
- player mouse look is handled through `_input`.

Latest shoot/menu fix:

- default mouse sensitivity lowered to `0.0018`;
- player shooting can be requested directly from input events and still respects cooldown;
- combatant collider now matches the visible capsule body so eye-height hitscan can damage the bot;
- `Esc` opens a pause menu with a sensitivity slider and `Retomar` button.

Bootstrap closeout:

- editor warning `SHADOWED_VARIABLE_BASE_CLASS` in `arena_hud.gd` fixed by avoiding a `CanvasLayer` method name collision;
- headless validation passes the FpsShooter GUT suite;
- first playable editor baseline is accepted as complete for Track 00.

## Read Next

1. `AGENTS.md`
2. `docs/work-plan.md`
3. `docs/reuse-map.md`
4. `docs/validation.md`
5. `implementation/tracks/track-01-arena-1x1-v1/current-status.md`
