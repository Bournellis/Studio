# T01-B01 - Frontend And Loadout UX Tightening

## Status

- Implemented: `2026-04-21`
- Validation: `tools/validate.gd passed`

## Purpose

Make the accepted local frontend feel like the real day-to-day entry surface for Godot development instead of a validation-era shell.

## Why This Thread Is First

The frontend is already the single entry path into `Arena`, `Survival`, and `Boss`, and the automated tests already protect its launch contract.

That makes it the safest high-leverage first thread after the documentation reset.

## Current Baseline

The current baseline already provides:

- one shared frontend for `Arena`, `Survival`, and `Boss`
- explicit mode buttons and launch requests
- a canonical loadout builder button
- saved-loadout persistence and manual restore
- validation coverage for routing copy, start-button state, and launch-context correctness

The current baseline still exposes validation-era language and provisional UX signals such as:

- `AVALIACAO GODOT`
- `Loadout do Slice`
- mode summaries that explicitly talk about `G4`
- save-state messaging that says the selection always opens clean even when a saved loadout exists

## Scope

- rewrite frontend copy so it describes the active local game surfaces rather than the old validation cycle
- rewrite mode copy in `modes/shared/local_mode_catalog.gd` so `Arena`, `Survival`, and `Boss` read as stable local play surfaces instead of `G4` deliveries
- tighten loadout summary and helper text so race, weapon, skills, potions, and selected mode are easier to judge at a glance
- tighten saved-loadout messaging so the manual restore path is explicit and trustworthy
- preserve the current shared launch contract, mode IDs, and parameter defaults

## Non-Goals

- new mode surfaces
- new gameplay systems
- Steam-facing work
- campaign work
- content-package expansion
- changes to the accepted loadout contract

## Public Surface Expectations

- the frontend remains PT-BR player-facing
- `Arena`, `Survival`, and `Boss` keep one shared entry flow
- the start button still reflects the selected mode action label
- manual restore of a saved loadout remains explicit rather than auto-applied on entry unless active docs deliberately change that policy later

## Implementation Notes

- update frontend copy in `modes/frontend/frontend_root.gd`
- update mode-facing copy in `modes/shared/local_mode_catalog.gd`
- extend or update frontend tests so the expected copy matches the new stable wording
- preserve existing launch-context behavior, validation rules, and scene routing

## Validation

- `tools/validate.gd`
- GUT frontend-flow coverage
- local manual smoke of:
  - frontend mode switching
  - canonical loadout selection
  - saved-loadout restore button behavior
  - Arena / Survival / Boss launch from the same frontend session

## Acceptance Criteria

- no validation-era labels remain on the active frontend surface
- mode subtitle, summary, controls hint, and start-button label still change correctly per selected mode
- the player can understand whether they are using a fresh selection or a saved loadout
- launch behavior remains unchanged in correctness even if wording and presentation improve
