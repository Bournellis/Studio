class_name JogoDaCopaMainMenu
extends Control

const FOOTBALL_SCENE_PATH: String = "res://modes/football/football.tscn"
const MENU_PANEL_SIZE: Vector2 = Vector2(520.0, 360.0)

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
		&"football":
			return FOOTBALL_SCENE_PATH
		_:
			return ""

func _build_ui() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var background := ColorRect.new()
	background.name = "WorldCupBackdrop"
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.02, 0.09, 0.08, 1.0)
	add_child(background)

	var pitch_band := ColorRect.new()
	pitch_band.name = "PitchBand"
	pitch_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pitch_band.anchor_left = 0.0
	pitch_band.anchor_top = 0.62
	pitch_band.anchor_right = 1.0
	pitch_band.anchor_bottom = 1.0
	pitch_band.color = Color(0.02, 0.34, 0.12, 1.0)
	add_child(pitch_band)

	var gold_strip := ColorRect.new()
	gold_strip.name = "GoldStrip"
	gold_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold_strip.anchor_left = 0.0
	gold_strip.anchor_top = 0.6
	gold_strip.anchor_right = 1.0
	gold_strip.anchor_bottom = 0.615
	gold_strip.color = Color(0.96, 0.76, 0.14, 1.0)
	add_child(gold_strip)

	var menu_center := CenterContainer.new()
	menu_center.name = "MenuCenter"
	menu_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_center)

	var menu_panel := PanelContainer.new()
	menu_panel.name = "MenuPanel"
	menu_panel.custom_minimum_size = MENU_PANEL_SIZE
	menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
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
	center.add_theme_constant_override("separation", 14)
	margin.add_child(center)

	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "Jogo Da Copa"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 42)
	center.add_child(title)

	var subtitle := Label.new()
	subtitle.name = "SubtitleLabel"
	subtitle.text = "Minigames de futebol"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	subtitle.add_theme_font_size_override("font_size", 16)
	center.add_child(subtitle)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Escolha um minigame"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.add_theme_font_size_override("font_size", 14)
	center.add_child(status_label)

	football_button = _build_button("FootballButton", "Futebol 1x1")
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
	footer.text = "PC Windows editor-first | Copa minigames"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_theme_font_size_override("font_size", 12)
	center.add_child(footer)

func _build_button(node_name: String, label: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = label
	button.custom_minimum_size = Vector2(320.0, 46.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_ALL
	return button

func _load_mode(scene_path: String) -> void:
	status_label.text = "Carregando..."
	get_tree().change_scene_to_file(scene_path)
