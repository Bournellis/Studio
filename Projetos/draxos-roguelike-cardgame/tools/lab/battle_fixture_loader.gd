extends RefCounted

const DEFAULT_BATTLE_DIR: String = "res://data/lab/battles"
const DEFAULT_PACK_ID: String = "track02_battle_core_v1"
const EXPECTED_SIMULATION_MODE: String = "battle_engine_v1"
const REQUIRED_PACK_FIELDS: PackedStringArray = ["pack_id", "schema_version", "simulation_mode", "cases"]
const REQUIRED_CASE_FIELDS: PackedStringArray = ["id", "name", "tags", "class_id", "encounter_id", "seed", "policy_id", "deck", "config", "turn_limit", "expectations"]
const ALLOWED_CONFIG_KEYS: PackedStringArray = [
	"player_health",
	"mana_per_turn",
	"max_hand_size",
	"class_passive_unlocked",
	"class_active_unlocked",
	"class_active_level",
	"relic_ids",
	"shuffle_deck",
	"shuffle_seed"
]

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
		return "%s/%s" % [DEFAULT_BATTLE_DIR, value]
	return value

static func load_pack(path_or_id: String = "") -> Dictionary:
	var result: Dictionary = load_pack_result(path_or_id)
	if not bool(result.get("ok", false)):
		return {}
	return Dictionary(result.get("pack", {}))

static func load_pack_result(path_or_id: String = "") -> Dictionary:
	var resolved_path: String = resolve_pack_path(path_or_id)
	if not FileAccess.file_exists(resolved_path):
		return {"ok": false, "message": "Battle pack not found: %s." % resolved_path, "path": resolved_path}
	var text: String = FileAccess.get_file_as_string(resolved_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Battle pack is not a JSON object: %s." % resolved_path, "path": resolved_path}
	var validation: Dictionary = validate_pack_result(Dictionary(parsed), resolved_path)
	if not bool(validation.get("ok", false)):
		return validation
	return {"ok": true, "path": resolved_path, "pack": Dictionary(parsed)}

static func validate_pack_result(pack: Dictionary, path: String = "") -> Dictionary:
	var errors: Array[String] = []
	for field: String in REQUIRED_PACK_FIELDS:
		if not pack.has(field):
			errors.append("pack missing `%s`" % field)
	if pack.has("simulation_mode") and str(pack.get("simulation_mode", "")) != EXPECTED_SIMULATION_MODE:
		errors.append("pack simulation_mode must be `%s`" % EXPECTED_SIMULATION_MODE)
	if pack.has("cases") and typeof(pack.get("cases")) != TYPE_ARRAY:
		errors.append("pack `cases` must be an array")
	var case_ids: Dictionary = {}
	var cases: Array = Array(pack.get("cases", []))
	for index: int in range(cases.size()):
		var case_value: Variant = cases[index]
		if typeof(case_value) != TYPE_DICTIONARY:
			errors.append("case[%d] must be an object" % index)
			continue
		var case_data: Dictionary = Dictionary(case_value)
		for field: String in REQUIRED_CASE_FIELDS:
			if not case_data.has(field):
				errors.append("case[%d] missing `%s`" % [index, field])
		var case_id: String = str(case_data.get("id", ""))
		if case_id == "":
			continue
		if case_ids.has(case_id):
			errors.append("duplicate case id `%s`" % case_id)
		case_ids[case_id] = true
		if case_data.has("tags") and typeof(case_data.get("tags")) != TYPE_ARRAY:
			errors.append("case `%s` tags must be an array" % case_id)
		if case_data.has("seed") and typeof(case_data.get("seed")) not in [TYPE_INT, TYPE_FLOAT]:
			errors.append("case `%s` seed must be numeric" % case_id)
		if case_data.has("deck") and typeof(case_data.get("deck")) != TYPE_ARRAY:
			errors.append("case `%s` deck must be an array" % case_id)
		if case_data.has("config") and typeof(case_data.get("config")) != TYPE_DICTIONARY:
			errors.append("case `%s` config must be an object" % case_id)
		if case_data.has("expectations") and typeof(case_data.get("expectations")) != TYPE_DICTIONARY:
			errors.append("case `%s` expectations must be an object" % case_id)
		if case_data.has("turn_limit") and typeof(case_data.get("turn_limit")) not in [TYPE_INT, TYPE_FLOAT]:
			errors.append("case `%s` turn_limit must be numeric" % case_id)
		_validate_config_keys(errors, case_id, Dictionary(case_data.get("config", {})))
		if case_data.has("encounter_override") and typeof(case_data.get("encounter_override")) != TYPE_DICTIONARY:
			errors.append("case `%s` encounter_override must be an object" % case_id)
	if not errors.is_empty():
		return {"ok": false, "message": "Invalid battle pack: %s." % "; ".join(errors), "path": path, "errors": errors}
	return {"ok": true, "path": path, "pack": pack}

static func cases_for(pack: Dictionary, case_id: String = "", tags: PackedStringArray = PackedStringArray()) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for case_value: Variant in Array(pack.get("cases", [])):
		var case_data: Dictionary = Dictionary(case_value)
		if case_id != "" and str(case_data.get("id", "")) != case_id:
			continue
		if not tags.is_empty() and not _case_has_any_tag(case_data, tags):
			continue
		result.append(case_data)
	return result

static func _validate_config_keys(errors: Array[String], case_id: String, config: Dictionary) -> void:
	for key: Variant in config.keys():
		var key_string: String = str(key)
		if not ALLOWED_CONFIG_KEYS.has(key_string):
			errors.append("case `%s` config key `%s` is not allowed" % [case_id, key_string])

static func _case_has_any_tag(case_data: Dictionary, tags: PackedStringArray) -> bool:
	var case_tags: Array = Array(case_data.get("tags", []))
	for filter_tag: String in tags:
		for case_tag: Variant in case_tags:
			if str(case_tag) == filter_tag:
				return true
	return false
