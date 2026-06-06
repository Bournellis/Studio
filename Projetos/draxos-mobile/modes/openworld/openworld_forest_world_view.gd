class_name OpenworldForestWorldView
extends Control

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

var world_size := Vector2(960, 1400)
var chest_position := Vector2(220, 250)
var player_position := Vector2(220, 330)
var resources: Array[Dictionary] = []
var nearest_item_id := ""
var collection_progress := 0.0
var pocket_full := false
var walk_phase := 0.0

func _ready() -> void:
	name = "OpenworldForestWorldView"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	queue_redraw()

func configure(next_world_size: Vector2, next_chest_position: Vector2) -> void:
	world_size = next_world_size
	chest_position = next_chest_position
	queue_redraw()

func set_state(
	next_player_position: Vector2,
	next_resources: Array[Dictionary],
	next_nearest_item_id: String,
	next_collection_progress: float,
	next_pocket_full: bool,
	next_walk_phase: float
) -> void:
	player_position = next_player_position
	resources = next_resources
	nearest_item_id = next_nearest_item_id
	collection_progress = clampf(next_collection_progress, 0.0, 1.0)
	pocket_full = next_pocket_full
	walk_phase = next_walk_phase
	queue_redraw()

func camera_origin() -> Vector2:
	return Vector2(_axis_origin(player_position.x, size.x, world_size.x), _axis_origin(player_position.y, size.y, world_size.y))

func world_to_screen(point: Vector2) -> Vector2:
	return point - camera_origin()

func _axis_origin(center: float, viewport: float, world_axis: float) -> float:
	if viewport >= world_axis:
		return -(viewport - world_axis) * 0.5
	return clampf(center - viewport * 0.5, 0.0, world_axis - viewport)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.046, 0.043), true)
	var origin := camera_origin()
	draw_set_transform(-origin, 0.0, Vector2.ONE)
	_draw_world_background()
	_draw_base_zone()
	_draw_forest_layers()
	_draw_cemetery_zone()
	_draw_resources()
	_draw_player()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_vignette()

func _draw_world_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, world_size), Color(0.075, 0.125, 0.087), true)
	draw_rect(Rect2(Vector2.ZERO, world_size), Color(0.22, 0.30, 0.18, 0.08), false, 6.0)
	for index in range(44):
		var point := _decor_point(index, 37.0, 19.0)
		var radius := 1.5 + float(index % 4)
		var color := Color(0.15, 0.23, 0.12, 0.32) if index % 3 != 0 else Color(0.41, 0.32, 0.16, 0.30)
		draw_circle(point, radius, color)
	_draw_path()

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
	draw_circle(chest_position + Vector2(0, 8), 98.0, Color(0.05, 0.03, 0.02, 0.28))
	draw_circle(chest_position, 92.0, Color(0.18, 0.11, 0.07, 0.74))
	draw_arc(chest_position, 92.0, 0.0, TAU, 72, Color(0.80, 0.70, 0.48, 0.24), 3.0, true)
	var chest_rect := Rect2(chest_position - Vector2(34, 22), Vector2(68, 44))
	draw_rect(chest_rect.grow(6.0), Color(0.02, 0.01, 0.0, 0.28), true)
	draw_rect(chest_rect, Color(0.34, 0.20, 0.10), true)
	draw_rect(chest_rect, Color(0.85, 0.70, 0.42, 0.64), false, 3.0)
	draw_line(chest_rect.position + Vector2(0, 20), chest_rect.position + Vector2(chest_rect.size.x, 20), Color(0.12, 0.06, 0.03), 3.0)
	draw_circle(chest_position + Vector2(0, 4), 5.0, Color(0.90, 0.70, 0.30))

func _draw_forest_layers() -> void:
	for index in range(30):
		var point := _decor_point(index + 180, 23.0, 71.0)
		var trunk := Color(0.14, 0.08, 0.04, 0.72)
		var leaf := Color(0.08, 0.18, 0.10, 0.78)
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
	draw_circle(brazier, 11.0 + sin(walk_phase * 2.0) * 2.0, Color(0.58, 0.16, 0.09, 0.56))

