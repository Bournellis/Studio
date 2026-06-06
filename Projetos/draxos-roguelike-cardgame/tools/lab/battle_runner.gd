extends RefCounted

const BattleEffectSignatureScript = preload("res://tools/lab/battle_effect_signature.gd")
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
	var lab_prestate: Dictionary = _apply_lab_prestate(engine, case_data)
	var initial_state: Dictionary = _engine_state(engine)
	var metrics: Dictionary = _initial_metrics(pack, case_data, encounter, initial_state, options, lab_prestate)
	var policy_id: String = BattlePolicyScript.resolve_policy_id(case_data, str(options.get("policy", "")))
	var turn_limit: int = maxi(1, int(case_data.get("turn_limit", 12)))
	var target_capture: Dictionary = _target_capture_config(pack, case_data)
	while str(_engine_state(engine).get("outcome", "")) == "" and int(metrics.get("combat_cycles", 0)) < turn_limit:
		var policy_options: Dictionary = _policy_options(case_data, options)
		policy_options["target_capture"] = target_capture.duplicate(true)
		policy_options["target_already_captured"] = bool(metrics.get("target_capture_complete", false))
		var policy_result: Dictionary = _play_enemy_signature_turn(engine, case_data) if _is_enemy_signature_case(case_data) else BattlePolicyScript.play_turn(engine, policy_id, policy_options)
		var state: Dictionary = _engine_state(engine)
		_record_policy_result(metrics, policy_result)
		if _is_enemy_signature_case(case_data):
			_record_enemy_signature_result(metrics, policy_result)
		metrics["combat_cycles"] = int(metrics.get("combat_cycles", 0)) + 1
		_record_target_capture_result(metrics, policy_result, state)
		_append_timeline(metrics, state, policy_result)
		if not bool(policy_result.get("ok", true)):
			var runner_warnings: Array = Array(metrics.get("runner_warnings", []))
			runner_warnings.append("Policy action rejected: %s" % str(policy_result.get("failed_actions", [])))
			metrics["runner_warnings"] = runner_warnings
			break
		if _should_stop_after_target_capture(metrics, target_capture):
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

static func _apply_lab_prestate(engine, case_data: Dictionary) -> Dictionary:
	var source: Dictionary = Dictionary(case_data.get("lab_prestate", {}))
	if source.is_empty():
		return {}
	var applied: Dictionary = {}
	if source.has("initial_dead_unit_count"):
		engine.dead_unit_count = maxi(0, int(source.get("initial_dead_unit_count", 0)))
		applied["initial_dead_unit_count"] = int(engine.dead_unit_count)
	return applied

