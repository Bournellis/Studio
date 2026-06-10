# FpsPlayground - Current Status

- Last updated: `2026-06-10`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Project Split Foundation V1`
- Active stage status: `COMPLETE`
- Status marker: `FPS_PLAYGROUND_PROJECT_SPLIT_FOUNDATION_COMPLETE`

## Current Truth

`FpsPlayground` is the first-person project split from the former `Projetos/FpsShooter` workspace. It keeps the accepted Arena Shooter baseline and no longer owns football/TPS gameplay.

The football work moved to `Projetos/JogoDaCopa`.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- `Duel Pit V2` 1x1 arena against a bot.
- Rifle hitscan, RMB Plasma Bolt, pickups, jump pads, high-route flow and knockback.
- Vertical-aware bot with shot pressure, health/overcharge awareness, simple jump and plasma dodge.
- Runtime primitive visuals/audio and GUT validation.
- No football, no TPS minigames, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Ready for editor playtest/regression focused on the preserved Arena Shooter loop after the split.

## Validation

Primary command:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/architecture-overview.md`
4. `docs/work-plan.md`
5. `docs/mode-contract.md`
6. `docs/validation.md`
7. `implementation/tracks/track-00-project-split-foundation-v1/current-status.md`
