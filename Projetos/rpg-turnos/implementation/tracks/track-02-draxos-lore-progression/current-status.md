# Track 02 Current Status

- Last Updated: `2026-05-13` (P18 complete)
- Status: `ACTIVE_LINEAR_PLAN`
- Track Name: `Track 02 - Draxos Lore And Progression Alignment`

## Goal

Turn the current playable C1 slice into the first Draxos campaign slice through controlled content, lore, and progression passes.

The track must preserve the validated card-slot runtime while migrating player-facing content toward the new Draxos invasion premise.

## Current Baseline

- C1 is the sole combat runtime.
- Official battle modes are implemented: `limpar_mesa`, `duelo`, `ondas`, `defesa`, `chefe_multiparte`, and `quebra_cabeca`.
- World progression, one-time encounter rewards, progressive NPC rewards, save/load, and art-ready placeholders exist.
- Runtime validation is green at the latest known baseline: `125/125` GUT tests, 653 asserts, through `tools/validate.gd`.
- Several player-facing catalog names already use Draxos/elemental language.
- The generated catalog now exposes the 3 new classes (Invocador, Arcano, Necromante) with `passiva`, `hero`, `hero_power`, and 20-card placeholder starter decks through `ContentLibrary`. Old 5 classes removed.
- Two new card definitions added: `reforco_aliado` (Invocador buff) and `amplificacao_campo` (Invocador area buff).
- `docs/class-catalog-schema.md` updated with `passiva` field and 3-class hero power reference.
- `GameSession` holds `selected_class` with full save/load compatibility and class deck helpers.
- `BattleEngine` now loads hero power from active class data via `ContentLibrary`; `use_player_hero_power(target)` dispatches data-driven; Preparar Defesa remains no-class fallback.
- `Amplificar` hero power implemented: permanent +2/+0 to chosen ally, cost 1, once per own turn.
- `Comandante de Campo` passive implemented: on player creature summon, highest-ATK ally gains +1/+0 permanent.
- `_apply_permanent_stat_buff` and `_play_stat_buff_spell` infrastructure added; `reforco_aliado` e `amplificacao_campo` are now playable cards.
- `test_class_invocador.gd` added with 14 tests covering passive, hero power, legacy fallback, and buff cards.
- `modes/class_select/class_select.tscn` + `class_select_root.gd` created: displays 3 classes (name, tagline, passiva, hero power); player selects one; session and deck initialized; save written; routes to world.
- `boot_root.gd` updated: Novo jogo routes to `class_select.tscn` instead of `world.tscn`.
- `GameSession.get_battle_config()` now includes `class_id` when a class is selected, wiring P04 hero power dispatch into live battles.
- 6 new P05 tests added to `test_content_and_session.gd`: battle config with/without class, full Invocador selection flow, deck validity, save/load round-trip, battle config persistence.
- **P06 — Invocador is first complete playable class:** hero power button text reads `display_name` from catalog (`"Amplificar"` for Invocador); `battle_root.gd` shows per-slot targeting buttons (`"Amplificar → Slot X"`) instead of a generic hero power button when `effect.target == "any_own_creature"`; class select screen "Hero Power:" label corrected to Portuguese; battle feedback hint de-coupled from "Preparar Defesa" name; 3 new P06 tests in `test_content_and_session.gd` cover hero power label data and empty-class fallback.
- Mechanical IDs remain legacy-compatible and should not be renamed opportunistically.

## Active Planning Rule

Track 02 now executes through `linear-execution-plan.md`.

Each prompt must:

- execute only the next pending prompt in the linear plan
- keep mechanical IDs stable unless explicitly in the ID migration prompt
- update records at the end of the prompt
- run validation after runtime, generated-resource, scene, data, or test changes

Each pass should still change one player-facing or runtime layer at a time:

1. story labels and dialogue
2. class fantasy
3. mission chain framing
4. card text and reward meaning
5. RPG progression systems
6. new content volume
7. technical ID and asset migration

## Completed in P07

- `BattleEngine` now tracks volatile per-turn `fluxo: int`; increments after each `magia` or `magia_de_tabuleiro` resolved by the player; resets at player upkeep start.
- `_play_damage_spell` adds `_player_fluxo_bonus()` to base damage amount (Arcano only).
- `_try_trigger_fluxo` and `_player_fluxo_bonus` helpers isolate the logic; both guard on `active_class_id != "arcano"`.
- `test_arcano_fluxo.gd` added with 13 tests: counter init, increment per spell type, stacking, turn reset, damage amplification on 2nd/3rd spell, no-class isolation, and creature attack isolation.

