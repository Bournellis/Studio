# FpsPlayground - Current Status

- Last updated: `2026-06-19`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 10 - Combat Balance And Weapon Roles V1`
- Active stage status: `READY_FOR_HUMAN_SMOKE`
- Status marker: `FPS_PLAYGROUND_TRACK10_COMBAT_BALANCE_READY_FOR_SMOKE`

## Current Truth

`FpsPlayground` owns the FPS arena work split from the former `FpsShooter`. Football/TPS work belongs to `Projetos/JogoDaCopa`.

The approved baseline has three selectable 1x1 arenas, route-first bot movement, item-aware navigation, reliable jump pad routes, repeatable duel flow, Plasma Impact Blast V1, Track 10 weapon-role tuning and the pre-Track-08 player movement feel preserved.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- Arenas: `Duel Pit V2`, `Relay Foundry V1`, `Crossfire Crucible V1`.
- Rifle hitscan, RMB Plasma Bolt with world-impact blast, pickups, jump pads, high-route flow and knockback.
- Bot with route-control movement, combat overlay shooting, item priorities and jump pad commitment.
- Duel state: round index, player/bot score, first to 3, round result and match result.
- Runtime primitive visuals/audio and GUT validation.
- No football, TPS minigames, export, Web/mobile, multiplayer/backend or progression.

## Latest Track

`Track 10 - Combat Balance And Weapon Roles V1`

Delivered:

- Tuned direct Plasma to `24` damage so it is a committed high-impact shot, not a weaker alternate fire.
- Tuned Plasma Blast to `46%` max and `22%` min damage fraction so splash remains pressure, not the best default shot.
- Added weapon-role helpers and automated contracts for rifle DPS, Plasma commitment, blast value, overcharge and readable bot pressure.
- Kept player movement, sensitivity, jump pads, arena geometry, bot route-control and pickup behavior unchanged.

Human smoke should focus on rifle precision, direct Plasma commitment, Plasma Blast pressure value, overcharge value and no regression in the approved movement/bot/map feel.

Track 08 movement feel was tested as an isolated branch and discarded before merge. Keep the current player movement feel for now.

## Track History

- Track 01: combat readability polish - approved.
- Track 02: bot tactical movement - approved.
- Track 03: multi-arena tactical context - locally validated.
- Track 04: arena movement flow and bot navigation - approved.
- Track 04B: bot pickup commitment - delivered.
- Track 05: Quake-style route-control bot - approved.
- Track 05B: long jump pad first-try reliability - approved.
- Track 06: arena variety and bot generalization - approved on `2026-06-19`.
- Track 07: match flow and duel UX - ready for smoke.
- Track 08: player movement feel experiment - discarded before merge on `2026-06-19`; current feel preserved.
- Track 09: combat sandbox expansion - ready for smoke.
- Track 10: combat balance and weapon roles - ready for smoke.

## Next Sequence

1. Preserve current player movement feel.
2. Smoke Track 10 - Combat Balance And Weapon Roles V1 in editor.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 43/43, 396 asserts
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/work-plan.md`
4. `docs/mode-contract.md`
5. `docs/validation.md`
6. `docs/bot-route-control.md`
7. `implementation/tracks/track-10-combat-balance-weapon-roles-v1/current-status.md`
