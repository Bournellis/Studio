extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const PlayerScript = preload("res://gameplay/player/fps_player_controller.gd")
const ArenaHudScript = preload("res://presentation/hud/arena_hud.gd")
const FeedbackScript = preload("res://presentation/feedback/fps_feedback_controller.gd")
const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")
const ArenaLayoutCatalogScript = preload("res://modes/arena/arena_layout_catalog.gd")

const EXPECTED_ACTIONS: PackedStringArray = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"jump",
	"shoot",
	"alt_fire",
	"restart_round",
	"ui_back"
]

func before_all() -> void:
	var result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func test_input_actions_are_bootstrapped() -> void:
	for action_name: String in EXPECTED_ACTIONS:
		assert_true(InputMap.has_action(action_name), "Missing input action %s" % action_name)
		assert_gt(InputMap.action_get_events(action_name).size(), 0, "Input action %s has no binding" % action_name)

func test_main_menu_scene_boots_with_arena_selection_buttons() -> void:
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	assert_not_null(menu_scene)
	var menu := menu_scene.instantiate()
	add_child_autofree(menu)
	await get_tree().process_frame

	assert_eq(menu.debug_get_mode_path(&"arena"), "res://modes/arena/arena.tscn")
	assert_eq(menu.debug_get_mode_path(&"relay_foundry"), "res://modes/arena/arena.tscn")
	assert_eq(menu.debug_get_mode_path(&"crossfire_crucible"), "res://modes/arena/arena.tscn")
	assert_eq(menu.debug_get_layout_id(&"arena"), &"duel_pit_v2")
	assert_eq(menu.debug_get_layout_id(&"relay_foundry"), &"relay_foundry_v1")
	assert_eq(menu.debug_get_layout_id(&"crossfire_crucible"), &"crossfire_crucible_v1")
	assert_eq(menu.debug_get_mode_path(&"football"), "")
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/ArenaButton"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/RelayFoundryButton"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/CrossfireCrucibleButton"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/FootballButton"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/QuitButton"))
	var menu_center := menu.get_node("MenuCenter") as CenterContainer
	var menu_panel := menu.get_node("MenuCenter/MenuPanel") as PanelContainer
	assert_almost_eq(menu_center.anchor_left, 0.0, 0.001)
	assert_almost_eq(menu_center.anchor_right, 1.0, 0.001)
	assert_eq(menu_panel.custom_minimum_size, Vector2(540.0, 390.0))
	assert_no_new_orphans()

func test_arena_scene_boots_with_player_bot_camera_and_hud() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	assert_not_null(arena_scene)
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	assert_not_null(arena.get_node_or_null("WorldEnvironment"))
	assert_not_null(arena.get_node_or_null("KeyLight"))
	assert_not_null(arena.get_node_or_null("ArenaFloor"))
	assert_not_null(arena.get_node_or_null("MidBlocker"))
	assert_not_null(arena.get_node_or_null("WestJumpPad"))
	assert_not_null(arena.get_node_or_null("EastJumpPad"))
	assert_null(arena.get_node_or_null("NorthVoidWell"))
	assert_null(arena.get_node_or_null("SouthVoidWell"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Bot"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Projectiles"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/HealthShard"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/Overcharge"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/HealthShard/ReadabilityHalo"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/HealthShard/ReadabilityBeacon"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/Overcharge/ReadabilityHalo"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/Overcharge/ReadabilityBeacon"))
	assert_not_null(arena.get_node_or_null("WestJumpPad/LaunchDirectionCue"))
	assert_not_null(arena.get_node_or_null("EastJumpPad/LaunchDirectionCue"))
	assert_not_null(arena.get_node_or_null("ArenaHud"))
	assert_not_null(arena.get_node_or_null("FeedbackController"))

	var player = arena.get_node("RuntimeRoot/Player")
	var bot = arena.get_node("RuntimeRoot/Bot")
	assert_true(player.get_script() == PlayerScript)
	assert_almost_eq(player.mouse_sensitivity, 0.0011, 0.00001)
	assert_not_null(player.get_node_or_null("Head/Camera3D"))
	assert_true((player.get_node("Head/Camera3D") as Camera3D).current)
	assert_almost_eq((player.get_node("Head/Camera3D") as Camera3D).fov, 86.0, 0.01)
	assert_eq(bot.debug_get_state(), &"reposition")
	assert_true(bot.debug_get_target() == player)
	assert_eq(bot.debug_get_tactical_context_label(), &"duel_pit_v2")
	assert_gt(bot.debug_get_tactical_point_count(), 0)

	var hud_root := arena.get_node("ArenaHud/HudRoot") as Control
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/ScoreLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/RoundLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/ResultLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/PlayerLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/CombatLoopLabel"))
	assert_not_null(hud_root.get_node_or_null("Crosshair/HitMarker"))
	assert_not_null(hud_root.get_node_or_null("CombatEventLabel"))
	var sensitivity_slider := hud_root.get_node_or_null("PauseMenuPanel/PauseMenuMargin/PauseMenuBox/SensitivitySlider") as HSlider
	assert_not_null(sensitivity_slider)
	assert_almost_eq(float(sensitivity_slider.value), 0.0011, 0.00001)
	assert_not_null(hud_root.get_node_or_null("PauseMenuPanel/PauseMenuMargin/PauseMenuBox/NewMatchButton"))
	assert_no_new_orphans()

