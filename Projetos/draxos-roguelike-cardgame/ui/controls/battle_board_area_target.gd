class_name BattleBoardAreaTarget
extends PanelContainer

signal target_dropped(data: Dictionary, target: Dictionary)

var target: Dictionary = {}
var visual_state: Dictionary = {}

func setup(title: String, detail: String, new_target: Dictionary, new_visual_state: Dictionary = {}) -> void:
	target = new_target.duplicate()
	visual_state = new_visual_state.duplicate(true)
	for child: Node in get_children():
		remove_child(child)
		child.free()
	var compact: bool = bool(visual_state.get("compact", true))
	var board_table: bool = bool(visual_state.get("board_table", false))
	custom_minimum_size = Vector2(220, 128) if board_table else Vector2(0, 28 if compact else 34)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _panel_style())

	if board_table:
		_build_board_table_label(title)
		return

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 0)
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(box)

	var label: Label = Label.new()
	label.name = "BattleBoardAreaTargetLabel"
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 11 if compact else 12)
	label.add_theme_color_override("font_color", Color(0.92, 0.94, 0.86, 0.95))
	box.add_child(label)

	if compact:
		return
	var hint: Label = Label.new()
	hint.name = "BattleBoardAreaTargetHint"
	hint.text = detail
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 9)
	hint.add_theme_color_override("font_color", Color(0.72, 0.82, 0.88, 0.78))
	box.add_child(hint)

func _build_board_table_label(title: String) -> void:
	var label: Label = Label.new()
	label.name = "BattleBoardAreaTargetLabel"
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.86, 0.94, 0.98, 0.72))
	label.anchor_left = 0.0
	label.anchor_top = 0.0
	label.anchor_right = 1.0
	label.anchor_bottom = 0.0
	label.offset_left = 10.0
	label.offset_top = 7.0
	label.offset_right = -10.0
	label.offset_bottom = 25.0
	add_child(label)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	var payload: Dictionary = Dictionary(data)
	return str(payload.get("kind", "")) == "battle_card" and Array(visual_state.get("accepted_card_indices", [])).has(int(payload.get("hand_index", -1)))

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	target_dropped.emit(Dictionary(data), target.duplicate())

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var active: bool = not Array(visual_state.get("accepted_card_indices", [])).is_empty()
	var board_table: bool = bool(visual_state.get("board_table", false))
	if board_table:
		style.bg_color = Color(0.035, 0.095, 0.105, 0.62 if active else 0.36)
		style.border_color = Color(0.48, 0.86, 0.95, 0.88 if active else 0.42)
		style.set_border_width_all(2 if active else 1)
		style.set_corner_radius_all(10)
		style.content_margin_left = 10
		style.content_margin_top = 8
		style.content_margin_right = 10
		style.content_margin_bottom = 8
		return style
	style.bg_color = Color(0.05, 0.07, 0.08, 0.78 if active else 0.42)
	style.border_color = Color(0.54, 0.82, 0.92, 0.92 if active else 0.45)
	style.set_border_width_all(2 if active else 1)
	style.set_corner_radius_all(7)
	style.content_margin_left = 8
	style.content_margin_top = 3
	style.content_margin_right = 8
	style.content_margin_bottom = 3
	return style
