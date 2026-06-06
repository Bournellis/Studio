# Track 02 Validation And Tuning Notes

- Last Updated: `2026-06-06`
- Prompt: `REWARD-CARD-REDESIGN-BATCH-02-UTILITY-USING-V4`
- Status: `REWARD_CARD_REDESIGN_BATCH_02_UTILITY_V4_COMPLETE`

## Validation Summary

- Godot validation command: green.
- GUT: `175/175` tests passing.
- Full-route pacing smoke: `29/29` maps completed.
- Estimated route turns: `217`.
- Estimated HP loss across route: `116`.
- Deaths in deterministic smoke: `0`.
- Souls earned/spent/left: `362 / 291 / 71`.
- Final deck size: `38`.
- Relic count: `6`.
- Shop usage count: `21`.
- Shared simulator: `tools/route_pacing_simulator.gd`.
- AutoRun Lab: `tools/run_lab.gd` now supports presets, case matrices, macro policies, detailed JSON, compatibility CSV/JSON, aggregate JSON/CSV/Markdown reports, scorecard JSON/Markdown, timeline records, official gate baselines and statistical baseline comparison through `tools/lab/`.
- Golden metrics: `tools/run_lab_golden_metrics.gd` protects Arcano seed `20260518` exact metrics and checks Invocador/Necromante completion/no-death contracts.
- Run Lab parity: `--compare-golden --require-golden` passes for Arcano, Invocador, and Necromante with seed `20260518`.
- AutoRun gate smoke: `--mode=gate --preset=smoke --baseline=track02_smoke_v1` passes the official 3-case smoke envelope.
- AutoRun gate quick: `--mode=gate --preset=quick --baseline=track02_quick_v1` passes 30 macro-route cases and writes scorecard output.
- Official gate baselines: `data/lab/baselines/track02_smoke_v1.json` and `data/lab/baselines/track02_quick_v1.json`.
- Card Impact Pack: `tools/run_card_impact.gd` runs explicit `before`, `after` and `compare` phases for `data/lab/card_impact/track02_card_impact_v1.json`, `data/lab/card_impact/track02_card_impact_v2.json`, `data/lab/card_impact/track02_card_impact_v3.json` and `data/lab/card_impact/track02_card_impact_v4.json`.
- Card Impact V4 coverage: 108 active player class/reward card variants, 30 active enemy cards in report-only signature mode and 15 legacy inactive `elemental_*` cards audited.
- Card Impact gate: `--phase=before --mode=gate`, `--phase=after --mode=gate` and `--phase=compare --mode=gate` all pass for the latest V4 reward-card redesign cycle; compare reports zero structural errors, zero new failures, zero removed records and zero status changes across battle/scenario/run_lab components.
- Card Impact smoke-tuning output: `user://card_impact/smoke_tuning_v1` reports one expected metric-impact row for `enemy_ar_rajada`: `damage_to_player_hero` `4 -> 5` and isolated harness `player_hp` `56 -> 55`.
- Card Impact reports: `card_impact_results.json`, `card_impact_results.csv`, `card_impact_summary.json`, `card_impact_summary.md`, `card_impact_gate.md`, plus component `before/`, `after/` and `compare/` output directories under `user://card_impact/track02_card_impact_v1`.
- Card Impact Effect Signature V2: `track02_card_impact_v2` requires derived player-card signatures from real BattleEngine snapshots/log deltas, keeps enemy signatures report-only, and reports `effect.*` diffs, effect-family matrices, top effect-delta cards and missing signatures.
- Card Impact V2 gate: `before`, `after` and `compare` pass at `user://card_impact/v2_all_gate` with 84/84 active cases, 54/54 required player effect signatures, 30 enemy cards report-only, 15 audited legacy inactive cards, zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes in same/same compare.
- Card Redesign Batch 01 gate: `before`, `after` and `compare` pass at `user://card_impact/redesign_batch_01` with zero structural errors, zero new failures, zero removed records, zero status changes, 9 metric deltas and 3 effect deltas from the intended Arcano damage-upgrade changes.
- Card Redesign Batch 01 effect deltas: `arcano_choque_lvl2` `effect.enemy_hero_damage` `52 -> 57`, `arcano_choque_lvl3` `86 -> 92`, and `arcano_tempestade_lvl3` `57 -> 62`.
- Card Redesign Batch 01 regression gates: V1 Card Impact same/same regression passes, Battle Lab remains `9 PASS / 3 WARN / 0 FAIL`, Scenario Fixtures remains `9 PASS / 3 WARN / 0 FAIL`, AutoRun smoke passes, AutoRun quick passes and `validate.gd` passes with `154/154` tests and `1575` asserts.
- Card Impact V2 Non-Damage Coverage gate: `before`, `after` and `compare` pass at `user://card_impact/track02_card_impact_v2_non_damage_coverage` with 84/84 active cards covered, zero structural errors, zero new failures and zero removed records.
- Card Impact V2 Non-Damage Coverage signatures: 54 required player signatures present, 30 enemy signatures report-only/missing as expected, 45 clean player signatures, 9 support-assisted signatures, 47 ambiguous signatures from repeated focused-card plays, and non-damage families `buff`, `control`, `debuff`, `economy`, `keyword` and `summon` visible in the Markdown matrix.
- Card Impact V3 Isolated Target Capture gate: `before`, `after` and `compare` pass at `user://card_impact/track02_card_impact_v3_isolated_target_capture` with 84/84 active cards covered, zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes.
- Card Impact V3 capture quality: player-card target captures are 45 clean, 9 support-required, 0 ambiguous, 0 failed and 0 repeated; enemy-card signatures remain report-only and do not count as isolated capture failures.
- Card Impact V4 Full Player Matrix gate: `before`, `after` and `compare` pass at `user://card_impact/track02_card_impact_v4_full_player_matrix` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, zero structural errors, zero new failures and zero removed records.
- Card Impact V4 utility signatures: `temporary_ability_power_delta`, `temporary_ability_power_gained` and `temporary_ability_power_lost` are now captured, aggregated, classified as utility and included in `effect.*` diffs plus Card Impact Markdown reporting.
- Card Impact V4 regression coverage: `track02_card_impact_v3` compare remains green at `user://card_impact/player_card_redesign_batch_02`; Battle Lab remains 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke and quick remain green.
- Reward Card Redesign Batch 01 Using V4 gate: `before`, `after` and `compare` pass at `user://card_impact/reward_card_redesign_batch_01_v4` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, zero structural errors, zero new failures, zero removed records, 6 changed battle records and 15 metric/effect deltas.
- Reward Card Redesign Batch 01 Using V4 regression coverage: Battle Lab remains 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke and quick remain green; `validate.gd` passes with 175/175 GUT tests and unchanged pacing telemetry.
- Reward Card Redesign Batch 02 Utility Using V4 gate: `before`, `after` and `compare` pass at `user://card_impact/reward_card_redesign_batch_02_utility_v4` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, zero structural errors, zero new failures, zero removed records, 4 changed battle records and 7 metric/effect deltas.
- Reward Card Redesign Batch 02 Utility Using V4 regression coverage: Battle Lab remains 9 PASS / 3 WARN / 0 FAIL; Scenario Fixtures remains 9 PASS / 3 WARN / 0 FAIL; AutoRun smoke and quick remain green; `validate.gd` passes with 175/175 GUT tests and unchanged pacing telemetry.
- Foundation Pass 4 added the golden comparison harness without changing route metrics or gameplay behavior.
- Foundation Pass 5 moved Souls shop offers/mutations/sync into `core/run_shop_service.gd` behind `RunSession` wrappers without changing route metrics, shop economy, or gameplay behavior.
- Foundation Pass 6 moved BattleRoot HUD/objective readouts and combat FX filtering/text/state projection into pure presenters without changing route metrics, UI layout, drag/drop, or gameplay behavior.
- Foundation Pass 7 added `tools/catalog_source_loader.gd` and GUT coverage for single-JSON semantic equivalence plus future catalog domains without changing route metrics, generated resource semantics, or gameplay behavior.
- Foundation Pass 8 moved staged combat, manual attack, slot damage, hero damage, and destruction queue handling into `battle/combat_resolution_director.gd` with wrapper/director parity coverage and without changing route metrics or gameplay behavior.
- Foundation Pass 9 closed the foundation review in docs only, added `docs/foundation-closeout.md`, refreshed the architecture ownership map, and separated product/playtest follow-up from optional technical extraction debt.

