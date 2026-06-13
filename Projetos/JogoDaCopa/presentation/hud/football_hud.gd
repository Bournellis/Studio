class_name FootballHud
extends CanvasLayer

signal resume_requested()
signal restart_requested()
signal main_menu_requested()
signal sensitivity_changed(value: float)
signal quality_changed(quality_id: StringName)
signal fullscreen_changed(enabled: bool)
signal start_requested()
signal rematch_requested()
signal skin_tone_previous_requested()
signal skin_tone_next_requested()
signal country_kit_previous_requested()
signal country_kit_next_requested()

const FADE_DURATION_SECONDS: float = 0.25
const BUS_MASTER: StringName = &"Master"
const BUS_SFX: StringName = &"SFX"
const BUS_UI: StringName = &"UI"
const BUS_AMBIENCE: StringName = &"Ambience"
const RESULT_SUPPRESS_TRANSITION_PULSE_KEY: String = "suppress_transition_pulse"
const CONTROL_HINTS: Array[Dictionary] = [
	{"action": "Mover", "input": "WASD"},
	{"action": "Boost", "input": "Shift"},
	{"action": "Dash", "input": "E / Ctrl"},
	{"action": "Girar jogador/camera", "input": "Mouse"},
	{"action": "Chute carregado", "input": "LMB segurar"},
	{"action": "Chute forte / SUPER", "input": "RMB"},
	{"action": "Pular / flip", "input": "Space"},
	{"action": "Emote pos-gol", "input": "T"},
	{"action": "Reiniciar", "input": "R"},
	{"action": "Menu", "input": "Esc"},
]

const RenderProfileScript = preload("res://autoloads/render_profile.gd")
const GameSettingsScript = preload("res://autoloads/game_settings.gd")

var status_label: Label
var score_label: Label
var clock_label: Label
var flow_label: Label
var control_label: Label
var boost_bar: ProgressBar
var event_label: Label
var ball_indicator: PanelContainer
var ball_indicator_label: Label
var player_kit_swatch: ColorRect
var bot_kit_swatch: ColorRect
var pulse_overlay: ColorRect
var intro_panel: PanelContainer
var pause_menu_panel: PanelContainer
var result_panel: PanelContainer
var result_title_label: Label
var result_score_label: Label
var result_detail_label: Label
var result_stats_label: Label
var result_player_kit_swatch: ColorRect
var result_bot_kit_swatch: ColorRect
var result_player_kit_label: Label
var result_bot_kit_label: Label
var result_rematch_button: Button
var result_menu_button: Button
var sensitivity_label: Label
var sensitivity_slider: HSlider
var pause_resume_button: Button
var pause_restart_button: Button
var pause_menu_button: Button
var pause_volume_slider: HSlider
var pause_sfx_volume_slider: HSlider
var pause_ui_volume_slider: HSlider
var pause_ambience_volume_slider: HSlider
var pause_section_buttons: Dictionary = {}
var pause_controls_section: Control
var pause_audio_title: Label
var pause_video_section: Control
var pause_sensitivity_section: Control
var pause_fullscreen_toggle: CheckButton
var pause_quality_option: OptionButton
var pause_quality_notice_label: Label
var pause_section_id: StringName = &"audio"
var skin_tone_label: Label
var country_kit_label: Label
var intro_start_button: Button
var fade_overlay: ColorRect
var fade_tween: Tween

var kick_feedback_time: float = 0.0
var strong_kick_feedback_time: float = 0.0
var whiff_feedback_time: float = 0.0
var goal_feedback_time: float = 0.0
var event_message_time: float = 0.0
var event_message_duration: float = 0.0
var event_message_queue: Array[Dictionary] = []
var last_event: StringName = &""
var kick_count: int = 0
var whiff_count: int = 0
var goal_count: int = 0
var last_player_scored: bool = false
var last_kick_assist_strength: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_audio_buses()
	_build_ui()
	call_deferred("play_fade_from_black")

func _process(delta: float) -> void:
	kick_feedback_time = maxf(0.0, kick_feedback_time - delta)
	strong_kick_feedback_time = maxf(0.0, strong_kick_feedback_time - delta)
	whiff_feedback_time = maxf(0.0, whiff_feedback_time - delta)
	goal_feedback_time = maxf(0.0, goal_feedback_time - delta)
	event_message_time = maxf(0.0, event_message_time - delta)
	if event_message_time <= 0.0 and not event_message_queue.is_empty():
		var next_message: Dictionary = event_message_queue.pop_front()
		_start_event_message(str(next_message.get("message", "")), float(next_message.get("duration", 0.4)))
	_refresh_overlay()
	_refresh_event_label()

