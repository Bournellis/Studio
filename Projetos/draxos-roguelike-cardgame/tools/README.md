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
