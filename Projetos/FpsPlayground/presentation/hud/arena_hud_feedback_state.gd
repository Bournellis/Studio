class_name ArenaHudFeedbackState
extends RefCounted

const TIMER_KEYS = [
	"shot_feedback_time",
	"hit_feedback_time",
	"miss_feedback_time",
	"damage_feedback_time",
	"kill_feedback_time",
	"plasma_feedback_time",
	"bot_tell_feedback_time",
	"event_message_time"
]


static func build_reset_state() -> Dictionary:
	return {
		"shot_feedback_time": 0.0,
		"hit_feedback_time": 0.0,
		"miss_feedback_time": 0.0,
		"damage_feedback_time": 0.0,
		"kill_feedback_time": 0.0,
		"plasma_feedback_time": 0.0,
		"bot_tell_feedback_time": 0.0,
		"event_message_time": 0.0,
		"event_message_color": Color.WHITE,
		"last_feedback": &""
	}


static func tick_feedback_state(state: Dictionary, delta: float) -> Dictionary:
	var updated := state.duplicate()
	for key: String in TIMER_KEYS:
		updated[key] = maxf(0.0, float(updated.get(key, 0.0)) - delta)
	return updated


static func build_crosshair_view(state: Dictionary) -> Dictionary:
	var color := Color(0.88, 0.96, 1.0, 0.88)
	var pulse := 0.0
	var marker_alpha := 0.0
	var marker_text := ""
	if float(state.get("kill_feedback_time", 0.0)) > 0.0:
		color = Color(1.0, 0.92, 0.28, 1.0)
		pulse = 0.18
		marker_alpha = 1.0
		marker_text = "X"
	elif float(state.get("hit_feedback_time", 0.0)) > 0.0:
		color = Color(0.5, 1.0, 0.58, 1.0)
		pulse = 0.14
		marker_alpha = 1.0
		marker_text = "x"
	elif float(state.get("plasma_feedback_time", 0.0)) > 0.0:
		color = Color(0.78, 0.46, 1.0, 1.0)
		pulse = 0.12
	elif float(state.get("bot_tell_feedback_time", 0.0)) > 0.0:
		color = Color(1.0, 0.72, 0.22, 1.0)
		pulse = 0.1
	elif float(state.get("shot_feedback_time", 0.0)) > 0.0:
		color = Color(0.28, 0.92, 1.0, 1.0)
		pulse = 0.08
	elif float(state.get("miss_feedback_time", 0.0)) > 0.0:
		color = Color(0.62, 0.76, 0.9, 0.72)
		pulse = 0.05
	return {
		"color": color,
		"pulse": pulse,
		"marker_alpha": marker_alpha,
		"marker_text": marker_text
	}


static func get_damage_overlay_alpha(damage_feedback_time: float) -> float:
	if damage_feedback_time <= 0.0:
		return 0.0
	return clampf(damage_feedback_time / 0.38, 0.0, 1.0) * 0.32


static func get_event_alpha(event_message_time: float) -> float:
	return clampf(event_message_time / 0.25, 0.0, 1.0) if event_message_time > 0.0 else 0.0


static func build_player_alt_fire_event(overcharged: bool) -> Dictionary:
	if not overcharged:
		return {}
	return build_event("OVERCHARGED PLASMA", 0.42, Color(0.9, 0.62, 1.0, 1.0))


static func get_plasma_hit_feedback(overcharged: bool, killed: bool) -> StringName:
	return &"plasma_kill" if killed else (&"overcharge_hit" if overcharged else &"plasma_hit")


static func build_plasma_hit_event(overcharged: bool, killed: bool) -> Dictionary:
	if killed:
		return build_event("BOT DOWN", 0.9, Color(1.0, 0.92, 0.28, 1.0))
	if overcharged:
		return build_event("OVERCHARGE HIT", 0.58, Color(0.9, 0.62, 1.0, 1.0))
	return build_event("PLASMA HIT", 0.42, Color(0.48, 1.0, 1.0, 1.0))


static func get_plasma_blast_feedback(overcharged: bool, killed: bool) -> StringName:
	return &"plasma_kill" if killed else (&"overcharge_blast" if overcharged else &"plasma_blast")


static func build_plasma_blast_event(overcharged: bool, killed: bool) -> Dictionary:
	if killed:
		return build_event("BOT DOWN", 0.9, Color(1.0, 0.92, 0.28, 1.0))
	if overcharged:
		return build_event("OVERCHARGE BLAST", 0.58, Color(0.9, 0.62, 1.0, 1.0))
	return build_event("PLASMA BLAST", 0.42, Color(0.48, 1.0, 1.0, 1.0))


static func build_hit_confirm_event(killed: bool) -> Dictionary:
	if not killed:
		return {}
	return build_event("BOT DOWN", 0.9, Color(1.0, 0.92, 0.28, 1.0))


static func build_player_damage_event(amount: float) -> Dictionary:
	return build_event("UNDER FIRE -%.0f" % amount, 0.38, Color(1.0, 0.28, 0.18, 1.0))


static func build_bot_tell_event(duration: float) -> Dictionary:
	return build_event("BOT FIRING", maxf(0.22, duration), Color(1.0, 0.72, 0.22, 1.0))


static func build_pickup_event(pickup_kind: StringName, health_amount: float) -> Dictionary:
	var message := "HEALTH +%.0f" % health_amount if pickup_kind == &"health" else "OVERCHARGE READY"
	var color := Color(0.46, 1.0, 0.58, 1.0) if pickup_kind == &"health" else Color(0.9, 0.62, 1.0, 1.0)
	return build_event(message, 0.58, color)


static func build_jump_pad_event() -> Dictionary:
	return build_event("JUMP PAD", 0.42, Color(0.35, 0.92, 1.0, 1.0))


static func build_fall_penalty_event(amount: float, for_player: bool) -> Dictionary:
	var message := "VOID -%.0f" % amount if for_player else "BOT VOID"
	return build_event(message, 0.68, Color(1.0, 0.22, 0.36, 1.0))


static func build_round_end_event(player_won: bool) -> Dictionary:
	var color := Color(0.52, 1.0, 0.58, 1.0) if player_won else Color(1.0, 0.28, 0.18, 1.0)
	return build_event("VITORIA" if player_won else "DERROTA", 1.6, color)


static func build_event(message: String, duration: float, color: Color = Color.WHITE) -> Dictionary:
	return {
		"message": message,
		"duration": maxf(0.05, duration),
		"color": color
	}