func _draw_resources() -> void:
	for entry: Dictionary in resources:
		if bool(entry.get("collected", false)):
			continue
		var item_id := str(entry.get("item_id", ""))
		var pos := Vector2(entry.get("position", Vector2.ZERO))
		var is_nearest := item_id == nearest_item_id
		if is_nearest:
			draw_circle(pos, ModelScript.COLLECTION_RADIUS, Color(0.82, 0.72, 0.45, 0.13))
			draw_arc(pos, ModelScript.COLLECTION_RADIUS, -PI * 0.5, TAU * collection_progress - PI * 0.5, 48, Color(0.90, 0.76, 0.38, 0.78), 4.0, true)
		_draw_resource_icon(item_id, pos, is_nearest)

func _draw_resource_icon(item_id: String, pos: Vector2, highlighted: bool) -> void:
	var shadow := Color(0.0, 0.0, 0.0, 0.30)
	draw_circle(pos + Vector2(0, 8), 17.0, shadow)
	match item_id:
		"galho":
			_draw_branch(pos, highlighted)
		"folha", "folha_seca":
			_draw_leaf(pos, highlighted, item_id == "folha_seca")
		"madeira":
			_draw_log(pos, highlighted)
		"pedra", "pedra_pequena":
			_draw_stone(pos, highlighted, item_id == "pedra_pequena")
		"cogumelo", "fungo":
			_draw_mushroom(pos, highlighted, item_id == "fungo")
		"inseto":
			_draw_insect(pos, highlighted)
		"resina":
			_draw_resin(pos, highlighted)
		"cinzas_preview":
			_draw_ash(pos, highlighted)
		"resto_ritual", "po_cinzento", "ossos_preview", "po_osso_preview":
			_draw_bone(pos, highlighted, item_id == "po_cinzento" or item_id == "po_osso_preview")
		_:
			draw_circle(pos, 14.0, Color(0.55, 0.55, 0.50))
	if highlighted:
		draw_arc(pos, 24.0, 0.0, TAU, 40, Color(0.95, 0.83, 0.55, 0.80), 2.0, true)

func _draw_branch(pos: Vector2, highlighted: bool) -> void:
	var color := Color(0.50, 0.32, 0.16).lightened(0.12 if highlighted else 0.0)
	draw_line(pos + Vector2(-18, 11), pos + Vector2(17, -9), color, 6.0)
	draw_line(pos + Vector2(-2, 0), pos + Vector2(11, 12), color, 4.0)

func _draw_leaf(pos: Vector2, highlighted: bool, dry: bool) -> void:
	var color := Color(0.56, 0.42, 0.19) if dry else Color(0.24, 0.55, 0.25)
	color = color.lightened(0.10 if highlighted else 0.0)
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -20),
		pos + Vector2(18, 0),
		pos + Vector2(0, 20),
		pos + Vector2(-16, 0),
	]), color)
	draw_line(pos + Vector2(0, -16), pos + Vector2(0, 16), Color(0.88, 0.82, 0.54, 0.52), 2.0)

func _draw_log(pos: Vector2, highlighted: bool) -> void:
	var color := Color(0.42, 0.24, 0.11).lightened(0.10 if highlighted else 0.0)
	var rect := Rect2(pos - Vector2(23, 12), Vector2(46, 24))
	draw_rect(rect, color, true)
	draw_rect(rect, Color(0.22, 0.11, 0.04), false, 3.0)
	draw_circle(pos + Vector2(-20, 0), 12.0, Color(0.62, 0.42, 0.22))
	draw_arc(pos + Vector2(-20, 0), 7.0, 0.0, TAU, 24, Color(0.30, 0.15, 0.06), 2.0, true)

func _draw_stone(pos: Vector2, highlighted: bool, small: bool) -> void:
	var radius := 13.0 if small else 18.0
	var color := Color(0.54, 0.56, 0.54).lightened(0.08 if highlighted else 0.0)
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(-radius, 5),
		pos + Vector2(-7, -radius),
		pos + Vector2(12, -radius * 0.75),
		pos + Vector2(radius, 7),
		pos + Vector2(3, radius),
	]), color)
	draw_line(pos + Vector2(-4, -7), pos + Vector2(9, 2), Color(0.80, 0.82, 0.78, 0.35), 2.0)

func _draw_mushroom(pos: Vector2, highlighted: bool, purple: bool) -> void:
	var cap := Color(0.40, 0.23, 0.52) if purple else Color(0.62, 0.18, 0.22)
	cap = cap.lightened(0.09 if highlighted else 0.0)
	draw_rect(Rect2(pos + Vector2(-5, -1), Vector2(10, 18)), Color(0.77, 0.69, 0.53), true)
	draw_circle(pos + Vector2(0, -7), 18.0, cap)
	draw_rect(Rect2(pos + Vector2(-18, -7), Vector2(36, 12)), cap, true)

