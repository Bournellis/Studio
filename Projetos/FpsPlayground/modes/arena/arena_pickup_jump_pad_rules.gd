class_name ArenaPickupJumpPadRules
extends RefCounted

const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")


static func build_pickup_state(pickup_node: Node3D, pickup_position: Vector3) -> Dictionary:
	return {
		"node": pickup_node,
		"position": pickup_position,
		"available": true,
		"respawn_remaining": 0.0
	}


static func set_pickup_available(entry: Dictionary, available: bool, respawn_duration: float) -> Dictionary:
	var updated := entry.duplicate()
	updated["available"] = available
	updated["respawn_remaining"] = 0.0 if available else respawn_duration
	return updated


static func update_pickup_respawn(entry: Dictionary, delta: float) -> Dictionary:
	var updated := entry.duplicate()
	var was_available := bool(updated.get("available", false))
	if was_available:
		return {
			"entry": updated,
			"respawned": false
		}
	var remaining := maxf(0.0, float(updated.get("respawn_remaining", 0.0)) - delta)
	updated["respawn_remaining"] = remaining
	var respawned := remaining <= 0.0
	if respawned:
		updated["available"] = true
	return {
		"entry": updated,
		"respawned": respawned
	}


static func can_attempt_pickup(entry: Dictionary, combatant_position: Vector3, pickup_radius: float) -> bool:
	if not bool(entry.get("available", false)):
		return false
	var pickup_position: Vector3 = entry.get("position", Vector3.ZERO)
	return combatant_position.distance_to(pickup_position) <= pickup_radius


static func get_pickup_respawn_duration(pickup_kind: StringName, health_respawn: float, overcharge_respawn: float) -> float:
	return ArenaCombatRulesScript.get_pickup_respawn_duration(pickup_kind, health_respawn, overcharge_respawn)


static func build_pickup_collected_payload(
	actor_id: String,
	pickup_kind: StringName,
	pickup_position: Vector3,
	health_before: float,
	health_after: float,
	max_health: float,
	healing_applied: float,
	healing_wasted: float,
	has_overcharge: bool
) -> Dictionary:
	return {
		"actor": actor_id,
		"pickup_kind": pickup_kind,
		"position": pickup_position,
		"health_before": health_before,
		"health_after": health_after,
		"max_health": max_health,
		"healing_applied": healing_applied,
		"healing_wasted": healing_wasted,
		"has_overcharge": has_overcharge
	}


static func normalize_jump_pad_state(pad: Dictionary) -> Dictionary:
	var updated := pad.duplicate()
	if not updated.has("player_cooldown"):
		updated["player_cooldown"] = 0.0
	if not updated.has("bot_cooldown"):
		updated["bot_cooldown"] = 0.0
	return updated


static func update_jump_pad_cooldowns(pad: Dictionary, delta: float) -> Dictionary:
	var updated := normalize_jump_pad_state(pad)
	updated["player_cooldown"] = maxf(0.0, float(updated.get("player_cooldown", 0.0)) - delta)
	updated["bot_cooldown"] = maxf(0.0, float(updated.get("bot_cooldown", 0.0)) - delta)
	return updated


static func reset_jump_pad_cooldowns(pad: Dictionary) -> Dictionary:
	var updated := normalize_jump_pad_state(pad)
	updated["player_cooldown"] = 0.0
	updated["bot_cooldown"] = 0.0
	return updated


static func mark_jump_pad_triggered(pad: Dictionary, actor_id: StringName, cooldown: float) -> Dictionary:
	var updated := normalize_jump_pad_state(pad)
	updated[get_jump_pad_cooldown_key(actor_id)] = cooldown
	return updated


static func get_jump_pad_cooldown_key(actor_id: StringName) -> String:
	return "player_cooldown" if actor_id == &"player" else "bot_cooldown"


static func can_trigger_jump_pad(
	pad: Dictionary,
	actor_id: StringName,
	combatant_position: Vector3,
	combatant_dead: bool,
	jump_pad_radius: float
) -> bool:
	if combatant_dead:
		return false
	var cooldown_key := get_jump_pad_cooldown_key(actor_id)
	if float(pad.get(cooldown_key, 0.0)) > 0.0:
		return false
	var pad_position: Vector3 = pad.get("position", Vector3.ZERO)
	var flat_delta := combatant_position - pad_position
	flat_delta.y = 0.0
	if flat_delta.length() > jump_pad_radius:
		return false
	return combatant_position.y <= pad_position.y + 1.1


static func build_jump_pad_launch_velocity(pad: Dictionary, forward_speed: float, vertical_speed: float) -> Vector3:
	var pad_position: Vector3 = pad.get("position", Vector3.ZERO)
	var target_position: Vector3 = pad.get("target", pad_position + Vector3.FORWARD)
	var flat := target_position - pad_position
	flat.y = 0.0
	if flat.length_squared() <= 0.0001:
		flat = Vector3.FORWARD
	return flat.normalized() * forward_speed + Vector3.UP * vertical_speed


static func build_jump_pad_triggered_payload(actor_id: StringName, pad: Dictionary, launch_velocity: Vector3) -> Dictionary:
	return {
		"actor": actor_id,
		"pad_id": pad.get("id", &""),
		"position": pad.get("position", Vector3.ZERO),
		"target": pad.get("target", Vector3.ZERO),
		"launch_velocity": launch_velocity
	}


static func build_jump_pad_flight(pad: Dictionary, started_at_msec: int) -> Dictionary:
	return {
		"pad_id": String(pad.get("id", &"")),
		"target": pad.get("target", Vector3.ZERO),
		"started_at": started_at_msec
	}