func test_arena_duel_state_scores_rounds_and_match_reset() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	assert_eq(arena.debug_get_round_state(), &"playing")
	assert_eq(arena.debug_get_round_index(), 1)
	assert_eq(arena.debug_get_player_score(), 0)
	assert_eq(arena.debug_get_bot_score(), 0)
	assert_eq(arena.debug_get_hud_snapshot().get("result_text", ""), "First to 3")

	arena.debug_force_round_result(true)
	assert_eq(arena.debug_get_round_state(), &"player_round_win")
	assert_eq(arena.debug_get_last_round_winner(), &"player")
	assert_eq(arena.debug_get_player_score(), 1)
	assert_eq(arena.debug_get_bot_score(), 0)
	arena.debug_force_round_result(true)
	assert_eq(arena.debug_get_player_score(), 1)

	arena.restart_round()
	assert_eq(arena.debug_get_round_state(), &"playing")
	assert_eq(arena.debug_get_round_index(), 2)
	assert_eq(arena.debug_get_player_score(), 1)
	assert_eq(arena.debug_get_bot_score(), 0)

	while arena.debug_get_player_score() < arena.debug_get_score_to_win():
		arena.debug_force_round_result(true)
		if arena.debug_get_round_state() != &"match_over":
			arena.restart_round()

	assert_eq(arena.debug_get_round_state(), &"match_over")
	assert_eq(arena.debug_get_match_winner(), &"player")
	assert_eq(arena.debug_get_player_score(), arena.debug_get_score_to_win())
	assert_true(str(arena.debug_get_hud_snapshot().get("hint", "")).contains("novo duelo"))

	arena.restart_round()
	assert_eq(arena.debug_get_round_state(), &"playing")
	assert_eq(arena.debug_get_round_index(), 1)
	assert_eq(arena.debug_get_player_score(), 0)
	assert_eq(arena.debug_get_bot_score(), 0)
	assert_eq(arena.debug_get_match_winner(), &"")
	assert_no_new_orphans()

func test_arena_duel_state_starts_clean_for_all_layouts() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	for layout_id: StringName in ArenaLayoutCatalogScript.get_layout_ids():
		var arena := arena_scene.instantiate()
		arena.set_arena_layout(layout_id)
		add_child_autofree(arena)
		await get_tree().process_frame
		await get_tree().physics_frame

		assert_eq(arena.debug_get_active_layout_id(), layout_id)
		assert_eq(arena.debug_get_round_state(), &"playing")
		assert_eq(arena.debug_get_round_index(), 1)
		assert_eq(arena.debug_get_player_score(), 0)
		assert_eq(arena.debug_get_bot_score(), 0)
		assert_eq(arena.debug_get_hud_snapshot().get("score_to_win", 0), arena.debug_get_score_to_win())
	assert_no_new_orphans()

