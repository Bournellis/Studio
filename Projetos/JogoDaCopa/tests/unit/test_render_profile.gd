extends "res://addons/gut/test.gd"

const RenderProfileScript = preload("res://autoloads/render_profile.gd")

func test_render_profile_selects_desktop_and_web_by_platform() -> void:
	assert_eq(RenderProfileScript.select_profile_for_platform(false), RenderProfileScript.PROFILE_DESKTOP)
	assert_eq(RenderProfileScript.select_profile_for_platform(true), RenderProfileScript.PROFILE_WEB)
	assert_eq(RenderProfileScript.get_renderer_label(RenderProfileScript.PROFILE_DESKTOP), "Forward+")
	assert_eq(RenderProfileScript.get_renderer_label(RenderProfileScript.PROFILE_WEB), "Compatibility")

func test_desktop_render_profile_preserves_forward_plus_values() -> void:
	var settings := RenderProfileScript.get_environment_settings(RenderProfileScript.PROFILE_DESKTOP)
	assert_true(bool(settings["glow_enabled"]))
	assert_true(bool(settings["ssao_enabled"]))
	assert_true(bool(settings["fog_enabled"]))
	assert_false(bool(settings["fake_ao_enabled"]))
	assert_almost_eq(float(settings["glow_intensity"]), 0.42, 0.001)
	assert_almost_eq(float(settings["ssao_radius"]), 2.6, 0.001)
	assert_almost_eq(RenderProfileScript.adjust_emission_energy(1.8, RenderProfileScript.ROLE_NEON, RenderProfileScript.PROFILE_DESKTOP), 1.8, 0.001)
	assert_eq(RenderProfileScript.adjust_particle_amount(56, RenderProfileScript.PROFILE_DESKTOP), 56)
	assert_eq(RenderProfileScript.get_scoreboard_viewport_size(RenderProfileScript.PROFILE_DESKTOP), Vector2i(1024, 384))
	assert_eq(RenderProfileScript.get_menu_preview_viewport_size(RenderProfileScript.PROFILE_DESKTOP), Vector2i(1280, 720))

func test_web_render_profile_uses_single_threaded_compatibility_fallbacks() -> void:
	var settings := RenderProfileScript.get_environment_settings(RenderProfileScript.PROFILE_WEB)
	var contract := RenderProfileScript.get_runtime_contract(RenderProfileScript.PROFILE_WEB)
	assert_eq(contract["profile"], RenderProfileScript.PROFILE_WEB)
	assert_eq(contract["renderer"], "Compatibility")
	assert_false(bool(contract["thread_support_enabled"]))
	assert_false(bool(contract["extension_support_enabled"]))
	assert_false(bool(contract["shared_array_buffer_required"]))
	assert_false(bool(contract["cross_origin_headers_required"]))
	assert_true(bool(contract["audio_requires_user_interaction"]))
	assert_eq(contract["user_save_backend"], "user:// via IndexedDB")
	assert_true(bool(settings["glow_enabled"]))
	assert_false(bool(settings["ssao_enabled"]))
	assert_true(bool(settings["fake_ao_enabled"]))
	assert_true(bool(settings["fog_enabled"]))
	assert_gt(RenderProfileScript.adjust_emission_energy(1.8, RenderProfileScript.ROLE_NEON, RenderProfileScript.PROFILE_WEB), 1.8)
	assert_lt(RenderProfileScript.adjust_particle_amount(56, RenderProfileScript.PROFILE_WEB), 56)
	assert_eq(RenderProfileScript.get_scoreboard_viewport_size(RenderProfileScript.PROFILE_WEB), Vector2i(768, 288))
	assert_eq(RenderProfileScript.get_menu_preview_viewport_size(RenderProfileScript.PROFILE_WEB), Vector2i(960, 540))
	assert_eq(RenderProfileScript.validate_profile_contract(RenderProfileScript.PROFILE_WEB).size(), 0)

func test_web_render_profile_documents_known_fallbacks() -> void:
	var fallbacks := RenderProfileScript.get_known_fallbacks(RenderProfileScript.PROFILE_WEB)
	assert_gt(fallbacks.size(), 0)
	assert_true(" ".join(fallbacks).contains("SSAO"))
	assert_true(" ".join(fallbacks).contains("IndexedDB"))
