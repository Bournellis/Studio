# FpsPlayground - Current Status

- Last updated: `2026-06-19`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 11 - Complete Telemetry V1`
- Active stage status: `READY_FOR_HUMAN_SMOKE`
- Status marker: `FPS_PLAYGROUND_TRACK11_COMPLETE_TELEMETRY_READY_FOR_SMOKE`

## Current Truth

`FpsPlayground` owns the FPS arena work split from the former `FpsShooter`. Football/TPS work belongs to `Projetos/JogoDaCopa`.

The approved baseline has three selectable 1x1 arenas, route-first bot movement, item-aware navigation, reliable jump pad routes, repeatable duel flow, Plasma Impact Blast V1, Track 10 weapon-role tuning, local duel telemetry and the pre-Track-08 player movement feel preserved.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- Arenas: `Duel Pit V2`, `Relay Foundry V1`, `Crossfire Crucible V1`.
- Rifle hitscan, RMB Plasma Bolt with world-impact blast, pickups, jump pads, high-route flow and knockback.
- Bot with route-control movement, combat overlay shooting, item priorities and jump pad commitment.
- Duel state: round index, player/bot score, first to 3, round result and match result.
- Local telemetry: JSONL event stream and compact summary for rounds, combat, Plasma, pickups, bot state, movement samples and jump pad landings.
- Runtime primitive visuals/audio and GUT validation.
- No football, TPS minigames, export, Web/mobile, multiplayer/backend or progression.

## Latest Track

`Track 11 - Complete Telemetry V1`

Delivered:

- Added local-only duel telemetry with `events.jsonl` and `summary.json`.
- Instrumented session, arena setup, round lifecycle, shots, hits, misses, damage, knockback, Plasma lifecycle, pickups, bot state, movement samples and jump pad landings.
- Added automated schema, summary, local-file and Track 10 gameplay guardrail tests.
- Kept player movement, sensitivity, jump pads, arena geometry, bot route-control, pickup rules and weapon values unchanged.

Human smoke should focus on confirming telemetry files are created, readable and useful for balance/bot/map decisions without any gameplay feel regression.

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
- Track 11: complete local telemetry - ready for smoke.

## Next Sequence

1. Smoke Track 11 - Complete Telemetry V1 in editor.
2. Preserve current player movement feel and use telemetry only as evidence for future tuning.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 47/47, 440 asserts
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/work-plan.md`
4. `docs/mode-contract.md`
5. `docs/validation.md`
6. `docs/bot-route-control.md`
7. `docs/telemetry.md`
8. `implementation/tracks/track-11-complete-telemetry-v1/current-status.md`
