class_name OpenworldWorldCatalog
extends RefCounted

const KIND_CHEST := "chest"
const KIND_TREE := "tree_large"
const KIND_ROCK := "rock_large"
const KIND_RESOURCE := "resource"
const KIND_CAMPFIRE := "campfire"

static func build_catalog(chest_position: Vector2, resource_fixtures: Array, obstacle_fixtures: Array = [], structure_fixtures: Array = []) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	entries.append({
		"id": "chest_home",
		"kind": KIND_CHEST,
		"display_name": "Bau do bosque",
		"position": chest_position,
		"visual_size": Vector2(92, 70),
		"collision_shape": "rectangle",
		"collision_size": Vector2(82, 54),
		"collision_radius": 43.0,
		"collision_offset": Vector2(0, 4),
		"interaction_radius": 88.0,
		"blocks_player": true,
		"collectible": false,
		"sort_offset": 30.0,
	})
	for obstacle: Dictionary in obstacle_fixtures:
		var entry := obstacle.duplicate(true)
		if str(entry.get("id", "")).strip_edges() == "":
			continue
		if str(entry.get("kind", "")).strip_edges() == "":
			entry["kind"] = KIND_TREE
		entry["blocks_player"] = bool(entry.get("blocks_player", true))
		entry["collectible"] = false
		entry["interaction_radius"] = float(entry.get("interaction_radius", 0.0))
		entry["sort_offset"] = float(entry.get("sort_offset", 20.0))
		entries.append(entry)
	for structure: Dictionary in structure_fixtures:
		var entry := structure.duplicate(true)
		if str(entry.get("id", "")).strip_edges() == "":
			continue
		if str(entry.get("kind", "")).strip_edges() == "":
			entry["kind"] = KIND_CAMPFIRE
		entry["blocks_player"] = bool(entry.get("blocks_player", true))
		entry["collectible"] = false
		entry["interaction_radius"] = float(entry.get("interaction_radius", 0.0))
		entry["sort_offset"] = float(entry.get("sort_offset", 20.0))
		entries.append(entry)
	for fixture: Dictionary in resource_fixtures:
		var item_id := str(fixture.get("item_id", ""))
		var node_id := str(fixture.get("node_id", "")).strip_edges()
		var resource_id := "resource_%s" % item_id if node_id == "" else "resource_%s" % node_id
		entries.append({
			"id": resource_id,
			"kind": KIND_RESOURCE,
			"display_name": item_id,
			"position": Vector2(fixture.get("position", Vector2.ZERO)),
			"visual_size": Vector2(42, 42),
			"collision_radius": 0.0,
			"interaction_radius": 40.0,
			"blocks_player": false,
			"collectible": true,
			"item_id": item_id,
			"node_id": node_id,
			"sort_offset": 12.0,
		})
	return entries