## First Tuning Pass

- Reward schedule remains unchanged.
- Shop prices remain at the approved Track 02 defaults.
- Enemy global stats were not inflated; difficulty remains driven by element identity, AI, modes, field effects, and boss hooks.
- Upgrade rewards no longer add extra deck copies by rarity in Track 02. This keeps upgrade rewards as level improvements and moved the deterministic full-route smoke from `43` final cards to `38`, matching the first-test deck-size target.
- Current full-route smoke leans recovery-heavy, with repeated healing purchases and two max HP purchases. That is acceptable for user playtest because there is no permanent account progression yet.

## Card Impact Smoke Tuning V1

- Purpose: test the `before -> change -> after -> compare` workflow on a real but intentionally small card batch.
- Player card changes:
  - `arcano_choque_lvl2`: damage `3 -> 4`, text updated.
  - `arcano_choque_lvl3`: damage `3 -> 4`, text updated.
  - `invocador_batedor_lvl3`: attack `6 -> 5`.
  - `necro_esqueleto_lvl2`: health `2 -> 3`.
- Enemy card change:
  - `enemy_ar_rajada`: attack `4 -> 5`.
- Card Impact compare result: PASS with 84/84 active cases covered, 15 legacy inactive `elemental_*` cards audited, no structural errors, no new failures, no removed records, no status changes and 2 metric deltas on the `enemy_ar_rajada` isolated enemy-card case.
- Existing gates after the tuning: Battle Lab `9 PASS / 3 WARN / 0 FAIL`, Scenario Fixtures `9 PASS / 3 WARN / 0 FAIL`, AutoRun smoke green, AutoRun quick green, `validate.gd` green with `148/148` tests and `1544` asserts.
- Operational note: a temporary probe on `enemy_terra_guerreiro_terra` produced Battle Lab map 8 failures and was not kept. This proved the broader lab stack can catch an unsafe "small" enemy-card change even when Card Impact itself remains structurally green.
- Tooling note: the player-card edits changed logs/effects but did not move the final metrics currently compared by Card Impact. Future Card Impact V2 should consider log-derived effect deltas for player-card cases, or stronger harness objectives that expose player-card numeric changes without relying only on final HP/turn fields.

