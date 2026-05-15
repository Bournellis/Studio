extends Node

const DEFAULT_RUN_SEED: int = 0
const REWARD_ADD_PULSO_ASTRAL: String = "add_pulso_astral"
const REWARD_REINFORCE_HEALTH: String = "reinforce_health"
const REWARD_MAX_MANA_1: String = "max_mana_1"
const REWARD_MAX_HAND_SIZE_1: String = "max_hand_size_1"
const REWARD_UNLOCK_CLASS_PASSIVE: String = "unlock_class_passive"
const REWARD_UNLOCK_CLASS_ACTIVE: String = "unlock_class_active"
const REWARD_ADD_CLASS_COST2_CORE: String = "add_class_cost2_core"
const CHOICE_REWARD_UPGRADE_CARD: String = "upgrade_card"
const CHOICE_REWARD_NEW_CARD: String = "new_card"
const REWARD_CARD_COPY_COUNT: int = 3
const DEFAULT_MAX_HAND_SIZE: int = 3
const PAID_HEAL_COST: int = 10
const PAID_HEAL_AMOUNT: int = 5
const DEFAULT_PLAYER_NAME: String = "Comandante Draxos"
const MIN_PLAYER_NAME_LENGTH: int = 2
const MAX_PLAYER_NAME_LENGTH: int = 18
const SNAPSHOT_VERSION: int = 3

var active: bool = false
var run_seed: int = DEFAULT_RUN_SEED
var player_name: String = DEFAULT_PLAYER_NAME
var selected_class_id: String = ""
var selected_class_display_name: String = ""
var selected_class_active_text: String = ""
var current_node_id: String = ""
var completed_node_ids: Array[String] = []
var current_deck_ids: Array[String] = []
var current_health: int = 0
var max_health: int = 0
var max_mana: int = 0
var max_hand_size: int = 0
var soul_total: int = 0
var class_passive_unlocked: bool = false
var class_active_unlocked: bool = false
var class_active_level: int = 0
var rewards_pending: Array[Dictionary] = []
var applied_reward_ids: Array[String] = []
var automatic_reward_ids: Array[String] = []
var card_upgrade_counts: Dictionary = {}
var last_completed_node_id: String = ""
var last_battle_outcome: String = ""

func start_empty_run(seed: int = DEFAULT_RUN_SEED) -> void:
	active = true
	run_seed = seed
	player_name = DEFAULT_PLAYER_NAME
	selected_class_id = ""
	selected_class_display_name = ""
	selected_class_active_text = ""
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	max_mana = 0
	max_hand_size = 0
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	class_active_level = 0
	rewards_pending = []
	applied_reward_ids = []
	automatic_reward_ids = []
	card_upgrade_counts = {}
	last_completed_node_id = ""
	last_battle_outcome = ""

func start_class_run(class_id: String, seed: int = DEFAULT_RUN_SEED, requested_player_name: String = DEFAULT_PLAYER_NAME) -> Dictionary:
	var class_option: Dictionary = ContentLibrary.find_class_option(class_id)
	if class_option.is_empty():
		return {"ok": false, "message": "Classe placeholder invalida: %s" % class_id}
	var name_result: Dictionary = validate_player_name(requested_player_name)
	if not bool(name_result.get("ok", false)):
		return name_result
	active = true
	run_seed = seed
	player_name = str(name_result.get("name", DEFAULT_PLAYER_NAME))
	selected_class_id = class_id
	selected_class_display_name = str(class_option.get("display_name", class_id))
	selected_class_active_text = str(class_option.get("active_text", ""))
	completed_node_ids = []
	current_deck_ids = _string_array(class_option.get("starter_deck", ContentLibrary.get_starter_deck_ids()))
	var catalog = ContentLibrary.get_catalog()
	var fallback_health: int = 20
	if catalog != null and catalog.player_hero != null:
		fallback_health = int(catalog.player_hero.max_health)
	max_health = int(class_option.get("starting_health", fallback_health))
	current_health = max_health
	max_mana = int(class_option.get("starting_mana", 2))
	max_hand_size = int(class_option.get("starting_hand_size", DEFAULT_MAX_HAND_SIZE))
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	class_active_level = 0
	rewards_pending = []
	applied_reward_ids = []
	automatic_reward_ids = []
	card_upgrade_counts = {}
	last_completed_node_id = ""
	last_battle_outcome = ""
	select_next_available_node()
	return {"ok": true, "message": "Run iniciada com %s." % selected_class_display_name}

