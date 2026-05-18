extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")
const BattleCardTokenScript = preload("res://ui/controls/battle_card_token.gd")
const CardTokenScript = preload("res://ui/controls/card_token.gd")
const TEST_SAVE_PREFIX: String = "user://gut_draxos_save_slot_"

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))
	ContentLibrary.reload()
	VisualAssets.reload()

func before_each() -> void:
	SaveManager.save_path_prefix = TEST_SAVE_PREFIX
	_clear_test_saves()
	SaveManager.select_slot(1)
	SaveManager.pending_new_game = false
	RunSession.reset()

func after_each() -> void:
	_clear_test_saves()
	SaveManager.save_path_prefix = "user://draxos_save_slot_"
	SaveManager.select_slot(1)
	SaveManager.pending_new_game = false
	RunSession.reset()

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

func test_main_menu_defaults_to_slot_one_and_button_states() -> void:
	var menu = await _instantiate_scene("res://modes/boot/boot.tscn")
	assert_eq(SaveManager.current_slot_index, 1)
	var slot_one: Button = menu.find_child("MainMenuSlot1", true, false)
	var new_button: Button = menu.find_child("MainMenuNewGameButton", true, false)
	var continue_button: Button = menu.find_child("MainMenuContinueButton", true, false)
	var delete_button: Button = menu.find_child("MainMenuDeleteButton", true, false)
	assert_not_null(slot_one)
	assert_string_contains(slot_one.text, "Save 1")
	assert_eq(slot_one.text.find("Slot"), -1)
	assert_false(new_button.disabled)
	assert_true(continue_button.disabled)
	assert_true(delete_button.disabled)
	menu._open_delete_modal()
	var delete_label: Label = menu.find_child("MainMenuDeleteConfirmText", true, false)
	assert_not_null(delete_label)
	assert_eq(delete_label.text, "Deletar Save 1?")
	menu.queue_free()
	await get_tree().process_frame

func test_main_menu_can_delete_stale_save_file_without_blocking_new_game() -> void:
	_write_test_save_file(1, {"version": SaveManager.SAVE_VERSION - 1, "run": {"selected_class_id": "arcano"}})
	var menu = await _instantiate_scene("res://modes/boot/boot.tscn")
	var slot_one: Button = menu.find_child("MainMenuSlot1", true, false)
	var new_button: Button = menu.find_child("MainMenuNewGameButton", true, false)
	var continue_button: Button = menu.find_child("MainMenuContinueButton", true, false)
	var delete_button: Button = menu.find_child("MainMenuDeleteButton", true, false)
	assert_string_contains(slot_one.text, "antigo")
	assert_false(new_button.disabled)
	assert_true(continue_button.disabled)
	assert_false(delete_button.disabled)
	menu.queue_free()
	await get_tree().process_frame

