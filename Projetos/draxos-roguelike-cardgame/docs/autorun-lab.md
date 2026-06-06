# AutoRun Lab

- Last Updated: `2026-06-06`
- Status: `CARD_IMPACT_V5_ENEMY_CAUSAL_SIGNATURES_COMPLETE`
- Scope: macro-route gameplay testing foundation, explicit scenario fixtures, isolated BattleEngine gameplay lab, before/after lab diff reporting, card impact orchestration, player-card effect signatures, isolated target-card capture, full active player-card coverage, utility effect signatures, card-flow observability, explicit card-flow expectations, enemy-card causal signatures and V4/V4.1/V4.2/V5 card redesign validation

## Purpose

AutoRun Lab is the first layer of the gameplay test toolchain. It expands the existing Run Lab from one class/seed sweep into a reusable headless framework for run matrices, macro policies, aggregate reports, official gate baselines and human-readable scorecards.

It still uses macro-route simulation through `tools/route_pacing_simulator.gd`. It does not play battles turn by turn and does not replace human playtest. It prepares the contracts that future Gameplay Lab, Scenario Lab and Replay Lab should reuse.

Scenario Fixtures V1 is the second layer of this toolchain. It runs small named scenarios from JSON packs, evaluates explicit expectations as `PASS`, `WARN`, or `FAIL`, and keeps stress signals visible without turning expected stress warnings into hard regressions.

Gameplay Lab V1 is the third layer. It runs isolated real battles through `BattleEngine`, using deterministic policies that only submit legal actions exposed by the engine. It targets combat regressions, keywords, hand/deck behavior, encounter modes, field effects, boss hooks and basic enemy AI signals without changing gameplay content or replacing human playtest.

Lab Diff Reporter V1 is the fourth layer. It compares before/after outputs from AutoRun Lab, Scenario Fixtures and Gameplay Lab, then turns status changes, new failures, removed records and metric deltas into JSON, CSV and Markdown reports. It is built for future large card changes where the important question is not only "did the gate pass?", but "what moved, by how much, and where should a human inspect next?".

Card Impact Pack V1 is the fifth layer. It orchestrates a deterministic before/after impact matrix for active player and enemy cards, runs selected lab components, compares outputs, and reports structural regressions separately from numerical tuning movement. It exists to prepare large future card changes without changing gameplay in this step.

Card Impact Smoke Tuning V1 is the first real use of that flow. It applies a deliberately small card batch, runs `before -> after -> compare`, and confirms that numeric impact can be reported without failing the structural gate.

Card Impact Effect Signature V2 extends that flow for player cards. It captures before/after `BattleEngine` snapshots around the focused card play, derives effect signatures from real logs/state deltas, compares those signatures in `before -> after -> compare`, and keeps enemy-card signatures reserved as schema/report-only data for a future enemy implementation pass.

Card Impact V3 Isolated Target Capture makes the player-card harness less ambiguous before broad card redesigns. It plays at most one required support card, plays the focused target card once, captures the signature, stops further card plays for that turn, and turns repeated-target or failed isolated captures into structural gate blockers.

Card Impact V4 Full Player Matrix expands the player-card matrix from the 54 core class variants to all 108 active player variants, including Terra/Gelo/Ar/Fogo reward cards and upgrades. It also promotes temporary ability power into explicit utility effect-signature fields while keeping enemy-card signatures report-only for a future causal enemy pass.

Card Impact V4.1 Card-Flow Harness Pass keeps the V4 full player matrix and adds a focused card-flow harness for draw, discard, hand and deck deltas. It makes `necro_colheita_das_almas` and `necro_colheita_das_almas_lvl3` expected card-flow cases, records lab-only prestate where needed, and gates missing card-flow observation structurally while keeping numeric deltas as review data.

Card Flow Redesign Batch 01 Using V4.1 is the first real card-flow edit cycle after the harness pass. It makes `draw_if_at_least` resolve as a bonus draw after normal hand refill, adds `necro_colheita_das_almas_lvl2` to the expected card-flow matrix, and proves the compare can surface `cards_drawn`, `deck_delta` and `hand_delta` movement without structural gate failure.

Card Impact V4.2 Card Flow Expectations promotes the proven V4.1 card-flow observations into explicit `required` and `watch` checks for the three Colheita variants. Required checks gate `card_flow_observed`, `cards_drawn`, `deck_delta` and `hand_delta`; watch checks keep exact calibrated values visible without blocking intentional numeric movement that still satisfies the required floor/ceiling.

