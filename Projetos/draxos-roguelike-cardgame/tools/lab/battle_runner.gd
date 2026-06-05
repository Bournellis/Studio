extends RefCounted

const BattleEvaluatorScript = preload("res://tools/lab/battle_evaluator.gd")
const BattlePolicyScript = preload("res://tools/lab/battle_policy.gd")
const SCHEMA_VERSION: int = 1
const TOOL_ID: String = "gameplay_battle_lab"

static func run_cases(catalog, pack: Dictionary, cases: Array[Dictionary], options: Dictionary = {}) -> Dictionary:
	var records: Array[Dictionary] = []
	var stopped_early: bool = false
	for case_data: Dictionary in cases:
		var metrics: Dictionary = run_case(catalog, pack, case_data, options)
		var evaluation: Dictionary = BattleEvaluatorScript.evaluate(case_data, metrics)
		var status: String = str(evaluation.get("status", BattleEvaluatorScript.STATUS_FAIL))
		var timeline: Array = Array(metrics.get("timeline", []))
		var tags: Array[String] = _string_array(Array(case_data.get("tags", [])))
		records.append({
			"schema_version": SCHEMA_VERSION,
			"tool": TOOL_ID,
			"case": case_data.duplicate(true),
			"result": metrics.duplicate(true),
			"timeline": timeline.duplicate(true),
			"expectations": Array(evaluation.get("expectations", [])).duplicate(true),
			"warnings": Array(evaluation.get("warnings", [])).duplicate(true),
			"failures": Array(evaluation.get("failures", [])).duplicate(true),
			"tags": tags,
			"status": status
		})
		if bool(options.get("stop_on_failure", false)) and status == BattleEvaluatorScript.STATUS_FAIL:
			stopped_early = true
			break
	var summary: Dictionary = summarize(records, pack, options)
	return {
		"ok": int(summary.get("fail_count", 0)) == 0,
		"records": records,
		"summary": summary,
		"stopped_early": stopped_early
	}

static func run_case(catalog, pack: Dictionary, case_data: Dictionary, options: Dictionary = {}) -> Dictionary:
	var encounter_id: String = str(case_data.get("encounter_id", ""))
	var encounter: Dictionary = _resolve_encounter(catalog, case_data)
	if encounter.is_empty():
		return _error_metrics(case_data, "Encounter not found: %s." % encounter_id)
	var deck_ids: Array[String] = _string_array(Array(case_data.get("deck", [])))
	var config: Dictionary = _battle_config(case_data, encounter)
	var battle_engine_script = load("res://battle/battle_engine.gd")
	var engine = battle_engine_script.new()
	engine.start_battle(catalog, deck_ids, config)
	var initial_state: Dictionary = _engine_state(engine)
	var metrics: Dictionary = _initial_metrics(pack, case_data, encounter, initial_state, options)
	var policy_id: String = BattlePolicyScript.resolve_policy_id(case_data, str(options.get("policy", "")))
	var turn_limit: int = maxi(1, int(case_data.get("turn_limit", 12)))
	while str(_engine_state(engine).get("outcome", "")) == "" and int(metrics.get("combat_cycles", 0)) < turn_limit:
		var policy_result: Dictionary = BattlePolicyScript.play_turn(engine, policy_id, _policy_options(case_data, options))
		var state: Dictionary = _engine_state(engine)
		_record_policy_result(metrics, policy_result)
		metrics["combat_cycles"] = int(metrics.get("combat_cycles", 0)) + 1
		_append_timeline(metrics, state, policy_result)
		if not bool(policy_result.get("ok", true)):
			var runner_warnings: Array = Array(metrics.get("runner_warnings", []))
			runner_warnings.append("Policy action rejected: %s" % str(policy_result.get("failed_actions", [])))
			metrics["runner_warnings"] = runner_warnings
			break
	var final_state: Dictionary = _engine_state(engine)
	_finalize_metrics(metrics, initial_state, final_state, turn_limit)
	return metrics

