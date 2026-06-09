class_name ArenaHud
extends CanvasLayer

signal resume_requested()
signal sensitivity_changed(value: float)

var status_label: Label
var player_label: Label
var bot_label: Label
var hint_label: Label
var player_health_bar: ProgressBar
var bot_health_bar: ProgressBar
var crosshair_root: Control
var crosshair_lines: Array[ColorRect] = []
var hit_marker_label: Label
var damage_overlay: ColorRect
var event_label: Label
var pause_menu_panel: PanelContainer
var sensitivity_label: Label
var sensitivity_slider: HSlider

var shot_feedback_time: float = 0.0
var hit_feedback_time: float = 0.0
var miss_feedback_time: float = 0.0
var damage_feedback_time: float = 0.0
var kill_feedback_time: float = 0.0
var event_message_time: float = 0.0
var last_feedback: StringName = &""
var hit_confirm_count: int = 0
var miss_count: int = 0
var player_damage_count: int = 0
var last_damage_amount: float = 0.0
var last_round_end_player_won: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _process(delta: float) -> void:
	shot_feedback_time = maxf(0.0, shot_feedback_time - delta)
	hit_feedback_time = maxf(0.0, hit_feedback_time - delta)
	miss_feedback_time = maxf(0.0, miss_feedback_time - delta)
	damage_feedback_time = maxf(0.0, damage_feedback_time - delta)
	kill_feedback_time = maxf(0.0, kill_feedback_time - delta)
	event_message_time = maxf(0.0, event_message_time - delta)
	_refresh_crosshair()
	_refresh_damage_overlay()
	_refresh_event_label()

func update_snapshot(snapshot: Dictionary) -> void:
	status_label.text = str(snapshot.get("status", "FpsShooter"))
	var player_health := float(snapshot.get("player_health", 0.0))
	var player_max := float(snapshot.get("player_max_health", 1.0))
	var bot_health := float(snapshot.get("bot_health", 0.0))
	var bot_max := float(snapshot.get("bot_max_health", 1.0))
	player_label.text = "Player %.0f / %.0f" % [player_health, player_max]
	bot_label.text = "Bot %.0f / %.0f" % [bot_health, bot_max]
	player_health_bar.max_value = maxf(1.0, player_max)
	player_health_bar.value = player_health
	bot_health_bar.max_value = maxf(1.0, bot_max)
	bot_health_bar.value = bot_health
	hint_label.text = str(snapshot.get("hint", "WASD move | Mouse look | LMB rifle | Space jump | R restart | Esc menu"))

func flash_hit() -> void:
	show_hit_confirm(false)

func show_player_shot() -> void:
	last_feedback = &"player_shot"
	shot_feedback_time = 0.11

func show_hit_confirm(killed: bool) -> void:
	last_feedback = &"kill" if killed else &"hit"
	hit_confirm_count += 1
	hit_feedback_time = 0.2
	if killed:
		kill_feedback_time = 0.9
		_set_event_message("BOT DOWN", 0.9)

func show_miss() -> void:
	last_feedback = &"miss"
	miss_count += 1
	miss_feedback_time = 0.1

func show_player_damage(amount: float, remaining_fraction: float) -> void:
	last_feedback = &"player_damage"
	player_damage_count += 1
	last_damage_amount = amount
	damage_feedback_time = clampf(0.18 + (1.0 - remaining_fraction) * 0.18, 0.18, 0.38)
	_set_event_message("-%.0f" % amount, 0.34)

func show_round_end(player_won: bool) -> void:
	last_feedback = &"round_end"
	last_round_end_player_won = player_won
	kill_feedback_time = 1.0
	_set_event_message("VITORIA" if player_won else "DERROTA", 1.6)

func reset_feedback() -> void:
	shot_feedback_time = 0.0
	hit_feedback_time = 0.0
	miss_feedback_time = 0.0
	damage_feedback_time = 0.0
	kill_feedback_time = 0.0
	event_message_time = 0.0
	last_feedback = &""
	if event_label != null:
		event_label.text = ""
		event_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	_refresh_crosshair()
	_refresh_damage_overlay()

func set_pause_menu_visible(menu_visible: bool, sensitivity_value: float) -> void:
	if pause_menu_panel == null:
		return
	pause_menu_panel.visible = menu_visible
	set_sensitivity_value(sensitivity_value)

func set_sensitivity_value(value: float) -> void:
	if sensitivity_slider == null:
		return
	sensitivity_slider.set_value_no_signal(value)
	_update_sensitivity_label(value)

func _build_ui() -> void:
	var root := Control.new()
	root.name = "HudRoot"
	root.process_mode = Node.PROCESS_MODE_ALWAYS
	_ignore_mouse(root)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	damage_overlay = ColorRect.new()
	damage_overlay.name = "DamageOverlay"
	_ignore_mouse(damage_overlay)
	damage_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	damage_overlay.color = Color(1.0, 0.0, 0.0, 0.0)
	root.add_child(damage_overlay)

	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	_ignore_mouse(panel)
	panel.position = Vector2(18.0, 18.0)
	panel.custom_minimum_size = Vector2(380.0, 126.0)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "StatusBox"
	_ignore_mouse(box)
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	_ignore_mouse(status_label)
	status_label.text = "FpsShooter"
	box.add_child(status_label)

	player_label = Label.new()
	player_label.name = "PlayerLabel"
	_ignore_mouse(player_label)
	box.add_child(player_label)

	player_health_bar = _build_health_bar("PlayerHealthBar", Color(0.32, 0.82, 1.0, 1.0))
	box.add_child(player_health_bar)

	bot_label = Label.new()
	bot_label.name = "BotLabel"
	_ignore_mouse(bot_label)
	box.add_child(bot_label)

	bot_health_bar = _build_health_bar("BotHealthBar", Color(1.0, 0.34, 0.22, 1.0))
	box.add_child(bot_health_bar)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	_ignore_mouse(hint_label)
	hint_label.position = Vector2(18.0, 158.0)
	hint_label.text = "Click captures mouse | WASD move | Mouse look | LMB rifle | Space jump | R restart | Esc menu"
	root.add_child(hint_label)

	_build_crosshair(root)
	_build_event_label(root)
	_build_pause_menu(root)

