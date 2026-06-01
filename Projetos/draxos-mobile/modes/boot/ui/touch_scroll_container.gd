class_name DraxosTouchScrollContainer
extends ScrollContainer

const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")

@export var drag_threshold := MobileUiContractScript.TOUCH_DRAG_THRESHOLD
@export var scrollbar_width := MobileUiContractScript.TOUCH_SCROLLBAR_WIDTH
@export var always_show_vertical_scrollbar := true

var _pressing := false
var _dragging := false
var _last_position := Vector2.ZERO
var _accumulated_drag := Vector2.ZERO
var _tracking_mouse := false
var _active_touch_index := -1

func _ready() -> void:
	set_process_input(true)
	_apply_configured_scroll_policy()
	call_deferred("_configure_scrollbars")

func configure_subtle_scrollbar() -> void:
	scrollbar_width = MobileUiContractScript.IMMERSIVE_SCROLLBAR_WIDTH
	always_show_vertical_scrollbar = false
	_apply_configured_scroll_policy()
	call_deferred("_configure_scrollbars")

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.pressed:
			_begin_drag_tracking(touch_event.position, false, touch_event.index)
		elif touch_event.index == _active_touch_index:
			_end_drag_tracking()
		return
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			_begin_drag_tracking(mouse_button.position, true)
		elif _tracking_mouse:
			_end_drag_tracking()
		return
	if event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _active_touch_index:
			_apply_drag_delta(drag.relative)
		return
	if event is InputEventMouseMotion and _pressing:
		if _tracking_mouse and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_end_drag_tracking()
			return
		var motion := event as InputEventMouseMotion
		_apply_drag_delta(motion.position - _last_position)
		_last_position = motion.position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if _tracking_mouse and mouse_button.button_index == MOUSE_BUTTON_LEFT and not mouse_button.pressed:
			_end_drag_tracking()
			return
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if _pressing and touch_event.index == _active_touch_index and not touch_event.pressed:
			_end_drag_tracking()

func is_touch_dragging_for_test() -> bool:
	return _dragging

func is_touch_pressing_for_test() -> bool:
	return _pressing

func _begin_drag_tracking(input_position: Vector2, from_mouse := false, touch_index := -1) -> void:
	_pressing = true
	_dragging = false
	_last_position = input_position
	_accumulated_drag = Vector2.ZERO
	_tracking_mouse = from_mouse
	_active_touch_index = -1 if from_mouse else touch_index

func _end_drag_tracking() -> void:
	_pressing = false
	_dragging = false
	_accumulated_drag = Vector2.ZERO
	_tracking_mouse = false
	_active_touch_index = -1

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
	_apply_configured_scroll_policy()

func _apply_configured_scroll_policy() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS if always_show_vertical_scrollbar else ScrollContainer.SCROLL_MODE_AUTO
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	var vertical_bar := get_v_scroll_bar()
	if vertical_bar == null:
		return
	vertical_bar.custom_minimum_size.x = maxf(vertical_bar.custom_minimum_size.x, scrollbar_width)
	vertical_bar.mouse_filter = Control.MOUSE_FILTER_PASS