static func summarize(records: Array[Dictionary], pack: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var summary: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"pack_id": str(pack.get("pack_id", "")),
		"simulation_mode": str(pack.get("simulation_mode", "battle_engine_v1")),
		"mode": str(options.get("mode", "explore")),
		"total_cases": records.size(),
		"pass_count": 0,
		"warn_count": 0,
		"fail_count": 0,
		"by_tag": {},
		"by_class": {},
		"by_policy": {},
		"by_encounter": {},
		"failures": [],
		"warnings": [],
		"critical_checkpoints": []
	}
	for record: Dictionary in records:
		var status: String = str(record.get("status", BattleEvaluatorScript.STATUS_FAIL))
		match status:
			BattleEvaluatorScript.STATUS_PASS:
				summary["pass_count"] = int(summary.get("pass_count", 0)) + 1
			BattleEvaluatorScript.STATUS_WARN:
				summary["warn_count"] = int(summary.get("warn_count", 0)) + 1
			_:
				summary["fail_count"] = int(summary.get("fail_count", 0)) + 1
		var case_data: Dictionary = Dictionary(record.get("case", {}))
		_increment_group(summary, "by_class", str(case_data.get("class_id", "")), status)
		_increment_group(summary, "by_policy", str(case_data.get("policy_id", "")), status)
		_increment_group(summary, "by_encounter", str(case_data.get("encounter_id", "")), status)
		for tag: String in _string_array(Array(record.get("tags", []))):
			_increment_group(summary, "by_tag", tag, status)
		for failure: Variant in Array(record.get("failures", [])):
			var failures: Array = Array(summary.get("failures", []))
			failures.append({"case_id": str(case_data.get("id", "")), "message": str(failure)})
			summary["failures"] = failures
		for warning: Variant in Array(record.get("warnings", [])):
			var warnings: Array = Array(summary.get("warnings", []))
			warnings.append({"case_id": str(case_data.get("id", "")), "message": str(warning)})
			summary["warnings"] = warnings
		_append_critical_checkpoint(summary, record)
	return summary

static func _resolve_encounter(catalog, case_data: Dictionary) -> Dictionary:
	if catalog == null:
		return {}
	var encounter: Dictionary = catalog.find_encounter(str(case_data.get("encounter_id", "")))
	var encounter_override: Dictionary = Dictionary(case_data.get("encounter_override", {}))
	if encounter.is_empty():
		if not encounter_override.is_empty():
			return encounter_override.duplicate(true)
		return {}
	var resolved: Dictionary = encounter.duplicate(true)
	for key: Variant in encounter_override.keys():
		resolved[key] = encounter_override.get(key)
	return resolved

static func _battle_config(case_data: Dictionary, encounter: Dictionary) -> Dictionary:
	var source_config: Dictionary = Dictionary(case_data.get("config", {}))
	var config: Dictionary = {}
	for key: Variant in source_config.keys():
		config[key] = source_config.get(key)
	config["class_id"] = str(case_data.get("class_id", ""))
	config["shuffle_deck"] = bool(source_config.get("shuffle_deck", false))
	config["shuffle_seed"] = int(source_config.get("shuffle_seed", case_data.get("seed", 0)))
	config["encounter"] = encounter.duplicate(true)
	return config

static func _engine_state(engine) -> Dictionary:
	return {
		"turn": int(engine.turn_number),
		"player_health": int(engine.player_health),
		"player_max_health": int(engine.player_max_health),
		"enemy_health": int(engine.enemy_health),
		"enemy_max_health": int(engine.enemy_max_health),
		"mana": int(engine.mana),
		"mana_per_turn": int(engine.mana_per_turn),
		"max_hand_size": int(engine.max_hand_size),
		"deck": engine.deck.duplicate(),
		"discard": engine.discard.duplicate(),
		"hand": engine.hand.duplicate(),
		"pending_choices": engine.pending_choices.duplicate(true),
		"player_slots": engine.player_slots.duplicate(true),
		"enemy_slots": engine.enemy_slots.duplicate(true),
		"log": engine.log_lines.duplicate(),
		"visual_events": engine.visual_events.duplicate(true),
		"outcome": str(engine.outcome),
		"current_phase": str(engine.current_phase),
		"mode": str(engine.mode),
		"encounter_id": str(engine.encounter_id),
		"field_effects": engine.field_effects.duplicate(),
		"selected_class_id": str(engine.selected_class_id),
		"class_active_used": bool(engine.class_active_used)
	}

