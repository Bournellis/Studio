extends "res://addons/gut/test.gd"

const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")
const BotAimModelScript = preload("res://gameplay/bot/bot_aim_model.gd")
const BotScript = preload("res://gameplay/bot/basic_duel_bot.gd")
const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")
const BotVisibilityPointsScript = preload("res://gameplay/bot/bot_visibility_points.gd")
const ArenaLayoutCatalogScript = preload("res://modes/arena/arena_layout_catalog.gd")
const ArenaHudSnapshotBuilderScript = preload("res://modes/arena/arena_hud_snapshot_builder.gd")
const ArenaCombatPipelineScript = preload("res://modes/arena/arena_combat_pipeline.gd")

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

func test_arena_weapon_role_helpers_calculate_overcharge_and_damage_rate() -> void:
	assert_almost_eq(ArenaCombatRulesScript.calculate_overcharged_value(20.0, 1.35, false), 20.0, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.calculate_overcharged_value(20.0, 1.35, true), 27.0, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.calculate_sustained_damage_rate(22.0, 0.18), 122.222, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.calculate_sustained_damage_rate(24.0, 0.9), 26.667, 0.001)

func test_arena_plasma_blast_falloff_and_damage_contract() -> void:
	var impact := Vector3.ZERO
	var near_target := Vector3(0.0, 0.0, 0.5)
	var edge_target := Vector3(0.0, 0.0, 2.0)
	var outside_target := Vector3(0.0, 0.0, 2.2)

	assert_almost_eq(ArenaCombatRulesScript.calculate_blast_falloff(impact, near_target, 2.0), 0.75, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.calculate_blast_falloff(impact, edge_target, 2.0), 0.0, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.calculate_blast_damage(impact, near_target, 2.0, 10.0, 0.35), 8.375, 0.001)
	assert_almost_eq(ArenaCombatRulesScript.calculate_blast_damage(impact, outside_target, 2.0, 10.0, 0.35), 0.0, 0.001)

func test_arena_combat_pipeline_builds_player_rifle_payload_contract() -> void:
	var payload := ArenaCombatPipelineScript.build_player_rifle_fired(
		"player_rifle_1",
		Vector3.ONE,
		Vector3.FORWARD,
		22.0,
		4.5,
		ArenaCombatPipelineScript.is_overcharged_damage(22.0, 20.0)
	)

	assert_true(bool(payload.get("overcharged", false)))
	assert_eq(payload.get("actor", ""), "player")
	assert_eq(payload.get("weapon", ""), "rifle")
	assert_eq(payload.get("source", ""), "player_rifle")
	assert_eq(payload.get("shot_id", ""), "player_rifle_1")
	assert_almost_eq(float(payload.get("damage", 0.0)), 22.0, 0.001)
	assert_false(ArenaCombatPipelineScript.is_overcharged_damage(20.0005, 20.0))

func test_arena_combat_pipeline_builds_plasma_payload_contract() -> void:
	var fired := ArenaCombatPipelineScript.build_player_plasma_fired(
		"player_plasma_2",
		Vector3.ZERO,
		Vector3(0.0, 1.4, -0.8),
		Vector3.FORWARD,
		24.0,
		8.0,
		24.0,
		0.18,
		true
	)
	var summary := ArenaCombatPipelineScript.build_player_plasma_blast_summary(
		"player_plasma_2",
		Vector3.ZERO,
		Vector3(0.0, 0.0, 0.5),
		2.25,
		0.75,
		8.8,
		true,
		false,
		true
	)

	assert_eq(fired.get("weapon", ""), "plasma_direct")
	assert_eq(fired.get("source", ""), "player_plasma")
	assert_eq(fired.get("projectile_id", ""), "player_plasma_2")
	assert_eq(summary.get("weapon", ""), "plasma_blast")
	assert_eq(summary.get("source", ""), "player_plasma_blast")
	assert_eq(summary.get("target", ""), "bot")
	assert_true(bool(summary.get("damaged_target", false)))
	assert_false(bool(summary.get("killed_target", true)))

func test_arena_combat_pipeline_calculates_plasma_blast_contract() -> void:
	var blast := ArenaCombatPipelineScript.calculate_player_plasma_blast(
		Vector3.ZERO,
		Vector3(0.0, 0.0, 0.5),
		Vector3.FORWARD,
		24.0,
		10.0,
		2.0,
		0.46,
		0.22,
		0.36
	)

	assert_true(bool(blast.get("damaged", false)))
	assert_almost_eq(float(blast.get("falloff", 0.0)), 0.75, 0.001)
	assert_almost_eq(float(blast.get("damage", 0.0)), 8.887, 0.001)
	assert_almost_eq(float(blast.get("knockback", 0.0)), 2.7, 0.001)
	assert_almost_eq((blast.get("direction", Vector3.ZERO) as Vector3).distance_to(Vector3.BACK), 0.0, 0.001)