func reset() -> void:
	active = false
	run_seed = DEFAULT_RUN_SEED
	player_name = DEFAULT_PLAYER_NAME
	selected_class_id = ""
	selected_class_display_name = ""
	selected_class_active_text = ""
	current_node_id = ""
	completed_node_ids = []
	current_deck_ids = []
	current_health = 0
	max_health = 0
	max_mana = 0
	max_hand_size = 0
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	class_active_level = 0
	rewards_pending = []
	applied_reward_ids = []
	automatic_reward_ids = []
	card_upgrade_counts = {}
	last_completed_node_id = ""
	last_battle_outcome = ""

func select_node(node_id: String) -> void:
	if not active:
		return
	current_node_id = node_id

func select_next_available_node() -> String:
	if not active:
		current_node_id = ""
		return ""
	for node: Dictionary in Array(ContentLibrary.get_run_map().get("nodes", [])):
		var node_id: String = str(node.get("id", ""))
		if completed_node_ids.has(node_id):
			continue
		if is_node_available(node):
			current_node_id = node_id
			return current_node_id
	current_node_id = ""
	return ""

func mark_node_completed(node_id: String) -> void:
	if node_id == "":
		return
	if not completed_node_ids.has(node_id):
		completed_node_ids.append(node_id)

func record_battle_result(node_id: String, outcome: String, remaining_health: int) -> Dictionary:
	last_battle_outcome = outcome
	current_health = clampi(remaining_health, 0, max_health)
	if outcome != "vitoria":
		return {
			"ok": false,
			"outcome": outcome,
			"node_id": node_id,
			"souls_gained": 0,
			"automatic_rewards": [],
			"choice_rewards": [],
			"next_node_id": current_node_id
		}
	var already_completed: bool = completed_node_ids.has(node_id)
	var souls_gained: int = 0
	var applied_rewards: Array[String] = []
	mark_node_completed(node_id)
	last_completed_node_id = node_id
	if not already_completed:
		souls_gained = _soul_reward_for_node(node_id)
		soul_total += souls_gained
		applied_rewards = _apply_automatic_rewards_for_node(node_id)
		_queue_choice_rewards_for_node(node_id)
	select_next_available_node()
	return {
		"ok": true,
		"outcome": outcome,
		"node_id": node_id,
		"souls_gained": souls_gained,
		"automatic_rewards": applied_rewards,
		"choice_rewards": rewards_pending.duplicate(true),
		"next_node_id": current_node_id
	}

func apply_placeholder_reward(reward_id: String) -> Dictionary:
	return apply_reward_choice(reward_id)

func current_pending_reward() -> Dictionary:
	if rewards_pending.is_empty():
		return {}
	return rewards_pending[0].duplicate(true)

func pending_reward_choices() -> Array[Dictionary]:
	var pending: Dictionary = current_pending_reward()
	if pending.is_empty():
		return []
	match str(pending.get("type", "")):
		CHOICE_REWARD_UPGRADE_CARD:
			return _upgrade_reward_choices(pending)
		CHOICE_REWARD_NEW_CARD:
			return _new_card_reward_choices(pending)
	return []

func apply_reward_choice(choice_id: String) -> Dictionary:
	if rewards_pending.is_empty():
		return {"ok": false, "message": "Nenhuma recompensa pendente."}
	var pending: Dictionary = rewards_pending[0]
	var choices: Array[Dictionary] = pending_reward_choices()
	var selected: Dictionary = {}
	for choice: Dictionary in choices:
		if str(choice.get("id", "")) == choice_id:
			selected = choice
			break
	if selected.is_empty():
		return {"ok": false, "message": "Escolha de recompensa invalida: %s" % choice_id}
	match str(pending.get("type", "")):
		CHOICE_REWARD_UPGRADE_CARD:
			var card_id: String = str(selected.get("card_id", ""))
			card_upgrade_counts[card_id] = mini(2, int(card_upgrade_counts.get(card_id, 0)) + 1)
		CHOICE_REWARD_NEW_CARD:
			var new_card_id: String = str(selected.get("card_id", ""))
			for _copy_index: int in range(REWARD_CARD_COPY_COUNT):
				current_deck_ids.append(new_card_id)
		_:
			return {"ok": false, "message": "Tipo de recompensa invalido: %s" % str(pending.get("type", ""))}
	rewards_pending.remove_at(0)
	applied_reward_ids.append("%s:%s" % [str(pending.get("id", "")), choice_id])
	return {"ok": true, "message": _reward_choice_message(selected)}

