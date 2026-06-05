extends RefCounted

const DEFAULT_CARD_IMPACT_DIR: String = "res://data/lab/card_impact"
const DEFAULT_PACK_ID: String = "track02_card_impact_v1"
const SUPPORTED_SIMULATION_MODES: Array[String] = ["card_impact_v1", "card_impact_v2"]
const REQUIRED_PACK_FIELDS: PackedStringArray = ["pack_id", "schema_version", "simulation_mode", "card_sets", "case_templates", "components", "gate_policy"]

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
		errors.append("pack simulation_mode must be one of `card_impact_v1,card_impact_v2`")
	for object_field: String in ["card_sets", "case_templates", "components", "gate_policy"]:
		if pack.has(object_field) and typeof(pack.get(object_field)) != TYPE_DICTIONARY:
			errors.append("pack `%s` must be an object" % object_field)
	if not errors.is_empty():
		return {"ok": false, "message": "Invalid card impact pack: %s." % "; ".join(errors), "path": path, "errors": errors}
	return {"ok": true, "path": path, "pack": pack}
