class_name OpenworldForestWorld2D
extends Node2D

const CatalogScript := preload("res://modes/openworld/openworld_world_catalog.gd")
const ObjectScript := preload("res://modes/openworld/openworld_world_object.gd")
const PlayerScript := preload("res://modes/openworld/openworld_player_controller.gd")

const WALL_THICKNESS := 96.0
const RESOURCE_PROXIMITY_RADIUS := 126.0

var world_size := Vector2(960, 1400)
var chest_position := Vector2(220, 250)
var player_initial_position := Vector2(220, 330)
var player: OpenworldPlayerController

var _camera: Camera2D
var _depth_layer: Node2D
var _object_blocker_body: StaticBody2D
var _boundary_body: StaticBody2D
var _viewport_size := Vector2(390, 844)
var _resource_fixtures: Array = []
var _obstacle_fixtures: Array = []
var _structure_fixtures: Array = []
var _launcher_fixtures: Array = []
var _objects_by_id: Dictionary = {}
var _resource_objects: Dictionary = {}
var _resource_objects_by_item: Dictionary = {}
var _structure_objects: Dictionary = {}
var _structure_blockers: Dictionary = {}
var _launcher_objects: Dictionary = {}
var _built_upgrades: Dictionary = {}
var _movement_vector := Vector2.ZERO
var _movement_speed := 0.0
var _last_physics_moved := false
var _walk_phase := 0.0
var _built := false

func _ready() -> void:
	name = "OpenworldForestWorld2D"
	z_as_relative = false
	_build_world()
	set_physics_process(true)
	queue_redraw()

func configure(
	next_world_size: Vector2,
	next_chest_position: Vector2,
	next_resource_fixtures: Array,
	next_player_position: Vector2,
	next_obstacle_fixtures: Array = [],
	next_structure_fixtures: Array = [],
	next_launcher_fixtures: Array = []
) -> void:
	world_size = next_world_size
	chest_position = next_chest_position
	_resource_fixtures = next_resource_fixtures.duplicate(true)
	_obstacle_fixtures = next_obstacle_fixtures.duplicate(true)
	_structure_fixtures = next_structure_fixtures.duplicate(true)
	_launcher_fixtures = next_launcher_fixtures.duplicate(true)
	player_initial_position = next_player_position
	if is_inside_tree():
		_build_world()

func set_viewport_size(next_size: Vector2) -> void:
	_viewport_size = next_size
	_update_camera()

func set_movement_vector(vector: Vector2, speed: float) -> void:
	_movement_vector = vector.limit_length(1.0)
	_movement_speed = maxf(0.0, speed)

func get_player_position() -> Vector2:
	if player == null:
		return player_initial_position
	return player.global_position

func set_player_position(next_position: Vector2) -> void:
	if player == null:
		player_initial_position = next_position
		return
	player.global_position = _clamp_inside_world(next_position)
	player.call("_update_depth")
	_update_camera()

func was_moving_last_physics_frame() -> bool:
	return _last_physics_moved

func is_near_chest() -> bool:
	return get_player_position().distance_to(chest_position) <= chest_interaction_radius()

func chest_collision_radius() -> float:
	var chest := _objects_by_id.get("chest_home") as OpenworldWorldObject
	return chest.collision_radius if chest != null else 34.0

func chest_interaction_radius() -> float:
	var chest := _objects_by_id.get("chest_home") as OpenworldWorldObject
	return chest.interaction_radius if chest != null else 88.0

func obstacle_position(object_id: String) -> Vector2:
	var object := _objects_by_id.get(object_id) as OpenworldWorldObject
	return object.global_position if object != null else Vector2.ZERO

func obstacle_collision_radius(object_id: String) -> float:
	var object := _objects_by_id.get(object_id) as OpenworldWorldObject
	return object.collision_radius if object != null else 0.0

func obstacle_collision_center(object_id: String) -> Vector2:
	var object := _objects_by_id.get(object_id) as OpenworldWorldObject
	if object == null:
		return Vector2.ZERO
	return object.collision_center_global()

func obstacle_collision_shape(object_id: String) -> String:
	var object := _objects_by_id.get(object_id) as OpenworldWorldObject
	return object.collision_shape if object != null else ""

func obstacle_collision_size(object_id: String) -> Vector2:
	var object := _objects_by_id.get(object_id) as OpenworldWorldObject
	return object.collision_size if object != null else Vector2.ZERO

