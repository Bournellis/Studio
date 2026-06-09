class_name FpsArenaRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/fps_player_controller.gd")
const BotController = preload("res://gameplay/bot/basic_duel_bot.gd")
const ArenaHudScript = preload("res://presentation/hud/arena_hud.gd")
const FeedbackControllerScript = preload("res://presentation/feedback/fps_feedback_controller.gd")

const FLOOR_SIZE: Vector3 = Vector3(30.0, 1.0, 30.0)
const WALL_HEIGHT: float = 3.6
const WALL_THICKNESS: float = 0.8
const PLAYER_SPAWN: Vector3 = Vector3(-10.8, 0.05, 8.6)
const BOT_SPAWN: Vector3 = Vector3(10.8, 0.05, -8.6)
const PLAYER_VISUAL_MUZZLE_RIGHT_OFFSET: float = 0.34
const PLAYER_VISUAL_MUZZLE_DOWN_OFFSET: float = 0.24
const PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET: float = 0.82
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
	Vector3(2.2, 0.05, -2.4)
]

var player
var bot
var hud
var feedback
var round_status: String = "Duel Pit V1"
var round_ended: bool = false
var menu_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_configure_world()
	_spawn_runtime()
	_capture_mouse_if_playing()

func _process(_delta: float) -> void:
	if hud != null:
		hud.update_snapshot(_build_hud_snapshot())

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
	round_status = "Duel Pit V1"
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
	_add_box("ArenaFloor", Vector3(0.0, -0.5, 0.0), FLOOR_SIZE, Color(0.13, 0.17, 0.23, 1.0))
	var half := FLOOR_SIZE.x * 0.5
	_add_box("NorthWall", Vector3(0.0, WALL_HEIGHT * 0.5, -half), Vector3(FLOOR_SIZE.x, WALL_HEIGHT, WALL_THICKNESS), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("SouthWall", Vector3(0.0, WALL_HEIGHT * 0.5, half), Vector3(FLOOR_SIZE.x, WALL_HEIGHT, WALL_THICKNESS), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("WestWall", Vector3(-half, WALL_HEIGHT * 0.5, 0.0), Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("EastWall", Vector3(half, WALL_HEIGHT * 0.5, 0.0), Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_visual_box("CenterLaneMark", Vector3(0.0, 0.025, 0.0), Vector3(1.1, 0.05, 24.0), Color(0.18, 0.52, 0.62, 1.0))
	_add_visual_box("EastRouteMark", Vector3(8.8, 0.026, 0.0), Vector3(0.8, 0.05, 20.0), Color(0.38, 0.25, 0.58, 1.0))
	_add_visual_box("WestRouteMark", Vector3(-8.8, 0.026, 0.0), Vector3(0.8, 0.05, 20.0), Color(0.38, 0.25, 0.58, 1.0))

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

func _spawn_runtime() -> void:
	var runtime_root := Node3D.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)

	player = PlayerController.new()
	player.name = "Player"
	player.position = PLAYER_SPAWN
	runtime_root.add_child(player)
	player.shoot_requested.connect(_on_player_shot)

	bot = BotController.new()
	bot.name = "Bot"
	bot.position = BOT_SPAWN
	runtime_root.add_child(bot)
	bot.set_reposition_points(_create_bot_reposition_points(runtime_root))
	bot.configure(player)
	bot.shot_windup_started.connect(_on_bot_shot_windup_started)
	bot.shot_feedback_requested.connect(_on_bot_shot_feedback_requested)
	bot.shot_resolution_requested.connect(_on_bot_shot_resolution_requested)

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
			collider.apply_knockback(shot_direction, knockback)
		if hud != null:
			var killed: bool = collider.get("is_dead") == true
			hud.show_hit_confirm(killed)
		if feedback != null:
			feedback.play_hit(visual_origin, impact_position)
		return
	if hud != null:
		hud.show_miss()
	if feedback != null:
		feedback.play_miss(visual_origin, impact_position)

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
		player.apply_knockback(shot_direction, knockback)
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
		"hint": "Click captures mouse | WASD move | Mouse look | LMB shoot | Space jump | R restart | Esc menu"
	}

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
