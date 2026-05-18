extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")
const VisualAssetsScript = preload("res://core/visual_assets.gd")
const TRACK_02_CONTRACT_ID: String = "track_02_complete_run_evolution"
const TRACK_02_ROUTE_STATUS_CONTRACT_ONLY: String = "contract_only"
const TRACK_02_SAVE_VERSION: int = 5
const TRACK_02_SNAPSHOT_VERSION: int = 5
const TRACK_02_CURRENT_ROUTE_MAP_COUNT: int = 13
const TRACK_02_TARGET_MAP_COUNT: int = 29
const TRACK_02_MAX_MANA_CAP: int = 6
const TRACK_02_MAX_HAND_SIZE_CAP: int = 5

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
		if reward_pool.size() != 8:
			return {"ok": false, "message": "Class %s needs exactly 8 real reward cards for Track 02." % class_id}
		for reward_card_id: String in reward_pool:
			if catalog.find_card(reward_card_id) == null:
				return {"ok": false, "message": "Class %s reward_pool references missing card %s." % [class_id, reward_card_id]}
			for suffix: String in ["_lvl2", "_lvl3"]:
				if catalog.find_card("%s%s" % [reward_card_id, suffix]) == null:
					return {"ok": false, "message": "Class %s reward card %s is missing upgrade %s." % [class_id, reward_card_id, suffix]}
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
		if str(card.id).contains("_recompensa_") or str(card.text).to_lower().contains("placeholder"):
			return {"ok": false, "message": "Placeholder reward card still exists: %s." % str(card.id)}
	for removed_player_id: String in ["arcano_spell_dano", "arcano_construtor_fluxo", "invocador_protecao", "invocador_buff_unico", "necro_spell_lentidao"]:
		if catalog.find_card(removed_player_id) != null:
			return {"ok": false, "message": "Removed player card still exists: %s." % removed_player_id}
	var required_new_cards: Array[String] = [
		"arcano_choque", "arcano_choque_lvl2", "arcano_choque_lvl3",
		"arcano_fagulha", "arcano_fagulha_lvl2", "arcano_fagulha_lvl3",
		"arcano_barreira", "arcano_barreira_lvl2", "arcano_barreira_lvl3",
		"arcano_tempestade", "arcano_tempestade_lvl2", "arcano_tempestade_lvl3",
		"arcano_bola_de_fogo", "arcano_bola_de_fogo_lvl2", "arcano_bola_de_fogo_lvl3",
		"arcano_acelerar", "arcano_acelerar_lvl2", "arcano_acelerar_lvl3",
		"invocador_soldado", "invocador_soldado_lvl2", "invocador_soldado_lvl3",
		"invocador_batedor", "invocador_batedor_lvl2", "invocador_batedor_lvl3",
		"invocador_promover", "invocador_promover_lvl2", "invocador_promover_lvl3",
		"invocador_guardiao", "invocador_guardiao_lvl2", "invocador_guardiao_lvl3",
		"invocador_atacar", "invocador_atacar_lvl2", "invocador_atacar_lvl3",
		"invocador_golem", "invocador_golem_lvl2", "invocador_golem_lvl3",
		"necro_esqueleto", "necro_esqueleto_lvl2", "necro_esqueleto_lvl3",
		"necro_morto_vivo", "necro_morto_vivo_lvl2", "necro_morto_vivo_lvl3",
		"necro_prender", "necro_prender_lvl2", "necro_prender_lvl3",
		"necro_zumbi", "necro_zumbi_lvl2", "necro_zumbi_lvl3",
		"necro_carniceiro", "necro_carniceiro_lvl2", "necro_carniceiro_lvl3",
		"necro_diabrete", "necro_diabrete_lvl2", "necro_diabrete_lvl3"
	]
	for new_card_id: String in required_new_cards:
		if catalog.find_card(new_card_id) == null:
			return {"ok": false, "message": "Missing redesigned player card %s." % new_card_id}
	var track_02_content_result: Dictionary = _validate_track_02_card_content(catalog)
	if not bool(track_02_content_result.get("ok", false)):
		return track_02_content_result
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
	var track_02_result: Dictionary = _validate_track_02_contract(catalog)
	if not bool(track_02_result.get("ok", false)):
		return track_02_result
	return {"ok": true, "message": "Bootstrap contract is valid."}