func can_buy_heal() -> bool:
	return active and soul_total >= PAID_HEAL_COST and current_health < max_health

func buy_paid_heal() -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if current_health >= max_health:
		return {"ok": false, "message": "%s ja esta com vida cheia." % player_display_name()}
	if soul_total < PAID_HEAL_COST:
		return {"ok": false, "message": "Almas insuficientes para cura."}
	soul_total -= PAID_HEAL_COST
	current_health = mini(max_health, current_health + PAID_HEAL_AMOUNT)
	return {"ok": true, "message": "Cura paga aplicada: +%d vida por %d almas." % [PAID_HEAL_AMOUNT, PAID_HEAL_COST]}

func has_pending_reward() -> bool:
	return not rewards_pending.is_empty()

func effective_deck_ids() -> Array[String]:
	var result: Array[String] = []
	for card_id: String in current_deck_ids:
		result.append(effective_card_id(card_id))
	return result

func effective_card_id(card_id: String) -> String:
	var upgrade_count: int = clampi(int(card_upgrade_counts.get(card_id, 0)), 0, 2)
	if upgrade_count <= 0:
		return card_id
	var candidate: String = "%s_lvl%d" % [card_id, upgrade_count + 1]
	return candidate if ContentLibrary.get_card(candidate) != null else card_id

func is_node_available(node: Dictionary) -> bool:
	if not active:
		return false
	for dependency: String in Array(node.get("available_after", [])):
		if not completed_node_ids.has(dependency):
			return false
	return true

func has_selected_class() -> bool:
	return selected_class_id != ""

func player_display_name() -> String:
	var normalized: String = _normalize_player_name(player_name)
	return normalized if normalized != "" else DEFAULT_PLAYER_NAME

func validate_player_name(requested_name: String) -> Dictionary:
	var normalized: String = _normalize_player_name(requested_name)
	if normalized.length() < MIN_PLAYER_NAME_LENGTH:
		return {"ok": false, "message": "Nome precisa ter pelo menos %d caracteres." % MIN_PLAYER_NAME_LENGTH}
	if normalized.length() > MAX_PLAYER_NAME_LENGTH:
		return {"ok": false, "message": "Nome pode ter no maximo %d caracteres." % MAX_PLAYER_NAME_LENGTH}
	if normalized.find("\n") >= 0 or normalized.find("\r") >= 0 or normalized.find("\t") >= 0:
		return {"ok": false, "message": "Nome nao pode ter quebra de linha."}
	return {"ok": true, "name": normalized}

func snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"active": active,
		"run_seed": run_seed,
		"player_name": player_display_name(),
		"selected_class_id": selected_class_id,
		"selected_class_display_name": selected_class_display_name,
		"selected_class_active_text": selected_class_active_text,
		"current_node_id": current_node_id,
		"completed_node_ids": completed_node_ids.duplicate(),
		"current_deck_ids": current_deck_ids.duplicate(),
		"current_health": current_health,
		"max_health": max_health,
		"max_mana": max_mana,
		"max_hand_size": max_hand_size,
		"soul_total": soul_total,
		"class_passive_unlocked": class_passive_unlocked,
		"class_active_unlocked": class_active_unlocked,
		"class_active_level": class_active_level,
		"rewards_pending": rewards_pending.duplicate(),
		"applied_reward_ids": applied_reward_ids.duplicate(),
		"automatic_reward_ids": automatic_reward_ids.duplicate(),
		"card_upgrade_counts": card_upgrade_counts.duplicate(),
		"last_completed_node_id": last_completed_node_id,
		"last_battle_outcome": last_battle_outcome
	}

