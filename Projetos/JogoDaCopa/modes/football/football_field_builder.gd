class_name FootballFieldBuilder
extends RefCounted

const RuntimePrimitiveFactoryScript = preload("res://modes/shared/runtime_primitive_factory.gd")
const RenderProfileScript = preload("res://autoloads/render_profile.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")
const DEFAULT_PLAYER_KIT_COLOR := Color(0.98, 0.82, 0.06, 1.0)
const DEFAULT_BOT_KIT_COLOR := Color(0.14, 0.42, 0.9, 1.0)
const DEFAULT_COUNTRY_NAMES := ["BRASIL", "FRANCA", "ARGENTINA", "ALEMANHA", "ESPANHA", "INGLATERRA", "PORTUGAL", "JAPAO"]

static var _net_material: ShaderMaterial
static var _crowd_material: ShaderMaterial
static var _flag_material: ShaderMaterial
static var _halo_material_cache: Dictionary = {}

static func debug_get_static_cache_counts() -> Dictionary:
	var counts := RuntimePrimitiveFactoryScript.debug_get_cache_counts()
	counts["field_net_material_cache"] = 1 if _net_material != null else 0
	counts["field_crowd_material_cache"] = 1 if _crowd_material != null else 0
	counts["field_flag_material_cache"] = 1 if _flag_material != null else 0
	counts["field_halo_material_cache"] = _halo_material_cache.size()
	var total := 0
	for cache_key in counts.keys():
		total += int(counts[cache_key])
	counts["static_cache_total_entries"] = total
	return counts

