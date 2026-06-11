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
	var goal_height: float = float(config.get("goal_height", 3.45))
	var goal_side_wall_x: float = float(config.get("goal_side_wall_x", goal_half_width + 0.62))
	var goal_side_wall_thickness: float = float(config.get("goal_side_wall_thickness", 0.55))
	var goal_closed_depth: float = float(config.get("goal_closed_depth", 2.9))
	var goal_line_north: float = float(config.get("goal_line_north", -field_half_length))
	var goal_line_south: float = float(config.get("goal_line_south", field_half_length))

	_add_pitch(parent, field_width, field_length, goal_half_width)
	_add_goal_shell(parent, "North", goal_line_north, -1.0, goal_half_width, goal_height, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, ceiling_height, wall_thickness)
	_add_goal_shell(parent, "South", goal_line_south, 1.0, goal_half_width, goal_height, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, ceiling_height, wall_thickness)
	_add_arena_glass(parent, field_width, field_length, field_half_width, wall_height, ceiling_height, wall_thickness, goal_side_wall_x, goal_closed_depth, goal_line_north, goal_line_south)
	_add_stadium_shell(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south)
	_add_arcade_field(parent, field_half_width, field_half_length, goal_line_north, goal_line_south)

static func _add_pitch(parent: Node3D, field_width: float, field_length: float, goal_half_width: float) -> void:
	var pitch := _add_box(parent, "FootballPitch", Vector3(0.0, -0.5, 0.0), Vector3(field_width, 1.0, field_length), Color(0.07, 0.32, 0.15, 1.0), 0.96, 0.18)
	var pitch_mesh := pitch.get_node_or_null("FootballPitchMesh") as MeshInstance3D
	if pitch_mesh != null:
		pitch_mesh.material_override = _build_pitch_material(field_width, field_length, goal_half_width)

static func _add_pitch_markings(parent: Node3D, field_width: float, field_length: float, goal_half_width: float, goal_line_north: float, goal_line_south: float) -> void:
	var line_color := Color(0.92, 0.96, 0.86, 1.0)
	_add_visual_box(parent, "CenterLine", Vector3(0.0, 0.07, 0.0), Vector3(field_width - 1.5, 0.055, 0.14), line_color)
	_add_visual_box(parent, "MidStripe", Vector3(0.0, 0.068, 0.0), Vector3(0.14, 0.055, field_length - 2.0), Color(0.12, 0.42, 0.19, 1.0))
	_add_circle_segments(parent, "CenterCircle", Vector3.ZERO, 3.8, 28, line_color)
	_add_penalty_box_markings(parent, "North", goal_line_north, 1.0, goal_half_width, line_color)
	_add_penalty_box_markings(parent, "South", goal_line_south, -1.0, goal_half_width, line_color)
	_add_visual_box(parent, "NorthGoalMouth", Vector3(0.0, 0.08, goal_line_north + 0.45), Vector3(goal_half_width * 2.0, 0.08, 0.34), Color(1.0, 0.88, 0.24, 1.0))
	_add_visual_box(parent, "SouthGoalMouth", Vector3(0.0, 0.08, goal_line_south - 0.45), Vector3(goal_half_width * 2.0, 0.08, 0.34), Color(1.0, 0.88, 0.24, 1.0))

static func _add_penalty_box_markings(parent: Node3D, prefix: String, goal_line: float, inward_direction: float, goal_half_width: float, line_color: Color) -> void:
	var box_depth := 6.1
	var box_width := goal_half_width * 2.55
	var center_z := goal_line + inward_direction * box_depth * 0.5
	_add_visual_box(parent, "%sGoalBoxFrontLine" % prefix, Vector3(0.0, 0.075, goal_line + inward_direction * box_depth), Vector3(box_width, 0.055, 0.14), line_color)
	_add_visual_box(parent, "%sGoalBoxLeftLine" % prefix, Vector3(-box_width * 0.5, 0.075, center_z), Vector3(0.14, 0.055, box_depth), line_color)
	_add_visual_box(parent, "%sGoalBoxRightLine" % prefix, Vector3(box_width * 0.5, 0.075, center_z), Vector3(0.14, 0.055, box_depth), line_color)
	_add_visual_box(parent, "%sPenaltySpot" % prefix, Vector3(0.0, 0.085, goal_line + inward_direction * 4.2), Vector3(0.34, 0.06, 0.34), Color(1.0, 0.88, 0.24, 1.0))

static func _add_circle_segments(parent: Node3D, prefix: String, center: Vector3, radius: float, segment_count: int, color: Color) -> void:
	var segment_length := TAU * radius / float(segment_count) * 0.72
	for index in range(segment_count):
		var angle := TAU * float(index) / float(segment_count)
		var x := center.x + cos(angle) * radius
		var z := center.z + sin(angle) * radius
		var yaw := -rad_to_deg(angle)
		_add_visual_box(parent, "%sSegment%d" % [prefix, index], Vector3(x, 0.082, z), Vector3(segment_length, 0.055, 0.09), color, Vector3(0.0, yaw, 0.0))

