extends RefCounted

const STATUS_PASS: String = "PASS"
const STATUS_WARN: String = "WARN"
const STATUS_FAIL: String = "FAIL"

static func evaluate(scenario: Dictionary, metrics: Dictionary) -> Dictionary:
	var expectations: Dictionary = Dictionary(scenario.get("expectations", {}))
	var entries: Array[Dictionary] = []
	var required_rules: Dictionary = Dictionary(expectations.get("required", {}))
	var watch_rules: Dictionary = Dictionary(expectations.get("watch", {}))
	if required_rules.is_empty() and watch_rules.is_empty():
		required_rules = expectations
	_evaluate_rules(entries, "required", required_rules, metrics, STATUS_FAIL)
	_evaluate_rules(entries, "watch", watch_rules, metrics, STATUS_WARN)
	var status: String = STATUS_PASS
	for entry: Dictionary in entries:
		var entry_status: String = str(entry.get("status", STATUS_PASS))
		if entry_status == STATUS_FAIL:
			status = STATUS_FAIL
			break
		if entry_status == STATUS_WARN:
			status = STATUS_WARN
	return {
		"ok": status != STATUS_FAIL,
		"status": status,
		"expectations": entries,
		"warnings": _messages_for_status(entries, STATUS_WARN),
		"failures": _messages_for_status(entries, STATUS_FAIL)
	}

static func _evaluate_rules(entries: Array[Dictionary], scope: String, rules: Dictionary, metrics: Dictionary, failed_status: String) -> void:
	for rule_key: String in rules.keys():
		if rule_key == "map_checkpoints":
			_evaluate_map_checkpoints(entries, scope, Array(rules.get(rule_key, [])), metrics, failed_status)
			continue
		if rule_key == "complete_route":
			var expected_complete: bool = bool(rules.get(rule_key, true))
			var actual_complete: bool = metrics.has("completed_maps") and metrics.has("map_count") and int(metrics.get("map_count", 0)) > 0 and int(metrics.get("completed_maps", 0)) == int(metrics.get("map_count", 0))
			_append_entry(entries, scope, rule_key, actual_complete, expected_complete, actual_complete == expected_complete, failed_status)
			continue
		if rule_key == "no_deaths":
			var expected_no_deaths: bool = bool(rules.get(rule_key, true))
			var actual_no_deaths: bool = metrics.has("deaths") and int(metrics.get("deaths", 0)) == 0
			_append_entry(entries, scope, rule_key, actual_no_deaths, expected_no_deaths, actual_no_deaths == expected_no_deaths, failed_status)
			continue
		var parsed: Dictionary = _parse_rule_key(rule_key)
		if parsed.is_empty():
			continue
		var metric_key: String = str(parsed.get("metric", ""))
		var op: String = str(parsed.get("op", ""))
		var actual: Variant = metrics.get(metric_key, null)
		var expected: Variant = rules.get(rule_key)
		_append_entry(entries, scope, rule_key, actual, _expected_label(op, expected), _passes(actual, op, expected), failed_status)

static func _evaluate_map_checkpoints(entries: Array[Dictionary], scope: String, checkpoints: Array, metrics: Dictionary, failed_status: String) -> void:
	for checkpoint_value: Variant in checkpoints:
		if typeof(checkpoint_value) != TYPE_DICTIONARY:
			continue
		var checkpoint: Dictionary = Dictionary(checkpoint_value)
		var map_index: int = int(checkpoint.get("map", 0))
		var event: Dictionary = _timeline_event_for_map(metrics, map_index)
		for rule_key: String in checkpoint.keys():
			if rule_key == "map":
				continue
			var parsed: Dictionary = _parse_rule_key(rule_key)
			if parsed.is_empty():
				continue
			var metric_key: String = str(parsed.get("metric", ""))
			var op: String = str(parsed.get("op", ""))
			var actual: Variant = event.get(metric_key, null)
			var expected: Variant = checkpoint.get(rule_key)
			_append_entry(entries, scope, "map_%02d.%s" % [map_index, rule_key], actual, _expected_label(op, expected), _passes(actual, op, expected), failed_status)

static func _timeline_event_for_map(metrics: Dictionary, map_index: int) -> Dictionary:
	for event_value: Variant in Array(metrics.get("timeline", [])):
		var event: Dictionary = Dictionary(event_value)
		if int(event.get("map", 0)) == map_index:
			return event
	return {}

static func _parse_rule_key(rule_key: String) -> Dictionary:
	if rule_key.ends_with("_min"):
		return {"metric": rule_key.trim_suffix("_min"), "op": "min"}
	if rule_key.ends_with("_max"):
		return {"metric": rule_key.trim_suffix("_max"), "op": "max"}
	if rule_key.ends_with("_equals"):
		return {"metric": rule_key.trim_suffix("_equals"), "op": "equals"}
	return {}

static func _passes(actual: Variant, op: String, expected: Variant) -> bool:
	if actual == null:
		return false
	match op:
		"min":
			return float(actual) >= float(expected)
		"max":
			return float(actual) <= float(expected)
		"equals":
			if typeof(expected) in [TYPE_INT, TYPE_FLOAT] and typeof(actual) in [TYPE_INT, TYPE_FLOAT]:
				return float(actual) == float(expected)
			return str(actual) == str(expected)
	return true

static func _expected_label(op: String, expected: Variant) -> String:
	match op:
		"min":
			return ">= %s" % str(expected)
		"max":
			return "<= %s" % str(expected)
		"equals":
			return str(expected)
	return str(expected)

static func _append_entry(entries: Array[Dictionary], scope: String, field: String, actual: Variant, expected: Variant, passed: bool, failed_status: String) -> void:
	var status: String = STATUS_PASS if passed else failed_status
	entries.append({
		"scope": scope,
		"field": field,
		"status": status,
		"actual": actual if actual != null else "missing",
		"expected": expected,
		"message": "%s.%s actual=%s expected=%s" % [scope, field, str(actual if actual != null else "missing"), str(expected)]
	})

static func _messages_for_status(entries: Array[Dictionary], status: String) -> Array[String]:
	var messages: Array[String] = []
	for entry: Dictionary in entries:
		if str(entry.get("status", STATUS_PASS)) == status:
			messages.append(str(entry.get("message", "")))
	return messages
