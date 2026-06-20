# Track 14C - Combat Pipeline Extraction V1

- Status: `LOCAL_VALIDATED`
- Date: `2026-06-20`
- Branch: `codex/fpsplayground/track14c-combat-pipeline-extraction-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track14c-combat-pipeline-extraction-v1`

## Goal

Extract a small combat pipeline boundary from `modes/arena/arena_root.gd` without changing weapon roles, telemetry fields or gameplay values.

## Delivered

- Added `modes/arena/arena_combat_pipeline.gd`.
- Moved rifle, Plasma, Plasma blast and bot shot telemetry payload construction behind helper functions.
- Moved pure Plasma blast damage/falloff/knockback calculation behind the helper.
- Added helper tests for payload contracts, overcharge epsilon and blast math.
- Preserved movement, jump pads, maps, pickups, bot behavior and Track 10 weapon values.

## Validation

```text
PASS git diff --check
PASS tools/validate.gd -- --profile=quick, GUT 57/57, 525 asserts
PASS tools/validate.gd, GUT 57/57, 525 asserts
PASS tools/check_doc_drift.ps1
```

## Next

After Fabio approves/merges Track 14C, execute `Track 14D - Pickups And Jump Pads Extraction V1`.
