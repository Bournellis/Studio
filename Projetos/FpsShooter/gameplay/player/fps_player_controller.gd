class_name FpsPlayerController
extends "res://gameplay/combat/combatant_3d.gd"

signal shoot_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float)

@export var move_speed: float = 7.2
@export var jump_velocity: float = 5.2
@export var mouse_sensitivity: float = 0.0034
@export var shot_damage: float = 22.0
@export var shot_knockback: float = 7.5
@export var shot_cooldown: float = 0.18

var head: Node3D
var camera: Camera3D
var pitch: float = 0.0
var vertical_velocity: float = 0.0
var shot_cooldown_remaining: float = 0.0

func _ready() -> void:
	super._ready()
	set_process_input(true)
	configure_for_round()
	_ensure_camera_nodes()

func configure_for_round() -> void:
	configure_combatant(&"player", 100.0, Color(0.32, 0.82, 1.0, 1.0))
	vertical_velocity = 0.0
	shot_cooldown_remaining = 0.0
	pitch = 0.0
	if head != null:
		head.rotation.x = pitch

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not is_dead:
		var motion := event as InputEventMouseMotion
		apply_mouse_look(motion.relative)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	shot_cooldown_remaining = maxf(0.0, shot_cooldown_remaining - delta)
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

func _handle_shooting() -> void:
	if not Input.is_action_just_pressed("shoot"):
		return
	if shot_cooldown_remaining > 0.0:
		return
	shot_cooldown_remaining = shot_cooldown
	shoot_requested.emit(get_shot_origin(), get_shot_direction(), shot_damage, shot_knockback)

func _handle_movement(delta: float) -> void:
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	if not is_on_floor():
		vertical_velocity -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		vertical_velocity = jump_velocity

	var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_transform.basis.x
	right.y = 0.0
	right = right.normalized()

	var direction := right * input_vector.x + forward * -input_vector.y
	if direction.length_squared() > 0.0001:
		direction = direction.normalized()

	var knockback := consume_knockback(delta)
	velocity = direction * move_speed + Vector3(knockback.x, 0.0, knockback.z)
	velocity.y = vertical_velocity + knockback.y

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
		camera.fov = 82.0
		camera.near = 0.04
		head.add_child(camera)
	camera.current = true

	var body_mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
	if body_mesh != null:
		body_mesh.visible = false
