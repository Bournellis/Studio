class_name OpenworldForestRuntimeState
extends RefCounted

const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")

var player_position := Vector2.ZERO
var session_seconds := 0.0
var walk_phase := 0.0
var active_collection_node_id := ""
var resource_nodes: Array[Dictionary] = []

func configure(initial_position: Vector2) -> void:
	player_position = initial_position
	session_seconds = 0.0
	walk_phase = 0.0
	active_collection_node_id = ""

func advance_time(delta: float) -> void:
	session_seconds += maxf(0.0, delta)

func update_player_position(next_position: Vector2) -> void:
	player_position = next_position

func advance_walk_phase(delta: float) -> void:
	walk_phase += maxf(0.0, delta) * 12.0

func reset_resources(fixtures: Array[Dictionary]) -> void:
	resource_nodes.clear()
	for fixture: Dictionary in fixtures:
		var node_id := str(fixture.get("node_id", "")).strip_edges()
		var item_id := str(fixture.get("item_id", "")).strip_edges()
		if item_id == "":
			continue
		if node_id == "":
			node_id = "node_%s_%d" % [item_id, resource_nodes.size() + 1]
		resource_nodes.append({
			"node_id": node_id,
			"item_id": item_id,
			"position": Vector2(fixture.get("position", Vector2.ZERO)),
			"quantity": maxi(1, int(fixture.get("quantity", 1))),
			"collected": false,
		})

func nearest_resource(bridge: Variant = null) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry: Dictionary in resource_nodes:
		if bool(entry.get("collected", false)):
			continue
		var node_id := str(entry.get("node_id", ""))
		if bridge != null and bridge.has_method("has_pending_collected_node") and bridge.has_pending_collected_node(node_id):
			continue
		var distance := player_position.distance_to(Vector2(entry.get("position", Vector2.ZERO)))
		if distance <= RulesetScript.collection_radius() and distance < best_distance:
			best = entry
			best_distance = distance
	return best

func mark_collected(node_id: String) -> void:
	for index in range(resource_nodes.size()):
		var node := resource_nodes[index]
		if str(node.get("node_id", "")) == node_id:
			node["collected"] = true
			resource_nodes[index] = node
			return

func apply_collected_nodes(collected_nodes: Dictionary) -> void:
	for index in range(resource_nodes.size()):
		var node := resource_nodes[index]
		var node_id := str(node.get("node_id", ""))
		node["collected"] = bool(collected_nodes.get(node_id, false))
		resource_nodes[index] = node

func resource_signature() -> String:
	var parts := PackedStringArray()
	for node: Dictionary in resource_nodes:
		parts.append("%s:%s:%s" % [
			str(node.get("node_id", "")),
			str(node.get("item_id", "")),
			"1" if bool(node.get("collected", false)) else "0",
		])
	return "|".join(parts)

func position_payload() -> Dictionary:
	return {
		"x": snappedf(player_position.x, 0.01),
		"y": snappedf(player_position.y, 0.01),
	}

static func dev_resource_fixtures() -> Array[Dictionary]:
	return [
		{"node_id": "dev_galho_01", "item_id": "galho", "position": Vector2(330, 420), "quantity": 1},
		{"node_id": "dev_folha_01", "item_id": "folha", "position": Vector2(410, 510), "quantity": 1},
		{"node_id": "dev_madeira_01", "item_id": "madeira", "position": Vector2(600, 440), "quantity": 1},
	]
