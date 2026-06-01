class_name RpgsuaveInventorySheet
extends PanelContainer

signal close_requested
signal deposit_requested
signal craft_requested(recipe_id: String)
signal complete_requested

const ModelScript := preload("res://dev/minigames/rpgsuave/rpgsuave_forest_model.gd")

var model: Variant = null
var integration_mode := "dev_local"
var server_session_id := ""
var network_busy := false
var pending_summary := ""
var result_text := ""
var payload_preview := {}

var _current_tab := "pocket"
var _technical_visible := false
var _title_label: Label
var _body: VBoxContainer
var _tab_buttons: Dictionary = {}
var _deposit_button: Button
var _complete_button: Button
var _technical_button: Button

func _ready() -> void:
	name = "RpgsuaveInventorySheet"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	add_theme_stylebox_override("panel", _panel_style(Color(0.0, 0.0, 0.0, 0.48), Color.TRANSPARENT))
	_build()
	visible = false

func bind_model(next_model: Variant) -> void:
	model = next_model
	render()

func render(
	next_integration_mode: String = integration_mode,
	next_server_session_id: String = server_session_id,
	next_network_busy: bool = network_busy,
	next_pending_summary: String = pending_summary,
	next_result_text: String = result_text,
	next_payload_preview: Dictionary = payload_preview
) -> void:
	integration_mode = next_integration_mode
	server_session_id = next_server_session_id
	network_busy = next_network_busy
	pending_summary = next_pending_summary
	result_text = next_result_text
	payload_preview = next_payload_preview
	if _body == null or model == null:
		return
	_title_label.text = _tab_title(_current_tab)
	_render_tab_buttons()
	_clear_body()
	match _current_tab:
		"pocket":
			_render_inventory("Bolso", model.pocket, "Peso %.1f / %.1f" % [model.pocket_weight(), model.capacity()])
		"chest":
			_render_inventory("Bau local", model.chest, "Materiais guardados no modo.")
		"craft":
			_render_craft()
		"session":
			_render_session()
		_:
			_render_inventory("Bolso", model.pocket, "Peso %.1f / %.1f" % [model.pocket_weight(), model.capacity()])

func open_sheet(tab_id: String = "pocket") -> void:
	_current_tab = tab_id
	visible = true
	render()

func close_sheet() -> void:
	visible = false
	close_requested.emit()

func set_deposit_available(available: bool) -> void:
	if _deposit_button != null:
		_deposit_button.disabled = not available or network_busy
		_deposit_button.tooltip_text = "Aproxime-se do bau para depositar." if not available else "Depositar bolso no bau."

func _build() -> void:
	var holder := VBoxContainer.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(holder)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.add_child(spacer)

	var sheet := PanelContainer.new()
	sheet.name = "RpgsuaveInventoryPanel"
	sheet.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sheet.custom_minimum_size = Vector2(0, 430)
	sheet.add_theme_stylebox_override("panel", _panel_style(Color(0.075, 0.078, 0.066, 0.97), Color(0.56, 0.48, 0.34, 0.72)))
	holder.add_child(sheet)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	sheet.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	margin.add_child(column)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)

	_title_label = Label.new()
	_title_label.text = "Mochila"
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.add_theme_color_override("font_color", Color(0.91, 0.84, 0.64))
	header.add_child(_title_label)

	var close := Button.new()
	close.name = "RpgsuaveInventoryCloseButton"
	close.text = "Fechar"
	close.custom_minimum_size = Vector2(82, 44)
	close.pressed.connect(close_sheet)
	header.add_child(close)

	var tabs := HBoxContainer.new()
	tabs.name = "RpgsuaveInventoryTabs"
	tabs.add_theme_constant_override("separation", 6)
	column.add_child(tabs)
	for tab_id in ["pocket", "chest", "craft", "session"]:
		var button := Button.new()
		button.text = _tab_button_text(tab_id)
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(72, 42)
		button.pressed.connect(Callable(self, "_select_tab").bind(tab_id))
		tabs.add_child(button)
		_tab_buttons[tab_id] = button

	_body = VBoxContainer.new()
	_body.name = "RpgsuaveInventoryBody"
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 8)
	column.add_child(_body)

func _select_tab(tab_id: String) -> void:
	_current_tab = tab_id
	if tab_id != "session":
		_technical_visible = false
	render()

func _render_tab_buttons() -> void:
	for key: String in _tab_buttons.keys():
		var button := _tab_buttons[key] as Button
		if button != null:
			button.button_pressed = key == _current_tab

func _render_inventory(title: String, source: Dictionary, subtitle: String) -> void:
	_body.add_child(_label(title, 16, Color(0.90, 0.82, 0.62)))
	_body.add_child(_label(subtitle, 13, Color(0.75, 0.72, 0.64)))
	_body.add_child(_label(_inventory_lines(source), 14, Color(0.94, 0.92, 0.84)))
	if _current_tab == "pocket":
		_deposit_button = Button.new()
		_deposit_button.name = "RpgsuaveSheetDepositButton"
		_deposit_button.text = "Depositar no bau"
		_deposit_button.custom_minimum_size = Vector2(0, 48)
		_deposit_button.pressed.connect(func() -> void:
			deposit_requested.emit()
		)
		_body.add_child(_deposit_button)

