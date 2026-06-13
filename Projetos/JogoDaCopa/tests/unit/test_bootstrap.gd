extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const PlayerControllerScript = preload("res://gameplay/player/fps_player_controller.gd")
const FootballChaseCameraScript = preload("res://presentation/camera/football_chase_camera.gd")
const FootballBallScript = preload("res://gameplay/football/football_ball.gd")
const FootballBotScript = preload("res://gameplay/football/football_bot.gd")
const FootballFieldBuilderScript = preload("res://modes/football/football_field_builder.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const BOT_DIFFICULTY_META_KEY: String = "jogodacopa_bot_difficulty"
const MATCH_MODE_META_KEY: String = "jogodacopa_match_mode"
const TOON_RENDER_META_KEY: String = "jogodacopa_toon_render"
const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"
const TRACK04E_CAPTURE_CAMERA_NAME: String = "Track04ECaptureCamera"
const TRACK04E_CAPTURE_CAMERA_FOV: float = 50.0
const TRACK04E_NIGHT_SKY_MAX_LUMA_255: float = 90.0

const EXPECTED_ACTIONS: PackedStringArray = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"jump",
	"boost",
	"arcade_dash",
	"arcade_emote",
	"shoot",
	"alt_fire",
	"restart_round",
	"ui_back"
]
const TRACK03I_REAL_CLICK_TEST_PENDING: bool = false
const TRACK03I_RED_REPRODUCTION_NOTE: String = "Track 03I red reproduced: MainMenuRoot has a 0x0 hit-test rect, leaving MenuSafeArea/MenuScroll collapsed and all real viewport clicks blocked."
const TRACK03I_REAL_CLICK_VIEWPORTS: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
]
const TRACK03L_SEAL_GRID_STEP: float = 0.25
const TRACK03L_MAX_TUNNELING_SPEED: float = 34.0
const TRACK04B2_DASH_BASELINE_DISTANCE: float = 5.3
const TRACK04B2_DASH_DISTANCE_TOLERANCE: float = TRACK04B2_DASH_BASELINE_DISTANCE * 0.05
const TRACK04B2_STATIONARY_JUMP_MAX_XZ_DRIFT: float = 0.05
const TRACK04B2_MENU_MIN_AVERAGE_LUMINANCE: float = 0.025

func before_all() -> void:
	var result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if get_tree().root.has_meta(BOT_DIFFICULTY_META_KEY):
		get_tree().root.remove_meta(BOT_DIFFICULTY_META_KEY)
	if get_tree().root.has_meta(MATCH_MODE_META_KEY):
		get_tree().root.remove_meta(MATCH_MODE_META_KEY)
	if get_tree().root.has_meta(TOON_RENDER_META_KEY):
		get_tree().root.remove_meta(TOON_RENDER_META_KEY)
	if get_tree().root.has_meta(CAPTURE_SCENE_META_KEY):
		get_tree().root.remove_meta(CAPTURE_SCENE_META_KEY)
	for action_name: String in EXPECTED_ACTIONS:
		Input.action_release(action_name)

func test_input_actions_are_bootstrapped() -> void:
	for action_name: String in EXPECTED_ACTIONS:
		assert_true(InputMap.has_action(action_name), "Missing input action %s" % action_name)
		assert_gt(InputMap.action_get_events(action_name).size(), 0, "Input action %s has no binding" % action_name)

func test_main_menu_scene_boots_with_football_button_only() -> void:
	var menu_scene := load("res://modes/menu/main_menu.tscn") as PackedScene
	assert_not_null(menu_scene)
	var menu := menu_scene.instantiate()
	add_child_autofree(menu)
	await get_tree().process_frame

	assert_eq(menu.debug_get_mode_path(&"football"), "res://modes/football/football.tscn")
	assert_eq(menu.debug_get_mode_path(&"arena"), "")
	assert_true(menu.debug_has_arena_preview())
	var footer_label := menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/FooterLabel") as Label
	assert_not_null(footer_label)
	if footer_label != null:
		assert_true(footer_label.text.contains("Copa Arena Futebol v1.1.0+"))
		assert_false(footer_label.text.contains("PC Windows editor-first"))
		assert_eq(footer_label.text, menu.debug_get_visible_version_text())
	assert_eq(menu.debug_get_selected_bot_difficulty_id(), &"normal")
	assert_eq(menu.debug_get_selected_match_mode_id(), &"timer")
	assert_false(menu.debug_is_toon_render_enabled())
	assert_false(menu.debug_has_main_menu_appearance_selection())
	assert_true(menu.debug_main_controls_fit_viewports([
		Vector2(1920.0, 1080.0),
		Vector2(1366.0, 768.0),
		Vector2(1280.0, 720.0)
	]))
	assert_true(menu.debug_has_audio_buses())
	assert_eq(menu.debug_get_ui_audio_pool_size(), 5)
	menu.debug_cycle_bot_difficulty(1)
	assert_eq(menu.debug_get_selected_bot_difficulty_id(), &"hard")
	menu.debug_cycle_match_mode(1)
	assert_eq(menu.debug_get_selected_match_mode_id(), &"goals")
	assert_eq(menu.debug_get_quality_text(), "Alta")
	assert_not_null(menu.get_node_or_null("ArenaPreviewViewport"))
	assert_not_null(menu.get_node_or_null("ArenaPreview"))
	assert_true(menu.debug_preview_uses_hero_shot())
	assert_eq(menu.get_viewport().gui_get_focus_owner().name, "FootballButton")
	assert_null(menu.get_node_or_null("MenuSafeArea"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuScroll"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/FootballButton"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/ArenaButton"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/SkinPreviewRow"))
	assert_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/KitPreviewRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/BotDifficultyRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/MatchModeRow"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/VolumeRow/VolumeSlider"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/SfxVolumeRow/SfxVolumeSlider"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/UiVolumeRow/UiVolumeSlider"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/AmbienceVolumeRow/AmbienceVolumeSlider"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/QualityRow/QualityOption"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/ToonRenderRow/ToonRenderToggle"))
	assert_not_null(menu.get_node_or_null("MenuCenter/MenuPanel/MenuBox/QuitButton"))
	var menu_panel := menu.get_node("MenuCenter/MenuPanel") as PanelContainer
	assert_eq(menu_panel.custom_minimum_size, Vector2(500.0, 0.0))
	assert_true(menu.debug_get_menu_required_size().y <= 684.0)
	assert_no_new_orphans()

