extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const PlayerScript = preload("res://gameplay/player/fps_player_controller.gd")
const FeedbackScript = preload("res://presentation/feedback/fps_feedback_controller.gd")

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

func test_main_menu_scene_boots_with_arena_button_only() -> void:
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	assert_not_null(menu_scene)
	var menu := menu_scene.instantiate()
	add_child_autofree(menu)
	await get_tree().process_frame

	assert_eq(menu.debug_get_mode_path(&"arena"), "res://modes/arena/arena.tscn")
	assert_eq(menu.debug_get_mode_path(&"football"), "")
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/ArenaButton"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/FootballButton"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuMargin/MenuBox/QuitButton"))
	var menu_center := menu.get_node("MenuCenter") as CenterContainer
	var menu_panel := menu.get_node("MenuCenter/MenuPanel") as PanelContainer
	assert_almost_eq(menu_center.anchor_left, 0.0, 0.001)
	assert_almost_eq(menu_center.anchor_right, 1.0, 0.001)
	assert_eq(menu_panel.custom_minimum_size, Vector2(500.0, 330.0))
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
	assert_not_null(arena.get_node_or_null("ArenaHud"))
	assert_not_null(arena.get_node_or_null("FeedbackController"))

	var player = arena.get_node("RuntimeRoot/Player")
	var bot = arena.get_node("RuntimeRoot/Bot")
	assert_true(player.get_script() == PlayerScript)
	assert_not_null(player.get_node_or_null("Head/Camera3D"))
	assert_true((player.get_node("Head/Camera3D") as Camera3D).current)
	assert_almost_eq((player.get_node("Head/Camera3D") as Camera3D).fov, 86.0, 0.01)
	assert_eq(bot.debug_get_state(), &"reposition")
	assert_true(bot.debug_get_target() == player)
	assert_gt(bot.debug_get_reposition_point_count(), 0)

	var hud_root := arena.get_node("ArenaHud/HudRoot") as Control
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/PlayerLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/CombatLoopLabel"))
	assert_not_null(hud_root.get_node_or_null("Crosshair/HitMarker"))
	assert_not_null(hud_root.get_node_or_null("PauseMenuPanel/PauseMenuMargin/PauseMenuBox/SensitivitySlider"))
	assert_no_new_orphans()

func test_duel_pit_layout_exposes_route_markers_and_bot_points() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var points: Array[Vector3] = arena.debug_get_bot_reposition_points()
	assert_eq(points.size(), 18)
	assert_not_null(arena.get_node_or_null("RuntimeRoot/BotRepositionPoints/BotRepositionPoint17"))
	assert_gt(arena.debug_get_flow_marker_count(), 5)
	assert_true(arena.debug_has_high_platform_cover())
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
	assert_not_null(feedback.debug_make_synthetic_stream(440.0, 0.02))
	assert_no_new_orphans()
