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
	for path: String in [
		"res://modes/boot/boot.tscn"
	]:
		if load(path) == null:
			return {"ok": false, "message": "Missing generated scene %s." % path}
	if str(catalog.run_map.get("id", "")) == "":
		return {"ok": false, "message": "Run map placeholder must exist."}
	return {"ok": true, "message": "Bootstrap contract is valid."}

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