func test_main_menu_real_mouse_clicks_reach_interactive_controls() -> void:
	if TRACK03I_REAL_CLICK_TEST_PENDING:
		pending(TRACK03I_RED_REPRODUCTION_NOTE)
		return
	for viewport_size: Vector2i in TRACK03I_REAL_CLICK_VIEWPORTS:
		var menu := await _spawn_main_menu_for_real_click_test(viewport_size)
		var menu_box_path := "MenuCenter/MenuPanel/MenuBox/"
		var context := "%sx%s" % [viewport_size.x, viewport_size.y]
		_disconnect_button_pressed_callbacks(menu.get_node(menu_box_path + "FootballButton") as Button)
		_disconnect_button_pressed_callbacks(menu.get_node(menu_box_path + "QuitButton") as Button)

		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "FootballButton", "Futebol %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "QuitButton", "Quit %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BotDifficultyRow/BotDifficultyPreviousButton", "Dificuldade anterior %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "BotDifficultyRow/BotDifficultyNextButton", "Dificuldade proxima %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "MatchModeRow/MatchModePreviousButton", "Modo anterior %s" % context)
		await _assert_real_button_click_emits_pressed(menu, menu_box_path + "MatchModeRow/MatchModeNextButton", "Modo proximo %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "VolumeRow/VolumeSlider", "Volume master %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "SfxVolumeRow/SfxVolumeSlider", "Volume SFX %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "UiVolumeRow/UiVolumeSlider", "Volume UI %s" % context)
		await _assert_real_slider_click_emits_value_changed(menu, menu_box_path + "AmbienceVolumeRow/AmbienceVolumeSlider", "Volume ambiente %s" % context)
	assert_no_new_orphans()

func test_main_menu_preview_capture_is_not_black_at_desktop_and_720p() -> void:
	for viewport_size: Vector2i in [Vector2i(1920, 1080), Vector2i(1280, 720)]:
		var menu := await _spawn_main_menu_for_real_click_test(viewport_size)
		for _frame in range(8):
			menu._process(1.0 / 60.0)
			await get_tree().process_frame
		var luminance: float = menu.debug_get_preview_average_luminance(24)
		assert_gt(
			luminance,
			TRACK04B2_MENU_MIN_AVERAGE_LUMINANCE,
			"Menu preview luminance %.4f below anti-black threshold at %sx%s" % [luminance, viewport_size.x, viewport_size.y]
		)
	assert_no_new_orphans()

func test_field_builder_stadium_visual_upgrade_is_config_driven() -> void:
	var stadium := Node3D.new()
	add_child_autofree(stadium)
	var player_color := Color(1.0, 0.16, 0.08, 1.0)
	var bot_color := Color(0.05, 0.72, 1.0, 1.0)

	FootballFieldBuilderScript.build(stadium, {
		"field_width": 32.0,
		"field_length": 44.0,
		"goal_closed_depth": 2.9,
		"stadium_tier_count": 4,
		"crowd_blocks_per_goal_side": 8,
		"crowd_blocks_per_lateral_side": 5,
		"player_kit_color": player_color,
		"bot_kit_color": bot_color,
		"country_names": ["BRASIL", "FRANCA", "ARGENTINA", "JAPAO"],
	})
	await get_tree().process_frame

	assert_not_null(stadium.get_node_or_null("NorthStandTier3"))
	assert_not_null(stadium.get_node_or_null("SouthStandTier3"))
	assert_not_null(stadium.get_node_or_null("EastStandTier3"))
	assert_not_null(stadium.get_node_or_null("NorthStandFrontWall"))
	assert_not_null(stadium.get_node_or_null("WestStandCorridorT2I1"))
	assert_not_null(stadium.get_node_or_null("NorthFlagMast0Flag"))
	assert_true((stadium.get_node("NorthFlagMast0Flag") as MeshInstance3D).material_override is ShaderMaterial)
	assert_not_null(stadium.get_node_or_null("NorthSkylineRing1Block6"))
	assert_not_null(stadium.get_node_or_null("EastSkylineBlock4"))
	assert_not_null(stadium.get_node_or_null("StadiumLightHaloNW"))
	assert_not_null(stadium.get_node_or_null("WorldCupScoreboardNorthViewport"))
	var scoreboard_viewport := stadium.get_node("WorldCupScoreboardNorthViewport") as SubViewport
	assert_eq(scoreboard_viewport.size, Vector2i(1024, 384))

	var crowd := stadium.get_node("NorthCrowdTier2Band0") as MeshInstance3D
	assert_not_null(crowd)
	var crowd_material := crowd.material_override as ShaderMaterial
	assert_not_null(crowd_material)
	var base_value: Vector3 = crowd.get_instance_shader_parameter("base_color")
	var alternate_value: Vector3 = crowd.get_instance_shader_parameter("alternate_color")
	assert_almost_eq(base_value.x, player_color.r, 0.001)
	assert_almost_eq(base_value.y, player_color.g, 0.001)
	assert_almost_eq(alternate_value.z, bot_color.b, 0.001)
	assert_almost_eq(float(crowd_material.get_shader_parameter("crowd_excitement")), 0.0, 0.001)

	for child in stadium.get_children():
		if child is Light3D:
			assert_false((child as Light3D).shadow_enabled, "Stadium visual upgrade must not add shadow-casting lights: %s" % child.name)
	assert_no_new_orphans()

func test_field_builder_crowd_excitement_clamps_and_updates_materials() -> void:
	var stadium := Node3D.new()
	add_child_autofree(stadium)
	FootballFieldBuilderScript.build(stadium, {
		"stadium_tier_count": 3,
		"crowd_blocks_per_goal_side": 8,
		"crowd_blocks_per_lateral_side": 5,
		"player_kit_color": Color(0.95, 0.8, 0.06, 1.0),
		"bot_kit_color": Color(0.1, 0.35, 0.95, 1.0),
	})
	await get_tree().process_frame

	FootballFieldBuilderScript.set_crowd_excitement(stadium, 1.4)
	assert_almost_eq(float(stadium.get_meta("crowd_excitement")), 1.0, 0.001)
	for node_name in ["NorthCrowdBand0", "SouthCrowdTier2Band3", "EastCrowdTier1Band2"]:
		var crowd := stadium.get_node(node_name) as MeshInstance3D
		var material := crowd.material_override as ShaderMaterial
		assert_almost_eq(float(material.get_shader_parameter("crowd_excitement")), 1.0, 0.001, "%s should receive max goal excitement" % node_name)

	FootballFieldBuilderScript.set_crowd_excitement(stadium, -0.5)
	assert_almost_eq(float(stadium.get_meta("crowd_excitement")), 0.0, 0.001)
	var crowd := stadium.get_node("NorthCrowdBand0") as MeshInstance3D
	var material := crowd.material_override as ShaderMaterial
	assert_almost_eq(float(material.get_shader_parameter("crowd_excitement")), 0.0, 0.001)
	assert_no_new_orphans()

func test_football_interactive_panels_accept_real_mouse_clicks() -> void:
	for viewport_size: Vector2i in TRACK03I_REAL_CLICK_VIEWPORTS:
		var football := await _spawn_football_for_real_click_test(viewport_size)
		var hud = football.get_node("FootballHud")
		var context := "%sx%s" % [viewport_size.x, viewport_size.y]

		var intro_path := "HudRoot/IntroCenter/IntroPanel/IntroMargin/IntroBox/"
		_disconnect_button_pressed_callbacks(hud.get_node(intro_path + "StartButton") as Button)
		await _assert_real_button_click_emits_pressed(hud, intro_path + "AvatarSelectionBox/SkinToneRow/SkinPreviousButton", "Intro pele anterior %s" % context)
		await _assert_real_button_click_emits_pressed(hud, intro_path + "AvatarSelectionBox/SkinToneRow/SkinNextButton", "Intro pele proxima %s" % context)
		await _assert_real_button_click_emits_pressed(hud, intro_path + "AvatarSelectionBox/CountryKitRow/KitPreviousButton", "Intro camisa anterior %s" % context)
		await _assert_real_button_click_emits_pressed(hud, intro_path + "AvatarSelectionBox/CountryKitRow/KitNextButton", "Intro camisa proxima %s" % context)
		await _assert_real_button_click_emits_pressed(hud, intro_path + "StartButton", "Intro comecar %s" % context)

		football.debug_start_match()
		football.debug_finish_kickoff_countdown()
		await get_tree().process_frame
		football._set_menu_open(true)
		await get_tree().process_frame
		assert_true(get_tree().paused)
		assert_eq(Input.get_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
		assert_eq(hud.debug_get_focused_control_name(), "ResumeButton")
		var pause_path := "HudRoot/PauseMenuCenter/PauseMenuPanel/PauseMenuMargin/PauseMenuBox/"
		_disconnect_button_pressed_callbacks(hud.get_node(pause_path + "ResumeButton") as Button)
		_disconnect_button_pressed_callbacks(hud.get_node(pause_path + "RestartMatchButton") as Button)
		_disconnect_button_pressed_callbacks(hud.get_node(pause_path + "MainMenuButton") as Button)
		await _assert_real_button_click_emits_pressed(hud, pause_path + "ResumeButton", "Pause continuar %s" % context)
		await _assert_real_button_click_emits_pressed(hud, pause_path + "RestartMatchButton", "Pause reiniciar %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "VolumeRow/VolumeSlider", "Pause volume master %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "SfxVolumeRow/SfxVolumeSlider", "Pause volume SFX %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "UiVolumeRow/UiVolumeSlider", "Pause volume UI %s" % context)
		await _assert_real_slider_click_emits_value_changed(hud, pause_path + "AmbienceVolumeRow/AmbienceVolumeSlider", "Pause volume ambiente %s" % context)
		await _assert_real_button_click_emits_pressed(hud, pause_path + "MainMenuButton", "Pause menu %s" % context)

		football._set_menu_open(false)
		football.debug_set_match_mode(&"goals")
		football.debug_set_score(2, 0)
		football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
		football._process_goal_detection()
		await get_tree().process_frame

		assert_true(football.debug_is_match_over())
		assert_true(football.debug_is_player_input_locked())
		assert_eq(Input.get_mouse_mode(), Input.MOUSE_MODE_VISIBLE)
		assert_eq(hud.debug_get_focused_control_name(), "RematchButton")
		var result_path := "HudRoot/ResultCenter/ResultPanel/ResultMargin/ResultBox/ResultButtons/"
		_disconnect_button_pressed_callbacks(hud.get_node(result_path + "RematchButton") as Button)
		_disconnect_button_pressed_callbacks(hud.get_node(result_path + "ResultMenuButton") as Button)
		await _assert_real_button_click_emits_pressed(hud, result_path + "RematchButton", "Resultado revanche %s" % context)
		await _assert_real_button_click_emits_pressed(hud, result_path + "ResultMenuButton", "Resultado menu %s" % context)
	assert_no_new_orphans()

func _spawn_main_menu_for_real_click_test(viewport_size: Vector2i) -> Control:
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

func _spawn_football_for_real_click_test(viewport_size: Vector2i) -> Node3D:
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
			var callable: Callable = connection["callable"]
			button.pressed.disconnect(callable)

func _assert_real_button_click_emits_pressed(root: Node, node_path: String, control_label: String) -> void:
	var button := root.get_node(node_path) as Button
	assert_not_null(button, "%s button missing at %s" % [control_label, node_path])
	var fired := [0]
	button.pressed.connect(func() -> void:
		fired[0] = int(fired[0]) + 1
	)
	var click_report := await _push_real_mouse_click_at_control(button)
	assert_gt(
		int(fired[0]),
		0,
		"%s did not emit pressed after real viewport click. %s" % [control_label, _format_click_report(click_report)]
	)

func _assert_real_slider_click_emits_value_changed(root: Node, node_path: String, control_label: String) -> void:
	var slider := root.get_node(node_path) as HSlider
	assert_not_null(slider, "%s slider missing at %s" % [control_label, node_path])
	var fired := [0]
	slider.value_changed.connect(func(_value: float) -> void:
		fired[0] = int(fired[0]) + 1
	)
	var click_report := await _push_real_mouse_click_at_control(slider)
	assert_gt(
		int(fired[0]),
		0,
		"%s did not emit value_changed after real viewport click. %s" % [control_label, _format_click_report(click_report)]
	)

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
		"hovered_after": hovered_after
	}

func _format_click_report(report: Dictionary) -> String:
	var target := report.get("target") as Control
	var hovered_before := report.get("hovered_before") as Control
	var hovered_after := report.get("hovered_after") as Control
	return "target=%s center=%s rect=%s hovered_before=%s hovered_after=%s ancestors=%s" % [
		_describe_control(target),
		str(report.get("center", Vector2.ZERO)),
		str(report.get("rect", Rect2())),
		_describe_control(hovered_before),
		_describe_control(hovered_after),
		_describe_control_ancestors(target)
	]

func _describe_control(control: Control) -> String:
	if control == null:
		return "<none>"
	var disabled_text := "false"
	if control is BaseButton:
		disabled_text = str((control as BaseButton).disabled)
	return "%s class=%s mouse_filter=%d visible=%s disabled=%s" % [
		str(control.get_path()),
		control.get_class(),
		control.mouse_filter,
		str(control.visible),
		disabled_text
	]

func _describe_control_ancestors(control: Control) -> String:
	if control == null:
		return "<none>"
	var parts: PackedStringArray = []
	var current: Node = control
	while current != null:
		if current is Control:
			var current_control := current as Control
			parts.append("%s class=%s filter=%d rect=%s visible=%s" % [
				current_control.name,
				current_control.get_class(),
				current_control.mouse_filter,
				str(current_control.get_global_rect()),
				str(current_control.visible)
			])
		current = current.get_parent()
	return " <- ".join(parts)

func test_football_scene_boots_with_player_bot_ball_goals_and_hud() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	assert_not_null(football_scene)
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	assert_not_null(football.get_node_or_null("WorldEnvironment"))
	var world_environment := football.get_node("WorldEnvironment") as WorldEnvironment
	var environment := world_environment.environment
	assert_not_null(environment)
	assert_eq(environment.background_mode, Environment.BG_SKY)
	assert_not_null(environment.sky)
	assert_eq(environment.tonemap_mode, Environment.TONE_MAPPER_ACES)
	assert_true(environment.glow_enabled)
	assert_true(environment.ssao_enabled)
	assert_true(environment.fog_enabled)
	assert_lt(environment.ambient_light_energy, 0.5)
	var key_light := football.get_node("StadiumKeyLight") as DirectionalLight3D
	assert_not_null(key_light)
	assert_true(key_light.shadow_enabled)
	assert_gt(key_light.directional_shadow_max_distance, 70.0)
	assert_not_null(football.get_node_or_null("FootballPitch"))
	assert_null(football.get_node_or_null("PitchGrassStripe0"))
	assert_null(football.get_node_or_null("CenterLine"))
	var pitch_mesh := football.get_node("FootballPitch/FootballPitchMesh") as MeshInstance3D
	assert_true(pitch_mesh.material_override is ShaderMaterial)
	assert_not_null(football.get_node_or_null("NorthGoalSideWallL"))
	assert_not_null(football.get_node_or_null("SouthGoalSideWallR"))
	assert_not_null(football.get_node_or_null("WestGlassWall"))
	assert_not_null(football.get_node_or_null("EastGlassWall"))
	assert_not_null(football.get_node_or_null("ArenaGlassCeiling"))
	assert_not_null(football.get_node_or_null("NorthBackGlass"))
	assert_not_null(football.get_node_or_null("SouthBackGlass"))
	assert_not_null(football.get_node_or_null("NorthGoalRoofGlass"))
	assert_not_null(football.get_node_or_null("SouthGoalRoofGlass"))
	assert_not_null(football.get_node_or_null("NorthGoalRoofFrontFrame"))
	assert_not_null(football.get_node_or_null("SouthGoalRoofBackFrame"))
	assert_true((football.get_node("NorthNetTint") as MeshInstance3D).material_override is ShaderMaterial)
	assert_not_null(football.get_node_or_null("WestGlassFramePost0"))
	assert_not_null(football.get_node_or_null("EastGlassFramePost0"))
	assert_not_null(football.get_node_or_null("ArenaRoofFrameNorth"))
	assert_not_null(football.get_node_or_null("ArenaRoofRib0"))
	assert_not_null(football.get_node_or_null("NorthStandTier0"))
	assert_not_null(football.get_node_or_null("SouthStandTier2"))
	assert_not_null(football.get_node_or_null("WestStandTier0"))
	assert_not_null(football.get_node_or_null("EastStandTier1"))
	assert_true((football.get_node("NorthCrowdBand0") as MeshInstance3D).material_override is ShaderMaterial)
	assert_not_null(football.get_node_or_null("NorthCountryBanner0"))
	assert_not_null(football.get_node_or_null("NorthCountryBanner0Label"))
	assert_false((football.get_node("NorthCountryBanner0Label") as Label3D).text.is_empty())
	assert_not_null(football.get_node_or_null("SouthCountryBanner7Stripe2"))
	assert_not_null(football.get_node_or_null("WorldCupScoreboardNorth"))
	assert_not_null(football.get_node_or_null("WorldCupScoreboardNorthViewport"))
	assert_not_null(football.get_node_or_null("WorldCupScoreboardNorthLiveDisplay"))
	assert_not_null(football.get_node_or_null("StadiumLightNW"))
	assert_true(football.get_node("StadiumLightNW") is SpotLight3D)
	var stadium_spot := football.get_node("StadiumLightNW") as SpotLight3D
	assert_false(stadium_spot.shadow_enabled)
	assert_gt(stadium_spot.spot_range, 45.0)
	assert_eq(football.debug_get_boost_pad_count(), 8)
	assert_eq(football.debug_get_jump_pad_count(), 2)
	assert_not_null(football.get_node_or_null("BoostPadSmall0"))
	assert_not_null(football.get_node_or_null("BoostPadLarge1"))
	assert_not_null(football.get_node_or_null("JumpPadNorth"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/Player/PlayerAvatar"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/FootballChaseCamera"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/FootballBot"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/FootballBot/BotAvatar"))
	assert_not_null(football.get_node_or_null("RuntimeRoot/Ball"))
	assert_not_null(football.get_node_or_null("FootballHud"))
	assert_not_null(football.get_node_or_null("FeedbackController"))
	assert_eq(football.debug_get_goal_limit(), 3)
	assert_eq(football.debug_get_match_mode(), &"timer")
	assert_false(football.debug_is_toon_render_enabled())
	assert_almost_eq(football.debug_get_match_time_remaining(), 180.0, 0.01)
	assert_eq(football.debug_get_player_score(), 0)
	assert_eq(football.debug_get_bot_score(), 0)
	assert_eq(football.debug_get_stadium_scoreboard_text("North"), "BRA 0 - 0 FRA")
	football.debug_cycle_country_kit(1)
	football.debug_set_score(2, 1)
	football._process(0.0)
	assert_eq(football.debug_get_stadium_scoreboard_text("North"), "ARG 2 - 1 FRA")
	football.debug_set_score(0, 0)
	football.debug_cycle_country_kit(-1)
	football._process(0.0)
	assert_true(football.debug_get_ball().get_script() == FootballBallScript)
	assert_not_null(load("res://assets/football/football_ball_panels.gdshader"))
	assert_true(football.debug_get_ball().debug_has_panel_asset_material())
	assert_true(football.debug_get_ball().debug_has_speed_trail())
	assert_true(football.debug_get_ball().debug_has_fireball_particles())
	assert_false(football.debug_get_ball().debug_is_toon_render_enabled())
	assert_false(football.debug_get_ball().debug_has_toon_outline())
	assert_true(football.debug_get_bot().get_script() == FootballBotScript)
	var player_avatar = football.debug_get_player_avatar()
	var bot_avatar = football.debug_get_bot_avatar()
	assert_true(player_avatar.get_script() == PlayerAvatarScript)
	assert_true(bot_avatar.get_script() == PlayerAvatarScript)
	assert_true(player_avatar.debug_has_real_model())
	assert_true(bot_avatar.debug_has_real_model())
	assert_gte(player_avatar.debug_get_animation_count(), 40)
	assert_gte(bot_avatar.debug_get_animation_count(), 40)
	assert_false(football.debug_get_player().debug_is_combatant_body_visible())
	assert_false(football.debug_get_bot().debug_is_combatant_body_visible())
	assert_null(player_avatar.get_node_or_null("AvatarParts/CopaAssetSkeleton"))
	assert_null(player_avatar.get_node_or_null("AvatarParts/AssetAnimationTree"))
	assert_true(player_avatar.debug_has_persistent_vfx())
	assert_false(player_avatar.debug_is_toon_render_enabled())
	assert_eq(player_avatar.debug_get_toon_outline_count(), 0)
	assert_true(football.debug_get_chase_camera().get_script() == FootballChaseCameraScript)
	assert_true(football.debug_get_chase_camera().debug_get_camera().current)
	assert_false(football.debug_get_player().get_camera().current)
	assert_false(player_avatar.local_first_person)
	assert_eq(player_avatar.debug_get_country_kit_id(), &"brazil")
	assert_eq(bot_avatar.debug_get_country_kit_id(), &"france")
	assert_true(football.debug_is_intro_open())
	assert_true(get_tree().paused)
	var football_hud = football.get_node("FootballHud")
	assert_true(football_hud.intro_panel.visible)
	assert_true(football_hud.debug_has_broadcast_scoreboard())
	assert_true(football.debug_get_hud_snapshot_interval_seconds() > 0.0)
	assert_true(football.debug_get_hud_snapshot_interval_seconds() <= 0.1)
	assert_true(football.debug_get_stadium_scoreboard_interval_seconds() > 0.0)
	assert_true(football.debug_get_stadium_scoreboard_interval_seconds() <= 0.1)
	assert_not_null(football_hud.get_node_or_null("HudRoot/IntroCenter/IntroPanel"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/ControlLabel"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BoostBar"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ScorePanel/ScoreBox/BroadcastScoreRow/PlayerKitSwatch"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/BallOffscreenIndicator"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ResultCenter/ResultPanel"))
	football.debug_force_ball_position(Vector3(20.0, 0.68, -18.0))
	football_hud.update_snapshot(football.debug_build_hud_snapshot())
	assert_true(football_hud.debug_is_ball_indicator_visible())
	football.debug_force_ball_position(Vector3(0.0, 0.68, 0.0))
	var arena_config: Dictionary = football.debug_get_arena_config()
	assert_gt(float(arena_config.get("field_width", 0.0)), 32.0)
	assert_gt(float(arena_config.get("wall_height", 0.0)), 6.0)
	assert_almost_eq(float(arena_config.get("goal_half_width", 0.0)), 4.32, 0.01)
	assert_almost_eq(float(arena_config.get("goal_height", 0.0)), 3.45, 0.01)
	var north_post_collision := football.get_node("NorthGoalPostL/NorthGoalPostLCollision") as CollisionShape3D
	var north_post_shape := north_post_collision.shape as BoxShape3D
	assert_almost_eq(north_post_shape.size.y, 3.45, 0.01)
	var north_roof_collision := football.get_node("NorthGoalRoofGlass/NorthGoalRoofGlassCollision") as CollisionShape3D
	var north_roof_shape := north_roof_collision.shape as BoxShape3D
	assert_gt(north_roof_shape.size.x, 10.0)
	assert_gt(north_roof_shape.size.z, 3.6)
	assert_gt(north_roof_shape.size.y, 0.3)
	var frame_mesh := football.get_node("WestGlassFrameTop") as MeshInstance3D
	var frame_material := frame_mesh.material_override as StandardMaterial3D
	assert_not_null(frame_material)
	if frame_material != null:
		assert_true(frame_material.emission_enabled)
		assert_gt(frame_material.emission_energy_multiplier, 1.5)
	var glass_mesh := football.get_node("WestGlassWall/WestGlassWallMesh") as MeshInstance3D
	var glass_material := glass_mesh.material_override as StandardMaterial3D
	assert_not_null(glass_material)
	if glass_material != null:
		assert_true(glass_material.rim_enabled)
		assert_true(glass_material.clearcoat_enabled)
		assert_gt(glass_material.emission_energy_multiplier, 0.5)
	assert_gt(football.debug_get_ball().physics_material_override.bounce, 0.8)
	assert_gt(football.debug_get_ball().physics_material_override.friction, 0.3)
	assert_no_new_orphans()

func test_football_capture_mode_uses_night_evidence_camera() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	assert_not_null(football_scene)
	get_tree().root.set_meta(CAPTURE_SCENE_META_KEY, &"kickoff")
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	await get_tree().process_frame

	var world_environment := football.get_node_or_null("WorldEnvironment") as WorldEnvironment
	assert_not_null(world_environment)
	var environment := world_environment.environment
	assert_not_null(environment)
	assert_eq(environment.tonemap_mode, Environment.TONE_MAPPER_ACES)
	assert_eq(environment.background_mode, Environment.BG_SKY)
	assert_not_null(environment.sky)
	assert_not_null(environment.sky.sky_material)
	var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
	assert_not_null(sky_material)
	assert_lt(_color_luma_255(sky_material.sky_top_color), TRACK04E_NIGHT_SKY_MAX_LUMA_255)

	var capture_camera := football.get_node_or_null(TRACK04E_CAPTURE_CAMERA_NAME) as Camera3D
	assert_not_null(capture_camera)
	assert_true(capture_camera.current)
	assert_almost_eq(capture_camera.fov, TRACK04E_CAPTURE_CAMERA_FOV, 0.001)
	assert_false(football.debug_get_chase_camera().debug_get_camera().current)
	assert_no_new_orphans()

func test_football_arena_raycast_seal_closes_upper_perimeter_and_goal_faces() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	await get_tree().physics_frame

	var leak_report := _collect_arena_seal_leaks(football)

	assert_eq(
		int(leak_report.get("count", 0)),
		0,
		"Arena seal raycasts escaped. Samples: %s" % _format_arena_leak_samples(leak_report)
	)
	assert_no_new_orphans()

func test_football_ball_uses_ccd_and_does_not_tunnel_at_max_speed() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var ball = football.debug_get_ball()
	assert_true(ball.continuous_cd)
	var cases: Array[Dictionary] = _build_track03l_tunneling_cases(football.debug_get_arena_config())
	for repeat_index in range(4):
		for case: Dictionary in cases:
			football.debug_force_ball_position(case.get("start", Vector3.ZERO) + Vector3(0.0, 0.0, float(repeat_index) * 0.015))
			ball.sleeping = false
			ball.linear_velocity = case.get("velocity", Vector3.ZERO)
			ball.angular_velocity = Vector3.ZERO
			for _frame in range(6):
				await get_tree().physics_frame
			assert_true(
				_track03l_ball_stayed_inside_case(ball.global_position, case),
				"%s repeat %d tunneled to %s" % [str(case.get("label", "")), repeat_index, str(ball.global_position)]
			)
	assert_no_new_orphans()

func test_football_ball_indicator_uses_player_local_basis() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var player = football.debug_get_player()
	var hud = football.get_node("FootballHud")
	player.global_position = Vector3.ZERO
	player.rotation.y = PI * 0.5
	await get_tree().process_frame

	var forward: Vector3 = -player.global_transform.basis.z
	football.debug_force_ball_position(player.global_position + forward * 24.0 + Vector3.UP * 0.63)
	hud.update_snapshot(football.debug_build_hud_snapshot())
	assert_true(hud.debug_get_ball_indicator_text().contains("FRENTE"))

	var right: Vector3 = player.global_transform.basis.x
	football.debug_force_ball_position(player.global_position + right * 24.0 + Vector3.UP * 0.63)
	hud.update_snapshot(football.debug_build_hud_snapshot())
	assert_true(hud.debug_get_ball_indicator_text().contains("D"))
	assert_no_new_orphans()

func test_football_player_avatar_visual_heading_tracks_movement_without_changing_logical_yaw() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var avatar = football.debug_get_player_avatar()
	player.rotation.y = 1.1
	player.velocity = Vector3(6.0, 0.0, 0.0)
	football._update_avatar_states(0.5)

	assert_almost_eq(player.rotation.y, 1.1, 0.001)
	assert_true(_track03l_visual_yaw_faces_direction(player.rotation.y + avatar.debug_get_visual_heading_yaw(), Vector3.RIGHT))

	player.velocity = Vector3(0.0, 0.0, -6.0)
	football._update_avatar_states(0.5)
	assert_true(_track03l_visual_yaw_faces_direction(player.rotation.y + avatar.debug_get_visual_heading_yaw(), Vector3.FORWARD))

	var held_heading: float = avatar.debug_get_visual_heading_yaw()
	player.velocity = Vector3.ZERO
	football._update_avatar_states(0.5)
	assert_almost_eq(avatar.debug_get_visual_heading_yaw(), held_heading, 0.001)
	assert_no_new_orphans()

func test_football_player_avatar_base_model_shows_back_to_chase_camera_after_forward_move() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var avatar = football.debug_get_player_avatar()
	player.rotation.y = 0.0
	player.velocity = Vector3(0.0, 0.0, -6.0)
	football._update_avatar_states(0.5)
	player.velocity = Vector3.ZERO
	football._update_avatar_states(0.5)
	avatar.set_move_state(0.0, true, 0.0)

	assert_almost_eq(absf(wrapf(avatar.debug_get_model_forward_compensation_yaw(), -PI, PI)), PI, 0.01)
	assert_eq(avatar.debug_get_animation_state(), &"idle")
	assert_gt(avatar.debug_get_model_front_direction().dot(Vector3.FORWARD), cos(deg_to_rad(15.0)))
	assert_gt((-avatar.debug_get_model_front_direction()).dot(Vector3.BACK), cos(deg_to_rad(15.0)))
	assert_no_new_orphans()

func test_football_chase_camera_keeps_ball_focus_subtle_when_far() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var chase_camera = football.debug_get_chase_camera()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	football.debug_force_ball_position(Vector3(0.0, 0.58, -1.0))
	chase_camera.snap_to_target()
	var close_weight: float = chase_camera.debug_get_ball_focus_weight()
	football.debug_force_ball_position(Vector3(0.0, 0.58, -16.0))
	chase_camera.snap_to_target()
	var far_weight: float = chase_camera.debug_get_ball_focus_weight()

	assert_gt(far_weight, close_weight)
	assert_true(far_weight <= 0.11)
	assert_no_new_orphans()

func test_football_intro_cycles_avatar_skin_and_country_kit() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var avatar = football.debug_get_player_avatar()
	var hud = football.get_node("FootballHud")
	assert_eq(football.debug_get_selected_skin_tone_id(), &"tan")
	assert_eq(football.debug_get_selected_country_kit_id(), &"brazil")
	assert_eq(avatar.debug_get_part_albedo_color(&"torso"), AvatarCatalogScript.get_kit_primary_color(&"brazil"))

	football.debug_cycle_skin_tone(1)
	football.debug_cycle_country_kit(1)

	assert_eq(football.debug_get_selected_skin_tone_id(), &"brown")
	assert_eq(football.debug_get_selected_country_kit_id(), &"argentina")
	assert_eq(avatar.debug_get_skin_tone_id(), &"brown")
	assert_eq(avatar.debug_get_country_kit_id(), &"argentina")
	assert_true(hud.skin_tone_label.text.contains("Pele morena"))
	assert_true(hud.country_kit_label.text.contains("Argentina"))
	assert_no_new_orphans()

func test_football_intro_avatar_selection_persists_between_session_rematches() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	football.debug_cycle_skin_tone(1)
	football.debug_cycle_country_kit(1)
	football.restart_match()
	await get_tree().process_frame

	assert_eq(football.debug_get_selected_skin_tone_id(), &"brown")
	assert_eq(football.debug_get_selected_country_kit_id(), &"argentina")
	assert_eq(football.debug_get_player_avatar().debug_get_skin_tone_id(), &"brown")
	assert_eq(football.debug_get_player_avatar().debug_get_country_kit_id(), &"argentina")
	assert_no_new_orphans()

func test_football_player_near_ball_stays_loose_without_dribble_lock() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	player.global_position = Vector3(0.0, 0.05, 4.0)
	player.rotation = Vector3.ZERO
	player.velocity = Vector3(0.0, 0.0, -6.0)
	football.debug_force_ball_position(player.global_position + Vector3(0.0, 0.53, -1.0))
	var before_kicks: int = ball.debug_get_kick_count()
	var before_dribbles: int = ball.debug_get_dribble_control_count()

	football.debug_update_player_ball_control(0.1)

	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_eq(ball.debug_get_dribble_control_count(), before_dribbles)
	assert_eq(football.debug_get_player_ball_control_state(), &"contact")
	assert_almost_eq(ball.linear_velocity.length(), 0.0, 0.001)
	assert_no_new_orphans()

func test_football_ball_ground_grip_slows_roll_without_air_drag() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var ball = football.debug_get_ball()
	ball.global_position = Vector3(0.0, 0.58, 0.0)
	ball.linear_velocity = Vector3(12.0, 0.1, 0.0)
	assert_true(ball.debug_is_ground_rolling())
	ball.debug_apply_ground_roll_drag(0.25)
	var ground_speed := Vector2(ball.linear_velocity.x, ball.linear_velocity.z).length()
	assert_lt(ground_speed, 9.0)

	ball.global_position = Vector3(0.0, 2.4, 0.0)
	ball.linear_velocity = Vector3(12.0, 0.1, 0.0)
	assert_false(ball.debug_is_ground_rolling())
	ball.debug_apply_ground_roll_drag(0.25)
	var air_speed := Vector2(ball.linear_velocity.x, ball.linear_velocity.z).length()
	assert_almost_eq(air_speed, 12.0, 0.001)
	assert_no_new_orphans()

func test_football_player_boost_spends_stamina() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var before_stamina: float = player.debug_get_boost_stamina()
	Input.action_press("move_forward")
	Input.action_press("boost")
	await get_tree().physics_frame
	Input.action_release("move_forward")
	Input.action_release("boost")

	assert_lt(player.debug_get_boost_stamina(), before_stamina)
	assert_lt(football.debug_get_player_boost_fraction(), 1.0)
	assert_no_new_orphans()

func test_football_kickoff_countdown_locks_ball_interaction() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match_with_countdown()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	var before_kicks: int = ball.debug_get_kick_count()
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0)

	assert_true(football.debug_is_kickoff_locked())
	assert_eq(ball.debug_get_kick_count(), before_kicks)
	football.debug_finish_kickoff_countdown()
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks + 1)
	assert_no_new_orphans()

func test_football_player_kick_assist_connects_near_front_side_ball() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	var origin: Vector3 = football.debug_get_player_kick_origin()
	var direction: Vector3 = football.debug_get_player_kick_direction()
	football.debug_force_ball_position(origin + direction * 2.05 + Vector3.RIGHT * 1.05 + Vector3.DOWN * 0.34)

	var before_kicks: int = ball.debug_get_kick_count()
	football._on_player_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 99.0, 99.0)

	assert_eq(ball.debug_get_kick_count(), before_kicks + 1)
	assert_almost_eq(ball.debug_get_last_kick_force(), 20.5, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 2.35, 0.01)
	assert_gt(ball.linear_velocity.y, 2.0)
	assert_gt(football.debug_get_last_kick_assist_strength(), 0.0)
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"kick")
	assert_no_new_orphans()

