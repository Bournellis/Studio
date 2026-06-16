class_name ArenaLayoutCatalog
extends RefCounted

const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")

const DUEL_PIT_ID: StringName = &"duel_pit_v2"
const RELAY_FOUNDRY_ID: StringName = &"relay_foundry_v1"
const CROSSFIRE_CRUCIBLE_ID: StringName = &"crossfire_crucible_v1"

static func get_default_layout_id() -> StringName:
	return DUEL_PIT_ID

static func get_layout_ids() -> Array[StringName]:
	return [DUEL_PIT_ID, RELAY_FOUNDRY_ID, CROSSFIRE_CRUCIBLE_ID]

static func has_layout(layout_id: StringName) -> bool:
	return get_layout_ids().has(layout_id)

static func normalize_layout_id(layout_id: StringName) -> StringName:
	if has_layout(layout_id):
		return layout_id
	return get_default_layout_id()

static func get_layout_display_name(layout_id: StringName) -> String:
	var spec := build_layout_spec(layout_id)
	return String(spec.get("display_name", spec.get("map_name", "Arena Shooter")))

static func build_layout_spec(layout_id: StringName) -> Dictionary:
	match normalize_layout_id(layout_id):
		DUEL_PIT_ID:
			return _build_duel_pit_spec()
		RELAY_FOUNDRY_ID:
			return _build_relay_foundry_spec()
		CROSSFIRE_CRUCIBLE_ID:
			return _build_crossfire_crucible_spec()
		_:
			return _build_duel_pit_spec()

static func _build_duel_pit_spec() -> Dictionary:
	var west_route: StringName = &"west_pad"
	var east_route: StringName = &"east_pad"
	var west_jump_pad_position := Vector3(-10.8, 0.08, -4.4)
	var west_jump_pad_target := Vector3(-9.6, 3.05, -8.6)
	var east_jump_pad_position := Vector3(10.8, 0.08, 4.4)
	var east_jump_pad_target := Vector3(9.6, 3.05, 8.6)
	var health_pickup_position := Vector3(-7.6, 3.55, -8.6)
	var overcharge_pickup_position := Vector3(7.6, 3.55, 8.6)
	return {
		"id": DUEL_PIT_ID,
		"builder": DUEL_PIT_ID,
		"display_name": "Arena Shooter - Duel Pit V2",
		"map_name": "Duel Pit V2",
		"floor_size": Vector3(30.0, 1.0, 30.0),
		"wall_height": 3.6,
		"wall_thickness": 0.8,
		"player_spawn": Vector3(-10.8, 0.05, 8.6),
		"bot_spawn": Vector3(10.8, 0.05, -8.6),
		"bot_arena_half_extent": 11.2,
		"health_pickup_position": health_pickup_position,
		"overcharge_pickup_position": overcharge_pickup_position,
		"west_jump_pad_position": west_jump_pad_position,
		"west_jump_pad_target": west_jump_pad_target,
		"east_jump_pad_position": east_jump_pad_position,
		"east_jump_pad_target": east_jump_pad_target,
		"jump_pad_routes": [
			BotTacticalContextScript.make_jump_pad_route(
				west_route,
				west_jump_pad_position,
				west_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND]
			),
			BotTacticalContextScript.make_jump_pad_route(
				east_route,
				east_jump_pad_position,
				east_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND]
			)
		],
		"tactical_points": _build_duel_pit_tactical_points(west_jump_pad_position, east_jump_pad_position, west_route, east_route)
	}

