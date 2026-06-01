class_name OpenworldForestWorld2D
extends Node2D

const CatalogScript := preload("res://modes/openworld/openworld_world_catalog.gd")
const ObjectScript := preload("res://modes/openworld/openworld_world_object.gd")
const PlayerScript := preload("res://modes/openworld/openworld_player_controller.gd")

const WALL_THICKNESS := 96.0

var world_size := Vector2(960, 1400)
var chest_position := Vector2(220, 250)
var player_initial_position := Vector2(220, 330)
var player: OpenworldPlayerController

var _camera: Camera2D
var _depth_layer: Node2D
var _boundary_body: StaticBody2D
var _viewport_size := Vector2(390, 844)
var _resource_fixtures: Array = []
var _objects_by_id: Dictionary = {}
var _resource_objects: Dictionary = {}
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

func configure(next_world_size: Vector2, next_chest_position: Vector2, next_resource_fixtures: Array, next_player_position: Vector2) -> void:
	world_size = next_world_size
	chest_position = next_chest_position
	_resource_fixtures = next_resource_fixtures.duplicate(true)
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

func resource_position(item_id: String) -> Vector2:
	var object := _resource_objects.get(item_id) as OpenworldWorldObject
	return object.global_position if object != null else Vector2.ZERO

func set_state(
	resources: Array[Dictionary],
	nearest_item_id: String,
	collection_progress: float,
	pocket_full: bool,
	next_walk_phase: float
) -> void:
	_walk_phase = next_walk_phase
	for entry: Dictionary in resources:
		var resource_item_id := str(entry.get("item_id", ""))
		var object := _resource_objects.get(resource_item_id) as OpenworldWorldObject
		if object == null:
			continue
		object.set_resource_state(
			bool(entry.get("collected", false)),
			resource_item_id == nearest_item_id,
			collection_progress if resource_item_id == nearest_item_id else 0.0
		)
	if player != null:
		player.set_visual_state(pocket_full, _walk_phase)

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
	_built = true

	_depth_layer = Node2D.new()
	_depth_layer.name = "OpenworldDepthLayer"
	_depth_layer.y_sort_enabled = true
	add_child(_depth_layer)

	var catalog: Array[Dictionary] = CatalogScript.build_catalog(chest_position, _resource_fixtures)
	for object_data: Dictionary in catalog:
		var object := ObjectScript.new()
		object.configure(object_data)
		_depth_layer.add_child(object)
		_objects_by_id[object.object_id] = object
		if object.collectible:
			_resource_objects[object.item_id] = object

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
