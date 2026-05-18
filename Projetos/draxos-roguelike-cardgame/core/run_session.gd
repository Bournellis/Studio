extends Node

const DEFAULT_RUN_SEED: int = 0
const REWARD_ADD_PULSO_ASTRAL: String = "add_pulso_astral"
const REWARD_REINFORCE_HEALTH: String = "reinforce_health"
const REWARD_MAX_MANA_1: String = "max_mana_1"
const REWARD_MAX_HAND_SIZE_1: String = "max_hand_size_1"
const REWARD_MAX_HEALTH_5: String = "max_health_5"
const REWARD_UNLOCK_CLASS_PASSIVE: String = "unlock_class_passive"
const REWARD_UNLOCK_CLASS_ACTIVE: String = "unlock_class_active"
const REWARD_ADD_CLASS_COST2_CORE: String = "add_class_cost2_core"
const REWARD_ADD_RELIC_PLACEHOLDER: String = "add_relic_placeholder"
const REWARD_GRANT_REMAINING_CARD: String = "grant_remaining_card"
const REWARD_COMPLETE_RUN_VICTORY: String = "complete_run_victory"
const CHOICE_REWARD_UPGRADE_CARD: String = "upgrade_card"
const CHOICE_REWARD_NEW_CARD: String = "new_card"
const CHOICE_REWARD_RELIC: String = "relic"
const CHOICE_REWARD_UTILITY: String = "utility_choice"
const UTILITY_REWARD_REMOVE_CARD: String = "remove_card"
const UTILITY_REWARD_DUPLICATE_CARD: String = "duplicate_card"
const UTILITY_REWARD_UPGRADE_CARD: String = "upgrade_card"
const REWARD_CARD_COPY_COUNT: int = 3
const REWARD_RARITY_COMMON: String = "comum"
const REWARD_RARITY_RARE: String = "rara"
const REWARD_RARITY_ULTRA: String = "ultra_rara"
const SHOP_CARD_UPGRADE_COST: int = 20
const SHOP_UPGRADE_OFFER_COUNT: int = 3
const SHOP_CARD_OFFER_COUNT: int = 3
const SHOP_RELIC_OFFER_COUNT: int = 2
const SHOP_HEAL_COST: int = 10
const SHOP_HEAL_AMOUNT: int = 5
const SHOP_REMOVE_CARD_COST: int = 15
const SHOP_DUPLICATE_CARD_COST: int = 20
const SHOP_BUY_COMMON_CARD_COST: int = 12
const SHOP_BUY_RARE_CARD_COST: int = 18
const SHOP_BUY_ULTRA_RARE_CARD_COST: int = 25
const SHOP_BUY_COMMON_RELIC_COST: int = 30
const SHOP_BUY_RARE_RELIC_COST: int = 45
const SHOP_BUY_ULTRA_RARE_RELIC_COST: int = 70
const SHOP_REROLL_COST_BASE: int = 8
const SHOP_REROLL_COST_STEP: int = 4
const SHOP_MAX_HEALTH_AMOUNT: int = 3
const SHOP_MAX_HEALTH_FIRST_COST: int = 18
const SHOP_MAX_HEALTH_SECOND_COST: int = 28
const SHOP_MAX_HEALTH_PURCHASE_LIMIT: int = 2
const DEFAULT_MAX_HAND_SIZE: int = 3
const PAID_HEAL_COST: int = SHOP_HEAL_COST
const PAID_HEAL_AMOUNT: int = SHOP_HEAL_AMOUNT
const RELIC_BOLSA_DE_CINZAS: String = "bolsa_de_cinzas"
const RELIC_LAMINA_DE_RESERVA: String = "lamina_de_reserva"
const RELIC_COURO_ASTRAL: String = "couro_astral"
const RELIC_CATALISADOR_ARCANO: String = "catalisador_arcano"
const RELIC_FERRAMENTAS_DE_CIRURGIA: String = "ferramentas_de_cirurgia"
const RELIC_NUCLEO_INSTAVEL: String = "nucleo_instavel"
const RELIC_BIBLIOTECA_PROIBIDA: String = "biblioteca_proibida"
const RELIC_FORJA_NEGRA: String = "forja_negra"
const RELIC_PACTO_DAS_RUINAS: String = "pacto_das_ruinas"
const DEFAULT_PLAYER_NAME: String = "Comandante Draxos"
const MIN_PLAYER_NAME_LENGTH: int = 2
const MAX_PLAYER_NAME_LENGTH: int = 18
const SNAPSHOT_VERSION: int = 5
const TRACK_02_CONTRACT_ID: String = "track_02_complete_run_evolution"
const TRACK_02_ROUTE_STATUS_CONTRACT_ONLY: String = "implemented"
const TRACK_02_TARGET_MAP_COUNT: int = 29
const TRACK_02_CURRENT_ROUTE_MAP_COUNT: int = 29
const TRACK_02_MAX_MANA_CAP: int = 6
const TRACK_02_MAX_HAND_SIZE_CAP: int = 5
const TRACK_02_SHOP_SCHEMA_VERSION: int = 1
const TRACK_02_REWARD_CATEGORY_SCHEMA_VERSION: int = 1

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
var max_mana_cap: int = TRACK_02_MAX_MANA_CAP
var max_hand_size_cap: int = TRACK_02_MAX_HAND_SIZE_CAP
var soul_total: int = 0
var class_passive_unlocked: bool = false
var class_active_unlocked: bool = false
var class_active_level: int = 0
var relic_ids: Array[String] = []
var shop_state: Dictionary = {}
var reward_category_state: Dictionary = {}
var reroll_count: int = 0
var route_metadata: Dictionary = {}
var rewards_pending: Array[Dictionary] = []
var applied_reward_ids: Array[String] = []
var automatic_reward_ids: Array[String] = []
var card_upgrade_counts: Dictionary = {}
var shop_upgrade_offer_card_ids: Array[String] = []
var shop_upgrade_refresh_node_id: String = ""
var shop_upgrade_purchase_node_id: String = ""
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
	max_mana_cap = TRACK_02_MAX_MANA_CAP
	max_hand_size_cap = TRACK_02_MAX_HAND_SIZE_CAP
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	class_active_level = 0
	relic_ids = []
	shop_upgrade_offer_card_ids = []
	shop_upgrade_refresh_node_id = ""
	shop_upgrade_purchase_node_id = ""
	shop_state = _default_shop_state()
	reward_category_state = _default_reward_category_state()
	reroll_count = 0
	route_metadata = _default_route_metadata()
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
	max_mana_cap = TRACK_02_MAX_MANA_CAP
	max_hand_size_cap = TRACK_02_MAX_HAND_SIZE_CAP
	max_mana = mini(int(class_option.get("starting_mana", 2)), max_mana_cap)
	max_hand_size = mini(int(class_option.get("starting_hand_size", DEFAULT_MAX_HAND_SIZE)), max_hand_size_cap)
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	class_active_level = 0
	relic_ids = []
	shop_upgrade_offer_card_ids = []
	shop_upgrade_refresh_node_id = ""
	shop_upgrade_purchase_node_id = ""
	shop_state = _default_shop_state()
	reward_category_state = _default_reward_category_state()
	reroll_count = 0
	route_metadata = _default_route_metadata()
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
	max_mana_cap = TRACK_02_MAX_MANA_CAP
	max_hand_size_cap = TRACK_02_MAX_HAND_SIZE_CAP
	soul_total = 0
	class_passive_unlocked = false
	class_active_unlocked = false
	class_active_level = 0
	relic_ids = []
	shop_upgrade_offer_card_ids = []
	shop_upgrade_refresh_node_id = ""
	shop_upgrade_purchase_node_id = ""
	shop_state = _default_shop_state()
	reward_category_state = _default_reward_category_state()
	reroll_count = 0
	route_metadata = _default_route_metadata()
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

