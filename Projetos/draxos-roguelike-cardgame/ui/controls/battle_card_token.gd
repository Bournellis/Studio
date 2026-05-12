class_name BattleCardToken
extends PanelContainer

var card_id: String = ""
var hand_index: int = -1
var card
var type_stripe: ColorRect
var art_rect: TextureRect
var keyword_chips: HBoxContainer
var drag_enabled: bool = true
var selected: bool = false

func setup(new_card_id: String, new_hand_index: int, enabled: bool = true, is_selected: bool = false) -> void:
	card_id = new_card_id
	hand_index = new_hand_index
	card = ContentLibrary.get_card(card_id)
	drag_enabled = enabled
	selected = is_selected
	_rebuild()

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	add_theme_stylebox_override("panel", _panel_style())

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = Vector2(126, 188)
	clip_contents = true
	add_theme_stylebox_override("panel", _panel_style())

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 3)
	add_child(box)

	var header: HBoxContainer = HBoxContainer.new()
	header.name = "BattleCardHeader"
	header.add_theme_constant_override("separation", 4)
	box.add_child(header)

	var title: Label = Label.new()
	title.name = "BattleCardTitle"
	title.text = card.display_name if card != null else card_id
	title.clip_text = true
	title.max_lines_visible = 1
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 11)
	header.add_child(title)

	var cost_badge: Label = _stat_badge("C%d" % (card.cost if card != null else 0), UiTokens.color("energy", Color(0.9, 0.7, 0.32)))
	cost_badge.name = "BattleCardCost"
	header.add_child(cost_badge)

	box.add_child(_build_art_area())

	keyword_chips = _build_keyword_chips()
	box.add_child(keyword_chips)

	var text_label: Label = Label.new()
	text_label.name = "BattleCardRulesText"
	text_label.text = VisualAssets.card_display_text(card) if card != null else ""
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.clip_text = true
	text_label.max_lines_visible = 2
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.add_theme_font_size_override("font_size", 8)
	box.add_child(text_label)

	var footer: HBoxContainer = HBoxContainer.new()
	footer.name = "BattleCardStats"
	footer.add_theme_constant_override("separation", 4)
	box.add_child(footer)

	if card != null and card.occupies_slot():
		var attack_badge: Label = _stat_badge("ATK %d" % card.attack, Color(0.95, 0.68, 0.38))
		attack_badge.name = "BattleCardAttack"
		footer.add_child(attack_badge)
		var footer_spacer: Control = Control.new()
		footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(footer_spacer)
		var health_badge: Label = _stat_badge("HP %d" % card.health, Color(0.52, 0.86, 0.66))
		health_badge.name = "BattleCardHealth"
		footer.add_child(health_badge)
	else:
		var type_label: Label = _stat_badge(UiTokens.type_display_name(card.card_type) if card != null else "Carta", _type_color())
		type_label.name = "BattleCardType"
		type_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(type_label)

	var frame_texture: Texture2D = VisualAssets.card_frame_overlay_texture(card_id)
	if frame_texture != null:
		var frame_rect: TextureRect = TextureRect.new()
		frame_rect.name = "BattleCardFrameOverlay"
		frame_rect.texture = frame_texture
		frame_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_rect.stretch_mode = TextureRect.STRETCH_SCALE
		frame_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(frame_rect)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if card_id == "" or not drag_enabled:
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
	style.bg_color = Color(0.055, 0.065, 0.075, 0.88) if drag_enabled else Color(0.045, 0.048, 0.052, 0.82)
	style.border_color = Color(0.95, 0.72, 0.26) if selected else VisualAssets.card_frame_color(card_id)
	var border_width: int = 3 if selected else 2
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 6
	style.content_margin_top = 6
	style.content_margin_right = 6
	style.content_margin_bottom = 6
	return style

func _build_art_area() -> Control:
	var art_area: Control = Control.new()
	art_area.name = "BattleCardArtArea"
	art_area.custom_minimum_size = Vector2(0, 70)
	art_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_area.clip_contents = true

	var fallback: ColorRect = ColorRect.new()
	fallback.name = "BattleCardArtFallback"
	var fallback_color: Color = VisualAssets.card_frame_color(card_id)
	fallback.color = Color(fallback_color.r, fallback_color.g, fallback_color.b, 0.34)
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_area.add_child(fallback)

	art_rect = TextureRect.new()
	art_rect.name = "BattleCardArt"
	art_rect.texture = VisualAssets.card_art_texture(card_id)
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_area.add_child(art_rect)

	if art_rect.texture == null:
		var label: Label = Label.new()
		label.name = "BattleCardArtFallbackLabel"
		label.text = str(VisualAssets.frame_entry(VisualAssets.card_frame_id(card_id)).get("fallback_label", "Arte"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.88, 0.9, 0.86, 0.72))
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		art_area.add_child(label)

	return art_area

func _stat_badge(text: String, color: Color) -> Label:
	var badge: Label = Label.new()
	badge.text = text
	badge.clip_text = true
	badge.max_lines_visible = 1
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 10)
	badge.add_theme_color_override("font_color", color)
	return badge

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
