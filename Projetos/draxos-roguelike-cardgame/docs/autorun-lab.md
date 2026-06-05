# AutoRun Lab

- Last Updated: `2026-06-05`
- Status: `LAB_DIFF_REPORTER_V1_READY`
- Scope: macro-route gameplay testing foundation, explicit scenario fixtures, isolated BattleEngine gameplay lab and before/after lab diff reporting

## Purpose

AutoRun Lab is the first layer of the gameplay test toolchain. It expands the existing Run Lab from one class/seed sweep into a reusable headless framework for run matrices, macro policies, aggregate reports, official gate baselines and human-readable scorecards.

It still uses macro-route simulation through `tools/route_pacing_simulator.gd`. It does not play battles turn by turn and does not replace human playtest. It prepares the contracts that future Gameplay Lab, Scenario Lab and Replay Lab should reuse.

Scenario Fixtures V1 is the second layer of this toolchain. It runs small named scenarios from JSON packs, evaluates explicit expectations as `PASS`, `WARN`, or `FAIL`, and keeps stress signals visible without turning expected stress warnings into hard regressions.

Gameplay Lab V1 is the third layer. It runs isolated real battles through `BattleEngine`, using deterministic policies that only submit legal actions exposed by the engine. It targets combat regressions, keywords, hand/deck behavior, encounter modes, field effects, boss hooks and basic enemy AI signals without changing gameplay content or replacing human playtest.

Lab Diff Reporter V1 is the fourth layer. It compares before/after outputs from AutoRun Lab, Scenario Fixtures and Gameplay Lab, then turns status changes, new failures, removed records and metric deltas into JSON, CSV and Markdown reports. It is built for future large card changes where the important question is not only "did the gate pass?", but "what moved, by how much, and where should a human inspect next?".

## Entry Point

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --preset=smoke --compare-golden --require-golden
```

Official gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --mode=gate --preset=smoke --baseline=track02_smoke_v1

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --mode=gate --preset=quick --baseline=track02_quick_v1
```

`--gate` is a shortcut for `--mode=gate`.

Scenario fixture gate:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_scenarios.gd -- --mode=gate --pack=track02_core_v1
```

Gameplay battle gate:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_battle_lab.gd -- --mode=gate --pack=track02_battle_core_v1
```

