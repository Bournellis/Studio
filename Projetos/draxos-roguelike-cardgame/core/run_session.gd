extends Node

const DEFAULT_RUN_SEED: int = 0

var active: bool = false
var run_seed: int = DEFAULT_RUN_SEED
var current_node_id: String = ""
var completed_node_ids: Array[String] = []
var current_deck_ids: Array[String] = []
var current_health: int = 0
var max_health: int = 0
var rewards_pending: Array[String] = []

func start_empty_run(seed: int = DEFAULT_RUN_SEED) -> void:
	active = true
	run_seed = seed
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	rewards_pending = []

func reset() -> void:
	active = false
	run_seed = DEFAULT_RUN_SEED
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	rewards_pending = []

func select_node(node_id: String) -> void:
	if not active:
		start_empty_run()
	current_node_id = node_id

func mark_node_completed(node_id: String) -> void:
	if node_id == "":
		return
	if not completed_node_ids.has(node_id):
		completed_node_ids.append(node_id)

func is_node_available(node: Dictionary) -> bool:
	for dependency: String in Array(node.get("available_after", [])):
		if not completed_node_ids.has(dependency):
			return false
	return true

func snapshot() -> Dictionary:
	return {
		"active": active,
		"run_seed": run_seed,
		"current_node_id": current_node_id,
		"completed_node_ids": completed_node_ids.duplicate(),
		"current_deck_ids": current_deck_ids.duplicate(),
		"current_health": current_health,
		"max_health": max_health,
		"rewards_pending": rewards_pending.duplicate()
	}
