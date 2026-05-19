class_name ContentGenerator
extends RefCounted

const CatalogScript = preload("res://data/resources/draxos_mobile_catalog.gd")

const SCHEMA_VERSION: int = 1
const DEFINITIONS_DIR: String = "res://data/definitions"
const GENERATED_DIR: String = "res://data/generated"
const CATALOG_PATH: String = "res://data/generated/draxos_mobile_catalog.tres"

const EXPECTED_DEFINITIONS: Array = [
	{"file": "spells.json", "collection": "spells"},
	{"file": "pets.json", "collection": "pets"},
	{"file": "passives.json", "collection": "passives"},
	{"file": "weapons.json", "collection": "weapons"},
	{"file": "base_structures.json", "collection": "base_structures"},
	{"file": "bot_builds.json", "collection": "bot_builds"},
	{"file": "power_bands.json", "collection": "power_bands"},
	{"file": "battle_fixtures.json", "collection": "battle_fixtures"},
	{"file": "rewards.json", "collection": "rewards"}
]

const COMMON_FIELDS: Array[String] = [
	"id",
	"display_name",
	"description",
	"version",
	"enabled",
	"tags"
]

func generate_all() -> Dictionary:
	_ensure_output_dirs()
	var collections: Dictionary = {}
	var source_files: Array[String] = []

	for expected: Dictionary in EXPECTED_DEFINITIONS:
		var file_name: String = str(expected.get("file", ""))
		var collection_id: String = str(expected.get("collection", ""))
		var result: Dictionary = _load_definition_file(file_name, collection_id)
		if not bool(result.get("ok", false)):
			return result
		collections[collection_id] = Array(result.get("items", []))
		source_files.append("%s/%s" % [DEFINITIONS_DIR, file_name])

	var reference_result: Dictionary = _validate_references(collections)
	if not bool(reference_result.get("ok", false)):
		return reference_result

	var catalog = CatalogScript.new()
	catalog.schema_version = SCHEMA_VERSION
	catalog.generated_from = PackedStringArray(source_files)
	catalog.collections = collections

	var save_error: Error = ResourceSaver.save(catalog, CATALOG_PATH)
	if save_error != OK:
		return {"ok": false, "message": "Failed to save generated catalog at %s." % CATALOG_PATH}

	return {
		"ok": true,
		"message": "Generated DraxosMobile MVP content catalog.",
		"counts": _collection_counts(collections)
	}

func validate_current_catalog() -> Dictionary:
	var result: Dictionary = generate_all()
	if not bool(result.get("ok", false)):
		return result
	var catalog = ResourceLoader.load(CATALOG_PATH, "", ResourceLoader.CACHE_MODE_REPLACE)
	if catalog == null:
		return {"ok": false, "message": "Generated catalog could not be loaded."}
	if catalog.schema_version != SCHEMA_VERSION:
		return {"ok": false, "message": "Generated catalog schema version mismatch."}
	for expected: Dictionary in EXPECTED_DEFINITIONS:
		var collection_id: String = str(expected.get("collection", ""))
		if catalog.get_collection(collection_id).is_empty():
			return {"ok": false, "message": "Generated catalog has empty collection: %s." % collection_id}
	if not catalog.has_item("battle_fixtures", "mvp_training_battle"):
		return {"ok": false, "message": "Generated catalog is missing MVP battle fixture."}
	return {"ok": true, "message": "Generated catalog contract is valid."}

func expected_collection_ids() -> PackedStringArray:
	var ids: Array[String] = []
	for expected: Dictionary in EXPECTED_DEFINITIONS:
		ids.append(str(expected.get("collection", "")))
	return PackedStringArray(ids)

func _load_definition_file(file_name: String, expected_collection: String) -> Dictionary:
	var path: String = "%s/%s" % [DEFINITIONS_DIR, file_name]
	if not FileAccess.file_exists(path):
		return {"ok": false, "message": "Missing definition file: %s." % path}

	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "message": "Definition file must be a JSON object: %s." % path}

	var data: Dictionary = Dictionary(parsed)
	if int(data.get("schema_version", 0)) != SCHEMA_VERSION:
		return {"ok": false, "message": "%s must use schema_version %d." % [file_name, SCHEMA_VERSION]}
	if str(data.get("collection", "")) != expected_collection:
		return {"ok": false, "message": "%s must declare collection %s." % [file_name, expected_collection]}

	var items: Array = Array(data.get("items", []))
	if items.is_empty():
		return {"ok": false, "message": "%s must contain at least one item." % file_name}

	var seen_ids: Dictionary = {}
	for item_variant: Variant in items:
		if typeof(item_variant) != TYPE_DICTIONARY:
			return {"ok": false, "message": "%s contains a non-object item." % file_name}
		var item: Dictionary = Dictionary(item_variant)
		var item_result: Dictionary = _validate_common_item(file_name, item)
		if not bool(item_result.get("ok", false)):
			return item_result
		var item_id: String = str(item.get("id", ""))
		if seen_ids.has(item_id):
			return {"ok": false, "message": "%s contains duplicate id %s." % [file_name, item_id]}
		seen_ids[item_id] = true

	return {"ok": true, "items": items}