func test_new_game_ship_modal_requires_class_and_saves_choice() -> void:
	var begin_result: Dictionary = SaveManager.begin_new_game(1)
	assert_true(bool(begin_result.get("ok", false)), str(begin_result.get("message", "")))
	var ship = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	var modal: PanelContainer = ship.find_child("ShipHubClassChoiceModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	var invocador_button: Button = ship.find_child("ShipHubClass_invocador", true, false)
	assert_not_null(invocador_button)
	invocador_button.pressed.emit()
	await get_tree().process_frame
	var name_modal: PanelContainer = ship.find_child("ShipHubPlayerNameModal", true, false)
	var name_input: LineEdit = ship.find_child("ShipHubPlayerNameInput", true, false)
	var confirm_button: Button = ship.find_child("ShipHubPlayerNameConfirm", true, false)
	assert_not_null(name_modal)
	assert_true(name_modal.visible)
	name_input.text = "Nyth"
	confirm_button.pressed.emit()
	await get_tree().process_frame
	assert_false(modal.visible)
	assert_false(name_modal.visible)
	assert_eq(RunSession.selected_class_id, "invocador")
	assert_eq(RunSession.player_display_name(), "Nyth")
	assert_true(SaveManager.has_save(1))
	ship.queue_free()
	await get_tree().process_frame

func test_ship_hub_creates_manifest_overlays() -> void:
	_start_class_run("arcano", 44)
	var ship = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	assert_not_null(ship.find_child("ShipHubOverlay_deck", true, false))
	assert_not_null(ship.find_child("ShipHubOverlay_map", true, false))
	assert_not_null(ship.find_child("ShipHubOverlay_souls", true, false))
	assert_null(ship.find_child("ShipHubVisualButtons", true, false))
	ship.queue_free()
	await get_tree().process_frame

func test_ship_hub_hides_run_state_and_deck_keeps_it() -> void:
	_start_class_run("arcano", 44)
	var ship = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	assert_null(ship.find_child("ShipHubRunStatePanel", true, false))
	assert_null(ship.find_child("ShipHubRunState", true, false))
	assert_not_null(ship.find_child("ShipHubClassChoiceMessage", true, false))
	ship.queue_free()
	await get_tree().process_frame
	var deck = await _instantiate_scene("res://modes/deck/deck.tscn")
	assert_not_null(deck.find_child("DeckRunStatePanel", true, false))
	assert_not_null(deck.find_child("DeckRunState", true, false))
	deck.queue_free()
	await get_tree().process_frame

func test_ship_overlay_manifest_positions_map_and_souls() -> void:
	assert_eq(VisualAssets.ship_overlay_position("map"), Vector2(0.45, 0.74))
	assert_eq(VisualAssets.ship_overlay_position("souls"), Vector2(0.22, 0.60))

func test_victory_reward_modal_records_reward_and_selects_next_map() -> void:
	_start_class_run("arcano", 77)
	RunSession.mark_node_completed("n01_tutorial_primeiro_contato")
	RunSession.mark_node_completed("n02_tutorial_dois_fronts")
	RunSession.mark_node_completed("n03_tutorial_primeira_onda")
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.outcome = "vitoria"
	battle.engine.player_health = 17
	battle._after_battle_action()
	await get_tree().process_frame
	var modal: PanelContainer = battle.find_child("BattleRewardModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	var reward_style: StyleBoxFlat = modal.get_theme_stylebox("panel") as StyleBoxFlat
	assert_almost_eq(reward_style.bg_color.a, 0.72, 0.01)
	assert_eq(RunSession.soul_total, 4)
	assert_eq(RunSession.current_health, 17)
	assert_eq(RunSession.current_node_id, "n05_ondas_iniciais")
	assert_true(SaveManager.has_save(1))
	battle.queue_free()
	await get_tree().process_frame

func test_souls_screen_heals_five_for_ten_souls() -> void:
	_start_class_run("necromante", 55)
	RunSession.current_health = 10
	RunSession.soul_total = 10
	var souls = await _instantiate_scene("res://modes/souls/souls.tscn")
	var heal: Button = souls.find_child("SoulsHealButton", true, false)
	assert_not_null(heal)
	assert_false(heal.disabled)
	heal.pressed.emit()
	await get_tree().process_frame
	assert_eq(RunSession.current_health, 15)
	assert_eq(RunSession.soul_total, 0)
	assert_true(SaveManager.has_save(1))
	souls.queue_free()
	await get_tree().process_frame

func test_deck_screen_lists_grouped_cards_and_upgrades() -> void:
	_start_class_run("arcano", 44)
	RunSession.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 20)
	RunSession.record_battle_result("n02_tutorial_dois_fronts", "vitoria", 20)
	var deck = await _instantiate_scene("res://modes/deck/deck.tscn")
	var list: VBoxContainer = deck.find_child("DeckGroupedCards", true, false)
	assert_not_null(list)
	assert_gt(_count_children_with_prefix(list, "DeckCard_"), 3)
	var upgrade_label: Label = deck.find_child("DeckUpgradeState", true, false)
	assert_not_null(upgrade_label)
	assert_string_contains(upgrade_label.text, "+1 Mana")
	deck.queue_free()
	await get_tree().process_frame

func test_deck_screen_falls_back_to_class_starter_deck_when_run_deck_empty() -> void:
	_start_class_run("invocador", 44)
	RunSession.current_deck_ids = []
	var deck = await _instantiate_scene("res://modes/deck/deck.tscn")
	var list: VBoxContainer = deck.find_child("DeckGroupedCards", true, false)
	assert_not_null(list)
	assert_eq(_count_children_with_prefix(list, "DeckCard_"), 3)
	assert_null(deck.find_child("DeckEmptyMessage", true, false))
	deck.queue_free()
	await get_tree().process_frame

func test_ship_overlay_alpha_debt_reports_map_without_real_alpha() -> void:
	var debts: Array[String] = VisualAssets.ship_overlay_alpha_debt_report()
	var found_map_debt: bool = false
	for debt: String in debts:
		if debt.find("map") >= 0 and debt.find("Mapa.png") >= 0:
			found_map_debt = true
	assert_true(found_map_debt, "Mapa.png should be reported as a non-fatal alpha debt.")

func test_escape_on_secondary_screens_returns_without_null_viewport_error() -> void:
	_start_class_run("arcano", 44)
	for scene_path: String in ["res://modes/run_map/run_map.tscn", "res://modes/deck/deck.tscn", "res://modes/souls/souls.tscn"]:
		var scene = await _instantiate_scene(scene_path)
		var event: InputEventKey = InputEventKey.new()
		event.pressed = true
		event.keycode = KEY_ESCAPE
		scene._unhandled_input(event)
		await get_tree().process_frame
		assert_true(true, "ESC handled for %s" % scene_path)
		if is_instance_valid(scene):
			scene.queue_free()
		if get_tree().current_scene != null:
			get_tree().current_scene.queue_free()
			get_tree().current_scene = null
		await get_tree().process_frame

func test_battle_choice_modals_are_centered_and_scrollable() -> void:
	_start_class_run("necromante", 44)
	RunSession.class_active_unlocked = true
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var necro_modal: PanelContainer = battle.find_child("NecromancerChoiceModal", true, false)
	var pending_modal: PanelContainer = battle.find_child("PendingBattleChoiceModal", true, false)
	assert_not_null(necro_modal)
	assert_not_null(pending_modal)
	assert_eq(necro_modal.anchor_left, 0.5)
	assert_eq(necro_modal.anchor_top, 0.5)
	assert_eq(necro_modal.offset_left, -necro_modal.offset_right)
	assert_eq(necro_modal.offset_top, -necro_modal.offset_bottom)
	assert_eq(pending_modal.anchor_left, 0.5)
	assert_eq(pending_modal.anchor_top, 0.5)
	assert_eq(pending_modal.offset_left, -pending_modal.offset_right)
	assert_eq(pending_modal.offset_top, -pending_modal.offset_bottom)
	assert_not_null(battle.find_child("NecromancerChoiceScroll", true, false))
	assert_not_null(battle.find_child("PendingBattleChoiceScroll", true, false))
	var necro_style: StyleBoxFlat = necro_modal.get_theme_stylebox("panel") as StyleBoxFlat
	var pending_style: StyleBoxFlat = pending_modal.get_theme_stylebox("panel") as StyleBoxFlat
	assert_almost_eq(necro_style.bg_color.a, 0.72, 0.01)
	assert_almost_eq(pending_style.bg_color.a, 0.72, 0.01)
	battle.engine.pending_choices.clear()
	battle.engine.pending_choices.append({"action": "weaken", "source_name": "Teste", "amount": 1})
	battle._play_combat_fx_events([{"type": "stage", "stage": "Teste", "label": "Teste"}], battle.engine.get_state())
	battle._refresh_pending_choice_modal()
	assert_false(pending_modal.visible)
	battle.queue_free()
	await get_tree().process_frame

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

func test_combat_discard_marks_during_main_phase_and_redraws_after_combat() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [
		"invocador_promover",
		"invocador_promover",
		"invocador_promover",
		"invocador_soldado",
		"invocador_soldado",
		"invocador_soldado"
	], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 1,
		"max_hand_size": 3,
		"player_health": 20,
		"shuffle_deck": false,
		"precombat_enabled": true
	})
	assert_false(engine.is_precombat_phase())
	assert_eq(engine.current_phase, BattleEngine.PHASE_MAIN)
	assert_eq(engine.hand.count("invocador_promover"), 3)
	for hand_index: int in range(3):
		assert_true(bool(engine.toggle_precombat_discard(hand_index).get("ok", false)))
	assert_eq(Array(engine.get_state().get("precombat_discard_indices", [])).size(), 3)
	var combat_result: Dictionary = engine.resolve_combat_cycle()
	assert_true(bool(combat_result.get("ok", false)), str(combat_result.get("message", "")))
	assert_eq(engine.hand.size(), 3)
	assert_eq(engine.hand.count("invocador_soldado"), 3)
	assert_eq(engine.discard.count("invocador_promover"), 3)

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
	assert_string_contains(text, "Causa 6 de dano")
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 2})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_null(engine.enemy_slots[2])

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

