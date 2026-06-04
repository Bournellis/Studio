# Current Status

- Last Updated: `2026-06-03`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 29-map complete-run roguelike cardgame production plan`
- Active Track: `Track 02 - Complete Run Evolution`
- Active Track Status: `T02-P09_COMPLETE`
- Current Operational Baseline: `Godot 4.6.2 Track 02 complete-run build: fixed 29-map route, save/snapshot version 5, production reward schedule, universal relics, expanded Souls shop, keyword tooltip vocabulary, all Track 02 keyword mechanics, 8 reward cards per class with upgrades, Terra/Gelo/Ar/Fogo enemy galleries, deterministic hybrid enemy AI, visible enemy intent, encounter modes, board formats, elemental field effects, boss hooks for maps 8/15/22/29, polished reward/map/shop/relic/keyword/intent/battle readability, discard marks folded into the main creature-play phase, 5/5, 6/6, and 7/7 layout coverage, shared route pacing simulator for validation and Run Lab, golden Run Lab comparison for approved Track 02 class/seed regressions, docs/playtest-track-02.md checklist, idempotent generated slice catalog hashing, catalog source loader seam for future domain splits, internal enemy-turn/intent directors, reward and Souls shop service delegation, battle preview/HUD/combat-FX presenters, and first tuning pass keeping upgrade rewards level-only to hit final deck-size targets.`
- Active Goal: `user playtest of Track 02 complete-run build`
- Validation: `2026-06-03 foundation hardening 7 validation green; 103/103 GUT tests passing across 7 modular scripts; 1271 asserts; shared full-route pacing smoke completed 29/29 maps with 217 estimated turns, 116 estimated HP loss, 0 deaths, 362 Souls earned, 291 Souls spent, 71 Souls left, 38-card final deck, 6 relics, and 21 shop actions. Run Lab --compare-golden --require-golden passes for Arcano/Invocador/Necromante seed 20260518, writes JSON/CSV to user://run_lab, protects Arcano exact metrics, and confirms all classes complete 29/29 without death. Human playtest and balance feedback remain pending.`

## Read Next

- `../AGENTS.md`
- `../../canon/canon-brief.md`
- `../docs/product-brief.md`
- `../docs/game-design-document.md`
- `../docs/design-early-game.md`
- `../docs/architecture.md`
- `../docs/reuse-map.md`
- `tracks/track-00-project-bootstrap/current-status.md`
- `tracks/track-00-project-bootstrap/linear-execution-plan.md`
- `tracks/track-01-playable-run-loop/current-status.md`
- `tracks/track-01-playable-run-loop/linear-execution-plan.md`
- `tracks/track-02-complete-run-evolution/current-status.md`
- `tracks/track-02-complete-run-evolution/design-brief.md`
- `tracks/track-02-complete-run-evolution/implementation-prompts.md`

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

## Next

Track 02 is ready for user playtest. Use `docs/playtest-track-02.md` for the human checklist and `tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md` for metrics and known debt; use the local Run Lab only for regression and tuning comparison, not as a substitute for human playtest.