func resource_position(item_id: String) -> Vector2:
	var objects: Array = _resource_objects_by_item.get(item_id, []) as Array
	var object: OpenworldWorldObject = null
	if not objects.is_empty():
		object = objects[0] as OpenworldWorldObject
	return object.global_position if object != null else Vector2.ZERO

func resource_node_position(node_id: String) -> Vector2:
	var object := _resource_objects.get(node_id) as OpenworldWorldObject
	return object.global_position if object != null else Vector2.ZERO

func resource_visual_state(item_id: String) -> Dictionary:
	var objects: Array = _resource_objects_by_item.get(item_id, []) as Array
	var object: OpenworldWorldObject = null
	if not objects.is_empty():
		object = objects[0] as OpenworldWorldObject
	return _resource_object_visual_state(object)

func resource_node_visual_state(node_id: String) -> Dictionary:
	var object := _resource_objects.get(node_id) as OpenworldWorldObject
	return _resource_object_visual_state(object)

func structure_position(upgrade_id: String) -> Vector2:
	var object := _structure_objects.get(upgrade_id) as OpenworldWorldObject
	return object.global_position if object != null else Vector2.ZERO

func structure_visible(upgrade_id: String) -> bool:
	var object := _structure_objects.get(upgrade_id) as OpenworldWorldObject
	return object != null and object.visible

func is_near_structure(upgrade_id: String) -> bool:
	var object := _structure_objects.get(upgrade_id) as OpenworldWorldObject
	if object == null or not object.visible:
		return false
	var radius := object.interaction_radius
	if radius <= 0.0:
		radius = maxf(64.0, object.collision_radius + 46.0)
	return get_player_position().distance_to(object.global_position) <= radius

func structure_collision_enabled(upgrade_id: String) -> bool:
	var shape := _structure_blockers.get(upgrade_id) as CollisionShape2D
	return shape != null and not shape.disabled

func launcher_count() -> int:
	return _launcher_objects.size()

func launcher_entry_ids() -> Array[String]:
	var result: Array[String] = []
	for key: String in _launcher_objects.keys():
		result.append(key)
	result.sort()
	return result

func launcher_position(entry_id: String) -> Vector2:
	var object := _launcher_objects.get(entry_id) as OpenworldWorldObject
	return object.global_position if object != null else Vector2.ZERO

func launcher_visual_state(entry_id: String) -> Dictionary:
	var object := _launcher_objects.get(entry_id) as OpenworldWorldObject
	if object == null:
		return {"exists": false}
	return {
		"exists": true,
		"visible": object.visible,
		"entry_id": object.entry_id,
		"action_id": object.action_id,
		"visual_kind": object.visual_kind,
		"highlighted": object.launcher_highlighted,
		"interaction_radius": object.interaction_radius,
	}

