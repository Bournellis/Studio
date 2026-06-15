class_name ArenaLayoutCatalog
extends RefCounted

const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")

const DUEL_PIT_ID: StringName = &"duel_pit_v2"

static func get_default_layout_id() -> StringName:
	return DUEL_PIT_ID

static func get_layout_ids() -> Array[StringName]:
	return [DUEL_PIT_ID]

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
		_:
			return _build_duel_pit_spec()

static func _build_duel_pit_spec() -> Dictionary:
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
				&"west_pad",
				west_jump_pad_position,
				west_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND]
			),
			BotTacticalContextScript.make_jump_pad_route(
				&"east_pad",
				east_jump_pad_position,
				east_jump_pad_target,
				[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND]
			)
		],
		"tactical_points": _build_duel_pit_tactical_points(west_jump_pad_position, east_jump_pad_position)
	}

static func _build_duel_pit_tactical_points(west_jump_pad_position: Vector3, east_jump_pad_position: Vector3) -> Array:
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
		BotTacticalContextScript.make_point(Vector3(-9.6, 3.05, -8.6), BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.22, &"west_high_landing"),
		BotTacticalContextScript.make_point(Vector3(-7.6, 3.05, -8.6), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.35, &"west_high_objective"),
		BotTacticalContextScript.make_point(Vector3(9.6, 3.05, 8.6), BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.22, &"east_high_landing"),
		BotTacticalContextScript.make_point(Vector3(7.6, 3.05, 8.6), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.35, &"east_high_objective"),
		BotTacticalContextScript.make_point(west_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.18, &"west_jump_pad"),
		BotTacticalContextScript.make_point(east_jump_pad_position, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.18, &"east_jump_pad")
	]
