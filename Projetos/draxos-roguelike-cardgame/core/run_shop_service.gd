extends RefCounted

static func refresh_shop_upgrade_offers(session) -> void:
	refresh_shop_inventory(session)

static func refresh_shop_inventory(session) -> void:
	if not session.active:
		return
	var refresh_id: String = session.last_completed_node_id
	if refresh_id == "" and not session.completed_node_ids.is_empty():
		refresh_id = session.completed_node_ids[session.completed_node_ids.size() - 1]
	if refresh_id == "" and session.current_node_id != "":
		refresh_id = session.current_node_id
	if refresh_id == "":
		return
	var candidates: Array[String] = shop_upgrade_candidates(session)
	candidates = session._stable_shuffled_strings(candidates, "shop_upgrade:%s:%d:%d" % [refresh_id, session.completed_node_ids.size(), session.reroll_count])
	var upgrade_offer_ids: Array[String] = []
	for card_id: String in candidates:
		upgrade_offer_ids.append(card_id)
		if upgrade_offer_ids.size() >= session.SHOP_UPGRADE_OFFER_COUNT:
			break
	session.shop_upgrade_offer_card_ids = upgrade_offer_ids
	session.shop_upgrade_refresh_node_id = refresh_id
	session.shop_upgrade_purchase_node_id = ""
	var card_offer_ids: Array[String] = session._stable_shuffled_strings(shop_card_candidates(session), "shop_card:%s:%d:%d" % [refresh_id, session.completed_node_ids.size(), session.reroll_count])
	var card_rarities: Dictionary = {}
	var trimmed_card_offer_ids: Array[String] = []
	for card_id: String in card_offer_ids:
		trimmed_card_offer_ids.append(card_id)
		card_rarities[card_id] = session._roll_rarity("shop:%s:%d" % [refresh_id, session.reroll_count], card_id)
		if trimmed_card_offer_ids.size() >= session.SHOP_CARD_OFFER_COUNT:
			break
	var relic_offer_ids: Array[String] = session._stable_shuffled_strings(shop_relic_candidates(session), "shop_relic:%s:%d:%d" % [refresh_id, session.completed_node_ids.size(), session.reroll_count])
	var trimmed_relic_offer_ids: Array[String] = []
	for relic_id: String in relic_offer_ids:
		trimmed_relic_offer_ids.append(relic_id)
		if trimmed_relic_offer_ids.size() >= session.SHOP_RELIC_OFFER_COUNT:
			break
	sync_shop_state(session, trimmed_card_offer_ids, card_rarities, trimmed_relic_offer_ids)

static func shop_upgrade_choices(session) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id: String in session.shop_upgrade_offer_card_ids:
		if int(session.card_upgrade_counts.get(card_id, 0)) >= 2:
			continue
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var upgrade_index: int = int(session.card_upgrade_counts.get(card_id, 0)) + 1
		result.append({
			"id": "shop_upgrade:%s" % card_id,
			"card_id": card_id,
			"title": "%s - Lvl %d" % [str(card.display_name), upgrade_index + 1],
			"body": session._upgrade_choice_body(card_id, upgrade_index),
			"cost": shop_upgrade_cost(session),
			"can_buy": can_buy_shop_upgrade(session, card_id)
		})
	return result

static func can_buy_shop_upgrade(session, card_id: String) -> bool:
	return session.active \
		and session.soul_total >= shop_upgrade_cost(session) \
		and session.shop_upgrade_refresh_node_id != "" \
		and session.shop_upgrade_purchase_node_id != session.shop_upgrade_refresh_node_id \
		and session.shop_upgrade_offer_card_ids.has(card_id) \
		and int(session.card_upgrade_counts.get(card_id, 0)) < 2

