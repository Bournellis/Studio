class_name JogoDaCopaMainMenu
extends Control

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")
const RenderProfileScript = preload("res://autoloads/render_profile.gd")
const GameSettingsScript = preload("res://autoloads/game_settings.gd")
const PerfProbeScript = preload("res://modes/shared/jdc_perf_probe.gd")

const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const BROADCAST_FONT_PATH: String = "res://assets/fonts/kenney/Kenney Future.ttf"
const BROADCAST_NARROW_FONT_PATH: String = "res://assets/fonts/kenney/Kenney Future Narrow.ttf"
const BROADCAST_MONO_FONT_PATH: String = "res://assets/fonts/kenney/Kenney Mini Square Mono.ttf"
const MENU_PANEL_MIN_SIZE: Vector2 = Vector2(500.0, 0.0)
const MENU_PANEL_SIDE_MARGIN: float = 48.0
const MENU_PANEL_MIN_TOP_MARGIN: float = 18.0
const BUS_MASTER: StringName = &"Master"
const BUS_SFX: StringName = &"SFX"
const BUS_UI: StringName = &"UI"
const BUS_AMBIENCE: StringName = &"Ambience"
const UI_AUDIO_POOL_SIZE: int = 5
const WEB_AUDIO_UNLOCK_POLL_MSEC: int = 500
const MENU_UI_AUDIO_PATHS: Dictionary = {
	&"ui_click": "res://assets/audio/kenney_sfx/click_001.ogg",
	&"ui_confirmation": "res://assets/audio/kenney_sfx/confirmation_001.ogg",
	&"ui_back": "res://assets/audio/kenney_sfx/back_001.ogg",
}
const BOT_DIFFICULTY_META_KEY: String = "jogodacopa_bot_difficulty"
const MATCH_MODE_META_KEY: String = "jogodacopa_match_mode"
const TOON_RENDER_META_KEY: String = "jogodacopa_toon_render"
const CAPTURE_SCENE_META_KEY: String = "jogodacopa_capture_scene"
const CAPTURE_QUERY_KEY: String = "jdc_capture"
const CAPTURE_SCENE_MENU: StringName = &"menu"
const CAPTURE_SCENE_KICKOFF: StringName = &"kickoff"
const CAPTURE_SCENE_GOAL: StringName = &"goal"
const CAPTURE_SCENE_RESULT: StringName = &"result"
const CAPTURE_SCENE_PLAY: StringName = &"play"
const BOT_DIFFICULTY_IDS: Array = [&"easy", &"normal", &"hard"]
const BOT_DIFFICULTY_LABELS: Dictionary = {
	&"easy": "Bot facil",
	&"normal": "Bot normal",
	&"hard": "Bot dificil"
}
const MATCH_MODE_IDS: Array = [&"timer", &"goals"]
const MATCH_MODE_LABELS: Dictionary = {
	&"timer": "3 minutos",
	&"goals": "3 gols"
}
const VISIBLE_VERSION: String = "v1.0.1"
const RELEASE_INFO_PATH: String = "res://build/release_info.json"
const PREVIEW_CAMERA_LOOK_AT: Vector3 = Vector3(-3.08, 1.32, 0.0)
const MENU_TRANSITION_SECONDS: float = 0.25

var football_button: Button
var quit_button: Button
var status_label: Label
var menu_panel: PanelContainer
var preview_viewport: SubViewport
var preview_camera: Camera3D
var preview_root: Node3D
var preview_avatar
var preview_ball: MeshInstance3D
var preview_environment: Environment
var skin_label: Label
var kit_label: Label
var difficulty_label: Label
var match_mode_label: Label
var skin_swatch: ColorRect
var kit_swatch: ColorRect
var volume_slider: HSlider
var sfx_volume_slider: HSlider
var ui_volume_slider: HSlider
var ambience_volume_slider: HSlider
var quality_option: OptionButton
var toon_check_button: CheckButton
var fade_overlay: ColorRect
var fade_tween: Tween
var ui_audio_streams: Dictionary = {}
var ui_audio_pool: Array[AudioStreamPlayer] = []
var ui_audio_pool_cursor: int = 0
var web_audio_locked_logged: bool = false
var web_audio_unlocked: bool = false
var web_audio_next_unlock_poll_msec: int = 0
var broadcast_font: FontFile
var broadcast_narrow_font: FontFile
var broadcast_mono_font: FontFile
var kit_secondary_swatch: ColorRect
var kit_shorts_swatch: ColorRect

var preview_time: float = 0.0
var selected_skin_tone_id: StringName = AvatarCatalogScript.DEFAULT_SKIN_TONE_ID
var selected_country_kit_id: StringName = AvatarCatalogScript.DEFAULT_COUNTRY_KIT_ID
var selected_bot_difficulty_id: StringName = &"normal"
var selected_match_mode_id: StringName = &"timer"
var selected_toon_render_enabled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	PerfProbeScript.ensure_enabled(self, "menu")
	PerfProbeScript.mark(self, "menu.ready.begin")
	RenderProfileScript.report_runtime_profile_once("MainMenuRoot")
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_sync_root_rect_to_viewport()
	if not get_viewport().size_changed.is_connected(_sync_root_rect_to_viewport):
		get_viewport().size_changed.connect(_sync_root_rect_to_viewport)
	_ensure_audio_buses()
	_load_ui_audio_streams()
	if not RenderProfileScript.is_web_platform():
		_build_ui_audio_pool()
	_load_broadcast_fonts()
	_build_ui()
	_sync_root_rect_to_viewport()
	_apply_initial_audio_mix()
	_connect_game_settings_signals()
	_update_preview_selection()
	_focus_initial_control()
	call_deferred("_play_fade_from_black")
	call_deferred("_try_load_web_capture_scene")
	PerfProbeScript.mark(self, "menu.ready.end")

func _process(delta: float) -> void:
	if RenderProfileScript.is_web_platform():
		return
	preview_time += delta
	if preview_root != null:
		preview_root.rotation.y = sin(preview_time * 0.45) * 0.08
	if preview_ball != null:
		preview_ball.rotation = Vector3(preview_time * 2.2, preview_time * 1.4, preview_time * 0.8)
	if preview_avatar != null:
		preview_avatar.set_move_state(2.8 + sin(preview_time * 2.0) * 1.2, true, 0.0)
	if preview_camera != null:
		_update_preview_camera_pose(preview_time)

func _sync_root_rect_to_viewport() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = get_viewport_rect().size
	_position_menu_panel()

func debug_get_mode_path(mode_id: StringName) -> String:
	match mode_id:
		&"football":
			return FOOTBALL_SCENE_PATH
		_:
			return ""

