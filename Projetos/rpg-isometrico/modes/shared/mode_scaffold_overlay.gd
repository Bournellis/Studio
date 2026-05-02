class_name ModeScaffoldOverlay
extends CanvasLayer

var session_manager

var title_label: Label
var summary_label: Label
var state_label: Label

func _ready() -> void:
	layer = 9
	_build_ui()

func bind(mode_title: String, summary_lines: Array[String], next_session_manager) -> void:
	if title_label == null:
		_build_ui()
	session_manager = next_session_manager
	title_label.text = mode_title
	summary_label.text = "\n".join(summary_lines)
	if session_manager != null and not session_manager.session_ended.is_connected(_on_session_ended):
		session_manager.session_ended.connect(_on_session_ended)

func _process(_delta: float) -> void:
	state_label.text = _format_session_state()

func _build_ui() -> void:
	if title_label != null:
		return
	var panel: PanelContainer = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	panel.offset_left = -372.0
	panel.offset_top = 16.0
	panel.offset_right = -16.0
	panel.custom_minimum_size = Vector2(356.0, 0.0)
	add_child(panel)

	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.09, 0.11, 0.86)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.84, 0.46, 0.22, 0.32)
	style_box.corner_radius_top_left = 14
	style_box.corner_radius_top_right = 14
	style_box.corner_radius_bottom_left = 14
	style_box.corner_radius_bottom_right = 14
	panel.add_theme_stylebox_override("panel", style_box)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.modulate = Color(0.95, 0.82, 0.64, 1.0)
	column.add_child(title_label)

	summary_label = Label.new()
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.modulate = Color(0.86, 0.88, 0.92, 1.0)
	column.add_child(summary_label)

	state_label = Label.new()
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_label.modulate = Color(0.72, 0.9, 0.8, 1.0)
	column.add_child(state_label)

	var hint_label: Label = Label.new()
	hint_label.text = "Esc volta ao frontend"
	hint_label.modulate = Color(0.76, 0.78, 0.82, 0.92)
	column.add_child(hint_label)

func _format_session_state() -> String:
	if session_manager == null:
		return "Estado: carregando scaffold"

	match int(session_manager.state):
		0:
			return "Estado: carregando"
		1:
			return "Estado: preparacao %.1fs" % session_manager.get_state_remaining_seconds()
		2:
			return "Estado: em andamento"
		3:
			return "Estado: encerrando %.1fs" % session_manager.get_state_remaining_seconds()
		4:
			return "Estado: resultado"
		_:
			return "Estado: desconhecido"

func _on_session_ended(_result: Dictionary) -> void:
	visible = false