Lab diff gate:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/compare_lab_reports.gd -- --before=user://battle_lab/before_cards --after=user://battle_lab/after_cards --type=battle --out=user://lab_diff/card_change_probe --mode=gate
```

## Presets

| Preset | Cases | Purpose |
|---|---:|---|
| `smoke` | 3 classes x 1 seed x `baseline` | Fast regression and golden parity. |
| `golden` | 3 classes x 1 seed x `baseline` | Explicit approved Track 02 comparison. |
| `quick` | 3 classes x 10 seeds x `baseline` | Small balance/tuning read. |
| `balance` | 3 classes x 100 seeds x `baseline,defensive,no_shop` | Broader macro tuning sweep. |
| `stress` | 3 classes x 1000 seeds x macro policy set | Heavy stress and distribution scan. |

Useful overrides:

```text
--classes=arcano,invocador,necromante
--seed-start=20260518
--seed-count=100
--seeds=20260518,20260519
--policies=baseline,defensive,no_shop
--out=user://run_lab/track02_balance
--compare-golden
--require-golden
--compare-baseline
--save-baseline
--baseline=track02_smoke_v1
--mode=explore|validate|baseline|compare
--mode=gate
--gate
--stop-on-failure
--no-timeline
--scorecard
--no-scorecard
```

## Macro Policies

| Policy | Reward Policy | Shop Policy | Intent |
|---|---|---|---|
| `baseline` | `baseline` | `baseline_recovery` | Preserve approved Track 02 metrics. |
| `greedy` / `greedy_power` | `rarity_first` | `power_greedy` | Stress high-power reward/shop behavior. |
| `defensive` | `defensive` | `defensive` | Stress recovery and survival leaning. |
| `thin_deck` | `thin_deck` | `thin_deck` | Stress removal/upgrade-heavy route shape. |
| `big_deck` | `rarity_first` | `big_deck` | Stress deck growth pressure. |
| `no_shop` | `baseline` | `none` | Measure route without shop intervention. |
| `high_shop` | `rarity_first` | `high_shop` | Stress aggressive shop spending. |

## Outputs

The tool writes all outputs under `--out`:

- `run_lab_metrics.json`: compatibility JSON with `runs`, `summary`, and optional comparisons.
- `run_lab_metrics.csv`: per-run CSV.
- `run_lab_detailed.json`: full records with case metadata, result, timeline, warnings and tags.
- `run_lab_summary.json`: aggregate summary.
- `run_lab_summary.csv`: aggregate rows for all, class and policy groups.
- `run_lab_summary.md`: human-readable report.
- `run_lab_scorecard.json`: structured human tuning scorecard.
- `run_lab_scorecard.md`: readable scorecard with overall, class and policy matrices.
- `run_lab_baseline.json`: optional saved statistical baseline when using `--save-baseline` or `--mode=baseline`.

## Scenario Fixtures V1

Scenario fixture packs live under `data/lab/scenarios/`. The first official pack is `track02_core_v1`.

Useful commands:

```text
--pack=track02_core_v1
--scenario=map_08_low_hp_checkpoint_baseline
--tags=route,economy
--out=user://scenario_lab/track02_core_v1
--mode=explore|gate
--gate
--stop-on-failure
```

Scenario outputs:

- `scenario_results.json`: complete records with scenario, result, timeline, expectations, warnings, tags and status.
- `scenario_results.csv`: one row per scenario.
- `scenario_summary.json`: aggregate status counts by tag, class and policy.
- `scenario_summary.md`: human-readable report with status matrix, checkpoints, warnings and failures.
- `scenario_gate.md`: short regression view for gate runs.

Expectation status:

- `PASS`: required and watch expectations passed.
- `WARN`: required expectations passed, but one or more watch expectations raised a tuning signal.
- `FAIL`: at least one required expectation failed. In `--mode=gate`, this exits with code `1`.

`WARN` does not fail the gate. Use it for expected stress cases such as `no_shop`, `big_deck`, and `thin_deck`.

`track02_core_v1` starts with 12 scenarios covering:

- baseline route completion for Arcano, Invocador and Necromante;
- map 08 low-HP and defensive recovery checkpoints;
- baseline shop recovery budget and no-shop stress;
- baseline, big-deck and thin-deck deck-size bands;
- late-route fire pressure and map 29 boss finish.

## Gameplay Lab V1

Battle fixture packs live under `data/lab/battles/`. The first official pack is `track02_battle_core_v1`.

Useful commands:

```text
--pack=track02_battle_core_v1
--case=boss_08_arcano_baseline
--tags=keyword,boss
--policy=baseline_legal
--out=user://battle_lab/track02_battle_core_v1
--mode=explore|gate
--gate
--stop-on-failure
```

Policies:

| Policy | Intent |
|---|---|
| `baseline_legal` | Balanced deterministic legal-action policy. |
| `aggressive_legal` | Prioritizes lethal, enemy hero pressure and high-threat removal. |
| `defensive_legal` | Prioritizes creatures, ally buffs, high-threat removal and avoids sacrifice while slots are open. |
| `end_turn_only` | Control/stress signal that never plays cards and only advances cycles. |

Battle outputs:

- `battle_results.json`: complete records with case, result, timeline, expectations, warnings, tags and status.
- `battle_results.csv`: one row per case.
- `battle_summary.json`: aggregate status counts by tag, class, policy and encounter.
- `battle_summary.md`: human-readable report with status matrix, critical checkpoints, warnings and failures.
- `battle_gate.md`: short regression view for gate runs.

`track02_battle_core_v1` starts with 12 isolated battle cases covering:

- tutorial baseline battles for Arcano, Invocador and Necromante;
- initial duel baseline;
- map 08 boss baseline and end-turn-only stress signal;
- survive and defense encounter-mode signals;
- Ar and Fogo field-effect signals;
- map 22 boss signal and map 29 final boss stress signal.

The current gate is explicit and is not called by `tools/validate.gd`. Current calibrated result: 9 PASS, 3 WARN and 0 FAIL. The WARN rows are intentional stress/signal cases, and `--mode=gate` fails only on `FAIL`.

## Lab Diff Reporter V1

`tools/compare_lab_reports.gd` compares two existing lab output directories. It does not run simulations itself and does not mutate gameplay data.

Supported report pairs:

- `battle`: `battle_results.json`
- `scenario`: `scenario_results.json`
- `run_lab`: `run_lab_detailed.json`, falling back to `run_lab_metrics.json`

Useful commands:

```text
--before=user://battle_lab/before_cards
--after=user://battle_lab/after_cards
--type=auto|battle|scenario|run_lab
--out=user://lab_diff/card_change_probe
--mode=explore|gate
--gate
--numeric-threshold=0
```

Diff outputs:

- `lab_diff.json`: complete structured diff.
- `lab_diff.csv`: one row per status or metric change.
- `lab_diff.md`: human report with status and metric matrices.
- `lab_diff_gate.md`: short regression view.

Gate behavior:

- New `FAIL` records fail `--mode=gate`.
- Removed records fail `--mode=gate`, because the compared matrix stopped covering a previous case.
- New `WARN` records and metric changes are reported but do not fail the gate.
- Identical deterministic before/after outputs should produce zero changes and pass the gate.

## Result Schema

Each detailed record contains:

- `schema_version`
- `tool`
- `case` or `scenario`
- `result`
- `timeline`
- `warnings`
- `tags`

The current macro-route `simulation_mode` is `macro_route_v1`. Gameplay Lab uses `battle_engine_v1`. Future bot and replay tools should preserve the same outer schema and add more detailed timelines instead of creating unrelated formats.

## Baseline Strategy

AutoRun Lab has two baseline types:

- Exact golden metrics through `tools/run_lab_golden_metrics.gd`.
- Official gate baselines under `data/lab/baselines/`, currently `track02_smoke_v1` and `track02_quick_v1`.
- Ad hoc statistical baseline comparison through `tools/lab/lab_baseline_store.gd`.

Use exact golden metrics for small approved class/seed regressions. Use official gate baselines for explicit regression checks before tuning or risky gameplay edits. Use ad hoc statistical baselines for larger exploratory matrices where exact numbers should vary but aggregate ranges should remain healthy.

## Gate Pack V1

Gate Pack V1 turns AutoRun Lab into an explicit regression contract:

- `track02_smoke_v1`: fast 3-case gate for Arcano, Invocador and Necromante on seed `20260518` with baseline policy.
- `track02_quick_v1`: 30-case gate for the three classes across seeds `20260518..20260527` with baseline policy.
- `--mode=gate`: resolves the requested official baseline, compares aggregate and group fields, and exits with code `1` on mismatch.
- Scorecards are written by default and summarize survival, route, economy, deck size, class rows, policy rows, risk maps and gate differences.

Do not wire gate mode into `tools/validate.gd` until it has survived a few tuning cycles. For now it is an explicit command operators run before and after balance changes.

## Future Phases

1. Build a Card Impact Pack V1 with targeted battle/scenario fixtures for starter cards, reward cards and important card families.
2. Use AutoRun, Scenario Fixtures, Gameplay Lab and Lab Diff Reporter together during the next card-change batch.
3. Decide which repeated WARN signals should become baseline PASS after real use.
4. Replay Lab: record human or bot decisions and replay them across builds.
5. Dashboard: read the JSON/CSV/Markdown outputs and compare historical runs visually.
