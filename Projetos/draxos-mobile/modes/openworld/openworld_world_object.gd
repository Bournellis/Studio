class_name OpenworldWorldObject
extends Node2D

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const CatalogScript := preload("res://modes/openworld/openworld_world_catalog.gd")

var object_id := ""
var kind := ""
var node_id := ""
var item_id := ""
var upgrade_id := ""
var entry_id := ""
var action_id := ""
var visual_kind := ""
var display_name := ""
var collision_shape := "circle"
var collision_size := Vector2.ZERO
var collision_offset := Vector2.ZERO
var collision_radius := 0.0
var interaction_radius := 0.0
var blocks_player := false
var collectible := false
var sort_offset := 0.0
var visual_size := Vector2(40, 40)
var collected := false
var nearest := false
var nearby := false
var collection_progress := 0.0
var built := true
var launcher_highlighted := false

var _static_body: StaticBody2D
var _area: Area2D

func configure(object_data: Dictionary) -> void:
	object_id = str(object_data.get("id", "object"))
	kind = str(object_data.get("kind", ""))
	node_id = str(object_data.get("node_id", ""))
	item_id = str(object_data.get("item_id", ""))
	upgrade_id = str(object_data.get("upgrade_id", ""))
	entry_id = str(object_data.get("entry_id", ""))
	action_id = str(object_data.get("action_id", ""))
	visual_kind = str(object_data.get("visual_kind", ""))
	display_name = str(object_data.get("display_name", object_id))
	position = Vector2(object_data.get("position", Vector2.ZERO))
	visual_size = Vector2(object_data.get("visual_size", Vector2(40, 40)))
	collision_shape = str(object_data.get("collision_shape", "circle"))
	collision_size = Vector2(object_data.get("collision_size", Vector2.ZERO))
	collision_offset = Vector2(object_data.get("collision_offset", Vector2.ZERO))
	collision_radius = float(object_data.get("collision_radius", 0.0))
	interaction_radius = float(object_data.get("interaction_radius", 0.0))
	blocks_player = bool(object_data.get("blocks_player", false))
	collectible = bool(object_data.get("collectible", false))
	sort_offset = float(object_data.get("sort_offset", 0.0))
	built = bool(object_data.get("built", true))
	name = "OpenworldObject_%s" % object_id
	visible = built
	_update_depth()
	if collectible or interaction_radius > 0.0:
		_add_area()
	queue_redraw()

func collision_center_global() -> Vector2:
	return global_position + collision_offset

func set_resource_state(next_collected: bool, next_nearest: bool, next_progress: float, next_nearby: bool = false) -> void:
	collected = next_collected
	nearest = next_nearest
	nearby = next_nearby or next_nearest
	collection_progress = clampf(next_progress, 0.0, 1.0)
	visible = not collected
	if _area != null:
		_area.monitoring = not collected
		_area.monitorable = not collected
	queue_redraw()

func set_built_state(next_built: bool) -> void:
	built = next_built
	visible = built
	queue_redraw()

func set_launcher_state(next_highlighted: bool) -> void:
	if launcher_highlighted == next_highlighted:
		return
	launcher_highlighted = next_highlighted
	queue_redraw()

func _add_static_body() -> void:
	_static_body = StaticBody2D.new()
	_static_body.name = "OpenworldBlocker_%s" % object_id
	_static_body.collision_layer = 1
	_static_body.collision_mask = 1
	add_child(_static_body)
	var shape := CollisionShape2D.new()
	shape.name = "OpenworldBlockerShape_%s" % object_id
	var circle := CircleShape2D.new()
	circle.radius = maxf(1.0, collision_radius)
	shape.shape = circle
	_static_body.add_child(shape)

func _add_area() -> void:
	_area = Area2D.new()
	_area.name = "OpenworldArea_%s" % object_id
	_area.collision_layer = 2
	_area.collision_mask = 0
	_area.monitoring = true
	_area.monitorable = true
	add_child(_area)
	var shape := CollisionShape2D.new()
	shape.name = "OpenworldAreaShape_%s" % object_id
	var circle := CircleShape2D.new()
	circle.radius = maxf(1.0, interaction_radius)
	shape.shape = circle
	_area.add_child(shape)

func _update_depth() -> void:
	z_index = int(global_position.y + sort_offset)

