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
	assert_gt(catalog.starter_deck_ids.size(), 0)
	for card_id: String in Array(catalog.starter_deck_ids):
		assert_not_null(catalog.find_card(card_id), "Missing card: %s" % card_id)
	assert_false(catalog.find_encounter("pouso_elemental").is_empty())
	assert_true(catalog.find_encounter("emboscada_na_ponte").is_empty())

func test_encounters_use_simple_slot_count_contract() -> void:
	for encounter: Dictionary in ContentLibrary.get_all_encounters():
		assert_gt(int(encounter.get("player_slots_count", 0)), 0)
		assert_gt(int(encounter.get("enemy_slots_count", 0)), 0)
		assert_true([
			"limpar_mesa",
			"duelo",
			"ondas",
			"defesa_posicao",
			"sobreviver_turnos",
			"chefe_summoner"
		].has(str(encounter.get("mode", ""))))

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
	_collect_world_root_references(root_path, offenders)
	assert_eq(offenders, [])

func _collect_world_root_references(path: String, offenders: Array[String]) -> void:
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
			_collect_world_root_references(full_path, offenders)
		elif entry.get_extension() in ["gd", "json", "md", "godot", "tscn"]:
			if entry == "test_bootstrap_contract.gd":
				entry = dir.get_next()
				continue
			var text: String = FileAccess.get_file_as_string(full_path)
			if text.contains("res://modes/world/world_root.gd"):
				offenders.append(full_path)
		entry = dir.get_next()
	dir.list_dir_end()