func test_new_arcano_cards_resolve_area_damage_and_accelerate() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_bola_de_fogo_lvl3"], {
		"encounter": {
			"id": "test_fireball",
			"display_name": "Teste Bola",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_medio"},
				{"slot": 1, "card_id": "elemental_guardiao"},
				{"slot": 2, "card_id": "elemental_medio"}
			]
		},
		"class_id": "arcano",
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	var fireball_result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_true(bool(fireball_result.get("ok", false)), str(fireball_result.get("message", "")))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 2)

	engine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_acelerar_lvl3", "arcano_choque"], {
		"encounter": {
			"id": "test_accelerate",
			"display_name": "Teste Acelerar",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 1,
			"enemy_slots_count": 1,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_medio"}]
		},
		"class_id": "arcano",
		"mana_per_turn": 1,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(ContentLibrary.get_card("arcano_fagulha"), BattleEngine.PLAYER_ID, false)
	assert_false(engine.can_play_card_without_target(0))
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "area": "board"}).get("ok", false)))
	assert_eq(engine.mana, 2)
	assert_eq(int(engine.get_state().get("temporary_ability_power", 0)), 3)
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0}).get("ok", false)))
	assert_null(engine.enemy_slots[0])

func test_invocador_new_cards_apply_temporary_buff_and_regeneration() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_golem_lvl2", "invocador_atacar_lvl2"], {
		"encounter": {
			"id": "test_golem",
			"display_name": "Teste Golem",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 2,
			"enemy_slots_count": 2,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "invocador",
		"mana_per_turn": 5,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	assert_false(bool(engine.play_card_from_hand(0).get("ok", false)))
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "area": "board"}).get("ok", false)))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 7)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("temporary_health_bonus", 0)), 2)
	var occupant: Dictionary = Dictionary(engine.player_slots[0])
	occupant["health"] = 3
	engine.player_slots[0] = occupant
	engine.resolve_combat_cycle()
	assert_true(int(Dictionary(engine.player_slots[0]).get("health", 0)) >= 4)

func test_necromante_new_cards_carrion_remove_and_punish_snared() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_carniceiro"], {
		"encounter": {
			"id": "test_carrion",
			"display_name": "Teste Carnica",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 2,
			"enemy_slots_count": 2,
			"starting_enemy_slots": [{"slot": 1, "card_id": "elemental_menor"}]
		},
		"class_id": "necromante",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 3)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 3)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 3)

	engine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_diabrete_lvl3"], {
		"encounter": {
			"id": "test_imp",
			"display_name": "Teste Diabrete",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 1,
			"enemy_slots_count": 1,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "necromante",
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 0}).get("ok", false)))
	engine._damage_slot(BattleEngine.PLAYER_ID, 0, 1)
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])

func test_arcane_tempest_requires_enemy_board_area_target() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_tempestade"], {
		"encounter": {
			"id": "test_area_spell",
			"display_name": "Teste Area",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "arcano",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_false(bool(engine.play_card_from_hand(0).get("ok", false)))
	var targets: Array[Dictionary] = engine.get_valid_card_targets(0)
	assert_eq(targets.size(), 1)
	assert_eq(str(targets[0].get("area", "")), "board")
	assert_eq(str(targets[0].get("owner", "")), BattleEngine.ENEMY_ID)
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "area": "board"})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var enemy_slot: Variant = engine.enemy_slots[0]
	assert_true(enemy_slot == null or int(Dictionary(enemy_slot).get("health", 0)) < 2 or engine.enemy_health < 20)

func test_battle_scene_exposes_enemy_board_area_drop_zone_for_tempest() -> void:
	_start_class_run("arcano", 44)
	RunSession.current_deck_ids = ["arcano_tempestade"]
	RunSession.max_hand_size = 1
	RunSession.max_mana = 2
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var area_target = battle.find_child("BattleEnemyBoardAreaTarget", true, false)
	var board_margin = battle.find_child("BattleBoardMargin", true, false)
	var enemy_slot = battle.find_child("EnemySlot0", true, false)
	battle._refresh()
	assert_not_null(area_target)
	assert_not_null(board_margin)
	assert_not_null(enemy_slot)
	assert_true(area_target.visible)
	assert_true(area_target.get_index() < board_margin.get_index())
	assert_gt(area_target.get_global_rect().size.y, enemy_slot.get_global_rect().size.y)
	assert_gt(area_target.get_global_rect().size.x, enemy_slot.get_global_rect().size.x * 2.0)
	assert_true(area_target.get_global_rect().intersects(enemy_slot.get_global_rect()))
	var tempest_payload: Dictionary = {"kind": "battle_card", "card_id": "arcano_tempestade", "hand_index": 0}
	assert_true(enemy_slot._can_drop_data(Vector2.ZERO, tempest_payload))
	assert_eq(str(battle._slot_or_area_drop_target(tempest_payload, BattleEngine.ENEMY_ID, 0).get("area", "")), "board")
	assert_true(area_target._can_drop_data(Vector2.ZERO, tempest_payload))
	var before_mana: int = battle.engine.mana
	battle._on_area_target_dropped(tempest_payload, {"owner": BattleEngine.ENEMY_ID, "area": "board"})
	assert_lt(battle.engine.mana, before_mana)
	battle.queue_free()
	await get_tree().process_frame