func _validate_visual_assets() -> Dictionary:
	var catalog = load("res://data/generated/slice_catalog.tres")
	if catalog == null:
		return {"ok": false, "message": "Missing generated slice catalog before visual validation."}
	var visual_assets = VisualAssetsScript.new()
	var result: Dictionary = visual_assets.validate_manifest(catalog)
	visual_assets.free()
	return result

func _validate_track_02_card_content(catalog) -> Dictionary:
	var expected_reward_pools: Dictionary = {
		"arcano": [
			"arcano_bola_de_fogo", "arcano_acelerar",
			"arcano_vortice", "arcano_sentinela_arcana",
			"arcano_amplificador", "arcano_canalizar",
			"arcano_espelho_arcano", "arcano_descarga"
		],
		"invocador": [
			"invocador_atacar", "invocador_golem",
			"invocador_capitao_de_campo", "invocador_parede_de_escudos",
			"invocador_cavaleiro_arcano", "invocador_berserker",
			"invocador_arauto", "invocador_tita_geminal"
		],
		"necromante": [
			"necro_carniceiro", "necro_diabrete",
			"necro_revenant", "necro_flagelo",
			"necro_arauto_das_sombras", "necro_colheita_das_almas",
			"necro_lich", "necro_praga"
		]
	}
	for class_id: String in expected_reward_pools.keys():
		var class_option: Dictionary = catalog.find_class_option(class_id)
		var reward_pool: Array = Array(class_option.get("reward_pool", []))
		var expected_pool: Array = Array(expected_reward_pools.get(class_id, []))
		if reward_pool != expected_pool:
			return {"ok": false, "message": "Class %s Track 02 reward_pool order is invalid." % class_id}
		for card_id: String in expected_pool:
			if catalog.find_card(card_id) == null:
				return {"ok": false, "message": "Track 02 reward card missing: %s." % card_id}
			if catalog.find_card("%s_lvl2" % card_id) == null or catalog.find_card("%s_lvl3" % card_id) == null:
				return {"ok": false, "message": "Track 02 reward card %s is missing Lvl 2 or Lvl 3." % card_id}

	var contract: Dictionary = Dictionary(catalog.track_contract)
	var reward_gallery: Dictionary = Dictionary(contract.get("track_02_player_card_rewards", {}))
	for class_id: String in expected_reward_pools.keys():
		var class_gallery: Dictionary = Dictionary(reward_gallery.get(class_id, {}))
		for element: String in ["terra", "gelo", "ar", "fogo"]:
			var pair: Array = Array(class_gallery.get(element, []))
			if pair.size() != 2:
				return {"ok": false, "message": "Class %s element %s needs exactly 2 reward cards." % [class_id, element]}
			for card_id: String in pair:
				if not Array(expected_reward_pools.get(class_id, [])).has(card_id):
					return {"ok": false, "message": "Class %s element %s references non-pool card %s." % [class_id, element, card_id]}

	var enemy_galleries: Dictionary = Dictionary(contract.get("enemy_card_galleries", {}))
	var expected_enemy_counts: Dictionary = {"terra": 10, "gelo": 7, "ar": 7, "fogo": 6}
	for element: String in expected_enemy_counts.keys():
		var enemy_ids: Array = Array(enemy_galleries.get(element, []))
		if enemy_ids.size() != int(expected_enemy_counts.get(element, 0)):
			return {"ok": false, "message": "Enemy gallery %s needs %d cards." % [element, int(expected_enemy_counts.get(element, 0))]}
		for enemy_id: String in enemy_ids:
			if catalog.find_card(enemy_id) == null:
				return {"ok": false, "message": "Enemy gallery %s references missing card %s." % [element, enemy_id]}
	return {"ok": true, "message": "Track 02 card content is valid."}

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
		if int(node_data.get("map_index", 0)) <= 0:
			return {"ok": false, "message": "Run map node %s needs map_index." % str(node_data.get("id", ""))}
		if kind == "mainline":
			has_mainline = true
	if not has_mainline:
		return {"ok": false, "message": "Run map must include mainline nodes."}
	var expected_rewards: Dictionary = {
		"n01_tutorial_primeiro_contato": "max_mana_1",
		"n02_tutorial_dois_fronts": "add_class_cost2_core",
		"n04_pouso_elemental": "add_relic_placeholder",
		"n05_ondas_iniciais": "max_mana_1",
		"n06_duelo_inicial": "max_hand_size_1",
		"n08_chefe_invocador": "unlock_class_passive",
		"n10_limpeza_elite": "max_health_5",
		"n11_ondas_avancadas": "grant_remaining_card"
	}
	for expected_node_id: String in expected_rewards.keys():
		var node_data: Dictionary = _find_run_node(nodes, expected_node_id)
		if node_data.is_empty():
			return {"ok": false, "message": "Run map missing reward node %s." % expected_node_id}
		if not Array(node_data.get("rewards", [])).has(str(expected_rewards.get(expected_node_id, ""))):
			return {"ok": false, "message": "Run map node %s missing automatic reward." % expected_node_id}
	var expected_choice_rewards: Dictionary = {
		"n03_tutorial_primeira_onda": "upgrade_card",
		"n07_defesa_posicao": "new_card",
		"n09_sobreviver_turnos": "upgrade_card",
		"n12_duelo_elite": "upgrade_card",
		"n13_chefe_final": "new_card"
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

func _validate_track_02_contract(catalog) -> Dictionary:
	var contract: Dictionary = Dictionary(catalog.track_contract)
	if contract.is_empty():
		return {"ok": false, "message": "Track 02 contract metadata is missing."}
	if str(contract.get("id", "")) != TRACK_02_CONTRACT_ID:
		return {"ok": false, "message": "Track 02 contract id is invalid."}
	if int(contract.get("save_version", 0)) != TRACK_02_SAVE_VERSION:
		return {"ok": false, "message": "Track 02 contract save_version must match SaveManager."}
	if int(contract.get("snapshot_version", 0)) != TRACK_02_SNAPSHOT_VERSION:
		return {"ok": false, "message": "Track 02 contract snapshot_version must match RunSession."}
	var stat_caps: Dictionary = Dictionary(contract.get("stat_caps", {}))
	if int(stat_caps.get("max_mana", 0)) != TRACK_02_MAX_MANA_CAP:
		return {"ok": false, "message": "Track 02 max mana cap must be 6."}
	if int(stat_caps.get("max_hand_size", 0)) != TRACK_02_MAX_HAND_SIZE_CAP:
		return {"ok": false, "message": "Track 02 max hand size cap must be 5."}
	var max_health: Dictionary = Dictionary(contract.get("max_health", {}))
	if int(max_health.get("starting", 0)) != 20:
		return {"ok": false, "message": "Track 02 starting max health must be 20."}
	if int(max_health.get("fixed_reward_target", 0)) != 30:
		return {"ok": false, "message": "Track 02 fixed max health target must be 30."}
	var route: Dictionary = Dictionary(contract.get("route", {}))
	if int(route.get("active_map_count", 0)) != TRACK_02_CURRENT_ROUTE_MAP_COUNT:
		return {"ok": false, "message": "Track 02 active route metadata must preserve the 13-map baseline."}
	if int(route.get("target_map_count", 0)) != TRACK_02_TARGET_MAP_COUNT:
		return {"ok": false, "message": "Track 02 target route metadata must be 29 maps."}
	if str(route.get("status", "")) != TRACK_02_ROUTE_STATUS_CONTRACT_ONLY:
		return {"ok": false, "message": "Track 02 route metadata should remain contract-only in T02-P01."}
	if Array(route.get("element_order", [])).size() != 4:
		return {"ok": false, "message": "Track 02 route metadata needs the four element blocks."}
	var reward_categories: Array = Array(contract.get("reward_categories", []))
	for category: String in ["max_mana", "max_hand_size", "max_health", "new_card", "remaining_card", "card_upgrade", "relic", "utility", "victory"]:
		if not reward_categories.has(category):
			return {"ok": false, "message": "Track 02 reward category missing: %s." % category}
	var reward_rarity: Dictionary = Dictionary(contract.get("reward_rarity", {}))
	if int(reward_rarity.get("common", 0)) != 70 or int(reward_rarity.get("rare", 0)) != 25 or int(reward_rarity.get("ultra_rare", 0)) != 5:
		return {"ok": false, "message": "Track 02 reward rarity must remain 70/25/5."}
	var copy_rules: Dictionary = Dictionary(contract.get("reward_card_copy_rules", {}))
	if int(copy_rules.get("common", 0)) != 3 or int(copy_rules.get("rare", 0)) != 4 or int(copy_rules.get("ultra_rare", 0)) != 5:
		return {"ok": false, "message": "Track 02 new-card copy rules must be 3/4/5."}
	var reward_schedule_result: Dictionary = _validate_track_02_reward_schedule(Array(contract.get("reward_schedule", [])))
	if not bool(reward_schedule_result.get("ok", false)):
		return reward_schedule_result
	var relic_schema: Dictionary = Dictionary(contract.get("relic_state_schema", {}))
	if str(relic_schema.get("stored_as", "")) != "relic_ids":
		return {"ok": false, "message": "Track 02 relic state must be stored as relic_ids."}
	var relic_result: Dictionary = _validate_track_02_relics(Array(contract.get("relics", [])))
	if not bool(relic_result.get("ok", false)):
		return relic_result
	var shop_result: Dictionary = _validate_track_02_shop_prices(Dictionary(contract.get("shop_prices", {})))
	if not bool(shop_result.get("ok", false)):
		return shop_result
	var tooltip_result: Dictionary = _validate_track_02_tooltips(contract, catalog)
	if not bool(tooltip_result.get("ok", false)):
		return tooltip_result
	return {"ok": true, "message": "Track 02 contract is valid."}

func _validate_track_02_tooltips(contract: Dictionary, catalog) -> Dictionary:
	var expected_keyword_ids: Array[String] = [
		"iniciativa",
		"defensor",
		"reviver",
		"regeneracao",
		"carnica",
		"suicida",
		"enfraquecer",
		"prender",
		"remover_keywords",
		"poder_de_habilidade",
		"atropelar",
		"brutal",
		"drenar",
		"espinhos",
		"escudo",
		"resistencia",
		"imune",
		"crescer",
		"furia",
		"ecoar",
		"veneno",
		"congelar",
		"profanar",
		"entrar",
		"proliferar",
		"sacrificio",
		"inspirar",
		"pacto",
		"drenar_almas",
		"ressurgir"
	]
	var seen_keywords: Array[String] = []
	for definition: Variant in Array(contract.get("keyword_definitions", [])):
		if typeof(definition) != TYPE_DICTIONARY:
			return {"ok": false, "message": "Track 02 keyword definitions must be dictionaries."}
		var data: Dictionary = Dictionary(definition)
		var keyword_id: String = str(data.get("id", ""))
		if keyword_id == "":
			return {"ok": false, "message": "Track 02 keyword definition missing id."}
		if seen_keywords.has(keyword_id):
			return {"ok": false, "message": "Duplicate Track 02 keyword definition: %s." % keyword_id}
		seen_keywords.append(keyword_id)
		if str(data.get("display_name", "")) == "" or str(data.get("tooltip", "")) == "" or str(data.get("timing", "")) == "":
			return {"ok": false, "message": "Track 02 keyword %s needs display, tooltip, and timing." % keyword_id}
	for expected_id: String in expected_keyword_ids:
		if not seen_keywords.has(expected_id):
			return {"ok": false, "message": "Missing Track 02 keyword definition: %s." % expected_id}
	for card in catalog.cards:
		for keyword: String in card.keywords:
			if not seen_keywords.has(_normalize_keyword_id(keyword)):
				return {"ok": false, "message": "Card %s references keyword without tooltip: %s." % [str(card.id), keyword]}
	var expected_surfaces: Array[String] = ["card", "occupant", "reward", "shop_item", "relic", "enemy_intent", "board_effect"]
	var surfaces: Array = Array(contract.get("tooltip_surfaces", []))
	for surface_id: String in expected_surfaces:
		if not surfaces.has(surface_id):
			return {"ok": false, "message": "Missing tooltip surface: %s." % surface_id}
	if Array(contract.get("status_definitions", [])).is_empty():
		return {"ok": false, "message": "Track 02 needs status definitions for tooltip presentation."}
	if Array(contract.get("board_effect_definitions", [])).is_empty():
		return {"ok": false, "message": "Track 02 needs board effect tooltip placeholders."}
	if Array(contract.get("enemy_intent_definitions", [])).is_empty():
		return {"ok": false, "message": "Track 02 needs enemy intent tooltip placeholders."}
	return {"ok": true, "message": "Track 02 tooltip vocabulary is valid."}

func _normalize_keyword_id(keyword_id: String) -> String:
	return keyword_id.strip_edges().to_lower().replace(" ", "_").replace("-", "_")

func _validate_track_02_relics(relics: Array) -> Dictionary:
	if relics.size() != 18:
		return {"ok": false, "message": "Track 02 must define exactly 18 initial relics."}
	var expected_ids: Array[String] = [
		"bolsa_de_cinzas",
		"lamina_de_reserva",
		"mao_preparada",
		"couro_astral",
		"marca_de_guerra",
		"eco_menor",
		"catalisador_arcano",
		"contrato_de_sangue",
		"ferramentas_de_cirurgia",
		"estandarte_vivo",
		"nucleo_instavel",
		"escudo_de_marcha",
		"coracao_de_eter",
		"biblioteca_proibida",
		"forja_negra",
		"olho_do_grande_mestre",
		"selo_de_dominacao",
		"pacto_das_ruinas"
	]
	var seen: Array[String] = []
	for relic: Variant in relics:
		if typeof(relic) != TYPE_DICTIONARY:
			return {"ok": false, "message": "Track 02 relic entries must be dictionaries."}
		var relic_data: Dictionary = Dictionary(relic)
		var relic_id: String = str(relic_data.get("id", ""))
		if not expected_ids.has(relic_id):
			return {"ok": false, "message": "Unexpected Track 02 relic id: %s." % relic_id}
		if seen.has(relic_id):
			return {"ok": false, "message": "Duplicate Track 02 relic id: %s." % relic_id}
		seen.append(relic_id)
		if not ["common", "rare", "ultra_rare"].has(str(relic_data.get("rarity", ""))):
			return {"ok": false, "message": "Track 02 relic %s has invalid rarity." % relic_id}
		if str(relic_data.get("display_name", "")) == "" or str(relic_data.get("effect_text", "")) == "":
			return {"ok": false, "message": "Track 02 relic %s needs display text." % relic_id}
	for expected_id: String in expected_ids:
		if not seen.has(expected_id):
			return {"ok": false, "message": "Missing Track 02 relic id: %s." % expected_id}
	return {"ok": true, "message": "Track 02 relics are valid."}

func _validate_track_02_shop_prices(prices: Dictionary) -> Dictionary:
	if int(prices.get("heal", 0)) != 10:
		return {"ok": false, "message": "Track 02 shop heal price must be 10."}
	if int(prices.get("remove_card", 0)) != 15:
		return {"ok": false, "message": "Track 02 shop remove price must be 15."}
	if int(prices.get("duplicate_card", 0)) != 20 or int(prices.get("upgrade_card", 0)) != 20:
		return {"ok": false, "message": "Track 02 shop duplicate/upgrade prices must be 20."}
	var card_prices: Dictionary = Dictionary(prices.get("buy_card", {}))
	if int(card_prices.get("common", 0)) != 12 or int(card_prices.get("rare", 0)) != 18 or int(card_prices.get("ultra_rare", 0)) != 25:
		return {"ok": false, "message": "Track 02 shop card prices must be 12/18/25."}
	var relic_prices: Dictionary = Dictionary(prices.get("buy_relic", {}))
	if int(relic_prices.get("common", 0)) != 30 or int(relic_prices.get("rare", 0)) != 45 or int(relic_prices.get("ultra_rare", 0)) != 70:
		return {"ok": false, "message": "Track 02 shop relic prices must be 30/45/70."}
	if int(prices.get("reroll_base", 0)) != 8 or int(prices.get("reroll_step", 0)) != 4:
		return {"ok": false, "message": "Track 02 reroll price must be 8 + 4 per reroll."}
	var max_health_prices: Array = Array(prices.get("max_health", []))
	if max_health_prices.size() != 2 or int(max_health_prices[0]) != 18 or int(max_health_prices[1]) != 28:
		return {"ok": false, "message": "Track 02 max HP shop prices must be 18 then 28."}
	return {"ok": true, "message": "Track 02 shop prices are valid."}

func _validate_track_02_reward_schedule(schedule: Array) -> Dictionary:
	if schedule.size() != TRACK_02_TARGET_MAP_COUNT:
		return {"ok": false, "message": "Track 02 reward schedule must contain 29 maps."}
	var expected_categories: Dictionary = {
		1: "max_mana",
		2: "new_card",
		3: "card_upgrade",
		4: "relic",
		5: "max_mana",
		6: "max_hand_size",
		7: "new_card",
		8: "relic",
		9: "card_upgrade",
		10: "max_health",
		11: "remaining_card",
		12: "card_upgrade",
		13: "new_card",
		14: "remaining_card",
		15: "max_health",
		16: "max_mana",
		17: "new_card",
		18: "card_upgrade",
		19: "max_mana",
		20: "remaining_card",
		21: "relic",
		22: "max_hand_size",
		23: "max_mana",
		24: "new_card",
		25: "card_upgrade",
		26: "remaining_card",
		27: "utility",
		28: "relic",
		29: "victory"
	}
	for index: int in range(schedule.size()):
		if typeof(schedule[index]) != TYPE_DICTIONARY:
			return {"ok": false, "message": "Track 02 reward schedule entry %d must be a dictionary." % (index + 1)}
		var entry: Dictionary = Dictionary(schedule[index])
		var map_index: int = int(entry.get("map", 0))
		if map_index != index + 1:
			return {"ok": false, "message": "Track 02 reward schedule map order is invalid at %d." % (index + 1)}
		if str(entry.get("category", "")) != str(expected_categories.get(map_index, "")):
			return {"ok": false, "message": "Track 02 reward schedule map %d has invalid category." % map_index}
		if str(entry.get("title", "")) == "":
			return {"ok": false, "message": "Track 02 reward schedule map %d needs title." % map_index}
	var map_10: Dictionary = Dictionary(schedule[9])
	var map_15: Dictionary = Dictionary(schedule[14])
	if int(map_10.get("max_health_delta", 0)) != 5 or int(map_15.get("max_health_delta", 0)) != 5:
		return {"ok": false, "message": "Track 02 fixed HP progression must be +5 at maps 10 and 15."}
	var map_23: Dictionary = Dictionary(schedule[22])
	if not Array(map_23.get("automatic_rewards", [])).has("max_mana_1"):
		return {"ok": false, "message": "Track 02 map 23 must grant the final max mana reward."}
	var map_27_choice: Dictionary = Dictionary(Dictionary(schedule[26]).get("choice_reward", {}))
	var utility_options: Array = Array(map_27_choice.get("options", []))
	for required_option: String in ["remove_card", "duplicate_card", "upgrade_card"]:
		if not utility_options.has(required_option):
			return {"ok": false, "message": "Track 02 map 27 utility choice missing %s." % required_option}
	return {"ok": true, "message": "Track 02 reward schedule is valid."}

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
