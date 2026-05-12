extends Control

var _confirmed_class_id: String = ""

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_ui()

func _build_ui() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.color = UiTokens.color("bg_deep", Color(0.06, 0.07, 0.08))
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root: VBoxContainer = VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 32
	root.offset_top = 28
	root.offset_right = -32
	root.offset_bottom = -28
	root.add_theme_constant_override("separation", 20)
	add_child(root)

	var title: Label = Label.new()
	title.text = "Escolha sua Classe"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	root.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Cada classe possui habilidades e deck exclusivos."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.modulate = Color(0.78, 0.82, 0.86)
	root.add_child(subtitle)

	var cards_row: HBoxContainer = HBoxContainer.new()
	cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_row.add_theme_constant_override("separation", 24)
	root.add_child(cards_row)

	var all_classes: Array = ContentLibrary.get_all_classes()
	for class_def: Dictionary in all_classes:
		var card_ui: PanelContainer = _build_class_card(class_def)
		cards_row.add_child(card_ui)

	var back_row: HBoxContainer = HBoxContainer.new()
	back_row.alignment = BoxContainer.ALIGNMENT_CENTER
	back_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(back_row)

	var back_btn: Button = Button.new()
	back_btn.text = "Voltar ao menu"
	back_btn.custom_minimum_size = Vector2(180, 42)
	back_btn.pressed.connect(_on_back_pressed)
	back_row.add_child(back_btn)

func _build_class_card(class_def: Dictionary) -> PanelContainer:
	var class_id: String = str(class_def.get("id", ""))
	var display_name: String = str(class_def.get("display_name", class_id))
	var tagline: String = str(class_def.get("tagline", ""))
	var passiva: Dictionary = Dictionary(class_def.get("passiva", {}))
	var commitment: String = str(passiva.get("text", ""))

	var hero: Dictionary = Dictionary(class_def.get("hero", {}))
	var hero_power: Dictionary = Dictionary(hero.get("hero_power", {}))
	var hero_power_text: String = str(hero_power.get("text", ""))

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(280, 360)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _card_style(false))

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_TOP
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var name_label: Label = Label.new()
	name_label.text = display_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	box.add_child(name_label)

	var divider: HSeparator = HSeparator.new()
	box.add_child(divider)

	var tagline_label: Label = Label.new()
	tagline_label.text = tagline
	tagline_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tagline_label.modulate = Color(0.88, 0.92, 0.96)
	box.add_child(tagline_label)

	if commitment != "":
		var passive_header: Label = Label.new()
		passive_header.text = "Passiva:"
		passive_header.modulate = Color(0.72, 0.82, 0.68)
		passive_header.add_theme_font_size_override("font_size", 13)
		box.add_child(passive_header)

		var passive_label: Label = Label.new()
		passive_label.text = commitment
		passive_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		passive_label.modulate = Color(0.78, 0.88, 0.74)
		passive_label.add_theme_font_size_override("font_size", 13)
		box.add_child(passive_label)

	if hero_power_text != "":
		var hp_header: Label = Label.new()
		hp_header.text = "Poder de heroi:"
		hp_header.modulate = Color(0.82, 0.78, 0.62)
		hp_header.add_theme_font_size_override("font_size", 13)
		box.add_child(hp_header)

		var hp_label: Label = Label.new()
		hp_label.text = hero_power_text
		hp_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		hp_label.modulate = Color(0.94, 0.88, 0.72)
		hp_label.add_theme_font_size_override("font_size", 13)
		box.add_child(hp_label)

	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)

	var select_btn: Button = Button.new()
	select_btn.name = "select_btn_%s" % class_id
	select_btn.text = "Selecionar %s" % display_name
	select_btn.custom_minimum_size = Vector2(0, 42)
	select_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	select_btn.pressed.connect(_on_class_selected.bind(class_id))
	box.add_child(select_btn)

	return panel

func _on_class_selected(class_id: String) -> void:
	if _confirmed_class_id != "":
		return
	_confirmed_class_id = class_id
	var ok: bool = GameSession.select_class(class_id)
	if not ok:
		_confirmed_class_id = ""
		return
	GameSession.initialize_deck_for_class()
	GameSession.save_game()
	get_tree().change_scene_to_file("res://modes/world/world.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://modes/boot/boot.tscn")

func _card_style(selected: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel", Color(0.1, 0.12, 0.14)) if not selected else Color(0.14, 0.18, 0.12)
	style.border_color = Color(0.52, 0.72, 0.48) if selected else UiTokens.color("border_default", Color(0.28, 0.34, 0.38))
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return st