func test_summon_on_occupied_slot_requires_confirmation_without_spending() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_batedor"], {
		"encounter": {
			"id": "test_sacrifice",
			"display_name": "Teste Sacrificio",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_solido"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_true(bool(engine.play_card_from_hand(0, {"slot": 0}).get("ok", false)))
	var before_mana: int = engine.mana
	var before_hand: Array[String] = engine.hand.duplicate()
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_false(bool(result.get("ok", false)))
	assert_true(bool(result.get("requires_confirmation", false)))
	assert_eq(engine.mana, before_mana)
	assert_eq(engine.hand, before_hand)
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	var confirmed_target: Dictionary = Dictionary(result.get("target", {}))
	confirmed_target["confirm_sacrifice"] = true
	assert_true(bool(engine.play_card_from_hand(int(result.get("hand_index", -1)), confirmed_target).get("ok", false)))
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_lt(engine.mana, before_mana)

func test_summon_cannot_replace_defense_objective() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_objective_replace",
			"display_name": "Teste Objetivo",
			"mode": BattleEngine.MODE_DEFENSE_POSITION,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"defense_slot": 1,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_false(engine.can_play_card_on_target(0, {"owner": BattleEngine.PLAYER_ID, "slot": 1}))
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 1})
	assert_false(bool(result.get("ok", false)))
	assert_false(bool(result.get("requires_confirmation", false)))

func test_battle_scene_sacrifice_modal_cancel_and_confirm() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var manual_hand: Array[String] = ["invocador_soldado", "invocador_batedor"]
	var empty_cards: Array[String] = []
	battle.engine.hand = manual_hand
	battle.engine.deck = empty_cards.duplicate()
	battle.engine.discard = empty_cards.duplicate()
	battle.engine.mana = 2
	battle.engine.player_slots[0] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	battle._refresh()
	var before_mana: int = battle.engine.mana
	battle._on_slot_target_dropped({"kind": "battle_card", "hand_index": 1, "card_id": "invocador_batedor"}, BattleEngine.PLAYER_ID, 0)
	var modal: PanelContainer = battle.find_child("BattleSacrificeConfirmModal", true, false)
	assert_not_null(modal)
	assert_true(modal.visible)
	assert_eq(battle.engine.mana, before_mana)
	assert_eq(str(Dictionary(battle.engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	var cancel_button: Button = battle.find_child("BattleSacrificeCancelButton", true, false)
	cancel_button.pressed.emit()
	await get_tree().process_frame
	assert_false(modal.visible)
	assert_eq(battle.engine.mana, before_mana)
	assert_eq(battle.engine.hand.size(), 2)
	battle._on_slot_target_dropped({"kind": "battle_card", "hand_index": 1, "card_id": "invocador_batedor"}, BattleEngine.PLAYER_ID, 0)
	var confirm_button: Button = battle.find_child("BattleSacrificeConfirmButton", true, false)
	confirm_button.pressed.emit()
	await get_tree().process_frame
	assert_false(modal.visible)
	assert_eq(str(Dictionary(battle.engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_lt(battle.engine.mana, before_mana)
	battle.queue_free()
	await get_tree().process_frame

func test_combat_fx_state_removes_dead_slot_only_on_damage_event() -> void:
	_start_class_run("arcano", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.combat_fx_state = battle.engine.get_state().duplicate(true)
	var attack_event: Dictionary = {"type": "attack", "target_owner": BattleEngine.ENEMY_ID, "target_slot": 0}
	battle._apply_combat_fx_event_to_state(attack_event)
	assert_not_null(Array(battle.combat_fx_state.get("enemy_slots", []))[0])
	var damage_event: Dictionary = {
		"type": "damage",
		"target_owner": BattleEngine.ENEMY_ID,
		"target_slot": 0,
		"amount": 99,
		"health_after": -97,
		"destroyed": true,
		"removed": true
	}
	battle._apply_combat_fx_event_to_state(damage_event)
	assert_null(Array(battle.combat_fx_state.get("enemy_slots", []))[0])
	battle.queue_free()
	await get_tree().process_frame

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
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "area": "board"})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 5)

func test_creature_moves_to_adjacent_empty_slot_once_per_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_move",
			"display_name": "Teste Movimento",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_solido"}]
		},
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 1})
	assert_true(engine.can_move_unit(BattleEngine.PLAYER_ID, 1, 0))
	assert_true(bool(engine.move_unit(BattleEngine.PLAYER_ID, 1, 0).get("ok", false)))
	assert_not_null(engine.player_slots[0])
	assert_null(engine.player_slots[1])
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 1))

func test_creature_move_swaps_adjacent_occupied_slots_and_blocks_objective() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado", "invocador_batedor"], {
		"encounter": {
			"id": "test_move_blocks",
			"display_name": "Teste Movimento Bloqueios",
			"mode": BattleEngine.MODE_DEFENSE_POSITION,
			"player_slots_count": 4,
			"enemy_slots_count": 4,
			"defense_slot": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_solido"}]
		},
		"mana_per_turn": 4,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.play_card_from_hand(0, {"slot": 1})
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 2))
	assert_true(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 1))
	assert_true(bool(engine.move_unit(BattleEngine.PLAYER_ID, 0, 1).get("ok", false)))
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_eq(str(Dictionary(engine.player_slots[1]).get("card_id", "")), "invocador_soldado")
	assert_true(bool(Dictionary(engine.player_slots[0]).get("moved_this_turn", false)))
	assert_true(bool(Dictionary(engine.player_slots[1]).get("moved_this_turn", false)))
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 0, 1))
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 1, 0))
	assert_false(engine.can_move_unit(BattleEngine.PLAYER_ID, 3, 2))

func test_field_unit_drop_moves_creature_in_battle_scene() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.player_slots[1] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	battle._refresh()
	battle._on_slot_target_dropped({"kind": "field_unit", "owner": BattleEngine.PLAYER_ID, "slot": 1}, BattleEngine.PLAYER_ID, 0)
	assert_not_null(battle.engine.player_slots[0])
	assert_null(battle.engine.player_slots[1])
	battle.queue_free()
	await get_tree().process_frame

