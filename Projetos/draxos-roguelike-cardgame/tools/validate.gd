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
	var alpha_warnings: Array = Array(visual_result.get("alpha_warnings", []))
	if not alpha_warnings.is_empty():
		print("[validate] ship overlay alpha debts, non-fatal: %d" % alpha_warnings.size())
		for warning: String in alpha_warnings:
			print("[validate] %s" % warning)

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
	if catalog.starter_deck_ids.size() != 9:
		return {"ok": false, "message": "Starter deck must have 9 cost-1 cards before the map 2 cost-2 reward."}
	if catalog.class_options.size() != 3:
		return {"ok": false, "message": "Catalog must expose exactly 3 playable class options for Track 01."}
	var expected_classes: Array[String] = ["arcano", "invocador", "necromante"]
	for class_option: Dictionary in catalog.class_options:
		var class_id: String = str(class_option.get("id", ""))
		if not expected_classes.has(class_id):
			return {"ok": false, "message": "Unexpected class option %s." % class_id}
		var starter_deck: Array = Array(class_option.get("starter_deck", []))
		if starter_deck.size() != 9:
			return {"ok": false, "message": "Class %s needs exactly 9 starter cards." % class_id}
		if int(class_option.get("starting_hand_size", 0)) != 3:
			return {"ok": false, "message": "Class %s needs starting_hand_size 3." % class_id}
		if int(class_option.get("starting_mana", 0)) != 1:
			return {"ok": false, "message": "Class %s needs starting_mana 1 for map 1." % class_id}
		if int(class_option.get("starting_health", 0)) != 20:
			return {"ok": false, "message": "Class %s needs starting_health 20 for the test slice." % class_id}
		if str(class_option.get("passive_id", "")) == "" or str(class_option.get("active_id", "")) == "":
			return {"ok": false, "message": "Class %s needs passive_id and active_id." % class_id}
		var reward_pool: Array = Array(class_option.get("reward_pool", []))
		if reward_pool.size() < 6 or reward_pool.size() > 8:
			return {"ok": false, "message": "Class %s needs a reward_pool of 6-8 placeholder cards." % class_id}
		for reward_card_id: String in reward_pool:
			if catalog.find_card(reward_card_id) == null:
				return {"ok": false, "message": "Class %s reward_pool references missing card %s." % [class_id, reward_card_id]}
		var unique_counts: Dictionary = {}
		for starter_card_id: String in starter_deck:
			var starter_card = catalog.find_card(starter_card_id)
			if starter_card == null:
				return {"ok": false, "message": "Class %s starter_deck references missing card %s." % [class_id, starter_card_id]}
			if int(starter_card.cost) != 1:
				return {"ok": false, "message": "Class %s starter_deck must only include cost 1 cards before map 2: %s." % [class_id, starter_card_id]}
			unique_counts[starter_card_id] = int(unique_counts.get(starter_card_id, 0)) + 1
		if unique_counts.size() != 3:
			return {"ok": false, "message": "Class %s needs 3 starter card types before the cost-2 reward." % class_id}
		for card_count: Variant in unique_counts.values():
			if int(card_count) != 3:
				return {"ok": false, "message": "Class %s needs 3 copies of each starter card." % class_id}
	for card_id: String in Array(catalog.starter_deck_ids):
		if catalog.find_card(card_id) == null:
			return {"ok": false, "message": "Starter deck references missing card %s." % card_id}
	for card in catalog.cards:
		if card.has_keyword("protecao") or card.has_keyword("voadora"):
			return {"ok": false, "message": "Card %s still uses removed keyword." % str(card.id)}
	for removed_player_id: String in ["arcano_spell_dano", "arcano_construtor_fluxo", "invocador_protecao", "invocador_buff_unico", "necro_spell_lentidao"]:
		if catalog.find_card(removed_player_id) != null:
			return {"ok": false, "message": "Removed player card still exists: %s." % removed_player_id}
	var required_new_cards: Array[String] = ["arcano_choque", "arcano_fagulha", "arcano_barreira", "arcano_tempestade", "invocador_soldado", "invocador_batedor", "invocador_promover", "invocador_guardiao", "necro_esqueleto", "necro_morto_vivo", "necro_prender", "necro_zumbi", "arcano_recompensa_1", "invocador_recompensa_1", "necro_recompensa_1"]
	for new_card_id: String in required_new_cards:
		if catalog.find_card(new_card_id) == null:
			return {"ok": false, "message": "Missing redesigned player card %s." % new_card_id}
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
		"res://modes/deck/deck.tscn",
		"res://modes/souls/souls.tscn",
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
	if not ["tutorial", "small", "medium", "elite_optional", "boss"].has(tier):
		return {"ok": false, "message": "Encounter %s has invalid tier." % encounter_id}
	if not ["prefilled_board", "waves", "scripted_boss", "player_like"].has(str(encounter.get("enemy_director", ""))):
		return {"ok": false, "message": "Encounter %s has invalid enemy_director." % encounter_id}
	var reward: Dictionary = Dictionary(encounter.get("soul_reward", {}))
	var min_reward: int = int(reward.get("min", 0))
	var max_reward: int = int(reward.get("max", 0))
	var expected: Dictionary = _soul_reward_band(tier)
	if tier == "tutorial" and (min_reward < int(expected.get("min", 0)) or max_reward > int(expected.get("max", 4)) or min_reward > max_reward):
		return {"ok": false, "message": "Encounter %s has invalid tutorial soul_reward." % encounter_id}
	if tier != "tutorial" and (min_reward != int(expected.get("min", -1)) or max_reward != int(expected.get("max", -1))):
		return {"ok": false, "message": "Encounter %s has invalid soul_reward for tier %s." % [encounter_id, tier]}
	if str(encounter.get("mode", "")) == "chefe_summoner" and Array(encounter.get("boss_summons", [])).is_empty():
		return {"ok": false, "message": "Summoner boss %s needs boss_summons." % encounter_id}
	return {"ok": true, "message": "Encounter contract is valid."}

