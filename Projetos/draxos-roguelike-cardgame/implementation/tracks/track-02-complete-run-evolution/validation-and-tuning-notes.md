# Track 02 Validation And Tuning Notes

- Last Updated: `2026-06-05`
- Prompt: `CARD-IMPACT-V2-NON-DAMAGE-COVERAGE`
- Status: `CARD_IMPACT_V2_NON_DAMAGE_COVERAGE_COMPLETE`

## Validation Summary

- Godot validation command: green.
- GUT: `157/157` tests passing.
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
- Card Impact Pack: `tools/run_card_impact.gd` runs explicit `before`, `after` and `compare` phases for `data/lab/card_impact/track02_card_impact_v1.json` and `data/lab/card_impact/track02_card_impact_v2.json`.
- Card Impact coverage: 54 core player class card variants, 30 active enemy cards and 15 legacy inactive `elemental_*` cards audited.
- Card Impact gate: `--phase=before --mode=gate`, `--phase=after --mode=gate` and `--phase=compare --mode=gate` all pass for the first real smoke-tuning cycle; compare reports zero structural errors, zero new failures, zero removed records and zero status changes across battle/scenario/run_lab components.
- Card Impact smoke-tuning output: `user://card_impact/smoke_tuning_v1` reports one expected metric-impact row for `enemy_ar_rajada`: `damage_to_player_hero` `4 -> 5` and isolated harness `player_hp` `56 -> 55`.
- Card Impact reports: `card_impact_results.json`, `card_impact_results.csv`, `card_impact_summary.json`, `card_impact_summary.md`, `card_impact_gate.md`, plus component `before/`, `after/` and `compare/` output directories under `user://card_impact/track02_card_impact_v1`.
- Card Impact Effect Signature V2: `track02_card_impact_v2` requires derived player-card signatures from real BattleEngine snapshots/log deltas, keeps enemy signatures report-only, and reports `effect.*` diffs, effect-family matrices, top effect-delta cards and missing signatures.
- Card Impact V2 gate: `before`, `after` and `compare` pass at `user://card_impact/v2_all_gate` with 84/84 active cases, 54/54 required player effect signatures, 30 enemy cards report-only, 15 audited legacy inactive cards, zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes in same/same compare.
- Card Redesign Batch 01 gate: `before`, `after` and `compare` pass at `user://card_impact/redesign_batch_01` with zero structural errors, zero new failures, zero removed records, zero status changes, 9 metric deltas and 3 effect deltas from the intended Arcano damage-upgrade changes.
- Card Redesign Batch 01 effect deltas: `arcano_choque_lvl2` `effect.enemy_hero_damage` `52 -> 57`, `arcano_choque_lvl3` `86 -> 92`, and `arcano_tempestade_lvl3` `57 -> 62`.
- Card Redesign Batch 01 regression gates: V1 Card Impact same/same regression passes, Battle Lab remains `9 PASS / 3 WARN / 0 FAIL`, Scenario Fixtures remains `9 PASS / 3 WARN / 0 FAIL`, AutoRun smoke passes, AutoRun quick passes and `validate.gd` passes with `154/154` tests and `1575` asserts.
- Card Impact V2 Non-Damage Coverage gate: `before`, `after` and `compare` pass at `user://card_impact/track02_card_impact_v2_non_damage_coverage` with 84/84 active cards covered, zero structural errors, zero new failures and zero removed records.
- Card Impact V2 Non-Damage Coverage signatures: 54 required player signatures present, 30 enemy signatures report-only/missing as expected, 45 clean player signatures, 9 support-assisted signatures, 47 ambiguous signatures from repeated focused-card plays, and non-damage families `buff`, `control`, `debuff`, `economy`, `keyword` and `summon` visible in the Markdown matrix.
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
- Next tooling recommendation: add an isolated target-card capture mode to `card_focus_legal` before the next broad redesign batch. It should play minimum legal support, play the focused card once, capture the signature and stop further card plays for the turn when safe.

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
- Large player-card changes should now use Card Impact V2: run `before`, apply the intended card edit, run `after`, run `compare`, then inspect both metric movement and player-card effect signatures before accepting the batch.
- Before the next broad card redesign, prefer one tooling hardening pass to reduce repeated-focused-card ambiguity in `card_focus_legal`.
- Sort playtest results into blocking bugs, tuning, UX clarity, and content/art debt before implementation.

## Remaining Technical Debt

- Final card/enemy art is still placeholder-driven where PNGs are absent.
- Four ship overlay alpha warnings remain non-fatal asset debt.
- The full-route smoke is deterministic validation telemetry, not a human balance verdict.
- Further BattleRoot, field-effect, boss-hook, or catalog-source splitting is optional future foundation work and is not required before Track 02 playtest.
