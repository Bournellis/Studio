class_name FootballHud
extends CanvasLayer

signal resume_requested()
signal main_menu_requested()
signal sensitivity_changed(value: float)
signal start_requested()
signal skin_tone_previous_requested()
signal skin_tone_next_requested()
signal country_kit_previous_requested()
signal country_kit_next_requested()

var status_label: Label
var score_label: Label
var clock_label: Label
var flow_label: Label
var hint_label: Label
var event_label: Label
var crosshair_root: Control
var crosshair_lines: Array[ColorRect] = []
var pulse_overlay: ColorRect
var intro_panel: PanelContainer
var pause_menu_panel: PanelContainer
var sensitivity_label: Label
var sensitivity_slider: HSlider
var skin_tone_label: Label
var country_kit_label: Label

var kick_feedback_time: float = 0.0
var strong_kick_feedback_time: float = 0.0
var whiff_feedback_time: float = 0.0
var goal_feedback_time: float = 0.0
var event_message_time: float = 0.0
var last_event: StringName = &""
var kick_count: int = 0
var whiff_count: int = 0
var goal_count: int = 0
var last_player_scored: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _process(delta: float) -> void:
	kick_feedback_time = maxf(0.0, kick_feedback_time - delta)
	strong_kick_feedback_time = maxf(0.0, strong_kick_feedback_time - delta)
	whiff_feedback_time = maxf(0.0, whiff_feedback_time - delta)
	goal_feedback_time = maxf(0.0, goal_feedback_time - delta)
	event_message_time = maxf(0.0, event_message_time - delta)
	_refresh_crosshair()
	_refresh_overlay()
	_refresh_event_label()

func update_snapshot(snapshot: Dictionary) -> void:
	status_label.text = str(snapshot.get("status", "Futebol 1x1"))
	score_label.text = "Player %d  -  %d Bot" % [
		int(snapshot.get("player_score", 0)),
		int(snapshot.get("bot_score", 0))
	]
	clock_label.text = "Ate %d gols | Bola %.1fm" % [
		int(snapshot.get("goal_limit", 3)),
		float(snapshot.get("ball_distance", 0.0))
	]
	var bot_state := str(snapshot.get("bot_state", "kickoff"))
	var phase := str(snapshot.get("phase", "kickoff"))
	flow_label.text = "Futebol: %s | Bot: %s" % [phase, bot_state]
	hint_label.text = str(snapshot.get("hint", "WASD move | Mouse gira jogador/camera | LMB chute | RMB chute forte | Space jump | R restart | Esc menu"))

func show_kick(strong: bool, connected: bool) -> void:
	if connected:
		last_event = &"strong_kick" if strong else &"kick"
		kick_count += 1
		kick_feedback_time = 0.16
		if strong:
			strong_kick_feedback_time = 0.24
			_set_event_message("CHUTE FORTE", 0.36)
		else:
			_set_event_message("CHUTE", 0.28)
		return
	last_event = &"whiff"
	whiff_count += 1
	whiff_feedback_time = 0.16
	_set_event_message("SEM CONTATO", 0.28)

func show_goal(player_scored: bool) -> void:
	last_event = &"goal"
	last_player_scored = player_scored
	goal_count += 1
	goal_feedback_time = 1.1
	_set_event_message("GOOOOL PLAYER" if player_scored else "GOL DO BOT", 1.1)

func show_match_end(player_won: bool) -> void:
	last_event = &"match_end"
	goal_feedback_time = 1.5
	_set_event_message("CAMPEAO" if player_won else "DERROTA", 1.6)

func reset_feedback() -> void:
	kick_feedback_time = 0.0
	strong_kick_feedback_time = 0.0
	whiff_feedback_time = 0.0
	goal_feedback_time = 0.0
	event_message_time = 0.0
	last_event = &""
	if event_label != null:
		event_label.text = ""
		event_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_refresh_crosshair()
	_refresh_overlay()

func set_pause_menu_visible(menu_is_open: bool, sensitivity_value: float) -> void:
	if pause_menu_panel == null:
		return
	pause_menu_panel.visible = menu_is_open
	set_sensitivity_value(sensitivity_value)

func set_intro_visible(intro_is_visible: bool) -> void:
	if intro_panel == null:
		return
	intro_panel.visible = intro_is_visible