static func _engine_state(engine) -> Dictionary:
	return {
		"turn": int(engine.turn_number),
		"player_health": int(engine.player_health),
		"player_max_health": int(engine.player_max_health),
		"enemy_health": int(engine.enemy_health),
		"enemy_max_health": int(engine.enemy_max_health),
		"mana": int(engine.mana),
		"ashes": int(engine.ashes),
		"dead_unit_count": int(engine.dead_unit_count),
		"mana_per_turn": int(engine.mana_per_turn),
		"max_hand_size": int(engine.max_hand_size),
		"deck": engine.deck.duplicate(),
		"discard": engine.discard.duplicate(),
		"hand": engine.hand.duplicate(),
		"enemy_deck": engine.enemy_deck.duplicate(),
		"enemy_discard": engine.enemy_discard.duplicate(),
		"enemy_hand": engine.enemy_hand.duplicate(),
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

static func _initial_metrics(pack: Dictionary, case_data: Dictionary, encounter: Dictionary, initial_state: Dictionary, options: Dictionary, lab_prestate: Dictionary = {}) -> Dictionary:
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
		"lab_prestate": lab_prestate.duplicate(true),
		"initial_dead_unit_count": int(initial_state.get("dead_unit_count", 0)),
		"turn_count": 0,
		"combat_cycles": 0,
		"cards_played": 0,
		"class_active_uses": 0,
		"pending_choices_resolved": 0,
		"player_hp": int(initial_state.get("player_health", 0)),
		"enemy_hp": int(initial_state.get("enemy_health", 0)),
		"ashes": int(initial_state.get("ashes", 0)),
		"dead_unit_count": int(initial_state.get("dead_unit_count", 0)),
		"player_max_hp": int(initial_state.get("player_max_health", 0)),
		"enemy_max_hp": int(initial_state.get("enemy_max_health", 0)),
		"player_units_alive": _occupied_count(Array(initial_state.get("player_slots", []))),
		"enemy_units_alive": _occupied_count(Array(initial_state.get("enemy_slots", []))),
		"damage_to_enemy_hero": 0,
		"damage_to_player_hero": 0,
		"card_under_test": str(Dictionary(case_data.get("card_under_test", {})).get("id", "")),
		"card_under_test_kind": str(Dictionary(case_data.get("card_under_test", {})).get("kind", "")),
		"card_flow_expected": bool(case_data.get("card_flow_expected", false)),
		"card_under_test_played": false,
		"card_under_test_play_count": 0,
		"card_under_test_seen": _state_contains_card(initial_state, str(Dictionary(case_data.get("card_under_test", {})).get("id", ""))),
		"card_under_test_participated": false,
		"card_play_sequence": [],
		"focused_card_play_index": -1,
		"support_cards_before_target": [],
		"support_cards_after_target": [],
		"support_card_count_before_target": 0,
		"support_card_count_after_target": 0,
		"support_contamination_status": "none",
		"signature_confidence": "none",
		"signature_ambiguous_reason": "",
		"capture_quality": "none",
		"ambiguity_reasons": [],
		"target_capture_mode": str(Dictionary(case_data.get("target_capture", {})).get("mode", "")),
		"target_capture_complete": false,
		"target_card_play_count": 0,
		"target_card_first_play_turn": -1,
		"target_card_first_play_cycle": -1,
		"stopped_after_target": false,
		"card_effect_samples": [],
		"card_effect_signature": {},
		"card_effect_signature_present": false,
		"card_effect_signature_missing_reason": "",
		"enemy_card_under_test_played": false,
		"enemy_card_under_test_play_count": 0,
		"enemy_card_effect_samples": [],
		"enemy_card_effect_signature": {},
		"enemy_card_effect_signature_present": false,
		"enemy_card_effect_signature_missing_reason": "",
		"effect_families": [],
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
	var sequence_before_turn: Array = Array(metrics.get("card_play_sequence", []))
	var global_sequence: Array = sequence_before_turn.duplicate()
	var local_card_ids: Array = _card_ids_from_plays(cards_played)
	for card_id_value: Variant in local_card_ids:
		global_sequence.append(str(card_id_value))
	metrics["card_play_sequence"] = global_sequence
	var effect_samples: Array = Array(metrics.get("card_effect_samples", []))
	var incoming_samples: Array = Array(policy_result.get("effect_samples", []))
	var focused_sample_index: int = 0
	for sample_value: Variant in incoming_samples:
		if typeof(sample_value) == TYPE_DICTIONARY:
			var sample: Dictionary = Dictionary(sample_value).duplicate(true)
			if card_under_test != "":
				var local_focus_index: int = int(sample.get("focused_card_play_index", -1))
				if local_focus_index < 0:
					local_focus_index = _local_focus_index(local_card_ids, card_under_test, focused_sample_index)
				if local_focus_index >= 0:
					var global_focus_index: int = sequence_before_turn.size() + local_focus_index
					sample["focused_card_play_index"] = global_focus_index
					var support_before: Array = _support_cards_in_range(global_sequence, 0, global_focus_index, card_under_test)
					sample["support_cards_before_target"] = support_before.duplicate()
					sample["support_card_count_before_target"] = support_before.size()
					if int(metrics.get("focused_card_play_index", -1)) < 0:
						metrics["focused_card_play_index"] = global_focus_index
					if not support_before.is_empty():
						sample["support_contamination_status"] = "support_assisted"
						sample["signature_confidence"] = "support_assisted"
						if str(sample.get("ambiguous_reason", "")) == "":
							sample["ambiguous_reason"] = "support cards were played before the focused card"
				focused_sample_index += 1
			effect_samples.append(sample)
	metrics["card_effect_samples"] = effect_samples
	if card_under_test != "":
		for play: Variant in cards_played:
			var played_card: Dictionary = Dictionary(play)
			if str(played_card.get("card_id", "")) == card_under_test:
				metrics["card_under_test_played"] = true
				metrics["card_under_test_play_count"] = int(metrics.get("card_under_test_play_count", 0)) + 1
				metrics["target_card_play_count"] = int(metrics.get("card_under_test_play_count", 0))
	if not bool(policy_result.get("ok", true)):
		metrics["policy_action_rejected"] = true

static func _record_enemy_signature_result(metrics: Dictionary, policy_result: Dictionary) -> void:
	var enemy_cards_played: Array = Array(policy_result.get("enemy_cards_played", []))
	var card_under_test: String = str(metrics.get("card_under_test", ""))
	var play_count: int = 0
	for play_value: Variant in enemy_cards_played:
		if typeof(play_value) != TYPE_DICTIONARY:
			continue
		if str(Dictionary(play_value).get("card_id", "")) == card_under_test:
			play_count += 1
	if play_count > 0:
		metrics["enemy_card_under_test_played"] = true
		metrics["enemy_card_under_test_play_count"] = int(metrics.get("enemy_card_under_test_play_count", 0)) + play_count
		metrics["card_under_test_played"] = true
		metrics["card_under_test_play_count"] = int(metrics.get("card_under_test_play_count", 0)) + play_count
		metrics["target_card_play_count"] = int(metrics.get("enemy_card_under_test_play_count", 0))
	var samples: Array = Array(metrics.get("enemy_card_effect_samples", []))
	for sample_value: Variant in Array(policy_result.get("effect_samples", [])):
		if typeof(sample_value) == TYPE_DICTIONARY:
			samples.append(Dictionary(sample_value).duplicate(true))
	metrics["enemy_card_effect_samples"] = samples

static func _play_enemy_signature_turn(engine, case_data: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"ok": true,
		"policy_id": str(case_data.get("policy_id", "end_turn_only")),
		"cards_played": [],
		"enemy_cards_played": [],
		"active_used": false,
		"active_choice": "",
		"pending_choices_resolved": 0,
		"failed_actions": [],
		"combat_cycle": {},
		"effect_samples": [],
		"target_captured": true,
		"stopped_after_target": true
	}
	var card_under_test: String = str(Dictionary(case_data.get("card_under_test", {})).get("id", ""))
	var before_play: Dictionary = BattleEffectSignatureScript.snapshot_from_engine(engine)
	var play: Dictionary = engine._best_enemy_play()
	if play.is_empty():
		result["ok"] = false
		result["failed_actions"] = [{"message": "Enemy commander did not find a legal play.", "kind": "enemy_card"}]
		return result
	var hand_index: int = int(play.get("hand_index", -1))
	var enemy_hand: Array = Array(engine.enemy_hand)
	var played_card_id: String = str(enemy_hand[hand_index]) if hand_index >= 0 and hand_index < enemy_hand.size() else ""
	if played_card_id != card_under_test:
		result["ok"] = false
		result["failed_actions"] = [{
			"message": "Enemy commander selected `%s` instead of `%s`." % [played_card_id, card_under_test],
			"kind": "enemy_card"
		}]
		return result
	if not engine._play_enemy_card_from_hand(hand_index, Dictionary(play.get("target", {}))):
		result["ok"] = false
		result["failed_actions"] = [{
			"card_id": played_card_id,
			"hand_index": hand_index,
			"target": Dictionary(play.get("target", {})).duplicate(true),
			"message": "Enemy card play rejected by BattleEngine.",
			"kind": "enemy_card"
		}]
		return result
	var after_play: Dictionary = BattleEffectSignatureScript.snapshot_from_engine(engine)
	var effect_samples: Array = Array(result.get("effect_samples", []))
	effect_samples.append(BattleEffectSignatureScript.build_enemy_play_sample(played_card_id, before_play, after_play))
	var enemy_cards_played: Array = Array(result.get("enemy_cards_played", []))
	enemy_cards_played.append({
		"card_id": played_card_id,
		"hand_index": hand_index,
		"target": Dictionary(play.get("target", {})).duplicate(true),
		"score": float(play.get("score", 0.0))
	})
	result["enemy_cards_played"] = enemy_cards_played
	engine.enemy_hand_count = 0
	if str(engine.get_state().get("outcome", "")) == "":
		var cycle_result: Dictionary = engine.resolve_combat_cycle()
		result["combat_cycle"] = cycle_result.duplicate(true)
		if not bool(cycle_result.get("ok", false)):
			var failed_cycle: Array = Array(result.get("failed_actions", []))
			failed_cycle.append({"message": str(cycle_result.get("message", "Combat cycle rejected.")), "kind": "combat_cycle"})
			result["failed_actions"] = failed_cycle
			result["ok"] = false
	var after_combat: Dictionary = BattleEffectSignatureScript.snapshot_from_engine(engine)
	effect_samples.append(BattleEffectSignatureScript.build_enemy_combat_sample(played_card_id, after_play, after_combat))
	result["effect_samples"] = effect_samples
	return result

static func _record_target_capture_result(metrics: Dictionary, policy_result: Dictionary, state: Dictionary) -> void:
	if not bool(policy_result.get("target_captured", false)):
		return
	metrics["target_capture_complete"] = true
	metrics["stopped_after_target"] = bool(policy_result.get("stopped_after_target", false))
	if int(metrics.get("target_card_first_play_cycle", -1)) < 0:
		metrics["target_card_first_play_cycle"] = int(metrics.get("combat_cycles", 0))
	if int(metrics.get("target_card_first_play_turn", -1)) < 0:
		metrics["target_card_first_play_turn"] = int(state.get("turn", 0))

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
		"ashes": int(state.get("ashes", 0)),
		"dead_unit_count": int(state.get("dead_unit_count", 0)),
		"hand_size": Array(state.get("hand", [])).size(),
		"deck_size": Array(state.get("deck", [])).size(),
		"discard_size": Array(state.get("discard", [])).size(),
		"player_units_alive": _occupied_count(Array(state.get("player_slots", []))),
		"enemy_units_alive": _occupied_count(Array(state.get("enemy_slots", []))),
		"cards_played": Array(policy_result.get("cards_played", [])).duplicate(true),
		"enemy_cards_played": Array(policy_result.get("enemy_cards_played", [])).duplicate(true),
		"effect_samples": Array(policy_result.get("effect_samples", [])).duplicate(true),
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
	metrics["ashes"] = int(final_state.get("ashes", 0))
	metrics["dead_unit_count"] = int(final_state.get("dead_unit_count", 0))
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
		metrics["card_under_test_participated"] = bool(metrics.get("enemy_card_under_test_played", false)) or (bool(metrics.get("card_under_test_seen", false)) and int(metrics.get("combat_cycles", 0)) > 0)
	_finalize_effect_signature(metrics)
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
		"card_play_sequence": [],
		"focused_card_play_index": -1,
		"support_cards_before_target": [],
		"support_cards_after_target": [],
		"support_card_count_before_target": 0,
		"support_card_count_after_target": 0,
		"support_contamination_status": "missing",
		"signature_confidence": "missing",
		"signature_ambiguous_reason": message,
		"capture_quality": "failed",
		"ambiguity_reasons": [message],
		"target_capture_mode": str(Dictionary(case_data.get("target_capture", {})).get("mode", "")),
		"target_capture_complete": false,
		"target_card_play_count": 0,
		"target_card_first_play_turn": -1,
		"target_card_first_play_cycle": -1,
		"stopped_after_target": false,
		"card_effect_samples": [],
		"card_effect_signature": BattleEffectSignatureScript.empty_missing(str(Dictionary(case_data.get("card_under_test", {})).get("id", "")), message),
		"card_effect_signature_present": false,
		"card_effect_signature_missing_reason": message,
		"enemy_card_under_test_played": false,
		"enemy_card_under_test_play_count": 0,
		"enemy_card_effect_samples": [],
		"enemy_card_effect_signature": BattleEffectSignatureScript.empty_missing(str(Dictionary(case_data.get("card_under_test", {})).get("id", "")), message),
		"enemy_card_effect_signature_present": false,
		"enemy_card_effect_signature_missing_reason": message,
		"effect_families": [],
		"policy_action_rejected": true,
		"runner_warnings": [message],
		"timeline": []
	}

