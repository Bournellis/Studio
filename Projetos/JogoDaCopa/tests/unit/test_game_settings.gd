extends "res://addons/gut/test.gd"

const GameSettingsScript = preload("res://autoloads/game_settings.gd")
const RenderProfileScript = preload("res://autoloads/render_profile.gd")

const TEST_CONFIG_PATH: String = "user://jogodacopa_test_settings.cfg"

func before_each() -> void:
	_remove_test_config()
	RenderProfileScript.set_quality_id(RenderProfileScript.QUALITY_HIGH)

func after_each() -> void:
	_remove_test_config()
	RenderProfileScript.set_quality_id(RenderProfileScript.QUALITY_HIGH)

func test_settings_persist_audio_video_quality_and_sensitivity() -> void:
	var settings = GameSettingsScript.new()
	settings.set_config_path_for_tests(TEST_CONFIG_PATH)
	settings.set_volume(GameSettingsScript.BUS_MASTER, 0.35)
	settings.set_volume(GameSettingsScript.BUS_SFX, 0.45)
	settings.set_volume(GameSettingsScript.BUS_UI, 0.55)
	settings.set_volume(GameSettingsScript.BUS_AMBIENCE, 0.65)
	settings.set_fullscreen_enabled(true, true, false)
	settings.set_quality_id(RenderProfileScript.QUALITY_LIGHT)
	settings.set_mouse_sensitivity(0.0026)

	var loaded = GameSettingsScript.new()
	loaded.set_config_path_for_tests(TEST_CONFIG_PATH, false)
	assert_true(loaded.load_settings())

	assert_almost_eq(loaded.get_volume(GameSettingsScript.BUS_MASTER), 0.35, 0.001)
	assert_almost_eq(loaded.get_volume(GameSettingsScript.BUS_SFX), 0.45, 0.001)
	assert_almost_eq(loaded.get_volume(GameSettingsScript.BUS_UI), 0.55, 0.001)
	assert_almost_eq(loaded.get_volume(GameSettingsScript.BUS_AMBIENCE), 0.65, 0.001)
	assert_true(loaded.get_fullscreen_enabled())
	assert_eq(loaded.get_quality_id(), RenderProfileScript.QUALITY_LIGHT)
	assert_almost_eq(loaded.get_mouse_sensitivity(), 0.0026, 0.0001)
	settings.free()
	loaded.free()

func test_light_quality_uses_web_render_profile_contract_on_desktop() -> void:
	var settings = GameSettingsScript.new()
	settings.set_config_path_for_tests(TEST_CONFIG_PATH)
	settings.set_quality_id(RenderProfileScript.QUALITY_LIGHT, false)

	assert_eq(RenderProfileScript.get_quality_id(), RenderProfileScript.QUALITY_LIGHT)
	assert_eq(RenderProfileScript.get_profile_id_for_quality(RenderProfileScript.QUALITY_LIGHT, false), RenderProfileScript.PROFILE_WEB)
	assert_eq(RenderProfileScript.get_menu_preview_viewport_size(), RenderProfileScript.WEB_MENU_PREVIEW_VIEWPORT_SIZE)
	assert_eq(RenderProfileScript.get_scoreboard_viewport_size(), RenderProfileScript.WEB_SCOREBOARD_VIEWPORT_SIZE)
	assert_lt(RenderProfileScript.adjust_particle_amount(56), 56)

	settings.set_quality_id(RenderProfileScript.QUALITY_HIGH, false)
	assert_eq(RenderProfileScript.get_profile_id_for_quality(RenderProfileScript.QUALITY_HIGH, false), RenderProfileScript.PROFILE_DESKTOP)
	settings.free()

func _remove_test_config() -> void:
	var absolute_path := ProjectSettings.globalize_path(TEST_CONFIG_PATH)
	if FileAccess.file_exists(TEST_CONFIG_PATH):
		DirAccess.remove_absolute(absolute_path)
