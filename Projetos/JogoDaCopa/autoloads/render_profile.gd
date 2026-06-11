class_name JogoDaCopaRenderProfile
extends Node

const PROFILE_DESKTOP: StringName = &"desktop"
const PROFILE_WEB: StringName = &"web"
const ROLE_DEFAULT: StringName = &"default"
const ROLE_NEON: StringName = &"neon"
const ROLE_GLASS: StringName = &"glass"
const ROLE_SCOREBOARD: StringName = &"scoreboard"
const ROLE_SHADER_PITCH: StringName = &"shader_pitch"
const ROLE_SHADER_NET: StringName = &"shader_net"
const ROLE_SHADER_CROWD: StringName = &"shader_crowd"
const ROLE_SHADER_FLAG: StringName = &"shader_flag"
const ROLE_SHADER_HALO: StringName = &"shader_halo"
const ROLE_CHARACTER: StringName = &"character"
const ROLE_PARTICLE: StringName = &"particle"

const DESKTOP_RENDERER_LABEL: String = "Forward+"
const WEB_RENDERER_LABEL: String = "Compatibility"
const WEB_OS_NAME: String = "Web"
const WEB_FEATURE_NAME: String = "web"

const WEB_THREAD_SUPPORT_ENABLED: bool = false
const WEB_EXTENSION_SUPPORT_ENABLED: bool = false
const WEB_SHARED_ARRAY_BUFFER_REQUIRED: bool = false
const WEB_CROSS_ORIGIN_HEADERS_REQUIRED: bool = false
const WEB_AUDIO_REQUIRES_USER_INTERACTION: bool = true
const WEB_SAVE_BACKEND_LABEL: String = "user:// via IndexedDB"

const DESKTOP_GLOW_ENABLED: bool = true
const DESKTOP_SSAO_ENABLED: bool = true
const DESKTOP_FAKE_AO_ENABLED: bool = false
const DESKTOP_FOG_ENABLED: bool = true
const DESKTOP_BACKGROUND_ENERGY: float = 0.82
const DESKTOP_BACKGROUND_INTENSITY: float = 0.72
const DESKTOP_AMBIENT_LIGHT_ENERGY: float = 0.34
const DESKTOP_AMBIENT_SKY_CONTRIBUTION: float = 0.74
const DESKTOP_TONEMAP_EXPOSURE: float = 1.08
const DESKTOP_TONEMAP_WHITE: float = 1.72
const DESKTOP_GLOW_INTENSITY: float = 0.42
const DESKTOP_GLOW_STRENGTH: float = 0.92
const DESKTOP_GLOW_BLOOM: float = 0.28
const DESKTOP_GLOW_HDR_THRESHOLD: float = 0.86
const DESKTOP_GLOW_HDR_SCALE: float = 1.65
const DESKTOP_GLOW_HDR_LUMINANCE_CAP: float = 9.0
const DESKTOP_SSAO_RADIUS: float = 2.6
const DESKTOP_SSAO_INTENSITY: float = 0.52
const DESKTOP_SSAO_POWER: float = 1.22
const DESKTOP_SSAO_DETAIL: float = 0.38
const DESKTOP_SSAO_SHARPNESS: float = 0.48
const DESKTOP_SSAO_LIGHT_AFFECT: float = 0.18
const DESKTOP_FOG_LIGHT_ENERGY: float = 0.28
const DESKTOP_FOG_DENSITY: float = 0.014
const DESKTOP_FOG_AERIAL_PERSPECTIVE: float = 0.34
const DESKTOP_FOG_SKY_AFFECT: float = 0.24
const DESKTOP_FOG_DEPTH_BEGIN: float = 30.0
const DESKTOP_FOG_DEPTH_END: float = 110.0
const DESKTOP_FOG_DEPTH_CURVE: float = 1.1
const DESKTOP_EMISSION_MULTIPLIER: float = 1.0
const DESKTOP_PARTICLE_AMOUNT_MULTIPLIER: float = 1.0
const DESKTOP_SCOREBOARD_VIEWPORT_SIZE: Vector2i = Vector2i(1024, 384)
const DESKTOP_MENU_PREVIEW_VIEWPORT_SIZE: Vector2i = Vector2i(1280, 720)
const DESKTOP_MENU_PREVIEW_TONEMAP_EXPOSURE: float = 1.22

