extends Control

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.045, 0.05, 0.055)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 320)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)

	var title: Label = Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.text = "Vitoria" if GameSession.last_battle_result == "victory" else "Derrota"
	box.add_child(title)

	var summary: Label = Label.new()
	summary.text = GameSession.last_battle_summary
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(summary)

	if GameSession.last_battle_result == "victory":
		var back: Button = Button.new()
		back.text = "Voltar ao mapa"
		back.custom_minimum_size = Vector2(220, 44)
		back.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://modes/world/world.tscn"))
		box.add_child(back)
	else:
		var retry: Button = Button.new()
		retry.text = "Tentar novamente"
		retry.custom_minimum_size = Vector2(220, 44)
		retry.pressed.connect(_retry)
		box.add_child(retry)

func _retry() -> void:
	GameSession.restore_pre_combat_snapshot()
	get_tree().change_scene_to_file("res://modes/battle/deck_setup.tscn")

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.1, 0.12)
	style.border_color = Color(0.32, 0.36, 0.38)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 28
	style.content_margin_top = 28
	style.content_margin_right = 28
	style.content_margin_bottom = 28
	return style