func debug_has_arena_preview() -> bool:
	return preview_viewport != null and preview_camera != null and preview_avatar != null

func debug_get_visible_version_text() -> String:
	return _build_visible_version_text()

func debug_get_selected_kit_id() -> StringName:
	return selected_country_kit_id

func debug_get_selected_skin_tone_id() -> StringName:
	return selected_skin_tone_id

func debug_get_selected_bot_difficulty_id() -> StringName:
	return selected_bot_difficulty_id

func debug_get_selected_match_mode_id() -> StringName:
	return selected_match_mode_id

func debug_is_toon_render_enabled() -> bool:
	return selected_toon_render_enabled

func debug_has_main_menu_appearance_selection() -> bool:
	return (
		get_node_or_null("MenuCenter/MenuPanel/MenuBox/SkinPreviewRow") != null
		or get_node_or_null("MenuCenter/MenuPanel/MenuBox/KitPreviewRow") != null
	)

func debug_main_controls_fit_viewports(viewport_sizes: Array) -> bool:
	var required_size := _get_menu_required_size()
	for viewport_value: Variant in viewport_sizes:
		var viewport_size: Vector2 = viewport_value
		if required_size.x > viewport_size.x or required_size.y > viewport_size.y:
			return false
	return true

func debug_get_menu_required_size() -> Vector2:
	return _get_menu_required_size()

func debug_cycle_bot_difficulty(step: int = 1) -> void:
	_cycle_bot_difficulty(step)

func debug_cycle_match_mode(step: int = 1) -> void:
	_cycle_match_mode(step)

func debug_cycle_skin_tone(step: int = 1) -> void:
	_cycle_skin_tone(step)

func debug_cycle_country_kit(step: int = 1) -> void:
	_cycle_country_kit(step)

func debug_has_broadcast_match_card() -> bool:
	return (
		get_node_or_null("MenuCenter/MenuPanel/MenuBox/BroadcastHeader") != null
		and get_node_or_null("MenuCenter/MenuPanel/MenuBox/MatchSectionLabel") != null
		and get_node_or_null("MenuCenter/MenuPanel/MenuBox/AppearanceSectionLabel") != null
		and get_node_or_null("MenuCenter/MenuPanel/MenuBox/AudioVideoSectionLabel") != null
	)

func debug_has_broadcast_font_loaded() -> bool:
	return broadcast_font != null and broadcast_narrow_font != null and broadcast_mono_font != null

func debug_get_primary_cta_min_height() -> float:
	if football_button == null:
		return 0.0
	return football_button.custom_minimum_size.y

func debug_get_quality_text() -> String:
	if quality_option == null:
		return ""
	return quality_option.get_item_text(quality_option.selected)

func debug_select_quality(index: int) -> void:
	_on_quality_selected(index)

func debug_has_audio_buses() -> bool:
	return (
		AudioServer.get_bus_index(str(BUS_SFX)) >= 0
		and AudioServer.get_bus_index(str(BUS_UI)) >= 0
		and AudioServer.get_bus_index(str(BUS_AMBIENCE)) >= 0
	)

func debug_get_render_profile_id() -> StringName:
	return RenderProfileScript.get_active_profile_id()

func debug_get_preview_viewport_size() -> Vector2i:
	return preview_viewport.size if preview_viewport != null else Vector2i.ZERO

func debug_get_ui_audio_pool_size() -> int:
	return ui_audio_pool.size()

func debug_get_preview_average_luminance(sample_step: int = 16) -> float:
	if preview_viewport == null or preview_viewport.get_texture() == null:
		return 0.0
	if DisplayServer.get_name().to_lower().contains("headless"):
		return _get_preview_configured_luminance()
	var image := preview_viewport.get_texture().get_image()
	if image == null or image.is_empty():
		return _get_preview_configured_luminance()
	var width := image.get_width()
	var height := image.get_height()
	var step := maxi(1, sample_step)
	var total := 0.0
	var count := 0
	var y := 0
	while y < height:
		var x := 0
		while x < width:
			var color := image.get_pixel(x, y)
			total += color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
			count += 1
			x += step
		y += step
	return total / maxf(1.0, float(count))

func debug_preview_uses_hero_shot() -> bool:
	if preview_camera == null or preview_avatar == null or preview_root == null:
		return false
	var hero_light := preview_viewport.get_node_or_null("PreviewWorld/PreviewHeroLight") as OmniLight3D
	var distance_to_avatar := preview_camera.global_position.distance_to(preview_avatar.global_position)
	var camera_is_low := preview_camera.global_position.y < PREVIEW_CAMERA_LOOK_AT.y
	var kit_matches := true
	if preview_avatar.has_method("debug_get_country_kit_id"):
		kit_matches = preview_avatar.debug_get_country_kit_id() == selected_country_kit_id
	return hero_light != null and camera_is_low and distance_to_avatar <= 6.2 and kit_matches

func _build_ui() -> void:
	_sync_root_rect_to_viewport()
	mouse_filter = Control.MOUSE_FILTER_PASS

	_build_arena_preview()

	var preview_texture := TextureRect.new()
	preview_texture.name = "ArenaPreview"
	preview_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_texture.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_texture.texture = preview_viewport.get_texture()
	preview_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(preview_texture)

	var shade := ColorRect.new()
	shade.name = "PreviewShade"
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.015, 0.025, 0.34)
	add_child(shade)

	var menu_center := Control.new()
	menu_center.name = "MenuCenter"
	menu_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	menu_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	menu_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(menu_center)

	menu_panel = PanelContainer.new()
	menu_panel.name = "MenuPanel"
	menu_panel.custom_minimum_size = MENU_PANEL_MIN_SIZE
	menu_panel.add_theme_stylebox_override("panel", _build_panel_style(Color(0.006, 0.026, 0.035, 0.93), Color(1.0, 0.78, 0.16, 0.95), 2))
	menu_center.add_child(menu_panel)

	var center := VBoxContainer.new()
	center.name = "MenuBox"
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 2)
	menu_panel.add_child(center)

	_build_broadcast_header(center)

	_build_selector_rows(center)
	_build_appearance_rows(center)
	_build_settings_rows(center)

	football_button = _build_button("FootballButton", "Jogar Futebol 1x1")
	football_button.pressed.connect(func() -> void:
		_play_ui_sound(&"ui_confirmation")
		PerfProbeScript.mark(self, "menu.play_pressed", "scene=%s" % FOOTBALL_SCENE_PATH)
		_load_mode(FOOTBALL_SCENE_PATH)
	)
	center.add_child(football_button)

	quit_button = _build_button("QuitButton", "Sair")
	quit_button.pressed.connect(func() -> void:
		_play_ui_sound(&"ui_back")
		get_tree().quit()
	)
	center.add_child(quit_button)

	var footer := Label.new()
	footer.name = "FooterLabel"
	footer.text = _build_visible_version_text()
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_broadcast_font(footer, 10, true)
	center.add_child(footer)

	_position_menu_panel()
	call_deferred("_position_menu_panel")
	_build_menu_fade_overlay()

