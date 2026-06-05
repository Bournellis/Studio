# Card Tuning Lab Probe V1

- Date: `2026-06-05`
- Branch: `codex/draxos-roguelike-cardgame/card-tuning-lab-probe-v1`
- Worktree: `D:\Estudio-worktrees\draxos-roguelike-cardgame--codex--card-tuning-lab-probe-v1`
- Purpose: test the lab toolchain with a real but intentionally small card change.

## Probe Change

Changed `arcano_choque` in `data/definitions/slice_catalog.json`:

- Before: cost 1, `2` direct damage.
- After: cost 1, `3` direct damage.

This is not proposed as final balance. It is a controlled signal to check whether the current labs detect card-stat edits at the right layer.

## Before Baseline

| Command | Result |
|---|---|
| `run_battle_lab --mode=gate --pack=track02_battle_core_v1` | PASS: 9 PASS, 3 WARN, 0 FAIL |
| `run_scenarios --mode=gate --pack=track02_core_v1` | PASS: 9 PASS, 3 WARN, 0 FAIL |
| `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1` | PASS |
| `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1` | PASS |

## After Results

| Command | Result | Signal |
|---|---|---|
| `run_battle_lab --mode=gate --pack=track02_battle_core_v1` | FAIL: 8 PASS, 3 WARN, 1 FAIL | Good signal. Battle Lab detected an isolated combat behavior change. |
| `run_scenarios --mode=gate --pack=track02_core_v1` | PASS: 9 PASS, 3 WARN, 0 FAIL | Expected. Macro scenarios do not simulate card play. |
| `run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1` | PASS | Expected. Route pacing simulator stayed unchanged. |
| `run_lab --mode=gate --preset=quick --baseline=track02_quick_v1` | PASS | Expected. Macro route aggregates stayed unchanged. |
| `tools/validate.gd` | FAIL: GUT 128/131, 1379/1382 asserts | Good signal. Unit contracts caught exact card and derived damage assumptions. |

## Battle Lab Delta

The failing battle case was:

- `boss_08_arcano_baseline`

Observed change:

- Before: `cards_played=12`, status PASS.
- After: `cards_played=11`, status FAIL.

The stronger `Choque` let the deterministic policy finish the map 08 boss case using one fewer card. That is exactly the kind of small behavior change the Gameplay Lab should reveal.

Secondary visible signal:

- `boss_22_soberano_signal` stayed WARN, but enemy HP moved from `22` to `20`.

This is useful but not gate-breaking because the case is currently a watch/stress signal.

## Validate Delta

`tools/validate.gd` reached GUT after a one-time headless import in the fresh worktree. It failed three expectations:

- `test_catalog_removes_old_player_cards_and_keeps_enemies`: expected `arcano_choque` amount `2`, got `3`.
- `test_ability_power_updates_spell_values_and_text`: expected ability-power text containing `Causa 6 de dano`, got `Causa 7 de dano`.
- `test_battle_engine_applies_safe_relic_hooks`: expected first spell damage derived from old `Choque` value; the stronger base damage changes the relic-hook result.

These are useful failures. They show that the existing unit suite protects both raw card data and derived combat text/effect behavior.

## Conclusion

The toolchain behaved correctly:

- Battle Lab caught the isolated combat impact.
- Unit tests caught exact and derived card assumptions.
- Scenario Fixtures and AutoRun macro gates stayed green, showing they are correctly scoped to route/economy/deck macro behavior rather than card-level battle math.

Recommendation:

- Do not merge this probe as a final balance change unless the team explicitly accepts `Choque` at 3 base damage.
- If accepted later, recalibrate affected unit expectations and `boss_08_arcano_baseline`; consider whether `boss_22_soberano_signal` should track its enemy HP delta more tightly.
- For future large card passes, run this sequence as the default before/after workflow: Battle Lab first for card-combat impact, then Scenario and AutoRun gates for macro-route safety.