func record_battle_result(node_id: String, outcome: String, remaining_health: int, bonus_souls: int = 0) -> Dictionary:
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
		if has_relic_id(RELIC_BOLSA_DE_CINZAS):
			souls_gained += 3
		souls_gained += max(0, bonus_souls)
		soul_total += souls_gained
		applied_rewards = _apply_automatic_rewards_for_node(node_id)
		_queue_choice_rewards_for_node(node_id)
		if rewards_pending.is_empty():
			refresh_shop_upgrade_offers()
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
			return _reward_choices_for_pending(pending)
		CHOICE_REWARD_NEW_CARD:
			return _reward_choices_for_pending(pending)
		CHOICE_REWARD_RELIC:
			return _reward_choices_for_pending(pending)
		CHOICE_REWARD_UTILITY:
			return _reward_choices_for_pending(pending)
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
			for _copy_index: int in range(_extra_upgrade_copies_for_rarity(str(selected.get("rarity", REWARD_RARITY_COMMON)))):
				current_deck_ids.append(card_id)
			if has_relic_id(RELIC_FORJA_NEGRA):
				current_health = mini(max_health, current_health + _modified_heal_amount(4))
		CHOICE_REWARD_NEW_CARD:
			var new_card_id: String = str(selected.get("card_id", ""))
			for _copy_index: int in range(_new_card_copies_for_rarity(str(selected.get("rarity", REWARD_RARITY_COMMON)))):
				current_deck_ids.append(new_card_id)
		CHOICE_REWARD_RELIC:
			var relic_id: String = str(selected.get("relic_id", ""))
			if relic_id == "":
				return {"ok": false, "message": "Reliquia invalida."}
			var relic_result: Dictionary = add_relic_id(relic_id)
			if not bool(relic_result.get("ok", false)):
				return relic_result
		CHOICE_REWARD_UTILITY:
			var utility_result: Dictionary = _apply_utility_reward_choice(selected)
			if not bool(utility_result.get("ok", false)):
				return utility_result
		_:
			return {"ok": false, "message": "Tipo de recompensa invalido: %s" % str(pending.get("type", ""))}
	rewards_pending.remove_at(0)
	applied_reward_ids.append("%s:%s" % [str(pending.get("id", "")), choice_id])
	_update_pending_reward_category_state()
	if rewards_pending.is_empty():
		refresh_shop_upgrade_offers()
	return {"ok": true, "message": _reward_choice_message(selected)}

func refresh_shop_upgrade_offers() -> void:
	refresh_shop_inventory()

func refresh_shop_inventory() -> void:
	if not active:
		return
	var refresh_id: String = last_completed_node_id
	if refresh_id == "" and not completed_node_ids.is_empty():
		refresh_id = completed_node_ids[completed_node_ids.size() - 1]
	if refresh_id == "" and current_node_id != "":
		refresh_id = current_node_id
	if refresh_id == "":
		return
	var candidates: Array[String] = _shop_upgrade_candidates()
	candidates = _stable_shuffled_strings(candidates, "shop_upgrade:%s:%d:%d" % [refresh_id, completed_node_ids.size(), reroll_count])
	shop_upgrade_offer_card_ids = []
	for card_id: String in candidates:
		shop_upgrade_offer_card_ids.append(card_id)
		if shop_upgrade_offer_card_ids.size() >= SHOP_UPGRADE_OFFER_COUNT:
			break
	shop_upgrade_refresh_node_id = refresh_id
	shop_upgrade_purchase_node_id = ""
	var card_offer_ids: Array[String] = _stable_shuffled_strings(_shop_card_candidates(), "shop_card:%s:%d:%d" % [refresh_id, completed_node_ids.size(), reroll_count])
	var card_rarities: Dictionary = {}
	var trimmed_card_offer_ids: Array[String] = []
	for card_id: String in card_offer_ids:
		trimmed_card_offer_ids.append(card_id)
		card_rarities[card_id] = _roll_rarity("shop:%s:%d" % [refresh_id, reroll_count], card_id)
		if trimmed_card_offer_ids.size() >= SHOP_CARD_OFFER_COUNT:
			break
	var relic_offer_ids: Array[String] = _stable_shuffled_strings(_shop_relic_candidates(), "shop_relic:%s:%d:%d" % [refresh_id, completed_node_ids.size(), reroll_count])
	var trimmed_relic_offer_ids: Array[String] = []
	for relic_id: String in relic_offer_ids:
		trimmed_relic_offer_ids.append(relic_id)
		if trimmed_relic_offer_ids.size() >= SHOP_RELIC_OFFER_COUNT:
			break
	_sync_shop_state(trimmed_card_offer_ids, card_rarities, trimmed_relic_offer_ids)

func shop_upgrade_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id: String in shop_upgrade_offer_card_ids:
		if int(card_upgrade_counts.get(card_id, 0)) >= 2:
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var upgrade_index: int = int(card_upgrade_counts.get(card_id, 0)) + 1
		result.append({
			"id": "shop_upgrade:%s" % card_id,
			"card_id": card_id,
			"title": "%s - Lvl %d" % [str(card.display_name), upgrade_index + 1],
			"body": _upgrade_choice_body(card_id, upgrade_index),
			"cost": _shop_upgrade_cost(),
			"can_buy": can_buy_shop_upgrade(card_id)
		})
	return result

func can_buy_shop_upgrade(card_id: String) -> bool:
	return active \
		and soul_total >= _shop_upgrade_cost() \
		and shop_upgrade_refresh_node_id != "" \
		and shop_upgrade_purchase_node_id != shop_upgrade_refresh_node_id \
		and shop_upgrade_offer_card_ids.has(card_id) \
		and int(card_upgrade_counts.get(card_id, 0)) < 2