func update_snapshot(snapshot: Dictionary) -> void:
	_set_label_text_if_changed(status_label, str(snapshot.get("status", "Futebol 1x1")))
	_set_label_text_if_changed(score_label, "%s %d   %d %s" % [
		str(snapshot.get("player_kit_code", "BRA")),
		int(snapshot.get("player_score", 0)),
		int(snapshot.get("bot_score", 0)),
		str(snapshot.get("bot_kit_code", "FRA"))
	])
	var match_mode := StringName(str(snapshot.get("match_mode", "goals")))
	var golden_goal := bool(snapshot.get("golden_goal_active", false))
	var time_remaining := float(snapshot.get("match_time_remaining", 0.0))
	if match_mode == &"timer":
		_set_label_text_if_changed(clock_label, "%s | BOLA %.1fm" % [
			"GOLDEN GOAL" if golden_goal else _format_match_time(time_remaining),
			float(snapshot.get("ball_distance", 0.0))
		])
		clock_label.modulate = Color(1.0, 0.82, 0.16, 1.0) if golden_goal or (time_remaining > 0.0 and time_remaining <= 30.0) else Color(1.0, 1.0, 1.0, 1.0)
	else:
		_set_label_text_if_changed(clock_label, "PRIMEIRO A %d | BOLA %.1fm" % [
			int(snapshot.get("goal_limit", 3)),
			float(snapshot.get("ball_distance", 0.0))
		])
		clock_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
	var bot_state := str(snapshot.get("bot_state", "kickoff"))
	var phase := str(snapshot.get("phase", "kickoff"))
	var kickoff_owner := str(snapshot.get("kickoff_owner", "player"))
	var bot_difficulty := str(snapshot.get("bot_difficulty", "normal"))
	_set_label_text_if_changed(flow_label, "Futebol: %s | Saida: %s | Bot %s: %s" % [phase, kickoff_owner, bot_difficulty, bot_state])
	var control_state := StringName(str(snapshot.get("ball_control", "free")))
	var control_strength := float(snapshot.get("ball_control_strength", 0.0))
	var boost_fraction := float(snapshot.get("boost_fraction", 1.0))
	var boost_active := bool(snapshot.get("boost_active", false))
	var dash_cooldown_fraction := float(snapshot.get("dash_cooldown_fraction", 0.0))
	var dash_label := "pronto" if dash_cooldown_fraction <= 0.0 else "%.0f%%" % [(1.0 - dash_cooldown_fraction) * 100.0]
	var charge_fraction := float(snapshot.get("shoot_charge_fraction", 0.0))
	var super_fraction := float(snapshot.get("player_super_fraction", 0.0))
	_set_label_text_if_changed(control_label, "Bola: %s %.0f%% | Boost %s | Dash %s | Carga %.0f%% | SUPER %.0f%%" % [
		_get_control_label(control_state),
		control_strength * 100.0,
		"ATIVO" if boost_active else "%.0f%%" % [boost_fraction * 100.0],
		dash_label,
		charge_fraction * 100.0,
		super_fraction * 100.0
	])
	if boost_bar != null:
		_set_progress_bar_value_if_changed(boost_bar, boost_fraction * 100.0)
		boost_bar.modulate = Color(0.35, 0.9, 1.0, 1.0) if boost_active else Color(0.9, 1.0, 0.92, 0.92)
	if player_kit_swatch != null:
		player_kit_swatch.color = snapshot.get("player_kit_color", Color(1.0, 0.86, 0.12, 1.0))
	if bot_kit_swatch != null:
		bot_kit_swatch.color = snapshot.get("bot_kit_color", Color(0.06, 0.16, 0.56, 1.0))
	if result_score_label != null:
		_set_label_text_if_changed(result_score_label, "%d - %d" % [
			int(snapshot.get("player_score", 0)),
			int(snapshot.get("bot_score", 0))
		])
	if result_player_kit_swatch != null:
		result_player_kit_swatch.color = snapshot.get("player_kit_color", Color(1.0, 0.86, 0.12, 1.0))
	if result_bot_kit_swatch != null:
		result_bot_kit_swatch.color = snapshot.get("bot_kit_color", Color(0.06, 0.16, 0.56, 1.0))
	if result_player_kit_label != null:
		_set_label_text_if_changed(result_player_kit_label, str(snapshot.get("player_kit_code", "BRA")))
	if result_bot_kit_label != null:
		_set_label_text_if_changed(result_bot_kit_label, str(snapshot.get("bot_kit_code", "FRA")))
	_update_ball_indicator(snapshot)

static func get_control_hints() -> Array[Dictionary]:
	return CONTROL_HINTS.duplicate(true)

func _set_label_text_if_changed(label: Label, next_text: String) -> void:
	if label == null or label.text == next_text:
		return
	label.text = next_text

func _set_progress_bar_value_if_changed(progress_bar: ProgressBar, next_value: float) -> void:
	if progress_bar == null or is_equal_approx(progress_bar.value, next_value):
		return
	progress_bar.value = next_value

func show_kick(strong: bool, connected: bool, assist_strength: float = 0.0) -> void:
	last_kick_assist_strength = assist_strength
	if connected:
		last_event = &"strong_kick" if strong else &"kick"
		kick_count += 1
		kick_feedback_time = 0.16
		if strong:
			strong_kick_feedback_time = 0.24
			_set_event_message("CHUTE FORTE", 0.36)
		elif assist_strength > 0.05:
			_set_event_message("CHUTE AJUSTADO", 0.32)
		else:
			_set_event_message("CHUTE", 0.28)
		return
	last_event = &"whiff"
	whiff_count += 1
	whiff_feedback_time = 0.16
	_set_event_message("SEM CONTATO", 0.28)

func show_goal(player_scored: bool, goal_value: int = 1, double_goal: bool = false) -> void:
	last_event = &"double_goal" if double_goal else &"goal"
	last_player_scored = player_scored
	goal_count += 1
	goal_feedback_time = 1.1
	var scorer := "PLAYER" if player_scored else "BOT"
	var message := "VALE 2! GOOOOL %s" % scorer if double_goal else ("GOOOOL %s" % scorer if player_scored else "GOL DO BOT")
	if goal_value > 1 and not double_goal:
		message = "%dx! %s" % [goal_value, message]
	_set_event_message(message, 1.1)

