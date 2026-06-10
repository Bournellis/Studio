# Track 05 - Foundation Hardening & Refactor V1

- Created: `2026-06-10`
- Status: `COMPLETE`
- Branch: `codex/fpsshooter/track05-foundation-hardening-refactor-v1`
- Worktree: `D:\Estudio-worktrees\FpsShooter--codex--track05-foundation-hardening-refactor-v1`

## Goal

Harden `FPS Playground` as a professional growth foundation while preserving accepted gameplay in both current modes:

- `Arena Shooter`
- `Futebol`

This track is a large sequential refactor and documentation pass. It must use separate commits per logical stage and validate between stages.

## Scope

- Documentation index and architecture overview.
- Codebase audit and refactor order.
- Mode, bot, tuning, validation and publication-readiness contracts.
- Validation/tooling hardening.
- Shared runtime primitive helpers.
- Safe layout/rule extraction.
- Bot helper extraction where tests protect behavior.
- Test suite split and helper extraction.
- Closeout status and portfolio updates.

## Non-Goals

- No new gameplay features.
- No weapon expansion.
- No football feature expansion.
- No export/publication.
- No online/multiplayer/backend.
- No Draxos gameplay/economy/progression import.
- No broad feel retuning.

## Baseline

Before Track 05 edits:

- `tools/validate.gd`: passed.
- GUT: `42/42`.
- Asserts: `355`.
- Known warnings: GUT UID/text-path warnings after headless load.
- Fresh worktree import note: initial validation may require one headless editor import for GUT global classes.

## Phase Checklist

- [x] Worktree and Kanban registered.
- [x] Baseline validation run.
- [x] Documentation and contracts.
- [x] Validation/tooling hardening.
- [x] Runtime primitive/tuning helpers.
- [x] Arena/Futebol layout and rule extraction.
- [x] Bot hardening helper extraction.
- [x] Test suite split.
- [x] Closeout docs and portfolio update.

## Delivered

- Added local documentation index, architecture overview, mode contract, bot contract, tuning guide, validation profile guide, publication-readiness checklist and codebase audit.
- Added validation profiles: `full`, `quick`, `structure` and `--list-profiles`.
- Extracted shared runtime primitive creation into `modes/shared/runtime_primitive_factory.gd`.
- Extracted `Duel Pit V2` static layout into `modes/arena/arena_duel_pit_layout_builder.gd`.
- Extracted football pitch/goal/stadium construction into `modes/football/football_field_builder.gd`.
- Extracted arena combat helper math into `gameplay/arena/arena_combat_rules.gd`.
- Extracted football match helper rules into `gameplay/football/football_match_rules.gd`.
- Extracted bot aim and visibility helper logic into `gameplay/bot/bot_aim_model.gd` and `gameplay/bot/bot_visibility_points.gd`.
- Added focused pure helper tests in `tests/unit/test_rule_helpers.gd` while preserving the broad integration regression in `tests/unit/test_bootstrap.gd`.

## Validation

- Final automated validation passed with `51/51` GUT tests and `386` asserts.
- Known warning class remains limited to GUT UID/text-path fallback warnings.

## Acceptance

- `Arena Shooter` behavior preserved.
- `Futebol` behavior preserved.
- Automated validation green after each phase.
- Tests are easier to navigate.
- Documentation is enough for a new agent to find the correct file before editing.
- Mode roots are closer to orchestration and less responsible for low-level construction/rule math.
