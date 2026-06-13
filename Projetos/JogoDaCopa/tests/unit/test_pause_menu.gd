extends "res://addons/gut/test.gd"

const RenderProfileScript = preload("res://autoloads/render_profile.gd")

const REAL_CLICK_VIEWPORTS: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720),
]

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	RenderProfileScript.set_quality_id(RenderProfileScript.QUALITY_HIGH)
	var settings = get_node_or_null("/root/GameSettings")
	if settings != null:
		settings.reset_to_defaults(false)

func test_main_menu_quality_dropdown_accepts_real_mouse_clicks_and_changes_profile() -> void:
	for viewport_size: Vector2i in REAL_CLICK_VIEWPORTS:
		var menu := await _spawn_main_menu(viewport_size)
		var option := menu.get_node("MenuCenter/MenuPanel/MenuBox/QualityRow/QualityOption") as OptionButton
		var popup := await _assert_real_option_button_opens(option, "Menu qualidade %sx%s" % [viewport_size.x, viewport_size.y])
		popup.hide()
		menu.debug_select_quality(1)
		assert_eq(menu.debug_get_quality_text(), "Leve")
		assert_eq(menu.debug_get_render_profile_id(), RenderProfileScript.PROFILE_WEB)
		assert_eq(menu.debug_get_preview_viewport_size(), RenderProfileScript.WEB_MENU_PREVIEW_VIEWPORT_SIZE)
		menu.debug_select_quality(0)
		_reset_runtime_settings()
	assert_no_new_orphans()

func test_pause_menu_full_controls_accept_real_mouse_clicks() -> void:
	for viewport_size: Vector2i in REAL_CLICK_VIEWPORTS:
		var football := await _spawn_football(viewport_size)
		var hud = football.get_node("FootballHud")
		football.debug_start_match()
		football.debug_finish_kickoff_countdown()
		await get_tree().process_frame
		football._set_menu_open(true)
		await get_tree().process_frame

		var context := "%sx%s" % [viewport_size.x, viewport_size.y]
		var pause_path := "HudRoot/PauseMenuCenter/PauseMenuPanel/PauseMenuMargin/PauseMenuBox/"
		assert_true(hud.debug_is_pause_menu_visible())
		assert_eq(get_tree().paused, true)
		assert_eq(Input.get_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
		assert_eq(hud.debug_get_focused_control_name(), "ResumeButton")
		assert_eq(hud.debug_get_pause_section_id(), &"audio")

		_disconnect_button_pressed_callbacks(hud.get_node(pause_path + "ResumeButton") as Button)
		_disconnect_button_pressed_callbacks(hud.get_node(pause_path + "RestartMatchButton") as Button)
		_disconnect_button_pressed_callbacks(hud.get_node(pause_path + "MainMenuButton") as Button)
		_disconnect_signal_callbacks((hud.get_node(pause_path + "VideoSection/FullscreenRow/FullscreenToggle") as CheckButton).toggled)

		await _assert_real_button_click_emits_pressed(hud, pause_path + "ResumeButton", "Pause continuar %s" % context)
		await _assert_real_button_click_emits_pressed(hud, pause_path + "RestartMatchButton", "Pause reiniciar %s" % context)
		await _assert_real_button_click_emits_pressed(hud, pause_path + "PauseSectionTabs/AudioTabButton", "Pause aba audio %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "VolumeRow/VolumeSlider", "Pause volume master %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "SfxVolumeRow/SfxVolumeSlider", "Pause volume SFX %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "UiVolumeRow/UiVolumeSlider", "Pause volume UI %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "AmbienceVolumeRow/AmbienceVolumeSlider", "Pause volume ambiente %s" % context)

		await _assert_real_button_click_emits_pressed(hud, pause_path + "PauseSectionTabs/ControlesTabButton", "Pause aba controles %s" % context)
		assert_true((hud.get_node(pause_path + "ControlsSection") as Control).visible)

		await _assert_real_button_click_emits_pressed(hud, pause_path + "PauseSectionTabs/VideoTabButton", "Pause aba video %s" % context)
		assert_true((hud.get_node(pause_path + "VideoSection") as Control).visible)
		await _assert_real_toggle_click_emits_toggled(hud, pause_path + "VideoSection/FullscreenRow/FullscreenToggle", "Pause fullscreen %s" % context)
		var popup := await _assert_real_option_button_opens(hud.get_node(pause_path + "VideoSection/QualityRow/QualityOption") as OptionButton, "Pause qualidade %s" % context)
		popup.hide()
		hud.debug_show_pause_section(&"video")
		(hud.get_node(pause_path + "VideoSection/QualityRow/QualityOption") as OptionButton).select(1)
		(hud.get_node(pause_path + "VideoSection/QualityRow/QualityOption") as OptionButton).item_selected.emit(1)
		assert_eq(RenderProfileScript.get_active_profile_id(), RenderProfileScript.PROFILE_WEB)

		await _assert_real_button_click_emits_pressed(hud, pause_path + "PauseSectionTabs/SensibilidadeTabButton", "Pause aba sensibilidade %s" % context)
		assert_true((hud.get_node(pause_path + "SensitivitySection") as Control).visible)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "SensitivitySection/SensitivityRow/SensitivitySlider", "Pause sensibilidade %s" % context)
		await _assert_real_button_click_emits_pressed(hud, pause_path + "MainMenuButton", "Pause menu %s" % context)
		_reset_runtime_settings()
	assert_no_new_orphans()

