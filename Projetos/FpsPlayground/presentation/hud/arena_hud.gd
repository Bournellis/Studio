class_name ArenaHud
extends CanvasLayer

const ArenaHudFeedbackStateScript = preload("res://presentation/hud/arena_hud_feedback_state.gd")

signal resume_requested()
signal main_menu_requested()
signal new_match_requested()
signal sensitivity_changed(value: float)

var status_label: Label
var score_label: Label
var round_label: Label
var result_label: Label
var player_label: Label
var bot_label: Label
var combat_loop_label: Label
var bot_flow_label: Label
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
var plasma_feedback_time: float = 0.0
var bot_tell_feedback_time: float = 0.0
var event_message_time: float = 0.0
var event_message_color: Color = Color.WHITE
var last_feedback: StringName = &""
var hit_confirm_count: int = 0
var miss_count: int = 0
var player_damage_count: int = 0
var alt_fire_count: int = 0
var plasma_hit_count: int = 0
var plasma_blast_count: int = 0
var bot_tell_count: int = 0
var pickup_count: int = 0
var jump_pad_count: int = 0
var fall_penalty_count: int = 0
var last_damage_amount: float = 0.0
var last_plasma_hit_overcharged: bool = false
var last_round_end_player_won: bool = false
var last_bot_flow_text: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()

func _process(delta: float) -> void:
	_apply_feedback_state(ArenaHudFeedbackStateScript.tick_feedback_state(_build_feedback_state(), delta))
	_refresh_crosshair()
	_refresh_damage_overlay()
	_refresh_event_label()

func update_snapshot(snapshot: Dictionary) -> void:
	status_label.text = str(snapshot.get("status", "FpsPlayground"))
	_update_duel_labels(snapshot)
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
	_update_combat_loop_label(snapshot)
	_update_bot_flow_label(snapshot)
	hint_label.text = str(snapshot.get("hint", "WASD move | Mouse look | LMB rifle | Space jump | R restart | Esc menu"))

func flash_hit() -> void:
	show_hit_confirm(false)

func show_player_shot() -> void:
	last_feedback = &"player_shot"
	shot_feedback_time = 0.11

func show_player_alt_fire(overcharged: bool) -> void:
	last_feedback = &"plasma_shot"
	alt_fire_count += 1
	plasma_feedback_time = 0.18
	shot_feedback_time = 0.08
	_apply_event_message(ArenaHudFeedbackStateScript.build_player_alt_fire_event(overcharged))

func show_plasma_hit(overcharged: bool, killed: bool) -> void:
	last_feedback = ArenaHudFeedbackStateScript.get_plasma_hit_feedback(overcharged, killed)
	hit_confirm_count += 1
	plasma_hit_count += 1
	last_plasma_hit_overcharged = overcharged
	hit_feedback_time = 0.22
	plasma_feedback_time = 0.34 if overcharged else 0.24
	if killed:
		kill_feedback_time = 0.9
	_apply_event_message(ArenaHudFeedbackStateScript.build_plasma_hit_event(overcharged, killed))

func show_plasma_blast(overcharged: bool, killed: bool) -> void:
	last_feedback = ArenaHudFeedbackStateScript.get_plasma_blast_feedback(overcharged, killed)
	hit_confirm_count += 1
	plasma_blast_count += 1
	last_plasma_hit_overcharged = overcharged
	hit_feedback_time = 0.16
	plasma_feedback_time = 0.38 if overcharged else 0.28
	if killed:
		kill_feedback_time = 0.9
	_apply_event_message(ArenaHudFeedbackStateScript.build_plasma_blast_event(overcharged, killed))

func show_hit_confirm(killed: bool) -> void:
	last_feedback = &"kill" if killed else &"hit"
	hit_confirm_count += 1
	hit_feedback_time = 0.2
	if killed:
		kill_feedback_time = 0.9
	_apply_event_message(ArenaHudFeedbackStateScript.build_hit_confirm_event(killed))

func show_miss() -> void:
	last_feedback = &"miss"
	miss_count += 1
	miss_feedback_time = 0.1

func show_player_damage(amount: float, remaining_fraction: float) -> void:
	last_feedback = &"player_damage"
	player_damage_count += 1
	last_damage_amount = amount
	damage_feedback_time = clampf(0.18 + (1.0 - remaining_fraction) * 0.18, 0.18, 0.38)
	_apply_event_message(ArenaHudFeedbackStateScript.build_player_damage_event(amount))

func show_bot_tell(duration: float) -> void:
	last_feedback = &"bot_tell"
	bot_tell_count += 1
	bot_tell_feedback_time = maxf(0.12, duration)
	_apply_event_message(ArenaHudFeedbackStateScript.build_bot_tell_event(duration))

