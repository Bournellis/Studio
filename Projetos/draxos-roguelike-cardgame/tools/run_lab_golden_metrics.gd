extends RefCounted

const DEFAULT_GOLDEN_SET_ID: String = "track_02_foundation_hardening_4"
const EXACT_FIELDS: PackedStringArray = [
	"class_id",
	"seed",
	"ok",
	"map_count",
	"completed_maps",
	"estimated_turns",
	"hp_loss",
	"final_hp",
	"max_hp",
	"souls_earned",
	"souls_spent",
	"souls_left",
	"deck_size",
	"relic_count",
	"shop_usage",
	"deaths",
	"shop_actions"
]
const COMPLETION_FIELDS: PackedStringArray = [
	"class_id",
	"seed",
	"ok",
	"map_count",
	"completed_maps",
	"deaths"
]
const SHOP_ACTIONS_TRACK_02: Array[String] = [
	"heal",
	"heal",
	"max_hp",
	"heal",
	"remove",
	"heal",
	"heal",
	"heal",
	"max_hp",
	"heal",
	"duplicate",
	"heal",
	"remove",
	"heal",
	"heal",
	"heal",
	"heal",
	"heal",
	"heal",
	"heal",
	"relic"
]
const GOLDEN_METRICS: Dictionary = {
	"arcano:20260518": {
		"class_id": "arcano",
		"seed": 20260518,
		"ok": true,
		"map_count": 29,
		"completed_maps": 29,
		"estimated_turns": 217,
		"hp_loss": 116,
		"final_hp": 13,
		"max_hp": 46,
		"souls_earned": 362,
		"souls_spent": 291,
		"souls_left": 71,
		"deck_size": 38,
		"relic_count": 6,
		"shop_usage": 21,
		"deaths": 0,
		"shop_actions": SHOP_ACTIONS_TRACK_02
	},
	"invocador:20260518": {
		"class_id": "invocador",
		"seed": 20260518,
		"ok": true,
		"map_count": 29,
		"completed_maps": 29,
		"estimated_turns": 217,
		"hp_loss": 116,
		"final_hp": 16,
		"max_hp": 49,
		"souls_earned": 362,
		"souls_spent": 276,
		"souls_left": 86,
		"deck_size": 37,
		"relic_count": 6,
		"shop_usage": 21,
		"deaths": 0,
		"shop_actions": SHOP_ACTIONS_TRACK_02
	},
	"necromante:20260518": {
		"class_id": "necromante",
		"seed": 20260518,
		"ok": true,
		"map_count": 29,
		"completed_maps": 29,
		"estimated_turns": 217,
		"hp_loss": 116,
		"final_hp": 13,
		"max_hp": 46,
		"souls_earned": 362,
		"souls_spent": 316,
		"souls_left": 46,
		"deck_size": 38,
		"relic_count": 6,
		"shop_usage": 21,
		"deaths": 0,
		"shop_actions": SHOP_ACTIONS_TRACK_02
	}
}
const COMPARISON_FIELDS_BY_KEY: Dictionary = {
	"arcano:20260518": EXACT_FIELDS,
	"invocador:20260518": COMPLETION_FIELDS,
	"necromante:20260518": COMPLETION_FIELDS
}

static func key_for(class_id: String, seed: int) -> String:
	return "%s:%d" % [class_id, seed]

static func has_golden(class_id: String, seed: int) -> bool:
	return GOLDEN_METRICS.has(key_for(class_id, seed))

static func golden_for(class_id: String, seed: int) -> Dictionary:
	return Dictionary(GOLDEN_METRICS.get(key_for(class_id, seed), {})).duplicate(true)

static func default_cases() -> Array[Dictionary]:
	var cases: Array[Dictionary] = []
	for key: String in GOLDEN_METRICS.keys():
		var expected: Dictionary = Dictionary(GOLDEN_METRICS.get(key, {})).duplicate(true)
		cases.append({
			"key": key,
			"class_id": str(expected.get("class_id", "")),
			"seed": int(expected.get("seed", 0)),
			"expected": expected,
			"fields": _fields_for_key(key, false)
		})
	return cases

static func compare_metrics(metrics: Dictionary, options: Dictionary = {}) -> Dictionary:
	var class_id: String = str(metrics.get("class_id", ""))
	var seed: int = int(metrics.get("seed", 0))
	var key: String = key_for(class_id, seed)
	var require_known: bool = bool(options.get("require_known", false))
	if not GOLDEN_METRICS.has(key):
		return {
			"ok": not require_known,
			"checked": false,
			"key": key,
			"message": "No golden metrics for %s." % key,
			"metrics": metrics.duplicate(true),
			"expected": {},
			"differences": []
		}

	var expected: Dictionary = Dictionary(GOLDEN_METRICS.get(key, {})).duplicate(true)
	var fields: PackedStringArray = _fields_for_key(key, bool(options.get("strict", false)))
	var differences: Array[Dictionary] = []
	for field: String in fields:
		var expected_value: Variant = expected.get(field)
		var actual_value: Variant = metrics.get(field)
		if not _values_match(actual_value, expected_value):
			differences.append({
				"field": field,
				"expected": expected_value,
				"actual": actual_value
			})

	var ok: bool = differences.is_empty()
	var message: String = "Golden metrics matched for %s." % key
	if not ok:
		message = "Golden metrics mismatch for %s." % key
	return {
		"ok": ok,
		"checked": true,
		"key": key,
		"golden_set_id": DEFAULT_GOLDEN_SET_ID,
		"message": message,
		"metrics": metrics.duplicate(true),
		"expected": expected,
		"fields": Array(fields),
		"differences": differences
	}

static func compare_many(results: Array[Dictionary], options: Dictionary = {}) -> Dictionary:
	var comparisons: Array[Dictionary] = []
	var checked_count: int = 0
	var mismatch_count: int = 0
	for metrics: Dictionary in results:
		var comparison: Dictionary = compare_metrics(metrics, options)
		comparisons.append(comparison)
		if bool(comparison.get("checked", false)):
			checked_count += 1
		if not bool(comparison.get("ok", false)):
			mismatch_count += 1
	return {
		"ok": mismatch_count == 0,
		"golden_set_id": DEFAULT_GOLDEN_SET_ID,
		"checked_count": checked_count,
		"mismatch_count": mismatch_count,
		"results": comparisons
	}

static func format_comparison(comparison: Dictionary) -> String:
	if not bool(comparison.get("checked", false)):
		return "golden skipped: %s" % str(comparison.get("message", ""))
	if bool(comparison.get("ok", false)):
		return "golden ok: %s" % str(comparison.get("key", ""))
	var parts: Array[String] = []
	for difference: Dictionary in Array(comparison.get("differences", [])):
		parts.append("%s expected=%s actual=%s" % [
			str(difference.get("field", "")),
			str(difference.get("expected", "")),
			str(difference.get("actual", ""))
		])
	return "golden mismatch: %s (%s)" % [str(comparison.get("key", "")), "; ".join(parts)]

static func _fields_for_key(key: String, strict: bool) -> PackedStringArray:
	if strict:
		return EXACT_FIELDS
	return PackedStringArray(COMPARISON_FIELDS_BY_KEY.get(key, COMPLETION_FIELDS))

static func _values_match(actual_value: Variant, expected_value: Variant) -> bool:
	if typeof(expected_value) == TYPE_ARRAY or typeof(actual_value) == TYPE_ARRAY:
		if typeof(expected_value) != TYPE_ARRAY or typeof(actual_value) != TYPE_ARRAY:
			return false
		return Array(actual_value) == Array(expected_value)
	return actual_value == expected_value