func test_football_charged_kick_preserves_tap_and_scales_hold() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var ball = football.debug_get_ball()
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_charged_kick_requested(Vector3.ZERO, Vector3.FORWARD, 0.0, 0.1)

	assert_almost_eq(ball.debug_get_last_kick_force(), 20.5, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 2.35, 0.01)

	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_charged_kick_requested(Vector3.ZERO, Vector3.FORWARD, 1.0, 0.8)

	assert_almost_eq(ball.debug_get_last_kick_force(), 31.775, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 3.45, 0.01)
	assert_no_new_orphans()

func test_football_strong_kick_uses_stronger_force() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	var hud = football.get_node("FootballHud")
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_almost_eq(ball.debug_get_last_kick_force(), 29.0, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 7.2, 0.01)
	assert_gt(ball.linear_velocity.y, 6.5)
	assert_eq(hud.last_event, &"strong_kick")
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"strong_kick")
	assert_gt(ball.linear_velocity.length(), 0.1)
	assert_no_new_orphans()

func test_football_super_shot_is_once_per_kickoff() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	football.debug_set_player_super_meter(100.0)
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_almost_eq(ball.debug_get_last_kick_force(), 38.5, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 9.4, 0.01)
	assert_almost_eq(football.debug_get_player_super_meter(), 0.0, 0.01)
	assert_true(football.debug_player_super_used_this_kickoff())

	football.debug_set_player_super_meter(100.0)
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_almost_eq(ball.debug_get_last_kick_force(), 29.0, 0.01)
	assert_almost_eq(ball.linear_velocity.y, 7.2, 0.01)
	assert_no_new_orphans()

