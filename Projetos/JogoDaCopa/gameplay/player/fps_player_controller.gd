class_name FpsPlayerController
extends "res://gameplay/combat/combatant_3d.gd"

signal shoot_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float)
signal alt_fire_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float, speed: float, radius: float, overcharged: bool)
signal arcade_dash_started(direction: Vector3)
signal arcade_flip_started(direction: Vector3)

const MIN_MOUSE_SENSITIVITY: float = 0.0008
const MAX_MOUSE_SENSITIVITY: float = 0.0032
const DEFAULT_MOUSE_SENSITIVITY: float = 0.0018
const ARCADE_DASH_SPEED: float = 14.0
const ARCADE_DASH_DURATION: float = 0.22
const ARCADE_DASH_COOLDOWN: float = 1.6
const ARCADE_DASH_STAMINA_COST: float = 20.0
const ARCADE_FLIP_VERTICAL_VELOCITY: float = 4.4
const ARCADE_FLIP_HORIZONTAL_SPEED: float = 8.0

@export var move_speed: float = 7.8
@export var jump_velocity: float = 5.6
@export var air_control: float = 0.72
@export var mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
@export var shot_damage: float = 22.0
@export var shot_knockback: float = 7.5
@export var shot_cooldown: float = 0.18
@export var alt_fire_damage: float = 16.0
@export var alt_fire_knockback: float = 10.8
@export var alt_fire_cooldown: float = 0.9
@export var alt_fire_speed: float = 18.0
@export var alt_fire_radius: float = 0.34
@export var overcharge_damage_multiplier: float = 1.35
@export var overcharge_knockback_multiplier: float = 1.25
@export var boost_speed_multiplier: float = 1.52
@export var boost_stamina_max: float = 100.0
@export var boost_stamina_deplete_per_second: float = 38.0
@export var boost_stamina_recharge_per_second: float = 26.0
@export var boost_recharge_delay: float = 0.45
@export var boost_min_stamina_to_start: float = 8.0

var head: Node3D
var camera: Camera3D
var pitch: float = 0.0
var vertical_velocity: float = 0.0
var launch_boost_velocity: Vector3 = Vector3.ZERO
var jump_pad_launch_count: int = 0
var shot_cooldown_remaining: float = 0.0
var alt_fire_cooldown_remaining: float = 0.0
var overcharge_shots_remaining: int = 0
var boost_stamina: float = 100.0
var boost_recharge_delay_remaining: float = 0.0
var boost_active: bool = false
var input_locked: bool = false
var arcade_dash_remaining: float = 0.0
var arcade_dash_cooldown_remaining: float = 0.0
var arcade_dash_direction: Vector3 = Vector3.FORWARD
var arcade_dash_count: int = 0
var arcade_flip_available: bool = true
var arcade_flip_count: int = 0
var arcade_stun_remaining: float = 0.0

func _ready() -> void:
	super._ready()
	set_process_input(true)
	configure_for_round()
	_ensure_camera_nodes()

func configure_for_round() -> void:
	configure_combatant(&"player", 100.0, Color(0.32, 0.82, 1.0, 1.0))
	vertical_velocity = 0.0
	launch_boost_velocity = Vector3.ZERO
	jump_pad_launch_count = 0
	shot_cooldown_remaining = 0.0
	alt_fire_cooldown_remaining = 0.0
	overcharge_shots_remaining = 0
	boost_stamina = boost_stamina_max
	boost_recharge_delay_remaining = 0.0
	boost_active = false
	arcade_dash_remaining = 0.0
	arcade_dash_cooldown_remaining = 0.0
	arcade_dash_direction = Vector3.FORWARD
	arcade_dash_count = 0
	arcade_flip_available = true
	arcade_flip_count = 0
	arcade_stun_remaining = 0.0
	pitch = 0.0
	if head != null:
		head.rotation.x = pitch