static func _finalize_effect_signature(metrics: Dictionary) -> void:
	var card_id: String = str(metrics.get("card_under_test", ""))
	if card_id == "":
		metrics["card_effect_signature"] = {}
		metrics["card_effect_signature_present"] = false
		metrics["card_effect_signature_missing_reason"] = "no card under test"
		metrics["effect_families"] = []
		return
	var samples: Array = Array(metrics.get("card_effect_samples", []))
	var card_kind: String = str(metrics.get("card_under_test_kind", ""))
	if samples.is_empty():
		var reason: String = "enemy card was not played" if card_kind == "enemy" and not bool(metrics.get("enemy_card_under_test_played", false)) else ("card was not played" if not bool(metrics.get("card_under_test_played", false)) else "card produced no effect sample")
		var missing_signature: Dictionary = BattleEffectSignatureScript.empty_missing(card_id, reason)
		missing_signature["card_flow_expected"] = bool(metrics.get("card_flow_expected", false))
		BattleEffectSignatureScript.apply_card_flow_quality(missing_signature)
		metrics["card_effect_signature"] = missing_signature
		metrics["card_effect_signature_present"] = false
		metrics["card_effect_signature_missing_reason"] = reason
		metrics["capture_quality"] = "failed"
		metrics["ambiguity_reasons"] = [reason]
		metrics["effect_families"] = []
		if card_kind == "enemy":
			metrics["enemy_card_effect_signature"] = missing_signature.duplicate(true)
			metrics["enemy_card_effect_signature_present"] = false
			metrics["enemy_card_effect_signature_missing_reason"] = reason
		return
	var signature: Dictionary = BattleEffectSignatureScript.aggregate(card_id, samples)
	if card_kind == "enemy":
		_apply_enemy_signature_metadata(metrics, signature)
	else:
		_apply_support_metadata(metrics, signature)
	metrics["card_effect_signature"] = signature
	metrics["card_effect_signature_present"] = bool(signature.get("present", false))
	metrics["card_effect_signature_missing_reason"] = ""
	metrics["effect_families"] = Array(signature.get("families", [])).duplicate()

