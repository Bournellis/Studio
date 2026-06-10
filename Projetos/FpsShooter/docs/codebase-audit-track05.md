# Track 05 Codebase Audit

- Last updated: `2026-06-10`
- Status: `TRACK_05_ACTIVE`

## Summary

The project is healthy for a fast prototype: both modes run, validation is green and behavior is covered by 42 GUT tests. The main risk is not correctness today; it is future growth pressure. Arena, football, bot and tests have accumulated enough responsibility that the next feature wave would be slower and riskier without a foundation pass.

## Baseline

- Validation command: `tools/validate.gd`.
- Baseline before Track 05 edits: `42/42` tests, `355` asserts.
- Known warning class: GUT UID/text-path warnings after headless runs.
- Fresh worktree note: a one-time headless editor import may be needed before GUT global classes are available.

## Main Risks

| Risk | Evidence | Impact | Track 05 Response |
|---|---|---|---|
| Mode roots are too broad | `arena_root.gd` and `football_root.gd` own composition, layout, rules and presentation snapshots. | New maps/modes encourage copy-paste. | Extract shared primitive helpers, mode contract and rule helpers. |
| Bot file is dense | `basic_duel_bot.gd` owns state, visibility, aiming, route scoring, jump and dodge. | Bot upgrades become hard to reason about. | Document bot contract, then extract helpers only behind tests. |
| Tests are monolithic | One `test_bootstrap.gd` covers menu, football, arena, bot, feedback and combat. | Failures are noisy; adding tests increases friction. | Split test suite and add helper file. |
| Tuning is scattered | Constants live across mode roots, bot and player scripts. | Playtest tuning requires code spelunking. | Add tuning guide and centralize safe shared constants where practical. |
| Publication readiness is implicit | Project is editor-first with no readiness checklist. | Future publication work may mix with gameplay changes. | Add publication readiness doc without adding export scope. |

## Safe Refactor Order

1. Documentation and contracts.
2. Validation profile/tooling hardening.
3. Shared runtime primitive/tuning helpers.
4. Arena and football layout builders.
5. Isolated rule helpers for football kicks/score and arena hit/projectile math. Completed through `gameplay/football/football_match_rules.gd` and `gameplay/arena/arena_combat_rules.gd`.
6. Bot helper extraction if behavior remains protected.
7. Test suite split.
8. Status and portfolio closeout.

## Non-Goals

- No gameplay feature additions.
- No visual finalization.
- No authored asset pipeline.
- No online, save, export or backend work.
- No moving `FpsShooter` folder name.
- No Draxos canon/progression/economy import.

## Acceptance

- `Arena Shooter` and `Futebol` behave the same in manual smoke.
- `tools/validate.gd` passes after every phase.
- Test suite is easier to navigate.
- Documentation explains where to work before editing.
- New architecture does not require a heavy base class for simple modes.