func buy_shop_card_upgrade(card_id: String) -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if shop_upgrade_purchase_node_id == shop_upgrade_refresh_node_id and shop_upgrade_refresh_node_id != "":
		return {"ok": false, "message": "Upgrade da loja ja comprado neste combate."}
	if not shop_upgrade_offer_card_ids.has(card_id):
		return {"ok": false, "message": "Carta nao esta nas ofertas da loja."}
	if int(card_upgrade_counts.get(card_id, 0)) >= 2:
		return {"ok": false, "message": "Carta ja esta no nivel maximo."}
	var cost: int = _shop_upgrade_cost()
	if soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para upgrade."}
	soul_total -= cost
	card_upgrade_counts[card_id] = mini(2, int(card_upgrade_counts.get(card_id, 0)) + 1)
	shop_upgrade_purchase_node_id = shop_upgrade_refresh_node_id
	_sync_shop_state()
	return {"ok": true, "message": "Upgrade comprado: %s." % ContentLibrary.get_card_name(card_id)}

func can_buy_heal() -> bool:
	return active and soul_total >= PAID_HEAL_COST and current_health < max_health and _modified_heal_amount(PAID_HEAL_AMOUNT) > 0

func buy_paid_heal() -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if current_health >= max_health:
		return {"ok": false, "message": "%s ja esta com vida cheia." % player_display_name()}
	if soul_total < PAID_HEAL_COST:
		return {"ok": false, "message": "Almas insuficientes para cura."}
	soul_total -= PAID_HEAL_COST
	var heal_amount: int = _modified_heal_amount(PAID_HEAL_AMOUNT)
	current_health = mini(max_health, current_health + heal_amount)
	return {"ok": true, "message": "Cura paga aplicada: +%d vida por %d almas." % [heal_amount, PAID_HEAL_COST]}

func shop_remove_card_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id: String in _unique_current_deck_card_ids():
		result.append({
			"id": "shop_remove:%s" % card_id,
			"card_id": card_id,
			"title": "Remover %s" % ContentLibrary.get_card_name(card_id),
			"body": "Remove 1 copia desta carta do deck da run.",
			"cost": _shop_remove_card_cost(),
			"can_buy": can_buy_shop_remove_card(card_id)
		})
	return result

func can_buy_shop_remove_card(card_id: String) -> bool:
	return active and current_deck_ids.has(card_id) and soul_total >= _shop_remove_card_cost()

func buy_shop_remove_card(card_id: String) -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if not current_deck_ids.has(card_id):
		return {"ok": false, "message": "Carta nao existe no deck da run."}
	var cost: int = _shop_remove_card_cost()
	if soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para remover carta."}
	soul_total -= cost
	current_deck_ids.erase(card_id)
	if cost == 0 and has_relic_id(RELIC_FERRAMENTAS_DE_CIRURGIA):
		shop_state["free_remove_card_used"] = true
	return {"ok": true, "message": "Carta removida: %s." % ContentLibrary.get_card_name(card_id)}

func shop_duplicate_card_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id: String in _unique_current_deck_card_ids():
		result.append({
			"id": "shop_duplicate:%s" % card_id,
			"card_id": card_id,
			"title": "Duplicar %s" % ContentLibrary.get_card_name(card_id),
			"body": "Adiciona 1 copia desta carta ao deck da run.",
			"cost": _shop_duplicate_card_cost(),
			"can_buy": can_buy_shop_duplicate_card(card_id)
		})
	return result

func can_buy_shop_duplicate_card(card_id: String) -> bool:
	return active and ContentLibrary.get_card(card_id) != null and current_deck_ids.has(card_id) and soul_total >= _shop_duplicate_card_cost()

func buy_shop_duplicate_card(card_id: String) -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if not current_deck_ids.has(card_id) or ContentLibrary.get_card(card_id) == null:
		return {"ok": false, "message": "Carta invalida para duplicacao."}
	var cost: int = _shop_duplicate_card_cost()
	if soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para duplicar carta."}
	soul_total -= cost
	current_deck_ids.append(card_id)
	if cost < SHOP_DUPLICATE_CARD_COST and has_relic_id(RELIC_LAMINA_DE_RESERVA):
		shop_state["discount_duplicate_used"] = true
	return {"ok": true, "message": "Carta duplicada: %s." % ContentLibrary.get_card_name(card_id)}

func shop_card_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var card_offer_ids: Array[String] = _string_array(shop_state.get("card_offer_ids", []))
	var rarity_by_id: Dictionary = Dictionary(shop_state.get("card_offer_rarity_by_id", {}))
	var purchased: Array[String] = _string_array(shop_state.get("purchased_card_offer_ids", []))
	for card_id: String in card_offer_ids:
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var rarity: String = str(rarity_by_id.get(card_id, REWARD_RARITY_COMMON))
		result.append({
			"id": "shop_card:%s" % card_id,
			"card_id": card_id,
			"rarity": rarity,
			"title": "%s%s" % [_rarity_title_prefix(rarity), str(card.display_name)],
			"body": "Compra 1 copia para o deck da run.",
			"cost": _shop_card_cost_for_rarity(rarity),
			"can_buy": can_buy_shop_card(card_id),
			"purchased": purchased.has(card_id)
		})
	return result

func can_buy_shop_card(card_id: String) -> bool:
	var purchased: Array[String] = _string_array(shop_state.get("purchased_card_offer_ids", []))
	if purchased.has(card_id):
		return false
	var rarity_by_id: Dictionary = Dictionary(shop_state.get("card_offer_rarity_by_id", {}))
	var rarity: String = str(rarity_by_id.get(card_id, REWARD_RARITY_COMMON))
	return active and _string_array(shop_state.get("card_offer_ids", [])).has(card_id) and ContentLibrary.get_card(card_id) != null and soul_total >= _shop_card_cost_for_rarity(rarity)

func buy_shop_card(card_id: String) -> Dictionary:
	if not can_buy_shop_card(card_id):
		return {"ok": false, "message": "Carta indisponivel ou Almas insuficientes."}
	var rarity_by_id: Dictionary = Dictionary(shop_state.get("card_offer_rarity_by_id", {}))
	var rarity: String = str(rarity_by_id.get(card_id, REWARD_RARITY_COMMON))
	var cost: int = _shop_card_cost_for_rarity(rarity)
	soul_total -= cost
	current_deck_ids.append(card_id)
	var purchased: Array[String] = _string_array(shop_state.get("purchased_card_offer_ids", []))
	if not purchased.has(card_id):
		purchased.append(card_id)
	shop_state["purchased_card_offer_ids"] = purchased
	return {"ok": true, "message": "Carta comprada: %s." % ContentLibrary.get_card_name(card_id)}

func shop_relic_choices() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for relic_id: String in _string_array(shop_state.get("relic_offer_ids", [])):
		var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
		if relic.is_empty():
			continue
		var rarity: String = str(relic.get("rarity", "common"))
		result.append({
			"id": "shop_relic:%s" % relic_id,
			"relic_id": relic_id,
			"rarity": rarity,
			"title": _relic_title(relic),
			"body": _relic_body(relic),
			"cost": _shop_relic_cost_for_rarity(rarity),
			"can_buy": can_buy_shop_relic(relic_id),
			"owned": has_relic_id(relic_id)
		})
	return result