Card Impact V5 Enemy Causal Signatures promotes the 30 active enemy cards from report-only participation to required causal effect signatures. V5 uses a commander-driven BattleEngine harness to make each enemy card enter play, captures play and first-combat snapshots, reports explicit `enemy_*` effect fields, and gates missing enemy play/signature data structurally while keeping intentional numeric deltas review-only.

Reward Card Redesign Batch 01 Using V4 is the first real reward-card edit cycle executed against the full 108-player-card matrix. It changes six reward/card-upgrade variants across Arcano, Invocador and Necromante, then uses V4 `before -> after -> compare` to confirm that the battle harness exposes the intended effect deltas while Scenario Fixtures, Run Lab and the full validation suite remain stable.

Reward Card Redesign Batch 02 Utility Using V4 is the second real reward-card edit cycle on the full matrix. It focuses on utility/control/economy movement: temporary ability power, freeze duration and Ash generation/card-flow hook data. The V4 compare confirms utility/control/economy effect deltas while Scenario Fixtures, Run Lab and the full validation suite remain stable.

Card Redesign Batch 01 is the first controlled real card-edit cycle using V2. It changes three Arcano damage upgrade variants, calibrates the damage-family harness so overkill does not hide effect movement, and proves that `effect.*` deltas can show intentional player-card movement while every structural gate remains green.

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

Card impact before/after/compare gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v1

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v1

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v1
```

Card impact V2 effect-signature gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v2

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v2

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v2
```

Card impact V3 isolated target-capture gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v3

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v3

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v3
```

Card impact V4 full player-matrix gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v4 --out=user://card_impact/track02_card_impact_v4_full_player_matrix

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v4 --out=user://card_impact/track02_card_impact_v4_full_player_matrix

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v4 --out=user://card_impact/track02_card_impact_v4_full_player_matrix
```

Card impact V4.1 card-flow gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness
```

Card impact V4.2 card-flow expectation gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v4_2 --out=user://card_impact/track02_card_impact_v4_2_card_flow_expectations
```

Card impact V5 enemy causal-signature gates:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v5 --out=user://card_impact/track02_card_impact_v5_enemy_causal_signatures

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v5 --out=user://card_impact/track02_card_impact_v5_enemy_causal_signatures

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v5 --out=user://card_impact/track02_card_impact_v5_enemy_causal_signatures
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

## Card Impact Pack V1

Card impact packs live under `data/lab/card_impact/`. The first official pack is `track02_card_impact_v1`.

Useful commands:

```text
--pack=track02_card_impact_v1
--phase=before|after|compare
--out=user://card_impact/track02_card_impact_v1
--cards=all|player|enemy|arcano_choque,enemy_terra_elemental_areia
--components=battle,scenario,run_lab
--mode=explore|gate
--gate
--stop-on-failure
```

The V1 matrix covers:

- 54 core player class card variants: six V1 core cards per class across Lvl 1, Lvl 2 and Lvl 3.
- 30 active enemy cards from `track_contract.enemy_card_galleries`.
- 15 `elemental_*` legacy inactive cards audited outside the active matrix.

The player-card battle harness uses `card_focus_legal`, which prioritizes the card under test once legal and plays a small enabling creature first when the target card needs an allied board. Enemy-card cases use a deterministic prefilled enemy slot to ensure the enemy card participates in a real `BattleEngine` combat cycle.

Card impact outputs:

- `before/` and `after/`: component lab outputs.
- `compare/`: per-component diff outputs.
- `card_impact_results.json`: complete aggregate payload.
- `card_impact_results.csv`: component and metric-change rows.
- `card_impact_summary.json`: aggregate summary.
- `card_impact_summary.md`: human report with impact matrix, component status, top impacted cards, status changes and metric changes.
- `card_impact_gate.md`: short structural regression view.

Gate behavior:

- Missing active-card cases, target cards not exercised, rejected `BattleEngine` actions, missing expected reports, removed after records and new after `FAIL` records fail `--mode=gate`.
- HP, turn, damage, units, deck, shop, Souls and other metric changes are reported as impact/WARN data but do not fail the gate by themselves.
- `PASS -> WARN` is visible in reports and reserved for human inspection, not an automatic veto.

Recommended future card-change flow:

1. Run `run_card_impact --phase=before --mode=gate`.
2. Apply the intended card changes.
3. Run `run_card_impact --phase=after --mode=gate`.
4. Run `run_card_impact --phase=compare --mode=gate`.
5. Inspect `card_impact_summary.md`, `card_impact_gate.md` and the component diff Markdown before deciding whether the numerical movement is intended.

