# FpsPlayground - Current Status

- Last updated: `2026-06-20`
- Project: `FpsPlayground`
- Portfolio status: `P2_IMPLEMENTACAO`
- Active surface: `PC Windows editor-first FPS gameplay lab`
- Active stage: `Post-Track14G Baseline`
- Active stage status: `MERGED_LOCAL`
- Status marker: `FPS_PLAYGROUND_TRACK14G_MERGED_LOCAL_BASELINE`

## Current Truth

`FpsPlayground` owns the FPS arena work split from the former `FpsShooter`. Football/TPS work belongs to `Projetos/JogoDaCopa`.

The approved baseline has three selectable 1x1 arenas, route-first bot movement, item-aware navigation, reliable jump pad routes, repeatable duel flow, Plasma Impact Blast V1, Track 10 weapon-role tuning, local duel telemetry, telemetry readout tooling and the pre-Track-08 player movement feel preserved.

Track 12 telemetry/readout is approved. Track 13 updated the live docs and added a future roadmap for maps, weapons, buffs, pickups, bot evolution and telemetry-first tuning. Track 14A started the hardening/refactor safety sequence. Track 14B extracted the HUD snapshot/status builder from `arena_root.gd`. Track 14C extracted combat telemetry payload builders and pure Plasma blast calculation into `arena_combat_pipeline.gd`. Track 14D extracted pickup and jump pad rules into `arena_pickup_jump_pad_rules.gd`. Track 14E extracted bot decision scoring into `bot_decision_model.gd`. Track 14F closed the hardening sequence with small dead-wrapper cleanup and code-size metrics. Track 14G added surgical expansion boundaries for bot movement execution, projectile runtime, HUD feedback state and telemetry events. No gameplay values changed in Track 13, 14A, 14B, 14C, 14D, 14E, 14F or 14G.

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

`Track 14G - Surgical Expansion Hardening V1`

Delivered:

- Added `BotMovementExecutor` for pure bot movement execution helpers.
- Added `ArenaProjectileRuntime` for player Plasma bolt creation, stepping and cleanup.
- Added `ArenaHudFeedbackState` for transient HUD timers, event messages and crosshair feedback view.
- Added `ArenaTelemetryEvents` facade for context assembly and event emission.
- Rebaselined hotspot metrics: `arena_root.gd` 1487 lines, `basic_duel_bot.gd` 1077 lines, `arena_hud.gd` 535 lines.
- Keeps gameplay, movement feel, jump pad force, maps, weapon values, pickups, aim difficulty, bot behavior and telemetry schema unchanged.

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
- Track 14A: refactor safety net and code health baseline - local validated on `2026-06-20`.
- Track 14B: arena root boundary - local validated on `2026-06-20`.
- Track 14C: combat pipeline extraction - merged locally on `2026-06-20`.
- Track 14D: pickups and jump pads extraction - merged locally on `2026-06-20`.
- Track 14E: bot decision boundary - approved by Fabio/tester on `2026-06-20`.
- Track 14F: cleanup and documentation - merged locally on `2026-06-20`.
- Track 14G: surgical expansion hardening - merged locally on `2026-06-20`.

## Next Sequence

1. Execute `Multi-Arena Balance Baseline V1`.
2. Choose arsenal/buff contracts, tuning or bot intelligence only after the multi-arena readout.
3. Keep further hardening/refactor scoped to implementation hotspots only when it protects the next gameplay track.

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path . --script res://tools/validate.gd
# PASS, GUT 66/66, 593 asserts
```

Manual smoke lives in `docs/validation.md`.

## Read Next

1. `AGENTS.md`
2. `docs/documentation-index.md`
3. `docs/work-plan.md`
4. `docs/refactor-hardening-roadmap.md`
5. `docs/arena-shooter-future-roadmap.md`
6. `docs/mode-contract.md`
7. `docs/validation.md`
8. `docs/bot-route-control.md`
9. `docs/telemetry.md`
10. `docs/telemetry-readout.md`
11. `docs/balance-baseline.md`
12. `implementation/tracks/track-14g-surgical-expansion-hardening-v1/current-status.md`