func can_buy_shop_relic(relic_id: String) -> bool:
	var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
	if relic.is_empty() or has_relic_id(relic_id):
		return false
	return active and _string_array(shop_state.get("relic_offer_ids", [])).has(relic_id) and soul_total >= _shop_relic_cost_for_rarity(str(relic.get("rarity", "common")))

func buy_shop_relic(relic_id: String) -> Dictionary:
	if not can_buy_shop_relic(relic_id):
		return {"ok": false, "message": "Reliquia indisponivel ou Almas insuficientes."}
	var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
	var cost: int = _shop_relic_cost_for_rarity(str(relic.get("rarity", "common")))
	var relic_result: Dictionary = add_relic_id(relic_id)
	if not bool(relic_result.get("ok", false)):
		return relic_result
	soul_total -= cost
	return {"ok": true, "message": "Reliquia comprada: %s." % ContentLibrary.get_relic_display_name(relic_id)}

func current_reroll_cost() -> int:
	return SHOP_REROLL_COST_BASE + (SHOP_REROLL_COST_STEP * maxi(0, reroll_count))

func buy_shop_reroll() -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	var cost: int = current_reroll_cost()
	if soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para reroll da loja."}
	soul_total -= cost
	reroll_count += 1
	refresh_shop_inventory()
	return {"ok": true, "message": "Loja rerolada por %d almas." % cost}

func buy_reward_reroll() -> Dictionary:
	if not active or rewards_pending.is_empty():
		return {"ok": false, "message": "Nenhuma recompensa pendente para reroll."}
	var cost: int = current_reroll_cost()
	if soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para reroll de recompensa."}
	soul_total -= cost
	reroll_count += 1
	var pending: Dictionary = rewards_pending[0]
	pending["reroll_index"] = int(pending.get("reroll_index", 0)) + 1
	pending["rarity_by_card_id"] = _rarity_map_for_pending(pending)
	rewards_pending[0] = pending
	return {"ok": true, "message": "Recompensa rerolada por %d almas." % cost}

func can_buy_shop_max_health() -> bool:
	return active and _shop_max_health_purchase_count() < SHOP_MAX_HEALTH_PURCHASE_LIMIT and soul_total >= _shop_max_health_cost()

func buy_shop_max_health() -> Dictionary:
	if not active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	var purchase_count: int = _shop_max_health_purchase_count()
	if purchase_count >= SHOP_MAX_HEALTH_PURCHASE_LIMIT:
		return {"ok": false, "message": "Limite de HP maximo da loja atingido."}
	var cost: int = _shop_max_health_cost()
	if soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para HP maximo."}
	soul_total -= cost
	shop_state["max_health_purchases"] = purchase_count + 1
	_increase_max_health(SHOP_MAX_HEALTH_AMOUNT)
	return {"ok": true, "message": "HP maximo aumentado em +%d." % SHOP_MAX_HEALTH_AMOUNT}

func has_relic_id(relic_id: String) -> bool:
	return relic_ids.has(relic_id)

func add_relic_id(relic_id: String) -> Dictionary:
	if relic_id == "":
		return {"ok": false, "message": "Reliquia invalida."}
	if not _is_known_relic_id(relic_id):
		return {"ok": false, "message": "Reliquia desconhecida: %s." % relic_id}
	if relic_ids.has(relic_id):
		return {"ok": false, "message": "Reliquia ja registrada: %s." % relic_id}
	relic_ids.append(relic_id)
	_apply_relic_pickup_effect(relic_id)
	return {"ok": true, "message": "Reliquia registrada: %s." % ContentLibrary.get_relic_display_name(relic_id)}

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
		"max_mana_cap": max_mana_cap,
		"max_hand_size_cap": max_hand_size_cap,
		"soul_total": soul_total,
		"class_passive_unlocked": class_passive_unlocked,
		"class_active_unlocked": class_active_unlocked,
		"class_active_level": class_active_level,
		"relic_ids": relic_ids.duplicate(),
		"shop_state": shop_state.duplicate(true),
		"reward_category_state": reward_category_state.duplicate(true),
		"reroll_count": reroll_count,
		"route_metadata": route_metadata.duplicate(true),
		"rewards_pending": rewards_pending.duplicate(),
		"applied_reward_ids": applied_reward_ids.duplicate(),
		"automatic_reward_ids": automatic_reward_ids.duplicate(),
		"card_upgrade_counts": card_upgrade_counts.duplicate(),
		"shop_upgrade_offer_card_ids": shop_upgrade_offer_card_ids.duplicate(),
		"shop_upgrade_refresh_node_id": shop_upgrade_refresh_node_id,
		"shop_upgrade_purchase_node_id": shop_upgrade_purchase_node_id,
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
	max_mana_cap = int(data.get("max_mana_cap", TRACK_02_MAX_MANA_CAP))
	if max_mana_cap <= 0:
		max_mana_cap = TRACK_02_MAX_MANA_CAP
	max_hand_size_cap = int(data.get("max_hand_size_cap", TRACK_02_MAX_HAND_SIZE_CAP))
	if max_hand_size_cap <= 0:
		max_hand_size_cap = TRACK_02_MAX_HAND_SIZE_CAP
	max_mana = mini(max_mana, max_mana_cap)
	max_hand_size = mini(max_hand_size, max_hand_size_cap)
	soul_total = int(data.get("soul_total", 0))
	class_passive_unlocked = bool(data.get("class_passive_unlocked", false))
	class_active_unlocked = bool(data.get("class_active_unlocked", false))
	class_active_level = int(data.get("class_active_level", -1))
	if class_active_level < 0:
		class_active_level = 2 if selected_class_id == "necromante" and class_active_unlocked else 0
	relic_ids = _string_array(data.get("relic_ids", []))
	shop_state = _dictionary_with_defaults(_default_shop_state(), Dictionary(data.get("shop_state", {})))
	reward_category_state = _dictionary_with_defaults(_default_reward_category_state(), Dictionary(data.get("reward_category_state", {})))
	reroll_count = maxi(0, int(data.get("reroll_count", 0)))
	route_metadata = _dictionary_with_defaults(_default_route_metadata(), Dictionary(data.get("route_metadata", {})))
	rewards_pending = _pending_reward_array(data.get("rewards_pending", []))
	applied_reward_ids = _string_array(data.get("applied_reward_ids", []))
	automatic_reward_ids = _string_array(data.get("automatic_reward_ids", []))
	card_upgrade_counts = Dictionary(data.get("card_upgrade_counts", {}))
	shop_upgrade_offer_card_ids = _string_array(data.get("shop_upgrade_offer_card_ids", []))
	shop_upgrade_refresh_node_id = str(data.get("shop_upgrade_refresh_node_id", ""))
	shop_upgrade_purchase_node_id = str(data.get("shop_upgrade_purchase_node_id", ""))
	last_completed_node_id = str(data.get("last_completed_node_id", ""))
	last_battle_outcome = str(data.get("last_battle_outcome", ""))
	_sync_track_01_shop_state()
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
		REWARD_MAX_HEALTH_5:
			return "+5 Vida maxima"
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
		REWARD_ADD_RELIC_PLACEHOLDER:
			return "Reliquia registrada"
		REWARD_GRANT_REMAINING_CARD:
			return "Carta restante adicionada ao deck"
		REWARD_COMPLETE_RUN_VICTORY:
			return "Vitoria da run completa"
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

