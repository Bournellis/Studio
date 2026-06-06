extends RefCounted

const DEFAULT_CARD_IMPACT_DIR: String = "res://data/lab/card_impact"
const DEFAULT_PACK_ID: String = "track02_card_impact_v1"
const SUPPORTED_SIMULATION_MODES: Array[String] = ["card_impact_v1", "card_impact_v2", "card_impact_v3", "card_impact_v4", "card_impact_v4_1", "card_impact_v4_2", "card_impact_v5"]
const REQUIRED_PACK_FIELDS: PackedStringArray = ["pack_id", "schema_version", "simulation_mode", "card_sets", "case_templates", "components", "gate_policy"]
const VALID_CARD_FLOW_EXPECTATION_FIELDS: Array[String] = ["card_flow_observed", "cards_drawn", "cards_discarded", "cards_created", "deck_delta", "hand_delta", "discard_delta"]
const VALID_CARD_FLOW_EXPECTATION_OPS: Array[String] = ["==", "!=", ">=", "<=", ">", "<"]
const VALID_CARD_FLOW_EXPECTATION_SEVERITIES: Array[String] = ["required", "watch"]

static func default_pack_id() -> String:
	return DEFAULT_PACK_ID

static func resolve_pack_path(path_or_id: String = "") -> String:
	var value: String = path_or_id.strip_edges()
	if value == "":
		value = DEFAULT_PACK_ID
	if value.begins_with("res://") or value.begins_with("user://") or value.is_absolute_path():
		return value
	if value.find("/") < 0 and value.find("\\") < 0:
		if not value.ends_with(".json"):
			value = "%s.json" % value
		return "%s/%s" % [DEFAULT_CARD_IMPACT_DIR, value]
	return value

static func load_pack(path_or_id: String = "") -> Dictionary:
	var result: Dictionary = load_pack_result(path_or_id)
	if not bool(result.get("ok", false)):
		return {}
	return Dictionary(result.get("pack", {}))

static func load_pack_result(path_or_id: String = "") -> Dictionary:
	var resolved_path: String = resolve_pack_path(path_or_id)
	if not FileAccess.file_exists(resolved_path):
		return {"ok": false, "message": "Card impact pack not found: %s." % resolved_path, "path": resolved_path}
	var text: String = FileAccess.get_file_as_string(resolved_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Card impact pack is not a JSON object: %s." % resolved_path, "path": resolved_path}
	var validation: Dictionary = validate_pack_result(Dictionary(parsed), resolved_path)
	if not bool(validation.get("ok", false)):
		return validation
	return {"ok": true, "path": resolved_path, "pack": Dictionary(parsed)}

static func validate_pack_result(pack: Dictionary, path: String = "") -> Dictionary:
	var errors: Array[String] = []
	for field: String in REQUIRED_PACK_FIELDS:
		if not pack.has(field):
			errors.append("pack missing `%s`" % field)
	if pack.has("simulation_mode") and not SUPPORTED_SIMULATION_MODES.has(str(pack.get("simulation_mode", ""))):
		errors.append("pack simulation_mode must be one of `%s`" % ",".join(SUPPORTED_SIMULATION_MODES))
	for object_field: String in ["card_sets", "case_templates", "components", "gate_policy"]:
		if pack.has(object_field) and typeof(pack.get(object_field)) != TYPE_DICTIONARY:
			errors.append("pack `%s` must be an object" % object_field)
	if str(pack.get("simulation_mode", "")) == "card_impact_v5":
		errors.append_array(_validate_v5_enemy_signatures(pack))
	if pack.has("card_flow_expectations"):
		if typeof(pack.get("card_flow_expectations")) != TYPE_DICTIONARY:
			errors.append("pack `card_flow_expectations` must be an object")
		else:
			errors.append_array(_validate_card_flow_expectations(Dictionary(pack.get("card_flow_expectations", {}))))
	if not errors.is_empty():
		return {"ok": false, "message": "Invalid card impact pack: %s." % "; ".join(errors), "path": path, "errors": errors}
	return {"ok": true, "path": path, "pack": pack}

static func _validate_v5_enemy_signatures(pack: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {}))
	if int(card_sets.get("expected_enemy_effect_signatures", 0)) != 30:
		errors.append("card_impact_v5 requires card_sets.expected_enemy_effect_signatures=30")
	var signatures: Dictionary = Dictionary(pack.get("effect_signatures", {}))
	if signatures.is_empty():
		errors.append("card_impact_v5 requires `effect_signatures`")
		return errors
	var enemy_config: Dictionary = Dictionary(signatures.get("enemy", {}))
	if enemy_config.is_empty():
		errors.append("card_impact_v5 requires `effect_signatures.enemy`")
	elif str(enemy_config.get("mode", "")) != "required":
		errors.append("card_impact_v5 requires effect_signatures.enemy.mode=`required`")
	return errors

static func _validate_card_flow_expectations(config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if not bool(config.get("enabled", false)):
		return errors
	if not config.has("checks") or typeof(config.get("checks")) != TYPE_ARRAY:
		errors.append("card_flow_expectations `checks` must be an array")
		return errors
	var index: int = 0
	for check_value: Variant in Array(config.get("checks", [])):
		if typeof(check_value) != TYPE_DICTIONARY:
			errors.append("card_flow_expectations check %d must be an object" % index)
			index += 1
			continue
		var check: Dictionary = Dictionary(check_value)
		for field: String in ["card_id", "field", "op", "severity"]:
			if str(check.get(field, "")) == "":
				errors.append("card_flow_expectations check %d missing `%s`" % [index, field])
		if not check.has("value"):
			errors.append("card_flow_expectations check %d missing `value`" % index)
		var effect_field: String = str(check.get("field", ""))
		if effect_field != "" and not VALID_CARD_FLOW_EXPECTATION_FIELDS.has(effect_field):
			errors.append("card_flow_expectations check %d field `%s` is not supported" % [index, effect_field])
		var op: String = str(check.get("op", ""))
		if op != "" and not VALID_CARD_FLOW_EXPECTATION_OPS.has(op):
			errors.append("card_flow_expectations check %d op `%s` is not supported" % [index, op])
		var severity: String = str(check.get("severity", ""))
		if severity != "" and not VALID_CARD_FLOW_EXPECTATION_SEVERITIES.has(severity):
			errors.append("card_flow_expectations check %d severity `%s` is not supported" % [index, severity])
		index += 1
	return errors
