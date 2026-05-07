extends Node

const DEFAULT_RUN_SEED: int = 0

var active: bool = false
var run_seed: int = DEFAULT_RUN_SEED
var current_node_id: String = ""
var current_deck_ids: Array[String] = []
var current_health: int = 0
var max_health: int = 0
var rewards_pending: Array[String] = []

func start_empty_run(seed: int = DEFAULT_RUN_SEED) -> void:
	active = true
	run_seed = seed
	current_node_id = ""
	current_deck_ids = []
	current_health = 0
	max_health = 0
	rewards_pending = []

func reset() -> void:
	active = false
	run_seed = DEFAULT_RUN_SEED
	current_node_id = ""
	current_deck_ids = []
	current_health = 0
	max_health = 0
	rewards_pending = []

func snapshot() -> Dictionary:
	return {
		"active": active,
		"run_seed": run_seed,
		"current_node_id": current_node_id,
		"current_deck_ids": current_deck_ids.duplicate(),
		"current_health": current_health,
		"max_health": max_health,
		"rewards_pending": rewards_pending.duplicate()
	}