static func _add_goal_shell(parent: Node3D, prefix: String, goal_line: float, side: float, goal_half_width: float, goal_height: float, goal_side_wall_x: float, side_wall_thickness: float, goal_closed_depth: float, ceiling_height: float, wall_thickness: float) -> void:
	var goal_center_z := goal_line + side * goal_closed_depth * 0.5
	_add_box(parent, "%sGoalFloor" % prefix, Vector3(0.0, -0.5, goal_center_z), Vector3(goal_half_width * 2.45, 1.0, goal_closed_depth), Color(0.07, 0.28, 0.14, 1.0), 0.96, 0.16)
	_add_goal_side_walls(parent, prefix, goal_center_z, goal_side_wall_x, side_wall_thickness, goal_closed_depth, ceiling_height)
	_add_glass_box(parent, "%sBackGlass" % prefix, Vector3(0.0, ceiling_height * 0.5, goal_line + side * goal_closed_depth), Vector3(goal_half_width * 2.45, ceiling_height, 0.5), 0.44)
	_add_goal_roof(parent, prefix, goal_center_z, goal_line, side, goal_half_width, goal_height, goal_closed_depth)
	_add_goal_frame(parent, prefix, goal_line + side * 0.22, side, goal_half_width, goal_height, goal_closed_depth)
	_add_goal_front_top_panel(parent, prefix, goal_line, goal_half_width, goal_height, goal_side_wall_x, side_wall_thickness, ceiling_height, wall_thickness)

static func _add_goal_side_walls(parent: Node3D, prefix: String, goal_center_z: float, goal_side_wall_x: float, side_wall_thickness: float, goal_closed_depth: float, ceiling_height: float) -> void:
	var side_wall_color := Color(0.34, 0.86, 1.0, 0.36)
	var side_size := Vector3(side_wall_thickness, ceiling_height, goal_closed_depth)
	_add_box(parent, "%sGoalSideWallL" % prefix, Vector3(-goal_side_wall_x, ceiling_height * 0.5, goal_center_z), side_size, side_wall_color, 0.18, 0.72)
	_add_box(parent, "%sGoalSideWallR" % prefix, Vector3(goal_side_wall_x, ceiling_height * 0.5, goal_center_z), side_size, side_wall_color, 0.18, 0.72)

static func _add_goal_roof(parent: Node3D, prefix: String, goal_center_z: float, goal_line: float, side: float, goal_half_width: float, goal_height: float, goal_closed_depth: float) -> void:
	var roof_y := goal_height + 0.18
	var roof_width := goal_half_width * 2.45
	_add_glass_box(parent, "%sGoalRoofGlass" % prefix, Vector3(0.0, roof_y, goal_center_z), Vector3(roof_width, 0.34, goal_closed_depth), 0.34)
	_add_visual_box(parent, "%sGoalRoofTint" % prefix, Vector3(0.0, roof_y + 0.025, goal_center_z), Vector3(goal_half_width * 2.05, 0.05, goal_closed_depth * 0.88), Color(0.22, 0.68, 0.92, 0.34))
	_add_box(parent, "%sGoalRoofFrontFrame" % prefix, Vector3(0.0, roof_y + 0.08, goal_line + side * 0.08), Vector3(roof_width + 0.22, 0.24, 0.22), Color(0.9, 0.98, 1.0, 1.0), 0.72, 0.0, 2.4, 0.24, 0.12, 0.45, 0.55)
	_add_box(parent, "%sGoalRoofBackFrame" % prefix, Vector3(0.0, roof_y + 0.08, goal_line + side * goal_closed_depth), Vector3(roof_width + 0.22, 0.24, 0.22), Color(0.9, 0.98, 1.0, 1.0), 0.72, 0.0, 2.4, 0.24, 0.12, 0.45, 0.55)
	_add_box(parent, "%sGoalRoofLeftRib" % prefix, Vector3(-roof_width * 0.5, roof_y + 0.08, goal_center_z), Vector3(0.22, 0.24, goal_closed_depth), Color(0.9, 0.98, 1.0, 1.0), 0.72, 0.0, 2.2, 0.24, 0.12, 0.42, 0.5)
	_add_box(parent, "%sGoalRoofRightRib" % prefix, Vector3(roof_width * 0.5, roof_y + 0.08, goal_center_z), Vector3(0.22, 0.24, goal_closed_depth), Color(0.9, 0.98, 1.0, 1.0), 0.72, 0.0, 2.2, 0.24, 0.12, 0.42, 0.5)

static func _add_goal_frame(parent: Node3D, prefix: String, goal_z: float, side: float, goal_half_width: float, goal_height: float, goal_closed_depth: float) -> void:
	var post_color := Color(0.94, 0.98, 1.0, 1.0)
	var post_size := Vector3(0.28, goal_height, 0.28)
	var post_center_y := goal_height * 0.5
	var back_z := goal_z + side * (goal_closed_depth - 0.22)
	_add_box(parent, "%sGoalPostL" % prefix, Vector3(-goal_half_width, post_center_y, goal_z), post_size, post_color, 0.72, 0.0, 2.25, 0.22, 0.1, 0.4, 0.52)
	_add_box(parent, "%sGoalPostR" % prefix, Vector3(goal_half_width, post_center_y, goal_z), post_size, post_color, 0.72, 0.0, 2.25, 0.22, 0.1, 0.4, 0.52)
	_add_box(parent, "%sGoalCrossbar" % prefix, Vector3(0.0, goal_height, goal_z), Vector3(goal_half_width * 2.0 + 0.28, 0.28, 0.28), post_color, 0.72, 0.0, 2.35, 0.22, 0.1, 0.4, 0.52)
	_add_box(parent, "%sGoalBackPostL" % prefix, Vector3(-goal_half_width, post_center_y, back_z), post_size, post_color, 0.72, 0.0, 2.05, 0.24, 0.08, 0.35, 0.48)
	_add_box(parent, "%sGoalBackPostR" % prefix, Vector3(goal_half_width, post_center_y, back_z), post_size, post_color, 0.72, 0.0, 2.05, 0.24, 0.08, 0.35, 0.48)
	_add_box(parent, "%sGoalBackTopBar" % prefix, Vector3(0.0, goal_height, back_z), Vector3(goal_half_width * 2.0 + 0.28, 0.28, 0.28), post_color, 0.72, 0.0, 2.05, 0.24, 0.08, 0.35, 0.48)
	_add_box(parent, "%sGoalTopRailL" % prefix, Vector3(-goal_half_width, goal_height, goal_z + side * goal_closed_depth * 0.5), Vector3(0.24, 0.24, goal_closed_depth), post_color, 0.72, 0.0, 2.0, 0.24, 0.08, 0.35, 0.48)
	_add_box(parent, "%sGoalTopRailR" % prefix, Vector3(goal_half_width, goal_height, goal_z + side * goal_closed_depth * 0.5), Vector3(0.24, 0.24, goal_closed_depth), post_color, 0.72, 0.0, 2.0, 0.24, 0.08, 0.35, 0.48)
	_add_net_panel(parent, "%sNetTint" % prefix, Vector3(0.0, goal_height * 0.5, goal_z + side * 0.62), Vector3(goal_half_width * 2.0, goal_height * 0.92, 0.12))