func _validate_common_item(file_name: String, item: Dictionary) -> Dictionary:
	for field: String in COMMON_FIELDS:
		if not item.has(field):
			return {"ok": false, "message": "%s item is missing %s." % [file_name, field]}
	if str(item.get("id", "")).strip_edges() == "":
		return {"ok": false, "message": "%s item has empty id." % file_name}
	if str(item.get("display_name", "")).strip_edges() == "":
		return {"ok": false, "message": "%s item %s has empty display_name." % [file_name, str(item.get("id", ""))]}
	if str(item.get("description", "")).strip_edges() == "":
		return {"ok": false, "message": "%s item %s has empty description." % [file_name, str(item.get("id", ""))]}
	if int(item.get("version", 0)) <= 0:
		return {"ok": false, "message": "%s item %s has invalid version." % [file_name, str(item.get("id", ""))]}
	if typeof(item.get("enabled")) != TYPE_BOOL:
		return {"ok": false, "message": "%s item %s needs boolean enabled." % [file_name, str(item.get("id", ""))]}
	if typeof(item.get("tags")) != TYPE_ARRAY:
		return {"ok": false, "message": "%s item %s needs tags array." % [file_name, str(item.get("id", ""))]}
	return {"ok": true}

func _validate_references(collections: Dictionary) -> Dictionary:
	for bot_variant: Variant in Array(collections.get("bot_builds", [])):
		var bot: Dictionary = Dictionary(bot_variant)
		var weapon_id: String = str(bot.get("weapon_id", ""))
		if not _collection_has_id(collections, "weapons", weapon_id):
			return {"ok": false, "message": "Bot %s references missing weapon %s." % [str(bot.get("id", "")), weapon_id]}
		for spell_id: Variant in Array(bot.get("spell_ids", [])):
			if not _collection_has_id(collections, "spells", str(spell_id)):
				return {"ok": false, "message": "Bot %s references missing spell %s." % [str(bot.get("id", "")), str(spell_id)]}
		var pet_id: String = str(bot.get("pet_id", ""))
		if pet_id != "" and not _collection_has_id(collections, "pets", pet_id):
			return {"ok": false, "message": "Bot %s references missing pet %s." % [str(bot.get("id", "")), pet_id]}
		var passive_id: String = str(bot.get("passive_id", ""))
		if passive_id != "" and not _collection_has_id(collections, "passives", passive_id):
			return {"ok": false, "message": "Bot %s references missing passive %s." % [str(bot.get("id", "")), passive_id]}

	for fixture_variant: Variant in Array(collections.get("battle_fixtures", [])):
		var fixture: Dictionary = Dictionary(fixture_variant)
		var player_fixture: Dictionary = Dictionary(fixture.get("player_fixture", {}))
		if not _collection_has_id(collections, "weapons", str(player_fixture.get("weapon_type", ""))):
			return {"ok": false, "message": "Fixture %s references missing player weapon." % str(fixture.get("id", ""))}
		for spell_id: Variant in Array(player_fixture.get("spell_ids", [])):
			if not _collection_has_id(collections, "spells", str(spell_id)):
				return {"ok": false, "message": "Fixture %s references missing player spell %s." % [str(fixture.get("id", "")), str(spell_id)]}
		var opponent_fixture: Dictionary = Dictionary(fixture.get("opponent_fixture", {}))
		if not _collection_has_id(collections, "bot_builds", str(opponent_fixture.get("id", ""))):
			return {"ok": false, "message": "Fixture %s references missing bot." % str(fixture.get("id", ""))}
	return {"ok": true}

func _collection_has_id(collections: Dictionary, collection_id: String, item_id: String) -> bool:
	if item_id == "":
		return false
	for item_variant: Variant in Array(collections.get(collection_id, [])):
		var item: Dictionary = Dictionary(item_variant)
		if str(item.get("id", "")) == item_id:
			return true
	return false

func _collection_counts(collections: Dictionary) -> Dictionary:
	var counts: Dictionary = {}
	for key: Variant in collections.keys():
		counts[str(key)] = Array(collections.get(key, [])).size()
	return counts

func _ensure_output_dirs() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(GENERATED_DIR))