static func _apply_enemy_signature_metadata(metrics: Dictionary, signature: Dictionary) -> void:
	var played: bool = bool(metrics.get("enemy_card_under_test_played", false)) or bool(signature.get("enemy_card_played", false))
	signature["enemy_card_played"] = played
	signature["enemy_card_play_count"] = maxi(int(signature.get("enemy_card_play_count", 0)), int(metrics.get("enemy_card_under_test_play_count", 0)))
	signature["enemy_signature_confidence"] = "clean" if played and bool(signature.get("present", false)) else "missing"
	signature["support_contamination_status"] = str(signature.get("enemy_signature_confidence", "clean"))
	signature["signature_confidence"] = str(signature.get("enemy_signature_confidence", "clean"))
	signature["capture_quality"] = str(signature.get("enemy_signature_confidence", "clean"))
	signature["target_capture_mode"] = "enemy_causal"
	signature["target_card_play_count"] = int(signature.get("enemy_card_play_count", 0))
	signature["target_card_first_play_turn"] = int(metrics.get("turn_count", 0))
	signature["target_card_first_play_cycle"] = int(metrics.get("combat_cycles", 0))
	signature["stopped_after_target"] = true
	metrics["enemy_card_effect_signature"] = signature.duplicate(true)
	metrics["enemy_card_effect_signature_present"] = bool(signature.get("present", false)) and played
	metrics["enemy_card_effect_signature_missing_reason"] = "" if bool(metrics.get("enemy_card_effect_signature_present", false)) else "enemy card produced no causal signature"
	metrics["support_contamination_status"] = str(signature.get("support_contamination_status", "clean"))
	metrics["signature_confidence"] = str(signature.get("signature_confidence", "clean"))
	metrics["capture_quality"] = str(signature.get("capture_quality", "clean"))
	metrics["ambiguity_reasons"] = []

