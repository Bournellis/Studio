extends Node

const DEFAULT_RUN_SEED: int = 0
const REWARD_ADD_PULSO_ASTRAL: String = "add_pulso_astral"
const REWARD_REINFORCE_HEALTH: String = "reinforce_health"
const REWARD_MAX_MANA_1: String = "max_mana_1"
const REWARD_ADD_COST3_CARDS: String = "add_cost3_cards"
const REWARD_UNLOCK_CLASS_PASSIVE: String = "unlock_class_passive"
const REWARD_UNLOCK_CLASS_ACTIVE: String = "unlock_class_active"
const PAID_HEAL_COST: int = 5
const PAID_HEAL_AMOUNT: int = 5

var active: bool = false
var run_seed: int = DEFAULT_RUN_SEED
var selected_class_id: String = ""
var selected_class_display_name: String = ""
var selected_class_active_text: String = ""
var current_node_id: String = ""
var completed_node_ids: Array[String] = []
var current_deck_ids: Array[String] = []
var current_health: int = 0
var max_health: int = 0
var max_mana: int = 0
var soul_total: int = 0
var class_passive_unlocked: bool = false
var class_active_unlocked: bool = false
var rewards_pending: Array[String] = []
var applied_reward_ids: Array[String] = []
var automatic_reward_ids: Array[String] = []
var last_completed_node_id: String = ""
var last_battle_outcome: String = ""

func start_empty_run(seed: int = DEFAULT_RUN_SEED) -> void:
	active = true
	run_seed = seed
	selected_class_id = ""
	selected_class_display_name = ""
	selected_class_active_text = ""
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	max_mana = 0
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	rewards_pending = []
	applied_reward_ids = []
	automatic_reward_ids = []
	last_completed_node_id = ""
	last_battle_outcome = ""

func start_class_run(class_id: String, seed: int = DEFAULT_RUN_SEED) -> Dictionary:
	var class_option: Dictionary = ContentLibrary.find_class_option(class_id)
	if class_option.is_empty():
		return {"ok": false, "message": "Classe placeholder invalida: %s" % class_id}
	active = true
	run_seed = seed
	selected_class_id = class_id
	selected_class_display_name = str(class_option.get("display_name", class_id))
	selected_class_active_text = str(class_option.get("active_text", ""))
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = _string_array(class_option.get("starter_deck", ContentLibrary.get_starter_deck_ids()))
	var catalog = ContentLibrary.get_catalog()
	var fallback_health: int = 20
	if catalog != null and catalog.player_hero != null:
		fallback_health = int(catalog.player_hero.max_health)
	max_health = int(class_option.get("starting_health", fallback_health))
	current_health = max_health
	max_mana = int(class_option.get("starting_mana", 2))
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	rewards_pending = []
	applied_reward_ids = []
	automatic_reward_ids = []
	last_completed_node_id = ""
	last_battle_outcome = ""
	return {"ok": true, "message": "Run iniciada com %s." % selected_class_display_name}

func reset() -> void:
	active = false
	run_seed = DEFAULT_RUN_SEED
	selected_class_id = ""
	selected_class_display_name = ""
	selected_class_active_text = ""
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	max_mana = 0
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	rewards_pending = []
	applied_reward_ids = []
	automatic_reward_ids = []
	last_completed_node_id = ""
	last_battle_outcome = ""

func select_node(node_id: String) -> void:
	if not active:
		return
	current_node_id = node_id

func mark_node_completed(node_id: String) -> void:
	if node_id == "":
		return
	if not completed_node_ids.has(node_id):
		completed_node_ids.append(node_id)

func record_battle_result(node_id: String, outcome: String, remaining_health: int) -> void:
	last_battle_outcome = outcome
	current_health = clampi(remaining_health, 0, max_health)
	if outcome != "vitoria":
		return
	var already_completed: bool = completed_node_ids.has(node_id)
	mark_node_completed(node_id)
	last_completed_node_id = node_id
	if not already_completed:
		soul_total += _soul_reward_for_node(node_id)
		_apply_automatic_rewards_for_node(node_id)
	if current_node_id == node_id:
		current_node_id = ""

func apply_placeholder_reward(reward_id: String) -> Dictionary:
	if rewards_pending.is_empty():
		return {"ok": false, "message": "Nenhuma recompensa pendente."}
	var pending_id: String = rewards_pending[0]
	match reward_id:
		REWARD_ADD_PULSO_ASTRAL:
			current_deck_ids.append(_default_reward_card_id())
		REWARD_REINFORCE_HEALTH:
			max_health += 2
			current_health = mini(max_health, current_health + 2)
		_:
			return {"ok": false, "message": "Recompensa placeholder invalida: %s" % reward_id}
	rewards_pending.remove_at(0)
	applied_reward_ids.append("%s:%s" % [pending_id, reward_id])
	return {"ok": true, "message": _reward_message(reward_id)}

