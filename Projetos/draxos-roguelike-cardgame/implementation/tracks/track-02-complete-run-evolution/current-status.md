# Track 02 Current Status

- Last Updated: `2026-06-06`
- Status: `T02-P09_COMPLETE`
- Scope: `First complete 29-map version of the Draxos roguelike cardgame`
- Historical Baseline Dependency: `Track 01 - Playable Run Loop`
- Validation Baseline: `Enemy Card Redesign Batch 02 Using V5 Terra, Enemy Card Redesign Batch 01 Using V5, Card Impact V5 Enemy Causal Signatures, Reward Card Redesign Batch 03 Using V4.2, Card Impact V4.2 Card Flow Expectations, Card Flow Redesign Batch 01 Using V4.1, Card Impact V4.1 Card-Flow Harness Pass, Reward Card Redesign Batch 02 Utility Using V4, Reward Card Redesign Batch 01 Using V4, Card Impact V4 Full Player Matrix, Player Card Redesign Batch 02, Card Impact V3 Isolated Target Capture, Card Impact V2 Non-Damage Coverage, Card Redesign Batch 01, Card Impact Effect Signature V2, Card Impact Smoke Tuning V1, Card Impact Pack V1, Lab Diff Reporter V1, Gameplay Lab V1, Scenario Fixtures V1 and AutoRun Gate Pack V1 preserve Track 02 route metrics and pass 211/211 GUT tests, shared full-route pacing smoke green, Card Impact V5 before/after/compare gate green at user://card_impact/enemy_card_redesign_batch_02_v5_terra with 108 player cards, 30 required enemy causal signatures, 15 legacy inactive elemental cards audited, 3 expected card-flow player cards observed, 21/21 card-flow expectation checks passing, 30/30 enemy cards played, 30/30 enemy signatures present, zero structural errors, zero new failures, zero removed records, zero status changes, 2 changed enemy records and 4 effect changes, Battle Lab track02_battle_core_v1 gate green with 9 PASS / 3 WARN / 0 FAIL, Scenario Fixture track02_core_v1 gate green with 9 PASS / 3 WARN / 0 FAIL, smoke gate track02_smoke_v1 green, and quick 30-case track02_quick_v1 gate/scorecard green`

## Purpose

Track 02 turned the historical validated 13-map playable slice into the first complete version of the game.

The target is a fixed, linear 29-map run with all planned encounter types, all planned keywords, improved enemy AI, a redesigned reward economy, universal run relics, a complete Souls shop, and stronger battle/map/reward UI.

## Approved Direction

- First complete version: fixed 29-map linear run.
- Target full-run duration: around 90 minutes.
- Player can lose before map 29.
- First balance target: max mana `6`, max hand size `5`.
- HP starts at `20`; fixed rewards raise it to `30`; shop/relics can raise it further.
- Every map grants Souls plus one main reward category.
- Reward rarity remains `70% common`, `25% rare`, `5% ultra rare`.
- Shop is available between maps and refreshes after victories.
- Existing class passives and actives remain intact.
- Universal relics are added as a separate run-passive system.
- All proposed keywords and encounter types are in scope.
- Enemy difficulty should not receive another global `+20%` stat pass; tune by element identity, AI behavior, and encounter role.

## Production Documents

- `design-brief.md`
- `reward-system.md`
- `relics.md`
- `enemy-ai-and-difficulty.md`
- `linear-execution-plan.md`
- `implementation-prompts.md`
- `handoff-log.md`
- `validation-and-tuning-notes.md`

## Current Execution Cursor

Completed prompt: `ENEMY-CARD-REDESIGN-BATCH-02-USING-V5-TERRA - apply a focused Terra enemy-card batch under Card Impact V5 before/change/after/compare with explicit Battle Lab review`.

Next implementation prompt: `TRACK-02-MANUAL-PLAYTEST-REVIEW - run or collect a human complete-route playtest before additional tuning`. If implementation continues before that, use a very small V5 enemy batch and keep Battle Lab as the broader encounter veto. Track 02 remains ready for user playtest.

## Implemented Baseline