## Card Impact Effect Signature V2

- Purpose: expose player-card effect movement that final HP/turn metrics can miss when the deterministic harness clears the board quickly.
- Scope: tooling only; no gameplay, card, enemy, reward, shop, route or balance changes.
- New pack: `data/lab/card_impact/track02_card_impact_v2.json`.
- New signature utility: `tools/lab/battle_effect_signature.gd`.
- Player cases: `card_focus_legal` captures snapshots around the focused card play and records `card_effect_samples`, `card_effect_signature`, `card_effect_signature_present` and `effect_families`.
- Enemy cases: schema is prepared, but signatures are `report_only` and do not fail V2 gate yet.
- Derived fields include hero damage, slot damage, summons, ally buffs, enemy debuffs, poison/freeze/shield additions, mana/ashes gains, cards drawn/discarded, pending choices, log/visual-event deltas, keyword deltas and effect families.
- Compare behavior: effect signature deltas appear as `effect.*` metric changes and feed `effect_changes`, `top_effect_delta_cards`, `by_effect_family` and `missing_signatures`.
- Gate behavior: missing required player signatures fail; effect deltas are review data and do not fail by themselves.
- Validation result: V2 before/after/compare, V1 regression before/after/compare, Battle Lab, Scenario Fixtures, AutoRun smoke, AutoRun quick and `validate.gd` all pass on 2026-06-05.

