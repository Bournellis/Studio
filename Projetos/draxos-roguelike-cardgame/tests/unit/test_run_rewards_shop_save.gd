extends "res://tests/unit/draxos_test_base.gd"

func test_run_session_tracks_hand_limit_reward() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.max_mana, 1)
	assert_eq(RunSession.max_hand_size, 3)
	assert_eq(RunSession.current_deck_ids.size(), 9)
	assert_eq(RunSession.current_node_id, "n01_tutorial_primeiro_contato")
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	assert_eq(RunSession.max_mana, 2)
	RunSession.record_battle_result("n02_tutorial_dois_fronts", "vitoria", 20)
	assert_eq(RunSession.current_deck_ids.size(), 12)
	assert_eq(RunSession.current_deck_ids.count("arcano_tempestade"), 3)
	RunSession.record_battle_result("n05_ondas_iniciais", "vitoria", 20)
	assert_eq(RunSession.max_mana, 3)
	RunSession.record_battle_result("n06_duelo_inicial", "vitoria", 20)
	assert_eq(RunSession.max_hand_size, 4)
	assert_eq(RunSession.current_deck_ids.size(), 12)
	assert_true(RunSession.automatic_reward_ids.has("n06_duelo_inicial:%s" % RunSession.REWARD_MAX_HAND_SIZE_1))
	assert_false(RunSession.has_pending_reward())

