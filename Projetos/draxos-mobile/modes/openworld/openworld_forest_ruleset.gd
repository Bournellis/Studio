class_name OpenworldForestRuleset
extends RefCounted

const RULESET_PATH := "res://data/definitions/openworld/forest_ruleset_v1.json"

static var _cached_ruleset: Dictionary = {}

static func data() -> Dictionary:
	if _cached_ruleset.is_empty():
		_cached_ruleset = _load_ruleset()
	return _cached_ruleset.duplicate(true)

static func mode_id() -> String:
	return str(data().get("mode_id", "openworld"))

static func slice_id() -> String:
	return str(data().get("slice_id", "forest"))

static func ruleset_id() -> String:
	return str(data().get("ruleset_id", "openworld_forest_ruleset_v1"))

static func ruleset_version() -> int:
	return int(data().get("ruleset_version", 1))

static func world_size() -> Vector2:
	return _vector2_from_dict(_world().get("size", {}), Vector2(960, 1400))

static func player_initial_position() -> Vector2:
	return _vector2_from_dict(_world().get("player_initial_position", {}), Vector2(220, 330))

static func chest_position() -> Vector2:
	return _vector2_from_dict(_world().get("chest_position", {}), Vector2(220, 250))

static func chest_radius() -> float:
	return float(_world().get("chest_radius", 88.0))

static func player_margin() -> float:
	return float(_world().get("player_margin", 28.0))

static func collection_radius() -> float:
	return float(_world().get("collection_radius", 40.0))

static func collection_cancel_radius() -> float:
	return float(_world().get("collection_cancel_radius", 52.0))

static func autosave_heartbeat_seconds() -> float:
	return float(_session().get("autosave_heartbeat_seconds", 15.0))

static func movement_value(key: String, fallback: float) -> float:
	return float(_movement().get(key, fallback))

static func item_definitions() -> Dictionary:
	var result: Dictionary = {}
	for item: Dictionary in _as_array(data().get("items", [])):
		var item_id := str(item.get("item_id", "")).strip_edges()
		if item_id == "":
			continue
		var definition := item.duplicate(true)
		definition.erase("item_id")
		result[item_id] = definition
	return result

static func recipes() -> Dictionary:
	var result: Dictionary = {}
	for recipe: Dictionary in _as_array(data().get("recipes", [])):
		var recipe_id := str(recipe.get("recipe_id", "")).strip_edges()
		if recipe_id == "":
			continue
		var definition := recipe.duplicate(true)
		definition.erase("recipe_id")
		result[recipe_id] = definition
	return result

static func resource_fixtures() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for node: Dictionary in _as_array(data().get("resource_nodes", [])):
		result.append({
			"node_id": str(node.get("node_id", "")),
			"item_id": str(node.get("item_id", "")),
			"position": _vector2_from_dict(node.get("position", {}), Vector2.ZERO),
			"quantity": maxi(1, int(node.get("quantity", 1))),
		})
	return result

static func obstacles() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for obstacle: Dictionary in _as_array(data().get("obstacles", [])):
		result.append({
			"id": str(obstacle.get("id", "")),
			"kind": str(obstacle.get("kind", "")),
			"display_name": str(obstacle.get("display_name", "")),
			"position": _vector2_from_dict(obstacle.get("position", {}), Vector2.ZERO),
			"visual_size": _vector2_from_dict(obstacle.get("visual_size", {}), Vector2(80, 80)),
			"collision_shape": str(obstacle.get("collision_shape", "circle")),
			"collision_size": _vector2_from_dict(obstacle.get("collision_size", {}), Vector2.ZERO),
			"collision_radius": float(obstacle.get("collision_radius", 20.0)),
			"collision_offset": _vector2_from_dict(obstacle.get("collision_offset", {}), Vector2.ZERO),
			"interaction_radius": float(obstacle.get("interaction_radius", 0.0)),
			"blocks_player": bool(obstacle.get("blocks_player", true)),
			"collectible": false,
			"sort_offset": float(obstacle.get("sort_offset", 20.0)),
		})
	return result

static func structures() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for structure: Dictionary in _as_array(data().get("structures", [])):
		result.append({
			"id": str(structure.get("id", "")),
			"kind": str(structure.get("kind", "")),
			"display_name": str(structure.get("display_name", "")),
			"position": _vector2_from_dict(structure.get("position", {}), Vector2.ZERO),
			"visual_size": _vector2_from_dict(structure.get("visual_size", {}), Vector2(72, 58)),
			"collision_shape": str(structure.get("collision_shape", "circle")),
			"collision_size": _vector2_from_dict(structure.get("collision_size", {}), Vector2.ZERO),
			"collision_radius": float(structure.get("collision_radius", 20.0)),
			"collision_offset": _vector2_from_dict(structure.get("collision_offset", {}), Vector2.ZERO),
			"interaction_radius": float(structure.get("interaction_radius", 0.0)),
			"blocks_player": bool(structure.get("blocks_player", true)),
			"collectible": false,
			"upgrade_id": str(structure.get("upgrade_id", "")),
			"sort_offset": float(structure.get("sort_offset", 20.0)),
		})
	return result

static func collected_nodes_from_snapshot(snapshot: Dictionary) -> Dictionary:
	return _as_dictionary(snapshot.get("collected_nodes", {}))

static func _load_ruleset() -> Dictionary:
	if not FileAccess.file_exists(RULESET_PATH):
		push_warning("Openworld ruleset missing: %s" % RULESET_PATH)
		return {}
	var file := FileAccess.open(RULESET_PATH, FileAccess.READ)
	if file == null:
		push_warning("Openworld ruleset could not be opened: %s" % RULESET_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	push_warning("Openworld ruleset is not a JSON object: %s" % RULESET_PATH)
	return {}

static func _world() -> Dictionary:
	return _as_dictionary(data().get("world", {}))

static func _movement() -> Dictionary:
	return _as_dictionary(data().get("movement", {}))

static func _session() -> Dictionary:
	return _as_dictionary(data().get("session", {}))

static func _vector2_from_dict(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		return Vector2(float(value.get("x", fallback.x)), float(value.get("y", fallback.y)))
	return fallback

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func _as_array(value: Variant) -> Array:
	return value if value is Array else []