func _build_visible_version_text() -> String:
	var release_info := _load_release_info()
	var version := str(release_info.get("version", VISIBLE_VERSION)).strip_edges()
	var short_hash := str(release_info.get("short_hash", "local")).strip_edges()
	if version.is_empty():
		version = VISIBLE_VERSION
	if short_hash.is_empty():
		short_hash = "local"
	return "Copa Arena Futebol %s+%s | sem logos oficiais" % [version, short_hash]

func _load_release_info() -> Dictionary:
	if not FileAccess.file_exists(RELEASE_INFO_PATH):
		return {}
	var file := FileAccess.open(RELEASE_INFO_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

func _load_broadcast_fonts() -> void:
	broadcast_font = load(BROADCAST_FONT_PATH) as FontFile
	if broadcast_font == null:
		push_error("Missing required menu broadcast font: %s" % BROADCAST_FONT_PATH)
	broadcast_narrow_font = load(BROADCAST_NARROW_FONT_PATH) as FontFile
	if broadcast_narrow_font == null:
		push_warning("Missing menu broadcast narrow font: %s" % BROADCAST_NARROW_FONT_PATH)
	broadcast_mono_font = load(BROADCAST_MONO_FONT_PATH) as FontFile
	if broadcast_mono_font == null:
		push_error("Missing required menu broadcast mono font: %s" % BROADCAST_MONO_FONT_PATH)

func _build_broadcast_header(parent: VBoxContainer) -> void:
	var header := VBoxContainer.new()
	header.name = "BroadcastHeader"
	header.custom_minimum_size = Vector2(0.0, 50.0)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_theme_constant_override("separation", 3)
	parent.add_child(header)

	var gradient_band := TextureRect.new()
	gradient_band.name = "CupGradientBand"
	gradient_band.custom_minimum_size = Vector2(0.0, 7.0)
	gradient_band.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gradient_band.texture = _build_cup_gradient_texture()
	gradient_band.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	gradient_band.stretch_mode = TextureRect.STRETCH_SCALE
	header.add_child(gradient_band)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Copa Arena Futebol"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color(1.0, 0.93, 0.72, 1.0))
	_apply_broadcast_font(title, 29, false)
	header.add_child(title)

	var match_line := Label.new()
	match_line.name = "BroadcastMatchLine"
	match_line.text = "FINAL 1x1  |  ARENA DE VIDRO"
	match_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_line.add_theme_color_override("font_color", Color(0.78, 0.94, 1.0, 1.0))
	_apply_broadcast_mono_font(match_line, 11)
	header.add_child(match_line)

	var gold_line := ColorRect.new()
	gold_line.name = "GoldDetailLine"
	gold_line.custom_minimum_size = Vector2(0.0, 2.0)
	gold_line.color = Color(1.0, 0.78, 0.16, 1.0)
	gold_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(gold_line)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Noite de final - primeiro a 3 gols"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_color_override("font_color", Color(0.84, 0.92, 0.92, 1.0))
	_apply_broadcast_font(status_label, 11, true)
	header.add_child(status_label)

func _build_cup_gradient_texture() -> GradientTexture2D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.02, 0.42, 0.18, 1.0))
	gradient.set_color(1, Color(0.02, 0.16, 0.62, 1.0))
	gradient.add_point(0.52, Color(0.88, 0.08, 0.12, 1.0))
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_LINEAR
	texture.fill_from = Vector2.ZERO
	texture.fill_to = Vector2.RIGHT
	return texture

func _build_arena_preview() -> void:
	preview_viewport = SubViewport.new()
	preview_viewport.name = "ArenaPreviewViewport"
	preview_viewport.size = RenderProfileScript.get_menu_preview_viewport_size()
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if RenderProfileScript.is_web_platform() else SubViewport.UPDATE_ALWAYS
	add_child(preview_viewport)

	var world := Node3D.new()
	world.name = "PreviewWorld"
	preview_viewport.add_child(world)

	var environment := WorldEnvironment.new()
	environment.name = "PreviewEnvironment"
	var env := Environment.new()
	preview_environment = env
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.018, 0.055, 0.105, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.34, 0.46, 0.6, 1.0)
	env.ambient_light_energy = 0.76
	var render_settings := RenderProfileScript.get_environment_settings()
	env.glow_enabled = bool(render_settings["glow_enabled"])
	env.glow_intensity = float(render_settings["glow_intensity"])
	env.glow_strength = float(render_settings["glow_strength"])
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = RenderProfileScript.get_menu_preview_tonemap_exposure()
	environment.environment = env
	world.add_child(environment)

	var key := DirectionalLight3D.new()
	key.name = "PreviewKeyLight"
	key.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	key.light_color = Color(0.8, 0.9, 1.0, 1.0)
	key.light_energy = 3.0
	world.add_child(key)

	var hero_light := OmniLight3D.new()
	hero_light.name = "PreviewHeroLight"
	hero_light.position = Vector3(-2.3, 2.7, 3.4)
	hero_light.light_color = Color(1.0, 0.88, 0.54, 1.0)
	hero_light.light_energy = 2.25
	hero_light.omni_range = 7.5
	world.add_child(hero_light)

	var rim_light := OmniLight3D.new()
	rim_light.name = "PreviewRimLight"
	rim_light.position = Vector3(2.4, 2.2, -2.6)
	rim_light.light_color = Color(0.25, 0.92, 1.0, 1.0)
	rim_light.light_energy = 1.45
	rim_light.omni_range = 8.0
	world.add_child(rim_light)

	preview_root = Node3D.new()
	preview_root.name = "PreviewArenaRoot"
	world.add_child(preview_root)
	_build_preview_pitch(preview_root)
	_build_preview_goal(preview_root, -8.6)
	_build_preview_goal(preview_root, 8.6)

	preview_avatar = PlayerAvatarScript.new()
	preview_avatar.name = "PreviewAvatar"
	preview_avatar.position = Vector3(-4.15, 0.0, 0.08)
	preview_avatar.rotation.y = -0.22
	preview_root.add_child(preview_avatar)

	preview_ball = MeshInstance3D.new()
	preview_ball.name = "PreviewBall"
	preview_ball.position = Vector3(-3.08, 0.46, -0.34)
	var ball_mesh := SphereMesh.new()
	ball_mesh.radius = 0.34
	ball_mesh.height = 0.68
	ball_mesh.radial_segments = 24
	ball_mesh.rings = 12
	preview_ball.mesh = ball_mesh
	preview_ball.material_override = _build_material(Color(0.95, 0.97, 0.92, 1.0), 0.2, Color(0.2, 0.9, 1.0, 1.0), 0.18, RenderProfileScript.ROLE_SCOREBOARD)
	preview_root.add_child(preview_ball)

	preview_camera = Camera3D.new()
	preview_camera.name = "PreviewCamera"
	preview_camera.current = true
	preview_camera.fov = 38.0
	preview_camera.near = 0.04
	preview_camera.far = 80.0
	world.add_child(preview_camera)
	_update_preview_camera_pose(0.0)