static func build(parent: Node3D, config: Dictionary) -> void:
	RenderProfileScript.report_runtime_profile_once("FootballFieldBuilder")
	var build_begin := PerfProbeScript.begin(parent, "field_builder.total")
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
	var player_kit_color := _get_color_config(config, "player_kit_color", DEFAULT_PLAYER_KIT_COLOR)
	var bot_kit_color := _get_color_config(config, "bot_kit_color", DEFAULT_BOT_KIT_COLOR)
	var country_names := _get_country_names_config(config)

	var stage_begin := PerfProbeScript.begin(parent, "field_builder.pitch")
	_add_pitch(parent, field_width, field_length, goal_half_width)
	PerfProbeScript.end(parent, "field_builder.pitch", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.goal_shells")
	_add_goal_shell(parent, "North", goal_line_north, -1.0, goal_half_width, goal_height, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, ceiling_height, wall_thickness)
	_add_goal_shell(parent, "South", goal_line_south, 1.0, goal_half_width, goal_height, goal_side_wall_x, goal_side_wall_thickness, goal_closed_depth, ceiling_height, wall_thickness)
	PerfProbeScript.end(parent, "field_builder.goal_shells", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.arena_glass")
	_add_arena_glass(parent, field_width, field_length, field_half_width, wall_height, ceiling_height, wall_thickness, goal_side_wall_x, goal_closed_depth, goal_line_north, goal_line_south)
	PerfProbeScript.end(parent, "field_builder.arena_glass", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.stadium_shell")
	_add_stadium_shell(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south, player_kit_color, bot_kit_color, country_names, config)
	PerfProbeScript.end(parent, "field_builder.stadium_shell", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.arcade_field")
	_add_arcade_field(parent, field_half_width, field_half_length, goal_line_north, goal_line_south)
	PerfProbeScript.end(parent, "field_builder.arcade_field", stage_begin)
	PerfProbeScript.end(parent, "field_builder.total", build_begin)

static func set_crowd_excitement(parent: Node, crowd_excitement: float) -> void:
	var clamped_excitement := clampf(crowd_excitement, 0.0, 1.0)
	if parent == null:
		return
	parent.set_meta("crowd_excitement", clamped_excitement)
	_apply_crowd_excitement_to_node(parent, clamped_excitement)

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

static func _add_stadium_shell(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float, player_kit_color: Color, bot_kit_color: Color, country_names: Array[String], config: Dictionary) -> void:
	var stage_begin := PerfProbeScript.begin(parent, "field_builder.stands")
	_add_stadium_seating(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south, player_kit_color, bot_kit_color, config)
	PerfProbeScript.end(parent, "field_builder.stands", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.banners")
	_add_country_banners(parent, field_width, goal_closed_depth, goal_line_north, goal_line_south, country_names)
	_add_flag_masts(parent, field_width, goal_closed_depth, goal_line_north, goal_line_south, player_kit_color, bot_kit_color, country_names)
	PerfProbeScript.end(parent, "field_builder.banners", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.scoreboards")
	_add_scoreboards(parent, field_width, goal_closed_depth, goal_line_north, goal_line_south)
	PerfProbeScript.end(parent, "field_builder.scoreboards", stage_begin)
	stage_begin = PerfProbeScript.begin(parent, "field_builder.skyline_lights")
	_add_skyline(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south)
	_add_light_rigs(parent, field_half_width, goal_line_north, goal_line_south)
	PerfProbeScript.end(parent, "field_builder.skyline_lights", stage_begin)

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

static func _add_stadium_seating(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float, player_kit_color: Color, bot_kit_color: Color, config: Dictionary) -> void:
	var tier_count: int = maxi(3, int(config.get("stadium_tier_count", 3)))
	var stand_color := Color(0.105, 0.125, 0.155, 1.0)
	var tier_color := Color(0.16, 0.18, 0.22, 1.0)
	var front_wall_color := Color(0.055, 0.075, 0.095, 1.0)
	for tier in range(tier_count):
		var tier_y := 0.52 + float(tier) * 0.82
		var tier_z_offset := goal_closed_depth + 2.4 + float(tier) * 1.18
		var tier_size := Vector3(field_width + 9.0 + float(tier) * 2.35, 0.72, 1.42)
		_add_decor_box(parent, "NorthStandTier%d" % tier, Vector3(0.0, tier_y, goal_line_north - tier_z_offset), tier_size, stand_color if tier == 0 else tier_color)
		_add_decor_box(parent, "SouthStandTier%d" % tier, Vector3(0.0, tier_y, goal_line_south + tier_z_offset), tier_size, stand_color if tier == 0 else tier_color)
		_add_stand_corridors(parent, "North", tier, field_width, tier_y, goal_line_north - tier_z_offset, tier_size.z, false)
		_add_stand_corridors(parent, "South", tier, field_width, tier_y, goal_line_south + tier_z_offset, tier_size.z, false)
	for tier in range(tier_count):
		var tier_x := field_half_width + 3.0 + float(tier) * 1.22
		var tier_y := 0.6 + float(tier) * 0.8
		var tier_size := Vector3(1.36, 0.72, field_length + 2.6 + float(tier) * 1.4)
		_add_decor_box(parent, "WestStandTier%d" % tier, Vector3(-tier_x, tier_y, 0.0), tier_size, stand_color if tier == 0 else tier_color)
		_add_decor_box(parent, "EastStandTier%d" % tier, Vector3(tier_x, tier_y, 0.0), tier_size, stand_color if tier == 0 else tier_color)
		_add_stand_corridors(parent, "West", tier, field_length, tier_y, -tier_x, tier_size.x, true)
		_add_stand_corridors(parent, "East", tier, field_length, tier_y, tier_x, tier_size.x, true)
	_add_decor_box(parent, "NorthStandFrontWall", Vector3(0.0, 0.78, goal_line_north - goal_closed_depth - 1.38), Vector3(field_width + 9.8, 1.05, 0.34), front_wall_color)
	_add_decor_box(parent, "SouthStandFrontWall", Vector3(0.0, 0.78, goal_line_south + goal_closed_depth + 1.38), Vector3(field_width + 9.8, 1.05, 0.34), front_wall_color)
	_add_decor_box(parent, "WestStandFrontWall", Vector3(-field_half_width - 2.0, 0.78, 0.0), Vector3(0.34, 1.05, field_length + 2.8), front_wall_color)
	_add_decor_box(parent, "EastStandFrontWall", Vector3(field_half_width + 2.0, 0.78, 0.0), Vector3(0.34, 1.05, field_length + 2.8), front_wall_color)
	_add_crowd_tiles(parent, field_width, field_length, field_half_width, goal_closed_depth, goal_line_north, goal_line_south, tier_count, player_kit_color, bot_kit_color, config)

static func _add_stand_corridors(parent: Node3D, side_name: String, tier: int, span: float, tier_y: float, fixed_axis_value: float, tier_depth: float, along_z: bool) -> void:
	var corridor_color := Color(0.035, 0.045, 0.058, 1.0)
	for index in range(3):
		var offset := -span * 0.28 + float(index) * span * 0.28
		if along_z:
			_add_decor_box(parent, "%sStandCorridorT%dI%d" % [side_name, tier, index], Vector3(fixed_axis_value, tier_y + 0.38, offset), Vector3(tier_depth + 0.08, 0.1, 0.48), corridor_color)
		else:
			_add_decor_box(parent, "%sStandCorridorT%dI%d" % [side_name, tier, index], Vector3(offset, tier_y + 0.38, fixed_axis_value), Vector3(0.48, 0.1, tier_depth + 0.08), corridor_color)

static func _add_crowd_tiles(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float, tier_count: int, player_kit_color: Color, bot_kit_color: Color, config: Dictionary) -> void:
	var goal_side_blocks: int = maxi(8, int(config.get("crowd_blocks_per_goal_side", 12)))
	var lateral_blocks: int = maxi(5, int(config.get("crowd_blocks_per_lateral_side", 7)))
	for tier in range(tier_count):
		var y := 1.65 + float(tier) * 0.82
		var z_offset := goal_closed_depth + 3.18 + float(tier) * 1.18
		var block_width := (field_width + 7.2 + float(tier) * 2.1) / float(goal_side_blocks)
		for index in range(goal_side_blocks):
			var x := -field_width * 0.5 - 3.4 - float(tier) * 0.9 + block_width * 0.5 + float(index) * block_width
			var color_a := player_kit_color if (index + tier) % 2 == 0 else bot_kit_color
			var color_b := bot_kit_color if (index + tier) % 2 == 0 else player_kit_color
			var north_name := "NorthCrowdBand%d" % index if tier == 0 else "NorthCrowdTier%dBand%d" % [tier, index]
			var south_name := "SouthCrowdBand%d" % index if tier == 0 else "SouthCrowdTier%dBand%d" % [tier, index]
			_add_crowd_tile(parent, north_name, Vector3(x, y, goal_line_north - z_offset), Vector3(block_width * 0.72, 1.04, 0.22), color_a, color_b, float(index) * 0.37 + float(tier) * 0.91)
			_add_crowd_tile(parent, south_name, Vector3(x, y, goal_line_south + z_offset), Vector3(block_width * 0.72, 1.04, 0.22), color_b, color_a, float(index) * 0.43 + float(tier) * 1.07 + 1.6)
	for side: float in [-1.0, 1.0]:
		var side_prefix := "East" if side > 0.0 else "West"
		for tier in range(tier_count):
			var x_side := side * (field_half_width + 3.62 + float(tier) * 1.18)
			var y := 1.54 + float(tier) * 0.8
			var block_length := (field_length - 5.5 + float(tier) * 0.8) / float(lateral_blocks)
			for index in range(lateral_blocks):
				var z := -field_length * 0.5 + 2.75 - float(tier) * 0.4 + block_length * 0.5 + float(index) * block_length
				var color_a := player_kit_color if (index + tier + (1 if side > 0.0 else 0)) % 2 == 0 else bot_kit_color
				var color_b := bot_kit_color if color_a == player_kit_color else player_kit_color
				var node_name := "%sCrowdBand%d" % [side_prefix, index] if tier == 0 else "%sCrowdTier%dBand%d" % [side_prefix, tier, index]
				_add_crowd_tile(parent, node_name, Vector3(x_side, y, z), Vector3(0.22, 0.98, block_length * 0.72), color_a, color_b, float(index) * 0.52 + float(tier) * 0.85 + (2.4 if side > 0.0 else 0.8))

static func _add_country_banners(parent: Node3D, field_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float, country_names: Array[String]) -> void:
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
		var north_z := goal_line_north - goal_closed_depth - 6.4
		var south_z := goal_line_south + goal_closed_depth + 6.4
		_add_banner(parent, "NorthCountryBanner%d" % index, Vector3(x, 4.55, north_z), Vector3(3.1, 1.18, 0.12), banner_sets[index % banner_sets.size()], country_names[index % country_names.size()])
		_add_banner(parent, "SouthCountryBanner%d" % index, Vector3(x, 4.55, south_z), Vector3(3.1, 1.18, 0.12), banner_sets[(index + 3) % banner_sets.size()], country_names[(index + 3) % country_names.size()])

static func _add_banner(parent: Node3D, node_name: String, center: Vector3, size: Vector3, colors: Array, label_text: String) -> void:
	_add_decor_box(parent, node_name, center, size + Vector3(0.16, 0.16, 0.02), Color(0.94, 0.94, 0.88, 1.0))
	for stripe_index in range(3):
		var stripe_y := center.y + (float(stripe_index) - 1.0) * size.y / 3.0
		var color: Color = colors[stripe_index]
		_add_decor_box(parent, "%sStripe%d" % [node_name, stripe_index], Vector3(center.x, stripe_y, center.z - 0.015), Vector3(size.x, size.y / 3.0, size.z + 0.04), color)
	var label := Label3D.new()
	label.name = "%sLabel" % node_name
	label.text = label_text
	label.position = center + Vector3(0.0, 0.0, -0.105)
	label.font_size = 34
	label.pixel_size = 0.012
	label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	label.outline_size = 8
	label.outline_modulate = Color(0.02, 0.03, 0.04, 1.0)
	parent.add_child(label)

static func _add_flag_masts(parent: Node3D, field_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float, player_kit_color: Color, bot_kit_color: Color, country_names: Array[String]) -> void:
	var flag_count := 6
	for index in range(flag_count):
		var x := -field_width * 0.5 + 2.7 + float(index) * ((field_width - 5.4) / float(flag_count - 1))
		_add_flag_mast(parent, "NorthFlagMast%d" % index, Vector3(x, 5.28, goal_line_north - goal_closed_depth - 7.38), player_kit_color, bot_kit_color, country_names[index % country_names.size()], float(index) * 0.72)
		_add_flag_mast(parent, "SouthFlagMast%d" % index, Vector3(x, 5.28, goal_line_south + goal_closed_depth + 7.38), bot_kit_color, player_kit_color, country_names[(index + 3) % country_names.size()], float(index) * 0.68 + 1.4)

static func _add_flag_mast(parent: Node3D, node_name: String, center: Vector3, base_color: Color, accent_color: Color, country_name: String, wave_phase: float) -> void:
	_add_decor_box(parent, "%sPole" % node_name, center - Vector3(1.18, 0.2, 0.0), Vector3(0.12, 2.9, 0.12), Color(0.72, 0.78, 0.84, 1.0))
	var flag := MeshInstance3D.new()
	flag.name = "%sFlag" % node_name
	flag.position = center + Vector3(0.12, 0.56, 0.0)
	var mesh := QuadMesh.new()
	mesh.size = Vector2(2.2, 1.08)
	flag.mesh = mesh
	flag.material_override = _build_flag_material(base_color, accent_color, wave_phase)
	flag.set_instance_shader_parameter("base_color", Vector3(base_color.r, base_color.g, base_color.b))
	flag.set_instance_shader_parameter("accent_color", Vector3(accent_color.r, accent_color.g, accent_color.b))
	flag.set_instance_shader_parameter("wave_phase", wave_phase)
	flag.set_meta("country_name", country_name)
	flag.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(flag)

	var label := Label3D.new()
	label.name = "%sLabel" % node_name
	label.text = country_name
	label.position = center + Vector3(0.12, -0.34, -0.08)
	label.font_size = 24
	label.pixel_size = 0.01
	label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	label.outline_size = 6
	label.outline_modulate = Color(0.02, 0.025, 0.035, 1.0)
	parent.add_child(label)

static func _add_scoreboards(parent: Node3D, field_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var board_size := Vector3(field_width * 0.56, 3.05, 0.26)
	var board_color := Color(0.03, 0.05, 0.08, 1.0)
	for side_name in ["North", "South"]:
		var side := -1.0 if side_name == "North" else 1.0
		var z := (goal_line_north if side_name == "North" else goal_line_south) + side * (goal_closed_depth + 8.75)
		_add_decor_box(parent, "WorldCupScoreboard%s" % side_name, Vector3(0.0, 6.12, z), board_size, board_color)
		_add_decor_box(parent, "WorldCupScoreboard%sGoldBand" % side_name, Vector3(0.0, 7.35, z - side * 0.02), Vector3(board_size.x * 0.92, 0.34, 0.3), Color(1.0, 0.82, 0.08, 1.0))
		_add_decor_box(parent, "WorldCupScoreboard%sBluePanel" % side_name, Vector3(-board_size.x * 0.24, 5.86, z - side * 0.03), Vector3(board_size.x * 0.34, 1.02, 0.32), Color(0.1, 0.32, 0.9, 1.0))
		_add_decor_box(parent, "WorldCupScoreboard%sGreenPanel" % side_name, Vector3(board_size.x * 0.24, 5.86, z - side * 0.03), Vector3(board_size.x * 0.34, 1.02, 0.32), Color(0.04, 0.58, 0.24, 1.0))
		_add_live_scoreboard(parent, side_name, Vector3(0.0, 6.06, z - side * 0.1), Vector3(board_size.x * 0.84, 1.72, 0.09))

static func _add_skyline(parent: Node3D, field_width: float, field_length: float, field_half_width: float, goal_closed_depth: float, goal_line_north: float, goal_line_south: float) -> void:
	var north_z := goal_line_north - goal_closed_depth - 13.6
	var south_z := goal_line_south + goal_closed_depth + 13.6
	for ring in range(2):
		var block_count := 13
		var skyline_width := field_width + 19.0 + float(ring) * 7.0
		var block_width := skyline_width / float(block_count)
		for index in range(block_count):
			var x := -skyline_width * 0.5 + block_width * 0.5 + float(index) * block_width
			var height := 1.3 + float((index * 5 + ring * 3) % 7) * 0.42 + float(ring) * 0.35
			var color := Color(0.025 + float(ring) * 0.01, 0.035 + float(index % 3) * 0.006, 0.055 + float(ring) * 0.012, 1.0)
			_add_decor_box(parent, "NorthSkylineRing%dBlock%d" % [ring, index], Vector3(x, height * 0.5 - 0.18, north_z - float(ring) * 1.8), Vector3(block_width * 0.72, height, 0.82), color)
			_add_decor_box(parent, "SouthSkylineRing%dBlock%d" % [ring, index], Vector3(x, height * 0.5 - 0.18, south_z + float(ring) * 1.8), Vector3(block_width * 0.72, height, 0.82), color)
	for side: float in [-1.0, 1.0]:
		var prefix := "East" if side > 0.0 else "West"
		var x_side := side * (field_half_width + 10.8)
		for index in range(10):
			var z := -field_length * 0.5 - 4.0 + float(index) * ((field_length + 8.0) / 9.0)
			var height := 1.1 + float((index * 3) % 6) * 0.38
			_add_decor_box(parent, "%sSkylineBlock%d" % [prefix, index], Vector3(x_side, height * 0.5 - 0.2, z), Vector3(0.78, height, 2.05), Color(0.025, 0.034, 0.052 + float(index % 2) * 0.012, 1.0))

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
		_add_light_halo(parent, "StadiumLightHalo%s" % label, position, Vector3(0.0, 2.2, 0.0))

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

static func _add_decor_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color, node_rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := RuntimePrimitiveFactoryScript.add_visual_box(parent, node_name, node_position, node_size, color, node_rotation_degrees, 0.34, 0.78)
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return mesh

static func _add_neon_box(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, color: Color, node_rotation_degrees: Vector3 = Vector3.ZERO, emission_energy: float = 2.0, roughness: float = 0.24) -> MeshInstance3D:
	return RuntimePrimitiveFactoryScript.add_visual_box(parent, node_name, node_position, node_size, color, node_rotation_degrees, emission_energy, roughness, 0.08, 0.42, 0.38, RenderProfileScript.ROLE_NEON)

static func _add_net_panel(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3) -> MeshInstance3D:
	var mesh := _add_visual_box(parent, node_name, node_position, node_size, Color(0.22, 0.68, 0.92, 0.58))
	mesh.material_override = _build_net_material()
	return mesh

static func _add_crowd_tile(parent: Node3D, node_name: String, node_position: Vector3, node_size: Vector3, base_color: Color, alternate_color: Color, wave_phase: float) -> MeshInstance3D:
	var mesh := _add_decor_box(parent, node_name, node_position, node_size, base_color)
	mesh.material_override = _build_crowd_material(base_color, alternate_color, wave_phase)
	mesh.set_instance_shader_parameter("base_color", Vector3(base_color.r, base_color.g, base_color.b))
	mesh.set_instance_shader_parameter("alternate_color", Vector3(alternate_color.r, alternate_color.g, alternate_color.b))
	mesh.set_instance_shader_parameter("wave_phase", wave_phase)
	mesh.add_to_group("football_crowd")
	mesh.set_meta("football_crowd_material", true)
	return mesh

static func _add_light_halo(parent: Node3D, node_name: String, halo_position: Vector3, target: Vector3) -> MeshInstance3D:
	var halo := MeshInstance3D.new()
	halo.name = node_name
	halo.position = halo_position
	var mesh := QuadMesh.new()
	mesh.size = Vector2(3.2, 3.2)
	halo.mesh = mesh
	halo.material_override = _build_halo_material(Color(1.0, 0.86, 0.58, 1.0))
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(halo)
	halo.look_at(target, Vector3.UP)
	return halo

static func _add_live_scoreboard(parent: Node3D, side_name: String, node_position: Vector3, node_size: Vector3) -> void:
	var viewport := SubViewport.new()
	viewport.name = "WorldCupScoreboard%sViewport" % side_name
	viewport.size = RenderProfileScript.get_scoreboard_viewport_size()
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if RenderProfileScript.is_web_platform() else SubViewport.UPDATE_ALWAYS
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
	top_band.offset_bottom = 44.0
	root.add_child(top_band)

	var score_label := Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "BRA 0 - 0 FRA"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	score_label.add_theme_font_size_override("font_size", 108)
	score_label.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	score_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	score_label.add_theme_constant_override("shadow_offset_x", 5)
	score_label.add_theme_constant_override("shadow_offset_y", 5)
	root.add_child(score_label)

	var phase_label := Label.new()
	phase_label.name = "PhaseLabel"
	phase_label.text = "FUTEBOL 1x1"
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase_label.anchor_left = 0.0
	phase_label.anchor_right = 1.0
	phase_label.anchor_top = 0.78
	phase_label.anchor_bottom = 1.0
	phase_label.add_theme_font_size_override("font_size", 42)
	phase_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.18, 1.0))
	root.add_child(phase_label)

	var display := _add_decor_box(parent, "WorldCupScoreboard%sLiveDisplay" % side_name, node_position, node_size, Color(1.0, 1.0, 1.0, 1.0))
	var material := StandardMaterial3D.new()
	material.albedo_texture = viewport.get_texture()
	material.emission_enabled = true
	material.emission_texture = viewport.get_texture()
	material.emission_energy_multiplier = RenderProfileScript.adjust_emission_energy(1.25, RenderProfileScript.ROLE_SCOREBOARD)
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
uniform float render_emission_scale = 1.0;
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
	EMISSION = color * (0.04 + line_mask * 0.08 + mouth_mask * 0.12) * render_emission_scale;
	ROUGHNESS = 0.88;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("pitch_size", Vector2(field_width, field_length))
	material.set_shader_parameter("goal_half_width", goal_half_width)
	material.set_shader_parameter("render_emission_scale", RenderProfileScript.get_emission_multiplier(RenderProfileScript.ROLE_SHADER_PITCH))
	return material

static func _build_net_material() -> ShaderMaterial:
	if _net_material != null:
		return _net_material
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode blend_mix, cull_disabled, depth_prepass_alpha;

uniform vec3 net_color = vec3(0.38, 0.86, 1.0);
uniform float grid_density = 10.0;
uniform float line_width = 0.055;
uniform float render_emission_scale = 1.0;

void fragment() {
	vec2 grid = abs(fract(UV * grid_density - 0.5) - 0.5) / fwidth(UV * grid_density);
	float line = 1.0 - min(min(grid.x, grid.y), 1.0);
	float alpha = mix(0.16, 0.74, smoothstep(1.0 - line_width, 1.0, line));
	ALBEDO = net_color;
	EMISSION = net_color * smoothstep(0.55, 1.0, line) * 0.85 * render_emission_scale;
	ALPHA = alpha;
	ROUGHNESS = 0.18;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("render_emission_scale", RenderProfileScript.get_emission_multiplier(RenderProfileScript.ROLE_SHADER_NET))
	_net_material = material
	return material

static func _build_crowd_material(base_color: Color, alternate_color: Color, wave_phase: float) -> ShaderMaterial:
	if _crowd_material != null:
		return _crowd_material
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

instance uniform vec3 base_color = vec3(0.9, 0.1, 0.1);
instance uniform vec3 alternate_color = vec3(0.1, 0.4, 0.9);
uniform float crowd_excitement = 0.0;
instance uniform float wave_phase = 0.0;
uniform float render_emission_scale = 1.0;
varying vec3 local_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void vertex() {
	local_pos = VERTEX;
	float cell_phase = floor(UV.x * 10.0) * 0.39 + floor(UV.y * 4.0) * 0.73;
	float slow_wave = sin(TIME * 1.55 + wave_phase + VERTEX.x * 2.6 + VERTEX.z * 1.8);
	float fast_wave = sin(TIME * (2.4 + crowd_excitement * 2.8) + wave_phase * 1.7 + cell_phase);
	float jump = max(fast_wave, 0.0) * crowd_excitement * 0.075;
	VERTEX.y += (slow_wave * 0.026 + fast_wave * 0.018) * (1.0 + crowd_excitement * 3.4) + jump;
}

void fragment() {
	vec2 cell = floor(UV * vec2(10.0, 4.0));
	float h = hash(cell);
	vec3 seat_color = mix(base_color, alternate_color, step(0.48, h));
	seat_color *= 0.68 + h * 0.42;
	seat_color = mix(seat_color, vec3(1.0), step(0.84, h) * (0.28 + crowd_excitement * 0.18));
	ALBEDO = seat_color;
	EMISSION = seat_color * (0.14 + crowd_excitement * 0.28) * render_emission_scale;
	ROUGHNESS = 0.64;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("crowd_excitement", 0.0)
	material.set_shader_parameter("render_emission_scale", RenderProfileScript.get_emission_multiplier(RenderProfileScript.ROLE_SHADER_CROWD))
	_crowd_material = material
	return material

static func _build_flag_material(base_color: Color, accent_color: Color, wave_phase: float) -> ShaderMaterial:
	if _flag_material != null:
		return _flag_material
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled;

instance uniform vec3 base_color = vec3(0.9, 0.1, 0.1);
instance uniform vec3 accent_color = vec3(1.0, 0.9, 0.1);
instance uniform float wave_phase = 0.0;
uniform float render_emission_scale = 1.0;

void vertex() {
	float free_edge = clamp(UV.x, 0.0, 1.0);
	VERTEX.z += sin(TIME * 2.0 + wave_phase + UV.x * 5.8 + UV.y * 2.6) * 0.12 * free_edge;
}

void fragment() {
	float stripe = step(0.33, UV.y) - step(0.66, UV.y);
	vec3 flag_color = mix(base_color, accent_color, stripe);
	flag_color = mix(flag_color, vec3(1.0), step(0.86, UV.x) * 0.08);
	ALBEDO = flag_color;
	EMISSION = flag_color * 0.18 * render_emission_scale;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("render_emission_scale", RenderProfileScript.get_emission_multiplier(RenderProfileScript.ROLE_SHADER_FLAG))
	_flag_material = material
	return material

static func _build_halo_material(halo_color: Color) -> ShaderMaterial:
	var cache_key := _color_key(halo_color)
	if _halo_material_cache.has(cache_key):
		return _halo_material_cache[cache_key]
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled;

uniform vec3 halo_color = vec3(1.0, 0.86, 0.58);
uniform float render_emission_scale = 1.0;

void fragment() {
	vec2 p = UV * 2.0 - vec2(1.0);
	float radius = dot(p, p);
	float halo = 1.0 - smoothstep(0.08, 1.0, radius);
	ALBEDO = halo_color;
	EMISSION = halo_color * halo * 1.35 * render_emission_scale;
	ALPHA = halo * 0.22;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("halo_color", Vector3(halo_color.r, halo_color.g, halo_color.b))
	material.set_shader_parameter("render_emission_scale", RenderProfileScript.get_emission_multiplier(RenderProfileScript.ROLE_SHADER_HALO))
	_halo_material_cache[cache_key] = material
	return material

static func _apply_crowd_excitement_to_node(node: Node, crowd_excitement: float) -> void:
	if node.has_meta("football_crowd_material"):
		var material: ShaderMaterial
		if node is MeshInstance3D:
			material = (node as MeshInstance3D).material_override as ShaderMaterial
		if material != null:
			material.set_shader_parameter("crowd_excitement", crowd_excitement)
	for child in node.get_children():
		_apply_crowd_excitement_to_node(child, crowd_excitement)

static func _color_key(color: Color) -> String:
	return "%.4f,%.4f,%.4f,%.4f" % [color.r, color.g, color.b, color.a]

static func _get_color_config(config: Dictionary, key: String, fallback: Color) -> Color:
	var value: Variant = config.get(key, fallback)
	if value is Color:
		return value
	if value is Vector3:
		var vector: Vector3 = value
		return Color(vector.x, vector.y, vector.z, 1.0)
	if value is Vector4:
		var vector4: Vector4 = value
		return Color(vector4.x, vector4.y, vector4.z, vector4.w)
	return fallback

static func _get_country_names_config(config: Dictionary) -> Array[String]:
	var value: Variant = config.get("country_names", DEFAULT_COUNTRY_NAMES)
	var names: Array[String] = []
	if value is PackedStringArray:
		for entry in value:
			names.append(str(entry))
	elif value is Array:
		for entry in value:
			names.append(str(entry))
	if names.is_empty():
		for entry in DEFAULT_COUNTRY_NAMES:
			names.append(str(entry))
	return names