- SaveManager save version and RunSession snapshot version are now `5`; v4 and older files follow the existing stale-save pattern.
- Runtime state now persists Track 02 contract fields for stat caps, relic ids, expanded shop state, reward category state, reroll count, and route metadata.
- Track 02 data metadata exposes the 29-map reward schedule and the active route now uses the fixed 29-map sequence.
- Reward application now supports max mana, max hand size, max HP, new-card choice, remaining-card grant, card upgrade, real relic rewards, utility choice, and victory metadata.
- Fixed HP progression starts at `20` and applies `+5` at map 10 and map 15; first-test caps remain max mana `6` and max hand size `5`.
- Map 27 utility choice supports remove card, duplicate card, or upgrade card.
- Reward rarity remains `70/25/5`, and new-card copy rules remain `3/4/5`.
- Track 02 now defines the initial 18 universal relics in data and stores owned relic ids in run state.
- Souls shop now exposes heal, remove card, duplicate card, buy card, upgrade card, buy relic, reroll shop/reward, and +3 max HP purchases with documented prices.
- Max HP shop purchases are limited to 2 per run with costs `18` then `28` Souls.
- Safe relic effects are implemented for Bolsa de Cinzas, Lamina de Reserva, Couro Astral, Marca de Guerra, Eco Menor, Catalisador Arcano, Ferramentas de Cirurgia, Estandarte Vivo, Nucleo Instavel, Coracao de Eter, Biblioteca Proibida, Forja Negra, and Pacto das Ruinas.
- Relics pending later hooks remain data-owned but effect-pending: Mao Preparada, Contrato de Sangue, Escudo de Marcha, Olho do Grande Mestre, and Selo de Dominacao.
- Track 02 now has canonical tooltip definitions for existing active keywords and all proposed keywords: Atropelar, Brutal, Drenar, Espinhos, Escudo, Resistencia, Imune, Crescer, Furia, Ecoar, Veneno, Congelar, Profanar, Entrar, Proliferar, Sacrificio, Inspirar, Pacto, Drenar Almas, and Ressurgir.
- Card, occupant, reward, shop item, relic, enemy intent, and board effect tooltip surfaces now route through shared lookup helpers; card/field keyword badges expose tooltip text and Souls shop/reward choices show floating previews.
- Status presentation now summarizes stack/count/timing data when fields exist, including current markers such as Lentidao, Confusao, Regeneracao, Carnica, revive use, and future markers for Escudo, Resistencia, Veneno, and Congelado.
- BattleEngine now implements all Track 02 keyword mechanics with timing coverage for summon, start of player turn, combat damage, damage received, death, end of combat, maintenance, sacrifice-cost confirmation, and run-economy bonus hooks.
- Implemented keyword scope includes Atropelar, Brutal, Drenar, Espinhos, Escudo, Resistencia, Imune, Crescer, Furia, Ecoar, Veneno, Congelar, Profanar, Entrar, Proliferar, Sacrificio, Inspirar, Pacto, Drenar Almas, and Ressurgir while preserving Iniciativa, Defensor, Reviver, Regeneracao, Carnica, Suicida, Enfraquecer, Prender, Remover Keywords, and Poder de Habilidade tests.
- T02-P06 promoted the 6 placeholder reward cards per class into real Gelo/Ar/Fogo class cards while preserving the 6 existing real cards per class.
- Every new class reward card now has Lvl 2 and Lvl 3 variants, and each class reward pool now contains the intended 8-card Terra/Gelo/Ar/Fogo sequence.
- Track 02 enemy card galleries now exist for Terra, Gelo, Ar, and Fogo, with 30 enemy cards total for later route/AI prompts.
- BattleEngine now has deterministic hybrid enemy AI foundations with archetype-driven scoring for Terra, Gelo, Ar, and Fogo profiles, including objective pressure, lane pressure, empty lanes, Defensor coverage, high-value threats, Espinhos risk, control priorities, and boss-phase protection scoring.
- Summoner-boss encounters now expose phase-hook intent data for current phase, next scripted trigger, and next major special action without implementing the final boss phase set.
- Battle state now exposes an enemy intent model for common encounters and bosses, including likely priorities, incoming lane/hero pressure, target priority, field-effect hints, next likely play, boss phase, next trigger, and next special action.
- Battle UI now shows a visible `BattleEnemyIntentPanel` with tooltip-backed intent categories, and the screenshot workflow captures duel battle screenshots with the panel visible.
- Visual asset manifest placeholders now cover all new class reward cards and enemy gallery cards.
- Validation now checks reward card ids, upgrade ids, reward pool order, enemy gallery card ids, keyword references, placeholder removal, deterministic enemy AI decisions, intent output, and intent panel presence.
- The active run route now contains the complete fixed 29-map linear sequence with exact unlock chaining and compact visual node positions.
- Track 02 encounter coverage now includes Tutorial, Ondas, Duelo, Chefe Invocador, Sobreviver Turnos, Emboscada, Escolta, and Invasao.
- BattleEngine now supports the planned board formats: Padrao, Assimetrico, Nucleo Central, Flanco, Frente e Retaguarda, and Abismo.
- Elemental field effects are implemented for Terra, Gelo, Ar, Fogo, and final-chaos encounters, including effects that influence movement, summons, attack lanes, damage, poison, freeze, and death hooks.
- Boss maps 8, 15, 22, and 29 now have representative scripted phase hooks and intent data.
- Production reward overrides are active: map 14 grants a Gelo remaining card, map 15 grants HP plus boss relic, map 23 raises max mana to 6, and map 28 grants rare/ultra relic choice.
- Validation now checks the 29-map route, linear unlock chain, reward schedule, mode/format/effect coverage, and boss hook coverage; representative tests exercise new modes, board formats, and field effects.
- Screenshot workflow captures RunMap and representative Battle surfaces for the complete-route state.
- T02-P09 added full-route pacing telemetry to validation, with map count, estimated turns, HP loss, Souls, deck size, relic count, shop usage, and deaths.
- Foundation hardening 2 extracted that route pacing telemetry into `tools/route_pacing_simulator.gd`, now shared by `tools/validate.gd`, `tools/run_lab.gd`, and GUT coverage.
- Foundation hardening 2 added `docs/playtest-track-02.md` as the human playtest checklist for the complete route.
- Foundation hardening 3 extracted enemy turn and intent directors, `core/run_reward_service.gd`, and the pure battle preview presenter while preserving public APIs, route behavior, reward/shop payloads, UI layout, and pacing metrics.
- Foundation hardening 4 added `tools/run_lab_golden_metrics.gd` and optional Run Lab golden comparison, with Arcano seed `20260518` exact metrics protected and Invocador/Necromante completion/no-death contracts checked.
- Foundation hardening 5 extracted Souls shop offer generation, purchases, rerolls, max-HP buys, cost helpers, and `shop_state` sync into `core/run_shop_service.gd` while preserving `RunSession` wrappers, snapshot v5 payloads, and golden pacing metrics.
- Foundation hardening 6 extracted BattleRoot HUD/objective readouts and combat FX filtering/text/state projection into pure presenters while preserving scene composition, layout, drag/drop, UI node names, route behavior, and golden pacing metrics.
- Foundation hardening 7 added `tools/catalog_source_loader.gd` as a composition seam for future catalog domain splits while preserving the current single `slice_catalog.json` source, generated `.tres` semantics, route behavior, and golden pacing metrics.
- Foundation hardening 8 extracted staged combat, manual attack, slot damage, hero damage, and destruction queue handling into `battle/combat_resolution_director.gd` while preserving `BattleEngine` wrappers, keyword timing, route behavior, and golden pacing metrics.
- Foundation hardening 9 closed the foundation review with `docs/foundation-closeout.md`, refreshed the live architecture ownership map, separated technical foundation debt from product/playtest follow-up, and kept the next product step focused on human Track 02 playtest.
- AutoRun Lab V1 turns `tools/run_lab.gd` into a modular macro-route lab with `tools/lab/` case building, presets, macro policies, aggregate JSON/CSV/Markdown reporting, detailed timelines, warnings/tags and statistical baseline comparison while preserving the exact Track 02 golden path.
- AutoRun Gate Pack V1 adds official smoke/quick baselines under `data/lab/baselines/`, explicit `--mode=gate` regression commands, baseline group-field comparisons, gate failure tests, and scorecard JSON/Markdown reports for human tuning reads.
- Scenario Fixtures V1 adds `data/lab/scenarios/track02_core_v1.json`, `tools/run_scenarios.gd`, loader/evaluator/runner/reporter modules, 12 deterministic route/economy/deck/boss/class/keyword-focused macro scenarios, PASS/WARN/FAIL expectations, explicit gate mode and JSON/CSV/Markdown reports without wiring the command into `tools/validate.gd`.
- Card Impact Pack V1 adds `data/lab/card_impact/track02_card_impact_v1.json`, `tools/run_card_impact.gd`, card discovery/matrix/runner/reporter modules, the `card_focus_legal` battle policy, 54 core player card variants, 30 active enemy cards, 15 audited legacy inactive elemental cards, explicit before/after/compare gate mode and JSON/CSV/Markdown impact reports without wiring the command into `tools/validate.gd`.
- Card Impact Smoke Tuning V1 applied a deliberately small card batch: `arcano_choque_lvl2` and `arcano_choque_lvl3` damage `3 -> 4`, `invocador_batedor_lvl3` attack `6 -> 5`, `necro_esqueleto_lvl2` health `2 -> 3`, and `enemy_ar_rajada` attack `4 -> 5`.
- The first real Card Impact compare stayed structurally green and surfaced one expected metric movement: `enemy_ar_rajada` raised `damage_to_player_hero` from `4` to `5` and lowered isolated harness `player_hp` from `56` to `55`.
- Card Impact Effect Signature V2 adds `data/lab/card_impact/track02_card_impact_v2.json`, `tools/lab/battle_effect_signature.gd`, BattleEngine before/after snapshots around focused player-card plays, required player-card effect signatures, schema-ready enemy report-only signatures, `effect.*` diff rows and Markdown summary sections for effect deltas, effect-family matrices, top effect-delta cards and missing signatures.
- Current V2 same/same calibration passes with 84/84 active card cases, 54/54 required player effect signatures, 30 enemy cards in report-only signature mode, 15 legacy inactive cards audited, zero structural errors, zero new failures, zero removed records, zero status changes, zero metric changes and zero effect changes.
- Card Impact V2 Non-Damage Coverage extends player-card signatures with summon aliases/totals, ally keyword/shield/resistance gains, enemy poison/freeze/snare/control counters, deck/hand/discard/card-flow deltas, pending choice/sacrifice counters, support-card before/after metadata, signature confidence, non-damage family matrix and support-contamination Markdown reporting.
- Current non-damage compare passes with 84/84 active card cases, 54 required player signatures, 30 enemy report-only missing signatures, zero structural errors, zero new failures and zero removed records; reported signature quality is 45 clean, 9 support-assisted, 47 ambiguous from repeated focused-card plays and 30 enemy report-only missing.
- Card Redesign Batch 01 applied the first controlled real V2 card cycle: `arcano_choque_lvl2` and `arcano_choque_lvl3` damage `4 -> 5`, `arcano_tempestade_lvl3` random damage `6 -> 7`, and damage-family Card Impact harnesses now use `enemy_health=160` plus `enemy_terra_elemental_tita` to keep extra damage observable instead of hidden by overkill.
- Batch 01 compare stayed structurally green and surfaced the intended effect deltas: `arcano_choque_lvl2` `effect.enemy_hero_damage` `52 -> 57`, `arcano_choque_lvl3` `86 -> 92`, and `arcano_tempestade_lvl3` `57 -> 62`.
- Card Impact V3 Isolated Target Capture added `data/lab/card_impact/track02_card_impact_v3.json`, `card_focus_isolated`, one-play target capture, stop-after-target behavior, target capture quality reporting and structural blockers for repeated/failed focused-card capture.
- Player Card Redesign Batch 02 changed six core player upgrades covered by V3: `arcano_acelerar_lvl2` AP `+3 -> +2`, `arcano_bola_de_fogo_lvl2` primary damage `2 -> 3`, `invocador_batedor_lvl2` attack `3 -> 4`, `invocador_guardiao_lvl2` health `6 -> 7`, `necro_prender_lvl3` Enfraquecer `1 -> 2`, and `necro_zumbi_lvl2` health `3 -> 4`.
- Batch 02 V3 compare passed with 84/84 active cards, zero structural errors, zero new failures, zero removed records, zero status changes, 14 metric deltas and 13 effect deltas. Macro Battle/Scenario/Run Lab gates stayed green, and `validate.gd` passed with 164/164 tests.
- Batch 02 exposed the next tooling gap: the current V3 player matrix does not cover reward cards outside the core 54 variants, and signatures do not directly track temporary ability power.
- Card Impact V4 Full Player Matrix adds `data/lab/card_impact/track02_card_impact_v4.json`, `player_scope=full_active_player_v1`, full active player-card discovery from starter decks, core cost-2 cards and all `track_02_player_card_rewards`, and deterministic coverage summaries by class/source.
- V4 covers 108 player variants, split 36 Arcano / 36 Invocador / 36 Necromante, plus 30 active enemy cards in report-only signature mode and 15 audited legacy inactive `elemental_*` cards.
- V4 adds explicit temporary ability power signature fields (`temporary_ability_power_delta`, `temporary_ability_power_gained`, `temporary_ability_power_lost`) to BattleEngine-derived effect signatures, `effect.*` diffs, utility family reporting and Card Impact Markdown summaries.
- V4 before/after/compare gates pass at `user://card_impact/track02_card_impact_v4_full_player_matrix` with zero structural errors, zero new failures and zero removed records; V3 compare regression for `user://card_impact/player_card_redesign_batch_02` remains green.
- Reward Card Redesign Batch 01 Using V4 changed six reward/card-upgrade variants: `arcano_canalizar_lvl2` damage `4 -> 5`, `arcano_descarga_lvl2` damage `3 -> 4`, `invocador_parede_de_escudos_lvl2` shield charges `1 -> 2`, `invocador_cavaleiro_arcano_lvl2` attack `4 -> 5`, `necro_flagelo_lvl3` poison `2 -> 3`, and `necro_colheita_das_almas_lvl3` Ashes `3 -> 4`.
- Batch 01 V4 compare passed at `user://card_impact/reward_card_redesign_batch_01_v4` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, zero structural errors, zero new failures, zero removed records, 6 changed battle records, 15 metric/effect deltas, 0 Scenario changes and 0 Run Lab changes.
- Batch 01 observed effect deltas matched intent: `effect.enemy_hero_damage`, `effect.enemy_slot_damage_total`, `effect.enemy_units_delta`, `effect.ally_shield_gain`, `effect.shield_added_total`, `effect.summoned_attack_total`, `effect.poison_added_total`, `effect.enemy_poison_added`, and `effect.ashes_gained`.
- Reward Card Redesign Batch 02 Utility Using V4 changed four player reward/card variants: `arcano_acelerar_lvl3` temporary ability power `3 -> 4`, `arcano_vortice` frozen duration `1 -> 2`, `arcano_vortice_lvl2` frozen duration `1 -> 2`, and `necro_colheita_das_almas` Ashes `2 -> 3` with `draw_if_at_least=3`.
- Batch 02 V4 compare passed at `user://card_impact/reward_card_redesign_batch_02_utility_v4` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, zero structural errors, zero new failures, zero removed records, 4 changed battle records, 7 metric/effect deltas, 0 Scenario changes and 0 Run Lab changes.
- Batch 02 observed effect deltas matched intent for utility/control/economy: `effect.temporary_ability_power_delta`, `effect.temporary_ability_power_gained`, `effect.freeze_added_total`, `effect.enemy_frozen_added`, and `effect.ashes_gained`; the added `draw_if_at_least` hook did not surface a `cards_drawn` delta in the current V4 harness.
- Card Impact V4.1 Card-Flow Harness Pass adds `data/lab/card_impact/track02_card_impact_v4_1.json`, keeps V4 full player coverage, classifies draw/discard/hand/deck cards as `card_flow`, and initially required 2 expected player card-flow cases: `necro_colheita_das_almas` and `necro_colheita_das_almas_lvl3`; Card Flow Redesign Batch 01 promotes Lvl 2, so the current pack expects 3.
- V4.1 adds a lab-only player card-flow harness with deterministic deck/hand setup, records `card_flow_expected`, `card_flow_observed`, `card_flow_missing_reason`, and exposes `effect.cards_drawn`, `effect.deck_delta`, `effect.hand_delta` and `effect.discard_delta` in diffs and Markdown.
- V4.1 adds `case_data.lab_prestate.initial_dead_unit_count` for Card Impact-only setup after `BattleEngine.start_battle`; `necro_colheita_das_almas_lvl3` uses `initial_dead_unit_count=2` so the Ash threshold can cross `draw_if_at_least` deterministically without changing gameplay APIs or content.
- V4.1 before/after/compare gates pass at `user://card_impact/track02_card_impact_v4_1_card_flow_harness` with zero structural errors, zero new failures and zero removed records; focused probes observe both expected card-flow cards drawing 1 card and moving deck_delta by -1.
- Card Flow Redesign Batch 01 Using V4.1 made the first real card-flow change after the harness pass: `draw_if_at_least` now resolves as a bonus draw after normal hand refill, `necro_colheita_das_almas_lvl2` now gains 3 Ashes and `draw_if_at_least=3`, and the V4.1 matrix now expects 3 card-flow player cases.
- Batch 01 V4.1 compare passed at `user://card_impact/card_flow_redesign_batch_01_v4_1` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, zero structural errors, zero new failures, zero removed records, 3 changed battle records and 11 card-flow/economy effect deltas.
- Batch 01 observed effect deltas matched intent: Colheita base/Lvl 2/Lvl 3 moved `effect.cards_drawn` `1 -> 2`, `effect.deck_delta` `-1 -> -2` and `effect.hand_delta` `0 -> 1`; Lvl 2 also moved `effect.ashes_gained` `2 -> 3` and `effect.card_flow_expected` `false -> true`.
- Card Impact V4.2 Card Flow Expectations adds `data/lab/card_impact/track02_card_impact_v4_2.json`, keeps V4.1 coverage, and promotes the three Colheita card-flow observations into explicit `required` plus `watch` checks.
- V4.2 required checks gate `card_flow_observed == true`, `cards_drawn >= 2`, `deck_delta <= -2` and `hand_delta >= 1` for `necro_colheita_das_almas`, `necro_colheita_das_almas_lvl2` and `necro_colheita_das_almas_lvl3`; exact values remain watch checks.
- V4.2 before/after/compare gates pass at `user://card_impact/track02_card_impact_v4_2_card_flow_expectations` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, 3 expected card-flow player cards, 21/21 expectation checks passing, zero structural errors, zero new failures and zero removed records.
- Reward Card Redesign Batch 03 Using V4.2 changed twelve reward/card-upgrade variants across Arcano, Invocador and Necromante while preserving Colheita card-flow values.
- Batch 03 V4.2 compare passed at `user://card_impact/reward_card_redesign_batch_03_v4_2` with 108 player cards, 30 enemy report-only cards, 15 legacy inactive cards, 12 impacted target cards, 18 effect changes, zero structural errors, zero new failures, zero removed records, zero status changes and 21/21 Card Flow Expectations passing.
- Batch 03 observed effect-family movement matched intent across buff, control, damage, summon and poison/card-state families; Battle Lab, Scenario Fixtures, AutoRun smoke/quick and `validate.gd` remained green.
- Card Impact V5 Enemy Causal Signatures adds `data/lab/card_impact/track02_card_impact_v5.json`, preserves V4.2 player/card-flow coverage, and promotes the 30 active enemy cards from report-only to required causal signatures.
- V5 enemy cases use a controlled BattleEngine commander harness with one enemy card in hand/deck, `effect_signature_scope="enemy"`, `enemy_causal_signature` tags, play snapshot capture and first-combat snapshot capture.
- V5 effect signatures add explicit enemy-caused fields for card play count, summon count/stat/keyword totals, keywords added, damage to player hero/slots, player unit delta, combat damage, signature phase and confidence.
- V5 before/after/compare gates pass at `user://card_impact/track02_card_impact_v5_enemy_causal_signatures` with 108 player cards, 30 enemy signatures required/present, 15 legacy inactive cards, 30/30 enemy cards played, 30 clean enemy signatures, zero structural errors, zero new failures, zero removed records, zero status changes and 21/21 Card Flow Expectations passing.
- V5 regression coverage stayed green: V4.2 historical compare at `user://card_impact/reward_card_redesign_batch_03_v4_2`, Battle Lab, Scenario Fixtures, AutoRun smoke/quick and `validate.gd` all passed.
- Enemy Card Redesign Batch 01 Using V5 applied six light enemy-card data changes across Gelo, Ar and Fogo while preserving player cards, labs, route, encounters, shop, relics and reward schedule.
- Batch 01 accepted changes: `enemy_gelo_elemental_de_gelo` health `3 -> 4`, `enemy_gelo_coluna_de_gelo` attack `0 -> 1`, `enemy_ar_brisa_mortal` attack `1 -> 2`, `enemy_ar_tempestade_vivente` health `3 -> 4`, `enemy_fogo_golem_de_lava` health `6 -> 7`, and `enemy_fogo_fragmento_de_chama` gained `furia`.
- Batch 01 V5 compare passed at `user://card_impact/enemy_card_redesign_batch_01_v5` with 6 changed enemy battle records, 17 metric/effect changes, zero structural errors, zero new failures, zero removed records, zero status changes and 21/21 Card Flow Expectations passing.
- Batch 01 observed enemy deltas matched intent across enemy stat, keyword and combat-damage families; an initial Terra probe was removed because Battle Lab caught Arcano duel/boss failures, proving the broader lab stack can veto unsafe early-route enemy changes even when Card Impact remains structurally green.
- Enemy Card Redesign Batch 02 Using V5 Terra applied two focused Terra enemy-card data changes while preserving labs, player cards, route, encounters, shop, relics and reward schedule.
- Batch 02 accepted changes: `enemy_terra_elemental_tita` attack `3 -> 2` and `enemy_terra_elemental_granito` health `7 -> 8`.
- Batch 02 V5 compare passed at `user://card_impact/enemy_card_redesign_batch_02_v5_terra` with 2 changed enemy records, 4 effect changes, zero structural errors, zero new failures, zero removed records, zero status changes and 21/21 Card Flow Expectations passing.
- Batch 02 observed enemy deltas matched intent: Tita reduced `enemy_summoned_attack_total`, `enemy_damage_to_player_hero` and `enemy_combat_damage_to_player_hero` from `3` to `2`; Granito raised `enemy_summoned_health_total` from `7` to `8`.
- Batch 02 regression coverage stayed green: V4.2 historical compare, Battle Lab 9 PASS / 3 WARN / 0 FAIL, Scenario Fixtures 9 PASS / 3 WARN / 0 FAIL, AutoRun smoke/quick gates and `validate.gd` with 211/211 GUT tests and 1906 asserts.
- Reward screen, RunMap, Souls shop/relic state, keyword preview, enemy intent, and dense Battle layouts received readability polish.
- Discard marking now happens in the main creature-play phase with right-click card selection, a visible hand hint, and marked-card discard/redraw on combat resolution instead of a separate pre-combat phase.
- 5/5, 6/6, and 7/7 battle layouts now have regression coverage.
- First tuning pass keeps the approved reward schedule and shop costs unchanged, but makes Track 02 upgrade rewards level-only instead of adding extra rarity copies; the full-route smoke now ends at `38` cards.
- Screenshot workflow now captures RunMap, reward screen, shop/relic, keyword tooltip, enemy intent, and late-board Battle surfaces at `1280x720` and `960x540`.

