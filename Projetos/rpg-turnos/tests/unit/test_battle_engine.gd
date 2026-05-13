extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleEngineScript = preload("res://battle/battle_engine.gd")

var catalog

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()
	catalog = ContentLibrary.get_catalog()

func _start_engine(deck: Array, config: Dictionary = {}):
	var engine = BattleEngineScript.new()
	engine.start_battle(catalog, deck, config)
	return engine

func _starter_deck() -> Array:
	return Array(catalog.starter_deck_ids)

func test_c1_is_single_main_game_and_starts_clear_board() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	assert_eq(engine.modo_batalha, "limpar_mesa")
	assert_eq(engine.current_phase, "fase_principal")
	assert_eq(engine.active_player_id, "jogador")
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.hand.size(), 5)
	assert_eq(engine.energy, 3)
	assert_eq(engine.player_health, 25)
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.enemy_slots.size(), 3)
	assert_true(engine.controladores.has("jogador"))
	assert_true(engine.controladores.has("inimigo"))

func test_player_pass_automates_enemy_and_pauses_on_player_in_enemy_turn() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	var result: Dictionary = engine.pass_priority("jogador")

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.current_phase, "descarte")
	assert_eq(engine.discard_controller_id, "jogador")

	result = engine.finish_discard_phase()

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.turno, 2)
	assert_eq(engine.active_player_id, "inimigo")
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.current_phase, "fase_principal")

func test_hero_power_costs_energy_grants_persistent_armor_and_auto_resolves_enemy() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	var result: Dictionary = engine.use_player_hero_power()

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.energy, 2)
	assert_eq(engine.player_armor, 2)
	assert_eq(engine.player_health, 25)
	assert_true(engine.hero_power_used)
	assert_eq(engine.priority_owner_id, "jogador")
	assert_gt(engine.eventos_visuais.size(), 0)

func test_normal_action_auto_returns_priority_after_enemy_pass() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.consecutive_passes, 1)
	assert_true(engine.player_slots[0] != null)

func test_instant_action_keeps_priority_without_enemy_automation() -> void:
	var engine = _start_engine(["raio_curto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.priority_owner_id, "jogador")
	assert_eq(engine.consecutive_passes, 0)
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 1)

func test_creature_has_enjoo_until_own_upkeep() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	assert_eq(engine.get_slot_attack_status("jogador", 0), "Enjoo")

	engine.pass_priority("jogador")
	engine.finish_discard_phase()
	engine.pass_priority("jogador")

	assert_eq(engine.active_player_id, "jogador")
	assert_eq(engine.get_slot_attack_status("jogador", 0), "Pode atacar")

func test_rapido_can_attack_immediately() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	assert_eq(engine.get_slot_attack_status("jogador", 0), "Pode atacar")
	assert_gt(engine.get_attack_options("jogador", 0).size(), 0)

func test_attack_damage_between_creatures_is_simultaneous() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])

func test_clear_board_does_not_allow_empty_lane_attack_without_objective() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	engine.enemy_slots[0] = null
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	assert_eq(engine.get_attack_options("jogador", 0).size(), 0)

func test_duel_allows_empty_lane_attack_against_enemy_hero() -> void:
	var engine = _start_engine(
		["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"],
		{"encounter_id": "duelista_bandido", "enemy_ai_enabled": false}
	)

	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": -1})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.enemy_health, 17)

func test_duel_starts_with_enemy_hero_and_custom_deck() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "duelista_bandido", "enemy_ai_enabled": false})
	var enemy: Dictionary = engine._controller("inimigo")

	assert_eq(engine.modo_batalha, "duelo")
	assert_eq(engine.enemy_health, 20)
	assert_eq(Array(enemy.get("deck", [])).size(), 20)
	assert_eq(str(Array(enemy.get("deck", []))[0]), "goblin_ponte")
	assert_true(Array(enemy.get("deck", [])).has("dragao_jovem"))

