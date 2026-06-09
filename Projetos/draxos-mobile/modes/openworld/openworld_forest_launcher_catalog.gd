class_name OpenworldForestLauncherCatalog
extends RefCounted

const WorldCatalogScript := preload("res://modes/openworld/openworld_world_catalog.gd")

const CATALOG_PATH := "res://data/definitions/openworld/forest_launcher_v1.json"
const REQUIRED_FIELDS := [
	"entry_id",
	"label",
	"action_id",
	"visual_kind",
	"position",
	"interaction_radius",
]

static func catalog_data(path: String = CATALOG_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var raw := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(raw)
	if not parsed is Dictionary:
		return {}
	return Dictionary(parsed)

static func entries(path: String = CATALOG_PATH) -> Array[Dictionary]:
	return entries_from_data(catalog_data(path))

static func entries_from_data(data: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var raw_entries := _as_array(data.get("entries", []))
	for value: Variant in raw_entries:
		if not value is Dictionary:
			continue
		var entry := Dictionary(value)
		if not bool(validate_entry(entry).get("ok", false)):
			continue
		result.append(normalize_entry(entry))
	return result

static func entry_by_id(entry_id: String, path: String = CATALOG_PATH) -> Dictionary:
	var normalized_id := entry_id.strip_edges()
	for entry: Dictionary in entries(path):
		if str(entry.get("entry_id", "")) == normalized_id:
			return entry.duplicate(true)
	return {}

static func validate_entry(entry: Dictionary) -> Dictionary:
	for field: String in REQUIRED_FIELDS:
		if not entry.has(field):
			return {"ok": false, "reason": "missing_%s" % field}
	var entry_id := str(entry.get("entry_id", "")).strip_edges()
	var label := str(entry.get("label", "")).strip_edges()
	var action_id := str(entry.get("action_id", "")).strip_edges()
	var visual_kind := str(entry.get("visual_kind", "")).strip_edges()
	if entry_id == "":
		return {"ok": false, "reason": "empty_entry_id"}
	if label == "":
		return {"ok": false, "reason": "empty_label"}
	if action_id == "":
		return {"ok": false, "reason": "empty_action_id"}
	if visual_kind == "":
		return {"ok": false, "reason": "empty_visual_kind"}
	if not entry.get("position") is Dictionary:
		return {"ok": false, "reason": "invalid_position"}
	var position := Dictionary(entry.get("position", {}))
	if not position.has("x") or not position.has("y"):
		return {"ok": false, "reason": "invalid_position"}
	if float(entry.get("interaction_radius", 0.0)) <= 0.0:
		return {"ok": false, "reason": "invalid_interaction_radius"}
	return {"ok": true}

static func normalize_entry(entry: Dictionary) -> Dictionary:
	var entry_id := str(entry.get("entry_id", "")).strip_edges()
	var position := Dictionary(entry.get("position", {}))
	var label := str(entry.get("label", "")).strip_edges()
	return {
		"id": "launcher_%s" % entry_id,
		"kind": WorldCatalogScript.KIND_LAUNCHER,
		"entry_id": entry_id,
		"display_name": label,
		"label": label,
		"action_id": str(entry.get("action_id", "")).strip_edges(),
		"visual_kind": str(entry.get("visual_kind", "")).strip_edges(),
		"position": Vector2(float(position.get("x", 0.0)), float(position.get("y", 0.0))),
		"interaction_radius": float(entry.get("interaction_radius", 0.0)),
		"blocks_player": bool(entry.get("blocks_player", false)),
		"collectible": false,
		"sort_offset": float(entry.get("sort_offset", 18.0)),
		"public": bool(entry.get("public", true)),
		"visual_size": _visual_size_for(str(entry.get("visual_kind", "")).strip_edges()),
	}

static func _visual_size_for(visual_kind: String) -> Vector2:
	match visual_kind:
		"arena_gate":
			return Vector2(86, 84)
		"workbench":
			return Vector2(84, 58)
		"shop_stall":
			return Vector2(86, 66)
		"social_totem":
			return Vector2(58, 86)
		"profile_shrine":
			return Vector2(64, 82)
		_:
			return Vector2(64, 64)

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