func test_reward_choices_apply_levels_and_two_step_new_cards() -> void:
	var result: Dictionary = RunSession.start_class_run("invocador", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.record_battle_result("n02_tutorial_dois_fronts", "vitoria", 20)
	RunSession.record_battle_result("n03_tutorial_primeira_onda", "vitoria", 20)
	var upgrade_choices: Array[Dictionary] = RunSession.pending_reward_choices()
	assert_eq(upgrade_choices.size(), 3)
	assert_string_contains(str(upgrade_choices[0].get("title", "")), "Lvl 2")
	var upgrade_result: Dictionary = RunSession.apply_reward_choice(str(upgrade_choices[0].get("id", "")))
	assert_true(bool(upgrade_result.get("ok", false)), str(upgrade_result.get("message", "")))
	var upgraded_card_id: String = str(upgrade_choices[0].get("card_id", ""))
	assert_eq(int(RunSession.card_upgrade_counts.get(upgraded_card_id, 0)), 1)
	assert_true(RunSession.effective_card_id(upgraded_card_id).ends_with("_lvl2"))
	RunSession.record_battle_result("n07_defesa_posicao", "vitoria", 20)
	var new_card_choices: Array[Dictionary] = RunSession.pending_reward_choices()
	assert_eq(new_card_choices.size(), 2)
	var before_count: int = RunSession.current_deck_ids.size()
	var card_id: String = str(new_card_choices[0].get("card_id", ""))
	var added_copies: int = _new_card_copies_for_rarity(str(new_card_choices[0].get("rarity", "")))
	var card_result: Dictionary = RunSession.apply_reward_choice(str(new_card_choices[0].get("id", "")))
	assert_true(bool(card_result.get("ok", false)), str(card_result.get("message", "")))
	assert_eq(RunSession.current_deck_ids.size(), before_count + added_copies)
	assert_eq(RunSession.current_deck_ids.count(card_id), added_copies)
	var remaining_card_id: String = ""
	for reward_card_id: String in ["invocador_atacar", "invocador_golem"]:
		if reward_card_id != card_id:
			remaining_card_id = reward_card_id
	RunSession.record_battle_result("n11_ondas_avancadas", "vitoria", 20)
	assert_false(RunSession.has_pending_reward())
	assert_gt(RunSession.current_deck_ids.count(remaining_card_id), 0)

func test_necromancer_passive_reward_unlocks_active_then_upgrade() -> void:
	var result: Dictionary = RunSession.start_class_run("necromante", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.record_battle_result("n08_chefe_invocador", "vitoria", 20)
	assert_true(RunSession.class_passive_unlocked)
	assert_true(RunSession.class_active_unlocked)
	assert_eq(RunSession.class_active_level, 1)
	assert_true(RunSession.has_relic_id(RunSession.RELIC_CATALISADOR_ARCANO))
	RunSession.record_battle_result("n10_limpeza_elite", "vitoria", 20)
	assert_eq(RunSession.class_active_level, 2)
	assert_eq(RunSession.max_health, 25)
	assert_eq(RunSession.current_health, 25)

func test_arcano_and_invocador_keep_active_on_second_reward() -> void:
	for class_id: String in ["arcano", "invocador"]:
		var result: Dictionary = RunSession.start_class_run(class_id, 77)
		assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
		RunSession.record_battle_result("n08_chefe_invocador", "vitoria", 20)
		assert_true(RunSession.class_passive_unlocked)
		assert_false(RunSession.class_active_unlocked)
		RunSession.record_battle_result("n10_limpeza_elite", "vitoria", 20)
		assert_true(RunSession.class_active_unlocked)
		assert_eq(RunSession.max_health, 25)
		RunSession.reset()

func test_run_session_snapshot_tracks_reward_choice_state() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.record_battle_result("n03_tutorial_primeira_onda", "vitoria", 20)
	var snapshot: Dictionary = RunSession.snapshot()
	assert_eq(int(snapshot.get("version", 0)), RunSession.SNAPSHOT_VERSION)
	assert_eq(Array(snapshot.get("rewards_pending", [])).size(), 1)
	var pending: Dictionary = Dictionary(Array(snapshot.get("rewards_pending", []))[0])
	assert_false(Dictionary(pending.get("rarity_by_card_id", {})).is_empty())

func test_run_session_snapshot_tracks_track02_state() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var relic_result: Dictionary = RunSession.add_relic_id("bolsa_de_cinzas")
	assert_true(bool(relic_result.get("ok", false)), str(relic_result.get("message", "")))
	RunSession.shop_state["expanded_offer_ids"] = ["future_shop_slot"]
	RunSession.reward_category_state["pending_category"] = "relic"
	RunSession.reroll_count = 2
	RunSession.route_metadata["last_resolved_map_index"] = 4
	var snapshot: Dictionary = RunSession.snapshot()
	assert_eq(int(snapshot.get("version", 0)), RunSession.SNAPSHOT_VERSION)
	assert_eq(int(snapshot.get("max_mana_cap", 0)), RunSession.TRACK_02_MAX_MANA_CAP)
	assert_eq(int(snapshot.get("max_hand_size_cap", 0)), RunSession.TRACK_02_MAX_HAND_SIZE_CAP)
	assert_true(Array(snapshot.get("relic_ids", [])).has("bolsa_de_cinzas"))
	assert_eq(str(Dictionary(snapshot.get("reward_category_state", {})).get("pending_category", "")), "relic")
	assert_eq(int(snapshot.get("reroll_count", 0)), 2)
	assert_eq(int(Dictionary(snapshot.get("route_metadata", {})).get("target_map_count", 0)), RunSession.TRACK_02_TARGET_MAP_COUNT)
	RunSession.reset()
	var load_result: Dictionary = RunSession.load_snapshot(snapshot)
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	assert_true(RunSession.has_relic_id("bolsa_de_cinzas"))
	assert_eq(str(RunSession.reward_category_state.get("pending_category", "")), "relic")
	assert_eq(int(RunSession.reroll_count), 2)
	assert_eq(int(RunSession.route_metadata.get("last_resolved_map_index", 0)), 4)

func test_track01_rewards_respect_track02_stat_caps() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.max_mana = RunSession.TRACK_02_MAX_MANA_CAP
	RunSession.max_hand_size = RunSession.TRACK_02_MAX_HAND_SIZE_CAP
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	RunSession.record_battle_result("n06_duelo_inicial", "vitoria", 20)
	assert_eq(RunSession.max_mana, RunSession.TRACK_02_MAX_MANA_CAP)
	assert_eq(RunSession.max_hand_size, RunSession.TRACK_02_MAX_HAND_SIZE_CAP)

func test_track02_real_relic_reward_and_reward_category_state_apply() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.record_battle_result("n04_pouso_elemental", "vitoria", 18)
	assert_true(RunSession.has_relic_id(RunSession.RELIC_BOLSA_DE_CINZAS))
	assert_true(RunSession.automatic_reward_ids.has("n04_pouso_elemental:%s" % RunSession.REWARD_ADD_RELIC_PLACEHOLDER))
	assert_eq(str(Dictionary(RunSession.reward_category_state.get("completed_categories_by_node", {})).get("n04_pouso_elemental", "")), "relic")

func test_track02_utility_choice_can_remove_duplicate_or_upgrade_cards() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var card_id: String = "arcano_choque"
	var initial_count: int = RunSession.current_deck_ids.count(card_id)
	RunSession.rewards_pending = [{
		"id": "n27:utility_choice",
		"node_id": "n27_future",
		"type": RunSession.CHOICE_REWARD_UTILITY,
		"category": "utility"
	}]
	var choices: Array[Dictionary] = RunSession.pending_reward_choices()
	assert_gt(choices.size(), 0)
	assert_true(bool(RunSession.apply_reward_choice("utility_remove:%s" % card_id).get("ok", false)))
	assert_eq(RunSession.current_deck_ids.count(card_id), initial_count - 1)
	RunSession.rewards_pending = [{
		"id": "n27:utility_choice",
		"node_id": "n27_future",
		"type": RunSession.CHOICE_REWARD_UTILITY,
		"category": "utility"
	}]
	assert_true(bool(RunSession.apply_reward_choice("utility_duplicate:%s" % card_id).get("ok", false)))
	assert_eq(RunSession.current_deck_ids.count(card_id), initial_count)
	RunSession.rewards_pending = [{
		"id": "n27:utility_choice",
		"node_id": "n27_future",
		"type": RunSession.CHOICE_REWARD_UTILITY,
		"category": "utility"
	}]
	assert_true(bool(RunSession.apply_reward_choice("utility_upgrade:%s" % card_id).get("ok", false)))
	assert_eq(int(RunSession.card_upgrade_counts.get(card_id, 0)), 1)

func test_soul_shop_card_upgrade_offers_and_purchase_limit() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.soul_total = 20
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	var choices: Array[Dictionary] = RunSession.shop_upgrade_choices()
	assert_eq(choices.size(), 3)
	var card_id: String = str(choices[0].get("card_id", ""))
	assert_true(RunSession.can_buy_shop_upgrade(card_id))
	var before_buy_souls: int = RunSession.soul_total
	var buy_result: Dictionary = RunSession.buy_shop_card_upgrade(card_id)
	assert_true(bool(buy_result.get("ok", false)), str(buy_result.get("message", "")))
	assert_eq(RunSession.soul_total, before_buy_souls - RunSession.SHOP_CARD_UPGRADE_COST)
	assert_eq(int(RunSession.card_upgrade_counts.get(card_id, 0)), 1)
	for choice: Dictionary in RunSession.shop_upgrade_choices():
		assert_false(bool(choice.get("can_buy", true)))
	RunSession.soul_total = 20
	assert_false(bool(RunSession.buy_shop_card_upgrade(str(choices[1].get("card_id", ""))).get("ok", true)))

func test_expanded_souls_shop_inventory_prices_and_purchases() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.soul_total = 220
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	var card_choices: Array[Dictionary] = RunSession.shop_card_choices()
	var relic_choices: Array[Dictionary] = RunSession.shop_relic_choices()
	var remove_choices: Array[Dictionary] = RunSession.shop_remove_card_choices()
	var duplicate_choices: Array[Dictionary] = RunSession.shop_duplicate_card_choices()
	assert_gt(card_choices.size(), 0)
	assert_gt(relic_choices.size(), 0)
	assert_gt(remove_choices.size(), 0)
	assert_gt(duplicate_choices.size(), 0)
	assert_eq(int(remove_choices[0].get("cost", 0)), RunSession.SHOP_REMOVE_CARD_COST)
	assert_eq(int(duplicate_choices[0].get("cost", 0)), RunSession.SHOP_DUPLICATE_CARD_COST)
	var card_id: String = str(card_choices[0].get("card_id", ""))
	var card_cost: int = int(card_choices[0].get("cost", 0))
	assert_true([RunSession.SHOP_BUY_COMMON_CARD_COST, RunSession.SHOP_BUY_RARE_CARD_COST, RunSession.SHOP_BUY_ULTRA_RARE_CARD_COST].has(card_cost))
	var before_card_count: int = RunSession.current_deck_ids.count(card_id)
	var before_souls: int = RunSession.soul_total
	assert_true(bool(RunSession.buy_shop_card(card_id).get("ok", false)))
	assert_eq(RunSession.current_deck_ids.count(card_id), before_card_count + 1)
	assert_eq(RunSession.soul_total, before_souls - card_cost)
	var remove_id: String = str(remove_choices[0].get("card_id", ""))
	assert_true(bool(RunSession.buy_shop_remove_card(remove_id).get("ok", false)))
	assert_false(RunSession.current_deck_ids.is_empty())
	var duplicate_id: String = str(duplicate_choices[0].get("card_id", ""))
	var duplicate_before: int = RunSession.current_deck_ids.count(duplicate_id)
	assert_true(bool(RunSession.buy_shop_duplicate_card(duplicate_id).get("ok", false)))
	assert_eq(RunSession.current_deck_ids.count(duplicate_id), duplicate_before + 1)
	var relic_id: String = str(relic_choices[0].get("relic_id", ""))
	var relic_cost: int = int(relic_choices[0].get("cost", 0))
	assert_true([RunSession.SHOP_BUY_COMMON_RELIC_COST, RunSession.SHOP_BUY_RARE_RELIC_COST, RunSession.SHOP_BUY_ULTRA_RARE_RELIC_COST].has(relic_cost))
	assert_true(bool(RunSession.buy_shop_relic(relic_id).get("ok", false)))
	assert_true(RunSession.has_relic_id(relic_id))

func test_relic_shop_discounts_pickup_effects_and_max_hp_limit() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.soul_total = 120
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_FERRAMENTAS_DE_CIRURGIA).get("ok", false)))
	assert_eq(int(RunSession.shop_remove_card_choices()[0].get("cost", -1)), 0)
	var remove_id: String = str(RunSession.shop_remove_card_choices()[0].get("card_id", ""))
	assert_true(bool(RunSession.buy_shop_remove_card(remove_id).get("ok", false)))
	assert_eq(int(RunSession.shop_remove_card_choices()[0].get("cost", -1)), RunSession.SHOP_REMOVE_CARD_COST)
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_LAMINA_DE_RESERVA).get("ok", false)))
	assert_eq(int(RunSession.shop_duplicate_card_choices()[0].get("cost", -1)), int(RunSession.SHOP_DUPLICATE_CARD_COST / 2))
	var duplicate_id: String = str(RunSession.shop_duplicate_card_choices()[0].get("card_id", ""))
	assert_true(bool(RunSession.buy_shop_duplicate_card(duplicate_id).get("ok", false)))
	assert_eq(int(RunSession.shop_duplicate_card_choices()[0].get("cost", -1)), RunSession.SHOP_DUPLICATE_CARD_COST)
	var max_before: int = RunSession.max_health
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_COURO_ASTRAL).get("ok", false)))
	assert_eq(RunSession.max_health, max_before + 3)
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_PACTO_DAS_RUINAS).get("ok", false)))
	assert_eq(RunSession.max_health, max_before + 13)
	RunSession.soul_total = 100
	var shop_max_before: int = RunSession.max_health
	assert_eq(RunSession._shop_max_health_cost(), RunSession.SHOP_MAX_HEALTH_FIRST_COST)
	assert_true(bool(RunSession.buy_shop_max_health().get("ok", false)))
	assert_eq(RunSession.max_health, shop_max_before + RunSession.SHOP_MAX_HEALTH_AMOUNT)
	assert_eq(RunSession._shop_max_health_cost(), RunSession.SHOP_MAX_HEALTH_SECOND_COST)
	assert_true(bool(RunSession.buy_shop_max_health().get("ok", false)))
	assert_false(bool(RunSession.buy_shop_max_health().get("ok", true)))