func _build_preview_pitch(parent: Node3D) -> void:
	var pitch := MeshInstance3D.new()
	pitch.name = "PreviewPitch"
	pitch.position = Vector3(0.0, -0.05, 0.0)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(14.0, 0.1, 20.0)
	pitch.mesh = mesh
	pitch.material_override = _build_material(Color(0.02, 0.42, 0.16, 1.0), 0.82, Color(0.0, 0.18, 0.08, 1.0), 0.05, RenderProfileScript.ROLE_SHADER_PITCH)
	parent.add_child(pitch)

	for index in range(5):
		var line := MeshInstance3D.new()
		line.name = "PreviewPitchStripe%d" % index
		line.position = Vector3(0.0, 0.03, -7.2 + index * 3.6)
		var stripe_mesh := BoxMesh.new()
		stripe_mesh.size = Vector3(14.2, 0.035, 0.08)
		line.mesh = stripe_mesh
		line.material_override = _build_material(Color(0.86, 0.96, 0.82, 1.0), 0.74, Color(0.5, 1.0, 0.7, 1.0), 0.08, RenderProfileScript.ROLE_SHADER_PITCH)
		parent.add_child(line)

func _build_preview_goal(parent: Node3D, z_position: float) -> void:
	var frame_color := Color(0.2, 0.9, 1.0, 1.0)
	for x in [-2.2, 2.2]:
		var post := MeshInstance3D.new()
		post.name = "PreviewGoalPost"
		post.position = Vector3(x, 1.1, z_position)
		var post_mesh := BoxMesh.new()
		post_mesh.size = Vector3(0.12, 2.2, 0.12)
		post.mesh = post_mesh
		post.material_override = _build_material(frame_color, 0.28, frame_color, 1.6, RenderProfileScript.ROLE_NEON)
		parent.add_child(post)
	var crossbar := MeshInstance3D.new()
	crossbar.name = "PreviewGoalCrossbar"
	crossbar.position = Vector3(0.0, 2.2, z_position)
	var crossbar_mesh := BoxMesh.new()
	crossbar_mesh.size = Vector3(4.55, 0.12, 0.12)
	crossbar.mesh = crossbar_mesh
	crossbar.material_override = _build_material(frame_color, 0.28, frame_color, 1.6, RenderProfileScript.ROLE_NEON)
	parent.add_child(crossbar)

func _update_preview_camera_pose(time_seconds: float) -> void:
	if preview_camera == null:
		return
	var angle := -0.34 + sin(time_seconds * 0.28) * 0.06
	var radius := 4.2
	preview_camera.position = Vector3(sin(angle) * radius - 2.85, 0.92 + sin(time_seconds * 0.5) * 0.05, cos(angle) * radius + 2.05)
	preview_camera.look_at(PREVIEW_CAMERA_LOOK_AT, Vector3.UP)

func _get_preview_configured_luminance() -> float:
	if preview_environment == null:
		return 0.0
	var color := preview_environment.background_color
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722

func _build_selector_rows(parent: VBoxContainer) -> void:
	parent.add_child(_build_section_label("MatchSectionLabel", "TRANSMISSAO DA PARTIDA"))

	var difficulty_row := HBoxContainer.new()
	difficulty_row.name = "BotDifficultyRow"
	difficulty_row.add_theme_constant_override("separation", 6)
	difficulty_row.custom_minimum_size.y = 24.0
	parent.add_child(difficulty_row)

	var difficulty_swatch := _build_swatch("BotDifficultySwatch", Color(1.0, 0.58, 0.22, 1.0))
	difficulty_row.add_child(difficulty_swatch)
	difficulty_row.add_child(_build_cycle_button("BotDifficultyPreviousButton", "<", func() -> void:
		_cycle_bot_difficulty(-1)
	))
	difficulty_label = _build_row_label("BotDifficultyLabel", _get_bot_difficulty_label(selected_bot_difficulty_id))
	difficulty_row.add_child(difficulty_label)
	difficulty_row.add_child(_build_cycle_button("BotDifficultyNextButton", ">", func() -> void:
		_cycle_bot_difficulty(1)
	))

	var match_mode_row := HBoxContainer.new()
	match_mode_row.name = "MatchModeRow"
	match_mode_row.add_theme_constant_override("separation", 6)
	match_mode_row.custom_minimum_size.y = 24.0
	parent.add_child(match_mode_row)

	var match_mode_swatch := _build_swatch("MatchModeSwatch", Color(0.34, 0.88, 1.0, 1.0))
	match_mode_row.add_child(match_mode_swatch)
	match_mode_row.add_child(_build_cycle_button("MatchModePreviousButton", "<", func() -> void:
		_cycle_match_mode(-1)
	))
	match_mode_label = _build_row_label("MatchModeLabel", _get_match_mode_label(selected_match_mode_id))
	match_mode_row.add_child(match_mode_label)
	match_mode_row.add_child(_build_cycle_button("MatchModeNextButton", ">", func() -> void:
		_cycle_match_mode(1)
	))