First real cycle result (`user://card_impact/smoke_tuning_v1`):

- Tuning batch: `arcano_choque_lvl2` and `arcano_choque_lvl3` damage `3 -> 4`, `invocador_batedor_lvl3` attack `6 -> 5`, `necro_esqueleto_lvl2` health `2 -> 3`, and `enemy_ar_rajada` attack `4 -> 5`.
- Card Impact coverage: `84/84` active card cases, with `54` player variants, `30` enemy cards, and `15` legacy inactive elemental cards audited.
- Compare gate: PASS, zero structural errors, zero new failures, zero removed records, zero status changes.
- Impact detected: `enemy_ar_rajada` changed `damage_to_player_hero` from `4` to `5` and `player_hp` from `56` to `55` in its isolated enemy-card harness.
- Operational lesson: an earlier probe on `enemy_terra_guerreiro_terra` was rejected because it changed the calibrated map 8 boss Battle Lab gate. Keep future smoke-tuning probes either intentionally gate-updating or isolated from calibrated core cases.

## Card Impact Effect Signature V2

`track02_card_impact_v2` keeps the V1 active-card matrix and adds derived effect signatures for player-card cases.

Coverage:

- 84/84 active card cases remain covered: 54 player card variants and 30 active enemy cards.
- 15 `elemental_*` legacy inactive cards remain audited outside the active matrix.
- 54/54 player-card cases require an effect signature in `--mode=gate`.
- Enemy-card signatures are schema-ready but `report_only` in V2; missing enemy signatures do not fail the gate.

Player signatures are derived from real `BattleEngine` snapshots around the `card_focus_legal` focused play. They summarize fields such as hero damage, slot damage, summons, ally buffs, enemy debuffs, poison/freeze/shield additions, mana/ashes gains, card draw/discard movement, pending choices, visual/log deltas, keyword deltas and compact effect-family tags.

V2 adds:

- `tools/lab/battle_effect_signature.gd`: pure snapshot/delta/aggregation utility.
- `data/lab/card_impact/track02_card_impact_v2.json`: schema version 2 pack with effect-signature policy and harness hints.
- `card_effect_signature`, `card_effect_signature_present`, `effect_families` and `card_effect_samples` fields in Battle Lab/Card Impact battle results.
- `effect.*` metric comparison rows in lab diffs.
- Card Impact summary fields for `effect_changes`, `top_effect_delta_cards`, `by_effect_family` and `missing_signatures`.

Gate behavior:

- Missing required player-card effect signatures fail `--mode=gate`.
- Effect deltas are reported for review but do not fail the gate by themselves.
- Structural regressions from V1 still fail: missing coverage, rejected engine actions, missing component reports, removed after records and new after `FAIL` records.

Current calibrated same/same result (`user://card_impact/v2_all_gate`):

- `before`, `after` and `compare` pass with 84 common battle cases, 12 common scenario cases and 3 common run-lab cases.
- Coverage is 84/84 active cases, 54 required player effect signatures, 30 report-only enemy cases and 15 audited inactive legacy cards.
- Compare reports zero status changes, zero metric changes, zero effect changes, zero missing signatures and zero structural errors.

First controlled V2 redesign result (`user://card_impact/redesign_batch_01`):

- Card changes: `arcano_choque_lvl2` damage `4 -> 5`, `arcano_choque_lvl3` damage `4 -> 5`, and `arcano_tempestade_lvl3` random damage `6 -> 7`.
- Harness calibration: damage-family player-card cases now use `enemy_health=160` and `enemy_terra_elemental_tita` so extra damage remains observable instead of being flattened by low-HP overkill.
- Compare gate: PASS with zero structural errors, zero new failures, zero removed records and zero status changes.
- Effect deltas detected: `card_impact_player_arcano_choque_lvl2` `effect.enemy_hero_damage` `52 -> 57`, `card_impact_player_arcano_choque_lvl3` `86 -> 92`, and `card_impact_player_arcano_tempestade_lvl3` `57 -> 62`.
- Metric deltas matched the intended direction: the three affected battle harnesses showed lower final enemy HP and higher `damage_to_enemy_hero`, with no Scenario or Run Lab gate regression.

## Card Impact V3 Isolated Target Capture

`track02_card_impact_v3` keeps the V2 matrix and derived player-card effect signatures, then adds `target_capture.mode=isolated_once` for player-card cases.