func test_shop_and_reward_reroll_cost_scaling() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.soul_total = 100
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	assert_eq(RunSession.current_reroll_cost(), 8)
	var shop_result: Dictionary = RunSession.buy_shop_reroll()
	assert_true(bool(shop_result.get("ok", false)), str(shop_result.get("message", "")))
	assert_eq(RunSession.reroll_count, 1)
	assert_eq(RunSession.current_reroll_cost(), 12)
	RunSession.rewards_pending = [{
		"id": "test:new_card",
		"node_id": "test_node",
		"type": RunSession.CHOICE_REWARD_NEW_CARD,
		"category": "new_card",
		"element": "terra",
		"pool_offset": 0
	}]
	var reward_result: Dictionary = RunSession.buy_reward_reroll()
	assert_true(bool(reward_result.get("ok", false)), str(reward_result.get("message", "")))
	assert_eq(RunSession.reroll_count, 2)
	assert_eq(RunSession.current_reroll_cost(), 16)
	assert_eq(int(Dictionary(RunSession.rewards_pending[0]).get("reroll_index", 0)), 1)

func test_relic_reward_choice_and_safe_mechanical_effects() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	RunSession.rewards_pending = [{
		"id": "n21:relic",
		"node_id": "n21_future",
		"type": RunSession.CHOICE_REWARD_RELIC,
		"category": "relic",
		"rarity": "standard"
	}]
	var relic_choices: Array[Dictionary] = RunSession.pending_reward_choices()
	assert_eq(relic_choices.size(), 3)
	assert_false(str(relic_choices[0].get("relic_id", "")).begins_with("placeholder_relic_"))
	var choice_relic_id: String = str(relic_choices[0].get("relic_id", ""))
	assert_true(bool(RunSession.apply_reward_choice(str(relic_choices[0].get("id", ""))).get("ok", false)))
	assert_true(RunSession.has_relic_id(choice_relic_id))
	RunSession.reset()
	result = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_BOLSA_DE_CINZAS).get("ok", false)))
	var summary: Dictionary = RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	assert_eq(int(summary.get("souls_gained", 0)), RunSession._soul_reward_for_node("n01_tutorial_primeiro_contato") + 3)
	RunSession.current_health = 10
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_FORJA_NEGRA).get("ok", false)))
	RunSession.rewards_pending = [{
		"id": "test:upgrade",
		"node_id": "test_node",
		"type": RunSession.CHOICE_REWARD_UPGRADE_CARD,
		"category": "card_upgrade",
		"rarity_by_card_id": {"arcano_choque": RunSession.REWARD_RARITY_COMMON}
	}]
	assert_true(bool(RunSession.apply_reward_choice("upgrade:arcano_choque").get("ok", false)))
	assert_eq(RunSession.current_health, 14)
	assert_true(bool(RunSession.add_relic_id(RunSession.RELIC_NUCLEO_INSTAVEL).get("ok", false)))
	var deck_before: int = RunSession.current_deck_ids.count("arcano_bola_de_fogo")
	RunSession.rewards_pending = [{
		"id": "test:new_card",
		"node_id": "test_node",
		"type": RunSession.CHOICE_REWARD_NEW_CARD,
		"category": "new_card",
		"element": "terra",
		"pool_offset": 0,
		"rarity_by_card_id": {"arcano_bola_de_fogo": RunSession.REWARD_RARITY_ULTRA}
	}]
	assert_true(bool(RunSession.apply_reward_choice("new_card:arcano_bola_de_fogo").get("ok", false)))
	assert_eq(RunSession.current_deck_ids.count("arcano_bola_de_fogo"), deck_before + 6)

