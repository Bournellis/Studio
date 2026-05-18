class_name ContentGenerator
extends RefCounted

const DEFINITION_PATH: String = "res://data/definitions/slice_catalog.json"
const GENERATED_DIR: String = "res://data/generated"
const CATALOG_PATH: String = "res://data/generated/slice_catalog.tres"
const SliceCatalogResourceScript = preload("res://data/resources/slice_catalog_resource.gd")
const HeroDefinitionResourceScript = preload("res://data/resources/hero_definition_resource.gd")
const CardDefinitionResourceScript = preload("res://data/resources/card_definition_resource.gd")

func generate_all() -> Dictionary:
	var definition: Dictionary = _load_definition()
	if definition.is_empty():
		return {"ok": false, "message": "Failed to load slice catalog definition."}

	var catalog = SliceCatalogResourceScript.new()
	catalog.player_hero = _build_hero(definition.get("player_hero", {}))
	catalog.enemy_hero = _build_hero(definition.get("enemy_hero", {}))
	catalog.starter_deck_ids = PackedStringArray(definition.get("starter_deck", []))
	catalog.class_options = _typed_dictionary_array(definition.get("class_options", []))
	catalog.first_npc_reward_card_id = str(definition.get("first_npc_reward_card", definition.get("reward_card", "")))
	catalog.reward_card_id = catalog.first_npc_reward_card_id
	catalog.npc_reward_choices = PackedStringArray(definition.get("npc_reward_choices", []))
	catalog.enemy_script = _typed_dictionary_array(definition.get("enemy_script", []))
	catalog.default_encounter_id = str(definition.get("default_encounter_id", "pouso_elemental"))
	catalog.boards = _typed_dictionary_array(definition.get("boards", []))
	catalog.encounters = _typed_dictionary_array(definition.get("encounters", []))
	catalog.run_map = Dictionary(definition.get("run_map", {}))
	catalog.track_contract = Dictionary(definition.get("track_contract", {}))

	for card_data: Dictionary in _typed_dictionary_array(definition.get("cards", [])):
		catalog.cards.append(_build_card(card_data))

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(GENERATED_DIR))
	var save_error: Error = ResourceSaver.save(catalog, CATALOG_PATH)
	if save_error != OK:
		return {"ok": false, "message": "Failed to save generated slice catalog."}
	return {"ok": true, "message": "Generated slice catalog."}

func _load_definition() -> Dictionary:
	if not FileAccess.file_exists(DEFINITION_PATH):
		return {}
	var file_text: String = FileAccess.get_file_as_string(DEFINITION_PATH)
	var parsed: Variant = JSON.parse_string(file_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _build_hero(data: Dictionary):
	var hero = HeroDefinitionResourceScript.new()
	hero.id = str(data.get("id", ""))
	hero.display_name = str(data.get("display_name", hero.id))
	hero.max_health = int(data.get("max_health", 1))
	hero.hero_power_text = str(data.get("hero_power_text", ""))
	return hero

func _build_card(data: Dictionary):
	var card = CardDefinitionResourceScript.new()
	card.id = str(data.get("id", ""))
	card.display_name = str(data.get("display_name", card.id))
	card.card_type = str(data.get("type", ""))
	card.cost = int(data.get("cost", 0))
	card.command_cost = int(data.get("command_cost", 0))
	card.speed = str(data.get("speed", "normal"))
	card.attack = int(data.get("attack", 0))
	card.health = int(data.get("health", 0))
	card.text = str(data.get("text", ""))
	card.keywords = PackedStringArray(data.get("keywords", []))
	card.effect = Dictionary(data.get("effect", {}))
	return card

func _typed_dictionary_array(source: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if typeof(source) != TYPE_ARRAY:
		return result
	for item: Variant in source:
		if typeof(item) == TYPE_DICTIONARY:
			result.append(Dictionary(item))
	return result
