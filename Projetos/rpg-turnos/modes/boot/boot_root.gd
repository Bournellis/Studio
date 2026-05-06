extends Control

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_menu()

func _build_menu() -> void:
	var bg_visual: TextureRect = TextureRect.new()
	bg_visual.name = "bg_visual"
	bg_visual.texture = AssetIds.texture("menu_background")
	bg_visual.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_visual.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_visual.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg_visual)

	var ambiance_layer: ColorRect = ColorRect.new()
	ambiance_layer.name = "ambiance_layer"
	ambiance_layer.color = UiTokens.color("bg_deep", Color(0.06, 0.07, 0.08))
	ambiance_layer.color.a = 0.82 if bg_visual.texture != null else 1.0
	ambiance_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(ambiance_layer)

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

	var logo_container: Control = _build_logo_container()
	box.add_child(logo_container)

	var subtitle: Label = Label.new()
	subtitle.text = "Slice jogavel inicial"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	var new_game: Button = Button.new()
	new_game.text = "Novo jogo"
	new_game.custom_minimum_size = Vector2(220, 44)
	new_game.pressed.connect(_on_new_game_pressed)
	box.add_child(new_game)

	if FileAccess.file_exists(GameSession.DEFAULT_SAVE_PATH):
		var continue_game: Button = Button.new()
		continue_game.text = "Continuar"
		continue_game.custom_minimum_size = Vector2(220, 44)
		continue_game.pressed.connect(_on_continue_pressed)
		box.add_child(continue_game)

	var quit: Button = Button.new()
	quit.text = "Sair"
	quit.custom_minimum_size = Vector2(220, 44)
	quit.pressed.connect(func() -> void: get_tree().quit())
	box.add_child(quit)

func _on_new_game_pressed() -> void:
	GameSession.start_new_game()
	GameSession.save_game()
	get_tree().change_scene_to_file("res://modes/world/world.tscn")

func _on_continue_pressed() -> void:
	GameSession.load_game()
	get_tree().change_scene_to_file("res://modes/world/world.tscn")

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel", Color(0.1, 0.12, 0.14))
	style.border_color = UiTokens.color("border_default", Color(0.28, 0.34, 0.38))
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

func _build_logo_container() -> Control:
	var logo_container: Control = Control.new()
	logo_container.name = "logo_container"
	logo_container.custom_minimum_size = Vector2(300, 74)

	var logo_rect: TextureRect = TextureRect.new()
	logo_rect.name = "logo_rect"
	logo_rect.texture = AssetIds.texture("ui_logo")
	logo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	logo_container.add_child(logo_rect)

	if logo_rect.texture == null:
		var title: Label = Label.new()
		title.name = "logo_placeholder_label"
		title.text = "RPG Turnos"
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", 38)
		title.set_anchors_preset(Control.PRESET_FULL_RECT)
		logo_container.add_child(title)

	return logo_container
