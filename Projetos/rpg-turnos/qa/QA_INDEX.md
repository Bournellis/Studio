# QA Index - RPG Turnos

## Metadata

- status: `active`
- authority: `technical_contract`
- last_verified: `2026-07-16`
- review_when: `a validator, critical journey or supported runtime changes`
- supersedes: `implicit test routing through tools/validate.gd only`
- superseded_by: `none`

`qa_manifest.json` is the machine authority for commands and timeouts. This file explains coverage and does not authorize work while the project is paused.

## Runners

- runner_id: `rpg_turnos_fast_contracts`
  - Category: `fast`; tier: `QA`; lane: `godot`.
  - Runs the complete GUT suite directly, without catalog/scene generation or the runtime contract wrapper.
  - Local headless execution only; no remote, publication or generated evidence bundle.

- runner_id: `rpg_turnos_runtime_full`
  - Category: `regression`; tier: `Runtime`; lane: `godot`.
  - Runs `res://tools/validate.gd`, including official catalog generation, scene presence, contract checks and all GUT tests.
  - Tracked output must be deterministic. Any Git change after a run is `VALIDATOR_SIDE_EFFECT`.

## Critical Journey

- capability_id: `boot_and_new_game`
  - Status: `covered`; runners: fast + runtime.

- capability_id: `class_selection_and_persistence`
  - Status: `covered`; runners: fast + runtime.

- capability_id: `deck_setup_contract`
  - Status: `covered`; runner: runtime.

- capability_id: `world_exploration_and_encounters`
  - Status: `covered`; runner: runtime.

- capability_id: `c1_battle_modes`
  - Status: `covered`; runners: fast + runtime.

- capability_id: `three_class_baseline`
  - Status: `covered`; runners: fast + runtime.

- capability_id: `save_v1_to_v2_migration`
  - Status: `covered`; runners: fast + runtime.

- capability_id: `human_playability`
  - Status: `manual`; evidence: `../docs/first-playable-slice-smoke.md`.
  - The P20 integrity repair has not received a new human playability verdict.

## Execution Guardrails

- FastSuite requires an explicit measured baseline before it can gate closure.
- Runtime is executed only when RPG Turnos is selected explicitly while paused.
- Godot/GUT ignored caches are allowed; tracked scene, resource or source changes are not.
- Human playability, balance, visual quality, resume and publication remain outside automation.