func _spawn_main_menu(viewport_size: Vector2i) -> Control:
	var test_viewport := SubViewport.new()
	test_viewport.set_size(viewport_size)
	add_child_autofree(test_viewport)
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	assert_not_null(menu_scene)
	var menu := menu_scene.instantiate() as Control
	assert_not_null(menu)
	test_viewport.add_child(menu)
	await get_tree().process_frame
	await get_tree().process_frame
	return menu

func _spawn_football(viewport_size: Vector2i) -> Node3D:
	var test_viewport := SubViewport.new()
	test_viewport.set_size(viewport_size)
	add_child_autofree(test_viewport)
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	assert_not_null(football_scene)
	var football := football_scene.instantiate() as Node3D
	assert_not_null(football)
	test_viewport.add_child(football)
	await get_tree().process_frame
	await get_tree().process_frame
	return football

func _disconnect_button_pressed_callbacks(button: Button) -> void:
	assert_not_null(button)
	for connection: Dictionary in button.pressed.get_connections():
		if connection.has("callable"):
			button.pressed.disconnect(connection["callable"])

func _disconnect_signal_callbacks(signal_value: Signal) -> void:
	for connection: Dictionary in signal_value.get_connections():
		if connection.has("callable"):
			signal_value.disconnect(connection["callable"])

func _assert_real_button_click_emits_pressed(root: Node, node_path: String, control_label: String) -> void:
	var button := root.get_node(node_path) as Button
	assert_not_null(button, "%s button missing at %s" % [control_label, node_path])
	var fired := [0]
	button.pressed.connect(func() -> void:
		fired[0] = int(fired[0]) + 1
	)
	var click_report := await _push_real_mouse_click_at_control(button)
	assert_gt(int(fired[0]), 0, "%s did not emit pressed. %s" % [control_label, _format_click_report(click_report)])

func _assert_real_toggle_click_emits_toggled(root: Node, node_path: String, control_label: String) -> void:
	var toggle := root.get_node(node_path) as CheckButton
	assert_not_null(toggle, "%s toggle missing at %s" % [control_label, node_path])
	var fired := [0]
	toggle.toggled.connect(func(_value: bool) -> void:
		fired[0] = int(fired[0]) + 1
	)
	var click_report := await _push_real_mouse_click_at_control(toggle)
	assert_gt(int(fired[0]), 0, "%s did not emit toggled. %s" % [control_label, _format_click_report(click_report)])

func _assert_real_slider_click_emits_value_changed(root: Node, node_path: String, control_label: String) -> void:
	var slider := root.get_node(node_path) as HSlider
	assert_not_null(slider, "%s slider missing at %s" % [control_label, node_path])
	var fired := [0]
	slider.value_changed.connect(func(_value: float) -> void:
		fired[0] = int(fired[0]) + 1
	)
	var click_report := await _push_real_mouse_click_at_control(slider)
	assert_gt(int(fired[0]), 0, "%s did not emit value_changed. %s" % [control_label, _format_click_report(click_report)])

func _assert_real_option_button_opens(option: OptionButton, control_label: String) -> PopupMenu:
	assert_not_null(option)
	var popup := option.get_popup()
	assert_not_null(popup)
	var click_report := await _push_real_mouse_click_at_control(option)
	assert_true(popup.visible, "%s popup did not open. %s" % [control_label, _format_click_report(click_report)])
	return popup

func _push_real_mouse_click_at_control(control: Control) -> Dictionary:
	assert_not_null(control)
	var viewport := control.get_viewport()
	var global_rect := control.get_global_rect()
	var center := global_rect.position + global_rect.size * 0.5
	var motion := InputEventMouseMotion.new()
	motion.position = center
	motion.global_position = center
	viewport.push_input(motion, true)
	Input.flush_buffered_events()
	await get_tree().process_frame
	var hovered_before := viewport.gui_get_hovered_control()

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.position = center
	press.global_position = center
	press.pressed = true
	press.button_mask = MOUSE_BUTTON_MASK_LEFT
	viewport.push_input(press, true)
	Input.flush_buffered_events()
	await get_tree().process_frame

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = center
	release.global_position = center
	release.pressed = false
	release.button_mask = 0
	viewport.push_input(release, true)
	Input.flush_buffered_events()
	await get_tree().process_frame
	var hovered_after := viewport.gui_get_hovered_control()

	return {
		"target": control,
		"center": center,
		"rect": global_rect,
		"hovered_before": hovered_before,
		"hovered_after": hovered_after,
	}

func _format_click_report(report: Dictionary) -> String:
	return "target=%s center=%s rect=%s hovered_before=%s hovered_after=%s" % [
		str(report.get("target")),
		str(report.get("center")),
		str(report.get("rect")),
		str(report.get("hovered_before")),
		str(report.get("hovered_after")),
	]

func _reset_runtime_settings() -> void:
	RenderProfileScript.set_quality_id(RenderProfileScript.QUALITY_HIGH)
	var settings = get_node_or_null("/root/GameSettings")
	if settings != null:
		settings.reset_to_defaults(false)