func test_ondas_starts_first_wave_without_enemy_hero() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "invasao_em_ondas", "enemy_ai_enabled": false})
	var enemy: Dictionary = engine._controller("inimigo")

	assert_eq(engine.modo_batalha, "ondas")
	assert_false(enemy.has("hero"))
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.wave_index, 0)
	assert_eq(engine.wave_count, 2)
	assert_eq(engine.get_wave_label(), "Onda 1/2")
	assert_eq(str(engine.enemy_slots[0].get("card_id", "")), "ladrao_rapido")
	assert_eq(str(engine.enemy_slots[1].get("card_id", "")), "ladrao_rapido")
	assert_eq(str(engine.enemy_slots[2].get("card_id", "")), "arqueiro_ponte")

func test_ondas_spawns_next_wave_on_enemy_upkeep_after_clear() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "invasao_em_ondas", "enemy_ai_enabled": false})
	engine.player_slots[0] = engine._build_occupant(catalog.find_card("escudeiro"), "jogador", false)
	var starting_player_health: int = engine.player_health
	var starting_player_deck: Array = engine.deck.duplicate()
	engine.enemy_slots = [null, null, null]

	engine._check_outcome()

	assert_eq(engine.outcome, "")

	engine._resolve_upkeep("inimigo")

	assert_eq(engine.wave_index, 1)
	assert_eq(engine.get_wave_label(), "Onda 2/2")
	assert_eq(engine.player_health, starting_player_health)
	assert_eq(engine.deck, starting_player_deck)
	assert_true(engine.player_slots[0] != null)
	assert_eq(str(engine.enemy_slots[0].get("card_id", "")), "lobo_alfa")
	assert_eq(str(engine.enemy_slots[1].get("card_id", "")), "corvo_batedor")
	assert_eq(str(engine.enemy_slots[2].get("card_id", "")), "bruto_ponte")

func test_ondas_victory_only_after_final_wave_clear() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "invasao_em_ondas", "enemy_ai_enabled": false})
	engine.enemy_slots = [null, null, null]

	engine._check_outcome()

	assert_eq(engine.outcome, "")

	engine._resolve_upkeep("inimigo")
	engine.enemy_slots = [null, null, null]
	engine._check_outcome()

	assert_eq(engine.outcome, "victory")

func test_defesa_starts_without_enemy_hero_and_tracks_turn_limit() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "defesa_do_portao", "enemy_ai_enabled": false})
	var enemy: Dictionary = engine._controller("inimigo")

	assert_eq(engine.modo_batalha, "defesa")
	assert_false(enemy.has("hero"))
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.defense_turn_limit, 2)
	assert_eq(engine.defense_turns_survived, 0)
	assert_eq(engine.get_defense_label(), "Defesa 0/2")
	assert_eq(str(engine.enemy_slots[0].get("card_id", "")), "lobo_alfa")
	assert_eq(str(engine.enemy_slots[2].get("card_id", "")), "ladrao_rapido")
	assert_eq(str(engine.enemy_slots[5].get("card_id", "")), "atirador_torre")

func test_defesa_does_not_win_when_enemy_board_is_clear() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "defesa_do_portao", "enemy_ai_enabled": false})
	engine.enemy_slots = [null, null, null, null, null, null]

	engine._check_outcome()

	assert_eq(engine.outcome, "")
	assert_eq(engine.defense_turns_survived, 0)

func test_defesa_wins_after_required_enemy_turns_survived() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "defesa_do_portao", "enemy_ai_enabled": false})

	engine._record_defense_turn_survived("inimigo")
	engine._check_outcome()

	assert_eq(engine.outcome, "")
	assert_eq(engine.get_defense_label(), "Defesa 1/2")

	engine._record_defense_turn_survived("inimigo")
	engine._check_outcome()

	assert_eq(engine.outcome, "victory")
	assert_eq(engine.get_defense_label(), "Defesa 2/2")

