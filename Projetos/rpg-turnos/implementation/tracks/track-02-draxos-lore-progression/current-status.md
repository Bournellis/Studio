# Track 02 Current Status

- Last Updated: `2026-05-13` (P17 complete)
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
- `_tick_enjoo_estend