class_name OpenworldVirtualJoystick
extends Control

signal vector_changed(vector: Vector2)

const BASE_SIZE := Vector2(112, 112)
const KNOB_DIAMETER := 54.0
const DEADZONE := 0.16

var _active := false
var _active_index := -1
var _vector := Vector2.ZERO
var _knob_offset := Vector2.ZERO
var _free_mode := false

func _ready() -> void:
	name = "OpenworldVirtualJoystick"
	custom_minimum_size = BASE_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_text = "Joystick"
	queue_redraw()

func input_vector() -> Vector2:
	return _vector

func is_active() -> bool:
	return _active

func begin_free(screen_position: Vector2, pointer_index: int = -2) -> void:
	_free_mode = true
	_active = true
	_active_index = pointer_index
	visible = true
	size = BASE_SIZE
	position = screen_position - size * 0.5
	_update_from_local(size * 0.5)

func drag_free(screen_position: Vector2, pointer_index: int = -2) -> void:
	if not _active or _active_index != pointer_index:
		return
	_update_from_local(screen_position - position)

func end_free(pointer_index: int = -2) -> void:
	if _active_index != pointer_index and pointer_index != -999:
		return
	reset()
	if _free_mode:
		visible = false

func reset() -> void:
	_active = false
	_active_index = -1
	_set_vector(Vector2.ZERO)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _active_index == -1:
			_active = true
			_active_index = touch.index
			_update_from_local(touch.position)
			accept_event()
		elif not touch.pressed and touch.index == _active_index:
			end_free(touch.index)
			accept_event()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _active_index:
			if _free_mode:
				drag_free(get_global_rect().position + drag.position, drag.index)
			else:
				_update_from_local(drag.position)
			accept_event()
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse.pressed:
			_active = true
			_active_index = -2
			_update_from_local(mouse.position)
			accept_event()
		elif _active and _active_index == -2:
			end_free(-2)
			accept_event()
	elif event is InputEventMouseMotion and _active and _active_index == -2:
		if _free_mode:
			drag_free(get_global_rect().position + (event as InputEventMouseMotion).position, -2)
		else:
			_update_from_local((event as InputEventMouseMotion).position)
		accept_event()

func _update_from_local(local_position: Vector2) -> void:
	var radius := minf(size.x, size.y) * 0.5
	var raw := local_position - size * 0.5
	var clamped := raw.limit_length(radius)
	_knob_offset = clamped
	var normalized := clamped / radius
	if normalized.length() < DEADZONE:
		normalized = Vector2.ZERO
	else:
		normalized = normalized.limit_length(1.0)
	_set_vector(normalized)

func _set_vector(value: Vector2) -> void:
	var next := value.limit_length(1.0)
	if next.is_equal_approx(_vector):
		return
	_vector = next
	if _vector == Vector2.ZERO:
		_knob_offset = Vector2.ZERO
	vector_changed.emit(_vector)
	queue_redraw()

func _draw() -> void:
	var radius := minf(size.x, size.y) * 0.5
	var center := size * 0.5
	if _free_mode and not visible:
		return
	draw_circle(center + Vector2(0, 3), radius, Color(0.0, 0.0, 0.0, 0.32))
	draw_circle(center, radius, Color(0.08, 0.10, 0.09, 0.74))
	draw_arc(center, radius - 3.0, 0.0, TAU, 64, Color(0.82, 0.74, 0.58, 0.62), 2.0, true)
	draw_circle(center, radius * DEADZONE, Color(0.82, 0.74, 0.58, 0.10))
	var knob_radius := KNOB_DIAMETER * 0.5
	var knob_center := center + _knob_offset
	draw_circle(knob_center + Vector2(0, 2), knob_radius, Color(0.0, 0.0, 0.0, 0.34))
	draw_circle(knob_center, knob_radius, Color(0.58, 0.10, 0.11, 0.92))
	draw_arc(knob_center, knob_radius - 2.0, 0.0, TAU, 48, Color(0.96, 0.88, 0.66, 0.68), 2.0, true)