const WEB_GLOW_ENABLED: bool = true
const WEB_SSAO_ENABLED: bool = false
const WEB_FAKE_AO_ENABLED: bool = true
const WEB_FOG_ENABLED: bool = true
const WEB_BACKGROUND_ENERGY: float = 0.86
const WEB_BACKGROUND_INTENSITY: float = 0.76
const WEB_AMBIENT_LIGHT_ENERGY: float = 0.28
const WEB_AMBIENT_SKY_CONTRIBUTION: float = 0.62
const WEB_TONEMAP_EXPOSURE: float = 1.12
const WEB_TONEMAP_WHITE: float = 1.62
const WEB_GLOW_INTENSITY: float = 0.52
const WEB_GLOW_STRENGTH: float = 1.02
const WEB_GLOW_BLOOM: float = 0.34
const WEB_GLOW_HDR_THRESHOLD: float = 0.74
const WEB_GLOW_HDR_SCALE: float = 1.9
const WEB_GLOW_HDR_LUMINANCE_CAP: float = 10.5
const WEB_SSAO_RADIUS: float = 0.0
const WEB_SSAO_INTENSITY: float = 0.0
const WEB_SSAO_POWER: float = 1.0
const WEB_SSAO_DETAIL: float = 0.0
const WEB_SSAO_SHARPNESS: float = 0.0
const WEB_SSAO_LIGHT_AFFECT: float = 0.0
const WEB_FOG_LIGHT_ENERGY: float = 0.34
const WEB_FOG_DENSITY: float = 0.011
const WEB_FOG_AERIAL_PERSPECTIVE: float = 0.22
const WEB_FOG_SKY_AFFECT: float = 0.18
const WEB_FOG_DEPTH_BEGIN: float = 34.0
const WEB_FOG_DEPTH_END: float = 118.0
const WEB_FOG_DEPTH_CURVE: float = 1.0
const WEB_DEFAULT_EMISSION_MULTIPLIER: float = 1.18
const WEB_NEON_EMISSION_MULTIPLIER: float = 1.34
const WEB_GLASS_EMISSION_MULTIPLIER: float = 1.24
const WEB_SCOREBOARD_EMISSION_MULTIPLIER: float = 1.18
const WEB_SHADER_PITCH_EMISSION_MULTIPLIER: float = 1.12
const WEB_SHADER_NET_EMISSION_MULTIPLIER: float = 1.26
const WEB_SHADER_CROWD_EMISSION_MULTIPLIER: float = 1.22
const WEB_SHADER_FLAG_EMISSION_MULTIPLIER: float = 1.16
const WEB_SHADER_HALO_EMISSION_MULTIPLIER: float = 1.32
const WEB_CHARACTER_EMISSION_MULTIPLIER: float = 1.1
const WEB_PARTICLE_EMISSION_MULTIPLIER: float = 1.22
const WEB_PARTICLE_AMOUNT_MULTIPLIER: float = 0.72
const WEB_SCOREBOARD_VIEWPORT_SIZE: Vector2i = Vector2i(768, 288)
const WEB_MENU_PREVIEW_VIEWPORT_SIZE: Vector2i = Vector2i(960, 540)
const WEB_MENU_PREVIEW_TONEMAP_EXPOSURE: float = 1.24

static var _reported_contexts: Dictionary = {}

func _ready() -> void:
	report_runtime_profile_once("RenderProfile")

static func is_web_platform() -> bool:
	return OS.has_feature(WEB_FEATURE_NAME) or OS.get_name() == WEB_OS_NAME

