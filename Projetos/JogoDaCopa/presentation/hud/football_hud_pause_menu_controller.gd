class_name FootballHudPauseMenuController
extends RefCounted

const RenderProfileScript = preload("res://autoloads/render_profile.gd")


static func build_pause_menu(hud: Node, root: Control) -> void:
	var pause_center := CenterContainer.new()
	pause_center.name = "PauseMenuCenter"
	pause_center.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(pause_center)

	hud.pause_menu_panel = PanelContainer.new()
	hud.pause_menu_panel.name = "PauseMenuPanel"
	hud.pause_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	hud.pause_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.pause_menu_panel.custom_minimum_size = Vector2(660.0, 540.0)
	hud.pause_menu_panel.visible = false
	hud.pause_menu_panel.add_theme_stylebox_override("panel", hud._build_panel_style(Color(0.012, 0.03, 0.04, 0.94), Color(0.12, 0.88, 1.0, 0.9), 2))
	pause_center.add_child(hud.pause_menu_panel)

	var margin := MarginContainer.new()
	margin.name = "PauseMenuMargin"
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	hud.pause_menu_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.name = "PauseMenuBox"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := Label.new()
	title.name = "PauseTitle"
	title.text = "Partida pausada"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	hud._ignore_mouse(title)
	box.add_child(title)

	hud.pause_resume_button = Button.new()
	hud.pause_resume_button.name = "ResumeButton"
	hud.pause_resume_button.text = "Continuar"
	hud.pause_resume_button.custom_minimum_size = Vector2(0.0, 42.0)
	hud.pause_resume_button.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.pause_resume_button.pressed.connect(func() -> void:
		hud.resume_requested.emit()
	)
	box.add_child(hud.pause_resume_button)

	hud.pause_restart_button = Button.new()
	hud.pause_restart_button.name = "RestartMatchButton"
	hud.pause_restart_button.text = "Reiniciar partida..."
	hud.pause_restart_button.custom_minimum_size = Vector2(0.0, 42.0)
	hud.pause_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.pause_restart_button.pressed.connect(func() -> void:
		set_restart_confirmation_visible(hud, true)
	)
	box.add_child(hud.pause_restart_button)

	hud.pause_restart_confirm_box = HBoxContainer.new()
	hud.pause_restart_confirm_box.name = "RestartConfirmBox"
	hud.pause_restart_confirm_box.visible = false
	hud.pause_restart_confirm_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.pause_restart_confirm_box.add_theme_constant_override("separation", 8)
	box.add_child(hud.pause_restart_confirm_box)

	var restart_confirm_label := Label.new()
	restart_confirm_label.name = "RestartConfirmLabel"
	restart_confirm_label.text = "Reiniciar a partida?"
	restart_confirm_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	restart_confirm_label.add_theme_font_size_override("font_size", 14)
	restart_confirm_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud._ignore_mouse(restart_confirm_label)
	hud.pause_restart_confirm_box.add_child(restart_confirm_label)

	hud.pause_restart_confirm_button = Button.new()
	hud.pause_restart_confirm_button.name = "ConfirmRestartButton"
	hud.pause_restart_confirm_button.text = "Confirmar"
	hud.pause_restart_confirm_button.custom_minimum_size = Vector2(150.0, 34.0)
	hud.pause_restart_confirm_button.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.pause_restart_confirm_button.add_theme_stylebox_override("normal", hud._build_button_style(Color(0.56, 0.1, 0.08, 1.0), Color(1.0, 0.62, 0.42, 1.0), 2))
	hud.pause_restart_confirm_button.add_theme_stylebox_override("hover", hud._build_button_style(Color(0.74, 0.14, 0.1, 1.0), Color(1.0, 0.78, 0.48, 1.0), 2))
	hud.pause_restart_confirm_button.pressed.connect(func() -> void:
		set_restart_confirmation_visible(hud, false)
		hud.restart_requested.emit()
	)
	hud.pause_restart_confirm_box.add_child(hud.pause_restart_confirm_button)

	hud.pause_restart_cancel_button = Button.new()
	hud.pause_restart_cancel_button.name = "CancelRestartButton"
	hud.pause_restart_cancel_button.text = "Cancelar"
	hud.pause_restart_cancel_button.custom_minimum_size = Vector2(120.0, 34.0)
	hud.pause_restart_cancel_button.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.pause_restart_cancel_button.pressed.connect(func() -> void:
		set_restart_confirmation_visible(hud, false)
		if hud.pause_restart_button != null:
			hud.pause_restart_button.grab_focus()
	)
	hud.pause_restart_confirm_box.add_child(hud.pause_restart_cancel_button)

	_build_pause_tab_bar(hud, box)
	hud.pause_controls_section = _build_pause_controls_section(hud, box)

	hud.pause_audio_title = Label.new()
	hud.pause_audio_title.name = "PauseVolumeTitle"
	hud.pause_audio_title.text = "Audio"
	hud.pause_audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud.pause_audio_title.add_theme_font_size_override("font_size", 16)
	hud._ignore_mouse(hud.pause_audio_title)
	box.add_child(hud.pause_audio_title)
	hud.pause_volume_slider = _build_pause_volume_row(hud, box, "VolumeRow", "VolumeLabel", "Master", "VolumeSlider", hud.BUS_MASTER)
	hud.pause_sfx_volume_slider = _build_pause_volume_row(hud, box, "SfxVolumeRow", "SfxVolumeLabel", "SFX", "SfxVolumeSlider", hud.BUS_SFX)
	hud.pause_ui_volume_slider = _build_pause_volume_row(hud, box, "UiVolumeRow", "UiVolumeLabel", "UI", "UiVolumeSlider", hud.BUS_UI)
	hud.pause_ambience_volume_slider = _build_pause_volume_row(hud, box, "AmbienceVolumeRow", "AmbienceVolumeLabel", "Ambiente", "AmbienceVolumeSlider", hud.BUS_AMBIENCE)
	hud.pause_video_section = _build_pause_video_section(hud, box)
	hud.pause_sensitivity_section = _build_pause_sensitivity_section(hud, box)

	hud.pause_menu_button = Button.new()
	hud.pause_menu_button.name = "MainMenuButton"
	hud.pause_menu_button.text = "Sair ao menu"
	hud.pause_menu_button.custom_minimum_size = Vector2(0.0, 42.0)
	hud.pause_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.pause_menu_button.pressed.connect(func() -> void:
		hud.main_menu_requested.emit()
	)
	box.add_child(hud.pause_menu_button)
	set_pause_section(hud, &"audio")


