# Current Status

- Last Updated: `2026-06-06`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 29-map complete-run roguelike cardgame production plan`
- Active Track: `Track 02 - Complete Run Evolution`
- Active Track Status: `T02-P09_COMPLETE`
- Current Operational Baseline: `Godot 4.6.2 Track 02 complete-run build with foundation closeout, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1, Card Impact Smoke Tuning V1, Card Impact Effect Signature V2, Card Impact V2 Non-Damage Coverage, Card Impact V3 Isolated Target Capture, Card Redesign Batch 01, Player Card Redesign Batch 02, Card Impact V4 Full Player Matrix, Reward Card Redesign Batch 01 Using V4, Reward Card Redesign Batch 02 Utility Using V4 and Card Impact V4.1 Card-Flow Harness Pass: fixed 29-map route, save/snapshot version 5, production reward schedule, universal relics, expanded Souls shop, keyword tooltip vocabulary, all Track 02 keyword mechanics, 8 reward cards per class with upgrades, Terra/Gelo/Ar/Fogo enemy galleries, deterministic hybrid enemy AI, visible enemy intent, encounter modes, board formats, elemental field effects, boss hooks for maps 8/15/22/29, polished reward/map/shop/relic/keyword/intent/battle readability, discard marks folded into the main creature-play phase, 5/5, 6/6, and 7/7 layout coverage, shared route pacing simulator for validation and AutoRun Lab, exact golden comparison for approved Track 02 class/seed regressions, official smoke/quick gate baselines in data/lab/baselines, explicit AutoRun --mode=gate regression commands, Scenario Fixture pack data/lab/scenarios/track02_core_v1.json, Gameplay Battle pack data/lab/battles/track02_battle_core_v1.json, deterministic legal-action policies baseline/aggressive/defensive/end-turn-only/card-focus/card-focus-isolated, PASS/WARN/FAIL expectations, tools/compare_lab_reports.gd before/after diff runner, Card Impact packs v1/v2/v3/v4/v4_1, V4/V4.1 full player matrix covering 108 player card variants plus 30 enemy report-only cards and 15 audited legacy inactive elemental cards, V4 temporary ability power utility signatures, V4.1 card-flow observability for draw/deck/hand/discard deltas, V4 reward-card before/change/after/compare workflow proven on damage/shield/summon/poison/economy plus utility/control/economy/card-flow changes, JSON/CSV/Markdown scenario, battle, AutoRun, lab-diff and card-impact reports, presets/case matrix/macro policies/aggregate reports/scorecards/statistical baseline comparison, docs/playtest-track-02.md checklist, docs/autorun-lab.md tool contract, docs/foundation-closeout.md ownership/debt map, idempotent generated slice catalog hashing, catalog source loader seam for future domain splits, internal enemy-turn/intent and combat/damage resolution directors, reward and Souls shop service delegation, battle preview/HUD/combat-FX presenters, and first tuning pass keeping upgrade rewards level-only to hit final deck-size targets.`
- Current Tooling Addendum: `Card Impact V4.1 is now the default card-change harness when player card-flow movement may matter. It preserves V4 coverage of 108 player cards / 30 enemy report-only cards / 15 legacy inactive cards, adds expected card-flow coverage for necro_colheita_das_almas and necro_colheita_das_almas_lvl3, records lab-only initial_dead_unit_count prestate for the lvl3 threshold case, and reports card_flow_expected/card_flow_observed/card_flow_missing_reason plus cards_drawn, deck_delta, hand_delta and discard_delta as review data. V4 remains intact as the historical baseline.`
- Current Tuning Addendum: `Reward Card Redesign Batch 02 Utility Using V4 changed four player reward/card variants: arcano_acelerar_lvl3 temporary ability power 3->4, arcano_vortice frozen duration 1->2, arcano_vortice_lvl2 frozen duration 1->2, and necro_colheita_das_almas Ashes 2->3 with draw_if_at_least=3. Card Impact V4 detected 4 changed battle records and 7 metric/effect deltas while Scenario Fixtures, Run Lab smoke/quick and validate pacing stayed unchanged.`
- Active Goal: `user playtest of Track 02 complete-run build`
- Validation: `2026-06-05 Card Impact V2 Non-Damage Coverage passed: Card Impact V2 before/after/compare --mode=gate --pack=track02_card_impact_v2 --out=user://card_impact/track02_card_impact_v2_non_damage_coverage green with zero structural errors, zero new failures and zero removed records, covering 84/84 active cards; compare report shows 54 required player signatures, 30 enemy report-only missing signatures, non-damage families buff/control/debuff/economy/keyword/summon, and support quality 45 clean / 9 support-assisted / 47 ambiguous / 30 enemy report-only missing; run_battle_lab --mode=gate --pack=track02_battle_core_v1 green with 9 PASS, 3 WARN and 0 FAIL; run_scenarios --mode=gate --pack=track02_core_v1 green with 9 PASS, 3 WARN and 0 FAIL; run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1 green; run_lab --mode=gate --preset=quick --baseline=track02_quick_v1 green across 30 macro-route cases; validate.gd passed with 157/157 GUT tests, shared full-route pacing smoke 29/29 maps, 217 estimated turns, 116 estimated HP loss, 0 deaths, 362 Souls earned, 291 Souls spent, 71 Souls left, 38-card final deck, 6 relics and 21 shop actions. Non-fatal visual asset/ship alpha warnings remain known. Human playtest and broader balance feedback remain pending.`
- Latest Validation Addendum: `2026-06-06 Card Impact V4.1 Card-Flow Harness Pass completed: run_card_impact before/after/compare --mode=gate --pack=track02_card_impact_v4_1 --out=user://card_impact/track02_card_impact_v4_1_card_flow_harness green with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, 2 expected card-flow player cards, zero structural errors, zero new failures and zero removed records. Focused card-flow probes observed necro_colheita_das_almas and necro_colheita_das_almas_lvl3 drawing 1 card with deck_delta -1; lvl3 used lab_prestate initial_dead_unit_count=2 and observed ashes_gained=6. V4 historical compare remained green at user://card_impact/reward_card_redesign_batch_02_utility_v4. Battle Lab remains 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke and quick gates remain green; validate.gd passed with 185/185 GUT tests and 1766 asserts. Known optional visual asset, GUT resource and ship alpha warnings remain non-fatal.`

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

Track 02 is ready for user playtest. Recommended next implementation step: use Card Impact V4.1 in a real small card-flow redesign batch with the full `before -> change -> after -> compare` cycle, then promote any useful thresholds or report sections discovered by that batch. Enemy-card signature derivation remains the next tooling follow-up once enemy per-card causality is explicit enough.