func set_sensitivity_value(value: float) -> void:
	if sensitivity_slider == null:
		return
	sensitivity_slider.set_value_no_signal(value)
	_update_sensitivity_label(value)

func set_avatar_selection_labels(skin_label: String, kit_label: String) -> void:
	if skin_tone_label != null:
		skin_tone_label.text = "Pele: %s" % skin_label
	if country_kit_label != null:
		country_kit_label.text = "Camisa: %s" % kit_label

func _build_ui() -> void:
	var root := Control.new()
	root.name = "HudRoot"
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	_ignore_mouse(root)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	pulse_overlay = ColorRect.new()
	pulse_overlay.name = "PulseOverlay"
	_ignore_mouse(pulse_overlay)
	pulse_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	pulse_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	root.add_child(pulse_overlay)

	var panel := PanelContainer.new()
	panel.name = "ScorePanel"
	_ignore_mouse(panel)
	panel.position = Vector2(18.0, 18.0)
	panel.custom_minimum_size = Vector2(360.0, 126.0)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "ScoreBox"
	_ignore_mouse(box)
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Futebol 1x1"
	_ignore_mouse(status_label)
	box.add_child(status_label)

	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "Player 0  -  0 Bot"
	score_label.add_theme_font_size_override("font_size", 24)
	_ignore_mouse(score_label)
	box.add_child(score_label)

	clock_label = Label.new()
	clock_label.name = "ClockLabel"
	clock_label.text = "Ate 3 gols"
	_ignore_mouse(clock_label)
	box.add_child(clock_label)

	flow_label = Label.new()
	flow_label.name = "FlowLabel"
	flow_label.add_theme_font_size_override("font_size", 12)
	flow_label.text = "Futebol: kickoff | Bot: kickoff"
	_ignore_mouse(flow_label)
	box.add_child(flow_label)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	hint_label.position = Vector2(18.0, 152.0)
	hint_label.text = "Click captura mouse | LMB chute | RMB chute forte | Space jump | R restart | Esc menu"
	_ignore_mouse(hint_label)
	root.add_child(hint_label)

	_build_crosshair(root)
	_build_event_label(root)
	_build_pause_menu(root)
	_build_intro_panel(root)

func _build_crosshair(root: Control) -> void:
	crosshair_root = Control.new()
	crosshair_root.name = "FootballCrosshair"
	_ignore_mouse(crosshair_root)
	crosshair_root.set_anchors_preset(Control.PRESET_CENTER)
	crosshair_root.position = Vector2(-42.0, -42.0)
	crosshair_root.custom_minimum_size = Vector2(84.0, 84.0)
	crosshair_root.pivot_offset = Vector2(42.0, 42.0)
	root.add_child(crosshair_root)

	_add_crosshair_line("Top", Vector2(40.0, 12.0), Vector2(4.0, 19.0))
	_add_crosshair_line("Bottom", Vector2(40.0, 53.0), Vector2(4.0, 19.0))
	_add_crosshair_line("Left", Vector2(12.0, 40.0), Vector2(19.0, 4.0))
	_add_crosshair_line("Right", Vector2(53.0, 40.0), Vector2(19.0, 4.0))

func _add_crosshair_line(node_name: String, line_position: Vector2, line_size: Vector2) -> void:
	var line := ColorRect.new()
	line.name = node_name
	_ignore_mouse(line)
	line.position = line_position
	line.size = line_size
	line.color = Color(0.88, 1.0, 0.9, 0.88)
	crosshair_root.add_child(line)
	crosshair_lines.append(line)

func _build_event_label(root: Control) -> void:
	event_label = Label.new()
	event_label.name = "FootballEventLabel"
	_ignore_mouse(event_label)
	event_label.set_anchors_preset(Control.PRESET_CENTER)
	event_label.position = Vector2(-220.0, 54.0)
	event_label.size = Vector2(440.0, 42.0)
	event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_label.add_theme_font_size_override("font_size", 28)
	event_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	root.add_child(event_label)