static func set_restart_confirmation_visible(hud: Node, is_visible: bool) -> void:
	if hud.pause_restart_confirm_box == null:
		return
	hud.pause_restart_confirm_box.visible = is_visible
	if is_visible and hud.pause_restart_confirm_button != null:
		hud.pause_restart_confirm_button.grab_focus()


static func sync_pause_settings_controls(hud: Node, sensitivity_value: float = 0.0) -> void:
	if hud.pause_volume_slider != null:
		hud.pause_volume_slider.set_value_no_signal(get_pause_volume(hud, hud.BUS_MASTER))
	if hud.pause_sfx_volume_slider != null:
		hud.pause_sfx_volume_slider.set_value_no_signal(get_pause_volume(hud, hud.BUS_SFX))
	if hud.pause_ui_volume_slider != null:
		hud.pause_ui_volume_slider.set_value_no_signal(get_pause_volume(hud, hud.BUS_UI))
	if hud.pause_ambience_volume_slider != null:
		hud.pause_ambience_volume_slider.set_value_no_signal(get_pause_volume(hud, hud.BUS_AMBIENCE))
	var settings = hud._get_game_settings()
	if hud.pause_fullscreen_toggle != null:
		hud.pause_fullscreen_toggle.set_pressed_no_signal(settings.get_fullscreen_enabled() if settings != null else DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	if hud.pause_quality_option != null:
		select_pause_quality_option(hud, settings.get_quality_id() if settings != null else RenderProfileScript.get_quality_id())
	var next_sensitivity := sensitivity_value
	if next_sensitivity <= 0.0 and settings != null:
		next_sensitivity = settings.get_mouse_sensitivity()
	if next_sensitivity > 0.0:
		hud.set_sensitivity_value(next_sensitivity)


static func set_pause_section(hud: Node, section_id: StringName) -> void:
	var normalized := section_id
	if not [&"controls", &"audio", &"video", &"sensitivity"].has(normalized):
		normalized = &"audio"
	hud.pause_section_id = normalized
	if hud.pause_controls_section != null:
		hud.pause_controls_section.visible = normalized == &"controls"
	var audio_visible := normalized == &"audio"
	if hud.pause_audio_title != null:
		hud.pause_audio_title.visible = audio_visible
	for control in [hud.pause_volume_slider, hud.pause_sfx_volume_slider, hud.pause_ui_volume_slider, hud.pause_ambience_volume_slider]:
		if control != null and control.get_parent() != null:
			control.get_parent().visible = audio_visible
	if hud.pause_video_section != null:
		hud.pause_video_section.visible = normalized == &"video"
	if hud.pause_sensitivity_section != null:
		hud.pause_sensitivity_section.visible = normalized == &"sensitivity"
	for key in hud.pause_section_buttons.keys():
		var button := hud.pause_section_buttons[key] as Button
		if button != null:
			button.set_pressed_no_signal(StringName(key) == normalized)


static func get_pause_volume(hud: Node, bus_name: StringName) -> float:
	var settings = hud._get_game_settings()
	if settings != null:
		return settings.get_volume(bus_name)
	return hud._get_bus_volume_linear(bus_name)


static func set_pause_volume(hud: Node, bus_name: StringName, value: float) -> void:
	var settings = hud._get_game_settings()
	if settings != null:
		settings.set_volume(bus_name, value, true, true)
		return
	hud._set_bus_volume(bus_name, value, true)


static func on_pause_fullscreen_toggled(hud: Node, enabled: bool) -> void:
	var settings = hud._get_game_settings()
	if settings != null:
		settings.set_fullscreen_enabled(enabled, true, true)
	hud.fullscreen_changed.emit(enabled)


static func on_pause_quality_selected(hud: Node, index: int) -> void:
	var quality_id := RenderProfileScript.QUALITY_LIGHT if index == 1 else RenderProfileScript.QUALITY_HIGH
	var settings = hud._get_game_settings()
	if settings != null:
		settings.set_quality_id(quality_id)
	else:
		RenderProfileScript.set_quality_id(quality_id)
	select_pause_quality_option(hud, quality_id)
	hud.quality_changed.emit(quality_id)


static func select_pause_quality_option(hud: Node, quality_id: StringName) -> void:
	if hud.pause_quality_option == null:
		return
	hud.pause_quality_option.select(1 if RenderProfileScript.normalize_quality_id(quality_id) == RenderProfileScript.QUALITY_LIGHT else 0)


static func on_sensitivity_slider_changed(hud: Node, value: float) -> void:
	update_sensitivity_label(hud, value)
	var settings = hud._get_game_settings()
	if settings != null:
		settings.set_mouse_sensitivity(value)
	hud.sensitivity_changed.emit(value)


static func update_sensitivity_label(hud: Node, value: float) -> void:
	if hud.sensitivity_label == null:
		return
	hud.sensitivity_label.text = "Sensibilidade: %.1f" % [value * 1000.0]


static func _build_pause_tab_bar(hud: Node, parent: VBoxContainer) -> void:
	var tab_bar := HBoxContainer.new()
	tab_bar.name = "PauseSectionTabs"
	tab_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_bar.add_theme_constant_override("separation", 8)
	parent.add_child(tab_bar)
	hud.pause_section_buttons.clear()
	tab_bar.add_child(_build_pause_tab_button(hud, &"controls", "Controles"))
	tab_bar.add_child(_build_pause_tab_button(hud, &"audio", "Audio"))
	tab_bar.add_child(_build_pause_tab_button(hud, &"video", "Video"))
	tab_bar.add_child(_build_pause_tab_button(hud, &"sensitivity", "Sensibilidade"))


static func _build_pause_tab_button(hud: Node, section_id: StringName, label: String) -> Button:
	var button := Button.new()
	button.name = "%sTabButton" % label.replace(" ", "")
	button.text = label
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0.0, 34.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(func() -> void:
		set_pause_section(hud, section_id)
	)
	hud.pause_section_buttons[section_id] = button
	return button


static func _build_pause_controls_section(hud: Node, parent: VBoxContainer) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "ControlsSection"
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_theme_constant_override("separation", 6)
	parent.add_child(section)

	var table := GridContainer.new()
	table.name = "ControlsTable"
	table.columns = 2
	table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	table.add_theme_constant_override("h_separation", 18)
	table.add_theme_constant_override("v_separation", 5)
	section.add_child(table)

	for hint: Dictionary in hud.CONTROL_HINTS:
		var action_label := Label.new()
		action_label.name = "ActionLabel"
		action_label.text = str(hint.get("action", ""))
		action_label.add_theme_font_size_override("font_size", 13)
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hud._ignore_mouse(action_label)
		table.add_child(action_label)

		var input_label := Label.new()
		input_label.name = "InputLabel"
		input_label.text = str(hint.get("input", ""))
		input_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		input_label.add_theme_font_size_override("font_size", 13)
		input_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hud._ignore_mouse(input_label)
		table.add_child(input_label)
	return section


static func _build_pause_video_section(hud: Node, parent: VBoxContainer) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "VideoSection"
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_theme_constant_override("separation", 8)
	parent.add_child(section)

	var title := Label.new()
	title.name = "VideoTitle"
	title.text = "Video"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	hud._ignore_mouse(title)
	section.add_child(title)

	var fullscreen_row := HBoxContainer.new()
	fullscreen_row.name = "FullscreenRow"
	fullscreen_row.add_theme_constant_override("separation", 8)
	section.add_child(fullscreen_row)

	var fullscreen_label := Label.new()
	fullscreen_label.name = "FullscreenLabel"
	fullscreen_label.text = "Tela cheia"
	fullscreen_label.custom_minimum_size.x = 116.0
	fullscreen_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud._ignore_mouse(fullscreen_label)
	fullscreen_row.add_child(fullscreen_label)

	hud.pause_fullscreen_toggle = CheckButton.new()
	hud.pause_fullscreen_toggle.name = "FullscreenToggle"
	hud.pause_fullscreen_toggle.text = "Ativar"
	hud.pause_fullscreen_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.pause_fullscreen_toggle.toggled.connect(Callable(hud, "_on_pause_fullscreen_toggled"))
	fullscreen_row.add_child(hud.pause_fullscreen_toggle)

	var quality_row := HBoxContainer.new()
	quality_row.name = "QualityRow"
	quality_row.add_theme_constant_override("separation", 8)
	section.add_child(quality_row)

	var quality_label := Label.new()
	quality_label.name = "QualityLabel"
	quality_label.text = "Qualidade"
	quality_label.custom_minimum_size.x = 116.0
	quality_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud._ignore_mouse(quality_label)
	quality_row.add_child(quality_label)

	hud.pause_quality_option = OptionButton.new()
	hud.pause_quality_option.name = "QualityOption"
	hud.pause_quality_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.pause_quality_option.add_item("Alta")
	hud.pause_quality_option.add_item("Leve")
	hud.pause_quality_option.item_selected.connect(Callable(hud, "_on_pause_quality_selected"))
	quality_row.add_child(hud.pause_quality_option)

	hud.pause_quality_notice_label = Label.new()
	hud.pause_quality_notice_label.name = "QualityNoticeLabel"
	hud.pause_quality_notice_label.text = "Ambiente e placares atualizam agora; materiais novos entram no proximo carregamento."
	hud.pause_quality_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hud.pause_quality_notice_label.add_theme_font_size_override("font_size", 12)
	hud._ignore_mouse(hud.pause_quality_notice_label)
	section.add_child(hud.pause_quality_notice_label)
	return section


static func _build_pause_sensitivity_section(hud: Node, parent: VBoxContainer) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "SensitivitySection"
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_theme_constant_override("separation", 8)
	parent.add_child(section)

	var title := Label.new()
	title.name = "SensitivityTitle"
	title.text = "Sensibilidade"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	hud._ignore_mouse(title)
	section.add_child(title)

	var row := HBoxContainer.new()
	row.name = "SensitivityRow"
	row.add_theme_constant_override("separation", 8)
	section.add_child(row)

	hud.sensitivity_label = Label.new()
	hud.sensitivity_label.name = "SensitivityLabel"
	hud.sensitivity_label.custom_minimum_size.x = 142.0
	hud.sensitivity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud._ignore_mouse(hud.sensitivity_label)
	row.add_child(hud.sensitivity_label)

	hud.sensitivity_slider = HSlider.new()
	hud.sensitivity_slider.name = "SensitivitySlider"
	hud.sensitivity_slider.min_value = 0.0008
	hud.sensitivity_slider.max_value = 0.0032
	hud.sensitivity_slider.step = 0.0001
	hud.sensitivity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud.sensitivity_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.sensitivity_slider.value_changed.connect(Callable(hud, "_on_sensitivity_slider_changed"))
	row.add_child(hud.sensitivity_slider)
	update_sensitivity_label(hud, hud.sensitivity_slider.value)
	return section


static func _build_pause_volume_row(hud: Node, parent: VBoxContainer, row_name: String, label_name: String, label: String, slider_name: String, bus_name: StringName) -> HSlider:
	var row := HBoxContainer.new()
	row.name = row_name
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var row_label := Label.new()
	row_label.name = label_name
	row_label.text = label
	row_label.custom_minimum_size.x = 96.0
	row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hud._ignore_mouse(row_label)
	row.add_child(row_label)

	var slider := HSlider.new()
	slider.name = slider_name
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = get_pause_volume(hud, bus_name)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.mouse_filter = Control.MOUSE_FILTER_STOP
	slider.value_changed.connect(func(value: float) -> void:
		set_pause_volume(hud, bus_name, value)
	)
	row.add_child(slider)
	return slider
