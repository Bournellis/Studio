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

func test_catalog_uses_real_slice_classes() -> void:
	var catalog = ContentLibrary.get_catalog()
	assert_not_null(catalog)
	assert_eq(catalog.player_hero.id, "comandante_draxos")
	assert_eq(catalog.player_hero.max_health, 20)
	assert_eq(catalog.class_options.size(), 3)
	for class_id: String in ["arcano", "invocador", "necromante"]:
		var class_option: Dictionary = catalog.find_class_option(class_id)
		assert_false(class_option.is_empty(), "Missing class %s" % class_id)
		assert_eq(int(class_option.get("starting_mana", 0)), 2)
		assert_eq(int(class_option.get("starting_health", 0)), 20)
		assert_gte(Array(class_option.get("starter_deck", [])).size(), 14)
		assert_false(str(class_option.get("passive_id", "")).is_empty())
		assert_false(str(class_option.get("active_id", "")).is_empty())

func test_class_decks_reference_existing_cards() -> void:
	var catalog = ContentLibrary.get_catalog()
	for class_option: Dictionary in catalog.class_options:
		for card_id: String in Array(class_option.get("starter_deck", [])):
			assert_not_null(catalog.find_card(card_id), "Missing card %s for %s" % [card_id, str(class_option.get("id", ""))])
			assert_lt(int(catalog.find_card(card_id).cost), 3, "Starter deck card must cost less than 3: %s" % card_id)

func test_linear_catalog_exposes_10_maps_and_all_modes() -> void:
	var catalog = ContentLibrary.get_catalog()
	var clear_encounter: Dictionary = ContentLibrary.get_catalog().find_encounter("pouso_elemental")
	assert_eq(str(clear_encounter.get("mode", "")), "limpar_mesa")
	assert_eq(int(clear_encounter.get("player_slots_count", 0)), 3)
	assert_eq(int(clear_encounter.get("enemy_slots_count", 0)), 3)
	assert_eq(Array(clear_encounter.get("starting_enemy_slots", [])).size(), 3)
	assert_eq(str(Dictionary(Array(clear_encounter.get("starting_enemy_slots", []))[0]).get("card_id", "")), "elemental_agil")

	var waves_encounter: Dictionary = ContentLibrary.get_catalog().find_encounter("ondas_iniciais")
	assert_eq(str(waves_encounter.get("mode", "")), "ondas")
	assert_eq(str(waves_encounter.get("enemy_director", "")), "waves")
	assert_eq(Array(waves_encounter.get("waves", [])).size(), 3)
	assert_eq(Array(Array(waves_encounter.get("waves", []))[2]).size(), 3)
	var modes: Array[String] = []
	for encounter: Dictionary in catalog.encounters:
		var mode: String = str(encounter.get("mode", ""))
		if not modes.has(mode):
			modes.append(mode)
	for expected_mode: String in ["limpar_mesa", "duelo", "ondas", "defesa_posicao", "sobreviver_turnos", "chefe_summoner"]:
		assert_true(modes.has(expected_mode), "Missing encounter mode %s" % expected_mode)
	assert_eq(catalog.encounters.size(), 10)

func test_run_map_exposes_10_linear_mainline_nodes() -> void:
	var nodes: Array = Array(ContentLibrary.get_run_map().get("nodes", []))
	assert_eq(nodes.size(), 10)
	assert_false(_find_run_node(nodes, "n01_pouso_elemental").is_empty())
	assert_false(_find_run_node(nodes, "n02_ondas_iniciais").is_empty())
	assert_false(_find_run_node(nodes, "n10_chefe_final").is_empty())
	var waves_node: Dictionary = _find_run_node(nodes, "n02_ondas_iniciais")
	assert_eq(str(waves_node.get("kind", "")), "mainline")
	assert_eq(str(waves_node.get("encounter_id", "")), "ondas_iniciais")
	assert_true(Array(waves_node.get("available_after", [])).has("n01_pouso_elemental"))
	assert_true(Array(waves_node.get("rewards", [])).has(RunSession.REWARD_MAX_MANA_1))
	for node: Dictionary in nodes:
		assert_eq(str(node.get("kind", "")), "mainline")