static func _build_duel_pit_tactical_points(west_jump_pad_position: Vector3, east_jump_pad_position: Vector3, west_route: StringName, east_route: StringName) -> Array:
	return [
		BotTacticalContextScript.make_point(Vector3(-11.2, 0.05, 7.8), BotTacticalContextScript.ROLE_FLANK, 1.05, &"west_deep_flank"),
		BotTacticalContextScript.make_point(Vector3(-10.8, 0.05, -7.2), BotTacticalContextScript.ROLE_RETREAT, 1.1, &"west_back_retreat"),
		BotTacticalContextScript.make_point(Vector3(-6.4, 0.05, 0.0), BotTacticalContextScript.ROLE_COVER, 1.0, &"west_mid_cover"),
		BotTacticalContextScript.make_point(Vector3(-3.8, 0.05, 5.4), BotTacticalContextScript.ROLE_PRESSURE, 1.1, &"west_pressure"),
		BotTacticalContextScript.make_point(Vector3(-1.8, 0.05, -6.8), BotTacticalContextScript.ROLE_FLANK, 1.05, &"west_low_flank"),
		BotTacticalContextScript.make_point(Vector3(1.8, 0.05, 6.8), BotTacticalContextScript.ROLE_FLANK, 1.05, &"east_low_flank"),
		BotTacticalContextScript.make_point(Vector3(3.8, 0.05, -5.4), BotTacticalContextScript.ROLE_PRESSURE, 1.1, &"east_pressure"),
		BotTacticalContextScript.make_point(Vector3(6.4, 0.05, 0.0), BotTacticalContextScript.ROLE_COVER, 1.0, &"east_mid_cover"),
		BotTacticalContextScript.make_point(Vector3(10.8, 0.05, 7.2), BotTacticalContextScript.ROLE_RETREAT, 1.1, &"east_back_retreat"),
		BotTacticalContextScript.make_point(Vector3(11.2, 0.05, -7.8), BotTacticalContextScript.ROLE_FLANK, 1.05, &"east_deep_flank"),
		BotTacticalContextScript.make_point(Vector3(-2.2, 0.05, 2.4), BotTacticalContextScript.ROLE_PRESSURE, 1.18, &"center_pressure_west"),
		BotTacticalContextScript.make_point(Vector3(2.2, 0.05, -2.4), BotTacticalContextScript.ROLE_PRESSURE, 1.18, &"center_pressure_east"),
		BotTacticalContextScript.make_point(Vector3(-9.6, 3.05, -8.6), BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.22, west_route),
		BotTacticalContextScript.make_point(Vector3(-7.6, 3.05, -8.6), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.35, west_route),
		BotTacticalContextScript.make_point(Vector3(9.6, 3.05, 8.6), BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.22, east_route),
		BotTacticalContextScript.make_point(Vector3(7.6, 3.05, 8.6), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.35, east_route),
		BotTacticalContextScript.make_point(west_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.18, west_route),
		BotTacticalContextScript.make_point(east_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.18, east_route)
	]

static func _build_relay_foundry_spec() -> Dictionary:
	var west_route: StringName = &"west_relay_pad"
	var east_route: StringName = &"east_forge_pad"
	var west_jump_pad_position := Vector3(-10.8, 0.08, 3.2)
	var west_jump_pad_target := Vector3(-13.0, 3.05, -9.4)
	var east_jump_pad_position := Vector3(10.8, 0.08, -3.2)
	var east_jump_pad_target := Vector3(13.0, 3.05, 9.4)
	var health_pickup_position := Vector3(-11.2, 3.55, -9.4)
	var overcharge_pickup_position := Vector3(11.2, 3.55, 9.4)
	return {
		"id": RELAY_FOUNDRY_ID,
		"builder": RELAY_FOUNDRY_ID,
		"display_name": "Arena Shooter - Relay Foundry V1",
		"map_name": "Relay Foundry V1",
		"floor_size": Vector3(38.0, 1.0, 30.0),
		"wall_height": 3.8,
		"wall_thickness": 0.8,
		"player_spawn": Vector3(-14.8, 0.05, 9.4),
		"bot_spawn": Vector3(14.8, 0.05, -9.4),
		"bot_arena_half_extent": 16.4,
		"health_pickup_position": health_pickup_position,
		"overcharge_pickup_position": overcharge_pickup_position,
		"west_jump_pad_position": west_jump_pad_position,
		"west_jump_pad_target": west_jump_pad_target,
		"east_jump_pad_position": east_jump_pad_position,
		"east_jump_pad_target": east_jump_pad_target,
		"jump_pad_routes": [
			BotTacticalContextScript.make_jump_pad_route(
				west_route,
				west_jump_pad_position,
				west_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND, BotTacticalContextScript.ROLE_HEALTH]
			),
			BotTacticalContextScript.make_jump_pad_route(
				east_route,
				east_jump_pad_position,
				east_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND, BotTacticalContextScript.ROLE_OVERCHARGE]
			)
		],
		"tactical_points": _build_relay_foundry_tactical_points(west_jump_pad_position, east_jump_pad_position, west_jump_pad_target, east_jump_pad_target, west_route, east_route)
	}