func load_snapshot(data: Dictionary) -> Dictionary:
	active = bool(data.get("active", false))
	run_seed = int(data.get("run_seed", DEFAULT_RUN_SEED))
	player_name = _normalize_player_name(str(data.get("player_name", DEFAULT_PLAYER_NAME)))
	if player_name == "":
		player_name = DEFAULT_PLAYER_NAME
	selected_class_id = str(data.get("selected_class_id", ""))
	selected_class_display_name = str(data.get("selected_class_display_name", ""))
	selected_class_active_text = str(data.get("selected_class_active_text", ""))
	current_node_id = str(data.get("current_node_id", ""))
	completed_node_ids = _string_array(data.get("completed_node_ids", []))
	current_deck_ids = _string_array(data.get("current_deck_ids", []))
	current_health = int(data.get("current_health", 0))
	max_health = int(data.get("max_health", 0))
	max_mana = int(data.get("max_mana", 0))
	max_hand_size = int(data.get("max_hand_size", DEFAULT_MAX_HAND_SIZE))
	soul_total = int(data.get("soul_total", 0))
	class_passive_unlocked = bool(data.get("class_passive_unlocked", false))
	class_active_unlocked = bool(data.get("class_active_unlocked", false))
	class_active_level = int(data.get("class_active_level", -1))
	if class_active_level < 0:
		class_active_level = 2 if selected_class_id == "necromante" and class_active_unlocked else 0
	rewards_pending = _pending_reward_array(data.get("rewards_pending", []))
	applied_reward_ids = _string_array(data.get("applied_reward_ids", []))
	automatic_reward_ids = _string_array(data.get("automatic_reward_ids", []))
	card_upgrade_counts = Dictionary(data.get("card_upgrade_counts", {}))
	last_completed_node_id = str(data.get("last_completed_node_id", ""))
	last_battle_outcome = str(data.get("last_battle_outcome", ""))
	if active and selected_class_display_name == "" and selected_class_id != "":
		var class_option: Dictionary = ContentLibrary.find_class_option(selected_class_id)
		selected_class_display_name = str(class_option.get("display_name", selected_class_id))
		selected_class_active_text = str(class_option.get("active_text", selected_class_active_text))
	if active and current_node_id == "":
		select_next_available_node()
	return {"ok": true, "message": "Run carregada."}

func current_node_display_name() -> String:
	if current_node_id == "":
		return "Rota concluida"
	var node: Dictionary = _run_node(current_node_id)
	if node.is_empty():
		return current_node_id
	var encounter_id: String = str(node.get("encounter_id", ""))
	var catalog = ContentLibrary.get_catalog()
	if catalog == null:
		return current_node_id
	var encounter: Dictionary = catalog.find_encounter(encounter_id)
	if encounter.is_empty():
		return current_node_id
	return str(encounter.get("display_name", current_node_id))

func automatic_reward_display_name(reward_id: String) -> String:
	match reward_id:
		REWARD_MAX_MANA_1:
			return "+1 Mana maxima"
		REWARD_MAX_HAND_SIZE_1:
			return "+1 Limite de mao"
		REWARD_UNLOCK_CLASS_PASSIVE:
			if selected_class_id == "necromante":
				return "Passiva + Ritual das Sombras I desbloqueados"
			return "Passiva de classe desbloqueada"
		REWARD_UNLOCK_CLASS_ACTIVE:
			if selected_class_id == "necromante":
				return "Ritual das Sombras II desbloqueado"
			return "Spell de classe desbloqueada"
		REWARD_ADD_CLASS_COST2_CORE:
			return "%s adicionada ao deck" % ContentLibrary.get_card_name(_class_core_cost2_card_id())
	return reward_id

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

func _apply_automatic_rewards_for_node(node_id: String) -> Array[String]:
	var applied: Array[String] = []
	var node: Dictionary = _run_node(node_id)
	for reward_id: String in _string_array(node.get("rewards", [])):
		var applied_id: String = "%s:%s" % [node_id, reward_id]
		if automatic_reward_ids.has(applied_id):
			continue
		match reward_id:
			REWARD_MAX_MANA_1:
				max_mana += 1
			REWARD_MAX_HAND_SIZE_1:
				max_hand_size += 1
			REWARD_UNLOCK_CLASS_PASSIVE:
				class_passive_unlocked = true
				if selected_class_id == "necromante":
					class_active_unlocked = true
					class_active_level = maxi(class_active_level, 1)
			REWARD_UNLOCK_CLASS_ACTIVE:
				class_active_unlocked = true
				class_active_level = maxi(class_active_level, 2 if selected_class_id == "necromante" else 1)
			REWARD_ADD_CLASS_COST2_CORE:
				var card_id: String = _class_core_cost2_card_id()
				for _copy_index: int in range(REWARD_CARD_COPY_COUNT):
					current_deck_ids.append(card_id)
			_:
				continue
		automatic_reward_ids.append(applied_id)
		applied.append(reward_id)
	return applied