func _input(event: InputEvent) -> void:
	if input_locked:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not is_dead:
		var motion := event as InputEventMouseMotion
		apply_mouse_look(motion.relative)
		return
	if event.is_action_pressed("shoot"):
		request_shot()
		return
	if event.is_action_pressed("alt_fire"):
		request_alt_fire()
		return
	if event.is_action_pressed("arcade_dash"):
		request_arcade_dash()

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	shot_cooldown_remaining = maxf(0.0, shot_cooldown_remaining - delta)
	alt_fire_cooldown_remaining = maxf(0.0, alt_fire_cooldown_remaining - delta)
	arcade_dash_cooldown_remaining = maxf(0.0, arcade_dash_cooldown_remaining - delta)
	arcade_stun_remaining = maxf(0.0, arcade_stun_remaining - delta)
	if arcade_stun_remaining > 0.0:
		boost_active = false
		var stun_knockback := consume_knockback(delta, is_on_floor())
		velocity = Vector3(stun_knockback.x, stun_knockback.y, stun_knockback.z)
		move_and_slide()
		return
	_handle_shooting()
	_handle_movement(delta)
	move_and_slide()
	if is_on_floor() and vertical_velocity < 0.0:
		vertical_velocity = -0.1

func get_camera() -> Camera3D:
	return camera

func get_shot_origin() -> Vector3:
	return camera.global_position if camera != null else global_position + Vector3.UP * 1.55

func get_shot_direction() -> Vector3:
	return -camera.global_transform.basis.z.normalized() if camera != null else -global_transform.basis.z.normalized()

func apply_mouse_look(relative_motion: Vector2) -> void:
	rotate_y(-relative_motion.x * mouse_sensitivity)
	pitch = clampf(pitch - relative_motion.y * mouse_sensitivity, deg_to_rad(-82.0), deg_to_rad(82.0))
	if head != null:
		head.rotation.x = pitch

func set_mouse_sensitivity(next_sensitivity: float) -> void:
	mouse_sensitivity = clampf(next_sensitivity, MIN_MOUSE_SENSITIVITY, MAX_MOUSE_SENSITIVITY)

func request_shot() -> void:
	if input_locked:
		return
	if not _can_request_fire():
		return
	if shot_cooldown_remaining > 0.0:
		return
	shot_cooldown_remaining = shot_cooldown
	var was_overcharged := _consume_overcharge()
	var damage := shot_damage * (overcharge_damage_multiplier if was_overcharged else 1.0)
	var knockback := shot_knockback * (overcharge_knockback_multiplier if was_overcharged else 1.0)
	shoot_requested.emit(get_shot_origin(), get_shot_direction(), damage, knockback)

func request_alt_fire() -> void:
	if input_locked:
		return
	if not _can_request_fire():
		return
	if alt_fire_cooldown_remaining > 0.0:
		return
	alt_fire_cooldown_remaining = alt_fire_cooldown
	var was_overcharged := _consume_overcharge()
	var damage := alt_fire_damage * (overcharge_damage_multiplier if was_overcharged else 1.0)
	var knockback := alt_fire_knockback * (overcharge_knockback_multiplier if was_overcharged else 1.0)
	alt_fire_requested.emit(get_shot_origin(), get_shot_direction(), damage, knockback, alt_fire_speed, alt_fire_radius, was_overcharged)

func request_arcade_dash(override_direction: Vector3 = Vector3.ZERO) -> bool:
	if input_locked or is_dead or arcade_stun_remaining > 0.0:
		return false
	if arcade_dash_cooldown_remaining > 0.0 or boost_stamina < ARCADE_DASH_STAMINA_COST:
		return false
	var direction := _flatten_direction(override_direction)
	if direction.length_squared() <= 0.0001:
		direction = _get_desired_move_direction()
	if direction.length_squared() <= 0.0001:
		direction = _get_forward_direction()
	arcade_dash_direction = direction.normalized()
	arcade_dash_remaining = ARCADE_DASH_DURATION
	arcade_dash_cooldown_remaining = ARCADE_DASH_COOLDOWN
	arcade_dash_count += 1
	boost_stamina = maxf(0.0, boost_stamina - ARCADE_DASH_STAMINA_COST)
	boost_recharge_delay_remaining = boost_recharge_delay
	arcade_dash_started.emit(arcade_dash_direction)
	return true