func test_football_super_whiff_does_not_consume_meter_or_kickoff_use() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var ball = football.debug_get_ball()
	football.debug_set_player_super_meter(100.0)
	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 24.0 + Vector3.DOWN * 0.34)
	var before_kicks: int = ball.debug_get_kick_count()
	football._on_player_strong_kick_requested(player.get_shot_origin(), player.get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_almost_eq(football.debug_get_player_super_meter(), 100.0, 0.01)
	assert_false(football.debug_player_super_used_this_kickoff())
	assert_no_new_orphans()

func test_football_ball_fireball_uses_speed_hysteresis() -> void:
	var ball = FootballBallScript.new()
	add_child_autofree(ball)
	await get_tree().process_frame

	ball.linear_velocity = Vector3(25.0, 0.0, 0.0)
	ball.debug_update_visual_asset(0.1)
	assert_true(ball.debug_is_fireball_active())

	ball.linear_velocity = Vector3(22.0, 0.0, 0.0)
	ball.debug_update_visual_asset(0.1)
	assert_true(ball.debug_is_fireball_active())

	ball.linear_velocity = Vector3(20.0, 0.0, 0.0)
	ball.debug_update_visual_asset(0.1)
	assert_false(ball.debug_is_fireball_active())
	assert_no_new_orphans()

func test_football_boost_pads_respawn_and_restore_stamina() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var small_pad := football.get_node("BoostPadSmall0") as Area3D
	var large_pad := football.get_node("BoostPadLarge0") as Area3D
	bot.global_position = Vector3(0.0, 0.05, 16.0)

	player.debug_set_boost_stamina(40.0)
	player.global_position = small_pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.1)

	assert_almost_eq(player.debug_get_boost_stamina(), 65.0, 0.01)
	assert_false(bool(small_pad.get_meta("active", true)))
	football.debug_update_arcade_field(3.8)
	assert_false(bool(small_pad.get_meta("active", true)))
	football.debug_update_arcade_field(0.3)
	assert_true(bool(small_pad.get_meta("active", false)))

	player.debug_set_boost_stamina(12.0)
	player.global_position = large_pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.1)

	assert_almost_eq(player.debug_get_boost_stamina(), 100.0, 0.01)
	assert_false(bool(large_pad.get_meta("active", true)))
	assert_no_new_orphans()