static func buy_shop_card_upgrade(session, card_id: String) -> Dictionary:
	if not session.active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if session.shop_upgrade_purchase_node_id == session.shop_upgrade_refresh_node_id and session.shop_upgrade_refresh_node_id != "":
		return {"ok": false, "message": "Upgrade da loja ja comprado neste combate."}
	if not session.shop_upgrade_offer_card_ids.has(card_id):
		return {"ok": false, "message": "Carta nao esta nas ofertas da loja."}
	if int(session.card_upgrade_counts.get(card_id, 0)) >= 2:
		return {"ok": false, "message": "Carta ja esta no nivel maximo."}
	var cost: int = shop_upgrade_cost(session)
	if session.soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para upgrade."}
	session.soul_total -= cost
	session.card_upgrade_counts[card_id] = mini(2, int(session.card_upgrade_counts.get(card_id, 0)) + 1)
	session.shop_upgrade_purchase_node_id = session.shop_upgrade_refresh_node_id
	sync_shop_state(session)
	return {"ok": true, "message": "Upgrade comprado: %s." % ContentLibrary.get_card_name(card_id)}

static func can_buy_heal(session) -> bool:
	return session.active and session.soul_total >= session.PAID_HEAL_COST and session.current_health < session.max_health and session._modified_heal_amount(session.PAID_HEAL_AMOUNT) > 0

static func buy_paid_heal(session) -> Dictionary:
	if not session.active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if session.current_health >= session.max_health:
		return {"ok": false, "message": "%s ja esta com vida cheia." % session.player_display_name()}
	if session.soul_total < session.PAID_HEAL_COST:
		return {"ok": false, "message": "Almas insuficientes para cura."}
	session.soul_total -= session.PAID_HEAL_COST
	var heal_amount: int = session._modified_heal_amount(session.PAID_HEAL_AMOUNT)
	session.current_health = mini(session.max_health, session.current_health + heal_amount)
	return {"ok": true, "message": "Cura paga aplicada: +%d vida por %d almas." % [heal_amount, session.PAID_HEAL_COST]}

static func shop_remove_card_choices(session) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id: String in unique_current_deck_card_ids(session):
		result.append({
			"id": "shop_remove:%s" % card_id,
			"card_id": card_id,
			"title": "Remover %s" % ContentLibrary.get_card_name(card_id),
			"body": "Remove 1 copia desta carta do deck da run.",
			"cost": shop_remove_card_cost(session),
			"can_buy": can_buy_shop_remove_card(session, card_id)
		})
	return result

static func can_buy_shop_remove_card(session, card_id: String) -> bool:
	return session.active and session.current_deck_ids.has(card_id) and session.soul_total >= shop_remove_card_cost(session)

static func buy_shop_remove_card(session, card_id: String) -> Dictionary:
	if not session.active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if not session.current_deck_ids.has(card_id):
		return {"ok": false, "message": "Carta nao existe no deck da run."}
	var cost: int = shop_remove_card_cost(session)
	if session.soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para remover carta."}
	session.soul_total -= cost
	session.current_deck_ids.erase(card_id)
	if cost == 0 and session.has_relic_id(session.RELIC_FERRAMENTAS_DE_CIRURGIA):
		session.shop_state["free_remove_card_used"] = true
	return {"ok": true, "message": "Carta removida: %s." % ContentLibrary.get_card_name(card_id)}

static func shop_duplicate_card_choices(session) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card_id: String in unique_current_deck_card_ids(session):
		result.append({
			"id": "shop_duplicate:%s" % card_id,
			"card_id": card_id,
			"title": "Duplicar %s" % ContentLibrary.get_card_name(card_id),
			"body": "Adiciona 1 copia desta carta ao deck da run.",
			"cost": shop_duplicate_card_cost(session),
			"can_buy": can_buy_shop_duplicate_card(session, card_id)
		})
	return result

static func can_buy_shop_duplicate_card(session, card_id: String) -> bool:
	return session.active and ContentLibrary.get_card(card_id) != null and session.current_deck_ids.has(card_id) and session.soul_total >= shop_duplicate_card_cost(session)

