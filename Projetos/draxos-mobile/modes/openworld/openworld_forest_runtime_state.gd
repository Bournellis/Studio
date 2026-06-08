class_name OpenworldForestRuntimeState
extends RefCounted

const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")

const RESPAWN_VISUAL_GRACE_SECONDS := 2

var player_position := Vector2.ZERO
var last_revision_position := Vector2.ZERO
var local_position_revision := 0
var session_seconds := 0.0
var walk_phase := 0.0
var active_collection_node_id := ""
var resource_nodes: Array[Dictionary] = []
var node_state: Dictionary = {}
var server_time_offset_seconds := 0.0

func configure(initial_position: Vector2) -> void:
	player_position = initial_position
	last_revision_position = initial_position
	local_position_revision = 0
	session_seconds = 0.0
	walk_phase = 0.0
	active_collection_node_id = ""

func advance_time(delta: float) -> void:
	session_seconds += maxf(0.0, delta)
	_refresh_respawned_nodes()

func sync_server_time(value: Variant) -> void:
	var server_unix := _timestamp_to_unix(value)
	if server_unix <= 0:
		return
	server_time_offset_seconds = float(server_unix - int(Time.get_unix_time_from_system()))
	_refresh_respawned_nodes()

func current_server_unix() -> int:
	return int(Time.get_unix_time_from_system() + server_time_offset_seconds)

func update_player_position(next_position: Vector2) -> void:
	player_position = next_position
	_bump_position_revision_if_changed()

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
			"respawn_seconds": maxi(0, int(fixture.get("respawn_seconds", RulesetScript.item_respawn_seconds(item_id)))),
			"collected": false,
			"next_spawn_at_unix": 0,
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

func resource_by_node_id(node_id: String) -> Dictionary:
	var clean_node_id := node_id.strip_edges()
	if clean_node_id == "":
		return {}
	for entry: Dictionary in resource_nodes:
		if str(entry.get("node_id", "")) == clean_node_id:
			return entry
	return {}

func mark_collected(node_id: String) -> void:
	for index in range(resource_nodes.size()):
		var node := resource_nodes[index]
		if str(node.get("node_id", "")) == node_id:
			node["collected"] = true
			var item_id := str(node.get("item_id", ""))
			var respawn_seconds := maxi(0, int(node.get("respawn_seconds", RulesetScript.item_respawn_seconds(item_id))))
			var local_next_spawn := current_server_unix() + respawn_seconds
			node["next_spawn_at_unix"] = maxi(int(node.get("next_spawn_at_unix", 0)), local_next_spawn)
			resource_nodes[index] = node
			return

func apply_collected_nodes(collected_nodes: Dictionary) -> void:
	for index in range(resource_nodes.size()):
		var node := resource_nodes[index]
		var node_id := str(node.get("node_id", ""))
		node["collected"] = bool(collected_nodes.get(node_id, false))
		resource_nodes[index] = node

func apply_node_state(next_node_state: Dictionary, now_unix := -1) -> void:
	if now_unix < 0:
		now_unix = current_server_unix()
	node_state = next_node_state.duplicate(true)
	for index in range(resource_nodes.size()):
		var node := resource_nodes[index]
		var node_id := str(node.get("node_id", ""))
		var state := _as_dictionary(node_state.get(node_id, {}))
		var next_spawn_at := _timestamp_to_unix(state.get("next_spawn_at", 0))
		node["next_spawn_at_unix"] = next_spawn_at
		node["collected"] = next_spawn_at + RESPAWN_VISUAL_GRACE_SECONDS > now_unix
		resource_nodes[index] = node

func node_state_snapshot() -> Dictionary:
	return node_state.duplicate(true)

func respawned_collected_nodes() -> Dictionary:
	var result: Dictionary = {}
	for node: Dictionary in resource_nodes:
		if bool(node.get("collected", false)):
			result[str(node.get("node_id", ""))] = true
	return result

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

func _bump_position_revision_if_changed() -> void:
	if player_position.distance_to(last_revision_position) < 0.01:
		return
	last_revision_position = player_position
	local_position_revision += 1

static func dev_resource_fixtures() -> Array[Dictionary]:
	return [
		{"node_id": "dev_galho_01", "item_id": "galho", "position": Vector2(330, 420), "quantity": 1},
		{"node_id": "dev_folha_01", "item_id": "folha", "position": Vector2(410, 510), "quantity": 1},
		{"node_id": "dev_madeira_01", "item_id": "madeira", "position": Vector2(600, 440), "quantity": 1},
	]

func _refresh_respawned_nodes() -> void:
	var now_unix := current_server_unix()
	for index in range(resource_nodes.size()):
		var node := resource_nodes[index]
		var next_spawn_at := int(node.get("next_spawn_at_unix", 0))
		if next_spawn_at > 0 and next_spawn_at + RESPAWN_VISUAL_GRACE_SECONDS <= now_unix:
			node["collected"] = false
			resource_nodes[index] = node

static func _timestamp_to_unix(value: Variant) -> int:
	if value is int:
		return int(value)
	if value is float:
		return int(value)
	var text := str(value).strip_edges()
	if text == "" or text == "<null>":
		return 0
	if text.is_valid_int():
		return int(text)
	var clean := text.replace("Z", "")
	var plus_index := clean.find("+", 19)
	if plus_index >= 0:
		clean = clean.substr(0, plus_index)
	var minus_index := clean.find("-", 19)
	if minus_index >= 0:
		clean = clean.substr(0, minus_index)
	if clean.length() > 19:
		clean = clean.substr(0, 19)
	return int(Time.get_unix_time_from_datetime_string(clean))

static func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