## Card Redesign Batch 01

- Purpose: execute a real but deliberately narrow card-change cycle to test the lab stack, not to claim final balance.
- Final card changes:
  - `arcano_choque_lvl2`: damage `4 -> 5`, text updated.
  - `arcano_choque_lvl3`: damage `4 -> 5`, text updated.
  - `arcano_tempestade_lvl3`: random damage `6 -> 7`, text updated.
- Tooling calibration kept with the batch: damage-family Card Impact player harnesses now use `enemy_health=160` and `enemy_terra_elemental_tita` to prevent overkill from hiding effect-signature movement.
- Card Impact V2 compare result: PASS with zero structural errors, zero new failures, zero removed records, zero status changes, 9 metric deltas and 3 effect deltas.
- Observed effect deltas:
  - `card_impact_player_arcano_choque_lvl2`: `effect.enemy_hero_damage` `52 -> 57`.
  - `card_impact_player_arcano_choque_lvl3`: `effect.enemy_hero_damage` `86 -> 92`.
  - `card_impact_player_arcano_tempestade_lvl3`: `effect.enemy_hero_damage` `57 -> 62`.
- Observed final metric deltas: the three affected battle harnesses showed lower `enemy_hp`, higher `damage_to_enemy_hero`, and matching `effect.enemy_hero_damage` movement; Scenario and Run Lab component gates did not regress.
- Operational lesson: changing base/support cards can contaminate many focused cases because they appear as helper cards in deterministic harnesses. Future redesign batches should either isolate upgrades like this batch or explicitly label support-card-wide movement as intended.
- Next tooling recommendation: strengthen V2 for non-damage families before a large redesign pass by comparing summon stat totals, ally buff totals, enemy debuff/control markers, economy/card-flow fields and support-card contamination signals more directly.

## Card Impact V2 Non-Damage Coverage

- Purpose: make Card Impact V2 useful for future large card redesigns that affect more than direct damage.
- Scope: tooling only; no gameplay, card, enemy, reward, shop, route or balance changes.
- `track02_card_impact_v2.json` now declares `effect_signatures.schema_version=2`.
- New derived fields cover summon aliases/totals, summoned keywords, ally keyword/shield/resistance gains, enemy keyword loss, poison/freeze/snare control, card-flow deltas, pending choices, sacrifice counters, log/visual-event deltas and support-card metadata.
- `card_focus_legal` now tags focused-card samples with support played before the target card.
- `BattleRunner` now stores card play sequence, focused card play index, support before/after target, support counts, contamination status, signature confidence and ambiguity reason.
- Compare now includes the expanded `effect.*` field set and aggregates quality from the `after` battle results so same/same compares still show non-damage coverage.
- Markdown now includes `Non-Damage Coverage Matrix` and `Support Contamination`.
- Final observed compare at `user://card_impact/track02_card_impact_v2_non_damage_coverage`:
  - Gate: PASS.
  - Coverage: 84/84 active cards.
  - Required player signatures: 54/54.
  - Enemy signatures: 30 report-only/missing expected.
  - Quality: 45 clean, 9 support-assisted, 47 ambiguous, 30 enemy report-only missing.
  - Families: `buff`, `control`, `debuff`, `economy`, `keyword`, `summon`.
