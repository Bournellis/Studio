extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")
const VisualAssetsScript = preload("res://core/visual_assets.gd")

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

	print("[validate] checking visual asset manifest")
	var visual_result: Dictionary = _validate_visual_assets()
	if not bool(visual_result.get("ok", false)):
		printerr("[validate] %s" % str(visual_result.get("message", "Visual asset manifest validation failed.")))
		return 1
	var missing_assets: Array = Array(visual_result.get("missing_assets", []))
	if not missing_assets.is_empty():
		print("[validate] visual assets missing but optional in V1: %d" % missing_assets.size())

	print("[validate] running GUT")
	var gut_exit_code: int = await _run_gut()
	if gut_exit_code != 0:
		printerr("[validate] GUT failed with exit code %d." % gut_exit_code)
		return gut_exit_code

	print("[validate] first mechanical class slice is playable; balance still in progress")
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
	if catalog.starter_deck_ids.size() < 10:
		return {"ok": false, "message": "Starter deck must keep a playable Arcano slice deck."}
	if catalog.class_options.size() != 3:
		return {"ok": false, "message": "Catalog must expose exactly 3 playable class options for Track 01."}
	var expected_classes: Array[String] = ["arcano", "invocador", "necromante"]
	for class_option: Dictionary in catalog.class_options:
		var class_id: String = str(class_option.get("id", ""))
		if not expected_classes.has(class_id):
			return {"ok": false, "message": "Unexpected class option %s." % class_id}
		if Array(class_option.get("starter_deck", [])).size() < 10:
			return {"ok": false, "message": "Class %s needs a playable starter_deck." % class_id}
		if int(class_option.get("starting_mana", 0)) != 2:
			return {"ok": false, "message": "Class %s needs starting_mana 2 for the linear run slice." % class_id}
		if int(class_option.get("starting_health", 0)) != 20:
			return {"ok": false, "message": "Class %s needs starting_health 20 for the test slice." % class_id}
		if str(class_option.get("passive_id", "")) == "" or str(class_option.get("active_id", "")) == "":
			return {"ok": false, "message": "Class %s needs passive_id and active_id." % class_id}
		for starter_card_id: String in Array(class_option.get("starter_deck", [])):
			var starter_card = catalog.find_card(starter_card_id)
			if starter_card == null:
				return {"ok": false, "message": "Class %s starter_deck references missing card %s." % [class_id, starter_card_id]}
			if int(starter_card.cost) >= 3:
				return {"ok": false, "message": "Class %s starter_deck still includes cost 3 card %s." % [class_id, starter_card_id]}
	for card_id: String in Array(catalog.starter_deck_ids):
		if catalog.find_card(card_id) == null:
			return {"ok": false, "message": "Starter deck references missing card %s." % card_id}
	for card in catalog.cards:
		if card.has_keyword("protecao") or card.has_keyword("voadora"):
			return {"ok": false, "message": "Card %s still uses removed keyword." % str(card.id)}
	for migrated_id: String in ["arcano_protetor", "invocador_protecao", "invocador_voadora"]:
		var migrated_card = catalog.find_card(migrated_id)
		if migrated_card == null or not migrated_card.has_keyword("iniciativa"):
			return {"ok": false, "message": "Migrated card %s needs iniciativa." % migrated_id}
	if catalog.find_encounter("pouso_elemental").is_empty():
		return {"ok": false, "message": "Pouso Elemental encounter must exist."}
	if catalog.find_encounter("ondas_iniciais").is_empty():
		return {"ok": false, "message": "Ondas Iniciais encounter must exist."}
	if catalog.find_encounter("chefe_invocador").is_empty():
		return {"ok": false, "message": "Chefe Invocador encounter must exist."}
	var required_modes: Array[String] = ["limpar_mesa", "duelo", "ondas", "defesa_posicao", "sobreviver_turnos", "chefe_summoner"]
	var found_modes: Array[String] = []
	for encounter: Dictionary in catalog.encounters:
		var encounter_mode: String = str(encounter.get("mode", ""))
		if not found_modes.has(encounter_mode):
			found_modes.append(encounter_mode)
		if int(encounter.get("player_slots_count", 0)) <= 0:
			return {"ok": false, "message": "Encounter %s needs player_slots_count." % str(encounter.get("id", ""))}
		if int(encounter.get("enemy_slots_count", 0)) <= 0:
			return {"ok": false, "message": "Encounter %s needs enemy_slots_count." % str(encounter.get("id", ""))}
		var encounter_contract_result: Dictionary = _validate_encounter_contract(encounter)
		if not bool(encounter_contract_result.get("ok", false)):
			return encounter_contract_result
	for required_mode: String in required_modes:
		if not found_modes.has(required_mode):
			return {"ok": false, "message": "Catalog needs encounter mode %s." % required_mode}
	for path: String in [
		"res://modes/boot/boot.tscn",
		"res://modes/ship_hub/ship_hub.tscn",
		"res://modes/run_map/run_map.tscn",
		"res://modes/battle/battle.tscn"
	]:
		if load(path) == null:
			return {"ok": false, "message": "Missing generated scene %s." % path}
	if str(catalog.run_map.get("id", "")) == "":
		return {"ok": false, "message": "Run map placeholder must exist."}
	var run_map_result: Dictionary = _validate_run_map_contract(Dictionary(catalog.run_map))
	if not bool(run_map_result.get("ok", false)):
		return run_map_result
	return {"ok": true, "message": "Bootstrap contract is valid."}

