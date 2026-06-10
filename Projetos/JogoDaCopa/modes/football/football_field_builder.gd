class_name FootballFieldBuilder
extends RefCounted

const RuntimePrimitiveFactoryScript = preload("res://modes/shared/runtime_primitive_factory.gd")

static func build(parent: Node3D, config: Dictionary) -> void:
	var field_width: float = float(config.get("field_width", 32.0))
	var field_length: float = float(config.get("field_length", 44.0))
	var field_half_width: float = field_width * 0.5
	var field_half_length: float = field_length * 0.5
	var wall_height: float = float(config.get("wall_height", 7.2))
	var ceiling_height: float = float(config.get("ceiling_height", wall_height + 1.6))
	var wall_thickness: float = float(config.get("wall_thickness", 0.8))
	var goal_half_width: float = float(config.get("goal_half_width", 4.1))
	var goal_side_wall_x: float = float(config.get("goal_side_wall_x", goal_half_width + 0.62))
	var goal_side_wall_thickness: float = float(config.get("goal_side_wall_thickness", 0.55))
	var goal_closed_depth: float = float(config.get("goal_closed_depth", 2.9))
	var goal_line_north: float = float(config.get("goal_line_north", -field_half_length))
	var goal_line_south: float = float(config.get("goal_line_south", field_half_length))

	_add_box(parent, "FootballPitch", Vector3(0.0, -0.5, 0.0), Vector3(field_width, 1.0, field_length), Color(0.08, 0.34, 0.16, 1.0), 0.96, 0.18)
	_add_visual_box(parent, "CenterLine", Vector3(0.0, 0.035, 0.0), Vector3(field_width - 1.5, 0.05, 0.14), Color(0.92, 0.96, 0.86, 1.0))
	_add_visual_box(parent, "MidStripe", Vector3(0.0, 0.032, 0.0), Vector3(0.14, 0.05, field_length - 2.0), Color(0.12, 0.42, 0.19, 1.0))
	_add_visual_box(parent, "NorthGoalBox", Vector3(0.0, 0.04, goal_line_north + 5.2), Vector3(goal_half_width * 2.4, 0.05, 0.16), Color(0.92, 0.96, 0.86, 1.0))
	_add_visual_box(parent, "SouthGoalBox", Vector3(0.0, 0.04, goal_line_south - 5.2), Vector3(goal_half_width * 2.4, 0.05, 0.16), Color(0.92, 0.96, 0.86, 1.0))
	_add_visual_box(parent, "NorthGoalMouth", Vector3(0.0, 0.05, goal_line_north + 0.45), Vector3(goal_half_width * 2.0, 0.08, 0.32), Color(1.0, 0.88, 0.24, 1.0))
	_add_visual_box(parent, "SouthGoalMouth", Vector3(0.0, 0.05, goal_line_south - 0.45), Vector3(goal_half_width * 2.0, 0.08, 0.32), Color(1.0, 0.88, 0.24, 1.0))
	_add_box(parent, "NorthGoalFloor", Vector3(0.0, -0.5, goal_line_north - goal_closed_depth * 0.5), Vector3(goal_half_width * 2.45, 1.0, goal_closed_depth), Color(0.07, 0.28, 0.14, 1.0), 0.96, 0.16)
	_add_box(parent, "SouthGoalFloor", Vector3(0.0, -0.5, goal_line_south + goal_closed_depth * 0.5), Vector3(goal_half_width * 2.45, 1.0, goal_closed_depth), Color(0.07, 0.28, 0.14, 1.0), 0.96, 0.16)
	_add_goal_side_walls(parent, "North", goal_line_north - goal_closed_depth * 0.5, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, wall_height)
	_add_goal_side_walls(parent, "South", goal_line_south + goal_closed_depth * 0.5, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, wall_height)

	_add_glass_box(parent, "WestGlassWall", Vector3(-field_half_width, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, field_length + goal_closed_depth * 2.0))
	_add_glass_box(parent, "EastGlassWall", Vector3(field_half_width, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, field_length + goal_closed_depth * 2.0))
	var end_wall_span := (field_half_width - goal_side_wall_x) - wall_thickness * 0.5
	var end_wall_center_x := goal_side_wall_x + end_wall_span * 0.5
	_add_glass_box(parent, "NorthGlassWallLeft", Vector3(-end_wall_center_x, wall_height * 0.5, goal_line_north), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "NorthGlassWallRight", Vector3(end_wall_center_x, wall_height * 0.5, goal_line_north), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "SouthGlassWallLeft", Vector3(-end_wall_center_x, wall_height * 0.5, goal_line_south), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "SouthGlassWallRight", Vector3(end_wall_center_x, wall_height * 0.5, goal_line_south), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "ArenaGlassCeiling", Vector3(0.0, ceiling_height, 0.0), Vector3(field_width, 0.55, field_length + goal_closed_depth * 2.0), 0.48)
	_add_glass_box(parent, "NorthBackGlass", Vector3(0.0, wall_height * 0.5, goal_line_north - goal_closed_depth), Vector3(goal_half_width * 2.45, wall_height, 0.5), 0.44)
	_add_glass_box(parent, "SouthBackGlass", Vector3(0.0, wall_height * 0.5, goal_line_south + goal_closed_depth), Vector3(goal_half_width * 2.45, wall_height, 0.5), 0.44)
	_add_goal_frame(parent, "North", goal_line_north - 0.22, -1.0, goal_half_width)
	_add_goal_frame(parent, "South", goal_line_south + 0.22, 1.0, goal_half_width)
	_add_stadium_bands(parent, field_half_width, goal_line_north, goal_line_south)