## Completed in P08

- `_use_hero_power_damage` added to `BattleEngine`: Pulso Astral deals 1+fluxo magic damage to any enemy permanent or hero; validates target before spending energy; cost 1, once per own turn.
- `use_player_hero_power` dispatch extended: `action == "damage"` routes to `_use_hero_power_damage`.
- `battle_root.gd` updated: `_hero_power_needs_ally_target` replaced by `_hero_power_needs_targeting` (supports `any_own_creature` and `any_permanent_or_hero`); `_rebuild_hero_power_targets` shows per-slot enemy buttons and hero button for Arcano; three callbacks added (`_on_hero_power_own_slot_pressed`, `_on_hero_power_enemy_slot_pressed`, `_on_hero_power_enemy_hero_pressed`).
- Arcano fully playable end-to-end: class selectable in class_select.tscn, starter deck activates via `initialize_deck_for_class`, Pulso Astral functional with fluxo amplification.
- `test_class_arcano.gd` added with 12 tests: slot/hero targeting, cost, used flag, failure cases, fluxo amplification, no fluxo increment, and hero_power_used reset on new turn.

## Completed in P09

- 4 integration tests added to `test_content_and_session.gd` for Arcano catalog data:
  - `test_arcano_hero_power_display_name_is_pulso_astral`: `ContentLibrary.get_class_hero_power("arcano")` returns `display_name == "Pulso Astral"`.
  - `test_arcano_hero_power_effect_target_is_any_permanent_or_hero`: effect target is `"any_permanent_or_hero"`, confirming UI shows enemy-slot and hero buttons.
  - `test_arcano_hero_power_has_fluxo_bonus_flag`: effect carries `fluxo_bonus: true`, confirming BattleEngine applies fluxo amplification.
  - `test_arcano_class_passiva_id_is_fluxo_continuo`: class passiva id is `"fluxo_continuo"`.
- Records updated. Validation pending local run.

## Completed in P10

- `cinzas: int` added to `BattleEngine`: volatile-free (persists across turns), resets to 0 on `start_battle`.
- `memorial_de_batalha: Array` added to `BattleEngine`: per-encounter list, resets to `[]` on `start_battle`.
- `_record_creature_death(occupant)` helper added: increments `cinzas` and appends snapshot `{card_id, name, attack, max_health, keywords}` to `memorial_de_batalha`; called from `_remove_destroyed` for player, enemy, and neutral slot deaths.
- `get_state()` now exposes `cinzas` and `memorial_de_batalha`.
- `test_necromante_cinzas.gd` with 13 tests: init state, enemy death, ally death, simultaneous deaths, multi-kill accumulation, turn persistence, encounter reset for both counters, memorial data correctness (card_id/name, attack/max_health, both sides), and get_state exposure.

## Completed in P11

- `use_player_hero_power` dispatch extended: `action == "ritual_das_sombras"` bypasses energy check and routes to `_use_hero_power_ritual_das_sombras`.
- `_use_hero_power_ritual_das_sombras`: validates tier (1–3), reads cinzas_cost from tiers array, fails if cinzas < cost, sets hero_power_used, deducts cinzas, dispatches to tier handler.
- `_ritual_degrau_i`: applies debuff (`enjoo_estendido`, `queimando`, or `minus_atk` −2/+0) to enemy creature at target slot.
- `_ritual_spawn_from_memorial(target, full_stats)`: spawns token from memorial entry into empty ally slot; Degrau II = 1/1 no keywords; Degrau III = original stats and keywords; token has `is_token: true`.
- `enjoo_estendido`: stored as `enjoo_estendido_turns: 2` + "enjoo_estendido" in status array on occupant; blocks `_can_attack_from_slot`; `_tick_enjoo_estendido` decrements each upkeep of the affected controller, removes status at 0.
- `_tick_enjoo_estendido(controller_id)` called from `_resolve_upkeep` before energy refill.
- `test_class_necromante.gd` with 17 tests: hero_power_used flag, once-per-turn, no energy cost, cinzas insufficient for all 3 tiers, cinzas deducted correctly, Degrau I enjoo_estendido applied/blocks attack/expires after 2 upkeeps, Degrau I queimando/minus_atk, Degrau II 1/1 token (stats + name + is_token), Degrau III original stats, tier II vs III stat comparison, token generates cinzas on destruction.

