extends "res://tests/unit/draxos_test_base.gd"

func test_catalog_uses_redesigned_class_decks() -> void:
	var catalog = ContentLibrary.get_catalog()
	for class_id: String in ["arcano", "invocador", "necromante"]:
		var class_option: Dictionary = catalog.find_class_option(class_id)
		assert_false(class_option.is_empty(), "Missing class %s" % class_id)
		assert_eq(int(class_option.get("starting_mana", 0)), 1)
		assert_eq(int(class_option.get("starting_health", 0)), 20)
		assert_eq(int(class_option.get("starting_hand_size", 0)), 3)
		var deck: Array = Array(class_option.get("starter_deck", []))
		assert_eq(deck.size(), 9)
		var reward_pool_size: int = Array(class_option.get("reward_pool", [])).size()
		assert_eq(reward_pool_size, 8)
		var counts: Dictionary = {}
		for card_id: String in deck:
			assert_not_null(catalog.find_card(card_id), "Missing card %s" % card_id)
			assert_eq(int(catalog.find_card(card_id).cost), 1)
			counts[card_id] = int(counts.get(card_id, 0)) + 1
		assert_eq(counts.size(), 3)
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
	assert_eq(int(ContentLibrary.get_card("arcano_choque").effect.get("amount", 0)), 2)
	assert_eq(int(ContentLibrary.get_card("arcano_fagulha").health), 2)
	assert_eq(int(ContentLibrary.get_card("arcano_barreira").attack), 0)
	assert_true(ContentLibrary.get_card("arcano_barreira").has_keyword("defensor"))
	assert_eq(int(ContentLibrary.get_card("arcano_tempestade").effect.get("amount", 0)), 4)
	assert_eq(int(ContentLibrary.get_card("necro_prender").cost), 1)
	assert_null(catalog.find_card("necro_punir"), "Punir should be removed from the active catalog.")
	for card_id: String in [
		"arcano_bola_de_fogo", "arcano_acelerar", "arcano_vortice", "arcano_sentinela_arcana", "arcano_amplificador", "arcano_canalizar", "arcano_espelho_arcano", "arcano_descarga",
		"invocador_atacar", "invocador_golem", "invocador_capitao_de_campo", "invocador_parede_de_escudos", "invocador_cavaleiro_arcano", "invocador_berserker", "invocador_arauto", "invocador_tita_geminal",
		"necro_carniceiro", "necro_diabrete", "necro_revenant", "necro_flagelo", "necro_arauto_das_sombras", "necro_colheita_das_almas", "necro_lich", "necro_praga"
	]:
		assert_not_null(ContentLibrary.get_card(card_id), "Missing real reward card %s" % card_id)
		assert_not_null(ContentLibrary.get_card("%s_lvl2" % card_id), "Missing level 2 card %s" % card_id)
		assert_not_null(ContentLibrary.get_card("%s_lvl3" % card_id), "Missing level 3 card %s" % card_id)
	for placeholder_id: String in ["arcano_recompensa_1", "invocador_recompensa_1", "necro_recompensa_1"]:
		assert_null(catalog.find_card(placeholder_id), "Placeholder reward card should be removed: %s" % placeholder_id)
	var galleries: Dictionary = Dictionary(ContentLibrary.get_track_contract().get("enemy_card_galleries", {}))
	for element: String in ["terra", "gelo", "ar", "fogo"]:
		assert_false(Array(galleries.get(element, [])).is_empty(), "Missing enemy gallery %s" % element)
		for enemy_card_id: String in Array(galleries.get(element, [])):
			assert_not_null(catalog.find_card(enemy_card_id), "Enemy gallery card missing: %s" % enemy_card_id)

func test_track02_data_contract_is_exposed_by_catalog() -> void:
	var contract: Dictionary = ContentLibrary.get_track_contract()
	assert_eq(str(contract.get("id", "")), RunSession.TRACK_02_CONTRACT_ID)
	assert_eq(int(contract.get("save_version", 0)), SaveManager.SAVE_VERSION)
	assert_eq(int(contract.get("snapshot_version", 0)), RunSession.SNAPSHOT_VERSION)
	assert_eq(int(Dictionary(contract.get("stat_caps", {})).get("max_mana", 0)), RunSession.TRACK_02_MAX_MANA_CAP)
	assert_eq(int(Dictionary(contract.get("stat_caps", {})).get("max_hand_size", 0)), RunSession.TRACK_02_MAX_HAND_SIZE_CAP)
	assert_eq(int(Dictionary(contract.get("route", {})).get("active_map_count", 0)), RunSession.TRACK_02_CURRENT_ROUTE_MAP_COUNT)
	assert_eq(int(Dictionary(contract.get("route", {})).get("target_map_count", 0)), RunSession.TRACK_02_TARGET_MAP_COUNT)
	assert_eq(str(Dictionary(contract.get("relic_state_schema", {})).get("stored_as", "")), "relic_ids")
	assert_eq(Array(contract.get("reward_schedule", [])).size(), 29)
	assert_eq(int(Dictionary(contract.get("reward_rarity", {})).get("common", 0)), 70)
	assert_eq(int(Dictionary(contract.get("reward_rarity", {})).get("rare", 0)), 25)
	assert_eq(int(Dictionary(contract.get("reward_rarity", {})).get("ultra_rare", 0)), 5)

