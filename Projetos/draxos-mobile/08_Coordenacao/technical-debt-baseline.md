# Baseline de dívida técnica — DraxosMobile

## Metadata

- status: `living`
- authority: `technical_contract`
- last_verified: `2026-07-16`
- review_when: `a listed file is touched or line-count policy changes`
- supersedes: `informal hotspot lists in historical hardening notes`
- superseded_by: `none`

Counts are exact at `main@756e82eb`; addons and generated/import caches are excluded from line budgets.

## Allowlisted above 1,000 lines

| Lines | File | Existing responsibility |
|---:|---|---|
| 3705 | `tests/client/test_boot_mobile_ui.gd` | integrated boot/client regression |
| 1446 | `ui/battle_stage_2d.gd` | battle presentation root |
| 1436 | `tests/client/test_openworld_mode_dev.gd` | integrated Openworld regression |
| 1363 | `modes/openworld/openworld_integrated_session_bridge.gd` | Openworld/session integration bridge |
| 1326 | `ui/battle_visual_mockup.gd` | visual battle mockup |
| 1279 | `tests/client/test_session_shell.gd` | integrated shell regression |
| 1240 | `dev/battle_lab/battle_lab_screen.gd` | Battle Lab screen |
| 1089 | `modes/boot/ui/mode_shell_overlay_controller.gd` | shell overlay controller |
| 1089 | `online/session_store.gd` | session state/store facade |

## Warnings from 701 to 1,000 lines

| Lines | File |
|---:|---|
| 981 | `modes/openworld/openworld_forest_screen.gd` |
| 978 | `online/supabase_client.gd` |
| 860 | `tools/capture_track15_mobile_ux.gd` |
| 848 | `modes/boot/flows/surface_action_flow.gd` |
| 816 | `modes/boot/surfaces/arena_surface_presenter.gd` |
| 790 | `dev/progression_lab/progression_lab_screen.gd` |

## Decompose on touch

- A file above 1,000 lines cannot grow or receive a new responsibility without extraction or a recorded exception with `review_when`.
- A surgical correction of at most 20 lines is allowed only when it adds no responsibility and includes focused regression evidence.
- Files above 700 lines trigger review for a boundary extraction; this migration does not authorize mass refactoring.
- When a listed file changes, record before/after counts and the responsibility decision in the local card.

