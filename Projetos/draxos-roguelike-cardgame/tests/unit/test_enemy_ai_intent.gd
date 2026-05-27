extends "res://tests/unit/draxos_test_base.gd"

func test_duel_enemy_commander_plays_after_combat_for_next_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_duel_enemy_after_combat",
			"display_name": "Teste Duelo Ordem IA",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_commander_enabled": true,
			"enemy_mana_per_turn": 2,
			"enemy_hand_count": 1,
			"enemy_deck": ["elemental_duelista"],
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 2)
	assert_eq(engine.enemy_health, 18)
	assert_eq(str(Dictionary(engine.enemy_slots[0]).get("card_id", "")), "elemental_duelista")

func test_duel_encounters_enemy_commander_draws_and_plays_cards() -> void:
	for encounter_id: String in ["duelo_inicial", "duelo_elite"]:
		var engine: BattleEngine = BattleEngine.new()
		engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_soldado", "invocador_soldado"], {
			"encounter_id": encounter_id,
			"mana_per_turn": 3,
			"max_hand_size": 3,
			"player_health": 20,
			"shuffle_deck": false
		})
		assert_true(engine.enemy_commander_enabled)
		assert_gt(engine.enemy_hand.size(), 0)

	var custom_engine: BattleEngine = BattleEngine.new()
	custom_engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_duel_commander_free_lane",
			"display_name": "Teste Duelo Commander",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_ai_profile": "ar",
			"enemy_commander_enabled": true,
			"enemy_mana_per_turn": 3,
			"enemy_hand_count": 1,
			"enemy_deck": ["enemy_ar_elemental_do_raio"],
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	var before_board: int = _occupied_count(custom_engine.enemy_slots)
	custom_engine.resolve_combat_cycle()
	assert_gt(_occupied_count(custom_engine.enemy_slots), before_board)
	assert_true(_enemy_board_has_card(custom_engine.enemy_slots, "enemy_ar_elemental_do_raio"))

func test_enemy_ai_profiles_make_deterministic_lane_decisions() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_ar_ai_empty_lane",
			"display_name": "Teste AI Ar",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_ai_profile": "ar",
			"enemy_commander_enabled": true,
			"enemy_mana_per_turn": 3,
			"enemy_hand_count": 1,
			"enemy_deck": ["enemy_ar_elemental_do_raio"],
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	engine._resolve_enemy_turn_actions()
	assert_eq(str(Dictionary(engine.enemy_slots[1]).get("card_id", "")), "enemy_ar_elemental_do_raio")

	engine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha"], {
		"encounter": {
			"id": "test_terra_ai_defender",
			"display_name": "Teste AI Terra",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_ai_profile": "terra",
			"enemy_commander_enabled": true,
			"enemy_mana_per_turn": 3,
			"enemy_hand_count": 1,
			"enemy_deck": ["enemy_terra_elemental_granito"],
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(ContentLibrary.get_card("arcano_barreira"), BattleEngine.PLAYER_ID, false)
	engine._resolve_enemy_turn_actions()
	assert_eq(str(Dictionary(engine.enemy_slots[0]).get("card_id", "")), "enemy_terra_elemental_granito")

func test_enemy_intent_reports_common_priorities_and_boss_hooks() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_intent_ar",
			"display_name": "Teste Intent Ar",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_ai_profile": "ar",
			"enemy_commander_enabled": true,
			"enemy_mana_per_turn": 3,
			"enemy_hand_count": 1,
			"enemy_deck": ["enemy_ar_elemental_do_raio"],
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	var intent: Dictionary = engine.get_enemy_intent()
	assert_true(bool(intent.get("visible", false)))
	assert_eq(str(intent.get("profile_id", "")), "ar")
	assert_string_contains(str(intent.get("next_action", "")), "Elemental do Raio")
	assert_string_contains(str(intent.get("incoming_field_effect", "")), "posicional")

	engine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha"], {
		"encounter": {
			"id": "test_boss_intent",
			"display_name": "Teste Boss Intent",
			"mode": BattleEngine.MODE_SUMMONER_BOSS,
			"enemy_ai_profile": "fogo",
			"boss_health": 30,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [],
			"boss_summons": [{"card_id": "enemy_fogo_elemental_de_chama"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	intent = engine.get_enemy_intent()
	assert_eq(str(intent.get("kind", "")), "boss")
	assert_string_contains(str(intent.get("current_phase", "")), "Fase 1")
	assert_string_contains(str(intent.get("next_scripted_trigger", "")), "66%")
	assert_string_contains(str(intent.get("next_major_special_action", "")), "Elemental de Chama")