static func buy_shop_duplicate_card(session, card_id: String) -> Dictionary:
	if not session.active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	if not session.current_deck_ids.has(card_id) or ContentLibrary.get_card(card_id) == null:
		return {"ok": false, "message": "Carta invalida para duplicacao."}
	var cost: int = shop_duplicate_card_cost(session)
	if session.soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para duplicar carta."}
	session.soul_total -= cost
	session.current_deck_ids.append(card_id)
	if cost < session.SHOP_DUPLICATE_CARD_COST and session.has_relic_id(session.RELIC_LAMINA_DE_RESERVA):
		session.shop_state["discount_duplicate_used"] = true
	return {"ok": true, "message": "Carta duplicada: %s." % ContentLibrary.get_card_name(card_id)}

static func shop_card_choices(session) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var card_offer_ids: Array[String] = session._string_array(session.shop_state.get("card_offer_ids", []))
	var rarity_by_id: Dictionary = Dictionary(session.shop_state.get("card_offer_rarity_by_id", {}))
	var purchased: Array[String] = session._string_array(session.shop_state.get("purchased_card_offer_ids", []))
	for card_id: String in card_offer_ids:
		var card = ContentLibrary.get_card(card_id)
		if card == null:
			continue
		var rarity: String = str(rarity_by_id.get(card_id, session.REWARD_RARITY_COMMON))
		result.append({
			"id": "shop_card:%s" % card_id,
			"card_id": card_id,
			"rarity": rarity,
			"title": "%s%s" % [session._rarity_title_prefix(rarity), str(card.display_name)],
			"body": "Compra 1 copia para o deck da run.",
			"cost": shop_card_cost_for_rarity(session, rarity),
			"can_buy": can_buy_shop_card(session, card_id),
			"purchased": purchased.has(card_id)
		})
	return result

static func can_buy_shop_card(session, card_id: String) -> bool:
	var purchased: Array[String] = session._string_array(session.shop_state.get("purchased_card_offer_ids", []))
	if purchased.has(card_id):
		return false
	var rarity_by_id: Dictionary = Dictionary(session.shop_state.get("card_offer_rarity_by_id", {}))
	var rarity: String = str(rarity_by_id.get(card_id, session.REWARD_RARITY_COMMON))
	return session.active and session._string_array(session.shop_state.get("card_offer_ids", [])).has(card_id) and ContentLibrary.get_card(card_id) != null and session.soul_total >= shop_card_cost_for_rarity(session, rarity)

static func buy_shop_card(session, card_id: String) -> Dictionary:
	if not can_buy_shop_card(session, card_id):
		return {"ok": false, "message": "Carta indisponivel ou Almas insuficientes."}
	var rarity_by_id: Dictionary = Dictionary(session.shop_state.get("card_offer_rarity_by_id", {}))
	var rarity: String = str(rarity_by_id.get(card_id, session.REWARD_RARITY_COMMON))
	var cost: int = shop_card_cost_for_rarity(session, rarity)
	session.soul_total -= cost
	session.current_deck_ids.append(card_id)
	var purchased: Array[String] = session._string_array(session.shop_state.get("purchased_card_offer_ids", []))
	if not purchased.has(card_id):
		purchased.append(card_id)
	session.shop_state["purchased_card_offer_ids"] = purchased
	return {"ok": true, "message": "Carta comprada: %s." % ContentLibrary.get_card_name(card_id)}

static func shop_relic_choices(session) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for relic_id: String in session._string_array(session.shop_state.get("relic_offer_ids", [])):
		var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
		if relic.is_empty():
			continue
		var rarity: String = str(relic.get("rarity", "common"))
		result.append({
			"id": "shop_relic:%s" % relic_id,
			"relic_id": relic_id,
			"rarity": rarity,
			"title": session._relic_title(relic),
			"body": session._relic_body(relic),
			"cost": shop_relic_cost_for_rarity(session, rarity),
			"can_buy": can_buy_shop_relic(session, relic_id),
			"owned": session.has_relic_id(relic_id)
		})
	return result

static func can_buy_shop_relic(session, relic_id: String) -> bool:
	var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
	if relic.is_empty() or session.has_relic_id(relic_id):
		return false
	return session.active and session._string_array(session.shop_state.get("relic_offer_ids", [])).has(relic_id) and session.soul_total >= shop_relic_cost_for_rarity(session, str(relic.get("rarity", "common")))