func test_field_unit_drop_swaps_adjacent_creatures_in_battle_scene() -> void:
	_start_class_run("invocador", 44)
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.player_slots[0] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_soldado"), BattleEngine.PLAYER_ID, false)
	battle.engine.player_slots[1] = battle.engine._build_occupant(ContentLibrary.get_card("invocador_batedor"), BattleEngine.PLAYER_ID, false)
	battle._refresh()
	battle._on_slot_target_dropped({"kind": "field_unit", "owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.PLAYER_ID, 1)
	assert_eq(str(Dictionary(battle.engine.player_slots[0]).get("card_id", "")), "invocador_batedor")
	assert_eq(str(Dictionary(battle.engine.player_slots[1]).get("card_id", "")), "invocador_soldado")
	assert_true(bool(Dictionary(battle.engine.player_slots[0]).get("moved_this_turn", false)))
	assert_true(bool(Dictionary(battle.engine.player_slots[1]).get("moved_this_turn", false)))
	battle.queue_free()
	await get_tree().process_frame

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

func test_overflow_rechecks_dead_defender_between_sequential_lanes() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_guardiao"], {
		"encounter": {
			"id": "test_dead_defender_overflow",
			"display_name": "Teste Defensor Morto",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_agil"},
				{"slot": 1, "card_id": "elemental_bruto"},
				{"slot": 2, "card_id": "elemental_solido"}
			]
		},
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)
	assert_eq(engine.player_health, 19)

func test_sequential_overflow_skips_creature_killed_before_its_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_overflow_dead_attacker",
			"display_name": "Teste Sobra Atacante Morto",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 1, "card_id": "elemental_bruto"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 0,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.player_slots[0] = engine._build_occupant(ContentLibrary.get_card("elemental_bruto"), BattleEngine.PLAYER_ID, false)
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[1])
	assert_eq(engine.player_health, 20)

func test_duel_overflow_hits_enemy_hero_when_no_front_or_defender() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_duel_overflow",
			"display_name": "Teste Duelo Sobra",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 16,
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
	assert_eq(engine.enemy_health, 15)

func test_non_hero_overflow_hits_nearest_enemy_creature() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_nearest_overflow",
			"display_name": "Teste Sobra Proxima",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_guardiao"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 6)

func test_defender_does_not_intercept_front_target() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_defender_front",
			"display_name": "Teste Defensor Frente",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [
				{"slot": 0, "card_id": "elemental_menor"},
				{"slot": 2, "card_id": "invocador_guardiao"}
			]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 4)

func test_initiative_kills_before_normal_response() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_batedor"], {
		"encounter": {
			"id": "test_initiative_order",
			"display_name": "Teste Iniciativa",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "arcano_fagulha"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 1)

func test_same_stage_attackers_deal_damage_before_death() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_stage_batch",
			"display_name": "Teste Etapa",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_true(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)

func test_overflow_attack_has_no_retaliation() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto"], {
		"encounter": {
			"id": "test_overflow_no_retaliation",
			"display_name": "Teste Sobra Sem Retorno",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 2, "card_id": "elemental_assaltante"}]
		},
		"mana_per_turn": 1,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 2)

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
		var before_board: int = _occupied_count(engine.enemy_slots)
		var before_discard: int = engine.enemy_discard.size()
		engine.resolve_combat_cycle()
		assert_gt(_occupied_count(engine.enemy_slots), before_board)
		assert_gt(engine.enemy_discard.size(), before_discard)

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

func test_duel_battle_layout_uses_compact_hud_composition() -> void:
	_start_class_run("arcano", 101)
	RunSession.select_node("n06_duelo_inicial")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	await get_tree().process_frame
	var main_stack: VBoxContainer = battle.find_child("BattleMainStack", true, false)
	var enemy_hud: PanelContainer = battle.find_child("BattleEnemyCommanderHud", true, false)
	var intent_panel: PanelContainer = battle.find_child("BattleEnemyIntentPanel", true, false)
	var player_hud: PanelContainer = battle.find_child("BattlePlayerHudDock", true, false)
	var player_target: PanelContainer = battle.find_child("BattlePlayerHeroTarget", true, false)
	var enemy_target: PanelContainer = battle.find_child("BattleEnemyHeroTarget", true, false)
	var hand_row: HBoxContainer = battle.find_child("BattleHandControlsRow", true, false)
	var area_target = battle.find_child("BattleEnemyBoardAreaTarget", true, false)
	assert_not_null(main_stack)
	assert_not_null(enemy_hud)
	assert_not_null(intent_panel)
	assert_not_null(player_hud)
	assert_not_null(player_target)
	assert_not_null(enemy_target)
	assert_not_null(hand_row)
	assert_not_null(area_target)
	assert_false(_has_label_text(player_target, "Heroi"))
	assert_false(_has_label_text(enemy_target, "Heroi"))
	assert_eq(player_target.custom_minimum_size, Vector2(118, 42))
	assert_eq(enemy_target.custom_minimum_size, Vector2(118, 42))
	assert_true(enemy_hud.get_parent() == battle)
	assert_true(intent_panel.visible)
	assert_true(_has_label_text(intent_panel, "Intencao inimiga"))
	assert_true(player_hud.get_parent() == hand_row)
	assert_null(battle.find_child("BattlePlayerHpStat", true, false))
	assert_eq(str(area_target.get_parent().name), "BattleBoardSurface")
	assert_false(main_stack.is_ancestor_of(enemy_hud))
	_assert_control_inside_viewport(battle.find_child("BattleHandPanel", true, false) as Control)
	_assert_control_inside_viewport(enemy_hud)
	_assert_control_inside_viewport(intent_panel)
	battle.queue_free()
	await get_tree().process_frame

func test_map_nine_duel_scene_keeps_four_lane_hud() -> void:
	_start_class_run("arcano", 99)
	RunSession.select_node("n12_duelo_elite")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var enemy_hud: PanelContainer = battle.find_child("BattleEnemyCommanderHud", true, false)
	assert_not_null(enemy_hud)
	assert_true(enemy_hud.visible)
	assert_eq(battle.enemy_slots_box.get_child_count(), 4)
	assert_eq(battle.player_slots_box.get_child_count(), 4)
	assert_not_null(battle.find_child("BattlePlayerHudDock", true, false))
	battle.queue_free()
	await get_tree().process_frame

