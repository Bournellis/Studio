class_name ArenaHud
extends CanvasLayer

signal resume_requested()
signal sensitivity_changed(value: float)

var status_label: Label
var player_label: Label
var bot_label: Label
var hint_label: Label
var crosshair_label: Label
var pause_menu_panel: PanelContainer
var sensitivity_label: Label
var sensitivity_slider: HSlider
var hit_flash_time: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _process(delta: float) -> void:
	if hit_flash_time > 0.0:
		hit_flash_time = maxf(0.0, hit_flash_time - delta)
		crosshair_label.modulate = Color(0.45, 1.0, 0.78, 1.0)
	else:
		crosshair_label.modulate = Color(0.9, 0.96, 1.0, 0.92)

func update_snapshot(snapshot: Dictionary) -> void:
	status_label.text = str(snapshot.get("status", "FpsShooter"))
	player_label.text = "Player %.0f / %.0f" % [
		float(snapshot.get("player_health", 0.0)),
		float(snapshot.get("player_max_health", 1.0))
	]
	bot_label.text = "Bot %.0f / %.0f" % [
		float(snapshot.get("bot_health", 0.0)),
		float(snapshot.get("bot_max_health", 1.0))
	]
	hint_label.text = str(snapshot.get("hint", "WASD move | Mouse look | LMB shoot | Space jump | R restart | Esc menu"))

func flash_hit() -> void:
	hit_flash_time = 0.12

func set_pause_menu_visible(is_visible: bool, sensitivity_value: float) -> void:
	if pause_menu_panel == null:
		return
	pause_menu_panel.visible = is_visible
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

	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	_ignore_mouse(panel)
	panel.position = Vector2(18.0, 18.0)
	panel.custom_minimum_size = Vector2(360.0, 94.0)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "StatusBox"
	_ignore_mouse(box)
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

	bot_label = Label.new()
	bot_label.name = "BotLabel"
	_ignore_mouse(bot_label)
	box.add_child(bot_label)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	_ignore_mouse(hint_label)
	hint_label.position = Vector2(18.0, 118.0)
	hint_label.text = "Click captures mouse | WASD move | Mouse look | LMB shoot | Space jump | R restart | Esc menu"
	root.add_child(hint_label)

	crosshair_label = Label.new()
	crosshair_label.name = "Crosshair"
	_ignore_mouse(crosshair_label)
	crosshair_label.text = "+"
	crosshair_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair_label.set_anchors_preset(Control.PRESET_CENTER)
	crosshair_label.position = Vector2(-8.0, -14.0)
	crosshair_label.add_theme_font_size_override("font_size", 28)
	root.add_child(crosshair_label)

	_build_pause_menu(root)

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