- Operational lesson: support before the focused card is real signature contamination; cards played after the focused-card snapshot are still reported but should not mark the signature support-assisted. Ambiguity remains high because the current policy can play the focused card more than once.
- Follow-up status: the isolated target-card capture recommendation from V2 is now implemented by Card Impact V3.

## Card Impact V3 Isolated Target Capture

- Purpose: reduce focused-card ambiguity before broad player-card redesign batches.
- Scope: tooling only; no gameplay, card, enemy, reward, shop, route or balance changes.
- New pack: `data/lab/card_impact/track02_card_impact_v3.json`.
- New policy: `card_focus_isolated`, which plays minimum support, plays the target card once, records the signature and stops further card plays for that turn.
- New target-capture fields: `target_card_play_count`, `target_card_first_play_turn`, `target_card_first_play_cycle`, `stopped_after_target`, `target_capture_mode`, `capture_quality` and `ambiguity_reasons`.
- Gate behavior: repeated target capture and failed isolated capture are structural blockers; support-required captures are visible but allowed; enemy signatures remain report-only.
- Final observed compare at `user://card_impact/track02_card_impact_v3_isolated_target_capture`:
  - Gate: PASS.
  - Coverage: 84/84 active cards.
  - Player capture quality: 45 clean, 9 support-required, 0 ambiguous, 0 failed, 0 repeated.
  - Compare: zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes.
- Operational lesson: V3 should be the default card-impact pack for broad player-card redesigns because it keeps V2 effect-family visibility while removing repeated-target noise.

## Player Card Redesign Batch 02

- Purpose: run a broader but still light real player-card change cycle to test Card Impact V3 before future large card redesigns.
- Scope: six core player-card variants already covered by the current V3 matrix; no enemy, reward, route, shop, relic or encounter changes.
- Card changes:
  - `arcano_acelerar_lvl2`: temporary ability power `+3 -> +2`.
  - `arcano_bola_de_fogo_lvl2`: primary damage `2 -> 3`, adjacent damage unchanged.
  - `invocador_batedor_lvl2`: attack `3 -> 4`.
  - `invocador_guardiao_lvl2`: health `6 -> 7`.
  - `necro_prender_lvl3`: Enfraquecer `1 -> 2`.
  - `necro_zumbi_lvl2`: health `3 -> 4`.
- Card Impact V3 compare at `user://card_impact/player_card_redesign_batch_02`: PASS with 84/84 active cases covered, zero structural errors, zero new failures, zero removed records, zero status changes, 14 metric deltas and 13 effect deltas.
- Detected V3 effect deltas:
  - `arcano_bola_de_fogo_lvl2`: `effect.enemy_slot_damage_total` `3 -> 4`.
  - `invocador_batedor_lvl2`: `effect.summoned_attack_total` `5 -> 6`.
  - `invocador_guardiao_lvl2`: `effect.summoned_health_total` `7 -> 8`.
  - `necro_zumbi_lvl2`: `effect.summoned_health_total` `3 -> 4`.
  - `necro_prender_lvl3`: stronger debuff killed the isolated target, moving the signature from control/debuff markers toward damage/economy side effects.
- Macro regression gates stayed green: Battle Lab `9 PASS / 3 WARN / 0 FAIL`, Scenario Fixtures `9 PASS / 3 WARN / 0 FAIL`, AutoRun smoke green, AutoRun quick green, and `validate.gd` passed with `164/164` tests and `1651` asserts.
- Tooling lesson: the first draft of this batch touched reward cards outside the V3 core-player matrix; those edits were removed before acceptance. The next tooling step should expand Card Impact to all active player reward cards and add explicit signature fields for utility quantities such as temporary ability power.

## Card Impact V4 Full Player Matrix

