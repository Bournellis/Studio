class_name FpsArenaRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/fps_player_controller.gd")
const BotController = preload("res://gameplay/bot/basic_duel_bot.gd")
const ArenaHudScript = preload("res://presentation/hud/arena_hud.gd")

const FLOOR_SIZE: Vector3 = Vector3(26.0, 1.0, 26.0)
const WALL_HEIGHT: float = 3.2
const WALL_THICKNESS: float = 0.8
const PLAYER_SPAWN: Vector3 = Vector3(-7.0, 1.1, 5.2)
const BOT_SPAWN: Vector3 = Vector3(7.0, 1.1, -5.2)

var player
var bot
var hud
var round_status: String = "Arena 1x1 V1"
var round_ended: bool = false

func _ready() -> void:
	_configure_world()
	_spawn_runtime()
	_capture_mouse_if_playing()

func _process(_delta: float) -> void:
	if hud != null:
		hud.update_snapshot(_build_hud_snapshot())

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_back"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			_capture_mouse_if_playing()
	if event is InputEventMouseButton and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_capture_mouse_if_playing()
	if Input.is_action_just_pressed("restart_round"):
		restart_round()

func restart_round() -> void:
	round_status = "Arena 1x1 V1"
	round_ended = false
	player.global_position = PLAYER_SPAWN
	player.rotation = Vector3.ZERO
	player.configure_for_round()
	bot.global_position = BOT_SPAWN
	bot.rotation = Vector3.ZERO
	bot.configure(player)
	_capture_mouse_if_playing()

func debug_get_player():
	return player

func debug_get_bot():
	return bot

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

	_add_box("ArenaFloor", Vector3(0.0, -0.5, 0.0), FLOOR_SIZE, Color(0.16, 0.2, 0.26, 1.0))
	var half := FLOOR_SIZE.x * 0.5
	_add_box("NorthWall", Vector3(0.0, WALL_HEIGHT * 0.5, -half), Vector3(FLOOR_SIZE.x, WALL_HEIGHT, WALL_THICKNESS), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("SouthWall", Vector3(0.0, WALL_HEIGHT * 0.5, half), Vector3(FLOOR_SIZE.x, WALL_HEIGHT, WALL_THICKNESS), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("WestWall", Vector3(-half, WALL_HEIGHT * 0.5, 0.0), Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("EastWall", Vector3(half, WALL_HEIGHT * 0.5, 0.0), Vector3(WALL_THICKNESS, WALL_HEIGHT, FLOOR_SIZE.z), Color(0.22, 0.28, 0.34, 1.0))
	_add_box("LowCoverA", Vector3(-2.0, 0.55, -2.5), Vector3(2.2, 1.1, 1.4), Color(0.28, 0.44, 0.5, 1.0))
	_add_box("LowCoverB", Vector3(3.4, 0.55, 2.8), Vector3(2.4, 1.1, 1.4), Color(0.32, 0.25, 0.42, 1.0))

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
	bot.configure(player)

	player.died.connect(_on_player_died)
	bot.died.connect(_on_bot_died)

	hud = ArenaHudScript.new()
	hud.name = "ArenaHud"
	add_child(hud)

func _on_player_shot(origin: Vector3, direction: Vector3, damage: float, knockback: float) -> void:
	if round_ended:
		return
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction.normalized() * 96.0)
	query.exclude = [player.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return
	var collider: Object = result.get("collider", null)
	if collider != null and collider.has_method("take_damage"):
		collider.take_damage(damage, &"player")
		if collider.has_method("apply_knockback"):
			collider.apply_knockback(direction, knockback)
		if hud != null:
			hud.flash_hit()

func _on_player_died() -> void:
	round_ended = true
	round_status = "Bot venceu. Aperte R para reiniciar."
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_bot_died() -> void:
	round_ended = true
	round_status = "Player venceu. Aperte R para reiniciar."
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _build_hud_snapshot() -> Dictionary:
	return {
		"status": round_status,
		"player_health": 0.0 if player == null else player.health,
		"player_max_health": 1.0 if player == null else player.max_health,
		"bot_health": 0.0 if bot == null else bot.health,
		"bot_max_health": 1.0 if bot == null else bot.max_health,
		"hint": "WASD move | Mouse look | LMB shoot | Space jump | R restart | Esc mouse"
	}

func _add_box(node_name: String, position: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	add_child(body)

	var collider := CollisionShape3D.new()
	collider.name = "CollisionShape3D"
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "MeshInstance3D"
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.84
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 0.05
	mesh_instance.material_override = material
	body.add_child(mesh_instance)
	return body

func _capture_mouse_if_playing() -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