static func _add_goal_front_top_panel(parent: Node3D, prefix: String, goal_line: float, goal_half_width: float, goal_height: float, goal_side_wall_x: float, side_wall_thickness: float, ceiling_height: float, wall_thickness: float) -> void:
	var bottom_y := goal_height + 0.14
	var panel_height := maxf(0.1, ceiling_height - bottom_y)
	var panel_center_y := bottom_y + panel_height * 0.5
	var panel_width := maxf(goal_half_width * 2.0, goal_side_wall_x * 2.0 - side_wall_thickness)
	_add_glass_box(parent, "%sGoalFrontTopGlass" % prefix, Vector3(0.0, panel_center_y, goal_line), Vector3(panel_width, panel_height, wall_thickness), 0.38)
	var frame_color := Color(0.9, 0.98, 1.0, 1.0)
	_add_neon_box(parent, "%sGoalFrontTopFrame" % prefix, Vector3(0.0, ceiling_height + 0.08, goal_line), Vector3(panel_width + 0.22, 0.22, 0.24), frame_color, Vector3.ZERO, 2.25)
	_add_neon_box(parent, "%sGoalFrontBottomFrame" % prefix, Vector3(0.0, bottom_y, goal_line), Vector3(panel_width + 0.22, 0.18, 0.22), frame_color, Vector3.ZERO, 1.85)
	_add_neon_box(parent, "%sGoalFrontLeftFrame" % prefix, Vector3(-panel_width * 0.5, panel_center_y, goal_line), Vector3(0.2, panel_height, 0.22), frame_color, Vector3.ZERO, 1.9)
	_add_neon_box(parent, "%sGoalFrontRightFrame" % prefix, Vector3(panel_width * 0.5, panel_center_y, goal_line), Vector3(0.2, panel_height, 0.22), frame_color, Vector3.ZERO, 1.9)

