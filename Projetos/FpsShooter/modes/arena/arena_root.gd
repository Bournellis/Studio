class_name FpsArenaRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/fps_player_controller.gd")
const BotController = preload("res://gameplay/bot/basic_duel_bot.gd")
const ArenaHudScript = preload("res://presentation/hud/arena_hud.gd")
const FeedbackControllerScript = preload("res://presentation/feedback/fps_feedback_controller.gd")

const MAP_NAME: String = "Duel Pit V2"
const FLOOR_SIZE: Vector3 = Vector3(30.0, 1.0, 30.0)
const WALL_HEIGHT: float = 3.6
const WALL_THICKNESS: float = 0.8
const PLAYER_SPAWN: Vector3 = Vector3(-10.8, 0.05, 8.6)
const BOT_SPAWN: Vector3 = Vector3(10.8, 0.05, -8.6)
const PLAYER_VISUAL_MUZZLE_RIGHT_OFFSET: float = 0.34
const PLAYER_VISUAL_MUZZLE_DOWN_OFFSET: float = 0.24
const PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET: float = 0.82
const PLAYER_SHOT_KNOCKBACK_LIFT: float = 1.75
const PLAYER_PLASMA_KNOCKBACK_LIFT: float = 2.25
const BOT_SHOT_KNOCKBACK_LIFT: float = 1.12
const PLASMA_BOLT_TTL: float = 2.45
const PICKUP_RADIUS: float = 1.05
const HEALTH_PICKUP_AMOUNT: float = 28.0
const HEALTH_PICKUP_RESPAWN: float = 10.0
const OVERCHARGE_PICKUP_RESPAWN: float = 14.0
const HEALTH_PICKUP_POSITION: Vector3 = Vector3(-7.6, 3.55, -8.6)
const OVERCHARGE_PICKUP_POSITION: Vector3 = Vector3(7.6, 3.55, 8.6)
const JUMP_PAD_RADIUS: float = 1.25
const JUMP_PAD_COOLDOWN: float = 0.64
const JUMP_PAD_VERTICAL_SPEED: float = 8.4
const JUMP_PAD_FORWARD_SPEED: float = 5.8
const WEST_JUMP_PAD_POSITION: Vector3 = Vector3(-10.8, 0.08, -4.4)
const WEST_JUMP_PAD_TARGET: Vector3 = Vector3(-9.6, 3.05, -8.6)
const EAST_JUMP_PAD_POSITION: Vector3 = Vector3(10.8, 0.08, 4.4)
const EAST_JUMP_PAD_TARGET: Vector3 = Vector3(9.6, 3.05, 8.6)
const BOT_REPOSITION_POINTS: Array[Vector3] = [
	Vector3(-11.2, 0.05, 7.8),
	Vector3(-10.8, 0.05, -7.2),
	Vector3(-6.4, 0.05, 0.0),
	Vector3(-3.8, 0.05, 5.4),
	Vector3(-1.8, 0.05, -6.8),
	Vector3(1.8, 0.05, 6.8),
	Vector3(3.8, 0.05, -5.4),
	Vector3(6.4, 0.05, 0.0),
	Vector3(10.8, 0.05, 7.2),
	Vector3(11.2, 0.05, -7.8),
	Vector3(-2.2, 0.05, 2.4),
	Vector3(2.2, 0.05, -2.4),
	Vector3(-9.6, 3.05, -8.6),
	Vector3(-7.6, 3.05, -8.6),
	Vector3(9.6, 3.05, 8.6),
	Vector3(7.6, 3.05, 8.6),
	WEST_JUMP_PAD_POSITION,
	EAST_JUMP_PAD_POSITION
]

var player
var bot
var hud
var feedback
var round_status: String = MAP_NAME
var round_ended: bool = false
var menu_open: bool = false
var projectile_root: Node3D
var pickup_root: Node3D
var active_projectiles: Array[Dictionary] = []
var pickups: Dictionary = {}
var jump_pads: Array[Dictionary] = []
var flow_marker_count: int = 0
var high_platform_cover_count: int = 0
var jump_pad_trigger_count: int = 0
var last_jump_pad_id: StringName = &""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_world()
	_spawn_runtime()
	_capture_mouse_if_playing()

func _process(_delta: float) -> void:
	if hud != null:
		hud.update_snapshot(_build_hud_snapshot())

func _physics_process(delta: float) -> void:
	if round_ended or menu_open:
		return
	_process_projectiles(delta)
	_process_pickups(delta)
	_process_jump_pads(delta)
	_update_bot_awareness()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		_set_menu_open(not menu_open)
		get_viewport().set_input_as_handled()
		return
	if menu_open:
		return
	if event is InputEventMouseButton and event.is_pressed() and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_capture_mouse_if_playing()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart_round"):
		restart_round()
		get_viewport().set_input_as_handled()

func restart_round() -> void:
	_set_menu_open(false)
	round_status = MAP_NAME
	round_ended = false
	player.global_position = PLAYER_SPAWN
	player.rotation = Vector3.ZERO
	player.configure_for_round()
	bot.global_position = BOT_SPAWN
	bot.rotation = Vector3.ZERO
	bot.configure(player)
	if hud != null:
		hud.reset_feedback()
	if feedback != null:
		feedback.clear_effects()
	_clear_projectiles()
	_reset_pickups()
	_reset_vertical_hazards()
	_update_bot_awareness()
	_capture_mouse_if_playing()

func debug_get_player():
	return player

func debug_get_bot():
	return bot

func debug_get_player_visual_muzzle_origin(origin: Vector3, direction: Vector3) -> Vector3:
	return _get_player_visual_muzzle_origin(origin, direction)

