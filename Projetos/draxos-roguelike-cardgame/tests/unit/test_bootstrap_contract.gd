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

func test_catalog_minimum_is_local_and_valid() -> void:
	var catalog = ContentLibrary.get_catalog()
	assert_not_null(catalog)
	assert_eq(catalog.default_encounter_id, "pouso_elemental")
	assert_eq(catalog.player_hero.id, "comandante_draxos")
	assert_eq(catalog.player_hero.display_name, "Comandante Draxos")
	assert_gt(catalog.starter_deck_ids.size(), 0)
	for card_id: String in Array(catalog.starter_deck_ids):
		assert_not_null(catalog.find_card(card_id), "Missing card: %s" % card_id)
	assert_false(catalog.find_encounter("pouso_elemental").is_empty())
	assert_true(catalog.find_encounter("emboscada_na_ponte").is_empty())

func test_encounters_use_simple_slot_count_contract() -> void:
	for encounter: Dictionary in ContentLibrary.get_all_encounters():
		assert_gt(int(encounter.get("player_slots_count", 0)), 0)
		assert_gt(int(encounter.get("enemy_slots_count", 0)), 0)
		assert_true(["small", "medium", "elite_optional", "boss"].has(str(encounter.get("tier", ""))))
		assert_true(["prefilled_board", "waves", "scripted_boss", "player_like"].has(str(encounter.get("enemy_director", ""))))
		var expected_reward: Dictionary = _soul_reward_band(str(encounter.get("tier", "")))
		var reward: Dictionary = Dictionary(encounter.get("soul_reward", {}))
		assert_eq(int(reward.get("min", 0)), int(expected_reward.get("min", -1)))
		assert_eq(int(reward.get("max", 0)), int(expected_reward.get("max", -1)))
		assert_true([
			"limpar_mesa",
			"duelo",
			"ondas",
			"defesa_posicao",
			"sobreviver_turnos",
			"chefe_summoner"
		].has(str(encounter.get("mode", ""))))

func test_run_map_has_mainline_and_optional_sidequest_contract() -> void:
	var run_map: Dictionary = ContentLibrary.get_run_map()
	var nodes: Array = Array(run_map.get("nodes", []))
	assert_gt(nodes.size(), 0)
	assert_false(_find_run_node(nodes, "n01_pouso_elemental").is_empty())
	assert_false(_find_run_node(nodes, "s01_incursao_lateral").is_empty())
	assert_false(_find_run_node(nodes, "n02_guardiao_do_conduto").is_empty())
	assert_false(_find_run_node(nodes, "n03_chefe_invocador").is_empty())
	var sidequest: Dictionary = _find_run_node(nodes, "s01_incursao_lateral")
	assert_eq(str(sidequest.get("kind", "")), "sidequest")
	assert_eq(str(sidequest.get("encounter_id", "")), "incursao_lateral")
	var next_mainline: Dictionary = _find_run_node(nodes, "n02_guardiao_do_conduto")
	assert_eq(str(next_mainline.get("kind", "")), "mainline")
	assert_false(Array(next_mainline.get("available_after", [])).has("s01_incursao_lateral"))

func test_ship_hub_scene_exists_and_exposes_placeholder_regions() -> void:
	var packed_scene: PackedScene = load("res://modes/ship_hub/ship_hub.tscn")
	assert_not_null(packed_scene)
	var hub = packed_scene.instantiate()
	assert_not_null(hub)
	add_child(hub)
	await get_tree().process_frame
	for region_id: String in [
		"command_station",
		"grand_master_channel",
		"subordinate_station",
		"mission_map_console",
		"deck_system",
		"soul_engine"
	]:
		assert_not_null(hub.find_child("Region_%s" % region_id, true, false), "Missing hub region: %s" % region_id)
	assert_not_null(hub.find_child("ShipHubStartRunButton", true, false))
	assert_not_null(hub.find_child("ShipHubOpenRunMapButton", true, false))
	assert_not_null(hub.find_child("ShipHubBackToBootButton", true, false))
	hub.queue_free()
	await get_tree().process_frame

func test_run_map_scene_exposes_nodes_and_selects_available_node() -> void:
	RunSession.start_empty_run(99)
	var packed_scene: PackedScene = load("res://modes/run_map/run_map.tscn")
	assert_not_null(packed_scene)
	var run_map = packed_scene.instantiate()
	assert_not_null(run_map)
	add_child(run_map)
	await get_tree().process_frame
	var first_node = run_map.find_child("RunMapNode_n01_pouso_elemental", true, false)
	var sidequest_node = run_map.find_child("RunMapNode_s01_incursao_lateral", true, false)
	var next_mainline_node = run_map.find_child("RunMapNode_n02_guardiao_do_conduto", true, false)
	assert_not_null(first_node)
	assert_not_null(sidequest_node)
	assert_not_null(next_mainline_node)
	assert_false(first_node.disabled)
	assert_true(sidequest_node.disabled)
	assert_true(next_mainline_node.disabled)
	first_node.pressed.emit()
	await get_tree().process_frame
	assert_eq(RunSession.current_node_id, "n01_pouso_elemental")
	assert_not_null(run_map.find_child("RunMapFutureBattleButton", true, false))
	assert_not_null(run_map.find_child("RunMapBackToShipHubButton", true, false))
	run_map.queue_free()
	await get_tree().process_frame

func test_run_session_unlocks_nodes_after_completion_placeholder() -> void:
	RunSession.start_empty_run()
	var nodes: Array = Array(ContentLibrary.get_run_map().get("nodes", []))
	var first_node: Dictionary = _find_run_node(nodes, "n01_pouso_elemental")
	var sidequest: Dictionary = _find_run_node(nodes, "s01_incursao_lateral")
	assert_true(RunSession.is_node_available(first_node))
	assert_false(RunSession.is_node_available(sidequest))
	RunSession.mark_node_completed("n01_pouso_elemental")
	assert_true(RunSession.is_node_available(sidequest))

func test_battle_engine_uses_local_slot_count_contract_without_legacy_board_terms() -> void:
	var text: String = FileAccess.get_file_as_string(ProjectSettings.globalize_path("res://battle/battle_engine.gd"))
	for forbidden: String in ["_attack_routes", "terrain", "elevation", "neutral_slots", "NEUTRAL_ID"]:
		assert_false(text.contains(forbidden), "BattleEngine still contains inherited term: %s" % forbidden)

func test_battle_engine_starts_from_encounter_slot_counts() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), ContentLibrary.get_starter_deck_ids(), {"encounter_id": "guardiao_do_conduto"})
	var state: Dictionary = engine.get_state()
	assert_eq(Array(state.get("player_slots", [])).size(), 4)
	assert_eq(Array(state.get("enemy_slots", [])).size(), 4)
	assert_false(state.has("neutral_slots"))
	assert_eq(str(state.get("mode", "")), "duelo")

func test_battle_engine_draws_on_play_and_sacrifices_occupied_slot() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [
		"adepto_vazio",
		"sentinela_eter",
		"pulso_astral",
		"adepto_vazio",
		"sentinela_eter",
		"pulso_astral",
		"adepto_vazio"
	], {
		"encounter_id": "pouso_elemental",
		"starting_enemy_slots": [{"slot": 0, "card_id": "adepto_vazio"}]
	})
	var first_result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(first_result.get("ok", false)), str(first_result.get("message", "")))
	assert_eq(engine.hand.size(), 5)
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "adepto_vazio")
	var second_result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(second_result.get("ok", false)), str(second_result.get("message", "")))
	assert_eq(engine.hand.size(), 5)
	assert_eq(str(Dictionary(engine.player_slots[0]).get("card_id", "")), "sentinela_eter")
	assert_true(engine.discard.has("adepto_vazio"))

func test_battle_engine_attack_priority_uses_front_then_left_to_right() -> void:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [
		"adepto_vazio",
		"pulso_astral",
		"pulso_astral",
		"pulso_astral",
		"pulso_astral",
		"pulso_astral"
	], {
		"encounter_id": "pouso_elemental",
		"starting_enemy_slots": [{"slot": 1, "card_id": "adepto_vazio"}]
	})
	var play_result: Dictionary = engine.play_card_from_hand(0, {"slot": 0})
	assert_true(bool(play_result.get("ok", false)), str(play_result.get("message", "")))
	var options: Array[Dictionary] = engine.get_attack_options(BattleEngine.PLAYER_ID, 0)
	assert_eq(options.size(), 1)
	assert_eq(str(options[0].get("owner", "")), BattleEngine.ENEMY_ID)
	assert_eq(int(options[0].get("slot", -1)), 1)
	var turn_result: Dictionary = engine.end_player_turn()
	assert_true(bool(turn_result.get("ok", false)), str(turn_result.get("message", "")))
	assert_eq(engine.enemy_slots[1], null)
	assert_eq(engine.outcome, "vitoria")

func test_boot_scene_exposes_entry_to_ship_hub() -> void:
	var packed_scene: PackedScene = load("res://modes/boot/boot.tscn")
	assert_not_null(packed_scene)
	var boot = packed_scene.instantiate()
	assert_not_null(boot)
	add_child(boot)
	await get_tree().process_frame
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

func test_run_session_starts_empty() -> void:
	var snapshot: Dictionary = RunSession.snapshot()
	assert_false(bool(snapshot.get("active", true)))
	assert_eq(Array(snapshot.get("current_deck_ids", [])).size(), 0)
	assert_eq(str(snapshot.get("current_node_id", "x")), "")
	assert_eq(int(snapshot.get("current_health", -1)), 0)

func test_run_session_can_start_empty_run() -> void:
	RunSession.start_empty_run(42)
	var snapshot: Dictionary = RunSession.snapshot()
	assert_true(bool(snapshot.get("active", false)))
	assert_eq(int(snapshot.get("run_seed", 0)), 42)
	assert_eq(Array(snapshot.get("rewards_pending", [])).size(), 0)

func test_project_does_not_reference_rpg_turnos_world_root() -> void:
	var root_path: String = ProjectSettings.globalize_path("res://")
	var offenders: Array[String] = []
	_collect_text_references(root_path, "res://modes/world/world_root.gd", offenders)
	assert_eq(offenders, [])

func _find_run_node(nodes: Array, node_id: String) -> Dictionary:
	for node: Variant in nodes:
		if typeof(node) == TYPE_DICTIONARY and str(Dictionary(node).get("id", "")) == node_id:
			return Dictionary(node)
	return {}

func _soul_reward_band(tier: String) -> Dictionary:
	match tier:
		"small":
			return {"min": 4, "max": 6}
		"medium":
			return {"min": 7, "max": 10}
		"elite_optional":
			return {"min": 11, "max": 16}
		"boss":
			return {"min": 18, "max": 25}
	return {}

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