func _validate_visual_assets() -> Dictionary:
	var catalog = load("res://data/generated/slice_catalog.tres")
	if catalog == null:
		return {"ok": false, "message": "Missing generated slice catalog before visual validation."}
	var visual_assets = VisualAssetsScript.new()
	var result: Dictionary = visual_assets.validate_manifest(catalog)
	visual_assets.free()
	return result

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
	if str(encounter.get("mode", "")) == "chefe_summoner" and Array(encounter.get("boss_summons", [])).is_empty():
		return {"ok": false, "message": "Summoner boss %s needs boss_summons." % encounter_id}
	return {"ok": true, "message": "Encounter contract is valid."}

func _validate_run_map_contract(run_map: Dictionary) -> Dictionary:
	var nodes: Array = Array(run_map.get("nodes", []))
	if nodes.size() != 10:
		return {"ok": false, "message": "Run map needs exactly 10 linear nodes."}
	var has_mainline: bool = false
	for node: Variant in nodes:
		if typeof(node) != TYPE_DICTIONARY:
			return {"ok": false, "message": "Run map nodes must be dictionaries."}
		var node_data: Dictionary = Dictionary(node)
		var kind: String = str(node_data.get("kind", ""))
		if kind != "mainline":
			return {"ok": false, "message": "Run map node %s has invalid kind." % str(node_data.get("id", ""))}
		if str(node_data.get("id", "")) == "":
			return {"ok": false, "message": "Run map node needs id."}
		if str(node_data.get("encounter_id", "")) == "":
			return {"ok": false, "message": "Run map node %s needs encounter_id." % str(node_data.get("id", ""))}
		if kind == "mainline":
			has_mainline = true
	if not has_mainline:
		return {"ok": false, "message": "Run map must include mainline nodes."}
	var expected_rewards: Dictionary = {
		"n02_ondas_iniciais": "max_mana_1",
		"n03_duelo_inicial": "add_cost3_cards",
		"n05_chefe_invocador": "unlock_class_passive",
		"n07_limpeza_elite": "unlock_class_active"
	}
	for expected_node_id: String in expected_rewards.keys():
		var node_data: Dictionary = _find_run_node(nodes, expected_node_id)
		if node_data.is_empty():
			return {"ok": false, "message": "Run map missing reward node %s." % expected_node_id}
		if not Array(node_data.get("rewards", [])).has(str(expected_rewards.get(expected_node_id, ""))):
			return {"ok": false, "message": "Run map node %s missing automatic reward." % expected_node_id}
	return {"ok": true, "message": "Run map contract is valid."}

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
