class_name JogoDaCopaMainMenu
extends Control

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")
const AvatarCatalogScript = preload("res://gameplay/avatar/avatar_catalog.gd")
const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")

const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const MENU_PANEL_SIZE: Vector2 = Vector2(560.0, 640.0)
const BOT_DIFFICULTY_META_KEY: String = "jogodacopa_bot_difficulty"
const MATCH_MODE_META_KEY: String = "jogodacopa_match_mode"
const TOON_RENDER_META_KEY: String = "jogodacopa_toon_render"
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

var football_button: Button
var quit_button: Button
var status_label: Label
var preview_viewport: SubViewport
var preview_camera: Camera3D
var preview_root: Node3D
var preview_avatar
var preview_ball: MeshInstance3D
var skin_label: Label
var kit_label: Label
var difficulty_label: Label
var match_mode_label: Label
var skin_swatch: ColorRect
var kit_swatch: ColorRect
var volume_slider: HSlider
var quality_option: OptionButton
var toon_check_button: CheckButton

var preview_time: float = 0.0
var selected_skin_tone_id: StringName = AvatarCatalogScript.DEFAULT_SKIN_TONE_ID
var selected_country_kit_id: StringName = AvatarCatalogScript.DEFAULT_COUNTRY_KIT_ID
var selected_bot_difficulty_id: StringName = &"normal"
var selected_match_mode_id: StringName = &"timer"
var selected_toon_render_enabled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_ui()
	_update_preview_selection()

func _process(delta: float) -> void:
	preview_time += delta
	if preview_root != null:
		preview_root.rotation.y = sin(preview_time * 0.45) * 0.08
	if preview_ball != null:
		preview_ball.rotation = Vector3(preview_time * 2.2, preview_time * 1.4, preview_time * 0.8)
	if preview_avatar != null:
		preview_avatar.set_move_state(2.8 + sin(preview_time * 2.0) * 1.2, true, 0.0)
	if preview_camera != null:
		var angle := preview_time * 0.18
		preview_camera.position = Vector3(sin(angle) * 6.8, 3.2, cos(angle) * 6.8 + 4.4)
		preview_camera.look_at(Vector3(0.0, 0.85, 0.0), Vector3.UP)

func debug_get_mode_path(mode_id: StringName) -> String:
	match mode_id:
		&"football":
			return FOOTBALL_SCENE_PATH
		_:
			return ""

func debug_has_arena_preview() -> bool:
	return preview_viewport != null and preview_camera != null and preview_avatar != null

func debug_get_selected_kit_id() -> StringName:
	return selected_country_kit_id

func debug_get_selected_bot_difficulty_id() -> StringName:
	return selected_bot_difficulty_id

func debug_get_selected_match_mode_id() -> StringName:
	return selected_match_mode_id

func debug_is_toon_render_enabled() -> bool:
	return selected_toon_render_enabled

func debug_cycle_bot_difficulty(step: int = 1) -> void:
	_cycle_bot_difficulty(step)

func debug_cycle_match_mode(step: int = 1) -> void:
	_cycle_match_mode(step)

