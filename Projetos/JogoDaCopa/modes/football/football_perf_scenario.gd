class_name FootballPerfScenario
extends RefCounted

const STEP_INTERVAL_SECONDS: float = 4.0
const STABILITY_SAMPLE_INTERVAL_SECONDS: float = 1.0
const INITIAL_DELAY_SECONDS: float = 2.0
const WEB_FEEDBACK_QUERY_KEY: String = "jdc_web_feedback"
const WEB_DEFAULT_FEEDBACK_EFFECTS: Array = ["whistle", "confetti", "kick", "countdown", "jump_pad", "result"]


static func maybe_quit_after_duration(root: Node, perf_probe_script: Object) -> void:
	if not perf_probe_script.is_enabled(root):
		return
	var quit_after: float = perf_probe_script.get_quit_after_seconds(root)
	if quit_after <= 0.0:
		return
	if perf_probe_script.get_elapsed_seconds(root) < quit_after:
		return
	perf_probe_script.mark(root, "session.quit_after", "seconds=%.2f" % quit_after)
	root.get_tree().quit()


static func update_stability_sampling(root: Node, delta: float, perf_probe_script: Object, field_builder_script: Object) -> void:
	if not perf_probe_script.is_stability_enabled(root):
		return
	root.perf_stability_sample_elapsed += delta
	if root.perf_stability_sample_elapsed < STABILITY_SAMPLE_INTERVAL_SECONDS:
		return
	root.perf_stability_sample_elapsed = 0.0
	perf_probe_script.log_stability_sample(root, root, build_stability_extra_counts(root, field_builder_script))


static func build_stability_extra_counts(root: Node, field_builder_script: Object) -> Dictionary:
	var counts: Dictionary = field_builder_script.debug_get_static_cache_counts()
	counts["boost_pad_areas"] = root.boost_pad_areas.size()
	counts["jump_pad_areas"] = root.jump_pad_areas.size()
	counts["stadium_scoreboard_viewports"] = root.stadium_scoreboard_viewports.size()
	counts["perf_scenario_step"] = root.perf_scenario_step
	counts["match_over"] = 1 if root.match_over else 0
	counts["goal_reset_active"] = 1 if root.goal_reset_timer > 0.0 else 0
	counts["feedback_active_effects"] = root.feedback.debug_active_effect_count() if root.feedback != null else 0
	return counts


static func start(root: Node, perf_probe_script: Object) -> void:
	root.perf_scenario_active = true
	root.perf_scenario_elapsed = -INITIAL_DELAY_SECONDS
	root.perf_scenario_step = -1
	perf_probe_script.mark(root, "perf_scenario.start")


static func update(root: Node, delta: float, perf_probe_script: Object, render_profile_script: Object) -> void:
	root.perf_scenario_elapsed += delta
	var next_step := int(floorf(root.perf_scenario_elapsed / STEP_INTERVAL_SECONDS))
	if next_step == root.perf_scenario_step:
		return
	root.perf_scenario_step = next_step
	_run_step(root, next_step, perf_probe_script, render_profile_script)


