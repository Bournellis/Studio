extends Control

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_menu()

func _build_menu() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = Color(0.06, 0.07, 0.08)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root: CenterContainer = CenterContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var panel: PanelContainer = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 340)
	panel.add_theme_stylebox_override("panel", _panel_style())
	root.add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "RPG Turnos"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	box.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Slice jogavel inicial"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	var new_game: Button = Button.new()
	new_game.text = "Novo jogo"
	new_game.custom_minimum_size = Vector2(220, 44)
	new_game.pressed.connect(_on_new_game_pressed)
	box.add_child(new_game)

	var quit: Button = Button.new()
	quit.text = "Sair"
	quit.custom_minimum_size = Vector2(220, 44)
	quit.pressed.connect(func() -> void: get_tree().quit())
	box.add_child(quit)

func _on_new_game_pressed() -> void:
	GameSession.start_new_game()
	get_tree().change_scene_to_file("res://modes/world/world.tscn")

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.14)
	style.border_color = Color(0.28, 0.34, 0.38)
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