func test_battle_engine_applies_safe_relic_hooks() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "arcano_fagulha", "arcano_fagulha"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 1,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false,
		"relic_ids": [
			"eco_menor",
			"catalisador_arcano",
			"coracao_de_eter",
			"marca_de_guerra",
			"estandarte_vivo"
		]
	})
	assert_eq(engine.mana, 2)
	var enemy_before: int = int(Dictionary(engine.enemy_slots[2]).get("health", 0))
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 2}).get("ok", false)))
	assert_eq(engine.mana, 2)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), enemy_before - 3)
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	var ally: Dictionary = Dictionary(engine.player_slots[0])
	assert_eq(int(ally.get("health", 0)), int(ally.get("max_health", 0)))
	assert_gt(int(ally.get("max_health", 0)), int(ContentLibrary.get_card("arcano_fagulha").health))
	assert_eq(int(ally.get("temporary_attack_bonus", 0)), 1)

func test_card_upgrade_counts_build_effective_level_cards() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "arcano_tempestade"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false,
		"card_upgrade_counts": {"arcano_choque": 2, "arcano_tempestade": 1}
	})
	assert_eq(engine.hand[0], "arcano_choque_lvl3")
	assert_eq(engine.hand[1], "arcano_tempestade_lvl2")
	assert_eq(int(ContentLibrary.get_card(engine.hand[0]).cost), 0)
	assert_eq(int(ContentLibrary.get_card(engine.hand[1]).effect.get("amount", 0)), 6)