static func select_profile_for_platform(is_web: bool) -> StringName:
	return PROFILE_WEB if is_web else PROFILE_DESKTOP

static func get_active_profile_id() -> StringName:
	return select_profile_for_platform(is_web_platform())

static func get_renderer_label(profile_id: StringName = &"") -> String:
	return WEB_RENDERER_LABEL if _resolve_profile_id(profile_id) == PROFILE_WEB else DESKTOP_RENDERER_LABEL

static func get_environment_settings(profile_id: StringName = &"") -> Dictionary:
	if _resolve_profile_id(profile_id) == PROFILE_WEB:
		return _build_web_environment_settings()
	return _build_desktop_environment_settings()

static func get_scoreboard_viewport_size(profile_id: StringName = &"") -> Vector2i:
	return WEB_SCOREBOARD_VIEWPORT_SIZE if _resolve_profile_id(profile_id) == PROFILE_WEB else DESKTOP_SCOREBOARD_VIEWPORT_SIZE

static func get_menu_preview_viewport_size(profile_id: StringName = &"") -> Vector2i:
	return WEB_MENU_PREVIEW_VIEWPORT_SIZE if _resolve_profile_id(profile_id) == PROFILE_WEB else DESKTOP_MENU_PREVIEW_VIEWPORT_SIZE

static func get_menu_preview_tonemap_exposure(profile_id: StringName = &"") -> float:
	return WEB_MENU_PREVIEW_TONEMAP_EXPOSURE if _resolve_profile_id(profile_id) == PROFILE_WEB else DESKTOP_MENU_PREVIEW_TONEMAP_EXPOSURE

static func adjust_emission_energy(base_energy: float, role: StringName = ROLE_DEFAULT, profile_id: StringName = &"") -> float:
	return base_energy * get_emission_multiplier(role, profile_id)

static func get_emission_multiplier(role: StringName = ROLE_DEFAULT, profile_id: StringName = &"") -> float:
	if _resolve_profile_id(profile_id) != PROFILE_WEB:
		return DESKTOP_EMISSION_MULTIPLIER
	match role:
		ROLE_NEON:
			return WEB_NEON_EMISSION_MULTIPLIER
		ROLE_GLASS:
			return WEB_GLASS_EMISSION_MULTIPLIER
		ROLE_SCOREBOARD:
			return WEB_SCOREBOARD_EMISSION_MULTIPLIER
		ROLE_SHADER_PITCH:
			return WEB_SHADER_PITCH_EMISSION_MULTIPLIER
		ROLE_SHADER_NET:
			return WEB_SHADER_NET_EMISSION_MULTIPLIER
		ROLE_SHADER_CROWD:
			return WEB_SHADER_CROWD_EMISSION_MULTIPLIER
		ROLE_SHADER_FLAG:
			return WEB_SHADER_FLAG_EMISSION_MULTIPLIER
		ROLE_SHADER_HALO:
			return WEB_SHADER_HALO_EMISSION_MULTIPLIER
		ROLE_CHARACTER:
			return WEB_CHARACTER_EMISSION_MULTIPLIER
		ROLE_PARTICLE:
			return WEB_PARTICLE_EMISSION_MULTIPLIER
		_:
			return WEB_DEFAULT_EMISSION_MULTIPLIER

static func adjust_particle_amount(base_amount: int, profile_id: StringName = &"") -> int:
	var multiplier := WEB_PARTICLE_AMOUNT_MULTIPLIER if _resolve_profile_id(profile_id) == PROFILE_WEB else DESKTOP_PARTICLE_AMOUNT_MULTIPLIER
	return maxi(1, int(round(float(base_amount) * multiplier)))

