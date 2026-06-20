# FpsPlayground

`FpsPlayground` is the studio's PC Windows editor-first first-person arena gameplay laboratory.

It preserves the accepted Arena Shooter baseline from the former `FpsShooter` project. Football/TPS work has been extracted to `../JogoDaCopa`.

## Current Content

- Main menu with `Arena Shooter`.
- Three selectable 1x1 arena layouts: `Duel Pit V2`, `Relay Foundry V1` and `Crossfire Crucible V1`.
- Repeatable duel flow: rounds, first-to-3 match score, restart and pause-menu reset.
- Rifle hitscan, RMB Plasma Bolt, Plasma Blast, overcharge and knockback.
- Health and overcharge pickups that create route decisions.
- Jump pads, high routes and route-aware arena layouts.
- Route-first bot with item priorities, combat overlay shooting and jump pad commitment.
- Local telemetry, compact summary and telemetry readout for balance review.
- Runtime primitive visuals/audio and GUT validation.

## Current Guardrails

- Preserve the approved player movement feel for now.
- Preserve approved jump pad force, arena flow and bot route-control unless a future track explicitly targets them.
- Use telemetry/readout evidence before weapon, buff, pickup or map tuning.
- Do not add football/TPS scope here; `../JogoDaCopa` owns that work.
- Do not add export, multiplayer/backend, Web/mobile or progression unless explicitly planned.

## Run

Open `project.godot` in Godot `4.6.2-stable` and press Play.

## Validate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
```

## Read Next

- `implementation/current-status.md`
- `docs/documentation-index.md`
- `docs/work-plan.md`
- `docs/arena-shooter-future-roadmap.md`
