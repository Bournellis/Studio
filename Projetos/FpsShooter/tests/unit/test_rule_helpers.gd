extends "res://addons/gut/test.gd"

const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")
const FootballMatchRulesScript = preload("res://gameplay/football/football_match_rules.gd")
const BotAimModelScript = preload("res://gameplay/bot/bot_aim_model.gd")
const BotVisibilityPointsScript = preload("res://gameplay/bot/bot_visibility_points.gd")

class MockVisibilityTarget:
	extends Node3D

	func get_shot_origin() -> Vector3:
		return global_position + Vector3.UP * 1.52

func test_arena_visual_muzzle_origin_uses_camera_offsets() -> void:
	var camera := Camera3D.new()
	add_child_autofree(camera)
	camera.global_position = Vector3(0.0, 1.6, 0.0)

	var origin := Vector3(0.0, 1.6, 0.0)
	var result: Vector3 = ArenaCombatRulesScript.build_visual_muzzle_origin(origin, Vector3.FORWARD, camera, 0.34, 0.24, 0.82)

	assert_almost_eq(result.x, 0.34, 0.001)
	assert_almost_eq(result.y, 1.36, 0.001)
	assert_almost_eq(result.z, -0.82, 0.001)

func test_arena_projectile_direction_falls_back_when_aim_point_matches_muzzle() -> void:
	var direction: Vector3 = ArenaCombatRulesScript.build_projectile_direction(Vector3.ONE, Vector3.ONE, Vector3.FORWARD)

	assert_almost_eq(direction.distance_to(Vector3.FORWARD), 0.0, 0.001)

func test_arena_pickup_respawn_uses_kind_contract() -> void:
	assert_almost_eq(ArenaCombatRulesScript.get_pickup_respawn_duration(&"health", 10.0, 14.0), 10.0, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.get_pickup_respawn_duration(&"overcharge", 10.0, 14.0), 14.0, 0.001)

func test_football_match_rules_detect_reachable_ball() -> void:
	assert_true(FootballMatchRulesScript.can_reach_ball(Vector3.ZERO, Vector3.FORWARD, Vector3(0.0, 0.0, -1.45), 0.35, 2.25))
	assert_false(FootballMatchRulesScript.can_reach_ball(Vector3.ZERO, Vector3.FORWARD, Vector3(4.0, 0.0, -1.45), 0.35, 2.25))

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

func test_football_match_rules_goal_and_score_contract() -> void:
	assert_eq(FootballMatchRulesScript.detect_goal(Vector3(0.0, 0.58, -22.2), 4.1, -22.0, 22.0), 1)
	assert_eq(FootballMatchRulesScript.detect_goal(Vector3(0.0, 0.58, 22.2), 4.1, -22.0, 22.0), -1)
	assert_eq(FootballMatchRulesScript.detect_goal(Vector3(4.5, 0.58, -22.2), 4.1, -22.0, 22.0), 0)

	var score: Dictionary = FootballMatchRulesScript.apply_goal_score(2, 1, true, 3)
	assert_eq(score.get("player_score", 0), 3)
	assert_eq(score.get("bot_score", 0), 1)
	assert_true(bool(score.get("match_over", false)))
	assert_true(bool(score.get("player_won", false)))

func test_bot_aim_model_uses_deterministic_patterns() -> void:
	assert_eq(BotAimModelScript.pattern_for_index(0), Vector2(0.12, 0.04))
	assert_eq(BotAimModelScript.pattern_for_index(6), Vector2(0.12, 0.04))

	var aim_position: Vector3 = BotAimModelScript.build_aim_position(
		Vector3(0.0, 1.0, -10.0),
		Vector3.ZERO,
		18.0,
		0.16,
		0.48,
		BotAimModelScript.pattern_for_index(2)
	)
	assert_gt(aim_position.x, 0.0)
	assert_gt(aim_position.y, 0.95)
	assert_almost_eq(aim_position.z, -10.0, 0.001)

func test_bot_visibility_points_remove_duplicate_target_exposure_points() -> void:
	var target := MockVisibilityTarget.new()
	add_child_autofree(target)
	target.global_position = Vector3.ZERO

	var points: Array[Vector3] = BotVisibilityPointsScript.build_target_points(target, Vector3(0.0, 0.82, 0.0), 1.52, 1.18, 0.82, 0.42)

	assert_eq(points.size(), 4)
	assert_almost_eq(points[0].y, 1.52, 0.001)
	assert_almost_eq(points[1].y, 1.18, 0.001)
	assert_almost_eq(points[2].y, 0.82, 0.001)
	assert_almost_eq(points[3].y, 0.42, 0.001)