func _validate_run_map_contract(run_map: Dictionary) -> Dictionary:
	var nodes: Array = Array(run_map.get("nodes", []))
	if nodes.size() != 13:
		return {"ok": false, "message": "Run map needs exactly 13 linear nodes."}
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
		"n01_tutorial_primeiro_contato": "max_mana_1",
		"n02_tutorial_dois_fronts": "add_class_cost2_core",
		"n05_ondas_iniciais": "max_mana_1",
		"n06_duelo_inicial": "max_hand_size_1",
		"n08_chefe_invocador": "unlock_class_passive",
		"n10_limpeza_elite": "unlock_class_active"
	}
	for expected_node_id: String in expected_rewards.keys():
		var node_data: Dictionary = _find_run_node(nodes, expected_node_id)
		if node_data.is_empty():
			return {"ok": false, "message": "Run map missing reward node %s." % expected_node_id}
		if not Array(node_data.get("rewards", [])).has(str(expected_rewards.get(expected_node_id, ""))):
			return {"ok": false, "message": "Run map node %s missing automatic reward." % expected_node_id}
	var expected_choice_rewards: Dictionary = {
		"n03_tutorial_primeira_onda": "upgrade_card",
		"n04_pouso_elemental": "upgrade_card",
		"n06_duelo_inicial": "upgrade_card",
		"n07_defesa_posicao": "new_card",
		"n09_sobreviver_turnos": "upgrade_card",
		"n11_ondas_avancadas": "new_card",
		"n12_duelo_elite": "upgrade_card"
	}
	for choice_node_id: String in expected_choice_rewards.keys():
		var choice_node: Dictionary = _find_run_node(nodes, choice_node_id)
		if choice_node.is_empty():
			return {"ok": false, "message": "Run map missing choice reward node %s." % choice_node_id}
		var choice_reward: Dictionary = Dictionary(choice_node.get("choice_reward", {}))
		if str(choice_reward.get("type", "")) != str(expected_choice_rewards.get(choice_node_id, "")):
			return {"ok": false, "message": "Run map node %s has invalid choice reward." % choice_node_id}
	return {"ok": true, "message": "Run map contract is valid."}

func _find_run_node(nodes: Array, node_id: String) -> Dictionary:
	for node: Variant in nodes:
		if typeof(node) == TYPE_DICTIONARY and str(Dictionary(node).get("id", "")) == node_id:
			return Dictionary(node)
	return {}

func _soul_reward_band(tier: String) -> Dictionary:
	match tier:
		"tutorial":
			return {"min": 0, "max": 4}
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
