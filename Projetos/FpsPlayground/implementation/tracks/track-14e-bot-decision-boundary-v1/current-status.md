# Track 14E - Bot Decision Boundary V1

- Status: `LOCAL_VALIDATED`
- Date: `2026-06-20`
- Branch: `codex/fpsplayground/track14e-bot-decision-boundary-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track14e-bot-decision-boundary-v1`

## Goal

Extract a bot decision/scoring boundary from `gameplay/bot/basic_duel_bot.gd` without changing route-first movement, combat overlay, aim difficulty, movement feel, jump pad force, maps, weapon values or pickup behavior.

## Delivered

- Added `gameplay/bot/bot_decision_model.gd`.
- Moved item priority, map route priority, tactical point scoring, route labels, route repetition penalty and route-hold checks behind helper functions.
- Kept `basic_duel_bot.gd` responsible for movement execution, physics, aim execution, combat overlay and Godot node state.
- Added direct unit coverage for health priority, overcharge priority, arena-agnostic scoring and route commitment.

## Validation

```text
PASS tools/validate.gd -- --profile=quick, GUT 62/62, 564 asserts
PASS tools/validate.gd, GUT 62/62, 564 asserts
```

## Next

After Fabio approves/merges Track 14E, execute `Track 14F - Cleanup And Documentation V1`.
