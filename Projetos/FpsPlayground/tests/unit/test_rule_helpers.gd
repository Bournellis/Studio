extends "res://addons/gut/test.gd"

const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")
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
