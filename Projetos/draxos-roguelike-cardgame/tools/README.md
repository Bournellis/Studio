# Tools

Local Godot tools for generation, validation, screenshots, and route telemetry live here.

## Main Tools

- `content_generator.gd`: builds generated resources from authored JSON and avoids rewriting generated catalog output when the semantic hash is unchanged.
- `scene_generator.gd`: repairs generated playable scenes.
- `validate.gd`: generates data/scenes, validates contracts and visual assets, runs the shared full-route pacing smoke, then runs GUT.
- `route_pacing_simulator.gd`: pure local simulator used by validation and Run Lab for deterministic route pacing metrics.
- `run_lab_golden_metrics.gd`: approved Track 02 golden metrics and comparison helpers for regression checks.
- `run_lab.gd`: runs route simulations by class/seed, writes JSON/CSV metrics, and can compare against golden metrics.
- `run_scenarios.gd`: runs explicit Scenario Fixtures packs with PASS/WARN/FAIL expectations and JSON/CSV/Markdown reports.
- `run_battle_lab.gd`: runs isolated BattleEngine fixture packs with deterministic legal-action policies and JSON/CSV/Markdown reports.
- `compare_lab_reports.gd`: compares before/after outputs from AutoRun Lab, Scenario Fixtures or Gameplay Lab and writes JSON/CSV/Markdown diffs.
- `run_card_impact.gd`: orchestrates Card Impact Pack before/after/compare phases for active player and enemy cards, including V2 player-card effect signatures, then writes aggregate JSON/CSV/Markdown reports.
- `capture_visual_screenshots.gd`: captures visual surfaces when UI work requires screenshots.

## Validation Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

## Run Lab Command

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --classes=arcano,invocador,necromante --seeds=20260518
```

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --classes=arcano,invocador,necromante --seeds=20260518 --compare-golden --require-golden
```

## Scenario Fixtures Gate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_scenarios.gd -- --mode=gate --pack=track02_core_v1
```

## Gameplay Battle Lab Gate

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_battle_lab.gd -- --mode=gate --pack=track02_battle_core_v1
```

## Lab Diff Reporter

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/compare_lab_reports.gd -- --before=user://battle_lab/before_cards --after=user://battle_lab/after_cards --type=battle --out=user://lab_diff/card_change_probe --mode=gate
```

Supported `--type` values are `auto`, `battle`, `scenario` and `run_lab`. Gate mode fails on new `FAIL` records or removed records; warnings and metric deltas are reported for inspection.

## Card Impact Pack Gate

V1 structural impact flow:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v1

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v1

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v1
```

V2 player-card effect-signature flow:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=before --mode=gate --pack=track02_card_impact_v2

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=after --mode=gate --pack=track02_card_impact_v2

D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_card_impact.gd -- --phase=compare --mode=gate --pack=track02_card_impact_v2
```

Useful filters:

```text
--cards=all|player|enemy|arcano_choque
--components=battle,scenario,run_lab
--effect-signatures
--effect-scope=player|enemy|all
--effect-mode=required|report_only|off
```

Card Impact gate mode fails only on structural regressions: missing card coverage, required target cards not exercised, required player-card effect signatures missing in V2, rejected `BattleEngine` actions, missing reports, removed after records or new after `FAIL` records. Numeric gameplay movement and effect-signature deltas are reported for review.

Operational calibration: player-card damage-family harnesses intentionally use a high-health enemy hero and `enemy_terra_elemental_tita` as the starting enemy slot. This keeps extra damage visible in V2 effect signatures instead of masking intentional changes through low-HP overkill.
