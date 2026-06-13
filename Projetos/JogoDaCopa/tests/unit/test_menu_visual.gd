extends "res://addons/gut/test.gd"

const RenderProfileScript = preload("res://autoloads/render_profile.gd")

const BROADCAST_VIEWPORTS: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1280, 720),
	Vector2i(960, 540),
]

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_reset_runtime_settings()

func test_broadcast_menu_card_uses_kenney_font_and_preserves_paths() -> void:
	var menu := await _spawn_main_menu(Vector2i(1280, 720))
	assert_true(menu.debug_has_broadcast_match_card())
	assert_true(menu.debug_has_broadcast_font_loaded())
	assert_true(menu.debug_preview_uses_hero_shot())
	assert_true(menu.debug_main_controls_fit_viewports([
		Vector2(1920.0, 1080.0),
		Vector2(1280.0, 720.0),
		Vector2(960.0, 540.0),
	]), "required_size=%s" % str(menu.debug_get_menu_required_size()))
	assert_gte(menu.debug_get_primary_cta_min_height(), 42.0)

	var menu_box_path := "MenuCenter/MenuPanel/MenuBox/"
	assert_not_null(menu.get_node_or_null(menu_box_path + "BroadcastHeader/TitleLabel"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "MatchSectionLabel"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "AppearanceSectionLabel"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "AudioVideoSectionLabel"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "BotDifficultyRow"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "MatchModeRow"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "BroadcastSkinToneRow"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "BroadcastCountryKitRow"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "VolumeRow/VolumeSlider"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "QualityRow/QualityOption"))
	assert_not_null(menu.get_node_or_null(menu_box_path + "ToonRenderRow/ToonRenderToggle"))
	assert_null(menu.get_node_or_null(menu_box_path + "SkinPreviewRow"))
	assert_null(menu.get_node_or_null(menu_box_path + "KitPreviewRow"))
	assert_no_new_orphans()

func test_broadcast_menu_cycles_appearance_into_hero_shot() -> void:
	var menu := await _spawn_main_menu(Vector2i(1280, 720))
	var initial_skin_id: StringName = menu.debug_get_selected_skin_tone_id()
	var initial_kit_id: StringName = menu.debug_get_selected_kit_id()

	menu.debug_cycle_skin_tone(1)
	menu.debug_cycle_country_kit(1)
	await get_tree().process_frame

	assert_ne(menu.debug_get_selected_skin_tone_id(), initial_skin_id)
	assert_ne(menu.debug_get_selected_kit_id(), initial_kit_id)
	assert_true(menu.debug_preview_uses_hero_shot())
	assert_no_new_orphans()

func test_broadcast_menu_controls_accept_real_mouse_clicks() -> void:
	for viewport_size: Vector2i in BROADCAST_VIEWPORTS:
		var menu := await _spawn_main_menu(viewport_size)
		var menu_box_path := "MenuCenter/MenuPanel/MenuBox/"
		var context := "%sx%s" % [viewport_size.x, viewport_size.y]
		_disconnect_button_pressed_callbacks(menu.get_node(menu_box_path + "FootballButton") as Button)
		_disconnect_button_pressed_callbacks(menu.get_node(menu_box_path + "QuitButton") as Button)

		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "FootballButton", "CTA %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "QuitButton", "Sair %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BotDifficultyRow/BotDifficultyPreviousButton", "Dificuldade anterior %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BotDifficultyRow/BotDifficultyNextButton", "Dificuldade proxima %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "MatchModeRow/MatchModePreviousButton", "Modo anterior %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "MatchModeRow/MatchModeNextButton", "Modo proximo %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BroadcastSkinToneRow/SkinTonePreviousButton", "Pele anterior %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BroadcastSkinToneRow/SkinToneNextButton", "Pele proxima %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BroadcastCountryKitRow/CountryKitPreviousButton", "Kit anterior %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BroadcastCountryKitRow/CountryKitNextButton", "Kit proximo %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "VolumeRow/VolumeSlider", "Volume master %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "SfxVolumeRow/SfxVolumeSlider", "Volume SFX %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "UiVolumeRow/UiVolumeSlider", "Volume UI %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "AmbienceVolumeRow/AmbienceVolumeSlider", "Volume ambiente %s" % context)
		await _assert_real_toggle_click_emits_toggled(menu, menu_box_path + "ToonRenderRow/ToonRenderToggle", "Toon %s" % context)
		var popup := await _assert_real_option_button_opens(menu.get_node(menu_box_path + "QualityRow/QualityOption") as OptionButton, "Qualidade %s" % context)
		popup.hide()
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

func _disconnect_button_pressed_callbacks(button: Button) -> void:
	assert_not_null(button)
	for connection: Dictionary in button.pressed.get_connections():
		if connection.has("callable"):
			button.pressed.disconnect(connection["callable"])

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