func _reward_schedule_entry_for_node(node_id: String) -> Dictionary:
	var node: Dictionary = _run_node(node_id)
	if node.is_empty():
		return {}
	var map_index: int = int(node.get("map_index", 0))
	if map_index <= 0:
		map_index = _map_index_for_node_id(node_id)
	if map_index <= 0:
		return {}
	return ContentLibrary.find_reward_schedule_entry(map_index)

func _map_index_for_node_id(node_id: String) -> int:
	var nodes: Array = Array(ContentLibrary.get_run_map().get("nodes", []))
	for index: int in range(nodes.size()):
		var node: Dictionary = Dictionary(nodes[index])
		if str(node.get("id", "")) == node_id:
			return index + 1
	return 0

func _automatic_reward_ids_for_node(node: Dictionary, schedule_entry: Dictionary) -> Array[String]:
	var result: Array[String] = []
	if schedule_entry.is_empty():
		return _string_array(node.get("rewards", []))
	result = _string_array(schedule_entry.get("automatic_rewards", []))
	var relic_reward: Dictionary = Dictionary(schedule_entry.get("relic_reward", {}))
	if str(relic_reward.get("mode", "")) in ["grant", "placeholder_grant"] and not result.has(REWARD_ADD_RELIC_PLACEHOLDER):
		result.append(REWARD_ADD_RELIC_PLACEHOLDER)
	return result

func _increase_max_health(amount: int) -> void:
	var delta: int = maxi(0, amount)
	max_health += delta
	current_health = mini(max_health, current_health + delta)

func _placeholder_relic_id_for_entry(schedule_entry: Dictionary, node_id: String) -> String:
	var relic_reward: Dictionary = Dictionary(schedule_entry.get("relic_reward", {}))
	var relic_id: String = str(relic_reward.get("id", ""))
	if relic_id != "" and not relic_ids.has(relic_id):
		return relic_id
	var fallback: String = _first_available_relic_id_for_rarity_label(str(relic_reward.get("rarity", "common")), node_id)
	if fallback != "":
		return fallback
	return "placeholder_relic_%s" % node_id

func _grant_remaining_reward_card(schedule_entry: Dictionary, node_id: String) -> bool:
	var pool: Array[String] = _class_reward_pool_for_context(schedule_entry)
	if pool.is_empty():
		return false
	for card_id: String in pool:
		if current_deck_ids.has(card_id):
			continue
		if ContentLibrary.get_card(card_id) == null:
			continue
		var rarity: String = _roll_rarity("%s:%s" % [node_id, REWARD_GRANT_REMAINING_CARD], card_id)
		for _copy_index: int in range(_new_card_copies_for_rarity(rarity)):
			current_deck_ids.append(card_id)
		return true
	return false

func _mark_reward_category_completed(node_id: String, schedule_entry: Dictionary) -> void:
	if schedule_entry.is_empty():
		return
	if reward_category_state.is_empty():
		reward_category_state = _default_reward_category_state()
	var category: String = str(schedule_entry.get("category", ""))
	if category == "":
		return
	var completed: Dictionary = Dictionary(reward_category_state.get("completed_categories_by_node", {}))
	if completed.has(node_id):
		reward_category_state["completed_categories_by_node"] = completed
		return
	completed[node_id] = category
	reward_category_state["completed_categories_by_node"] = completed
	var counts: Dictionary = Dictionary(reward_category_state.get("category_counts", {}))
	counts[category] = int(counts.get(category, 0)) + 1
	reward_category_state["category_counts"] = counts

func _update_pending_reward_category_state() -> void:
	if reward_category_state.is_empty():
		reward_category_state = _default_reward_category_state()
	if rewards_pending.is_empty():
		reward_category_state["pending_category"] = ""
		return
	var pending: Dictionary = rewards_pending[0]
	reward_category_state["pending_category"] = str(pending.get("category", pending.get("type", "")))

func _apply_automatic_rewards_for_node(node_id: String) -> Array[String]:
	var applied: Array[String] = []
	var node: Dictionary = _run_node(node_id)
	var schedule_entry: Dictionary = _reward_schedule_entry_for_node(node_id)
	for reward_id: String in _automatic_reward_ids_for_node(node, schedule_entry):
		var applied_id: String = "%s:%s" % [node_id, reward_id]
		if automatic_reward_ids.has(applied_id):
			continue
		match reward_id:
			REWARD_MAX_MANA_1:
				max_mana = mini(max_mana + 1, max_mana_cap)
			REWARD_MAX_HAND_SIZE_1:
				max_hand_size = mini(max_hand_size + 1, max_hand_size_cap)
			REWARD_MAX_HEALTH_5:
				_increase_max_health(int(schedule_entry.get("max_health_delta", 5)))
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
			REWARD_ADD_RELIC_PLACEHOLDER:
				var relic_id: String = _placeholder_relic_id_for_entry(schedule_entry, node_id)
				if relic_id == "" or relic_ids.has(relic_id):
					continue
				var relic_result: Dictionary = add_relic_id(relic_id)
				if not bool(relic_result.get("ok", false)):
					continue
			REWARD_GRANT_REMAINING_CARD:
				if not _grant_remaining_reward_card(schedule_entry, node_id):
					continue
			REWARD_COMPLETE_RUN_VICTORY:
				route_metadata["victory_node_id"] = node_id
				route_metadata["completed_run"] = true
			_:
				continue
		automatic_reward_ids.append(applied_id)
		applied.append(reward_id)
	_mark_reward_category_completed(node_id, schedule_entry)
	return applied

func _queue_choice_rewards_for_node(node_id: String) -> void:
	var node: Dictionary = _run_node(node_id)
	var schedule_entry: Dictionary = _reward_schedule_entry_for_node(node_id)
	var reward: Dictionary = Dictionary(schedule_entry.get("choice_reward", node.get("choice_reward", {})))
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
	pending["category"] = str(schedule_entry.get("category", str(reward.get("type", ""))))
	pending["rarity_by_card_id"] = _rarity_map_for_pending(pending)
	if _reward_choices_for_pending(pending).is_empty():
		return
	rewards_pending.append(pending)
	_mark_reward_category_completed(node_id, schedule_entry)
	_update_pending_reward_category_state()

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

