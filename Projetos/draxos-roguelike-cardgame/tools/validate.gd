extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_validation()
	quit(exit_code)

func _run_validation() -> int:
	print("[validate] generating JSON-driven slice catalog")
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[validate] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1

	print("[validate] generating playable scenes")
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[validate] %s" % str(scene_result.get("message", "Scene generation failed.")))
		return 1

	print("[validate] checking bootstrap contract")
	var contract_result: Dictionary = _validate_contract()
	if not bool(contract_result.get("ok", false)):
		printerr("[validate] %s" % str(contract_result.get("message", "Contract validation failed.")))
		return 1

	print("[validate] running GUT")
	var gut_exit_code: int = await _run_gut()
	if gut_exit_code != 0:
		printerr("[validate] GUT failed with exit code %d." % gut_exit_code)
		return gut_exit_code

	print("[validate] bootstrap scaffold is not a playable slice yet")
	print("[validate] success")
	return 0

func _validate_contract() -> Dictionary:
	var catalog = load("res://data/generated/slice_catalog.tres")
	if catalog == null:
		return {"ok": false, "message": "Missing generated slice catalog."}
	if catalog.player_hero == null or catalog.player_hero.max_health <= 0:
		return {"ok": false, "message": "Player hero must exist for the bootstrap catalog."}
	if catalog.player_hero.id != "comandante_draxos":
		return {"ok": false, "message": "Player hero must be the Draxos commander."}
	if catalog.starter_deck_ids.size() < 1:
		return {"ok": false, "message": "Starter deck must have placeholder cards."}
	for card_id: String in Array(catalog.starter_deck_ids):
		if catalog.find_card(card_id) == null:
			return {"ok": false, "message": "Starter deck references missing card %s." % card_id}
	if catalog.find_encounter("pouso_elemental").is_empty():
		return {"ok": false, "message": "Pouso Elemental encounter must exist."}
	if catalog.find_encounter("chefe_invocador").is_empty():
		return {"ok": false, "message": "Chefe Invocador encounter must exist."}
	for encounter: Dictionary in catalog.encounters:
		if int(encounter.get("player_slots_count", 0)) <= 0:
			return {"ok": false, "message": "Encounter %s needs player_slots_count." % str(encounter.get("id", ""))}
		if int(encounter.get("enemy_slots_count", 0)) <= 0:
			return {"ok": false, "message": "Encounter %s needs enemy_slots_count." % str(encounter.get("id", ""))}
		var encounter_contract_result: Dictionary = _validate_encounter_contract(encounter)
		if not bool(encounter_contract_result.get("ok", false)):
			return encounter_contract_result
	for path: String in [
		"res://modes/boot/boot.tscn",
		"res://modes/ship_hub/ship_hub.tscn",
		"res://modes/run_map/run_map.tscn"
	]:
		if load(path) == null:
			return {"ok": false, "message": "Missing generated scene %s." % path}
	if str(catalog.run_map.get("id", "")) == "":
		return {"ok": false, "message": "Run map placeholder must exist."}
	var run_map_result: Dictionary = _validate_run_map_contract(Dictionary(catalog.run_map))
	if not bool(run_map_result.get("ok", false)):
		return run_map_result
	return {"ok": true, "message": "Bootstrap contract is valid."}

func _validate_encounter_contract(encounter: Dictionary) -> Dictionary:
	var encounter_id: String = str(encounter.get("id", ""))
	var tier: String = str(encounter.get("tier", ""))
	if not ["small", "medium", "elite_optional", "boss"].has(tier):
		return {"ok": false, "message": "Encounter %s has invalid tier." % encounter_id}
	if not ["prefilled_board", "waves", "scripted_boss", "player_like"].has(str(encounter.get("enemy_director", ""))):
		return {"ok": false, "message": "Encounter %s has invalid enemy_director." % encounter_id}
	var reward: Dictionary = Dictionary(encounter.get("soul_reward", {}))
	var min_reward: int = int(reward.get("min", 0))
	var max_reward: int = int(reward.get("max", 0))
	var expected: Dictionary = _soul_reward_band(tier)
	if min_reward != int(expected.get("min", -1)) or max_reward != int(expected.get("max", -1)):
		return {"ok": false, "message": "Encounter %s has invalid soul_reward for tier %s." % [encounter_id, tier]}
	return {"ok": true, "message": "Encounter contract is valid."}

func _validate_run_map_contract(run_map: Dictionary) -> Dictionary:
	var nodes: Array = Array(run_map.get("nodes", []))
	if nodes.size() < 1:
		return {"ok": false, "message": "Run map needs placeholder nodes."}
	var has_mainline: bool = false
	var has_sidequest: bool = false
	for node: Variant in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			return {"ok": false, "message": "Run map nodes must be dictionaries."}
		var node_data: Dictionary = Dictionary(node)
		var kind: String = str(node_data.get("kind", ""))
		if not ["mainline", "sidequest"].has(kind):
			return {"ok": false, "message": "Run map node %s has invalid kind." % str(node_data.get("id", ""))}
		if str(node_data.get("id", "")) == "":
			return {"ok": false, "message": "Run map node needs id."}
		if str(node_data.get("encounter_id", "")) == "":
			return {"ok": false, "message": "Run map node %s needs encounter_id." % str(node_data.get("id", ""))}
		if kind == "mainline":
			has_mainline = true
		if kind == "sidequest":
			has_sidequest = true
	if not has_mainline or not has_sidequest:
		return {"ok": false, "message": "Run map must include mainline and sidequest nodes."}
	return {"ok": true, "message": "Run map contract is valid."}

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

func _run_gut() -> int:
	var gut_config_script: Script = load("res://addons/gut/gut_config.gd")
	if gut_config_script == null or not gut_config_script.can_instantiate():
		printerr("[validate] GUT is not ready. Run a one-time headless editor import, then validate again.")
		return 1

	var gut_config = gut_config_script.new()
	var load_result: int = int(gut_config.load_options("res://.gutconfig.json"))
	if load_result == -1:
		printerr("[validate] Failed to load res://.gutconfig.json.")
		return 1

	gut_config.options.should_exit = false
	gut_config.options.should_exit_on_success = false

	var gut_script: Script = load("res://addons/gut/gut.gd")
	if gut_script == null or not gut_script.can_instantiate():
		printerr("[validate] Failed to instantiate GUT runner.")
		return 1

	var gut = gut_script.new()
	gut.name = "ValidationGut"
	root.add_child(gut)
	gut_config.apply_options(gut)
	gut.ignore_pause_before_teardown = true

	var completed: Array[bool] = [false]
	var exit_code: Array[int] = [0]
	gut.end_run.connect(func() -> void:
		exit_code[0] = 1 if gut.get_fail_count() > 0 else 0
		completed[0] = true
	)

	gut.test_scripts(gut.unit_test_name == "")
	while not completed[0]:
		await process_frame

	gut.queue_free()
	await process_frame
	return exit_code[0]
