extends RefCounted

const DEFAULT_PLAYER_NAME: String = "Comandante Draxos"
const TRACK_02_TARGET_MAP_COUNT: int = 29
const TURNS_MIN: int = 110
const TURNS_MAX: int = 230
const DECK_MIN: int = 30
const DECK_MAX: int = 42
const MIN_RELIC_COUNT: int = 5
const MIN_SHOP_USAGE: int = 2

func simulate_route(session, catalog, class_id: String, seed: int, options: Dictionary = {}) -> Dictionary:
	var nodes: Array = []
	if catalog != null:
		nodes = Array(catalog.run_map.get("nodes", []))
	var metrics: Dictionary = _empty_metrics(class_id, seed, nodes.size())
	if session == null:
		metrics["ok"] = false
		metrics["message"] = "RunSession autoload is missing."
		return metrics
	if catalog == null:
		metrics["ok"] = false
		metrics["message"] = "Missing generated slice catalog."
		return metrics

	session.reset()
	var player_name: String = str(options.get("player_name", DEFAULT_PLAYER_NAME))
	var start_result: Dictionary = session.start_class_run(class_id, seed, player_name)
	metrics["ok"] = bool(start_result.get("ok", false))
	metrics["message"] = str(start_result.get("message", ""))
	if not bool(start_result.get("ok", false)):
		session.reset()
		return metrics

	for node: Dictionary in nodes:
		var node_id: String = str(node.get("id", ""))
		var map_index: int = int(node.get("map_index", 0))
		if session.current_node_id != node_id:
			if not session.is_node_available(node):
				metrics["ok"] = false
				metrics["message"] = "Route blocked before map %d (%s)." % [map_index, node_id]
				break
			session.select_node(node_id)
		var encounter: Dictionary = catalog.find_encounter(str(node.get("encounter_id", "")))
		if encounter.is_empty():
			metrics["ok"] = false
			metrics["message"] = "Missing encounter for map %d (%s)." % [map_index, node_id]
			break

		_apply_pre_battle_shop(session, metrics)
		metrics["estimated_turns"] = int(metrics.get("estimated_turns", 0)) + _estimated_turns_for_encounter(encounter)
		var hp_loss: int = _estimated_hp_loss_for_encounter(encounter, map_index)
		var remaining_health: int = session.current_health - hp_loss
		if remaining_health <= 0:
			metrics["deaths"] = int(metrics.get("deaths", 0)) + 1
			remaining_health = 1
		metrics["hp_loss"] = int(metrics.get("hp_loss", 0)) + maxi(0, session.current_health - remaining_health)

		var summary: Dictionary = session.record_battle_result(node_id, "vitoria", remaining_health)
		if not bool(summary.get("ok", false)):
			metrics["ok"] = false
			metrics["message"] = "Could not record map %d (%s)." % [map_index, node_id]
			break
		metrics["souls_earned"] = int(metrics.get("souls_earned", 0)) + int(summary.get("souls_gained", 0))
		if not _apply_all_pending_rewards(session):
			metrics["ok"] = false
			metrics["message"] = "Could not resolve reward choices after map %d." % map_index
			break
		_apply_post_reward_shop(session, metrics, map_index)
		metrics["completed_maps"] = int(metrics.get("completed_maps", 0)) + 1

	metrics["final_hp"] = session.current_health
	metrics["max_hp"] = session.max_health
	metrics["souls_left"] = session.soul_total
	metrics["deck_size"] = session.current_deck_ids.size()
	metrics["relic_count"] = session.relic_ids.size()
	if bool(metrics.get("ok", false)) and int(metrics.get("completed_maps", 0)) != nodes.size():
		metrics["ok"] = false
		metrics["message"] = "Completed %d/%d maps." % [int(metrics.get("completed_maps", 0)), nodes.size()]
	session.reset()
	return metrics

