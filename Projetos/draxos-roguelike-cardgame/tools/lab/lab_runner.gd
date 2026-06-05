extends RefCounted

const RoutePacingSimulatorScript = preload("res://tools/route_pacing_simulator.gd")
const SCHEMA_VERSION: int = 1
const TOOL_ID: String = "autorun_lab"

static func run_cases(session, catalog, cases: Array[Dictionary], options: Dictionary = {}) -> Dictionary:
	var simulator = RoutePacingSimulatorScript.new()
	var records: Array[Dictionary] = []
	var stopped_early: bool = false
	for case_data: Dictionary in cases:
		var metrics: Dictionary = simulator.simulate_route(session, catalog, str(case_data.get("class_id", "")), int(case_data.get("seed", 0)), {
			"policy_id": str(case_data.get("policy_id", "baseline")),
			"route_policy": str(case_data.get("route_policy", "linear_track02")),
			"reward_policy": str(case_data.get("reward_policy", "baseline")),
			"shop_policy": str(case_data.get("shop_policy", "baseline_recovery")),
			"simulation_mode": str(case_data.get("simulation_mode", "macro_route_v1")),
			"timeline": bool(options.get("timeline", true))
		})
		metrics["case_id"] = str(case_data.get("case_id", ""))
		metrics["policy_id"] = str(case_data.get("policy_id", "baseline"))
		metrics["reward_policy"] = str(case_data.get("reward_policy", "baseline"))
		metrics["shop_policy"] = str(case_data.get("shop_policy", "baseline_recovery"))
		metrics["route_policy"] = str(case_data.get("route_policy", "linear_track02"))
		metrics["simulation_mode"] = str(case_data.get("simulation_mode", "macro_route_v1"))
		var timeline: Array = Array(metrics.get("timeline", []))
		var warnings: Array[String] = _warnings_for(metrics)
		records.append({
			"schema_version": SCHEMA_VERSION,
			"tool": TOOL_ID,
			"case": case_data.duplicate(true),
			"result": metrics.duplicate(true),
			"timeline": timeline.duplicate(true),
			"warnings": warnings,
			"tags": _tags_for(metrics)
		})
		if bool(options.get("stop_on_failure", false)) and not bool(metrics.get("ok", false)):
			stopped_early = true
			break
	return {
		"ok": _records_ok(records),
		"records": records,
		"stopped_early": stopped_early
	}

static func metrics_for_records(records: Array[Dictionary]) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	for record: Dictionary in records:
		results.append(Dictionary(record.get("result", {})).duplicate(true))
	return results

static func _records_ok(records: Array[Dictionary]) -> bool:
	for record: Dictionary in records:
		if not bool(Dictionary(record.get("result", {})).get("ok", false)):
			return false
	return true

static func _warnings_for(metrics: Dictionary) -> Array[String]:
	var warnings: Array[String] = []
	if int(metrics.get("completed_maps", 0)) < int(metrics.get("map_count", 0)):
		warnings.append("route_incomplete")
	if int(metrics.get("deaths", 0)) > 0:
		warnings.append("lethal_events")
	if int(metrics.get("final_hp", 0)) <= 5:
		warnings.append("low_final_hp")
	return warnings

static func _tags_for(metrics: Dictionary) -> Array[String]:
	var tags: Array[String] = [str(metrics.get("simulation_mode", "macro_route_v1")), str(metrics.get("policy_id", "baseline"))]
	if bool(metrics.get("ok", false)) and int(metrics.get("completed_maps", 0)) == int(metrics.get("map_count", 0)):
		tags.append("complete_route")
	return tags