## Completed in P12

- `on_death` field added to 3 Necromante starter-deck creatures in `slice_catalog.json`:
  - `incursor_vazio`: `on_death: { action: extra_cinza }` → +1 Cinza extra (total 2 on death)
  - `batedor_eter`: `on_death: { action: apply_status, status: enjoo, target: first_ready_enemy_creature }`
  - `lamina_choque`: `on_death: { action: damage, amount: 1, damage_type: magico, target: first_enemy_permanent }`
- `_build_occupant` now copies `on_death` from `card.effect` into the occupant dict.
- `_trigger_on_death(occupant)` dispatches on `action`: `extra_cinza` adds +1 cinza; `damage` hits first enemy permanent; `apply_status` applies status to first ready enemy creature.
- `_find_first_occupied_slot` and `_find_first_ready_creature_slot` helpers added.
- All 3 hooks guard silently (no crash) when no valid target exists.
- Hook fires for both player and enemy creature deaths via `_record_creature_death`.
- Necromante starter deck activated via existing `initialize_deck_for_class()` — no new session code needed.
- `test_on_death_triggers.gd` with 13 tests: all 3 on_death effect types, enemy-owned card fires hook, no-target guard cases, chain kill (lamina_choque kills enemy → 2 cinzas), no-trigger on placement or surviving damage, and 4 Necromante deck activation tests.
- `.tres` catalog regeneration required on next local validation run.

## Completed in P13

- 4 integration tests added to `test_content_and_session.gd` for Necromante catalog contract:
  - `test_necromante_hero_power_display_name_is_ritual_das_sombras`
  - `test_necromante_hero_power_action_is_ritual_das_sombras` — confirms BattleEngine dispatch key
  - `test_necromante_hero_power_has_three_tiers` — confirms 3-tier structure in effect
  - `test_necromante_class_passiva_id_is_colheita_sombria`
- All 3 classes (Invocador, Arcano, Necromante) have parallel integration test coverage in `test_content_and_session.gd`.
- Records updated. Validation pending local run.

## Completed in P14

- `test_multi_class_regression.gd` created with 21 regression tests:
  - Battle startup with correct `active_class_id` for all 3 classes.
  - Hero power `hero_power_used == false` at battle start for all 3 classes.
  - Full turn cycle completes cleanly for all 3 classes; fluxo resets for Arcano; cinzas persists for Necromante.
  - Invocador Amplificar and Necromante Ritual das Sombras Degrau I confirmed playable in non-duelo (no enemy hero required).
  - Arcano Pulso Astral slot-target confirmed in non-duelo; hero-target confirmed to fail without enemy hero.
  - Starter deck card-count (20) and catalog existence validated for all 3 classes.
- Stage 2 class implementation locked as new baseline.
- Records updated. Validation pending local run.

## Completed in P15

Design decision: Two most blocking test-play issues fixed together.

- `battle_root.gd`: `class_state_label` added to header (below vitals row); `_update_class_state_display()` shows `"Fluxo: N"` for Arcano and `"Cinzas: N | Memorial: N carta(s)"` for Necromante; hidden for Invocador/no class.
- `battle_root.gd`: `_hero_power_needs_targeting()` updated to return `true` for `action == "ritual_das_sombras"`.
- `battle_root.gd`: `_rebuild_hero_power_targets()` routes `ritual_das_sombras` to new `_build_ritual_tier_buttons()` helper.
- `battle_root.gd`: `_build_ritual_tier_buttons()` shows one "Ritual I → slot" button per occupied enemy slot (enjoo_estendido debuff, this UI pass), plus "Ritual II (1/1)" and "Ritual III (stats)" buttons gated by cinzas cost and memorial size. Falls back to disabled hero_power_button when no tiers reachable.
- `battle_root.gd`: `_on_ritual_i_pressed`, `_on_ritual_ii_pressed`, `_on_ritual_iii_pressed` callbacks added.
- `battle_slot_control.gd`: slot stats line now appends debuff status — `"Enjoo xN"` when `enjoo_estendido_turns > 0`, `"Queimando"` when status present.
- No layout tests added (UI is code-built, not scene-based; test-play is the verification path).
- Records updated. Validation pending local run.

