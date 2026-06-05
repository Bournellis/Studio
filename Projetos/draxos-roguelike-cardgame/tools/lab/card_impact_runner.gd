extends RefCounted

const BattleReporterScript = preload("res://tools/lab/battle_reporter.gd")
const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")
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
		component_results.append(_diff_component_result(component, diff_report, write_result))
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
	return _component_from_summary("battle", bool(run_result.get("ok", false)) and bool(write_result.get("ok", false)), summary, write_result, records.size())

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

static func _diff_component_result(component: String, diff_report: Dictionary, write_result: Dictionary) -> Dictionary:
	var summary: Dictionary = Dictionary(diff_report.get("summary", {}))
	return {
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
	for component: Dictionary in component_results:
		if str(component.get("status", "")) == "FAIL":
			blocking_changes.append("Component `%s` failed." % str(component.get("component", "")))
	return {
		"coverage": coverage,
		"components": component_results,
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
	var new_failure_count: int = 0
	var removed_count: int = 0
	var blocking_changes: Array[String] = structural_errors.duplicate()
	for component: Dictionary in component_results:
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
					if str(row.get("field", "")) == "effect.present" and bool(row.get("after", true)) == false:
						missing_signatures.append({
							"component": str(component.get("component", "")),
							"id": diff_id,
							"before": row.get("before", null),
							"after": row.get("after", null)
						})
			_record_card_impact(top_map, diff)
	return {
		"coverage": _compare_coverage(pack, component_results),
		"components": component_results,
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
		"missing_signatures": missing_signatures,
		"top_impacted_cards": _top_impacted_cards(top_map),
		"gate_ok": blocking_changes.is_empty() and new_failure_count == 0 and removed_count == 0
	}

static func _compare_coverage(pack: Dictionary, component_results: Array[Dictionary]) -> Dictionary:
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	var expected_player: int = int(card_sets.get("expected_player_cards", 0))
	var expected_enemy: int = int(card_sets.get("expected_enemy_cards", 0))
	var expected_legacy: int = int(card_sets.get("expected_legacy_inactive_cards", 0))
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
		"expected_active_cards": expected_player + expected_enemy,
		"covered_active_cards": covered_active,
		"player_cards_total": expected_player,
		"enemy_cards_total": expected_enemy,
		"legacy_inactive_cards_total": expected_legacy,
		"filtered_player_cards": expected_player if covered_active >= expected_player else 0,
		"filtered_enemy_cards": expected_enemy if covered_active >= expected_player + expected_enemy else 0
	}
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
	if field in ["summons_created", "player_units_delta", "enemy_units_delta", "summoned_attack_total", "summoned_health_total"]:
		return "summon"
	if field in ["ally_attack_buff_total", "ally_health_buff_total", "shield_added_total"]:
		return "buff"
	if field in ["enemy_attack_debuff_total", "enemy_health_debuff_total"]:
		return "debuff"
	if field in ["poison_added_total", "freeze_added_total"]:
		return "control"
	if field in ["mana_gained", "ashes_gained", "cards_drawn", "cards_discarded"]:
		return "economy"
	if field in ["keywords_added", "keywords_removed", "families"]:
		return "keyword"
	if field in ["pending_choices_delta"]:
		return "choice"
	if field in ["present", "sample_count"]:
		return "coverage"
	return "other"

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