func test_arena_hud_snapshot_builder_preserves_duel_status_contract() -> void:
	var snapshot := ArenaHudSnapshotBuilderScript.build_snapshot({
		"status": "Relay Foundry V1 | Round 2 | Player 1 x 0 Bot",
		"map_name": "Relay Foundry V1",
		"round_state": &"player_round_win",
		"round_index": 2,
		"score_to_win": 3,
		"player_score": 1,
		"bot_score": 0,
		"last_round_winner": &"player",
		"health_pickup_available": true,
		"health_pickup_respawn": 0.0,
		"overcharge_pickup_available": false,
		"overcharge_pickup_respawn": 6.5,
		"last_jump_pad_id": &"east_forge_pad",
		"round_ended": true
	})

	assert_eq(snapshot.get("result_text", ""), "Player venceu o round")
	assert_eq(snapshot.get("hint", ""), "R proximo round | Esc menu")
	assert_eq(snapshot.get("score_to_win", 0), 3)
	assert_eq(snapshot.get("bot_state", &""), &"none")
	assert_eq(snapshot.get("last_jump_pad_id", &""), &"east_forge_pad")
	assert_eq(
		ArenaHudSnapshotBuilderScript.build_playing_status("Duel Pit V2", 1, 0, 0),
		"Duel Pit V2 | Round 1 | Player 0 x 0 Bot"
	)
	assert_eq(
		ArenaHudSnapshotBuilderScript.build_result_status(&"match_over", &"bot", 2, 3, 5),
		"Bot venceu o duelo 2 x 3. Aperte R para novo duelo."
	)
	assert_eq(ArenaHudSnapshotBuilderScript.build_result_text(&"playing", &"", 3), "First to 3")
	assert_eq(ArenaHudSnapshotBuilderScript.build_hint(&"match_over", true), "R novo duelo | Esc menu")

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

func test_arena_layout_catalog_exposes_distinct_tactical_contexts() -> void:
	var layout_ids := ArenaLayoutCatalogScript.get_layout_ids()
	assert_eq(layout_ids.size(), 3)
	assert_true(layout_ids.has(ArenaLayoutCatalogScript.DUEL_PIT_ID))
	assert_true(layout_ids.has(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID))
	assert_true(layout_ids.has(ArenaLayoutCatalogScript.CROSSFIRE_CRUCIBLE_ID))

	var duel_pit := ArenaLayoutCatalogScript.build_layout_spec(ArenaLayoutCatalogScript.DUEL_PIT_ID)
	var relay_foundry := ArenaLayoutCatalogScript.build_layout_spec(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID)
	var crossfire_crucible := ArenaLayoutCatalogScript.build_layout_spec(ArenaLayoutCatalogScript.CROSSFIRE_CRUCIBLE_ID)
	assert_eq(duel_pit.get("id", &""), &"duel_pit_v2")
	assert_eq(relay_foundry.get("id", &""), &"relay_foundry_v1")
	assert_eq(crossfire_crucible.get("id", &""), &"crossfire_crucible_v1")
	assert_false(duel_pit.get("player_spawn", Vector3.ZERO) == relay_foundry.get("player_spawn", Vector3.ZERO))
	assert_false(duel_pit.get("bot_spawn", Vector3.ZERO) == relay_foundry.get("bot_spawn", Vector3.ZERO))
	assert_false(crossfire_crucible.get("player_spawn", Vector3.ZERO) == relay_foundry.get("player_spawn", Vector3.ZERO))
	assert_false(crossfire_crucible.get("bot_spawn", Vector3.ZERO) == relay_foundry.get("bot_spawn", Vector3.ZERO))
	assert_gt((duel_pit.get("tactical_points", []) as Array).size(), 10)
	assert_gt((relay_foundry.get("tactical_points", []) as Array).size(), 10)
	assert_gt((crossfire_crucible.get("tactical_points", []) as Array).size(), 10)
	assert_eq((duel_pit.get("jump_pad_routes", []) as Array).size(), 2)
	assert_eq((relay_foundry.get("jump_pad_routes", []) as Array).size(), 2)
	assert_eq((crossfire_crucible.get("jump_pad_routes", []) as Array).size(), 2)

	var relay_roles: Array[StringName] = []
	for point: Dictionary in relay_foundry.get("tactical_points", []):
		var role: StringName = point.get("role", &"")
		if not relay_roles.has(role):
			relay_roles.append(role)
	assert_true(relay_roles.has(BotTacticalContextScript.ROLE_PRESSURE))
	assert_true(relay_roles.has(BotTacticalContextScript.ROLE_HIGH_GROUND))
	assert_true(relay_roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY))

	var crossfire_roles: Array[StringName] = []
	for point: Dictionary in crossfire_crucible.get("tactical_points", []):
		var role: StringName = point.get("role", &"")
		if not crossfire_roles.has(role):
			crossfire_roles.append(role)
	assert_true(crossfire_roles.has(BotTacticalContextScript.ROLE_PRESSURE))
	assert_true(crossfire_roles.has(BotTacticalContextScript.ROLE_HIGH_GROUND))
	assert_true(crossfire_roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY))
	assert_true(crossfire_roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_LANDING))