func request_arcade_flip(override_direction: Vector3 = Vector3.ZERO) -> bool:
	if input_locked or is_dead or arcade_stun_remaining > 0.0:
		return false
	if is_on_floor() or not arcade_flip_available:
		return false
	var direction := _flatten_direction(override_direction)
	if direction.length_squared() <= 0.0001:
		direction = _get_desired_move_direction()
	if direction.length_squared() <= 0.0001:
		direction = _get_forward_direction()
	vertical_velocity = maxf(vertical_velocity, ARCADE_FLIP_VERTICAL_VELOCITY)
	launch_boost_velocity = direction.normalized() * ARCADE_FLIP_HORIZONTAL_SPEED
	arcade_flip_available = false
	arcade_flip_count += 1
	arcade_flip_started.emit(direction.normalized())
	return true

func apply_arcade_stun(duration: float) -> void:
	arcade_stun_remaining = maxf(arcade_stun_remaining, duration)
	boost_active = false
	arcade_dash_remaining = 0.0

func grant_overcharge() -> void:
	if is_dead:
		return
	overcharge_shots_remaining = 1

func has_overcharge_charge() -> bool:
	return overcharge_shots_remaining > 0

func get_alt_fire_cooldown_fraction() -> float:
	if alt_fire_cooldown <= 0.0:
		return 0.0
	return clampf(alt_fire_cooldown_remaining / alt_fire_cooldown, 0.0, 1.0)

func get_boost_stamina_fraction() -> float:
	if boost_stamina_max <= 0.0:
		return 0.0
	return clampf(boost_stamina / boost_stamina_max, 0.0, 1.0)

func is_boosting() -> bool:
	return boost_active

func is_arcade_dashing() -> bool:
	return arcade_dash_remaining > 0.0

func get_arcade_dash_direction() -> Vector3:
	return arcade_dash_direction

func get_arcade_dash_cooldown_fraction() -> float:
	if ARCADE_DASH_COOLDOWN <= 0.0:
		return 0.0
	return clampf(arcade_dash_cooldown_remaining / ARCADE_DASH_COOLDOWN, 0.0, 1.0)

func apply_jump_pad_launch(launch_velocity: Vector3) -> void:
	if is_dead:
		return
	vertical_velocity = maxf(vertical_velocity, launch_velocity.y)
	launch_boost_velocity = Vector3(launch_velocity.x, 0.0, launch_velocity.z)
	jump_pad_launch_count += 1

func clear_movement_impulses() -> void:
	vertical_velocity = 0.0
	launch_boost_velocity = Vector3.ZERO
	velocity = Vector3.ZERO
	knockback_velocity = Vector3.ZERO
	arcade_dash_remaining = 0.0

func set_input_locked(is_locked: bool) -> void:
	input_locked = is_locked
	if input_locked:
		boost_active = false
		velocity = Vector3.ZERO
		vertical_velocity = 0.0
		arcade_dash_remaining = 0.0

func debug_get_vertical_velocity() -> float:
	return vertical_velocity

func debug_get_jump_pad_launch_count() -> int:
	return jump_pad_launch_count

func debug_get_boost_stamina() -> float:
	return boost_stamina

func debug_set_boost_stamina(next_stamina: float) -> void:
	boost_stamina = clampf(next_stamina, 0.0, boost_stamina_max)
	boost_recharge_delay_remaining = 0.0

func debug_get_arcade_dash_count() -> int:
	return arcade_dash_count

func debug_get_arcade_flip_count() -> int:
	return arcade_flip_count

func debug_is_arcade_flip_available() -> bool:
	return arcade_flip_available

func debug_get_arcade_stun_remaining() -> float:
	return arcade_stun_remaining

func debug_force_arcade_flip_available(is_available: bool) -> void:
	arcade_flip_available = is_available

func debug_reset_arcade_flip_for_floor() -> void:
	arcade_flip_available = true

func _handle_shooting() -> void:
	if input_locked:
		return
	if Input.is_action_just_pressed("shoot"):
		request_shot()
	if Input.is_action_just_pressed("alt_fire"):
		request_alt_fire()
	if Input.is_action_just_pressed("arcade_dash"):
		request_arcade_dash()

func _consume_overcharge() -> bool:
	if overcharge_shots_remaining <= 0:
		return false
	overcharge_shots_remaining -= 1
	return true