func nearest_launcher(player_position: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry_id: String in _launcher_objects.keys():
		var object := _launcher_objects.get(entry_id) as OpenworldWorldObject
		if object == null or not object.visible:
			continue
		var distance := player_position.distance_to(object.global_position)
		if object.interaction_radius > 0.0 and distance <= object.interaction_radius and distance < best_distance:
			best = _launcher_object_entry(object)
			best_distance = distance
	return best

func launcher_entry_at_world_position(world_position: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry_id: String in _launcher_objects.keys():
		var object := _launcher_objects.get(entry_id) as OpenworldWorldObject
		if object == null or not object.visible:
			continue
		var radius := maxf(object.interaction_radius, maxf(object.visual_size.x, object.visual_size.y) * 0.65)
		var distance := world_position.distance_to(object.global_position)
		if radius > 0.0 and distance <= radius and distance < best_distance:
			best = _launcher_object_entry(object)
			best_distance = distance
	return best

func world_position_from_viewport_point(viewport_point: Vector2) -> Vector2:
	var camera_position := _camera.position if _camera != null else _camera_center_for(get_player_position())
	return camera_position - _viewport_size * 0.5 + viewport_point

func viewport_point_from_world_position(world_point: Vector2) -> Vector2:
	var camera_position := _camera.position if _camera != null else _camera_center_for(get_player_position())
	return world_point - camera_position + _viewport_size * 0.5

func set_state(
	resources: Array[Dictionary],
	nearest_node_id: String,
	collection_progress: float,
	pocket_full: bool,
	next_walk_phase: float,
	built_upgrades: Dictionary = {},
	nearest_launcher_entry_id: String = ""
) -> void:
	_walk_phase = next_walk_phase
	_set_structure_visibility(built_upgrades)
	var player_position := get_player_position()
	for entry: Dictionary in resources:
		var resource_item_id := str(entry.get("item_id", ""))
		var resource_node_id := str(entry.get("node_id", ""))
		var object := _resource_objects.get(resource_node_id) as OpenworldWorldObject
		if object == null:
			continue
		var resource_collected := bool(entry.get("collected", false))
		var resource_nearest := resource_node_id == nearest_node_id
		var resource_nearby := not resource_collected and player_position.distance_to(object.global_position) <= RESOURCE_PROXIMITY_RADIUS
		object.set_resource_state(
			resource_collected,
			resource_nearest,
			collection_progress if resource_nearest else 0.0,
			resource_nearby
		)
	for entry_id: String in _launcher_objects.keys():
		var launcher := _launcher_objects.get(entry_id) as OpenworldWorldObject
		if launcher != null:
			launcher.set_launcher_state(entry_id == nearest_launcher_entry_id)
	if player != null:
		player.set_visual_state(pocket_full, _walk_phase)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	_last_physics_moved = player.move_with_input(_movement_vector, _movement_speed)
	if _movement_vector.length() <= 0.05:
		player.stop_motion()
	_update_camera()

func _build_world() -> void:
	for child: Node in get_children():
		child.queue_free()
	_objects_by_id.clear()
	_resource_objects.clear()
	_resource_objects_by_item.clear()
	_structure_objects.clear()
	_structure_blockers.clear()
	_launcher_objects.clear()
	_built = true

	_depth_layer = Node2D.new()
	_depth_layer.name = "OpenworldDepthLayer"
	_depth_layer.y_sort_enabled = true
	add_child(_depth_layer)

	_object_blocker_body = StaticBody2D.new()
	_object_blocker_body.name = "OpenworldObjectBlockers"
	_object_blocker_body.collision_layer = 1
	_object_blocker_body.collision_mask = 1
	add_child(_object_blocker_body)

	var catalog: Array[Dictionary] = CatalogScript.build_catalog(chest_position, _resource_fixtures, _obstacle_fixtures, _structure_fixtures, _launcher_fixtures)
	for object_data: Dictionary in catalog:
		var object := ObjectScript.new()
		object.configure(object_data)
		_depth_layer.add_child(object)
		_objects_by_id[object.object_id] = object
		if object.collectible:
			_resource_objects[object.node_id] = object
			if not _resource_objects_by_item.has(object.item_id):
				_resource_objects_by_item[object.item_id] = []
			(_resource_objects_by_item[object.item_id] as Array).append(object)
		elif object.kind == CatalogScript.KIND_CAMPFIRE:
			_structure_objects[object.upgrade_id] = object
			var shape := _add_object_blocker(object_data) if bool(object_data.get("blocks_player", false)) else null
			if shape != null:
				_structure_blockers[object.upgrade_id] = shape
		elif object.kind == CatalogScript.KIND_LAUNCHER:
			_launcher_objects[object.entry_id] = object
			if bool(object_data.get("blocks_player", false)):
				_add_object_blocker(object_data)
		elif bool(object_data.get("blocks_player", false)):
			_add_object_blocker(object_data)
	_set_structure_visibility(_built_upgrades)

	player = PlayerScript.new()
	player.position = player_initial_position
	_depth_layer.add_child(player)

	_boundary_body = StaticBody2D.new()
	_boundary_body.name = "OpenworldBoundaryWalls"
	_boundary_body.collision_layer = 1
	_boundary_body.collision_mask = 1
	add_child(_boundary_body)
	_add_wall("Top", Vector2(world_size.x * 0.5, -WALL_THICKNESS * 0.5), Vector2(world_size.x + WALL_THICKNESS * 2.0, WALL_THICKNESS))
	_add_wall("Bottom", Vector2(world_size.x * 0.5, world_size.y + WALL_THICKNESS * 0.5), Vector2(world_size.x + WALL_THICKNESS * 2.0, WALL_THICKNESS))
	_add_wall("Left", Vector2(-WALL_THICKNESS * 0.5, world_size.y * 0.5), Vector2(WALL_THICKNESS, world_size.y + WALL_THICKNESS * 2.0))
	_add_wall("Right", Vector2(world_size.x + WALL_THICKNESS * 0.5, world_size.y * 0.5), Vector2(WALL_THICKNESS, world_size.y + WALL_THICKNESS * 2.0))

	_camera = Camera2D.new()
	_camera.name = "OpenworldCamera2D"
	add_child(_camera)
	_camera.make_current()
	_update_camera()
	queue_redraw()

func _add_wall(label: String, wall_position: Vector2, wall_size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	shape.name = "OpenworldBoundary%s" % label
	shape.position = wall_position
	var rectangle := RectangleShape2D.new()
	rectangle.size = wall_size
	shape.shape = rectangle
	_boundary_body.add_child(shape)

func _add_object_blocker(object_data: Dictionary) -> CollisionShape2D:
	if _object_blocker_body == null:
		return null
	var shape := CollisionShape2D.new()
	shape.name = "OpenworldObjectBlocker_%s" % str(object_data.get("id", "object"))
	shape.position = Vector2(object_data.get("position", Vector2.ZERO)) + Vector2(object_data.get("collision_offset", Vector2.ZERO))
	var shape_type := str(object_data.get("collision_shape", "circle"))
	if shape_type == "rectangle":
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(object_data.get("collision_size", Vector2(40, 40)))
		if rectangle.size == Vector2.ZERO:
			var radius := float(object_data.get("collision_radius", 20.0))
			rectangle.size = Vector2(radius * 2.0, radius * 2.0)
		shape.shape = rectangle
	else:
		var circle := CircleShape2D.new()
		circle.radius = maxf(1.0, float(object_data.get("collision_radius", 20.0)))
		shape.shape = circle
	_object_blocker_body.add_child(shape)
	return shape

func _set_structure_visibility(built_upgrades: Dictionary) -> void:
	_built_upgrades = built_upgrades.duplicate(true)
	for upgrade_id: String in _structure_objects.keys():
		var built := bool(_built_upgrades.get(upgrade_id, false))
		var object := _structure_objects.get(upgrade_id) as OpenworldWorldObject
		if object != null:
			object.set_built_state(built)
		var shape := _structure_blockers.get(upgrade_id) as CollisionShape2D
		if shape != null:
			shape.disabled = not built

func _update_camera() -> void:
	if _camera == null:
		return
	_camera.position = _camera_center_for(get_player_position())

func _camera_center_for(center: Vector2) -> Vector2:
	var half := _viewport_size * 0.5
	var x := world_size.x * 0.5 if _viewport_size.x >= world_size.x else clampf(center.x, half.x, world_size.x - half.x)
	var y := world_size.y * 0.5 if _viewport_size.y >= world_size.y else clampf(center.y, half.y, world_size.y - half.y)
	return Vector2(x, y)

func _clamp_inside_world(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, PlayerScript.PLAYER_RADIUS, world_size.x - PlayerScript.PLAYER_RADIUS),
		clampf(point.y, PlayerScript.PLAYER_RADIUS, world_size.y - PlayerScript.PLAYER_RADIUS)
	)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size), Color(0.075, 0.125, 0.087), true)
	draw_rect(Rect2(Vector2.ZERO, world_size), Color(0.22, 0.30, 0.18, 0.12), false, 6.0)
	draw_rect(Rect2(Vector2(8, 8), world_size - Vector2(16, 16)), Color(0.76, 0.68, 0.46, 0.15), false, 2.0)
	for index in range(44):
		var point := _decor_point(index, 37.0, 19.0)
		var radius := 1.5 + float(index % 4)
		var color := Color(0.15, 0.23, 0.12, 0.32) if index % 3 != 0 else Color(0.41, 0.32, 0.16, 0.30)
		draw_circle(point, radius, color)
	_draw_path()
	_draw_base_zone()
	_draw_nonblocking_landmarks()
	_draw_background_forest()
	_draw_cemetery_zone()