func test_duel_pit_layout_exposes_route_markers_and_bot_points() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var points: Array[Vector3] = arena.debug_get_bot_reposition_points()
	assert_eq(points.size(), 18)
	var tactical_root := arena.get_node_or_null("RuntimeRoot/BotTacticalPoints")
	assert_not_null(tactical_root)
	assert_true(tactical_root.get_child_count() >= 18)
	assert_eq(arena.debug_get_bot_tactical_point_count(), 20)
	var roles: Array[StringName] = arena.debug_get_bot_tactical_roles()
	assert_true(roles.has(BotTacticalContextScript.ROLE_PRESSURE))
	assert_true(roles.has(BotTacticalContextScript.ROLE_HEALTH))
	assert_true(roles.has(BotTacticalContextScript.ROLE_OVERCHARGE))
	assert_true(roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY))
	assert_gt(arena.debug_get_flow_marker_count(), 5)
	assert_true(arena.debug_has_high_platform_cover())
	assert_no_new_orphans()

func test_relay_foundry_layout_exposes_distinct_route_markers_and_bot_points() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	arena.set_arena_layout(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID)
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	assert_eq(arena.debug_get_active_layout_id(), &"relay_foundry_v1")
	assert_eq(arena.debug_get_active_layout_name(), "Relay Foundry V1")
	assert_not_null(arena.get_node_or_null("RelayFoundryFloor"))
	assert_not_null(arena.get_node_or_null("RelayCore"))
	assert_not_null(arena.get_node_or_null("WestRelayJumpPad"))
	assert_not_null(arena.get_node_or_null("EastForgeJumpPad"))
	assert_null(arena.get_node_or_null("MidBlocker"))
	assert_eq(arena.debug_get_jump_pad_count(), 2)
	assert_eq(arena.debug_get_bot_reposition_points().size(), 20)
	assert_eq(arena.debug_get_bot_tactical_point_count(), 22)
	assert_gt(arena.debug_get_flow_marker_count(), 5)
	assert_true(arena.debug_has_high_platform_cover())

	var bot = arena.debug_get_bot()
	assert_eq(bot.debug_get_tactical_context_label(), &"relay_foundry_v1")
	assert_eq(bot.debug_get_jump_pad_route_count(), 2)
	var roles: Array[StringName] = arena.debug_get_bot_tactical_roles()
	assert_true(roles.has(BotTacticalContextScript.ROLE_PRESSURE))
	assert_true(roles.has(BotTacticalContextScript.ROLE_COVER))
	assert_true(roles.has(BotTacticalContextScript.ROLE_FLANK))
	assert_true(roles.has(BotTacticalContextScript.ROLE_RETREAT))
	assert_true(roles.has(BotTacticalContextScript.ROLE_HEALTH))
	assert_true(roles.has(BotTacticalContextScript.ROLE_OVERCHARGE))
	assert_true(roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY))
	assert_no_new_orphans()

func test_crossfire_crucible_layout_exposes_distinct_route_markers_and_bot_points() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	arena.set_arena_layout(ArenaLayoutCatalogScript.CROSSFIRE_CRUCIBLE_ID)
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	assert_eq(arena.debug_get_active_layout_id(), &"crossfire_crucible_v1")
	assert_eq(arena.debug_get_active_layout_name(), "Crossfire Crucible V1")
	assert_not_null(arena.get_node_or_null("CrossfireCrucibleFloor"))
	assert_not_null(arena.get_node_or_null("CrucibleCore"))
	assert_not_null(arena.get_node_or_null("WestLiftJumpPad"))
	assert_not_null(arena.get_node_or_null("EastDiagonalJumpPad"))
	assert_null(arena.get_node_or_null("MidBlocker"))
	assert_eq(arena.debug_get_jump_pad_count(), 2)
	assert_eq(arena.debug_get_bot_reposition_points().size(), 20)
	assert_eq(arena.debug_get_bot_tactical_point_count(), 22)
	assert_gt(arena.debug_get_flow_marker_count(), 5)
	assert_true(arena.debug_has_high_platform_cover())

	var bot = arena.debug_get_bot()
	assert_eq(bot.debug_get_tactical_context_label(), &"crossfire_crucible_v1")
	assert_eq(bot.debug_get_jump_pad_route_count(), 2)
	var roles: Array[StringName] = arena.debug_get_bot_tactical_roles()
	assert_true(roles.has(BotTacticalContextScript.ROLE_PRESSURE))
	assert_true(roles.has(BotTacticalContextScript.ROLE_COVER))
	assert_true(roles.has(BotTacticalContextScript.ROLE_FLANK))
	assert_true(roles.has(BotTacticalContextScript.ROLE_RETREAT))
	assert_true(roles.has(BotTacticalContextScript.ROLE_HEALTH))
	assert_true(roles.has(BotTacticalContextScript.ROLE_OVERCHARGE))
	assert_true(roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY))
	assert_true(roles.has(BotTacticalContextScript.ROLE_JUMP_PAD_LANDING))
	assert_true(roles.has(BotTacticalContextScript.ROLE_HIGH_GROUND))
	assert_no_new_orphans()