static func buy_shop_relic(session, relic_id: String) -> Dictionary:
	if not can_buy_shop_relic(session, relic_id):
		return {"ok": false, "message": "Reliquia indisponivel ou Almas insuficientes."}
	var relic: Dictionary = ContentLibrary.get_relic_definition(relic_id)
	var cost: int = shop_relic_cost_for_rarity(session, str(relic.get("rarity", "common")))
	var relic_result: Dictionary = session.add_relic_id(relic_id)
	if not bool(relic_result.get("ok", false)):
		return relic_result
	session.soul_total -= cost
	return {"ok": true, "message": "Reliquia comprada: %s." % ContentLibrary.get_relic_display_name(relic_id)}

static func current_reroll_cost(session) -> int:
	return reroll_cost(session.reroll_count, session.SHOP_REROLL_COST_BASE, session.SHOP_REROLL_COST_STEP)

static func buy_shop_reroll(session) -> Dictionary:
	if not session.active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	var cost: int = current_reroll_cost(session)
	if session.soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para reroll da loja."}
	session.soul_total -= cost
	session.reroll_count += 1
	refresh_shop_inventory(session)
	return {"ok": true, "message": "Loja rerolada por %d almas." % cost}

static func buy_reward_reroll(session) -> Dictionary:
	if not session.active or session.rewards_pending.is_empty():
		return {"ok": false, "message": "Nenhuma recompensa pendente para reroll."}
	var cost: int = current_reroll_cost(session)
	if session.soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para reroll de recompensa."}
	session.soul_total -= cost
	session.reroll_count += 1
	var pending: Dictionary = session.rewards_pending[0]
	pending["reroll_index"] = int(pending.get("reroll_index", 0)) + 1
	pending["rarity_by_card_id"] = session._rarity_map_for_pending(pending)
	session.rewards_pending[0] = pending
	return {"ok": true, "message": "Recompensa rerolada por %d almas." % cost}

static func can_buy_shop_max_health(session) -> bool:
	return session.active and shop_max_health_purchase_count(session) < session.SHOP_MAX_HEALTH_PURCHASE_LIMIT and session.soul_total >= shop_max_health_cost(session)

static func buy_shop_max_health(session) -> Dictionary:
	if not session.active:
		return {"ok": false, "message": "Nenhuma run ativa."}
	var purchase_count: int = shop_max_health_purchase_count(session)
	if purchase_count >= session.SHOP_MAX_HEALTH_PURCHASE_LIMIT:
		return {"ok": false, "message": "Limite de HP maximo da loja atingido."}
	var cost: int = shop_max_health_cost(session)
	if session.soul_total < cost:
		return {"ok": false, "message": "Almas insuficientes para HP maximo."}
	session.soul_total -= cost
	session.shop_state["max_health_purchases"] = purchase_count + 1
	session._increase_max_health(session.SHOP_MAX_HEALTH_AMOUNT)
	return {"ok": true, "message": "HP maximo aumentado em +%d." % session.SHOP_MAX_HEALTH_AMOUNT}

static func shop_upgrade_candidates(session) -> Array[String]:
	var result: Array[String] = []
	var seen: Array[String] = []
	for card_id: String in session.current_deck_ids:
		if seen.has(card_id):
			continue
		seen.append(card_id)
		if int(session.card_upgrade_counts.get(card_id, 0)) >= 2:
			continue
		if ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	return result

static func shop_card_candidates(session) -> Array[String]:
	var result: Array[String] = []
	var pool: Array[String] = session._class_reward_pool()
	for card_id: String in pool:
		if result.has(card_id) or ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	for card_id: String in unique_current_deck_card_ids(session):
		if result.has(card_id) or ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	return result

