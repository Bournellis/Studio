extends RefCounted

const DEFAULT_BASELINE_DIR: String = "res://data/lab/baselines"
const DEFAULT_BASELINE_BY_PRESET: Dictionary = {
	"smoke": "track02_smoke_v1",
	"golden": "track02_smoke_v1",
	"quick": "track02_quick_v1"
}
const DEFAULT_ACCEPTANCE: Dictionary = {
	"baseline_id": "track02_autorun_macro_v1_smoke",
	"summary_fields": {
		"victory_rate_min": 1.0,
		"completion_rate_min": 1.0,
		"avg_deck_size_min": 30.0,
		"avg_deck_size_max": 42.0,
		"avg_shop_usage_min": 0.0,
		"avg_shop_usage_max": 30.0
	}
}

static func compare_summary(summary: Dictionary, baseline: Dictionary = {}) -> Dictionary:
	var expected: Dictionary = DEFAULT_ACCEPTANCE if baseline.is_empty() else baseline
	var differences: Array[Dictionary] = []
	_compare_fields(differences, "summary", summary, Dictionary(expected.get("summary_fields", {})))
	_compare_required_groups(differences, summary, Dictionary(expected.get("required_groups", {})))
	_compare_group_fields(differences, summary, Dictionary(expected.get("group_fields", {})))
	return {
		"ok": differences.is_empty(),
		"baseline_id": str(expected.get("baseline_id", "custom")),
		"differences": differences,
		"expected": expected
	}

static func default_baseline_id_for_preset(preset: String) -> String:
	return str(DEFAULT_BASELINE_BY_PRESET.get(preset, ""))

static func resolve_baseline_path(path_or_id: String, preset: String = "") -> String:
	var value: String = path_or_id.strip_edges()
	if value == "":
		value = default_baseline_id_for_preset(preset)
	if value == "":
		return ""
	if value.begins_with("res://") or value.begins_with("user://") or value.is_absolute_path():
		return value
	if value.find("/") < 0 and value.find("\\") < 0:
		if not value.ends_with(".json"):
			value = "%s.json" % value
		return "%s/%s" % [DEFAULT_BASELINE_DIR, value]
	return value

static func load_baseline(path_or_id: String, preset: String = "") -> Dictionary:
	var result: Dictionary = load_baseline_result(path_or_id, preset)
	if not bool(result.get("ok", false)):
		return {}
	return Dictionary(result.get("baseline", {}))