func _build_appearance_rows(parent: VBoxContainer) -> void:
	parent.add_child(_build_section_label("AppearanceSectionLabel", "UNIFORME DO PLAYER"))

	var skin_row := HBoxContainer.new()
	skin_row.name = "BroadcastSkinToneRow"
	skin_row.add_theme_constant_override("separation", 6)
	skin_row.custom_minimum_size.y = 24.0
	parent.add_child(skin_row)

	skin_swatch = _build_swatch("BroadcastSkinSwatch", AvatarCatalogScript.get_skin_color(selected_skin_tone_id))
	skin_row.add_child(skin_swatch)
	skin_row.add_child(_build_cycle_button("SkinTonePreviousButton", "<", func() -> void:
		_cycle_skin_tone(-1)
	))
	skin_label = _build_row_label("BroadcastSkinToneLabel", AvatarCatalogScript.get_skin_label(selected_skin_tone_id))
	skin_row.add_child(skin_label)
	skin_row.add_child(_build_cycle_button("SkinToneNextButton", ">", func() -> void:
		_cycle_skin_tone(1)
	))

	var kit_row := HBoxContainer.new()
	kit_row.name = "BroadcastCountryKitRow"
	kit_row.add_theme_constant_override("separation", 6)
	kit_row.custom_minimum_size.y = 24.0
	parent.add_child(kit_row)

	var kit_flag := HBoxContainer.new()
	kit_flag.name = "BroadcastKitFlag"
	kit_flag.custom_minimum_size = Vector2(52.0, 22.0)
	kit_flag.add_theme_constant_override("separation", 2)
	kit_row.add_child(kit_flag)
	kit_swatch = _build_swatch("BroadcastKitPrimarySwatch", AvatarCatalogScript.get_kit_primary_color(selected_country_kit_id))
	kit_secondary_swatch = _build_swatch("BroadcastKitSecondarySwatch", AvatarCatalogScript.get_kit_secondary_color(selected_country_kit_id))
	kit_shorts_swatch = _build_swatch("BroadcastKitShortsSwatch", AvatarCatalogScript.get_kit_shorts_color(selected_country_kit_id))
	kit_flag.add_child(kit_swatch)
	kit_flag.add_child(kit_secondary_swatch)
	kit_flag.add_child(kit_shorts_swatch)
	kit_row.add_child(_build_cycle_button("CountryKitPreviousButton", "<", func() -> void:
		_cycle_country_kit(-1)
	))
	kit_label = _build_row_label("BroadcastCountryKitLabel", AvatarCatalogScript.get_country_kit_label(selected_country_kit_id))
	kit_row.add_child(kit_label)
	kit_row.add_child(_build_cycle_button("CountryKitNextButton", ">", func() -> void:
		_cycle_country_kit(1)
	))

func _build_settings_rows(parent: VBoxContainer) -> void:
	parent.add_child(_build_section_label("AudioVideoSectionLabel", "CONTROLE DA TRANSMISSAO"))

	var settings = _get_game_settings()
	volume_slider = _build_volume_row(parent, "VolumeRow", "VolumeLabel", "Master", "VolumeSlider", _on_volume_changed, settings.get_volume(BUS_MASTER) if settings != null else 0.82)
	sfx_volume_slider = _build_volume_row(parent, "SfxVolumeRow", "SfxVolumeLabel", "SFX", "SfxVolumeSlider", _on_sfx_volume_changed, settings.get_volume(BUS_SFX) if settings != null else 0.86)
	ui_volume_slider = _build_volume_row(parent, "UiVolumeRow", "UiVolumeLabel", "UI", "UiVolumeSlider", _on_ui_volume_changed, settings.get_volume(BUS_UI) if settings != null else 0.9)
	ambience_volume_slider = _build_volume_row(parent, "AmbienceVolumeRow", "AmbienceVolumeLabel", "Ambiente", "AmbienceVolumeSlider", _on_ambience_volume_changed, settings.get_volume(BUS_AMBIENCE) if settings != null else 0.78)

	var quality_row := HBoxContainer.new()
	quality_row.name = "QualityRow"
	quality_row.add_theme_constant_override("separation", 6)
	quality_row.custom_minimum_size.y = 24.0
	parent.add_child(quality_row)

	var quality_label := _build_row_label("QualityLabel", "Qualidade")
	quality_label.custom_minimum_size.x = 88.0
	quality_row.add_child(quality_label)

	quality_option = OptionButton.new()
	quality_option.name = "QualityOption"
	quality_option.custom_minimum_size = Vector2(0.0, 24.0)
	quality_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_broadcast_font(quality_option, 11, true)
	quality_option.add_item("Alta")
	quality_option.add_item("Leve")
	_select_quality_option(settings.get_quality_id() if settings != null else RenderProfileScript.QUALITY_HIGH)
	quality_option.item_selected.connect(_on_quality_selected)
	quality_row.add_child(quality_option)

	var toon_row := HBoxContainer.new()
	toon_row.name = "ToonRenderRow"
	toon_row.add_theme_constant_override("separation", 6)
	toon_row.custom_minimum_size.y = 24.0
	parent.add_child(toon_row)

	var toon_label := _build_row_label("ToonRenderLabel", "Toon")
	toon_label.custom_minimum_size.x = 88.0
	toon_row.add_child(toon_label)

	toon_check_button = CheckButton.new()
	toon_check_button.name = "ToonRenderToggle"
	toon_check_button.text = "Experimento"
	toon_check_button.custom_minimum_size = Vector2(0.0, 24.0)
	toon_check_button.button_pressed = selected_toon_render_enabled
	toon_check_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_apply_broadcast_font(toon_check_button, 11, true)
	toon_check_button.toggled.connect(func(is_pressed: bool) -> void:
		_play_ui_sound(&"ui_click")
		selected_toon_render_enabled = is_pressed
		status_label.text = "Toon: %s" % ("ON" if selected_toon_render_enabled else "OFF")
	)
	toon_row.add_child(toon_check_button)

func _build_volume_row(parent: VBoxContainer, row_name: String, label_name: String, label: String, slider_name: String, callback: Callable, default_value: float) -> HSlider:
	var volume_row := HBoxContainer.new()
	volume_row.name = row_name
	volume_row.add_theme_constant_override("separation", 6)
	volume_row.custom_minimum_size.y = 24.0
	parent.add_child(volume_row)

	var volume_label := _build_row_label(label_name, label)
	volume_label.custom_minimum_size.x = 88.0
	volume_row.add_child(volume_label)

	var slider := HSlider.new()
	slider.name = slider_name
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = default_value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(callback)
	volume_row.add_child(slider)
	return slider

