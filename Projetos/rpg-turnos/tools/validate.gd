extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")
const DeckRulesScript = preload("res://systems/deck/deck_rules.gd")

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

	print("[validate] checking first-slice contract")
	var contract_result: Dictionary = _validate_contract()
	if not bool(contract_result.get("ok", false)):
		printerr("[validate] %s" % str(contract_result.get("message", "Contract validation failed.")))
		return 1

	print("[validate] running GUT")
	var gut_exit_code: int = await _run_gut()
	if gut_exit_code != 0:
		printerr("[validate] GUT failed with exit code %d." % gut_exit_code)
		return gut_exit_code

	print("[validate] manual smoke: res://docs/first-playable-slice-smoke.md")
	print("[validate] success")
	return 0

func _validate_contract() -> Dictionary:
	var catalog = load("res://data/generated/slice_catalog.tres")
	if catalog == null:
		return {"ok": false, "message": "Missing generated slice catalog."}
	if catalog.player_hero == null or catalog.player_hero.max_health != 25:
		return {"ok": false, "message": "Player hero must have 25 HP in this slice."}
	if catalog.enemy_hero == null or catalog.enemy_hero.max_health != 20:
		return {"ok": false, "message": "Enemy hero must have 20 HP in this slice."}
	if catalog.starter_deck_ids.size() != 20:
		return {"ok": false, "message": "Starter deck must have 20 cards."}
	if catalog.find_encounter("emboscada_na_ponte").is_empty():
		return {"ok": false, "message": "Emboscada na Ponte encounter must exist."}
	if catalog.find_encounter("duelista_bandido").is_empty():
		return {"ok": false, "message": "Duelista Bandido encounter must exist."}
	if catalog.first_npc_reward_card_id == "" or catalog.find_card(catalog.first_npc_reward_card_id) == null:
		return {"ok": false, "message": "First NPC reward card must exist."}
	if catalog.classes.size() != 3:
		return {"ok": false, "message": "Generated class catalog must expose 3 classes."}
	for class_data: Dictionary in catalog.classes:
		var class_id: String = str(class_data.get("id", ""))
		var starter_deck: Array = Array(class_data.get("starter_deck", []))
		if starter_deck.size() != 20:
			return {"ok": false, "message": "Class %s starter deck must have 20 cards." % class_id}
		for card_id: Variant in starter_deck:
			if catalog.find_card(str(card_id)) == null:
				return {"ok": false, "message": "Class %s starter card %s is missing." % [class_id, str(card_id)]}
	for path: String in [
		"res://modes/boot/boot.tscn",
		"res://modes/world/world.tscn",
		"res://modes/battle/deck_setup.tscn",
		"res://modes/battle/battle.tscn",
		"res://modes/battle/result.tscn"
	]:
		if load(path) == null:
			return {"ok": false, "message": "Missing generated scene %s." % path}

	var deck_rules = DeckRulesScript.new()
	var deck_validation: Dictionary = deck_rules.validate(Array(catalog.starter_deck_ids), Array(catalog.starter_deck_ids))
	if not bool(deck_validation.get("ok", false)):
		return deck_validation
	return {"ok": true, "message": "First playable slice contract is valid."}

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
