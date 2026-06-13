extends "res://addons/gut/test.gd"

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func test_broadcast_scorebug_states_and_super_meter() -> void:
	var hud := FootballHud.new()
	add_child_autofree(hud)
	await get_tree().process_frame

	assert_true(hud.debug_has_broadcast_scorebug_v1())
	assert_not_null(hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BroadcastScoreRow/PlayerKitSwatch"))
	assert_not_null(hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BroadcastScoreRow/BotKitSwatch"))
	assert_not_null(hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/StateBadgeLabel"))
	assert_not_null(hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BoostBar"))
	assert_not_null(hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/SuperMeterRow/SuperBar"))
	var flow_label := hud.get_node("HudRoot/ScorePanel/ScoreBox/FlowLabel") as Label
	var control_label := hud.get_node("HudRoot/ScorePanel/ScoreBox/ControlLabel") as Label
	assert_false(flow_label.visible)
	assert_false(control_label.visible)
	hud.debug_set_telemetry_visible(true)
	assert_true(flow_label.visible)
	assert_true(control_label.visible)
	hud.debug_set_telemetry_visible(false)
	assert_false(flow_label.visible)
	assert_false(control_label.visible)

	hud.update_snapshot(_build_snapshot({
		"match_mode": "goals",
		"boost_fraction": 0.66,
		"player_super_fraction": 0.5,
	}))
	assert_false(flow_label.visible)
	assert_false(control_label.visible)
	assert_ne(flow_label.text, "")
	assert_ne(control_label.text, "")
	assert_eq(hud.debug_get_state_badge_text(), "3 GOLS")
	assert_almost_eq(hud.debug_get_super_bar_value(), 50.0, 0.001)
	assert_false(hud.debug_is_super_ready_visible())

	hud.update_snapshot(_build_snapshot({
		"match_mode": "timer",
		"match_time_remaining": 25.0,
		"player_super_fraction": 1.0,
	}))
	assert_eq(hud.debug_get_state_badge_text(), "VALE 2")
	assert_true(hud.debug_is_super_ready_visible())
	assert_true(hud.debug_get_clock_text().contains("00:25"))

	hud.update_snapshot(_build_snapshot({
		"match_mode": "timer",
		"golden_goal_active": true,
		"match_time_remaining": 0.0,
	}))
	assert_eq(hud.debug_get_state_badge_text(), "GOLDEN GOAL")
	assert_true(hud.debug_get_clock_text().contains("GOLDEN GOAL"))
	assert_no_new_orphans()

func test_goal_and_countdown_have_broadcast_punch_feedback() -> void:
	var hud := FootballHud.new()
	add_child_autofree(hud)
	await get_tree().process_frame

	hud.show_goal(true, 2, true)
	hud._process(0.08)
	assert_true(hud.debug_get_event_text().contains("VALE 2"))
	assert_gt(hud.debug_get_scorebug_scale().x, 1.0)

	hud.reset_feedback()
	hud.show_countdown("3")
	hud._process(0.04)
	assert_eq(hud.debug_get_event_text(), "3")
	assert_gt(hud.get_node("HudRoot/FootballEventLabel").scale.x, 1.0)
	assert_gt(hud.debug_get_scorebug_scale().x, 1.0)
	assert_no_new_orphans()

func test_kickoff_countdown_still_starts_once_with_broadcast_hud() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	assert_eq(football.debug_get_kickoff_countdown_start_count(), 0)
	football.debug_start_match_with_countdown()
	assert_eq(football.debug_get_kickoff_countdown_start_count(), 1)

	var hud := football.get_node("FootballHud")
	assert_true(hud.debug_has_broadcast_scorebug_v1())
	assert_true(["SAIDA PLAYER", "3"].has(hud.debug_get_event_text()))
	assert_no_new_orphans()

func _build_snapshot(overrides: Dictionary = {}) -> Dictionary:
	var snapshot := {
		"status": "Futebol 1x1",
		"player_score": 1,
		"bot_score": 0,
		"player_kit_code": "BRA",
		"bot_kit_code": "FRA",
		"player_kit_color": Color(1.0, 0.86, 0.12, 1.0),
		"bot_kit_color": Color(0.06, 0.16, 0.56, 1.0),
		"phase": "match",
		"match_mode": "goals",
		"goal_limit": 3,
		"match_time_remaining": 180.0,
		"golden_goal_active": false,
		"ball_distance": 8.0,
		"ball_relative_x": 0.0,
		"ball_relative_z": -1.0,
		"ball_control": "reachable",
		"ball_control_strength": 0.45,
		"boost_fraction": 1.0,
		"boost_active": false,
		"dash_cooldown_fraction": 0.0,
		"shoot_charge_fraction": 0.0,
		"player_super_fraction": 0.0,
		"bot_state": "attack",
		"bot_difficulty": "normal",
		"kickoff_owner": "player",
	}
	for key in overrides.keys():
		snapshot[key] = overrides[key]
	return snapshot