func test_track02_dense_board_layouts_remain_readable_for_5_6_7_slots() -> void:
	var cases: Array[Dictionary] = [
		{"node_id": "n22_soberano_tempestades", "slots": 6},
		{"node_id": "n28_portal_caos", "slots": 6},
		{"node_id": "n29_dragao_primordial", "slots": 7}
	]
	for test_case: Dictionary in cases:
		_start_class_run("arcano", 202)
		RunSession.max_mana = 6
		RunSession.max_hand_size = 5
		RunSession.current_deck_ids.append_array(["arcano_barreira", "arcano_tempestade", "arcano_vortice", "arcano_acelerar"])
		RunSession.select_node(str(test_case.get("node_id", "")))
		var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
		await get_tree().process_frame
		assert_eq(battle.player_slots_box.get_child_count(), int(test_case.get("slots", 0)))
		assert_eq(battle.enemy_slots_box.get_child_count(), int(test_case.get("slots", 0)))
		assert_true(battle._uses_dense_battle_layout())
		assert_true(battle._field_card_size().x >= 70.0)
		assert_true(battle._hand_card_size().x >= 82.0)
		_assert_control_inside_viewport(battle.find_child("BattleHandPanel", true, false) as Control)
		_assert_control_inside_viewport(battle.find_child("BattleEnemyIntentPanel", true, false) as Control)
		_assert_control_inside_viewport(battle.find_child("BattleEndTurnFloatingButton", true, false) as Control)
		battle.queue_free()
		await get_tree().process_frame

func test_unlocked_passive_and_active_stay_visible_with_preview_data() -> void:
	_start_class_run("arcano", 99)
	RunSession.class_passive_unlocked = true
	RunSession.class_active_unlocked = true
	RunSession.select_node("n06_duelo_inicial")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var passive_tile = battle.find_child("BattleClassPassiveTile", true, false)
	var active_tile = battle.find_child("BattleClassActiveTile", true, false)
	assert_not_null(passive_tile)
	assert_not_null(active_tile)
	assert_true(passive_tile.visible)
	assert_true(active_tile.visible)
	assert_string_contains(str(battle._class_passive_preview_data().get("body", "")), "Fluxo")
	assert_string_contains(str(battle._class_active_preview_data().get("body", "")), "Fluxo")
	battle.engine.mana = 0
	battle._refresh()
	assert_true(active_tile.visible)
	battle.queue_free()
	await get_tree().process_frame

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
	assert_not_null(engine.player_slots[0])
	assert_true(bool(Dictionary(engine.player_slots[0]).get("revive_marker", false)))
	var sacrifice_result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(sacrifice_result.get("requires_confirmation", false)))
	var confirmed_target: Dictionary = Dictionary(sacrifice_result.get("target", {}))
	confirmed_target["confirm_sacrifice"] = true
	engine.play_card_from_hand(int(sacrifice_result.get("hand_index", -1)), confirmed_target)
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
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("attack", 0)), 3)
	assert_eq(int(Dictionary(engine.enemy_slots[1]).get("health", 0)), 3)

func test_necromancer_active_level_one_choices_use_exact_values() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_fagulha", "necro_esqueleto"], {
		"encounter": {
			"id": "test_necro_level_one",
			"display_name": "Teste Necro I",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_bruto"}]
		},
		"class_id": "necromante",
		"class_active_unlocked": true,
		"class_active_level": 1,
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 1})
	engine.ashes = 2
	var choices: Array[Dictionary] = engine.get_necromancer_active_choices()
	assert_eq(choices.size(), 3)
	for choice: Dictionary in choices:
		var choice_id: String = str(choice.get("id", ""))
		assert_false(["necro_slow", "necro_confusion", "necro_revive_full"].has(choice_id))
	assert_true(bool(engine.use_class_active({"owner": BattleEngine.ENEMY_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_ROT).get("ok", false)))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 3)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 3)

func test_necromancer_active_level_two_adds_upgrades_and_temp_attack() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_esqueleto", "invocador_soldado"], {
		"encounter": {
			"id": "test_necro_level_two",
			"display_name": "Teste Necro II",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_bruto"}]
		},
		"class_id": "necromante",
		"class_active_unlocked": true,
		"class_active_level": 2,
		"mana_per_turn": 2,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.discard.append("necro_esqueleto")
	engine.ashes = 4
	var choices: Array[Dictionary] = engine.get_necromancer_active_choices()
	assert_eq(choices.size(), 7)
	assert_true(engine.can_use_class_active_on_target({"owner": BattleEngine.PLAYER_ID, "slot": 1}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE))
	assert_true(bool(engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_ATTACK_FOUR).get("ok", false)))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 5)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("temporary_attack_bonus", 0)), 4)

