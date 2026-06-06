extends RefCounted

const BattleReporterScript = preload("res://tools/lab/battle_reporter.gd")
const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")
const CardFlowExpectationEvaluatorScript = preload("res://tools/lab/card_flow_expectation_evaluator.gd")
const CardImpactMatrixScript = preload("res://tools/lab/card_impact_matrix.gd")
const LabAggregatorScript = preload("res://tools/lab/lab_aggregator.gd")
const LabCaseBuilderScript = preload("res://tools/lab/lab_case_builder.gd")
const LabDiffReporterScript = preload("res://tools/lab/lab_diff_reporter.gd")
const LabReporterScript = preload("res://tools/lab/lab_reporter.gd")
const LabRunnerScript = preload("res://tools/lab/lab_runner.gd")
const ScenarioFixtureLoaderScript = preload("res://tools/lab/scenario_fixture_loader.gd")
const ScenarioReporterScript = preload("res://tools/lab/scenario_reporter.gd")
const ScenarioRunnerScript = preload("res://tools/lab/scenario_runner.gd")

const SCHEMA_VERSION: int = 1
const TOOL_ID: String = "card_impact_pack"

static func run_phase(catalog, session, pack: Dictionary, options: Dictionary = {}) -> Dictionary:
	var phase: String = str(options.get("phase", "before"))
	if phase == "compare":
		return compare_phase(pack, options)
	var output_dir: String = str(options.get("out", "user://card_impact/track02_card_impact_v1"))
	var phase_dir: String = "%s/%s" % [output_dir, phase]
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(catalog, pack, PackedStringArray(options.get("cards", PackedStringArray(["all"]))))
	var structural_errors: Array[String] = _string_array(Array(matrix.get("errors", [])))
	var component_results: Array[Dictionary] = []
	var components: PackedStringArray = PackedStringArray(options.get("components", PackedStringArray(["battle", "scenario", "run_lab"])))
	if components.has("battle"):
		component_results.append(_run_battle_component(catalog, pack, matrix, "%s/battle" % phase_dir, options))
	if components.has("scenario"):
		component_results.append(_run_scenario_component(session, catalog, pack, "%s/scenario" % phase_dir, options))
	if components.has("run_lab"):
		component_results.append(_run_lab_component(session, catalog, pack, "%s/run_lab" % phase_dir, options))
	for component: Dictionary in component_results:
		for error: Variant in Array(component.get("structural_errors", [])):
			structural_errors.append(str(error))
	var summary: Dictionary = _phase_summary(pack, matrix, component_results, structural_errors)
	return {
		"ok": bool(summary.get("gate_ok", false)),
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"phase": phase,
		"pack_id": str(pack.get("pack_id", "")),
		"output_dir": output_dir,
		"phase_dir": phase_dir,
		"matrix": matrix,
		"components": component_results,
		"summary": summary
	}

static func compare_phase(pack: Dictionary, options: Dictionary = {}) -> Dictionary:
	var output_dir: String = str(options.get("out", "user://card_impact/track02_card_impact_v1"))
	var compare_dir: String = "%s/compare" % output_dir
	var components: PackedStringArray = PackedStringArray(options.get("components", PackedStringArray(["battle", "scenario", "run_lab"])))
	var component_results: Array[Dictionary] = []
	var structural_errors: Array[String] = []
	for component: String in components:
		var report_type: String = _diff_type_for_component(component)
		if report_type == "":
			structural_errors.append("Unsupported compare component `%s`." % component)
			continue
		var before_dir: String = "%s/before/%s" % [output_dir, component]
		var after_dir: String = "%s/after/%s" % [output_dir, component]
		var diff_options: Dictionary = {
			"type": report_type,
			"numeric_threshold": float(options.get("numeric_threshold", 0.0)),
			"command": str(options.get("command", ""))
		}
		var diff_report: Dictionary = LabDiffReporterScript.compare(before_dir, after_dir, diff_options)
		if not bool(diff_report.get("ok", false)):
			structural_errors.append(str(diff_report.get("message", "Could not compare %s." % component)))
			component_results.append(_component_error(component, str(diff_report.get("message", ""))))
			continue
		var write_result: Dictionary = LabDiffReporterScript.write_outputs("%s/%s" % [compare_dir, component], diff_report, diff_options)
		if not bool(write_result.get("ok", false)):
			structural_errors.append(str(write_result.get("message", "Could not write compare output for %s." % component)))
		component_results.append(_diff_component_result(component, diff_report, write_result, pack, options))
	var summary: Dictionary = _compare_summary(pack, component_results, structural_errors)
	return {
		"ok": bool(summary.get("gate_ok", false)),
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"phase": "compare",
		"pack_id": str(pack.get("pack_id", "")),
		"output_dir": output_dir,
		"compare_dir": compare_dir,
		"components": component_results,
		"summary": summary
	}