static func load_baseline_result(path_or_id: String, preset: String = "") -> Dictionary:
	var resolved_path: String = resolve_baseline_path(path_or_id, preset)
	if resolved_path == "":
		return {"ok": false, "message": "No baseline was provided for preset `%s`." % preset}
	if not FileAccess.file_exists(resolved_path):
		return {"ok": false, "message": "Baseline not found: %s." % resolved_path, "path": resolved_path}
	var text: String = FileAccess.get_file_as_string(resolved_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Baseline is not valid JSON object: %s." % resolved_path, "path": resolved_path}
	return {"ok": true, "path": resolved_path, "baseline": Dictionary(parsed)}

static func save_baseline(path: String, summary: Dictionary) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Could not write baseline %s." % path}
	file.store_string(JSON.stringify({
		"baseline_id": "autorun_lab_saved_%s" % Time.get_datetime_string_from_system(false, true),
		"summary_fields": {
			"victory_rate_min": maxf(0.0, float(summary.get("victory_rate", 0.0)) - 0.05),
			"completion_rate_min": maxf(0.0, float(summary.get("completion_rate", 0.0)) - 0.05),
			"avg_deck_size_min": maxf(0.0, float(Dictionary(summary.get("averages", {})).get("deck_size", 0.0)) - 4.0),
			"avg_deck_size_max": float(Dictionary(summary.get("averages", {})).get("deck_size", 0.0)) + 4.0,
			"avg_shop_usage_min": maxf(0.0, float(Dictionary(summary.get("averages", {})).get("shop_usage", 0.0)) - 6.0),
			"avg_shop_usage_max": float(Dictionary(summary.get("averages", {})).get("shop_usage", 0.0)) + 6.0
		},
		"source_summary": summary
	}, "\t"))
	file.close()
	return {"ok": true, "path": path}

static func format_comparison(comparison: Dictionary) -> String:
	if bool(comparison.get("ok", false)):
		return "baseline ok: %s" % str(comparison.get("baseline_id", ""))
	var parts: Array[String] = []
	for difference: Dictionary in Array(comparison.get("differences", [])):
		parts.append("%s actual=%s expected=%s" % [
			str(difference.get("field", "")),
			str(difference.get("actual", "")),
			str(difference.get("expected", ""))
		])
	if parts.size() > 8:
		var trimmed_parts: Array[String] = []
		for index: int in range(8):
			trimmed_parts.append(parts[index])
		trimmed_parts.append("... %d more" % (Array(comparison.get("differences", [])).size() - 8))
		parts = trimmed_parts
	return "baseline mismatch: %s (%s)" % [str(comparison.get("baseline_id", "")), "; ".join(parts)]

static func _compare_required_groups(differences: Array[Dictionary], summary: Dictionary, required_groups: Dictionary) -> void:
	for group_name: String in required_groups.keys():
		var group: Dictionary = Dictionary(summary.get(group_name, {}))
		for expected_key: Variant in Array(required_groups.get(group_name, [])):
			var key: String = str(expected_key)
			if not group.has(key):
				differences.append({
					"field": "%s.%s" % [group_name, key],
					"actual": "missing",
					"expected": "present"
				})

static func _compare_group_fields(differences: Array[Dictionary], summary: Dictionary, group_fields: Dictionary) -> void:
	for group_name: String in group_fields.keys():
		var group: Dictionary = Dictionary(summary.get(group_name, {}))
		var rules_by_key: Dictionary = Dictionary(group_fields.get(group_name, {}))
		if rules_by_key.has("*"):
			var wildcard_rules: Dictionary = Dictionary(rules_by_key.get("*", {}))
			for key: String in group.keys():
				_compare_fields(differences, "%s.%s" % [group_name, key], Dictionary(group.get(key, {})), wildcard_rules)
		for key: String in rules_by_key.keys():
			if key == "*":
				continue
			if not group.has(key):
				differences.append({
					"field": "%s.%s" % [group_name, key],
					"actual": "missing",
					"expected": "present"
				})
				continue
			_compare_fields(differences, "%s.%s" % [group_name, key], Dictionary(group.get(key, {})), Dictionary(rules_by_key.get(key, {})))

static func _compare_fields(differences: Array[Dictionary], prefix: String, data: Dictionary, rules: Dictionary) -> void:
	for rule_key: String in rules.keys():
		var parsed: Dictionary = _parse_rule_key(rule_key)
		if parsed.is_empty():
			continue
		var metric_key: String = str(parsed.get("metric", ""))
		var op: String = str(parsed.get("op", ""))
		var actual: Variant = _value_for_metric(data, metric_key)
		var expected: Variant = rules.get(rule_key)
		var field_name: String = "%s.%s" % [prefix, metric_key]
		if actual == null:
			differences.append({"field": field_name, "actual": "missing", "expected": str(expected)})
			continue
		match op:
			"min":
				if float(actual) < float(expected):
					differences.append({"field": field_name, "actual": actual, "expected": ">= %.3f" % float(expected)})
			"max":
				if float(actual) > float(expected):
					differences.append({"field": field_name, "actual": actual, "expected": "<= %.3f" % float(expected)})
			"equals":
				if str(actual) != str(expected):
					differences.append({"field": field_name, "actual": actual, "expected": str(expected)})

static func _parse_rule_key(rule_key: String) -> Dictionary:
	if rule_key.ends_with("_min"):
		return {"metric": rule_key.trim_suffix("_min"), "op": "min"}
	if rule_key.ends_with("_max"):
		return {"metric": rule_key.trim_suffix("_max"), "op": "max"}
	if rule_key.ends_with("_equals"):
		return {"metric": rule_key.trim_suffix("_equals"), "op": "equals"}
	return {}

static func _value_for_metric(data: Dictionary, metric_key: String) -> Variant:
	if data.has(metric_key):
		return data.get(metric_key)
	if metric_key.begins_with("avg_"):
		return Dictionary(data.get("averages", {})).get(metric_key.trim_prefix("avg_"), null)
	if metric_key.begins_with("min_"):
		return Dictionary(data.get("mins", {})).get(metric_key.trim_prefix("min_"), null)
	if metric_key.begins_with("max_"):
		return Dictionary(data.get("maxes", {})).get(metric_key.trim_prefix("max_"), null)
	for percentile_key: String in ["p10", "p50", "p90"]:
		var prefix: String = "%s_" % percentile_key
		if metric_key.begins_with(prefix):
			var field: String = metric_key.trim_prefix(prefix)
			return Dictionary(Dictionary(data.get("percentiles", {})).get(field, {})).get(percentile_key, null)
	return null