static func _add_goal_side_walls(parent: Node3D, prefix: String, goal_center_z: float, goal_side_wall_x: float, side_wall_thickness: float, goal_closed_depth: float, wall_height: float) -> void:
	var side_wall_color := Color(0.34, 0.86, 1.0, 0.36)
	var side_size := Vector3(side_wall_thickness, wall_height, goal_closed_depth)
	_add_box(parent, "%sGoalSideWallL" % prefix, Vector3(-goal_side_wall_x, wall_height * 0.5, goal_center_z), side_size, side_wall_color, 0.18, 0.72)
	_add_box(parent, "%sGoalSideWallR" % prefix, Vector3(goal_side_wall_x, wall_height * 0.5, goal_center_z), side_size, side_wall_color, 0.18, 0.72)

static func _add_goal_frame(parent: Node3D, prefix: String, goal_z: float, side: float, goal_half_width: float) -> void:
	var post_color := Color(0.95, 0.95, 0.9, 1.0)
	_add_box(parent, "%sGoalPostL" % prefix, Vector3(-goal_half_width, 1.15, goal_z), Vector3(0.28, 2.3, 0.28), post_color)
	_add_box(parent, "%sGoalPostR" % prefix, Vector3(goal_half_width, 1.15, goal_z), Vector3(0.28, 2.3, 0.28), post_color)
	_add_box(parent, "%sGoalCrossbar" % prefix, Vector3(0.0, 2.28, goal_z), Vector3(goal_half_width * 2.0 + 0.28, 0.28, 0.28), post_color)
	_add_visual_box(parent, "%sNetTint" % prefix, Vector3(0.0, 1.1, goal_z + side * 0.62), Vector3(goal_half_width * 2.0, 2.1, 0.12), Color(0.22, 0.68, 0.92, 0.72))

static func _add_stadium_bands(parent: Node3D, field_half_width: float, goal_line_north: float, goal_line_south: float) -> void:
	var band_colors: Array[Color] = [
		Color(0.9, 0.06, 0.06, 1.0),
		Color(0.95, 0.82, 0.08, 1.0),
		Color(0.08, 0.52, 0.18, 1.0),
		Color(0.14, 0.42, 0.88, 1.0)
	]
	for index in range(10):
		var x := -18.0 + float(index) * 4.0
		var color := band_colors[index % band_colors.size()]
		_add_visual_box(parent, "NorthCrowdBand%d" % index, Vector3(x, 3.6, goal_line_north - 5.2), Vector3(2.6, 1.35, 0.18), color)
		_add_visual_box(parent, "SouthCrowdBand%d" % index, Vector3(x, 3.6, goal_line_south + 5.2), Vector3(2.6, 1.35, 0.18), color)
	var side_values: Array[float] = [-1.0, 1.0]
	for side: float in side_values:
		var x_side: float = side * (field_half_width + 2.4)
		for index in range(6):
			var z: float = goal_line_north + 6.0 + float(index) * 7.2
			var color := band_colors[(index + (1 if side > 0.0 else 2)) % band_colors.size()]
			_add_visual_box(parent, "SideCrowdBand%s%d" % ["E" if side > 0 else "W", index], Vector3(x_side, 3.2, z), Vector3(0.18, 1.2, 3.1), color)

static func _add_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color, physics_friction: float = 0.72, physics_bounce: float = 0.0) -> StaticBody3D:
	return RuntimePrimitiveFactoryScript.add_static_box(
		parent,
		node_name,
		node_position,
		node_size,
		color,
		Vector3.ZERO,
		0.08,
		0.72,
		"%sMesh" % node_name,
		"%sCollision" % node_name,
		physics_friction,
		physics_bounce
	)

static func _add_glass_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, alpha: float = 0.34) -> StaticBody3D:
	return RuntimePrimitiveFactoryScript.add_static_box(
		parent,
		node_name,
		node_position,
		node_size,
		Color(0.34, 0.86, 1.0, alpha),
		Vector3.ZERO,
		0.28,
		0.18,
		"%sMesh" % node_name,
		"%sCollision" % node_name,
		0.08,
		0.72
	)

static func _add_visual_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color) -> MeshInstance3D:
	return RuntimePrimitiveFactoryScript.add_visual_box(parent, node_name, node_position, node_size, color, Vector3.ZERO, 0.55, 0.72)