func show_match_end(player_won: bool, result_snapshot: Dictionary = {}) -> void:
	last_event = &"match_end"
	goal_feedback_time = 1.5
	_set_event_message("CAMPEAO" if player_won else "DERROTA", 1.6)
	_apply_result_snapshot(player_won, result_snapshot)
	if not RenderProfileScript.is_web_platform() and not bool(result_snapshot.get(RESULT_SUPPRESS_TRANSITION_PULSE_KEY, false)):
		play_transition_pulse()

func _apply_result_snapshot(player_won: bool, result_snapshot: Dictionary) -> void:
	if result_panel != null:
		result_panel.visible = true
	if result_rematch_button != null and not RenderProfileScript.is_web_platform():
		result_rematch_button.grab_focus()
	if result_title_label != null:
		_set_label_text_if_changed(result_title_label, "VITORIA" if player_won else "DERROTA")
	if result_score_label != null:
		_set_label_text_if_changed(result_score_label, "%d - %d" % [
			int(result_snapshot.get("player_score", 0)),
			int(result_snapshot.get("bot_score", 0))
		])
	if result_detail_label != null:
		_set_label_text_if_changed(result_detail_label, "Fim de jogo. Rematch rapido ou volta para ajustar a final." if player_won else "Fim de jogo. A revanche fica pronta sem reiniciar o app.")
	if result_player_kit_swatch != null:
		result_player_kit_swatch.color = result_snapshot.get("player_kit_color", Color(1.0, 0.86, 0.12, 1.0))
	if result_bot_kit_swatch != null:
		result_bot_kit_swatch.color = result_snapshot.get("bot_kit_color", Color(0.06, 0.16, 0.56, 1.0))
	if result_player_kit_label != null:
		_set_label_text_if_changed(result_player_kit_label, str(result_snapshot.get("player_kit_code", "BRA")))
	if result_bot_kit_label != null:
		_set_label_text_if_changed(result_bot_kit_label, str(result_snapshot.get("bot_kit_code", "FRA")))
	if result_stats_label != null:
		_set_label_text_if_changed(result_stats_label, str(result_snapshot.get("stats_text", "Estatisticas indisponiveis.")))

func show_countdown(message: String, duration: float = 0.32) -> void:
	last_event = &"countdown"
	_set_event_message(message, duration)

func show_announcement(message: String, duration: float = 0.8, event_id: StringName = &"announcement") -> void:
	last_event = event_id
	_set_event_message(message, duration)

func reset_feedback() -> void:
	kick_feedback_time = 0.0
	strong_kick_feedback_time = 0.0
	whiff_feedback_time = 0.0
	goal_feedback_time = 0.0
	event_message_time = 0.0
	event_message_duration = 0.0
	event_message_queue.clear()
	last_event = &""
	last_kick_assist_strength = 0.0
	if event_label != null:
		event_label.text = ""
		event_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if result_panel != null:
		result_panel.visible = false
	_refresh_overlay()

func set_pause_menu_visible(menu_is_open: bool, sensitivity_value: float = 0.0) -> void:
	if pause_menu_panel == null:
		return
	pause_menu_panel.visible = menu_is_open
	_sync_pause_settings_controls(sensitivity_value)
	if menu_is_open and pause_resume_button != null:
		_set_pause_section(&"audio")
		pause_resume_button.grab_focus()

func set_intro_visible(intro_is_visible: bool) -> void:
	if intro_panel == null:
		return
	intro_panel.visible = intro_is_visible
	if intro_is_visible and intro_start_button != null:
		intro_start_button.grab_focus()

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

func debug_has_broadcast_scoreboard() -> bool:
	return player_kit_swatch != null and bot_kit_swatch != null and score_label != null

func debug_is_result_panel_visible() -> bool:
	return result_panel != null and result_panel.visible

func debug_get_result_title() -> String:
	return result_title_label.text if result_title_label != null else ""

func debug_get_result_stats_text() -> String:
	return result_stats_label.text if result_stats_label != null else ""

func debug_is_pause_menu_visible() -> bool:
	return pause_menu_panel != null and pause_menu_panel.visible

func debug_show_pause_section(section_id: StringName) -> void:
	_set_pause_section(section_id)

func debug_get_pause_section_id() -> StringName:
	return pause_section_id

func debug_get_fade_alpha() -> float:
	return fade_overlay.color.a if fade_overlay != null else 0.0

func debug_is_ball_indicator_visible() -> bool:
	return ball_indicator != null and ball_indicator.visible

func debug_get_ball_indicator_text() -> String:
	return ball_indicator_label.text if ball_indicator_label != null else ""

func debug_get_event_text() -> String:
	return event_label.text if event_label != null else ""

func debug_get_clock_text() -> String:
	return clock_label.text if clock_label != null else ""