func _draw() -> void:
	if collectible:
		if collected:
			return
		if nearby:
			_draw_resource_pickup_marker(nearest)
		if nearest:
			draw_circle(Vector2.ZERO, ModelScript.COLLECTION_RADIUS, Color(0.82, 0.72, 0.45, 0.13))
			draw_arc(Vector2.ZERO, ModelScript.COLLECTION_RADIUS, -PI * 0.5, TAU * collection_progress - PI * 0.5, 48, Color(0.90, 0.76, 0.38, 0.78), 4.0, true)
		_draw_resource_icon(item_id, nearby)
		return
	match kind:
		CatalogScript.KIND_CHEST:
			_draw_chest()
		CatalogScript.KIND_TREE:
			_draw_large_tree()
		CatalogScript.KIND_ROCK:
			_draw_large_rock()
		CatalogScript.KIND_CAMPFIRE:
			_draw_campfire()
		CatalogScript.KIND_LAUNCHER:
			_draw_launcher()
		_:
			draw_circle(Vector2.ZERO, 18.0, Color(0.52, 0.48, 0.36))

func _draw_chest() -> void:
	draw_circle(Vector2(0, 8), interaction_radius + 10.0, Color(0.05, 0.03, 0.02, 0.28))
	draw_circle(Vector2.ZERO, interaction_radius + 4.0, Color(0.18, 0.11, 0.07, 0.48))
	draw_arc(Vector2.ZERO, interaction_radius + 4.0, 0.0, TAU, 72, Color(0.80, 0.70, 0.48, 0.20), 3.0, true)
	var chest_rect := Rect2(Vector2(-34, -22), Vector2(68, 44))
	draw_rect(chest_rect.grow(6.0), Color(0.02, 0.01, 0.0, 0.28), true)
	draw_rect(chest_rect, Color(0.34, 0.20, 0.10), true)
	draw_rect(chest_rect, Color(0.85, 0.70, 0.42, 0.64), false, 3.0)
	draw_line(chest_rect.position + Vector2(0, 20), chest_rect.position + Vector2(chest_rect.size.x, 20), Color(0.12, 0.06, 0.03), 3.0)
	draw_circle(Vector2(0, 4), 5.0, Color(0.90, 0.70, 0.30))

func _draw_large_tree() -> void:
	draw_circle(Vector2(0, 22), 36.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_arc(Vector2(0, 20), collision_radius, 0.0, TAU, 48, Color(0.02, 0.02, 0.01, 0.18), 2.0, true)
	draw_line(Vector2(0, 24), Vector2(0, -42), Color(0.14, 0.08, 0.04, 0.88), 13.0)
	draw_line(Vector2(-12, -4), Vector2(-30, -42), Color(0.14, 0.08, 0.04, 0.58), 6.0)
	draw_line(Vector2(10, -12), Vector2(34, -49), Color(0.14, 0.08, 0.04, 0.58), 6.0)
	var leaf := Color(0.08, 0.18, 0.10, 0.92)
	draw_circle(Vector2(-26, -50), 35.0, leaf)
	draw_circle(Vector2(24, -56), 41.0, leaf.darkened(0.05))
	draw_circle(Vector2(2, -87), 36.0, leaf.lightened(0.04))
	draw_circle(Vector2(-3, -42), 33.0, leaf.darkened(0.02))

func _draw_large_rock() -> void:
	draw_circle(Vector2(0, 17), visual_size.x * 0.44, Color(0.0, 0.0, 0.0, 0.28))
	var half := visual_size * 0.5
	draw_colored_polygon(PackedVector2Array([
		Vector2(-half.x, 10),
		Vector2(-half.x * 0.58, -half.y * 0.75),
		Vector2(half.x * 0.16, -half.y),
		Vector2(half.x * 0.84, -half.y * 0.45),
		Vector2(half.x, 10),
		Vector2(half.x * 0.26, half.y),
		Vector2(-half.x * 0.62, half.y * 0.72),
	]), Color(0.46, 0.48, 0.45))
	draw_polyline(PackedVector2Array([
		Vector2(-half.x * 0.5, -6),
		Vector2(-8, -18),
		Vector2(half.x * 0.35, -10),
	]), Color(0.82, 0.82, 0.76, 0.30), 2.0)
	draw_arc(Vector2.ZERO, collision_radius, 0.0, TAU, 40, Color(0.0, 0.0, 0.0, 0.10), 1.0, true)

func _draw_campfire() -> void:
	draw_circle(Vector2(0, 3), 52.0, Color(0.95, 0.36, 0.10, 0.08))
	draw_circle(Vector2(0, 6), 38.0, Color(1.00, 0.58, 0.20, 0.10))
	draw_circle(Vector2(0, 12), 30.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_arc(Vector2(0, 8), 34.0, 0.0, TAU, 64, Color(0.98, 0.68, 0.32, 0.36), 2.0, true)
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var point := Vector2(cos(angle), sin(angle) * 0.62) * 22.0 + Vector2(0, 8)
		draw_circle(point, 8.0, Color(0.36, 0.35, 0.31))
		draw_arc(point, 8.0, -0.4, 1.2, 10, Color(0.76, 0.72, 0.60, 0.20), 1.2, true)
	draw_line(Vector2(-20, 15), Vector2(18, -4), Color(0.38, 0.20, 0.09), 7.0)
	draw_line(Vector2(19, 15), Vector2(-17, -5), Color(0.30, 0.15, 0.07), 7.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -30),
		Vector2(14, -2),
		Vector2(3, 17),
		Vector2(-13, 2),
	]), Color(0.93, 0.34, 0.10, 0.82))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -20),
		Vector2(8, -1),
		Vector2(0, 12),
		Vector2(-7, 0),
	]), Color(1.0, 0.74, 0.26, 0.92))
	draw_line(Vector2(-8, -28), Vector2(-18, -48), Color(0.86, 0.70, 0.42, 0.18), 2.0)
	draw_line(Vector2(8, -26), Vector2(20, -44), Color(0.86, 0.70, 0.42, 0.16), 2.0)
	draw_circle(Vector2(0, 9), 10.0, Color(0.18, 0.12, 0.08, 0.48))

