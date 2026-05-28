class_name DraxosMobileUiContract
extends RefCounted

const MIN_TOUCH_TARGET := 48.0
const TOUCH_SCROLLBAR_WIDTH := 18.0
const IMMERSIVE_SCROLLBAR_WIDTH := 8.0
const TOUCH_DRAG_THRESHOLD := 12.0
const COMPACT_WIDTH_BREAKPOINT := 760.0
const LANDSCAPE_COLUMN_RATIO := 1.08
const WIDE_LANDSCAPE_WIDTH := 1180.0
const PORTRAIT_FRAME_WIDTH := 432.0

static func button_min_size(compact: bool) -> Vector2:
	var min_size := Vector2(0, 50) if compact else Vector2(0, MIN_TOUCH_TARGET)
	min_size.y = maxf(min_size.y, MIN_TOUCH_TARGET)
	return min_size

static func input_min_size(compact: bool) -> Vector2:
	var min_size := Vector2(0, 48) if compact else Vector2(0, 40)
	min_size.y = maxf(min_size.y, MIN_TOUCH_TARGET)
	return min_size

static func apply_touch_button(button: Button, mouse_filter: int = Control.MOUSE_FILTER_PASS) -> void:
	if button == null:
		return
	button.mouse_filter = mouse_filter as Control.MouseFilter
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, MIN_TOUCH_TARGET)

static func apply_touch_scroll_policy(scroll: ScrollContainer) -> void:
	if scroll == null:
		return
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_ALWAYS
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	apply_scrollbar_touch_policy(scroll)

static func apply_scrollbar_touch_policy(scroll: ScrollContainer) -> void:
	if scroll == null:
		return
	var vertical_bar := scroll.get_v_scroll_bar()
	if vertical_bar == null:
		return
	vertical_bar.custom_minimum_size.x = maxf(vertical_bar.custom_minimum_size.x, TOUCH_SCROLLBAR_WIDTH)
	vertical_bar.mouse_filter = Control.MOUSE_FILTER_PASS

static func action_button_columns_for_size(viewport_size: Vector2, compact: bool) -> int:
	if compact:
		return 1
	if viewport_size.x <= PORTRAIT_FRAME_WIDTH + 80.0:
		return 1
	return 2

static func surface_columns_for_size(_viewport_size: Vector2, _max_columns: int = 2) -> int:
	return 1

static func base_map_columns_for_size(viewport_size: Vector2, compact: bool) -> int:
	if compact:
		return 1
	if viewport_size.x <= PORTRAIT_FRAME_WIDTH + 80.0:
		return 1
	return 2

static func layout_summary_for_size(viewport_size: Vector2, compact: bool, max_surface_columns: int = 2) -> Dictionary:
	return {
		"orientation": "portrait",
		"action_button_columns": action_button_columns_for_size(viewport_size, compact),
		"surface_columns": surface_columns_for_size(viewport_size, max_surface_columns),
		"base_map_columns": base_map_columns_for_size(viewport_size, compact),
		"portrait_frame_width": PORTRAIT_FRAME_WIDTH,
	}