func _draw_path() -> void:
	var points := PackedVector2Array([
		Vector2(190, 210),
		Vector2(250, 360),
		Vector2(380, 500),
		Vector2(520, 700),
		Vector2(460, 930),
		Vector2(555, 1130),
		Vector2(690, 1265),
	])
	draw_polyline(points, Color(0.24, 0.18, 0.11, 0.90), 58.0, true)
	draw_polyline(points, Color(0.45, 0.34, 0.19, 0.35), 34.0, true)
	for index in range(18):
		var point := _decor_point(index + 90, 11.0, 53.0)
		if point.distance_to(chest_position) < 170.0:
			continue
		draw_circle(point, 4.0 + float(index % 3), Color(0.14, 0.18, 0.12, 0.34))

func _draw_base_zone() -> void:
	draw_circle(chest_position + Vector2(0, 8), 108.0, Color(0.05, 0.03, 0.02, 0.20))
	draw_circle(chest_position, 100.0, Color(0.18, 0.11, 0.07, 0.36))

func _draw_nonblocking_landmarks() -> void:
	_draw_fallen_log(Vector2(735, 905), -0.24)
	_draw_fern_cluster(Vector2(176, 595))
	_draw_fern_cluster(Vector2(820, 535))

func _draw_fallen_log(center: Vector2, angle: float) -> void:
	var direction := Vector2(cos(angle), sin(angle))
	var normal := Vector2(-direction.y, direction.x)
	var start := center - direction * 44.0
	var finish := center + direction * 44.0
	draw_line(start + normal * 8.0, finish + normal * 8.0, Color(0.02, 0.01, 0.0, 0.18), 18.0)
	draw_line(start, finish, Color(0.26, 0.15, 0.07, 0.40), 13.0)
	draw_line(start + direction * 10.0, finish - direction * 16.0, Color(0.54, 0.34, 0.16, 0.22), 3.0)
	draw_circle(start, 7.0, Color(0.55, 0.37, 0.19, 0.28))