func test_chefe_multiparte_starts_without_enemy_hero_and_tracks_parts() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "colosso_fragmentado", "enemy_ai_enabled": false})
	var enemy: Dictionary = engine._controller("inimigo")

	assert_eq(engine.modo_batalha, "chefe_multiparte")
	assert_false(enemy.has("hero"))
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.boss_part_slots.size(), 3)
	assert_eq(engine.boss_part_slots[0], 0)
	assert_eq(engine.boss_part_slots[1], 2)
	assert_eq(engine.boss_part_slots[2], 5)
	assert_eq(engine.get_boss_label(), "Partes 0/3")
	assert_eq(str(engine.enemy_slots[0].get("card_id", "")), "guardiao_portal")
	assert_eq(str(engine.enemy_slots[1].get("card_id", "")), "bruto_ponte")
	assert_eq(str(engine.enemy_slots[2].get("card_id", "")), "torre_blindada")
	assert_eq(str(engine.enemy_slots[5].get("card_id", "")), "atirador_torre")

func test_chefe_multiparte_ignores_non_part_support_for_victory() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "colosso_fragmentado", "enemy_ai_enabled": false})
	engine.enemy_slots[1] = null

	engine._check_outcome()

	assert_eq(engine.outcome, "")
	assert_eq(engine.get_boss_label(), "Partes 0/3")

	engine.enemy_slots[0] = null
	engine._check_outcome()

	assert_eq(engine.outcome, "")
	assert_eq(engine.get_boss_label(), "Partes 1/3")

func test_chefe_multiparte_wins_when_all_parts_are_destroyed_even_with_support_alive() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "colosso_fragmentado", "enemy_ai_enabled": false})
	engine.enemy_slots[0] = null
	engine.enemy_slots[2] = null
	engine.enemy_slots[5] = null

	engine._check_outcome()

	assert_true(engine.enemy_slots[1] != null)
	assert_eq(engine.outcome, "victory")

func test_quebra_cabeca_starts_without_enemy_hero_and_tracks_targets() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "enigma_da_ponte", "enemy_ai_enabled": false})
	var enemy: Dictionary = engine._controller("inimigo")

	assert_eq(engine.modo_batalha, "quebra_cabeca")
	assert_false(enemy.has("hero"))
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.puzzle_target_slots.size(), 2)
	assert_eq(engine.puzzle_target_slots[0], 0)
	assert_eq(engine.puzzle_target_slots[1], 2)
	assert_eq(engine.puzzle_turn_limit, 2)
	assert_eq(engine.puzzle_turns_used, 0)
	assert_eq(engine.get_puzzle_label(), "Alvos 0/2 | Turnos 0/2")
	assert_eq(str(engine.enemy_slots[0].get("card_id", "")), "barricada")
	assert_eq(str(engine.enemy_slots[1].get("card_id", "")), "guardiao_portal")
	assert_eq(str(engine.enemy_slots[2].get("card_id", "")), "atirador_torre")

func test_quebra_cabeca_wins_when_targets_clear_even_with_support_alive() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "enigma_da_ponte", "enemy_ai_enabled": false})
	engine.enemy_slots[0] = null
	engine.enemy_slots[2] = null

	engine._check_outcome()

	assert_true(engine.enemy_slots[1] != null)
	assert_eq(engine.outcome, "victory")
	assert_eq(engine.get_puzzle_label(), "Alvos 2/2 | Turnos 0/2")

func test_quebra_cabeca_loses_when_turn_limit_expires_without_targets_clear() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "enigma_da_ponte", "enemy_ai_enabled": false})
	engine._record_puzzle_turn_used("jogador")
	engine._check_outcome()

	assert_eq(engine.outcome, "")
	assert_eq(engine.get_puzzle_label(), "Alvos 0/2 | Turnos 1/2")

	engine._record_puzzle_turn_used("jogador")
	engine._check_outcome()

	assert_eq(engine.outcome, "defeat")
	assert_eq(engine.get_puzzle_label(), "Alvos 0/2 | Turnos 2/2")