func debug_get_focused_control_name() -> String:
	var focused := get_viewport().gui_get_focus_owner()
	return focused.name if focused != null else ""

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
	panel.custom_minimum_size = Vector2(468.0, 154.0)
	panel.add_theme_stylebox_override("panel", _build_panel_style(Color(0.015, 0.035, 0.045, 0.86), Color(0.1, 0.85, 0.72, 0.8), 2))
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "ScoreBox"
	_ignore_mouse(box)
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "FUTEBOL 1x1"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 13)
	_ignore_mouse(status_label)
	box.add_child(status_label)

	var score_row := HBoxContainer.new()
	score_row.name = "BroadcastScoreRow"
	score_row.add_theme_constant_override("separation", 10)
	_ignore_mouse(score_row)
	box.add_child(score_row)

	player_kit_swatch = ColorRect.new()
	player_kit_swatch.name = "PlayerKitSwatch"
	player_kit_swatch.custom_minimum_size = Vector2(42.0, 28.0)
	player_kit_swatch.color = Color(1.0, 0.86, 0.12, 1.0)
	_ignore_mouse(player_kit_swatch)
	score_row.add_child(player_kit_swatch)

	score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "BRA 0   0 FRA"
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label.add_theme_font_size_override("font_size", 30)
	_ignore_mouse(score_label)
	score_row.add_child(score_label)

	bot_kit_swatch = ColorRect.new()
	bot_kit_swatch.name = "BotKitSwatch"
	bot_kit_swatch.custom_minimum_size = Vector2(42.0, 28.0)
	bot_kit_swatch.color = Color(0.06, 0.16, 0.56, 1.0)
	_ignore_mouse(bot_kit_swatch)
	score_row.add_child(bot_kit_swatch)

	clock_label = Label.new()
	clock_label.name = "ClockLabel"
	clock_label.text = "PRIMEIRO A 3"
	clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	clock_label.add_theme_font_size_override("font_size", 13)
	_ignore_mouse(clock_label)
	box.add_child(clock_label)

	flow_label = Label.new()
	flow_label.name = "FlowLabel"
	flow_label.add_theme_font_size_override("font_size", 12)
	flow_label.text = "Futebol: kickoff | Bot: kickoff"
	_ignore_mouse(flow_label)
	box.add_child(flow_label)

	control_label = Label.new()
	control_label.name = "ControlLabel"
	control_label.add_theme_font_size_override("font_size", 12)
	control_label.text = "Bola: solta 0% | Boost 100%"
	_ignore_mouse(control_label)
	box.add_child(control_label)

	boost_bar = ProgressBar.new()
	boost_bar.name = "BoostBar"
	boost_bar.min_value = 0.0
	boost_bar.max_value = 100.0
	boost_bar.value = 100.0
	boost_bar.show_percentage = false
	boost_bar.custom_minimum_size = Vector2(0.0, 12.0)
	_ignore_mouse(boost_bar)
	box.add_child(boost_bar)

	_build_ball_indicator(root)
	_build_event_label(root)
	_build_result_panel(root)
	_build_pause_menu(root)
	_build_intro_panel(root)
	_build_fade_overlay(root)

func _build_event_label(root: Control) -> void:
	event_label = Label.new()
	event_label.name = "FootballEventLabel"
	_ignore_mouse(event_label)
	event_label.set_anchors_preset(Control.PRESET_CENTER)
	event_label.position = Vector2(-340.0, 42.0)
	event_label.size = Vector2(680.0, 72.0)
	event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	event_label.add_theme_font_size_override("font_size", 46)
	event_label.pivot_offset = Vector2(340.0, 36.0)
	event_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	root.add_child(event_label)

func _build_ball_indicator(root: Control) -> void:
	ball_indicator = PanelContainer.new()
	ball_indicator.name = "BallOffscreenIndicator"
	_ignore_mouse(ball_indicator)
	ball_indicator.position = Vector2(18.0, 190.0)
	ball_indicator.custom_minimum_size = Vector2(168.0, 34.0)
	ball_indicator.visible = false
	ball_indicator.add_theme_stylebox_override("panel", _build_panel_style(Color(0.02, 0.07, 0.08, 0.78), Color(0.92, 0.78, 0.16, 0.9), 1))
	root.add_child(ball_indicator)

	ball_indicator_label = Label.new()
	ball_indicator_label.name = "BallIndicatorLabel"
	ball_indicator_label.text = "BOLA"
	ball_indicator_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ball_indicator_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ball_indicator_label.add_theme_font_size_override("font_size", 13)
	_ignore_mouse(ball_indicator_label)
	ball_indicator.add_child(ball_indicator_label)