V3 target capture behavior:

- Player-card cases use `card_focus_isolated`.
- The policy may play one enabling support card when the target cannot be legally played without a board.
- The focused card is played once, its effect signature is captured, and no more cards are played that turn.
- `capture_quality` is reported as `clean`, `support_required`, `ambiguous` or `failed`.
- Repeated target-card captures and failed isolated captures fail the V3 structural gate.
- Enemy-card signatures remain schema-ready/report-only; missing enemy signatures do not count as isolated capture failures.

V3 adds:

- `data/lab/card_impact/track02_card_impact_v3.json`.
- `card_focus_isolated` in `tools/lab/battle_policy.gd`.
- Target capture fields in battle/card-impact records and `effect.*` diffs: `target_card_play_count`, first play turn/cycle, `stopped_after_target`, `target_capture_mode`, `capture_quality` and `ambiguity_reasons`.
- `Target Capture Quality` in Card Impact Markdown summaries.

Current calibrated same/same result (`user://card_impact/track02_card_impact_v3_isolated_target_capture`):

- `before`, `after` and `compare` pass with zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes.
- Coverage is 84/84 active cases: 54 player cards, 30 active enemy cards and 15 audited inactive legacy cards.
- Player target capture quality is 45 clean, 9 support-required, 0 ambiguous, 0 failed and 0 repeated target captures.

## Player Card Redesign Batch 02

Batch 02 is a real but light player-card change cycle using V3 as the default harness. Its purpose is to test the toolchain on a broader core-card edit, not to declare final balance.

Changed core cards:

- `arcano_acelerar_lvl2`: temporary ability power `+3 -> +2`.
- `arcano_bola_de_fogo_lvl2`: primary damage `2 -> 3`, adjacent damage unchanged.
- `invocador_batedor_lvl2`: attack `3 -> 4`.
- `invocador_guardiao_lvl2`: health `6 -> 7`.
- `necro_prender_lvl3`: Enfraquecer `1 -> 2`.
- `necro_zumbi_lvl2`: health `3 -> 4`.

Observed V3 compare result (`user://card_impact/player_card_redesign_batch_02`):

- Gate: PASS.
- Coverage: 84/84 active cases, with 54 player, 30 enemy and 15 legacy inactive cards audited.
- Structural errors/new failures/removed records/status changes: 0.
- Battle component changes: 5 changed records, 14 metric changes and 13 effect changes.
- Scenario and Run Lab components: 0 metric/status changes.
- Target capture quality stayed stable at 45 clean, 9 support-required, 0 ambiguous, 0 failed and 0 repeated.

Detected effect movement:

- `arcano_bola_de_fogo_lvl2`: `effect.enemy_slot_damage_total` `3 -> 4`.
- `invocador_batedor_lvl2`: `effect.summoned_attack_total` `5 -> 6`.
- `invocador_guardiao_lvl2`: `effect.summoned_health_total` `7 -> 8`.
- `necro_zumbi_lvl2`: `effect.summoned_health_total` `3 -> 4`.
- `necro_prender_lvl3`: multiple deltas from stronger Enfraquecer killing the target in the isolated harness instead of leaving a debuffed/snared unit alive.

Tooling lesson:

- V3 correctly protected structural coverage and caught effect movement for damage, summon stats and combat-state consequences.
- `arcano_acelerar_lvl2` did not surface an `effect.*` delta because the current signature does not track temporary ability power directly. Add `temporary_ability_power_delta` or equivalent before larger utility-card redesigns.
- The first draft of this batch touched reward cards outside the current V3 player matrix. That was corrected before acceptance, and the next tooling step should expand Card Impact coverage to all active player reward cards, not only the 54 core variants.

## Card Impact V4 Full Player Matrix

`track02_card_impact_v4` keeps the V3 isolated target-capture behavior and expands the player scope to `full_active_player_v1`.

V4 coverage:

- 108 active player card variants: 36 Arcano, 36 Invocador and 36 Necromante.
- Player source split: 27 starter-deck variants, 9 core cost-2 variants and 72 reward-card variants.
- 30 active enemy cards remain in report-only signature mode.
- 15 `elemental_*` legacy inactive cards remain audited outside the active matrix.
- Reward-card examples now covered include `arcano_vortice`, `invocador_cavaleiro_arcano` and `necro_lich`, plus their Lvl 2 and Lvl 3 upgrades.

V4 adds:

- `data/lab/card_impact/track02_card_impact_v4.json`.
- `player_scope="full_active_player_v1"` in the Card Impact matrix.
- Matrix discovery from starter decks, core cost-2 cards and all `track_02_player_card_rewards` entries instead of only Terra reward cards.
- Explicit utility signature fields: `temporary_ability_power_delta`, `temporary_ability_power_gained` and `temporary_ability_power_lost`.
- Utility effect-family classification and `effect.temporary_ability_power_*` diff rows.
- Card Impact Markdown sections for full player coverage by class/source and utility effect deltas.

Gate behavior remains structural:

- Missing active-player coverage, missing expected reports, rejected engine actions, removed records and new `FAIL` records fail `--mode=gate`.
- Temporary ability power movement is reported as `effect.*` delta data and does not fail the gate by itself.
- Enemy-card signatures are still schema-ready/report-only and do not fail V4 until a future enemy causality pass promotes them.

Current calibrated same/same result (`user://card_impact/track02_card_impact_v4_full_player_matrix`):

- `before`, `after` and `compare` pass with zero structural errors, zero new failures and zero removed records.
- Coverage is 153/153 audited cards: 108 player, 30 active enemy and 15 legacy inactive cards.
- Full player matrix is split evenly across classes: 36 Arcano, 36 Invocador and 36 Necromante.
- V3 compare regression for `user://card_impact/player_card_redesign_batch_02` remains green.
- Battle Lab remains 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick gates remain green, and `validate.gd` passes with 175/175 GUT tests and 1704 asserts.

## Card Impact V4.1 Card-Flow Harness Pass

`track02_card_impact_v4_1` keeps V4 coverage and adds focused card-flow observability.

V4.1 coverage:

- 108 active player card variants, 30 active enemy report-only cards and 15 legacy inactive cards, unchanged from V4.
- Initial harness coverage had 2 expected player card-flow cases: `necro_colheita_das_almas` and `necro_colheita_das_almas_lvl3`; Card Flow Redesign Batch 01 promotes Lvl 2, so the current pack expects 3.
- Enemy-card signatures remain report-only.

V4.1 adds:

- `data/lab/card_impact/track02_card_impact_v4_1.json`.
- `effect_family="card_flow"` classification for cards with draw/discard/hand/deck keys.
- A player card-flow harness that leaves draw room in hand and at least one card in deck.
- Card Impact-only `lab_prestate.initial_dead_unit_count`, applied after `BattleEngine.start_battle` and before the first policy action. This is used for `necro_colheita_das_almas_lvl3` so the threshold reaches `draw_if_at_least=6` deterministically.
- Signature/report fields: `card_flow_expected`, `card_flow_observed`, `card_flow_missing_reason`, plus the existing `cards_drawn`, `cards_discarded`, `deck_delta`, `hand_delta` and `discard_delta`.
- Card Impact Markdown `Card Flow Coverage`, including missing cases and card-flow deltas.

Gate behavior:

- Missing expected card-flow cases fail `--mode=gate`.
- Missing expected card-flow signatures fail `--mode=gate`.
- `card_flow_expected=true` with `card_flow_observed=false` fails `--mode=gate`.
- Numeric card-flow deltas remain review data and do not fail compare by themselves.

Current calibrated same/same result (`user://card_impact/track02_card_impact_v4_1_card_flow_harness`):

- `before`, `after` and `compare` pass with zero structural errors, zero new failures and zero removed records.
- Focused probes observe both expected card-flow cards drawing 1 card, with `deck_delta=-1` and `card_flow_observed=true`.
- `necro_colheita_das_almas_lvl3` records `lab_prestate.initial_dead_unit_count=2` and `ashes_gained=6`.

## Card Flow Redesign Batch 01 Using V4.1

Purpose: execute a small real card-flow redesign to validate Card Impact V4.1 on actual card movement.

Changed behavior/content:

- `draw_if_at_least` now grants a bonus draw after the normal hand refill, making the extra draw observable rather than hidden by refill-to-hand-size.
- `necro_colheita_das_almas`, `necro_colheita_das_almas_lvl2` and `necro_colheita_das_almas_lvl3` now describe the draw as `compra 1 carta extra`.
- `necro_colheita_das_almas_lvl2` Ashes gain changed `2 -> 3` and gained `draw_if_at_least=3`.
- `track02_card_impact_v4_1` now expects 3 player card-flow cases: base, Lvl 2 and Lvl 3 Colheita.

Observed V4.1 compare result (`user://card_impact/card_flow_redesign_batch_01_v4_1`):