func _reward_choices_for_pending(pending: Dictionary) -> Array[Dictionary]:
	match str(pending.get("type", "")):
		CHOICE_REWARD_UPGRADE_CARD:
			return _upgrade_reward_choices(pending)
		CHOICE_REWARD_NEW_CARD:
			return _new_card_reward_choices(pending)
		CHOICE_REWARD_RELIC:
			return _relic_reward_choices(pending)
		CHOICE_REWARD_UTILITY:
			return _utility_reward_choices(pending)
	return []

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
			"rarity": _rarity_for_card(_pending, card_id),
			"title": "%s%s - Lvl %d" % [_rarity_title_prefix(_rarity_for_card(_pending, card_id)), str(card.display_name), upgrade_index + 1],
			"body": _upgrade_choice_body(card_id, upgrade_index, _rarity_for_card(_pending, card_id))
		})
		if result.size() >= 3:
			break
	return result

func _new_card_reward_choices(_pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var pool: Array[String] = _class_reward_pool_for_context(_pending)
	if pool.is_empty():
		return result
	for card_id: String in pool:
		if current_deck_ids.has(card_id):
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var rarity: String = _rarity_for_card(_pending, card_id)
		result.append({
			"id": "new_card:%s" % card_id,
			"card_id": card_id,
			"rarity": rarity,
			"title": "%s%s" % [_rarity_title_prefix(rarity), str(card.display_name)],
			"body": "Adiciona %d copias ao deck." % _new_card_copies_for_rarity(rarity)
		})
	return result

func _relic_reward_choices(pending: Dictionary) -> Array[Dictionary]:
	var rarity: String = str(pending.get("rarity", "standard"))
	var result: Array[Dictionary] = []
	var candidates: Array[String] = _stable_shuffled_strings(_relic_ids_for_rarity_label(rarity), "%s:%d" % [str(pending.get("id", "")), int(pending.get("reroll_index", 0))])
	for relic_id: String in candidates:
		if relic_ids.has(relic_id):
			continue
		var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
		if relic.is_empty():
			continue
		result.append({
			"id": "relic:%s" % relic_id,
			"relic_id": relic_id,
			"rarity": str(relic.get("rarity", "common")),
			"title": _relic_title(relic),
			"body": _relic_body(relic)
		})
		if result.size() >= 3:
			break
	return result

func _utility_reward_choices(_pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Array[String] = []
	for card_id: String in current_deck_ids:
		if seen.has(card_id):
			continue
		seen.append(card_id)
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		result.append({
			"id": "utility_remove:%s" % card_id,
			"utility": UTILITY_REWARD_REMOVE_CARD,
			"card_id": card_id,
			"title": "Remover %s" % str(card.display_name),
			"body": "Remove 1 copia desta carta do deck da run."
		})
		result.append({
			"id": "utility_duplicate:%s" % card_id,
			"utility": UTILITY_REWARD_DUPLICATE_CARD,
			"card_id": card_id,
			"title": "Duplicar %s" % str(card.display_name),
			"body": "Adiciona 1 copia desta carta ao deck da run."
		})
	for card_id: String in _shop_upgrade_candidates():
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var upgrade_index: int = int(card_upgrade_counts.get(card_id, 0)) + 1
		result.append({
			"id": "utility_upgrade:%s" % card_id,
			"utility": UTILITY_REWARD_UPGRADE_CARD,
			"card_id": card_id,
			"title": "Aprimorar %s - Lvl %d" % [str(card.display_name), upgrade_index + 1],
			"body": _upgrade_choice_body(card_id, upgrade_index)
		})
	return result

func _class_reward_pool() -> Array[String]:
	var class_option: Dictionary = ContentLibrary.find_class_option(selected_class_id)
	return _string_array(class_option.get("reward_pool", []))

func _class_reward_pool_for_context(context: Dictionary) -> Array[String]:
	var pool: Array[String] = _class_reward_pool()
	var offset: int = int(context.get("pool_offset", _pool_offset_for_element(str(context.get("element", "")))))
	var option_count: int = 3 if str(context.get("type", "")) == CHOICE_REWARD_NEW_CARD and has_relic_id(RELIC_BIBLIOTECA_PROIBIDA) else 2
	if offset <= 0:
		return pool.slice(0, mini(option_count, pool.size()))
	if offset >= pool.size():
		return []
	return pool.slice(offset, mini(offset + option_count, pool.size()))

func _pool_offset_for_element(element: String) -> int:
	match element:
		"gelo":
			return 2
		"ar":
			return 4
		"fogo":
			return 6
	return 0

func _upgrade_choice_body(card_id: String, upgrade_index: int, rarity: String = REWARD_RARITY_COMMON) -> String:
	var extra_copies: int = _extra_upgrade_copies_for_rarity(rarity)
	var suffix: String = "" if extra_copies <= 0 else " Adiciona +%d copia(s) da carta base." % extra_copies
	if upgrade_index <= 1:
		return "%s sobe para Lvl 2 em todas as copias da run.%s" % [ContentLibrary.get_card_name(card_id), suffix]
	return "%s sobe para Lvl 3 em todas as copias da run.%s" % [ContentLibrary.get_card_name(card_id), suffix]

func _reward_choice_message(choice: Dictionary) -> String:
	if str(choice.get("id", "")).begins_with("upgrade:"):
		return "Upgrade aplicado: %s." % str(choice.get("title", ""))
	if str(choice.get("id", "")).begins_with("new_card:"):
		return "Carta adicionada ao deck: %s x%d." % [str(choice.get("title", "")), _new_card_copies_for_rarity(str(choice.get("rarity", REWARD_RARITY_COMMON)))]
	if str(choice.get("id", "")).begins_with("relic:"):
		return "Reliquia registrada: %s." % str(choice.get("title", ""))
	if str(choice.get("id", "")).begins_with("utility_"):
		return "Utilidade aplicada: %s." % str(choice.get("title", ""))
	return "Recompensa aplicada."

func _apply_utility_reward_choice(choice: Dictionary) -> Dictionary:
	var card_id: String = str(choice.get("card_id", ""))
	if card_id == "":
		return {"ok": false, "message": "Carta invalida para utilidade."}
	match str(choice.get("utility", "")):
		UTILITY_REWARD_REMOVE_CARD:
			if not current_deck_ids.has(card_id):
				return {"ok": false, "message": "Carta nao existe no deck da run."}
			current_deck_ids.erase(card_id)
		UTILITY_REWARD_DUPLICATE_CARD:
			if ContentLibrary.get_card(card_id) == null:
				return {"ok": false, "message": "Carta invalida para duplicacao."}
			current_deck_ids.append(card_id)
		UTILITY_REWARD_UPGRADE_CARD:
			if int(card_upgrade_counts.get(card_id, 0)) >= 2:
				return {"ok": false, "message": "Carta ja esta no nivel maximo."}
			card_upgrade_counts[card_id] = mini(2, int(card_upgrade_counts.get(card_id, 0)) + 1)
		_:
			return {"ok": false, "message": "Utilidade invalida."}
	return {"ok": true, "message": "Utilidade aplicada."}

func _rarity_map_for_pending(pending: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var type: String = str(pending.get("type", ""))
	var card_ids: Array[String] = []
	if type == CHOICE_REWARD_NEW_CARD:
		card_ids = _class_reward_pool_for_context(pending)
	elif type == CHOICE_REWARD_UPGRADE_CARD:
		card_ids = _shop_upgrade_candidates()
	for card_id: String in card_ids:
		result[card_id] = _roll_rarity(str(pending.get("id", "")), card_id)
	return result

func _rarity_for_card(pending: Dictionary, card_id: String) -> String:
	var rarity_by_card_id: Dictionary = Dictionary(pending.get("rarity_by_card_id", {}))
	return str(rarity_by_card_id.get(card_id, REWARD_RARITY_COMMON))

func _roll_rarity(pending_id: String, card_id: String) -> String:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var seed_text: String = "%d:%s:%s:%s:rarity" % [run_seed, selected_class_id, pending_id, card_id]
	rng.seed = absi(seed_text.hash())
	var roll: int = rng.randi_range(1, 100)
	if roll <= 5:
		return REWARD_RARITY_ULTRA
	if roll <= 30:
		return REWARD_RARITY_RARE
	return REWARD_RARITY_COMMON

func _rarity_title_prefix(rarity: String) -> String:
	match rarity:
		REWARD_RARITY_RARE:
			return "[Rara] "
		REWARD_RARITY_ULTRA:
			return "[Ultra rara] "
	return ""

func _rarity_from_schedule_label(rarity: String) -> String:
	match rarity:
		"rare", "rare_ultra":
			return REWARD_RARITY_RARE
		"ultra", "ultra_rare":
			return REWARD_RARITY_ULTRA
	return REWARD_RARITY_COMMON

func _new_card_copies_for_rarity(rarity: String) -> int:
	match rarity:
		REWARD_RARITY_RARE:
			return REWARD_CARD_COPY_COUNT + 1
		REWARD_RARITY_ULTRA:
			return REWARD_CARD_COPY_COUNT + 2 + (1 if has_relic_id(RELIC_NUCLEO_INSTAVEL) else 0)
	return REWARD_CARD_COPY_COUNT

func _extra_upgrade_copies_for_rarity(_rarity: String) -> int:
	# Track 02 tuning keeps upgrade rewards as level improvements only so the
	# 29-map route lands near the target final deck size.
	return 0

func _shop_upgrade_candidates() -> Array[String]:
	var result: Array[String] = []
	var seen: Array[String] = []
	for card_id: String in current_deck_ids:
		if seen.has(card_id):
			continue
		seen.append(card_id)
		if int(card_upgrade_counts.get(card_id, 0)) >= 2:
			continue
		if ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	return result

func _shop_card_candidates() -> Array[String]:
	var result: Array[String] = []
	var pool: Array[String] = _class_reward_pool()
	for card_id: String in pool:
		if result.has(card_id) or ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	for card_id: String in _unique_current_deck_card_ids():
		if result.has(card_id) or ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	return result

func _shop_relic_candidates() -> Array[String]:
	var result: Array[String] = []
	for relic: Variant in ContentLibrary.get_relic_definitions():
		if typeof(relic) != TYPE_DICTIONARY:
			continue
		var relic_id: String = str(Dictionary(relic).get("id", ""))
		if relic_id == "" or relic_ids.has(relic_id):
			continue
		result.append(relic_id)
	return result

func _unique_current_deck_card_ids() -> Array[String]:
	var result: Array[String] = []
	for card_id: String in current_deck_ids:
		if result.has(card_id):
			continue
		if ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	return result

func _shop_upgrade_cost() -> int:
	return SHOP_CARD_UPGRADE_COST

func _shop_remove_card_cost() -> int:
	if has_relic_id(RELIC_FERRAMENTAS_DE_CIRURGIA) and not bool(shop_state.get("free_remove_card_used", false)):
		return 0
	return SHOP_REMOVE_CARD_COST

func _shop_duplicate_card_cost() -> int:
	if has_relic_id(RELIC_LAMINA_DE_RESERVA) and not bool(shop_state.get("discount_duplicate_used", false)):
		return int(SHOP_DUPLICATE_CARD_COST / 2)
	return SHOP_DUPLICATE_CARD_COST

func _shop_card_cost_for_rarity(rarity: String) -> int:
	match rarity:
		REWARD_RARITY_RARE, "rare":
			return SHOP_BUY_RARE_CARD_COST
		REWARD_RARITY_ULTRA, "ultra_rare", "ultra":
			return SHOP_BUY_ULTRA_RARE_CARD_COST
	return SHOP_BUY_COMMON_CARD_COST

func _shop_relic_cost_for_rarity(rarity: String) -> int:
	match rarity:
		"rare", REWARD_RARITY_RARE:
			return SHOP_BUY_RARE_RELIC_COST
		"ultra_rare", "ultra", REWARD_RARITY_ULTRA:
			return SHOP_BUY_ULTRA_RARE_RELIC_COST
	return SHOP_BUY_COMMON_RELIC_COST

func _shop_max_health_purchase_count() -> int:
	if shop_state.is_empty():
		shop_state = _default_shop_state()
	return clampi(int(shop_state.get("max_health_purchases", 0)), 0, SHOP_MAX_HEALTH_PURCHASE_LIMIT)

func _shop_max_health_cost() -> int:
	return SHOP_MAX_HEALTH_FIRST_COST if _shop_max_health_purchase_count() <= 0 else SHOP_MAX_HEALTH_SECOND_COST

func _modified_heal_amount(amount: int) -> int:
	var value: int = maxi(0, amount)
	if value > 0 and has_relic_id(RELIC_PACTO_DAS_RUINAS):
		value = int(value / 2)
	return value

func _is_known_relic_id(relic_id: String) -> bool:
	if ContentLibrary.get_relic_definition(relic_id).is_empty():
		return relic_id.begins_with("placeholder_relic_")
	return true

func _apply_relic_pickup_effect(relic_id: String) -> void:
	match relic_id:
		RELIC_COURO_ASTRAL:
			_increase_max_health(3)
		RELIC_PACTO_DAS_RUINAS:
			_increase_max_health(10)

func _relic_ids_for_rarity_label(rarity: String) -> Array[String]:
	var rarity_ids: Array[String] = []
	match rarity:
		"common":
			rarity_ids = ["common"]
		"rare", "boss":
			rarity_ids = ["rare"]
		"ultra", "ultra_rare":
			rarity_ids = ["ultra_rare"]
		"rare_ultra":
			rarity_ids = ["rare", "ultra_rare"]
		_:
			rarity_ids = ["common", "rare"]
	var result: Array[String] = []
	for relic: Dictionary in ContentLibrary.get_relics_by_rarity(rarity_ids):
		var relic_id: String = str(relic.get("id", ""))
		if relic_id != "":
			result.append(relic_id)
	return result

func _first_available_relic_id_for_rarity_label(rarity: String, salt: String) -> String:
	for relic_id: String in _stable_shuffled_strings(_relic_ids_for_rarity_label(rarity), "auto_relic:%s:%s" % [rarity, salt]):
		if not relic_ids.has(relic_id):
			return relic_id
	return ""

func _relic_title(relic: Dictionary) -> String:
	return "%s%s" % [_rarity_title_prefix(_rarity_from_relic_label(str(relic.get("rarity", "common")))), str(relic.get("display_name", relic.get("id", "")))]

func _relic_body(relic: Dictionary) -> String:
	var effect: String = str(relic.get("effect_text", ""))
	var status: String = str(relic.get("effect_status", "implemented"))
	if status == "implemented":
		return effect
	return "%s\nEfeito pendente: %s." % [effect, status]

func _rarity_from_relic_label(rarity: String) -> String:
	match rarity:
		"rare":
			return REWARD_RARITY_RARE
		"ultra_rare":
			return REWARD_RARITY_ULTRA
	return REWARD_RARITY_COMMON

func _default_shop_state() -> Dictionary:
	var contract: Dictionary = ContentLibrary.get_track_contract()
	var schema: Dictionary = Dictionary(contract.get("shop_state_schema", {}))
	return {
		"schema_version": int(schema.get("version", TRACK_02_SHOP_SCHEMA_VERSION)),
		"expanded_shop_pending": bool(schema.get("expanded_shop_pending", true)),
		"refresh_node_id": shop_upgrade_refresh_node_id,
		"purchase_node_id": shop_upgrade_purchase_node_id,
		"upgrade_offer_card_ids": shop_upgrade_offer_card_ids.duplicate(),
		"card_offer_ids": [],
		"card_offer_rarity_by_id": {},
		"relic_offer_ids": [],
		"purchased_card_offer_ids": [],
		"max_health_purchases": 0,
		"free_remove_card_used": false,
		"discount_duplicate_used": false,
		"track_01_upgrade_cost": SHOP_CARD_UPGRADE_COST,
		"prices": _shop_prices_snapshot()
	}

func _default_reward_category_state() -> Dictionary:
	var contract: Dictionary = ContentLibrary.get_track_contract()
	var schema: Dictionary = Dictionary(contract.get("reward_category_state_schema", {}))
	return {
		"schema_version": int(schema.get("version", TRACK_02_REWARD_CATEGORY_SCHEMA_VERSION)),
		"schedule_pending": bool(schema.get("schedule_pending", true)),
		"schedule_version": int(schema.get("schedule_version", 1)),
		"pending_category": "",
		"completed_categories_by_node": {},
		"category_counts": {}
	}

func _default_route_metadata() -> Dictionary:
	var contract: Dictionary = ContentLibrary.get_track_contract()
	var route_contract: Dictionary = Dictionary(contract.get("route", {}))
	var run_map: Dictionary = ContentLibrary.get_run_map()
	var active_count: int = Array(run_map.get("nodes", [])).size()
	return {
		"track_id": str(contract.get("id", TRACK_02_CONTRACT_ID)),
		"metadata_version": int(route_contract.get("metadata_version", 1)),
		"route_id": str(run_map.get("id", "")),
		"route_display_name": str(run_map.get("display_name", "")),
		"status": str(route_contract.get("status", TRACK_02_ROUTE_STATUS_CONTRACT_ONLY)),
		"linear": bool(run_map.get("linear", true)),
		"active_map_count": int(route_contract.get("active_map_count", active_count)),
		"target_map_count": int(route_contract.get("target_map_count", TRACK_02_TARGET_MAP_COUNT))
	}

func _sync_track_01_shop_state() -> void:
	_sync_shop_state()

func _sync_shop_state(card_offer_ids: Array = [], card_rarities: Dictionary = {}, relic_offer_ids: Array = []) -> void:
	if shop_state.is_empty():
		shop_state = _default_shop_state()
	if card_offer_ids.is_empty() and shop_state.has("card_offer_ids"):
		card_offer_ids = _string_array(shop_state.get("card_offer_ids", []))
	if card_rarities.is_empty() and shop_state.has("card_offer_rarity_by_id"):
		card_rarities = Dictionary(shop_state.get("card_offer_rarity_by_id", {}))
	if relic_offer_ids.is_empty() and shop_state.has("relic_offer_ids"):
		relic_offer_ids = _string_array(shop_state.get("relic_offer_ids", []))
	shop_state["refresh_node_id"] = shop_upgrade_refresh_node_id
	shop_state["purchase_node_id"] = shop_upgrade_purchase_node_id
	shop_state["upgrade_offer_card_ids"] = shop_upgrade_offer_card_ids.duplicate()
	shop_state["card_offer_ids"] = card_offer_ids.duplicate()
	shop_state["card_offer_rarity_by_id"] = card_rarities.duplicate()
	shop_state["relic_offer_ids"] = relic_offer_ids.duplicate()
	if not shop_state.has("purchased_card_offer_ids"):
		shop_state["purchased_card_offer_ids"] = []
	if not shop_state.has("max_health_purchases"):
		shop_state["max_health_purchases"] = 0
	if not shop_state.has("free_remove_card_used"):
		shop_state["free_remove_card_used"] = false
	if not shop_state.has("discount_duplicate_used"):
		shop_state["discount_duplicate_used"] = false
	shop_state["expanded_shop_pending"] = false
	shop_state["track_01_upgrade_cost"] = SHOP_CARD_UPGRADE_COST
	shop_state["prices"] = _shop_prices_snapshot()

func _shop_prices_snapshot() -> Dictionary:
	return {
		"heal": SHOP_HEAL_COST,
		"remove_card": SHOP_REMOVE_CARD_COST,
		"duplicate_card": SHOP_DUPLICATE_CARD_COST,
		"upgrade_card": SHOP_CARD_UPGRADE_COST,
		"buy_card_common": SHOP_BUY_COMMON_CARD_COST,
		"buy_card_rare": SHOP_BUY_RARE_CARD_COST,
		"buy_card_ultra_rare": SHOP_BUY_ULTRA_RARE_CARD_COST,
		"buy_relic_common": SHOP_BUY_COMMON_RELIC_COST,
		"buy_relic_rare": SHOP_BUY_RARE_RELIC_COST,
		"buy_relic_ultra_rare": SHOP_BUY_ULTRA_RARE_RELIC_COST,
		"reroll_base": SHOP_REROLL_COST_BASE,
		"reroll_step": SHOP_REROLL_COST_STEP,
		"max_health_first": SHOP_MAX_HEALTH_FIRST_COST,
		"max_health_second": SHOP_MAX_HEALTH_SECOND_COST
	}

func _dictionary_with_defaults(defaults: Dictionary, source: Dictionary) -> Dictionary:
	var result: Dictionary = defaults.duplicate(true)
	for key: Variant in source.keys():
		result[key] = source[key]
	return result

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