func _draw_insect(pos: Vector2, highlighted: bool) -> void:
	var color := Color(0.15, 0.11, 0.08).lightened(0.12 if highlighted else 0.0)
	draw_circle(pos, 10.0, color)
	draw_circle(pos + Vector2(0, -12), 7.0, color)
	for side in [-1.0, 1.0]:
		draw_line(pos + Vector2(side * 4.0, -2), pos + Vector2(side * 18.0, -10), color, 2.0)
		draw_line(pos + Vector2(side * 5.0, 4), pos + Vector2(side * 19.0, 10), color, 2.0)

func _draw_resin(pos: Vector2, highlighted: bool) -> void:
	var color := Color(0.90, 0.56, 0.14).lightened(0.08 if highlighted else 0.0)
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -21),
		pos + Vector2(16, 0),
		pos + Vector2(7, 19),
		pos + Vector2(-12, 15),
		pos + Vector2(-16, -3),
	]), color)
	draw_circle(pos + Vector2(3, -3), 5.0, Color(1.0, 0.86, 0.38, 0.42))

func _draw_ash(pos: Vector2, highlighted: bool) -> void:
	var color := Color(0.58, 0.58, 0.54).lightened(0.08 if highlighted else 0.0)
	draw_circle(pos + Vector2(-8, 5), 12.0, color)
	draw_circle(pos + Vector2(8, 4), 10.0, color.darkened(0.10))
	draw_circle(pos + Vector2(0, -5), 9.0, Color(0.75, 0.73, 0.66, 0.75))

func _draw_bone(pos: Vector2, highlighted: bool, powder: bool) -> void:
	var color := Color(0.82, 0.78, 0.62).lightened(0.08 if highlighted else 0.0)
	if powder:
		for index in range(5):
			draw_circle(pos + Vector2(float(index - 2) * 6.0, sin(float(index)) * 6.0), 5.0, color)
		return
	draw_line(pos + Vector2(-17, 10), pos + Vector2(17, -10), color, 8.0)
	draw_circle(pos + Vector2(-18, 10), 7.0, color)
	draw_circle(pos + Vector2(18, -10), 7.0, color)

func _draw_player() -> void:
	var bob := sin(walk_phase) * 3.0
	var pos := player_position + Vector2(0, bob)
	draw_circle(player_position + Vector2(0, 18), 19.0, Color(0.0, 0.0, 0.0, 0.34))
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -28),
		pos + Vector2(21, 17),
		pos + Vector2(0, 31),
		pos + Vector2(-21, 17),
	]), Color(0.23, 0.04, 0.055))
	draw_circle(pos + Vector2(0, -17), 16.0, Color(0.10, 0.08, 0.075))
	draw_arc(pos + Vector2(0, -17), 12.0, PI * 0.10, PI * 0.90, 24, Color(0.79, 0.70, 0.50, 0.56), 2.0, true)
	draw_line(pos + Vector2(18, -8), pos + Vector2(29, 25), Color(0.45, 0.28, 0.13), 4.0)
	draw_circle(pos + Vector2(30, 26), 5.0, Color(0.72, 0.62, 0.42))
	if pocket_full:
		draw_arc(player_position, 36.0, 0.0, TAU, 40, Color(0.70, 0.07, 0.08, 0.75), 3.0, true)

func _draw_vignette() -> void:
	var edge := 34.0
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, edge)), Color(0.0, 0.0, 0.0, 0.20), true)
	draw_rect(Rect2(Vector2(0, size.y - edge), Vector2(size.x, edge)), Color(0.0, 0.0, 0.0, 0.24), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(edge, size.y)), Color(0.0, 0.0, 0.0, 0.18), true)
	draw_rect(Rect2(Vector2(size.x - edge, 0), Vector2(edge, size.y)), Color(0.0, 0.0, 0.0, 0.18), true)

func _decor_point(index: int, x_seed: float, y_seed: float) -> Vector2:
	var x := fmod(float(index * 97) + x_seed, world_size.x - 80.0) + 40.0
	var y := fmod(float(index * 163) + y_seed, world_size.y - 90.0) + 45.0
	return Vector2(x, y)