func test_enemy_hero_power_uses_golpe_direto_once() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "duelista_bandido", "enemy_ai_enabled": false})
	engine.active_player_id = "inimigo"
	engine.priority_owner_id = "inimigo"
	engine.current_phase = "fase_principal"

	var result: Dictionary = engine._enemy_use_hero_power()

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.player_health, 24)
	assert_eq(engine.priority_owner_id, "jogador")
	assert_true(bool(engine._controller("inimigo").get("hero_power_used", false)))

	result = engine._enemy_use_hero_power()
	assert_false(bool(result.get("ok", false)))

func test_enemy_ai_uses_power_before_playing_cards() -> void:
	var engine = _start_engine(_starter_deck(), {"encounter_id": "duelista_bandido", "enemy_ai_enabled": true})
	var enemy: Dictionary = engine._controller("inimigo")
	enemy["hand"] = ["goblin_ponte"]
	enemy["energy"] = 3
	engine._set_controller("inimigo", enemy)
	engine.active_player_id = "inimigo"
	engine.priority_owner_id = "inimigo"
	engine.current_phase = "fase_principal"

	var result: Dictionary = engine._perform_enemy_action()

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.player_health, 24)
	assert_null(engine.enemy_slots[0])

	engine.priority_owner_id = "inimigo"
	result = engine._perform_enemy_action()

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(engine.enemy_slots[0].get("card_id", "")), "goblin_ponte")

func test_creature_can_move_once_to_neutral_slot() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {
		"encounter_id": "emboscada_no_cruzamento",
		"enemy_ai_enabled": false
	})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	var result: Dictionary = engine.move_unit("jogador", "jogador", 0, "neutro", 0)

	assert_true(bool(result.get("ok", false)))
	assert_null(engine.player_slots[0])
	assert_eq(str(engine.neutral_slots[0].get("card_id", "")), "escudeiro")
	assert_false(bool(engine.neutral_slots[0].get("exhausted", false)))

	engine.priority_owner_id = "jogador"
	result = engine.move_unit("jogador", "neutro", 0, "jogador", 0)
	assert_false(bool(result.get("ok", false)))

func test_size_no_longer_restricts_slot_placement() -> void:
	var engine = _start_engine(["bruto_mercenario", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "jogador", "slot": 1})

	assert_true(bool(result.get("ok", false)))
	assert_eq(str(engine.player_slots[1].get("card_id", "")), "bruto_mercenario")

func test_cover_reduces_ranged_damage() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 2})
	engine.priority_owner_id = "inimigo"

	var result: Dictionary = engine.attack_with_unit("inimigo", 2, {"owner": "jogador", "slot": 2})

	assert_true(bool(result.get("ok", false)))
	assert_eq(int(engine.player_slots[2].get("health", 0)), 2)

func test_cover_keyword_stacks_against_fisico_alcance() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.player_slots[2] = engine._build_occupant(catalog.find_card("torre_blindada"), "jogador", false)
	engine.enemy_slots[2] = engine._build_occupant(catalog.find_card("atirador_torre"), "inimigo", false)
	engine.priority_owner_id = "inimigo"

	var result: Dictionary = engine.attack_with_unit("inimigo", 2, {"owner": "jogador", "slot": 2})

	assert_true(bool(result.get("ok", false)))
	assert_eq(int(engine.player_slots[2].get("health", 0)), 7)

func test_defensor_cannot_attack() -> void:
	var engine = _start_engine(["guarda_vila", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	engine.player_slots[0]["summoning_sick"] = false
	engine.player_slots[0]["ready"] = true

	assert_eq(engine.get_slot_attack_status("jogador", 0), "Sem alvo")
	assert_eq(engine.get_attack_options("jogador", 0).size(), 0)

func test_high_reach_route_can_offer_multiple_targets() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 1})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 2})
	engine.priority_owner_id = "inimigo"

	var options: Array = engine.get_attack_options("inimigo", 2)

	assert_eq(options.size(), 2)
	assert_eq(str(Dictionary(options[0]).get("label", "")), "P2")
	assert_eq(str(Dictionary(options[1]).get("label", "")), "P3")

