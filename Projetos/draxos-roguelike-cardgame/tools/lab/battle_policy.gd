extends RefCounted

const BattleEffectSignatureScript = preload("res://tools/lab/battle_effect_signature.gd")

const PLAYER_ID: String = "jogador"
const ENEMY_ID: String = "inimigo"
const POLICY_BASELINE: String = "baseline_legal"
const POLICY_AGGRESSIVE: String = "aggressive_legal"
const POLICY_DEFENSIVE: String = "defensive_legal"
const POLICY_END_TURN: String = "end_turn_only"
const POLICY_CARD_FOCUS: String = "card_focus_legal"
const POLICY_CARD_FOCUS_ISOLATED: String = "card_focus_isolated"
const DEFAULT_MAX_ACTIONS_PER_TURN: int = 24
const DEFAULT_MAX_PENDING_RESOLUTIONS: int = 12

static func supported_policies() -> PackedStringArray:
	return PackedStringArray([POLICY_BASELINE, POLICY_AGGRESSIVE, POLICY_DEFENSIVE, POLICY_END_TURN, POLICY_CARD_FOCUS, POLICY_CARD_FOCUS_ISOLATED])

static func resolve_policy_id(case_data: Dictionary, override_policy_id: String = "") -> String:
	var policy_id: String = override_policy_id.strip_edges()
	if policy_id == "":
		policy_id = str(case_data.get("policy_id", POLICY_BASELINE))
	if not supported_policies().has(policy_id):
		return POLICY_BASELINE
	return policy_id