func can_buy_heal() -> bool:
	return active and soul_total >= PAID_HEAL_COST and current_health < max_health

func buy_paid_heal() -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if current_health >= max_health:
		return {"ok": false, "message": "O Comandante ja esta com vida cheia."}
	if soul_total < PAID_HEAL_COST:
		return {"ok": false, "message": "Almas insuficientes para cura."}
	soul_total -= PAID_HEAL_COST
	current_health = mini(max_health, current_health + PAID_HEAL_AMOUNT)
	return {"ok": true, "message": "Cura paga aplicada: +%d vida por %d almas." % [PAID_HEAL_AMOUNT, PAID_HEAL_COST]}

func has_pending_reward() -> bool:
	return not rewards_pending.is_empty()

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
		"selected_class_active_text": selected_class_active_text,
		"current_node_id": current_node_id,
		"completed_node_ids": completed_node_ids.duplicate(),
		"current_deck_ids": current_deck_ids.duplicate(),
		"current_health": current_health,
		"max_health": max_health,
		"max_mana": max_mana,
		"soul_total": soul_total,
		"class_passive_unlocked": class_passive_unlocked,
		"class_active_unlocked": class_active_unlocked,
		"rewards_pending": rewards_pending.duplicate(),
		"applied_reward_ids": applied_reward_ids.duplicate(),
		"automatic_reward_ids": automatic_reward_ids.duplicate(),
		"last_completed_node_id": last_completed_node_id,
		"last_battle_outcome": last_battle_outcome
	}

func _soul_reward_for_node(node_id: String) -> int:
	var encounter: Dictionary = _encounter_for_node(node_id)
	var reward: Dictionary = Dictionary(encounter.get("soul_reward", {}))
	if reward.is_empty():
		return 0
	return int(reward.get("min", 0))

func _encounter_for_node(node_id: String) -> Dictionary:
	var node: Dictionary = _run_node(node_id)
	if node.is_empty():
		return {}
	var catalog = ContentLibrary.get_catalog()
	if catalog == null:
		return {}
	return catalog.find_encounter(str(node.get("encounter_id", "")))

func _run_node(node_id: String) -> Dictionary:
	var catalog = ContentLibrary.get_catalog()
	if catalog == null:
		return {}
	for node: Dictionary in Array(ContentLibrary.get_run_map().get("nodes", [])):
		if str(node.get("id", "")) != node_id:
			continue
		return node
	return {}

func _apply_automatic_rewards_for_node(node_id: String) -> void:
	var node: Dictionary = _run_node(node_id)
	for reward_id: String in _string_array(node.get("rewards", [])):
		var applied_id: String = "%s:%s" % [node_id, reward_id]
		if automatic_reward_ids.has(applied_id):
			continue
		match reward_id:
			REWARD_MAX_MANA_1:
				max_mana += 1
			REWARD_ADD_COST3_CARDS:
				for card_id: String in _cost_three_reward_card_ids():
					current_deck_ids.append(card_id)
			REWARD_UNLOCK_CLASS_PASSIVE:
				class_passive_unlocked = true
			REWARD_UNLOCK_CLASS_ACTIVE:
				class_active_unlocked = true
			_:
				continue
		automatic_reward_ids.append(applied_id)

func _cost_three_reward_card_ids() -> Array[String]:
	return [
		"arcano_amplificador",
		"invocador_colosso"
	]

func _queue_placeholder_reward(node_id: String) -> void:
	var pending_id: String = "placeholder_reward:%s" % node_id
	if rewards_pending.has(pending_id):
		return
	for applied_id: String in applied_reward_ids:
		if applied_id.begins_with("%s:" % pending_id):
			return
	rewards_pending.append(pending_id)

func _reward_message(reward_id: String) -> String:
	match reward_id:
		REWARD_ADD_PULSO_ASTRAL:
			return "Recompensa aplicada: carta de classe adicionada ao deck da run."
		REWARD_REINFORCE_HEALTH:
			return "Recompensa aplicada: vida maxima e atual reforcadas em +2."
	return "Recompensa aplicada."

func _default_reward_card_id() -> String:
	match selected_class_id:
		"arcano":
			return "arcano_spell_dano"
		"invocador":
			return "invocador_buff_unico"
		"necromante":
			return "necro_spell_lentidao"
	return "arcano_spell_dano"

func _string_array(source: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in Array(source):
		result.append(str(item))
	return result