static func shop_relic_candidates(session) -> Array[String]:
	var result: Array[String] = []
	for relic: Variant in ContentLibrary.get_relic_definitions():
		if typeof(relic) != TYPE_DICTIONARY:
			continue
		var relic_id: String = str(Dictionary(relic).get("id", ""))
		if relic_id == "" or session.relic_ids.has(relic_id):
			continue
		result.append(relic_id)
	return result

static func unique_current_deck_card_ids(session) -> Array[String]:
	var result: Array[String] = []
	for card_id: String in session.current_deck_ids:
		if result.has(card_id):
			continue
		if ContentLibrary.get_card(card_id) == null:
			continue
		result.append(card_id)
	return result

static func shop_upgrade_cost(session) -> int:
	return upgrade_cost(session.SHOP_CARD_UPGRADE_COST)

static func upgrade_cost(base_cost: int) -> int:
	return base_cost

static func shop_remove_card_cost(session) -> int:
	return remove_card_cost(session.SHOP_REMOVE_CARD_COST, session.has_relic_id(session.RELIC_FERRAMENTAS_DE_CIRURGIA), bool(session.shop_state.get("free_remove_card_used", false)))

static func remove_card_cost(base_cost: int, has_free_remove_relic: bool, free_remove_used: bool) -> int:
	if has_free_remove_relic and not free_remove_used:
		return 0
	return base_cost

static func shop_duplicate_card_cost(session) -> int:
	return duplicate_card_cost(session.SHOP_DUPLICATE_CARD_COST, session.has_relic_id(session.RELIC_LAMINA_DE_RESERVA), bool(session.shop_state.get("discount_duplicate_used", false)))

static func duplicate_card_cost(base_cost: int, has_discount_relic: bool, discount_used: bool) -> int:
	if has_discount_relic and not discount_used:
		return int(base_cost / 2)
	return base_cost

static func shop_card_cost_for_rarity(session, rarity: String) -> int:
	return card_cost_for_rarity(rarity, session.SHOP_BUY_COMMON_CARD_COST, session.SHOP_BUY_RARE_CARD_COST, session.SHOP_BUY_ULTRA_RARE_CARD_COST)

static func card_cost_for_rarity(rarity: String, common_cost: int, rare_cost: int, ultra_cost: int) -> int:
	match rarity:
		"rara", "rare":
			return rare_cost
		"ultra_rara", "ultra_rare", "ultra":
			return ultra_cost
	return common_cost

static func shop_relic_cost_for_rarity(session, rarity: String) -> int:
	return relic_cost_for_rarity(rarity, session.SHOP_BUY_COMMON_RELIC_COST, session.SHOP_BUY_RARE_RELIC_COST, session.SHOP_BUY_ULTRA_RARE_RELIC_COST)

static func relic_cost_for_rarity(rarity: String, common_cost: int, rare_cost: int, ultra_cost: int) -> int:
	match rarity:
		"rara", "rare":
			return rare_cost
		"ultra_rara", "ultra_rare", "ultra":
			return ultra_cost
	return common_cost

static func shop_max_health_purchase_count(session) -> int:
	if session.shop_state.is_empty():
		session.shop_state = default_shop_state(session)
	return clampi(int(session.shop_state.get("max_health_purchases", 0)), 0, session.SHOP_MAX_HEALTH_PURCHASE_LIMIT)

static func shop_max_health_cost(session) -> int:
	return max_health_cost(shop_max_health_purchase_count(session), session.SHOP_MAX_HEALTH_FIRST_COST, session.SHOP_MAX_HEALTH_SECOND_COST)

static func max_health_cost(purchase_count: int, first_cost: int, second_cost: int) -> int:
	return first_cost if purchase_count <= 0 else second_cost

static func reroll_cost(reroll_count: int, base_cost: int, step_cost: int) -> int:
	return base_cost + (step_cost * maxi(0, reroll_count))