func _build_pause_menu(root: Control) -> void:
	var pause_center := CenterContainer.new()
	pause_center.name = "PauseMenuCenter"
	pause_center.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(pause_center)

	pause_menu_panel = PanelContainer.new()
	pause_menu_panel.name = "PauseMenuPanel"
	pause_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu_panel.custom_minimum_size = Vector2(390.0, 232.0)
	pause_menu_panel.visible = false
	pause_center.add_child(pause_menu_panel)

	var margin := MarginContainer.new()
	margin.name = "PauseMenuMargin"
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 16)
	pause_menu_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.name = "PauseMenuBox"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var title := Label.new()
	title.name = "PauseTitle"
	title.text = "Futebol"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	_ignore_mouse(title)
	box.add_child(title)

	sensitivity_label = Label.new()
	sensitivity_label.name = "SensitivityLabel"
	_ignore_mouse(sensitivity_label)
	box.add_child(sensitivity_label)

	sensitivity_slider = HSlider.new()
	sensitivity_slider.name = "SensitivitySlider"
	sensitivity_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	sensitivity_slider.min_value = 0.0008
	sensitivity_slider.max_value = 0.0032
	sensitivity_slider.step = 0.0001
	sensitivity_slider.value_changed.connect(_on_sensitivity_slider_changed)
	box.add_child(sensitivity_slider)

	var resume_button := Button.new()
	resume_button.name = "ResumeButton"
	resume_button.text = "Retomar"
	resume_button.mouse_filter = Control.MOUSE_FILTER_STOP
	resume_button.pressed.connect(func() -> void:
		resume_requested.emit()
	)
	box.add_child(resume_button)

	var menu_button := Button.new()
	menu_button.name = "MainMenuButton"
	menu_button.text = "Menu inicial"
	menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_button.pressed.connect(func() -> void:
		main_menu_requested.emit()
	)
	box.add_child(menu_button)

func _build_intro_panel(root: Control) -> void:
	var intro_center := CenterContainer.new()
	intro_center.name = "IntroCenter"
	intro_center.process_mode = Node.PROCESS_MODE_ALWAYS
	intro_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(intro_center)

	intro_panel = PanelContainer.new()
	intro_panel.name = "IntroPanel"
	intro_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	intro_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	intro_panel.custom_minimum_size = Vector2(600.0, 510.0)
	intro_center.add_child(intro_panel)

	var margin := MarginContainer.new()
	margin.name = "IntroMargin"
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 20)
	intro_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.name = "IntroBox"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	var title := Label.new()
	title.name = "IntroTitle"
	title.text = "Como Jogar"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 28)
	_ignore_mouse(title)
	box.add_child(title)

	var summary := Label.new()
	summary.name = "IntroSummary"
	summary.text = "Futebol 1x1 em terceira pessoa. Primeiro a 3 gols vence."
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ignore_mouse(summary)
	box.add_child(summary)

	var hotkeys := Label.new()
	hotkeys.name = "HotkeysLabel"
	hotkeys.text = "WASD - mover\nMouse - girar jogador/camera\nEspaco - pular\nLMB - chute\nRMB - chute forte\nR - reiniciar partida\nEsc - menu de sensibilidade"
	hotkeys.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hotkeys.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hotkeys.add_theme_font_size_override("font_size", 15)
	_ignore_mouse(hotkeys)
	box.add_child(hotkeys)

	var avatar_box := VBoxContainer.new()
	avatar_box.name = "AvatarSelectionBox"
	avatar_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	avatar_box.add_theme_constant_override("separation", 8)
	box.add_child(avatar_box)

	var avatar_title := Label.new()
	avatar_title.name = "AvatarTitle"
	avatar_title.text = "Jogador"
	avatar_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar_title.add_theme_font_size_override("font_size", 17)
	_ignore_mouse(avatar_title)
	avatar_box.add_child(avatar_title)

	var skin_row := HBoxContainer.new()
	skin_row.name = "SkinToneRow"
	skin_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	skin_row.add_theme_constant_override("separation", 8)
	avatar_box.add_child(skin_row)

	var skin_previous := Button.new()
	skin_previous.name = "SkinPreviousButton"
	skin_previous.text = "<"
	skin_previous.custom_minimum_size = Vector2(42.0, 34.0)
	skin_previous.mouse_filter = Control.MOUSE_FILTER_STOP
	skin_previous.pressed.connect(func() -> void:
		skin_tone_previous_requested.emit()
	)
	skin_row.add_child(skin_previous)

	skin_tone_label = Label.new()
	skin_tone_label.name = "SkinToneLabel"
	skin_tone_label.text = "Pele: Pele bronze"
	skin_tone_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	skin_tone_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ignore_mouse(skin_tone_label)
	skin_row.add_child(skin_tone_label)

	var skin_next := Button.new()
	skin_next.name = "SkinNextButton"
	skin_next.text = ">"
	skin_next.custom_minimum_size = Vector2(42.0, 34.0)
	skin_next.mouse_filter = Control.MOUSE_FILTER_STOP
	skin_next.pressed.connect(func() -> void:
		skin_tone_next_requested.emit()
	)
	skin_row.add_child(skin_next)

	var kit_row := HBoxContainer.new()
	kit_row.name = "CountryKitRow"
	kit_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	kit_row.add_theme_constant_override("separation", 8)
	avatar_box.add_child(kit_row)

	var kit_previous := Button.new()
	kit_previous.name = "KitPreviousButton"
	kit_previous.text = "<"
	kit_previous.custom_minimum_size = Vector2(42.0, 34.0)
	kit_previous.mouse_filter = Control.MOUSE_FILTER_STOP
	kit_previous.pressed.connect(func() -> void:
		country_kit_previous_requested.emit()
	)
	kit_row.add_child(kit_previous)

	country_kit_label = Label.new()
	country_kit_label.name = "CountryKitLabel"
	country_kit_label.text = "Camisa: Brasil inspirado"
	country_kit_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	country_kit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ignore_mouse(country_kit_label)
	kit_row.add_child(country_kit_label)

	var kit_next := Button.new()
	kit_next.name = "KitNextButton"
	kit_next.text = ">"
	kit_next.custom_minimum_size = Vector2(42.0, 34.0)
	kit_next.mouse_filter = Control.MOUSE_FILTER_STOP
	kit_next.pressed.connect(func() -> void:
		country_kit_next_requested.emit()
	)
	kit_row.add_child(kit_next)

	var start_button := Button.new()
	start_button.name = "StartButton"
	start_button.text = "Comecar"
	start_button.custom_minimum_size = Vector2(320.0, 46.0)
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	start_button.pressed.connect(func() -> void:
		start_requested.emit()
	)
	box.add_child(start_button)