func _build_health_bar(node_name: String, color: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = node_name
	_ignore_mouse(bar)
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(328.0, 10.0)
	bar.add_theme_stylebox_override("background", _build_bar_style(Color(0.06, 0.08, 0.11, 0.92)))
	bar.add_theme_stylebox_override("fill", _build_bar_style(color))
	return bar

func _build_bar_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	return style

func _build_crosshair(root: Control) -> void:
	crosshair_root = Control.new()
	crosshair_root.name = "Crosshair"
	_ignore_mouse(crosshair_root)
	crosshair_root.set_anchors_preset(Control.PRESET_CENTER)
	crosshair_root.position = Vector2(-44.0, -44.0)
	crosshair_root.custom_minimum_size = Vector2(88.0, 88.0)
	crosshair_root.pivot_offset = Vector2(44.0, 44.0)
	root.add_child(crosshair_root)

	_add_crosshair_line("Top", Vector2(42.0, 14.0), Vector2(4.0, 20.0))
	_add_crosshair_line("Bottom", Vector2(42.0, 54.0), Vector2(4.0, 20.0))
	_add_crosshair_line("Left", Vector2(14.0, 42.0), Vector2(20.0, 4.0))
	_add_crosshair_line("Right", Vector2(54.0, 42.0), Vector2(20.0, 4.0))

	hit_marker_label = Label.new()
	hit_marker_label.name = "HitMarker"
	_ignore_mouse(hit_marker_label)
	hit_marker_label.text = "x"
	hit_marker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hit_marker_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hit_marker_label.position = Vector2(30.0, 26.0)
	hit_marker_label.size = Vector2(28.0, 28.0)
	hit_marker_label.add_theme_font_size_override("font_size", 28)
	hit_marker_label.modulate = Color(0.5, 1.0, 0.58, 0.0)
	crosshair_root.add_child(hit_marker_label)

func _add_crosshair_line(node_name: String, line_position: Vector2, line_size: Vector2) -> void:
	var line := ColorRect.new()
	line.name = node_name
	_ignore_mouse(line)
	line.position = line_position
	line.size = line_size
	line.color = Color(0.88, 0.96, 1.0, 0.88)
	crosshair_root.add_child(line)
	crosshair_lines.append(line)

func _build_event_label(root: Control) -> void:
	event_label = Label.new()
	event_label.name = "CombatEventLabel"
	_ignore_mouse(event_label)
	event_label.set_anchors_preset(Control.PRESET_CENTER)
	event_label.position = Vector2(-180.0, 50.0)
	event_label.size = Vector2(360.0, 36.0)
	event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_label.add_theme_font_size_override("font_size", 24)
	event_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	root.add_child(event_label)

func _ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _build_pause_menu(root: Control) -> void:
	pause_menu_panel = PanelContainer.new()
	pause_menu_panel.name = "PauseMenuPanel"
	pause_menu_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu_panel.custom_minimum_size = Vector2(380.0, 190.0)
	pause_menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_menu_panel.position = Vector2(-190.0, -95.0)
	pause_menu_panel.visible = false
	root.add_child(pause_menu_panel)

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
	title.text = "Menu"
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
	var color := Color(0.88, 0.96, 1.0, 0.88)
	var pulse := 0.0
	if kill_feedback_time > 0.0:
		color = Color(1.0, 0.92, 0.28, 1.0)
		pulse = 0.18
	elif hit_feedback_time > 0.0:
		color = Color(0.5, 1.0, 0.58, 1.0)
		pulse = 0.14
	elif shot_feedback_time > 0.0:
		color = Color(0.28, 0.92, 1.0, 1.0)
		pulse = 0.08
	elif miss_feedback_time > 0.0:
		color = Color(0.62, 0.76, 0.9, 0.72)
		pulse = 0.05
	for line: ColorRect in crosshair_lines:
		line.color = color
	crosshair_root.scale = Vector2.ONE * (1.0 + pulse)
	var marker_alpha := 0.0
	if kill_feedback_time > 0.0:
		marker_alpha = 1.0
		hit_marker_label.text = "X"
	elif hit_feedback_time > 0.0:
		marker_alpha = 1.0
		hit_marker_label.text = "x"
	hit_marker_label.modulate = Color(color.r, color.g, color.b, marker_alpha)

func _refresh_damage_overlay() -> void:
	if damage_overlay == null:
		return
	var alpha := 0.0
	if damage_feedback_time > 0.0:
		alpha = clampf(damage_feedback_time / 0.38, 0.0, 1.0) * 0.32
	damage_overlay.color = Color(1.0, 0.04, 0.02, alpha)

func _refresh_event_label() -> void:
	if event_label == null:
		return
	var alpha := clampf(event_message_time / 0.25, 0.0, 1.0) if event_message_time > 0.0 else 0.0
	event_label.modulate = Color(1.0, 1.0, 1.0, alpha)

func _set_event_message(message: String, duration: float) -> void:
	event_label.text = message
	event_message_time = maxf(0.05, duration)
