extends "res://addons/gut/test.gd"

const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")

func test_football_match_rules_detect_reachable_ball() -> void:
	assert_true(FootballMatchRulesScript.can_reach_ball(Vector3.ZERO, Vector3.FORWARD, Vector3(0.0, 0.0, -1.45), 0.35, 2.25))
	assert_false(FootballMatchRulesScript.can_reach_ball(Vector3.ZERO, Vector3.FORWARD, Vector3(4.0, 0.0, -1.45), 0.35, 2.25))

func test_football_match_rules_assist_reaches_near_front_side_ball() -> void:
	var assist: Dictionary = FootballMatchRulesScript.get_kick_assist(
		Vector3.ZERO,
		Vector3.FORWARD,
		Vector3(1.34, 0.0, -2.35),
		0.48,
		2.25,
		2.85
	)

	assert_true(bool(assist.get("connected", false)))
	assert_gt(float(assist.get("assist_strength", 0.0)), 0.0)

func test_football_match_rules_build_normalized_kick_direction() -> void:
	var direction: Vector3 = FootballMatchRulesScript.build_kick_direction(
		Vector3.ZERO,
		Vector3.FORWARD,
		Vector3(0.6, 0.0, -1.5),
		Vector3.FORWARD
	)

	assert_almost_eq(direction.length(), 1.0, 0.001)
	assert_lt(direction.z, -0.8)
	assert_gt(direction.x, 0.0)

func test_football_match_rules_player_contact_requires_motion_and_radius() -> void:
	var missed: Dictionary = FootballMatchRulesScript.get_player_contact_kick(Vector3.ZERO, Vector3.ZERO, Vector3(0.0, 0.5, 0.7), 1.15, 2.0)
	assert_false(bool(missed.get("connected", false)))

	var connected: Dictionary = FootballMatchRulesScript.get_player_contact_kick(Vector3.ZERO, Vector3.FORWARD * 3.0, Vector3(0.0, 0.5, -0.7), 1.15, 2.0)
	assert_true(bool(connected.get("connected", false)))
	var contact_direction: Vector3 = connected.get("direction", Vector3.ZERO)
	assert_almost_eq(contact_direction.length(), 1.0, 0.001)

func test_football_match_rules_exposes_possession_state() -> void:
	var state: Dictionary = FootballMatchRulesScript.get_player_possession_state(
		Vector3.ZERO,
		Vector3.FORWARD,
		Vector3.FORWARD * 4.0,
		Vector3(0.0, 0.5, -1.0),
		1.72,
		2.72
	)

	assert_eq(state.get("state", &"free"), &"possession")
	assert_gt(float(state.get("strength", 0.0)), 0.45)
	var direction: Vector3 = state.get("direction", Vector3.ZERO)
	assert_almost_eq(direction.length(), 1.0, 0.001)

func test_football_match_rules_goal_and_score_contract() -> void:
	assert_eq(FootballMatchRulesScript.detect_goal(Vector3(0.0, 0.58, -22.2), 4.1, -22.0, 22.0), 1)
	assert_eq(FootballMatchRulesScript.detect_goal(Vector3(0.0, 0.58, 22.2), 4.1, -22.0, 22.0), -1)
	assert_eq(FootballMatchRulesScript.detect_goal(Vector3(4.5, 0.58, -22.2), 4.1, -22.0, 22.0), 0)

	var score: Dictionary = FootballMatchRulesScript.apply_goal_score(2, 1, true, 3)
	assert_eq(score.get("player_score", 0), 3)
	assert_eq(score.get("bot_score", 0), 1)
	assert_true(bool(score.get("match_over", false)))
	assert_true(bool(score.get("player_won", false)))