static func play_turn(engine, policy_id: String, options: Dictionary = {}) -> Dictionary:
	var max_actions: int = int(options.get("max_actions_per_turn", DEFAULT_MAX_ACTIONS_PER_TURN))
	var result: Dictionary = {
		"ok": true,
		"policy_id": policy_id,
		"cards_played": [],
		"active_used": false,
		"active_choice": "",
		"pending_choices_resolved": 0,
		"failed_actions": [],
		"combat_cycle": {},
		"effect_samples": []
	}
	_resolve_pending_choices(engine, policy_id, result)
	if policy_id != POLICY_END_TURN:
		_try_class_active(engine, policy_id, result)
	var action_count: int = 0
	while action_count < max_actions and policy_id != POLICY_END_TURN:
		_resolve_pending_choices(engine, policy_id, result)
		var state: Dictionary = _engine_state(engine)
		if str(state.get("outcome", "")) != "":
			break
		var candidate: Dictionary = _best_card_candidate(engine, policy_id, options)
		if candidate.is_empty():
			break
		var focused_card_id: String = str(options.get("card_under_test", ""))
		var is_focus_policy: bool = policy_id == POLICY_CARD_FOCUS or policy_id == POLICY_CARD_FOCUS_ISOLATED
		var is_focused_card: bool = is_focus_policy and focused_card_id != "" and str(candidate.get("card_id", "")) == focused_card_id
		var before_effect_snapshot: Dictionary = BattleEffectSignatureScript.snapshot_from_engine(engine) if is_focused_card else {}
		var play_result: Dictionary = engine.play_card_from_hand(int(candidate.get("hand_index", -1)), Dictionary(candidate.get("target", {})))
		if bool(play_result.get("requires_confirmation", false)) and _should_confirm_sacrifice(engine, policy_id):
			var confirmed_target: Dictionary = Dictionary(play_result.get("target", candidate.get("target", {}))).duplicate()
			confirmed_target["confirm_sacrifice"] = true
			play_result = engine.play_card_from_hand(int(play_result.get("hand_index", candidate.get("hand_index", -1))), confirmed_target)
			candidate["target"] = confirmed_target
		if not bool(play_result.get("ok", false)):
			var failed_actions: Array = Array(result.get("failed_actions", []))
			failed_actions.append({
				"card_id": str(candidate.get("card_id", "")),
				"hand_index": int(candidate.get("hand_index", -1)),
				"target": Dictionary(candidate.get("target", {})).duplicate(true),
				"message": str(play_result.get("message", "Action rejected."))
			})
			result["failed_actions"] = failed_actions
			result["ok"] = false
			break
		if is_focused_card:
			_resolve_pending_choices(engine, policy_id, result)
			var after_effect_snapshot: Dictionary = BattleEffectSignatureScript.snapshot_from_engine(engine)
			var effect_samples: Array = Array(result.get("effect_samples", []))
			var effect_sample: Dictionary = BattleEffectSignatureScript.build_sample(
				focused_card_id,
				Dictionary(candidate.get("target", {})),
				before_effect_snapshot,
				after_effect_snapshot
			)
			var support_cards_before: Array = _card_ids_from_plays(Array(result.get("cards_played", [])))
			effect_sample["focused_card_play_index"] = support_cards_before.size()
			effect_sample["support_cards_before_target"] = support_cards_before.duplicate()
			effect_sample["support_card_count_before_target"] = support_cards_before.size()
			if not support_cards_before.is_empty():
				effect_sample["support_contamination_status"] = "support_assisted"
				effect_sample["signature_confidence"] = "support_assisted"
				effect_sample["ambiguous_reason"] = "support cards were played before the focused card"
			effect_samples.append(effect_sample)
			result["effect_samples"] = effect_samples
		var cards_played: Array = Array(result.get("cards_played", []))
		cards_played.append({
			"card_id": str(candidate.get("card_id", "")),
			"name": str(candidate.get("name", "")),
			"hand_index": int(candidate.get("hand_index", -1)),
			"target": Dictionary(candidate.get("target", {})).duplicate(true),
			"score": float(candidate.get("score", 0.0))
		})
		result["cards_played"] = cards_played
		action_count += 1
		if is_focused_card and policy_id == POLICY_CARD_FOCUS_ISOLATED:
			result["target_captured"] = true
			result["stopped_after_target"] = bool(Dictionary(options.get("target_capture", {})).get("stop_after_target", true))
			if bool(result.get("stopped_after_target", true)):
				break
	_resolve_pending_choices(engine, policy_id, result)
	if str(_engine_state(engine).get("outcome", "")) == "":
		var cycle_result: Dictionary = engine.resolve_combat_cycle()
		result["combat_cycle"] = cycle_result.duplicate(true)
		if not bool(cycle_result.get("ok", false)):
			var failed_cycle: Array = Array(result.get("failed_actions", []))
			failed_cycle.append({"message": str(cycle_result.get("message", "Combat cycle rejected.")), "kind": "combat_cycle"})
			result["failed_actions"] = failed_cycle
			result["ok"] = false
	return result

static func _resolve_pending_choices(engine, policy_id: String, result: Dictionary) -> void:
	var guard: int = 0
	while engine.has_pending_choice() and guard < DEFAULT_MAX_PENDING_RESOLUTIONS:
		guard += 1
		var choice: Dictionary = engine.get_pending_choice()
		var option_id: String = _choose_pending_option(choice, policy_id)
		var target: Dictionary = _choose_pending_target(engine, policy_id)
		var resolved: Dictionary = engine.resolve_pending_choice(target, option_id)
		if not bool(resolved.get("ok", false)):
			var failed_actions: Array = Array(result.get("failed_actions", []))
			failed_actions.append({"message": str(resolved.get("message", "Pending choice rejected.")), "kind": "pending_choice"})
			result["failed_actions"] = failed_actions
			result["ok"] = false
			break
		result["pending_choices_resolved"] = int(result.get("pending_choices_resolved", 0)) + 1

