class_name BotTacticalContext
extends RefCounted

const ROLE_PRESSURE: StringName = &"pressure"
const ROLE_FLANK: StringName = &"flank"
const ROLE_COVER: StringName = &"cover"
const ROLE_RETREAT: StringName = &"retreat"
const ROLE_HEALTH: StringName = &"health"
const ROLE_OVERCHARGE: StringName = &"overcharge"
const ROLE_HIGH_GROUND: StringName = &"high_ground"
const ROLE_JUMP_PAD_ENTRY: StringName = &"jump_pad_entry"
const ROLE_JUMP_PAD_LANDING: StringName = &"jump_pad_landing"
const ROLE_FALLBACK: StringName = &"fallback"

static func make_context(label: StringName, points: Array = [], jump_pad_routes: Array = []) -> Dictionary:
	return {
		"label": label,
		"points": points.duplicate(true),
		"jump_pad_routes": jump_pad_routes.duplicate(true)
	}

static func make_point(
	position: Vector3,
	role: StringName,
	weight: float = 1.0,
	route: StringName = &"",
	available: bool = true
) -> Dictionary:
	return {
		"position": position,
		"role": role,
		"weight": weight,
		"route": role if route == &"" else route,
		"available": available
	}

static func make_jump_pad_route(id: StringName, position: Vector3, target: Vector3, roles: Array = []) -> Dictionary:
	return {
		"id": id,
		"position": position,
		"target": target,
		"roles": roles.duplicate()
	}

static func get_points(context: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for point: Dictionary in context.get("points", []):
		if not bool(point.get("available", true)):
			continue
		if not point.has("position"):
			continue
		result.append(point.duplicate(true))
	return result

static func get_jump_pad_routes(context: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for route: Dictionary in context.get("jump_pad_routes", []):
		if not route.has("position") or not route.has("target"):
			continue
		result.append(route.duplicate(true))
	return result

static func points_for_role(context: Dictionary, role: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for point: Dictionary in get_points(context):
		if point.get("role", ROLE_FALLBACK) == role:
			result.append(point)
	return result

static func is_reposition_role(role: StringName) -> bool:
	return role in [
		ROLE_PRESSURE,
		ROLE_FLANK,
		ROLE_COVER,
		ROLE_RETREAT,
		ROLE_HEALTH,
		ROLE_OVERCHARGE,
		ROLE_HIGH_GROUND,
		ROLE_JUMP_PAD_ENTRY,
		ROLE_JUMP_PAD_LANDING,
		ROLE_FALLBACK
	]
