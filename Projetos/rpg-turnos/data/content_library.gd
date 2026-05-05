extends Node

const CATALOG_PATH: String = "res://data/generated/slice_catalog.tres"
const ContentGeneratorScript = preload("res://tools/content_generator.gd")

var _catalog

func ensure_loaded():
	if _catalog != null:
		return _catalog
	if not ResourceLoader.exists(CATALOG_PATH):
		var result: Dictionary = ContentGeneratorScript.new().generate_all()
		if not bool(result.get("ok", false)):
			push_error(str(result.get("message", "Content generation failed.")))
			return null
	_catalog = load(CATALOG_PATH)
	if _catalog == null:
		push_error("Failed to load generated slice catalog.")
	return _catalog

func reload() -> void:
	_catalog = null
	ensure_loaded()

func get_catalog():
	return ensure_loaded()

func get_card(card_id: String):
	var catalog = ensure_loaded()
	if catalog == null:
		return null
	return catalog.find_card(card_id)

func get_card_name(card_id: String) -> String:
	var catalog = ensure_loaded()
	if catalog == null:
		return card_id
	return catalog.card_name(card_id)

func get_starter_deck_ids() -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	return Array(catalog.starter_deck_ids)

func get_first_npc_reward_card_id() -> String:
	var catalog = ensure_loaded()
	if catalog == null:
		return ""
	return catalog.first_npc_reward_card_id

func get_reward_card_id() -> String:
	return get_first_npc_reward_card_id()

func get_npc_reward_choices() -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	return Array(catalog.npc_reward_choices)

func get_encounter_reward_cards(encounter_id: String) -> Array:
	var catalog = ensure_loaded()
	if catalog == null:
		return []
	var encounter: Dictionary = catalog.find_encounter(encounter_id)
	return Array(encounter.get("reward_cards", []))

func get_encounter_display_name(encounter_id: String) -> String:
	var catalog = ensure_loaded()
	if catalog == null:
		return encounter_id
	var encounter: Dictionary = catalog.find_encounter(encounter_id)
	return str(encounter.get("display_name", encounter_id))
