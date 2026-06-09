# Draxos Roguelike Cardgame

Menu-first Draxos roguelike cardgame in Godot 4.6.2.

The current baseline is Track 02 - Complete Run Evolution: a complete-run build with a fixed 29-map route, ShipHub, RunMap, Deck, Souls shop, Battle, three classes, save/snapshot v5, production rewards, universal relics, expanded shop actions, full keyword/status vocabulary, elemental enemy galleries, enemy AI/intent, encounter modes, board formats, field effects, boss hooks, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1 and Design Lab V1.

Track 02 remains technically playtestable, but the current operational bridge before full-run feel playtests is Design Lab-guided content expansion. Author player/enemy card and mechanic ideas as Design Lab proposal packs, tune candidates to viable/recommended, promote accepted content manually, then protect the promoted changes with Card Impact V4.2/V5 and Run Lab smoke/quick gates.

Start with:

- `AGENTS.md`
- `implementation/current-status.md`
- `docs/product-brief.md`
- `docs/game-design-document.md`
- `docs/architecture.md`
- `docs/foundation-closeout.md`
- `docs/reuse-map.md`

Validation:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

Live validation counts and the current gate live in `implementation/current-status.md`. Preserved foundation signals include full-route pacing smoke 29/29, AutoRun smoke/quick gates, Scenario Fixtures gate, Gameplay Battle Lab gate, golden Run Lab comparison for Track 02 class/seed regressions, internal directors/services for enemy AI/intent, combat/damage resolution, rewards, Souls shop, battle previews, HUD/objective readouts and combat FX presentation, catalog source loader seam for future domain splits, foundation ownership documented in `docs/foundation-closeout.md`, and no generated-catalog churn when validation is run repeatedly without semantic JSON changes.

Run Lab:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --classes=arcano,invocador,necromante --seeds=20260518
```

By default the Run Lab writes `user://run_lab/run_lab_metrics.json` and `user://run_lab/run_lab_metrics.csv`.

Use `--compare-golden --require-golden` to validate the approved Track 02 regression baseline for Arcano, Invocador, and Necromante with seed `20260518`.

Gameplay Battle Lab:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_battle_lab.gd -- --mode=gate --pack=track02_battle_core_v1
```
