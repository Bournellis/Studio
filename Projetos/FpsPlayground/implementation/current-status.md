# FpsPlayground - Current Status

- Last updated: `2026-06-15`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 02 - Bot Duel Tuning V1`
- Active stage status: `PLANNED`
- Status marker: `FPS_PLAYGROUND_TRACK01_COMBAT_READABILITY_POLISH_APPROVED`

## Current Truth

`FpsPlayground` is the first-person project split from the former `Projetos/FpsShooter` workspace. It keeps the accepted Arena Shooter baseline and no longer owns football/TPS gameplay.

The football work moved to `Projetos/JogoDaCopa`.

Fabio reported the post-split human Arena Shooter regression as OK on 2026-06-15. Track 01 polished combat readability and was approved by Fabio after smoke.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- `Duel Pit V2` 1x1 arena against a bot.
- Rifle hitscan, RMB Plasma Bolt, pickups, jump pads, high-route flow and knockback.
- Vertical-aware bot with shot pressure, health/overcharge awareness, simple jump and plasma dodge.
- Runtime primitive visuals/audio and GUT validation.
- No football, no TPS minigames, no export, no Web/mobile, no multiplayer/backend.

## Current Gate

Track 01 is approved. The next recommended gate is `Track 02 - Bot Duel Tuning V1`, focused on bot pressure, fairness and route variety without new map or weapon scope.

## Track 01 Delivered

- HUD event colors and messages for bot tell, player damage, Plasma hit and overcharge hit.
- Dedicated HUD contract for Plasma hit/kill instead of using only generic hit confirm.
- Readability beacons/halos for health and overcharge pickups.
- Launch direction cues on both jump pads.
- Focused GUT coverage for combat readability HUD events and scene nodes.

## Recommended Next Track

`Track 02 - Bot Duel Tuning V1`

- Tune bot pressure windows after the readability pass.
- Adjust aim fairness, windup timing, cooldown and reaction feel.
- Review route selection between direct pressure, health, overcharge and jump pads.
- Preserve current `Duel Pit V2` layout and weapon kit.
- Avoid new weapons, new map, export, Web/mobile, multiplayer and backend.

## Validation

Latest result:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 15/15, 118 asserts
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