func acceptance_for(metrics: Dictionary) -> Dictionary:
	if int(metrics.get("completed_maps", 0)) != TRACK_02_TARGET_MAP_COUNT:
		return {"ok": false, "message": "Pacing smoke completed %d/%d maps." % [int(metrics.get("completed_maps", 0)), TRACK_02_TARGET_MAP_COUNT], "metrics": metrics}
	if int(metrics.get("deaths", 0)) != 0:
		return {"ok": false, "message": "Pacing smoke recorded deaths: %d." % int(metrics.get("deaths", 0)), "metrics": metrics}
	var turns: int = int(metrics.get("estimated_turns", 0))
	if turns < TURNS_MIN or turns > TURNS_MAX:
		return {"ok": false, "message": "Pacing smoke estimated turns outside first-test range: %d." % turns, "metrics": metrics}
	var deck_size: int = int(metrics.get("deck_size", 0))
	if deck_size < DECK_MIN or deck_size > DECK_MAX:
		return {"ok": false, "message": "Pacing smoke final deck size outside first-test range: %d." % deck_size, "metrics": metrics}
	if int(metrics.get("relic_count", 0)) < MIN_RELIC_COUNT:
		return {"ok": false, "message": "Pacing smoke expected at least 5 relics, got %d." % int(metrics.get("relic_count", 0)), "metrics": metrics}
	if int(metrics.get("shop_usage", 0)) < MIN_SHOP_USAGE:
		return {"ok": false, "message": "Pacing smoke expected at least 2 practical shop actions, got %d." % int(metrics.get("shop_usage", 0)), "metrics": metrics}
	return {"ok": true, "message": "Track 02 full-route pacing smoke passed.", "metrics": metrics}

func format_metrics(metrics: Dictionary) -> String:
	return "full-route pacing: maps=%d/%d turns_est=%d hp_loss_est=%d deaths=%d souls_earned=%d souls_spent_est=%d souls_left=%d deck_size=%d relic_count=%d shop_usage=%d actions=%s" % [
		int(metrics.get("completed_maps", 0)),
		int(metrics.get("map_count", TRACK_02_TARGET_MAP_COUNT)),
		int(metrics.get("estimated_turns", 0)),
		int(metrics.get("hp_loss", 0)),
		int(metrics.get("deaths", 0)),
		int(metrics.get("souls_earned", 0)),
		int(metrics.get("souls_spent", 0)),
		int(metrics.get("souls_left", 0)),
		int(metrics.get("deck_size", 0)),
		int(metrics.get("relic_count", 0)),
		int(metrics.get("shop_usage", 0)),
		", ".join(Array(metrics.get("shop_actions", [])))
	]

func _empty_metrics(class_id: String, seed: int, map_count: int) -> Dictionary:
	return {
		"class_id": class_id,
		"seed": seed,
		"ok": false,
		"message": "",
		"map_count": map_count,
		"completed_maps": 0,
		"estimated_turns": 0,
		"hp_loss": 0,
		"final_hp": 0,
		"max_hp": 0,
		"souls_earned": 0,
		"souls_spent": 0,
		"souls_left": 0,
		"deck_size": 0,
		"relic_count": 0,
		"shop_usage": 0,
		"deaths": 0,
		"shop_actions": []
	}

func _apply_all_pending_rewards(session) -> bool:
	var guard: int = 0
	while session.has_pending_reward():
		guard += 1
		if guard > 12:
			return false
		var choices: Array[Dictionary] = session.pending_reward_choices()
		if choices.is_empty():
			return false
		var selected: Dictionary = _preferred_reward_choice(choices)
		if selected.is_empty():
			selected = choices[0]
		var result: Dictionary = session.apply_reward_choice(str(selected.get("id", "")))
		if not bool(result.get("ok", false)):
			return false
	return true

func _preferred_reward_choice(choices: Array[Dictionary]) -> Dictionary:
	for choice: Dictionary in choices:
		if str(choice.get("utility", "")) == "remove_card":
			return choice
	for choice: Dictionary in choices:
		if str(choice.get("rarity", "")) in ["ultra_rara", "ultra_rare"]:
			return choice
	for choice: Dictionary in choices:
		if str(choice.get("rarity", "")) in ["rara", "rare"]:
			return choice
	return choices[0] if not choices.is_empty() else {}