## Completed in P16

- `mission` field added to all 11 encounters in `data/definitions/slice_catalog.json`: each encounter now carries a one-sentence Draxos operational purpose that flows into `.tres` on next regeneration.
- `docs/lore-campaign.md` updated: removed stale old 5 class names (Assaltante de Vazio, Arquiteto de Éter, Dominador Astral, Vinculador, Tecelão Astral); documented Invocador/Arcano/Necromante as the active classes; added Encounter Arc section listing all 8 world-chain encounters with their operational roles.
- Technical IDs kept stable (no renaming of `emboscada_na_ponte`, etc.).
- Existing rewards reviewed — current assignments are well-matched to encounter purpose; no changes required.
- No new runtime code or tests; `.tres` regeneration required locally to expose `mission` field.

## Completed in P17

- `operacao_rank: int` added to `GameSession`: persists in save, retrocompatible (old saves default to 0), clamped 0-3 on load.
- Auto-advances in `complete_encounter()` via `_check_rank_advancement()`: ≥1 completion → Agente, ≥3 → Operativo, ≥6 → Comandante.
- `get_rank_display_name() -> String` helper: "Recruta" / "Agente" / "Operativo" / "Comandante".
- Rank preserved in `capture_pre_combat_snapshot()` / `restore_pre_combat_snapshot()`.
- `world_root.gd`: 3 side encounters added to `ENCOUNTER_MARKERS` with `min_rank` gates: `patrulha_avancada` (rank 1), `duelista_sombrio` (rank 2), `emboscada_reforcos` (rank 3). These were already in the JSON but not on the map.
- `_marker_available()` extended to check `min_rank` against `GameSession.operacao_rank`.
- `_marker_status_text()` shows "Requer: Operativo" (etc.) when blocked by rank, not just "Bloqueado".
- NPC dialogue prefixed with rank name: "Agente — o comando libera..."
- `rank_label` added to world map top bar showing current rank in blue.
- `test_operacao_rank.gd` with 18 tests: initial state, all 4 rank thresholds, no-decrease, save/load, old save retrocompat, corrupted/overflow values, snapshot preserve/restore, and rank gate logic for all 3 side encounters.
- Validation pending local run.

## Completed in P18

- `class_pressure: Array` field added to 7 encounters in `data/definitions/slice_catalog.json` covering all 3 class weaknesses:
  - Invocador: `defesa_do_portao`, `fortaleza_do_desfiladeiro`, `patrulha_avancada`
  - Arcano: `invasao_em_ondas`, `duelista_sombrio`
  - Necromante: `enigma_da_ponte`, `colosso_fragmentado`
- Slot-level pressure adjustments:
  - `defesa_do_portao` starting_enemy_slots: goblin → `lobo_alfa` (atropelar pressure; destroys buffed Invocador creatures and deals excess damage to hero)
  - `invasao_em_ondas` wave 1 slot 0: goblin → `ladrao_rapido` (double rapido in wave 1 prevents Arcano from building Fluxo chain before rapid creatures strike)
- `ContentLibrary.get_all_encounters() -> Array` added in `data/content_library.gd` following `get_all_classes()` pattern.
- 6 new P18 tests added to `test_content_and_session.gd`:
  - `test_invocador_pressure_encounter_exists`
  - `test_arcano_pressure_encounter_exists`
  - `test_necromante_pressure_encounter_exists`
  - `test_each_class_has_at_least_one_pressure_encounter`
  - `test_defesa_do_portao_has_lobo_alfa_in_starting_slots`
  - `test_invasao_em_ondas_wave1_has_two_ladrao_rapido`
- `.tres` regeneration required locally (incorporates `class_pressure` from P18, `mission` from P16, `on_death` from P12).
- Validation pending local run; expected ~229+ tests green.

## Next Implementation Candidate

Continue with `P19 - New Content Expansion Cluster` from `linear-execution-plan.md`.

## Do Not Start Yet

- later class engine systems beyond P02
- final planet/crystal naming as hard canon
- broad card economy
- equipment/items
- save-breaking technical ID rename
- final art import

Those depend on decisions or later passes in `implementation-plan.md`.