- Purpose: expand Card Impact from core-player variants to all active player reward cards before larger card redesigns.
- Scope: tooling only; no gameplay, card, enemy, reward, shop, route, relic or balance changes.
- New pack: `data/lab/card_impact/track02_card_impact_v4.json`.
- New matrix scope: `full_active_player_v1`, discovering starter deck cards, core cost-2 cards and all `track_02_player_card_rewards` entries with Lvl 1/2/3 variants.
- Coverage: 108 player cards, split 36 Arcano / 36 Invocador / 36 Necromante, plus 30 enemy report-only cards and 15 legacy inactive cards.
- Reward cards now covered include non-Terra examples such as `arcano_vortice`, `invocador_cavaleiro_arcano` and `necro_lich`.
- Signature update: temporary ability power is now a first-class utility signature via `temporary_ability_power_delta`, `temporary_ability_power_gained` and `temporary_ability_power_lost`.
- Reports now show full player coverage by class/source, reward-card coverage, utility effect deltas, target capture quality and top impacted cards without changing the external output filenames.
- Validation result: V4 `before`, `after` and `compare` pass at `user://card_impact/track02_card_impact_v4_full_player_matrix`; V3 Batch 02 compare remains green; Battle Lab, Scenario Fixtures, AutoRun smoke, AutoRun quick and `validate.gd` are green.
- Operational lesson: V4 should be the default harness for the next real reward-card redesign batch. Enemy-card signatures should stay report-only until a dedicated enemy causality pass.

## Reward Card Redesign Batch 01 Using V4

- Purpose: execute the first real reward-card change cycle against Card Impact V4, testing the full active player-card matrix rather than only the historical core 54 variants.
- Scope: six player reward/card-upgrade variants; no enemy, route, shop, relic, encounter, reward schedule or tooling changes beyond docs/status.
- Card changes:
  - `arcano_canalizar_lvl2`: damage `4 -> 5`.
  - `arcano_descarga_lvl2`: damage `3 -> 4`.
  - `invocador_parede_de_escudos_lvl2`: shield charges `1 -> 2`.
  - `invocador_cavaleiro_arcano_lvl2`: attack `4 -> 5`.
  - `necro_flagelo_lvl3`: poison amount `2 -> 3`.
  - `necro_colheita_das_almas_lvl3`: Ashes gain `3 -> 4`.
- Card Impact V4 compare at `user://card_impact/reward_card_redesign_batch_01_v4`: PASS with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, 0 structural errors, 0 new failures, 0 removed records, 0 status changes, 6 changed battle records and 15 metric/effect deltas.
- Detected V4 effect deltas:
  - `arcano_canalizar_lvl2`: `effect.enemy_hero_damage` `5 -> 6`.
  - `arcano_descarga_lvl2`: `effect.enemy_units_delta` `0 -> -1`, `effect.enemy_slot_damage_total` `4 -> 5`, and `effect.log_added` `1 -> 2`.
  - `invocador_parede_de_escudos_lvl2`: `effect.ally_shield_gain` `1 -> 2` and `effect.shield_added_total` `1 -> 2`.
  - `invocador_cavaleiro_arcano_lvl2`: `effect.summoned_attack_total` `6 -> 7`.
  - `necro_flagelo_lvl3`: `effect.poison_added_total` `2 -> 3` and `effect.enemy_poison_added` `2 -> 3`.
  - `necro_colheita_das_almas_lvl3`: `effect.ashes_gained` `3 -> 4`.
- Target capture quality stayed stable at 96 clean, 12 support-required, 0 ambiguous, 0 failed and 0 repeated.
- Macro regression gates stayed green: Battle Lab `9 PASS / 3 WARN / 0 FAIL`, Scenario Fixtures `9 PASS / 3 WARN / 0 FAIL`, AutoRun smoke green, AutoRun quick green, and `validate.gd` passed with `175/175` tests and `1704` asserts.
- Operational lesson: V4 exposed reward-card movement cleanly for damage, shield, summon stats, poison and economy effects. This batch intentionally did not exercise AP/utility-card movement; that follow-up is covered by Reward Card Redesign Batch 02 Utility Using V4.

