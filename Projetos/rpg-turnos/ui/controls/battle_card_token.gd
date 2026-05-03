class_name BattleCardToken
extends PanelContainer

var card_id: String = ""
var hand_index: int = -1
var card

func setup(new_card_id: String, new_hand_index: int) -> void:
	card_id = new_card_id
	hand_index = new_hand_index
	card = ContentLibrary.get_card(card_id)
	_rebuild()

func _rebuild() -> void:
	custom_minimum_size = Vector2(156, 82)
	clip_contents = true
	add_theme_stylebox_override("panel", _panel_style())
	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	add_child(box)

	var title: Label = Label.new()
	title.text = card.display_name if card != null else card_id
	title.clip_text = true
	title.max_lines_visible = 1
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_size_override("font_size", 14)
	box.add_child(title)

	var stats: Label = Label.new()
	if card != null:
		stats.text = "Custo %d" % card.cost
		if card.occupies_slot():
			stats.text += " | %d/%d" % [card.attack, card.health]
	stats.clip_text = true
	stats.max_lines_visible = 1
	stats.add_theme_font_size_override("font_size", 13)
	box.add_child(stats)

	var text_label: Label = Label.new()
	text_label.text = card.text if card != null else ""
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.clip_text = true
	text_label.max_lines_visible = 2
	text_label.add_theme_font_size_override("font_size", 9)
	box.add_child(text_label)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if card_id == "":
		return null
	var preview: Label = Label.new()
	preview.text = card.display_name if card != null else card_id
	set_drag_preview(preview)
	return {
		"kind": "battle_card",
		"card_id": card_id,
		"hand_index": hand_index
	}

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.15, 0.17)
	style.border_color = Color(0.45, 0.48, 0.5)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 7
	style.content_margin_top = 6
	style.content_margin_right = 7
	style.content_margin_bottom = 6
	return style