func test_run_session_rejects_invalid_player_names() -> void:
	assert_false(bool(RunSession.validate_player_name("A").get("ok", false)))
	assert_false(bool(RunSession.validate_player_name("Nome Grande Demais X").get("ok", false)))
	assert_true(bool(RunSession.validate_player_name("Nyx").get("ok", false)))

func test_save_manager_saves_loads_names_and_deletes_slots() -> void:
	var result: Dictionary = RunSession.start_class_run("invocador", 123, "Kael")
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.current_node_id, "n01_tutorial_primeiro_contato")
	assert_eq(RunSession.player_display_name(), "Kael")
	var save_result: Dictionary = SaveManager.save_current_run(1)
	assert_true(bool(save_result.get("ok", false)), str(save_result.get("message", "")))
	assert_true(SaveManager.has_save(1))
	RunSession.reset()
	var load_result: Dictionary = SaveManager.load_slot(1)
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	assert_eq(RunSession.selected_class_id, "invocador")
	assert_eq(RunSession.current_node_id, "n01_tutorial_primeiro_contato")
	assert_eq(RunSession.player_display_name(), "Kael")
	var slots: Array[Dictionary] = SaveManager.get_slots()
	assert_string_contains(str(slots[0].get("summary", "")), "Kael")
	assert_string_contains(str(slots[0].get("summary", "")), "Invocador")
	var delete_result: Dictionary = SaveManager.delete_slot(1)
	assert_true(bool(delete_result.get("ok", false)), str(delete_result.get("message", "")))
	assert_false(SaveManager.has_save(1))

func test_save_manager_allows_deleting_or_overwriting_stale_save_files() -> void:
	_write_test_save_file(1, {"version": SaveManager.SAVE_VERSION - 1, "run": {"selected_class_id": "arcano"}})
	assert_false(SaveManager.has_save(1))
	assert_true(SaveManager.has_save_file(1))
	var slots: Array[Dictionary] = SaveManager.get_slots()
	assert_false(bool(slots[0].get("exists", true)))
	assert_true(bool(slots[0].get("has_file", false)))
	assert_true(bool(slots[0].get("invalid", false)))
	assert_string_contains(str(slots[0].get("summary", "")), "antigo")
	var begin_result: Dictionary = SaveManager.begin_new_game(1)
	assert_true(bool(begin_result.get("ok", false)), str(begin_result.get("message", "")))
	var delete_result: Dictionary = SaveManager.delete_slot(1)
	assert_true(bool(delete_result.get("ok", false)), str(delete_result.get("message", "")))
	assert_false(SaveManager.has_save_file(1))