func show_pickup(pickup_kind: StringName) -> void:
	last_feedback = &"pickup"
	pickup_count += 1
	_apply_event_message(ArenaHudFeedbackStateScript.build_pickup_event(pickup_kind, 28.0))

func show_jump_pad() -> void:
	last_feedback = &"jump_pad"
	jump_pad_count += 1
	plasma_feedback_time = 0.16
	_apply_event_message(ArenaHudFeedbackStateScript.build_jump_pad_event())

func show_fall_penalty(amount: float, for_player: bool) -> void:
	last_feedback = &"fall"
	fall_penalty_count += 1
	damage_feedback_time = 0.32 if for_player else damage_feedback_time
	_apply_event_message(ArenaHudFeedbackStateScript.build_fall_penalty_event(amount, for_player))

func show_round_end(player_won: bool) -> void:
	last_feedback = &"round_end"
	last_round_end_player_won = player_won
	kill_feedback_time = 1.0
	_apply_event_message(ArenaHudFeedbackStateScript.build_round_end_event(player_won))

func reset_feedback() -> void:
	_apply_feedback_state(ArenaHudFeedbackStateScript.build_reset_state())
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

func _update_combat_loop_label(snapshot: Dictionary) -> void:
	if combat_loop_label == null:
		return
	var plasma_ready := bool(snapshot.get("alt_fire_ready", true))
	var cooldown_fraction := float(snapshot.get("alt_fire_cooldown_fraction", 0.0))
	var plasma_text := "Plasma ready" if plasma_ready else "Plasma %.0f%%" % [(1.0 - cooldown_fraction) * 100.0]
	var overcharge_text := "Overcharge ready" if bool(snapshot.get("player_overcharge", false)) else "Overcharge empty"
	var health_pickup_text := "Health up" if bool(snapshot.get("health_pickup_available", false)) else "Health %.0fs" % [float(snapshot.get("health_pickup_respawn", 0.0))]
	var overcharge_pickup_text := "OVR up" if bool(snapshot.get("overcharge_pickup_available", false)) else "OVR %.0fs" % [float(snapshot.get("overcharge_pickup_respawn", 0.0))]
	if bool(snapshot.get("bot_overcharge", false)):
		overcharge_pickup_text += " | Bot charged"
	combat_loop_label.text = "%s | %s | %s | %s" % [plasma_text, overcharge_text, health_pickup_text, overcharge_pickup_text]

func _update_duel_labels(snapshot: Dictionary) -> void:
	if score_label == null or round_label == null or result_label == null:
		return
	var player_score := int(snapshot.get("player_score", 0))
	var bot_score := int(snapshot.get("bot_score", 0))
	var round_index := int(snapshot.get("round_index", 1))
	var score_to_win := int(snapshot.get("score_to_win", 3))
	var map_name := str(snapshot.get("map_name", "Arena Shooter"))
	score_label.text = "Score  Player %d  x  %d Bot" % [player_score, bot_score]
	round_label.text = "%s | Round %d | First to %d" % [map_name, round_index, score_to_win]
	result_label.text = str(snapshot.get("result_text", "First to %d" % score_to_win))

