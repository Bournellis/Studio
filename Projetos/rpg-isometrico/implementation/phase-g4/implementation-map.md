# Phase G4 Implementation Map

This file summarizes the intended stable surface for the next bounded Godot phase.

## Target Surface

- frontend routing for multiple local modes
- shared launch-context contract with mode-specific parameters
- shared composition seams across playable modes
- Arena retained as the combat validation surface
- Survival playable baseline
- Boss playable baseline
- one shared combat-shell HUD family across Arena, Survival, and Boss
- shared results-return contract across solo modes
- validation and smoke coverage for the multi-mode local base

## Current Delivered Foundation

- explicit frontend mode routing for `Arena`, `Survival`, and `Boss`
- typed launch requests that carry mode identity, loadout, and sanitized mode parameters
- Arena preserved on the accepted G3 runtime baseline while consuming the shared launch contract
- playable `modes/survival/` baseline with troll runtime, spawn control, wave/rest loop, shared combat shell reuse, and shared result return
- playable `modes/boss/` baseline with Boss Troll runtime, three phases, authored attacks, shared combat shell reuse, and shared result return
- shared shell-snapshot presentation contract now consumed by `Arena`, `Survival`, and `Boss` through the same `CombatHud`
- structured result sections now keep `Arena`, `Survival`, and `Boss` aligned under the same `ResultOverlay`
- automated regression coverage for frontend routing, launch context, Arena regression, Survival boot/wave behavior, Boss boot, Boss phase thresholds, Boss result return, and shared presentation parity
- frontend mode copy plus launch-default regressions now explicitly cover all three local modes from the shared frontend surface
- sequential launch-context consumption now has explicit regression coverage against stale mode-parameter leakage across re-entry
- `docs/g4-shared-mode-foundation-smoke.md` now acts as the local multi-mode playtest gate for routing, shell readability, result return, and re-entry
- checkpoint handoff notes now package the multi-mode base for the next planning decision without reopening mode-foundation questions

## Intended Runtime Surface

- `modes/frontend/` expands from single-flow loadout entry into explicit local mode routing
- `modes/arena/` remains the reference local combat surface
- `modes/survival/` becomes the local wave-based PvE mode surface
- `modes/boss/` becomes the local boss-encounter surface
- `autoloads/launch_context.gd` carries selected loadout plus mode-specific launch parameters
- `presentation/hud/` preserves one shared combat-shell family with mode-specific modules driven by a shared shell snapshot contract
- `presentation/results/` preserves shared return flow and structured mode-specific summaries inside one overlay family
- `tools/validate.gd` now anchors multi-mode local regression coverage and points manual follow-up to the G4 smoke gate

## Canon Alignment Notes

- preserve the canonical loadout contract
- preserve fixed isometric camera identity
- keep gameplay rules outside presentation
- keep online and Steam seams deferred
- use shared canon first and Unity legacy only as consultation evidence when needed