static func _initial_metrics(pack: Dictionary, case_data: Dictionary, encounter: Dictionary, initial_state: Dictionary, options: Dictionary) -> Dictionary:
	return {
		"ok": true,
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"pack_id": str(pack.get("pack_id", "")),
		"simulation_mode": str(pack.get("simulation_mode", "battle_engine_v1")),
		"mode": str(options.get("mode", "explore")),
		"case_id": str(case_data.get("id", "")),
		"class_id": str(case_data.get("class_id", "")),
		"encounter_id": str(case_data.get("encounter_id", "")),
		"encounter_name": str(encounter.get("display_name", case_data.get("encounter_id", ""))),
		"encounter_mode": str(encounter.get("mode", "")),
		"policy_id": BattlePolicyScript.resolve_policy_id(case_data, str(options.get("policy", ""))),
		"seed": int(case_data.get("seed", 0)),
		"turn_limit": int(case_data.get("turn_limit", 12)),
		"turn_count": 0,
		"combat_cycles": 0,
		"cards_played": 0,
		"class_active_uses": 0,
		"pending_choices_resolved": 0,
		"player_hp": int(initial_state.get("player_health", 0)),
		"enemy_hp": int(initial_state.get("enemy_health", 0)),
		"player_max_hp": int(initial_state.get("player_max_health", 0)),
		"enemy_max_hp": int(initial_state.get("enemy_max_health", 0)),
		"player_units_alive": _occupied_count(Array(initial_state.get("player_slots", []))),
		"enemy_units_alive": _occupied_count(Array(initial_state.get("enemy_slots", []))),
		"damage_to_enemy_hero": 0,
		"damage_to_player_hero": 0,
		"card_under_test": str(Dictionary(case_data.get("card_under_test", {})).get("id", "")),
		"card_under_test_kind": str(Dictionary(case_data.get("card_under_test", {})).get("kind", "")),
		"card_under_test_played": false,
		"card_under_test_play_count": 0,
		"card_under_test_seen": _state_contains_card(initial_state, str(Dictionary(case_data.get("card_under_test", {})).get("id", ""))),
		"card_under_test_participated": false,
		"policy_action_rejected": false,
		"outcome": str(initial_state.get("outcome", "")),
		"terminated": false,
		"runner_warnings": [],
		"timeline": []
	}

static func _record_policy_result(metrics: Dictionary, policy_result: Dictionary) -> void:
	var cards_played: Array = Array(policy_result.get("cards_played", []))
	metrics["cards_played"] = int(metrics.get("cards_played", 0)) + cards_played.size()
	metrics["pending_choices_resolved"] = int(metrics.get("pending_choices_resolved", 0)) + int(policy_result.get("pending_choices_resolved", 0))
	if bool(policy_result.get("active_used", false)):
		metrics["class_active_uses"] = int(metrics.get("class_active_uses", 0)) + 1
	var card_under_test: String = str(metrics.get("card_under_test", ""))
	if card_under_test != "":
		for play: Variant in cards_played:
			var played_card: Dictionary = Dictionary(play)
			if str(played_card.get("card_id", "")) == card_under_test:
				metrics["card_under_test_played"] = true
				metrics["card_under_test_play_count"] = int(metrics.get("card_under_test_play_count", 0)) + 1
	if not bool(policy_result.get("ok", true)):
		metrics["policy_action_rejected"] = true

