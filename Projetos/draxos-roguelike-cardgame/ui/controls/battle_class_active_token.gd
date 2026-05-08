class_name BattleClassActiveToken
extends PanelContainer

signal choices_requested

var class_id: String = ""
var display_name: String = ""
var detail_text: String = ""
var choice_id: String = ""
var drag_enabled: bool = false
var needs_choice: bool = false

func setup(new_class_id: String, new_display_name: String, new_detail_text: String, new_choice_id: String, enabled: bool, requires_choice: bool) -> void:
	class_id = new_class_id
	display_name = new_display_name
	detail_text = new_detail_text
	choice_id = new_choice_id
	drag_enabled = enabled
	needs_choice = requires_choice
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = Vector2(184, 78)
	clip_contents = true
	add_theme_stylebox_override("panel", _panel_style())

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(box)

	var eyebrow: Label = Label.new()
	eyebrow.text = "SPELL DE CLASSE"
	eyebrow.add_theme_font_size_override("font_size", 9)
	eyebrow.add_theme_color_override("font_color", Color(0.98, 0.78, 0.48))
	box.add_child(eyebrow)

	var title: Label = Label.new()
	title.text = display_name
	title.clip_text = true
	title.max_lines_visible = 1
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_size_override("font_size", 14)
	box.add_child(title)

	var detail: Label = Label.new()
	detail.text = detail_text
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.clip_text = true
	detail.max_lines_visible = 2
	detail.add_theme_font_size_override("font_size", 10)
	detail.add_theme_color_override("font_color", Color(0.82, 0.88, 0.94))
	box.add_child(detail)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and needs_choice and (choice_id == "" or not drag_enabled):
		choices_requested.emit()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not drag_enabled:
		return null
	var preview: Label = Label.new()
	preview.text = display_name
	set_drag_preview(preview)
	return {
		"kind": "class_active",
		"class_id": class_id,
		"choice_id": choice_id
	}

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.11, 0.17) if drag_enabled else Color(0.08, 0.075, 0.09)
	style.border_color = Color(0.72, 0.46, 0.86) if drag_enabled else Color(0.35, 0.32, 0.38)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	return style
