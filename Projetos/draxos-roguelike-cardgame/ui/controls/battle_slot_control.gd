class_name BattleSlotControl
extends PanelContainer

const BattleCardVisualsScript = preload("res://ui/controls/battle_card_visuals.gd")

signal card_dropped(data: Dictionary, owner: String, slot_index: int)

var slot_owner: String = "player"
var slot_index: int = -1
var occupant: Variant = null
var visual_state: Dictionary = {}
var card_size: Vector2 = Vector2(112, 158)

func setup(new_owner: String, new_slot_index: int, new_occupant: Variant, new_visual_state: Dictionary = {}) -> void:
	slot_owner = new_owner
	slot_index = new_slot_index
	occupant = new_occupant
	visual_state = new_visual_state
	card_size = visual_state.get("card_size", Vector2(112, 158))
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = card_size
	size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	size_flags_vertical = Control.SIZE_SHRINK_CENTER
	clip_contents = true
	add_theme_stylebox_override("panel", _panel_style())

	var content: Control = Control.new()
	content.name = "FieldSlotContent"
	content.custom_minimum_size = card_size
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(content)

	if occupant == null:
		_build_empty_socket(content)
	else:
		_build_field_card(content, Dictionary(occupant))

func _build_empty_socket(parent: Control) -> void:
	var center: VBoxContainer = VBoxContainer.new()
	center.name = "FieldEmptySocket"
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 4)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)

	var slot_label: Label = Label.new()
	slot_label.name = "FieldSlotLabel"
	slot_label.text = _short_slot_label()
	slot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot_label.add_theme_font_size_override("font_size", 11)
	slot_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.88, 0.74))
	center.add_child(slot_label)

	var chip: Label = Label.new()
	chip.name = "FieldSlotState"
	chip.text = _chip_text()
	chip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	chip.clip_text = true
	chip.max_lines_visible = 1
	chip.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	chip.add_theme_font_size_override("font_size", 9)
	chip.add_theme_color_override("font_color", _chip_color())
	center.add_child(chip)

func _build_field_card(parent: Control, data: Dictionary) -> void:
	var card_id: String = str(data.get("card_id", ""))
	var card = ContentLibrary.get_card(card_id)
	var is_objective: bool = bool(data.get("objective", false))
	var display_name: String = str(data.get("name", "Objetivo" if is_objective else "Carta"))
	var fallback_label: String = "Objetivo" if is_objective or card_id == "" else ""

	var art_area: Control = BattleCardVisualsScript.build_art_area(card_id, 0, fallback_label)
	art_area.name = "FieldCardArtArea"
	art_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(art_area)

	var shade: ColorRect = ColorRect.new()
	shade.name = "FieldCardShade"
	shade.color = Color(0.0, 0.0, 0.0, 0.20)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(shade)

	var title_bar: ColorRect = ColorRect.new()
	title_bar.name = "FieldCardTitleBar"
	title_bar.color = Color(0.025, 0.028, 0.032, 0.72)
	title_bar.anchor_left = 0.0
	title_bar.anchor_top = 0.0
	title_bar.anchor_right = 1.0
	title_bar.anchor_bottom = 0.0
	title_bar.offset_left = 0.0
	title_bar.offset_top = 0.0
	title_bar.offset_right = 0.0
	title_bar.offset_bottom = 24.0 if _is_compact_card() else 28.0
	parent.add_child(title_bar)

	var title: Label = Label.new()
	title.name = "FieldCardTitle"
	title.text = display_name
	title.clip_text = true
	title.max_lines_visible = 1
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 8 if _is_compact_card() else 10)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title.anchor_left = 0.0
	title.anchor_top = 0.0
	title.anchor_right = 1.0
	title.anchor_bottom = 0.0
	title.offset_left = 6.0
	title.offset_top = 4.0
	title.offset_right = -28.0 if _is_compact_card() else -34.0
	title.offset_bottom = 21.0 if _is_compact_card() else 24.0
	parent.add_child(title)

	if card != null:
		var cost_badge: PanelContainer = BattleCardVisualsScript.build_floating_badge("FieldCardCost", str(int(card.cost)), UiTokens.color("energy"), _small_badge_size(), 11 if _is_compact_card() else 13)
		_anchor_badge(cost_badge, 1.0, 0.0, Vector2(-27, 3) if _is_compact_card() else Vector2(-31, 4), Vector2(-3, 25) if _is_compact_card() else Vector2(-4, 28))
		parent.add_child(cost_badge)

	var state_label: Label = Label.new()
	state_label.name = "FieldCardState"
	state_label.text = _occupant_state_text(data)
	state_label.clip_text = true
	state_label.max_lines_visible = 1
	state_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.add_theme_font_size_override("font_size", 8 if _is_compact_card() else 9)
	state_label.add_theme_color_override("font_color", Color(0.82, 0.88, 0.94, 0.82))
	state_label.anchor_left = 0.0
	state_label.anchor_top = 1.0
	state_label.anchor_right = 1.0
	state_label.anchor_bottom = 1.0
	state_label.offset_left = 24.0 if _is_compact_card() else 30.0
	state_label.offset_top = -24.0 if _is_compact_card() else -26.0
	state_label.offset_right = -24.0 if _is_compact_card() else -30.0
	state_label.offset_bottom = -6.0
	parent.add_child(state_label)

	var attack_badge: PanelContainer = BattleCardVisualsScript.build_floating_badge("FieldCardAttack", str(int(data.get("attack", 0))), Color(0.95, 0.58, 0.30), _stat_badge_size(), 13 if _is_compact_card() else 15)
	_anchor_badge(attack_badge, 0.0, 1.0, Vector2(4, -28) if _is_compact_card() else Vector2(5, -31), Vector2(31, -4) if _is_compact_card() else Vector2(35, -5))
	parent.add_child(attack_badge)

	var health_badge: PanelContainer = BattleCardVisualsScript.build_floating_badge("FieldCardHealth", str(int(data.get("health", 0))), Color(0.40, 0.86, 0.58), _stat_badge_size(), 13 if _is_compact_card() else 15)
	_anchor_badge(health_badge, 1.0, 1.0, Vector2(-31, -28) if _is_compact_card() else Vector2(-35, -31), Vector2(-4, -4) if _is_compact_card() else Vector2(-5, -5))
	parent.add_child(health_badge)

	if is_objective or card_id == "":
		var objective_label: Label = Label.new()
		objective_label.name = "FieldObjectiveLabel"
		objective_label.text = "OBJ"
		objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		objective_label.add_theme_font_size_override("font_size", 9)
		objective_label.add_theme_color_override("font_color", Color(0.98, 0.82, 0.45))
		objective_label.anchor_left = 0.0
		objective_label.anchor_top = 0.0
		objective_label.anchor_right = 0.0
		objective_label.anchor_bottom = 0.0
		objective_label.offset_left = 5.0
		objective_label.offset_top = 5.0
		objective_label.offset_right = 32.0
		objective_label.offset_bottom = 23.0
		parent.add_child(objective_label)
	else:
		BattleCardVisualsScript.add_frame_overlay(parent, card_id, "FieldCardFrameOverlay")

