class_name FootballBallContactController
extends RefCounted

const PLAYER_CONTACT_MINIMUM_TOUCH_SPEED: float = 2.0


static func update_contact_cooldowns(root: Node, delta: float) -> void:
	root.player_touch_cooldown_remaining = maxf(0.0, root.player_touch_cooldown_remaining - delta)
	root.arcade_contact_cooldown_remaining = maxf(0.0, root.arcade_contact_cooldown_remaining - delta)
	root.ball_contact_audio_cooldown_remaining = maxf(0.0, root.ball_contact_audio_cooldown_remaining - delta)


static func update_player_ball_control(root: Node, _delta: float) -> void:
	if root.player == null or root.ball == null:
		root.player_ball_control_state = &"free"
		root.player_ball_control_strength = 0.0
		return
	var flat_forward := _flatten_normalized(root._get_player_kick_direction())
	if flat_forward.length_squared() <= 0.0001:
		flat_forward = Vector3.FORWARD
	var player_center: Vector3 = root.player.global_position + Vector3.UP * 0.48
	var ball_position: Vector3 = root.ball.global_position
	var flat_delta := Vector3(ball_position.x - player_center.x, 0.0, ball_position.z - player_center.z)
	var distance := flat_delta.length()
	if distance <= 0.0001:
		root.player_ball_control_state = &"contact"
		root.player_ball_control_strength = 1.0
		return
	var ball_direction := flat_delta / distance
	var forward_dot := ball_direction.dot(flat_forward)
	var reachable: bool = distance <= root.PLAYER_NEAR_BALL_RADIUS and forward_dot >= -0.12
	var touching: bool = distance <= root.PLAYER_TOUCH_RADIUS
	if touching:
		root.player_ball_control_state = &"contact"
	elif reachable:
		root.player_ball_control_state = &"reachable"
	else:
		root.player_ball_control_state = &"free"
	var proximity_strength := 1.0 - clampf(distance / maxf(0.01, root.PLAYER_NEAR_BALL_RADIUS), 0.0, 1.0)
	var facing_strength := clampf((forward_dot + 0.12) / 1.12, 0.0, 1.0)
	root.player_ball_control_strength = clampf(proximity_strength * 0.62 + facing_strength * 0.38, 0.0, 1.0)


static func process_player_ball_contact(root: Node) -> void:
	if root.player_touch_cooldown_remaining > 0.0:
		return
	var player_center: Vector3 = root.player.global_position + Vector3.UP * 0.5
	var ball_position: Vector3 = root.ball.global_position
	var delta := ball_position - player_center
	var flat_delta := Vector3(delta.x, 0.0, delta.z)
	var flat_delta_length_squared := flat_delta.length_squared()
	if flat_delta_length_squared > root.PLAYER_TOUCH_RADIUS * root.PLAYER_TOUCH_RADIUS:
		return
	var player_velocity: Vector3 = root.player.velocity
	var flat_velocity := Vector3(player_velocity.x, 0.0, player_velocity.z)
	if flat_velocity.length_squared() < PLAYER_CONTACT_MINIMUM_TOUCH_SPEED * PLAYER_CONTACT_MINIMUM_TOUCH_SPEED:
		return
	var contact_direction_source := flat_velocity.normalized() * 0.6
	if flat_delta_length_squared > 0.0001:
		contact_direction_source += flat_delta.normalized()
	var contact_direction := contact_direction_source.normalized()
	if contact_direction.length_squared() <= 0.0001:
		return
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
	if root.player.is_arcade_dashing():
		handled = _process_arcade_dash_contact(root, root.player, root.bot, true, root.player.get_arcade_dash_direction()) or handled
	if root.bot.debug_is_arcade_dashing():
		handled = _process_arcade_dash_contact(root, root.bot, root.player, false, root.bot.debug_get_arcade_dash_direction()) or handled
	if handled:
		root.arcade_contact_cooldown_remaining = root.ARCADE_CONTACT_COOLDOWN


static func _process_arcade_dash_contact(root: Node, actor: Node3D, target: Node3D, actor_is_player: bool, dash_direction: Vector3) -> bool:
	var actor_position: Vector3 = actor.global_position
	var target_position: Vector3 = target.global_position
	dash_direction = _normalize_arcade_dash_direction(actor, dash_direction)
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


static func _normalize_arcade_dash_direction(actor: Node3D, direction: Vector3) -> Vector3:
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


static func _flatten_normalized(value: Vector3) -> Vector3:
	value.y = 0.0
	return value.normalized() if value.length_squared() > 0.0001 else Vector3.ZERO