static func _try_class_active(engine, policy_id: String, result: Dictionary) -> void:
	if not engine.can_use_class_active():
		return
	var state: Dictionary = _engine_state(engine)
	var class_id: String = str(state.get("selected_class_id", ""))
	var choice_id: String = ""
	if class_id == "necromante":
		choice_id = _choose_necro_active_choice(engine, policy_id)
		if choice_id == "":
			return
	var targets: Array[Dictionary] = engine.get_valid_class_active_targets(choice_id)
	if targets.is_empty():
		return
	var target: Dictionary = _best_target(state, targets, policy_id, "class_active")
	if target.is_empty() or not engine.can_use_class_active_on_target(target, choice_id):
		return
	var active_result: Dictionary = engine.use_class_active(target, choice_id)
	if bool(active_result.get("ok", false)):
		result["active_used"] = true
		result["active_choice"] = choice_id
	else:
		var failed_actions: Array = Array(result.get("failed_actions", []))
		failed_actions.append({"message": str(active_result.get("message", "Class active rejected.")), "kind": "class_active"})
		result["failed_actions"] = failed_actions
		result["ok"] = false

static func _card_ids_from_plays(plays: Array) -> Array:
	var ids: Array = []
	for play_value: Variant in plays:
		if typeof(play_value) != TYPE_DICTIONARY:
			continue
		var card_id: String = str(Dictionary(play_value).get("card_id", ""))
		if card_id != "":
			ids.append(card_id)
	return ids

static func _best_card_candidate(engine, policy_id: String, options: Dictionary = {}) -> Dictionary:
	if policy_id == POLICY_CARD_FOCUS or policy_id == POLICY_CARD_FOCUS_ISOLATED:
		if policy_id == POLICY_CARD_FOCUS_ISOLATED and bool(options.get("target_already_captured", false)):
			return {}
		var focused: Dictionary = _focused_card_candidate(engine, str(options.get("card_under_test", "")))
		if not focused.is_empty():
			return focused
		var enabling: Dictionary = _enabling_card_candidate(engine, str(options.get("card_under_test", "")), Dictionary(options.get("target_capture", {})))
		if not enabling.is_empty():
			return enabling
	var state: Dictionary = _engine_state(engine)
	var hand: Array = Array(state.get("hand", []))
	var best: Dictionary = {}
	var best_score: float = -999999.0
	for hand_index: int in range(hand.size()):
		var card_id: String = str(hand[hand_index])
		var card = engine._card(card_id)
		if card == null:
			continue
		var targets: Array[Dictionary] = _legal_targets_for_card(engine, hand_index)
		for target: Dictionary in targets:
			if _target_requires_sacrifice(state, target) and policy_id == POLICY_DEFENSIVE and _has_open_player_slot(state):
				continue
			var score: float = _card_score(card, target, state, policy_id) - float(hand_index) * 0.01
			if score > best_score:
				best_score = score
				best = {
					"hand_index": hand_index,
					"card_id": card_id,
					"name": str(card.display_name),
					"target": target.duplicate(true),
					"score": score
				}
	return best

static func _focused_card_candidate(engine, card_under_test: String) -> Dictionary:
	if card_under_test == "":
		return {}
	var state: Dictionary = _engine_state(engine)
	var hand: Array = Array(state.get("hand", []))
	for hand_index: int in range(hand.size()):
		var card_id: String = str(hand[hand_index])
		if card_id != card_under_test:
			continue
		var card = engine._card(card_id)
		if card == null:
			continue
		var targets: Array[Dictionary] = _legal_targets_for_card(engine, hand_index)
		if targets.is_empty():
			return {}
		var best_target: Dictionary = {}
		if targets.size() == 1 and Dictionary(targets[0]).is_empty():
			best_target = {}
		else:
			best_target = _best_target(state, targets, POLICY_BASELINE, str(Dictionary(card.effect).get("action", "")))
		return {
			"hand_index": hand_index,
			"card_id": card_id,
			"name": str(card.display_name),
			"target": best_target.duplicate(true),
			"score": 9999.0
		}
	return {}