func test_football_bot_collects_route_boost_pad() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	var player = football.debug_get_player()
	var pad := football.get_node("BoostPadSmall1") as Area3D
	player.global_position = Vector3(-14.0, 0.05, 16.0)
	bot.global_position = pad.global_position + Vector3(0.0, 0.0, -4.0)
	football.debug_force_ball_position(pad.global_position + Vector3(0.0, 0.6, 4.5))
	bot._physics_process(0.1)

	assert_eq(bot.debug_get_last_approach_label(), &"boost_pad")
	bot.global_position = pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.1)

	assert_eq(bot.debug_get_boost_pad_collect_count(), 1)
	assert_false(bool(pad.get_meta("active", true)))
	assert_no_new_orphans()

func test_football_jump_pad_launches_characters_not_ball() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	var jump_pad := football.get_node("JumpPadNorth") as Area3D
	football.debug_force_ball_position(jump_pad.global_position + Vector3(0.0, 0.58, 0.0))
	var before_kicks: int = ball.debug_get_kick_count()
	var before_player_launches: int = player.debug_get_jump_pad_launch_count()

	player.global_position = jump_pad.global_position + Vector3.UP * 0.05
	bot.global_position = Vector3(12.0, 0.05, 12.0)
	football.debug_update_arcade_field(0.1)

	assert_eq(player.debug_get_jump_pad_launch_count(), before_player_launches + 1)
	assert_eq(football.debug_get_feedback().debug_get_last_audio_event(), &"ui_confirmation")
	assert_gt(player.debug_get_vertical_velocity(), 8.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_almost_eq(ball.linear_velocity.length(), 0.0, 0.001)

	player.global_position = Vector3(-12.0, 0.05, 12.0)
	bot.global_position = jump_pad.global_position + Vector3.UP * 0.05
	football.debug_update_arcade_field(0.8)
	football.debug_update_arcade_field(0.1)

	assert_gt(bot.debug_get_vertical_velocity(), 8.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks)
	assert_no_new_orphans()

func test_football_bot_approaches_behind_ball_before_attacking() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	football.debug_force_ball_position(Vector3(0.0, 0.58, 0.0))
	await get_tree().physics_frame

	assert_eq(bot.debug_get_last_approach_label(), &"chase_setup")
	assert_lt(bot.debug_get_last_move_target().z, football.debug_get_ball().global_position.z)
	assert_no_new_orphans()

func test_football_bot_uses_prediction_difficulty_and_boost() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.set_bot_difficulty(&"hard")
	football.debug_force_ball_position(Vector3(0.0, 0.58, 0.0))
	ball.linear_velocity = Vector3(8.0, 0.0, 0.0)
	bot._physics_process(0.1)

	assert_eq(football.debug_get_bot_difficulty_id(), &"hard")
	assert_eq(bot.debug_get_difficulty_id(), &"hard")
	assert_lt(bot.debug_get_aim_error_radius(), 0.2)
	assert_gt(bot.debug_get_last_predicted_ball_position().x, ball.global_position.x)
	assert_true(bot.debug_is_boosting())
	assert_no_new_orphans()

func test_football_arcade_dash_spends_stamina_and_slides_ball_with_stun() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	bot.global_position = Vector3(0.0, 0.05, -0.92)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -1.1))
	var before_stamina: float = player.debug_get_boost_stamina()
	var before_kicks: int = ball.debug_get_kick_count()

	assert_true(player.request_arcade_dash(Vector3.FORWARD))
	football.debug_process_arcade_action_contacts()

	assert_eq(player.debug_get_arcade_dash_count(), 1)
	assert_lt(player.debug_get_boost_stamina(), before_stamina)
	assert_gt(football.debug_get_player_dash_cooldown_fraction(), 0.0)
	assert_eq(ball.debug_get_kick_count(), before_kicks + 1)
	assert_almost_eq(ball.debug_get_last_kick_force(), 7.2, 0.01)
	assert_gt(bot.debug_get_arcade_stun_remaining(), 0.0)
	assert_gt(bot.debug_get_knockback_event_count(), 0)
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"slide")
	assert_no_new_orphans()

