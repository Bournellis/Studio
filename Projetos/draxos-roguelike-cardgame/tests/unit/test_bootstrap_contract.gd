extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))
	ContentLibrary.reload()
	VisualAssets.reload()

func before_each() -> void:
	RunSession.reset()

func test_catalog_uses_redesigned_class_decks() -> void:
	var catalog = ContentLibrary.get_catalog()
	for class_id: String in ["arcano", "invocador", "necromante"]:
		var class_option: Dictionary = catalog.find_class_option(class_id)
		assert_false(class_option.is_empty(), "Missing class %s" % class_id)
		assert_eq(int(class_option.get("starting_mana", 0)), 2)
		assert_eq(int(class_option.get("starting_health", 0)), 20)
		assert_eq(int(class_option.get("starting_hand_size", 0)), 3)
		var deck: Array = Array(class_option.get("starter_deck", []))
		assert_eq(deck.size(), 12)
		var counts: Dictionary = {}
		for card_id: String in deck:
			assert_not_null(catalog.find_card(card_id), "Missing card %s" % card_id)
			counts[card_id] = int(counts.get(card_id, 0)) + 1
		assert_eq(counts.size(), 4)
		for count: Variant in counts.values():
			assert_eq(int(count), 3)

func test_catalog_removes_old_player_cards_and_keeps_enemies() -> void:
	var catalog = ContentLibrary.get_catalog()
	for removed_id: String in ["arcano_spell_dano", "arcano_construtor_fluxo", "invocador_protecao", "invocador_buff_unico", "necro_spell_lentidao"]:
		assert_null(catalog.find_card(removed_id), "Old player card should be removed: %s" % removed_id)
	for enemy_id: String in ["elemental_agil", "elemental_guardiao", "elemental_tita"]:
		assert_not_null(catalog.find_card(enemy_id), "Enemy card should remain: %s" % enemy_id)
	assert_true(ContentLibrary.get_card("invocador_guardiao").has_keyword("defensor"))
	assert_true(ContentLibrary.get_card("necro_esqueleto").has_keyword("reviver"))

func test_run_session_tracks_hand_limit_reward() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.max_mana, 2)
	assert_eq(RunSession.max_hand_size, 3)
	assert_eq(RunSession.current_deck_ids.size(), 12)
	RunSession.record_battle_result("n02_ondas_iniciais", "vitoria", 20)
	assert_eq(RunSession.max_mana, 3)
	RunSession.record_battle_result("n03_duelo_inicial", "vitoria", 20)
	assert_eq(RunSession.max_hand_size, 4)
	assert_eq(RunSession.current_deck_ids.size(), 12)
	assert_true(RunSession.automatic_reward_ids.has("n03_duelo_inicial:%s" % RunSession.REWARD_MAX_HAND_SIZE_1))

func test_battle_engine_draws_to_dynamic_hand_limit() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "arcano_fagulha", "arcano_barreira", "arcano_tempestade", "arcano_choque"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(engine.hand.size(), 3)
	engine.max_hand_size = 4
	engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0})
	assert_eq(engine.hand.size(), 4)

func test_ability_power_updates_spell_values_and_text() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha", "arcano_barreira", "arcano_choque", "arcano_tempestade"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"class_passive_unlocked": true,
		"mana_per_turn": 4,
		"max_hand_size": 4,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0})
	engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 1})
	assert_eq(int(engine.get_state().get("ability_power", 0)), 2)
	var text: String = VisualAssets.card_display_text(ContentLibrary.get_card("arcano_choque"), engine.get_card_text_context("arcano_choque"))
	assert_string_contains(text, "Causa 5 de dano")
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 2})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_null(engine.enemy_slots[2])

func test_ability_power_updates_class_active_values() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha", "invocador_soldado", "invocador_soldado"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"class_active_unlocked": true,
		"mana_per_turn": 4,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 1})
	engine.play_card_from_hand(0, {"slot": 0})
	assert_eq(int(engine.get_state().get("ability_power", 0)), 1)
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 5)

func test_defender_redirects_empty_lane_to_nearest_defender() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_soldado", "invocador_soldado"], {
		"encounter": {
			"id": "test_defensor",
			"display_name": "Teste Defensor",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "invocador_guardiao"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_eq(engine.enemy_health, 20)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 2)

func test_promote_choice_applies_stats_or_keywords() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "arcano_fagulha", "invocador_promover"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 3,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.play_card_from_hand(0, {"slot": 1})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_true(engine.has_pending_choice())
	engine.resolve_pending_choice({}, BattleEngine.PROMOTE_CHOICE_STATS)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 4)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 4)

func test_reviver_returns_once_but_not_on_replacement() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto", "invocador_soldado", "invocador_soldado"], {
		"encounter": {
			"id": "test_reviver",
			"display_name": "Teste Reviver",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_true(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))
	engine.play_card_from_hand(0, {"slot": 0})
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	assert_false(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))

func test_on_death_weaken_uses_pending_target_choice() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_morto_vivo", "arcano_choque", "arcano_choque"], {
		"encounter": {
			"id": "test_enfraquecer",
			"display_name": "Teste Enfraquecer",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_menor"},
				{"slot": 1, "card_id": "elemental_bruto"}
			]
		},
		"mana_per_turn": 2,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_true(engine.has_pending_choice())
	engine.resolve_pending_choice({"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("attack", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("health", 0)), 2)

func test_combat_cycle_resolves_combat_before_maintenance() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "arcano_choque", "arcano_choque"], {
		"encounter_id": "ondas_iniciais",
		"class_id": "arcano",
		"mana_per_turn": 3,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine._damage_slot(BattleEngine.ENEMY_ID, 0, 99)
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 99)
	assert_eq(engine.wave_index, 1)
	engine.resolve_combat_cycle()
	assert_eq(engine.wave_index, 2)

func test_battle_scene_uses_resolve_combat_button() -> void:
	_start_class_run("arcano")
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var button: Button = battle.find_child("BattleEndTurnFloatingButton", true, false)
	assert_not_null(button)
	assert_string_contains(button.text, "Resolver")
	battle.queue_free()
	await get_tree().process_frame

func _instantiate_scene(path: String):
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	var node = packed.instantiate()
	add_child(node)
	await get_tree().process_frame
	return node

func _start_class_run(class_id: String, seed: int = 0) -> void:
	var result: Dictionary = RunSession.start_class_run(class_id, seed)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
