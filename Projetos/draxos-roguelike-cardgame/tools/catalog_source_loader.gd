class_name CatalogSourceLoader
extends RefCounted

const SLICE_CATALOG_PATH: String = "res://data/definitions/slice_catalog.json"
const VISUAL_ASSETS_PATH: String = "res://data/definitions/visual_assets.json"
const DOMAIN_ORDER: Array[String] = [
	"meta",
	"classes",
	"cards",
	"enemies",
	"rewards",
	"relics",
	"encounters",
	"run_map",
	"keywords",
	"visuals"
]

const TOP_LEVEL_DOMAIN_KEYS: Dictionary = {
	"classes": ["player_hero", "class_options"],
	"cards": ["cards", "starter_deck"],
	"enemies": ["enemy_hero", "enemy_script"],
	"rewards": ["first_npc_reward_card", "reward_card", "npc_reward_choices"],
	"encounters": ["default_encounter_id", "encounters", "boards"],
	"run_map": ["run_map"]
}

const TRACK_CONTRACT_DOMAIN_KEYS: Dictionary = {
	"meta": ["id", "status", "save_version", "snapshot_version"],
	"classes": ["stat_caps", "max_health"],
	"enemies": ["enemy_card_galleries", "enemy_intent_definitions"],
	"rewards": ["reward_categories", "reward_rarity", "reward_card_copy_rules", "reward_category_state_schema", "shop_state_schema", "shop_prices", "reward_schedule", "track_02_player_card_rewards"],
	"relics": ["relic_state_schema", "relics"],
	"encounters": ["board_effect_definitions"],
	"run_map": ["route"],
	"keywords": ["keyword_definitions", "status_definitions"],
	"visuals": ["tooltip_surfaces"]
}

func load_catalog_source() -> Dictionary:
	var raw_definition: Dictionary = load_raw_catalog_definition()
	if raw_definition.is_empty():
		return {"ok": false, "message": "Failed to load slice catalog definition."}
	var domains: Dictionary = split_catalog_definition(raw_definition)
	return {
		"ok": true,
		"message": "Loaded slice catalog source.",
		"source_mode": "single_json",
		"source_paths": PackedStringArray([SLICE_CATALOG_PATH]),
		"domains": domains,
		"definition": assemble_catalog_definition(domains)
	}

func load_catalog_definition() -> Dictionary:
	var source: Dictionary = load_catalog_source()
	if not bool(source.get("ok", false)):
		return {}
	return Dictionary(source.get("definition", {}))

func load_raw_catalog_definition() -> Dictionary:
	return _load_json_dictionary(SLICE_CATALOG_PATH)

func load_visual_assets_definition() -> Dictionary:
	return _load_json_dictionary(VISUAL_ASSETS_PATH)

func split_catalog_definition(definition: Dictionary) -> Dictionary:
	var domains: Dictionary = {}
	var assigned_top_level_keys: Dictionary = {}
	var assigned_contract_keys: Dictionary = {}
	for domain: String in DOMAIN_ORDER:
		domains[domain] = {"top_level": {}, "track_contract": {}}
		for key: String in Array(TOP_LEVEL_DOMAIN_KEYS.get(domain, [])):
			if definition.has(key):
				domains[domain]["top_level"][key] = _deep_duplicate(definition[key])
				assigned_top_level_keys[key] = true
		var contract: Dictionary = Dictionary(definition.get("track_contract", {}))
		for key: String in Array(TRACK_CONTRACT_DOMAIN_KEYS.get(domain, [])):
			if contract.has(key):
				domains[domain]["track_contract"][key] = _deep_duplicate(contract[key])
				assigned_contract_keys[key] = true
	for key: Variant in definition.keys():
		var key_string: String = str(key)
		if key_string == "track_contract" or bool(assigned_top_level_keys.get(key_string, false)):
			continue
		domains["meta"]["top_level"][key_string] = _deep_duplicate(definition[key])
	var contract_data: Dictionary = Dictionary(definition.get("track_contract", {}))
	for key: Variant in contract_data.keys():
		var key_string: String = str(key)
		if bool(assigned_contract_keys.get(key_string, false)):
			continue
		domains["meta"]["track_contract"][key_string] = _deep_duplicate(contract_data[key])
	return domains