static func _apply_support_metadata(metrics: Dictionary, signature: Dictionary) -> void:
	var card_id: String = str(metrics.get("card_under_test", ""))
	var sequence: Array = Array(metrics.get("card_play_sequence", []))
	var focused_index: int = int(metrics.get("focused_card_play_index", -1))
	if focused_index < 0 and card_id != "":
		focused_index = _first_index_of(sequence, card_id)
		metrics["focused_card_play_index"] = focused_index
	if focused_index < 0:
		metrics["support_contamination_status"] = "missing"
		metrics["signature_confidence"] = "missing"
		metrics["signature_ambiguous_reason"] = "focused card was not found in card play sequence"
		metrics["capture_quality"] = "failed"
		metrics["ambiguity_reasons"] = ["focused card was not found in card play sequence"]
		signature["support_contamination_status"] = "missing"
		signature["signature_confidence"] = "missing"
		signature["ambiguous_reason"] = str(metrics["signature_ambiguous_reason"])
		_apply_target_capture_fields(metrics, signature)
		return
	var support_before: Array = _support_cards_in_range(sequence, 0, focused_index, card_id)
	var support_after: Array = _support_cards_in_range(sequence, focused_index + 1, sequence.size(), card_id)
	metrics["support_cards_before_target"] = support_before.duplicate()
	metrics["support_cards_after_target"] = support_after.duplicate()
	metrics["support_card_count_before_target"] = support_before.size()
	metrics["support_card_count_after_target"] = support_after.size()
	signature["focused_card_play_index"] = focused_index
	signature["support_cards_before_target"] = support_before.duplicate()
	signature["support_cards_after_target"] = support_after.duplicate()
	signature["support_card_count_before_target"] = support_before.size()
	signature["support_card_count_after_target"] = support_after.size()
	if not support_before.is_empty():
		metrics["support_contamination_status"] = "support_assisted"
		metrics["signature_confidence"] = "support_assisted"
		metrics["signature_ambiguous_reason"] = "support cards were played before the focused card"
		metrics["capture_quality"] = "support_required"
		metrics["ambiguity_reasons"] = ["support_before_target"]
		signature["support_contamination_status"] = "support_assisted"
		signature["signature_confidence"] = "support_assisted"
		signature["ambiguous_reason"] = str(metrics["signature_ambiguous_reason"])
	else:
		metrics["support_contamination_status"] = "clean"
		metrics["signature_confidence"] = "clean"
		metrics["signature_ambiguous_reason"] = ""
		metrics["capture_quality"] = "clean"
		metrics["ambiguity_reasons"] = []
		signature["support_contamination_status"] = "clean"
		signature["signature_confidence"] = "clean"
		signature["ambiguous_reason"] = ""
	if int(metrics.get("card_under_test_play_count", 0)) > 1:
		metrics["signature_confidence"] = "ambiguous"
		metrics["signature_ambiguous_reason"] = "focused card was played more than once"
		metrics["capture_quality"] = "ambiguous"
		metrics["ambiguity_reasons"] = _append_unique(Array(metrics.get("ambiguity_reasons", [])), "target_played_multiple_times")
		signature["signature_confidence"] = "ambiguous"
		signature["ambiguous_reason"] = str(metrics["signature_ambiguous_reason"])
	if bool(metrics.get("stopped_after_target", false)) and int(metrics.get("support_card_count_after_target", 0)) == 0:
		metrics["ambiguity_reasons"] = _remove_value(Array(metrics.get("ambiguity_reasons", [])), "post_target_actions")
	elif int(metrics.get("support_card_count_after_target", 0)) > 0:
		metrics["signature_confidence"] = "ambiguous"
		metrics["capture_quality"] = "ambiguous"
		metrics["signature_ambiguous_reason"] = "cards were played after the focused card"
		metrics["ambiguity_reasons"] = _append_unique(Array(metrics.get("ambiguity_reasons", [])), "post_target_actions")
		signature["signature_confidence"] = "ambiguous"
		signature["ambiguous_reason"] = str(metrics["signature_ambiguous_reason"])
	_apply_target_capture_fields(metrics, signature)

