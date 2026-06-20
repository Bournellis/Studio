class_name ArenaCombatPipeline
extends RefCounted

const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")
const OVERCHARGE_EPSILON: float = 0.001


static func is_overcharged_damage(damage: float, base_damage: float) -> bool:
	return damage > base_damage + OVERCHARGE_EPSILON


static func build_player_rifle_fired(shot_id: String, origin: Vector3, direction: Vector3, damage: float, knockback: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": shot_id,
		"actor": "player",
		"weapon": "rifle",
		"source": "player_rifle",
		"overcharged": overcharged,
		"origin": origin,
		"direction": direction,
		"damage": damage,
		"knockback": knockback
	}


static func build_player_rifle_miss(shot_id: String, impact_position: Vector3, distance: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": shot_id,
		"actor": "player",
		"weapon": "rifle",
		"source": "player_rifle",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"distance": distance
	}


static func build_player_rifle_hit(shot_id: String, target: String, impact_position: Vector3, distance: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": shot_id,
		"actor": "player",
		"target": target,
		"weapon": "rifle",
		"source": "player_rifle",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"distance": distance
	}


static func build_player_plasma_fired(
	projectile_id: String,
	origin: Vector3,
	visual_origin: Vector3,
	direction: Vector3,
	damage: float,
	knockback: float,
	speed: float,
	radius: float,
	overcharged: bool
) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"projectile_id": projectile_id,
		"actor": "player",
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"origin": origin,
		"visual_origin": visual_origin,
		"direction": direction,
		"damage": damage,
		"knockback": knockback,
		"speed": speed,
		"radius": radius
	}


static func build_player_plasma_spawned(
	projectile_id: String,
	origin: Vector3,
	direction: Vector3,
	damage: float,
	knockback: float,
	speed: float,
	radius: float,
	ttl: float,
	overcharged: bool
) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"projectile_id": projectile_id,
		"actor": "player",
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"origin": origin,
		"direction": direction,
		"damage": damage,
		"knockback": knockback,
		"speed": speed,
		"radius": radius,
		"ttl": ttl
	}


static func build_player_plasma_expired(projectile_id: String, impact_position: Vector3, overcharged: bool) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"projectile_id": projectile_id,
		"actor": "player",
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"impact_position": impact_position
	}


static func build_player_plasma_miss(projectile_id: String, impact_position: Vector3, overcharged: bool) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"actor": "player",
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"impact_position": impact_position
	}


static func build_player_plasma_direct_hit(projectile_id: String, target: String, impact_position: Vector3, damage: float, knockback: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"projectile_id": projectile_id,
		"actor": "player",
		"target": target,
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"damage": damage,
		"knockback": knockback
	}


static func build_player_plasma_direct_shot_hit(projectile_id: String, target: String, impact_position: Vector3, overcharged: bool) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"actor": "player",
		"target": target,
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"impact_position": impact_position
	}


static func build_player_plasma_world_impact(projectile_id: String, impact_position: Vector3, overcharged: bool) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"projectile_id": projectile_id,
		"actor": "player",
		"weapon": "plasma_direct",
		"source": "player_plasma",
		"overcharged": overcharged,
		"impact_position": impact_position
	}


static func calculate_player_plasma_blast(
	impact_position: Vector3,
	target_position: Vector3,
	shot_direction: Vector3,
	direct_damage: float,
	direct_knockback: float,
	blast_radius: float,
	damage_fraction: float,
	min_damage_fraction: float,
	knockback_fraction: float
) -> Dictionary:
	var max_blast_damage := direct_damage * damage_fraction
	var blast_damage := ArenaCombatRulesScript.calculate_blast_damage(
		impact_position,
		target_position,
		blast_radius,
		max_blast_damage,
		min_damage_fraction
	)
	if blast_damage <= 0.0:
		return {
			"damaged": false,
			"damage": 0.0,
			"falloff": 0.0,
			"knockback": 0.0,
			"direction": shot_direction.normalized()
		}

	var falloff := ArenaCombatRulesScript.calculate_blast_falloff(impact_position, target_position, blast_radius)
	var blast_direction := target_position - impact_position
	if blast_direction.length_squared() <= 0.0001:
		blast_direction = shot_direction
	blast_direction = blast_direction.normalized()
	return {
		"damaged": true,
		"damage": blast_damage,
		"falloff": falloff,
		"knockback": direct_knockback * knockback_fraction * clampf(falloff, 0.35, 1.0),
		"direction": blast_direction
	}


static func build_player_plasma_blast_shot_hit(
	projectile_id: String,
	impact_position: Vector3,
	target_position: Vector3,
	falloff: float,
	overcharged: bool
) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"actor": "player",
		"target": "bot",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"target_position": target_position,
		"distance": impact_position.distance_to(target_position),
		"falloff": falloff
	}


static func build_player_plasma_blast_summary(
	projectile_id: String,
	impact_position: Vector3,
	target_position: Vector3,
	blast_radius: float,
	falloff: float,
	damage: float,
	damaged_target: bool,
	killed_target: bool,
	overcharged: bool
) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"projectile_id": projectile_id,
		"actor": "player",
		"target": "bot" if damaged_target else "",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"target_position": target_position,
		"blast_radius": blast_radius,
		"falloff": falloff,
		"damage": damage,
		"damaged_target": damaged_target,
		"killed_target": killed_target
	}


static func build_player_plasma_blast_miss(projectile_id: String, impact_position: Vector3, overcharged: bool) -> Dictionary:
	return {
		"shot_id": projectile_id,
		"actor": "player",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"overcharged": overcharged,
		"impact_position": impact_position
	}


static func build_bot_shot_fired(shot_id: String, origin: Vector3, direction: Vector3, damage: float, knockback: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": shot_id,
		"actor": "bot",
		"weapon": "bot_shot",
		"source": "bot_shot",
		"overcharged": overcharged,
		"origin": origin,
		"direction": direction,
		"damage": damage,
		"knockback": knockback
	}


static func build_bot_shot_miss(shot_id: String, impact_position: Vector3, distance: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": shot_id,
		"actor": "bot",
		"weapon": "bot_shot",
		"source": "bot_shot",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"distance": distance
	}


static func build_bot_shot_hit(shot_id: String, impact_position: Vector3, distance: float, overcharged: bool) -> Dictionary:
	return {
		"shot_id": shot_id,
		"actor": "bot",
		"target": "player",
		"weapon": "bot_shot",
		"source": "bot_shot",
		"overcharged": overcharged,
		"impact_position": impact_position,
		"distance": distance
	}


static func build_damage_applied(
	shot_id: String,
	actor: String,
	target: String,
	weapon: String,
	source: String,
	overcharged: bool,
	damage: float,
	target_health: float,
	falloff: float = 0.0,
	include_falloff: bool = false
) -> Dictionary:
	var payload := {
		"shot_id": shot_id,
		"actor": actor,
		"target": target,
		"weapon": weapon,
		"source": source,
		"overcharged": overcharged,
		"damage": damage,
		"target_health": target_health
	}
	if include_falloff:
		payload["falloff"] = falloff
	return payload


static func build_knockback_applied(
	shot_id: String,
	actor: String,
	target: String,
	weapon: String,
	knockback: float,
	lift: float,
	falloff: float = 0.0,
	include_falloff: bool = false
) -> Dictionary:
	var payload := {
		"shot_id": shot_id,
		"actor": actor,
		"target": target,
		"weapon": weapon,
		"knockback": knockback,
		"lift": lift
	}
	if include_falloff:
		payload["falloff"] = falloff
	return payload