func test_voadora_enters_ready_and_can_attack_alto() -> void:
	var engine = _start_engine(["corvo_batedor", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "jogador", "slot": 2})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.get_slot_attack_status("jogador", 2), "Pode atacar")
	var options: Array = engine.get_attack_options("jogador", 2)
	assert_eq(options.size(), 1)
	assert_eq(str(Dictionary(options[0]).get("label", "")), "E3")

func test_melee_skips_voadora_and_targets_next_non_flying() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.enemy_slots[0] = engine._build_occupant(catalog.find_card("corvo_batedor"), "inimigo", false)
	engine.enemy_slots[1] = engine._build_occupant(catalog.find_card("goblin_ponte"), "inimigo", false)
	engine._attack_routes[engine._route_key("jogador", 0)] = {
		"targets": [{"owner": "inimigo", "slot": 0}, {"owner": "inimigo", "slot": 1}],
		"fallback_slots": [],
		"ranged_targets": [],
		"fallback": "none"
	}
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	var options: Array = engine.get_attack_options("jogador", 0)

	assert_eq(options.size(), 1)
	assert_eq(str(Dictionary(options[0]).get("label", "")), "E2")

	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 1})
	assert_true(bool(result.get("ok", false)))
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 2)

func test_magico_damage_can_hit_voadora() -> void:
	var engine = _start_engine(["raio_curto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.enemy_slots[0] = engine._build_occupant(catalog.find_card("corvo_batedor"), "inimigo", false)

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 1)

func test_fallback_slots_are_used_after_front_line_is_empty() -> void:
	var engine = _start_engine(["lobo_faminto", "escudeiro", "escudeiro", "escudeiro"], {
		"encounter_id": "fortaleza_do_desfiladeiro",
		"enemy_ai_enabled": false
	})
	engine.enemy_slots[0] = null
	engine.enemy_slots[3] = engine._build_occupant(catalog.find_card("goblin_ponte"), "inimigo", false)
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})

	var options: Array = engine.get_attack_options("jogador", 0)

	assert_eq(options.size(), 1)
	assert_eq(str(Dictionary(options[0]).get("label", "")), "EB1")

func test_atropelar_deals_overflow_to_hero_in_duel() -> void:
	var engine = _start_engine(
		["javali_guerra", "escudeiro", "escudeiro", "escudeiro"],
		{"encounter_id": "duelista_bandido", "enemy_ai_enabled": false}
	)
	engine.enemy_slots[0] = engine._build_occupant(catalog.find_card("goblin_ponte"), "inimigo", false)
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	engine.player_slots[0]["summoning_sick"] = false
	engine.player_slots[0]["ready"] = true

	var result: Dictionary = engine.attack_with_unit("jogador", 0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.enemy_health, 18)