func test_track02_relic_definitions_and_shop_prices_are_exposed() -> void:
	var relics: Array = ContentLibrary.get_relic_definitions()
	assert_eq(relics.size(), 18)
	for relic_id: String in [
		RunSession.RELIC_BOLSA_DE_CINZAS,
		RunSession.RELIC_LAMINA_DE_RESERVA,
		"mao_preparada",
		RunSession.RELIC_COURO_ASTRAL,
		"marca_de_guerra",
		"eco_menor",
		RunSession.RELIC_CATALISADOR_ARCANO,
		"contrato_de_sangue",
		RunSession.RELIC_FERRAMENTAS_DE_CIRURGIA,
		"estandarte_vivo",
		RunSession.RELIC_NUCLEO_INSTAVEL,
		"escudo_de_marcha",
		"coracao_de_eter",
		RunSession.RELIC_BIBLIOTECA_PROIBIDA,
		RunSession.RELIC_FORJA_NEGRA,
		"olho_do_grande_mestre",
		"selo_de_dominacao",
		RunSession.RELIC_PACTO_DAS_RUINAS
	]:
		var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
		assert_false(relic.is_empty(), "Missing relic %s" % relic_id)
		assert_true(str(relic.get("effect_text", "")) != "")
	assert_eq(str(ContentLibrary.get_relic_definition("contrato_de_sangue").get("effect_status", "")), "pending_reward_prompt")
	assert_eq(str(ContentLibrary.get_relic_definition("olho_do_grande_mestre").get("effect_status", "")), "pending_enemy_intent_prompt")
	var prices: Dictionary = ContentLibrary.get_shop_prices()
	assert_eq(int(prices.get("heal", 0)), RunSession.SHOP_HEAL_COST)
	assert_eq(int(prices.get("remove_card", 0)), RunSession.SHOP_REMOVE_CARD_COST)
	assert_eq(int(Dictionary(prices.get("buy_card", {})).get("ultra_rare", 0)), RunSession.SHOP_BUY_ULTRA_RARE_CARD_COST)
	assert_eq(int(Dictionary(prices.get("buy_relic", {})).get("rare", 0)), RunSession.SHOP_BUY_RARE_RELIC_COST)
	assert_eq(int(Array(prices.get("max_health", []))[0]), RunSession.SHOP_MAX_HEALTH_FIRST_COST)

func test_track02_keyword_and_status_tooltip_contract_is_exposed() -> void:
	for keyword_id: String in [
		"iniciativa",
		"defensor",
		"reviver",
		"regeneracao",
		"carnica",
		"suicida",
		"enfraquecer",
		"prender",
		"remover_keywords",
		"poder_de_habilidade",
		"atropelar",
		"brutal",
		"drenar",
		"espinhos",
		"escudo",
		"resistencia",
		"imune",
		"crescer",
		"furia",
		"ecoar",
		"veneno",
		"congelar",
		"profanar",
		"entrar",
		"proliferar",
		"sacrificio",
		"inspirar",
		"pacto",
		"drenar_almas",
		"ressurgir"
	]:
		var definition: Dictionary = ContentLibrary.get_keyword_definition(keyword_id)
		assert_false(definition.is_empty(), "Missing keyword definition %s" % keyword_id)
		assert_true(str(definition.get("tooltip", "")) != "", "Missing tooltip for %s" % keyword_id)
	assert_string_contains(ContentLibrary.keyword_tooltip_text("defensor"), "Defensor")
	assert_string_contains(ContentLibrary.keyword_tooltip_text("atropelar"), "Timing: combate")
	assert_eq(ContentLibrary.missing_tooltip_report().size(), 0)
	var status_text: String = ContentLibrary.status_tooltip_text({
		"slow_turns": 1,
		"poison_amount": 3,
		"temporary_attack_bonus": 2
	})
	assert_string_contains(status_text, "Lentidao")
	assert_string_contains(status_text, "Veneno")
	assert_string_contains(" | ".join(ContentLibrary.status_summary_parts({"shield_charges": 1, "resistance_amount": 2})), "Escudo 1")

