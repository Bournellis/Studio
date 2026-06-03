class_name OpenworldForestInputController
extends RefCounted

const JoystickScript := preload("res://modes/openworld/openworld_virtual_joystick.gd")

const KEYBOARD_ACTION_KEYS := {
	"openworld_move_left": [KEY_A, KEY_LEFT],
	"openworld_move_right": [KEY_D, KEY_RIGHT],
	"openworld_move_up": [KEY_W, KEY_UP],
	"openworld_move_down": [KEY_S, KEY_DOWN],
}

var joystick: Variant = null
var debug_vector := Vector2.ZERO
var free_pointer_active := false
var free_pointer_index := -999

var _keyboard_action_down := {}
var _screen_size_callable := Callable()
var _event_screen_position_callable := Callable()
var _pointer_over_overlay_callable := Callable()
var _focus_callable := Callable()

func configure(
	next_joystick: Variant,
	screen_size_callable: Callable,
	event_screen_position_callable: Callable,
	pointer_over_overlay_callable: Callable,
	focus_callable: Callable
) -> void:
	joystick = next_joystick
	_screen_size_callable = screen_size_callable
	_event_screen_position_callable = event_screen_position_callable
	_pointer_over_overlay_callable = pointer_over_overlay_callable
	_focus_callable = focus_callable
	reset_keyboard_state()

func ensure_input_actions() -> void:
	for action_name: String in KEYBOARD_ACTION_KEYS.keys():
		_ensure_key_action(action_name, KEYBOARD_ACTION_KEYS[action_name])

func reset_runtime_input() -> void:
	reset_keyboard_state()
	if joystick != null and joystick.has_method("end_free"):
		joystick.end_free(-999)
	free_pointer_active = false
	free_pointer_index = -999

func reset_keyboard_state() -> void:
	_keyboard_action_down.clear()
	for action_name: String in KEYBOARD_ACTION_KEYS.keys():
		_keyboard_action_down[action_name] = false

func handle_input(event: InputEvent, already_screen_position: bool) -> bool:
	if event is InputEventKey:
		return _handle_keyboard_event(event as InputEventKey)
	return handle_pointer_event(event, already_screen_position)

func handle_pointer_event(event: InputEvent, already_screen_position: bool) -> bool:
	if joystick == null:
		return false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		var touch_position := _event_screen_position(touch.position, already_screen_position)
		if touch.pressed:
			if free_pointer_active or _pointer_over_overlay(touch_position):
				return false
			_begin_free_joystick(touch_position, touch.index)
			return true
		if free_pointer_active and free_pointer_index == touch.index:
			_end_free_joystick(touch.index)
			return true
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if free_pointer_active and free_pointer_index == drag.index:
			_drag_free_joystick(_event_screen_position(drag.position, already_screen_position), drag.index)
			return true
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return false
		var mouse_position := _event_screen_position(mouse.position, already_screen_position)
		if mouse.pressed:
			if free_pointer_active or _pointer_over_overlay(mouse_position):
				return false
			_begin_free_joystick(mouse_position, -2)
			return true
		if free_pointer_active and free_pointer_index == -2:
			_end_free_joystick(-2)
			return true
	elif event is InputEventMouseMotion and free_pointer_active and free_pointer_index == -2:
		_drag_free_joystick(_event_screen_position((event as InputEventMouseMotion).position, already_screen_position), -2)
		return true
	return false

func movement_vector() -> Vector2:
	var movement := _keyboard_vector() + debug_vector
	if joystick != null and joystick.has_method("input_vector"):
		movement += joystick.input_vector()
	return movement.limit_length(1.0)

func joystick_vector() -> Vector2:
	if joystick == null or not joystick.has_method("input_vector"):
		return Vector2.ZERO
	return joystick.input_vector()

func set_debug_vector(vector: Vector2) -> void:
	debug_vector = vector.limit_length(1.0)

func begin_free_for_tests(screen_position: Vector2) -> void:
	_begin_free_joystick(screen_position, -2)

