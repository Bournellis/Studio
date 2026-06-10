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

	_add_pitch(parent, field_width, field_length)
	_add_pitch_markings(parent, field_width, field_length, goal_half_width, goal_line_north, goal_line_south)
	_add_goal_shell(parent, "North", goal_line_north, -1.0, goal_half_width, goal_height, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, wall_height)
	_add_goal_shell(parent, "South", goal_line_south, 1.0, goal_half_width, goal_height, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, wall_height)
	_add_arena_glass(parent, field_width, field_length, field_half_width, wall_height, ceiling_height, wall_thickness, goal_side_wall_x, goal_closed_depth, goal_line_north, goal_line_south)
	_add_stadium_shell(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south)

static func _add_pitch(parent: Node3D, field_width: float, field_length: float) -> void:
	_add_box(parent, "FootballPitch", Vector3(0.0, -0.5, 0.0), Vector3(field_width, 1.0, field_length), Color(0.07, 0.32, 0.15, 1.0), 0.96, 0.18)
	var stripe_count := 9
	var stripe_length := field_length / float(stripe_count)
	for index in range(stripe_count):
		var z := -field_length * 0.5 + stripe_length * (float(index) + 0.5)
		var color := Color(0.09, 0.39, 0.18, 1.0) if index % 2 == 0 else Color(0.06, 0.29, 0.14, 1.0)
		_add_visual_box(parent, "PitchGrassStripe%d" % index, Vector3(0.0, 0.022, z), Vector3(field_width - 0.9, 0.035, stripe_length - 0.08), color)

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

static func _add_goal_shell(parent: Node3D, prefix: String, goal_line: float, side: float, goal_half_width: float, goal_height: float, goal_side_wall_x: float, side_wall_thickness: float, goal_closed_depth: float, wall_height: float) -> void:
	var goal_center_z := goal_line + side * goal_closed_depth * 0.5
	_add_box(parent, "%sGoalFloor" % prefix, Vector3(0.0, -0.5, goal_center_z), Vector3(goal_half_width * 2.45, 1.0, goal_closed_depth), Color(0.07, 0.28, 0.14, 1.0), 0.96, 0.16)
	_add_goal_side_walls(parent, prefix, goal_center_z, goal_side_wall_x, side_wall_thickness, goal_closed_depth, wall_height)
	_add_glass_box(parent, "%sBackGlass" % prefix, Vector3(0.0, wall_height * 0.5, goal_line + side * goal_closed_depth), Vector3(goal_half_width * 2.45, wall_height, 0.5), 0.44)
	_add_goal_roof(parent, prefix, goal_center_z, goal_line, side, goal_half_width, goal_height, goal_closed_depth)
	_add_goal_frame(parent, prefix, goal_line + side * 0.22, side, goal_half_width, goal_height, goal_closed_depth)

static func _add_goal_side_walls(parent: Node3D, prefix: String, goal_center_z: float, goal_side_wall_x: float, side_wall_thickness: float, goal_closed_depth: float, wall_height: float) -> void:
	var side_wall_color := Color(0.34, 0.86, 1.0, 0.36)
	var side_size := Vector3(side_wall_thickness, wall_height, goal_closed_depth)
	_add_box(parent, "%sGoalSideWallL" % prefix, Vector3(-goal_side_wall_x, wall_height * 0.5, goal_center_z), side_size, side_wall_color, 0.18, 0.72)
	_add_box(parent, "%sGoalSideWallR" % prefix, Vector3(goal_side_wall_x, wall_height * 0.5, goal_center_z), side_size, side_wall_color, 0.18, 0.72)

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
	_add_visual_box(parent, "%sNetTint" % prefix, Vector3(0.0, goal_height * 0.5, goal_z + side * 0.62), Vector3(goal_half_width * 2.0, goal_height * 0.92, 0.12), Color(0.22, 0.68, 0.92, 0.72))