static func _apply_target_capture_fields(metrics: Dictionary, signature: Dictionary) -> void:
	signature["target_capture_mode"] = str(metrics.get("target_capture_mode", ""))
	signature["target_card_play_count"] = int(metrics.get("target_card_play_count", metrics.get("card_under_test_play_count", 0)))
	signature["target_card_first_play_turn"] = int(metrics.get("target_card_first_play_turn", -1))
	signature["target_card_first_play_cycle"] = int(metrics.get("target_card_first_play_cycle", -1))
	signature["stopped_after_target"] = bool(metrics.get("stopped_after_target", false))
	signature["capture_quality"] = str(metrics.get("capture_quality", "none"))
	signature["ambiguity_reasons"] = Array(metrics.get("ambiguity_reasons", [])).duplicate()

static func _card_ids_from_plays(plays: Array) -> Array:
	var ids: Array = []
	for play_value: Variant in plays:
		if typeof(play_value) != TYPE_DICTIONARY:
			continue
		var card_id: String = str(Dictionary(play_value).get("card_id", ""))
		if card_id != "":
			ids.append(card_id)
	return ids

static func _local_focus_index(card_ids: Array, card_id: String, occurrence: int) -> int:
	if card_id == "":
		return -1
	var seen: int = 0
	for index: int in range(card_ids.size()):
		if str(card_ids[index]) != card_id:
			continue
		if seen == occurrence:
			return index
		seen += 1
	return -1

