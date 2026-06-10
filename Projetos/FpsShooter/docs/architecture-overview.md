# FPS Playground Architecture Overview

- Last updated: `2026-06-10`
- Status: `TRACK_05_COMPLETE`

## Current Shape

`FPS Playground` is a Godot 4.6.2 PC Windows editor-first project with two playable first-person modes:

- `Arena Shooter`: a local 1x1 arena duel against a bot.
- `Futebol`: a local 1x1 first-person football match against a bot.

The project started as a fast tech probe. Track 05 keeps the accepted gameplay but hardens the structure so future modes, maps and systems can grow without turning each root scene into a large custom application.

## Architecture Layers

| Layer | Local Paths | Owns | Must Not Own |
|---|---|---|---|
| Foundation | `autoloads/`, `modes/shared/`, shared constants/helpers | Input setup, shared mode contracts, primitive runtime helpers, validation support. | Mode-specific scoring, combat or bot decision rules. |
| Gameplay | `gameplay/` | Player controller, combat body, bot behavior, football ball/bot, rule helpers. | HUD layout, scene generation, portfolio docs. |
| Presentation | `presentation/` | HUD, crosshair, overlays, synthetic audio, runtime effects. | Combat decisions, scoring authority, bot route choices. |
| Composition | `modes/` | Mode scene assembly, layout spawning, signal wiring, restart/pause/menu flow. | Reusable low-level math/rules that can be tested separately. |
| Tools | `tools/`, `tests/` | Scene generation, validation profiles, GUT suite and test helpers. | Runtime gameplay behavior outside debug hooks. |

## Mode Runtime Flow

Every playable mode should follow the same rough sequence:

1. Configure world and engine settings.
2. Build static/runtime layout.
3. Spawn player, bot, HUD, feedback and mode-specific actors.
4. Wire signals.
5. Enter an explicit ready/intro/playing state.
6. Build a HUD snapshot every frame or state change.
7. Resolve restart, pause and return-to-menu consistently.

`Arena Shooter` already has strong gameplay authority, but still mixes layout construction, projectile resolution, pickups and HUD snapshot creation. `Futebol` similarly mixes field construction, scoring, kicking and pause/intro flow. Track 05 separates these gradually.

## Target Direction

Track 05 should move toward:

- `modes/*_root.gd` as orchestrators, not giant rule containers.
- Shared primitive creation under `modes/shared/`.
- Small rule helpers under `gameplay/arena/` and `gameplay/football/`.
- Validation profiles that make failures easier to read.
- Tests split by domain instead of one large bootstrap file.

Track 05 first code extraction:

- `modes/shared/runtime_primitive_factory.gd` owns common runtime box collision/mesh/material creation for mode layouts.
- `modes/arena/arena_duel_pit_layout_builder.gd` owns static `Duel Pit V2` geometry, route markers and jump-pad node construction.
- `modes/football/football_field_builder.gd` owns static football pitch, goal, wall and stadium-band construction.
- `gameplay/arena/arena_combat_rules.gd` owns small arena combat calculations that do not need scene authority, such as visual muzzle origin, projectile direction and pickup respawn choice.
- `gameplay/football/football_match_rules.gd` owns football reach checks, kick direction math, player ball contact, goal detection and score/match-end calculation.

Track 05 should not move toward:

- A heavy inheritance framework.
- Data-driven everything before the product shape is stable.
- New gameplay features hidden inside refactor commits.
- Export, online, save, account or backend assumptions.

## Current Large Files

| File | Current Pressure | Preferred Direction |
|---|---|---|
| `modes/arena/arena_root.gd` | Map, pickups, jump pads, projectile resolution, HUD snapshot and round state live together. | Keep as arena authority; extract primitive/layout helpers and isolated rule math. |
| `gameplay/bot/basic_duel_bot.gd` | State machine, route scoring, visibility, aiming, jump and dodge logic live together. | Keep as controller; extract visibility, aim or route helpers only where tests protect behavior. |
| `modes/football/football_root.gd` | Field construction, scoring, input mapping and menu flow live together. | Keep as match authority; extract field builder and match/kick rules. |
| `presentation/hud/*` | HUD construction and state transitions are manually built at runtime. | Preserve runtime construction; make snapshot keys stable and documented. |
| `tests/unit/test_bootstrap.gd` | Covers every domain in one long script. | Split into mode, arena, bot, football and feedback files with shared helpers. |

## Stability Rule

During Track 05, a successful refactor is invisible to the player. If a change alters movement, shots, bot pressure, ball physics, scoring or pause behavior, it must be called out as a bug fix or postponed to a gameplay track.
