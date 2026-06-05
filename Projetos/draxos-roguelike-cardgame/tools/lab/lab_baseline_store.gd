extends RefCounted

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
	var fields: Dictionary = Dictionary(expected.get("summary_fields", {}))
	var differences: Array[Dictionary] = []
	_check_min(differences, "victory_rate", float(summary.get("victory_rate", 0.0)), float(fields.get("victory_rate_min", 0.0)))
	_check_min(differences, "completion_rate", float(summary.get("completion_rate", 0.0)), float(fields.get("completion_rate_min", 0.0)))
	var averages: Dictionary = Dictionary(summary.get("averages", {}))
	_check_range(differences, "avg_deck_size", float(averages.get("deck_size", 0.0)), float(fields.get("avg_deck_size_min", 0.0)), float(fields.get("avg_deck_size_max", 999999.0)))
	_check_range(differences, "avg_shop_usage", float(averages.get("shop_usage", 0.0)), float(fields.get("avg_shop_usage_min", 0.0)), float(fields.get("avg_shop_usage_max", 999999.0)))
	return {
		"ok": differences.is_empty(),
		"baseline_id": str(expected.get("baseline_id", "custom")),
		"differences": differences,
		"expected": expected
	}

static func load_baseline(path: String) -> Dictionary:
	if path == "" or not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return Dictionary(parsed)

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
	return "baseline mismatch: %s (%s)" % [str(comparison.get("baseline_id", "")), "; ".join(parts)]

static func _check_min(differences: Array[Dictionary], field: String, actual: float, expected_min: float) -> void:
	if actual < expected_min:
		differences.append({"field": field, "actual": actual, "expected": ">= %.3f" % expected_min})

static func _check_range(differences: Array[Dictionary], field: String, actual: float, expected_min: float, expected_max: float) -> void:
	if actual < expected_min or actual > expected_max:
		differences.append({"field": field, "actual": actual, "expected": "%.3f..%.3f" % [expected_min, expected_max]})