static func default_shop_state(session) -> Dictionary:
	var contract: Dictionary = ContentLibrary.get_track_contract()
	var schema: Dictionary = Dictionary(contract.get("shop_state_schema", {}))
	return {
		"schema_version": int(schema.get("version", session.TRACK_02_SHOP_SCHEMA_VERSION)),
		"expanded_shop_pending": bool(schema.get("expanded_shop_pending", true)),
		"refresh_node_id": session.shop_upgrade_refresh_node_id,
		"purchase_node_id": session.shop_upgrade_purchase_node_id,
		"upgrade_offer_card_ids": session.shop_upgrade_offer_card_ids.duplicate(),
		"card_offer_ids": [],
		"card_offer_rarity_by_id": {},
		"relic_offer_ids": [],
		"purchased_card_offer_ids": [],
		"max_health_purchases": 0,
		"free_remove_card_used": false,
		"discount_duplicate_used": false,
		"track_01_upgrade_cost": session.SHOP_CARD_UPGRADE_COST,
		"prices": shop_prices_snapshot(session)
	}

static func sync_shop_state(session, card_offer_ids: Array = [], card_rarities: Dictionary = {}, relic_offer_ids: Array = []) -> void:
	if session.shop_state.is_empty():
		session.shop_state = default_shop_state(session)
	if card_offer_ids.is_empty() and session.shop_state.has("card_offer_ids"):
		card_offer_ids = session._string_array(session.shop_state.get("card_offer_ids", []))
	if card_rarities.is_empty() and session.shop_state.has("card_offer_rarity_by_id"):
		card_rarities = Dictionary(session.shop_state.get("card_offer_rarity_by_id", {}))
	if relic_offer_ids.is_empty() and session.shop_state.has("relic_offer_ids"):
		relic_offer_ids = session._string_array(session.shop_state.get("relic_offer_ids", []))
	session.shop_state["refresh_node_id"] = session.shop_upgrade_refresh_node_id
	session.shop_state["purchase_node_id"] = session.shop_upgrade_purchase_node_id
	session.shop_state["upgrade_offer_card_ids"] = session.shop_upgrade_offer_card_ids.duplicate()
	session.shop_state["card_offer_ids"] = card_offer_ids.duplicate()
	session.shop_state["card_offer_rarity_by_id"] = card_rarities.duplicate()
	session.shop_state["relic_offer_ids"] = relic_offer_ids.duplicate()
	if not session.shop_state.has("purchased_card_offer_ids"):
		session.shop_state["purchased_card_offer_ids"] = []
	if not session.shop_state.has("max_health_purchases"):
		session.shop_state["max_health_purchases"] = 0
	if not session.shop_state.has("free_remove_card_used"):
		session.shop_state["free_remove_card_used"] = false
	if not session.shop_state.has("discount_duplicate_used"):
		session.shop_state["discount_duplicate_used"] = false
	session.shop_state["expanded_shop_pending"] = false
	session.shop_state["track_01_upgrade_cost"] = session.SHOP_CARD_UPGRADE_COST
	session.shop_state["prices"] = shop_prices_snapshot(session)

static func shop_prices_snapshot(session) -> Dictionary:
	return {
		"heal": session.SHOP_HEAL_COST,
		"remove_card": session.SHOP_REMOVE_CARD_COST,
		"duplicate_card": session.SHOP_DUPLICATE_CARD_COST,
		"upgrade_card": session.SHOP_CARD_UPGRADE_COST,
		"buy_card_common": session.SHOP_BUY_COMMON_CARD_COST,
		"buy_card_rare": session.SHOP_BUY_RARE_CARD_COST,
		"buy_card_ultra_rare": session.SHOP_BUY_ULTRA_RARE_CARD_COST,
		"buy_relic_common": session.SHOP_BUY_COMMON_RELIC_COST,
		"buy_relic_rare": session.SHOP_BUY_RARE_RELIC_COST,
		"buy_relic_ultra_rare": session.SHOP_BUY_ULTRA_RARE_RELIC_COST,
		"reroll_base": session.SHOP_REROLL_COST_BASE,
		"reroll_step": session.SHOP_REROLL_COST_STEP,
		"max_health_first": session.SHOP_MAX_HEALTH_FIRST_COST,
		"max_health_second": session.SHOP_MAX_HEALTH_SECOND_COST
	}
