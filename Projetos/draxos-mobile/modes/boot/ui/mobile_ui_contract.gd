class_name DraxosMobileUiContract
extends RefCounted

const MIN_TOUCH_TARGET := 56.0
const CTA_TOUCH_TARGET := 60.0
const TOUCH_SCROLLBAR_WIDTH := 18.0
const IMMERSIVE_SCROLLBAR_WIDTH := 8.0
const TOUCH_DRAG_THRESHOLD := 12.0
const COMPACT_WIDTH_BREAKPOINT := 760.0
const LANDSCAPE_COLUMN_RATIO := 1.08
const WIDE_LANDSCAPE_WIDTH := 1180.0
const PORTRAIT_FRAME_WIDTH := 432.0
const SHELL_MARGIN_COMPACT := 10.0
const SHELL_MARGIN_REGULAR := 18.0
const PANEL_GAP_COMPACT := 8.0
const PANEL_GAP_REGULAR := 12.0
const PANEL_RADIUS := 8

static func button_min_size(compact: bool) -> Vector2:
	var min_size := Vector2(0, MIN_TOUCH_TARGET if compact else 58)
	min_size.y = maxf(min_size.y, MIN_TOUCH_TARGET)
	return min_size

static func cta_min_size(compact: bool) -> Vector2:
	var min_size := button_min_size(compact)
	min_size.y = maxf(min_size.y, CTA_TOUCH_TARGET)
	return min_size

static func input_min_size(compact: bool) -> Vector2:
	var min_size := Vector2(0, MIN_TOUCH_TARGET if compact else 52)
	min_size.y = maxf(min_size.y, MIN_TOUCH_TARGET)
	return min_size

static func apply_touch_button(button: Button, mouse_filter: int = Control.MOUSE_FILTER_PASS) -> void:
	if button == null:
		return
	button.mouse_filter = mouse_filter as Control.MouseFilter
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, MIN_TOUCH_TARGET)

static func apply_cta_button(button: Button, mouse_filter: int = Control.MOUSE_FILTER_PASS) -> void:
	apply_touch_button(button, mouse_filter)
	if button == null:
		return
	button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, CTA_TOUCH_TARGET)

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

static func shell_margin(compact: bool) -> float:
	return SHELL_MARGIN_COMPACT if compact else SHELL_MARGIN_REGULAR

static func panel_gap(compact: bool) -> int:
	return int(PANEL_GAP_COMPACT if compact else PANEL_GAP_REGULAR)

static func panel_padding(compact: bool) -> int:
	return 12 if compact else 16

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
		"touch_target": MIN_TOUCH_TARGET,
		"cta_touch_target": CTA_TOUCH_TARGET,
		"panel_radius": PANEL_RADIUS,
	}