func test_football_arcade_dash_peak_is_at_least_one_and_half_boost_run_speed() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	var boosted_player_speed: float = player.move_speed * player.boost_speed_multiplier
	var boosted_bot_speed: float = bot.move_speed * bot.boost_speed_multiplier

	assert_true(PlayerControllerScript.ARCADE_DASH_SPEED >= boosted_player_speed * 1.5)
	assert_true(FootballBotScript.ARCADE_DASH_SPEED >= boosted_player_speed * 1.5)
	assert_gt(FootballBotScript.ARCADE_DASH_SPEED, boosted_bot_speed)
	assert_almost_eq(PlayerControllerScript.ARCADE_DASH_DURATION, 0.28, 0.001)
	assert_almost_eq(FootballBotScript.ARCADE_DASH_DURATION, 0.28, 0.001)
	assert_almost_eq(player.debug_get_arcade_dash_distance(), TRACK04B2_DASH_BASELINE_DISTANCE, TRACK04B2_DASH_DISTANCE_TOLERANCE)
	assert_almost_eq(bot.debug_get_arcade_dash_distance(), player.debug_get_arcade_dash_distance(), 0.001)
	assert_almost_eq(bot.debug_get_arcade_dash_peak_speed(), player.debug_get_arcade_dash_peak_speed(), 0.001)
	assert_no_new_orphans()

func test_football_arcade_dash_curve_accelerates_and_preserves_total_distance() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	var bot = football.debug_get_bot()
	player.global_position = Vector3.ZERO
	player.rotation = Vector3.ZERO
	player.velocity = Vector3.ZERO
	player.clear_movement_impulses()
	player.debug_set_boost_stamina(100.0)
	var first_frame_speed: float = player.debug_get_arcade_dash_average_speed_for_frame(1.0 / 60.0)
	var peak_speed: float = player.debug_get_arcade_dash_peak_speed()
	var start_position: Vector3 = player.global_position

	assert_true(player.request_arcade_dash(Vector3.RIGHT))
	var max_observed_speed := 0.0
	for _frame in range(40):
		await get_tree().physics_frame
		var flat_speed := Vector2(player.velocity.x, player.velocity.z).length()
		max_observed_speed = maxf(max_observed_speed, flat_speed)
		if not player.is_arcade_dashing():
			break

	var traveled := _flat_xz_distance(start_position, player.global_position)
	assert_lt(first_frame_speed, peak_speed)
	assert_gt(max_observed_speed, first_frame_speed)
	assert_almost_eq(traveled, TRACK04B2_DASH_BASELINE_DISTANCE, TRACK04B2_DASH_DISTANCE_TOLERANCE)
	assert_lt(bot.debug_get_arcade_dash_average_speed_for_frame(1.0 / 60.0), bot.debug_get_arcade_dash_peak_speed())
	assert_no_new_orphans()

func test_football_arcade_flip_consumes_once_and_resets_for_floor() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	player.global_position.y = 2.0
	player.debug_force_arcade_flip_available(true)
	await get_tree().physics_frame

	assert_true(player.request_arcade_flip(Vector3.FORWARD))
	assert_eq(player.debug_get_arcade_flip_count(), 1)
	assert_false(player.debug_is_arcade_flip_available())
	assert_false(player.request_arcade_flip(Vector3.FORWARD))
	player.debug_reset_arcade_flip_for_floor()
	assert_true(player.debug_is_arcade_flip_available())
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"flip")
	assert_no_new_orphans()

func test_football_stationary_jump_and_double_flip_stay_vertical() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	player.global_position = Vector3(2.0, 0.08, 2.0)
	player.rotation = Vector3.ZERO
	player.clear_movement_impulses()
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")
	var jump_start := Vector3(2.0, 0.08, 2.0)
	await _wait_until_character_lands(player)

	assert_lte(_flat_xz_distance(jump_start, player.global_position), TRACK04B2_STATIONARY_JUMP_MAX_XZ_DRIFT)

	player.global_position = Vector3(4.0, 2.2, 4.0)
	player.velocity = Vector3.ZERO
	player.clear_movement_impulses()
	player.debug_force_arcade_flip_available(true)
	for _frame in range(6):
		await get_tree().physics_frame
		if not player.is_on_floor():
			break
	var flip_start: Vector3 = player.global_position
	assert_true(player.request_arcade_flip())
	assert_almost_eq(Vector2(player.debug_get_launch_boost_velocity().x, player.debug_get_launch_boost_velocity().z).length(), 0.0, 0.001)
	await _wait_until_character_lands(player)

	assert_lte(_flat_xz_distance(flip_start, player.global_position), TRACK04B2_STATIONARY_JUMP_MAX_XZ_DRIFT)
	assert_no_new_orphans()

func test_football_jump_with_forward_input_moves_forward() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var player = football.debug_get_player()
	player.global_position = Vector3(0.0, 0.08, 4.0)
	player.rotation = Vector3.ZERO
	player.clear_movement_impulses()
	var start_position: Vector3 = player.global_position
	Input.action_press("move_forward")
	Input.action_press("jump")
	await get_tree().physics_frame
	Input.action_release("jump")
	await _wait_until_character_lands(player)
	Input.action_release("move_forward")

	assert_lt(player.global_position.z, start_position.z - 0.4)
	assert_lt(absf(player.global_position.x - start_position.x), 0.12)
	assert_no_new_orphans()

func test_football_bot_flip_uses_vertical_only_without_target_direction() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	bot.velocity = Vector3.ZERO
	bot.clear_movement_impulses()
	bot.debug_force_arcade_flip_available(true)
	assert_true(bot.debug_request_arcade_flip(Vector3.ZERO))

	assert_gt(bot.debug_get_vertical_velocity(), 0.0)
	assert_almost_eq(Vector2(bot.debug_get_arcade_flip_boost_velocity().x, bot.debug_get_arcade_flip_boost_velocity().z).length(), 0.0, 0.001)

	bot.velocity = Vector3.ZERO
	bot.clear_movement_impulses()
	bot.debug_force_arcade_flip_available(true)
	assert_true(bot.debug_request_arcade_flip(Vector3.FORWARD))

	assert_lt(bot.debug_get_arcade_flip_boost_velocity().z, -1.0)
	assert_no_new_orphans()

func test_football_bot_uses_arcade_dash_for_defense() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.set_bot_difficulty(&"hard")
	bot.global_position = Vector3(8.0, 0.05, -18.0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -20.0))
	ball.linear_velocity = Vector3(0.0, 0.0, -8.0)
	bot._physics_process(0.1)

	assert_gt(bot.debug_get_arcade_dash_count(), 0)
	assert_true(bot.debug_is_arcade_dashing())
	assert_eq(football.debug_get_bot_avatar().debug_get_animation_state(), &"slide")
	assert_no_new_orphans()

func test_football_player_kickoff_bot_holds_defensive_line_until_first_touch() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match_with_countdown()
	football.debug_finish_kickoff_countdown()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	var hold_position: Vector3 = bot.global_position

	assert_eq(football.debug_get_kickoff_owner(), &"player")
	assert_true(football.debug_is_bot_kickoff_hold_active())
	assert_eq(football.debug_get_bot_last_approach_label(), &"kickoff_hold")
	assert_lt(bot.global_position.z, ball.global_position.z)
	assert_gt(bot.global_position.z, -27.0)
	bot._physics_process(0.3)
	assert_almost_eq(bot.global_position.z, hold_position.z, 0.05)

	football.debug_force_ball_position(football.debug_get_player_kick_origin() + football.debug_get_player_kick_direction() * 1.45 + Vector3.DOWN * 0.34)
	football._on_player_strong_kick_requested(football.debug_get_player().get_shot_origin(), football.debug_get_player().get_shot_direction(), 0.0, 0.0, 0.0, 0.0, false)

	assert_false(football.debug_is_bot_kickoff_hold_active())
	assert_eq(football.debug_get_bot_last_approach_label(), &"kickoff_released")
	assert_gt(ball.linear_velocity.length(), 0.1)
	assert_no_new_orphans()

func test_football_bot_aerial_goal_defense_uses_difficulty_delay_and_jump() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.set_bot_difficulty(&"easy")
	bot.global_position = Vector3(0.0, 0.05, -25.6)
	football.debug_force_ball_position(Vector3(0.0, 3.2, -5.0))
	ball.linear_velocity = Vector3(0.0, 3.5, -18.0)
	bot._physics_process(0.1)

	assert_eq(bot.debug_get_last_approach_label(), &"aerial_delay")
	assert_gt(bot.debug_get_aerial_defense_delay_remaining(), 0.2)

	football.set_bot_difficulty(&"hard")
	football.debug_force_ball_position(Vector3(0.0, 3.2, -5.0))
	ball.linear_velocity = Vector3(0.0, 3.5, -18.0)
	bot.global_position = Vector3(0.0, 0.05, -25.6)
	bot._physics_process(0.1)

	assert_eq(bot.debug_get_last_approach_label(), &"aerial_goal_defense")
	assert_gt(bot.debug_get_vertical_velocity(), 0.0)
	assert_no_new_orphans()

func test_football_uses_main_menu_bot_difficulty_in_hud() -> void:
	get_tree().root.set_meta(BOT_DIFFICULTY_META_KEY, &"hard")
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var hud = football.get_node("FootballHud")
	hud.update_snapshot(football.debug_build_hud_snapshot())

	assert_eq(football.debug_get_bot_difficulty_id(), &"hard")
	assert_eq(football.debug_get_bot().debug_get_difficulty_id(), &"hard")
	assert_true(hud.flow_label.text.contains("Bot hard"))
	assert_no_new_orphans()

