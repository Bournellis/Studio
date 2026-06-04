# Draxos Roguelike Cardgame

Menu-first Draxos roguelike cardgame in Godot 4.6.2.

The current baseline is Track 02 - Complete Run Evolution: a complete-run build with a fixed 29-map route, ShipHub, RunMap, Deck, Souls shop, Battle, three classes, save/snapshot v5, production rewards, universal relics, expanded shop actions, full keyword/status vocabulary, elemental enemy galleries, enemy AI/intent, encounter modes, board formats, field effects, and boss hooks.

This build is ready for user playtest and balance feedback. It is not a new-content track; current foundation work should keep the JSON Track 02 catalog as source of truth and preserve behavior unless a product decision says otherwise.

Start with:

- `AGENTS.md`
- `implementation/current-status.md`
- `docs/product-brief.md`
- `docs/game-design-document.md`
- `docs/architecture.md`
- `docs/reuse-map.md`

Validation:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

Expected foundation baseline after the 2026-06-03 hardening pass 8: GUT 105/105, 1279 asserts, full-route pacing smoke 29/29, golden Run Lab comparison for Track 02 class/seed regressions, internal directors/services for enemy AI/intent, combat/damage resolution, rewards, Souls shop, battle previews, HUD/objective readouts and combat FX presentation, catalog source loader seam for future domain splits, and no generated-catalog churn when validation is run repeatedly without semantic JSON changes.

Run Lab:

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/run_lab.gd -- --classes=arcano,invocador,necromante --seeds=20260518
```

By default the Run Lab writes `user://run_lab/run_lab_metrics.json` and `user://run_lab/run_lab_metrics.csv`.

Use `--compare-golden --require-golden` to validate the approved Track 02 regression baseline for Arcano, Invocador, and Necromante with seed `20260518`.
