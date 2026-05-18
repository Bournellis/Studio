class_name CardToken
extends PanelContainer

signal card_dropped_on_token(data: Dictionary)

var card_id: String = ""
var source: String = ""
var source_index: int = -1
var card
var compact: bool = false
var art_rect: TextureRect
var keyword_chips: HBoxContainer
var pip_row: HBoxContainer

func setup(new_card_id: String, new_source: String, new_source_index: int, is_compact: bool = false) -> void:
	card_id = new_card_id
	source = new_source
	source_index = new_source_index
	compact = is_compact
	card = ContentLibrary.get_card(card_id)
	_rebuild()

func _rebuild() -> void:
	custom_minimum_size = Vector2(132, 70) if compact else Vector2(148, 118)
	tooltip_text = ContentLibrary.card_tooltip_text(card_id)
	add_theme_stylebox_override("panel", _panel_style(Color(0.14, 0.16, 0.18), Color(0.32, 0.42, 0.52)))

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)

	if not compact:
		art_rect = TextureRect.new()
		art_rect.name = "art_rect"
		art_rect.custom_minimum_size = Vector2(0, 38)
		art_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		art_rect.texture = VisualAssets.card_art_texture(card_id)
		art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art_rect.modulate = Color.WHITE if art_rect.texture != null else UiTokens.color("placeholder", Color(0.22, 0.25, 0.28))
		box.add_child(art_rect)

	var title: Label = Label.new()
	title.text = card.display_name if card != null else card_id
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.add_theme_font_size_override("font_size", 13 if compact else 14)
	box.add_child(title)

	var stats: Label = Label.new()
	if card != null:
		stats.text = UiTokens.type_display_name(card.card_type)
		if card.occupies_slot():
			stats.text += " | %d/%d" % [card.attack, card.health]
	box.add_child(stats)

	pip_row = _build_pip_row(card.cost if card != null else 0)
	box.add_child(pip_row)

	keyword_chips = _build_keyword_chips()
	box.add_child(keyword_chips)

	if not compact:
		var body: Label = Label.new()
		body.text = VisualAssets.card_display_text(card) if card != null else ""
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

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return source == "deck" and typeof(data) == TYPE_DICTIONARY and str(data.get("kind", "")) == "card"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	card_dropped_on_token.emit(Dictionary(data))

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = UiTokens.type_color(card.card_type) if card != null else border
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

func _build_pip_row(cost: int) -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.name = "PipRowComponent"
	row.add_theme_constant_override("separation", 2)
	for index: int in range(max(1, min(cost, 8))):
		var pip: ColorRect = ColorRect.new()
		pip.custom_minimum_size = Vector2(8, 8)
		pip.color = UiTokens.color("energy", Color(0.9, 0.7, 0.32)) if index < cost else UiTokens.color("border_default")
		row.add_child(pip)
	return row

func _build_keyword_chips() -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.name = "KeywordChipsComponent"
	row.add_theme_constant_override("separation", 3)
	if card == null:
		return row
	for keyword: String in card.keywords:
		var chip: Label = Label.new()
		chip.text = ContentLibrary.get_keyword_display_name(keyword)
		chip.tooltip_text = ContentLibrary.keyword_tooltip_text(keyword)
		chip.clip_text = true
		chip.max_lines_visible = 1
		chip.add_theme_font_size_override("font_size", 9)
		chip.add_theme_color_override("font_color", UiTokens.color("text_primary"))
		row.add_child(chip)
	return row