- Gate: PASS.
- Coverage: 108 player cards, 30 enemy report-only cards and 15 legacy inactive cards audited.
- Structural errors, new failures, removed records and status changes: 0.
- Battle component changes: 3 changed records and 11 effect deltas.
- Scenario and Run Lab components: 0 changes.

Detected player effect movement:

- `necro_colheita_das_almas`: `effect.cards_drawn` `1 -> 2`, `effect.deck_delta` `-1 -> -2`, `effect.hand_delta` `0 -> 1`.
- `necro_colheita_das_almas_lvl2`: `effect.ashes_gained` `2 -> 3`, `effect.cards_drawn` `1 -> 2`, `effect.deck_delta` `-1 -> -2`, `effect.hand_delta` `0 -> 1`, `effect.card_flow_expected` `false -> true`.
- `necro_colheita_das_almas_lvl3`: `effect.cards_drawn` `1 -> 2`, `effect.deck_delta` `-1 -> -2`, `effect.hand_delta` `0 -> 1`.

Macro regression gates after the batch:

- Battle Lab: 9 PASS / 3 WARN / 0 FAIL.
- Scenario Fixtures: 9 PASS / 3 WARN / 0 FAIL.
- AutoRun smoke gate: PASS.
- AutoRun quick gate: PASS across 30 macro-route cases.
- `tools/validate.gd`: PASS with 187/187 GUT tests, 1785 asserts and unchanged full-route pacing telemetry.

Operational lesson: V4.1 now proves card-flow deltas on a real content change. Next, decide whether any card-flow observations should become explicit expectations before broad draw/discard/hand/deck redesigns.

## Card Impact V4.2 Card Flow Expectations

`track02_card_impact_v4_2` keeps V4.1 coverage and adds explicit card-flow expectations to the Card Impact contract.

V4.2 coverage:

- 108 active player card variants, split 36 Arcano / 36 Invocador / 36 Necromante.
- 30 active enemy cards remain `report_only`.
- 15 legacy inactive `elemental_*` cards remain audited.
- 3 expected player card-flow cases: `necro_colheita_das_almas`, `necro_colheita_das_almas_lvl2` and `necro_colheita_das_almas_lvl3`.

V4.2 adds:

- `data/lab/card_impact/track02_card_impact_v4_2.json`.
- Optional `card_flow_expectations` checks with `card_id`, `field`, `op`, `value` and `severity`.
- Supported fields: `card_flow_observed`, `cards_drawn`, `cards_discarded`, `cards_created`, `deck_delta`, `hand_delta` and `discard_delta`.
- Supported severities: `required` becomes a gate-blocking `FAIL`; `watch` becomes a report-only `WARN`.
- Card Impact Markdown/CSV/Gate reporting for `Card Flow Expectations`.

Initial promoted expectations:

- For each Colheita variant, `card_flow_observed == true`, `cards_drawn >= 2`, `deck_delta <= -2` and `hand_delta >= 1` are `required`.
- Exact current values `cards_drawn == 2`, `deck_delta == -2` and `hand_delta == 1` are `watch`.

Current calibrated same/same result (`user://card_impact/track02_card_impact_v4_2_card_flow_expectations`):

- `before`, `after` and `compare` pass with zero structural errors, zero new failures and zero removed records.
- Coverage is 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards and 3 expected card-flow player cards.
- Card Flow Expectations pass 21/21 checks with 0 WARN, 0 FAIL and 0 required failures.
- V4.1 historical compare for `user://card_impact/card_flow_redesign_batch_01_v4_1` remains green.
- Battle Lab remains 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick gates remain green, and `validate.gd` passes with 199/199 GUT tests and 1827 asserts.

Operational lesson: V4.2 is now the recommended pack for future card-flow or broad reward-card redesigns. Numeric card-flow deltas remain allowed when they satisfy `required` expectations; intentional changes that reduce required draw/deck/hand behavior should update the V4.2 expectation in the same work.

## Card Impact V5 Enemy Causal Signatures

`track02_card_impact_v5` keeps V4.2 player coverage and promotes enemy-card effect signatures from report-only to required.

V5 coverage:

- 108 active player card variants, split 36 Arcano / 36 Invocador / 36 Necromante.
- 30 active enemy cards with required causal signatures.
- 15 legacy inactive `elemental_*` cards remain audited.
- 3 expected player card-flow cases and 21 promoted Card Flow Expectation checks remain active.

V5 adds:

- `data/lab/card_impact/track02_card_impact_v5.json`.
- `effect_signatures.enemy.mode="required"`.
- `expected_enemy_effect_signatures=30`.
- Enemy cases tagged `enemy_causal_signature`, with `effect_signature_scope="enemy"` and `effect_signature_required=true`.
- A controlled commander harness using one enemy card in hand/deck, a one-turn duel setup and first-combat snapshot capture.
- Explicit enemy-caused fields: `enemy_card_played`, `enemy_card_play_count`, `enemy_summons_created`, `enemy_summoned_count`, `enemy_summoned_attack_total`, `enemy_summoned_health_total`, `enemy_summoned_keyword_count`, `enemy_keywords_added`, `enemy_damage_to_player_hero`, `enemy_damage_to_player_slots`, `enemy_player_units_delta`, `enemy_combat_damage_to_player_hero`, `enemy_combat_damage_to_player_slots`, `enemy_signature_phase` and `enemy_signature_confidence`.
- Card Impact Markdown sections for `Enemy Causal Signature Coverage`, `Enemy Signature Quality`, `Top Enemy Effect Deltas` and `Enemy Missing/Ambiguous Cases`.

Gate behavior:

- Missing enemy-card coverage, a V5 enemy card not being played, or a missing V5 enemy signature fails `--mode=gate`.
- Removed after records, new after `FAIL` records, rejected BattleEngine actions and failed Card Flow Expectations remain structural blockers.
- Numeric enemy signature movement is review data and does not fail compare by itself.
- V4.2 remains the historical/default player-card-flow harness; V5 is the recommended harness before enemy-card redesigns.

Current calibrated same/same result (`user://card_impact/track02_card_impact_v5_enemy_causal_signatures`):

- `before`, `after` and `compare` pass with zero structural errors, zero new failures and zero removed records.
- Coverage is 138/138 active report records, with 108 player cards, 30 enemy cards and 15 legacy inactive cards.
- Enemy signatures are 30 expected, 30 present, 0 missing; enemy cards played/not played is 30/0.
- Enemy signature quality is 30 clean, 0 ambiguous and 0 missing.
- Card Flow Expectations remain 21/21 PASS.
- V4.2 historical compare for `user://card_impact/reward_card_redesign_batch_03_v4_2` remains green.
- Battle Lab remains 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick gates remain green, and `validate.gd` passes with 211/211 GUT tests and 1906 asserts.

Operational lesson: V5 is now the recommended pack for the first enemy-card redesign batch. Enemy-card attack, health, keywords, summon totals and first-combat pressure can be compared before/after without turning intentional numeric movement into a structural gate failure.

## Reward Card Redesign Batch 01 Using V4

Purpose: execute a light but real reward-card tuning batch to prove that Card Impact V4 can inspect the full player matrix during intentional card movement.

Changed player cards:

- `arcano_canalizar_lvl2`: damage `4 -> 5`.
- `arcano_descarga_lvl2`: damage `3 -> 4`.
- `invocador_parede_de_escudos_lvl2`: shield charges `1 -> 2`.
- `invocador_cavaleiro_arcano_lvl2`: summoned attack `4 -> 5`.
- `necro_flagelo_lvl3`: poison amount `2 -> 3`.
- `necro_colheita_das_almas_lvl3`: Ashes gain `3 -> 4`.

Observed V4 compare result (`user://card_impact/reward_card_redesign_batch_01_v4`):

- Gate: PASS.
- Coverage: 138/138 active report records, with 108 player cards, 30 enemy report-only cards and 15 legacy inactive cards audited.
- Structural errors, new failures, removed records and status changes: 0.
- Battle component changes: 6 changed records and 15 metric/effect changes.
- Scenario and Run Lab components: 0 changes.
- Target capture quality stayed stable: 96 clean, 12 support-required, 0 ambiguous, 0 failed and 0 repeated target captures.

Detected player effect movement:

- `arcano_canalizar_lvl2`: `effect.enemy_hero_damage` `5 -> 6`.
- `arcano_descarga_lvl2`: `effect.enemy_units_delta` `0 -> -1`, `effect.enemy_slot_damage_total` `4 -> 5`, and visible final-metric movement from killing the target earlier.
- `invocador_parede_de_escudos_lvl2`: `effect.ally_shield_gain` `1 -> 2` and `effect.shield_added_total` `1 -> 2`.
- `invocador_cavaleiro_arcano_lvl2`: `effect.summoned_attack_total` `6 -> 7`.
- `necro_flagelo_lvl3`: `effect.poison_added_total` `2 -> 3` and `effect.enemy_poison_added` `2 -> 3`.
- `necro_colheita_das_almas_lvl3`: `effect.ashes_gained` `3 -> 4`.

