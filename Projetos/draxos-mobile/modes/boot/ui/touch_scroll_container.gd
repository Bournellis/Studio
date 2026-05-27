class_name DraxosTouchScrollContainer
extends ScrollContainer

const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")

@export var drag_threshold := MobileUiContractScript.TOUCH_DRAG_THRESHOLD

var _pressing := false
var _dragging := false
var _last_position := Vector2.ZERO
var _accumulated_drag := Vector2.ZERO

func _ready() -> void:
	MobileUiContractScript.apply_touch_scroll_policy(self)
	call_deferred("_configure_scrollbars")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_begin_drag_tracking(touch_event.position)
		else:
			_end_drag_tracking()
		return
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			_begin_drag_tracking(mouse_button.position)
		else:
			_end_drag_tracking()
		return
	if event is InputEventScreenDrag:
		_apply_drag_delta((event as InputEventScreenDrag).relative)
		return
	if event is InputEventMouseMotion and _pressing:
		var motion := event as InputEventMouseMotion
		_apply_drag_delta(motion.position - _last_position)
		_last_position = motion.position

func is_touch_dragging_for_test() -> bool:
	return _dragging

func _begin_drag_tracking(position: Vector2) -> void:
	_pressing = true
	_dragging = false
	_last_position = position
	_accumulated_drag = Vector2.ZERO

func _end_drag_tracking() -> void:
	_pressing = false
	_dragging = false
	_accumulated_drag = Vector2.ZERO

func _apply_drag_delta(delta: Vector2) -> void:
	if not _pressing:
		return
	_accumulated_drag += delta
	if not _dragging and _accumulated_drag.length() < drag_threshold:
		return
	_dragging = true
	var vertical_bar := get_v_scroll_bar()
	if vertical_bar != null:
		vertical_bar.value -= delta.y
	accept_event()

func _configure_scrollbars() -> void:
	MobileUiContractScript.apply_scrollbar_touch_policy(self)
