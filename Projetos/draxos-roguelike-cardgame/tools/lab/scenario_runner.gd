extends RefCounted

const LabCaseBuilderScript = preload("res://tools/lab/lab_case_builder.gd")
const RoutePacingSimulatorScript = preload("res://tools/route_pacing_simulator.gd")
const ScenarioEvaluatorScript = preload("res://tools/lab/scenario_evaluator.gd")
const SCHEMA_VERSION: int = 1
const TOOL_ID: String = "scenario_fixtures"

static func run_scenarios(session, catalog, pack: Dictionary, scenarios: Array[Dictionary], options: Dictionary = {}) -> Dictionary:
	var simulator = RoutePacingSimulatorScript.new()
	var records: Array[Dictionary] = []
	var stopped_early: bool = false
	for scenario: Dictionary in scenarios:
		var policy: Dictionary = LabCaseBuilderScript.policy_contract(str(scenario.get("policy_id", "baseline")))
		var metrics: Dictionary = simulator.simulate_route(session, catalog, str(scenario.get("class_id", "")), int(scenario.get("seed", 0)), {
			"policy_id": str(scenario.get("policy_id", "baseline")),
			"route_policy": str(policy.get("route_policy", "linear_track02")),
			"reward_policy": str(policy.get("reward_policy", "baseline")),
			"shop_policy": str(policy.get("shop_policy", "baseline_recovery")),
			"simulation_mode": str(pack.get("simulation_mode", "macro_route_v1")),
			"timeline": true
		})
		metrics["scenario_id"] = str(scenario.get("id", ""))
		metrics["policy_id"] = str(scenario.get("policy_id", "baseline"))
		metrics["route_policy"] = str(policy.get("route_policy", "linear_track02"))
		metrics["reward_policy"] = str(policy.get("reward_policy", "baseline"))
		metrics["shop_policy"] = str(policy.get("shop_policy", "baseline_recovery"))
		metrics["simulation_mode"] = str(pack.get("simulation_mode", "macro_route_v1"))
		var evaluation: Dictionary = ScenarioEvaluatorScript.evaluate(scenario, metrics)
		var status: String = str(evaluation.get("status", ScenarioEvaluatorScript.STATUS_FAIL))
		var timeline: Array = Array(metrics.get("timeline", []))
		var tags: Array[String] = _string_array(Array(scenario.get("tags", [])))
		records.append({
			"schema_version": SCHEMA_VERSION,
			"tool": TOOL_ID,
			"scenario": scenario.duplicate(true),
			"result": metrics.duplicate(true),
			"timeline": timeline.duplicate(true),
			"expectations": Array(evaluation.get("expectations", [])).duplicate(true),
			"warnings": Array(evaluation.get("warnings", [])).duplicate(true),
			"failures": Array(evaluation.get("failures", [])).duplicate(true),
			"tags": tags,
			"status": status
		})
		if bool(options.get("stop_on_failure", false)) and status == ScenarioEvaluatorScript.STATUS_FAIL:
			stopped_early = true
			break
	var summary: Dictionary = summarize(records, pack, options)
	return {
		"ok": int(summary.get("fail_count", 0)) == 0,
		"records": records,
		"summary": summary,
		"stopped_early": stopped_early
	}

static func summarize(records: Array[Dictionary], pack: Dictionary = {}, options: Dictionary = {}) -> Dictionary:
	var summary: Dictionary = {
		"schema_version": SCHEMA_VERSION,
		"tool": TOOL_ID,
		"pack_id": str(pack.get("pack_id", "")),
		"simulation_mode": str(pack.get("simulation_mode", "macro_route_v1")),
		"mode": str(options.get("mode", "explore")),
		"total_scenarios": records.size(),
		"pass_count": 0,
		"warn_count": 0,
		"fail_count": 0,
		"by_tag": {},
		"by_class": {},
		"by_policy": {},
		"failures": [],
		"warnings": [],
		"checkpoint_highlights": []
	}
	for record: Dictionary in records:
		var status: String = str(record.get("status", ScenarioEvaluatorScript.STATUS_FAIL))
		match status:
			ScenarioEvaluatorScript.STATUS_PASS:
				summary["pass_count"] = int(summary.get("pass_count", 0)) + 1
			ScenarioEvaluatorScript.STATUS_WARN:
				summary["warn_count"] = int(summary.get("warn_count", 0)) + 1
			_:
				summary["fail_count"] = int(summary.get("fail_count", 0)) + 1
		var scenario: Dictionary = Dictionary(record.get("scenario", {}))
		_increment_group(summary, "by_class", str(scenario.get("class_id", "")), status)
		_increment_group(summary, "by_policy", str(scenario.get("policy_id", "")), status)
		for tag: String in _string_array(Array(record.get("tags", []))):
			_increment_group(summary, "by_tag", tag, status)
		for failure: Variant in Array(record.get("failures", [])):
			var failures: Array = Array(summary.get("failures", []))
			failures.append({"scenario_id": str(scenario.get("id", "")), "message": str(failure)})
			summary["failures"] = failures
		for warning: Variant in Array(record.get("warnings", [])):
			var warnings: Array = Array(summary.get("warnings", []))
			warnings.append({"scenario_id": str(scenario.get("id", "")), "message": str(warning)})
			summary["warnings"] = warnings
		_append_checkpoint_highlights(summary, record)
	return summary

static func _append_checkpoint_highlights(summary: Dictionary, record: Dictionary) -> void:
	var scenario: Dictionary = Dictionary(record.get("scenario", {}))
	for expectation: Dictionary in Array(record.get("expectations", [])):
		var field: String = str(expectation.get("field", ""))
		if not field.begins_with("map_"):
			continue
		var checkpoint_highlights: Array = Array(summary.get("checkpoint_highlights", []))
		checkpoint_highlights.append({
			"scenario_id": str(scenario.get("id", "")),
			"field": field,
			"status": str(expectation.get("status", "")),
			"actual": expectation.get("actual", ""),
			"expected": expectation.get("expected", "")
		})
		summary["checkpoint_highlights"] = checkpoint_highlights

static func _increment_group(summary: Dictionary, group_name: String, key: String, status: String) -> void:
	if key == "":
		key = "unknown"
	var groups: Dictionary = Dictionary(summary.get(group_name, {}))
	if not groups.has(key):
		groups[key] = {"total": 0, "pass": 0, "warn": 0, "fail": 0}
	var group: Dictionary = Dictionary(groups.get(key, {}))
	group["total"] = int(group.get("total", 0)) + 1
	match status:
		ScenarioEvaluatorScript.STATUS_PASS:
			group["pass"] = int(group.get("pass", 0)) + 1
		ScenarioEvaluatorScript.STATUS_WARN:
			group["warn"] = int(group.get("warn", 0)) + 1
		_:
			group["fail"] = int(group.get("fail", 0)) + 1
	groups[key] = group
	summary[group_name] = groups

static func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value: Variant in values:
		result.append(str(value))
	return result
