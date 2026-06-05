extends RefCounted

const DEFAULT_SCENARIO_DIR: String = "res://data/lab/scenarios"
const DEFAULT_PACK_ID: String = "track02_core_v1"
const REQUIRED_PACK_FIELDS: PackedStringArray = ["pack_id", "schema_version", "simulation_mode", "scenarios"]
const REQUIRED_SCENARIO_FIELDS: PackedStringArray = ["id", "name", "tags", "class_id", "seed", "policy_id", "focus", "expectations"]

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
		return "%s/%s" % [DEFAULT_SCENARIO_DIR, value]
	return value

static func load_pack(path_or_id: String = "") -> Dictionary:
	var result: Dictionary = load_pack_result(path_or_id)
	if not bool(result.get("ok", false)):
		return {}
	return Dictionary(result.get("pack", {}))

static func load_pack_result(path_or_id: String = "") -> Dictionary:
	var resolved_path: String = resolve_pack_path(path_or_id)
	if not FileAccess.file_exists(resolved_path):
		return {"ok": false, "message": "Scenario pack not found: %s." % resolved_path, "path": resolved_path}
	var text: String = FileAccess.get_file_as_string(resolved_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Scenario pack is not a JSON object: %s." % resolved_path, "path": resolved_path}
	var validation: Dictionary = validate_pack_result(Dictionary(parsed), resolved_path)
	if not bool(validation.get("ok", false)):
		return validation
	return {"ok": true, "path": resolved_path, "pack": Dictionary(parsed)}

static func validate_pack_result(pack: Dictionary, path: String = "") -> Dictionary:
	var errors: Array[String] = []
	for field: String in REQUIRED_PACK_FIELDS:
		if not pack.has(field):
			errors.append("pack missing `%s`" % field)
	if pack.has("scenarios") and typeof(pack.get("scenarios")) != TYPE_ARRAY:
		errors.append("pack `scenarios` must be an array")
	var scenario_ids: Dictionary = {}
	var scenarios: Array = Array(pack.get("scenarios", []))
	for index: int in range(scenarios.size()):
		var scenario_value: Variant = scenarios[index]
		if typeof(scenario_value) != TYPE_DICTIONARY:
			errors.append("scenario[%d] must be an object" % index)
			continue
		var scenario: Dictionary = Dictionary(scenario_value)
		for field: String in REQUIRED_SCENARIO_FIELDS:
			if not scenario.has(field):
				errors.append("scenario[%d] missing `%s`" % [index, field])
		var scenario_id: String = str(scenario.get("id", ""))
		if scenario_id == "":
			continue
		if scenario_ids.has(scenario_id):
			errors.append("duplicate scenario id `%s`" % scenario_id)
		scenario_ids[scenario_id] = true
		if scenario.has("tags") and typeof(scenario.get("tags")) != TYPE_ARRAY:
			errors.append("scenario `%s` tags must be an array" % scenario_id)
		if scenario.has("seed") and typeof(scenario.get("seed")) not in [TYPE_INT, TYPE_FLOAT]:
			errors.append("scenario `%s` seed must be numeric" % scenario_id)
		if scenario.has("expectations") and typeof(scenario.get("expectations")) != TYPE_DICTIONARY:
			errors.append("scenario `%s` expectations must be an object" % scenario_id)
	if not errors.is_empty():
		return {"ok": false, "message": "Invalid scenario pack: %s." % "; ".join(errors), "path": path, "errors": errors}
	return {"ok": true, "path": path, "pack": pack}

static func scenarios_for(pack: Dictionary, scenario_id: String = "", tags: PackedStringArray = PackedStringArray()) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for scenario_value: Variant in Array(pack.get("scenarios", [])):
		var scenario: Dictionary = Dictionary(scenario_value)
		if scenario_id != "" and str(scenario.get("id", "")) != scenario_id:
			continue
		if not tags.is_empty() and not _scenario_has_any_tag(scenario, tags):
			continue
		result.append(scenario)
	return result

static func _scenario_has_any_tag(scenario: Dictionary, tags: PackedStringArray) -> bool:
	var scenario_tags: Array = Array(scenario.get("tags", []))
	for filter_tag: String in tags:
		for scenario_tag: Variant in scenario_tags:
			if str(scenario_tag) == filter_tag:
				return true
	return false