func _ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_sensitivity_slider_changed(value: float) -> void:
	_update_sensitivity_label(value)
	sensitivity_changed.emit(value)

func _update_sensitivity_label(value: float) -> void:
	if sensitivity_label == null:
		return
	sensitivity_label.text = "Sensibilidade: %.1f" % [value * 1000.0]

func _refresh_crosshair() -> void:
	if crosshair_root == null:
		return
	var color := Color(0.88, 1.0, 0.9, 0.88)
	var pulse := 0.0
	if goal_feedback_time > 0.0:
		color = Color(1.0, 0.88, 0.22, 1.0) if last_player_scored else Color(1.0, 0.32, 0.22, 1.0)
		pulse = 0.2
	elif strong_kick_feedback_time > 0.0:
		color = Color(0.34, 0.88, 1.0, 1.0)
		pulse = 0.14
	elif kick_feedback_time > 0.0:
		color = Color(0.36, 1.0, 0.58, 1.0)
		pulse = 0.09
	elif whiff_feedback_time > 0.0:
		color = Color(0.68, 0.78, 0.84, 0.72)
		pulse = 0.04
	for line: ColorRect in crosshair_lines:
		line.color = color
	crosshair_root.scale = Vector2.ONE * (1.0 + pulse)

func _refresh_overlay() -> void:
	if pulse_overlay == null:
		return
	var color := Color(0.0, 0.0, 0.0, 0.0)
	if goal_feedback_time > 0.0:
		var alpha := clampf(goal_feedback_time / 1.1, 0.0, 1.0) * 0.2
		color = Color(1.0, 0.82, 0.12, alpha) if last_player_scored else Color(1.0, 0.12, 0.08, alpha)
	pulse_overlay.color = color

func _refresh_event_label() -> void:
	if event_label == null:
		return
	var alpha := clampf(event_message_time / 0.25, 0.0, 1.0) if event_message_time > 0.0 else 0.0
	event_label.modulate = Color(1.0, 1.0, 1.0, alpha)

func _set_event_message(message: String, duration: float) -> void:
	event_label.text = message
	event_message_time = maxf(0.05, duration)
