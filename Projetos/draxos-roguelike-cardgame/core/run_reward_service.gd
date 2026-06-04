extends RefCounted

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
const RELIC_NUCLEO_INSTAVEL: String = "nucleo_instavel"
const RELIC_BIBLIOTECA_PROIBIDA: String = "biblioteca_proibida"
const RELIC_FORJA_NEGRA: String = "forja_negra"

static func pending_reward_choices(session) -> Array[Dictionary]:
	var pending: Dictionary = session.current_pending_reward()
	if pending.is_empty():
		return []
	match str(pending.get("type", "")):
		CHOICE_REWARD_UPGRADE_CARD:
			return reward_choices_for_pending(session, pending)
		CHOICE_REWARD_NEW_CARD:
			return reward_choices_for_pending(session, pending)
		CHOICE_REWARD_RELIC:
			return reward_choices_for_pending(session, pending)
		CHOICE_REWARD_UTILITY:
			return reward_choices_for_pending(session, pending)
	return []

static func apply_reward_choice(session, choice_id: String) -> Dictionary:
	if session.rewards_pending.is_empty():
		return {"ok": false, "message": "Nenhuma recompensa pendente."}
	var pending: Dictionary = session.rewards_pending[0]
	var choices: Array[Dictionary] = pending_reward_choices(session)
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
			session.card_upgrade_counts[card_id] = mini(2, int(session.card_upgrade_counts.get(card_id, 0)) + 1)
			for _copy_index: int in range(extra_upgrade_copies_for_rarity(str(selected.get("rarity", REWARD_RARITY_COMMON)))):
				session.current_deck_ids.append(card_id)
			if session.has_relic_id(RELIC_FORJA_NEGRA):
				session.current_health = mini(session.max_health, session.current_health + session._modified_heal_amount(4))
		CHOICE_REWARD_NEW_CARD:
			var new_card_id: String = str(selected.get("card_id", ""))
			for _copy_index: int in range(new_card_copies_for_rarity(session, str(selected.get("rarity", REWARD_RARITY_COMMON)))):
				session.current_deck_ids.append(new_card_id)
		CHOICE_REWARD_RELIC:
			var relic_id: String = str(selected.get("relic_id", ""))
			if relic_id == "":
				return {"ok": false, "message": "Reliquia invalida."}
			var relic_result: Dictionary = session.add_relic_id(relic_id)
			if not bool(relic_result.get("ok", false)):
				return relic_result
		CHOICE_REWARD_UTILITY:
			var utility_result: Dictionary = apply_utility_reward_choice(session, selected)
			if not bool(utility_result.get("ok", false)):
				return utility_result
		_:
			return {"ok": false, "message": "Tipo de recompensa invalido: %s" % str(pending.get("type", ""))}
	session.rewards_pending.remove_at(0)
	session.applied_reward_ids.append("%s:%s" % [str(pending.get("id", "")), choice_id])
	session._update_pending_reward_category_state()
	if session.rewards_pending.is_empty():
		session.refresh_shop_upgrade_offers()
	return {"ok": true, "message": reward_choice_message(session, selected)}

static func apply_automatic_rewards_for_node(session, node_id: String) -> Array[String]:
	var applied: Array[String] = []
	var node: Dictionary = session._run_node(node_id)
	var schedule_entry: Dictionary = session._reward_schedule_entry_for_node(node_id)
	for reward_id: String in session._automatic_reward_ids_for_node(node, schedule_entry):
		var applied_id: String = "%s:%s" % [node_id, reward_id]
		if session.automatic_reward_ids.has(applied_id):
			continue
		match reward_id:
			REWARD_MAX_MANA_1:
				session.max_mana = mini(session.max_mana + 1, session.max_mana_cap)
			REWARD_MAX_HAND_SIZE_1:
				session.max_hand_size = mini(session.max_hand_size + 1, session.max_hand_size_cap)
			REWARD_MAX_HEALTH_5:
				session._increase_max_health(int(schedule_entry.get("max_health_delta", 5)))
			REWARD_UNLOCK_CLASS_PASSIVE:
				session.class_passive_unlocked = true
				if session.selected_class_id == "necromante":
					session.class_active_unlocked = true
					session.class_active_level = maxi(session.class_active_level, 1)
			REWARD_UNLOCK_CLASS_ACTIVE:
				session.class_active_unlocked = true
				session.class_active_level = maxi(session.class_active_level, 2 if session.selected_class_id == "necromante" else 1)
			REWARD_ADD_CLASS_COST2_CORE:
				var card_id: String = class_core_cost2_card_id(session)
				for _copy_index: int in range(REWARD_CARD_COPY_COUNT):
					session.current_deck_ids.append(card_id)
			REWARD_ADD_RELIC_PLACEHOLDER:
				var relic_id: String = session._placeholder_relic_id_for_entry(schedule_entry, node_id)
				if relic_id == "" or session.relic_ids.has(relic_id):
					continue
				var relic_result: Dictionary = session.add_relic_id(relic_id)
				if not bool(relic_result.get("ok", false)):
					continue
			REWARD_GRANT_REMAINING_CARD:
				if not session._grant_remaining_reward_card(schedule_entry, node_id):
					continue
			REWARD_COMPLETE_RUN_VICTORY:
				session.route_metadata["victory_node_id"] = node_id
				session.route_metadata["completed_run"] = true
			_:
				continue
		session.automatic_reward_ids.append(applied_id)
		applied.append(reward_id)
	session._mark_reward_category_completed(node_id, schedule_entry)
	return applied