func _draw_launcher() -> void:
	var pulse := 1.0 + (0.06 if launcher_highlighted else 0.0)
	var marker_alpha := 0.18 if launcher_highlighted else 0.08
	draw_circle(Vector2(0, 12), interaction_radius * 0.42 * pulse, Color(0.88, 0.75, 0.42, marker_alpha))
	if launcher_highlighted:
		draw_arc(Vector2(0, 12), interaction_radius * 0.45, 0.0, TAU, 56, Color(0.96, 0.82, 0.48, 0.62), 2.0, true)
	match visual_kind:
		"arena_gate":
			_draw_launcher_arena_gate()
		"workbench":
			_draw_launcher_workbench()
		"shop_stall":
			_draw_launcher_shop_stall()
		"social_totem":
			_draw_launcher_social_totem()
		"profile_shrine":
			_draw_launcher_profile_shrine()
		_:
			draw_circle(Vector2.ZERO, 24.0, Color(0.56, 0.48, 0.34))

func _draw_launcher_arena_gate() -> void:
	var accent := Color(0.82, 0.34, 0.22).lightened(0.10 if launcher_highlighted else 0.0)
	draw_circle(Vector2(0, 27), 36.0, Color(0.0, 0.0, 0.0, 0.30))
	draw_line(Vector2(-30, 26), Vector2(-30, -36), Color(0.20, 0.14, 0.10), 12.0)
	draw_line(Vector2(30, 26), Vector2(30, -36), Color(0.20, 0.14, 0.10), 12.0)
	draw_arc(Vector2(0, -34), 30.0, PI, TAU, 32, accent, 9.0, true)
	draw_line(Vector2(-18, 20), Vector2(18, -12), Color(0.86, 0.58, 0.34), 4.0)
	draw_line(Vector2(18, 20), Vector2(-18, -12), Color(0.86, 0.58, 0.34), 4.0)

func _draw_launcher_workbench() -> void:
	var wood := Color(0.44, 0.24, 0.11).lightened(0.08 if launcher_highlighted else 0.0)
	draw_circle(Vector2(0, 20), 34.0, Color(0.0, 0.0, 0.0, 0.26))
	draw_rect(Rect2(Vector2(-38, -12), Vector2(76, 24)), wood, true)
	draw_line(Vector2(-26, 8), Vector2(-34, 34), Color(0.24, 0.12, 0.05), 6.0)
	draw_line(Vector2(26, 8), Vector2(34, 34), Color(0.24, 0.12, 0.05), 6.0)
	draw_line(Vector2(-10, -18), Vector2(26, -31), Color(0.70, 0.66, 0.56), 6.0)
	draw_circle(Vector2(-18, -14), 8.0, Color(0.55, 0.52, 0.46))

