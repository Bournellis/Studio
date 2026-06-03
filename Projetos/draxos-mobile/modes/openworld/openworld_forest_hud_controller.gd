class_name OpenworldForestHudController
extends RefCounted

signal deposit_requested
signal craft_requested(recipe_id: String)
signal complete_requested
signal abandon_requested
signal back_requested

const JoystickScript := preload("res://modes/openworld/openworld_virtual_joystick.gd")
const InventorySheetScript := preload("res://modes/openworld/openworld_inventory_sheet.gd")

var model: Variant = null
var joystick: Variant = null
var sheet: Variant = null

var hud_top: PanelContainer
var actions: HBoxContainer
var weight_label: Label
var status_label: Label
var mode_label: Label
var feedback_label: Label
var inventory_button: Button
var deposit_button: Button
var complete_button: Button
var back_button: Button

var _last_sheet_signature := ""
var _last_state: Dictionary = {}
var _compact_actions := false

func build(root: Control, next_model: Variant) -> void:
	model = next_model
	hud_top = PanelContainer.new()
	hud_top.name = "OpenworldHudTop"
	hud_top.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.052, 0.045, 0.82), Color(0.74, 0.64, 0.42, 0.36)))
	root.add_child(hud_top)

	var hud_margin := MarginContainer.new()
	hud_margin.add_theme_constant_override("margin_left", 10)
	hud_margin.add_theme_constant_override("margin_right", 10)
	hud_margin.add_theme_constant_override("margin_top", 8)
	hud_margin.add_theme_constant_override("margin_bottom", 8)
	hud_top.add_child(hud_margin)

	var hud_column := VBoxContainer.new()
	hud_column.add_theme_constant_override("separation", 2)
	hud_margin.add_child(hud_column)

	var hud_row := HBoxContainer.new()
	hud_row.add_theme_constant_override("separation", 8)
	hud_column.add_child(hud_row)

	weight_label = _hud_label("")
	weight_label.name = "OpenworldPocketWeight"
	weight_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_row.add_child(weight_label)

	mode_label = _hud_label("")
	mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud_row.add_child(mode_label)

	status_label = _hud_label("")
	status_label.name = "OpenworldCollectState"
	hud_column.add_child(status_label)

	feedback_label = _hud_label("")
	feedback_label.name = "OpenworldFeedback"
	feedback_label.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58))
	hud_column.add_child(feedback_label)

	joystick = JoystickScript.new()
	joystick.name = "OpenworldVirtualJoystick"
	joystick.visible = false
	root.add_child(joystick)

	actions = HBoxContainer.new()
	actions.name = "OpenworldActionButtons"
	actions.add_theme_constant_override("separation", 6)
	actions.size_flags_horizontal = Control.SIZE_SHRINK_END
	root.add_child(actions)

	inventory_button = _action_button("Mochila")
	inventory_button.name = "OpenworldInventoryButton"
	inventory_button.pressed.connect(func() -> void:
		open_sheet("pocket")
	)
	actions.add_child(inventory_button)

	deposit_button = _action_button("Depositar")
	deposit_button.name = "OpenworldDepositButton"
	deposit_button.pressed.connect(func() -> void:
		deposit_requested.emit()
	)
	actions.add_child(deposit_button)

	complete_button = _action_button("Completar")
	complete_button.name = "OpenworldCompleteButton"
	complete_button.pressed.connect(func() -> void:
		complete_requested.emit()
	)
	actions.add_child(complete_button)

	back_button = _action_button("Voltar")
	back_button.name = "OpenworldBackButton"
	back_button.pressed.connect(func() -> void:
		back_requested.emit()
	)
	actions.add_child(back_button)

	sheet = InventorySheetScript.new()
	sheet.bind_model(model)
	sheet.deposit_requested.connect(func() -> void:
		deposit_requested.emit()
	)
	sheet.craft_requested.connect(func(recipe_id: String) -> void:
		craft_requested.emit(recipe_id)
	)
	sheet.complete_requested.connect(func() -> void:
		complete_requested.emit()
	)
	sheet.abandon_requested.connect(func() -> void:
		abandon_requested.emit()
	)
	root.add_child(sheet)