static func _append_timeline(metrics: Dictionary, state: Dictionary, policy_result: Dictionary) -> void:
	var card_under_test: String = str(metrics.get("card_under_test", ""))
	if card_under_test != "" and _state_contains_card(state, card_under_test):
		metrics["card_under_test_seen"] = true
	var timeline: Array = Array(metrics.get("timeline", []))
	timeline.append({
		"cycle": int(metrics.get("combat_cycles", 0)),
		"turn": int(state.get("turn", 0)),
		"player_hp": int(state.get("player_health", 0)),
		"enemy_hp": int(state.get("enemy_health", 0)),
		"mana": int(state.get("mana", 0)),
		"hand_size": Array(state.get("hand", [])).size(),
		"deck_size": Array(state.get("deck", [])).size(),
		"discard_size": Array(state.get("discard", [])).size(),
		"player_units_alive": _occupied_count(Array(state.get("player_slots", []))),
		"enemy_units_alive": _occupied_count(Array(state.get("enemy_slots", []))),
		"cards_played": Array(policy_result.get("cards_played", [])).duplicate(true),
		"active_used": bool(policy_result.get("active_used", false)),
		"pending_choices_resolved": int(policy_result.get("pending_choices_resolved", 0)),
		"outcome": str(state.get("outcome", "")),
		"log_tail": _tail_strings(Array(state.get("log", [])), 5),
		"visual_event_count": Array(state.get("visual_events", [])).size(),
		"visual_event_types": _visual_event_types(Array(state.get("visual_events", [])))
	})
	metrics["timeline"] = timeline

static func _finalize_metrics(metrics: Dictionary, initial_state: Dictionary, final_state: Dictionary, turn_limit: int) -> void:
	var outcome: String = str(final_state.get("outcome", ""))
	metrics["turn_count"] = int(metrics.get("combat_cycles", 0))
	metrics["player_hp"] = int(final_state.get("player_health", 0))
	metrics["enemy_hp"] = int(final_state.get("enemy_health", 0))
	metrics["player_units_alive"] = _occupied_count(Array(final_state.get("player_slots", [])))
	metrics["enemy_units_alive"] = _occupied_count(Array(final_state.get("enemy_slots", [])))
	metrics["damage_to_enemy_hero"] = maxi(0, int(initial_state.get("enemy_health", 0)) - int(final_state.get("enemy_health", 0)))
	metrics["damage_to_player_hero"] = maxi(0, int(initial_state.get("player_health", 0)) - int(final_state.get("player_health", 0)))
	var card_under_test: String = str(metrics.get("card_under_test", ""))
	if card_under_test != "" and _state_contains_card(final_state, card_under_test):
		metrics["card_under_test_seen"] = true
	var card_kind: String = str(metrics.get("card_under_test_kind", ""))
	metrics["card_under_test_participated"] = bool(metrics.get("card_under_test_played", false))
	if card_kind == "enemy":
		metrics["card_under_test_participated"] = bool(metrics.get("card_under_test_seen", false)) and int(metrics.get("combat_cycles", 0)) > 0
	metrics["outcome"] = outcome
	metrics["terminated"] = outcome != ""
	metrics["turn_limit_hit"] = outcome == "" and int(metrics.get("combat_cycles", 0)) >= turn_limit
	metrics["log_tail"] = _tail_strings(Array(final_state.get("log", [])), 12)
	metrics["visual_event_count"] = Array(final_state.get("visual_events", [])).size()
	metrics["visual_event_types"] = _visual_event_types(Array(final_state.get("visual_events", [])))

static func _error_metrics(case_data: Dictionary, message: String) -> Dictionary:
	return {
		"ok": false,
		"case_id": str(case_data.get("id", "")),
		"class_id": str(case_data.get("class_id", "")),
		"encounter_id": str(case_data.get("encounter_id", "")),
		"policy_id": str(case_data.get("policy_id", "")),
		"outcome": "",
		"terminated": false,
		"turn_count": 0,
		"combat_cycles": 0,
		"cards_played": 0,
		"player_hp": 0,
		"enemy_hp": 0,
		"player_units_alive": 0,
		"enemy_units_alive": 0,
		"damage_to_enemy_hero": 0,
		"damage_to_player_hero": 0,
		"card_under_test": str(Dictionary(case_data.get("card_under_test", {})).get("id", "")),
		"card_under_test_kind": str(Dictionary(case_data.get("card_under_test", {})).get("kind", "")),
		"card_under_test_played": false,
		"card_under_test_play_count": 0,
		"card_under_test_seen": false,
		"card_under_test_participated": false,
		"policy_action_rejected": true,
		"runner_warnings": [message],
		"timeline": []
	}

