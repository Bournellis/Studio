# Track 05 - Foundation Hardening & Refactor V1

- Created: `2026-06-10`
- Status: `ACTIVE`
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
- [ ] Documentation and contracts.
- [ ] Validation/tooling hardening.
- [ ] Runtime primitive/tuning helpers.
- [ ] Arena/Futebol layout and rule extraction.
- [ ] Bot hardening helper extraction.
- [ ] Test suite split.
- [ ] Closeout docs and portfolio update.

## Acceptance

- `Arena Shooter` behavior preserved.
- `Futebol` behavior preserved.
- Automated validation green after each phase.
- Tests are easier to navigate.
- Documentation is enough for a new agent to find the correct file before editing.
- Mode roots are closer to orchestration and less responsible for low-level construction/rule math.
