# FpsPlayground Technical-Debt Baseline

## Metadata

- status: `active`
- authority: `technical_contract`
- last_verified: `2026-07-16`
- review_when: `a listed file is touched or a GDScript crosses 700 lines`
- supersedes: `duplicated hotspot sections in live planning documents`
- superseded_by: `none`

This baseline blocks debt growth; it does not authorize a mass refactor.

## Exact Baseline

| Path | Lines | Existing responsibility | Review when |
|---|---:|---|---|
| `modes/arena/arena_root.gd` | 1506 | Arena composition, duel state and runtime orchestration | Any functional touch |
| `gameplay/bot/basic_duel_bot.gd` | 1077 | Bot state, movement/aim execution and combat overlay | Any functional touch |
| `tests/unit/test_bootstrap.gd` | 842 | Broad boot, arena and integration regression safety net | New test responsibility |

Counts exclude `addons/` and were measured from committed UTF-8 text on `2026-07-16`.

## Growth Contract

- A file above 1,000 lines cannot grow when touched without extracting responsibility or recording a narrow exception with owner and `review_when`.
- A file above 700 lines emits a warning; new responsibilities belong in focused files with regression coverage.
- A surgical correction of at most 20 lines may touch an allowlisted file only when it adds no responsibility and includes a targeted regression.
- Tests may be moved, but coverage and assertion intent must not be weakened during extraction.
- Gameplay, tuning and human gates cannot be changed as a side effect of debt work.

## Preferred Extraction Boundaries

- `arena_root.gd`: keep orchestration; extract a cohesive runtime responsibility before adding another branch.
- `basic_duel_bot.gd`: keep state integration; extend decision and movement helper boundaries instead of adding another policy layer.
- `test_bootstrap.gd`: place new focused coverage beside `test_rule_helpers.gd` or a new domain-specific suite.