func _draw_launcher_shop_stall() -> void:
	var cloth := Color(0.75, 0.48, 0.22).lightened(0.10 if launcher_highlighted else 0.0)
	draw_circle(Vector2(0, 23), 39.0, Color(0.0, 0.0, 0.0, 0.26))
	draw_rect(Rect2(Vector2(-38, -10), Vector2(76, 42)), Color(0.36, 0.20, 0.10), true)
	for index in range(4):
		var x := -38.0 + float(index) * 19.0
		draw_rect(Rect2(Vector2(x, -34), Vector2(19, 24)), cloth if index % 2 == 0 else Color(0.86, 0.75, 0.48), true)
	draw_line(Vector2(-42, -10), Vector2(42, -10), Color(0.18, 0.09, 0.04), 4.0)
	draw_circle(Vector2(-22, 32), 8.0, Color(0.10, 0.07, 0.04))
	draw_circle(Vector2(22, 32), 8.0, Color(0.10, 0.07, 0.04))

func _draw_launcher_social_totem() -> void:
	var stone := Color(0.38, 0.42, 0.37).lightened(0.08 if launcher_highlighted else 0.0)
	draw_circle(Vector2(0, 24), 28.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_rect(Rect2(Vector2(-15, -40), Vector2(30, 74)), stone, true)
	draw_rect(Rect2(Vector2(-12, -36), Vector2(24, 22)), Color(0.16, 0.24, 0.18), true)
	draw_circle(Vector2(-6, -24), 4.0, Color(0.92, 0.78, 0.42))
	draw_circle(Vector2(6, -24), 4.0, Color(0.92, 0.78, 0.42))
	draw_line(Vector2(-10, 1), Vector2(10, 1), Color(0.82, 0.72, 0.46), 3.0)
	draw_circle(Vector2(0, 23), 8.0, Color(0.30, 0.54, 0.34))

func _draw_launcher_profile_shrine() -> void:
	var stone := Color(0.46, 0.43, 0.38).lightened(0.10 if launcher_highlighted else 0.0)
	draw_circle(Vector2(0, 25), 31.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -44),
		Vector2(25, -12),
		Vector2(18, 32),
		Vector2(-18, 32),
		Vector2(-25, -12),
	]), stone)
	draw_circle(Vector2(0, -11), 14.0, Color(0.20, 0.18, 0.16))
	draw_arc(Vector2(0, -11), 9.0, 0.2, TAU - 0.2, 30, Color(0.86, 0.74, 0.44), 2.0, true)
	draw_line(Vector2(-13, 13), Vector2(13, 13), Color(0.86, 0.74, 0.44), 3.0)

func _draw_resource_pickup_marker(highlighted: bool) -> void:
	var radius := 32.0 if highlighted else 27.0
	var marker_color := Color(0.93, 0.76, 0.38, 0.22 if highlighted else 0.13)
	draw_circle(Vector2(0, 8), radius, Color(marker_color.r, marker_color.g, marker_color.b, marker_color.a * 0.42))
	draw_arc(Vector2(0, 8), radius, 0.0, TAU, 48, marker_color, 1.5, true)
	draw_arc(Vector2(0, 8), radius * 0.62, 0.3, TAU + 0.3, 48, Color(marker_color.r, marker_color.g, marker_color.b, marker_color.a * 0.72), 1.0, true)
	for index in range(3):
		var angle := TAU * float(index) / 3.0 - PI * 0.5
		draw_circle(Vector2(0, 8) + Vector2(cos(angle), sin(angle)) * (radius + 3.0), 2.0, Color(1.0, 0.88, 0.56, 0.44 if highlighted else 0.26))

func _draw_resource_icon(resource_item_id: String, highlighted: bool) -> void:
	draw_circle(Vector2(0, 8), 17.0, Color(0.0, 0.0, 0.0, 0.30))
	match resource_item_id:
		"galho":
			_draw_branch(highlighted)
		"folha", "folha_seca":
			_draw_leaf(highlighted, resource_item_id == "folha_seca")
		"madeira":
			_draw_log(highlighted)
		"pedra", "pedra_pequena":
			_draw_stone(highlighted, resource_item_id == "pedra_pequena")
		"cogumelo", "fungo":
			_draw_mushroom(highlighted, resource_item_id == "fungo")
		"inseto":
			_draw_insect(highlighted)
		"resina":
			_draw_resin(highlighted)
		"cinzas_preview":
			_draw_ash(highlighted)
		"resto_ritual", "po_cinzento", "ossos_preview", "po_osso_preview":
			_draw_bone(highlighted, resource_item_id == "po_cinzento" or resource_item_id == "po_osso_preview")
		_:
			draw_circle(Vector2.ZERO, 14.0, Color(0.55, 0.55, 0.50))
	if highlighted:
		draw_arc(Vector2.ZERO, 24.0, 0.0, TAU, 40, Color(0.95, 0.83, 0.55, 0.80), 2.0, true)