func test_visual_asset_manifest_covers_current_slice_without_requiring_pngs() -> void:
	var result: Dictionary = VisualAssets.validate_manifest(ContentLibrary.get_catalog())
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var missing_assets: Array = Array(result.get("missing_assets", []))
	assert_true(missing_assets.size() > 0, "The V1 manifest should report missing PNGs without failing.")
	assert_false(VisualAssets.surface_entry("ship_hub_background").is_empty())
	assert_false(VisualAssets.frame_entry("frame_arcano").is_empty())
	assert_false(VisualAssets.card_entry("arcano_spell_dano").is_empty())
	assert_eq(str(VisualAssets.surface_entry("ship_hub_background").get("actual_resolution", "")), "1456x816")
	assert_true(VisualAssets.card_frame_overlay_safe("arcano_spell_dano"))
	assert_false(VisualAssets.card_frame_overlay_safe("invocador_protecao"))
	assert_null(VisualAssets.card_frame_overlay_texture("invocador_protecao"))

func test_visual_asset_fallback_background_builds_without_png() -> void:
	var background: Control = VisualAssets.build_surface_background("ship_hub_background")
	assert_not_null(background)
	assert_eq(background.name, "VisualSurface_ship_hub_background")
	if VisualAssets.surface_texture("ship_hub_background") == null:
		assert_not_null(background.find_child("VisualSurfaceFallbackFill", true, false))
		assert_not_null(background.find_child("VisualSurfaceFallbackLabel", true, false))
	background.free()

func test_visual_card_template_uses_mechanical_values() -> void:
	var small_damage = ContentLibrary.get_card("arcano_spell_dano")
	var large_damage = ContentLibrary.get_card("arcano_spell_dano_maior")
	var buff = ContentLibrary.get_card("invocador_buff_unico")
	assert_string_contains(VisualAssets.card_display_text(small_damage), "Causa 1 de dano")
	assert_string_contains(VisualAssets.card_display_text(large_damage), "Causa 2 de dano")
	assert_string_contains(VisualAssets.card_display_text(buff), "+1/+1")

func test_keywords_migrate_frontline_cards_to_initiative() -> void:
	for card_id: String in ["arcano_protetor", "invocador_protecao", "invocador_voadora"]:
		var card = ContentLibrary.get_card(card_id)
		assert_true(card.has_keyword("iniciativa"), "%s should have iniciativa." % card_id)
		assert_false(card.has_keyword("protecao"), "%s should not keep protecao." % card_id)
		assert_false(card.has_keyword("voadora"), "%s should not keep voadora." % card_id)

func test_run_session_starts_arcano_run_with_slice_stats() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_true(RunSession.active)
	assert_eq(RunSession.selected_class_id, "arcano")
	assert_eq(RunSession.selected_class_display_name, "Arcano")
	assert_eq(RunSession.current_health, 20)
	assert_eq(RunSession.max_health, 20)
	assert_eq(RunSession.max_mana, 2)
	assert_eq(RunSession.soul_total, 0)
	assert_eq(RunSession.current_deck_ids.size(), 14)
	assert_false(RunSession.class_passive_unlocked)
	assert_false(RunSession.class_active_unlocked)

func test_run_session_records_souls_without_pending_choice_reward() -> void:
	_start_run()
	RunSession.record_battle_result("n01_pouso_elemental", "vitoria", 14)
	assert_eq(RunSession.current_health, 14)
	assert_eq(RunSession.soul_total, 4)
	assert_eq(RunSession.rewards_pending.size(), 0)
	assert_true(RunSession.completed_node_ids.has("n01_pouso_elemental"))

func test_run_session_paid_heal_spends_souls() -> void:
	_start_run()
	RunSession.record_battle_result("n01_pouso_elemental", "vitoria", 14)
	RunSession.soul_total = 6
	var result: Dictionary = RunSession.buy_paid_heal()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.soul_total, 1)
	assert_eq(RunSession.current_health, 19)

func test_run_session_applies_automatic_map_rewards() -> void:
	_start_run()
	var starting_size: int = RunSession.current_deck_ids.size()
	RunSession.record_battle_result("n02_ondas_iniciais", "vitoria", 20)
	assert_eq(RunSession.max_mana, 3)
	assert_true(RunSession.automatic_reward_ids.has("n02_ondas_iniciais:%s" % RunSession.REWARD_MAX_MANA_1))
	RunSession.record_battle_result("n03_duelo_inicial", "vitoria", 20)
	assert_eq(RunSession.current_deck_ids.size(), starting_size + 2)
	assert_true(RunSession.current_deck_ids.has("arcano_amplificador"))
	assert_true(RunSession.current_deck_ids.has("invocador_colosso"))
	RunSession.record_battle_result("n05_chefe_invocador", "vitoria", 20)
	assert_true(RunSession.class_passive_unlocked)
	RunSession.record_battle_result("n07_limpeza_elite", "vitoria", 20)
	assert_true(RunSession.class_active_unlocked)