func test_necromancer_reanimation_does_not_replace_occupied_slots() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_soldado"], {
		"encounter": {
			"id": "test_necro_no_auto_replace",
			"display_name": "Teste Necro Sem Troca",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 2,
			"enemy_slots_count": 2,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"class_id": "necromante",
		"class_active_unlocked": true,
		"class_active_level": 2,
		"mana_per_turn": 2,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"slot": 0})
	engine.discard.append("necro_esqueleto")
	engine.ashes = 4
	assert_false(engine.can_use_class_active_on_target({"owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE))
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE)
	assert_false(bool(result.get("ok", false)))
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "invocador_soldado")
	assert_eq(engine.ashes, 4)

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

func test_defense_position_does_not_win_by_clearing_board_before_turn_goal() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "defesa_posicao_inicial",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(engine.required_defense_turns, 5)
	assert_eq(engine.wave_index, 1)
	for index: int in range(engine.enemy_slots.size()):
		engine._damage_slot(BattleEngine.ENEMY_ID, index, 99)
	engine._check_outcome()
	assert_eq(engine.outcome, "")
	engine.survived_turns = engine.required_defense_turns
	engine._check_outcome()
	assert_eq(engine.outcome, "vitoria")

func test_survive_still_wins_when_board_is_cleared_and_starts_buffed() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "sobreviver_turnos_inicial",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(str(Dictionary(engine.enemy_slots[1]).get("card_id", "")), "enemy_gelo_djinn_do_frio")
	for index: int in range(engine.enemy_slots.size()):
		engine._damage_slot(BattleEngine.ENEMY_ID, index, 99)
	engine._check_outcome()
	assert_eq(engine.outcome, "vitoria")

func test_boss_encounters_start_with_stronger_boards() -> void:
	var first_boss: BattleEngine = BattleEngine.new()
	first_boss.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "chefe_invocador",
		"mana_per_turn": 3,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(first_boss.enemy_health, 30)
	assert_true(_occupied_count(first_boss.enemy_slots) >= 4)

	var final_boss: BattleEngine = BattleEngine.new()
	final_boss.start_battle(ContentLibrary.get_catalog(), ["arcano_choque"], {
		"encounter_id": "chefe_summoner_final",
		"mana_per_turn": 5,
		"max_hand_size": 1,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(final_boss.enemy_health, 50)
	assert_eq(final_boss.board_format, BattleEngine.BOARD_FORMAT_ABYSS)
	assert_true(_occupied_count(final_boss.enemy_slots) >= 7)
	assert_true(_enemy_board_has_card(final_boss.enemy_slots, "enemy_fogo_fenix"))

func test_battle_scene_uses_resolve_combat_button() -> void:
	_start_class_run("arcano")
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var button: Button = battle.find_child("BattleEndTurnFloatingButton", true, false)
	assert_not_null(button)
	assert_string_contains(button.text, "Resolver")
	button.pressed.emit()
	await get_tree().process_frame
	assert_string_contains(button.text, "Resolver")
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_shows_discard_hint_badge_near_hand() -> void:
	_start_class_run("arcano")
	RunSession.select_node("n04_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var badge: PanelContainer = battle.find_child("BattleDiscardHintBadge", true, false)
	var hand: HBoxContainer = battle.find_child("BattleHand", true, false)
	assert_not_null(badge)
	assert_not_null(hand)
	assert_true(badge.visible)
	assert_string_contains(str(badge.tooltip_text), "cartas selecionadas")
	assert_true(badge.get_global_rect().intersects(hand.get_parent().get_global_rect()))
	battle.queue_free()
	await get_tree().process_frame

func test_track02_atropelar_brutal_and_inspirar_resolve_in_combat_stage() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_DUEL)
	engine.enemy_health = 20
	engine.enemy_max_health = 20
	engine.player_slots[0] = engine._build_occupant(_keyword_card("trample", 5, 3, ["atropelar"]), BattleEngine.PLAYER_ID, false)
	engine.player_slots[1] = engine._build_occupant(_keyword_card("captain", 0, 3, ["inspirar"], {"inspire_amount": 1}), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("blocker", 0, 2, []), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_eq(engine.enemy_health, 16)

	engine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[1] = engine._build_occupant(_keyword_card("brutal", 2, 4, ["brutal"]), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("left", 0, 2, []), BattleEngine.ENEMY_ID, true)
	engine.enemy_slots[1] = engine._build_occupant(_keyword_card("front", 0, 5, []), BattleEngine.ENEMY_ID, true)
	engine.enemy_slots[2] = engine._build_occupant(_keyword_card("right", 0, 2, []), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 1)
	assert_eq(int(Dictionary(engine.enemy_slots[2]).get("health", 0)), 1)

func test_track02_drenar_ecoar_veneno_congelar_and_drenar_almas_use_damage_hooks() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_health = 10
	engine.player_max_health = 12
	engine.player_slots[0] = engine._build_occupant(_keyword_card("reaper", 2, 4, ["drenar", "ecoar", "veneno", "congelar", "drenar_almas"], {
		"drain_amount": 2,
		"poison_apply_amount": 2
	}), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("victim", 3, 8, []), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(engine.player_health, 12)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("poison_amount", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("frozen_turns", 0)), 1)
	assert_true(bool(Dictionary(engine.player_slots[0]).get("echo_used", false)))
	assert_eq(engine.bonus_souls, 0)
	engine.resolve_combat_cycle()
	assert_null(engine.enemy_slots[0])
	assert_eq(engine.bonus_souls, 3)

func test_track02_escudo_resistencia_espinhos_and_furia_modify_received_damage() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("attacker", 3, 5, []), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("shield", 0, 4, ["escudo"]), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 4)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("shield_charges", 0)), 0)

	engine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("attacker", 3, 5, []), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("stone", 0, 4, ["resistencia", "espinhos", "furia"], {
		"resistance_amount": 2,
		"thorns_amount": 2
	}), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 3)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 3)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 1)

func test_track02_imune_blocks_spells_debuffs_and_keyword_removal() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_choque", "necro_prender"], {
		"encounter": {
			"id": "test_imune",
			"display_name": "Teste Imune",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 3,
		"max_hand_size": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("lich", 3, 5, ["imune", "crescer"]), BattleEngine.ENEMY_ID, true)
	assert_false(engine.can_play_card_on_target(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0}))
	engine._apply_debuff_to_target({"debuff": "freeze", "amount": 1}, {"owner": BattleEngine.ENEMY_ID, "slot": 0})
	engine._remove_keywords_from_target({"owner": BattleEngine.ENEMY_ID, "slot": 0})
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("frozen_turns", 0)), 0)
	assert_true(bool(Dictionary(engine.enemy_slots[0]).get("imune", false)))
	assert_true(bool(Dictionary(engine.enemy_slots[0]).get("crescer", false)))