func _update_bot_flow_label(snapshot: Dictionary) -> void:
	if bot_flow_label == null:
		return
	var bot_state := str(snapshot.get("bot_state", "none"))
	var route_label := str(snapshot.get("bot_route_label", "none"))
	var los_text := "LOS" if bool(snapshot.get("bot_has_line_of_sight", false)) else "No LOS"
	var pad_id := str(snapshot.get("last_jump_pad_id", ""))
	var pad_text := "" if pad_id.is_empty() else " | Pad %s" % pad_id
	last_bot_flow_text = "Bot: %s | Route: %s | %s%s" % [bot_state, route_label, los_text, pad_text]
	bot_flow_label.text = last_bot_flow_text

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
	panel.custom_minimum_size = Vector2(448.0, 224.0)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "StatusBox"
	_ignore_mouse(box)
	box.add_theme_constant_override("separation", 5)
	panel.add_child(box)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	_ignore_mouse(status_label)
	status_label.text = "FpsPlayground"
	box.add_child(status_label)

	score_label = Label.new()
	score_label.name = "ScoreLabel"
	_ignore_mouse(score_label)
	score_label.text = "Score  Player 0  x  0 Bot"
	box.add_child(score_label)

	round_label = Label.new()
	round_label.name = "RoundLabel"
	_ignore_mouse(round_label)
	round_label.add_theme_font_size_override("font_size", 12)
	round_label.text = "Duel Pit V2 | Round 1 | First to 3"
	box.add_child(round_label)

	result_label = Label.new()
	result_label.name = "ResultLabel"
	_ignore_mouse(result_label)
	result_label.add_theme_font_size_override("font_size", 12)
	result_label.text = "First to 3"
	box.add_child(result_label)

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

	combat_loop_label = Label.new()
	combat_loop_label.name = "CombatLoopLabel"
	_ignore_mouse(combat_loop_label)
	combat_loop_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_loop_label.add_theme_font_size_override("font_size", 12)
	combat_loop_label.text = "Plasma ready | Pickups active"
	box.add_child(combat_loop_label)

	bot_flow_label = Label.new()
	bot_flow_label.name = "BotFlowLabel"
	_ignore_mouse(bot_flow_label)
	bot_flow_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bot_flow_label.add_theme_font_size_override("font_size", 12)
	bot_flow_label.text = "Bot: idle | Route: none | No LOS"
	box.add_child(bot_flow_label)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	_ignore_mouse(hint_label)
	hint_label.position = Vector2(18.0, 242.0)
	hint_label.text = "Click captures mouse | WASD move | Mouse look | LMB rifle | RMB plasma | Space jump | R restart | Esc menu"
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
	pause_menu_panel.custom_minimum_size = Vector2(380.0, 284.0)
	pause_menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	pause_menu_panel.position = Vector2(-190.0, -142.0)
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

	var new_match_button := Button.new()
	new_match_button.name = "NewMatchButton"
	new_match_button.text = "Novo duelo"
	new_match_button.mouse_filter = Control.MOUSE_FILTER_STOP
	new_match_button.pressed.connect(func() -> void:
		new_match_requested.emit()
	)
	box.add_child(new_match_button)

	var menu_button := Button.new()
	menu_button.name = "MainMenuButton"
	menu_button.text = "Menu inicial"
	menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_button.pressed.connect(func() -> void:
		main_menu_requested.emit()
	)
	box.add_child(menu_button)

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
	var view := ArenaHudFeedbackStateScript.build_crosshair_view(_build_feedback_state())
	var color: Color = view.get("color", Color(0.88, 0.96, 1.0, 0.88))
	var pulse := float(view.get("pulse", 0.0))
	for line: ColorRect in crosshair_lines:
		line.color = color
	crosshair_root.scale = Vector2.ONE * (1.0 + pulse)
	var marker_alpha := float(view.get("marker_alpha", 0.0))
	hit_marker_label.text = str(view.get("marker_text", ""))
	hit_marker_label.modulate = Color(color.r, color.g, color.b, marker_alpha)

func _refresh_damage_overlay() -> void:
	if damage_overlay == null:
		return
	var alpha := ArenaHudFeedbackStateScript.get_damage_overlay_alpha(damage_feedback_time)
	damage_overlay.color = Color(1.0, 0.04, 0.02, alpha)

func _refresh_event_label() -> void:
	if event_label == null:
		return
	var alpha := ArenaHudFeedbackStateScript.get_event_alpha(event_message_time)
	event_label.modulate = Color(event_message_color.r, event_message_color.g, event_message_color.b, alpha)

func _apply_event_message(event: Dictionary) -> void:
	if event.is_empty() or event_label == null:
		return
	event_label.text = str(event.get("message", ""))
	event_message_color = event.get("color", Color.WHITE)
	event_message_time = float(event.get("duration", 0.05))

func _build_feedback_state() -> Dictionary:
	return {
		"shot_feedback_time": shot_feedback_time,
		"hit_feedback_time": hit_feedback_time,
		"miss_feedback_time": miss_feedback_time,
		"damage_feedback_time": damage_feedback_time,
		"kill_feedback_time": kill_feedback_time,
		"plasma_feedback_time": plasma_feedback_time,
		"bot_tell_feedback_time": bot_tell_feedback_time,
		"event_message_time": event_message_time,
		"event_message_color": event_message_color,
		"last_feedback": last_feedback
	}

func _apply_feedback_state(state: Dictionary) -> void:
	shot_feedback_time = float(state.get("shot_feedback_time", 0.0))
	hit_feedback_time = float(state.get("hit_feedback_time", 0.0))
	miss_feedback_time = float(state.get("miss_feedback_time", 0.0))
	damage_feedback_time = float(state.get("damage_feedback_time", 0.0))
	kill_feedback_time = float(state.get("kill_feedback_time", 0.0))
	plasma_feedback_time = float(state.get("plasma_feedback_time", 0.0))
	bot_tell_feedback_time = float(state.get("bot_tell_feedback_time", 0.0))
	event_message_time = float(state.get("event_message_time", 0.0))
	event_message_color = state.get("event_message_color", Color.WHITE)
	last_feedback = state.get("last_feedback", &"")