func test_battle_engine_shuffles_deck_with_run_seed() -> void:
	var engine: BattleEngine = BattleEngine.new()
	var ordered_deck: Array[String] = [
		"arcano_construtor_fluxo",
		"arcano_spell_dano",
		"arcano_protetor",
		"arcano_gerador_entrada",
		"arcano_spell_dano_maior",
		"arcano_gerador_continuo",
		"arcano_amplificador"
	]
	engine.start_battle(ContentLibrary.get_catalog(), ordered_deck, {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_seed": 42
	})
	assert_eq(engine.hand.size(), 5)
	assert_ne(engine.hand, ordered_deck.slice(0, 5))
	assert_true(bool(engine.get_state().get("shuffle_enabled", false)))

func test_battle_engine_arcano_flow_amplifies_damage() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"class_passive_unlocked": true,
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(engine.flow, 1)
	assert_eq(engine.enemy_slots[0], null)

func test_battle_engine_arcano_active_uses_flow_once_per_turn() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_construtor_fluxo", "arcano_construtor_fluxo", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"class_passive_unlocked": true,
		"class_active_unlocked": true,
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 1})
	engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_true(engine.can_use_class_active())
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_false(engine.can_use_class_active())

func test_battle_engine_class_mechanics_wait_for_map_unlocks() -> void:
	var arcano_engine: BattleEngine = BattleEngine.new()
	arcano_engine.start_battle(ContentLibrary.get_catalog(), ["arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var spell_result: Dictionary = arcano_engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 0})
	assert_true(bool(spell_result.get("ok", false)), str(spell_result.get("message", "")))
	assert_eq(arcano_engine.flow, 0)
	assert_not_null(arcano_engine.enemy_slots[0])
	assert_eq(int(Dictionary(arcano_engine.enemy_slots[0]).get("health", 0)), 1)
	assert_false(arcano_engine.can_use_class_active())

	var invocador_engine: BattleEngine = BattleEngine.new()
	invocador_engine.start_battle(ContentLibrary.get_catalog(), ["invocador_voadora", "invocador_protecao", "invocador_buff_unico", "invocador_buff_unico", "invocador_buff_unico"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var summon_result: Dictionary = invocador_engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(summon_result.get("ok", false)), str(summon_result.get("message", "")))
	assert_eq(int(Dictionary(invocador_engine.player_slots[0]).get("attack", 0)), 3)
	assert_false(invocador_engine.can_use_class_active())

	var necro_engine: BattleEngine = BattleEngine.new()
	necro_engine.start_battle(ContentLibrary.get_catalog(), ["necro_sacrificio_zero", "necro_sacrificio_zero", "necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao"], {
		"encounter_id": "pouso_elemental",
		"class_id": "necromante",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var necro_result: Dictionary = necro_engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(necro_result.get("ok", false)), str(necro_result.get("message", "")))
	necro_engine.end_player_turn()
	assert_eq(necro_engine.ashes, 0)
	assert_false(necro_engine.can_use_class_active())

func test_battle_engine_target_helpers_hide_heroes_in_board_modes() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_protecao", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var summon_result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 2})
	assert_true(bool(summon_result.get("ok", false)), str(summon_result.get("message", "")))
	var targets: Array[Dictionary] = engine.get_valid_card_targets(0)
	assert_true(_has_target(targets, {"owner": BattleEngine.PLAYER_ID, "slot": 2}))
	assert_true(_has_target(targets, {"owner": BattleEngine.ENEMY_ID, "slot": 0}))
	assert_false(_has_target(targets, {"owner": BattleEngine.ENEMY_ID, "hero": true}))
	assert_false(_has_target(engine.get_valid_class_active_targets(""), {"owner": BattleEngine.ENEMY_ID, "hero": true}))

func test_battle_engine_drag_summon_uses_chosen_slot_and_replaces_occupant() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_protecao", "invocador_voadora", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var first_result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 2})
	assert_true(bool(first_result.get("ok", false)), str(first_result.get("message", "")))
	assert_eq(str(Dictionary(engine.player_slots[2]).get("card_id", "")), "invocador_protecao")
	var replace_result: Dictionary = engine.play_card_from_hand(0, {"owner": BattleEngine.PLAYER_ID, "slot": 2})
	assert_true(bool(replace_result.get("ok", false)), str(replace_result.get("message", "")))
	assert_eq(str(Dictionary(engine.player_slots[2]).get("card_id", "")), "invocador_voadora")

func test_battle_engine_invocador_passive_and_active_buff_units() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_voadora", "invocador_protecao", "invocador_buff_unico", "invocador_buff_unico", "invocador_buff_unico"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"class_passive_unlocked": true,
		"class_active_unlocked": true,
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 4)
	var active_result: Dictionary = engine.use_class_active({"slot": 0})
	assert_true(bool(active_result.get("ok", false)), str(active_result.get("message", "")))
	assert_eq(int(Dictionary(engine.player_slots[0]).get("attack", 0)), 6)

func test_battle_engine_necromante_gains_ashes_from_death() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_sacrificio_zero", "necro_sacrificio_zero", "necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao"], {
		"encounter_id": "pouso_elemental",
		"class_id": "necromante",
		"class_passive_unlocked": true,
		"class_active_unlocked": true,
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	engine.end_player_turn()
	assert_gte(engine.ashes, 2)
	assert_true(engine.can_use_class_active())

func test_battle_engine_necromancer_choices_target_debuffs_and_reanimation_slots() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao"], {
		"encounter_id": "pouso_elemental",
		"class_id": "necromante",
		"class_active_unlocked": true,
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.ashes = 2
	var choices: Array[Dictionary] = engine.get_necromancer_active_choices()
	assert_true(_choice_enabled(choices, BattleEngine.NECRO_CHOICE_SLOW))
	assert_true(_choice_enabled(choices, BattleEngine.NECRO_CHOICE_ROT))
	assert_true(_choice_enabled(choices, BattleEngine.NECRO_CHOICE_CONFUSION))
	var confusion_result: Dictionary = engine.use_class_active({"owner": BattleEngine.ENEMY_ID, "slot": 0}, BattleEngine.NECRO_CHOICE_CONFUSION)
	assert_true(bool(confusion_result.get("ok", false)), str(confusion_result.get("message", "")))
	assert_eq(int(Dictionary(engine.enemy_slots[0]).get("confusion_turns", 0)), 1)
	assert_eq(engine.ashes, 0)

	engine.start_battle(ContentLibrary.get_catalog(), ["necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao", "necro_spell_lentidao"], {
		"encounter_id": "pouso_elemental",
		"class_id": "necromante",
		"class_active_unlocked": true,
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.ashes = 4
	engine.discard.append("necro_reanimavel")
	assert_true(_choice_enabled(engine.get_necromancer_active_choices(), BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE))
	var revive_result: Dictionary = engine.use_class_active({"owner": BattleEngine.PLAYER_ID, "slot": 1}, BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE)
	assert_true(bool(revive_result.get("ok", false)), str(revive_result.get("message", "")))
	assert_eq(str(Dictionary(engine.player_slots[1]).get("card_id", "")), "necro_reanimavel")
	assert_eq(int(Dictionary(engine.player_slots[1]).get("attack", 0)), 1)

func test_battle_engine_front_lane_damage_is_simultaneous() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["elemental_agil", "elemental_agil", "elemental_agil", "elemental_agil", "elemental_agil"], {
		"encounter": {
			"id": "test_frente_simultanea",
			"display_name": "Teste frente simultanea",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_agil"}]
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	engine.end_player_turn()
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])
	assert_eq(engine.outcome, "vitoria")

func test_battle_engine_empty_lane_damage_passes_to_commander() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_dano_direto_comandante",
			"display_name": "Teste dano direto",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 99,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.end_player_turn()
	assert_eq(engine.player_health, 19)

func test_battle_engine_initiative_kills_without_return_damage() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_voadora", "invocador_voadora", "invocador_voadora", "invocador_voadora", "invocador_voadora"], {
		"encounter": {
			"id": "test_iniciativa_sem_retorno",
			"display_name": "Teste iniciativa",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_menor"}]
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	engine.end_player_turn()
	assert_not_null(engine.player_slots[0])
	assert_eq(int(Dictionary(engine.player_slots[0]).get("health", 0)), 2)
	assert_null(engine.enemy_slots[0])

func test_battle_engine_initiative_tie_is_simultaneous() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_voadora", "invocador_voadora", "invocador_voadora", "invocador_voadora", "invocador_voadora"], {
		"encounter": {
			"id": "test_iniciativa_empate",
			"display_name": "Teste iniciativa empate",
			"mode": BattleEngine.MODE_CLEAR_BOARD,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": [{"slot": 0, "card_id": "elemental_elite_agil"}]
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	engine.end_player_turn()
	assert_null(engine.player_slots[0])
	assert_null(engine.enemy_slots[0])

func test_battle_engine_defense_position_wins_after_three_turns_with_objective_alive() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_defesa_posicao",
			"display_name": "Teste defesa posicao",
			"mode": BattleEngine.MODE_DEFENSE_POSITION,
			"defense_turns": 3,
			"defense_slot": 1,
			"defense_health": 10,
			"player_slots_count": 3,
			"enemy_slots_count": 3
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_not_null(engine.player_slots[1])
	assert_eq(int(Dictionary(engine.player_slots[1]).get("attack", 0)), 0)
	assert_eq(int(Dictionary(engine.player_slots[1]).get("health", 0)), 10)
	engine.end_player_turn()
	engine.end_player_turn()
	engine.end_player_turn()
	assert_eq(engine.outcome, "vitoria")

func test_battle_engine_survive_turns_wins_after_three_turns() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_sobreviver_turnos",
			"display_name": "Teste sobreviver turnos",
			"mode": BattleEngine.MODE_SURVIVE_TURNS,
			"survive_turns": 3,
			"player_slots_count": 3,
			"enemy_slots_count": 3
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.end_player_turn()
	engine.end_player_turn()
	engine.end_player_turn()
	assert_eq(engine.outcome, "vitoria")

func test_battle_engine_duel_wins_by_direct_damage_to_enemy_hero() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["elemental_agil", "elemental_agil", "elemental_agil", "elemental_agil", "elemental_agil"], {
		"encounter": {
			"id": "test_duelo",
			"display_name": "Teste duelo",
			"mode": BattleEngine.MODE_DUEL,
			"enemy_health": 2,
			"player_slots_count": 3,
			"enemy_slots_count": 3
		},
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	var result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	engine.end_player_turn()
	assert_eq(engine.enemy_health, 0)
	assert_eq(engine.outcome, "vitoria")

func test_battle_engine_waves_spawn_sequentially() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_spell_dano_maior", "arcano_spell_dano_maior", "arcano_spell_dano_maior", "arcano_spell_dano_maior", "arcano_spell_dano_maior"], {
		"encounter_id": "ondas_iniciais",
		"class_id": "arcano",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	assert_eq(engine.wave_index, 1)
	assert_not_null(engine.enemy_slots[0])
	engine._damage_slot(BattleEngine.ENEMY_ID, 0, 99)
	engine._damage_slot(BattleEngine.ENEMY_ID, 1, 99)
	engine.end_player_turn()
	assert_eq(engine.wave_index, 2)
	assert_not_null(engine.enemy_slots[0])

func test_battle_engine_summoner_boss_invokes_over_time() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ContentLibrary.get_starter_deck_ids(), {"encounter_id": "chefe_invocador"})
	assert_eq(engine.enemy_health, 14)
	engine.end_player_turn()
	assert_eq(str(Dictionary(engine.enemy_slots[0]).get("card_id", "")), "elemental_menor")
	engine.end_player_turn()
	assert_eq(str(Dictionary(engine.enemy_slots[1]).get("card_id", "")), "elemental_medio")

func test_battle_engine_uses_local_slot_count_contract_without_legacy_board_terms() -> void:
	var text: String = FileAccess.get_file_as_string(ProjectSettings.globalize_path("res://battle/battle_engine.gd"))
	for forbidden: String in ["_attack_routes", "terrain", "elevation", "neutral_slots", "NEUTRAL_ID"]:
		assert_false(text.contains(forbidden), "BattleEngine still contains inherited term: %s" % forbidden)

func test_ship_hub_scene_exposes_classes_and_paid_heal() -> void:
	var hub = await _instantiate_scene("res://modes/ship_hub/ship_hub.tscn")
	assert_not_null(hub.find_child("ShipHubVisualBackground", true, false))
	assert_not_null(hub.find_child("ShipHubHotspots", true, false))
	assert_not_null(hub.find_child("ShipHubHotspot_command_station", true, false))
	assert_not_null(hub.find_child("ShipHubHotspot_mission_map_console", true, false))
	assert_not_null(hub.find_child("ShipHubHotspot_deck_system", true, false))
	assert_not_null(hub.find_child("ShipHubHotspot_soul_engine", true, false))
	assert_not_null(hub.find_child("ShipHubStatusScroll", true, false))
	assert_not_null(hub.find_child("ShipHubClass_arcano", true, false))
	assert_not_null(hub.find_child("ShipHubClass_invocador", true, false))
	assert_not_null(hub.find_child("ShipHubClass_necromante", true, false))
	assert_not_null(hub.find_child("ShipHubPaidHealButton", true, false))
	var start_button = hub.find_child("ShipHubStartRunButton", true, false)
	var class_button = hub.find_child("ShipHubClass_arcano", true, false)
	assert_true(start_button.disabled)
	class_button.pressed.emit()
	await get_tree().process_frame
	assert_false(start_button.disabled)
	start_button.pressed.emit()
	await get_tree().process_frame
	assert_eq(RunSession.selected_class_id, "arcano")
	hub.queue_free()
	await get_tree().process_frame

func test_run_map_scene_selects_available_wave_path_after_first_win() -> void:
	_start_run()
	RunSession.record_battle_result("n01_pouso_elemental", "vitoria", 14)
	var run_map = await _instantiate_scene("res://modes/run_map/run_map.tscn")
	assert_not_null(run_map.find_child("RunMapVisualBackground", true, false))
	assert_not_null(run_map.find_child("RunMapRouteArea", true, false))
	assert_not_null(run_map.find_child("RunMapRouteLines", true, false))
	assert_not_null(run_map.find_child("RunMapNodes", true, false))
	var waves_node = run_map.find_child("RunMapNode_n02_ondas_iniciais", true, false)
	assert_not_null(waves_node)
	assert_false(waves_node.disabled)
	assert_null(run_map.find_child("RunMapNode_s01_incursao_lateral", true, false))
	waves_node.pressed.emit()
	await get_tree().process_frame
	assert_eq(RunSession.current_node_id, "n02_ondas_iniciais")
	run_map.queue_free()
	await get_tree().process_frame

func test_battle_scene_passes_run_class_to_engine() -> void:
	_start_run()
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	assert_eq(battle.engine.selected_class_id, "arcano")
	assert_eq(battle.engine.mana_per_turn, 2)
	assert_eq(battle.engine.player_health, 20)
	assert_not_null(battle.find_child("BattleClassActiveTile", true, false))
	assert_false(battle.find_child("BattleClassActiveTile", true, false).visible)
	assert_not_null(battle.find_child("BattleVisualBackground", true, false))
	assert_not_null(battle.find_child("BattleTopStatusBar", true, false))
	assert_not_null(battle.find_child("BattleBoardPanel", true, false))
	assert_not_null(battle.find_child("BattleHandPanel", true, false))
	assert_not_null(battle.find_child("BattleHandCard0", true, false))
	assert_not_null(battle.find_child("PlayerSlot0", true, false))
	assert_not_null(battle.find_child("EnemySlot0", true, false))
	assert_not_null(battle.find_child("FieldCardArtArea", true, false))
	assert_not_null(battle.find_child("FieldCardCost", true, false))
	assert_not_null(battle.find_child("FieldCardAttack", true, false))
	assert_not_null(battle.find_child("FieldCardHealth", true, false))
	assert_not_null(battle.find_child("BattleCardPreview", true, false))
	assert_not_null(battle.find_child("BattleLogTicker", true, false))
	assert_not_null(battle.find_child("BattleLogHistoryButton", true, false))
	assert_not_null(battle.find_child("BattleLogScroll", true, false))
	battle.queue_free()
	await get_tree().process_frame

func test_battle_card_token_uses_portrait_visual_contract() -> void:
	var token: BattleCardToken = BattleCardToken.new()
	token.setup("arcano_spell_dano", 0, true, false)
	add_child(token)
	await get_tree().process_frame
	assert_eq(token.custom_minimum_size, Vector2(126, 188))
	assert_not_null(token.find_child("BattleCardArtArea", true, false))
	assert_not_null(token.find_child("BattleCardCost", true, false))
	assert_eq(token.find_child("BattleCardCost", true, false).text, "1")
	assert_null(token.find_child("BattleCardAttack", true, false))
	assert_null(token.find_child("BattleCardHealth", true, false))
	assert_not_null(token.find_child("BattleCardRulesText", true, false))
	assert_not_null(token.find_child("BattleCardFrameOverlay", true, false))
	assert_string_contains(token.find_child("BattleCardRulesText", true, false).text, "Causa 1 de dano")
	token.queue_free()
	await get_tree().process_frame

	var unsafe_token: BattleCardToken = BattleCardToken.new()
	unsafe_token.setup("invocador_protecao", 0, true, false)
	add_child(unsafe_token)
	await get_tree().process_frame
	assert_null(unsafe_token.find_child("BattleCardFrameOverlay", true, false))
	assert_eq(unsafe_token.find_child("BattleCardCost", true, false).text, "1")
	assert_eq(unsafe_token.find_child("BattleCardAttack", true, false).text, "1")
	assert_eq(unsafe_token.find_child("BattleCardHealth", true, false).text, "4")
	unsafe_token.queue_free()
	await get_tree().process_frame

func test_battle_slot_control_renders_field_card_with_current_floating_values() -> void:
	var slot: BattleSlotControl = BattleSlotControl.new()
	slot.setup(BattleEngine.PLAYER_ID, 0, {
		"owner": BattleEngine.PLAYER_ID,
		"card_id": "invocador_protecao",
		"name": "Guarda Vinculado",
		"attack": 5,
		"health": 2,
		"max_health": 5,
		"ready": true,
		"keywords": ["iniciativa"],
		"iniciativa": true,
		"regeneracao": false,
		"slow_turns": 0,
		"confusion_turns": 0,
		"temporary_attack_bonus": 3
	}, {"is_empty": false})
	add_child(slot)
	await get_tree().process_frame
	assert_not_null(slot.find_child("FieldCardArtArea", true, false))
	assert_eq(slot.find_child("FieldCardCost", true, false).text, "1")
	assert_eq(slot.find_child("FieldCardAttack", true, false).text, "5")
	assert_eq(slot.find_child("FieldCardHealth", true, false).text, "2")
	slot.queue_free()
	await get_tree().process_frame

func test_battle_slot_control_renders_defense_objective_as_card_socket() -> void:
	var slot: BattleSlotControl = BattleSlotControl.new()
	slot.setup(BattleEngine.PLAYER_ID, 1, {
		"owner": BattleEngine.PLAYER_ID,
		"card_id": "",
		"name": "Objetivo de Defesa",
		"attack": 0,
		"health": 7,
		"max_health": 10,
		"ready": false,
		"keywords": [],
		"objective": true
	}, {"is_empty": false})
	add_child(slot)
	await get_tree().process_frame
	assert_not_null(slot.find_child("FieldObjectiveLabel", true, false))
	assert_eq(slot.find_child("FieldCardAttack", true, false).text, "0")
	assert_eq(slot.find_child("FieldCardHealth", true, false).text, "7")
	assert_null(slot.find_child("FieldCardCost", true, false))
	slot.queue_free()
	await get_tree().process_frame

func test_battle_scene_drop_plays_cards_on_explicit_slots() -> void:
	_start_run()
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.start_battle(ContentLibrary.get_catalog(), ["invocador_protecao", "invocador_voadora", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 2,
		"player_health": 20,
		"shuffle_deck": false
	})
	battle._refresh()
	battle._on_slot_target_dropped({"kind": "battle_card", "hand_index": 0, "card_id": "invocador_protecao"}, BattleEngine.PLAYER_ID, 2)
	assert_eq(str(Dictionary(battle.engine.player_slots[2]).get("card_id", "")), "invocador_protecao")
	battle._on_slot_target_dropped({"kind": "battle_card", "hand_index": 0, "card_id": "invocador_voadora"}, BattleEngine.PLAYER_ID, 2)
	assert_eq(str(Dictionary(battle.engine.player_slots[2]).get("card_id", "")), "invocador_voadora")
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_necromancer_modal_exposes_ritual_choices() -> void:
	_start_class_run("necromante")
	RunSession.class_active_unlocked = true
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.class_active_unlocked = true
	battle.engine.ashes = 6
	battle.engine.discard.append("necro_reanimavel")
	battle._refresh()
	battle._open_necromancer_modal()
	assert_true(battle.find_child("NecromancerChoiceModal", true, false).visible)
	assert_not_null(battle.find_child("NecroChoice_%s" % BattleEngine.NECRO_CHOICE_SLOW, true, false))
	assert_not_null(battle.find_child("NecroChoice_%s" % BattleEngine.NECRO_CHOICE_ROT, true, false))
	assert_not_null(battle.find_child("NecroChoice_%s" % BattleEngine.NECRO_CHOICE_CONFUSION, true, false))
	assert_not_null(battle.find_child("NecroChoice_%s" % BattleEngine.NECRO_CHOICE_REVIVE_ONE_ONE, true, false))
	assert_not_null(battle.find_child("NecroChoice_%s" % BattleEngine.NECRO_CHOICE_REVIVE_FULL, true, false))
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_preview_receives_full_card_data() -> void:
	_start_run()
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle._show_preview_now(battle._card_preview_data("arcano_spell_dano", {}))
	assert_true(battle.find_child("BattleCardPreview", true, false).visible)
	assert_eq(battle.find_child("BattleCardPreviewTitle", true, false).text, "Pulso de Fluxo")
	assert_string_contains(battle.find_child("BattleCardPreviewBody", true, false).text, "Causa 1 de dano")
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_field_preview_reports_current_stats_against_base() -> void:
	_start_run()
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	var preview: Dictionary = battle._card_preview_data("invocador_protecao", {
		"card_id": "invocador_protecao",
		"attack": 5,
		"health": 2,
		"max_health": 5,
		"temporary_attack_bonus": 3,
		"slow_turns": 1,
		"confusion_turns": 0,
		"regeneracao": false
	})
	assert_string_contains(str(preview.get("state", "")), "ATK atual 5 (base 1)")
	assert_string_contains(str(preview.get("state", "")), "HP atual 2/5 (base 4)")
	assert_string_contains(str(preview.get("state", "")), "Bonus temporario +3 ATK")
	assert_string_contains(str(preview.get("state", "")), "Lentidao 1")
	battle.queue_free()
	await get_tree().process_frame

func test_boot_scene_exposes_entry_to_ship_hub() -> void:
	var boot = await _instantiate_scene("res://modes/boot/boot.tscn")
	var found_hub_entry: bool = false
	for node: Node in _collect_descendants(boot):
		if node is Button and String(node.text).contains("Ponte de Comando"):
			found_hub_entry = true
	assert_true(found_hub_entry)
	boot.queue_free()
	await get_tree().process_frame

func test_runtime_contract_does_not_use_old_novice_id() -> void:
	var root_path: String = ProjectSettings.globalize_path("res://")
	var offenders: Array[String] = []
	_collect_text_references(root_path, "novato_draxos", offenders)
	assert_eq(offenders, [])

func test_project_does_not_reference_rpg_turnos_world_root() -> void:
	var root_path: String = ProjectSettings.globalize_path("res://")
	var offenders: Array[String] = []
	_collect_text_references(root_path, "res://modes/world/world_root.gd", offenders)
	assert_eq(offenders, [])

func _start_run(seed: int = 0) -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", seed)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func _start_class_run(class_id: String, seed: int = 0) -> void:
	var result: Dictionary = RunSession.start_class_run(class_id, seed)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func _instantiate_scene(path: String):
	var packed_scene: PackedScene = load(path)
	assert_not_null(packed_scene)
	var instance = packed_scene.instantiate()
	assert_not_null(instance)
	add_child(instance)
	await get_tree().process_frame
	return instance

func _find_run_node(nodes: Array, node_id: String) -> Dictionary:
	for node: Variant in nodes:
		if typeof(node) == TYPE_DICTIONARY and str(Dictionary(node).get("id", "")) == node_id:
			return Dictionary(node)
	return {}

func _has_target(targets: Array[Dictionary], target: Dictionary) -> bool:
	for option: Dictionary in targets:
		if str(option.get("owner", "")) == str(target.get("owner", "")) and int(option.get("slot", -999)) == int(target.get("slot", -999)) and bool(option.get("hero", false)) == bool(target.get("hero", false)):
			return true
	return false

func _choice_enabled(choices: Array[Dictionary], choice_id: String) -> bool:
	for choice: Dictionary in choices:
		if str(choice.get("id", "")) == choice_id:
			return bool(choice.get("enabled", false))
	return false

func _collect_descendants(root: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child: Node in root.get_children():
		result.append(child)
		result.append_array(_collect_descendants(child))
	return result

func _collect_text_references(path: String, pattern: String, offenders: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var full_path: String = path.path_join(entry)
		if dir.current_is_dir():
			_collect_text_references(full_path, pattern, offenders)
		elif entry.get_extension() in ["gd", "json", "md", "godot", "tscn", "tres"]:
			if entry == "test_bootstrap_contract.gd":
				entry = dir.get_next()
				continue
			var text: String = FileAccess.get_file_as_string(full_path)
			if text.contains(pattern):
				offenders.append(full_path)
		entry = dir.get_next()
	dir.list_dir_end()
