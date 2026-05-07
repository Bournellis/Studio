extends Node

const DEFAULT_RUN_SEED: int = 0

var active: bool = false
var run_seed: int = DEFAULT_RUN_SEED
var selected_class_id: String = ""
var selected_class_display_name: String = ""
var current_node_id: String = ""
var completed_node_ids: Array[String] = []
var current_deck_ids: Array[String] = []
var current_health: int = 0
var max_health: int = 0
var rewards_pending: Array[String] = []

func start_empty_run(seed: int = DEFAULT_RUN_SEED) -> void:
	active = true
	run_seed = seed
	selected_class_id = ""
	selected_class_display_name = ""
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	rewards_pending = []

func start_class_run(class_id: String, seed: int = DEFAULT_RUN_SEED) -> Dictionary:
	var class_option: Dictionary = ContentLibrary.find_class_option(class_id)
	if class_option.is_empty():
		return {"ok": false, "message": "Classe placeholder invalida: %s" % class_id}
	active = true
	run_seed = seed
	selected_class_id = class_id
	selected_class_display_name = str(class_option.get("display_name", class_id))
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = _string_array(class_option.get("starter_deck", ContentLibrary.get_starter_deck_ids()))
	var catalog = ContentLibrary.get_catalog()
	var fallback_health: int = 30
	if catalog != null and catalog.player_hero != null:
		fallback_health = int(catalog.player_hero.max_health)
	max_health = int(class_option.get("starting_health", fallback_health))
	current_health = max_health
	rewards_pending = []
	return {"ok": true, "message": "Run placeholder iniciada com %s." % selected_class_display_name}

func reset() -> void:
	active = false
	run_seed = DEFAULT_RUN_SEED
	selected_class_id = ""
	selected_class_display_name = ""
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	rewards_pending = []

func select_node(node_id: String) -> void:
	if not active:
		return
	current_node_id = node_id

func mark_node_completed(node_id: String) -> void:
	if node_id == "":
		return
	if not completed_node_ids.has(node_id):
		completed_node_ids.append(node_id)

func is_node_available(node: Dictionary) -> bool:
	if not active:
		return false
	for dependency: String in Array(node.get("available_after", [])):
		if not completed_node_ids.has(dependency):
			return false
	return true

func has_selected_class() -> bool:
	return selected_class_id != ""

func snapshot() -> Dictionary:
	return {
		"active": active,
		"run_seed": run_seed,
		"selected_class_id": selected_class_id,
		"selected_class_display_name": selected_class_display_name,
		"current_node_id": current_node_id,
		"completed_node_ids": completed_node_ids.duplicate(),
		"current_deck_ids": current_deck_ids.duplicate(),
		"current_health": current_health,
		"max_health": max_health,
		"rewards_pending": rewards_pending.duplicate()
	}

func _string_array(source: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in Array(source):
		result.append(str(item))
	return result