func test_keyword_badges_and_choice_tooltips_have_floating_text() -> void:
	var deck_token = CardTokenScript.new()
	add_child(deck_token)
	deck_token.setup("arcano_barreira", "deck", 0)
	var deck_chip = deck_token.find_child("KeywordChipsComponent", true, false).get_child(0)
	assert_string_contains(str(deck_chip.tooltip_text), "Defensor")
	assert_string_contains(str(deck_token.tooltip_text), "Barreira Arcana")
	deck_token.queue_free()

	var battle_token = BattleCardTokenScript.new()
	add_child(battle_token)
	battle_token.setup("arcano_barreira", 0)
	var battle_chip = battle_token.find_child("KeywordChipsComponent", true, false).get_child(0)
	assert_string_contains(str(battle_chip.tooltip_text), "Defensor")
	assert_string_contains(str(battle_token.tooltip_text), "Barreira Arcana")
	battle_token.queue_free()

	var reward_tooltip: String = ContentLibrary.reward_choice_tooltip({
		"id": "new_card:arcano_barreira",
		"card_id": "arcano_barreira",
		"body": "Adiciona 3 copias ao deck."
	})
	assert_string_contains(reward_tooltip, "Adiciona 3")
	assert_string_contains(reward_tooltip, "Defensor")
	var shop_tooltip: String = ContentLibrary.shop_choice_tooltip({
		"id": "shop_relic:bolsa_de_cinzas",
		"relic_id": "bolsa_de_cinzas",
		"cost": 30,
		"body": "Compra esta reliquia."
	})
	assert_string_contains(shop_tooltip, "Custo: 30")
	assert_string_contains(shop_tooltip, "Bolsa de Cinzas")
	assert_string_contains(ContentLibrary.enemy_intent_tooltip_text("lane_pressure"), "Pressao")
	assert_string_contains(ContentLibrary.board_effect_tooltip_text("geada"), "Geada")
	await get_tree().process_frame

func test_track02_reward_schedule_matches_progression_contract() -> void:
	var schedule: Array = ContentLibrary.get_reward_schedule()
	assert_eq(schedule.size(), 29)
	assert_eq(str(Dictionary(schedule[0]).get("category", "")), "max_mana")
	assert_eq(str(Dictionary(schedule[9]).get("category", "")), "max_health")
	assert_eq(int(Dictionary(schedule[9]).get("max_health_delta", 0)), 5)
	assert_eq(str(Dictionary(schedule[14]).get("category", "")), "max_health")
	assert_eq(int(Dictionary(schedule[14]).get("max_health_delta", 0)), 5)
	assert_eq(str(Dictionary(schedule[21]).get("category", "")), "max_hand_size")
	assert_eq(str(Dictionary(schedule[22]).get("category", "")), "max_mana")
	assert_eq(str(Dictionary(schedule[28]).get("category", "")), "victory")
	var map_27_choice: Dictionary = Dictionary(Dictionary(schedule[26]).get("choice_reward", {}))
	assert_eq(str(map_27_choice.get("type", "")), RunSession.CHOICE_REWARD_UTILITY)
	for option: String in [RunSession.UTILITY_REWARD_REMOVE_CARD, RunSession.UTILITY_REWARD_DUPLICATE_CARD, RunSession.UTILITY_REWARD_UPGRADE_CARD]:
		assert_true(Array(map_27_choice.get("options", [])).has(option))
	var map_28: Dictionary = Dictionary(schedule[27])
	assert_eq(str(map_28.get("category", "")), "relic")
	assert_eq(str(Dictionary(map_28.get("relic_reward", {})).get("rarity", "")), "rare_ultra")

func test_track02_route_has_29_fixed_linear_maps_and_production_rewards() -> void:
	var run_map: Dictionary = ContentLibrary.get_run_map()
	var nodes: Array = Array(run_map.get("nodes", []))
	assert_eq(nodes.size(), 29)
	for index: int in range(nodes.size()):
		var node: Dictionary = Dictionary(nodes[index])
		assert_eq(int(node.get("map_index", 0)), index + 1)
		if index == 0:
			assert_true(Array(node.get("available_after", [])).is_empty())
		else:
			assert_true(Array(node.get("available_after", [])).has(str(Dictionary(nodes[index - 1]).get("id", ""))))
		if index < nodes.size() - 1:
			assert_true(Array(node.get("unlocks", [])).has(str(Dictionary(nodes[index + 1]).get("id", ""))))
	assert_eq(str(Dictionary(nodes[13]).get("encounter_id", "")), "sobreviver_turnos_inicial")
	assert_true(Array(Dictionary(nodes[13]).get("rewards", [])).has(RunSession.REWARD_GRANT_REMAINING_CARD))
	assert_true(Array(Dictionary(nodes[14]).get("rewards", [])).has(RunSession.REWARD_MAX_HEALTH_5))
	assert_false(Dictionary(Dictionary(nodes[14]).get("relic_reward", {})).is_empty())
	assert_true(Array(Dictionary(nodes[22]).get("rewards", [])).has(RunSession.REWARD_MAX_MANA_1))
	assert_eq(str(Dictionary(Dictionary(nodes[27]).get("relic_reward", {})).get("rarity", "")), "rare_ultra")

