# Current Status

- Last Updated: `2026-06-06`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 29-map complete-run roguelike cardgame production plan`
- Active Track: `Track 02 - Complete Run Evolution`
- Active Track Status: `T02-P09_COMPLETE`
- Current Operational Baseline: `Godot 4.6.2 Track 02 complete-run build with foundation closeout, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1, Card Impact Smoke Tuning V1, Card Impact Effect Signature V2, Card Impact V2 Non-Damage Coverage, Card Impact V3 Isolated Target Capture, Card Redesign Batch 01, Player Card Redesign Batch 02, Card Impact V4 Full Player Matrix, Reward Card Redesign Batch 01 Using V4, Reward Card Redesign Batch 02 Utility Using V4, Card Impact V4.1 Card-Flow Harness Pass, Card Flow Redesign Batch 01 Using V4.1, Card Impact V4.2 Card Flow Expectations, Reward Card Redesign Batch 03 Using V4.2, Card Impact V5 Enemy Causal Signatures, Enemy Card Redesign Batch 01 Using V5 and Enemy Card Redesign Batch 02 Using V5 Terra: fixed 29-map route, save/snapshot version 5, production reward schedule, universal relics, expanded Souls shop, keyword tooltip vocabulary, all Track 02 keyword mechanics, 8 reward cards per class with upgrades, Terra/Gelo/Ar/Fogo enemy galleries, deterministic hybrid enemy AI, visible enemy intent, encounter modes, board formats, elemental field effects, boss hooks for maps 8/15/22/29, polished reward/map/shop/relic/keyword/intent/battle readability, discard marks folded into the main creature-play phase, 5/5, 6/6, and 7/7 layout coverage, shared route pacing simulator for validation and AutoRun Lab, exact golden comparison for approved Track 02 class/seed regressions, official smoke/quick gate baselines in data/lab/baselines, explicit AutoRun --mode=gate regression commands, Scenario Fixture pack data/lab/scenarios/track02_core_v1.json, Gameplay Battle pack data/lab/battles/track02_battle_core_v1.json, deterministic legal-action policies baseline/aggressive/defensive/end-turn-only/card-focus/card-focus-isolated, PASS/WARN/FAIL expectations, tools/compare_lab_reports.gd before/after diff runner, Card Impact packs v1/v2/v3/v4/v4_1/v4_2/v5, V4/V4.1/V4.2/V5 full player matrix covering 108 player card variants plus 30 active enemy cards and 15 audited legacy inactive elemental cards, V4 temporary ability power utility signatures, V4.1 card-flow observability for draw/deck/hand/discard deltas, V4.2 explicit card-flow expectations for the three Colheita variants, V5 required causal enemy-card signatures with play/combat enemy_* fields, V4/V4.1/V4.2/V5 before/change/after/compare workflow proven on damage/shield/summon/poison/economy plus utility/control/economy/card-flow/enemy-causality coverage, JSON/CSV/Markdown scenario, battle, AutoRun, lab-diff and card-impact reports, presets/case matrix/macro policies/aggregate reports/scorecards/statistical baseline comparison, docs/playtest-track-02.md checklist, docs/autorun-lab.md tool contract, docs/foundation-closeout.md ownership/debt map, idempotent generated slice catalog hashing, catalog source loader seam for future domain splits, internal enemy-turn/intent and combat/damage resolution directors, reward and Souls shop service delegation, battle preview/HUD/combat-FX presenters, and first tuning pass keeping upgrade rewards level-only to hit final deck-size targets.`
- Current Tooling Addendum: `Card Impact V5 is now the recommended harness before broad enemy-card redesigns. It preserves V4.2 coverage of 108 player cards / 30 enemy cards / 15 legacy inactive cards, keeps the three Colheita card-flow expectations at 21/21 PASS, and promotes all 30 enemy cards to required causal signatures using a controlled BattleEngine commander harness. V4.2 remains the default player-card-flow harness; V1-V4.2 remain intact as historical baselines.`
- Current Tuning Addendum: `Reward Card Redesign Batch 03 Using V4.2 applied 12 light reward-card edits across Arcano, Invocador and Necromante without changing labs, route, enemies, shop, relics or reward schedule. The batch exercises V4.2 impact reporting across damage, control, shield/buff, summon and health signatures while preserving Colheita card-flow expectations.`
- Current Enemy Tuning Addendum: `Enemy Card Redesign Batch 01 Using V5 applied 6 light enemy-card edits across Gelo, Ar and Fogo, and Enemy Card Redesign Batch 02 Using V5 Terra applied 2 focused Terra edits: enemy_terra_elemental_tita attack 3->2 and enemy_terra_elemental_granito health 7->8. Both batches avoided lab/tooling, player-card, route, encounter, shop, relic and reward-schedule changes. Batch 02 deliberately avoided the earlier unsafe Terra probe targets and kept Battle Lab green.`
- Active Goal: `user playtest of Track 02 complete-run build`
- Validation: `2026-06-05 Card Impact V2 Non-Damage Coverage passed: Card Impact V2 before/after/compare --mode=gate --pack=track02_card_impact_v2 --out=user://card_impact/track02_card_impact_v2_non_damage_coverage green with zero structural errors, zero new failures and zero removed records, covering 84/84 active cards; compare report shows 54 required player signatures, 30 enemy report-only missing signatures, non-damage families buff/control/debuff/economy/keyword/summon, and support quality 45 clean / 9 support-assisted / 47 ambiguous / 30 enemy report-only missing; run_battle_lab --mode=gate --pack=track02_battle_core_v1 green with 9 PASS, 3 WARN and 0 FAIL; run_scenarios --mode=gate --pack=track02_core_v1 green with 9 PASS, 3 WARN and 0 FAIL; run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1 green; run_lab --mode=gate --preset=quick --baseline=track02_quick_v1 green across 30 macro-route cases; validate.gd passed with 157/157 GUT tests, shared full-route pacing smoke 29/29 maps, 217 estimated turns, 116 estimated HP loss, 0 deaths, 362 Souls earned, 291 Souls spent, 71 Souls left, 38-card final deck, 6 relics and 21 shop actions. Non-fatal visual asset/ship alpha warnings remain known. Human playtest and broader balance feedback remain pending.`
- Latest Validation Addendum: `2026-06-06 Card Impact V5 Enemy Causal Signatures completed: Card Impact V5 before/after/compare passed in gate mode at user://card_impact/track02_card_impact_v5_enemy_causal_signatures with 108 player cards, 30 enemy cards, 15 legacy inactive cards, zero structural errors, zero new failures, zero removed records, 30/30 required enemy signatures present, 30/30 enemy cards played, 30 clean enemy signatures, 0 ambiguous, 0 missing, and Card Flow Expectations still 21/21 PASS. V4.2 historical compare at user://card_impact/reward_card_redesign_batch_03_v4_2 stayed green. Battle Lab remains 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke and quick gates remain green; validate.gd passed with 211/211 GUT tests and 1906 asserts. Known optional visual asset, GUT resource and ship alpha warnings remain non-fatal.`
- Latest Enemy Batch Validation Addendum: `2026-06-06 Enemy Card Redesign Batch 02 Using V5 Terra completed: Card Impact V5 before/after/compare passed at user://card_impact/enemy_card_redesign_batch_02_v5_terra with zero structural errors, zero new failures, zero removed records and zero status changes. Final compare shows 2 changed enemy records, 4 effect changes, enemy_terra_elemental_tita moving enemy_summoned_attack_total and enemy combat/hero damage 3->2, enemy_terra_elemental_granito moving enemy_summoned_health_total 7->8, 30/30 enemy signatures still present, 30 clean enemy signatures, 0 missing/not-played enemy cards, and 21/21 Card Flow Expectations passing. V4.2 historical compare stayed green; Battle Lab stayed 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures stayed 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke/quick gates stayed green; validate.gd passed with 211/211 GUT tests and 1906 asserts.`

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

Track 02 is ready for user playtest. Recommended next step: run a manual Track 02 playtest before more tuning; if implementation continues first, use Card Impact V5 for a very small Enemy Card Redesign Batch 03 only after reviewing the Batch 02 Terra report.