static func _support_cards_in_range(card_ids: Array, start_index: int, end_index: int, focused_card_id: String) -> Array:
	var support: Array = []
	var start: int = maxi(0, start_index)
	var end: int = mini(card_ids.size(), end_index)
	for index: int in range(start, end):
		var card_id: String = str(card_ids[index])
		if card_id == "" or card_id == focused_card_id:
			continue
		support.append(card_id)
	return support

static func _first_index_of(values: Array, target: String) -> int:
	for index: int in range(values.size()):
		if str(values[index]) == target:
			return index
	return -1

static func _target_capture_config(pack: Dictionary, case_data: Dictionary) -> Dictionary:
	var config: Dictionary = Dictionary(case_data.get("target_capture", {})).duplicate(true)
	if config.is_empty():
		config = Dictionary(Dictionary(pack.get("effect_signatures", {})).get("target_capture", {})).duplicate(true)
	if not config.has("mode"):
		config["mode"] = ""
	if not config.has("stop_after_target"):
		config["stop_after_target"] = str(config.get("mode", "")) == "isolated_once"
	if not config.has("max_support_cards_before_target"):
		config["max_support_cards_before_target"] = 999
	return config

static func _should_stop_after_target_capture(metrics: Dictionary, target_capture: Dictionary) -> bool:
	if str(target_capture.get("mode", "")) != "isolated_once":
		return false
	if not bool(target_capture.get("stop_after_target", true)):
		return false
	return bool(metrics.get("target_capture_complete", false))

static func _is_enemy_signature_case(case_data: Dictionary) -> bool:
	return str(case_data.get("effect_signature_scope", "")) == "enemy"

static func _policy_options(case_data: Dictionary, options: Dictionary) -> Dictionary:
	var policy_options: Dictionary = options.duplicate(true)
	var card_under_test: Dictionary = Dictionary(case_data.get("card_under_test", {}))
	if not card_under_test.is_empty():
		policy_options["card_under_test"] = str(card_under_test.get("id", ""))
	policy_options["card_flow_expected"] = bool(case_data.get("card_flow_expected", false))
	if case_data.has("target_capture"):
		policy_options["target_capture"] = Dictionary(case_data.get("target_capture", {})).duplicate(true)
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

static func _append_unique(values: Array, value: String) -> Array:
	var result: Array = values.duplicate()
	if value != "" and not result.has(value):
		result.append(value)
	return result

static func _remove_value(values: Array, value: String) -> Array:
	var result: Array = []
	for item: Variant in values:
		if str(item) != value:
			result.append(item)
	return result