static func _enabling_card_candidate(engine, card_under_test: String, target_capture: Dictionary = {}) -> Dictionary:
	if card_under_test == "":
		return {}
	if int(target_capture.get("max_support_cards_before_target", 999)) <= 0:
		return {}
	var focus_card = engine._card(card_under_test)
	if focus_card == null:
		return {}
	var action: String = str(Dictionary(focus_card.effect).get("action", ""))
	if not (action in ["buff_ally", "promote", "buff_all_allies", "gain_mana", "shield_all_allies"]):
		return {}
	var state: Dictionary = _engine_state(engine)
	if _occupied_count(Array(state.get("player_slots", []))) != 0:
		return {}
	var hand: Array = Array(state.get("hand", []))
	for hand_index: int in range(hand.size()):
		var card_id: String = str(hand[hand_index])
		if card_id == card_under_test:
			continue
		var card = engine._card(card_id)
		if card == null or not card.occupies_slot():
			continue
		var targets: Array[Dictionary] = _legal_targets_for_card(engine, hand_index)
		if targets.is_empty():
			continue
		return {
			"hand_index": hand_index,
			"card_id": card_id,
			"name": str(card.display_name),
			"target": Dictionary(targets[0]).duplicate(true),
			"score": 9998.0
		}
	return {}

static func _legal_targets_for_card(engine, hand_index: int) -> Array[Dictionary]:
	var targets: Array[Dictionary] = []
	if engine.can_play_card_without_target(hand_index):
		targets.append({})
	for target: Dictionary in engine.get_valid_card_targets(hand_index):
		if engine.can_play_card_on_target(hand_index, target):
			targets.append(target.duplicate(true))
	return targets

static func _card_score(card, target: Dictionary, state: Dictionary, policy_id: String) -> float:
	var score: float = 0.0
	var effect: Dictionary = Dictionary(card.effect)
	var action: String = str(effect.get("action", ""))
	var occupies_slot: bool = card.occupies_slot()
	if occupies_slot:
		score += 12.0 + float(card.attack) * 2.0 + float(card.health)
		if Array(card.keywords).has("defensor"):
			score += 8.0 if policy_id == POLICY_DEFENSIVE else 4.0
		if Array(card.keywords).has("iniciativa"):
			score += 5.0 if policy_id == POLICY_AGGRESSIVE else 2.0
		if Array(card.keywords).has("regeneracao"):
			score += 5.0
	else:
		score += 5.0
		match action:
			"damage", "flow_damage", "adjacent_damage", "random_damage", "all_enemy_damage", "poison_all_enemies":
				score += 22.0 if policy_id == POLICY_AGGRESSIVE else 14.0
			"debuff", "weaken", "snare", "multi_debuff", "punish_snared", "freeze_random_enemy":
				score += 18.0
			"buff_ally", "promote", "buff_all_allies", "shield_all_allies":
				score += 18.0 if policy_id == POLICY_DEFENSIVE else 12.0
			"gain_mana", "gain_ashes":
				score += 6.0
	score += _target_score(state, target, policy_id, action)
	score -= float(card.cost) * 0.25
	if _target_requires_sacrifice(state, target):
		score -= 18.0 if policy_id == POLICY_DEFENSIVE else 4.0
	return score

static func _target_score(state: Dictionary, target: Dictionary, policy_id: String, action: String = "") -> float:
	if target.is_empty():
		return 2.0
	var owner: String = str(target.get("owner", ""))
	if bool(target.get("hero", false)):
		if owner == ENEMY_ID:
			return 80.0 if policy_id == POLICY_AGGRESSIVE else 30.0
		return -50.0
	if str(target.get("area", "")) == "board":
		if owner == ENEMY_ID:
			return 28.0 if policy_id == POLICY_AGGRESSIVE else 18.0
		return 20.0 if policy_id == POLICY_DEFENSIVE else 12.0
	if target.has("slot"):
		var occupant: Dictionary = _occupant_at(state, owner, int(target.get("slot", -1)))
		if owner == ENEMY_ID:
			if occupant.is_empty():
				return 0.0
			return float(occupant.get("attack", 0)) * 4.0 + float(occupant.get("health", 0)) * 1.5
		if owner == PLAYER_ID:
			if occupant.is_empty():
				return 8.0
			if action in ["buff_ally", "promote", "buff_all_allies", "shield_all_allies", "class_active"]:
				return float(occupant.get("attack", 0)) * 1.5 + float(occupant.get("health", 0)) + 8.0
			return 0.0
	return 0.0