static func queue_choice_rewards_for_node(session, node_id: String) -> void:
	var node: Dictionary = session._run_node(node_id)
	var schedule_entry: Dictionary = session._reward_schedule_entry_for_node(node_id)
	var reward: Dictionary = Dictionary(schedule_entry.get("choice_reward", node.get("choice_reward", {})))
	if reward.is_empty():
		return
	var pending_id: String = "%s:%s" % [node_id, str(reward.get("type", ""))]
	for pending: Dictionary in session.rewards_pending:
		if str(pending.get("id", "")) == pending_id:
			return
	for applied_id: String in session.applied_reward_ids:
		if applied_id.begins_with("%s:" % pending_id):
			return
	var pending: Dictionary = reward.duplicate(true)
	pending["id"] = pending_id
	pending["node_id"] = node_id
	pending["category"] = str(schedule_entry.get("category", str(reward.get("type", ""))))
	pending["rarity_by_card_id"] = rarity_map_for_pending(session, pending)
	if reward_choices_for_pending(session, pending).is_empty():
		return
	session.rewards_pending.append(pending)
	session._mark_reward_category_completed(node_id, schedule_entry)
	session._update_pending_reward_category_state()

static func reward_message(reward_id: String) -> String:
	match reward_id:
		REWARD_ADD_PULSO_ASTRAL:
			return "Recompensa aplicada: carta de classe adicionada ao deck da run."
		REWARD_REINFORCE_HEALTH:
			return "Recompensa aplicada: vida maxima e atual reforcadas em +2."
	return "Recompensa aplicada."

static func default_reward_card_id(session) -> String:
	match session.selected_class_id:
		"arcano":
			return "arcano_choque"
		"invocador":
			return "invocador_promover"
		"necromante":
			return "necro_prender"
	return "arcano_choque"

static func class_core_cost2_card_id(session) -> String:
	match session.selected_class_id:
		"arcano":
			return "arcano_tempestade"
		"invocador":
			return "invocador_guardiao"
		"necromante":
			return "necro_zumbi"
	return "arcano_tempestade"

static func reward_choices_for_pending(session, pending: Dictionary) -> Array[Dictionary]:
	match str(pending.get("type", "")):
		CHOICE_REWARD_UPGRADE_CARD:
			return upgrade_reward_choices(session, pending)
		CHOICE_REWARD_NEW_CARD:
			return new_card_reward_choices(session, pending)
		CHOICE_REWARD_RELIC:
			return relic_reward_choices(session, pending)
		CHOICE_REWARD_UTILITY:
			return utility_reward_choices(session, pending)
	return []