static func get_runtime_contract(profile_id: StringName = &"") -> Dictionary:
	var resolved := _resolve_profile_id(profile_id)
	return {
		"profile": resolved,
		"renderer": get_renderer_label(resolved),
		"thread_support_enabled": false if resolved == PROFILE_WEB else true,
		"extension_support_enabled": false if resolved == PROFILE_WEB else true,
		"shared_array_buffer_required": false if resolved == PROFILE_WEB else true,
		"cross_origin_headers_required": false if resolved == PROFILE_WEB else true,
		"audio_requires_user_interaction": WEB_AUDIO_REQUIRES_USER_INTERACTION if resolved == PROFILE_WEB else false,
		"user_save_backend": WEB_SAVE_BACKEND_LABEL if resolved == PROFILE_WEB else "user:// native filesystem",
	}

static func validate_profile_contract(profile_id: StringName = &"") -> PackedStringArray:
	var resolved := _resolve_profile_id(profile_id)
	var failures := PackedStringArray()
	if resolved == PROFILE_WEB:
		if WEB_THREAD_SUPPORT_ENABLED:
			failures.append("Web profile must be single-threaded.")
		if WEB_EXTENSION_SUPPORT_ENABLED:
			failures.append("Web profile must keep extension support disabled.")
		if WEB_SHARED_ARRAY_BUFFER_REQUIRED:
			failures.append("Web profile must not require SharedArrayBuffer.")
		if WEB_CROSS_ORIGIN_HEADERS_REQUIRED:
			failures.append("Web profile must not require COOP/COEP headers.")
		if not WEB_SSAO_ENABLED and not WEB_FAKE_AO_ENABLED:
			failures.append("Web profile disables SSAO without fake AO fallback.")
		if not WEB_GLOW_ENABLED and WEB_DEFAULT_EMISSION_MULTIPLIER <= DESKTOP_EMISSION_MULTIPLIER:
			failures.append("Web profile disables glow without emissive compensation.")
	return failures

static func get_known_fallbacks(profile_id: StringName = &"") -> PackedStringArray:
	if _resolve_profile_id(profile_id) != PROFILE_WEB:
		return PackedStringArray()
	return PackedStringArray([
		"SSAO is disabled under Compatibility and replaced by lower ambient/skylight fake AO.",
		"Glow/bloom is compensated with stronger emissive material and shader multipliers.",
		"Scoreboard and menu SubViewports use lower fixed sizes on Web.",
		"Particles keep the same gameplay triggers but use reduced amounts on Web.",
		"Audio starts only after the first browser user interaction.",
		"user:// save data maps to browser IndexedDB.",
	])

static func report_runtime_profile_once(context: String) -> void:
	var key := "%s:%s" % [context, str(get_active_profile_id())]
	if _reported_contexts.has(key):
		return
	_reported_contexts[key] = true
	var failures := validate_profile_contract()
	for failure in failures:
		push_error("RenderProfile %s: %s" % [context, failure])
	if not failures.is_empty():
		return
	if get_active_profile_id() == PROFILE_WEB:
		for fallback in get_known_fallbacks():
			push_warning("RenderProfile %s: %s" % [context, fallback])

static func _resolve_profile_id(profile_id: StringName) -> StringName:
	if profile_id == PROFILE_WEB:
		return PROFILE_WEB
	if profile_id == PROFILE_DESKTOP:
		return PROFILE_DESKTOP
	return get_active_profile_id()