func _queue_choice_rewards_for_node(node_id: String) -> void:
	var node: Dictionary = _run_node(node_id)
	var reward: Dictionary = Dictionary(node.get("choice_reward", {}))
	if reward.is_empty():
		return
	var pending_id: String = "%s:%s" % [node_id, str(reward.get("type", ""))]
	for pending: Dictionary in rewards_pending:
		if str(pending.get("id", "")) == pending_id:
			return
	for applied_id: String in applied_reward_ids:
		if applied_id.begins_with("%s:" % pending_id):
			return
	var pending: Dictionary = reward.duplicate(true)
	pending["id"] = pending_id
	pending["node_id"] = node_id
	rewards_pending.append(pending)

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
			return "arcano_choque"
		"invocador":
			return "invocador_promover"
		"necromante":
			return "necro_prender"
	return "arcano_choque"

func _class_core_cost2_card_id() -> String:
	match selected_class_id:
		"arcano":
			return "arcano_tempestade"
		"invocador":
			return "invocador_guardiao"
		"necromante":
			return "necro_zumbi"
	return "arcano_tempestade"

func _upgrade_reward_choices(_pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Array[String] = []
	for card_id: String in current_deck_ids:
		if seen.has(card_id):
			continue
		seen.append(card_id)
	var candidates: Array[String] = []
	for card_id: String in seen:
		if int(card_upgrade_counts.get(card_id, 0)) >= 2:
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		candidates.append(card_id)
	candidates = _stable_shuffled_strings(candidates, str(_pending.get("id", "")))
	for card_id: String in candidates:
		var card = ContentLibrary.get_card(card_id)
		var upgrade_index: int = int(card_upgrade_counts.get(card_id, 0)) + 1
		result.append({
			"id": "upgrade:%s" % card_id,
			"card_id": card_id,
			"title": "%s - Lvl %d" % [str(card.display_name), upgrade_index + 1],
			"body": _upgrade_choice_body(card_id, upgrade_index)
		})
		if result.size() >= 3:
			break
	return result

func _new_card_reward_choices(_pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var pool: Array[String] = _class_reward_pool()
	if pool.is_empty():
		return result
	for card_id: String in pool:
		if current_deck_ids.has(card_id):
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		result.append({
			"id": "new_card:%s" % card_id,
			"card_id": card_id,
			"title": str(card.display_name),
			"body": "Adiciona %d copias ao deck." % REWARD_CARD_COPY_COUNT
		})
	return result

func _class_reward_pool() -> Array[String]:
	var class_option: Dictionary = ContentLibrary.find_class_option(selected_class_id)
	return _string_array(class_option.get("reward_pool", []))

func _upgrade_choice_body(card_id: String, upgrade_index: int) -> String:
	if upgrade_index <= 1:
		return "%s sobe para Lvl 2 em todas as copias da run." % ContentLibrary.get_card_name(card_id)
	return "%s sobe para Lvl 3 em todas as copias da run." % ContentLibrary.get_card_name(card_id)

func _reward_choice_message(choice: Dictionary) -> String:
	if str(choice.get("id", "")).begins_with("upgrade:"):
		return "Upgrade aplicado: %s." % str(choice.get("title", ""))
	if str(choice.get("id", "")).begins_with("new_card:"):
		return "Carta adicionada ao deck: %s x%d." % [str(choice.get("title", "")), REWARD_CARD_COPY_COUNT]
	return "Recompensa aplicada."

func _string_array(source: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in Array(source):
		result.append(str(item))
	return result

func _pending_reward_array(source: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for item: Variant in Array(source):
		if typeof(item) == TYPE_DICTIONARY:
			result.append(Dictionary(item))
	return result

func _stable_shuffled_strings(source: Array[String], salt: String) -> Array[String]:
	var result: Array[String] = source.duplicate()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var seed_text: String = "%d:%s:%s" % [run_seed, selected_class_id, salt]
	rng.seed = absi(seed_text.hash())
	for index: int in range(result.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var value: String = result[index]
		result[index] = result[swap_index]
		result[swap_index] = value
	return result

func _normalize_player_name(requested_name: String) -> String:
	var normalized: String = requested_name.strip_edges()
	while normalized.find("  ") >= 0:
		normalized = normalized.replace("  ", " ")
	return normalized