func debug_get_quality_text() -> String:
	if quality_option == null:
		return ""
	return quality_option.get_item_text(quality_option.selected)

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

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

	var menu_center := CenterContainer.new()
	menu_center.name = "MenuCenter"
	menu_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_center)

	var menu_panel := PanelContainer.new()
	menu_panel.name = "MenuPanel"
	menu_panel.custom_minimum_size = MENU_PANEL_SIZE
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_panel.add_theme_stylebox_override("panel", _build_panel_style(Color(0.012, 0.03, 0.04, 0.88), Color(1.0, 0.78, 0.16, 0.9), 2))
	menu_center.add_child(menu_panel)

	var margin := MarginContainer.new()
	margin.name = "MenuMargin"
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	menu_panel.add_child(margin)

	var center := VBoxContainer.new()
	center.name = "MenuBox"
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_theme_constant_override("separation", 12)
	margin.add_child(center)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Copa Arena Futebol"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 44)
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "Futebol arcade em arena de vidro"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle.add_theme_font_size_override("font_size", 16)
	center.add_child(subtitle)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Noite de final - primeiro a 3 gols"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_font_size_override("font_size", 14)
	center.add_child(status_label)

	_build_selector_rows(center)
	_build_settings_rows(center)

	football_button = _build_button("FootballButton", "Jogar Futebol 1x1")
	football_button.pressed.connect(func() -> void:
		_load_mode(FOOTBALL_SCENE_PATH)
	)
	center.add_child(football_button)

	quit_button = _build_button("QuitButton", "Sair")
	quit_button.pressed.connect(func() -> void:
		get_tree().quit()
	)
	center.add_child(quit_button)

	var footer := Label.new()
	footer.name = "FooterLabel"
	footer.text = "PC Windows editor-first | sem logos oficiais"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_theme_font_size_override("font_size", 12)
	center.add_child(footer)

func _build_arena_preview() -> void:
	preview_viewport = SubViewport.new()
	preview_viewport.name = "ArenaPreviewViewport"
	preview_viewport.size = Vector2i(1280, 720)
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(preview_viewport)

	var world := Node3D.new()
	world.name = "PreviewWorld"
	preview_viewport.add_child(world)

	var environment := WorldEnvironment.new()
	environment.name = "PreviewEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.006, 0.018, 0.035, 1.0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.24, 0.34, 0.46, 1.0)
	env.ambient_light_energy = 0.54
	env.glow_enabled = true
	env.glow_intensity = 0.32
	env.glow_strength = 0.82
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.environment = env
	world.add_child(environment)

	var key := DirectionalLight3D.new()
	key.name = "PreviewKeyLight"
	key.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	key.light_color = Color(0.8, 0.9, 1.0, 1.0)
	key.light_energy = 2.0
	world.add_child(key)

	preview_root = Node3D.new()
	preview_root.name = "PreviewArenaRoot"
	world.add_child(preview_root)
	_build_preview_pitch(preview_root)
	_build_preview_goal(preview_root, -8.6)
	_build_preview_goal(preview_root, 8.6)

	preview_avatar = PlayerAvatarScript.new()
	preview_avatar.name = "PreviewAvatar"
	preview_avatar.position = Vector3(-1.15, 0.0, 0.35)
	preview_avatar.rotation.y = -0.32
	preview_root.add_child(preview_avatar)

	preview_ball = MeshInstance3D.new()
	preview_ball.name = "PreviewBall"
	preview_ball.position = Vector3(0.88, 0.46, -0.32)
	var ball_mesh := SphereMesh.new()
	ball_mesh.radius = 0.34
	ball_mesh.height = 0.68
	ball_mesh.radial_segments = 24
	ball_mesh.rings = 12
	preview_ball.mesh = ball_mesh
	preview_ball.material_override = _build_material(Color(0.95, 0.97, 0.92, 1.0), 0.2, Color(0.2, 0.9, 1.0, 1.0), 0.18)
	preview_root.add_child(preview_ball)

	preview_camera = Camera3D.new()
	preview_camera.name = "PreviewCamera"
	preview_camera.current = true
	preview_camera.fov = 52.0
	world.add_child(preview_camera)