func layout(screen_size: Vector2) -> void:
	if hud_top == null:
		return
	var safe_margin := 12.0
	var top_width := minf(screen_size.x - safe_margin * 2.0, 460.0)
	hud_top.position = Vector2(safe_margin, safe_margin)
	hud_top.size = Vector2(top_width, 92.0)
	if joystick != null:
		joystick.size = JoystickScript.BASE_SIZE
		if not joystick.is_active():
			joystick.visible = false
	if actions != null:
		var separation := 4 if screen_size.x < 420.0 else 6
		actions.add_theme_constant_override("separation", separation)
		_compact_actions = screen_size.x < 420.0
		actions.size = Vector2(screen_size.x if _compact_actions else minf(380.0, screen_size.x - 28.0), 48.0)
		actions.position = Vector2(0.0 if _compact_actions else maxf(14.0, screen_size.x - actions.size.x - 14.0), maxf(16.0, screen_size.y - 72.0))
		var button_width := maxf(58.0, floor((actions.size.x - float(separation * 3)) / 4.0))
		for button: Button in [inventory_button, deposit_button, complete_button, back_button]:
			if button != null:
				button.custom_minimum_size = Vector2(button_width, 48.0)
		if inventory_button != null:
			inventory_button.text = "Moch." if _compact_actions else "Mochila"
		if deposit_button != null:
			deposit_button.text = "Dep." if _compact_actions else "Depositar"
		if back_button != null:
			back_button.text = "Voltar"
		var minimum_width := actions.get_combined_minimum_size().x
		var scale_x := minf(1.0, screen_size.x / maxf(1.0, minimum_width))
		actions.scale = Vector2(scale_x, 1.0)

func update(state: Dictionary) -> void:
	_last_state = state.duplicate(true)
	if weight_label != null:
		weight_label.text = "Bolso %.1f / %.1f" % [
			float(state.get("pocket_weight", 0.0)),
			float(state.get("capacity", 0.0)),
		]
	if mode_label != null:
		mode_label.text = str(state.get("mode_label", "Bosque"))
	if status_label != null:
		status_label.text = str(state.get("status_text", "Explore o bosque"))
	if feedback_label != null:
		feedback_label.text = str(state.get("feedback_text", ""))
	if deposit_button != null:
		deposit_button.disabled = bool(state.get("deposit_disabled", false))
		deposit_button.tooltip_text = str(state.get("deposit_tooltip", "Depositar bolso no bau."))
	if complete_button != null:
		complete_button.text = ("Fim" if str(state.get("integration_mode", "dev_local")) == "integrated_alpha" else "Preview") if _compact_actions else str(state.get("complete_text", "Completar"))
		complete_button.disabled = bool(state.get("complete_disabled", false))
		complete_button.tooltip_text = str(state.get("complete_tooltip", "Completar sessao."))
	_render_sheet_if_needed(state, false)

func open_sheet(tab_id: String) -> void:
	if sheet == null:
		return
	sheet.open_sheet(tab_id)
	_render_sheet_if_needed(_last_state, true)

func force_sheet_render() -> void:
	_last_sheet_signature = ""
	_render_sheet_if_needed(_last_state, true)

func overlay_controls() -> Array[Control]:
	var controls: Array[Control] = []
	for node: Variant in [hud_top, actions, sheet, joystick]:
		if node is Control:
			controls.append(node)
	return controls

func _render_sheet_if_needed(state: Dictionary, force: bool) -> void:
	if sheet == null or state.is_empty():
		return
	var signature := _sheet_signature(state)
	if not force and signature == _last_sheet_signature:
		return
	_last_sheet_signature = signature
	sheet.render(
		str(state.get("integration_mode", "dev_local")),
		str(state.get("server_session_id", "")),
		bool(state.get("network_busy", false)),
		str(state.get("pending_summary", "")),
		str(state.get("result_text", "")),
		_as_dictionary(state.get("payload_preview", {})),
		bool(state.get("can_complete", true)),
		str(state.get("session_state", "preview")),
		str(state.get("session_message", "")),
		bool(state.get("abandon_available", false)),
		bool(state.get("abandon_confirm_pending", false))
	)
	sheet.set_deposit_available(bool(state.get("deposit_available", false)))

func _sheet_signature(state: Dictionary) -> String:
	var payload := {
		"tab": sheet.current_tab_for_tests() if sheet != null and sheet.has_method("current_tab_for_tests") else "",
		"visible": sheet.visible if sheet != null else false,
		"integration_mode": state.get("integration_mode", ""),
		"server_session_id": state.get("server_session_id", ""),
		"network_busy": state.get("network_busy", false),
		"pending_summary": state.get("pending_summary", ""),
		"result_text": state.get("result_text", ""),
		"can_complete": state.get("can_complete", false),
		"session_state": state.get("session_state", ""),
		"session_message": state.get("session_message", ""),
		"abandon_available": state.get("abandon_available", false),
		"abandon_confirm_pending": state.get("abandon_confirm_pending", false),
		"deposit_available": state.get("deposit_available", false),
		"pocket": model.pocket if model != null else {},
		"chest": model.chest if model != null else {},
		"upgrades": model.upgrades if model != null else {},
		"active_collection": model.active_collection if model != null else {},
	}
	return JSON.stringify(payload)

func _hud_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.94, 0.91, 0.80))
	return label

func _action_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.clip_text = true
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(62, 48)
	button.tooltip_text = text
	return button

func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