func _can_request_fire() -> bool:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return true
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func _handle_movement(delta: float) -> void:
	if input_locked:
		boost_active = false
		velocity = Vector3.ZERO
		return
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	if not is_on_floor():
		vertical_velocity -= gravity * delta
		if Input.is_action_just_pressed("jump"):
			request_arcade_flip()
	elif Input.is_action_just_pressed("jump"):
		vertical_velocity = jump_velocity
	else:
		arcade_flip_available = true

	var direction := _get_desired_move_direction()

	_update_boost(delta, direction.length_squared() > 0.0001)

	var speed_multiplier := boost_speed_multiplier if boost_active else 1.0
	var horizontal_velocity := direction * move_speed * speed_multiplier
	if not is_on_floor():
		var previous_horizontal := Vector3(velocity.x, 0.0, velocity.z)
		horizontal_velocity = previous_horizontal.lerp(horizontal_velocity, clampf(air_control, 0.0, 1.0))

	var knockback := consume_knockback(delta, is_on_floor())
	var launch_boost := _consume_launch_boost(delta)
	var dash_velocity := _consume_arcade_dash(delta)
	if dash_velocity.length_squared() > 0.0001:
		horizontal_velocity = dash_velocity
	velocity = horizontal_velocity + Vector3(knockback.x, 0.0, knockback.z) + launch_boost
	velocity.y = vertical_velocity + knockback.y

func _consume_arcade_dash(delta: float) -> Vector3:
	if arcade_dash_remaining <= 0.0:
		return Vector3.ZERO
	arcade_dash_remaining = maxf(0.0, arcade_dash_remaining - delta)
	return arcade_dash_direction * ARCADE_DASH_SPEED

func _consume_launch_boost(delta: float) -> Vector3:
	var current := launch_boost_velocity
	launch_boost_velocity = launch_boost_velocity.move_toward(Vector3.ZERO, 5.8 * delta)
	return current

func _update_boost(delta: float, has_movement_input: bool) -> void:
	var wants_boost := Input.is_action_pressed("boost") and has_movement_input
	var has_enough_to_start := boost_active or boost_stamina >= boost_min_stamina_to_start
	boost_active = wants_boost and has_enough_to_start and boost_stamina > 0.0
	if boost_active:
		boost_stamina = maxf(0.0, boost_stamina - boost_stamina_deplete_per_second * delta)
		boost_recharge_delay_remaining = boost_recharge_delay
		if boost_stamina <= 0.0:
			boost_active = false
		return

	boost_recharge_delay_remaining = maxf(0.0, boost_recharge_delay_remaining - delta)
	if boost_recharge_delay_remaining <= 0.0:
		boost_stamina = minf(boost_stamina_max, boost_stamina + boost_stamina_recharge_per_second * delta)

func _get_desired_move_direction() -> Vector3:
	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := _get_forward_direction()
	var right := global_transform.basis.x
	right.y = 0.0
	right = right.normalized() if right.length_squared() > 0.0001 else Vector3.RIGHT
	var direction := right * input_vector.x + forward * -input_vector.y
	return direction.normalized() if direction.length_squared() > 0.0001 else Vector3.ZERO

func _get_forward_direction() -> Vector3:
	var forward := -global_transform.basis.z
	forward.y = 0.0
	return forward.normalized() if forward.length_squared() > 0.0001 else Vector3.FORWARD

func _flatten_direction(direction: Vector3) -> Vector3:
	var flat := Vector3(direction.x, 0.0, direction.z)
	return flat.normalized() if flat.length_squared() > 0.0001 else Vector3.ZERO

func _ensure_camera_nodes() -> void:
	head = get_node_or_null("Head") as Node3D
	if head == null:
		head = Node3D.new()
		head.name = "Head"
		head.position = Vector3(0.0, 1.5, 0.0)
		add_child(head)

	camera = head.get_node_or_null("Camera3D") as Camera3D
	if camera == null:
		camera = Camera3D.new()
		camera.name = "Camera3D"
		camera.fov = 86.0
		camera.near = 0.04
		head.add_child(camera)
	camera.current = true

	var body_mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if body_mesh != null:
		body_mesh.visible = false