func _build_result_panel(root: Control) -> void:
	var result_center := CenterContainer.new()
	result_center.name = "ResultCenter"
	result_center.process_mode = Node.PROCESS_MODE_ALWAYS
	result_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(result_center)

	result_panel = PanelContainer.new()
	result_panel.name = "ResultPanel"
	result_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	result_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	result_panel.custom_minimum_size = Vector2(660.0, 420.0)
	result_panel.visible = false
	result_panel.add_theme_stylebox_override("panel", _build_panel_style(Color(0.015, 0.035, 0.045, 0.92), Color(1.0, 0.78, 0.16, 0.92), 2))
	result_center.add_child(result_panel)

	var margin := MarginContainer.new()
	margin.name = "ResultMargin"
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	result_panel.add_child(margin)

	var box := VBoxContainer.new()
	box.name = "ResultBox"
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	result_title_label = Label.new()
	result_title_label.name = "ResultTitle"
	result_title_label.text = "RESULTADO"
	result_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title_label.add_theme_font_size_override("font_size", 24)
	_ignore_mouse(result_title_label)
	box.add_child(result_title_label)

	var score_strip := HBoxContainer.new()
	score_strip.name = "ResultScoreStrip"
	score_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_strip.add_theme_constant_override("separation", 14)
	box.add_child(score_strip)

	var player_flag := VBoxContainer.new()
	player_flag.name = "ResultPlayerFlag"
	player_flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_strip.add_child(player_flag)

	result_player_kit_swatch = ColorRect.new()
	result_player_kit_swatch.name = "ResultPlayerKitSwatch"
	result_player_kit_swatch.custom_minimum_size = Vector2(92.0, 52.0)
	result_player_kit_swatch.color = Color(1.0, 0.86, 0.12, 1.0)
	_ignore_mouse(result_player_kit_swatch)
	player_flag.add_child(result_player_kit_swatch)

	result_player_kit_label = Label.new()
	result_player_kit_label.name = "ResultPlayerKitLabel"
	result_player_kit_label.text = "BRA"
	result_player_kit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_player_kit_label.add_theme_font_size_override("font_size", 16)
	_ignore_mouse(result_player_kit_label)
	player_flag.add_child(result_player_kit_label)

	result_score_label = Label.new()
	result_score_label.name = "ResultScore"
	result_score_label.text = "0 - 0"
	result_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_score_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_score_label.add_theme_font_size_override("font_size", 54)
	_ignore_mouse(result_score_label)
	score_strip.add_child(result_score_label)

	var bot_flag := VBoxContainer.new()
	bot_flag.name = "ResultBotFlag"
	bot_flag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	score_strip.add_child(bot_flag)

	result_bot_kit_swatch = ColorRect.new()
	result_bot_kit_swatch.name = "ResultBotKitSwatch"
	result_bot_kit_swatch.custom_minimum_size = Vector2(92.0, 52.0)
	result_bot_kit_swatch.color = Color(0.06, 0.16, 0.56, 1.0)
	_ignore_mouse(result_bot_kit_swatch)
	bot_flag.add_child(result_bot_kit_swatch)

	result_bot_kit_label = Label.new()
	result_bot_kit_label.name = "ResultBotKitLabel"
	result_bot_kit_label.text = "FRA"
	result_bot_kit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_bot_kit_label.add_theme_font_size_override("font_size", 16)
	_ignore_mouse(result_bot_kit_label)
	bot_flag.add_child(result_bot_kit_label)

	result_detail_label = Label.new()
	result_detail_label.name = "ResultDetail"
	result_detail_label.text = "Revanche pronta."
	result_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ignore_mouse(result_detail_label)
	box.add_child(result_detail_label)

	result_stats_label = Label.new()
	result_stats_label.name = "ResultStats"
	result_stats_label.text = "Estatisticas da partida."
	result_stats_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_stats_label.add_theme_font_size_override("font_size", 15)
	_ignore_mouse(result_stats_label)
	box.add_child(result_stats_label)

	var buttons := HBoxContainer.new()
	buttons.name = "ResultButtons"
	buttons.add_theme_constant_override("separation", 10)
	buttons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(buttons)

	result_rematch_button = Button.new()
	result_rematch_button.name = "RematchButton"
	result_rematch_button.text = "Rematch"
	result_rematch_button.custom_minimum_size = Vector2(180.0, 42.0)
	result_rematch_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_rematch_button.mouse_filter = Control.MOUSE_FILTER_STOP
	result_rematch_button.pressed.connect(func() -> void:
		rematch_requested.emit()
	)
	buttons.add_child(result_rematch_button)

	result_menu_button = Button.new()
	result_menu_button.name = "ResultMenuButton"
	result_menu_button.text = "Sair ao menu"
	result_menu_button.custom_minimum_size = Vector2(180.0, 42.0)
	result_menu_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	result_menu_button.pressed.connect(func() -> void:
		main_menu_requested.emit()
	)
	buttons.add_child(result_menu_button)

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
	pause_menu_panel.custom_minimum_size = Vector2(680.0, 560.0)
	pause_menu_panel.visible = false
	pause_menu_panel.add_theme_stylebox_override("panel", _build_panel_style(Color(0.012, 0.03, 0.04, 0.94), Color(0.12, 0.88, 1.0, 0.9), 2))
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
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title := Label.new()
	title.name = "PauseTitle"
	title.text = "Partida pausada"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	_ignore_mouse(title)
	box.add_child(title)

	pause_resume_button = Button.new()
	pause_resume_button.name = "ResumeButton"
	pause_resume_button.text = "Continuar"
	pause_resume_button.custom_minimum_size = Vector2(0.0, 42.0)
	pause_resume_button.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_resume_button.pressed.connect(func() -> void:
		resume_requested.emit()
	)
	box.add_child(pause_resume_button)

	pause_restart_button = Button.new()
	pause_restart_button.name = "RestartMatchButton"
	pause_restart_button.text = "Reiniciar partida"
	pause_restart_button.custom_minimum_size = Vector2(0.0, 42.0)
	pause_restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_restart_button.pressed.connect(func() -> void:
		restart_requested.emit()
	)
	box.add_child(pause_restart_button)

	_build_pause_tab_bar(box)
	pause_controls_section = _build_pause_controls_section(box)

	pause_audio_title = Label.new()
	pause_audio_title.name = "PauseVolumeTitle"
	pause_audio_title.text = "Audio"
	pause_audio_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_audio_title.add_theme_font_size_override("font_size", 16)
	_ignore_mouse(pause_audio_title)
	box.add_child(pause_audio_title)
	pause_volume_slider = _build_pause_volume_row(box, "VolumeRow", "VolumeLabel", "Master", "VolumeSlider", BUS_MASTER)
	pause_sfx_volume_slider = _build_pause_volume_row(box, "SfxVolumeRow", "SfxVolumeLabel", "SFX", "SfxVolumeSlider", BUS_SFX)
	pause_ui_volume_slider = _build_pause_volume_row(box, "UiVolumeRow", "UiVolumeLabel", "UI", "UiVolumeSlider", BUS_UI)
	pause_ambience_volume_slider = _build_pause_volume_row(box, "AmbienceVolumeRow", "AmbienceVolumeLabel", "Ambiente", "AmbienceVolumeSlider", BUS_AMBIENCE)
	pause_video_section = _build_pause_video_section(box)
	pause_sensitivity_section = _build_pause_sensitivity_section(box)

	pause_menu_button = Button.new()
	pause_menu_button.name = "MainMenuButton"
	pause_menu_button.text = "Sair ao menu"
	pause_menu_button.custom_minimum_size = Vector2(0.0, 42.0)
	pause_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_menu_button.pressed.connect(func() -> void:
		main_menu_requested.emit()
	)
	box.add_child(pause_menu_button)
	_set_pause_section(&"audio")