func _draw_branch(highlighted: bool) -> void:
	var color := Color(0.50, 0.32, 0.16).lightened(0.12 if highlighted else 0.0)
	draw_line(Vector2(-18, 11), Vector2(17, -9), color, 6.0)
	draw_line(Vector2(-2, 0), Vector2(11, 12), color, 4.0)

func _draw_leaf(highlighted: bool, dry: bool) -> void:
	var color := Color(0.56, 0.42, 0.19) if dry else Color(0.24, 0.55, 0.25)
	color = color.lightened(0.10 if highlighted else 0.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -20),
		Vector2(18, 0),
		Vector2(0, 20),
		Vector2(-16, 0),
	]), color)
	draw_line(Vector2(0, -16), Vector2(0, 16), Color(0.88, 0.82, 0.54, 0.52), 2.0)

func _draw_log(highlighted: bool) -> void:
	var color := Color(0.42, 0.24, 0.11).lightened(0.10 if highlighted else 0.0)
	var rect := Rect2(Vector2(-23, -12), Vector2(46, 24))
	draw_rect(rect, color, true)
	draw_rect(rect, Color(0.22, 0.11, 0.04), false, 3.0)
	draw_circle(Vector2(-20, 0), 12.0, Color(0.62, 0.42, 0.22))
	draw_arc(Vector2(-20, 0), 7.0, 0.0, TAU, 24, Color(0.30, 0.15, 0.06), 2.0, true)

func _draw_stone(highlighted: bool, small: bool) -> void:
	var radius := 13.0 if small else 18.0
	var color := Color(0.54, 0.56, 0.54).lightened(0.08 if highlighted else 0.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(-radius, 5),
		Vector2(-7, -radius),
		Vector2(12, -radius * 0.75),
		Vector2(radius, 7),
		Vector2(3, radius),
	]), color)
	draw_line(Vector2(-4, -7), Vector2(9, 2), Color(0.80, 0.82, 0.78, 0.35), 2.0)

func _draw_mushroom(highlighted: bool, purple: bool) -> void:
	var cap := Color(0.40, 0.23, 0.52) if purple else Color(0.62, 0.18, 0.22)
	cap = cap.lightened(0.09 if highlighted else 0.0)
	draw_rect(Rect2(Vector2(-5, -1), Vector2(10, 18)), Color(0.77, 0.69, 0.53), true)
	draw_circle(Vector2(0, -7), 18.0, cap)
	draw_rect(Rect2(Vector2(-18, -7), Vector2(36, 12)), cap, true)

func _draw_insect(highlighted: bool) -> void:
	var color := Color(0.15, 0.11, 0.08).lightened(0.12 if highlighted else 0.0)
	draw_circle(Vector2.ZERO, 10.0, color)
	draw_circle(Vector2(0, -12), 7.0, color)
	for side in [-1.0, 1.0]:
		draw_line(Vector2(side * 4.0, -2), Vector2(side * 18.0, -10), color, 2.0)
		draw_line(Vector2(side * 5.0, 4), Vector2(side * 19.0, 10), color, 2.0)

func _draw_resin(highlighted: bool) -> void:
	var color := Color(0.90, 0.56, 0.14).lightened(0.08 if highlighted else 0.0)
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -21),
		Vector2(16, 0),
		Vector2(7, 19),
		Vector2(-12, 15),
		Vector2(-16, -3),
	]), color)
	draw_circle(Vector2(3, -3), 5.0, Color(1.0, 0.86, 0.38, 0.42))

func _draw_ash(highlighted: bool) -> void:
	var color := Color(0.58, 0.58, 0.54).lightened(0.08 if highlighted else 0.0)
	draw_circle(Vector2(-8, 5), 12.0, color)
	draw_circle(Vector2(8, 4), 10.0, color.darkened(0.10))
	draw_circle(Vector2(0, -5), 9.0, Color(0.75, 0.73, 0.66, 0.75))

func _draw_bone(highlighted: bool, powder: bool) -> void:
	var color := Color(0.82, 0.78, 0.62).lightened(0.08 if highlighted else 0.0)
	if powder:
		for index in range(5):
			draw_circle(Vector2(float(index - 2) * 6.0, sin(float(index)) * 6.0), 5.0, color)
		return
	draw_line(Vector2(-17, 10), Vector2(17, -10), color, 8.0)
	draw_circle(Vector2(-18, 10), 7.0, color)
	draw_circle(Vector2(18, -10), 7.0, color)
