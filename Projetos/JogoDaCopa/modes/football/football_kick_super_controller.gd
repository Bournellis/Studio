class_name FootballKickSuperController
extends RefCounted

const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")


static func on_player_kick_requested(root: Node, _origin: Vector3, _direction: Vector3, _damage: float, _knockback: float) -> void:
	try_player_kick(root, root._get_player_kick_origin(), root._get_player_kick_direction(), root.PLAYER_KICK_FORCE, root.PLAYER_KICK_LIFT, false)


static func on_player_charged_kick_requested(root: Node, _origin: Vector3, _direction: Vector3, charge_fraction: float, _held_seconds: float) -> void:
	var clamped_charge := clampf(charge_fraction, 0.0, 1.0)
	var force: float = root.PLAYER_KICK_FORCE * lerpf(1.0, root.CHARGED_KICK_FORCE_MULTIPLIER, clamped_charge)
	var lift: float = root.PLAYER_KICK_LIFT + root.CHARGED_KICK_LIFT_BONUS * clamped_charge
	try_player_kick(root, root._get_player_kick_origin(), root._get_player_kick_direction(), force, lift, false)


static func on_player_strong_kick_requested(root: Node, _origin: Vector3, _direction: Vector3, _damage: float, _knockback: float, _speed: float, _radius: float, _overcharged: bool) -> void:
	if can_player_use_super(root):
		try_player_kick(root, root._get_player_kick_origin(), root._get_player_kick_direction(), root.SUPER_SHOT_FORCE, root.SUPER_SHOT_LIFT, true, true)
		return
	try_player_kick(root, root._get_player_kick_origin(), root._get_player_kick_direction(), root.PLAYER_STRONG_KICK_FORCE, root.PLAYER_STRONG_KICK_LIFT, true)


static func try_player_kick(root: Node, origin: Vector3, direction: Vector3, force: float, lift: float, strong: bool, super_shot: bool = false) -> void:
	PerfProbeScript.mark(root, "event.player_kick_request", "strong=%s super=%s" % [str(strong), str(super_shot)])
	if root.match_over or root.intro_open or root.menu_open or root.goal_reset_timer > 0.0 or root.kickoff_countdown_remaining > 0.0:
		return
	var connected: bool = root._can_reach_ball(origin, direction)
	root.last_kick_assist_strength = root._get_kick_assist_strength(origin, direction) if connected else 0.0
	if root.player_avatar != null:
		root.player_avatar.play_kick(strong)
	if root.hud != null:
		root.hud.show_kick(strong, connected, root.last_kick_assist_strength)
	if not connected:
		return
	var kick_direction: Vector3 = root._build_kick_direction(origin, direction)
	root._notify_player_touched_ball()
	root.ball.kick(kick_direction, force, lift)
	root._record_shot_stat(&"player", super_shot)
	if super_shot:
		root.player_super_meter = 0.0
		root.player_super_used_this_kickoff = true
	else:
		add_player_super(root, root.SUPER_TOUCH_GAIN)
	if root.feedback != null:
		root.feedback.play_football_kick(root.ball.global_position, kick_direction, strong)
	if root.chase_camera != null:
		root.chase_camera.play_shake(0.2 if super_shot else (0.09 if strong else 0.045), 0.22 if super_shot else (0.18 if strong else 0.1))


static func on_bot_kick_requested(root: Node, origin: Vector3, direction: Vector3, force: float, lift: float) -> void:
	PerfProbeScript.mark(root, "event.bot_kick_request")
	if root.match_over or root.intro_open or root.goal_reset_timer > 0.0 or root.kickoff_countdown_remaining > 0.0:
		return
	var to_ball: Vector3 = root.ball.global_position - origin
	if to_ball.length() > root.bot.kick_range + 0.55:
		return
	if root.bot_avatar != null:
		root.bot_avatar.play_kick(false)
	var applied_force := force
	var applied_lift := lift
	var bot_super := can_bot_use_super(root)
	if bot_super:
		root.bot_super_meter = 0.0
		root.bot_super_used_this_kickoff = true
		applied_force = root.SUPER_SHOT_FORCE
		applied_lift = root.SUPER_SHOT_LIFT
	root._notify_ball_touched_by(&"bot")
	root.ball.kick(direction, applied_force, applied_lift)
	root._record_shot_stat(&"bot", bot_super)
	if not bot_super:
		add_bot_super(root, root.SUPER_TOUCH_GAIN)
	if root.feedback != null:
		root.feedback.play_football_kick(root.ball.global_position, direction, bot_super)
	if root.chase_camera != null:
		root.chase_camera.play_shake(0.16 if bot_super else 0.035, 0.2 if bot_super else 0.08)


static func add_player_super(root: Node, amount: float) -> void:
	root.player_super_meter = clampf(root.player_super_meter + amount, 0.0, root.SUPER_METER_MAX)


static func add_bot_super(root: Node, amount: float) -> void:
	root.bot_super_meter = clampf(root.bot_super_meter + amount * get_bot_super_gain_multiplier(root), 0.0, root.SUPER_METER_MAX)


static func can_player_use_super(root: Node) -> bool:
	return root.player_super_meter >= root.SUPER_METER_MAX and not root.player_super_used_this_kickoff


static func can_bot_use_super(root: Node) -> bool:
	return root.bot_super_meter >= root.SUPER_METER_MAX and not root.bot_super_used_this_kickoff


static func get_bot_super_gain_multiplier(root: Node) -> float:
	return root.SUPER_BOT_HARD_GAIN_MULTIPLIER if root.bot_difficulty_id == &"hard" else 1.0