func test_track02_crescer_proliferar_pacto_ressurgir_and_profanar_use_turn_death_and_end_combat_timing() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("spawner", 0, 3, ["proliferar"]), BattleEngine.PLAYER_ID, false)
	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("grower", 0, 3, ["crescer"], {"grow_amount": 2}), BattleEngine.ENEMY_ID, true)
	engine.resolve_combat_cycle()
	assert_not_null(engine.player_slots[1])
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 2)

	engine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("twin_a", 2, 3, ["pacto"]), BattleEngine.PLAYER_ID, false)
	engine.player_slots[1] = engine._build_occupant(_keyword_card("twin_b", 2, 3, ["pacto"]), BattleEngine.PLAYER_ID, false)
	engine._recalculate_pact_bonuses(BattleEngine.PLAYER_ID)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 4)
	engine.player_slots[1] = null
	engine._recalculate_pact_bonuses(BattleEngine.PLAYER_ID)
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 2)

	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("phoenix", 4, 5, ["ressurgir"]), BattleEngine.ENEMY_ID, true)
	engine._damage_slot(BattleEngine.ENEMY_ID, 0, 99)
	assert_not_null(engine.enemy_slots[0])
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("attack", 0)), 2)
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)
	assert_true(Array(Dictionary(engine.enemy_slots[0]).get("keywords", [])).is_empty())

	engine.enemy_slots[1] = engine._build_occupant(_keyword_card("profane", 0, 1, ["profanar"]), BattleEngine.ENEMY_ID, true)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("blessed", 1, 3, ["defensor", "escudo"]), BattleEngine.PLAYER_ID, false)
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 99)
	assert_false(bool(Dictionary(engine.player_slots[0]).get("defensor", false)))
	assert_false(bool(Dictionary(engine.player_slots[0]).get("escudo", false)))

func test_track02_entrar_sacrificio_and_poison_maintenance_are_available_to_card_effects() -> void:
	var engine: BattleEngine = _keyword_engine(BattleEngine.MODE_SURVIVE_TURNS)
	engine.player_slots[0] = engine._build_occupant(_keyword_card("ally", 1, 2, []), BattleEngine.PLAYER_ID, false)
	var herald := _keyword_card("herald", 1, 2, ["entrar"], {"on_enter": {"action": "summon_token", "count": 1, "attack": 1, "health": 1, "name": "Recruta"}})
	engine._resolve_on_enter(herald, BattleEngine.PLAYER_ID, 0)
	assert_not_null(engine.player_slots[1])
	assert_eq(str(Dictionary(engine.player_slots[1]).get("name", "")), "Recruta")

	var sacrifice_card := _keyword_card("sacrifice", 2, 2, ["sacrificio"], {"sacrifice_discount": 2})
	sacrifice_card.cost = 3
	engine.mana = 1
	assert_eq(engine._minimum_card_play_cost(sacrifice_card), 1)
	assert_eq(engine._card_play_cost_for_target(sacrifice_card, {"owner": BattleEngine.PLAYER_ID, "slot": 0, "confirm_sacrifice": true}), 1)

	engine.enemy_slots[0] = engine._build_occupant(_keyword_card("poisoned", 0, 4, []), BattleEngine.ENEMY_ID, true)
	engine._apply_poison_to_slot(BattleEngine.ENEMY_ID, 0, 2)
	engine._resolve_poison_ticks()
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("health", 0)), 2)

func _instantiate_scene(path: String):
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	var node = packed.instantiate()
	add_child(node)
	await get_tree().process_frame
	return node

func _keyword_engine(mode: String = BattleEngine.MODE_SURVIVE_TURNS) -> BattleEngine:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_keywords",
			"display_name": "Teste Keywords",
			"mode": mode,
			"survive_turns": 99,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 0,
		"max_hand_size": 0,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.outcome = ""
	engine.current_phase = BattleEngine.PHASE_MAIN
	return engine

func _keyword_card(card_id: String, attack: int, health: int, keywords: Array[String], effect: Dictionary = {}) -> CardDefinitionResource:
	var card: CardDefinitionResource = CardDefinitionResource.new()
	card.id = "test_%s" % card_id
	card.display_name = "Teste %s" % card_id
	card.card_type = "criatura"
	card.cost = 0
	card.attack = attack
	card.health = health
	card.keywords = PackedStringArray(keywords)
	card.effect = effect
	return card

func _start_class_run(class_id: String, seed: int = 0) -> void:
	var result: Dictionary = RunSession.start_class_run(class_id, seed)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func _count_children_with_prefix(node: Node, prefix: String) -> int:
	var count: int = 0
	for child: Node in node.get_children():
		if str(child.name).begins_with(prefix):
			count += 1
	return count

func _occupied_count(slots: Array) -> int:
	var count: int = 0
	for occupant: Variant in slots:
		if occupant != null:
			count += 1
	return count

func _enemy_board_has_card(slots: Array, card_id: String) -> bool:
	for occupant: Variant in slots:
		if occupant != null and str(Dictionary(occupant).get("card_id", "")) == card_id:
			return true
	return false

func _new_card_copies_for_rarity(rarity: String) -> int:
	match rarity:
		RunSession.REWARD_RARITY_RARE:
			return 4
		RunSession.REWARD_RARITY_ULTRA:
			return 5
		_:
			return 3

func _has_label_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text) == text:
		return true
	for child: Node in node.get_children():
		if _has_label_text(child, text):
			return true
	return false

func _assert_control_inside_viewport(control: Control) -> void:
	assert_not_null(control)
	if control == null:
		return
	var rect: Rect2 = control.get_global_rect()
	var viewport_size: Vector2 = control.get_viewport_rect().size
	assert_true(rect.position.x >= -1.0, "%s should not extend past the left edge." % str(control.name))
	assert_true(rect.position.y >= -1.0, "%s should not extend past the top edge." % str(control.name))
	assert_true(rect.position.x + rect.size.x <= viewport_size.x + 1.0, "%s should not extend past the right edge." % str(control.name))
	assert_true(rect.position.y + rect.size.y <= viewport_size.y + 1.0, "%s should not extend past the bottom edge." % str(control.name))

func _clear_test_saves() -> void:
	for index: int in range(1, SaveManager.SLOT_COUNT + 1):
		var path: String = "%s%d.json" % [TEST_SAVE_PREFIX, index]
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _write_test_save_file(index: int, payload: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://"))
	var path: String = "%s%d.json" % [TEST_SAVE_PREFIX, index]
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
