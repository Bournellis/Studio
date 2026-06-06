extends RefCounted

const VALID_FIELDS: Array[String] = [
	"card_flow_observed",
	"cards_drawn",
	"cards_discarded",
	"cards_created",
	"deck_delta",
	"hand_delta",
	"discard_delta"
]
const VALID_OPS: Array[String] = ["==", "!=", ">=", "<=", ">", "<"]
const SEVERITY_REQUIRED: String = "required"
const SEVERITY_WATCH: String = "watch"

static func empty_summary(pack: Dictionary = {}) -> Dictionary:
	var config: Dictionary = Dictionary(pack.get("card_flow_expectations", {}))
	return {
		"enabled": bool(config.get("enabled", false)),
		"total_count": 0,
		"pass_count": 0,
		"warn_count": 0,
		"fail_count": 0,
		"required_fail_count": 0,
		"watch_warn_count": 0,
		"missing_signature_count": 0,
		"skipped_count": 0,
		"results": []
	}

static func evaluate_records(pack: Dictionary, records: Array, options: Dictionary = {}) -> Dictionary:
	var config: Dictionary = Dictionary(pack.get("card_flow_expectations", {}))
	if not bool(config.get("enabled", false)):
		return empty_summary(pack)
	var checks: Array = Array(config.get("checks", []))
	var constrain_to_selected: bool = options.has("card_ids")
	var selected_ids: Dictionary = _selected_id_map(PackedStringArray(options.get("card_ids", PackedStringArray())))
	var signature_map: Dictionary = _signature_map(records)
	var results: Array[Dictionary] = []
	var skipped_count: int = 0
	for check_value: Variant in checks:
		if typeof(check_value) != TYPE_DICTIONARY:
			continue
		var check: Dictionary = Dictionary(check_value)
		var card_id: String = str(check.get("card_id", ""))
		if constrain_to_selected and not selected_ids.has(card_id):
			skipped_count += 1
			continue
		results.append(_evaluate_check(check, Dictionary(signature_map.get(card_id, {}))))
	return _summary_from_results(pack, results, skipped_count)

static func evaluate_records_from_path(pack: Dictionary, path: String, options: Dictionary = {}) -> Dictionary:
	if path == "" or not FileAccess.file_exists(path):
		var summary: Dictionary = empty_summary(pack)
		if bool(summary.get("enabled", false)):
			summary["fail_count"] = 1
			summary["required_fail_count"] = 1
			summary["results"] = [{
				"card_id": "",
				"field": "",
				"op": "",
				"expected": "",
				"actual": "",
				"severity": SEVERITY_REQUIRED,
				"status": "FAIL",
				"message": "missing battle results for card-flow expectations"
			}]
		return summary
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return empty_summary(pack)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return empty_summary(pack)
	return evaluate_records(pack, Array(Dictionary(parsed).get("records", [])), options)

static func merge_summaries(target: Dictionary, source: Dictionary) -> void:
	if source.is_empty():
		return
	target["enabled"] = bool(target.get("enabled", false)) or bool(source.get("enabled", false))
	for field: String in ["total_count", "pass_count", "warn_count", "fail_count", "required_fail_count", "watch_warn_count", "missing_signature_count", "skipped_count"]:
		target[field] = int(target.get(field, 0)) + int(source.get(field, 0))
	var results: Array = Array(target.get("results", []))
	for result_value: Variant in Array(source.get("results", [])):
		if typeof(result_value) == TYPE_DICTIONARY:
			results.append(Dictionary(result_value).duplicate(true))
	target["results"] = results

static func _evaluate_check(check: Dictionary, signature: Dictionary) -> Dictionary:
	var card_id: String = str(check.get("card_id", ""))
	var field: String = str(check.get("field", ""))
	var op: String = str(check.get("op", ""))
	var expected: Variant = check.get("value", null)
	var severity: String = str(check.get("severity", SEVERITY_REQUIRED))
	var actual: Variant = null
	var passed: bool = false
	var message: String = ""
	if signature.is_empty() or not bool(signature.get("present", false)):
		message = "missing effect signature"
	elif not signature.has(field):
		message = "signature missing `%s`" % field
	else:
		actual = signature.get(field)
		var compare: Dictionary = _compare(actual, expected, op)
		passed = bool(compare.get("ok", false))
		message = str(compare.get("message", ""))
	var status: String = "PASS"
	if not passed:
		status = "FAIL" if severity == SEVERITY_REQUIRED else "WARN"
	return {
		"card_id": card_id,
		"field": field,
		"op": op,
		"expected": expected,
		"actual": actual,
		"severity": severity,
		"status": status,
		"message": message
	}

static func _compare(actual: Variant, expected: Variant, op: String) -> Dictionary:
	match op:
		"==":
			return {"ok": actual == expected, "message": ""}
		"!=":
			return {"ok": actual != expected, "message": ""}
	if not _is_number(actual) or not _is_number(expected):
		return {"ok": false, "message": "operator `%s` requires numeric values" % op}
	var actual_number: float = float(actual)
	var expected_number: float = float(expected)
	match op:
		">=":
			return {"ok": actual_number >= expected_number, "message": ""}
		"<=":
			return {"ok": actual_number <= expected_number, "message": ""}
		">":
			return {"ok": actual_number > expected_number, "message": ""}
		"<":
			return {"ok": actual_number < expected_number, "message": ""}
	return {"ok": false, "message": "unsupported operator `%s`" % op}

static func _summary_from_results(pack: Dictionary, results: Array[Dictionary], skipped_count: int) -> Dictionary:
	var summary: Dictionary = empty_summary(pack)
	summary["total_count"] = results.size()
	summary["skipped_count"] = skipped_count
	for result: Dictionary in results:
		match str(result.get("status", "")):
			"PASS":
				summary["pass_count"] = int(summary.get("pass_count", 0)) + 1
			"WARN":
				summary["warn_count"] = int(summary.get("warn_count", 0)) + 1
				summary["watch_warn_count"] = int(summary.get("watch_warn_count", 0)) + 1
			"FAIL":
				summary["fail_count"] = int(summary.get("fail_count", 0)) + 1
				summary["required_fail_count"] = int(summary.get("required_fail_count", 0)) + 1
		if str(result.get("message", "")) == "missing effect signature":
			summary["missing_signature_count"] = int(summary.get("missing_signature_count", 0)) + 1
	summary["results"] = results.duplicate(true)
	return summary

static func _signature_map(records: Array) -> Dictionary:
	var mapped: Dictionary = {}
	for record_value: Variant in records:
		if typeof(record_value) != TYPE_DICTIONARY:
			continue
		var record: Dictionary = Dictionary(record_value)
		var result: Dictionary = Dictionary(record.get("result", {}))
		var signature: Dictionary = Dictionary(result.get("card_effect_signature", {}))
		var card_id: String = str(signature.get("card_id", result.get("card_under_test", "")))
		if card_id == "":
			card_id = _card_id_from_case_id(str(result.get("case_id", Dictionary(record.get("case", {})).get("id", ""))))
		if card_id != "":
			mapped[card_id] = signature
	return mapped

static func _selected_id_map(ids: PackedStringArray) -> Dictionary:
	var mapped: Dictionary = {}
	for id: String in ids:
		if id != "":
			mapped[id] = true
	return mapped

static func _card_id_from_case_id(case_id: String) -> String:
	if case_id.begins_with("card_impact_player_"):
		return case_id.trim_prefix("card_impact_player_")
	if case_id.begins_with("card_impact_enemy_"):
		return case_id.trim_prefix("card_impact_enemy_")
	return ""

static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT
