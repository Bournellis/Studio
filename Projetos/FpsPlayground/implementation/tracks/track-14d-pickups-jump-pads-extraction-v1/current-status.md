# Track 14D - Pickups And Jump Pads Extraction V1

- Status: `MERGED_LOCAL`
- Date: `2026-06-20`
- Branch: `codex/fpsplayground/track14d-pickups-jump-pads-extraction-v1`
- Worktree: `D:\Estudio-worktrees\FpsPlayground--codex--track14d-pickups-jump-pads-extraction-v1`

## Goal

Extract pickup and jump pad runtime helper boundaries from `modes/arena/arena_root.gd` without changing approved pickup behavior, jump pad force, map geometry, movement feel, bot route commitment or telemetry fields.

## Delivered

- Added `modes/arena/arena_pickup_jump_pad_rules.gd`.
- Moved pickup state, respawn ticking, collection telemetry payload and respawn duration routing behind helper functions.
- Moved jump pad cooldown ticking, trigger checks, launch vector math and telemetry payload helpers behind helper functions.
- Added direct unit coverage for pickup respawn and approved jump pad force contracts.
- Preserved movement feel, jump pad force, maps, pickups, bot behavior and weapon values.

## Validation

```text
PASS git diff --check
PASS tools/validate.gd -- --profile=quick, GUT 59/59, 552 asserts
PASS tools/validate.gd, GUT 59/59, 552 asserts
PASS tools/check_doc_drift.ps1
```

## Next

Execute `Track 14E - Bot Decision Boundary V1`.
