# FpsPlayground - Current Status

- Last updated: `2026-06-15`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 01 - Combat Readability Polish V1`
- Active stage status: `DOING`
- Status marker: `FPS_PLAYGROUND_TRACK01_COMBAT_READABILITY_POLISH_DOING`

## Current Truth

`FpsPlayground` is the first-person project split from the former `Projetos/FpsShooter` workspace. It keeps the accepted Arena Shooter baseline and no longer owns football/TPS gameplay.

The football work moved to `Projetos/JogoDaCopa`.

Fabio reported the post-split human Arena Shooter regression as OK on 2026-06-15. Track 01 resumes the project to polish combat readability without expanding gameplay scope.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- `Duel Pit V2` 1x1 arena against a bot.
- Rifle hitscan, RMB Plasma Bolt, pickups, jump pads, high-route flow and knockback.
- Vertical-aware bot with shot pressure, health/overcharge awareness, simple jump and plasma dodge.
- Runtime primitive visuals/audio and GUT validation.
- No football, no TPS minigames, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Automated baseline is green and human regression is accepted. Track 01 is active and must preserve the current `Duel Pit V2` combat contract while making combat events easier to read.

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
8. `implementation/tracks/track-01-combat-readability-polish-v1/current-status.md`
