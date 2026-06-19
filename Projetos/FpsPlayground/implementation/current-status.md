# FpsPlayground - Current Status

- Last updated: `2026-06-19`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 07 - Match Flow And Duel UX V1`
- Active stage status: `READY_FOR_HUMAN_SMOKE`
- Status marker: `FPS_PLAYGROUND_TRACK07_MATCH_FLOW_DUEL_UX_READY_FOR_SMOKE`

## Current Truth

`FpsPlayground` owns the FPS arena work split from the former `FpsShooter`. Football/TPS work belongs to `Projetos/JogoDaCopa`.

The approved baseline has three selectable 1x1 arenas, route-first bot movement, item-aware navigation, reliable jump pad routes and a repeatable duel flow.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- Arenas: `Duel Pit V2`, `Relay Foundry V1`, `Crossfire Crucible V1`.
- Rifle hitscan, RMB Plasma Bolt, pickups, jump pads, high-route flow and knockback.
- Bot with route-control movement, combat overlay shooting, item priorities and jump pad commitment.
- Duel state: round index, player/bot score, first to 3, round result and match result.
- Runtime primitive visuals/audio and GUT validation.
- No football, TPS minigames, export, Web/mobile, multiplayer/backend or progression.

## Latest Track

`Track 07 - Match Flow And Duel UX V1`

Delivered:

- Added explicit duel state: `playing`, round win states and `match_over`.
- Added player/bot score, round index, first-to-3 target and winner tracking.
- Made `R` advance to next round after a result and start a fresh match after match over.
- Added pause-menu `Novo duelo` reset.
- Added persistent HUD score, round and result labels.
- Added tests for score progression, duplicate round-end safety, match reset and clean starts across all arenas.

Human smoke should focus on score/result readability, `R` flow, pause/menu reset and no regression in the approved bot/map feel.

## Track History

- Track 01: combat readability polish - approved.
- Track 02: bot tactical movement - approved.
- Track 03: multi-arena tactical context - locally validated.
- Track 04: arena movement flow and bot navigation - approved.
- Track 04B: bot pickup commitment - delivered.
- Track 05: Quake-style route-control bot - approved.
- Track 05B: long jump pad first-try reliability - approved.
- Track 06: arena variety and bot generalization - approved on `2026-06-19`.

## Next Sequence

1. Fabio/tester smoke Track 07.
2. If approved, execute Track 08 - Player Movement Feel Polish V1.
3. Then execute Track 09 - Combat Sandbox Expansion V1.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 34/34, 340 asserts
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/work-plan.md`
4. `docs/mode-contract.md`
5. `docs/validation.md`
6. `docs/bot-route-control.md`
7. `implementation/tracks/track-07-match-flow-duel-ux-v1/current-status.md`
