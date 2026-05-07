class_name BattleCardToken
extends PanelContainer

var card_id: String = ""
var hand_index: int = -1
var card
var type_stripe: ColorRect
var art_rect: TextureRect
var keyword_chips: HBoxContainer

func setup(new_card_id: String, new_hand_index: int) -> void:
	card_id = new_card_id
	hand_index = new_hand_index
	card = ContentLibrary.get_card(card_id)
	_rebuild()

func _rebuild() -> void:
	custom_minimum_size = Vector2(156, 82)
	clip_contents = true
	add_theme_stylebox_override("panel", _panel_style())

	var row: HBoxContainer = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	add_child(row)

	type_stripe = ColorRect.new()
	type_stripe.name = "type_stripe"
	type_stripe.custom_minimum_size = Vector2(6, 0)
	type_stripe.size_flags_vertical = Control.SIZE_EXPAND_FILL
	type_stripe.color = _type_color()
	row.add_child(type_stripe)

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	row.add_child(box)

	art_rect = TextureRect.new()
	art_rect.name = "art_rect"
	art_rect.custom_minimum_size = Vector2(0, 20)
	art_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_rect.texture = AssetIds.card_art_texture(card_id)
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_rect.modulate = Color.WHITE if art_rect.texture != null else UiTokens.color("placeholder", Color(0.22, 0.25, 0.28))
	box.add_child(art_rect)

	var title: Label = Label.new()
	title.text = card.display_name if card != null else card_id
	title.clip_text = true
	title.max_lines_visible = 1
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_size_override("font_size", 14)
	box.add_child(title)

	var stats: Label = Label.new()
	if card != null:
		stats.text = "%s | Custo %d" % [UiTokens.type_display_name(card.card_type), card.cost]
		if card.occupies_slot():
			stats.text += " | %d/%d" % [card.attack, card.health]
	stats.clip_text = true
	stats.max_lines_visible = 1
	stats.add_theme_font_size_override("font_size", 13)
	box.add_child(stats)

	keyword_chips = _build_keyword_chips()
	box.add_child(keyword_chips)

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

func _type_color() -> Color:
	if card == null:
		return UiTokens.color("border_default", Color(0.45, 0.48, 0.5))
	return UiTokens.type_color(str(card.card_type))

func _build_keyword_chips() -> HBoxContainer:
	var row: HBoxContainer = HBoxContainer.new()
	row.name = "KeywordChipsComponent"
	row.add_theme_constant_override("separation", 3)
	if card == null:
		return row
	for keyword: String in card.keywords:
		var chip: Label = Label.new()
		chip.text = keyword
		chip.clip_text = true
		chip.max_lines_visible = 1
		chip.add_theme_font_size_override("font_size", 8)
		chip.add_theme_color_override("font_color", UiTokens.color("text_primary"))
		row.add_child(chip)
	return row