func _render_craft() -> void:
	_body.add_child(_label("Craft local", 16, Color(0.90, 0.82, 0.62)))
	_body.add_child(_label("Upgrades do modo. Nao altera Base/Conta.", 13, Color(0.75, 0.72, 0.64)))
	for recipe_id: String in ModelScript.RECIPES.keys():
		var recipe := ModelScript.RECIPES[recipe_id] as Dictionary
		var button := Button.new()
		button.name = "RpgsuaveCraft_%s" % recipe_id
		button.text = "%s  |  %s" % [str(recipe.get("display_name", recipe_id)), _cost_text(recipe.get("cost", {}))]
		button.custom_minimum_size = Vector2(0, 48)
		button.disabled = not model.can_craft(recipe_id)
		button.pressed.connect(func(id := recipe_id) -> void:
			craft_requested.emit(id)
		)
		_body.add_child(button)
	_body.add_child(_label("Ativos: %s" % _upgrade_lines(), 13, Color(0.86, 0.81, 0.68)))

func _render_session() -> void:
	_body.add_child(_label("Sessao", 16, Color(0.90, 0.82, 0.62)))
	var state := "online" if integration_mode == "integrated_alpha" and server_session_id != "" else integration_mode
	_body.add_child(_label("Estado: %s" % state, 13, Color(0.82, 0.80, 0.70)))
	_complete_button = Button.new()
	_complete_button.name = "RpgsuaveSheetCompleteButton"
	_complete_button.text = "Completar sessao" if integration_mode == "integrated_alpha" else "Gerar resultado local"
	_complete_button.custom_minimum_size = Vector2(0, 48)
	_complete_button.disabled = network_busy
	_complete_button.pressed.connect(func() -> void:
		complete_requested.emit()
	)
	_body.add_child(_complete_button)
	if result_text != "":
		_body.add_child(_label(result_text, 13, Color(0.94, 0.90, 0.74)))
	_technical_button = Button.new()
	_technical_button.name = "RpgsuaveTechnicalDetailsButton"
	_technical_button.text = "Ocultar detalhes tecnicos" if _technical_visible else "Detalhes tecnicos"
	_technical_button.custom_minimum_size = Vector2(0, 44)
	_technical_button.pressed.connect(func() -> void:
		_technical_visible = not _technical_visible
		render()
	)
	_body.add_child(_technical_button)
	if _technical_visible:
		var text := "mode=%s\nruleset=%s v%s\nsession=%s\nnetwork_busy=%s\npending=%s\npayload=%s" % [
			ModelScript.MODE_ID,
			ModelScript.RULESET_ID,
			str(ModelScript.RULESET_VERSION),
			"-" if server_session_id == "" else server_session_id,
			str(network_busy),
			"-" if pending_summary == "" else pending_summary,
			JSON.stringify(payload_preview),
		]
		var label := _label(text, 12, Color(0.78, 0.77, 0.70))
		label.name = "RpgsuaveTechnicalDetails"
		_body.add_child(label)

func _clear_body() -> void:
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	_deposit_button = null
	_complete_button = null
	_technical_button = null

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _inventory_lines(source: Dictionary) -> String:
	if source.is_empty():
		return "-"
	var keys := PackedStringArray()
	for key: String in source.keys():
		keys.append(key)
	keys.sort()
	var lines := PackedStringArray()
	for key: String in keys:
		lines.append("%s x%d" % [model.item_display_name(key), int(source.get(key, 0))])
	return "\n".join(lines)

func _upgrade_lines() -> String:
	var active := PackedStringArray()
	for key: String in model.upgrades.keys():
		if bool(model.upgrades.get(key, false)):
			active.append(key)
	return "-" if active.is_empty() else ", ".join(active)

func _cost_text(value: Variant) -> String:
	var cost: Dictionary = value if value is Dictionary else {}
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s x%d" % [model.item_display_name(key), int(cost.get(key, 0))])
	return ", ".join(parts)

func _tab_title(tab_id: String) -> String:
	match tab_id:
		"pocket":
			return "Mochila - Bolso"
		"chest":
			return "Mochila - Bau"
		"craft":
			return "Mochila - Craft"
		"session":
			return "Mochila - Sessao"
		_:
			return "Mochila"

func _tab_button_text(tab_id: String) -> String:
	match tab_id:
		"pocket":
			return "Bolso"
		"chest":
			return "Bau"
		"craft":
			return "Craft"
		"session":
			return "Sessao"
		_:
			return tab_id

func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 1 if border.a > 0.0 else 0
	style.border_width_top = 1 if border.a > 0.0 else 0
	style.border_width_right = 1 if border.a > 0.0 else 0
	style.border_width_bottom = 1 if border.a > 0.0 else 0
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 0
	style.corner_radius_bottom_right = 0
	return style