static func _best_target(state: Dictionary, targets: Array[Dictionary], policy_id: String, action: String = "") -> Dictionary:
	var best: Dictionary = {}
	var best_score: float = -999999.0
	for target: Dictionary in targets:
		var score: float = _target_score(state, target, policy_id, action)
		if score > best_score:
			best_score = score
			best = target.duplicate(true)
	return best

static func _choose_pending_option(choice: Dictionary, policy_id: String) -> String:
	var options: Array = Array(choice.get("options", []))
	if options.is_empty():
		return ""
	var preferred: PackedStringArray = PackedStringArray()
	match policy_id:
		POLICY_AGGRESSIVE:
			preferred = PackedStringArray(["initiative", "stats", "defender"])
		POLICY_DEFENSIVE:
			preferred = PackedStringArray(["defender", "stats", "initiative"])
		_:
			preferred = PackedStringArray(["stats", "initiative", "defender"])
	for option_id: String in preferred:
		for option_value: Variant in options:
			var option: Dictionary = Dictionary(option_value)
			if str(option.get("id", "")) == option_id:
				return option_id
	return str(Dictionary(options[0]).get("id", ""))

static func _choose_pending_target(engine, policy_id: String) -> Dictionary:
	var targets: Array[Dictionary] = engine.get_valid_pending_choice_targets()
	if targets.is_empty():
		return {}
	return _best_target(_engine_state(engine), targets, policy_id, "pending_choice")

static func _choose_necro_active_choice(engine, policy_id: String) -> String:
	var best_choice: String = ""
	var best_score: float = -999999.0
	for choice: Dictionary in engine.get_necromancer_active_choices():
		if not bool(choice.get("enabled", false)):
			continue
		var choice_id: String = str(choice.get("id", ""))
		var score: float = 1.0
		if choice_id.find("lightning") >= 0:
			score += 20.0 if policy_id == POLICY_AGGRESSIVE else 8.0
		elif choice_id.find("rot") >= 0:
			score += 16.0
		elif choice_id.find("revive") >= 0:
			score += 18.0 if policy_id == POLICY_DEFENSIVE else 10.0
		elif choice_id.find("attack") >= 0:
			score += 14.0
		if score > best_score:
			best_score = score
			best_choice = choice_id
	return best_choice

static func _target_requires_sacrifice(state: Dictionary, target: Dictionary) -> bool:
	if str(target.get("owner", "")) != PLAYER_ID or not target.has("slot"):
		return false
	return not _occupant_at(state, PLAYER_ID, int(target.get("slot", -1))).is_empty()

static func _has_open_player_slot(state: Dictionary) -> bool:
	for slot_value: Variant in Array(state.get("player_slots", [])):
		if slot_value == null:
			return true
	return false

static func _occupied_count(slots: Array) -> int:
	var count: int = 0
	for slot_value: Variant in slots:
		if slot_value != null:
			count += 1
	return count

static func _should_confirm_sacrifice(engine, policy_id: String) -> bool:
	if policy_id == POLICY_DEFENSIVE:
		return not _has_open_player_slot(_engine_state(engine))
	return policy_id != POLICY_END_TURN

static func _engine_state(engine) -> Dictionary:
	return {
		"outcome": str(engine.outcome),
		"selected_class_id": str(engine.selected_class_id),
		"hand": engine.hand.duplicate(),
		"player_slots": engine.player_slots.duplicate(true),
		"enemy_slots": engine.enemy_slots.duplicate(true)
	}

static func _occupant_at(state: Dictionary, owner_id: String, slot_index: int) -> Dictionary:
	var key: String = "player_slots" if owner_id == PLAYER_ID else "enemy_slots"
	var slots: Array = Array(state.get(key, []))
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return {}
	return Dictionary(slots[slot_index])