static func _build_desktop_environment_settings() -> Dictionary:
	return {
		"glow_enabled": DESKTOP_GLOW_ENABLED,
		"ssao_enabled": DESKTOP_SSAO_ENABLED,
		"fake_ao_enabled": DESKTOP_FAKE_AO_ENABLED,
		"fog_enabled": DESKTOP_FOG_ENABLED,
		"background_energy_multiplier": DESKTOP_BACKGROUND_ENERGY,
		"background_intensity": DESKTOP_BACKGROUND_INTENSITY,
		"ambient_light_energy": DESKTOP_AMBIENT_LIGHT_ENERGY,
		"ambient_light_sky_contribution": DESKTOP_AMBIENT_SKY_CONTRIBUTION,
		"tonemap_exposure": DESKTOP_TONEMAP_EXPOSURE,
		"tonemap_white": DESKTOP_TONEMAP_WHITE,
		"glow_intensity": DESKTOP_GLOW_INTENSITY,
		"glow_strength": DESKTOP_GLOW_STRENGTH,
		"glow_bloom": DESKTOP_GLOW_BLOOM,
		"glow_hdr_threshold": DESKTOP_GLOW_HDR_THRESHOLD,
		"glow_hdr_scale": DESKTOP_GLOW_HDR_SCALE,
		"glow_hdr_luminance_cap": DESKTOP_GLOW_HDR_LUMINANCE_CAP,
		"ssao_radius": DESKTOP_SSAO_RADIUS,
		"ssao_intensity": DESKTOP_SSAO_INTENSITY,
		"ssao_power": DESKTOP_SSAO_POWER,
		"ssao_detail": DESKTOP_SSAO_DETAIL,
		"ssao_sharpness": DESKTOP_SSAO_SHARPNESS,
		"ssao_light_affect": DESKTOP_SSAO_LIGHT_AFFECT,
		"fog_light_energy": DESKTOP_FOG_LIGHT_ENERGY,
		"fog_density": DESKTOP_FOG_DENSITY,
		"fog_aerial_perspective": DESKTOP_FOG_AERIAL_PERSPECTIVE,
		"fog_sky_affect": DESKTOP_FOG_SKY_AFFECT,
		"fog_depth_begin": DESKTOP_FOG_DEPTH_BEGIN,
		"fog_depth_end": DESKTOP_FOG_DEPTH_END,
		"fog_depth_curve": DESKTOP_FOG_DEPTH_CURVE,
	}

static func _build_web_environment_settings() -> Dictionary:
	return {
		"glow_enabled": WEB_GLOW_ENABLED,
		"ssao_enabled": WEB_SSAO_ENABLED,
		"fake_ao_enabled": WEB_FAKE_AO_ENABLED,
		"fog_enabled": WEB_FOG_ENABLED,
		"background_energy_multiplier": WEB_BACKGROUND_ENERGY,
		"background_intensity": WEB_BACKGROUND_INTENSITY,
		"ambient_light_energy": WEB_AMBIENT_LIGHT_ENERGY,
		"ambient_light_sky_contribution": WEB_AMBIENT_SKY_CONTRIBUTION,
		"tonemap_exposure": WEB_TONEMAP_EXPOSURE,
		"tonemap_white": WEB_TONEMAP_WHITE,
		"glow_intensity": WEB_GLOW_INTENSITY,
		"glow_strength": WEB_GLOW_STRENGTH,
		"glow_bloom": WEB_GLOW_BLOOM,
		"glow_hdr_threshold": WEB_GLOW_HDR_THRESHOLD,
		"glow_hdr_scale": WEB_GLOW_HDR_SCALE,
		"glow_hdr_luminance_cap": WEB_GLOW_HDR_LUMINANCE_CAP,
		"ssao_radius": WEB_SSAO_RADIUS,
		"ssao_intensity": WEB_SSAO_INTENSITY,
		"ssao_power": WEB_SSAO_POWER,
		"ssao_detail": WEB_SSAO_DETAIL,
		"ssao_sharpness": WEB_SSAO_SHARPNESS,
		"ssao_light_affect": WEB_SSAO_LIGHT_AFFECT,
		"fog_light_energy": WEB_FOG_LIGHT_ENERGY,
		"fog_density": WEB_FOG_DENSITY,
		"fog_aerial_perspective": WEB_FOG_AERIAL_PERSPECTIVE,
		"fog_sky_affect": WEB_FOG_SKY_AFFECT,
		"fog_depth_begin": WEB_FOG_DEPTH_BEGIN,
		"fog_depth_end": WEB_FOG_DEPTH_END,
		"fog_depth_curve": WEB_FOG_DEPTH_CURVE,
	}
