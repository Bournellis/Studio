class_name FpsPlaygroundMainMenu
extends Control

const ARENA_SCENE_PATH: String = "res://modes/arena/arena.tscn"
const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"

var arena_button: Button
var football_button: Button
var quit_button: Button
var status_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_ui()

func debug_get_mode_path(mode_id: StringName) -> String:
	match mode_id:
		&"arena":
			return ARENA_SCENE_PATH
		&"football":
			return FOOTBALL_SCENE_PATH
		_:
			return ""

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.name = "WorldCupBackdrop"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.02, 0.09, 0.08, 1.0)
	add_child(background)

	var pitch_band := ColorRect.new()
	pitch_band.name = "PitchBand"
	pitch_band.anchor_left = 0.0
	pitch_band.anchor_top = 0.62
	pitch_band.anchor_right = 1.0
	pitch_band.anchor_bottom = 1.0
	pitch_band.color = Color(0.02, 0.34, 0.12, 1.0)
	add_child(pitch_band)

	var gold_strip := ColorRect.new()
	gold_strip.name = "GoldStrip"
	gold_strip.anchor_left = 0.0
	gold_strip.anchor_top = 0.6
	gold_strip.anchor_right = 1.0
	gold_strip.anchor_bottom = 0.615
	gold_strip.color = Color(0.96, 0.76, 0.14, 1.0)
	add_child(gold_strip)

	var center := VBoxContainer.new()
	center.name = "MenuBox"
	center.set_anchors_preset(Control.PRESET_CENTER)
	center.position = Vector2(-210.0, -168.0)
	center.custom_minimum_size = Vector2(420.0, 336.0)
	center.add_theme_constant_override("separation", 14)
	add_child(center)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "FPS Playground"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "Arena Shooter + Futebol 1x1"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	center.add_child(subtitle)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Escolha um modo"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	center.add_child(status_label)

	arena_button = _build_button("ArenaButton", "Arena Shooter")
	arena_button.pressed.connect(func() -> void:
		_load_mode(ARENA_SCENE_PATH)
	)
	center.add_child(arena_button)

	football_button = _build_button("FootballButton", "Futebol")
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
	footer.text = "PC Windows editor-first | Copa mode prototype"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	center.add_child(footer)

func _build_button(node_name: String, label: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = Vector2(320.0, 46.0)
	button.focus_mode = Control.FOCUS_ALL
	return button

func _load_mode(scene_path: String) -> void:
	status_label.text = "Carregando..."
	get_tree().change_scene_to_file(scene_path)