func debug_get_player_spawn() -> Vector3:
	return PLAYER_SPAWN

func debug_get_bot_spawn() -> Vector3:
	return BOT_SPAWN

func debug_get_bot_reposition_points() -> Array[Vector3]:
	return BOT_REPOSITION_POINTS.duplicate()

func debug_get_active_projectile_count() -> int:
	return active_projectiles.size()

func debug_get_jump_pad_count() -> int:
	return jump_pads.size()

func debug_get_jump_pad_position(index: int = 0) -> Vector3:
	if index < 0 or index >= jump_pads.size():
		return Vector3.ZERO
	var pad: Dictionary = jump_pads[index]
	return pad.get("position", Vector3.ZERO)

func debug_get_jump_pad_target(index: int = 0) -> Vector3:
	if index < 0 or index >= jump_pads.size():
		return Vector3.ZERO
	var pad: Dictionary = jump_pads[index]
	return pad.get("target", Vector3.ZERO)

func debug_get_jump_pad_trigger_count() -> int:
	return jump_pad_trigger_count

func debug_get_last_jump_pad_id() -> StringName:
	return last_jump_pad_id

func debug_get_flow_marker_count() -> int:
	return flow_marker_count

func debug_has_high_platform_cover() -> bool:
	return high_platform_cover_count >= 2

func debug_get_pickup_jump_target_distance(pickup_kind: StringName) -> float:
	var pickup_position := debug_get_pickup_position(pickup_kind)
	var target_position := WEST_JUMP_PAD_TARGET if pickup_kind == &"health" else EAST_JUMP_PAD_TARGET
	pickup_position.y = 0.0
	target_position.y = 0.0
	return pickup_position.distance_to(target_position)

func debug_get_pickup_position(pickup_kind: StringName) -> Vector3:
	var entry: Dictionary = pickups.get(pickup_kind, {})
	return entry.get("position", Vector3.ZERO)

func debug_is_pickup_available(pickup_kind: StringName) -> bool:
	var entry: Dictionary = pickups.get(pickup_kind, {})
	return bool(entry.get("available", false))

func debug_force_pickup_available(pickup_kind: StringName, available: bool) -> void:
	if not pickups.has(pickup_kind):
		return
	var entry: Dictionary = pickups[pickup_kind]
	entry["available"] = available
	entry["respawn_remaining"] = 0.0 if available else 9999.0
	var node := entry.get("node", null) as Node3D
	if node != null:
		node.visible = available
	pickups[pickup_kind] = entry
	_update_bot_awareness()

