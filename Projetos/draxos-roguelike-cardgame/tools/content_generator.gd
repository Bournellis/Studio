class_name ContentGenerator
extends RefCounted

const DEFINITION_PATH: String = "res://data/definitions/slice_catalog.json"
const GENERATED_DIR: String = "res://data/generated"
const CATALOG_PATH: String = "res://data/generated/slice_catalog.tres"
const CatalogSourceLoaderScript = preload("res://tools/catalog_source_loader.gd")
const SliceCatalogResourceScript = preload("res://data/resources/slice_catalog_resource.gd")
const HeroDefinitionResourceScript = preload("res://data/resources/hero_definition_resource.gd")
const CardDefinitionResourceScript = preload("res://data/resources/card_definition_resource.gd")

func generate_all() -> Dictionary:
	var source: Dictionary = CatalogSourceLoaderScript.new().load_catalog_source()
	if not bool(source.get("ok", false)):
		return {"ok": false, "message": str(source.get("message", "Failed to load slice catalog definition."))}
	var definition: Dictionary = Dictionary(source.get("definition", {}))
	var definition_hash: String = _definition_hash(definition)

	var existing_catalog = _load_existing_catalog()
	if existing_catalog != null and str(existing_catalog.definition_hash) == definition_hash:
		return {"ok": true, "message": "Generated slice catalog unchanged."}

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
	catalog.definition_hash = definition_hash

	for card_data: Dictionary in _typed_dictionary_array(definition.get("cards", [])):
		catalog.cards.append(_build_card(card_data))

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(GENERATED_DIR))
	var save_error: Error = ResourceSaver.save(catalog, CATALOG_PATH)
	if save_error != OK:
		return {"ok": false, "message": "Failed to save generated slice catalog."}
	return {"ok": true, "message": "Generated slice catalog."}

func _load_existing_catalog():
	if not ResourceLoader.exists(CATALOG_PATH):
		return null
	return load(CATALOG_PATH)

func _load_definition() -> Dictionary:
	return CatalogSourceLoaderScript.new().load_catalog_definition()

func _definition_hash(value: Variant) -> String:
	return CatalogSourceLoaderScript.stable_definition_hash(value)

func _stable_definition_string(value: Variant) -> String:
	return CatalogSourceLoaderScript.stable_definition_string(value)

func _escape_json_string(value: String) -> String:
	return CatalogSourceLoaderScript.escape_stable_json_string(value)

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
