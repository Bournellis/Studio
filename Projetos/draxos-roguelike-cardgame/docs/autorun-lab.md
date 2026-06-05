# AutoRun Lab

- Last Updated: `2026-06-05`
- Status: `AUTORUN_LAB_V1_READY`
- Scope: macro-route gameplay testing foundation

## Purpose

AutoRun Lab is the first layer of the gameplay test toolchain. It expands the existing Run Lab from one class/seed sweep into a reusable headless framework for run matrices, macro policies, aggregate reports and statistical baseline comparison.

It still uses macro-route simulation through `tools/route_pacing_simulator.gd`. It does not play battles turn by turn and does not replace human playtest. It prepares the contracts that future Gameplay Lab, Scenario Lab and Replay Lab should reuse.

## Entry Point

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --preset=smoke --compare-golden --require-golden
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
--mode=explore|validate|baseline|compare
--stop-on-failure
--no-timeline
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
- `run_lab_baseline.json`: optional saved statistical baseline when using `--save-baseline` or `--mode=baseline`.

## Result Schema

Each detailed record contains:

- `schema_version`
- `tool`
- `case`
- `result`
- `timeline`
- `warnings`
- `tags`

The current `simulation_mode` is `macro_route_v1`. Future bot and replay tools should preserve the same outer schema and add more detailed timelines instead of creating unrelated formats.

## Baseline Strategy

AutoRun Lab has two baseline types:

- Exact golden metrics through `tools/run_lab_golden_metrics.gd`.
- Statistical baseline comparison through `tools/lab/lab_baseline_store.gd`.

Use exact golden metrics for small approved class/seed regressions. Use statistical baselines for larger matrices where exact numbers should vary but aggregate ranges should remain healthy.

## Future Phases

1. Gameplay Lab: play battles with `BattleEngine` using legal-action policies.
2. Scenario Lab: fuzz isolated encounters, bosses, field effects and keywords.
3. Replay Lab: record human or bot decisions and replay them across builds.
4. Dashboard: read the JSON/CSV/Markdown outputs and compare historical runs visually.
