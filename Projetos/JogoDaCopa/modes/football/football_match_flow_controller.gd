class_name FootballMatchFlowController
extends RefCounted

const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")


static func restart_play(root: Node, after_goal: bool, start_countdown: bool = true) -> void:
	PerfProbeScript.mark(root, "event.restart_play", "after_goal=%s" % str(after_goal))
	root.phase_label = &"kickoff" if not after_goal else &"reset"
	Engine.time_scale = 1.0
	root.goal_slowmo_remaining = 0.0
	root.player_super_used_this_kickoff = false
	root.bot_super_used_this_kickoff = false
	if after_goal:
		_advance_kickoff_owner(root)
	var ball_spawn := _get_ball_spawn_for_kickoff(root)
	root.player.global_position = _get_player_spawn_for_kickoff(root)
	root.player.rotation = Vector3.ZERO
	root.player.configure_for_round()
	root.player.clear_movement_impulses()
	root.bot.global_position = _get_bot_spawn_for_kickoff(root)
	root.bot.rotation.y = PI
	root.bot.configure(root.ball, Vector3(0.0, 0.0, root.GOAL_LINE_NORTH), Vector3(0.0, 0.0, root.GOAL_LINE_SOUTH), root.FIELD_HALF_WIDTH, root.FIELD_HALF_LENGTH)
	root.bot.set_difficulty(root.bot_difficulty_id)
	_snap_kickoff_avatar_facing(root)
	root.player_kickoff_waiting_for_touch = root.kickoff_owner == &"player" and not root.match_over
	if root.player_kickoff_waiting_for_touch and root.bot.has_method("start_kickoff_defense_hold"):
		root.bot.start_kickoff_defense_hold(_get_player_kickoff_bot_defense_position(root, ball_spawn))
	root.ball.teleport_to_spawn(ball_spawn)
	update_kickoff_marker(root, ball_spawn, true)
	if root.chase_camera != null:
		root.chase_camera.snap_to_target()
	root.player_touch_cooldown_remaining = 0.0
	root.arcade_contact_cooldown_remaining = 0.0
	root.ball_contact_audio_cooldown_remaining = 0.0
	root.player_ball_control_state = &"free"
	root.player_ball_control_strength = 0.0
	root.last_kick_assist_strength = 0.0
	if root.match_over:
		root.bot.set_celebrating(true)
	else:
		root.bot.set_celebrating(false)
	if start_countdown and not root.intro_open:
		start_kickoff_countdown(root)
	else:
		root.phase_label = &"play"


static func start_kickoff_countdown(root: Node) -> void:
	root.debug_kickoff_countdown_start_count += 1
	root.kickoff_countdown_remaining = root.KICKOFF_COUNTDOWN_DURATION
	root.countdown_last_number = int(ceilf(root.KICKOFF_COUNTDOWN_DURATION))
	root.phase_label = &"kickoff"
	root._request_hud_and_scoreboard_refresh()
	set_round_input_locked(root, true)
	if root.hud != null:
		root.hud.show_announcement("SAIDA PLAYER" if root.kickoff_owner == &"player" else "SAIDA BOT", 0.68, &"kickoff_owner")
		root.hud.show_countdown("3", 0.45)
	if root.feedback != null:
		root.feedback.play_countdown_tick(false)
		root.feedback.set_ambience_ducked(false)


static func update_kickoff_countdown(root: Node, delta: float) -> void:
	root.kickoff_countdown_remaining = maxf(0.0, root.kickoff_countdown_remaining - delta)
	var next_number := int(ceilf(root.kickoff_countdown_remaining))
	if next_number > 0 and next_number != root.countdown_last_number:
		root.countdown_last_number = next_number
		if root.hud != null:
			root.hud.show_countdown(str(next_number), 0.36)
		if root.feedback != null:
			root.feedback.play_countdown_tick(false)
	if root.kickoff_countdown_remaining > 0.0:
		return
	set_round_input_locked(root, false)
	root.phase_label = &"play"
	root._request_hud_and_scoreboard_refresh()
	if root.hud != null:
		root.hud.show_countdown("VAI!", 0.48)
	if root.feedback != null:
		root.feedback.play_countdown_tick(true)
		root.feedback.play_referee_whistle(root.ball.global_position if root.ball != null else Vector3.ZERO)


