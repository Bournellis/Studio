# Current Status

- Last Updated: `2026-06-06`
- Active Project Name: `draxos-roguelike-cardgame`
- Active Surface: `linear 29-map complete-run roguelike cardgame production plan`
- Active Track: `Track 02 - Complete Run Evolution`
- Active Track Status: `T02-P09_COMPLETE`
- Current Operational Baseline: `Godot 4.6.2 Track 02 complete-run build with foundation closeout, AutoRun Gate Pack V1, Scenario Fixtures V1, Gameplay Lab V1, Lab Diff Reporter V1, Card Impact Pack V1, Card Impact Smoke Tuning V1, Card Impact Effect Signature V2, Card Impact V2 Non-Damage Coverage, Card Impact V3 Isolated Target Capture, Card Redesign Batch 01, Player Card Redesign Batch 02, Card Impact V4 Full Player Matrix, Reward Card Redesign Batch 01 Using V4, Reward Card Redesign Batch 02 Utility Using V4, Card Impact V4.1 Card-Flow Harness Pass, Card Flow Redesign Batch 01 Using V4.1 and Card Impact V4.2 Card Flow Expectations: fixed 29-map route, save/snapshot version 5, production reward schedule, universal relics, expanded Souls shop, keyword tooltip vocabulary, all Track 02 keyword mechanics, 8 reward cards per class with upgrades, Terra/Gelo/Ar/Fogo enemy galleries, deterministic hybrid enemy AI, visible enemy intent, encounter modes, board formats, elemental field effects, boss hooks for maps 8/15/22/29, polished reward/map/shop/relic/keyword/intent/battle readability, discard marks folded into the main creature-play phase, 5/5, 6/6, and 7/7 layout coverage, shared route pacing simulator for validation and AutoRun Lab, exact golden comparison for approved Track 02 class/seed regressions, official smoke/quick gate baselines in data/lab/baselines, explicit AutoRun --mode=gate regression commands, Scenario Fixture pack data/lab/scenarios/track02_core_v1.json, Gameplay Battle pack data/lab/battles/track02_battle_core_v1.json, deterministic legal-action policies baseline/aggressive/defensive/end-turn-only/card-focus/card-focus-isolated, PASS/WARN/FAIL expectations, tools/compare_lab_reports.gd before/after diff runner, Card Impact packs v1/v2/v3/v4/v4_1/v4_2, V4/V4.1/V4.2 full player matrix covering 108 player card variants plus 30 enemy report-only cards and 15 audited legacy inactive elemental cards, V4 temporary ability power utility signatures, V4.1 card-flow observability for draw/deck/hand/discard deltas, V4.2 explicit card-flow expectations for the three Colheita variants, V4/V4.1/V4.2 reward-card before/change/after/compare workflow proven on damage/shield/summon/poison/economy plus utility/control/economy/card-flow changes, JSON/CSV/Markdown scenario, battle, AutoRun, lab-diff and card-impact reports, presets/case matrix/macro policies/aggregate reports/scorecards/statistical baseline comparison, docs/playtest-track-02.md checklist, docs/autorun-lab.md tool contract, docs/foundation-closeout.md ownership/debt map, idempotent generated slice catalog hashing, catalog source loader seam for future domain splits, internal enemy-turn/intent and combat/damage resolution directors, reward and Souls shop service delegation, battle preview/HUD/combat-FX presenters, and first tuning pass keeping upgrade rewards level-only to hit final deck-size targets.`
- Current Tooling Addendum: `Card Impact V4.2 is now the default card-change harness when player card-flow movement may matter. It preserves V4.1 coverage of 108 player cards / 30 enemy report-only cards / 15 legacy inactive cards, expects 3 card-flow player cases, keeps the V4.1 card-flow harness/prestate, and promotes Colheita base/Lvl 2/Lvl 3 to explicit required expectations: card_flow_observed true, cards_drawn >= 2, deck_delta <= -2 and hand_delta >= 1. Exact current values stay as watch checks. V4 and V4.1 remain intact as historical baselines.`
- Current Tuning Addendum: `Card Flow Redesign Batch 01 Using V4.1 changed Colheita card-flow semantics deliberately: draw_if_at_least now resolves as a bonus draw after normal hand refill, Colheita das Almas / Lvl 3 now say compra 1 carta extra, and necro_colheita_das_almas_lvl2 changed Ashes 2->3 plus draw_if_at_least=3, entering the expected card-flow matrix. Card Impact V4.1 compare detected 3 changed battle records and 11 card-flow/economy deltas with no structural regression.`
- Active Goal: `user playtest of Track 02 complete-run build`
- Validation: `2026-06-05 Card Impact V2 Non-Damage Coverage passed: Card Impact V2 before/after/compare --mode=gate --pack=track02_card_impact_v2 --out=user://card_impact/track02_card_impact_v2_non_damage_coverage green with zero structural errors, zero new failures and zero removed records, covering 84/84 active cards; compare report shows 54 required player signatures, 30 enemy report-only missing signatures, non-damage families buff/control/debuff/economy/keyword/summon, and support quality 45 clean / 9 support-assisted / 47 ambiguous / 30 enemy report-only missing; run_battle_lab --mode=gate --pack=track02_battle_core_v1 green with 9 PASS, 3 WARN and 0 FAIL; run_scenarios --mode=gate --pack=track02_core_v1 green with 9 PASS, 3 WARN and 0 FAIL; run_lab --mode=gate --preset=smoke --baseline=track02_smoke_v1 green; run_lab --mode=gate --preset=quick --baseline=track02_quick_v1 green across 30 macro-route cases; validate.gd passed with 157/157 GUT tests, shared full-route pacing smoke 29/29 maps, 217 estimated turns, 116 estimated HP loss, 0 deaths, 362 Souls earned, 291 Souls spent, 71 Souls left, 38-card final deck, 6 relics and 21 shop actions. Non-fatal visual asset/ship alpha warnings remain known. Human playtest and broader balance feedback remain pending.`
- Latest Validation Addendum: `2026-06-06 Card Impact V4.2 Card Flow Expectations completed: Card Impact V4.2 before/after/compare passed in gate mode at user://card_impact/track02_card_impact_v4_2_card_flow_expectations with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, 3 expected card-flow player cards, zero structural errors, zero new failures and zero removed records. Card Flow Expectations passed 21/21 checks with 0 WARN, 0 FAIL and 0 required failures; each Colheita variant satisfied card_flow_observed true, cards_drawn >= 2, deck_delta <= -2 and hand_delta >= 1. V4.1 historical compare at user://card_impact/card_flow_redesign_batch_01_v4_1 stayed green. Battle Lab remains 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke and quick gates remain green; validate.gd passed with 199/199 GUT tests and 1827 asserts. Known optional visual asset, GUT resource and ship alpha warnings remain non-fatal.`

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

Track 02 is ready for user playtest. Recommended next implementation step: run the next broader reward-card redesign batch using Card Impact V4.2 `before -> change -> after -> compare`, keeping explicit card-flow expectations aligned with any intentional draw/deck/hand behavior changes. Enemy-card signature derivation remains the next tooling follow-up once enemy per-card causality is explicit enough.
