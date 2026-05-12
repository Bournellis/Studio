class_name BattleSlotControl
extends PanelContainer

signal card_dropped(data: Dictionary, owner: String, slot_index: int)

var slot_owner: String = "player"
var slot_index: int = -1
var occupant: Variant = null
var visual_state: Dictionary = {}

func setup(new_owner: String, new_slot_index: int, new_occupant: Variant, new_visual_state: Dictionary = {}) -> void:
	slot_owner = new_owner
	slot_index = new_slot_index
	occupant = new_occupant
	visual_state = new_visual_state
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = Vector2(150, 70)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _panel_style())

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 3)
	add_child(box)

	var label: Label = Label.new()
	label.text = str(visual_state.get("label", "%s%d" % ["P" if slot_owner == "player" else "E", slot_index + 1]))
	label.add_theme_font_size_override("font_size", 12)
	box.add_child(label)

	var chip: Label = Label.new()
	chip.text = _chip_text()
	chip.clip_text = true
	chip.max_lines_visible = 1
	chip.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	chip.add_theme_font_size_override("font_size", 9)
	chip.add_theme_color_override("font_color", _chip_color())
	box.add_child(chip)

	if occupant == null:
		var empty: Label = Label.new()
		empty.text = "Livre"
		empty.add_theme_color_override("font_color", Color(0.72, 0.76, 0.78))
		box.add_child(empty)
	else:
		var data: Dictionary = occupant
		var name_label: Label = Label.new()
		name_label.text = str(data.get("name", "Carta"))
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_label.max_lines_visible = 2
		name_label.clip_text = true
		box.add_child(name_label)

		var stats: Label = Label.new()
		var state_text: String = "Pronta"
		if bool(data.get("summoning_sick", false)):
			state_text = "Enjoo"
		elif bool(data.get("exhausted", false)):
			state_text = "Exausta"
		elif not bool(data.get("ready", false)):
			state_text = "Preparando"
		stats.text = "%d/%d %s" % [
			int(data.get("attack", 0)),
			int(data.get("health", 0)),
			state_text
		]
		box.add_child(stats)

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
	var border_width: int = 3 if bool(visual_state.get("is_attack_source", false)) or bool(visual_state.get("is_attack_target", false)) else 2
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	return style

func _chip_text() -> String:
	if bool(visual_state.get("is_attack_source", false)):
		return "Fonte de ataque"
	if bool(visual_state.get("is_attack_target", false)):
		return "Alvo possivel"
	if bool(visual_state.get("is_drop_target", false)):
		return "Solte aqui"
	return str(visual_state.get("attack_status", "Livre"))

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
		return Color(0.18, 0.17, 0.09)
	if bool(visual_state.get("is_attack_target", false)):
		return Color(0.2, 0.1, 0.09)
	if bool(visual_state.get("is_drop_target", false)):
		return Color(0.16, 0.14, 0.08)
	if bool(visual_state.get("is_empty", false)):
		return Color(0.07, 0.085, 0.09) if slot_owner == "player" else Color(0.1, 0.075, 0.08)
	return Color(0.1, 0.12, 0.13) if slot_owner == "player" else Color(0.15, 0.1, 0.11)

func _slot_border() -> Color:
	if bool(visual_state.get("is_attack_source", false)):
		return Color(0.95, 0.72, 0.26)
	if bool(visual_state.get("is_attack_target", false)):
		return Color(0.95, 0.44, 0.34)
	if bool(visual_state.get("is_drop_target", false)):
		return Color(0.9, 0.68, 0.3)
	return Color(0.32, 0.5, 0.48) if slot_owner == "player" else Color(0.56, 0.32, 0.34)