func test_bot_prioritizes_health_tactical_route_when_critical() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	bot.take_damage(84.0)
	arena.debug_force_pickup_available(&"health", true)
	bot._choose_reposition_destination()

	assert_eq(bot.debug_get_decision_reason(), BotTacticalContextScript.ROLE_HEALTH)
	assert_eq(bot.debug_get_route_label(), &"health")
	assert_gt(bot.debug_get_recent_route_count(), 0)
	assert_no_new_orphans()

func test_bot_commits_to_nearby_health_pickup_when_damaged() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	var health_position: Vector3 = arena.debug_get_pickup_position(&"health")
	bot.take_damage(25.0)
	bot.global_position = health_position + Vector3(1.1, -health_position.y + 0.05, 0.0)
	bot.last_has_line_of_sight = true
	bot.shoot_cooldown_remaining = 0.0
	bot._set_state(&"engage")
	arena.debug_force_pickup_available(&"health", true)

	assert_true(bot._try_start_pickup_reposition())
	assert_eq(bot.debug_get_route_label(), &"health")
	assert_eq(bot.debug_get_reposition_destination(), health_position)
	assert_true(bot._should_hold_current_route())
	assert_no_new_orphans()

func test_bot_commits_to_nearby_overcharge_pickup_even_with_line_of_sight() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	bot.global_position = overcharge_position + Vector3(-1.2, -overcharge_position.y + 0.05, 0.0)
	bot.last_has_line_of_sight = true
	bot.shoot_cooldown_remaining = 0.0
	bot._set_state(&"engage")
	arena.debug_force_pickup_available(&"overcharge", true)

	assert_true(bot._try_start_pickup_reposition())
	assert_eq(bot.debug_get_route_label(), &"overcharge")
	assert_eq(bot.debug_get_reposition_destination(), overcharge_position)
	assert_true(bot._should_hold_current_route())
	assert_no_new_orphans()

func test_bot_prioritizes_overcharge_route_when_healthy_even_with_line_of_sight() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	bot.global_position = Vector3(overcharge_position.x - 5.2, 0.05, overcharge_position.z - 1.4)
	bot.last_has_line_of_sight = true
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	bot._set_state(&"engage")
	arena.debug_force_pickup_available(&"overcharge", true)

	assert_true(bot._try_start_pickup_reposition())
	assert_eq(bot.debug_get_route_label(), &"overcharge")
	assert_true(bot._should_hold_current_route())
	assert_no_new_orphans()

func test_bot_combat_overlay_shoots_without_canceling_item_route() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	player.global_position = Vector3(0.0, 0.05, 0.0)
	bot.global_position = Vector3(overcharge_position.x - 5.2, 0.05, overcharge_position.z - 1.4)
	bot._start_reposition_to(overcharge_position, &"overcharge")
	bot.last_has_line_of_sight = true
	bot.last_visible_target_position = player.get_body_center()
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0

	var movement: Vector3 = bot._handle_reposition()
	assert_eq(bot.debug_get_state(), &"reposition")
	assert_eq(bot.debug_get_route_label(), &"overcharge")
	assert_true(bot.debug_is_combat_overlay_active())
	assert_gt(movement.length(), 0.0)

	bot._update_combat_overlay(bot.shot_tell_duration + 0.01)
	assert_eq(bot.debug_get_state(), &"reposition")
	assert_eq(bot.debug_get_route_label(), &"overcharge")
	assert_gt(bot.shoot_cooldown_remaining, 0.0)
	assert_no_new_orphans()