static func upgrade_reward_choices(session, pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Array[String] = []
	for card_id: String in session.current_deck_ids:
		if seen.has(card_id):
			continue
		seen.append(card_id)
	var candidates: Array[String] = []
	for card_id: String in seen:
		if int(session.card_upgrade_counts.get(card_id, 0)) >= 2:
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		candidates.append(card_id)
	candidates = session._stable_shuffled_strings(candidates, str(pending.get("id", "")))
	for card_id: String in candidates:
		var card = ContentLibrary.get_card(card_id)
		var upgrade_index: int = int(session.card_upgrade_counts.get(card_id, 0)) + 1
		result.append({
			"id": "upgrade:%s" % card_id,
			"card_id": card_id,
			"rarity": rarity_for_card(pending, card_id),
			"title": "%s%s - Lvl %d" % [rarity_title_prefix(rarity_for_card(pending, card_id)), str(card.display_name), upgrade_index + 1],
			"body": upgrade_choice_body(card_id, upgrade_index, rarity_for_card(pending, card_id))
		})
		if result.size() >= 3:
			break
	return result

static func new_card_reward_choices(session, pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var pool: Array[String] = class_reward_pool_for_context(session, pending)
	if pool.is_empty():
		return result
	for card_id: String in pool:
		if session.current_deck_ids.has(card_id):
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var rarity: String = rarity_for_card(pending, card_id)
		result.append({
			"id": "new_card:%s" % card_id,
			"card_id": card_id,
			"rarity": rarity,
			"title": "%s%s" % [rarity_title_prefix(rarity), str(card.display_name)],
			"body": "Adiciona %d copias ao deck." % new_card_copies_for_rarity(session, rarity)
		})
	return result

static func relic_reward_choices(session, pending: Dictionary) -> Array[Dictionary]:
	var rarity: String = str(pending.get("rarity", "standard"))
	var result: Array[Dictionary] = []
	var candidates: Array[String] = session._stable_shuffled_strings(session._relic_ids_for_rarity_label(rarity), "%s:%d" % [str(pending.get("id", "")), int(pending.get("reroll_index", 0))])
	for relic_id: String in candidates:
		if session.relic_ids.has(relic_id):
			continue
		var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
		if relic.is_empty():
			continue
		result.append({
			"id": "relic:%s" % relic_id,
			"relic_id": relic_id,
			"rarity": str(relic.get("rarity", "common")),
			"title": session._relic_title(relic),
			"body": session._relic_body(relic)
		})
		if result.size() >= 3:
			break
	return result

static func utility_reward_choices(session, _pending: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen: Array[String] = []
	for card_id: String in session.current_deck_ids:
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
	for card_id: String in session._shop_upgrade_candidates():
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var upgrade_index: int = int(session.card_upgrade_counts.get(card_id, 0)) + 1
		result.append({
			"id": "utility_upgrade:%s" % card_id,
			"utility": UTILITY_REWARD_UPGRADE_CARD,
			"card_id": card_id,
			"title": "Aprimorar %s - Lvl %d" % [str(card.display_name), upgrade_index + 1],
			"body": upgrade_choice_body(card_id, upgrade_index)
		})
	return result

static func class_reward_pool(session) -> Array[String]:
	var class_option: Dictionary = ContentLibrary.find_class_option(session.selected_class_id)
	return session._string_array(class_option.get("reward_pool", []))

static func class_reward_pool_for_context(session, context: Dictionary) -> Array[String]:
	var pool: Array[String] = class_reward_pool(session)
	var offset: int = int(context.get("pool_offset", pool_offset_for_element(str(context.get("element", "")))))
	var option_count: int = 3 if str(context.get("type", "")) == CHOICE_REWARD_NEW_CARD and session.has_relic_id(RELIC_BIBLIOTECA_PROIBIDA) else 2
	if offset <= 0:
		return pool.slice(0, mini(option_count, pool.size()))
	if offset >= pool.size():
		return []
	return pool.slice(offset, mini(offset + option_count, pool.size()))

static func pool_offset_for_element(element: String) -> int:
	match element:
		"gelo":
			return 2
		"ar":
			return 4
		"fogo":
			return 6
	return 0

static func upgrade_choice_body(card_id: String, upgrade_index: int, rarity: String = REWARD_RARITY_COMMON) -> String:
	var extra_copies: int = extra_upgrade_copies_for_rarity(rarity)
	var suffix: String = "" if extra_copies <= 0 else " Adiciona +%d copia(s) da carta base." % extra_copies
	if upgrade_index <= 1:
		return "%s sobe para Lvl 2 em todas as copias da run.%s" % [ContentLibrary.get_card_name(card_id), suffix]
	return "%s sobe para Lvl 3 em todas as copias da run.%s" % [ContentLibrary.get_card_name(card_id), suffix]

static func reward_choice_message(session, choice: Dictionary) -> String:
	if str(choice.get("id", "")).begins_with("upgrade:"):
		return "Upgrade aplicado: %s." % str(choice.get("title", ""))
	if str(choice.get("id", "")).begins_with("new_card:"):
		return "Carta adicionada ao deck: %s x%d." % [str(choice.get("title", "")), new_card_copies_for_rarity(session, str(choice.get("rarity", REWARD_RARITY_COMMON)))]
	if str(choice.get("id", "")).begins_with("relic:"):
		return "Reliquia registrada: %s." % str(choice.get("title", ""))
	if str(choice.get("id", "")).begins_with("utility_"):
		return "Utilidade aplicada: %s." % str(choice.get("title", ""))
	return "Recompensa aplicada."

static func apply_utility_reward_choice(session, choice: Dictionary) -> Dictionary:
	var card_id: String = str(choice.get("card_id", ""))
	if card_id == "":
		return {"ok": false, "message": "Carta invalida para utilidade."}
	match str(choice.get("utility", "")):
		UTILITY_REWARD_REMOVE_CARD:
			if not session.current_deck_ids.has(card_id):
				return {"ok": false, "message": "Carta nao existe no deck da run."}
			session.current_deck_ids.erase(card_id)
		UTILITY_REWARD_DUPLICATE_CARD:
			if ContentLibrary.get_card(card_id) == null:
				return {"ok": false, "message": "Carta invalida para duplicacao."}
			session.current_deck_ids.append(card_id)
		UTILITY_REWARD_UPGRADE_CARD:
			if int(session.card_upgrade_counts.get(card_id, 0)) >= 2:
				return {"ok": false, "message": "Carta ja esta no nivel maximo."}
			session.card_upgrade_counts[card_id] = mini(2, int(session.card_upgrade_counts.get(card_id, 0)) + 1)
		_:
			return {"ok": false, "message": "Utilidade invalida."}
	return {"ok": true, "message": "Utilidade aplicada."}

static func rarity_map_for_pending(session, pending: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var type: String = str(pending.get("type", ""))
	var card_ids: Array[String] = []
	if type == CHOICE_REWARD_NEW_CARD:
		card_ids = class_reward_pool_for_context(session, pending)
	elif type == CHOICE_REWARD_UPGRADE_CARD:
		card_ids = session._shop_upgrade_candidates()
	for card_id: String in card_ids:
		result[card_id] = roll_rarity(session, str(pending.get("id", "")), card_id)
	return result

static func rarity_for_card(pending: Dictionary, card_id: String) -> String:
	var rarity_by_card_id: Dictionary = Dictionary(pending.get("rarity_by_card_id", {}))
	return str(rarity_by_card_id.get(card_id, REWARD_RARITY_COMMON))

static func roll_rarity(session, pending_id: String, card_id: String) -> String:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var seed_text: String = "%d:%s:%s:%s:rarity" % [session.run_seed, session.selected_class_id, pending_id, card_id]
	rng.seed = absi(seed_text.hash())
	var roll: int = rng.randi_range(1, 100)
	if roll <= 5:
		return REWARD_RARITY_ULTRA
	if roll <= 30:
		return REWARD_RARITY_RARE
	return REWARD_RARITY_COMMON

static func rarity_title_prefix(rarity: String) -> String:
	match rarity:
		REWARD_RARITY_RARE:
			return "[Rara] "
		REWARD_RARITY_ULTRA:
			return "[Ultra rara] "
	return ""

static func rarity_from_schedule_label(rarity: String) -> String:
	match rarity:
		"rare", "rare_ultra":
			return REWARD_RARITY_RARE
		"ultra", "ultra_rare":
			return REWARD_RARITY_ULTRA
	return REWARD_RARITY_COMMON

static func new_card_copies_for_rarity(session, rarity: String) -> int:
	match rarity:
		REWARD_RARITY_RARE:
			return REWARD_CARD_COPY_COUNT + 1
		REWARD_RARITY_ULTRA:
			return REWARD_CARD_COPY_COUNT + 2 + (1 if session.has_relic_id(RELIC_NUCLEO_INSTAVEL) else 0)
	return REWARD_CARD_COPY_COUNT

static func extra_upgrade_copies_for_rarity(_rarity: String) -> int:
	# Track 02 tuning keeps upgrade rewards as level improvements only so the
	# 29-map route lands near the target final deck size.
	return 0