func _anchor_badge(badge: Control, anchor_x: float, anchor_y: float, top_left: Vector2, bottom_right: Vector2) -> void:
	badge.anchor_left = anchor_x
	badge.anchor_top = anchor_y
	badge.anchor_right = anchor_x
	badge.anchor_bottom = anchor_y
	badge.offset_left = top_left.x
	badge.offset_top = top_left.y
	badge.offset_right = bottom_right.x
	badge.offset_bottom = bottom_right.y

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	var payload: Dictionary = Dictionary(data)
	match str(payload.get("kind", "")):
		"battle_card":
			return Array(visual_state.get("accepted_card_indices", [])).has(int(payload.get("hand_index", -1)))
		"class_active":
			return Array(visual_state.get("accepted_class_choices", [])).has(str(payload.get("choice_id", "")))
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	card_dropped.emit(Dictionary(data), slot_owner, slot_index)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = _slot_fill()
	style.border_color = _slot_border()
	var border_width: int = 3 if _is_emphasized() else 2
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	return style

func _chip_text() -> String:
	if bool(visual_state.get("is_attack_source", false)):
		return "Ataque"
	if bool(visual_state.get("is_attack_target", false)):
		return "Alvo"
	if bool(visual_state.get("is_drop_target", false)):
		return "Solte aqui"
	return "Livre"

func _chip_color() -> Color:
	if bool(visual_state.get("is_attack_source", false)):
		return Color(1.0, 0.82, 0.32)
	if bool(visual_state.get("is_attack_target", false)):
		return Color(0.95, 0.55, 0.42)
	if bool(visual_state.get("is_drop_target", false)):
		return Color(0.9, 0.78, 0.42)
	return Color(0.7, 0.78, 0.82)

func _slot_fill() -> Color:
	if bool(visual_state.get("is_attack_source", false)):
		return Color(0.18, 0.17, 0.09, 0.82)
	if bool(visual_state.get("is_attack_target", false)):
		return Color(0.2, 0.1, 0.09, 0.82)
	if bool(visual_state.get("is_drop_target", false)):
		return Color(0.16, 0.14, 0.08, 0.82)
	if bool(visual_state.get("is_empty", false)):
		return Color(0.035, 0.045, 0.048, 0.46) if slot_owner == "jogador" else Color(0.055, 0.038, 0.043, 0.50)
	return Color(0.055, 0.065, 0.07, 0.78) if slot_owner == "jogador" else Color(0.085, 0.055, 0.06, 0.82)

func _slot_border() -> Color:
	if bool(visual_state.get("is_attack_source", false)):
		return Color(0.95, 0.72, 0.26)
	if bool(visual_state.get("is_attack_target", false)):
		return Color(0.95, 0.44, 0.34)
	if bool(visual_state.get("is_drop_target", false)):
		return Color(0.9, 0.68, 0.3)
	return Color(0.32, 0.5, 0.48, 0.78) if slot_owner == "jogador" else Color(0.56, 0.32, 0.34, 0.82)

func _is_emphasized() -> bool:
	return bool(visual_state.get("is_attack_source", false)) or bool(visual_state.get("is_attack_target", false)) or bool(visual_state.get("is_drop_target", false))

func _is_compact_card() -> bool:
	return card_size.x < 90.0

func _small_badge_size() -> Vector2:
	return Vector2(24, 22) if _is_compact_card() else Vector2(27, 24)

func _stat_badge_size() -> Vector2:
	return Vector2(27, 24) if _is_compact_card() else Vector2(30, 26)

func _short_slot_label() -> String:
	return "J%d" % (slot_index + 1) if slot_owner == "jogador" else "I%d" % (slot_index + 1)

func _occupant_state_text(data: Dictionary) -> String:
	if bool(data.get("objective", false)):
		return "Defender"
	if int(data.get("slow_turns", 0)) > 0:
		return "Lento"
	if int(data.get("confusion_turns", 0)) > 0:
		return "Confuso"
	if bool(data.get("ready", false)):
		return "Pronta"
	return "Preparando"
