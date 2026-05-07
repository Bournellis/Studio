extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
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
