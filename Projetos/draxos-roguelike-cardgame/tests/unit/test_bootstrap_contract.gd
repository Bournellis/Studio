extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))
	ContentLibrary.reload()

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
		assert_eq(int(class_option.get("starting_mana", 0)), 3)
		assert_eq(int(class_option.get("starting_health", 0)), 20)
		assert_eq(Array(class_option.get("starter_deck", [])).size(), 15)
		assert_false(str(class_option.get("passive_id", "")).is_empty())
		assert_false(str(class_option.get("active_id", "")).is_empty())

func test_class_decks_reference_existing_cards() -> void:
	var catalog = ContentLibrary.get_catalog()
	for class_option: Dictionary in catalog.class_options:
		for card_id: String in Array(class_option.get("starter_deck", [])):
			assert_not_null(catalog.find_card(card_id), "Missing card %s for %s" % [card_id, str(class_option.get("id", ""))])

func test_first_two_encounters_match_mockup_contract() -> void:
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

func test_run_map_exposes_mainline_waves_and_optional_sidequest() -> void:
	var nodes: Array = Array(ContentLibrary.get_run_map().get("nodes", []))
	assert_false(_find_run_node(nodes, "n01_pouso_elemental").is_empty())
	assert_false(_find_run_node(nodes, "n02_ondas_iniciais").is_empty())
	assert_false(_find_run_node(nodes, "s01_incursao_lateral").is_empty())
	var waves_node: Dictionary = _find_run_node(nodes, "n02_ondas_iniciais")
	assert_eq(str(waves_node.get("kind", "")), "mainline")
	assert_eq(str(waves_node.get("encounter_id", "")), "ondas_iniciais")
	assert_true(Array(waves_node.get("available_after", [])).has("n01_pouso_elemental"))

func test_run_session_starts_arcano_run_with_slice_stats() -> void:
	var result: Dictionary = RunSession.start_class_run("arcano", 77)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_true(RunSession.active)
	assert_eq(RunSession.selected_class_id, "arcano")
	assert_eq(RunSession.selected_class_display_name, "Arcano")
	assert_eq(RunSession.current_health, 20)
	assert_eq(RunSession.max_health, 20)
	assert_eq(RunSession.max_mana, 3)
	assert_eq(RunSession.soul_total, 0)
	assert_eq(RunSession.current_deck_ids.size(), 15)

func test_run_session_records_souls_and_pending_reward() -> void:
	_start_run()
	RunSession.record_battle_result("n01_pouso_elemental", "vitoria", 14)
	assert_eq(RunSession.current_health, 14)
	assert_eq(RunSession.soul_total, 4)
	assert_eq(RunSession.rewards_pending.size(), 1)
	assert_true(RunSession.completed_node_ids.has("n01_pouso_elemental"))

func test_run_session_paid_heal_spends_souls() -> void:
	_start_run()
	RunSession.record_battle_result("n01_pouso_elemental", "vitoria", 14)
	RunSession.soul_total = 6
	var result: Dictionary = RunSession.buy_paid_heal()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.soul_total, 1)
	assert_eq(RunSession.current_health, 19)

func test_reward_adds_class_card_instead_of_old_placeholder() -> void:
	_start_run()
	RunSession.record_battle_result("n01_pouso_elemental", "vitoria", 14)
	var starting_size: int = RunSession.current_deck_ids.size()
	var result: Dictionary = RunSession.apply_placeholder_reward(RunSession.REWARD_ADD_PULSO_ASTRAL)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_eq(RunSession.current_deck_ids.size(), starting_size + 1)
	assert_eq(RunSession.current_deck_ids[RunSession.current_deck_ids.size() - 1], "arcano_spell_dano")

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
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 1})
	engine.play_card_from_hand(0, {"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_true(engine.can_use_class_active())
	var result: Dictionary = engine.use_class_active({"owner": BattleEngine.ENEMY_ID, "slot": 1})
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	assert_false(engine.can_use_class_active())

func test_battle_engine_target_helpers_hide_heroes_in_board_modes() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["invocador_protecao", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "arcano",
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
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
		"mana_per_turn": 3,
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

func test_battle_engine_waves_spawn_sequentially() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ["arcano_spell_dano_maior", "arcano_spell_dano_maior", "arcano_spell_dano_maior", "arcano_spell_dano_maior", "arcano_spell_dano_maior"], {
		"encounter_id": "ondas_iniciais",
		"class_id": "arcano",
		"mana_per_turn": 3,
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
	assert_eq(engine.enemy_health, 12)
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
	var waves_node = run_map.find_child("RunMapNode_n02_ondas_iniciais", true, false)
	var side_node = run_map.find_child("RunMapNode_s01_incursao_lateral", true, false)
	assert_not_null(waves_node)
	assert_not_null(side_node)
	assert_false(waves_node.disabled)
	assert_false(side_node.disabled)
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
	assert_eq(battle.engine.mana_per_turn, 3)
	assert_eq(battle.engine.player_health, 20)
	assert_not_null(battle.find_child("BattleClassActiveTile", true, false))
	assert_not_null(battle.find_child("BattleHandCard0", true, false))
	assert_not_null(battle.find_child("PlayerSlot0", true, false))
	assert_not_null(battle.find_child("EnemySlot0", true, false))
	assert_not_null(battle.find_child("BattleCardPreview", true, false))
	assert_not_null(battle.find_child("BattleLogScroll", true, false))
	battle.queue_free()
	await get_tree().process_frame

func test_battle_scene_drop_plays_cards_on_explicit_slots() -> void:
	_start_run()
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
	battle.engine.start_battle(ContentLibrary.get_catalog(), ["invocador_protecao", "invocador_voadora", "arcano_spell_dano", "arcano_spell_dano", "arcano_spell_dano"], {
		"encounter_id": "pouso_elemental",
		"class_id": "invocador",
		"mana_per_turn": 3,
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
	RunSession.select_node("n01_pouso_elemental")
	var battle = await _instantiate_scene("res://modes/battle/battle.tscn")
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
