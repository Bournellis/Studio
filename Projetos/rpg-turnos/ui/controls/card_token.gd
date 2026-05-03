class_name CardToken
extends PanelContainer

var card_id: String = ""
var source: String = ""
var source_index: int = -1
var card

func setup(new_card_id: String, new_source: String, new_source_index: int) -> void:
	card_id = new_card_id
	source = new_source
	source_index = new_source_index
	card = ContentLibrary.get_card(card_id)
	_rebuild()

func _rebuild() -> void:
	custom_minimum_size = Vector2(148, 118)
	add_theme_stylebox_override("panel", _panel_style(Color(0.14, 0.16, 0.18), Color(0.32, 0.42, 0.52)))

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)

	var title: Label = Label.new()
	title.text = card.display_name if card != null else card_id
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 14)
	box.add_child(title)

	var stats: Label = Label.new()
	if card != null:
		stats.text = "Custo %d" % card.cost
		if card.occupies_slot():
			stats.text += " | %d/%d" % [card.attack, card.health]
	box.add_child(stats)

	var body: Label = Label.new()
	body.text = card.text if card != null else ""
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 11)
	box.add_child(body)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if card_id == "":
		return null
	var preview: Label = Label.new()
	preview.text = card.display_name if card != null else card_id
	preview.add_theme_color_override("font_color", Color.WHITE)
	set_drag_preview(preview)
	return {
		"kind": "card",
		"card_id": card_id,
		"source": source,
		"source_index": source_index
	}

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	return style