static func _policy_options(case_data: Dictionary, options: Dictionary) -> Dictionary:
	var policy_options: Dictionary = options.duplicate(true)
	var card_under_test: Dictionary = Dictionary(case_data.get("card_under_test", {}))
	if not card_under_test.is_empty():
		policy_options["card_under_test"] = str(card_under_test.get("id", ""))
	return policy_options

static func _state_contains_card(state: Dictionary, card_id: String) -> bool:
	if card_id == "":
		return false
	for field: String in ["hand", "deck", "discard", "enemy_hand", "enemy_deck", "enemy_discard"]:
		if Array(state.get(field, [])).has(card_id):
			return true
	for field: String in ["player_slots", "enemy_slots"]:
		for occupant_value: Variant in Array(state.get(field, [])):
			if typeof(occupant_value) == TYPE_DICTIONARY and str(Dictionary(occupant_value).get("card_id", "")) == card_id:
				return true
	return false

static func _append_critical_checkpoint(summary: Dictionary, record: Dictionary) -> void:
	var case_data: Dictionary = Dictionary(record.get("case", {}))
	var result: Dictionary = Dictionary(record.get("result", {}))
	var tags: Array = Array(record.get("tags", []))
	if not (tags.has("boss") or tags.has("survive") or tags.has("defense") or tags.has("field") or str(record.get("status", "")) != BattleEvaluatorScript.STATUS_PASS):
		return
	var checkpoints: Array = Array(summary.get("critical_checkpoints", []))
	checkpoints.append({
		"case_id": str(case_data.get("id", "")),
		"status": str(record.get("status", "")),
		"outcome": str(result.get("outcome", "")),
		"turn_count": int(result.get("turn_count", 0)),
		"player_hp": int(result.get("player_hp", 0)),
		"enemy_hp": int(result.get("enemy_hp", 0)),
		"tags": _string_array(tags)
	})
	summary["critical_checkpoints"] = checkpoints

static func _increment_group(summary: Dictionary, group_name: String, key: String, status: String) -> void:
	if key == "":
		key = "unknown"
	var groups: Dictionary = Dictionary(summary.get(group_name, {}))
	if not groups.has(key):
		groups[key] = {"total": 0, "pass": 0, "warn": 0, "fail": 0}
	var group: Dictionary = Dictionary(groups.get(key, {}))
	group["total"] = int(group.get("total", 0)) + 1
	match status:
		BattleEvaluatorScript.STATUS_PASS:
			group["pass"] = int(group.get("pass", 0)) + 1
		BattleEvaluatorScript.STATUS_WARN:
			group["warn"] = int(group.get("warn", 0)) + 1
		_:
			group["fail"] = int(group.get("fail", 0)) + 1
	groups[key] = group
	summary[group_name] = groups

static func _occupied_count(slots: Array) -> int:
	var count: int = 0
	for slot_value: Variant in slots:
		if slot_value != null:
			count += 1
	return count

static func _visual_event_types(events: Array) -> Dictionary:
	var counts: Dictionary = {}
	for event_value: Variant in events:
		if typeof(event_value) != TYPE_DICTIONARY:
			continue
		var event: Dictionary = Dictionary(event_value)
		var key: String = str(event.get("type", "unknown"))
		counts[key] = int(counts.get(key, 0)) + 1
	return counts

static func _tail_strings(values: Array, count: int) -> Array[String]:
	var result: Array[String] = []
	var start_index: int = maxi(0, values.size() - count)
	for index: int in range(start_index, values.size()):
		result.append(str(values[index]))
	return result

static func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str(value))
	return result