func _build_pause_tab_bar(parent: VBoxContainer) -> void:
	var tab_bar := HBoxContainer.new()
	tab_bar.name = "PauseSectionTabs"
	tab_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tab_bar.add_theme_constant_override("separation", 8)
	parent.add_child(tab_bar)
	pause_section_buttons.clear()
	tab_bar.add_child(_build_pause_tab_button(&"controls", "Controles"))
	tab_bar.add_child(_build_pause_tab_button(&"audio", "Audio"))
	tab_bar.add_child(_build_pause_tab_button(&"video", "Video"))
	tab_bar.add_child(_build_pause_tab_button(&"sensitivity", "Sensibilidade"))

func _build_pause_tab_button(section_id: StringName, label: String) -> Button:
	var button := Button.new()
	button.name = "%sTabButton" % label.replace(" ", "")
	button.text = label
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0.0, 34.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.pressed.connect(func() -> void:
		_set_pause_section(section_id)
	)
	pause_section_buttons[section_id] = button
	return button

func _build_pause_controls_section(parent: VBoxContainer) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "ControlsSection"
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_theme_constant_override("separation", 6)
	parent.add_child(section)

	var table := GridContainer.new()
	table.name = "ControlsTable"
	table.columns = 2
	table.mouse_filter = Control.MOUSE_FILTER_IGNORE
	table.add_theme_constant_override("h_separation", 18)
	table.add_theme_constant_override("v_separation", 5)
	section.add_child(table)

	for hint: Dictionary in CONTROL_HINTS:
		var action_label := Label.new()
		action_label.name = "ActionLabel"
		action_label.text = str(hint.get("action", ""))
		action_label.add_theme_font_size_override("font_size", 13)
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_ignore_mouse(action_label)
		table.add_child(action_label)

		var input_label := Label.new()
		input_label.name = "InputLabel"
		input_label.text = str(hint.get("input", ""))
		input_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		input_label.add_theme_font_size_override("font_size", 13)
		input_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_ignore_mouse(input_label)
		table.add_child(input_label)
	return section

func _build_pause_video_section(parent: VBoxContainer) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "VideoSection"
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_theme_constant_override("separation", 8)
	parent.add_child(section)

	var title := Label.new()
	title.name = "VideoTitle"
	title.text = "Video"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	_ignore_mouse(title)
	section.add_child(title)

	var fullscreen_row := HBoxContainer.new()
	fullscreen_row.name = "FullscreenRow"
	fullscreen_row.add_theme_constant_override("separation", 8)
	section.add_child(fullscreen_row)

	var fullscreen_label := Label.new()
	fullscreen_label.name = "FullscreenLabel"
	fullscreen_label.text = "Tela cheia"
	fullscreen_label.custom_minimum_size.x = 116.0
	fullscreen_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ignore_mouse(fullscreen_label)
	fullscreen_row.add_child(fullscreen_label)

	pause_fullscreen_toggle = CheckButton.new()
	pause_fullscreen_toggle.name = "FullscreenToggle"
	pause_fullscreen_toggle.text = "Ativar"
	pause_fullscreen_toggle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_fullscreen_toggle.toggled.connect(_on_pause_fullscreen_toggled)
	fullscreen_row.add_child(pause_fullscreen_toggle)

	var quality_row := HBoxContainer.new()
	quality_row.name = "QualityRow"
	quality_row.add_theme_constant_override("separation", 8)
	section.add_child(quality_row)

	var quality_label := Label.new()
	quality_label.name = "QualityLabel"
	quality_label.text = "Qualidade"
	quality_label.custom_minimum_size.x = 116.0
	quality_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ignore_mouse(quality_label)
	quality_row.add_child(quality_label)

	pause_quality_option = OptionButton.new()
	pause_quality_option.name = "QualityOption"
	pause_quality_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pause_quality_option.add_item("Alta")
	pause_quality_option.add_item("Leve")
	pause_quality_option.item_selected.connect(_on_pause_quality_selected)
	quality_row.add_child(pause_quality_option)

	pause_quality_notice_label = Label.new()
	pause_quality_notice_label.name = "QualityNoticeLabel"
	pause_quality_notice_label.text = "Ambiente e placares atualizam agora; materiais novos entram no proximo carregamento."
	pause_quality_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	pause_quality_notice_label.add_theme_font_size_override("font_size", 12)
	_ignore_mouse(pause_quality_notice_label)
	section.add_child(pause_quality_notice_label)
	return section

func _build_pause_sensitivity_section(parent: VBoxContainer) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.name = "SensitivitySection"
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	section.add_theme_constant_override("separation", 8)
	parent.add_child(section)

	var title := Label.new()
	title.name = "SensitivityTitle"
	title.text = "Sensibilidade"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	_ignore_mouse(title)
	section.add_child(title)

	var row := HBoxContainer.new()
	row.name = "SensitivityRow"
	row.add_theme_constant_override("separation", 8)
	section.add_child(row)

	sensitivity_label = Label.new()
	sensitivity_label.name = "SensitivityLabel"
	sensitivity_label.custom_minimum_size.x = 142.0
	sensitivity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ignore_mouse(sensitivity_label)
	row.add_child(sensitivity_label)

	sensitivity_slider = HSlider.new()
	sensitivity_slider.name = "SensitivitySlider"
	sensitivity_slider.min_value = 0.0008
	sensitivity_slider.max_value = 0.0032
	sensitivity_slider.step = 0.0001
	sensitivity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sensitivity_slider.mouse_filter = Control.MOUSE_FILTER_STOP
	sensitivity_slider.value_changed.connect(_on_sensitivity_slider_changed)
	row.add_child(sensitivity_slider)
	_update_sensitivity_label(sensitivity_slider.value)
	return section