func assemble_catalog_definition(domains: Dictionary) -> Dictionary:
	var definition: Dictionary = {}
	var track_contract: Dictionary = {}
	for domain: String in DOMAIN_ORDER:
		var domain_data: Dictionary = Dictionary(domains.get(domain, {}))
		var top_level: Dictionary = Dictionary(domain_data.get("top_level", {}))
		var contract: Dictionary = Dictionary(domain_data.get("track_contract", {}))
		for key: Variant in top_level.keys():
			definition[str(key)] = _deep_duplicate(top_level[key])
		for key: Variant in contract.keys():
			track_contract[str(key)] = _deep_duplicate(contract[key])
	if not track_contract.is_empty():
		definition["track_contract"] = track_contract
	return definition

func domain_summary(domains: Dictionary, visual_assets_definition: Dictionary = {}) -> Dictionary:
	var summary: Dictionary = {}
	for domain: String in DOMAIN_ORDER:
		var domain_data: Dictionary = Dictionary(domains.get(domain, {}))
		var top_level: Dictionary = Dictionary(domain_data.get("top_level", {}))
		var track_contract: Dictionary = Dictionary(domain_data.get("track_contract", {}))
		summary[domain] = {
			"top_level_keys": _sorted_string_array(top_level.keys()),
			"track_contract_keys": _sorted_string_array(track_contract.keys()),
			"item_count": _domain_item_count(top_level) + _domain_item_count(track_contract)
		}
	if not visual_assets_definition.is_empty():
		var visual_summary: Dictionary = Dictionary(summary.get("visuals", {}))
		visual_summary["visual_asset_entries"] = _domain_item_count(visual_assets_definition)
		summary["visuals"] = visual_summary
	return summary

static func stable_definition_hash(value: Variant) -> String:
	return stable_definition_string(value).sha256_text()

static func stable_definition_string(value: Variant) -> String:
	match typeof(value):
		TYPE_DICTIONARY:
			var data: Dictionary = Dictionary(value)
			var keys: Array = data.keys()
			keys.sort()
			var parts: PackedStringArray = PackedStringArray()
			for key: Variant in keys:
				parts.append("%s:%s" % [stable_definition_string(str(key)), stable_definition_string(data[key])])
			return "{%s}" % ",".join(parts)
		TYPE_ARRAY:
			var items: PackedStringArray = PackedStringArray()
			for item: Variant in Array(value):
				items.append(stable_definition_string(item))
			return "[%s]" % ",".join(items)
		TYPE_STRING:
			return "\"%s\"" % escape_stable_json_string(str(value))
		TYPE_BOOL:
			return "true" if bool(value) else "false"
		TYPE_INT, TYPE_FLOAT:
			return str(value)
		TYPE_NIL:
			return "null"
	return "\"%s\"" % escape_stable_json_string(str(value))

static func escape_stable_json_string(value: String) -> String:
	return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")

func _load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file_text: String = FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(file_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return Dictionary(parsed)

func _deep_duplicate(value: Variant) -> Variant:
	if typeof(value) == TYPE_DICTIONARY or typeof(value) == TYPE_ARRAY:
		return value.duplicate(true)
	return value

func _sorted_string_array(keys: Array) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var strings: Array[String] = []
	for key: Variant in keys:
		strings.append(str(key))
	strings.sort()
	for key: String in strings:
		result.append(key)
	return result

func _domain_item_count(data: Dictionary) -> int:
	var count: int = 0
	for value: Variant in data.values():
		match typeof(value):
			TYPE_ARRAY:
				count += Array(value).size()
			TYPE_DICTIONARY:
				count += max(1, Dictionary(value).size())
			_:
				count += 1
	return count
