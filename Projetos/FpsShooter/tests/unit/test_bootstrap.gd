extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const CombatantScript = preload("res://gameplay/combat/combatant_3d.gd")
const PlayerScript = preload("res://gameplay/player/fps_player_controller.gd")
const FeedbackScript = preload("res://presentation/feedback/fps_feedback_controller.gd")

const EXPECTED_ACTIONS: PackedStringArray = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"jump",
	"shoot",
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
	assert_not_null(arena.get_node_or_null("NorthWall"))
	assert_not_null(arena.get_node_or_null("LowCoverA"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Bot"))
	assert_not_null(arena.get_node_or_null("ArenaHud"))
	assert_not_null(arena.get_node_or_null("FeedbackController"))

	var player = arena.get_node("RuntimeRoot/Player")
	assert_not_null(player.get_node_or_null("Head/Camera3D"))
	assert_true((player.get_node("Head/Camera3D") as Camera3D).current)
	assert_almost_eq((player.get_node("Head/Camera3D") as Camera3D).fov, 86.0, 0.01)
	var hud_root := arena.get_node("ArenaHud/HudRoot") as Control
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/PlayerLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/PlayerHealthBar"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/BotHealthBar"))
	assert_not_null(hud_root.get_node_or_null("DamageOverlay"))
	assert_eq(hud_root.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((hud_root.get_node("StatusPanel") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((hud_root.get_node("HintLabel") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((hud_root.get_node("Crosshair") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_not_null(hud_root.get_node_or_null("Crosshair/Top"))
	assert_not_null(hud_root.get_node_or_null("Crosshair/HitMarker"))
	assert_not_null(hud_root.get_node_or_null("PauseMenuPanel/PauseMenuMargin/PauseMenuBox/SensitivitySlider"))
	assert_no_new_orphans()

func test_player_mouse_motion_updates_view_when_captured() -> void:
	var player = PlayerScript.new()
	add_child_autofree(player)
	await get_tree().process_frame

	var before_yaw: float = player.rotation.y
	player.apply_mouse_look(Vector2(120.0, -60.0))

	assert_lt(player.mouse_sensitivity, 0.0034)
	assert_gt(absf(player.rotation.y - before_yaw), 0.01)
	assert_gt((player.get_node("Head") as Node3D).rotation.x, 0.01)
	assert_no_new_orphans()

func test_player_shot_ray_damages_bot_when_aimed_at_body() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	var before: float = bot.health
	var origin: Vector3 = player.get_shot_origin()
	var aim_point: Vector3 = bot.global_position + Vector3.UP * 1.2
	var direction: Vector3 = (aim_point - origin).normalized()
	arena._on_player_shot(origin, direction, player.shot_damage, player.shot_knockback)

	assert_lt(bot.health, before)
	assert_gt(bot.knockback_velocity.length(), 0.1)
	assert_eq(hud.last_feedback, &"hit")
	assert_gt(hud.hit_confirm_count, 0)
	assert_gt(bot.damage_flash_time, 0.0)
	assert_eq(feedback.last_event, &"hit")
	assert_gt(feedback.player_shot_count, 0)
	assert_gt(feedback.hit_count, 0)
	assert_gt(feedback.debug_active_effect_count(), 0)
	assert_no_new_orphans()

func test_player_shot_visual_origin_is_offset_from_camera_ray() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var camera: Camera3D = player.get_camera()
	var origin: Vector3 = player.get_shot_origin()
	var direction: Vector3 = player.get_shot_direction()
	var visual_origin: Vector3 = arena.debug_get_player_visual_muzzle_origin(origin, direction)
	var offset := visual_origin - origin

	assert_gt(offset.length(), 0.86)
	assert_gt(offset.dot(camera.global_transform.basis.x), 0.28)
	assert_gt(offset.dot(-camera.global_transform.basis.y), 0.18)
	assert_gt(offset.dot(direction), 0.72)
	assert_no_new_orphans()

func test_player_miss_feedback_does_not_damage_bot() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	var before: float = bot.health
	arena._on_player_shot(player.get_shot_origin(), Vector3.UP, player.shot_damage, player.shot_knockback)

	assert_eq(bot.health, before)
	assert_eq(hud.last_feedback, &"miss")
	assert_gt(hud.miss_count, 0)
	assert_eq(feedback.last_event, &"miss")
	assert_gt(feedback.miss_count, 0)
	assert_no_new_orphans()

func test_escape_menu_exposes_sensitivity_slider() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame

	var player = arena.debug_get_player()
	var hud = arena.get_node("ArenaHud")
	arena._set_menu_open(true)
	assert_true(get_tree().paused)
	assert_true(hud.pause_menu_panel.visible)

	hud.sensitivity_slider.value = 0.0012
	assert_almost_eq(player.mouse_sensitivity, 0.0012, 0.00001)

	arena._set_menu_open(false)
	assert_false(get_tree().paused)
	assert_false(hud.pause_menu_panel.visible)
	assert_no_new_orphans()

func test_combatant_damage_and_knockback_contract() -> void:
	var combatant = CombatantScript.new()
	add_child_autofree(combatant)
	combatant.configure_combatant(&"probe", 50.0, Color.WHITE)
	combatant.take_damage(12.0, &"test")
	assert_eq(combatant.health, 38.0)
	assert_gt(combatant.damage_flash_time, 0.0)
	assert_gt(combatant.get_body_center().y, combatant.global_position.y)
	combatant.apply_knockback(Vector3.FORWARD, 4.0)
	assert_gt(combatant.knockback_velocity.length(), 0.1)
	combatant.take_damage(80.0, &"test")
	assert_true(combatant.is_dead)
	assert_no_new_orphans()

func test_bot_force_fire_damages_player() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	var before: float = player.health
	bot.force_fire()
	assert_lt(player.health, before)
	assert_gt(player.knockback_velocity.length(), 0.1)
	assert_eq(hud.last_feedback, &"player_damage")
	assert_gt(hud.player_damage_count, 0)
	assert_gt(feedback.bot_shot_count, 0)
	assert_gt(feedback.player_damage_count, 0)
	assert_false(bot.is_telegraphing)
	assert_no_new_orphans()

func test_bot_normal_fire_uses_short_windup_before_damage() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var feedback = arena.get_node("FeedbackController")
	bot.shoot_cooldown_remaining = 0.0
	var before: float = player.health
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	assert_eq(player.health, before)
	assert_gt(feedback.bot_tell_count, 0)

	for _step in range(18):
		await get_tree().physics_frame

	assert_false(bot.is_telegraphing)
	assert_lt(player.health, before)
	assert_gt(feedback.bot_shot_count, 0)
	assert_no_new_orphans()

func test_feedback_controller_builds_synthetic_audio_stream() -> void:
	var feedback = FeedbackScript.new()
	add_child_autofree(feedback)
	await get_tree().process_frame

	var stream := feedback.debug_make_synthetic_stream(440.0, 0.04)
	assert_not_null(stream)
	assert_gt(stream.data.size(), 0)
	feedback.play_player_shot(Vector3.ZERO, Vector3.FORWARD)
	assert_gt(feedback.player_shot_count, 0)
	assert_gt(feedback.debug_active_effect_count(), 0)
	assert_no_new_orphans()