func _build_button(node_name: String, label: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = Vector2(320.0, 52.0 if node_name == "FootballButton" else 34.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	if node_name == "FootballButton":
		button.add_theme_font_size_override("font_size", 20)
		_apply_button_style(button, Color(0.02, 0.48, 0.20, 1.0), Color(1.0, 0.78, 0.16, 1.0), Color(0.04, 0.64, 0.26, 1.0))
	else:
		_apply_broadcast_font(button, 12, true)
		_apply_button_style(button, Color(0.02, 0.08, 0.11, 1.0), Color(0.28, 0.74, 0.78, 0.75), Color(0.04, 0.14, 0.18, 1.0))
	return button

func _build_cycle_button(node_name: String, label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = Vector2(32.0, 24.0)
	button.add_theme_font_size_override("font_size", 13)
	_apply_button_style(button, Color(0.035, 0.11, 0.14, 1.0), Color(1.0, 0.78, 0.16, 0.8), Color(0.08, 0.20, 0.22, 1.0))
	button.pressed.connect(func() -> void:
		_play_ui_sound(&"ui_click")
		callback.call()
	)
	return button

func _build_row_label(node_name: String, label: String) -> Label:
	var row_label := Label.new()
	row_label.name = node_name
	row_label.text = label
	row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row_label.add_theme_color_override("font_color", Color(0.86, 0.94, 0.95, 1.0))
	_apply_broadcast_font(row_label, 11, true)
	return row_label

func _build_swatch(node_name: String, color: Color) -> ColorRect:
	var swatch := ColorRect.new()
	swatch.name = node_name
	swatch.color = color
	swatch.custom_minimum_size = Vector2(18.0, 24.0)
	return swatch

func _build_section_label(node_name: String, text: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.custom_minimum_size = Vector2(0.0, 12.0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.16, 1.0))
	_apply_broadcast_font(label, 10, true)
	return label

func _focus_initial_control() -> void:
	if football_button != null:
		football_button.grab_focus()

func _position_menu_panel() -> void:
	if menu_panel == null:
		return
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var required_size := _get_menu_required_size()
	var panel_width := minf(required_size.x, maxf(360.0, viewport_size.x - MENU_PANEL_SIDE_MARGIN * 2.0))
	var panel_height := minf(required_size.y, maxf(0.0, viewport_size.y - MENU_PANEL_MIN_TOP_MARGIN * 2.0))
	var panel_x := (viewport_size.x - panel_width) * 0.5
	if viewport_size.x >= 980.0:
		var preferred_x := viewport_size.x - panel_width - MENU_PANEL_SIDE_MARGIN
		var hero_clearance := minf(viewport_size.x * 0.46, 720.0)
		var right_limit := maxf(MENU_PANEL_SIDE_MARGIN, viewport_size.x - panel_width - MENU_PANEL_SIDE_MARGIN * 0.5)
		panel_x = clampf(preferred_x, hero_clearance, right_limit)
	var panel_y := maxf(MENU_PANEL_MIN_TOP_MARGIN, (viewport_size.y - panel_height) * 0.5)
	menu_panel.position = Vector2(panel_x, panel_y)
	menu_panel.size = Vector2(panel_width, panel_height)

func _build_menu_fade_overlay() -> void:
	fade_overlay = ColorRect.new()
	fade_overlay.name = "MenuFadeOverlay"
	fade_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fade_overlay)

func _play_fade_from_black() -> void:
	if _is_headless_display():
		_set_fade_alpha_immediate(0.0)
		return
	call_deferred("_fade_to_alpha_async", 0.0, MENU_TRANSITION_SECONDS)

func _play_fade_to_black() -> void:
	if _is_headless_display():
		_set_fade_alpha_immediate(1.0)
		return
	call_deferred("_fade_to_alpha_async", 1.0, MENU_TRANSITION_SECONDS)

func _fade_to_alpha_async(target_alpha: float, duration: float) -> void:
	if fade_overlay == null:
		return
	if fade_tween != null:
		fade_tween.kill()
	fade_overlay.visible = true
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	fade_tween = create_tween()
	fade_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fade_tween.tween_property(fade_overlay, "color:a", clampf(target_alpha, 0.0, 1.0), maxf(0.01, duration))
	await fade_tween.finished
	if fade_overlay == null:
		return
	if target_alpha <= 0.001:
		fade_overlay.visible = false
		fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

func _set_fade_alpha_immediate(target_alpha: float) -> void:
	if fade_overlay == null:
		return
	if fade_tween != null:
		fade_tween.kill()
		fade_tween = null
	fade_overlay.color = Color(0.0, 0.0, 0.0, clampf(target_alpha, 0.0, 1.0))
	fade_overlay.visible = target_alpha > 0.001
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP if fade_overlay.visible else Control.MOUSE_FILTER_IGNORE

func _is_headless_display() -> bool:
	return DisplayServer.get_name().to_lower().contains("headless")

func _build_panel_style(fill_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 22
	style.content_margin_top = 10
	style.content_margin_right = 22
	style.content_margin_bottom = 10
	return style

func _build_compact_style(fill_color: Color, border_color: Color, border_width: int, radius: int = 5) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 8
	style.content_margin_top = 4
	style.content_margin_right = 8
	style.content_margin_bottom = 4
	return style

func _apply_button_style(button: Button, normal_color: Color, border_color: Color, hover_color: Color) -> void:
	button.add_theme_stylebox_override("normal", _build_compact_style(normal_color, border_color, 1))
	button.add_theme_stylebox_override("hover", _build_compact_style(hover_color, border_color, 1))
	button.add_theme_stylebox_override("pressed", _build_compact_style(hover_color.darkened(0.12), border_color, 1))
	button.add_theme_stylebox_override("focus", _build_compact_style(Color(0.0, 0.0, 0.0, 0.0), Color(1.0, 0.94, 0.62, 1.0), 2))
	button.add_theme_color_override("font_color", Color(0.94, 0.99, 0.96, 1.0))

func _apply_broadcast_font(control: Control, font_size: int, use_narrow: bool) -> void:
	var font := broadcast_narrow_font if use_narrow and broadcast_narrow_font != null else broadcast_font
	if font != null:
		control.add_theme_font_override("font", font)
	control.add_theme_font_size_override("font_size", font_size)

func _apply_broadcast_mono_font(control: Control, font_size: int) -> void:
	if broadcast_mono_font != null:
		control.add_theme_font_override("font", broadcast_mono_font)
	control.add_theme_font_size_override("font_size", font_size)

func _build_material(color: Color, roughness: float, emission: Color, emission_energy: float, render_profile_role: StringName = &"default") -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = RenderProfileScript.adjust_emission_energy(emission_energy, render_profile_role)
	return material

func _update_preview_selection() -> void:
	var appearance = AvatarAppearanceScript.new(selected_skin_tone_id, selected_country_kit_id)
	if preview_avatar != null:
		preview_avatar.apply_appearance(appearance)
	_request_preview_viewport_update()
	if skin_label != null:
		skin_label.text = AvatarCatalogScript.get_skin_label(selected_skin_tone_id)
	if kit_label != null:
		kit_label.text = AvatarCatalogScript.get_country_kit_label(selected_country_kit_id)
	if skin_swatch != null:
		skin_swatch.color = AvatarCatalogScript.get_skin_color(selected_skin_tone_id)
	if kit_swatch != null:
		kit_swatch.color = AvatarCatalogScript.get_kit_primary_color(selected_country_kit_id)
	if kit_secondary_swatch != null:
		kit_secondary_swatch.color = AvatarCatalogScript.get_kit_secondary_color(selected_country_kit_id)
	if kit_shorts_swatch != null:
		kit_shorts_swatch.color = AvatarCatalogScript.get_kit_shorts_color(selected_country_kit_id)

func _request_preview_viewport_update() -> void:
	if preview_viewport == null or not RenderProfileScript.is_web_platform():
		return
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func _cycle_bot_difficulty(step: int) -> void:
	var index := BOT_DIFFICULTY_IDS.find(selected_bot_difficulty_id)
	if index < 0:
		index = 1
	index = (index + step) % BOT_DIFFICULTY_IDS.size()
	if index < 0:
		index += BOT_DIFFICULTY_IDS.size()
	selected_bot_difficulty_id = StringName(BOT_DIFFICULTY_IDS[index])
	if difficulty_label != null:
		difficulty_label.text = _get_bot_difficulty_label(selected_bot_difficulty_id)
	status_label.text = "Dificuldade: %s" % _get_bot_difficulty_label(selected_bot_difficulty_id)

func _cycle_match_mode(step: int) -> void:
	var index := MATCH_MODE_IDS.find(selected_match_mode_id)
	if index < 0:
		index = 0
	index = (index + step) % MATCH_MODE_IDS.size()
	if index < 0:
		index += MATCH_MODE_IDS.size()
	selected_match_mode_id = StringName(MATCH_MODE_IDS[index])
	if match_mode_label != null:
		match_mode_label.text = _get_match_mode_label(selected_match_mode_id)
	status_label.text = "Modo: %s" % _get_match_mode_label(selected_match_mode_id)

func _cycle_skin_tone(step: int) -> void:
	selected_skin_tone_id = AvatarCatalogScript.get_next_skin_tone_id(selected_skin_tone_id, step)
	_update_preview_selection()
	status_label.text = "Pele do hero shot: %s" % AvatarCatalogScript.get_skin_label(selected_skin_tone_id)

func _cycle_country_kit(step: int) -> void:
	selected_country_kit_id = AvatarCatalogScript.get_next_country_kit_id(selected_country_kit_id, step)
	_update_preview_selection()
	status_label.text = "Kit do hero shot: %s" % AvatarCatalogScript.get_country_kit_label(selected_country_kit_id)

func _get_bot_difficulty_label(difficulty_id: StringName) -> String:
	return str(BOT_DIFFICULTY_LABELS.get(difficulty_id, "Bot normal"))

func _get_match_mode_label(match_mode_id: StringName) -> String:
	return str(MATCH_MODE_LABELS.get(match_mode_id, "3 minutos"))

func _on_volume_changed(value: float) -> void:
	_apply_volume_setting(BUS_MASTER, value)
	status_label.text = "Volume: %.0f%%" % [value * 100.0]

func _apply_initial_audio_mix() -> void:
	var settings = _get_game_settings()
	if settings != null:
		settings.apply_audio_settings()
		return
	if volume_slider != null:
		_set_bus_volume(BUS_MASTER, volume_slider.value)
	if sfx_volume_slider != null:
		_set_bus_volume(BUS_SFX, sfx_volume_slider.value)
	if ui_volume_slider != null:
		_set_bus_volume(BUS_UI, ui_volume_slider.value)
	if ambience_volume_slider != null:
		_set_bus_volume(BUS_AMBIENCE, ambience_volume_slider.value)

func _on_sfx_volume_changed(value: float) -> void:
	_apply_volume_setting(BUS_SFX, value)
	status_label.text = "SFX: %.0f%%" % [value * 100.0]

func _on_ui_volume_changed(value: float) -> void:
	_apply_volume_setting(BUS_UI, value)
	status_label.text = "UI: %.0f%%" % [value * 100.0]

func _on_ambience_volume_changed(value: float) -> void:
	_apply_volume_setting(BUS_AMBIENCE, value)
	status_label.text = "Ambiente: %.0f%%" % [value * 100.0]

func _on_quality_selected(index: int) -> void:
	var settings = _get_game_settings()
	var quality_id := _quality_id_for_option_index(index)
	if settings != null:
		settings.set_quality_id(quality_id)
	else:
		RenderProfileScript.set_quality_id(quality_id)
	_select_quality_option(quality_id)
	_apply_render_profile_to_menu_preview()
	_play_ui_sound(&"ui_click")
	if status_label != null:
		status_label.text = "Qualidade: %s" % RenderProfileScript.get_quality_label(quality_id)

func _on_settings_quality_changed(quality_id: StringName) -> void:
	_select_quality_option(quality_id)
	_apply_render_profile_to_menu_preview()

func _apply_volume_setting(bus_name: StringName, value: float) -> void:
	var settings = _get_game_settings()
	if settings != null:
		settings.set_volume(bus_name, value)
		return
	_set_bus_volume(bus_name, value)

func _get_game_settings():
	return get_node_or_null("/root/GameSettings")

func _connect_game_settings_signals() -> void:
	var settings = _get_game_settings()
	if settings == null:
		return
	if not settings.quality_changed.is_connected(_on_settings_quality_changed):
		settings.quality_changed.connect(_on_settings_quality_changed)

func _quality_id_for_option_index(index: int) -> StringName:
	return RenderProfileScript.QUALITY_LIGHT if index == 1 else RenderProfileScript.QUALITY_HIGH

func _select_quality_option(quality_id: StringName) -> void:
	if quality_option == null:
		return
	quality_option.select(1 if RenderProfileScript.normalize_quality_id(quality_id) == RenderProfileScript.QUALITY_LIGHT else 0)

func _apply_render_profile_to_menu_preview() -> void:
	var render_settings := RenderProfileScript.get_environment_settings()
	if preview_viewport != null:
		preview_viewport.size = RenderProfileScript.get_menu_preview_viewport_size()
		preview_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE if RenderProfileScript.is_web_platform() else SubViewport.UPDATE_ALWAYS
	if preview_environment != null:
		preview_environment.glow_enabled = bool(render_settings["glow_enabled"])
		preview_environment.glow_intensity = float(render_settings["glow_intensity"])
		preview_environment.glow_strength = float(render_settings["glow_strength"])
		preview_environment.tonemap_exposure = RenderProfileScript.get_menu_preview_tonemap_exposure()
	_request_preview_viewport_update()

func _set_bus_volume(bus_name: StringName, value: float) -> void:
	_ensure_audio_bus(bus_name)
	var bus_index := AudioServer.get_bus_index(str(bus_name))
	if bus_index < 0:
		return
	var clamped_value := clampf(value, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, clamped_value <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, -80.0 if clamped_value <= 0.001 else linear_to_db(clamped_value))

func _ensure_audio_buses() -> void:
	_ensure_audio_bus(BUS_SFX)
	_ensure_audio_bus(BUS_UI)
	_ensure_audio_bus(BUS_AMBIENCE)

func _ensure_audio_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(str(bus_name)) >= 0:
		return
	AudioServer.add_bus(AudioServer.get_bus_count())
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, str(bus_name))
	AudioServer.set_bus_send(bus_index, "Master")

func _load_ui_audio_streams() -> void:
	ui_audio_streams.clear()
	for audio_key: StringName in MENU_UI_AUDIO_PATHS.keys():
		var audio_path := str(MENU_UI_AUDIO_PATHS[audio_key])
		var stream := load(audio_path) as AudioStream
		if stream == null:
			push_warning("Missing menu audio stream: %s" % audio_path)
			continue
		ui_audio_streams[audio_key] = stream

func _build_ui_audio_pool() -> void:
	if not ui_audio_pool.is_empty():
		return
	for index in range(UI_AUDIO_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "MenuUiAudioPlayer%d" % index
		player.bus = BUS_UI
		add_child(player)
		ui_audio_pool.append(player)

func _can_play_web_audio(force_poll: bool = false) -> bool:
	if not RenderProfileScript.is_web_platform():
		return true
	if web_audio_unlocked:
		return true
	var now_msec := Time.get_ticks_msec()
	if not force_poll and now_msec < web_audio_next_unlock_poll_msec:
		return false
	web_audio_next_unlock_poll_msec = now_msec + WEB_AUDIO_UNLOCK_POLL_MSEC
	var state := str(JavaScriptBridge.eval("navigator.userActivation && navigator.userActivation.hasBeenActive ? '1' : '0'", true))
	web_audio_unlocked = state == "1"
	if not web_audio_unlocked and not web_audio_locked_logged:
		web_audio_locked_logged = true
		PerfProbeScript.mark(self, "menu.web_audio_locked", "waiting_for_browser_user_activation=true")
	return web_audio_unlocked

func _play_ui_sound(audio_key: StringName) -> void:
	if not _can_play_web_audio(true):
		return
	if ui_audio_pool.is_empty():
		_build_ui_audio_pool()
	var stream := ui_audio_streams.get(audio_key) as AudioStream
	if stream == null or ui_audio_pool.is_empty():
		return
	var player := ui_audio_pool[ui_audio_pool_cursor]
	ui_audio_pool_cursor = (ui_audio_pool_cursor + 1) % ui_audio_pool.size()
	player.stop()
	player.stream = stream
	player.volume_db = -8.0 if audio_key == &"ui_confirmation" else -11.0
	player.pitch_scale = 1.0
	player.play()

func _load_mode(scene_path: String) -> void:
	call_deferred("_load_mode_async", scene_path)

func _try_load_web_capture_scene() -> void:
	var capture_scene_id := _get_web_capture_scene_id()
	if capture_scene_id == &"":
		return
	if capture_scene_id == CAPTURE_SCENE_MENU:
		return
	if not _is_capture_scene_supported(capture_scene_id):
		push_error("Unsupported JogoDaCopa web capture scene: %s" % str(capture_scene_id))
		return
	get_tree().root.set_meta(CAPTURE_SCENE_META_KEY, capture_scene_id)
	selected_bot_difficulty_id = &"normal"
	selected_match_mode_id = &"goals"
	selected_toon_render_enabled = false
	_load_mode(FOOTBALL_SCENE_PATH)

func _get_web_capture_scene_id() -> StringName:
	var command_line_capture := _get_capture_scene_id_from_args()
	if command_line_capture != &"":
		return command_line_capture
	if not OS.has_feature("web"):
		return &""
	var query_string := str(JavaScriptBridge.eval("window.location.search", true))
	if query_string.is_empty() or query_string == "null":
		return &""
	if query_string.begins_with("?"):
		query_string = query_string.substr(1)
	for query_pair in query_string.split("&", false):
		var key := query_pair.get_slice("=", 0).uri_decode()
		if key != CAPTURE_QUERY_KEY:
			continue
		var value := query_pair.get_slice("=", 1).uri_decode().strip_edges().to_lower()
		return StringName(value)
	return &""

func _get_capture_scene_id_from_args() -> StringName:
	for arg in _collect_command_line_args():
		var normalized := arg.strip_edges()
		var lowered := normalized.to_lower()
		if lowered.begins_with("--jdc_capture=") or lowered.begins_with("--jdc-capture="):
			return StringName(normalized.get_slice("=", 1).strip_edges().to_lower())
	return &""

func _collect_command_line_args() -> Array[String]:
	var args: Array[String] = []
	for arg in OS.get_cmdline_args():
		args.append(str(arg))
	for arg in OS.get_cmdline_user_args():
		args.append(str(arg))
	return args

func _is_capture_scene_supported(capture_scene_id: StringName) -> bool:
	return (
		capture_scene_id == CAPTURE_SCENE_MENU
		or capture_scene_id == CAPTURE_SCENE_KICKOFF
		or capture_scene_id == CAPTURE_SCENE_GOAL
		or capture_scene_id == CAPTURE_SCENE_RESULT
		or capture_scene_id == CAPTURE_SCENE_PLAY
	)

func _load_mode_async(scene_path: String) -> void:
	var load_begin := PerfProbeScript.begin(self, "menu.load_mode", "scene=%s" % scene_path)
	status_label.text = "Carregando..."
	get_tree().root.set_meta(BOT_DIFFICULTY_META_KEY, selected_bot_difficulty_id)
	get_tree().root.set_meta(MATCH_MODE_META_KEY, selected_match_mode_id)
	get_tree().root.set_meta(TOON_RENDER_META_KEY, selected_toon_render_enabled)
	_play_fade_to_black()
	await get_tree().create_timer(MENU_TRANSITION_SECONDS, true, false, true).timeout
	PerfProbeScript.end(self, "menu.load_mode.fade_wait", load_begin, "scene=%s" % scene_path)
	PerfProbeScript.mark(self, "menu.change_scene.begin", "scene=%s" % scene_path)
	get_tree().change_scene_to_file(scene_path)

func _get_menu_required_size() -> Vector2:
	if menu_panel == null:
		return MENU_PANEL_MIN_SIZE
	var panel_size := menu_panel.get_combined_minimum_size()
	return Vector2(maxf(panel_size.x, MENU_PANEL_MIN_SIZE.x), maxf(panel_size.y, MENU_PANEL_MIN_SIZE.y))