func test_burning_terrain_ticks_on_occupant_upkeep() -> void:
	var engine = _start_engine(["escudeiro", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	engine._player_slot_definitions[0]["terrain"] = "queimando"

	engine._resolve_upkeep("jogador")

	assert_eq(int(engine.player_slots[0].get("health", 0)), 1)

func test_burning_slot_and_creature_status_stack() -> void:
	var engine = _start_engine(["guarda_vila", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	engine.play_card_from_hand(0, {"owner": "jogador", "slot": 0})
	engine._player_slot_definitions[0]["terrain"] = "queimando"
	engine.player_slots[0]["status"] = ["queimando"]

	engine._resolve_upkeep("jogador")

	assert_eq(int(engine.player_slots[0].get("health", 0)), 2)

func test_chuva_brasas_applies_queimando_to_all_enemy_slots() -> void:
	var engine = _start_engine(["chuva_brasas", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	var controller: Dictionary = engine._controller("jogador")
	controller["energy"] = 4
	engine._set_controller("jogador", controller)

	var result: Dictionary = engine.play_card_from_hand(0, {})

	assert_true(bool(result.get("ok", false)))
	for slot_def: Variant in engine._enemy_slot_definitions:
		assert_true(Array(Dictionary(slot_def).get("status", [])).has("queimando"))

	engine._resolve_upkeep("inimigo")

	assert_eq(int(engine.enemy_slots[0].get("health", 0)), 1)

func test_draw_uses_cyclic_deck_without_discard_pile() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})
	var controller: Dictionary = engine._controller("jogador")
	controller["hand"] = _starter_deck().slice(0, 7)
	controller["deck"] = ["escudeiro", "guarda_vila"]
	controller["max_hand_size"] = 7
	engine._set_controller("jogador", controller)

	var drawn: int = engine._draw_cards_for("jogador", 2)

	assert_eq(drawn, 2)
	assert_eq(engine._controller("jogador").get("hand").size(), 9)
	assert_eq(engine.current_phase, "descarte")
	assert_eq(engine.discard_target_size, 8)
	assert_false(engine.get_state().has("discard"))

	engine.discard_card_from_hand(0)

	assert_eq(engine._controller("jogador").get("hand").size(), 8)
	assert_eq(str(Array(engine._controller("jogador").get("deck", [])).back()), "escudeiro")

func test_energy_and_hand_limit_ramp_on_own_upkeep() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})

	assert_eq(int(engine._controller("jogador").get("energy_max", 0)), 3)
	assert_eq(int(engine._controller("jogador").get("max_hand_size", 0)), 5)

	engine._resolve_upkeep("jogador")

	assert_eq(int(engine._controller("jogador").get("energy_max", 0)), 4)
	assert_eq(int(engine._controller("jogador").get("max_hand_size", 0)), 6)

func test_public_discard_phase_reduces_hand_to_carry_limit() -> void:
	var engine = _start_engine(_starter_deck(), {"enemy_ai_enabled": false})
	var controller: Dictionary = engine._controller("jogador")
	controller["hand"] = _starter_deck().slice(0, 8)
	engine._set_controller("jogador", controller)

	engine.pass_priority("jogador")

	assert_eq(engine.current_phase, "descarte")
	assert_false(engine.can_finish_discard())

	var discarded_id: String = str(engine.hand[0])
	engine.discard_card_from_hand(0)

	assert_true(engine.can_finish_discard())
	assert_eq(engine.hand.size(), 7)
	assert_eq(str(Array(engine._controller("jogador").get("deck", [])).back()), discarded_id)

	var result: Dictionary = engine.finish_discard_phase()

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.turno, 2)

func test_spell_goes_to_bottom_of_deck_not_discard() -> void:
	var engine = _start_engine(["raio_curto", "escudeiro", "escudeiro", "escudeiro"], {"enemy_ai_enabled": false})
	var starting_deck_size: int = engine.deck.size()

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 0})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.discard.size(), 0)
	assert_eq(engine.deck.size(), starting_deck_size + 1)
	assert_eq(str(engine.deck.back()), "raio_curto")

func test_clear_board_victory_when_last_enemy_destroyed() -> void:
	var engine = _start_engine(["golpe_preciso", "golpe_preciso", "golpe_preciso", "golpe_preciso"], {"enemy_ai_enabled": false})
	engine.enemy_slots[0] = null
	engine.enemy_slots[1] = null
	engine.enemy_slots[2]["health"] = 3

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": 2})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.outcome, "victory")

func test_duel_victory_when_enemy_hero_reaches_zero() -> void:
	var engine = _start_engine(
		["golpe_preciso", "golpe_preciso", "golpe_preciso", "golpe_preciso"],
		{"encounter_id": "duelista_bandido", "enemy_ai_enabled": false}
	)
	engine.force_enemy_health(3)

	var result: Dictionary = engine.play_card_from_hand(0, {"owner": "inimigo", "slot": -1})

	assert_true(bool(result.get("ok", false)))
	assert_eq(engine.outcome, "victory")

func test_player_defeat_wins_over_simultaneous_result() -> void:
	var engine = _start_engine(["golpe_preciso", "golpe_preciso", "golpe_preciso", "golpe_preciso"], {"enemy_ai_enabled": false})

	engine.force_player_health(0)

	assert_eq(engine.outcome, "defeat")
