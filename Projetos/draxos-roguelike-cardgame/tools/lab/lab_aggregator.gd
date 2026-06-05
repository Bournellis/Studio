extends RefCounted

const NUMERIC_FIELDS: PackedStringArray = [
	"completed_maps",
	"estimated_turns",
	"hp_loss",
	"final_hp",
	"max_hp",
	"deck_size",
	"relic_count",
	"souls_earned",
	"souls_spent",
	"souls_left",
	"shop_usage",
	"deaths"
]

static func aggregate(records: Array[Dictionary], options: Dictionary = {}) -> Dictionary:
	var metrics_list: Array[Dictionary] = []
	for record: Dictionary in records:
		metrics_list.append(Dictionary(record.get("result", {})))
	var summary: Dictionary = _aggregate_group(metrics_list)
	summary["schema_version"] = 1
	summary["tool"] = "autorun_lab"
	summary["preset"] = str(options.get("preset", "smoke"))
	summary["simulation_mode"] = str(options.get("simulation_mode", "macro_route_v1"))
	summary["case_count"] = int(options.get("case_count", metrics_list.size()))
	summary["by_class"] = _aggregate_by(metrics_list, "class_id")
	summary["by_policy"] = _aggregate_by(metrics_list, "policy_id")
	summary["risk_maps"] = _risk_maps(records)
	summary["extremes"] = _extremes(metrics_list)
	return summary

static func _aggregate_by(metrics_list: Array[Dictionary], field: String) -> Dictionary:
	var grouped: Dictionary = {}
	for metrics: Dictionary in metrics_list:
		var key: String = str(metrics.get(field, "unknown"))
		if not grouped.has(key):
			grouped[key] = []
		Array(grouped[key]).append(metrics)
	var result: Dictionary = {}
	for key: String in grouped.keys():
		result[key] = _aggregate_group(Array(grouped.get(key, [])))
	return result

static func _aggregate_group(metrics_list: Array) -> Dictionary:
	var total: int = metrics_list.size()
	var ok_count: int = 0
	var victory_count: int = 0
	var total_maps: int = 0
	var max_maps: int = 0
	var sums: Dictionary = {}
	var mins: Dictionary = {}
	var maxes: Dictionary = {}
	var values_by_field: Dictionary = {}
	for field: String in NUMERIC_FIELDS:
		sums[field] = 0.0
		values_by_field[field] = []

	for item: Variant in metrics_list:
		var metrics: Dictionary = Dictionary(item)
		var map_count: int = int(metrics.get("map_count", 0))
		var completed_maps: int = int(metrics.get("completed_maps", 0))
		total_maps += completed_maps
		max_maps += map_count
		if bool(metrics.get("ok", false)):
			ok_count += 1
		if bool(metrics.get("ok", false)) and completed_maps == map_count and int(metrics.get("deaths", 0)) == 0:
			victory_count += 1
		for field: String in NUMERIC_FIELDS:
			var value: float = float(metrics.get(field, 0))
			sums[field] = float(sums.get(field, 0.0)) + value
			if not mins.has(field) or value < float(mins.get(field, 0.0)):
				mins[field] = value
			if not maxes.has(field) or value > float(maxes.get(field, 0.0)):
				maxes[field] = value
			Array(values_by_field[field]).append(value)

	var averages: Dictionary = {}
	var percentiles: Dictionary = {}
	for field: String in NUMERIC_FIELDS:
		averages[field] = _safe_ratio(float(sums.get(field, 0.0)), total)
		percentiles[field] = {
			"p10": _percentile(Array(values_by_field.get(field, [])), 0.10),
			"p50": _percentile(Array(values_by_field.get(field, [])), 0.50),
			"p90": _percentile(Array(values_by_field.get(field, [])), 0.90)
		}
	return {
		"total_runs": total,
		"ok_runs": ok_count,
		"failed_runs": total - ok_count,
		"victories": victory_count,
		"victory_rate": _safe_ratio(victory_count, total),
		"completion_rate": _safe_ratio(total_maps, max_maps),
		"averages": averages,
		"mins": mins,
		"maxes": maxes,
		"percentiles": percentiles
	}

static func _risk_maps(records: Array[Dictionary]) -> Array[Dictionary]:
	var counts: Dictionary = {}
	for record: Dictionary in records:
		for event: Dictionary in Array(record.get("timeline", [])):
			var map_index: int = int(event.get("map", 0))
			if map_index <= 0:
				continue
			if int(event.get("lethal_event", 0)) > 0 or int(event.get("hp_after", 0)) <= 5:
				counts[map_index] = int(counts.get(map_index, 0)) + 1
	var maps: Array = counts.keys()
	maps.sort()
	var result: Array[Dictionary] = []
	for map_index: int in maps:
		result.append({"map": map_index, "risk_events": int(counts.get(map_index, 0))})
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("risk_events", 0)) > int(b.get("risk_events", 0))
	)
	return result

static func _extremes(metrics_list: Array[Dictionary]) -> Dictionary:
	return {
		"lowest_final_hp": _extreme_case(metrics_list, "final_hp", true),
		"highest_deck_size": _extreme_case(metrics_list, "deck_size", false),
		"highest_shop_usage": _extreme_case(metrics_list, "shop_usage", false),
		"most_hp_loss": _extreme_case(metrics_list, "hp_loss", false)
	}

static func _extreme_case(metrics_list: Array[Dictionary], field: String, lowest: bool) -> Dictionary:
	var selected: Dictionary = {}
	for metrics: Dictionary in metrics_list:
		if selected.is_empty():
			selected = metrics
			continue
		var current_value: int = int(metrics.get(field, 0))
		var selected_value: int = int(selected.get(field, 0))
		if (lowest and current_value < selected_value) or (not lowest and current_value > selected_value):
			selected = metrics
	return {
		"case_id": str(selected.get("case_id", "")),
		"class_id": str(selected.get("class_id", "")),
		"seed": int(selected.get("seed", 0)),
		"policy_id": str(selected.get("policy_id", "")),
		"value": int(selected.get(field, 0))
	}

static func _safe_ratio(numerator: float, denominator: float) -> float:
	if denominator <= 0.0:
		return 0.0
	return numerator / denominator

static func _percentile(values: Array, percentile: float) -> float:
	if values.is_empty():
		return 0.0
	var sorted_values: Array = values.duplicate()
	sorted_values.sort()
	var index: int = clampi(int(round((sorted_values.size() - 1) * percentile)), 0, sorted_values.size() - 1)
	return float(sorted_values[index])