func _apply_pre_battle_shop(session, metrics: Dictionary) -> void:
	while session.can_buy_heal() and session.current_health <= maxi(8, int(session.max_health * 0.45)):
		var souls_before: int = session.soul_total
		_record_shop_purchase(session, metrics, "heal", session.buy_paid_heal(), souls_before)

func _apply_post_reward_shop(session, metrics: Dictionary, map_index: int) -> void:
	var souls_before: int = 0
	if map_index == 10 or map_index == 16:
		souls_before = session.soul_total
		_record_shop_purchase(session, metrics, "max_hp", session.buy_shop_max_health(), souls_before)
	if map_index == 12 or map_index == 20:
		var remove_choices: Array[Dictionary] = session.shop_remove_card_choices()
		if not remove_choices.is_empty():
			souls_before = session.soul_total
			_record_shop_purchase(session, metrics, "remove", session.buy_shop_remove_card(str(remove_choices[0].get("card_id", ""))), souls_before)
	if map_index == 18:
		var duplicate_choices: Array[Dictionary] = session.shop_duplicate_card_choices()
		if not duplicate_choices.is_empty():
			souls_before = session.soul_total
			_record_shop_purchase(session, metrics, "duplicate", session.buy_shop_duplicate_card(str(duplicate_choices[0].get("card_id", ""))), souls_before)
	if map_index == 21 or map_index == 28:
		var relic_choices: Array[Dictionary] = session.shop_relic_choices()
		if not relic_choices.is_empty():
			souls_before = session.soul_total
			_record_shop_purchase(session, metrics, "relic", session.buy_shop_relic(str(relic_choices[0].get("relic_id", ""))), souls_before)

func _record_shop_purchase(session, metrics: Dictionary, action_id: String, result: Dictionary, souls_before: int) -> void:
	if not bool(result.get("ok", false)):
		return
	var actions: Array = Array(metrics.get("shop_actions", []))
	actions.append(action_id)
	metrics["shop_actions"] = actions
	metrics["shop_usage"] = int(metrics.get("shop_usage", 0)) + 1
	metrics["souls_spent"] = int(metrics.get("souls_spent", 0)) + maxi(0, souls_before - session.soul_total)

func _estimated_turns_for_encounter(encounter: Dictionary) -> int:
	var turns: int = 4
	match str(encounter.get("tier", "")):
		"tutorial":
			turns = 3
		"small":
			turns = 4
		"medium":
			turns = 5
		"elite_optional":
			turns = 7
		"boss":
			turns = 10
	match str(encounter.get("mode", "")):
		"ondas":
			turns += 2
		"defesa_posicao":
			turns = maxi(turns, int(encounter.get("defense_turns", 5)))
		"sobreviver_turnos":
			turns = maxi(turns, int(encounter.get("survive_turns", 5)))
		"chefe_summoner":
			turns += 2
		"emboscada", "escolta", "invasao":
			turns += 1
	if maxi(int(encounter.get("player_slots_count", 0)), int(encounter.get("enemy_slots_count", 0))) >= 6:
		turns += 1
	return turns

func _estimated_hp_loss_for_encounter(encounter: Dictionary, map_index: int) -> int:
	var loss: int = 0
	match str(encounter.get("tier", "")):
		"tutorial":
			loss = 0 if map_index == 1 else 1
		"small":
			loss = 1
		"medium":
			loss = 2
		"elite_optional":
			loss = 3
		"boss":
			loss = 4
	match str(encounter.get("element", "")):
		"gelo":
			loss += 1
		"ar":
			loss += 1
		"fogo":
			loss += 2
	if str(encounter.get("mode", "")) in ["duelo", "invasao", "chefe_summoner"]:
		loss += 1
	if map_index >= 28:
		loss += 1
	return loss