static func _run_battle_component(catalog, pack: Dictionary, matrix: Dictionary, output_dir: String, options: Dictionary) -> Dictionary:
	var cases: Array[Dictionary] = Array(matrix.get("cases", []))
	var battle_pack: Dictionary = {
		"pack_id": str(pack.get("pack_id", "")),
		"schema_version": SCHEMA_VERSION,
		"simulation_mode": "battle_engine_v1"
	}
	var run_options: Dictionary = options.duplicate(true)
	run_options["policy"] = ""
	var run_result: Dictionary = BattleRunnerScript.run_cases(catalog, battle_pack, cases, run_options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	var summary: Dictionary = Dictionary(run_result.get("summary", {}))
	var write_result: Dictionary = BattleReporterScript.write_outputs(output_dir, records, summary, run_options)
	var component_result: Dictionary = _component_from_summary("battle", bool(run_result.get("ok", false)) and bool(write_result.get("ok", false)), summary, write_result, records.size())
	component_result["signature_quality"] = _signature_quality_from_records(records)
	component_result["card_flow_expectations"] = CardFlowExpectationEvaluatorScript.evaluate_records(pack, records, {"card_ids": _matrix_player_card_ids(matrix)})
	return component_result

static func _run_scenario_component(session, catalog, pack: Dictionary, output_dir: String, options: Dictionary) -> Dictionary:
	var component: Dictionary = Dictionary(Dictionary(pack.get("components", {})).get("scenario", {}))
	var scenario_pack_id: String = str(component.get("pack", "track02_core_v1"))
	var load_result: Dictionary = ScenarioFixtureLoaderScript.load_pack_result(scenario_pack_id)
	if not bool(load_result.get("ok", false)):
		return _component_error("scenario", str(load_result.get("message", "")))
	var scenario_pack: Dictionary = Dictionary(load_result.get("pack", {}))
	var scenarios: Array[Dictionary] = ScenarioFixtureLoaderScript.scenarios_for(scenario_pack)
	var run_result: Dictionary = ScenarioRunnerScript.run_scenarios(session, catalog, scenario_pack, scenarios, options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	var summary: Dictionary = Dictionary(run_result.get("summary", {}))
	var write_result: Dictionary = ScenarioReporterScript.write_outputs(output_dir, records, summary, options)
	return _component_from_summary("scenario", bool(run_result.get("ok", false)) and bool(write_result.get("ok", false)), summary, write_result, records.size())

static func _run_lab_component(session, catalog, pack: Dictionary, output_dir: String, options: Dictionary) -> Dictionary:
	var component: Dictionary = Dictionary(Dictionary(pack.get("components", {})).get("run_lab", {}))
	var lab_options: Dictionary = {
		"preset": str(component.get("preset", "smoke")),
		"classes": PackedStringArray(Array(component.get("classes", ["arcano", "invocador", "necromante"]))),
		"seeds": _packed_ints(Array(component.get("seeds", [20260518]))),
		"policies": PackedStringArray(Array(component.get("policies", ["baseline"]))),
		"out": output_dir,
		"mode": str(options.get("mode", "explore")),
		"stop_on_failure": bool(options.get("stop_on_failure", false)),
		"timeline": true,
		"scorecard": true,
		"simulation_mode": "macro_route_v1"
	}
	lab_options["case_count"] = PackedStringArray(lab_options.get("classes", PackedStringArray())).size() * PackedInt64Array(lab_options.get("seeds", PackedInt64Array())).size() * PackedStringArray(lab_options.get("policies", PackedStringArray())).size()
	var cases: Array[Dictionary] = LabCaseBuilderScript.build_cases(lab_options)
	var run_result: Dictionary = LabRunnerScript.run_cases(session, catalog, cases, lab_options)
	var records: Array[Dictionary] = Array(run_result.get("records", []))
	var summary: Dictionary = LabAggregatorScript.aggregate(records, lab_options)
	var write_result: Dictionary = LabReporterScript.write_outputs(output_dir, records, summary, {}, {}, lab_options)
	return _component_from_summary("run_lab", bool(run_result.get("ok", false)) and bool(write_result.get("ok", false)), summary, write_result, records.size())

static func _component_from_summary(component: String, ok: bool, summary: Dictionary, write_result: Dictionary, record_count: int) -> Dictionary:
	var fail_count: int = int(summary.get("fail_count", 0))
	var warn_count: int = int(summary.get("warn_count", 0))
	return {
		"component": component,
		"ok": ok and fail_count == 0,
		"status": "FAIL" if (not ok or fail_count > 0) else ("WARN" if warn_count > 0 else "PASS"),
		"pass_count": int(summary.get("pass_count", record_count if fail_count == 0 else 0)),
		"warn_count": warn_count,
		"fail_count": fail_count,
		"record_count": record_count,
		"summary": summary.duplicate(true),
		"write_result": write_result.duplicate(true),
		"structural_errors": [] if bool(write_result.get("ok", true)) else [str(write_result.get("message", "Could not write %s output." % component))]
	}

static func _diff_component_result(component: String, diff_report: Dictionary, write_result: Dictionary, pack: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var summary: Dictionary = Dictionary(diff_report.get("summary", {}))
	var component_result: Dictionary = {
		"component": component,
		"ok": bool(summary.get("gate_ok", true)) and bool(write_result.get("ok", true)),
		"status": "PASS" if bool(summary.get("gate_ok", true)) and bool(write_result.get("ok", true)) else "FAIL",
		"pass_count": 0,
		"warn_count": int(summary.get("new_warning_count", 0)),
		"fail_count": int(summary.get("new_failure_count", 0)),
		"changed_count": int(summary.get("changed_count", 0)),
		"metric_change_count": int(summary.get("metric_change_count", 0)),
		"removed_count": int(summary.get("removed_count", 0)),
		"new_failure_count": int(summary.get("new_failure_count", 0)),
		"summary": summary.duplicate(true),
		"diffs": Array(diff_report.get("diffs", [])).duplicate(true),
		"write_result": write_result.duplicate(true),
		"structural_errors": [] if bool(write_result.get("ok", true)) else [str(write_result.get("message", "Could not write %s diff output." % component))]
	}
	if component == "battle":
		component_result["signature_quality"] = _signature_quality_from_battle_results_path(str(diff_report.get("after_path", "")))
		component_result["card_flow_expectations"] = CardFlowExpectationEvaluatorScript.evaluate_records_from_path(pack, str(diff_report.get("after_path", "")), {"card_ids": _card_flow_expectation_ids_from_options(pack, options)})
	return component_result

static func _component_error(component: String, message: String) -> Dictionary:
	return {
		"component": component,
		"ok": false,
		"status": "FAIL",
		"pass_count": 0,
		"warn_count": 0,
		"fail_count": 1,
		"record_count": 0,
		"structural_errors": [message]
	}

static func _phase_summary(pack: Dictionary, matrix: Dictionary, component_results: Array[Dictionary], structural_errors: Array[String]) -> Dictionary:
	var coverage: Dictionary = Dictionary(Dictionary(matrix.get("summary", {})).duplicate(true))
	coverage["expected_active_cards"] = int(coverage.get("expected_player_cards", 0)) + int(coverage.get("expected_enemy_cards", 0))
	coverage["covered_active_cards"] = int(coverage.get("filtered_player_cards", 0)) + int(coverage.get("filtered_enemy_cards", 0))
	_apply_effect_signature_coverage(coverage, pack)
	var blocking_changes: Array[String] = structural_errors.duplicate()
	var signature_quality: Dictionary = _empty_signature_quality()
	var card_flow_expectations: Dictionary = CardFlowExpectationEvaluatorScript.empty_summary(pack)
	for component: Dictionary in component_results:
		if component.has("signature_quality"):
			_merge_signature_quality(signature_quality, Dictionary(component.get("signature_quality", {})))
		if component.has("card_flow_expectations"):
			CardFlowExpectationEvaluatorScript.merge_summaries(card_flow_expectations, Dictionary(component.get("card_flow_expectations", {})))
		if str(component.get("status", "")) == "FAIL":
			blocking_changes.append("Component `%s` failed." % str(component.get("component", "")))
	blocking_changes.append_array(_target_capture_blockers(pack, signature_quality))
	blocking_changes.append_array(_enemy_signature_blockers(pack, signature_quality))
	blocking_changes.append_array(_card_flow_expectation_blockers(pack, card_flow_expectations))
	return {
		"coverage": coverage,
		"components": component_results,
		"signature_quality": signature_quality,
		"card_flow_expectations": card_flow_expectations,
		"structural_errors": structural_errors,
		"blocking_changes": blocking_changes,
		"new_failure_count": 0,
		"removed_count": 0,
		"status_changes": [],
		"metric_changes": [],
		"top_impacted_cards": [],
		"gate_ok": blocking_changes.is_empty()
	}

static func _compare_summary(pack: Dictionary, component_results: Array[Dictionary], structural_errors: Array[String]) -> Dictionary:
	var status_changes: Array[Dictionary] = []
	var metric_changes: Array[Dictionary] = []
	var effect_changes: Array[Dictionary] = []
	var top_map: Dictionary = {}
	var top_effect_map: Dictionary = {}
	var effect_family_map: Dictionary = {}
	var missing_signatures: Array[Dictionary] = []
	var support_contamination_changes: Array[Dictionary] = []
	var signature_quality: Dictionary = _empty_signature_quality()
	var card_flow_expectations: Dictionary = CardFlowExpectationEvaluatorScript.empty_summary(pack)
	var new_failure_count: int = 0
	var removed_count: int = 0
	var blocking_changes: Array[String] = structural_errors.duplicate()
	for component: Dictionary in component_results:
		if component.has("signature_quality"):
			_merge_signature_quality(signature_quality, Dictionary(component.get("signature_quality", {})))
		if component.has("card_flow_expectations"):
			CardFlowExpectationEvaluatorScript.merge_summaries(card_flow_expectations, Dictionary(component.get("card_flow_expectations", {})))
		new_failure_count += int(component.get("new_failure_count", 0))
		removed_count += int(component.get("removed_count", 0))
		if str(component.get("status", "")) == "FAIL":
			blocking_changes.append("Component `%s` compare gate failed." % str(component.get("component", "")))
		for diff: Dictionary in Array(component.get("diffs", [])):
			var diff_id: String = str(diff.get("id", ""))
			if bool(diff.get("status_changed", false)):
				status_changes.append({
					"component": str(component.get("component", "")),
					"id": diff_id,
					"before_status": str(diff.get("before_status", "")),
					"after_status": str(diff.get("after_status", ""))
				})
			for change: Dictionary in Array(diff.get("metric_changes", [])):
				var row: Dictionary = change.duplicate(true)
				row["component"] = str(component.get("component", ""))
				row["id"] = diff_id
				metric_changes.append(row)
				if str(row.get("field", "")).begins_with("effect."):
					effect_changes.append(row)
					_record_card_impact(top_effect_map, diff)
					_record_effect_family(effect_family_map, row)
					if _is_support_field(str(row.get("field", "")).trim_prefix("effect.")):
						support_contamination_changes.append(row)
					if str(row.get("field", "")) == "effect.present" and bool(row.get("after", true)) == false:
						missing_signatures.append({
							"component": str(component.get("component", "")),
							"id": diff_id,
							"before": row.get("before", null),
							"after": row.get("after", null)
						})
			_record_card_impact(top_map, diff)
	blocking_changes.append_array(_target_capture_blockers(pack, signature_quality))
	blocking_changes.append_array(_enemy_signature_blockers(pack, signature_quality))
	blocking_changes.append_array(_card_flow_expectation_blockers(pack, card_flow_expectations))
	return {
		"coverage": _compare_coverage(pack, component_results),
		"components": component_results,
		"signature_quality": signature_quality,
		"card_flow_expectations": card_flow_expectations,
		"structural_errors": structural_errors,
		"blocking_changes": blocking_changes,
		"new_failure_count": new_failure_count,
		"removed_count": removed_count,
		"status_changes": status_changes,
		"metric_changes": metric_changes,
		"effect_changes": effect_changes,
		"effect_change_count": effect_changes.size(),
		"top_effect_delta_cards": _top_impacted_cards(top_effect_map),
		"by_effect_family": effect_family_map,
		"support_contamination_changes": support_contamination_changes,
		"missing_signatures": missing_signatures,
		"top_impacted_cards": _top_impacted_cards(top_map),
		"gate_ok": blocking_changes.is_empty() and new_failure_count == 0 and removed_count == 0
	}

static func _compare_coverage(pack: Dictionary, component_results: Array[Dictionary]) -> Dictionary:
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	var expected_player: int = int(card_sets.get("expected_player_cards", 0))
	var expected_enemy: int = int(card_sets.get("expected_enemy_cards", 0))
	var expected_legacy: int = int(card_sets.get("expected_legacy_inactive_cards", 0))
	var expected_card_flow: int = int(card_sets.get("expected_card_flow_player_cards", 0))
	var covered_active: int = 0
	for component: Dictionary in component_results:
		if str(component.get("component", "")) != "battle":
			continue
		var summary: Dictionary = Dictionary(component.get("summary", {}))
		covered_active = int(summary.get("total_after", summary.get("total_before", 0)))
	var coverage: Dictionary = {
		"expected_player_cards": expected_player,
		"expected_enemy_cards": expected_enemy,
		"expected_legacy_inactive_cards": expected_legacy,
		"expected_card_flow_player_cards": expected_card_flow,
		"expected_active_cards": expected_player + expected_enemy,
		"covered_active_cards": covered_active,
		"player_cards_total": expected_player,
		"enemy_cards_total": expected_enemy,
		"legacy_inactive_cards_total": expected_legacy,
		"card_flow_player_cards_total": expected_card_flow,
		"filtered_player_cards": expected_player if covered_active >= expected_player else 0,
		"filtered_enemy_cards": expected_enemy if covered_active >= expected_player + expected_enemy else 0,
		"filtered_card_flow_player_cards": expected_card_flow if covered_active >= expected_player else 0
	}
	if card_sets.has("expected_player_cards_by_class"):
		coverage["filtered_player_cards_by_class"] = Dictionary(card_sets.get("expected_player_cards_by_class", {})).duplicate(true)
		coverage["player_cards_total_by_class"] = Dictionary(card_sets.get("expected_player_cards_by_class", {})).duplicate(true)
	if card_sets.has("expected_player_cards_by_source"):
		coverage["filtered_player_cards_by_source"] = Dictionary(card_sets.get("expected_player_cards_by_source", {})).duplicate(true)
		coverage["player_cards_total_by_source"] = Dictionary(card_sets.get("expected_player_cards_by_source", {})).duplicate(true)
	_apply_effect_signature_coverage(coverage, pack)
	return coverage

static func _apply_effect_signature_coverage(coverage: Dictionary, pack: Dictionary) -> void:
	var config: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	var enabled: bool = bool(config.get("enabled", false))
	var player_config: Dictionary = Dictionary(config.get("player", {}))
	var enemy_config: Dictionary = Dictionary(config.get("enemy", {}))
	coverage["effect_signatures_enabled"] = enabled
	coverage["player_effect_signature_mode"] = str(player_config.get("mode", "off")) if enabled else "off"
	coverage["enemy_effect_signature_mode"] = str(enemy_config.get("mode", "off")) if enabled else "off"
	coverage["expected_player_effect_signatures"] = int(coverage.get("filtered_player_cards", 0)) if str(coverage.get("player_effect_signature_mode", "")) == "required" else 0
	coverage["expected_enemy_effect_signatures"] = int(coverage.get("filtered_enemy_cards", 0)) if str(coverage.get("enemy_effect_signature_mode", "")) == "required" else 0

static func _enemy_signature_blockers(pack: Dictionary, signature_quality: Dictionary) -> Array[String]:
	var gate_policy: Dictionary = Dictionary(pack.get("gate_policy", {}))
	var blockers: Array[String] = []
	if bool(gate_policy.get("fail_on_missing_enemy_card_played", false)):
		var not_played_count: int = int(signature_quality.get("enemy_card_not_played_count", 0))
		if not_played_count > 0:
			blockers.append("%d enemy signature cases did not play the card under test." % not_played_count)
	if bool(gate_policy.get("fail_on_missing_enemy_effect_signature", false)):
		var missing_count: int = int(signature_quality.get("enemy_signature_missing_count", 0))
		if missing_count > 0:
			blockers.append("%d enemy signature cases are missing causal signatures." % missing_count)
	return blockers

static func _target_capture_blockers(pack: Dictionary, signature_quality: Dictionary) -> Array[String]:
	var gate_policy: Dictionary = Dictionary(pack.get("gate_policy", {}))
	var blockers: Array[String] = []
	if bool(gate_policy.get("fail_on_repeated_target_capture", false)):
		var repeated_count: int = int(signature_quality.get("repeated_target_count", 0))
		if repeated_count > 0:
			blockers.append("%d target-card captures played the focused card more than once." % repeated_count)
		var failed_count: int = int(signature_quality.get("capture_failed_count", 0))
		if failed_count > 0:
			blockers.append("%d target-card captures failed." % failed_count)
	if bool(gate_policy.get("fail_on_missing_card_flow_signature", false)):
		var card_flow_signature_missing_count: int = int(signature_quality.get("card_flow_signature_missing_count", 0))
		if card_flow_signature_missing_count > 0:
			blockers.append("%d card-flow captures are missing effect signatures." % card_flow_signature_missing_count)
	if bool(gate_policy.get("fail_on_missing_card_flow_observed", false)):
		var card_flow_missing_count: int = int(signature_quality.get("card_flow_missing_count", 0))
		if card_flow_missing_count > 0:
			blockers.append("%d expected card-flow captures did not observe card-flow counters." % card_flow_missing_count)
	return blockers

static func _card_flow_expectation_blockers(pack: Dictionary, expectation_summary: Dictionary) -> Array[String]:
	var gate_policy: Dictionary = Dictionary(pack.get("gate_policy", {}))
	if not bool(gate_policy.get("fail_on_card_flow_expectation_fail", false)):
		return []
	if not bool(expectation_summary.get("enabled", false)):
		return []
	var required_fail_count: int = int(expectation_summary.get("required_fail_count", 0))
	if required_fail_count <= 0:
		return []
	return ["%d required card-flow expectations failed." % required_fail_count]

static func _record_card_impact(top_map: Dictionary, diff: Dictionary) -> void:
	var card_id: String = _card_id_from_diff_id(str(diff.get("id", "")))
	if card_id == "":
		return
	if not top_map.has(card_id):
		top_map[card_id] = {"card_id": card_id, "change_count": 0, "metric_change_count": 0, "status_change_count": 0}
	var entry: Dictionary = Dictionary(top_map.get(card_id, {}))
	entry["change_count"] = int(entry.get("change_count", 0)) + 1
	entry["metric_change_count"] = int(entry.get("metric_change_count", 0)) + Array(diff.get("metric_changes", [])).size()
	if bool(diff.get("status_changed", false)):
		entry["status_change_count"] = int(entry.get("status_change_count", 0)) + 1
	top_map[card_id] = entry

static func _record_effect_family(effect_family_map: Dictionary, change: Dictionary) -> void:
	var field: String = str(change.get("field", "")).trim_prefix("effect.")
	var family: String = _effect_family_for_field(field)
	if not effect_family_map.has(family):
		effect_family_map[family] = {"change_count": 0, "fields": {}}
	var entry: Dictionary = Dictionary(effect_family_map.get(family, {}))
	entry["change_count"] = int(entry.get("change_count", 0)) + 1
	var fields: Dictionary = Dictionary(entry.get("fields", {}))
	fields[field] = int(fields.get(field, 0)) + 1
	entry["fields"] = fields
	effect_family_map[family] = entry

static func _effect_family_for_field(field: String) -> String:
	if field in ["enemy_hero_damage", "player_hero_damage", "enemy_slot_damage_total", "player_slot_damage_total"]:
		return "damage"
	if field in ["summons_created", "summoned_count", "summoned_slot_count", "summoned_keyword_count", "player_units_delta", "enemy_units_delta", "summoned_attack_total", "summoned_health_total"]:
		return "summon"
	if field in ["ally_attack_buff_total", "ally_health_buff_total", "shield_added_total", "ally_keyword_gain_count", "ally_shield_gain", "ally_resistance_gain"]:
		return "buff"
	if field in ["enemy_attack_debuff_total", "enemy_health_debuff_total", "enemy_keyword_loss_count"]:
		return "debuff"
	if field in ["poison_added_total", "enemy_poison_added", "freeze_added_total", "enemy_frozen_added", "enemy_snared_added", "enemy_slow_added"]:
		return "control"
	if field in ["cards_drawn", "cards_discarded", "cards_created", "deck_delta", "hand_delta", "discard_delta", "card_flow_observed", "card_flow_expected", "card_flow_missing_reason"]:
		return "card_flow"
	if field in ["mana_gained", "ashes_gained"]:
		return "economy"
	if field in ["temporary_ability_power_delta", "temporary_ability_power_gained", "temporary_ability_power_lost"]:
		return "utility"
	if field in ["keywords_added", "keywords_removed", "families"]:
		return "keyword"
	if field in ["enemy_summons_created", "enemy_summoned_count"]:
		return "enemy_summon"
	if field in ["enemy_summoned_attack_total", "enemy_summoned_health_total"]:
		return "enemy_stat"
	if field in ["enemy_summoned_keyword_count", "enemy_keywords_added"]:
		return "enemy_keyword"
	if field in ["enemy_damage_to_player_hero", "enemy_damage_to_player_slots", "enemy_player_units_delta", "enemy_combat_damage_to_player_hero", "enemy_combat_damage_to_player_slots"]:
		return "enemy_combat_damage"
	if field in ["enemy_card_played", "enemy_card_play_count", "enemy_signature_phase", "enemy_signature_confidence"]:
		return "enemy_signature"
	if field in ["pending_choices_delta", "pending_choice_created", "pending_choice_resolved", "sacrifice_required", "sacrifice_consumed", "sacrifice_units_destroyed"]:
		return "choice"
	if field in ["present", "sample_count"]:
		return "coverage"
	if _is_support_field(field):
		return "support"
	return "other"

static func _is_support_field(field: String) -> bool:
	return field in [
		"focused_card_play_index",
		"support_cards_before_target",
		"support_cards_after_target",
		"support_card_count_before_target",
		"support_card_count_after_target",
		"support_contamination_status",
		"signature_confidence",
		"ambiguous_reason",
		"target_card_play_count",
		"target_card_first_play_turn",
		"target_card_first_play_cycle",
		"stopped_after_target",
		"target_capture_mode",
		"capture_quality",
		"ambiguity_reasons"
	]

static func _signature_quality_from_records(records: Array) -> Dictionary:
	var quality: Dictionary = _empty_signature_quality()
	for record_value: Variant in records:
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record: Dictionary = Dictionary(record_value)
		var case_data: Dictionary = Dictionary(record.get("case", {}))
		var result: Dictionary = Dictionary(record.get("result", {}))
		var signature: Dictionary = Dictionary(result.get("card_effect_signature", {}))
		var card_id: String = str(result.get("card_under_test", signature.get("card_id", "")))
		var case_id: String = str(record.get("id", case_data.get("id", "")))
		var families: Array = Array(signature.get("families", result.get("effect_families", [])))
		if families.is_empty():
			families = ["missing" if not bool(signature.get("present", false)) else "played"]
		var card_under_test: Dictionary = Dictionary(case_data.get("card_under_test", {}))
		var card_kind: String = str(result.get("card_under_test_kind", card_under_test.get("kind", "")))
		var effect_scope: String = str(case_data.get("effect_signature_scope", result.get("effect_signature_scope", "")))
		var enemy_signature_expected: bool = card_kind == "enemy" and effect_scope == "enemy"
		var card_flow_expected: bool = bool(signature.get("card_flow_expected", result.get("card_flow_expected", false)))
		var card_flow_observed: bool = bool(signature.get("card_flow_observed", false))
		if card_flow_expected and not families.has("card_flow"):
			families.append("card_flow")
		var status: String = str(signature.get("support_contamination_status", result.get("support_contamination_status", "none")))
		var confidence: String = str(signature.get("signature_confidence", result.get("signature_confidence", "none")))
		var capture_quality: String = str(signature.get("capture_quality", result.get("capture_quality", "none")))
		var target_play_count: int = int(signature.get("target_card_play_count", result.get("target_card_play_count", result.get("card_under_test_play_count", 0))))
		var target_capture_mode: String = str(signature.get("target_capture_mode", result.get("target_capture_mode", "")))
		if not bool(signature.get("present", false)):
			status = "missing"
			confidence = "missing"
			capture_quality = "failed" if target_capture_mode == "isolated_once" else "none"
		_increment_enemy_signature_quality(quality, case_id, card_id, enemy_signature_expected, result, signature)
		_increment_card_flow_quality(quality, case_id, card_id, card_flow_expected, card_flow_observed, bool(signature.get("present", false)), str(signature.get("card_flow_missing_reason", "")))
		_increment_signature_quality_total(quality, status, confidence, capture_quality, target_play_count)
		for family_value: Variant in families:
			_increment_signature_family_quality(quality, str(family_value), status, confidence, capture_quality, target_play_count)
		if status in ["support_assisted", "missing"] or confidence == "ambiguous" or capture_quality in ["support_required", "ambiguous", "failed"] or (card_flow_expected and not card_flow_observed):
			var cases: Array = Array(quality.get("cases", []))
			cases.append({
				"case_id": case_id,
				"card_id": card_id,
				"families": families.duplicate(),
				"support_contamination_status": status,
				"signature_confidence": confidence,
				"capture_quality": capture_quality,
				"target_card_play_count": target_play_count,
				"card_flow_expected": card_flow_expected,
				"card_flow_observed": card_flow_observed,
				"card_flow_missing_reason": str(signature.get("card_flow_missing_reason", "")),
				"reason": str(signature.get("ambiguous_reason", result.get("signature_ambiguous_reason", signature.get("missing_reason", "")))),
				"ambiguity_reasons": Array(signature.get("ambiguity_reasons", result.get("ambiguity_reasons", []))).duplicate(),
				"support_cards_before_target": Array(signature.get("support_cards_before_target", result.get("support_cards_before_target", []))).duplicate(),
				"support_cards_after_target": Array(signature.get("support_cards_after_target", result.get("support_cards_after_target", []))).duplicate()
			})
			quality["cases"] = cases
	return quality

static func _signature_quality_from_battle_results_path(path: String) -> Dictionary:
	if path == "" or not FileAccess.file_exists(path):
		return _empty_signature_quality()
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _empty_signature_quality()
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return _empty_signature_quality()
	return _signature_quality_from_records(Array(Dictionary(parsed).get("records", [])))

static func _empty_signature_quality() -> Dictionary:
	return {
		"total": 0,
		"clean_count": 0,
		"support_assisted_count": 0,
		"ambiguous_count": 0,
		"missing_count": 0,
		"none_count": 0,
		"capture_clean_count": 0,
		"capture_support_required_count": 0,
		"capture_ambiguous_count": 0,
		"capture_failed_count": 0,
		"repeated_target_count": 0,
		"card_flow_expected_count": 0,
		"card_flow_observed_count": 0,
		"card_flow_missing_count": 0,
		"card_flow_signature_missing_count": 0,
		"card_flow_cases": [],
		"enemy_signature_expected_count": 0,
		"enemy_signature_present_count": 0,
		"enemy_signature_missing_count": 0,
		"enemy_card_played_count": 0,
		"enemy_card_not_played_count": 0,
		"enemy_signature_clean_count": 0,
		"enemy_signature_ambiguous_count": 0,
		"enemy_signature_confidence_missing_count": 0,
		"enemy_signature_cases": [],
		"by_family": {},
		"cases": []
	}

static func _merge_signature_quality(target: Dictionary, source: Dictionary) -> void:
	for field: String in ["total", "clean_count", "support_assisted_count", "ambiguous_count", "missing_count", "none_count", "capture_clean_count", "capture_support_required_count", "capture_ambiguous_count", "capture_failed_count", "repeated_target_count", "card_flow_expected_count", "card_flow_observed_count", "card_flow_missing_count", "card_flow_signature_missing_count", "enemy_signature_expected_count", "enemy_signature_present_count", "enemy_signature_missing_count", "enemy_card_played_count", "enemy_card_not_played_count", "enemy_signature_clean_count", "enemy_signature_ambiguous_count", "enemy_signature_confidence_missing_count"]:
		target[field] = int(target.get(field, 0)) + int(source.get(field, 0))
	var target_by_family: Dictionary = Dictionary(target.get("by_family", {}))
	for family_key: Variant in Dictionary(source.get("by_family", {})).keys():
		var family: String = str(family_key)
		if not target_by_family.has(family):
			target_by_family[family] = _empty_signature_quality_family()
		var target_entry: Dictionary = Dictionary(target_by_family.get(family, {}))
		var source_entry: Dictionary = Dictionary(Dictionary(source.get("by_family", {})).get(family_key, {}))
		for field: String in ["total", "clean_count", "support_assisted_count", "ambiguous_count", "missing_count", "none_count", "capture_clean_count", "capture_support_required_count", "capture_ambiguous_count", "capture_failed_count", "repeated_target_count"]:
			target_entry[field] = int(target_entry.get(field, 0)) + int(source_entry.get(field, 0))
		target_by_family[family] = target_entry
	target["by_family"] = target_by_family
	var cases: Array = Array(target.get("cases", []))
	for case_value: Variant in Array(source.get("cases", [])):
		if typeof(case_value) == TYPE_DICTIONARY:
			cases.append(Dictionary(case_value).duplicate(true))
	target["cases"] = cases
	var card_flow_cases: Array = Array(target.get("card_flow_cases", []))
	for case_value: Variant in Array(source.get("card_flow_cases", [])):
		if typeof(case_value) == TYPE_DICTIONARY:
			card_flow_cases.append(Dictionary(case_value).duplicate(true))
	target["card_flow_cases"] = card_flow_cases
	var enemy_signature_cases: Array = Array(target.get("enemy_signature_cases", []))
	for case_value: Variant in Array(source.get("enemy_signature_cases", [])):
		if typeof(case_value) == TYPE_DICTIONARY:
			enemy_signature_cases.append(Dictionary(case_value).duplicate(true))
	target["enemy_signature_cases"] = enemy_signature_cases

static func _increment_enemy_signature_quality(quality: Dictionary, case_id: String, card_id: String, expected: bool, result: Dictionary, signature: Dictionary) -> void:
	if not expected:
		return
	quality["enemy_signature_expected_count"] = int(quality.get("enemy_signature_expected_count", 0)) + 1
	var played: bool = bool(result.get("enemy_card_under_test_played", false)) or bool(signature.get("enemy_card_played", false))
	var present: bool = bool(result.get("enemy_card_effect_signature_present", false)) or bool(signature.get("present", false))
	var confidence: String = str(signature.get("enemy_signature_confidence", result.get("signature_confidence", "missing")))
	if played:
		quality["enemy_card_played_count"] = int(quality.get("enemy_card_played_count", 0)) + 1
	else:
		quality["enemy_card_not_played_count"] = int(quality.get("enemy_card_not_played_count", 0)) + 1
	if present and played:
		quality["enemy_signature_present_count"] = int(quality.get("enemy_signature_present_count", 0)) + 1
	else:
		quality["enemy_signature_missing_count"] = int(quality.get("enemy_signature_missing_count", 0)) + 1
	match confidence:
		"clean":
			quality["enemy_signature_clean_count"] = int(quality.get("enemy_signature_clean_count", 0)) + 1
		"ambiguous":
			quality["enemy_signature_ambiguous_count"] = int(quality.get("enemy_signature_ambiguous_count", 0)) + 1
		_:
			quality["enemy_signature_confidence_missing_count"] = int(quality.get("enemy_signature_confidence_missing_count", 0)) + 1
	if played and present and confidence == "clean":
		return
	var cases: Array = Array(quality.get("enemy_signature_cases", []))
	cases.append({
		"case_id": case_id,
		"card_id": card_id,
		"played": played,
		"signature_present": present and played,
		"confidence": confidence,
		"phase": str(signature.get("enemy_signature_phase", "")),
		"missing_reason": str(result.get("enemy_card_effect_signature_missing_reason", signature.get("missing_reason", "")))
	})
	quality["enemy_signature_cases"] = cases

static func _increment_card_flow_quality(quality: Dictionary, case_id: String, card_id: String, expected: bool, observed: bool, signature_present: bool, missing_reason: String) -> void:
	if not expected:
		return
	quality["card_flow_expected_count"] = int(quality.get("card_flow_expected_count", 0)) + 1
	if observed:
		quality["card_flow_observed_count"] = int(quality.get("card_flow_observed_count", 0)) + 1
		return
	quality["card_flow_missing_count"] = int(quality.get("card_flow_missing_count", 0)) + 1
	if not signature_present:
		quality["card_flow_signature_missing_count"] = int(quality.get("card_flow_signature_missing_count", 0)) + 1
	var cases: Array = Array(quality.get("card_flow_cases", []))
	cases.append({
		"case_id": case_id,
		"card_id": card_id,
		"signature_present": signature_present,
		"card_flow_observed": observed,
		"missing_reason": missing_reason
	})
	quality["card_flow_cases"] = cases

static func _increment_signature_quality_total(quality: Dictionary, status: String, confidence: String, capture_quality: String = "none", target_play_count: int = 0) -> void:
	quality["total"] = int(quality.get("total", 0)) + 1
	_increment_quality_bucket(quality, status, confidence, capture_quality, target_play_count)

static func _increment_signature_family_quality(quality: Dictionary, family: String, status: String, confidence: String, capture_quality: String = "none", target_play_count: int = 0) -> void:
	var by_family: Dictionary = Dictionary(quality.get("by_family", {}))
	if not by_family.has(family):
		by_family[family] = _empty_signature_quality_family()
	var entry: Dictionary = Dictionary(by_family.get(family, {}))
	entry["total"] = int(entry.get("total", 0)) + 1
	_increment_quality_bucket(entry, status, confidence, capture_quality, target_play_count)
	by_family[family] = entry
	quality["by_family"] = by_family

static func _increment_quality_bucket(target: Dictionary, status: String, confidence: String, capture_quality: String = "none", target_play_count: int = 0) -> void:
	match status:
		"clean":
			target["clean_count"] = int(target.get("clean_count", 0)) + 1
		"support_assisted":
			target["support_assisted_count"] = int(target.get("support_assisted_count", 0)) + 1
		"missing":
			target["missing_count"] = int(target.get("missing_count", 0)) + 1
		_:
			target["none_count"] = int(target.get("none_count", 0)) + 1
	if confidence == "ambiguous":
		target["ambiguous_count"] = int(target.get("ambiguous_count", 0)) + 1
	match capture_quality:
		"clean":
			target["capture_clean_count"] = int(target.get("capture_clean_count", 0)) + 1
		"support_required":
			target["capture_support_required_count"] = int(target.get("capture_support_required_count", 0)) + 1
		"ambiguous":
			target["capture_ambiguous_count"] = int(target.get("capture_ambiguous_count", 0)) + 1
		"failed":
			target["capture_failed_count"] = int(target.get("capture_failed_count", 0)) + 1
	if target_play_count > 1:
		target["repeated_target_count"] = int(target.get("repeated_target_count", 0)) + 1

static func _empty_signature_quality_family() -> Dictionary:
	return {
		"total": 0,
		"clean_count": 0,
		"support_assisted_count": 0,
		"ambiguous_count": 0,
		"missing_count": 0,
		"none_count": 0,
		"capture_clean_count": 0,
		"capture_support_required_count": 0,
		"capture_ambiguous_count": 0,
		"capture_failed_count": 0,
		"repeated_target_count": 0
	}

static func _top_impacted_cards(top_map: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key: Variant in top_map.keys():
		result.append(Dictionary(top_map.get(key, {})))
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.get("change_count", 0)) == int(b.get("change_count", 0)):
			return str(a.get("card_id", "")) < str(b.get("card_id", ""))
		return int(a.get("change_count", 0)) > int(b.get("change_count", 0))
	)
	return result

static func _card_id_from_diff_id(diff_id: String) -> String:
	if diff_id.begins_with("card_impact_player_"):
		return diff_id.trim_prefix("card_impact_player_")
	if diff_id.begins_with("card_impact_enemy_"):
		return diff_id.trim_prefix("card_impact_enemy_")
	return ""

static func _matrix_player_card_ids(matrix: Dictionary) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for card_value: Variant in Array(matrix.get("player_cards", [])):
		if typeof(card_value) != TYPE_DICTIONARY:
			continue
		var card_id: String = str(Dictionary(card_value).get("id", ""))
		if card_id != "":
			ids.append(card_id)
	return ids

static func _card_flow_expectation_ids_from_options(pack: Dictionary, options: Dictionary) -> PackedStringArray:
	var requested: PackedStringArray = PackedStringArray(options.get("cards", PackedStringArray(["all"])))
	if requested.is_empty() or (requested.size() == 1 and str(requested[0]) in ["all", "player"]):
		return _card_flow_expectation_ids(pack)
	if requested.size() == 1 and str(requested[0]) == "enemy":
		return PackedStringArray()
	var valid_ids: Dictionary = {}
	for card_id: String in _card_flow_expectation_ids(pack):
		valid_ids[card_id] = true
	var result: PackedStringArray = PackedStringArray()
	for card_id: String in requested:
		if valid_ids.has(card_id):
			result.append(card_id)
	return result

static func _card_flow_expectation_ids(pack: Dictionary) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var config: Dictionary = Dictionary(pack.get("card_flow_expectations", {}))
	for check_value: Variant in Array(config.get("checks", [])):
		if typeof(check_value) != TYPE_DICTIONARY:
			continue
		var card_id: String = str(Dictionary(check_value).get("card_id", ""))
		if card_id != "" and not result.has(card_id):
			result.append(card_id)
	return result

static func _diff_type_for_component(component: String) -> String:
	match component:
		"battle":
			return "battle"
		"scenario":
			return "scenario"
		"run_lab":
			return "run_lab"
	return ""

static func _packed_ints(values: Array) -> PackedInt64Array:
	var result: PackedInt64Array = PackedInt64Array()
	for value: Variant in values:
		result.append(int(value))
	return result

static func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str(value))
	return result