func _build_pause_volume_row(parent: VBoxContainer, row_name: String, label_name: String, label: String, slider_name: String, bus_name: StringName) -> HSlider:
	var row := HBoxContainer.new()
	row.name = row_name
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var row_label := Label.new()
	row_label.name = label_name
	row_label.text = label
	row_label.custom_minimum_size.x = 96.0
	row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_ignore_mouse(row_label)
	row.add_child(row_label)

	var slider := HSlider.new()
	slider.name = slider_name
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = _get_pause_volume(bus_name)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.mouse_filter = Control.MOUSE_FILTER_STOP
	slider.value_changed.connect(func(value: float) -> void:
		_set_pause_volume(bus_name, value)
	)
	row.add_child(slider)
	return slider

func _sync_pause_settings_controls(sensitivity_value: float = 0.0) -> void:
	if pause_volume_slider != null:
		pause_volume_slider.set_value_no_signal(_get_pause_volume(BUS_MASTER))
	if pause_sfx_volume_slider != null:
		pause_sfx_volume_slider.set_value_no_signal(_get_pause_volume(BUS_SFX))
	if pause_ui_volume_slider != null:
		pause_ui_volume_slider.set_value_no_signal(_get_pause_volume(BUS_UI))
	if pause_ambience_volume_slider != null:
		pause_ambience_volume_slider.set_value_no_signal(_get_pause_volume(BUS_AMBIENCE))
	var settings = _get_game_settings()
	if pause_fullscreen_toggle != null:
		pause_fullscreen_toggle.set_pressed_no_signal(settings.get_fullscreen_enabled() if settings != null else DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	if pause_quality_option != null:
		_select_pause_quality_option(settings.get_quality_id() if settings != null else RenderProfileScript.get_quality_id())
	var next_sensitivity := sensitivity_value
	if next_sensitivity <= 0.0 and settings != null:
		next_sensitivity = settings.get_mouse_sensitivity()
	if next_sensitivity > 0.0:
		set_sensitivity_value(next_sensitivity)

func _set_pause_section(section_id: StringName) -> void:
	var normalized := section_id
	if not [&"controls", &"audio", &"video", &"sensitivity"].has(normalized):
		normalized = &"audio"
	pause_section_id = normalized
	if pause_controls_section != null:
		pause_controls_section.visible = normalized == &"controls"
	var audio_visible := normalized == &"audio"
	if pause_audio_title != null:
		pause_audio_title.visible = audio_visible
	for control in [pause_volume_slider, pause_sfx_volume_slider, pause_ui_volume_slider, pause_ambience_volume_slider]:
		if control != null and control.get_parent() != null:
			control.get_parent().visible = audio_visible
	if pause_video_section != null:
		pause_video_section.visible = normalized == &"video"
	if pause_sensitivity_section != null:
		pause_sensitivity_section.visible = normalized == &"sensitivity"
	for key in pause_section_buttons.keys():
		var button := pause_section_buttons[key] as Button
		if button != null:
			button.set_pressed_no_signal(StringName(key) == normalized)

func _get_pause_volume(bus_name: StringName) -> float:
	var settings = _get_game_settings()
	if settings != null:
		return settings.get_volume(bus_name)
	return _get_bus_volume_linear(bus_name)

func _set_pause_volume(bus_name: StringName, value: float) -> void:
	var settings = _get_game_settings()
	if settings != null:
		settings.set_volume(bus_name, value)
		return
	_set_bus_volume(bus_name, value)

func _on_pause_fullscreen_toggled(enabled: bool) -> void:
	var settings = _get_game_settings()
	if settings != null:
		settings.set_fullscreen_enabled(enabled, true, true)
	fullscreen_changed.emit(enabled)

func _on_pause_quality_selected(index: int) -> void:
	var quality_id := RenderProfileScript.QUALITY_LIGHT if index == 1 else RenderProfileScript.QUALITY_HIGH
	var settings = _get_game_settings()
	if settings != null:
		settings.set_quality_id(quality_id)
	else:
		RenderProfileScript.set_quality_id(quality_id)
	_select_pause_quality_option(quality_id)
	quality_changed.emit(quality_id)

func _select_pause_quality_option(quality_id: StringName) -> void:
	if pause_quality_option == null:
		return
	pause_quality_option.select(1 if RenderProfileScript.normalize_quality_id(quality_id) == RenderProfileScript.QUALITY_LIGHT else 0)

func _get_game_settings():
	return get_node_or_null("/root/GameSettings")

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

func _get_bus_volume_linear(bus_name: StringName) -> float:
	_ensure_audio_bus(bus_name)
	var bus_index := AudioServer.get_bus_index(str(bus_name))
	if bus_index < 0:
		return 1.0
	if AudioServer.is_bus_mute(bus_index):
		return 0.0
	return clampf(db_to_linear(AudioServer.get_bus_volume_db(bus_index)), 0.0, 1.0)

func _set_bus_volume(bus_name: StringName, value: float) -> void:
	_ensure_audio_bus(bus_name)
	var bus_index := AudioServer.get_bus_index(str(bus_name))
	if bus_index < 0:
		return
	var clamped_value := clampf(value, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, clamped_value <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, -80.0 if clamped_value <= 0.001 else linear_to_db(clamped_value))

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
	summary.text = "Futebol 1x1 em terceira pessoa. Timer de 3 minutos por padrao; 3 gols segue no menu."
	summary.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	summary.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ignore_mouse(summary)
	box.add_child(summary)

	var hotkeys := Label.new()
	hotkeys.name = "HotkeysLabel"
	hotkeys.text = "WASD - mover\nShift - boost de velocidade com stamina\nE/Ctrl - dash\nMouse - girar jogador/camera\nEspaco - pular/flip\nLMB - segurar e chutar\nRMB - chute forte/SUPER\nT - emote pos-gol\nR - reiniciar partida\nEsc - menu de sensibilidade"
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

	intro_start_button = Button.new()
	intro_start_button.name = "StartButton"
	intro_start_button.text = "Comecar"
	intro_start_button.custom_minimum_size = Vector2(320.0, 46.0)
	intro_start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intro_start_button.mouse_filter = Control.MOUSE_FILTER_STOP
	intro_start_button.pressed.connect(func() -> void:
		start_requested.emit()
	)
	box.add_child(intro_start_button)

func _build_fade_overlay(root: Control) -> void:
	fade_overlay = ColorRect.new()
	fade_overlay.name = "FadeOverlay"
	fade_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.color = Color(0.0, 0.0, 0.0, 1.0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(fade_overlay)

func play_fade_from_black(duration: float = FADE_DURATION_SECONDS) -> void:
	if _is_headless_display():
		_set_fade_alpha_immediate(0.0)
		return
	_play_fade_to_alpha(0.0, duration)

func play_fade_to_black(duration: float = FADE_DURATION_SECONDS) -> void:
	if _is_headless_display():
		_set_fade_alpha_immediate(1.0)
		return
	_play_fade_to_alpha(1.0, duration)

func play_transition_pulse(duration: float = FADE_DURATION_SECONDS) -> void:
	if _is_headless_display():
		return
	call_deferred("_play_transition_pulse_async", duration)

func _play_transition_pulse_async(duration: float) -> void:
	await _fade_to_alpha_async(1.0, duration * 0.5)
	await _fade_to_alpha_async(0.0, duration * 0.5)

func _play_fade_to_alpha(target_alpha: float, duration: float) -> void:
	call_deferred("_fade_to_alpha_async", target_alpha, duration)

func _fade_to_alpha_async(target_alpha: float, duration: float) -> void:
	if fade_overlay == null:
		return
	if fade_tween != null:
		fade_tween.kill()
	fade_overlay.visible = true
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var start_color := fade_overlay.color
	start_color.a = clampf(start_color.a, 0.0, 1.0)
	fade_overlay.color = start_color
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

func _ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE

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

func _on_sensitivity_slider_changed(value: float) -> void:
	_update_sensitivity_label(value)
	var settings = _get_game_settings()
	if settings != null:
		settings.set_mouse_sensitivity(value)
	sensitivity_changed.emit(value)

func _update_sensitivity_label(value: float) -> void:
	if sensitivity_label == null:
		return
	sensitivity_label.text = "Sensibilidade: %.1f" % [value * 1000.0]

func _refresh_overlay() -> void:
	if pulse_overlay == null:
		return
	if RenderProfileScript.is_web_platform():
		pulse_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
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
	var progress := 1.0 - clampf(event_message_time / maxf(0.01, event_message_duration), 0.0, 1.0)
	var squash := sin(progress * PI) * 0.18
	event_label.scale = Vector2.ONE if RenderProfileScript.is_web_platform() else Vector2(1.0 + squash, 1.0 - squash * 0.42)
	event_label.modulate = Color(1.0, 1.0, 1.0, alpha)

func _set_event_message(message: String, duration: float) -> void:
	if event_message_time > 0.0:
		if event_message_queue.size() >= 5:
			event_message_queue.pop_front()
		event_message_queue.append({"message": message, "duration": duration})
		return
	_start_event_message(message, duration)

func _start_event_message(message: String, duration: float) -> void:
	event_label.text = message
	event_message_duration = maxf(0.05, duration)
	event_message_time = event_message_duration

func _format_match_time(time_seconds: float) -> String:
	var seconds := maxi(0, int(ceil(time_seconds)))
	var minutes: int = int(seconds / 60)
	var remainder: int = seconds % 60
	return "%02d:%02d" % [minutes, remainder]

func _update_ball_indicator(snapshot: Dictionary) -> void:
	if ball_indicator == null or ball_indicator_label == null:
		return
	var ball_distance := float(snapshot.get("ball_distance", 0.0))
	var relative_x := float(snapshot.get("ball_relative_x", 0.0))
	var relative_z := float(snapshot.get("ball_relative_z", 0.0))
	ball_indicator.visible = ball_distance > 18.0
	if not ball_indicator.visible:
		return
	var horizontal := "E" if relative_x < -2.0 else ("D" if relative_x > 2.0 else "")
	var depth := "FRENTE" if relative_z < 0.0 else "TRAS"
	_set_label_text_if_changed(ball_indicator_label, "BOLA %s %s %.0fm" % [horizontal, depth, ball_distance])

func _get_control_label(control_state: StringName) -> String:
	if control_state == &"contact":
		return "contato"
	if control_state == &"reachable":
		return "alcance"
	return "solta"