func _build_preview_pitch(parent: Node3D) -> void:
	var pitch := MeshInstance3D.new()
	pitch.name = "PreviewPitch"
	pitch.position = Vector3(0.0, -0.05, 0.0)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(14.0, 0.1, 20.0)
	pitch.mesh = mesh
	pitch.material_override = _build_material(Color(0.02, 0.42, 0.16, 1.0), 0.82, Color(0.0, 0.18, 0.08, 1.0), 0.05)
	parent.add_child(pitch)

	for index in range(5):
		var line := MeshInstance3D.new()
		line.name = "PreviewPitchStripe%d" % index
		line.position = Vector3(0.0, 0.03, -7.2 + index * 3.6)
		var stripe_mesh := BoxMesh.new()
		stripe_mesh.size = Vector3(14.2, 0.035, 0.08)
		line.mesh = stripe_mesh
		line.material_override = _build_material(Color(0.86, 0.96, 0.82, 1.0), 0.74, Color(0.5, 1.0, 0.7, 1.0), 0.08)
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
		post.material_override = _build_material(frame_color, 0.28, frame_color, 1.6)
		parent.add_child(post)
	var crossbar := MeshInstance3D.new()
	crossbar.name = "PreviewGoalCrossbar"
	crossbar.position = Vector3(0.0, 2.2, z_position)
	var crossbar_mesh := BoxMesh.new()
	crossbar_mesh.size = Vector3(4.55, 0.12, 0.12)
	crossbar.mesh = crossbar_mesh
	crossbar.material_override = _build_material(frame_color, 0.28, frame_color, 1.6)
	parent.add_child(crossbar)

func _build_selector_rows(parent: VBoxContainer) -> void:
	var skin_row := HBoxContainer.new()
	skin_row.name = "SkinPreviewRow"
	skin_row.add_theme_constant_override("separation", 8)
	parent.add_child(skin_row)

	skin_swatch = _build_swatch("SkinPreviewSwatch", Color(0.77, 0.50, 0.32, 1.0))
	skin_row.add_child(skin_swatch)
	skin_row.add_child(_build_cycle_button("SkinPreviousButton", "<", func() -> void:
		selected_skin_tone_id = AvatarCatalogScript.get_next_skin_tone_id(selected_skin_tone_id, -1)
		_update_preview_selection()
	))
	skin_label = _build_row_label("SkinPreviewLabel", "Pele bronze")
	skin_row.add_child(skin_label)
	skin_row.add_child(_build_cycle_button("SkinNextButton", ">", func() -> void:
		selected_skin_tone_id = AvatarCatalogScript.get_next_skin_tone_id(selected_skin_tone_id, 1)
		_update_preview_selection()
	))

	var kit_row := HBoxContainer.new()
	kit_row.name = "KitPreviewRow"
	kit_row.add_theme_constant_override("separation", 8)
	parent.add_child(kit_row)

	kit_swatch = _build_swatch("KitPreviewSwatch", Color(1.0, 0.86, 0.12, 1.0))
	kit_row.add_child(kit_swatch)
	kit_row.add_child(_build_cycle_button("KitPreviousButton", "<", func() -> void:
		selected_country_kit_id = AvatarCatalogScript.get_next_country_kit_id(selected_country_kit_id, -1)
		_update_preview_selection()
	))
	kit_label = _build_row_label("KitPreviewLabel", "Brasil inspirado")
	kit_row.add_child(kit_label)
	kit_row.add_child(_build_cycle_button("KitNextButton", ">", func() -> void:
		selected_country_kit_id = AvatarCatalogScript.get_next_country_kit_id(selected_country_kit_id, 1)
		_update_preview_selection()
	))

	var difficulty_row := HBoxContainer.new()
	difficulty_row.name = "BotDifficultyRow"
	difficulty_row.add_theme_constant_override("separation", 8)
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
	match_mode_row.add_theme_constant_override("separation", 8)
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

