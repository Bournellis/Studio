class_name OpenworldWorldCatalog
extends RefCounted

const KIND_CHEST := "chest"
const KIND_TREE := "tree_large"
const KIND_ROCK := "rock_large"
const KIND_RESOURCE := "resource"

static func build_catalog(chest_position: Vector2, resource_fixtures: Array) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	entries.append({
		"id": "chest_home",
		"kind": KIND_CHEST,
		"display_name": "Bau do bosque",
		"position": chest_position,
		"visual_size": Vector2(92, 70),
		"collision_radius": 34.0,
		"interaction_radius": 88.0,
		"blocks_player": true,
		"collectible": false,
		"sort_offset": 30.0,
	})
	entries.append_array(_large_obstacles())
	for fixture: Dictionary in resource_fixtures:
		var item_id := str(fixture.get("item_id", ""))
		entries.append({
			"id": "resource_%s" % item_id,
			"kind": KIND_RESOURCE,
			"display_name": item_id,
			"position": Vector2(fixture.get("position", Vector2.ZERO)),
			"visual_size": Vector2(42, 42),
			"collision_radius": 0.0,
			"interaction_radius": 40.0,
			"blocks_player": false,
			"collectible": true,
			"item_id": item_id,
			"sort_offset": 12.0,
		})
	return entries

static func _large_obstacles() -> Array[Dictionary]:
	return [
		{
			"id": "tree_large_northwest",
			"kind": KIND_TREE,
			"display_name": "Arvore grande",
			"position": Vector2(130, 430),
			"visual_size": Vector2(105, 130),
			"collision_radius": 30.0,
			"interaction_radius": 0.0,
			"blocks_player": true,
			"collectible": false,
			"sort_offset": 28.0,
		},
		{
			"id": "tree_large_mid",
			"kind": KIND_TREE,
			"display_name": "Arvore grande",
			"position": Vector2(540, 595),
			"visual_size": Vector2(120, 142),
			"collision_radius": 34.0,
			"interaction_radius": 0.0,
			"blocks_player": true,
			"collectible": false,
			"sort_offset": 30.0,
		},
		{
			"id": "tree_large_south",
			"kind": KIND_TREE,
			"display_name": "Arvore grande",
			"position": Vector2(352, 1135),
			"visual_size": Vector2(115, 138),
			"collision_radius": 32.0,
			"interaction_radius": 0.0,
			"blocks_player": true,
			"collectible": false,
			"sort_offset": 30.0,
		},
		{
			"id": "tree_large_east",
			"kind": KIND_TREE,
			"display_name": "Arvore grande",
			"position": Vector2(812, 710),
			"visual_size": Vector2(118, 136),
			"collision_radius": 33.0,
			"interaction_radius": 0.0,
			"blocks_player": true,
			"collectible": false,
			"sort_offset": 30.0,
		},
		{
			"id": "rock_large_path",
			"kind": KIND_ROCK,
			"display_name": "Rocha grande",
			"position": Vector2(505, 820),
			"visual_size": Vector2(82, 58),
			"collision_radius": 28.0,
			"interaction_radius": 0.0,
			"blocks_player": true,
			"collectible": false,
			"sort_offset": 18.0,
		},
		{
			"id": "rock_large_cemetery",
			"kind": KIND_ROCK,
			"display_name": "Rocha grande",
			"position": Vector2(655, 1110),
			"visual_size": Vector2(92, 62),
			"collision_radius": 30.0,
			"interaction_radius": 0.0,
			"blocks_player": true,
			"collectible": false,
			"sort_offset": 18.0,
		},
	]