func test_arena_layout_catalog_exposes_staged_vertical_route_contracts() -> void:
	for layout_id: StringName in ArenaLayoutCatalogScript.get_layout_ids():
		var spec := ArenaLayoutCatalogScript.build_layout_spec(layout_id)
		var points: Array = spec.get("tactical_points", [])
		for route: Dictionary in spec.get("jump_pad_routes", []):
			var route_id: StringName = route.get("id", &"")
			var route_position: Vector3 = route.get("position", Vector3.ZERO)
			var route_target: Vector3 = route.get("target", Vector3.ZERO)
			assert_ne(route_id, &"", "Jump pad route must have a stable route id.")
			assert_gt(_flat_distance_between(route_position, route_target), 4.0, "Jump pad route %s needs useful flat travel distance." % String(route_id))
			assert_true(_layout_has_role_for_route(points, route_id, BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY), "Route %s needs jump pad entry point." % String(route_id))
			assert_true(_layout_has_role_for_route(points, route_id, BotTacticalContextScript.ROLE_JUMP_PAD_LANDING), "Route %s needs landing point." % String(route_id))
			assert_true(_layout_has_role_for_route(points, route_id, BotTacticalContextScript.ROLE_HIGH_GROUND), "Route %s needs high-ground continuation." % String(route_id))

func test_relay_foundry_jump_pads_are_not_glued_to_high_platforms() -> void:
	var relay_foundry := ArenaLayoutCatalogScript.build_layout_spec(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID)
	var routes: Array = relay_foundry.get("jump_pad_routes", [])
	assert_eq(routes.size(), 2)
	for route: Dictionary in routes:
		var route_position: Vector3 = route.get("position", Vector3.ZERO)
		var route_target: Vector3 = route.get("target", Vector3.ZERO)
		assert_gt(_flat_distance_between(route_position, route_target), 10.0)
		assert_gt(absf(route_position.z - route_target.z), 9.5)

func test_crossfire_crucible_jump_pad_routes_have_distinct_lengths() -> void:
	var crossfire_crucible := ArenaLayoutCatalogScript.build_layout_spec(ArenaLayoutCatalogScript.CROSSFIRE_CRUCIBLE_ID)
	var routes: Array = crossfire_crucible.get("jump_pad_routes", [])
	assert_eq(routes.size(), 2)
	var first_distance := _flat_distance_between(routes[0].get("position", Vector3.ZERO), routes[0].get("target", Vector3.ZERO))
	var second_distance := _flat_distance_between(routes[1].get("position", Vector3.ZERO), routes[1].get("target", Vector3.ZERO))
	assert_gt(first_distance, 7.0)
	assert_gt(second_distance, 11.0)
	assert_gt(absf(first_distance - second_distance), 3.0)

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

func test_bot_keeps_jump_pad_as_navigation_target_until_vertical_launch() -> void:
	var bot = BotScript.new()
	var target := MockBotTarget.new()
	add_child_autofree(bot)
	add_child_autofree(target)
	bot.global_position = Vector3(4.8, 0.05, 0.1)
	target.global_position = Vector3(0.0, 0.05, -8.0)
	bot.configure(target)
	bot.set_tactical_context(BotTacticalContextScript.make_context(&"test_arena", [
		BotTacticalContextScript.make_point(Vector3(5.0, 0.08, 0.0), BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, 1.0, &"test_pad"),
		BotTacticalContextScript.make_point(Vector3(5.0, 3.05, 6.0), BotTacticalContextScript.ROLE_JUMP_PAD_LANDING, 1.0, &"test_pad"),
		BotTacticalContextScript.make_point(Vector3(5.0, 3.05, 7.2), BotTacticalContextScript.ROLE_HIGH_GROUND, 1.0, &"test_pad")
	], [
		BotTacticalContextScript.make_jump_pad_route(&"test_pad", Vector3(5.0, 0.08, 0.0), Vector3(5.0, 3.05, 6.0))
	]))

	var navigation_target: Vector3 = bot._resolve_navigation_target(Vector3(5.0, 3.05, 7.2))

	assert_almost_eq(navigation_target.distance_to(Vector3(5.0, 0.08, 0.0)), 0.0, 0.001)

func _layout_has_role_for_route(points: Array, route_id: StringName, role: StringName) -> bool:
	for point: Dictionary in points:
		if point.get("route", &"") == route_id and point.get("role", &"") == role:
			return true
	return false

func _flat_distance_between(first_point: Vector3, second_point: Vector3) -> float:
	var delta := first_point - second_point
	delta.y = 0.0
	return delta.length()