func _configure_world() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.045, 0.06, 0.085, 1.0)
	env.ambient_light_color = Color(0.7, 0.82, 0.95, 1.0)
	env.ambient_light_energy = 0.82
	environment.environment = env
	add_child(environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "KeyLight"
	key_light.rotation_degrees = Vector3(-58.0, -38.0, 0.0)
	key_light.light_energy = 2.6
	key_light.shadow_enabled = true
	add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.name = "DraxosFillLight"
	fill_light.position = Vector3(0.0, 6.0, 0.0)
	fill_light.light_color = Color(0.42, 0.86, 1.0, 1.0)
	fill_light.light_energy = 1.4
	fill_light.omni_range = 32.0
	add_child(fill_light)

	_build_duel_pit_layout()

func _build_duel_pit_layout() -> void:
	jump_pads.clear()
	flow_marker_count = 0
	high_platform_cover_count = 0

	_add_box("ArenaFloor", Vector3(0.0, -0.5, 0.0), FLOOR_SIZE, Color(0.13, 0.17, 0.23, 1.0))
	var half := FLOOR_SIZE.x * 0.5
	_add_box("NorthWall", Vector3(0.0, WALL_HEIGHT * 0.5, -half), Vector3(FLOOR_SIZE.x, WALL_HEIGHT, WALL_THICKNESS), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("SouthWall", Vector3(0.0, WALL_HEIGHT * 0.5, half), Vector3(FLOOR_SIZE.x, WALL_HEIGHT, WALL_THICKNESS), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("WestWall", Vector3(-half, WALL_HEIGHT * 0.5, 0.0), Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("EastWall", Vector3(half, WALL_HEIGHT * 0.5, 0.0), Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_visual_box("CenterLaneMark", Vector3(0.0, 0.025, 0.0), Vector3(1.1, 0.05, 24.0), Color(0.18, 0.52, 0.62, 1.0))
	_add_visual_box("EastRouteMark", Vector3(8.8, 0.026, 0.0), Vector3(0.8, 0.05, 20.0), Color(0.38, 0.25, 0.58, 1.0))
	_add_visual_box("WestRouteMark", Vector3(-8.8, 0.026, 0.0), Vector3(0.8, 0.05, 20.0), Color(0.38, 0.25, 0.58, 1.0))
	_add_flow_marker("WestPadApproachMark", Vector3(-10.8, 0.032, -2.2), Vector3(1.35, 0.05, 3.6), Color(0.08, 0.74, 0.9, 1.0))
	_add_flow_marker("EastPadApproachMark", Vector3(10.8, 0.032, 2.2), Vector3(1.35, 0.05, 3.6), Color(0.08, 0.74, 0.9, 1.0))

	_add_box("MidBlocker", Vector3(0.0, 1.6, 0.0), Vector3(3.2, 3.2, 3.2), Color(0.19, 0.25, 0.32, 1.0))
	_add_box("HighCoverA", Vector3(-5.0, 1.6, -0.8), Vector3(1.4, 3.2, 3.8), Color(0.24, 0.3, 0.38, 1.0))
	_add_box("HighCoverB", Vector3(5.0, 1.6, 0.8), Vector3(1.4, 3.2, 3.8), Color(0.24, 0.3, 0.38, 1.0))
	_add_box("PlayerSpawnCover", Vector3(-9.4, 1.25, 6.4), Vector3(3.2, 2.5, 0.9), Color(0.25, 0.31, 0.4, 1.0))
	_add_box("BotSpawnCover", Vector3(9.4, 1.25, -6.4), Vector3(3.2, 2.5, 0.9), Color(0.25, 0.31, 0.4, 1.0))

	_add_box("LowCoverA", Vector3(-2.0, 0.55, -2.5), Vector3(2.8, 1.1, 1.2), Color(0.28, 0.48, 0.54, 1.0))
	_add_box("LowCoverB", Vector3(3.4, 0.55, 2.8), Vector3(2.8, 1.1, 1.2), Color(0.34, 0.26, 0.48, 1.0))
	_add_box("LowCoverC", Vector3(-6.0, 0.55, 4.0), Vector3(3.0, 1.1, 1.0), Color(0.28, 0.48, 0.54, 1.0), Vector3(0.0, 28.0, 0.0))
	_add_box("LowCoverD", Vector3(6.0, 0.55, -4.0), Vector3(3.0, 1.1, 1.0), Color(0.34, 0.26, 0.48, 1.0), Vector3(0.0, 28.0, 0.0))

	_add_box("WestPlatform", Vector3(-9.6, 0.55, -1.6), Vector3(4.4, 1.1, 5.0), Color(0.18, 0.26, 0.33, 1.0))
	_add_box("EastPlatform", Vector3(9.6, 0.55, 1.6), Vector3(4.4, 1.1, 5.0), Color(0.18, 0.26, 0.33, 1.0))
	_add_box("WestRamp", Vector3(-9.6, 0.52, 2.9), Vector3(4.4, 0.32, 4.8), Color(0.22, 0.38, 0.44, 1.0), Vector3(-12.0, 0.0, 0.0))
	_add_box("EastRamp", Vector3(9.6, 0.52, -2.9), Vector3(4.4, 0.32, 4.8), Color(0.22, 0.38, 0.44, 1.0), Vector3(12.0, 0.0, 0.0))
	_add_box("WestHighPlatform", Vector3(-8.0, 2.78, -8.6), Vector3(6.8, 0.58, 4.2), Color(0.16, 0.3, 0.39, 1.0))
	_add_box("EastHighPlatform", Vector3(8.0, 2.78, 8.6), Vector3(6.8, 0.58, 4.2), Color(0.16, 0.3, 0.39, 1.0))
	_add_high_platform_cover("WestHighSoftCover", Vector3(-9.25, 3.48, -7.15), Vector3(2.2, 0.82, 0.34), Color(0.18, 0.34, 0.42, 1.0))
	_add_high_platform_cover("WestHighAngleCover", Vector3(-5.25, 3.52, -9.55), Vector3(0.36, 0.95, 1.7), Color(0.18, 0.34, 0.42, 1.0))
	_add_high_platform_cover("EastHighSoftCover", Vector3(9.25, 3.48, 7.15), Vector3(2.2, 0.82, 0.34), Color(0.18, 0.34, 0.42, 1.0))
	_add_high_platform_cover("EastHighAngleCover", Vector3(5.25, 3.52, 9.55), Vector3(0.36, 0.95, 1.7), Color(0.18, 0.34, 0.42, 1.0))
	_add_visual_box("WestHighGuardMark", Vector3(-8.0, 3.12, -10.6), Vector3(6.2, 0.08, 0.18), Color(0.18, 0.72, 0.86, 1.0))
	_add_visual_box("EastHighGuardMark", Vector3(8.0, 3.12, 10.6), Vector3(6.2, 0.08, 0.18), Color(0.18, 0.72, 0.86, 1.0))
	_add_flow_marker("WestLandingZoneMark", WEST_JUMP_PAD_TARGET + Vector3(0.0, 0.08, 0.0), Vector3(2.3, 0.06, 1.65), Color(0.12, 0.82, 0.96, 1.0))
	_add_flow_marker("EastLandingZoneMark", EAST_JUMP_PAD_TARGET + Vector3(0.0, 0.08, 0.0), Vector3(2.3, 0.06, 1.65), Color(0.12, 0.82, 0.96, 1.0))
	_add_flow_marker("HealthObjectivePadMark", Vector3(HEALTH_PICKUP_POSITION.x, 3.14, HEALTH_PICKUP_POSITION.z), Vector3(1.35, 0.06, 1.35), Color(0.32, 1.0, 0.48, 1.0))
	_add_flow_marker("OverchargeObjectivePadMark", Vector3(OVERCHARGE_PICKUP_POSITION.x, 3.14, OVERCHARGE_PICKUP_POSITION.z), Vector3(1.35, 0.06, 1.35), Color(0.72, 0.42, 1.0, 1.0))
	_add_jump_pad(&"west_pad", "WestJumpPad", WEST_JUMP_PAD_POSITION, WEST_JUMP_PAD_TARGET)
	_add_jump_pad(&"east_pad", "EastJumpPad", EAST_JUMP_PAD_POSITION, EAST_JUMP_PAD_TARGET)

func _spawn_runtime() -> void:
	var runtime_root := Node3D.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)

	player = PlayerController.new()
	player.name = "Player"
	player.position = PLAYER_SPAWN
	runtime_root.add_child(player)
	player.shoot_requested.connect(_on_player_shot)
	player.alt_fire_requested.connect(_on_player_alt_fire)

	bot = BotController.new()
	bot.name = "Bot"
	bot.position = BOT_SPAWN
	runtime_root.add_child(bot)
	bot.set_reposition_points(_create_bot_reposition_points(runtime_root))
	bot.set_jump_pad_routes(_get_jump_pad_routes())
	bot.configure(player)
	bot.shot_windup_started.connect(_on_bot_shot_windup_started)
	bot.shot_feedback_requested.connect(_on_bot_shot_feedback_requested)
	bot.shot_resolution_requested.connect(_on_bot_shot_resolution_requested)

	projectile_root = Node3D.new()
	projectile_root.name = "Projectiles"
	runtime_root.add_child(projectile_root)

	pickup_root = Node3D.new()
	pickup_root.name = "Pickups"
	runtime_root.add_child(pickup_root)
	_build_pickups()
	_update_bot_awareness()

	feedback = FeedbackControllerScript.new()
	feedback.name = "FeedbackController"
	add_child(feedback)

	player.damaged.connect(_on_player_damaged)
	player.died.connect(_on_player_died)
	bot.died.connect(_on_bot_died)

	hud = ArenaHudScript.new()
	hud.name = "ArenaHud"
	add_child(hud)
	hud.sensitivity_changed.connect(_on_sensitivity_changed)
	hud.resume_requested.connect(func() -> void:
		_set_menu_open(false)
	)
	hud.set_sensitivity_value(player.mouse_sensitivity)

func _on_player_shot(origin: Vector3, direction: Vector3, damage: float, knockback: float) -> void:
	if round_ended or menu_open:
		return
	var shot_direction := direction.normalized()
	var shot_end := origin + shot_direction * 96.0
	var visual_origin := _get_player_visual_muzzle_origin(origin, shot_direction)
	if hud != null:
		hud.show_player_shot()
	if feedback != null:
		feedback.play_player_shot(visual_origin, shot_direction)

	var query := PhysicsRayQueryParameters3D.create(origin, shot_end)
	query.exclude = [player.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		if hud != null:
			hud.show_miss()
		if feedback != null:
			feedback.play_miss(visual_origin, shot_end)
		return
	var impact_position: Vector3 = result.get("position", shot_end)
	var collider: Object = result.get("collider", null)
	if collider != null and collider.has_method("take_damage"):
		collider.take_damage(damage, &"player")
		if collider.has_method("apply_knockback"):
			collider.apply_knockback(shot_direction, knockback, PLAYER_SHOT_KNOCKBACK_LIFT)
		if hud != null:
			var killed: bool = collider.get("is_dead") == true
			hud.show_hit_confirm(killed)
		if feedback != null:
			feedback.play_hit(visual_origin, impact_position)
			var knockback_position := impact_position
			if collider.has_method("get_body_center"):
				knockback_position = collider.get_body_center()
			feedback.play_knockback(knockback_position, shot_direction, knockback, true)
		return
	if hud != null:
		hud.show_miss()
	if feedback != null:
		feedback.play_miss(visual_origin, impact_position)

func _on_player_alt_fire(origin: Vector3, direction: Vector3, damage: float, knockback: float, speed: float, radius: float, overcharged: bool) -> void:
	if round_ended or menu_open:
		return
	var shot_direction := direction.normalized()
	if shot_direction.length_squared() <= 0.0001:
		return
	var visual_origin := _get_player_visual_muzzle_origin(origin, shot_direction)
	var aim_point := _resolve_player_aim_point(origin, shot_direction)
	var projectile_direction := aim_point - visual_origin
	if projectile_direction.length_squared() <= 0.0001:
		projectile_direction = shot_direction
	else:
		projectile_direction = projectile_direction.normalized()
	if hud != null:
		hud.show_player_alt_fire(overcharged)
	if feedback != null:
		feedback.play_plasma_shot(visual_origin, projectile_direction, overcharged)
	_spawn_player_plasma_bolt(visual_origin, projectile_direction, damage, knockback, speed, radius, overcharged)

func _spawn_player_plasma_bolt(origin: Vector3, direction: Vector3, damage: float, knockback: float, speed: float, radius: float, overcharged: bool) -> void:
	if projectile_root == null:
		return
	var bolt := Node3D.new()
	bolt.name = "PlayerPlasmaBolt"
	projectile_root.add_child(bolt)
	bolt.global_position = origin

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PlasmaBoltMesh"
	var mesh := SphereMesh.new()
	mesh.radius = radius * (1.12 if overcharged else 1.0)
	mesh.height = mesh.radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_plasma_material(overcharged)
	bolt.add_child(mesh_instance)

	var light := OmniLight3D.new()
	light.name = "PlasmaBoltLight"
	light.light_color = Color(0.78, 0.46, 1.0, 1.0) if overcharged else Color(0.38, 0.98, 1.0, 1.0)
	light.light_energy = 2.5 if overcharged else 1.8
	light.omni_range = 2.8
	bolt.add_child(light)

	active_projectiles.append({
		"node": bolt,
		"velocity": direction.normalized() * maxf(1.0, speed),
		"damage": damage,
		"knockback": knockback,
		"radius": radius * (1.12 if overcharged else 1.0),
		"ttl": PLASMA_BOLT_TTL,
		"source": &"player",
		"overcharged": overcharged
	})
	_update_bot_awareness()

func _process_projectiles(delta: float) -> void:
	for index in range(active_projectiles.size() - 1, -1, -1):
		var entry := active_projectiles[index]
		var bolt := entry.get("node", null) as Node3D
		if bolt == null or not is_instance_valid(bolt):
			active_projectiles.remove_at(index)
			continue
		var ttl := float(entry.get("ttl", 0.0)) - delta
		var velocity: Vector3 = entry.get("velocity", Vector3.ZERO)
		var start_position := bolt.global_position
		var end_position := start_position + velocity * delta
		var result := _query_player_projectile_impact(start_position, end_position, float(entry.get("radius", 0.0)))
		if not result.is_empty():
			var impact_position: Vector3 = result.get("position", end_position)
			var collider: Object = result.get("collider", null)
			_resolve_player_projectile_hit(entry, impact_position, collider)
			_remove_projectile(index)
			continue
		bolt.global_position = end_position
		if ttl <= 0.0:
			if hud != null:
				hud.show_miss()
			if feedback != null:
				feedback.play_plasma_miss(end_position, bool(entry.get("overcharged", false)))
			_remove_projectile(index)
			continue
		entry["ttl"] = ttl
		active_projectiles[index] = entry
	_update_bot_awareness()

func _resolve_player_projectile_hit(entry: Dictionary, impact_position: Vector3, collider: Object) -> void:
	var velocity: Vector3 = entry.get("velocity", Vector3.FORWARD)
	var shot_direction := velocity.normalized()
	var overcharged := bool(entry.get("overcharged", false))
	if collider != null and collider.has_method("take_damage"):
		var damage := float(entry.get("damage", 0.0))
		var knockback := float(entry.get("knockback", 0.0))
		collider.take_damage(damage, &"player")
		if collider.has_method("apply_knockback"):
			collider.apply_knockback(shot_direction, knockback, PLAYER_PLASMA_KNOCKBACK_LIFT)
		if hud != null:
			var killed: bool = collider.get("is_dead") == true
			hud.show_hit_confirm(killed)
		if feedback != null:
			feedback.play_plasma_hit(impact_position, overcharged)
			var knockback_position := impact_position
			if collider.has_method("get_body_center"):
				knockback_position = collider.get_body_center()
			feedback.play_knockback(knockback_position, shot_direction, knockback, true)
		return
	if hud != null:
		hud.show_miss()
	if feedback != null:
		feedback.play_plasma_miss(impact_position, overcharged)

func _resolve_player_aim_point(origin: Vector3, direction: Vector3) -> Vector3:
	var aim_end := origin + direction.normalized() * 96.0
	var query := PhysicsRayQueryParameters3D.create(origin, aim_end)
	if player != null:
		query.exclude = [player.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return aim_end
	return result.get("position", aim_end)

func _query_player_projectile_impact(start_position: Vector3, end_position: Vector3, radius: float) -> Dictionary:
	var exclusions: Array[RID] = []
	if player != null:
		exclusions.append(player.get_rid())

	var ray_query := PhysicsRayQueryParameters3D.create(start_position, end_position)
	ray_query.exclude = exclusions
	var ray_result := get_world_3d().direct_space_state.intersect_ray(ray_query)
	if not ray_result.is_empty():
		return ray_result

	var sphere := SphereShape3D.new()
	sphere.radius = maxf(0.05, radius)
	var shape_query := PhysicsShapeQueryParameters3D.new()
	shape_query.shape = sphere
	shape_query.transform = Transform3D(Basis(), end_position)
	shape_query.exclude = exclusions
	var overlaps := get_world_3d().direct_space_state.intersect_shape(shape_query, 8)
	if overlaps.is_empty():
		return {}
	for overlap: Dictionary in overlaps:
		var collider: Object = overlap.get("collider", null)
		if collider != null and collider.has_method("take_damage"):
			overlap["position"] = end_position
			return overlap
	var first_overlap: Dictionary = overlaps[0]
	first_overlap["position"] = end_position
	return first_overlap

func _remove_projectile(index: int) -> void:
	if index < 0 or index >= active_projectiles.size():
		return
	var entry := active_projectiles[index]
	var bolt := entry.get("node", null) as Node3D
	if bolt != null and is_instance_valid(bolt):
		bolt.queue_free()
	active_projectiles.remove_at(index)
	_update_bot_awareness()

func _clear_projectiles() -> void:
	for entry: Dictionary in active_projectiles:
		var bolt := entry.get("node", null) as Node3D
		if bolt != null and is_instance_valid(bolt):
			bolt.queue_free()
	active_projectiles.clear()

func _on_player_damaged(amount: float, remaining_health: float) -> void:
	if hud != null and player != null:
		hud.show_player_damage(amount, remaining_health / maxf(1.0, player.max_health))
	if feedback != null and player != null:
		feedback.play_player_damage(amount, player.health_fraction(), player.get_body_center())

func _on_bot_shot_windup_started(origin: Vector3, target_position: Vector3, duration: float) -> void:
	if round_ended or menu_open:
		return
	if feedback != null:
		feedback.play_bot_tell(origin, target_position, duration)

func _on_bot_shot_feedback_requested(origin: Vector3, target_position: Vector3) -> void:
	if round_ended or menu_open:
		return
	if feedback != null:
		feedback.play_bot_shot(origin, target_position)

func _on_bot_shot_resolution_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float) -> void:
	if round_ended or menu_open or player == null or bot == null:
		return
	var shot_direction := direction.normalized()
	if shot_direction.length_squared() <= 0.0001:
		return
	var shot_end := origin + shot_direction * maxf(1.0, bot.shoot_range)
	var query := PhysicsRayQueryParameters3D.create(origin, shot_end)
	query.exclude = [bot.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		if feedback != null:
			feedback.play_bot_miss(origin, shot_end)
		return

	var impact_position: Vector3 = result.get("position", shot_end)
	var collider: Object = result.get("collider", null)
	if collider == player:
		if feedback != null:
			feedback.play_bot_shot(origin, impact_position)
		player.take_damage(damage, &"bot")
		player.apply_knockback(shot_direction, knockback, BOT_SHOT_KNOCKBACK_LIFT)
		if feedback != null:
			feedback.play_knockback(player.get_body_center(), shot_direction, knockback, false)
		return
	if feedback != null:
		feedback.play_bot_miss(origin, impact_position)

func _on_player_died() -> void:
	_set_menu_open(false)
	round_ended = true
	round_status = "Bot venceu. Aperte R para reiniciar."
	if hud != null:
		hud.show_round_end(false)
	if feedback != null:
		feedback.play_round_end(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_bot_died() -> void:
	_set_menu_open(false)
	round_ended = true
	round_status = "Player venceu. Aperte R para reiniciar."
	if hud != null:
		hud.show_round_end(true)
	if feedback != null:
		feedback.play_round_end(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _build_hud_snapshot() -> Dictionary:
	return {
		"status": round_status,
		"player_health": 0.0 if player == null else player.health,
		"player_max_health": 1.0 if player == null else player.max_health,
		"bot_health": 0.0 if bot == null else bot.health,
		"bot_max_health": 1.0 if bot == null else bot.max_health,
		"alt_fire_cooldown_fraction": 0.0 if player == null else player.get_alt_fire_cooldown_fraction(),
		"alt_fire_ready": true if player == null else player.alt_fire_cooldown_remaining <= 0.0,
		"player_overcharge": false if player == null else player.has_overcharge_charge(),
		"bot_overcharge": false if bot == null else bot.has_overcharge_charge(),
		"health_pickup_available": debug_is_pickup_available(&"health"),
		"health_pickup_respawn": _get_pickup_respawn_remaining(&"health"),
		"overcharge_pickup_available": debug_is_pickup_available(&"overcharge"),
		"overcharge_pickup_respawn": _get_pickup_respawn_remaining(&"overcharge"),
		"bot_state": &"none" if bot == null else bot.debug_get_state(),
		"bot_route_label": &"none" if bot == null else bot.debug_get_route_label(),
		"bot_has_line_of_sight": false if bot == null else bot.debug_has_line_of_sight(),
		"last_jump_pad_id": last_jump_pad_id,
		"hint": "Click captures mouse | WASD move | LMB rifle | RMB plasma | Pads launch | High pickups | Bot route | R restart | Esc"
	}

func _build_pickups() -> void:
	pickups.clear()
	_create_pickup(&"health", HEALTH_PICKUP_POSITION, Color(0.38, 1.0, 0.52, 1.0))
	_create_pickup(&"overcharge", OVERCHARGE_PICKUP_POSITION, Color(0.78, 0.46, 1.0, 1.0))

func _create_pickup(pickup_kind: StringName, pickup_position: Vector3, color: Color) -> void:
	if pickup_root == null:
		return
	var pickup := Node3D.new()
	pickup.name = "HealthShard" if pickup_kind == &"health" else "Overcharge"
	pickup_root.add_child(pickup)
	pickup.global_position = pickup_position

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PickupMesh"
	if pickup_kind == &"health":
		var mesh := SphereMesh.new()
		mesh.radius = 0.32
		mesh.height = 0.64
		mesh.radial_segments = 12
		mesh.rings = 6
		mesh_instance.mesh = mesh
	else:
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.52, 0.52, 0.52)
		mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_pickup_material(color)
	pickup.add_child(mesh_instance)

	var light := OmniLight3D.new()
	light.name = "PickupLight"
	light.light_color = color
	light.light_energy = 1.55
	light.omni_range = 2.6
	pickup.add_child(light)

	pickups[pickup_kind] = {
		"node": pickup,
		"position": pickup_position,
		"available": true,
		"respawn_remaining": 0.0
	}

func _process_pickups(delta: float) -> void:
	for pickup_kind in pickups.keys():
		var entry: Dictionary = pickups[pickup_kind]
		var pickup_node := entry.get("node", null) as Node3D
		if pickup_node != null and bool(entry.get("available", false)):
			pickup_node.rotate_y(delta * 1.8)
		if not bool(entry.get("available", false)):
			var remaining := maxf(0.0, float(entry.get("respawn_remaining", 0.0)) - delta)
			entry["respawn_remaining"] = remaining
			if remaining <= 0.0:
				entry["available"] = true
				if pickup_node != null:
					pickup_node.visible = true
			pickups[pickup_kind] = entry
			continue
		if player != null and _try_consume_pickup(pickup_kind, player):
			continue
		if bot != null:
			_try_consume_pickup(pickup_kind, bot)

func _process_jump_pads(delta: float) -> void:
	for index in range(jump_pads.size()):
		var pad: Dictionary = jump_pads[index]
		pad["player_cooldown"] = maxf(0.0, float(pad.get("player_cooldown", 0.0)) - delta)
		pad["bot_cooldown"] = maxf(0.0, float(pad.get("bot_cooldown", 0.0)) - delta)
		if _try_trigger_jump_pad(pad, player, &"player"):
			pad["player_cooldown"] = JUMP_PAD_COOLDOWN
		if _try_trigger_jump_pad(pad, bot, &"bot"):
			pad["bot_cooldown"] = JUMP_PAD_COOLDOWN
		jump_pads[index] = pad

func _try_trigger_jump_pad(pad: Dictionary, combatant, actor_id: StringName) -> bool:
	if combatant == null or combatant.get("is_dead") == true:
		return false
	var cooldown_key := "player_cooldown" if actor_id == &"player" else "bot_cooldown"
	if float(pad.get(cooldown_key, 0.0)) > 0.0:
		return false
	var pad_position: Vector3 = pad.get("position", Vector3.ZERO)
	var flat_delta: Vector3 = combatant.global_position - pad_position
	flat_delta.y = 0.0
	if flat_delta.length() > JUMP_PAD_RADIUS:
		return false
	if combatant.global_position.y > pad_position.y + 1.1:
		return false
	var launch_velocity := _build_jump_pad_launch_velocity(pad)
	if combatant.has_method("apply_jump_pad_launch"):
		combatant.apply_jump_pad_launch(launch_velocity)
	else:
		combatant.apply_knockback(launch_velocity.normalized(), launch_velocity.length(), JUMP_PAD_VERTICAL_SPEED)
	jump_pad_trigger_count += 1
	last_jump_pad_id = pad.get("id", &"")
	if hud != null and actor_id == &"player":
		hud.show_jump_pad()
	if feedback != null:
		feedback.play_jump_pad(pad_position, launch_velocity)
	return true

func _build_jump_pad_launch_velocity(pad: Dictionary) -> Vector3:
	var pad_position: Vector3 = pad.get("position", Vector3.ZERO)
	var target_position: Vector3 = pad.get("target", pad_position + Vector3.FORWARD)
	var flat := target_position - pad_position
	flat.y = 0.0
	if flat.length_squared() <= 0.0001:
		flat = Vector3.FORWARD
	return flat.normalized() * JUMP_PAD_FORWARD_SPEED + Vector3.UP * JUMP_PAD_VERTICAL_SPEED

func _try_consume_pickup(pickup_kind: StringName, combatant) -> bool:
	if not pickups.has(pickup_kind) or combatant == null:
		return false
	if combatant.get("is_dead") == true:
		return false
	var entry: Dictionary = pickups[pickup_kind]
	if not bool(entry.get("available", false)):
		return false
	var pickup_position: Vector3 = entry.get("position", Vector3.ZERO)
	if combatant.get_body_center().distance_to(pickup_position) > PICKUP_RADIUS:
		return false
	match pickup_kind:
		&"health":
			if not combatant.has_method("heal"):
				return false
			var applied: float = combatant.heal(HEALTH_PICKUP_AMOUNT)
			if applied <= 0.0:
				return false
		&"overcharge":
			if not combatant.has_method("grant_overcharge"):
				return false
			if combatant.has_method("has_overcharge_charge") and combatant.has_overcharge_charge():
				return false
			combatant.grant_overcharge()
		_:
			return false
	_set_pickup_available(pickup_kind, false)
	if hud != null and combatant == player:
		hud.show_pickup(pickup_kind)
	if feedback != null:
		feedback.play_pickup(pickup_position, pickup_kind)
	_update_bot_awareness()
	return true

func _set_pickup_available(pickup_kind: StringName, available: bool) -> void:
	if not pickups.has(pickup_kind):
		return
	var entry: Dictionary = pickups[pickup_kind]
	entry["available"] = available
	entry["respawn_remaining"] = 0.0 if available else _get_pickup_respawn_duration(pickup_kind)
	var pickup_node := entry.get("node", null) as Node3D
	if pickup_node != null:
		pickup_node.visible = available
	pickups[pickup_kind] = entry

func _reset_pickups() -> void:
	for pickup_kind in pickups.keys():
		_set_pickup_available(pickup_kind, true)

func _reset_vertical_hazards() -> void:
	jump_pad_trigger_count = 0
	last_jump_pad_id = &""
	for index in range(jump_pads.size()):
		var pad: Dictionary = jump_pads[index]
		pad["player_cooldown"] = 0.0
		pad["bot_cooldown"] = 0.0
		jump_pads[index] = pad

func _get_pickup_respawn_duration(pickup_kind: StringName) -> float:
	return HEALTH_PICKUP_RESPAWN if pickup_kind == &"health" else OVERCHARGE_PICKUP_RESPAWN

func _get_pickup_respawn_remaining(pickup_kind: StringName) -> float:
	var entry: Dictionary = pickups.get(pickup_kind, {})
	return float(entry.get("respawn_remaining", 0.0))

func _update_bot_awareness() -> void:
	if bot == null:
		return
	bot.set_jump_pad_routes(_get_jump_pad_routes())
	bot.set_pickup_awareness(
		debug_get_pickup_position(&"health"),
		debug_is_pickup_available(&"health"),
		debug_get_pickup_position(&"overcharge"),
		debug_is_pickup_available(&"overcharge")
	)
	var threat := _get_nearest_player_projectile_to_bot()
	if threat.is_empty():
		bot.set_projectile_threat(Vector3.ZERO, Vector3.ZERO, false)
		return
	var threat_node := threat.get("node", null) as Node3D
	if threat_node == null:
		bot.set_projectile_threat(Vector3.ZERO, Vector3.ZERO, false)
		return
	bot.set_projectile_threat(threat_node.global_position, threat.get("velocity", Vector3.ZERO), true)

func _get_nearest_player_projectile_to_bot() -> Dictionary:
	if bot == null:
		return {}
	var best_entry: Dictionary = {}
	var best_distance := 1000000.0
	for entry: Dictionary in active_projectiles:
		if entry.get("source", &"") != &"player":
			continue
		var threat_node := entry.get("node", null) as Node3D
		if threat_node == null or not is_instance_valid(threat_node):
			continue
		var distance := threat_node.global_position.distance_to(bot.get_body_center())
		if distance < best_distance:
			best_distance = distance
			best_entry = entry
	if best_distance > bot.projectile_dodge_radius * 1.7:
		return {}
	return best_entry

func _get_jump_pad_routes() -> Array[Dictionary]:
	var routes: Array[Dictionary] = []
	for pad: Dictionary in jump_pads:
		routes.append({
			"id": pad.get("id", &""),
			"position": pad.get("position", Vector3.ZERO),
			"target": pad.get("target", Vector3.ZERO)
		})
	return routes

func _get_player_visual_muzzle_origin(origin: Vector3, direction: Vector3) -> Vector3:
	var shot_direction := direction.normalized()
	var fallback_origin := origin + shot_direction * PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET
	if player == null or not player.has_method("get_camera"):
		return fallback_origin
	var camera: Camera3D = player.get_camera()
	if camera == null:
		return fallback_origin
	var camera_basis := camera.global_transform.basis
	var visual_origin := origin
	visual_origin += camera_basis.x.normalized() * PLAYER_VISUAL_MUZZLE_RIGHT_OFFSET
	visual_origin -= camera_basis.y.normalized() * PLAYER_VISUAL_MUZZLE_DOWN_OFFSET
	visual_origin += shot_direction * PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET
	return visual_origin

func _create_bot_reposition_points(parent: Node3D) -> Array[Vector3]:
	var marker_root := Node3D.new()
	marker_root.name = "BotRepositionPoints"
	parent.add_child(marker_root)
	var points: Array[Vector3] = []
	for index in range(BOT_REPOSITION_POINTS.size()):
		var point := BOT_REPOSITION_POINTS[index]
		points.append(point)
		var marker := Marker3D.new()
		marker.name = "BotRepositionPoint%02d" % index
		marker.position = point
		marker_root.add_child(marker)
	return points

func _add_jump_pad(pad_id: StringName, pad_name: String, pad_position: Vector3, target_position: Vector3) -> void:
	var pad := Node3D.new()
	pad.name = pad_name
	pad.position = pad_position
	add_child(pad)

	var base_mesh := MeshInstance3D.new()
	base_mesh.name = "PadSurface"
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.0, 0.12, 2.0)
	base_mesh.mesh = mesh
	base_mesh.position = Vector3(0.0, 0.04, 0.0)
	base_mesh.material_override = _build_box_material(Color(0.04, 0.85, 1.0, 1.0), 1.75)
	pad.add_child(base_mesh)

	var core_mesh := MeshInstance3D.new()
	core_mesh.name = "LaunchCore"
	var core := BoxMesh.new()
	core.size = Vector3(0.85, 0.18, 0.85)
	core_mesh.mesh = core
	core_mesh.position = Vector3(0.0, 0.18, 0.0)
	core_mesh.material_override = _build_box_material(Color(0.95, 0.95, 1.0, 1.0), 2.2)
	pad.add_child(core_mesh)

	var light := OmniLight3D.new()
	light.name = "JumpPadLight"
	light.light_color = Color(0.18, 0.9, 1.0, 1.0)
	light.light_energy = 0.65
	light.omni_range = 4.5
	light.position = Vector3(0.0, 0.55, 0.0)
	pad.add_child(light)

	jump_pads.append({
		"id": pad_id,
		"node": pad,
		"position": pad_position,
		"target": target_position,
		"player_cooldown": 0.0,
		"bot_cooldown": 0.0,
	})

func _add_flow_marker(node_name: String, marker_position: Vector3, marker_size: Vector3, color: Color, marker_rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	flow_marker_count += 1
	return _add_visual_box(node_name, marker_position, marker_size, color, marker_rotation_degrees)

func _add_high_platform_cover(node_name: String, cover_position: Vector3, cover_size: Vector3, color: Color) -> StaticBody3D:
	high_platform_cover_count += 1
	return _add_box(node_name, cover_position, cover_size, color)

func _add_box(node_name: String, box_position: Vector3, box_size: Vector3, color: Color, box_rotation_degrees: Vector3 = Vector3.ZERO) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = box_position
	body.rotation_degrees = box_rotation_degrees
	add_child(body)

	var collider := CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = box_size
	collider.shape = shape
	body.add_child(collider)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_box_material(color)
	body.add_child(mesh_instance)
	return body

func _add_visual_box(node_name: String, box_position: Vector3, box_size: Vector3, color: Color, box_rotation_degrees: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = box_position
	mesh_instance.rotation_degrees = box_rotation_degrees
	var mesh := BoxMesh.new()
	mesh.size = box_size
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_box_material(color, 0.18)
	add_child(mesh_instance)
	return mesh_instance

func _build_plasma_material(overcharged: bool) -> StandardMaterial3D:
	var color := Color(0.78, 0.46, 1.0, 1.0) if overcharged else Color(0.38, 0.98, 1.0, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.22
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.3 if overcharged else 1.8
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _build_pickup_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.3
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.35
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _build_box_material(color: Color, emission_energy: float = 0.05) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = emission_energy
	return material

func _capture_mouse_if_playing() -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return
	if menu_open or round_ended:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _set_menu_open(is_open: bool) -> void:
	menu_open = is_open
	get_tree().paused = menu_open
	if hud != null:
		hud.set_pause_menu_visible(menu_open, player.mouse_sensitivity)
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_capture_mouse_if_playing()

func _on_sensitivity_changed(value: float) -> void:
	if player != null:
		player.set_mouse_sensitivity(value)
	if hud != null:
		hud.set_sensitivity_value(player.mouse_sensitivity)