func drag_free_for_tests(screen_position: Vector2) -> void:
	_drag_free_joystick(screen_position, -2)

func end_free_for_tests() -> void:
	_end_free_joystick(-2)

func _begin_free_joystick(screen_position: Vector2, pointer_index: int) -> void:
	if joystick == null:
		return
	if _focus_callable.is_valid():
		_focus_callable.call()
	free_pointer_active = true
	free_pointer_index = pointer_index
	joystick.begin_free(_clamp_joystick_screen_position(screen_position), pointer_index)

func _drag_free_joystick(screen_position: Vector2, pointer_index: int) -> void:
	if not free_pointer_active or free_pointer_index != pointer_index:
		return
	joystick.drag_free(screen_position, pointer_index)

func _end_free_joystick(pointer_index: int) -> void:
	if not free_pointer_active or free_pointer_index != pointer_index:
		return
	joystick.end_free(pointer_index)
	free_pointer_active = false
	free_pointer_index = -999

func _keyboard_vector() -> Vector2:
	return Vector2(
		_action_strength("openworld_move_right") - _action_strength("openworld_move_left"),
		_action_strength("openworld_move_down") - _action_strength("openworld_move_up")
	).limit_length(1.0)

func _action_strength(action_name: String) -> float:
	var input_strength := Input.get_action_strength(action_name)
	var manual_strength := 1.0 if bool(_keyboard_action_down.get(action_name, false)) else 0.0
	return maxf(input_strength, manual_strength)

func _handle_keyboard_event(event: InputEventKey) -> bool:
	if event.echo:
		return false
	var action_name := _keyboard_action_for_event(event)
	if action_name == "":
		return false
	_keyboard_action_down[action_name] = event.pressed
	return true

func _keyboard_action_for_event(event: InputEventKey) -> String:
	for action_name: String in KEYBOARD_ACTION_KEYS.keys():
		for keycode: int in KEYBOARD_ACTION_KEYS[action_name]:
			if _key_event_has_key(event, keycode):
				return action_name
	return ""

func _key_event_has_key(event: InputEventKey, keycode: int) -> bool:
	return event.keycode == keycode or event.physical_keycode == keycode or event.key_label == keycode

func _ensure_key_action(action_name: String, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.5)
	for keycode: int in keycodes:
		if not _input_action_has_key(action_name, keycode, true):
			var physical_event := InputEventKey.new()
			physical_event.physical_keycode = keycode
			InputMap.action_add_event(action_name, physical_event)
		if not _input_action_has_key(action_name, keycode, false):
			var key_event := InputEventKey.new()
			key_event.keycode = keycode
			InputMap.action_add_event(action_name, key_event)

func _input_action_has_key(action_name: String, keycode: int, physical: bool) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if not event is InputEventKey:
			continue
		var key_event := event as InputEventKey
		if physical and key_event.physical_keycode == keycode:
			return true
		if not physical and key_event.keycode == keycode:
			return true
	return false

func _event_screen_position(event_position: Vector2, already_screen_position: bool) -> Vector2:
	if already_screen_position or not _event_screen_position_callable.is_valid():
		return event_position
	return _event_screen_position_callable.call(event_position)

func _pointer_over_overlay(screen_position: Vector2) -> bool:
	if not _pointer_over_overlay_callable.is_valid():
		return false
	return bool(_pointer_over_overlay_callable.call(screen_position))

func _clamp_joystick_screen_position(screen_position: Vector2) -> Vector2:
	var half_size := JoystickScript.BASE_SIZE * 0.5
	var screen_size: Vector2 = _screen_size_callable.call() if _screen_size_callable.is_valid() else Vector2(390, 844)
	return Vector2(
		clampf(screen_position.x, half_size.x, maxf(half_size.x, screen_size.x - half_size.x)),
		clampf(screen_position.y, half_size.y, maxf(half_size.y, screen_size.y - half_size.y))
	)