func test_track02_route_covers_modes_formats_effects_and_boss_hooks() -> void:
	var modes: Array[String] = []
	var formats: Array[String] = []
	var effects: Array[String] = []
	var boss_maps: Array[int] = []
	for node: Dictionary in Array(ContentLibrary.get_run_map().get("nodes", [])):
		var encounter: Dictionary = ContentLibrary.get_catalog().find_encounter(str(node.get("encounter_id", "")))
		var mode: String = str(encounter.get("mode", ""))
		var board_format: String = str(encounter.get("board_format", "padrao"))
		if not modes.has(mode):
			modes.append(mode)
		if not formats.has(board_format):
			formats.append(board_format)
		for effect_id: Variant in Array(encounter.get("field_effects", [])):
			if not effects.has(str(effect_id)):
				effects.append(str(effect_id))
		if mode == BattleEngine.MODE_SUMMONER_BOSS:
			boss_maps.append(int(node.get("map_index", 0)))
			assert_false(Array(encounter.get("boss_phase_hooks", [])).is_empty())
	for required_mode: String in [BattleEngine.MODE_AMBUSH, BattleEngine.MODE_ESCORT, BattleEngine.MODE_INVASION]:
		assert_true(modes.has(required_mode), "Missing mode %s" % required_mode)
	for required_format: String in [BattleEngine.BOARD_FORMAT_ASYMMETRIC, BattleEngine.BOARD_FORMAT_CENTRAL_CORE, BattleEngine.BOARD_FORMAT_FLANK, BattleEngine.BOARD_FORMAT_FRONT_REAR, BattleEngine.BOARD_FORMAT_ABYSS]:
		assert_true(formats.has(required_format), "Missing board format %s" % required_format)
	for required_effect: String in [BattleEngine.FIELD_GEADA, BattleEngine.FIELD_CHAO_VIVO, BattleEngine.FIELD_OLHO_TEMPESTADE, BattleEngine.FIELD_PORTAL_ABERTO, BattleEngine.FIELD_INFERNO_TOTAL]:
		assert_true(effects.has(required_effect), "Missing field effect %s" % required_effect)
	assert_eq(boss_maps, [8, 15, 22, 29])

func test_track02_representative_modes_formats_and_field_effects_resolve() -> void:
	var ambush: BattleEngine = BattleEngine.new()
	ambush.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "emboscada_nuvens",
		"shuffle_deck": false
	})
	assert_eq(ambush.mode, BattleEngine.MODE_AMBUSH)
	assert_eq(ambush.mana, 0)
	assert_eq(ambush.board_format, BattleEngine.BOARD_FORMAT_FLANK)
	assert_eq(ambush.enemy_slots.size(), 6)

	var escort: BattleEngine = BattleEngine.new()
	escort.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "rio_lava",
		"shuffle_deck": false
	})
	assert_eq(escort.mode, BattleEngine.MODE_ESCORT)
	assert_eq(escort.board_format, BattleEngine.BOARD_FORMAT_FRONT_REAR)
	assert_true(bool(Dictionary(escort.player_slots[0]).get("escort", false)))

	var invasion: BattleEngine = BattleEngine.new()
	invasion.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "portal_caos",
		"shuffle_deck": false
	})
	invasion.turn_number = 3
	var before_portal: int = _occupied_count(invasion.enemy_slots)
	invasion._resolve_maintenance_field_effects()
	assert_true(_occupied_count(invasion.enemy_slots) >= before_portal)
	assert_true(bool(invasion.field_effect_state.get("portal_turn_3", false)))

	var core: BattleEngine = BattleEngine.new()
	core.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "nucleo_ciclone",
		"shuffle_deck": false
	})
	var attack: Dictionary = core._build_attack_event("test", BattleEngine.ENEMY_ID, 2, {"owner": BattleEngine.PLAYER_ID, "hero": true})
	assert_eq(int(attack.get("damage", 0)), int(Dictionary(core.enemy_slots[2]).get("attack", 0)) + 1)

	var frost: BattleEngine = BattleEngine.new()
	frost.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "blizzard",
		"shuffle_deck": false
	})
	frost.player_slots[0] = frost._build_occupant(ContentLibrary.get_card("arcano_fagulha"), BattleEngine.PLAYER_ID, false)
	frost.turn_number = 2
	frost._resolve_start_of_player_field_effects()
	assert_true(int(Dictionary(frost.player_slots[0]).get("frozen_turns", 0)) >= 1)