func test_bot_commits_to_jump_pad_landing_after_launch() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	arena.set_arena_layout(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID)
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	var pad_position: Vector3 = arena.debug_get_jump_pad_position(1)
	var pad_target: Vector3 = arena.debug_get_jump_pad_target(1)
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	bot.global_position = pad_position
	bot._start_reposition_to(overcharge_position, &"overcharge")
	bot.apply_jump_pad_launch(Vector3(4.0, 6.2, 4.0))

	assert_eq(bot.debug_get_state(), &"reposition")
	assert_true(bot.debug_is_jump_pad_commitment_active())
	assert_eq(bot.debug_get_jump_pad_landing_target(), pad_target)
	assert_eq(bot.debug_get_route_label(), &"jump_pad")

	bot.global_position = pad_position + Vector3(0.0, 1.5, 0.0)
	var movement: Vector3 = bot._movement_toward_reposition()
	var expected: Vector3 = pad_target - bot.global_position
	expected.y = 0.0
	assert_gt(movement.dot(expected.normalized()), 0.82)
	assert_no_new_orphans()

func test_relay_foundry_jump_pad_launch_uses_old_fixed_force_contract() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	arena.set_arena_layout(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID)
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var pad_position: Vector3 = arena.debug_get_jump_pad_position(1)
	var pad_target: Vector3 = arena.debug_get_jump_pad_target(1)
	var launch_velocity: Vector3 = arena._build_jump_pad_launch_velocity({
		"position": pad_position,
		"target": pad_target
	})
	var flat_velocity := Vector3(launch_velocity.x, 0.0, launch_velocity.z)

	assert_almost_eq(flat_velocity.length(), 5.8, 0.01)
	assert_almost_eq(launch_velocity.y, 8.4, 0.01)
	var pad_to_landing := pad_target - pad_position
	pad_to_landing.y = 0.0
	assert_gt(flat_velocity.normalized().dot(pad_to_landing.normalized()), 0.98)
	assert_no_new_orphans()

func test_bot_triggers_relay_foundry_long_jump_pad_with_old_fixed_force() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	arena.set_arena_layout(ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID)
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var pad_position: Vector3 = arena.debug_get_jump_pad_position(1)
	var pad_target: Vector3 = arena.debug_get_jump_pad_target(1)
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	var approach_direction := pad_target - pad_position
	approach_direction.y = 0.0
	approach_direction = approach_direction.normalized()
	player.global_position = Vector3(-14.8, 0.05, 9.4)
	bot.global_position = pad_position - approach_direction * 3.0
	bot.global_position.y = 0.05
	bot._start_reposition_to(overcharge_position, &"overcharge")
	arena.debug_force_pickup_available(&"overcharge", true)

	var launched := false
	var highest_after_launch := -9999.0
	var frames_after_launch := 0
	for frame_index in range(160):
		await get_tree().physics_frame
		if bot.debug_get_jump_pad_launch_count() > 0:
			launched = true
			frames_after_launch += 1
			highest_after_launch = maxf(highest_after_launch, bot.global_position.y)
		if launched and frames_after_launch >= 24:
			break

	assert_true(launched)
	assert_gte(bot.debug_get_jump_pad_launch_count(), 1)
	assert_gt(highest_after_launch, 2.4)
	assert_eq(arena.debug_get_last_jump_pad_id(), &"east_forge_pad")
	assert_no_new_orphans()

func test_player_shot_ray_damages_bot_when_aimed_at_body() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var feedback = arena.get_node("FeedbackController")
	player.global_position = Vector3(-9.0, 0.05, 0.0)
	bot.global_position = Vector3(-9.0, 0.05, -7.0)
	await get_tree().physics_frame

	var before: float = bot.health
	var direction: Vector3 = (bot.get_body_center() - player.get_shot_origin()).normalized()
	arena._on_player_shot(player.get_shot_origin(), direction, player.shot_damage, player.shot_knockback)

	assert_lt(bot.health, before)
	assert_eq(feedback.last_event, &"hit")
	assert_no_new_orphans()

