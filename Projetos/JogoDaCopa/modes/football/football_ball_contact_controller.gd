class_name FootballBallContactController
extends RefCounted

const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")


static func update_contact_cooldowns(root: Node, delta: float) -> void:
	root.player_touch_cooldown_remaining = maxf(0.0, root.player_touch_cooldown_remaining - delta)
	root.arcade_contact_cooldown_remaining = maxf(0.0, root.arcade_contact_cooldown_remaining - delta)
	root.ball_contact_audio_cooldown_remaining = maxf(0.0, root.ball_contact_audio_cooldown_remaining - delta)


static func update_player_ball_control(root: Node, _delta: float) -> void:
	if root.player == null or root.ball == null:
		root.player_ball_control_state = &"free"
		root.player_ball_control_strength = 0.0
		return
	var state: Dictionary = FootballMatchRulesScript.get_player_possession_state(
		root.player.global_position,
		root._get_player_kick_direction(),
		root.player.velocity,
		root.ball.global_position,
		root.PLAYER_TOUCH_RADIUS,
		root.PLAYER_NEAR_BALL_RADIUS
	)
	root.player_ball_control_state = state.get("state", &"free")
	root.player_ball_control_strength = float(state.get("strength", 0.0))


static func process_player_ball_contact(root: Node) -> void:
	if root.player_touch_cooldown_remaining > 0.0:
		return
	var contact: Dictionary = FootballMatchRulesScript.get_player_contact_kick(
		root.player.global_position,
		root.player.velocity,
		root.ball.global_position,
		root.PLAYER_TOUCH_RADIUS,
		2.0
	)
	if not bool(contact.get("connected", false)):
		return
	var contact_direction: Vector3 = contact.get("direction", Vector3.ZERO)
	var boost_multiplier := 1.35 if root.player.is_boosting() else 1.0
	var contact_lift := 0.42 if root.player.is_boosting() else 0.18
	root._notify_player_touched_ball()
	root.ball.kick(contact_direction, root.PLAYER_TOUCH_FORCE * boost_multiplier, contact_lift)
	root._add_player_super(root.SUPER_TOUCH_GAIN)
	root.player_touch_cooldown_remaining = root.PLAYER_TOUCH_COOLDOWN


static func on_ball_body_entered(root: Node, body: Node, render_profile_script) -> void:
	if root.feedback == null or root.ball == null or root.ball_contact_audio_cooldown_remaining > 0.0:
		return
	if render_profile_script.is_web_platform():
		return
	var ball_speed: float = root.ball.linear_velocity.length()
	if ball_speed < 2.0:
		return
	var body_name := str(body.name).to_lower()
	if body_name.contains("glass") or body_name.contains("wall") or body_name.contains("goal"):
		root.feedback.play_ball_glass(root.ball.global_position)
	else:
		root.feedback.play_ball_bounce(root.ball.global_position, ball_speed > 12.0)
	root.ball_contact_audio_cooldown_remaining = 0.12


static func process_arcade_action_contacts(root: Node) -> void:
	if root.arcade_contact_cooldown_remaining > 0.0 or root.player == null or root.bot == null or root.ball == null:
		return
	var handled := false
	if root.player.has_method("is_arcade_dashing") and root.player.is_arcade_dashing():
		handled = _process_arcade_dash_contact(root, root.player, root.bot, true) or handled
	if root.bot.has_method("debug_is_arcade_dashing") and root.bot.debug_is_arcade_dashing():
		handled = _process_arcade_dash_contact(root, root.bot, root.player, false) or handled
	if handled:
		root.arcade_contact_cooldown_remaining = root.ARCADE_CONTACT_COOLDOWN


static func _process_arcade_dash_contact(root: Node, actor: Node3D, target: Node3D, actor_is_player: bool) -> bool:
	var actor_position: Vector3 = actor.global_position
	var target_position: Vector3 = target.global_position
	var dash_direction := _get_arcade_dash_direction(actor, actor_is_player)
	var ball_close: bool = _flat_distance(actor_position, root.ball.global_position) <= root.ARCADE_SLIDE_BALL_RADIUS
	var body_close: bool = _flat_distance(actor_position, target_position) <= root.ARCADE_BODY_CONTACT_RADIUS
	if not ball_close and not body_close:
		return false
	if ball_close:
		if actor_is_player:
			root._notify_player_touched_ball()
		else:
			root._notify_ball_touched_by(&"bot")
		root.ball.kick(dash_direction, root.ARCADE_SLIDE_BALL_FORCE, root.ARCADE_SLIDE_BALL_LIFT)
		if actor_is_player:
			root._add_player_super(root.SUPER_TOUCH_GAIN)
		else:
			root._add_bot_super(root.SUPER_TOUCH_GAIN)
		if actor_is_player and root.player_avatar != null:
			root.player_avatar.play_slide()
		elif not actor_is_player and root.bot_avatar != null:
			root.bot_avatar.play_slide()
		if body_close:
			_apply_arcade_knockback_and_stun(root, target, dash_direction, root.ARCADE_SLIDE_KNOCKBACK_FORCE, root.ARCADE_SLIDE_STUN_DURATION)
		return true
	if body_close:
		if actor_is_player and root.player_avatar != null and root.player_avatar.has_method("play_push"):
			root.player_avatar.play_push()
		elif not actor_is_player and root.bot_avatar != null and root.bot_avatar.has_method("play_push"):
			root.bot_avatar.play_push()
		_apply_arcade_knockback(target, dash_direction, root.ARCADE_SHOULDER_KNOCKBACK_FORCE)
		_apply_arcade_knockback(actor, -dash_direction, root.ARCADE_SHOULDER_KNOCKBACK_FORCE * 0.72)
		return true
	return false


static func _get_arcade_dash_direction(actor: Node3D, actor_is_player: bool) -> Vector3:
	var direction := Vector3.ZERO
	if actor_is_player and actor.has_method("get_arcade_dash_direction"):
		direction = actor.get_arcade_dash_direction()
	elif not actor_is_player and actor.has_method("debug_get_arcade_dash_direction"):
		direction = actor.debug_get_arcade_dash_direction()
	direction.y = 0.0
	if direction.length_squared() <= 0.0001:
		direction = -actor.global_transform.basis.z
		direction.y = 0.0
	return direction.normalized() if direction.length_squared() > 0.0001 else Vector3.FORWARD


static func _apply_arcade_knockback_and_stun(root: Node, target: Node, direction: Vector3, force: float, stun_duration: float) -> void:
	_apply_arcade_knockback(target, direction, force)
	if target.has_method("apply_arcade_stun"):
		target.apply_arcade_stun(stun_duration)
	if target == root.player and root.player_avatar != null:
		root.player_avatar.play_hit()
	elif target == root.bot and root.bot_avatar != null:
		root.bot_avatar.play_hit()


static func _apply_arcade_knockback(target: Node, direction: Vector3, force: float) -> void:
	if target.has_method("apply_knockback"):
		target.apply_knockback(direction, force, 1.05)


static func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
