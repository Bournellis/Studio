class_name ArenaRelayFoundryLayoutBuilder
extends RefCounted

const RuntimePrimitiveFactoryScript = preload("res://modes/shared/runtime_primitive_factory.gd")

static func build(parent: Node3D, config: Dictionary) -> Dictionary:
	var jump_pads: Array[Dictionary] = []
	var flow_marker_count: int = 0
	var high_platform_cover_count: int = 0

	var floor_size: Vector3 = config.get("floor_size", Vector3(34.0, 1.0, 26.0))
	var wall_height: float = float(config.get("wall_height", 3.8))
	var wall_thickness: float = float(config.get("wall_thickness", 0.8))
	var west_jump_pad_position: Vector3 = config.get("west_jump_pad_position", Vector3.ZERO)
	var west_jump_pad_target: Vector3 = config.get("west_jump_pad_target", Vector3.ZERO)
	var east_jump_pad_position: Vector3 = config.get("east_jump_pad_position", Vector3.ZERO)
	var east_jump_pad_target: Vector3 = config.get("east_jump_pad_target", Vector3.ZERO)
	var health_pickup_position: Vector3 = config.get("health_pickup_position", Vector3.ZERO)
	var overcharge_pickup_position: Vector3 = config.get("overcharge_pickup_position", Vector3.ZERO)
	var half_x := floor_size.x * 0.5
	var half_z := floor_size.z * 0.5

	_add_box(parent, "RelayFoundryFloor", Vector3(0.0, -0.5, 0.0), floor_size, Color(0.11, 0.15, 0.18, 1.0))
	_add_box(parent, "NorthWall", Vector3(0.0, wall_height * 0.5, -half_z), Vector3(floor_size.x, wall_height, wall_thickness), Color(0.22, 0.27, 0.31, 1.0))
	_add_box(parent, "SouthWall", Vector3(0.0, wall_height * 0.5, half_z), Vector3(floor_size.x, wall_height, wall_thickness), Color(0.22, 0.27, 0.31, 1.0))
	_add_box(parent, "WestWall", Vector3(-half_x, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, floor_size.z), Color(0.22, 0.27, 0.31, 1.0))
	_add_box(parent, "EastWall", Vector3(half_x, wall_height * 0.5, 0.0), Vector3(wall_thickness, wall_height, floor_size.z), Color(0.22, 0.27, 0.31, 1.0))

	_add_visual_box(parent, "RelayLaneMark", Vector3(0.0, 0.026, 0.0), Vector3(30.0, 0.05, 0.82), Color(0.18, 0.66, 0.72, 1.0))
	_add_visual_box(parent, "FoundryLaneMark", Vector3(0.0, 0.027, 9.8), Vector3(27.0, 0.05, 0.72), Color(0.58, 0.24, 0.5, 1.0))
	_add_visual_box(parent, "RelayNorthMark", Vector3(-11.4, 0.028, -11.0), Vector3(8.6, 0.05, 0.72), Color(0.12, 0.78, 0.9, 1.0))
	_add_visual_box(parent, "ForgeSouthMark", Vector3(11.4, 0.028, 11.0), Vector3(8.6, 0.05, 0.72), Color(0.74, 0.42, 1.0, 1.0))

	_add_box(parent, "RelayCore", Vector3(0.0, 1.25, 0.0), Vector3(3.8, 2.5, 4.0), Color(0.2, 0.24, 0.28, 1.0))
	_add_box(parent, "NorthCoreCover", Vector3(-4.0, 0.58, -7.2), Vector3(3.8, 1.16, 1.0), Color(0.24, 0.34, 0.39, 1.0), Vector3(0.0, -18.0, 0.0))
	_add_box(parent, "SouthCoreCover", Vector3(4.2, 0.58, 7.0), Vector3(3.8, 1.16, 1.0), Color(0.32, 0.26, 0.42, 1.0), Vector3(0.0, -18.0, 0.0))
	_add_box(parent, "WestRelayCover", Vector3(-7.2, 0.95, 2.0), Vector3(1.1, 1.9, 3.4), Color(0.21, 0.32, 0.37, 1.0))
	_add_box(parent, "EastForgeCover", Vector3(7.2, 0.95, -2.0), Vector3(1.1, 1.9, 3.4), Color(0.29, 0.25, 0.4, 1.0))
	_add_box(parent, "PlayerSpawnCover", Vector3(-14.8, 1.0, 6.5), Vector3(3.4, 2.0, 0.9), Color(0.22, 0.32, 0.39, 1.0))
	_add_box(parent, "BotSpawnCover", Vector3(14.8, 1.0, -6.5), Vector3(3.4, 2.0, 0.9), Color(0.34, 0.24, 0.38, 1.0))
	_add_box(parent, "NorthResetCover", Vector3(-15.2, 0.55, -11.6), Vector3(2.0, 1.1, 1.1), Color(0.22, 0.32, 0.39, 1.0))
	_add_box(parent, "SouthResetCover", Vector3(15.2, 0.55, 11.6), Vector3(2.0, 1.1, 1.1), Color(0.34, 0.24, 0.38, 1.0))

	_add_box(parent, "WestRelayPlatform", Vector3(-12.4, 2.78, -9.4), Vector3(8.8, 0.58, 4.4), Color(0.16, 0.28, 0.34, 1.0))
	_add_box(parent, "EastForgePlatform", Vector3(12.4, 2.78, 9.4), Vector3(8.8, 0.58, 4.4), Color(0.23, 0.18, 0.34, 1.0))
	_add_box(parent, "WestRelayRamp", Vector3(-7.4, 0.58, -5.7), Vector3(5.8, 0.32, 7.0), Color(0.19, 0.38, 0.43, 1.0), Vector3(-11.0, 0.0, -5.0))
	_add_box(parent, "EastForgeRamp", Vector3(7.4, 0.58, 5.7), Vector3(5.8, 0.32, 7.0), Color(0.4, 0.25, 0.52, 1.0), Vector3(11.0, 0.0, -5.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "WestRelaySoftCover", Vector3(-10.2, 3.48, -8.0), Vector3(2.0, 0.82, 0.34), Color(0.16, 0.36, 0.44, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "WestRelayAngleCover", Vector3(-15.4, 3.52, -10.8), Vector3(0.36, 0.95, 1.6), Color(0.16, 0.36, 0.44, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "EastForgeSoftCover", Vector3(10.2, 3.48, 8.0), Vector3(2.0, 0.82, 0.34), Color(0.36, 0.24, 0.5, 1.0))
	high_platform_cover_count += _add_high_platform_cover(parent, "EastForgeAngleCover", Vector3(15.4, 3.52, 10.8), Vector3(0.36, 0.95, 1.6), Color(0.36, 0.24, 0.5, 1.0))

	flow_marker_count += _add_flow_marker(parent, "WestRelayPadApproachMark", Vector3(-10.8, 0.032, 5.7), Vector3(1.35, 0.05, 4.2), Color(0.08, 0.74, 0.9, 1.0))
	flow_marker_count += _add_flow_marker(parent, "EastForgePadApproachMark", Vector3(10.8, 0.032, -5.7), Vector3(1.35, 0.05, 4.2), Color(0.74, 0.42, 1.0, 1.0))
	flow_marker_count += _add_flow_marker(parent, "WestRelayLandingMark", west_jump_pad_target + Vector3(0.0, 0.08, 0.0), Vector3(2.3, 0.06, 1.5), Color(0.12, 0.82, 0.96, 1.0))
	flow_marker_count += _add_flow_marker(parent, "EastForgeLandingMark", east_jump_pad_target + Vector3(0.0, 0.08, 0.0), Vector3(2.3, 0.06, 1.5), Color(0.76, 0.44, 1.0, 1.0))
	flow_marker_count += _add_flow_marker(parent, "HealthObjectivePadMark", Vector3(health_pickup_position.x, 3.14, health_pickup_position.z), Vector3(1.35, 0.06, 1.35), Color(0.32, 1.0, 0.48, 1.0))
	flow_marker_count += _add_flow_marker(parent, "OverchargeObjectivePadMark", Vector3(overcharge_pickup_position.x, 3.14, overcharge_pickup_position.z), Vector3(1.35, 0.06, 1.35), Color(0.72, 0.42, 1.0, 1.0))
	_add_jump_pad(parent, jump_pads, &"west_relay_pad", "WestRelayJumpPad", west_jump_pad_position, west_jump_pad_target, Color(0.04, 0.85, 1.0, 1.0))
	_add_jump_pad(parent, jump_pads, &"east_forge_pad", "EastForgeJumpPad", east_jump_pad_position, east_jump_pad_target, Color(0.78, 0.42, 1.0, 1.0))

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

static func _add_jump_pad(parent: Node3D, jump_pads: Array[Dictionary], pad_id: StringName, pad_name: String, pad_position: Vector3, target_position: Vector3, color: Color) -> void:
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
	base_mesh.material_override = RuntimePrimitiveFactoryScript.build_material(color, 1.75, 0.84)
	pad.add_child(base_mesh)

	var core_mesh := MeshInstance3D.new()
	core_mesh.name = "LaunchCore"
	var core := BoxMesh.new()
	core.size = Vector3(0.85, 0.18, 0.85)
	core_mesh.mesh = core
	core_mesh.position = Vector3(0.0, 0.18, 0.0)
	core_mesh.material_override = RuntimePrimitiveFactoryScript.build_material(Color(0.95, 0.95, 1.0, 1.0), 2.2, 0.84)
	pad.add_child(core_mesh)
	_add_jump_pad_launch_cue(pad, pad_position, target_position)

	var light := OmniLight3D.new()
	light.name = "JumpPadLight"
	light.light_color = color
	light.light_energy = 0.7
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

static func _add_jump_pad_launch_cue(pad: Node3D, pad_position: Vector3, target_position: Vector3) -> void:
	var flat_direction := target_position - pad_position
	flat_direction.y = 0.0
	if flat_direction.length_squared() <= 0.0001:
		flat_direction = Vector3.FORWARD
	flat_direction = flat_direction.normalized()

	var cue := MeshInstance3D.new()
	cue.name = "LaunchDirectionCue"
	var cue_mesh := BoxMesh.new()
	cue_mesh.size = Vector3(0.28, 0.08, 1.45)
	cue.mesh = cue_mesh
	cue.position = flat_direction * 0.62 + Vector3.UP * 0.3
	cue.rotation.y = atan2(flat_direction.x, flat_direction.z)
	cue.material_override = RuntimePrimitiveFactoryScript.build_material(Color(0.82, 0.98, 1.0, 1.0), 2.4, 0.72, true)
	pad.add_child(cue)
