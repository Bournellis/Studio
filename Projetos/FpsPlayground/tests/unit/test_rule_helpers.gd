extends "res://addons/gut/test.gd"

const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")
const BotAimModelScript = preload("res://gameplay/bot/bot_aim_model.gd")
const BotScript = preload("res://gameplay/bot/basic_duel_bot.gd")
const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")
const BotVisibilityPointsScript = preload("res://gameplay/bot/bot_visibility_points.gd")

class MockVisibilityTarget:
	extends Node3D

	func get_shot_origin() -> Vector3:
		return global_position + Vector3.UP * 1.52

class MockBotTarget:
	extends Node3D

	var is_dead: bool = false
	var health: float = 100.0
	var max_health: float = 100.0

	func get_body_center() -> Vector3:
		return global_position + Vector3.UP * 0.82

	func health_fraction() -> float:
		return health / maxf(1.0, max_health)

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

func test_bot_tactical_context_filters_unavailable_points_by_role() -> void:
	var context := BotTacticalContextScript.make_context(&"test_arena", [
		BotTacticalContextScript.make_point(Vector3.ZERO, BotTacticalContextScript.ROLE_PRESSURE, 1.0, &"pressure_a"),
		BotTacticalContextScript.make_point(Vector3(2.0, 0.0, 0.0), BotTacticalContextScript.ROLE_HEALTH, 1.0, &"health_a", false),
		BotTacticalContextScript.make_point(Vector3(4.0, 0.0, 0.0), BotTacticalContextScript.ROLE_HEALTH, 1.0, &"health_b", true)
	])

	assert_eq(BotTacticalContextScript.get_points(context).size(), 2)
	assert_eq(BotTacticalContextScript.points_for_role(context, BotTacticalContextScript.ROLE_HEALTH).size(), 1)

func test_bot_scores_alternate_tactical_context_without_duel_pit_points() -> void:
	var bot = BotScript.new()
	var target := MockBotTarget.new()
	add_child_autofree(bot)
	add_child_autofree(target)
	bot.global_position = Vector3.ZERO
	target.global_position = Vector3(0.0, 0.05, -8.0)
	bot.configure(target)
	bot.last_has_line_of_sight = false
	bot.set_tactical_context(BotTacticalContextScript.make_context(&"test_arena", [
		BotTacticalContextScript.make_point(Vector3(0.0, 0.05, -6.0), BotTacticalContextScript.ROLE_PRESSURE, 1.0, &"test_pressure"),
		BotTacticalContextScript.make_point(Vector3(4.0, 3.05, -4.0), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.45, &"test_high")
	]))

	bot._choose_reposition_destination()

	assert_eq(bot.debug_get_tactical_context_label(), &"test_arena")
	assert_eq(bot.debug_get_decision_reason(), BotTacticalContextScript.ROLE_HIGH_GROUND)
	assert_eq(bot.debug_get_route_label(), &"high")
	assert_gt(bot.debug_get_recent_route_count(), 0)