static func _build_relay_foundry_tactical_points(west_jump_pad_position: Vector3, east_jump_pad_position: Vector3, west_jump_pad_target: Vector3, east_jump_pad_target: Vector3, west_route: StringName, east_route: StringName) -> Array:
	return [
		BotTacticalContextScript.make_point(Vector3(-14.8, 0.05, 9.4), BotTacticalContextScript.ROLE_RETREAT, 1.12, &"player_side_retreat"),
		BotTacticalContextScript.make_point(Vector3(14.8, 0.05, -9.4), BotTacticalContextScript.ROLE_RETREAT, 1.12, &"bot_side_retreat"),
		BotTacticalContextScript.make_point(Vector3(-7.4, 0.05, 2.4), BotTacticalContextScript.ROLE_COVER, 1.1, &"west_relay_cover"),
		BotTacticalContextScript.make_point(Vector3(7.4, 0.05, -2.4), BotTacticalContextScript.ROLE_COVER, 1.1, &"east_forge_cover"),
		BotTacticalContextScript.make_point(Vector3(-6.8, 0.05, -7.4), BotTacticalContextScript.ROLE_FLANK, 1.08, &"west_low_flank"),
		BotTacticalContextScript.make_point(Vector3(6.8, 0.05, 7.4), BotTacticalContextScript.ROLE_FLANK, 1.08, &"east_low_flank"),
		BotTacticalContextScript.make_point(Vector3(-1.8, 0.05, -8.8), BotTacticalContextScript.ROLE_PRESSURE, 1.14, &"north_pressure"),
		BotTacticalContextScript.make_point(Vector3(2.2, 0.05, 8.8), BotTacticalContextScript.ROLE_PRESSURE, 1.14, &"south_pressure"),
		BotTacticalContextScript.make_point(Vector3(-3.6, 0.05, 0.0), BotTacticalContextScript.ROLE_COVER, 1.0, &"core_west_cover"),
		BotTacticalContextScript.make_point(Vector3(3.6, 0.05, 0.0), BotTacticalContextScript.ROLE_COVER, 1.0, &"core_east_cover"),
		BotTacticalContextScript.make_point(Vector3(-10.8, 0.05, 11.2), BotTacticalContextScript.ROLE_FLANK, 1.05, &"south_west_wrap"),
		BotTacticalContextScript.make_point(Vector3(10.8, 0.05, -11.2), BotTacticalContextScript.ROLE_FLANK, 1.05, &"north_east_wrap"),
		BotTacticalContextScript.make_point(west_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.24, west_route),
		BotTacticalContextScript.make_point(east_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.24, east_route),
		BotTacticalContextScript.make_point(west_jump_pad_target, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.24, west_route),
		BotTacticalContextScript.make_point(Vector3(-10.8, 3.05, -9.4), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.38, west_route),
		BotTacticalContextScript.make_point(east_jump_pad_target, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.24, east_route),
		BotTacticalContextScript.make_point(Vector3(10.8, 3.05, 9.4), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.38, east_route),
		BotTacticalContextScript.make_point(Vector3(-15.2, 0.05, -11.6), BotTacticalContextScript.ROLE_RETREAT, 1.08, &"north_west_reset"),
		BotTacticalContextScript.make_point(Vector3(15.2, 0.05, 11.6), BotTacticalContextScript.ROLE_RETREAT, 1.08, &"south_east_reset")
	]

static func _build_crossfire_crucible_spec() -> Dictionary:
	var west_route: StringName = &"west_lift_pad"
	var east_route: StringName = &"east_diagonal_pad"
	var west_jump_pad_position := Vector3(-8.8, 0.08, 5.6)
	var west_jump_pad_target := Vector3(-6.2, 3.05, -2.8)
	var east_jump_pad_position := Vector3(8.8, 0.08, -5.8)
	var east_jump_pad_target := Vector3(3.0, 3.05, 6.6)
	var health_pickup_position := Vector3(-5.0, 3.55, -2.8)
	var overcharge_pickup_position := Vector3(4.8, 3.55, 6.6)
	return {
		"id": CROSSFIRE_CRUCIBLE_ID,
		"builder": CROSSFIRE_CRUCIBLE_ID,
		"display_name": "Arena Shooter - Crossfire Crucible V1",
		"map_name": "Crossfire Crucible V1",
		"floor_size": Vector3(34.0, 1.0, 28.0),
		"wall_height": 3.8,
		"wall_thickness": 0.8,
		"player_spawn": Vector3(-12.4, 0.05, 7.8),
		"bot_spawn": Vector3(12.4, 0.05, -7.8),
		"bot_arena_half_extent": 14.4,
		"health_pickup_position": health_pickup_position,
		"overcharge_pickup_position": overcharge_pickup_position,
		"west_jump_pad_position": west_jump_pad_position,
		"west_jump_pad_target": west_jump_pad_target,
		"east_jump_pad_position": east_jump_pad_position,
		"east_jump_pad_target": east_jump_pad_target,
		"jump_pad_routes": [
			BotTacticalContextScript.make_jump_pad_route(
				west_route,
				west_jump_pad_position,
				west_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND, BotTacticalContextScript.ROLE_HEALTH]
			),
			BotTacticalContextScript.make_jump_pad_route(
				east_route,
				east_jump_pad_position,
				east_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND, BotTacticalContextScript.ROLE_OVERCHARGE]
			)
		],
		"tactical_points": _build_crossfire_crucible_tactical_points(west_jump_pad_position, east_jump_pad_position, west_jump_pad_target, east_jump_pad_target, west_route, east_route)
	}