static func _add_arena_glass(parent: Node3D, field_width: float, field_length: float, field_half_width: float, wall_height: float, ceiling_height: float, wall_thickness: float, goal_side_wall_x: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var total_length := field_length + goal_closed_depth * 2.0
	_add_glass_box(parent, "WestGlassWall", Vector3(-field_half_width, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, total_length))
	_add_glass_box(parent, "EastGlassWall", Vector3(field_half_width, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, total_length))
	var end_wall_span := (field_half_width - goal_side_wall_x) - wall_thickness * 0.5
	var end_wall_center_x := goal_side_wall_x + end_wall_span * 0.5
	_add_glass_box(parent, "NorthGlassWallLeft", Vector3(-end_wall_center_x, wall_height * 0.5, goal_line_north), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "NorthGlassWallRight", Vector3(end_wall_center_x, wall_height * 0.5, goal_line_north), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "SouthGlassWallLeft", Vector3(-end_wall_center_x, wall_height * 0.5, goal_line_south), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "SouthGlassWallRight", Vector3(end_wall_center_x, wall_height * 0.5, goal_line_south), Vector3(end_wall_span, wall_height, wall_thickness))
	_add_glass_box(parent, "ArenaGlassCeiling", Vector3(0.0, ceiling_height, 0.0), Vector3(field_width, 0.55, total_length), 0.42)
	_add_glass_frames(parent, field_width, field_half_width, total_length, wall_height, ceiling_height, goal_line_north, goal_line_south, end_wall_center_x, end_wall_span, wall_thickness)

static func _add_glass_frames(parent: Node3D, field_width: float, field_half_width: float, total_length: float, wall_height: float, ceiling_height: float, goal_line_north: float, goal_line_south: float, end_wall_center_x: float, end_wall_span: float, wall_thickness: float) -> void:
	var frame_color := Color(0.78, 0.96, 1.0, 0.96)
	_add_neon_box(parent, "WestGlassFrameTop", Vector3(-field_half_width, wall_height + 0.08, 0.0), Vector3(0.24, 0.22, total_length), frame_color, Vector3.ZERO, 2.15)
	_add_neon_box(parent, "EastGlassFrameTop", Vector3(field_half_width, wall_height + 0.08, 0.0), Vector3(0.24, 0.22, total_length), frame_color, Vector3.ZERO, 2.15)
	_add_neon_box(parent, "WestGlassFrameMid", Vector3(-field_half_width, wall_height * 0.52, 0.0), Vector3(0.18, 0.16, total_length), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.55)
	_add_neon_box(parent, "EastGlassFrameMid", Vector3(field_half_width, wall_height * 0.52, 0.0), Vector3(0.18, 0.16, total_length), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.55)
	for index in range(8):
		var z := -total_length * 0.5 + total_length * float(index) / 7.0
		_add_neon_box(parent, "WestGlassFramePost%d" % index, Vector3(-field_half_width, wall_height * 0.5, z), Vector3(0.24, wall_height + 0.25, 0.2), frame_color, Vector3.ZERO, 2.0)
		_add_neon_box(parent, "EastGlassFramePost%d" % index, Vector3(field_half_width, wall_height * 0.5, z), Vector3(0.24, wall_height + 0.25, 0.2), frame_color, Vector3.ZERO, 2.0)
	for side_name in ["North", "South"]:
		var z_line := goal_line_north if side_name == "North" else goal_line_south
		_add_neon_box(parent, "%sGlassFrameTopLeft" % side_name, Vector3(-end_wall_center_x, wall_height + 0.08, z_line), Vector3(end_wall_span, 0.22, 0.24), frame_color, Vector3.ZERO, 2.0)
		_add_neon_box(parent, "%sGlassFrameTopRight" % side_name, Vector3(end_wall_center_x, wall_height + 0.08, z_line), Vector3(end_wall_span, 0.22, 0.24), frame_color, Vector3.ZERO, 2.0)
		_add_neon_box(parent, "%sGlassFrameMidLeft" % side_name, Vector3(-end_wall_center_x, wall_height * 0.52, z_line), Vector3(end_wall_span, 0.16, 0.18), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.5)
		_add_neon_box(parent, "%sGlassFrameMidRight" % side_name, Vector3(end_wall_center_x, wall_height * 0.52, z_line), Vector3(end_wall_span, 0.16, 0.18), Color(0.62, 0.88, 1.0, 0.72), Vector3.ZERO, 1.5)
	_add_neon_box(parent, "ArenaCornerPostNW", Vector3(-field_half_width, wall_height * 0.5, goal_line_north), Vector3(0.34, wall_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaCornerPostNE", Vector3(field_half_width, wall_height * 0.5, goal_line_north), Vector3(0.34, wall_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaCornerPostSW", Vector3(-field_half_width, wall_height * 0.5, goal_line_south), Vector3(0.34, wall_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
	_add_neon_box(parent, "ArenaCornerPostSE", Vector3(field_half_width, wall_height * 0.5, goal_line_south), Vector3(0.34, wall_height + 0.35, 0.34), frame_color, Vector3.ZERO, 2.2)
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
		_add_visual_box(parent, "NorthCrowdBand%d" % index, Vector3(x, 2.75, goal_line_north - goal_closed_depth - 4.65), Vector3(2.25, 1.0, 0.2), color)
		_add_visual_box(parent, "SouthCrowdBand%d" % index, Vector3(x, 2.75, goal_line_south + goal_closed_depth + 4.65), Vector3(2.25, 1.0, 0.2), color)
	for side: float in [-1.0, 1.0]:
		var x_side := side * (field_half_width + 4.1)
		var side_prefix := "East" if side > 0.0 else "West"
		for index in range(8):
			var z := -field_length * 0.5 + 4.0 + float(index) * ((field_length - 8.0) / 7.0)
			var color: Color = crowd_colors[(index + (1 if side > 0.0 else 3)) % crowd_colors.size()]
			_add_visual_box(parent, "%sCrowdBand%d" % [side_prefix, index], Vector3(x_side, 2.35, z), Vector3(0.2, 0.95, 2.35), color)

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
	var banner_count := 8
	for index in range(banner_count):
		var x := -field_width * 0.5 + 3.0 + float(index) * ((field_width - 6.0) / float(banner_count - 1))
		var north_z := goal_line_north - goal_closed_depth - 6.0
		var south_z := goal_line_south + goal_closed_depth + 6.0
		_add_banner(parent, "NorthCountryBanner%d" % index, Vector3(x, 4.25, north_z), Vector3(2.7, 1.05, 0.12), banner_sets[index % banner_sets.size()])
		_add_banner(parent, "SouthCountryBanner%d" % index, Vector3(x, 4.25, south_z), Vector3(2.7, 1.05, 0.12), banner_sets[(index + 3) % banner_sets.size()])

static func _add_banner(parent: Node3D, node_name: String, center: Vector3, size: Vector3, colors: Array) -> void:
	_add_visual_box(parent, node_name, center, size + Vector3(0.16, 0.16, 0.02), Color(0.94, 0.94, 0.88, 1.0))
	for stripe_index in range(3):
		var stripe_y := center.y + (float(stripe_index) - 1.0) * size.y / 3.0
		var color: Color = colors[stripe_index]
		_add_visual_box(parent, "%sStripe%d" % [node_name, stripe_index], Vector3(center.x, stripe_y, center.z - 0.015), Vector3(size.x, size.y / 3.0, size.z + 0.04), color)

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
