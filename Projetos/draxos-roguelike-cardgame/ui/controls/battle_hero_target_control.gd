class_name BattleHeroTargetControl
extends PanelContainer

signal target_dropped(data: Dictionary, owner: String)

var hero_owner: String = "inimigo"
var display_name: String = "Heroi"
var health: int = 0
var visual_state: Dictionary = {}

func setup(new_owner: String, new_display_name: String, new_health: int, new_visual_state: Dictionary = {}) -> void:
	hero_owner = new_owner
	display_name = new_display_name
	health = new_health
	visual_state = new_visual_state
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = Vector2(150, 54)
	add_theme_stylebox_override("panel", _panel_style())

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	add_child(box)

	var label: Label = Label.new()
	label.text = display_name
	label.clip_text = true
	label.max_lines_visible = 1
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_size_override("font_size", 12)
	box.add_child(label)

	var health_label: Label = Label.new()
	health_label.text = "Vida %d" % health
	health_label.add_theme_font_size_override("font_size", 10)
	health_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.96))
	box.add_child(health_label)

	var chip: Label = Label.new()
	chip.text = "Alvo" if bool(visual_state.get("is_attack_target", false)) else ("Solte aqui" if bool(visual_state.get("is_drop_target", false)) else "Heroi")
	chip.add_theme_font_size_override("font_size", 9)
	chip.add_theme_color_override("font_color", Color(0.95, 0.55, 0.42) if bool(visual_state.get("is_attack_target", false)) else (Color(0.95, 0.72, 0.36) if bool(visual_state.get("is_drop_target", false)) else Color(0.7, 0.78, 0.82)))
	box.add_child(chip)

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
	target_dropped.emit(Dictionary(data), hero_owner)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.1, 0.1) if hero_owner == "inimigo" else Color(0.09, 0.12, 0.16)
	style.border_color = Color(0.95, 0.44, 0.34) if bool(visual_state.get("is_attack_target", false)) else (Color(0.95, 0.62, 0.3) if bool(visual_state.get("is_drop_target", false)) else Color(0.44, 0.36, 0.38))
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
