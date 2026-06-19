class_name FootballBallContactController
extends RefCounted

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


static func process_arcade_dash_contact(root: Node, actor: Node3D, target: Node3D, actor_is_player: bool, dash_direction: Vector3) -> bool:
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