Macro regression gates after the batch:

- Battle Lab: 9 PASS / 3 WARN / 0 FAIL.
- Scenario Fixtures: 9 PASS / 3 WARN / 0 FAIL.
- AutoRun smoke gate: PASS.
- AutoRun quick gate: PASS across 30 macro-route cases.
- `tools/validate.gd`: PASS with 175/175 GUT tests, 1704 asserts and unchanged full-route pacing telemetry.

Operational lesson: V4 is now proven on reward-card movement, including damage, shield, summon stat, poison and economy signatures. This batch did not exercise temporary ability power utility deltas; that follow-up is covered by Reward Card Redesign Batch 02 Utility Using V4.

## Reward Card Redesign Batch 02 Utility Using V4

Purpose: execute a second light reward-card tuning batch to prove that Card Impact V4 can expose utility/control/economy movement, especially temporary ability power.

Changed player cards:

- `arcano_acelerar_lvl3`: temporary ability power `+3 -> +4`.
- `arcano_vortice`: frozen duration `1 -> 2` turns on one random enemy.
- `arcano_vortice_lvl2`: frozen duration `1 -> 2` turns on up to two random enemies.
- `necro_colheita_das_almas`: Ashes gain `2 -> 3` and `draw_if_at_least=3` hook added.

Observed V4 compare result (`user://card_impact/reward_card_redesign_batch_02_utility_v4`):

- Gate: PASS.
- Coverage: 138/138 active report records, with 108 player cards, 30 enemy report-only cards and 15 legacy inactive cards audited.
- Structural errors, new failures, removed records and status changes: 0.
- Battle component changes: 4 changed records and 7 metric/effect changes.
- Scenario and Run Lab components: 0 changes.
- Target capture quality stayed stable: 96 clean, 12 support-required, 0 ambiguous, 0 failed and 0 repeated target captures.

Detected player effect movement:

- `arcano_acelerar_lvl3`: `effect.temporary_ability_power_delta` `3 -> 4` and `effect.temporary_ability_power_gained` `3 -> 4`.
- `arcano_vortice`: `effect.freeze_added_total` `1 -> 2` and `effect.enemy_frozen_added` `1 -> 2`.
- `arcano_vortice_lvl2`: `effect.freeze_added_total` `1 -> 2` and `effect.enemy_frozen_added` `1 -> 2`.
- `necro_colheita_das_almas`: `effect.ashes_gained` `2 -> 3`.

Macro regression gates after the batch:

- Battle Lab: 9 PASS / 3 WARN / 0 FAIL.
- Scenario Fixtures: 9 PASS / 3 WARN / 0 FAIL.
- AutoRun smoke gate: PASS.
- AutoRun quick gate: PASS across 30 macro-route cases.
- `tools/validate.gd`: PASS with 175/175 GUT tests, 1704 asserts and unchanged full-route pacing telemetry.

Operational lesson: V4 now has a real utility-family delta through temporary ability power and continues to expose control/economy movement cleanly. The new `draw_if_at_least` hook on `necro_colheita_das_almas` did not surface a `cards_drawn` effect delta in the current harness; if card-flow deltas become important, the next tooling step should add a dedicated card-flow harness or fixture before broad draw/discard redesigns.

## Result Schema

Each detailed record contains:

- `schema_version`
- `tool`
- `case` or `scenario`
- `result`
- `timeline`
- `warnings`
- `tags`

The current macro-route `simulation_mode` is `macro_route_v1`. Gameplay Lab uses `battle_engine_v1`. Card Impact uses `card_impact_v1`, `card_impact_v2`, `card_impact_v3`, `card_impact_v4`, `card_impact_v4_1`, `card_impact_v4_2` and `card_impact_v5`. Future bot and replay tools should preserve the same outer schema and add more detailed timelines instead of creating unrelated formats.

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

1. Run the first enemy-card redesign batch under V5 before/change/after/compare.
2. Decide which repeated enemy signature movements deserve promoted expectations after real use.
3. Continue broad player reward-card redesigns under V4.2 when card-flow expectations matter.
4. Expand explicit expectations for additional draw/discard/hand/deck cards as they enter the active card matrix.
5. Replay Lab: record human or bot decisions and replay them across builds.
6. Dashboard: read the JSON/CSV/Markdown outputs and compare historical runs visually.
