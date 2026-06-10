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
	assert_not_null(arena.get_node_or_null("MidBlocker"))
	assert_not_null(arena.get_node_or_null("HighCoverA"))
	assert_not_null(arena.get_node_or_null("LowCoverA"))
	assert_not_null(arena.get_node_or_null("LowCoverD"))
	assert_not_null(arena.get_node_or_null("WestPlatform"))
	assert_not_null(arena.get_node_or_null("EastPlatform"))
	assert_not_null(arena.get_node_or_null("WestRamp"))
	assert_not_null(arena.get_node_or_null("EastRamp"))
	assert_not_null(arena.get_node_or_null("WestHighPlatform"))
	assert_not_null(arena.get_node_or_null("EastHighPlatform"))
	assert_not_null(arena.get_node_or_null("WestJumpPad"))
	assert_not_null(arena.get_node_or_null("EastJumpPad"))
	assert_null(arena.get_node_or_null("NorthVoidWell"))
	assert_null(arena.get_node_or_null("SouthVoidWell"))
	assert_not_null(arena.get_node_or_null("CenterLaneMark"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Bot"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/BotRepositionPoints"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Projectiles"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/HealthShard"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Pickups/Overcharge"))
	assert_not_null(arena.get_node_or_null("ArenaHud"))
	assert_not_null(arena.get_node_or_null("FeedbackController"))

	var player = arena.get_node("RuntimeRoot/Player")
	var bot = arena.get_node("RuntimeRoot/Bot")
	assert_not_null(player.get_node_or_null("Head/Camera3D"))
	assert_true((player.get_node("Head/Camera3D") as Camera3D).current)
	assert_almost_eq((player.get_node("Head/Camera3D") as Camera3D).fov, 86.0, 0.01)
	assert_eq(bot.debug_get_state(), &"reposition")
	assert_true(bot.debug_get_target() == player)
	assert_gt(bot.debug_get_reposition_point_count(), 0)
	var hud_root := arena.get_node("ArenaHud/HudRoot") as Control
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/PlayerLabel"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/PlayerHealthBar"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/BotHealthBar"))
	assert_not_null(hud_root.get_node_or_null("StatusPanel/StatusBox/CombatLoopLabel"))
	assert_not_null(hud_root.get_node_or_null("DamageOverlay"))
	assert_eq(hud_root.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((hud_root.get_node("StatusPanel") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((hud_root.get_node("HintLabel") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq((hud_root.get_node("Crosshair") as Control).mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_not_null(hud_root.get_node_or_null("Crosshair/Top"))
	assert_not_null(hud_root.get_node_or_null("Crosshair/HitMarker"))
	assert_not_null(hud_root.get_node_or_null("PauseMenuPanel/PauseMenuMargin/PauseMenuBox/SensitivitySlider"))
	assert_no_new_orphans()

func test_duel_pit_layout_blocks_spawn_sightline() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var feedback = arena.get_node("FeedbackController")
	var before: float = bot.health
	var direction: Vector3 = (bot.get_body_center() - player.get_shot_origin()).normalized()
	arena._on_player_shot(player.get_shot_origin(), direction, player.shot_damage, player.shot_knockback)

	assert_eq(bot.health, before)
	assert_eq(feedback.last_event, &"miss")
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
	var high_point_count := 0
	var ground_point_count := 0
	for point in points:
		assert_lte(absf(point.x), 12.0)
		assert_lte(absf(point.z), 12.0)
		if point.y > 2.0:
			high_point_count += 1
		if is_equal_approx(point.y, 0.05) or is_equal_approx(point.y, 0.08):
			ground_point_count += 1
	assert_gt(high_point_count, 0)
	assert_gt(ground_point_count, 0)
	assert_no_new_orphans()

func test_duel_pit_v2_exposes_jump_pads_without_void_zones_to_bot() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	assert_eq(arena.debug_get_jump_pad_count(), 2)
	assert_gt(arena.debug_get_jump_pad_target(0).y, arena.debug_get_jump_pad_position(0).y + 2.0)
	assert_gt(arena.debug_get_jump_pad_target(1).y, arena.debug_get_jump_pad_position(1).y + 2.0)
	assert_eq(bot.debug_get_jump_pad_route_count(), 2)
	assert_null(arena.get_node_or_null("NorthVoidWell"))
	assert_null(arena.get_node_or_null("SouthVoidWell"))
	assert_no_new_orphans()

func test_jump_pad_launches_player_and_bot() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	arena.debug_force_pickup_available(&"health", false)
	arena.debug_force_pickup_available(&"overcharge", false)
	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	player.global_position = arena.debug_get_jump_pad_position(0)
	player.clear_movement_impulses()
	bot.global_position = arena.debug_get_jump_pad_position(1)
	bot.clear_movement_impulses()
	bot.shoot_cooldown_remaining = 99.0
	bot.reaction_remaining = 99.0
	await get_tree().physics_frame

	assert_gt(player.debug_get_jump_pad_launch_count(), 0)
	assert_gt(player.debug_get_vertical_velocity(), 7.0)
	assert_gt(bot.debug_get_jump_pad_launch_count(), 0)
	assert_gt(bot.debug_get_vertical_velocity(), 7.0)
	assert_gt(arena.debug_get_jump_pad_trigger_count(), 1)
	assert_false(arena.debug_get_last_jump_pad_id() == &"")
	assert_eq(hud.last_feedback, &"jump_pad")
	assert_gt(feedback.jump_pad_count, 1)
	assert_no_new_orphans()

func test_bot_routes_high_reposition_goal_through_jump_pad() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	arena.debug_force_pickup_available(&"health", false)
	arena.debug_force_pickup_available(&"overcharge", false)
	var bot = arena.debug_get_bot()
	var high_target: Vector3 = arena.debug_get_jump_pad_target(0)
	var pad_position: Vector3 = arena.debug_get_jump_pad_position(0)
	bot.global_position = Vector3(-2.0, 0.05, -1.0)
	bot.shoot_cooldown_remaining = 99.0
	bot.reaction_remaining = 99.0
	bot._start_reposition_to(high_target)
	await get_tree().physics_frame

	assert_lt(bot.debug_get_last_navigation_target().distance_to(pad_position), 0.4)
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

	_place_open_duel(arena)
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
	var impulse: Vector3 = bot.debug_get_last_knockback_impulse()
	assert_gt(Vector3(impulse.x, 0.0, impulse.z).length(), 7.0)
	assert_gt(impulse.y, 1.6)
	assert_eq(hud.last_feedback, &"hit")
	assert_gt(hud.hit_confirm_count, 0)
	assert_gt(bot.damage_flash_time, 0.0)
	assert_eq(feedback.last_event, &"hit")
	assert_gt(feedback.player_shot_count, 0)
	assert_gt(feedback.hit_count, 0)
	assert_gt(feedback.knockback_count, 0)
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

func test_player_alt_fire_emits_overcharged_plasma_payload() -> void:
	var player = PlayerScript.new()
	add_child_autofree(player)
	await get_tree().process_frame

	var payloads: Array[Dictionary] = []
	player.alt_fire_requested.connect(func(origin: Vector3, direction: Vector3, damage: float, knockback: float, speed: float, radius: float, overcharged: bool) -> void:
		payloads.append({
			"origin": origin,
			"direction": direction,
			"damage": damage,
			"knockback": knockback,
			"speed": speed,
			"radius": radius,
			"overcharged": overcharged
		})
	)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.grant_overcharge()
	player.request_alt_fire()

	assert_eq(payloads.size(), 1)
	assert_true(bool(payloads[0].get("overcharged", false)))
	assert_gt(float(payloads[0].get("damage", 0.0)), player.alt_fire_damage)
	assert_gt(float(payloads[0].get("knockback", 0.0)), player.alt_fire_knockback)
	assert_false(player.has_overcharge_charge())
	assert_gt(player.alt_fire_cooldown_remaining, 0.0)
	assert_no_new_orphans()

func test_player_alt_fire_spawns_visible_plasma_projectile() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	bot.shoot_cooldown_remaining = 99.0
	var origin: Vector3 = player.get_shot_origin()
	var direction: Vector3 = (bot.get_body_center() - origin).normalized()
	arena._on_player_alt_fire(origin, direction, player.alt_fire_damage, player.alt_fire_knockback, player.alt_fire_speed, player.alt_fire_radius, false)

	assert_eq(arena.debug_get_active_projectile_count(), 1)
	assert_eq(hud.last_feedback, &"plasma_shot")
	assert_gt(hud.alt_fire_count, 0)
	assert_gt(feedback.plasma_shot_count, 0)
	assert_no_new_orphans()

func test_player_plasma_bolt_hits_bot_with_strong_knockback() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	bot.shoot_cooldown_remaining = 99.0
	bot.reaction_remaining = 99.0
	bot.move_speed = 0.0
	var before: float = bot.health
	var camera: Camera3D = player.get_camera()
	camera.look_at(bot.get_body_center(), Vector3.UP)
	player.grant_overcharge()
	player.request_alt_fire()
	for _step in range(80):
		await get_tree().physics_frame
		if arena.debug_get_active_projectile_count() == 0:
			break

	assert_lt(bot.health, before)
	assert_gt(bot.debug_get_last_knockback_impulse().y, 2.0)
	assert_eq(hud.last_feedback, &"hit")
	assert_gt(feedback.plasma_hit_count, 0)
	assert_gt(feedback.knockback_count, 0)
	assert_no_new_orphans()

func test_player_alt_fire_request_hits_crosshair_body_edge_from_offset_muzzle() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var feedback = arena.get_node("FeedbackController")
	bot.shoot_cooldown_remaining = 99.0
	bot.reaction_remaining = 99.0
	var before: float = bot.health
	var camera: Camera3D = player.get_camera()
	camera.look_at(bot.get_body_center() + Vector3.RIGHT * 0.28, Vector3.UP)
	player.request_alt_fire()
	for _step in range(80):
		await get_tree().physics_frame
		if arena.debug_get_active_projectile_count() == 0:
			break

	assert_lt(bot.health, before)
	assert_gt(feedback.plasma_hit_count, 0)
	assert_gt(bot.debug_get_last_knockback_impulse().length(), 0.1)
	assert_no_new_orphans()

func test_pickups_heal_player_and_grant_overcharge() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var feedback = arena.get_node("FeedbackController")
	player.take_damage(45.0, &"test")
	var damaged_health: float = player.health
	var health_position: Vector3 = arena.debug_get_pickup_position(&"health")
	player.global_position = health_position - Vector3.UP * 0.82
	await get_tree().physics_frame

	assert_gt(player.health, damaged_health)
	assert_false(arena.debug_is_pickup_available(&"health"))
	assert_gt(feedback.pickup_count, 0)

	arena.debug_force_pickup_available(&"overcharge", true)
	var overcharge_position: Vector3 = arena.debug_get_pickup_position(&"overcharge")
	player.global_position = overcharge_position - Vector3.UP * 0.82
	await get_tree().physics_frame

	assert_true(player.has_overcharge_charge())
	assert_false(arena.debug_is_pickup_available(&"overcharge"))
	assert_no_new_orphans()

func test_bot_prioritizes_health_pickup_when_hurt() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	var health_position: Vector3 = arena.debug_get_pickup_position(&"health")
	bot.take_damage(65.0, &"test")
	bot.global_position = health_position + Vector3(2.4, -1.37, 0.0)
	bot.reaction_remaining = 1.0
	bot.shoot_cooldown_remaining = 3.0
	arena.debug_force_pickup_available(&"health", true)
	await get_tree().physics_frame

	assert_eq(bot.debug_get_state(), &"reposition")
	var destination: Vector3 = bot.debug_get_reposition_destination()
	assert_lt(Vector3(destination.x, 0.0, destination.z).distance_to(Vector3(health_position.x, 0.0, health_position.z)), 0.2)
	assert_no_new_orphans()

func test_bot_takes_ready_shot_before_health_pickup() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	bot.take_damage(65.0, &"test")
	bot.aim_error_radius = 0.0
	bot.close_range_aim_error_radius = 0.0
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	arena.debug_force_pickup_available(&"health", true)
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	assert_eq(bot.debug_get_state(), &"windup")
	assert_no_new_orphans()

func test_bot_interrupts_health_route_when_shot_becomes_ready() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var health_position: Vector3 = arena.debug_get_pickup_position(&"health")
	bot.take_damage(65.0, &"test")
	bot.global_position = health_position + Vector3(2.4, -1.37, 0.0)
	player.global_position = bot.global_position + Vector3(0.0, 0.0, 8.0)
	bot.shoot_cooldown_remaining = 3.0
	bot.reaction_remaining = 1.0
	arena.debug_force_pickup_available(&"health", true)
	await get_tree().physics_frame

	assert_eq(bot.debug_get_state(), &"reposition")
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	assert_eq(bot.debug_get_state(), &"windup")
	assert_no_new_orphans()

func test_bot_jumps_toward_higher_reposition_goal() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	bot.shoot_cooldown_remaining = 3.0
	bot.reaction_remaining = 1.0
	bot._start_reposition_to(bot.global_position + Vector3(-2.2, 1.1, 2.2))
	await get_tree().physics_frame
	await get_tree().physics_frame

	assert_gt(bot.debug_get_jump_count(), 0)
	assert_gt(bot.debug_get_vertical_velocity(), 0.0)
	assert_no_new_orphans()

func test_bot_receives_plasma_threat_and_can_dodge() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var threat_origin: Vector3 = bot.get_body_center() + Vector3.RIGHT * 2.0
	arena._spawn_player_plasma_bolt(threat_origin, Vector3.LEFT, player.alt_fire_damage, player.alt_fire_knockback, player.alt_fire_speed, player.alt_fire_radius, false)
	arena._update_bot_awareness()

	assert_true(bot.debug_is_projectile_dodging())
	assert_eq(arena.debug_get_active_projectile_count(), 1)
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
	var impulse: Vector3 = combatant.debug_get_last_knockback_impulse()
	assert_gt(Vector3(impulse.x, 0.0, impulse.z).length(), 3.9)
	assert_gt(impulse.y, 1.0)
	assert_eq(combatant.debug_get_knockback_event_count(), 1)
	combatant.take_damage(80.0, &"test")
	assert_true(combatant.is_dead)
	assert_no_new_orphans()

func test_knockback_clamps_stack_and_decays_slower_airborne() -> void:
	var airborne = CombatantScript.new()
	add_child_autofree(airborne)
	airborne.configure_combatant(&"airborne", 50.0, Color.WHITE)
	airborne.apply_knockback(Vector3.RIGHT, 50.0, 3.0)

	var grounded = CombatantScript.new()
	add_child_autofree(grounded)
	grounded.configure_combatant(&"grounded", 50.0, Color.WHITE)
	grounded.apply_knockback(Vector3.RIGHT, 50.0, 3.0)

	assert_lte(airborne.debug_get_knockback_horizontal_speed(), airborne.knockback_max_horizontal_speed + 0.001)
	assert_lte(airborne.knockback_velocity.y, airborne.knockback_max_vertical_speed + 0.001)

	airborne.consume_knockback(0.12, false)
	grounded.consume_knockback(0.12, true)

	assert_gt(airborne.knockback_velocity.length(), grounded.knockback_velocity.length())
	assert_no_new_orphans()

func test_bot_force_fire_damages_player() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var hud = arena.get_node("ArenaHud")
	var feedback = arena.get_node("FeedbackController")
	var before: float = player.health
	bot.force_fire()
	assert_lt(player.health, before)
	assert_gt(player.knockback_velocity.length(), 0.1)
	assert_gt(player.debug_get_last_knockback_impulse().y, 1.0)
	assert_eq(hud.last_feedback, &"player_damage")
	assert_gt(hud.player_damage_count, 0)
	assert_gt(feedback.bot_shot_count, 0)
	assert_gt(feedback.player_damage_count, 0)
	assert_false(bot.is_telegraphing)
	assert_no_new_orphans()

func test_bot_respects_line_of_sight_before_windup() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	player.global_position = Vector3(-2.0, 0.05, 0.8)
	bot.global_position = Vector3(-2.0, 0.05, -5.8)
	_add_static_blocker(arena, Vector3(-2.0, 1.25, -2.5), Vector3(2.6, 2.5, 1.3))
	await get_tree().physics_frame

	bot.configure(player)
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	await get_tree().physics_frame

	assert_false(bot.debug_has_line_of_sight())
	assert_false(bot.is_telegraphing)
	assert_eq(bot.debug_get_state(), &"reposition")
	assert_no_new_orphans()

func test_bot_detects_player_visible_over_low_cover() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	player.global_position = Vector3(-2.0, 0.05, 0.8)
	bot.global_position = Vector3(-2.0, 0.05, -5.8)
	bot.configure(player)
	bot.aim_error_radius = 0.0
	bot.close_range_aim_error_radius = 0.0
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	await get_tree().physics_frame

	assert_true(bot.debug_has_line_of_sight())
	assert_true(bot.is_telegraphing)
	assert_gt(bot.debug_get_visible_target_position().y, player.get_body_center().y + 0.4)
	assert_gt(bot.debug_get_last_aim_position().y, player.get_body_center().y + 0.35)
	assert_no_new_orphans()

func test_bot_normal_fire_uses_short_windup_before_damage() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var feedback = arena.get_node("FeedbackController")
	bot.aim_error_radius = 0.0
	bot.close_range_aim_error_radius = 0.0
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	var before: float = player.health
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	assert_eq(player.health, before)
	assert_gt(feedback.bot_tell_count, 0)

	for _step in range(18):
		await get_tree().physics_frame

	assert_false(bot.is_telegraphing)
	assert_lt(player.health, before)
	assert_gt(player.debug_get_knockback_event_count(), 0)
	assert_gt(player.debug_get_last_knockback_impulse().y, 1.0)
	assert_gt(feedback.knockback_count, 0)
	assert_gt(feedback.bot_shot_count, 0)
	assert_no_new_orphans()

func test_bot_normal_fire_can_miss_without_damage() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var feedback = arena.get_node("FeedbackController")
	bot.aim_error_radius = 10.0
	bot.close_range_aim_error_radius = 10.0
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	var before: float = player.health
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	assert_gt(bot.debug_get_last_aim_position().distance_to(player.get_body_center()), 0.5)
	for _step in range(18):
		await get_tree().physics_frame

	assert_eq(player.health, before)
	assert_gt(feedback.bot_miss_count, 0)
	assert_eq(feedback.last_event, &"bot_miss")
	assert_eq(player.debug_get_knockback_event_count(), 0)
	assert_eq(feedback.knockback_count, 0)
	assert_no_new_orphans()

func test_bot_strafes_when_cooling_down() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	bot.shoot_cooldown_remaining = 3.0
	bot.reaction_remaining = 0.0
	bot.reposition_cooldown_remaining = 0.0
	var start_position: Vector3 = bot.global_position
	await get_tree().physics_frame

	assert_eq(bot.debug_get_state(), &"strafe")
	for _step in range(16):
		await get_tree().physics_frame

	var flat_delta: Vector3 = bot.global_position - start_position
	flat_delta.y = 0.0
	assert_gt(flat_delta.length(), 0.1)
	assert_no_new_orphans()

func test_bot_cancels_windup_when_target_dies() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	bot.aim_error_radius = 0.0
	bot.close_range_aim_error_radius = 0.0
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	player.take_damage(200.0, &"test")
	await get_tree().physics_frame

	assert_false(bot.is_telegraphing)
	assert_eq(bot.debug_get_state(), &"idle")
	assert_no_new_orphans()

func test_restart_resets_bot_duelist_state() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	_place_open_duel(arena)
	await get_tree().physics_frame

	var bot = arena.debug_get_bot()
	bot.aim_error_radius = 0.0
	bot.close_range_aim_error_radius = 0.0
	bot.shoot_cooldown_remaining = 0.0
	bot.reaction_remaining = 0.0
	await get_tree().physics_frame

	assert_true(bot.is_telegraphing)
	arena.restart_round()

	assert_false(bot.is_telegraphing)
	assert_eq(bot.debug_get_state(), &"engage")
	assert_almost_eq(bot.global_position.x, arena.debug_get_bot_spawn().x, 0.001)
	assert_almost_eq(bot.global_position.z, arena.debug_get_bot_spawn().z, 0.001)
	assert_almost_eq(arena.debug_get_player().global_position.x, arena.debug_get_player_spawn().x, 0.001)
	assert_almost_eq(arena.debug_get_player().global_position.z, arena.debug_get_player_spawn().z, 0.001)
	assert_gt(bot.debug_get_reposition_point_count(), 0)
	assert_eq((arena.get_node("FeedbackController")).debug_active_effect_count(), 0)
	assert_no_new_orphans()

func test_feedback_controller_builds_synthetic_audio_stream() -> void:
	var feedback = FeedbackScript.new()
	add_child_autofree(feedback)
	await get_tree().process_frame

	var stream := feedback.debug_make_synthetic_stream(440.0, 0.04)
	assert_not_null(stream)
	assert_gt(stream.data.size(), 0)
	feedback.play_player_shot(Vector3.ZERO, Vector3.FORWARD)
	feedback.play_bot_miss(Vector3.ZERO, Vector3.FORWARD)
	feedback.play_knockback(Vector3.ZERO, Vector3.FORWARD, 5.0, true)
	assert_gt(feedback.player_shot_count, 0)
	assert_gt(feedback.bot_miss_count, 0)
	assert_gt(feedback.knockback_count, 0)
	assert_gt(feedback.debug_active_effect_count(), 0)
	assert_no_new_orphans()

func _add_static_blocker(parent: Node, blocker_position: Vector3, blocker_size: Vector3) -> StaticBody3D:
	var blocker := StaticBody3D.new()
	blocker.name = "TestSightBlocker"
	blocker.position = blocker_position
	var shape := CollisionShape3D.new()
	var box_shape := BoxShape3D.new()
	box_shape.size = blocker_size
	shape.shape = box_shape
	blocker.add_child(shape)
	parent.add_child(blocker)
	return blocker

func _place_open_duel(arena: Node) -> void:
	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	arena.debug_force_pickup_available(&"health", false)
	arena.debug_force_pickup_available(&"overcharge", false)
	player.global_position = Vector3(12.2, 0.05, 4.8)
	player.rotation = Vector3.ZERO
	bot.global_position = Vector3(12.2, 0.05, -4.8)
	bot.rotation = Vector3.ZERO
	bot.configure(player)
