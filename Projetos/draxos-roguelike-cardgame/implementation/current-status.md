# Current Status

- Last Updated: `2026-06-05`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 29-map complete-run roguelike cardgame production plan`
- Active Track: `Track 02 - Complete Run Evolution`
- Active Track Status: `T02-P09_COMPLETE`
- Current Operational Baseline: `Godot 4.6.2 Track 02 complete-run build with foundation closeout, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1, Card Impact Smoke Tuning V1 and Card Impact Effect Signature V2: fixed 29-map route, save/snapshot version 5, production reward schedule, universal relics, expanded Souls shop, keyword tooltip vocabulary, all Track 02 keyword mechanics, 8 reward cards per class with upgrades, Terra/Gelo/Ar/Fogo enemy galleries, deterministic hybrid enemy AI, visible enemy intent, encounter modes, board formats, elemental field effects, boss hooks for maps 8/15/22/29, polished reward/map/shop/relic/keyword/intent/battle readability, discard marks folded into the main creature-play phase, 5/5, 6/6, and 7/7 layout coverage, shared route pacing simulator for validation and AutoRun Lab, exact golden comparison for approved Track 02 class/seed regressions, official smoke/quick gate baselines in data/lab/baselines, explicit AutoRun --mode=gate regression commands, Scenario Fixture pack data/lab/scenarios/track02_core_v1.json, Gameplay Battle pack data/lab/battles/track02_battle_core_v1.json, deterministic legal-action policies baseline/aggressive/defensive/end-turn-only/card-focus, PASS/WARN/FAIL expectations, tools/compare_lab_reports.gd before/after diff runner, data/lab/card_impact/track02_card_impact_v1.json and track02_card_impact_v2.json covering 84 active card cases plus 15 audited legacy inactive elemental cards, V2 player-card effect signatures derived from BattleEngine snapshots/log deltas, first real card-change probe covering Choque Lvl 2/3, Batedor Arcano Lvl 3, Esqueleto Lvl 2 and enemy Rajada, JSON/CSV/Markdown scenario, battle, AutoRun, lab-diff and card-impact reports, presets/case matrix/macro policies/aggregate reports/scorecards/statistical baseline comparison, docs/playtest-track-02.md checklist, docs/autorun-lab.md tool contract, docs/foundation-closeout.md ownership/debt map, idempotent generated slice catalog hashing, catalog source loader seam for future domain splits, internal enemy-turn/intent and combat/damage resolution directors, reward and Souls shop service delegation, battle preview/HUD/combat-FX presenters, and first tuning pass keeping upgrade rewards level-only to hit final deck-size targets.`
- Active Goal: `user playtest of Track 02 complete-run build`
- Validation: `2026-06-05 Card Impact Effect Signature V2 passed: run_card_impact --phase=before/after/compare --mode=gate --pack=track02_card_impact_v2 --cards=all --components=battle,scenario,run_lab --out=user://card_impact/v2_all_gate green with 84/84 active card cases, 54/54 required player-card effect signatures, 30 enemy cards in report-only signature mode, 15 audited legacy inactive elemental cards, zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes in same/same compare; V1 regression before/after/compare also green; run_battle_lab --mode=gate --pack=track02_battle_core_v1 green with 12 isolated BattleEngine cases, 9 PASS, 3 WARN and 0 FAIL; run_scenarios --mode=gate --pack=track02_core_v1 green with 12 scenarios, 9 PASS, 3 WARN and 0 FAIL; run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1 green; run_lab --mode=gate --preset=quick --baseline=track02_quick_v1 green across 30 macro-route cases; validate.gd passed with 154/154 GUT tests, 1575 asserts, shared full-route pacing smoke 29/29 maps, 217 estimated turns, 116 estimated HP loss, 0 deaths, 362 Souls earned, 291 Souls spent, 71 Souls left, 38-card final deck, 6 relics, and 21 shop actions. Human playtest and broader balance feedback remain pending.`

## Read Next

- `../AGENTS.md`
- `../../canon/canon-brief.md`
- `../docs/product-brief.md`
- `../docs/game-design-document.md`
- `../docs/design-early-game.md`
- `../docs/architecture.md`
- `../docs/autorun-lab.md`
- `../docs/foundation-closeout.md`
- `../docs/reuse-map.md`
- `tracks/track-02-complete-run-evolution/current-status.md`
- `tracks/track-02-complete-run-evolution/design-brief.md`
- `tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md`
- `tracks/track-02-complete-run-evolution/handoff-log.md`

Historical reference only:

- `tracks/track-00-project-bootstrap/current-status.md`
- `tracks/track-00-project-bootstrap/linear-execution-plan.md`
- `tracks/track-01-playable-run-loop/current-status.md`
- `tracks/track-01-playable-run-loop/linear-execution-plan.md`

## Validation

```powershell
D:\Estudio\.local-tools\godot\4.6.2\Godot_v4.6.2-stable_win64_console.exe --headless --path D:\Estudio\Projetos\draxos-roguelike-cardgame -s res://tools/validate.gd
```

## Next

Track 02 is ready for user playtest and for the first meaningful player-card redesign batch using Card Impact V2. Use `docs/playtest-track-02.md` for the human checklist and `tracks/track-02-complete-run-evolution/validation-and-tuning-notes.md` for metrics and known debt; use `track02_card_impact_v2` before/change/after/compare to inspect structural regressions, final metrics and player-card effect signatures before accepting broader card edits.