func test_football_kickoff_alternates_after_goal_reset() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()

	assert_eq(football.debug_get_kickoff_owner(), &"player")
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._physics_process(0.1)
	assert_eq(football.debug_get_player_score(), 1)
	football._physics_process(1.3)

	assert_eq(football.debug_get_kickoff_owner(), &"bot")
	assert_lt(football.debug_get_ball().global_position.z, 0.0)
	assert_true(football.debug_is_kickoff_locked())
	assert_no_new_orphans()

func test_football_bot_kickoff_camera_starts_outside_goal_shell() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	football.debug_set_kickoff_owner(&"bot")
	football._restart_play(false)
	football.debug_start_match_with_countdown()
	await get_tree().physics_frame

	assert_eq(football.debug_get_kickoff_owner(), &"bot")
	assert_false(football.debug_is_camera_inside_goal_shell())
	assert_true(football.debug_is_kickoff_locked())
	assert_no_new_orphans()

func test_football_kickoff_marker_tracks_ball_spawn_and_safe_reset_unfreezes() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var ball = football.debug_get_ball()
	football.debug_set_kickoff_owner(&"bot")
	football._restart_play(false)

	assert_true(football.debug_is_kickoff_marker_visible())
	assert_almost_eq(football.debug_get_kickoff_marker_position().z, -9.0, 0.01)
	assert_almost_eq(ball.global_position.z, -9.0, 0.01)
	assert_almost_eq(ball.linear_velocity.length(), 0.0, 0.001)
	assert_almost_eq(ball.angular_velocity.length(), 0.0, 0.001)
	await get_tree().process_frame
	assert_false(ball.freeze)
	assert_no_new_orphans()

func test_football_goal_updates_score_and_match_ends_at_three() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"goals")
	football.debug_start_match()
	await get_tree().physics_frame

	football.debug_set_score(2, 0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_eq(football.debug_get_player_score(), 3)
	assert_eq(football.debug_get_bot_score(), 0)
	assert_true(football.debug_is_match_over())
	assert_eq(football.get_node("FootballHud").last_event, &"match_end")
	var football_hud = football.get_node("FootballHud")
	assert_true(football_hud.debug_is_result_panel_visible())
	assert_eq(football_hud.debug_get_result_title(), "VITORIA")
	assert_true(football_hud.debug_get_result_stats_text().contains("Gols por periodo"))
	assert_true(football_hud.debug_get_result_stats_text().contains("Chutes"))
	assert_true(football_hud.debug_get_result_stats_text().contains("Posse por toques"))
	assert_not_null(football_hud.get_node_or_null("HudRoot/ResultCenter/ResultPanel/ResultMargin/ResultBox/ResultButtons/RematchButton"))
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"celebrate")
	assert_true(football.debug_is_goal_slowmo_active())
	assert_true(football.debug_get_chase_camera().debug_is_goal_focus_active())
	assert_no_new_orphans()

func test_football_timer_mode_enters_golden_goal_and_next_goal_wins() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"timer")
	football.debug_start_match()
	await get_tree().physics_frame

	football.debug_set_score(1, 1)
	football.debug_set_match_time_remaining(0.05)
	football._physics_process(0.1)

	assert_true(football.debug_is_golden_goal_active())
	assert_false(football.debug_is_match_over())
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"golden_goal")

	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_eq(football.debug_get_player_score(), 2)
	assert_eq(football.debug_get_bot_score(), 1)
	assert_eq(football.debug_get_last_goal_value(), 1)
	assert_true(football.debug_is_match_over())
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"match_end")
	assert_no_new_orphans()