func _build_settings_rows(parent: VBoxContainer) -> void:
	var volume_row := HBoxContainer.new()
	volume_row.name = "VolumeRow"
	volume_row.add_theme_constant_override("separation", 8)
	parent.add_child(volume_row)

	var volume_label := _build_row_label("VolumeLabel", "Volume")
	volume_label.custom_minimum_size.x = 96.0
	volume_row.add_child(volume_label)

	volume_slider = HSlider.new()
	volume_slider.name = "VolumeSlider"
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.value = 0.82
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_slider.value_changed.connect(_on_volume_changed)
	volume_row.add_child(volume_slider)

	var quality_row := HBoxContainer.new()
	quality_row.name = "QualityRow"
	quality_row.add_theme_constant_override("separation", 8)
	parent.add_child(quality_row)

	var quality_label := _build_row_label("QualityLabel", "Qualidade")
	quality_label.custom_minimum_size.x = 96.0
	quality_row.add_child(quality_label)

	quality_option = OptionButton.new()
	quality_option.name = "QualityOption"
	quality_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quality_option.add_item("Alta")
	quality_option.add_item("Performance")
	quality_option.select(0)
	quality_option.item_selected.connect(func(index: int) -> void:
		status_label.text = "Qualidade: %s" % quality_option.get_item_text(index)
	)
	quality_row.add_child(quality_option)

	var toon_row := HBoxContainer.new()
	toon_row.name = "ToonRenderRow"
	toon_row.add_theme_constant_override("separation", 8)
	parent.add_child(toon_row)

	var toon_label := _build_row_label("ToonRenderLabel", "Toon")
	toon_label.custom_minimum_size.x = 96.0
	toon_row.add_child(toon_label)

	toon_check_button = CheckButton.new()
	toon_check_button.name = "ToonRenderToggle"
	toon_check_button.text = "Experimento"
	toon_check_button.button_pressed = selected_toon_render_enabled
	toon_check_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toon_check_button.toggled.connect(func(is_pressed: bool) -> void:
		selected_toon_render_enabled = is_pressed
		status_label.text = "Toon: %s" % ("ON" if selected_toon_render_enabled else "OFF")
	)
	toon_row.add_child(toon_check_button)

func _build_button(node_name: String, label: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = Vector2(320.0, 46.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	return button

func _build_cycle_button(node_name: String, label: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = Vector2(42.0, 34.0)
	button.pressed.connect(callback)
	return button

func _build_row_label(node_name: String, label: String) -> Label:
	var row_label := Label.new()
	row_label.name = node_name
	row_label.text = label
	row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return row_label

func _build_swatch(node_name: String, color: Color) -> ColorRect:
	var swatch := ColorRect.new()
	swatch.name = node_name
	swatch.color = color
	swatch.custom_minimum_size = Vector2(36.0, 28.0)
	return swatch

func _build_panel_style(fill_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style

func _build_material(color: Color, roughness: float, emission: Color, emission_energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = emission_energy
	return material

func _update_preview_selection() -> void:
	var appearance = AvatarAppearanceScript.new(selected_skin_tone_id, selected_country_kit_id)
	if preview_avatar != null:
		preview_avatar.apply_appearance(appearance)
	if skin_label != null:
		skin_label.text = AvatarCatalogScript.get_skin_label(selected_skin_tone_id)
	if kit_label != null:
		kit_label.text = AvatarCatalogScript.get_country_kit_label(selected_country_kit_id)
	if skin_swatch != null:
		skin_swatch.color = AvatarCatalogScript.get_skin_color(selected_skin_tone_id)
	if kit_swatch != null:
		kit_swatch.color = AvatarCatalogScript.get_kit_primary_color(selected_country_kit_id)

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

func _get_bot_difficulty_label(difficulty_id: StringName) -> String:
	return str(BOT_DIFFICULTY_LABELS.get(difficulty_id, "Bot normal"))

func _get_match_mode_label(match_mode_id: StringName) -> String:
	return str(MATCH_MODE_LABELS.get(match_mode_id, "3 minutos"))

func _on_volume_changed(value: float) -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(maxf(value, 0.01)))
	status_label.text = "Volume: %.0f%%" % [value * 100.0]

func _load_mode(scene_path: String) -> void:
	status_label.text = "Carregando..."
	get_tree().root.set_meta(BOT_DIFFICULTY_META_KEY, selected_bot_difficulty_id)
	get_tree().root.set_meta(MATCH_MODE_META_KEY, selected_match_mode_id)
	get_tree().root.set_meta(TOON_RENDER_META_KEY, selected_toon_render_enabled)
	get_tree().change_scene_to_file(scene_path)