## Reward Card Redesign Batch 02 Utility Using V4

- Purpose: execute a second real reward-card change cycle against Card Impact V4, focused on utility/control/economy effects rather than broad tuning.
- Scope: four player reward/card variants; no enemy, route, shop, relic, encounter, reward schedule or tooling changes beyond docs/status/test expectation alignment.
- Card changes:
  - `arcano_acelerar_lvl3`: temporary ability power `3 -> 4`.
  - `arcano_vortice`: frozen duration `1 -> 2`.
  - `arcano_vortice_lvl2`: frozen duration `1 -> 2`.
  - `necro_colheita_das_almas`: Ashes gain `2 -> 3` and `draw_if_at_least=3`.
- Card Impact V4 compare at `user://card_impact/reward_card_redesign_batch_02_utility_v4`: PASS with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, 0 structural errors, 0 new failures, 0 removed records, 0 status changes, 4 changed battle records and 7 metric/effect deltas.
- Detected V4 effect deltas:
  - `arcano_acelerar_lvl3`: `effect.temporary_ability_power_delta` `3 -> 4` and `effect.temporary_ability_power_gained` `3 -> 4`.
  - `arcano_vortice`: `effect.freeze_added_total` `1 -> 2` and `effect.enemy_frozen_added` `1 -> 2`.
  - `arcano_vortice_lvl2`: `effect.freeze_added_total` `1 -> 2` and `effect.enemy_frozen_added` `1 -> 2`.
  - `necro_colheita_das_almas`: `effect.ashes_gained` `2 -> 3`.
- Target capture quality stayed stable at 96 clean, 12 support-required, 0 ambiguous, 0 failed and 0 repeated.
- Macro regression gates stayed green: Battle Lab `9 PASS / 3 WARN / 0 FAIL`, Scenario Fixtures `9 PASS / 3 WARN / 0 FAIL`, AutoRun smoke green, AutoRun quick green, and `validate.gd` passed with `175/175` tests and `1704` asserts.
- Tooling lesson: temporary ability power utility movement is now proven by real V4 before/change/after/compare data. The new `draw_if_at_least` hook on `necro_colheita_das_almas` did not produce an observed `cards_drawn` delta in the current harness, so draw/discard/hand/deck work should get a small Card Impact V4.1 card-flow harness pass before larger card-flow redesigns.

## Screenshots

Captured at `1280x720` and `960x540` in:

- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\run_map_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\reward_screen_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\shop_relic_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\keyword_tooltip_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\enemy_intent_*.png`
- `D:\Estudio\builds\draxos-roguelike-cardgame\visual-screenshots\late_board_battle_*.png`

## Product And Playtest Follow-Up

- Manual playtest remains the next production step and should use `docs/playtest-track-02.md`.
- Balance changes should come from observed human runs, with AutoRun Gate Pack used for explicit regression, distribution checks and tuning comparison rather than as the final verdict.
- Large player-card changes should now use Card Impact V4: run `before`, apply the intended card edit, run `after`, run `compare`, then inspect full player coverage, target-capture quality, metric movement, utility deltas and player-card effect signatures before accepting the batch.
- Recommended next implementation batch: add Card Impact V4.1 card-flow harness coverage so draw, discard, hand and deck deltas become reliable before larger card-flow redesigns.
- Enemy-card signature derivation remains the recommended tooling follow-up once enemy per-card causality is exposed clearly enough.
- Sort playtest results into blocking bugs, tuning, UX clarity, and content/art debt before implementation.

## Remaining Technical Debt

- Final card/enemy art is still placeholder-driven where PNGs are absent.
- Four ship overlay alpha warnings remain non-fatal asset debt.
- The full-route smoke is deterministic validation telemetry, not a human balance verdict.
- Further BattleRoot, field-effect, boss-hook, or catalog-source splitting is optional future foundation work and is not required before Track 02 playtest.