func _draw_fern_cluster(center: Vector2) -> void:
	for index in range(5):
		var angle := -1.05 + float(index) * 0.52
		var length := 24.0 + float(index % 2) * 8.0
		var tip := center + Vector2(cos(angle), sin(angle)) * length
		draw_line(center, tip, Color(0.20, 0.42, 0.18, 0.32), 3.0)
		draw_circle(tip, 5.0, Color(0.22, 0.52, 0.22, 0.24))

func _draw_background_forest() -> void:
	for index in range(24):
		var point := _decor_point(index + 180, 23.0, 71.0)
		var trunk := Color(0.14, 0.08, 0.04, 0.50)
		var leaf := Color(0.08, 0.18, 0.10, 0.50)
		draw_line(point + Vector2(0, 16), point + Vector2(0, -14), trunk, 5.0)
		draw_circle(point + Vector2(-10, -13), 16.0, leaf)
		draw_circle(point + Vector2(9, -18), 19.0, leaf.darkened(0.05))
		draw_circle(point + Vector2(3, -34), 14.0, leaf.lightened(0.05))

func _draw_cemetery_zone() -> void:
	var center := Vector2(700, 1210)
	draw_circle(center, 190.0, Color(0.08, 0.075, 0.072, 0.70))
	draw_circle(center, 144.0, Color(0.14, 0.12, 0.105, 0.64))
	for index in range(6):
		var x := 592.0 + float(index % 3) * 74.0
		var y := 1134.0 + float(index / 3) * 76.0
		var rect := Rect2(Vector2(x, y), Vector2(25, 40))
		draw_rect(rect, Color(0.32, 0.31, 0.28, 0.70), true)
		draw_rect(rect, Color(0.82, 0.76, 0.60, 0.34), false, 2.0)
	var brazier := Vector2(612, 1220)
	draw_circle(brazier, 34.0, Color(0.06, 0.04, 0.035, 0.75))
	draw_circle(brazier, 20.0, Color(0.35, 0.32, 0.30, 0.80))
	draw_circle(brazier, 11.0 + sin(_walk_phase * 2.0) * 2.0, Color(0.58, 0.16, 0.09, 0.56))

func _decor_point(index: int, x_seed: float, y_seed: float) -> Vector2:
	var x := fmod(float(index * 97) + x_seed, world_size.x - 80.0) + 40.0
	var y := fmod(float(index * 163) + y_seed, world_size.y - 90.0) + 45.0
	return Vector2(x, y)

func _resource_object_visual_state(object: OpenworldWorldObject) -> Dictionary:
	if object == null:
		return {"exists": false}
	return {
		"exists": true,
		"visible": object.visible,
		"collected": object.collected,
		"nearest": object.nearest,
		"nearby": object.nearby,
		"collection_progress": object.collection_progress,
	}

func _launcher_object_entry(object: OpenworldWorldObject) -> Dictionary:
	return {
		"entry_id": object.entry_id,
		"label": object.display_name,
		"display_name": object.display_name,
		"action_id": object.action_id,
		"visual_kind": object.visual_kind,
		"position": object.global_position,
		"interaction_radius": object.interaction_radius,
		"visual_size": object.visual_size,
	}