static func _add_arena_glass(parent: Node3D, field_width: float, field_length: float, field_half_width: float, wall_height: float, ceiling_height: float, wall_thickness: float, goal_side_wall_x: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var total_length := field_length + goal_closed_depth * 2.0
	var glass_height := ceiling_height
	_add_glass_box(parent, "WestGlassWall", Vector3(-field_half_width, glass_height * 0.5, 0.0), Vector3(wall_thickness, glass_height, total_length))
	_add_glass_box(parent, "EastGlassWall", Vector3(field_half_width, glass_height * 0.5, 0.0), Vector3(wall_thickness, glass_height, total_length))
	var end_wall_span := (field_half_width - goal_side_wall_x) - wall_thickness * 0.5
	var end_wall_center_x := goal_side_wall_x + end_wall_span * 0.5
	_add_glass_box(parent, "NorthGlassWallLeft", Vector3(-end_wall_center_x, glass_height * 0.5, goal_line_north), Vector3(end_wall_span, glass_height, wall_thickness))
	_add_glass_box(parent, "NorthGlassWallRight", Vector3(end_wall_center_x, glass_height * 0.5, goal_line_north), Vector3(end_wall_span, glass_height, wall_thickness))
	_add_glass_box(parent, "SouthGlassWallLeft", Vector3(-end_wall_center_x, glass_height * 0.5, goal_line_south), Vector3(end_wall_span, glass_height, wall_thickness))
	_add_glass_box(parent, "SouthGlassWallRight", Vector3(end_wall_center_x, glass_height * 0.5, goal_line_south), Vector3(end_wall_span, glass_height, wall_thickness))
	_add_glass_box(parent, "ArenaGlassCeiling", Vector3(0.0, ceiling_height, 0.0), Vector3(field_width, 0.55, total_length), 0.42)
	_add_glass_frames(parent, field_width, field_half_width, total_length, glass_height, ceiling_height, goal_line_north, goal_line_south, end_wall_center_x, end_wall_span, wall_thickness)

static func _add_glass_frames(parent: Node3D, field_width: float, field_half_width: float, total_length: float, glass_height: float, ceiling_height: float, goal_line_north: float, goal_line_south: float, end_wall_center_x: float, end_wall_span: float, wall_thickness: float) -> void:
	var frame_color := Color(0.78, 0.96, 1.0, 0.96)
	_add_neon_box(parent, "WestGlassFrameTop", Vector3(-field_half_width, glass_height + 0.08, 0.0), Vector3(0.24, 0.22, total_length), frame_color, Vector3.ZERO, 2.15)
	_add_neon_box(parent, "EastGlassFrameTop", Vector3(field_half_width, glass_height + 0.08, 0.0), Vector3(0.24, 0.22, total_length), frame_color, Vector3.ZERO, 2.15)
	_add_neon_box(parent, "WestGlassFrameMid", Vector3(-field_half_width, glass_height * 0.52, 0.0), Vector3(0.18, 0.16, total_length), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.55)
	_add_neon_box(parent, "EastGlassFrameMid", Vector3(field_half_width, glass_height * 0.52, 0.0), Vector3(0.18, 0.16, total_length), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.55)
	for index in range(8):
		var z := -total_length * 0.5 + total_length * float(index) / 7.0
		_add_neon_box(parent, "WestGlassFramePost%d" % index, Vector3(-field_half_width, glass_height * 0.5, z), Vector3(0.24, glass_height + 0.25, 0.2), frame_color, Vector3.ZERO, 2.0)
		_add_neon_box(parent, "EastGlassFramePost%d" % index, Vector3(field_half_width, glass_height * 0.5, z), Vector3(0.24, glass_height + 0.25, 0.2), frame_color, Vector3.ZERO, 2.0)
	for side_name in ["North", "South"]:
		var z_line := goal_line_north if side_name == "North" else goal_line_south
		_add_neon_box(parent, "%sGlassFrameTopLeft" % side_name, Vector3(-end_wall_center_x, glass_height + 0.08, z_line), Vector3(end_wall_span, 0.22, 0.24), frame_color, Vector3.ZERO, 2.0)
		_add_neon_box(parent, "%sGlassFrameTopRight" % side_name, Vector3(end_wall_center_x, glass_height + 0.08, z_line), Vector3(end_wall_span, 0.22, 0.24), frame_color, Vector3.ZERO, 2.0)
		_add_neon_box(parent, "%sGlassFrameMidLeft" % side_name, Vector3(-end_wall_center_x, glass_height * 0.52, z_line), Vector3(end_wall_span, 0.16, 0.18), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.5)
		_add_neon_box(parent, "%sGlassFrameMidRight" % side_name, Vector3(end_wall_center_x, glass_height * 0.52, z_line), Vector3(end_wall_span, 0.16, 0.18), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.5)
	_add_neon_box(parent, "ArenaCornerPostNW", Vector3(-field_half_width, glass_height * 0.5, goal_line_north), Vector3(0.34, glass_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaCornerPostNE", Vector3(field_half_width, glass_height * 0.5, goal_line_north), Vector3(0.34, glass_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaCornerPostSW", Vector3(-field_half_width, glass_height * 0.5, goal_line_south), Vector3(0.34, glass_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaCornerPostSE", Vector3(field_half_width, glass_height * 0.5, goal_line_south), Vector3(0.34, glass_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaRoofFrameNorth", Vector3(0.0, ceiling_height + 0.18, -total_length * 0.5), Vector3(field_width, 0.22, 0.24), frame_color, Vector3.ZERO, 2.25)
	_add_neon_box(parent, "ArenaRoofFrameSouth", Vector3(0.0, ceiling_height + 0.18, total_length * 0.5), Vector3(field_width, 0.22, 0.24), frame_color, Vector3.ZERO, 2.25)
	_add_neon_box(parent, "ArenaRoofFrameWest", Vector3(-field_half_width, ceiling_height + 0.18, 0.0), Vector3(0.24, 0.22, total_length), frame_color, Vector3.ZERO, 2.25)
	_add_neon_box(parent, "ArenaRoofFrameEast", Vector3(field_half_width, ceiling_height + 0.18, 0.0), Vector3(0.24, 0.22, total_length), frame_color, Vector3.ZERO, 2.25)
	for index in range(5):
		var x := -field_half_width + field_width * (float(index) + 1.0) / 6.0
		_add_neon_box(parent, "ArenaRoofRib%d" % index, Vector3(x, ceiling_height + 0.16, 0.0), Vector3(0.16, 0.18, total_length), Color(0.62, 0.88, 1.0, 0.62), Vector3.ZERO, 1.45)

static func _add_stadium_shell(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	_add_stadium_seating(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south)
	_add_country_banners(parent, field_width, goal_closed_depth, goal_line_north, goal_line_south)
	_add_scoreboards(parent, field_width, goal_closed_depth, goal_line_north, goal_line_south)
	_add_light_rigs(parent, field_half_width, goal_line_north, goal_line_south)

static func _add_arcade_field(parent: Node3D, field_half_width: float, field_half_length: float, goal_line_north: float, goal_line_south: float) -> void:
	_add_boost_pads(parent, field_half_width, field_half_length)
	_add_jump_pads(parent, goal_line_north, goal_line_south)

static func _add_boost_pads(parent: Node3D, field_half_width: float, field_half_length: float) -> void:
	var small_positions: Array[Vector3] = [
		Vector3(-8.5, 0.08, -10.0),
		Vector3(8.5, 0.08, -10.0),
		Vector3(-10.0, 0.08, 0.0),
		Vector3(10.0, 0.08, 0.0),
		Vector3(-8.5, 0.08, 10.0),
		Vector3(8.5, 0.08, 10.0)
	]
	for index in range(small_positions.size()):
		_add_boost_pad(parent, "BoostPadSmall%d" % index, small_positions[index], false)

	var large_positions: Array[Vector3] = [
		Vector3(-field_half_width + 4.2, 0.08, -field_half_length + 5.4),
		Vector3(field_half_width - 4.2, 0.08, field_half_length - 5.4)
	]
	for index in range(large_positions.size()):
		_add_boost_pad(parent, "BoostPadLarge%d" % index, large_positions[index], true)

static func _add_boost_pad(parent: Node3D, node_name: String, pad_position: Vector3, full_pad: bool) -> void:
	var area := Area3D.new()
	area.name = node_name
	area.position = pad_position
	area.set_meta("pad_type", "large" if full_pad else "small")
	area.set_meta("active", true)
	area.add_to_group("football_boost_pad")
	parent.add_child(area)

	var collision := CollisionShape3D.new()
	collision.name = "%sCollision" % node_name
	var shape := CylinderShape3D.new()
	shape.radius = 1.05 if full_pad else 0.78
	shape.height = 0.42
	collision.shape = shape
	area.add_child(collision)

	var disc := MeshInstance3D.new()
	disc.name = "%sDisc" % node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = shape.radius
	mesh.bottom_radius = shape.radius
	mesh.height = 0.08
	mesh.radial_segments = 32
	disc.mesh = mesh
	disc.material_override = RuntimePrimitiveFactoryScript.build_material(
		Color(1.0, 0.74, 0.12, 1.0) if full_pad else Color(0.15, 0.92, 1.0, 1.0),
		2.2 if full_pad else 1.55,
		0.18,
		true
	)
	area.add_child(disc)

static func _add_jump_pads(parent: Node3D, goal_line_north: float, goal_line_south: float) -> void:
	_add_jump_pad(parent, "JumpPadNorth", Vector3(0.0, 0.1, goal_line_north - 2.25))
	_add_jump_pad(parent, "JumpPadSouth", Vector3(0.0, 0.1, goal_line_south + 2.25))

static func _add_jump_pad(parent: Node3D, node_name: String, pad_position: Vector3) -> void:
	var area := Area3D.new()
	area.name = node_name
	area.position = pad_position
	area.add_to_group("football_jump_pad")
	parent.add_child(area)

	var collision := CollisionShape3D.new()
	collision.name = "%sCollision" % node_name
	var shape := CylinderShape3D.new()
	shape.radius = 1.35
	shape.height = 0.5
	collision.shape = shape
	area.add_child(collision)

	var disc := MeshInstance3D.new()
	disc.name = "%sRing" % node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = 1.35
	mesh.bottom_radius = 1.35
	mesh.height = 0.09
	mesh.radial_segments = 36
	disc.mesh = mesh
	disc.material_override = RuntimePrimitiveFactoryScript.build_material(Color(0.72, 0.36, 1.0, 1.0), 2.4, 0.14, true)
	area.add_child(disc)

static func _add_stadium_seating(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var stand_color := Color(0.12, 0.15, 0.18, 1.0)
	var tier_color := Color(0.18, 0.21, 0.24, 1.0)
	for tier in range(3):
		var tier_y := 0.55 + float(tier) * 0.74
		var tier_z_offset := goal_closed_depth + 2.6 + float(tier) * 1.08
		var tier_size := Vector3(field_width + 8.0 + float(tier) * 2.0, 0.7, 1.34)
		_add_visual_box(parent, "NorthStandTier%d" % tier, Vector3(0.0, tier_y, goal_line_north - tier_z_offset), tier_size, stand_color if tier == 0 else tier_color)
		_add_visual_box(parent, "SouthStandTier%d" % tier, Vector3(0.0, tier_y, goal_line_south + tier_z_offset), tier_size, stand_color if tier == 0 else tier_color)
	for tier in range(2):
		var tier_x := field_half_width + 3.2 + float(tier) * 1.25
		var tier_y := 0.64 + float(tier) * 0.72
		var tier_size := Vector3(1.28, 0.72, field_length + 1.5)
		_add_visual_box(parent, "WestStandTier%d" % tier, Vector3(-tier_x, tier_y, 0.0), tier_size, stand_color if tier == 0 else tier_color)
		_add_visual_box(parent, "EastStandTier%d" % tier, Vector3(tier_x, tier_y, 0.0), tier_size, stand_color if tier == 0 else tier_color)
	_add_crowd_tiles(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south)

static func _add_crowd_tiles(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var crowd_colors: Array[Color] = [
		Color(0.9, 0.06, 0.06, 1.0),
		Color(0.95, 0.82, 0.08, 1.0),
		Color(0.08, 0.52, 0.18, 1.0),
		Color(0.14, 0.42, 0.88, 1.0),
		Color(0.96, 0.96, 0.96, 1.0)
	]
	for index in range(14):
		var x := -field_width * 0.5 - 2.0 + float(index) * ((field_width + 4.0) / 13.0)
		var color: Color = crowd_colors[index % crowd_colors.size()]
		_add_crowd_tile(parent, "NorthCrowdBand%d" % index, Vector3(x, 2.75, goal_line_north - goal_closed_depth - 4.65), Vector3(2.25, 1.0, 0.2), color)
		_add_crowd_tile(parent, "SouthCrowdBand%d" % index, Vector3(x, 2.75, goal_line_south + goal_closed_depth + 4.65), Vector3(2.25, 1.0, 0.2), color)
	for side: float in [-1.0, 1.0]:
		var x_side := side * (field_half_width + 4.1)
		var side_prefix := "East" if side > 0.0 else "West"
		for index in range(8):
			var z := -field_length * 0.5 + 4.0 + float(index) * ((field_length - 8.0) / 7.0)
			var color: Color = crowd_colors[(index + (1 if side > 0.0 else 3)) % crowd_colors.size()]
			_add_crowd_tile(parent, "%sCrowdBand%d" % [side_prefix, index], Vector3(x_side, 2.35, z), Vector3(0.2, 0.95, 2.35), color)

static func _add_country_banners(parent: Node3D, field_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var banner_sets: Array = [
		[Color(0.05, 0.46, 0.18, 1.0), Color(0.98, 0.82, 0.05, 1.0), Color(0.08, 0.22, 0.74, 1.0)],
		[Color(0.45, 0.75, 1.0, 1.0), Color(1.0, 1.0, 1.0, 1.0), Color(0.45, 0.75, 1.0, 1.0)],
		[Color(0.0, 0.16, 0.5, 1.0), Color(1.0, 1.0, 1.0, 1.0), Color(0.9, 0.05, 0.08, 1.0)],
		[Color(0.04, 0.04, 0.04, 1.0), Color(0.86, 0.04, 0.04, 1.0), Color(0.95, 0.78, 0.05, 1.0)],
		[Color(0.9, 0.04, 0.04, 1.0), Color(0.95, 0.78, 0.04, 1.0), Color(0.9, 0.04, 0.04, 1.0)],
		[Color(1.0, 1.0, 1.0, 1.0), Color(0.86, 0.04, 0.04, 1.0), Color(1.0, 1.0, 1.0, 1.0)],
		[Color(0.0, 0.42, 0.22, 1.0), Color(0.86, 0.04, 0.04, 1.0), Color(0.95, 0.82, 0.05, 1.0)],
		[Color(1.0, 1.0, 1.0, 1.0), Color(0.86, 0.04, 0.04, 1.0), Color(1.0, 1.0, 1.0, 1.0)]
	]
	var country_names: PackedStringArray = ["BRASIL", "ARG", "FRANCA", "ALEMANHA", "ESPANHA", "INGLATERRA", "PORTUGAL", "JAPAO"]
	var banner_count := 8
	for index in range(banner_count):
		var x := -field_width * 0.5 + 3.0 + float(index) * ((field_width - 6.0) / float(banner_count - 1))
		var north_z := goal_line_north - goal_closed_depth - 6.0
		var south_z := goal_line_south + goal_closed_depth + 6.0
		_add_banner(parent, "NorthCountryBanner%d" % index, Vector3(x, 4.25, north_z), Vector3(2.7, 1.05, 0.12), banner_sets[index % banner_sets.size()], country_names[index % country_names.size()])
		_add_banner(parent, "SouthCountryBanner%d" % index, Vector3(x, 4.25, south_z), Vector3(2.7, 1.05, 0.12), banner_sets[(index + 3) % banner_sets.size()], country_names[(index + 3) % country_names.size()])

static func _add_banner(parent: Node3D, node_name: String, center: Vector3, size: Vector3, colors: Array, label_text: String) -> void:
	_add_visual_box(parent, node_name, center, size + Vector3(0.16, 0.16, 0.02), Color(0.94, 0.94, 0.88, 1.0))
	for stripe_index in range(3):
		var stripe_y := center.y + (float(stripe_index) - 1.0) * size.y / 3.0
		var color: Color = colors[stripe_index]
		_add_visual_box(parent, "%sStripe%d" % [node_name, stripe_index], Vector3(center.x, stripe_y, center.z - 0.015), Vector3(size.x, size.y / 3.0, size.z + 0.04), color)
	var label := Label3D.new()
	label.name = "%sLabel" % node_name
	label.text = label_text
	label.position = center + Vector3(0.0, 0.0, -0.105)
	label.font_size = 26
	label.pixel_size = 0.014
	label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	label.outline_size = 8
	label.outline_modulate = Color(0.02, 0.03, 0.04, 1.0)
	parent.add_child(label)

static func _add_scoreboards(parent: Node3D, field_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var board_size := Vector3(field_width * 0.38, 2.2, 0.22)
	var board_color := Color(0.03, 0.05, 0.08, 1.0)
	for side_name in ["North", "South"]:
		var side := -1.0 if side_name == "North" else 1.0
		var z := (goal_line_north if side_name == "North" else goal_line_south) + side * (goal_closed_depth + 8.0)
		_add_visual_box(parent, "WorldCupScoreboard%s" % side_name, Vector3(0.0, 5.45, z), board_size, board_color)
		_add_visual_box(parent, "WorldCupScoreboard%sGoldBand" % side_name, Vector3(0.0, 6.35, z - side * 0.02), Vector3(board_size.x * 0.92, 0.28, 0.26), Color(1.0, 0.82, 0.08, 1.0))
		_add_visual_box(parent, "WorldCupScoreboard%sBluePanel" % side_name, Vector3(-board_size.x * 0.22, 5.35, z - side * 0.03), Vector3(board_size.x * 0.34, 0.82, 0.28), Color(0.1, 0.32, 0.9, 1.0))
		_add_visual_box(parent, "WorldCupScoreboard%sGreenPanel" % side_name, Vector3(board_size.x * 0.22, 5.35, z - side * 0.03), Vector3(board_size.x * 0.34, 0.82, 0.28), Color(0.04, 0.58, 0.24, 1.0))
		_add_live_scoreboard(parent, side_name, Vector3(0.0, 5.42, z - side * 0.08), Vector3(board_size.x * 0.82, 1.25, 0.08))

static func _add_light_rigs(parent: Node3D, field_half_width: float, goal_line_north: float, goal_line_south: float) -> void:
	var rig_data: Array = [
		["NW", Vector3(-field_half_width - 5.8, 4.6, goal_line_north - 6.4)],
		["NE", Vector3(field_half_width + 5.8, 4.6, goal_line_north - 6.4)],
		["SW", Vector3(-field_half_width - 5.8, 4.6, goal_line_south + 6.4)],
		["SE", Vector3(field_half_width + 5.8, 4.6, goal_line_south + 6.4)]
	]
	for entry in rig_data:
		var label: String = entry[0]
		var position: Vector3 = entry[1]
		_add_visual_box(parent, "StadiumLightRig%s" % label, position - Vector3.UP * 1.8, Vector3(0.42, 3.6, 0.42), Color(0.2, 0.22, 0.26, 1.0))
		_add_neon_box(parent, "StadiumLightBar%s" % label, position + Vector3.UP * 0.25, Vector3(2.0, 0.34, 0.34), Color(1.0, 0.93, 0.72, 1.0), Vector3.ZERO, 4.4, 0.18)
		var light := SpotLight3D.new()
		light.name = "StadiumLight%s" % label
		light.position = position
		light.light_color = Color(1.0, 0.88, 0.62, 1.0)
		light.light_energy = 5.2
		light.spot_range = 58.0
		light.spot_angle = 42.0
		light.spot_angle_attenuation = 0.72
		light.shadow_enabled = false
		parent.add_child(light)
		light.look_at(Vector3(0.0, 1.0, 0.0), Vector3.UP)

static func _add_box(
	parent: Node3D,
	node_name: String,
	node_position: Vector3,
	node_size: Vector3,
	color: Color,
	physics_friction: float = 0.72,
	physics_bounce: float = 0.0,
	emission_energy: float = 0.08,
	roughness: float = 0.72,
	metallic: float = 0.0,
	rim_strength: float = 0.0,
	clearcoat_strength: float = 0.0
) -> StaticBody3D:
	return RuntimePrimitiveFactoryScript.add_static_box(
		parent,
		node_name,
		node_position,
		node_size,
		color,
		Vector3.ZERO,
		emission_energy,
		roughness,
		"%sMesh" % node_name,
		"%sCollision" % node_name,
		physics_friction,
		physics_bounce,
		metallic,
		rim_strength,
		clearcoat_strength
	)

static func _add_glass_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, alpha: float = 0.34) -> StaticBody3D:
	var glass_color := Color(0.34, 0.86, 1.0, alpha)
	var body := RuntimePrimitiveFactoryScript.add_static_box(
		parent,
		node_name,
		node_position,
		node_size,
		glass_color,
		Vector3.ZERO,
		0.68,
		0.1,
		"%sMesh" % node_name,
		"%sCollision" % node_name,
		0.08,
		0.72,
		0.0,
		0.72,
		0.82
	)
	var mesh := body.get_node_or_null("%sMesh" % node_name) as MeshInstance3D
	if mesh != null:
		mesh.material_override = RuntimePrimitiveFactoryScript.build_glass_material(glass_color, 0.68, 0.1)
	return body

static func _add_visual_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color, node_rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	return RuntimePrimitiveFactoryScript.add_visual_box(parent, node_name, node_position, node_size, color, node_rotation_degrees, 0.55, 0.72)

static func _add_neon_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color, node_rotation_degrees: Vector3 = Vector3.ZERO, emission_energy: float = 2.0, roughness: float = 0.24) -> MeshInstance3D:
	return RuntimePrimitiveFactoryScript.add_visual_box(parent, node_name, node_position, node_size, color, node_rotation_degrees, emission_energy, roughness, 0.08, 0.42, 0.38)

static func _add_net_panel(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3) -> MeshInstance3D:
	var mesh := _add_visual_box(parent, node_name, node_position, node_size, Color(0.22, 0.68, 0.92, 0.58))
	mesh.material_override = _build_net_material()
	return mesh

static func _add_crowd_tile(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color) -> MeshInstance3D:
	var mesh := _add_visual_box(parent, node_name, node_position, node_size, color)
	mesh.material_override = _build_crowd_material(color)
	return mesh

static func _add_live_scoreboard(parent: Node3D, side_name: String, node_position: Vector3, node_size: Vector3) -> void:
	var viewport := SubViewport.new()
	viewport.name = "WorldCupScoreboard%sViewport" % side_name
	viewport.size = Vector2i(512, 192)
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	parent.add_child(viewport)

	var root := Control.new()
	root.name = "ScoreRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	viewport.add_child(root)

	var background := ColorRect.new()
	background.name = "Background"
	background.color = Color(0.015, 0.025, 0.04, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(background)

	var top_band := ColorRect.new()
	top_band.name = "TopBand"
	top_band.color = Color(1.0, 0.78, 0.08, 1.0)
	top_band.anchor_right = 1.0
	top_band.offset_bottom = 24.0
	root.add_child(top_band)

	var score_label := Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "BRA 0 - 0 FRA"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_label.add_theme_font_size_override("font_size", 58)
	score_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	score_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	score_label.add_theme_constant_override("shadow_offset_x", 3)
	score_label.add_theme_constant_override("shadow_offset_y", 3)
	root.add_child(score_label)

	var phase_label := Label.new()
	phase_label.name = "PhaseLabel"
	phase_label.text = "FUTEBOL 1x1"
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase_label.anchor_left = 0.0
	phase_label.anchor_right = 1.0
	phase_label.anchor_top = 0.78
	phase_label.anchor_bottom = 1.0
	phase_label.add_theme_font_size_override("font_size", 24)
	phase_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.18, 1.0))
	root.add_child(phase_label)

	var display := _add_visual_box(parent, "WorldCupScoreboard%sLiveDisplay" % side_name, node_position, node_size, Color(1.0, 1.0, 1.0, 1.0))
	var material := StandardMaterial3D.new()
	material.albedo_texture = viewport.get_texture()
	material.emission_enabled = true
	material.emission_texture = viewport.get_texture()
	material.emission_energy_multiplier = 1.25
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	display.material_override = material

static func _build_pitch_material(field_width: float, field_length: float, goal_half_width: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec2 pitch_size = vec2(38.0, 54.0);
uniform float goal_half_width = 4.32;
uniform vec3 grass_dark = vec3(0.045, 0.24, 0.105);
uniform vec3 grass_light = vec3(0.075, 0.36, 0.16);
uniform vec3 line_color = vec3(0.92, 0.98, 0.86);
uniform vec3 gold_color = vec3(1.0, 0.82, 0.18);
varying vec3 local_pos;

void vertex() {
	local_pos = VERTEX;
}

float stroke(float value, float width) {
	return 1.0 - smoothstep(width, width + 0.035, abs(value));
}

float box_outline(vec2 point, vec2 center, vec2 half_size, float width) {
	vec2 d = abs(point - center) - half_size;
	float outside = length(max(d, vec2(0.0)));
	float inside = min(max(d.x, d.y), 0.0);
	float signed_distance = outside + inside;
	return 1.0 - smoothstep(width, width + 0.04, abs(signed_distance));
}

void fragment() {
	vec2 p = vec2(local_pos.x, local_pos.z);
	float stripe_width = pitch_size.y / 9.0;
	float stripe = step(0.5, fract((p.y + pitch_size.y * 0.5) / stripe_width));
	float mowing_noise = sin(p.x * 3.7 + p.y * 0.41) * sin(p.y * 2.9) * 0.025;
	vec3 grass = mix(grass_dark, grass_light, stripe) + vec3(mowing_noise);

	float half_width = pitch_size.x * 0.5;
	float half_length = pitch_size.y * 0.5;
	float line_width = 0.085;
	float line_mask = 0.0;
	line_mask = max(line_mask, stroke(p.y, line_width));
	line_mask = max(line_mask, stroke(length(p) - 3.8, line_width));
	line_mask = max(line_mask, stroke(abs(p.x) - (half_width - 0.55), line_width));
	line_mask = max(line_mask, stroke(abs(p.y) - (half_length - 0.55), line_width));

	float box_depth = 6.1;
	float box_width = goal_half_width * 2.55;
	line_mask = max(line_mask, box_outline(p, vec2(0.0, -half_length + box_depth * 0.5), vec2(box_width * 0.5, box_depth * 0.5), line_width));
	line_mask = max(line_mask, box_outline(p, vec2(0.0, half_length - box_depth * 0.5), vec2(box_width * 0.5, box_depth * 0.5), line_width));

	float spot_mask = 1.0 - smoothstep(0.12, 0.2, length(p - vec2(0.0, -half_length + 4.2)));
	spot_mask = max(spot_mask, 1.0 - smoothstep(0.12, 0.2, length(p - vec2(0.0, half_length - 4.2))));
	float mouth_mask = max(stroke(p.y + half_length - 0.45, 0.16), stroke(p.y - half_length + 0.45, 0.16)) * (1.0 - smoothstep(goal_half_width, goal_half_width + 0.08, abs(p.x)));

	vec3 color = mix(grass, line_color, clamp(line_mask, 0.0, 1.0));
	color = mix(color, gold_color, clamp(max(spot_mask, mouth_mask), 0.0, 1.0));
	ALBEDO = color;
	EMISSION = color * (0.04 + line_mask * 0.08 + mouth_mask * 0.12);
	ROUGHNESS = 0.88;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("pitch_size", Vector2(field_width, field_length))
	material.set_shader_parameter("goal_half_width", goal_half_width)
	return material

static func _build_net_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec3 net_color = vec3(0.38, 0.86, 1.0);
uniform float grid_density = 10.0;
uniform float line_width = 0.055;

void fragment() {
	vec2 grid = abs(fract(UV * grid_density - 0.5) - 0.5) / fwidth(UV * grid_density);
	float line = 1.0 - min(min(grid.x, grid.y), 1.0);
	float alpha = mix(0.16, 0.74, smoothstep(1.0 - line_width, 1.0, line));
	ALBEDO = net_color;
	EMISSION = net_color * smoothstep(0.55, 1.0, line) * 0.85;
	ALPHA = alpha;
	ROUGHNESS = 0.18;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material

static func _build_crowd_material(base_color: Color) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec3 base_color = vec3(0.9, 0.1, 0.1);
varying vec3 local_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void vertex() {
	local_pos = VERTEX;
	float wave = sin(TIME * 2.2 + VERTEX.x * 4.0 + VERTEX.z * 2.1) * 0.035;
	VERTEX.y += wave;
}

void fragment() {
	vec2 cell = floor(UV * vec2(9.0, 3.0));
	float h = hash(cell);
	vec3 seat_color = base_color * (0.72 + h * 0.46);
	seat_color = mix(seat_color, vec3(1.0), step(0.82, h) * 0.35);
	ALBEDO = seat_color;
	EMISSION = seat_color * 0.14;
	ROUGHNESS = 0.64;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", Vector3(base_color.r, base_color.g, base_color.b))
	return material