func test_football_timer_mode_goal_counts_double_in_final_30_seconds() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"timer")
	football.debug_start_match()
	await get_tree().physics_frame
	(football.get_node("FootballHud") as FootballHud).reset_feedback()

	football.debug_set_match_time_remaining(29.0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_eq(football.debug_get_player_score(), 2)
	assert_eq(football.debug_get_last_goal_value(), 2)
	assert_false(football.debug_is_match_over())
	assert_eq((football.get_node("FootballHud") as FootballHud).last_event, &"double_goal")
	assert_true((football.get_node("FootballHud") as FootballHud).debug_get_event_text().contains("VALE 2"))
	assert_no_new_orphans()

func test_football_root_collects_match_stats_for_result_screen() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_set_match_mode(&"goals")
	football.debug_start_match()
	await get_tree().physics_frame

	football._notify_ball_touched_by(&"player")
	football._notify_ball_touched_by(&"player")
	football._notify_ball_touched_by(&"bot")
	football._record_shot_stat(&"player", true)
	football._record_shot_stat(&"bot", false)
	football.debug_set_score(2, 0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()
	var summary: Dictionary = football.debug_get_match_stats_summary()
	var stats_text := (football.get_node("FootballHud") as FootballHud).debug_get_result_stats_text()

	assert_eq(summary.get("player_touches", -1), 2)
	assert_eq(summary.get("bot_touches", -1), 1)
	assert_eq(summary.get("player_shots", -1), 1)
	assert_eq(summary.get("bot_shots", -1), 1)
	assert_eq(summary.get("player_supers", -1), 1)
	assert_eq(summary.get("longest_touch_team", &"none"), &"player")
	assert_true(stats_text.contains("SUPERS usados"))
	assert_true(stats_text.contains("Maior sequencia"))
	assert_no_new_orphans()

func test_football_escape_targets_intro_pause_and_result_menu() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	assert_eq(football.debug_get_escape_target(), &"menu")
	football.debug_start_match()
	await get_tree().physics_frame
	assert_eq(football.debug_get_escape_target(), &"pause")
	football.debug_set_match_mode(&"goals")
	football.debug_set_score(2, 0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()

	assert_true(football.debug_is_match_over())
	assert_eq(football.debug_get_escape_target(), &"menu")
	assert_no_new_orphans()

func test_football_restart_cleans_countdown_golden_goal_and_slowmo() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	football.debug_start_match_with_countdown()
	assert_true(football.debug_is_kickoff_locked())
	football.restart_match()
	assert_eq(football.debug_get_player_score(), 0)
	assert_eq(football.debug_get_bot_score(), 0)
	assert_false(football.debug_is_golden_goal_active())
	assert_false(football.debug_is_goal_slowmo_active())
	assert_true(football.debug_is_kickoff_locked())

	football.debug_set_match_mode(&"timer")
	football.debug_start_match()
	football.debug_set_score(1, 1)
	football.debug_set_match_time_remaining(0.05)
	football._physics_process(0.1)
	assert_true(football.debug_is_golden_goal_active())
	football.restart_match()
	assert_false(football.debug_is_golden_goal_active())
	assert_eq(Engine.time_scale, 1.0)

	football.debug_start_match()
	football.debug_set_match_mode(&"goals")
	football.debug_set_score(0, 0)
	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()
	assert_true(football.debug_is_goal_slowmo_active())
	football.restart_match()

	assert_false(football.debug_is_goal_slowmo_active())
	assert_eq(Engine.time_scale, 1.0)
	assert_eq(football.debug_get_player_score(), 0)
	assert_eq(football.debug_get_bot_score(), 0)
	assert_no_new_orphans()

func test_football_arcade_emote_only_triggers_after_goal() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var feedback = football.debug_get_feedback()
	football.debug_trigger_arcade_emote(true)
	assert_eq(feedback.debug_get_confetti_count(), 0)

	football.debug_force_ball_position(Vector3(0.0, 0.68, -27.35))
	football._process_goal_detection()
	var confetti_after_goal: int = feedback.debug_get_confetti_count()
	football.debug_trigger_arcade_emote(true)

	assert_eq(feedback.debug_get_confetti_count(), confetti_after_goal + 1)
	assert_eq(football.debug_get_player_avatar().debug_get_animation_state(), &"celebrate")
	assert_no_new_orphans()

func test_football_toon_render_toggle_is_off_by_default_and_isolated() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var player_avatar = football.debug_get_player_avatar()
	var bot_avatar = football.debug_get_bot_avatar()
	var ball = football.debug_get_ball()

	assert_false(football.debug_is_toon_render_enabled())
	assert_eq(player_avatar.debug_get_toon_outline_count(), 0)
	assert_eq(bot_avatar.debug_get_toon_outline_count(), 0)
	assert_false(ball.debug_has_toon_outline())

	football.debug_set_toon_render_enabled(true)

	assert_true(football.debug_is_toon_render_enabled())
	assert_true(player_avatar.debug_is_toon_render_enabled())
	assert_true(bot_avatar.debug_is_toon_render_enabled())
	assert_true(ball.debug_is_toon_render_enabled())
	assert_gt(player_avatar.debug_get_toon_outline_count(), 0)
	assert_gt(bot_avatar.debug_get_toon_outline_count(), 0)
	assert_true(ball.debug_has_toon_outline())

	football.debug_set_toon_render_enabled(false)

	assert_false(player_avatar.debug_is_toon_render_enabled())
	assert_false(ball.debug_is_toon_render_enabled())
	assert_eq(player_avatar.debug_get_toon_outline_count(), 0)
	assert_false(ball.debug_has_toon_outline())
	assert_no_new_orphans()

func test_football_feedback_exposes_boost_and_skid_vfx() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var avatar = football.debug_get_player_avatar()
	var feedback = football.debug_get_feedback()
	assert_true(avatar.debug_has_persistent_vfx())

	avatar.set_boost_trail_active(true)
	avatar.set_skid_dust_active(true)

	assert_true(avatar.debug_is_boost_trail_emitting())
	assert_true(avatar.debug_is_skid_dust_emitting())
	assert_eq(feedback.debug_active_effect_count(), 0)
	assert_no_new_orphans()

func test_football_feedback_uses_real_audio_pools_and_synthetic_whistle() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame

	var feedback = football.debug_get_feedback()
	assert_true(feedback.debug_has_real_audio())
	assert_eq(feedback.debug_get_sfx_pool_size(), 14)
	assert_eq(feedback.debug_get_ui_pool_size(), 8)
	assert_true(feedback.debug_is_ambience_playing())

	feedback.play_football_kick(Vector3.ZERO, Vector3.FORWARD, false)
	assert_eq(feedback.debug_get_last_audio_event(), &"kick")
	feedback.play_ball_glass(Vector3.ZERO)
	assert_eq(feedback.debug_get_last_audio_event(), &"ball_glass")
	feedback.play_countdown_tick(true)
	assert_eq(feedback.debug_get_last_audio_event(), &"ui_confirmation")

	var before_whistles: int = feedback.debug_get_synthetic_whistle_count()
	feedback.play_referee_whistle(Vector3.ZERO)
	assert_eq(feedback.debug_get_synthetic_whistle_count(), before_whistles + 1)
	assert_eq(feedback.debug_get_last_audio_event(), &"synthetic_whistle")
	assert_no_new_orphans()

func test_football_bot_kick_request_moves_ball() -> void:
	var football_scene := load("res://modes/football/football.tscn") as PackedScene
	var football := football_scene.instantiate()
	add_child_autofree(football)
	await get_tree().process_frame
	football.debug_start_match()
	await get_tree().physics_frame

	var bot = football.debug_get_bot()
	var ball = football.debug_get_ball()
	football.debug_force_ball_position(bot.global_position + Vector3(0.0, 0.55, 1.1))
	football._on_bot_kick_requested(bot.global_position + Vector3.UP * 0.9, Vector3.BACK, 11.0, 0.7)

	assert_eq(ball.debug_get_kick_count(), 1)
	assert_almost_eq(ball.debug_get_last_kick_force(), 11.0, 0.01)
	assert_eq(football.debug_get_bot_avatar().debug_get_animation_state(), &"kick")
	assert_gt(ball.linear_velocity.length(), 0.1)
	assert_no_new_orphans()

func _collect_arena_seal_leaks(football: Node3D) -> Dictionary:
	var config: Dictionary = football.debug_get_arena_config()
	var field_half_width := float(config.get("field_width", 38.0)) * 0.5
	var ceiling_height := float(config.get("ceiling_height", 8.8))
	var goal_half_width := float(config.get("goal_half_width", 4.32))
	var goal_height := float(config.get("goal_height", 3.45))
	var goal_side_wall_x := float(config.get("goal_side_wall_x", goal_half_width + 0.72))
	var goal_closed_depth := float(config.get("goal_closed_depth", 3.8))
	var goal_line_north := float(config.get("goal_line_north", -27.0))
	var goal_line_south := float(config.get("goal_line_south", 27.0))
	var total_min_z := goal_line_north - goal_closed_depth + 0.15
	var total_max_z := goal_line_south + goal_closed_depth - 0.15
	var y_samples := _sample_track03l_range(0.25, ceiling_height - 0.05, TRACK03L_SEAL_GRID_STEP)
	var leaks: Dictionary = {"count": 0, "samples": PackedStringArray()}
	var space_state := football.get_world_3d().direct_space_state

	for y: float in y_samples:
		for z: float in _sample_track03l_range(total_min_z, total_max_z, TRACK03L_SEAL_GRID_STEP):
			_record_track03l_arena_ray(leaks, space_state, Vector3(-field_half_width + 0.55, y, z), Vector3(-field_half_width - 1.1, y, z), "west-wall")
			_record_track03l_arena_ray(leaks, space_state, Vector3(field_half_width - 0.55, y, z), Vector3(field_half_width + 1.1, y, z), "east-wall")

	var end_ranges: Array[Vector2] = [
		Vector2(-field_half_width + 0.55, -goal_side_wall_x - 0.15),
		Vector2(goal_side_wall_x + 0.15, field_half_width - 0.55)
	]
	for y: float in y_samples:
		for end_range: Vector2 in end_ranges:
			for x: float in _sample_track03l_range(end_range.x, end_range.y, TRACK03L_SEAL_GRID_STEP):
				_record_track03l_arena_ray(leaks, space_state, Vector3(x, y, goal_line_north + 0.8), Vector3(x, y, goal_line_north - 1.1), "north-end")
				_record_track03l_arena_ray(leaks, space_state, Vector3(x, y, goal_line_south - 0.8), Vector3(x, y, goal_line_south + 1.1), "south-end")

	for y: float in y_samples:
		for x: float in _sample_track03l_range(-goal_half_width, goal_half_width, TRACK03L_SEAL_GRID_STEP):
			_record_track03l_arena_ray(leaks, space_state, Vector3(x, y, goal_line_north - goal_closed_depth + 0.55), Vector3(x, y, goal_line_north - goal_closed_depth - 1.0), "north-goal-back")
			_record_track03l_arena_ray(leaks, space_state, Vector3(x, y, goal_line_south + goal_closed_depth - 0.55), Vector3(x, y, goal_line_south + goal_closed_depth + 1.0), "south-goal-back")

	for y: float in _sample_track03l_range(goal_height + 0.25, ceiling_height - 0.05, TRACK03L_SEAL_GRID_STEP):
		for x: float in _sample_track03l_range(-goal_half_width, goal_half_width, TRACK03L_SEAL_GRID_STEP):
			_record_track03l_arena_ray(leaks, space_state, Vector3(x, y, goal_line_north + 0.8), Vector3(x, y, goal_line_north - 1.1), "north-goal-front-top")
			_record_track03l_arena_ray(leaks, space_state, Vector3(x, y, goal_line_south - 0.8), Vector3(x, y, goal_line_south + 1.1), "south-goal-front-top")

	for x: float in _sample_track03l_range(-field_half_width + 0.7, field_half_width - 0.7, TRACK03L_SEAL_GRID_STEP):
		for z: float in _sample_track03l_range(total_min_z + 0.7, total_max_z - 0.7, TRACK03L_SEAL_GRID_STEP):
			_record_track03l_arena_ray(leaks, space_state, Vector3(x, ceiling_height - 0.85, z), Vector3(x, ceiling_height + 0.85, z), "ceiling")

	return leaks

func _record_track03l_arena_ray(leaks: Dictionary, space_state: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3, label: String) -> void:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := space_state.intersect_ray(query)
	if not hit.is_empty():
		return
	leaks["count"] = int(leaks.get("count", 0)) + 1
	var samples := leaks.get("samples", PackedStringArray()) as PackedStringArray
	if samples.size() < 12:
		samples.append("%s from=%s to=%s" % [label, str(from), str(to)])
		leaks["samples"] = samples

func _format_arena_leak_samples(leak_report: Dictionary) -> String:
	var samples := leak_report.get("samples", PackedStringArray()) as PackedStringArray
	return "count=%d; %s" % [int(leak_report.get("count", 0)), " | ".join(samples)]

func _flat_xz_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x, a.z).distance_to(Vector2(b.x, b.z))

func _color_luma_255(color: Color) -> float:
	return ((0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b)) * 255.0

func _wait_until_character_lands(character: CharacterBody3D, max_frames: int = 180) -> void:
	var saw_airborne := false
	for _frame in range(max_frames):
		await get_tree().physics_frame
		if character == null:
			return
		if not character.is_on_floor():
			saw_airborne = true
		elif saw_airborne:
			return

func _sample_track03l_range(min_value: float, max_value: float, step: float) -> Array[float]:
	var values: Array[float] = []
	if max_value < min_value:
		return values
	var value := min_value
	while value <= max_value + 0.001:
		values.append(value)
		value += step
	if values.is_empty() or values[values.size() - 1] < max_value - 0.001:
		values.append(max_value)
	return values

func _build_track03l_tunneling_cases(config: Dictionary) -> Array[Dictionary]:
	var field_half_width := float(config.get("field_width", 38.0)) * 0.5
	var ceiling_height := float(config.get("ceiling_height", 8.8))
	var goal_height := float(config.get("goal_height", 3.45))
	var goal_line_north := float(config.get("goal_line_north", -27.0))
	var goal_line_south := float(config.get("goal_line_south", 27.0))
	return [
		{"label": "east-wall", "start": Vector3(field_half_width - 1.25, 1.4, 0.0), "velocity": Vector3(TRACK03L_MAX_TUNNELING_SPEED, 0.0, 0.0), "limit_axis": "x_max", "limit": field_half_width + 0.2},
		{"label": "west-wall", "start": Vector3(-field_half_width + 1.25, 1.4, 0.0), "velocity": Vector3(-TRACK03L_MAX_TUNNELING_SPEED, 0.0, 0.0), "limit_axis": "x_min", "limit": -field_half_width - 0.2},
		{"label": "ceiling", "start": Vector3(0.0, ceiling_height - 1.1, 0.0), "velocity": Vector3(0.0, TRACK03L_MAX_TUNNELING_SPEED, 0.0), "limit_axis": "y_max", "limit": ceiling_height + 0.2},
		{"label": "north-goal-front-top", "start": Vector3(0.0, goal_height + 0.95, goal_line_north + 1.3), "velocity": Vector3(0.0, 0.0, -TRACK03L_MAX_TUNNELING_SPEED), "limit_axis": "z_min", "limit": goal_line_north - 0.2},
		{"label": "south-goal-front-top", "start": Vector3(0.0, goal_height + 0.95, goal_line_south - 1.3), "velocity": Vector3(0.0, 0.0, TRACK03L_MAX_TUNNELING_SPEED), "limit_axis": "z_max", "limit": goal_line_south + 0.2},
	]

func _track03l_ball_stayed_inside_case(position: Vector3, case: Dictionary) -> bool:
	match str(case.get("limit_axis", "")):
		"x_max":
			return position.x <= float(case.get("limit", INF))
		"x_min":
			return position.x >= float(case.get("limit", -INF))
		"y_max":
			return position.y <= float(case.get("limit", INF))
		"z_max":
			return position.z <= float(case.get("limit", INF))
		"z_min":
			return position.z >= float(case.get("limit", -INF))
		_:
			return false

func _track03l_visual_yaw_faces_direction(yaw: float, expected_direction: Vector3) -> bool:
	var visual_forward := Vector3(-sin(yaw), 0.0, -cos(yaw)).normalized()
	var expected := Vector3(expected_direction.x, 0.0, expected_direction.z).normalized()
	return visual_forward.dot(expected) >= cos(deg_to_rad(15.0))