func test_hud_tracks_combat_readability_events() -> void:
	var hud = ArenaHudScript.new()
	add_child_autofree(hud)
	await get_tree().process_frame

	hud.update_snapshot({
		"map_name": "Duel Pit V2",
		"round_index": 2,
		"score_to_win": 3,
		"player_score": 1,
		"bot_score": 0,
		"result_text": "Player venceu o round",
		"hint": "R proximo round | Esc menu"
	})
	assert_eq(hud.score_label.text, "Score  Player 1  x  0 Bot")
	assert_eq(hud.round_label.text, "Duel Pit V2 | Round 2 | First to 3")
	assert_eq(hud.result_label.text, "Player venceu o round")
	assert_eq(hud.hint_label.text, "R proximo round | Esc menu")

	hud.show_bot_tell(0.24)
	assert_eq(hud.last_feedback, &"bot_tell")
	assert_eq(hud.bot_tell_count, 1)
	assert_gt(hud.bot_tell_feedback_time, 0.0)
	assert_eq(hud.event_label.text, "BOT FIRING")

	hud.show_plasma_hit(true, false)
	assert_eq(hud.last_feedback, &"overcharge_hit")
	assert_eq(hud.plasma_hit_count, 1)
	assert_true(hud.last_plasma_hit_overcharged)
	assert_eq(hud.event_label.text, "OVERCHARGE HIT")

	hud.show_player_damage(9.0, 0.82)
	assert_eq(hud.last_feedback, &"player_damage")
	assert_eq(hud.player_damage_count, 1)
	assert_eq(hud.event_label.text, "UNDER FIRE -9")
	assert_no_new_orphans()

func test_player_alt_fire_spawns_visible_plasma_projectile() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var before_count: int = arena.debug_get_active_projectile_count()
	arena._on_player_alt_fire(
		player.get_shot_origin(),
		player.get_shot_direction(),
		player.alt_fire_damage,
		player.alt_fire_knockback,
		player.alt_fire_speed,
		player.alt_fire_radius,
		false
	)

	assert_eq(arena.debug_get_active_projectile_count(), before_count + 1)
	assert_no_new_orphans()

func test_pickups_heal_player_and_grant_overcharge() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	player.take_damage(35.0)
	var health_position: Vector3 = arena.debug_get_pickup_position(&"health")
	player.global_position += health_position - player.get_body_center()
	assert_true(arena._try_consume_pickup(&"health", player))
	assert_gt(player.health, 65.0)
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	player.global_position += overcharge_position - player.get_body_center()
	assert_true(arena._try_consume_pickup(&"overcharge", player))
	assert_true(player.has_overcharge_charge())
	assert_no_new_orphans()

func test_bot_force_fire_damages_player() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var before: float = player.health
	bot.force_fire()

	assert_lt(player.health, before)
	assert_false(bot.is_telegraphing)
	assert_no_new_orphans()

func test_feedback_controller_builds_synthetic_audio_stream() -> void:
	var feedback = FeedbackScript.new()
	add_child_autofree(feedback)
	await get_tree().process_frame

	feedback.play_player_shot(Vector3.ZERO, Vector3.FORWARD)
	assert_eq(feedback.last_event, &"player_shot")
	assert_gt(feedback.debug_active_effect_count(), 0)
	feedback.play_bot_tell(Vector3.ZERO, Vector3.FORWARD * 2.0, 0.2)
	assert_eq(feedback.last_event, &"bot_tell")
	assert_eq(feedback.bot_tell_count, 1)
	feedback.play_plasma_hit(Vector3.FORWARD, true)
	assert_eq(feedback.last_event, &"plasma_hit")
	assert_eq(feedback.plasma_hit_count, 1)
	assert_not_null(feedback.debug_make_synthetic_stream(440.0, 0.02))
	assert_no_new_orphans()

func _descending_flight_time(vertical_speed: float, height_delta: float) -> float:
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	var discriminant: float = vertical_speed * vertical_speed - 2.0 * gravity * height_delta
	if discriminant <= 0.001 or gravity <= 0.001:
		return 0.0
	return (vertical_speed + sqrt(discriminant)) / gravity

func _flat_distance_between(first_point: Vector3, second_point: Vector3) -> float:
	var delta := first_point - second_point
	delta.y = 0.0
	return delta.length()