## Handoff Rule

Every future Track 02 implementation or playtest-fix thread must:

- read this file and `implementation-prompts.md`;
- execute exactly one focused fix group unless the user explicitly expands scope;
- run the required validation;
- update this file with status and next prompt;
- append `handoff-log.md`;
- leave a clear final summary with changed files, validation result, blockers, and next prompt id.

## Current Risk

Track 02 is ready for user playtest and now has multiple real player-card and enemy-card redesign cycles plus Card Impact V4/V4.1/V4.2/V5 coverage validated. Remaining risk is human balance feedback: the deterministic full-route smoke, AutoRun Gate Pack macro matrices, Scenario Fixtures V1, Gameplay Lab V1, Card Impact Pack V1/V2/V3/V4/V4.1/V4.2/V5 and card redesign batches validate structure, tuning trends, small named regression signals, isolated combat behavior, card-specific before/after movement, player-card effect deltas, promoted card-flow expectations and enemy-card causal signatures, but they are not substitutes for a manual run. Current Card Impact coverage now includes active reward-card families, temporary ability power signatures, card-flow observability, explicit Colheita card-flow thresholds, a broader reward-card batch proven under V4.2, required causal signatures for all 30 enemy cards, and two accepted V5 enemy-card batches including a focused Terra pass. The recommended next step is direct manual playtest of the complete route before additional tuning.
