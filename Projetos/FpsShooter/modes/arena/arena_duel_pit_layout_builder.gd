class_name ArenaDuelPitLayoutBuilder
extends RefCounted

const RuntimePrimitiveFactoryScript = preload("res://modes/shared/runtime_primitive_factory.gd")

static func build(parent: Node3D, config: Dictionary) -> Dictionary:
	var jump_pads: Array[Dictionary] = []
	var flow_marker_count: int = 0
	var high_platform_cover_count: int = 0

	var floor_size: Vector3 = config.get("floor_size", Vector3(30.0, 1.0, 30.0))
	var wall_height: float = float(config.get("wall_height", 3.6))
	var wall_thickness: float = float(config.get("wall_thickness", 0.8))
	var west_jump_pad_position: Vector3 = config.get("west_jump_pad_position", Vector3.ZERO)
	var west_jump_pad_target: Vector3 = config.get("west_jump_pad_target", Vector3.ZERO)
	var east_jump_pad_position: Vector3 = config.get("east_jump_pad_position", Vector3.ZERO)
	var east_jump_pad_target: Vector3 = config.get("east_jump_pad_target", Vector3.ZERO)
	var health_pickup_position: Vector3 = config.get("health_pickup_position", Vector3.ZERO)
	var overcharge_pickup_position: Vector3 = config.get("overcharge_pickup_position", Vector3.ZERO)

	_add_box(parent, "ArenaFloor", Vector3(0.0, -0.5, 0.0), floor_size, Color(0.13, 0.17, 0.23, 1.0))
	var half := floor_size.x * 0.5
	_add_box(parent, "NorthWall", Vector3(0.0, wall_height * 0.5, -half), Vector3(floor_size.x, wall_height, wall_thickness), Color(0.22, 0.28, 0.34, 1.0))
	_add_box(parent, "SouthWall", Vector3(0.0, wall_height * 0.5, half), Vector3(floor_size.x, wall_height, wall_thickness), Color(0.22, 0.28, 0.34, 1.0))
	_add_box(parent, "WestWall", Vector3(-half, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, floor_size.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_box(parent, "EastWall", Vector3(half, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, floor_size.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_visual_box(parent, "CenterLaneMark", Vector3(0.0, 0.025, 0.0), Vector3(1.1, 0.05, 24.0), Color(0.18, 0.52, 0.62, 1.0))
	_add_visual_box(parent, "EastRouteMark", Vector3(8.8, 0.026, 0.0), Vector3(0.8, 0.05, 20.0), Color(0.38, 0.25, 0.58, 1.0))
	_add_visual_box(parent, "WestRouteMark", Vector3(-8.8, 0.026, 0.0), Vector3(0.8, 0.05, 20.0), Color(0.38, 0.25, 0.58, 1.0))
	flow_marker_count += _add_flow_marker(parent, "WestPadApproachMark", Vector3(-10.8, 0.032, -2.2), Vector3(1.35, 0.05, 3.6), Color(0.08, 0.74, 0.9, 1.0))
	flow_marker_count += _add_flow_marker(parent, "EastPadApproachMark", Vector3(10.8, 0.032, 2.2), Vector3(1.35, 0.05, 3.6), Color(0.08, 0.74, 0.9, 1.0))

	_add_box(parent, "MidBlocker", Vector3(0.0, 1.6, 0.0), Vector3(3.2, 3.2, 3.2), Color(0.19, 0.25, 0.32, 1.0))
	_add_box(parent, "HighCoverA", Vector3(-5.0, 1.6, -0.8), Vector3(1.4, 3.2, 3.8), Color(0.24, 0.3, 0.38, 1.0))
	_add_box(parent, "HighCoverB", Vector3(5.0, 1.6, 0.8), Vector3(1.4, 3.2, 3.8), Color(0.24, 0.3, 0.38, 1.0))
	_add_box(parent, "PlayerSpawnCover", Vector3(-9.4, 1.25, 6.4), Vector3(3.2, 2.5, 0.9), Color(0.25, 0.31, 0.4, 1.0))
	_add_box(parent, "BotSpawnCover", Vector3(9.4, 1.25, -6.4), Vector3(3.2, 2.5, 0.9), Color(0.25, 0.31, 0.4, 1.0))

	_add_box(parent, "LowCoverA", Vector3(-2.0, 0.55, -2.5), Vector3(2.8, 1.1, 1.2), Color(0.28, 0.48, 0.54, 1.0))
	_add_box(parent, "LowCoverB", Vector3(3.4, 0.55, 2.8), Vector3(2.8, 1.1, 1.2), Color(0.34, 0.26, 0.48, 1.0))
	_add_box(parent, "LowCoverC", Vector3(-6.0, 0.55, 4.0), Vector3(3.0, 1.1, 1.0), Color(0.28, 0.48, 0.54, 1.0), Vector3(0.0, 28.0, 0.0))
	_add_box(parent, "LowCoverD", Vector3(6.0, 0.55, -4.0), Vector3(3.0, 1.1, 1.0), Color(0.34, 0.26, 0.48, 1.0), Vector3(0.0, 28.0, 0.0))

	_add_box(parent, "WestPlatform", Vector3(-9.6, 0.55, -1.6), Vector3(4.4, 1.1, 5.0), Color(0.18, 0.26, 0.33, 1.0))
	_add_box(parent, "EastPlatform", Vector3(9.6, 0.55, 1.6), Vector3(4.4, 1.1, 5.0), Color(0.18, 0.26, 0.33, 1.0))
	_add_box(parent, "WestRamp", Vector3(-9.6, 0.52, 2.9), Vector3(4.4, 0.32, 4.8), Color(0.22, 0.38, 0.44, 1.0), Vector3(-12.0, 0.0, 0.0))
	_add_box(parent, "EastRamp", Vector3(9.6, 0.52, -2.9), Vector3(4.4, 0.32, 4.8), Color(0.22, 0.38, 0.44, 1.0), Vector3(12.0, 0.0, 0.0))
	_add_box(parent, "WestHighPlatform", Vector3(-8.0, 2.78, -8.6), Vector3(6.8, 0.58, 4.2), Color(0.16, 0.3, 0.39, 1.0))
	_add_box(parent, "EastHighPlatform", Vector3(8.0, 2.78, 8.6), Vector3(6.8, 0.58, 4.2), Color(0.16, 0.3, 0.39, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "WestHighSoftCover", Vector3(-9.25, 3.48, -7.15), Vector3(2.2, 0.82, 0.34), Color(0.18, 0.34, 0.42, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "WestHighAngleCover", Vector3(-5.25, 3.52, -9.55), Vector3(0.36, 0.95, 1.7), Color(0.18, 0.34, 0.42, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "EastHighSoftCover", Vector3(9.25, 3.48, 7.15), Vector3(2.2, 0.82, 0.34), Color(0.18, 0.34, 0.42, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "EastHighAngleCover", Vector3(5.25, 3.52, 9.55), Vector3(0.36, 0.95, 1.7), Color(0.18, 0.34, 0.42, 1.0))
	_add_visual_box(parent, "WestHighGuardMark", Vector3(-8.0, 3.12, -10.6), Vector3(6.2, 0.08, 0.18), Color(0.18, 0.72, 0.86, 1.0))
	_add_visual_box(parent, "EastHighGuardMark", Vector3(8.0, 3.12, 10.6), Vector3(6.2, 0.08, 0.18), Color(0.18, 0.72, 0.86, 1.0))
	flow_marker_count += _add_flow_marker(parent, "WestLandingZoneMark", west_jump_pad_target + Vector3(0.0, 0.08, 0.0), Vector3(2.3, 0.06, 1.65), Color(0.12, 0.82, 0.96, 1.0))
	flow_marker_count += _add_flow_marker(parent, "EastLandingZoneMark", east_jump_pad_target + Vector3(0.0, 0.08, 0.0), Vector3(2.3, 0.06, 1.65), Color(0.12, 0.82, 0.96, 1.0))
	flow_marker_count += _add_flow_marker(parent, "HealthObjectivePadMark", Vector3(health_pickup_position.x, 3.14, health_pickup_position.z), Vector3(1.35, 0.06, 1.35), Color(0.32, 1.0, 0.48, 1.0))
	flow_marker_count += _add_flow_marker(parent, "OverchargeObjectivePadMark", Vector3(overcharge_pickup_position.x, 3.14, overcharge_pickup_position.z), Vector3(1.35, 0.06, 1.35), Color(0.72, 0.42, 1.0, 1.0))
	_add_jump_pad(parent, jump_pads, &"west_pad", "WestJumpPad", west_jump_pad_position, west_jump_pad_target)
	_add_jump_pad(parent, jump_pads, &"east_pad", "EastJumpPad", east_jump_pad_position, east_jump_pad_target)

	return {
		"jump_pads": jump_pads,
		"flow_marker_count": flow_marker_count,
		"high_platform_cover_count": high_platform_cover_count,
	}

static func _add_box(parent: Node3D, node_name: String, box_position: Vector3, box_size: Vector3, color: Color, box_rotation_degrees: Vector3 = Vector3.ZERO) -> StaticBody3D:
	return RuntimePrimitiveFactoryScript.add_static_box(parent, node_name, box_position, box_size, color, box_rotation_degrees, 0.05, 0.84)

static func _add_visual_box(parent: Node3D, node_name: String, box_position: Vector3, box_size: Vector3, color: Color, box_rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	return RuntimePrimitiveFactoryScript.add_visual_box(parent, node_name, box_position, box_size, color, box_rotation_degrees, 0.18, 0.84)

static func _add_flow_marker(parent: Node3D, node_name: String, marker_position: Vector3, marker_size: Vector3, color: Color, marker_rotation_degrees: Vector3 = Vector3.ZERO) -> int:
	_add_visual_box(parent, node_name, marker_position, marker_size, color, marker_rotation_degrees)
	return 1

static func _add_high_platform_cover(parent: Node3D, node_name: String, cover_position: Vector3, cover_size: Vector3, color: Color) -> int:
	_add_box(parent, node_name, cover_position, cover_size, color)
	return 1

static func _add_jump_pad(parent: Node3D, jump_pads: Array[Dictionary], pad_id: StringName, pad_name: String, pad_position: Vector3, target_position: Vector3) -> void:
	var pad := Node3D.new()
	pad.name = pad_name
	pad.position = pad_position
	parent.add_child(pad)

	var base_mesh := MeshInstance3D.new()
	base_mesh.name = "PadSurface"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.0, 0.12, 2.0)
	base_mesh.mesh = mesh
	base_mesh.position = Vector3(0.0, 0.04, 0.0)
	base_mesh.material_override = RuntimePrimitiveFactoryScript.build_material(Color(0.04, 0.85, 1.0, 1.0), 1.75, 0.84)
	pad.add_child(base_mesh)

	var core_mesh := MeshInstance3D.new()
	core_mesh.name = "LaunchCore"
	var core := BoxMesh.new()
	core.size = Vector3(0.85, 0.18, 0.85)
	core_mesh.mesh = core
	core_mesh.position = Vector3(0.0, 0.18, 0.0)
	core_mesh.material_override = RuntimePrimitiveFactoryScript.build_material(Color(0.95, 0.95, 1.0, 1.0), 2.2, 0.84)
	pad.add_child(core_mesh)

	var light := OmniLight3D.new()
	light.name = "JumpPadLight"
	light.light_color = Color(0.18, 0.9, 1.0, 1.0)
	light.light_energy = 0.65
	light.omni_range = 4.5
	light.position = Vector3(0.0, 0.55, 0.0)
	pad.add_child(light)

	jump_pads.append({
		"id": pad_id,
		"node": pad,
		"position": pad_position,
		"target": target_position,
		"player_cooldown": 0.0,
		"bot_cooldown": 0.0,
	})
