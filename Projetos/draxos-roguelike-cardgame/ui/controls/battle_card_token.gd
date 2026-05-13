class_name BattleCardToken
extends PanelContainer

const BattleCardVisualsScript = preload("res://ui/controls/battle_card_visuals.gd")

var card_id: String = ""
var hand_index: int = -1
var card
var type_stripe: ColorRect
var art_rect: TextureRect
var keyword_chips: HBoxContainer
var drag_enabled: bool = true
var selected: bool = false
var card_size: Vector2 = Vector2(126, 188)

func setup(new_card_id: String, new_hand_index: int, enabled: bool = true, is_selected: bool = false, new_card_size: Vector2 = Vector2(126, 188)) -> void:
	card_id = new_card_id
	hand_index = new_hand_index
	card = ContentLibrary.get_card(card_id)
	drag_enabled = enabled
	selected = is_selected
	card_size = new_card_size
	_rebuild()

func set_selected(is_selected: bool) -> void:
	selected = is_selected
	add_theme_stylebox_override("panel", _panel_style())

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = card_size
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

	var title_badge_guard: Control = Control.new()
	title_badge_guard.custom_minimum_size = Vector2(30, 0)
	header.add_child(title_badge_guard)

	box.add_child(_build_art_area())

	keyword_chips = _build_keyword_chips()
	box.add_child(keyword_chips)

	var text_margin: MarginContainer = MarginContainer.new()
	text_margin.name = "BattleCardRulesTextMargin"
	text_margin.add_theme_constant_override("margin_left", 4 if _is_compact_card() else 6)
	text_margin.add_theme_constant_override("margin_top", 1)
	text_margin.add_theme_constant_override("margin_right", 4 if _is_compact_card() else 6)
	text_margin.add_theme_constant_override("margin_bottom", 1)
	text_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(text_margin)

	var text_label: Label = Label.new()
	text_label.name = "BattleCardRulesText"
	text_label.text = VisualAssets.card_display_text(card) if card != null else ""
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.clip_text = true
	text_label.max_lines_visible = 2
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.add_theme_font_size_override("font_size", 8)
	text_margin.add_child(text_label)

	var footer: HBoxContainer = HBoxContainer.new()
	footer.name = "BattleCardStats"
	footer.add_theme_constant_override("separation", 4)
	box.add_child(footer)

	if card != null:
		var type_label: Label = _stat_badge("BattleCardType", UiTokens.type_display_name(card.card_type) if card != null else "Carta", _type_color())
		type_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.add_child(type_label)

	BattleCardVisualsScript.add_frame_overlay(self, card_id, "BattleCardFrameOverlay")
	_add_floating_badges()
	_make_children_mouse_transparent(self)

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
	style.content_margin_left = 9 if _is_compact_card() else 11
	style.content_margin_top = 7 if _is_compact_card() else 9
	style.content_margin_right = 9 if _is_compact_card() else 11
	style.content_margin_bottom = 7 if _is_compact_card() else 9
	return style

func _build_art_area() -> Control:
	var art_area: Control = BattleCardVisualsScript.build_art_area(card_id, maxi(52, int(card_size.y * 0.37)))
	art_rect = art_area.find_child("BattleCardArt", true, false) as TextureRect
	return art_area

func _stat_badge(label_name: String, text: String, color: Color) -> Label:
	return BattleCardVisualsScript.build_plain_stat_label(label_name, text, color, 10)

func _add_floating_badges() -> void:
	var overlay: Control = Control.new()
	overlay.name = "BattleCardFloatingStats"
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var cost_badge: PanelContainer = BattleCardVisualsScript.build_floating_badge("BattleCardCost", str(int(card.cost if card != null else 0)), UiTokens.color("energy"), _floating_cost_size(), 11 if _is_compact_card() else 13)
	_anchor_badge(cost_badge, 1.0, 0.0, Vector2(-31, 4) if _is_compact_card() else Vector2(-36, 5), Vector2(-4, 29) if _is_compact_card() else Vector2(-6, 33))
	overlay.add_child(cost_badge)

	if card == null or not card.occupies_slot():
		return

	var attack_badge: PanelContainer = BattleCardVisualsScript.build_floating_badge("BattleCardAttack", str(int(card.attack)), Color(0.95, 0.58, 0.30), _floating_stat_size(), 12 if _is_compact_card() else 15)
	_anchor_badge(attack_badge, 0.0, 1.0, Vector2(4, -29) if _is_compact_card() else Vector2(6, -34), Vector2(32, -4) if _is_compact_card() else Vector2(39, -6))
	overlay.add_child(attack_badge)

	var health_badge: PanelContainer = BattleCardVisualsScript.build_floating_badge("BattleCardHealth", str(int(card.health)), Color(0.40, 0.86, 0.58), _floating_stat_size(), 12 if _is_compact_card() else 15)
	_anchor_badge(health_badge, 1.0, 1.0, Vector2(-32, -29) if _is_compact_card() else Vector2(-39, -34), Vector2(-4, -4) if _is_compact_card() else Vector2(-6, -6))
	overlay.add_child(health_badge)

func _anchor_badge(badge: Control, anchor_x: float, anchor_y: float, top_left: Vector2, bottom_right: Vector2) -> void:
	badge.anchor_left = anchor_x
	badge.anchor_top = anchor_y
	badge.anchor_right = anchor_x
	badge.anchor_bottom = anchor_y
	badge.offset_left = top_left.x
	badge.offset_top = top_left.y
	badge.offset_right = bottom_right.x
	badge.offset_bottom = bottom_right.y

func _is_compact_card() -> bool:
	return card_size.x < 110.0

func _floating_cost_size() -> Vector2:
	return Vector2(27, 25) if _is_compact_card() else Vector2(30, 28)

func _floating_stat_size() -> Vector2:
	return Vector2(28, 25) if _is_compact_card() else Vector2(33, 28)

func _make_children_mouse_transparent(root: Node) -> void:
	for child: Node in root.get_children():
		if child is Control:
			var control: Control = child
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_make_children_mouse_transparent(child)

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