static func _build_crossfire_crucible_tactical_points(west_jump_pad_position: Vector3, east_jump_pad_position: Vector3, west_jump_pad_target: Vector3, east_jump_pad_target: Vector3, west_route: StringName, east_route: StringName) -> Array:
	return [
		BotTacticalContextScript.make_point(Vector3(-12.4, 0.05, 7.8), BotTacticalContextScript.ROLE_RETREAT, 1.12, &"player_side_reset"),
		BotTacticalContextScript.make_point(Vector3(12.4, 0.05, -7.8), BotTacticalContextScript.ROLE_RETREAT, 1.12, &"bot_side_reset"),
		BotTacticalContextScript.make_point(Vector3(-8.6, 0.05, -0.4), BotTacticalContextScript.ROLE_COVER, 1.1, &"west_cross_cover"),
		BotTacticalContextScript.make_point(Vector3(8.6, 0.05, 0.4), BotTacticalContextScript.ROLE_COVER, 1.1, &"east_cross_cover"),
		BotTacticalContextScript.make_point(Vector3(-5.8, 0.05, -8.7), BotTacticalContextScript.ROLE_FLANK, 1.08, &"north_west_flank"),
		BotTacticalContextScript.make_point(Vector3(5.8, 0.05, 8.7), BotTacticalContextScript.ROLE_FLANK, 1.08, &"south_east_flank"),
		BotTacticalContextScript.make_point(Vector3(-1.7, 0.05, -6.8), BotTacticalContextScript.ROLE_PRESSURE, 1.16, &"north_pressure"),
		BotTacticalContextScript.make_point(Vector3(1.7, 0.05, 6.8), BotTacticalContextScript.ROLE_PRESSURE, 1.16, &"south_pressure"),
		BotTacticalContextScript.make_point(Vector3(-2.6, 0.05, 0.0), BotTacticalContextScript.ROLE_PRESSURE, 1.18, &"center_west_pressure"),
		BotTacticalContextScript.make_point(Vector3(2.6, 0.05, 0.0), BotTacticalContextScript.ROLE_PRESSURE, 1.18, &"center_east_pressure"),
		BotTacticalContextScript.make_point(Vector3(-12.0, 0.05, -5.2), BotTacticalContextScript.ROLE_FLANK, 1.05, &"west_wrap"),
		BotTacticalContextScript.make_point(Vector3(12.0, 0.05, 5.2), BotTacticalContextScript.ROLE_FLANK, 1.05, &"east_wrap"),
		BotTacticalContextScript.make_point(west_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.24, west_route),
		BotTacticalContextScript.make_point(east_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.24, east_route),
		BotTacticalContextScript.make_point(west_jump_pad_target, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.22, west_route),
		BotTacticalContextScript.make_point(Vector3(-5.0, 3.05, -2.8), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.36, west_route),
		BotTacticalContextScript.make_point(east_jump_pad_target, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.22, east_route),
		BotTacticalContextScript.make_point(Vector3(4.8, 3.05, 6.6), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.4, east_route),
		BotTacticalContextScript.make_point(Vector3(-14.0, 0.05, 0.0), BotTacticalContextScript.ROLE_RETREAT, 1.08, &"west_reset"),
		BotTacticalContextScript.make_point(Vector3(14.0, 0.05, 0.0), BotTacticalContextScript.ROLE_RETREAT, 1.08, &"east_reset")
	]
