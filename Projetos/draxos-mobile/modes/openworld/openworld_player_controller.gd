class_name OpenworldPlayerController
extends CharacterBody2D

const PLAYER_RADIUS := 20.0

var pocket_full := false
var walk_phase := 0.0

func _ready() -> void:
	name = "OpenworldPlayer"
	collision_layer = 1
	collision_mask = 1
	var shape := CollisionShape2D.new()
	shape.name = "OpenworldPlayerCollision"
	var circle := CircleShape2D.new()
	circle.radius = PLAYER_RADIUS
	shape.shape = circle
	add_child(shape)
	queue_redraw()

func move_with_input(input_vector: Vector2, speed: float) -> bool:
	var before := global_position
	var movement := input_vector.limit_length(1.0)
	velocity = movement * maxf(0.0, speed)
	move_and_slide()
	_update_depth()
	if movement.length() > 0.05:
		walk_phase += get_physics_process_delta_time() * 12.0
	queue_redraw()
	return global_position.distance_to(before) > 0.01

func stop_motion() -> void:
	velocity = Vector2.ZERO

func set_visual_state(next_pocket_full: bool, next_walk_phase: float) -> void:
	pocket_full = next_pocket_full
	walk_phase = next_walk_phase
	_update_depth()
	queue_redraw()

func _update_depth() -> void:
	z_index = int(global_position.y + PLAYER_RADIUS)

func _draw() -> void:
	var bob := sin(walk_phase) * 3.0
	var pos := Vector2(0, bob)
	draw_circle(Vector2(0, 18), 19.0, Color(0.0, 0.0, 0.0, 0.34))
	draw_colored_polygon(PackedVector2Array([
		pos + Vector2(0, -28),
		pos + Vector2(21, 17),
		pos + Vector2(0, 31),
		pos + Vector2(-21, 17),
	]), Color(0.23, 0.04, 0.055))
	draw_circle(pos + Vector2(0, -17), 16.0, Color(0.10, 0.08, 0.075))
	draw_arc(pos + Vector2(0, -17), 12.0, PI * 0.10, PI * 0.90, 24, Color(0.79, 0.70, 0.50, 0.56), 2.0, true)
	draw_line(pos + Vector2(18, -8), pos + Vector2(29, 25), Color(0.45, 0.28, 0.13), 4.0)
	draw_circle(pos + Vector2(30, 26), 5.0, Color(0.72, 0.62, 0.42))
	if pocket_full:
		draw_arc(Vector2.ZERO, 36.0, 0.0, TAU, 40, Color(0.70, 0.07, 0.08, 0.75), 3.0, true)