static func _run_step(root: Node, step_index: int, perf_probe_script: Object, render_profile_script: Object) -> void:
	match step_index:
		0:
			if not _is_feedback_step_enabled(root, &"whistle", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=whistle skipped=true")
				return
			root._set_menu_open(false)
			root.debug_finish_kickoff_countdown()
			perf_probe_script.mark(root, "perf_scenario.step", "action=whistle")
			if root.feedback != null:
				root.feedback.play_referee_whistle(root.ball.global_position if root.ball != null else Vector3.ZERO)
		1:
			if not _is_feedback_step_enabled(root, &"confetti", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=bot_goal_confetti skipped=true")
				return
			perf_probe_script.mark(root, "perf_scenario.step", "action=bot_goal_confetti")
			root.debug_force_ball_position(Vector3(0.0, 0.68, root.GOAL_LINE_SOUTH + 0.35))
			root._process_goal_detection()
		2:
			if not _is_feedback_step_enabled(root, &"kick", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=strong_kick skipped=true")
				return
			perf_probe_script.mark(root, "perf_scenario.step", "action=strong_kick")
			root.debug_finish_kickoff_countdown()
			root.debug_force_ball_position(root.player.global_position + (-root.player.global_transform.basis.z * 1.2) + Vector3.UP * 0.55)
			root._try_player_kick(root._get_player_kick_origin(), root._get_player_kick_direction(), root.PLAYER_KICK_FORCE, root.PLAYER_KICK_LIFT, true)
		3:
			if not _is_feedback_step_enabled(root, &"countdown", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=countdown skipped=true")
				return
			perf_probe_script.mark(root, "perf_scenario.step", "action=countdown")
			if root.hud != null:
				root.hud.show_countdown("2", 0.35)
			if root.feedback != null:
				root.feedback.play_countdown_tick(false)
		4:
			if not _is_feedback_step_enabled(root, &"kick", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=super_fireball skipped=true")
				return
			perf_probe_script.mark(root, "perf_scenario.step", "action=super_fireball")
			root.debug_finish_kickoff_countdown()
			root.debug_set_player_super_meter(root.SUPER_METER_MAX)
			root.debug_force_ball_position(root.player.global_position + (-root.player.global_transform.basis.z * 1.0) + Vector3.UP * 0.55)
			root._try_player_kick(root._get_player_kick_origin(), root._get_player_kick_direction(), root.SUPER_SHOT_FORCE, root.SUPER_SHOT_LIFT, true, true)
		5:
			if not _is_feedback_step_enabled(root, &"jump_pad", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=jump_pad skipped=true")
				return
			perf_probe_script.mark(root, "perf_scenario.step", "action=jump_pad")
			if not root.jump_pad_areas.is_empty() and root.player != null:
				root.player.global_position = root.jump_pad_areas[0].global_position
				root._update_arcade_field(0.1)
		6:
			if not _is_feedback_step_enabled(root, &"result", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=result skipped=true")
				return
			root._set_menu_open(false)
			perf_probe_script.mark(root, "perf_scenario.step", "action=result")
			root.debug_set_score(2, 0)
			root.debug_force_ball_position(Vector3(0.0, 0.68, root.GOAL_LINE_NORTH - 0.35))
			root._process_goal_detection()
		7:
			if not _is_feedback_step_enabled(root, &"result", perf_probe_script, render_profile_script):
				perf_probe_script.mark(root, "perf_scenario.step", "action=rematch skipped=true")
				return
			perf_probe_script.mark(root, "perf_scenario.step", "action=rematch")
			perf_probe_script.mark(root, "event.rematch")
			root.restart_match()
			root.debug_finish_kickoff_countdown()
		_:
			perf_probe_script.mark(root, "perf_scenario.step", "action=coast index=%d" % step_index)


static func _is_feedback_step_enabled(root: Node, effect_key: StringName, perf_probe_script: Object, render_profile_script: Object) -> bool:
	if not render_profile_script.is_web_platform():
		return true
	_load_feedback_scenario_filter(root, perf_probe_script, render_profile_script)
	if root.web_feedback_scenario_allow_all:
		return true
	return root.web_feedback_scenario_enabled.has(str(effect_key))


static func _load_feedback_scenario_filter(root: Node, perf_probe_script: Object, render_profile_script: Object) -> void:
	if root.web_feedback_scenario_filter_loaded:
		return
	root.web_feedback_scenario_filter_loaded = true
	root.web_feedback_scenario_enabled.clear()
	root.web_feedback_scenario_allow_all = false
	var query_value := ""
	if render_profile_script.is_web_platform():
		var script := "(new URLSearchParams(window.location.search)).get('%s') || ''" % WEB_FEEDBACK_QUERY_KEY
		query_value = str(JavaScriptBridge.eval(script, true)).strip_edges().to_lower()
	if query_value.is_empty():
		_enable_default_feedback_steps(root)
		perf_probe_script.mark(root, "perf_scenario.feedback_filter", "mode=default effects=%s" % ",".join(WEB_DEFAULT_FEEDBACK_EFFECTS))
		return
	if query_value == "all":
		root.web_feedback_scenario_allow_all = true
		perf_probe_script.mark(root, "perf_scenario.feedback_filter", "mode=all")
		return
	if query_value == "none":
		root.web_feedback_scenario_allow_all = false
		perf_probe_script.mark(root, "perf_scenario.feedback_filter", "mode=none")
		return
	root.web_feedback_scenario_allow_all = false
	for part in query_value.split(",", false):
		var effect := part.strip_edges()
		if not effect.is_empty():
			root.web_feedback_scenario_enabled[effect] = true
	perf_probe_script.mark(root, "perf_scenario.feedback_filter", "mode=list effects=%s" % query_value)


static func _enable_default_feedback_steps(root: Node) -> void:
	for effect in WEB_DEFAULT_FEEDBACK_EFFECTS:
		root.web_feedback_scenario_enabled[str(effect)] = true
