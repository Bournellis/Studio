extends Control

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_ui()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.color = UiTokens.color("bg_deep", Color(0.045, 0.05, 0.055))
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(720, 360)
	panel.offset_left = -360
	panel.offset_top = -180
	panel.offset_right = 360
	panel.offset_bottom = 180
	panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	panel.add_child(box)

	var title: Label = Label.new()
	title.text = "Draxos Roguelike Cardgame"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	var status: Label = Label.new()
	status.text = "Bootstrap oficial: hub, mapa de run e combate simplificado ainda pendentes."
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_color_override("font_color", UiTokens.color("text_secondary", Color(0.7, 0.72, 0.74)))
	box.add_child(status)

	var catalog_label: Label = Label.new()
	catalog_label.text = "Catalogo local: %d cartas placeholder, %d encontros iniciais." % [
		ContentLibrary.get_starter_deck_ids().size(),
		ContentLibrary.get_all_encounters().size()
	]
	catalog_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	catalog_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(catalog_label)

	var run_button: Button = Button.new()
	run_button.text = "Criar RunSession Vazia"
	run_button.pressed.connect(func() -> void:
		RunSession.start_empty_run()
		status.text = "RunSession vazia criada. Proximo passo: ShipHub placeholder."
	)
	box.add_child(run_button)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel", Color(0.1, 0.11, 0.12))
	style.border_color = UiTokens.color("border_default", Color(0.25, 0.3, 0.34))
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 28
	style.content_margin_top = 28
	style.content_margin_right = 28
	style.content_margin_bottom = 28
	return style
