extends RefCounted

const DEFAULT_DESIGN_DIR: String = "res://data/lab/design"
const DEFAULT_PROPOSAL_DIR: String = "res://data/lab/design/proposals"
const DEFAULT_PACK_ID: String = "design_lab_sample_v1"
const REGISTRY_PATH: String = "res://data/lab/design/mechanic_registry.json"
const SCORING_PROFILES_PATH: String = "res://data/lab/design/scoring_profiles.json"
const REQUIRED_PACK_FIELDS: PackedStringArray = ["pack_id", "schema_version", "design_goal", "notes", "mechanics", "scoring_profile", "promotion_policy", "encounter_contexts"]
const REQUIRED_CARD_FIELDS: PackedStringArray = ["owner", "role", "design_intent", "timing", "valid_targets", "mechanics"]
const VALID_OWNERS: Array[String] = ["player", "enemy"]

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
		return "%s/%s" % [DEFAULT_PROPOSAL_DIR, value]
	return value

static func load_pack(path_or_id: String = "") -> Dictionary:
	var result: Dictionary = load_pack_result(path_or_id)
	if not bool(result.get("ok", false)):
		return {}
	return Dictionary(result.get("pack", {}))

static func load_pack_result(path_or_id: String = "") -> Dictionary:
	var registry_result: Dictionary = load_registry_result()
	if not bool(registry_result.get("ok", false)):
		return registry_result
	var resolved_path: String = resolve_pack_path(path_or_id)
	if not FileAccess.file_exists(resolved_path):
		return {"ok": false, "message": "Design proposal pack not found: %s." % resolved_path, "path": resolved_path}
	var text: String = FileAccess.get_file_as_string(resolved_path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Design proposal pack is not a JSON object: %s." % resolved_path, "path": resolved_path}
	var validation: Dictionary = validate_pack_result(Dictionary(parsed), Dictionary(registry_result.get("registry", {})), resolved_path)
	if not bool(validation.get("ok", false)):
		return validation
	return {"ok": true, "path": resolved_path, "pack": Dictionary(parsed), "registry": Dictionary(registry_result.get("registry", {}))}

static func load_registry_result(path: String = REGISTRY_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "message": "Design mechanic registry not found: %s." % path, "path": path}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Design mechanic registry is not a JSON object: %s." % path, "path": path}
	var registry: Dictionary = Dictionary(parsed)
	var by_id: Dictionary = {}
	for entry_value: Variant in Array(registry.get("mechanics", [])):
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var entry: Dictionary = Dictionary(entry_value)
		var mechanic_id: String = str(entry.get("mechanic_id", ""))
		if mechanic_id != "":
			by_id[mechanic_id] = entry
	registry["by_id"] = by_id
	return {"ok": true, "path": path, "registry": registry}

static func load_profiles_result(path: String = SCORING_PROFILES_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"ok": false, "message": "Design scoring profiles not found: %s." % path, "path": path}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Design scoring profiles are not a JSON object: %s." % path, "path": path}
	var payload: Dictionary = Dictionary(parsed)
	var by_id: Dictionary = {}
	for entry_value: Variant in Array(payload.get("profiles", [])):
		if typeof(entry_value) != TYPE_DICTIONARY:
			continue
		var profile: Dictionary = Dictionary(entry_value)
		var profile_id: String = str(profile.get("profile_id", ""))
		if profile_id != "":
			by_id[profile_id] = profile
	payload["by_id"] = by_id
	return {"ok": true, "path": path, "profiles": payload}

static func profile_by_id(profiles_payload: Dictionary, profile_id: String) -> Dictionary:
	var by_id: Dictionary = Dictionary(profiles_payload.get("by_id", {}))
	if by_id.has(profile_id):
		return Dictionary(by_id.get(profile_id, {}))
	if by_id.has("default"):
		return Dictionary(by_id.get("default", {}))
	return {}

static func validate_pack_result(pack: Dictionary, registry: Dictionary, path: String = "") -> Dictionary:
	var errors: Array[String] = []
	for field: String in REQUIRED_PACK_FIELDS:
		if not pack.has(field):
			errors.append("pack missing `%s`" % field)
	if not pack.has("cards") and not pack.has("enemy_cards"):
		errors.append("pack needs at least `cards` or `enemy_cards`")
	for object_field: String in ["promotion_policy"]:
		if pack.has(object_field) and typeof(pack.get(object_field)) != TYPE_DICTIONARY:
			errors.append("pack `%s` must be an object" % object_field)
	for array_field: String in ["mechanics", "cards", "enemy_cards", "encounter_contexts"]:
		if pack.has(array_field) and typeof(pack.get(array_field)) != TYPE_ARRAY:
			errors.append("pack `%s` must be an array" % array_field)
	var registry_by_id: Dictionary = Dictionary(registry.get("by_id", {}))
	errors.append_array(_validate_pack_mechanics(pack, registry_by_id))
	var contexts: Array = Array(pack.get("encounter_contexts", []))
	var context_ids: Array[String] = []
	for context_value: Variant in contexts:
		if typeof(context_value) != TYPE_DICTIONARY:
			continue
		var context_id: String = str(Dictionary(context_value).get("id", ""))
		if context_id != "":
			context_ids.append(context_id)
	var index: int = 0
	for card: Dictionary in card_specs(pack):
		errors.append_array(_validate_card_spec(card, index, registry_by_id, context_ids))
		index += 1
	if not errors.is_empty():
		return {"ok": false, "message": "Invalid design proposal pack: %s." % "; ".join(errors), "path": path, "errors": errors}
	return {"ok": true, "path": path, "pack": pack}

static func card_specs(pack: Dictionary) -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	for value: Variant in Array(pack.get("cards", [])):
		if typeof(value) == TYPE_DICTIONARY:
			var spec: Dictionary = Dictionary(value).duplicate(true)
			spec["owner"] = str(spec.get("owner", "player"))
			specs.append(spec)
	for value: Variant in Array(pack.get("enemy_cards", [])):
		if typeof(value) == TYPE_DICTIONARY:
			var spec: Dictionary = Dictionary(value).duplicate(true)
			spec["owner"] = str(spec.get("owner", "enemy"))
			specs.append(spec)
	return specs

static func filtered_card_specs(pack: Dictionary, card_filter: PackedStringArray) -> Array[Dictionary]:
	var mode: String = "all"
	if card_filter.size() == 1:
		mode = str(card_filter[0])
	if mode == "all" or card_filter.is_empty():
		return card_specs(pack)
	var wanted: Dictionary = {}
	for card_id: String in card_filter:
		wanted[card_id] = true
	var result: Array[Dictionary] = []
	for spec: Dictionary in card_specs(pack):
		var spec_id: String = card_spec_id(spec)
		if wanted.has(spec_id) or wanted.has(str(spec.get("new_card_id", ""))) or wanted.has(str(spec.get("extends_card_id", ""))):
			result.append(spec)
	return result

static func card_spec_id(spec: Dictionary) -> String:
	var value: String = str(spec.get("id", ""))
	if value != "":
		return value
	value = str(spec.get("new_card_id", ""))
	if value != "":
		return value
	return str(spec.get("extends_card_id", ""))

static func mechanic_entries_for_card(spec: Dictionary, registry: Dictionary) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var by_id: Dictionary = Dictionary(registry.get("by_id", {}))
	for mechanic_value: Variant in Array(spec.get("mechanics", [])):
		var mechanic_id: String = str(mechanic_value)
		if by_id.has(mechanic_id):
			entries.append(Dictionary(by_id.get(mechanic_id, {})))
	return entries

static func blocked_mechanics_for_card(spec: Dictionary, registry: Dictionary) -> Array[Dictionary]:
	var blocked: Array[Dictionary] = []
	for entry: Dictionary in mechanic_entries_for_card(spec, registry):
		var status: String = str(entry.get("status", ""))
		if status == "blocked_missing_engine_support":
			blocked.append(entry)
	return blocked

static func _validate_pack_mechanics(pack: Dictionary, registry_by_id: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	for mechanic_value: Variant in Array(pack.get("mechanics", [])):
		if typeof(mechanic_value) != TYPE_DICTIONARY:
			errors.append("pack mechanics entries must be objects")
			continue
		var mechanic_id: String = str(Dictionary(mechanic_value).get("mechanic_id", ""))
		if mechanic_id == "":
			errors.append("pack mechanics entry missing `mechanic_id`")
		elif not registry_by_id.has(mechanic_id):
			errors.append("mechanic `%s` is not present in mechanic_registry" % mechanic_id)
	return errors

static func _validate_card_spec(spec: Dictionary, index: int, registry_by_id: Dictionary, context_ids: Array[String]) -> Array[String]:
	var errors: Array[String] = []
	var card_id: String = card_spec_id(spec)
	if card_id == "":
		errors.append("card %d needs `id`, `new_card_id` or `extends_card_id`" % index)
	for field: String in REQUIRED_CARD_FIELDS:
		if not spec.has(field):
			errors.append("card `%s` missing `%s`" % [card_id, field])
	var owner: String = str(spec.get("owner", ""))
	if not VALID_OWNERS.has(owner):
		errors.append("card `%s` owner must be player or enemy" % card_id)
	if str(spec.get("role", "")) == "":
		errors.append("card `%s` needs role" % card_id)
	if str(spec.get("design_intent", "")) == "":
		errors.append("card `%s` needs design_intent" % card_id)
	if Array(spec.get("valid_targets", [])).is_empty():
		errors.append("card `%s` needs valid_targets" % card_id)
	if Array(spec.get("mechanics", [])).is_empty():
		errors.append("card `%s` needs mechanics" % card_id)
	for mechanic_value: Variant in Array(spec.get("mechanics", [])):
		var mechanic_id: String = str(mechanic_value)
		if not registry_by_id.has(mechanic_id):
			errors.append("card `%s` references missing mechanic `%s`" % [card_id, mechanic_id])
	if not spec.has("variant_space") or typeof(spec.get("variant_space")) != TYPE_DICTIONARY or Dictionary(spec.get("variant_space", {})).is_empty():
		errors.append("card `%s` needs non-empty variant_space" % card_id)
	var card_contexts: Array = Array(spec.get("context_ids", []))
	if card_contexts.is_empty() and context_ids.is_empty():
		errors.append("card `%s` needs at least one context" % card_id)
	for context_value: Variant in card_contexts:
		var context_id: String = str(context_value)
		if context_id != "" and not context_ids.has(context_id):
			errors.append("card `%s` references unknown context `%s`" % [card_id, context_id])
	return errors
