class_name BattleCardVisuals
extends RefCounted

static func build_art_area(card_id: String, min_height: int, fallback_label_override: String = "") -> Control:
	var art_area: Control = Control.new()
	art_area.name = "BattleCardArtArea"
	art_area.custom_minimum_size = Vector2(0, min_height)
	art_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	art_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	art_area.clip_contents = true

	var fallback: ColorRect = ColorRect.new()
	fallback.name = "BattleCardArtFallback"
	var fallback_color: Color = VisualAssets.card_frame_color(card_id)
	fallback.color = Color(fallback_color.r, fallback_color.g, fallback_color.b, 0.34)
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_area.add_child(fallback)

	var art_rect: TextureRect = TextureRect.new()
	art_rect.name = "BattleCardArt"
	art_rect.texture = VisualAssets.card_art_texture(card_id)
	art_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_area.add_child(art_rect)

	if art_rect.texture == null:
		var label: Label = Label.new()
		label.name = "BattleCardArtFallbackLabel"
		label.text = fallback_label_override if fallback_label_override != "" else str(VisualAssets.frame_entry(VisualAssets.card_frame_id(card_id)).get("fallback_label", "Arte"))
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", Color(0.88, 0.9, 0.86, 0.72))
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		art_area.add_child(label)

	return art_area

static func build_plain_stat_label(label_name: String, text: String, color: Color, font_size: int = 10) -> Label:
	var badge: Label = Label.new()
	badge.name = label_name
	badge.text = text
	badge.clip_text = true
	badge.max_lines_visible = 1
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", font_size)
	badge.add_theme_color_override("font_color", color)
	return badge

static func build_floating_badge(label_name: String, text: String, accent: Color, min_size: Vector2 = Vector2(28, 24), font_size: int = 14) -> PanelContainer:
	var badge_panel: PanelContainer = PanelContainer.new()
	badge_panel.name = "%sBadge" % label_name
	badge_panel.custom_minimum_size = min_size
	badge_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge_panel.add_theme_stylebox_override("panel", _badge_style(accent))

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 5)
	margin.add_theme_constant_override("margin_top", 2)
	margin.add_theme_constant_override("margin_right", 5)
	margin.add_theme_constant_override("margin_bottom", 2)
	badge_panel.add_child(margin)

	var label: Label = Label.new()
	label.name = label_name
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.max_lines_visible = 1
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.98, 0.96, 0.88))
	margin.add_child(label)
	return badge_panel

static func add_frame_overlay(parent: Control, card_id: String, node_name: String) -> void:
	var frame_texture: Texture2D = VisualAssets.card_frame_overlay_texture(card_id)
	if frame_texture == null:
		return
	var frame_rect: TextureRect = TextureRect.new()
	frame_rect.name = node_name
	frame_rect.texture = frame_texture
	frame_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame_rect.stretch_mode = TextureRect.STRETCH_SCALE
	frame_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(frame_rect)

static func _badge_style(accent: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.028, 0.032, 0.88)
	style.border_color = Color(accent.r, accent.g, accent.b, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	return style
