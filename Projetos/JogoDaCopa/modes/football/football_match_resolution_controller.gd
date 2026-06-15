class_name FootballMatchResolutionController
extends RefCounted

const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")
const RenderProfileScript = preload("res://autoloads/render_profile.gd")


static func restart_match(root: Node, capture_mouse: bool = true) -> void:
	root._set_intro_open(false)
	root._set_menu_open(false)
	root.player_score = 0
	root.bot_score = 0
	root.match_over = false
	root.goal_reset_timer = 0.0
	root.last_goal_player_scored = false
	root.kickoff_owner = &"player"
	root.match_time_remaining = root.MATCH_DURATION_SECONDS
	root.golden_goal_active = false
	root.last_thirty_announced = false
	root.last_goal_value = 1
	root.player_super_meter = 0.0
	root.bot_super_meter = 0.0
	root.player_super_used_this_kickoff = false
	root.bot_super_used_this_kickoff = false
	root.match_stats = FootballMatchRulesScript.build_empty_match_stats()
	root._reset_arcade_field()
	root._restart_play(false)
	if root.hud != null:
		root.hud.reset_feedback()
	if root.feedback != null:
		root.feedback.clear_effects()
	root._request_hud_and_scoreboard_refresh()
	if capture_mouse:
		root._capture_mouse_if_playing()


static func set_match_mode(root: Node, next_match_mode_id: StringName) -> void:
	root.match_mode_id = root._sanitize_match_mode(next_match_mode_id)
	if root.match_mode_id == root.MATCH_MODE_TIMER and root.match_time_remaining <= 0.0 and not root.golden_goal_active:
		root.match_time_remaining = root.MATCH_DURATION_SECONDS
	root._request_hud_and_scoreboard_refresh()


static func update_goal_reset(root: Node, delta: float) -> bool:
	if root.goal_reset_timer <= 0.0:
		return false
	root.goal_reset_timer = maxf(0.0, root.goal_reset_timer - delta)
	if root.goal_reset_timer <= 0.0 and not root.match_over:
		root._restart_play(true)
	return true


static func process_goal_detection(root: Node) -> void:
	var goal_side := FootballMatchRulesScript.detect_goal(
		root.ball.global_position,
		root.GOAL_HALF_WIDTH,
		root.GOAL_LINE_NORTH,
		root.GOAL_LINE_SOUTH,
		root.GOAL_HEIGHT
	)
	if goal_side == 1:
		PerfProbeScript.mark(root, "event.goal_detected", "side=north player_scored=true")
		register_goal(root, true)
	elif goal_side == -1:
		PerfProbeScript.mark(root, "event.goal_detected", "side=south player_scored=false")
		register_goal(root, false)


static func register_goal(root: Node, player_scored: bool) -> void:
	root.last_goal_player_scored = player_scored
	var score_result: Dictionary = FootballMatchRulesScript.apply_goal_score_for_mode(
		root.player_score,
		root.bot_score,
		player_scored,
		root.GOAL_LIMIT,
		root.match_mode_id,
		root.match_time_remaining,
		root.DOUBLE_GOAL_WINDOW_SECONDS,
		root.golden_goal_active
	)
	root.player_score = int(score_result.get("player_score", root.player_score))
	root.bot_score = int(score_result.get("bot_score", root.bot_score))
	root.last_goal_value = int(score_result.get("goal_value", 1))
	root._request_hud_and_scoreboard_refresh()
	record_goal_stat(root, player_scored, root.last_goal_value)
	var double_goal := bool(score_result.get("double_goal", false))
	root.phase_label = &"goal"
	root.goal_reset_timer = root.GOAL_RESET_DELAY
	root.bot.set_celebrating(true)
	if player_scored:
		root._add_bot_super(root.SUPER_GOAL_SUFFERED_GAIN)
	else:
		root._add_player_super(root.SUPER_GOAL_SUFFERED_GAIN)
	if root.hud != null:
		root.hud.show_goal(player_scored, root.last_goal_value, double_goal)
	if player_scored and root.player_avatar != null and not RenderProfileScript.is_web_platform():
		root.player_avatar.play_celebrate()
	elif not player_scored and root.bot_avatar != null and not RenderProfileScript.is_web_platform():
		root.bot_avatar.play_celebrate()
	if root.feedback != null:
		var goal_z: float = root.GOAL_LINE_NORTH if player_scored else root.GOAL_LINE_SOUTH
		root.feedback.play_football_goal(Vector3(0.0, 1.0, goal_z), player_scored)
	root._trigger_goal_gamefeel()
	if not player_scored:
		root._trigger_arcade_emote(false)
	if bool(score_result.get("match_over", false)):
		finish_match(root, bool(score_result.get("player_won", false)))


static func update_match_clock(root: Node, delta: float) -> void:
	if root.match_mode_id != root.MATCH_MODE_TIMER or root.golden_goal_active or root.match_over:
		return
	var previous_time: float = root.match_time_remaining
	root.match_time_remaining = maxf(0.0, root.match_time_remaining - delta)
	if previous_time > root.DOUBLE_GOAL_WINDOW_SECONDS and root.match_time_remaining <= root.DOUBLE_GOAL_WINDOW_SECONDS and root.match_time_remaining > 0.0:
		root.last_thirty_announced = true
		if root.hud != null:
			root.hud.show_announcement("ULTIMO MINUTO!", 0.9, &"last_minute")
	if root.match_time_remaining > 0.0:
		return
	if root.player_score == root.bot_score:
		root.golden_goal_active = true
		root.phase_label = &"golden_goal"
		if root.hud != null:
			root.hud.show_announcement("GOLDEN GOAL!", 1.05, &"golden_goal")
		return
	finish_match(root, root.player_score > root.bot_score)


static func finish_match(root: Node, player_won: bool) -> void:
	var profile_begin := PerfProbeScript.begin(root, "football.finish_match", "player_won=%s" % str(player_won))
	PerfProbeScript.mark(root, "event.result", "player_won=%s" % str(player_won))
	root.match_over = true
	root.goal_reset_timer = 0.0
	root.phase_label = &"match_end"
	root._set_round_input_locked(true)
	if root.bot != null:
		root.bot.set_celebrating(true)
	if player_won and root.player_avatar != null and not RenderProfileScript.is_web_platform():
		root.player_avatar.play_celebrate()
	elif not player_won and root.bot_avatar != null and not RenderProfileScript.is_web_platform():
		root.bot_avatar.play_celebrate()
	if root.hud != null:
		var result_snapshot: Dictionary = root._build_result_snapshot()
		if root.capture_scene_active:
			result_snapshot[root.RESULT_SUPPRESS_TRANSITION_PULSE_KEY] = true
		root.hud.show_match_end(player_won, result_snapshot)
	if root.feedback != null:
		root.feedback.play_round_end(player_won)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	PerfProbeScript.end(root, "football.finish_match", profile_begin)


static func record_shot_stat(root: Node, team: StringName, super_used: bool) -> void:
	root.match_stats = FootballMatchRulesScript.record_shot_stat(root.match_stats, team, super_used)


static func record_goal_stat(root: Node, player_scored: bool, goal_value: int) -> void:
	root.match_stats = FootballMatchRulesScript.record_goal_stat(
		root.match_stats,
		player_scored,
		goal_value,
		root.match_mode_id,
		root.match_time_remaining,
		root.MATCH_DURATION_SECONDS,
		root.golden_goal_active
	)