static func set_round_input_locked(root: Node, is_locked: bool) -> void:
	if is_locked:
		root._set_player_persistent_vfx(false, false)
	if root.player != null and root.player.has_method("set_input_locked"):
		root.player.set_input_locked(is_locked)
	if root.bot != null:
		root.bot.set_physics_process(not is_locked)
	if is_locked:
		if root.player != null:
			root.player.clear_movement_impulses()
		if root.bot != null:
			root.bot.velocity = Vector3.ZERO
		if root.ball != null:
			root.ball.linear_velocity = Vector3.ZERO
			root.ball.angular_velocity = Vector3.ZERO


static func update_kickoff_marker(root: Node, ball_spawn: Vector3, is_visible: bool) -> void:
	if root.kickoff_marker == null:
		return
	root.kickoff_marker.global_position = Vector3(ball_spawn.x, 0.045, ball_spawn.z)
	root.kickoff_marker.visible = is_visible


static func notify_player_touched_ball(root: Node) -> void:
	if root.player_kickoff_waiting_for_touch:
		root.player_kickoff_waiting_for_touch = false
		if root.bot != null and root.bot.has_method("release_kickoff_defense_hold"):
			root.bot.release_kickoff_defense_hold()
	notify_ball_touched_by(root, &"player")


static func notify_any_ball_touched(root: Node) -> void:
	notify_ball_touched_by(root, &"none")


static func notify_ball_touched_by(root: Node, team: StringName) -> void:
	if team == &"player" or team == &"bot":
		root.match_stats = FootballMatchRulesScript.record_touch_stat(root.match_stats, team)
	if root.kickoff_marker != null:
		root.kickoff_marker.visible = false


static func _advance_kickoff_owner(root: Node) -> void:
	root.kickoff_owner = &"bot" if root.kickoff_owner == &"player" else &"player"


static func _get_player_spawn_for_kickoff(root: Node) -> Vector3:
	if root.kickoff_owner == &"bot":
		return Vector3(0.0, root.PLAYER_SPAWN.y, root.FIELD_HALF_LENGTH - root.BOT_KICKOFF_PLAYER_SAFE_Z_OFFSET)
	return root.PLAYER_SPAWN


static func _get_bot_spawn_for_kickoff(root: Node) -> Vector3:
	if root.kickoff_owner == &"bot":
		return Vector3(0.0, root.BOT_SPAWN.y, -root.FIELD_HALF_LENGTH + 9.0)
	return _get_player_kickoff_bot_defense_position(root, _get_ball_spawn_for_kickoff(root))


static func _get_ball_spawn_for_kickoff(root: Node) -> Vector3:
	if root.kickoff_owner == &"bot":
		return Vector3(0.0, root.BALL_SPAWN.y, -9.0)
	return Vector3(0.0, root.BALL_SPAWN.y, 9.0)


static func _get_player_kickoff_bot_defense_position(root: Node, ball_spawn: Vector3) -> Vector3:
	var own_goal := Vector3(0.0, root.BOT_SPAWN.y, root.GOAL_LINE_NORTH)
	return ball_spawn.lerp(own_goal, root.PLAYER_KICKOFF_BOT_DEFENSE_RATIO)


static func _snap_kickoff_avatar_facing(root: Node) -> void:
	if root.player != null and root.bot != null and root.player_avatar != null and root.player_avatar.has_method("snap_visual_facing_direction"):
		root.player_avatar.snap_visual_facing_direction(root.bot.global_position - root.player.global_position, root.player.rotation.y)
	if root.player != null and root.bot != null and root.bot_avatar != null and root.bot_avatar.has_method("snap_visual_facing_direction"):
		root.bot_avatar.snap_visual_facing_direction(root.player.global_position - root.bot.global_position, root.bot.rotation.y)
