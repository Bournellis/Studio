# FpsPlayground - Current Status

- Last updated: `2026-06-19`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Track 13 - Documentation Rebaseline And Future Roadmap V1`
- Active stage status: `COMPLETE`
- Status marker: `FPS_PLAYGROUND_TRACK13_DOCS_REBASELINE_FUTURE_ROADMAP_COMPLETE`

## Current Truth

`FpsPlayground` owns the FPS arena work split from the former `FpsShooter`. Football/TPS work belongs to `Projetos/JogoDaCopa`.

The approved baseline has three selectable 1x1 arenas, route-first bot movement, item-aware navigation, reliable jump pad routes, repeatable duel flow, Plasma Impact Blast V1, Track 10 weapon-role tuning, local duel telemetry, telemetry readout tooling and the pre-Track-08 player movement feel preserved.

Track 12 telemetry/readout is approved. Track 13 updated the live docs and added a future roadmap for maps, weapons, buffs, pickups, bot evolution and telemetry-first tuning. No gameplay values changed in Track 13.

## Current Scope

- PC Windows editor-first.
- Main menu with `Arena Shooter`.
- Arenas: `Duel Pit V2`, `Relay Foundry V1`, `Crossfire Crucible V1`.
- Rifle hitscan, RMB Plasma Bolt with world-impact blast, pickups, jump pads, high-route flow and knockback.
- Bot with route-control movement, combat overlay shooting, item priorities and jump pad commitment.
- Duel state: round index, player/bot score, first to 3, round result and match result.
- Local telemetry: JSONL event stream, compact summary and local readout for rounds, combat, Plasma, pickups, bot state, movement samples and jump pad landings.
- Runtime primitive visuals/audio and GUT validation.
- No football, TPS minigames, export, Web/mobile, multiplayer/backend or progression.

## Latest Track

`Track 13 - Documentation Rebaseline And Future Roadmap V1`

Delivered:

- Promoted Track 12 telemetry readout from smoke-pending to approved in live docs.
- Updated the project README, documentation index, work plan, architecture overview, tuning guide, telemetry readout and balance baseline.
- Added `docs/arena-shooter-future-roadmap.md` as the near-term expansion compass for maps, weapons, buffs, pickups, bot and telemetry.
- Added a Track 13 record under `implementation/tracks/`.
- Updated studio snapshots for the observable status change.

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
- Track 07: match flow and duel UX - implemented and folded into the approved baseline.
- Track 08: player movement feel experiment - discarded before merge on `2026-06-19`; current feel preserved.
- Track 09: combat sandbox expansion - implemented and folded into the approved baseline.
- Track 10: combat balance and weapon roles - implemented and folded into the approved baseline.
- Track 11: complete local telemetry - approved on `2026-06-19`.
- Track 12: telemetry readout and balance baseline - approved on `2026-06-19`.
- Track 13: documentation rebaseline and future roadmap - complete on `2026-06-19`.

## Next Sequence

1. Review `docs/arena-shooter-future-roadmap.md`.
2. Prefer `Track 14 - Multi-Arena Balance Baseline V1` before gameplay tuning, unless Fabio explicitly chooses an arsenal/buff contract track first.
3. Preserve current movement, jump pads, maps and bot route-control by default until a track explicitly targets one of them.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . -s res://tools/validate.gd
# PASS, GUT 53/53, 496 asserts
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/work-plan.md`
4. `docs/arena-shooter-future-roadmap.md`
5. `docs/mode-contract.md`
6. `docs/validation.md`
7. `docs/bot-route-control.md`
8. `docs/telemetry.md`
9. `docs/telemetry-readout.md`
10. `docs/balance-baseline.md`
11. `implementation/tracks/track-13-documentation-rebaseline-future-roadmap-v1/current-status.md`
