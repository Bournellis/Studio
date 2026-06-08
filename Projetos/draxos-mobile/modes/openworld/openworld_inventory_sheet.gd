class_name OpenworldInventorySheet
extends PanelContainer

signal close_requested
signal deposit_requested
signal craft_requested(recipe_id: String)
signal station_craft_requested(recipe_id: String)
signal complete_requested
signal abandon_requested
signal guidance_reopen_requested
signal tab_changed(tab_id: String)

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")

var model: Variant = null
var integration_mode := "dev_local"
var server_session_id := ""
var network_busy := false
var pending_summary := ""
var result_text := ""
var payload_preview := {}
var can_complete := true
var session_state := "preview"
var session_message := ""
var abandon_available := false
var abandon_confirm_pending := false
var station_nearby := false
var render_count_for_tests := 0

var _current_tab := "pocket"
var _technical_visible := false
var _title_label: Label
var _body: VBoxContainer
var _tab_buttons: Dictionary = {}
var _deposit_button: Button
var _complete_button: Button
var _abandon_button: Button
var _guidance_button: Button
var _technical_button: Button

func _ready() -> void:
	name = "OpenworldInventorySheet"
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
	next_payload_preview: Dictionary = payload_preview,
	next_can_complete: bool = can_complete,
	next_session_state: String = session_state,
	next_session_message: String = session_message,
	next_abandon_available: bool = abandon_available,
	next_abandon_confirm_pending: bool = abandon_confirm_pending,
	next_station_nearby: bool = station_nearby
) -> void:
	integration_mode = next_integration_mode
	server_session_id = next_server_session_id
	network_busy = next_network_busy
	pending_summary = next_pending_summary
	result_text = next_result_text
	payload_preview = next_payload_preview
	can_complete = next_can_complete
	session_state = next_session_state
	session_message = next_session_message
	abandon_available = next_abandon_available
	abandon_confirm_pending = next_abandon_confirm_pending
	station_nearby = next_station_nearby
	if _body == null or model == null:
		return
	render_count_for_tests += 1
	_title_label.text = _tab_title(_current_tab)
	_render_tab_buttons()
	_clear_body()
	match _current_tab:
		"pocket":
			_render_inventory("Bolso", model.pocket, model.pocket_status_text())
		"chest":
			_render_inventory("Bau local", model.chest, "Materiais guardados no modo.")
		"craft":
			_render_craft()
		"fogueira":
			_render_station_craft()
		"session":
			_render_session()
		_:
			_render_inventory("Bolso", model.pocket, "Peso %.1f / %.1f" % [model.pocket_weight(), model.capacity()])

func open_sheet(tab_id: String = "pocket") -> void:
	_current_tab = tab_id
	visible = true
	render()
	tab_changed.emit(_current_tab)

func close_sheet() -> void:
	visible = false
	close_requested.emit()

func set_deposit_available(available: bool) -> void:
	if _deposit_button != null:
		_deposit_button.disabled = not available
		if network_busy:
			_deposit_button.tooltip_text = "Aguarde a confirmacao do servidor."
		elif model != null and model.pocket.is_empty():
			_deposit_button.tooltip_text = "Bolso vazio; colete algo antes."
		else:
			_deposit_button.tooltip_text = "Aproxime-se do bau para depositar." if not available else "Depositar tudo que esta no bolso."

func current_tab_for_tests() -> String:
	return _current_tab

func render_count() -> int:
	return render_count_for_tests

func _build() -> void:
	var holder := VBoxContainer.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(holder)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	holder.add_child(spacer)

	var sheet := PanelContainer.new()
	sheet.name = "OpenworldInventoryPanel"
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
	close.name = "OpenworldInventoryCloseButton"
	close.text = "Fechar"
	close.custom_minimum_size = Vector2(82, 44)
	close.pressed.connect(close_sheet)
	header.add_child(close)

	var tabs := HBoxContainer.new()
	tabs.name = "OpenworldInventoryTabs"
	tabs.add_theme_constant_override("separation", 6)
	column.add_child(tabs)
	for tab_id in ["pocket", "chest", "craft", "fogueira", "session"]:
		var button := Button.new()
		button.text = _tab_button_text(tab_id)
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(72, 42)
		button.pressed.connect(Callable(self, "_select_tab").bind(tab_id))
		tabs.add_child(button)
		_tab_buttons[tab_id] = button

	_body = VBoxContainer.new()
	_body.name = "OpenworldInventoryBody"
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 8)
	column.add_child(_body)

func _select_tab(tab_id: String) -> void:
	_current_tab = tab_id
	if tab_id != "session":
		_technical_visible = false
	render()
	tab_changed.emit(tab_id)

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
		_deposit_button.name = "OpenworldSheetDepositButton"
		_deposit_button.text = "Depositar tudo no bau"
		_deposit_button.custom_minimum_size = Vector2(0, 48)
		_deposit_button.pressed.connect(func() -> void:
			deposit_requested.emit()
		)
		_body.add_child(_deposit_button)
	elif _current_tab == "chest":
		var craft_ready: int = model.available_craft_count()
		if craft_ready > 0:
			_body.add_child(_label("Craft pronto: %s." % model.first_available_recipe_name(), 13, Color(0.96, 0.86, 0.58)))
		else:
			_body.add_child(_label("Guarde materiais aqui para liberar upgrades do Bosque.", 13, Color(0.78, 0.75, 0.66)))

func _render_craft() -> void:
	_body.add_child(_label("Construcoes", 16, Color(0.90, 0.82, 0.62)))
	var craft_ready: int = model.available_craft_count()
	var summary := "%d pronto(s). Estruturas e melhorias duraveis do Bosque." % craft_ready
	_body.add_child(_label(summary, 13, Color(0.75, 0.72, 0.64)))
	var recipes := ModelScript.recipes()
	for recipe_id: String in recipes.keys():
		var recipe := recipes[recipe_id] as Dictionary
		var recipe_state: String = model.recipe_state_text(recipe_id)
		var button := Button.new()
		button.name = "OpenworldCraft_%s" % recipe_id
		button.text = "%s  |  %s" % [str(recipe.get("display_name", recipe_id)), recipe_state]
		button.tooltip_text = "Custo: %s" % _cost_text(recipe.get("cost", {}))
		button.custom_minimum_size = Vector2(0, 48)
		button.disabled = not model.can_craft(recipe_id)
		button.pressed.connect(func(id := recipe_id) -> void:
			craft_requested.emit(id)
		)
		_body.add_child(button)
	_body.add_child(_label("Ativos: %s" % _upgrade_lines(), 13, Color(0.86, 0.81, 0.68)))

func _render_station_craft() -> void:
	_body.add_child(_label("Fogueira", 16, Color(0.90, 0.82, 0.62)))
	var built: bool = bool(model.has_upgrade("fogueira_estavel_1"))
	var checkpoint_pending := pending_summary.strip_edges() != "" or session_state in ["pending", "resyncing"]
	if not built:
		_body.add_child(_label("Construa Fogueira estavel I em Construcoes para preparar pocoes.", 13, Color(0.75, 0.72, 0.64)))
	elif checkpoint_pending:
		_body.add_child(_label("Salvando Fogueira antes de preparar...", 13, Color(0.78, 0.77, 0.70)))
	elif not station_nearby:
		_body.add_child(_label("Aproxime-se da Fogueira para preparar pocoes globais.", 13, Color(0.75, 0.72, 0.64)))
	else:
		_body.add_child(_label("Prepare pocoes na Fogueira usando materiais do Bau do Bosque e Po de Osso da Conta/Ossario.", 13, Color(0.75, 0.72, 0.64)))
	if network_busy:
		_body.add_child(_label("Salvando Bosque antes de preparar...", 13, Color(0.78, 0.77, 0.70)))
	var recipes := _station_recipes()
	if recipes.is_empty():
		_body.add_child(_label("Nenhuma receita de Fogueira disponivel neste pacote.", 13, Color(0.78, 0.75, 0.66)))
		return
	for recipe: Dictionary in recipes:
		var recipe_id := str(recipe.get("id", recipe.get("recipe_id", "")))
		var missing := _station_recipe_missing_text(recipe)
		var output_item := _recipe_output_item(recipe)
		var stock := _global_item_quantity(output_item)
		var button := Button.new()
		button.name = "OpenworldStationCraft_%s" % recipe_id
		button.text = "%s  |  Estoque %d%s" % [
			str(recipe.get("display_name", recipe_id)),
			stock,
			"  |  %s" % missing if missing != "" else "  |  Pronta",
		]
		button.tooltip_text = "Custo: %s" % _station_cost_text(recipe)
		button.custom_minimum_size = Vector2(0, 48)
		button.disabled = (not built) or checkpoint_pending or (not station_nearby) or network_busy or missing != ""
		button.pressed.connect(func(id := recipe_id) -> void:
			station_craft_requested.emit(id)
		)
		_body.add_child(button)
	_body.add_child(_label("A Fogueira cria consumiveis globais para a Arena; por isso confirma no servidor.", 12, Color(0.78, 0.75, 0.66)))

func _render_session() -> void:
	_body.add_child(_label("Bosque", 16, Color(0.90, 0.82, 0.62)))
	var state := _session_state_text()
	_body.add_child(_label("Estado: %s" % state, 13, Color(0.82, 0.80, 0.70)))
	_body.add_child(_label("Mochila do Bosque: %s" % model.inventory_summary_text(model.pocket, "vazia"), 13, Color(0.86, 0.83, 0.70)))
	_body.add_child(_label("Bau do Bosque: %s" % model.inventory_summary_text(model.chest, "sem deposito"), 13, Color(0.86, 0.83, 0.70)))
	_body.add_child(_label("Criacoes: %s" % model.upgrades_summary_text("nenhuma"), 13, Color(0.86, 0.83, 0.70)))
	if session_message.strip_edges() != "":
		_body.add_child(_label(session_message, 13, Color(0.86, 0.83, 0.70)))
	if pending_summary.strip_edges() != "":
		_body.add_child(_label("Sincronizando: %s" % pending_summary, 12, Color(0.78, 0.77, 0.70)))
	_complete_button = Button.new()
	_complete_button.name = "OpenworldSheetCompleteButton"
	_complete_button.text = "Encerrar visita"
	_complete_button.custom_minimum_size = Vector2(0, 48)
	_complete_button.disabled = network_busy or not can_complete
	_complete_button.pressed.connect(func() -> void:
		complete_requested.emit()
	)
	_body.add_child(_complete_button)
	_render_guidance_session_block()
	if abandon_available:
		_abandon_button = Button.new()
		_abandon_button.name = "OpenworldSheetAbandonButton"
		_abandon_button.text = "Confirmar abandono" if abandon_confirm_pending else "Abandonar sessao"
		_abandon_button.custom_minimum_size = Vector2(0, 46)
		_abandon_button.disabled = network_busy
		_abandon_button.pressed.connect(func() -> void:
			abandon_requested.emit()
		)
		_body.add_child(_abandon_button)
	if result_text != "":
		_body.add_child(_label(result_text, 13, Color(0.94, 0.90, 0.74)))
	_technical_button = Button.new()
	_technical_button.name = "OpenworldTechnicalDetailsButton"
	_technical_button.text = "Ocultar detalhes da operacao" if _technical_visible else "Detalhes da operacao"
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
		label.name = "OpenworldTechnicalDetails"
		_body.add_child(label)

func _clear_body() -> void:
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	_deposit_button = null
	_complete_button = null
	_abandon_button = null
	_guidance_button = null
	_technical_button = null

func _render_guidance_session_block() -> void:
	if model == null or not model.has_method("guidance_state"):
		return
	var guidance_text := ""
	if model.has_method("guidance_text"):
		guidance_text = str(model.guidance_text())
	if guidance_text == "":
		guidance_text = "Dicas ocultas ou concluidas. Reabra se quiser rever o fluxo."
	_body.add_child(_label("Dicas do Bosque", 15, Color(0.90, 0.82, 0.62)))
	_body.add_child(_label(guidance_text, 13, Color(0.84, 0.80, 0.68)))
	_guidance_button = Button.new()
	_guidance_button.name = "OpenworldGuidanceReopenButton"
	_guidance_button.text = "Reabrir dicas do Bosque"
	_guidance_button.custom_minimum_size = Vector2(0, 44)
	_guidance_button.disabled = network_busy
	_guidance_button.pressed.connect(func() -> void:
		guidance_reopen_requested.emit()
	)
	_body.add_child(_guidance_button)

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
		return "Nenhum item."
	var keys := PackedStringArray()
	for key: String in source.keys():
		keys.append(key)
	keys.sort()
	var lines := PackedStringArray()
	for key: String in keys:
		lines.append("%s x%d" % [model.item_display_name(key), int(source.get(key, 0))])
	return "\n".join(lines)

func _upgrade_lines() -> String:
	return model.upgrades_summary_text("-")

func _cost_text(value: Variant) -> String:
	var cost: Dictionary = value if value is Dictionary else {}
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s x%d" % [model.item_display_name(key), int(cost.get(key, 0))])
	return ", ".join(parts)

func _station_recipes() -> Array[Dictionary]:
	var crafting := _crafting_snapshot()
	var source := _as_array(crafting.get("recipes", []))
	var result: Array[Dictionary] = []
	for recipe_variant: Variant in source:
		var recipe := _as_dictionary(recipe_variant)
		var station := _as_dictionary(recipe.get("station", {}))
		if str(station.get("mode_id", "")) != ModelScript.MODE_ID:
			continue
		if str(station.get("slice_id", "")) != ModelScript.SLICE_ID:
			continue
		if str(station.get("station_id", "")) != "fogueira_estavel_1":
			continue
		result.append(recipe)
	if result.is_empty():
		var fallback := [
			{
				"id": "craft_pocao_vida",
				"display_name": "Preparar Pocao de Vida",
				"inputs": [
					{"domain": "openworld_chest", "item_id": "folha", "quantity": 2},
					{"domain": "openworld_chest", "item_id": "cogumelo", "quantity": 1},
					{"domain": "account_resource", "item_id": "po_osso", "quantity": 25},
				],
				"outputs": [{"domain": "account_consumable", "item_id": "pocao_vida", "quantity": 1}],
			},
			{
				"id": "craft_pocao_foco",
				"display_name": "Preparar Pocao de Foco",
				"inputs": [
					{"domain": "openworld_chest", "item_id": "fungo", "quantity": 1},
					{"domain": "openworld_chest", "item_id": "inseto", "quantity": 1},
					{"domain": "account_resource", "item_id": "po_osso", "quantity": 15},
				],
				"outputs": [{"domain": "account_consumable", "item_id": "pocao_foco", "quantity": 1}],
			},
			{
				"id": "craft_pocao_resguardo",
				"display_name": "Preparar Pocao de Resguardo",
				"inputs": [
					{"domain": "openworld_chest", "item_id": "resina", "quantity": 1},
					{"domain": "openworld_chest", "item_id": "pedra_pequena", "quantity": 1},
					{"domain": "account_resource", "item_id": "po_osso", "quantity": 20},
				],
				"outputs": [{"domain": "account_consumable", "item_id": "pocao_resguardo", "quantity": 1}],
			},
		]
		for recipe: Dictionary in fallback:
			result.append(recipe)
	return result

func _station_recipe_missing_text(recipe: Dictionary) -> String:
	var parts := PackedStringArray()
	for input_variant: Variant in _as_array(recipe.get("inputs", [])):
		var input := _as_dictionary(input_variant)
		var item_id := str(input.get("item_id", "")).strip_edges()
		var quantity := maxi(1, int(input.get("quantity", 1)))
		var missing := quantity - _input_stock(input)
		if missing > 0:
			parts.append("%s x%d" % [_input_display_name(input), missing])
	return ", ".join(parts)

func _station_cost_text(recipe: Dictionary) -> String:
	var parts := PackedStringArray()
	for input_variant: Variant in _as_array(recipe.get("inputs", [])):
		var input := _as_dictionary(input_variant)
		parts.append("%s x%d" % [_input_display_name(input), maxi(1, int(input.get("quantity", 1)))])
	return ", ".join(parts)

func _input_stock(input: Dictionary) -> int:
	var domain := str(input.get("domain", "")).strip_edges()
	var item_id := str(input.get("item_id", "")).strip_edges()
	match domain:
		"openworld_chest":
			return int(model.chest.get(item_id, 0))
		"account_resource":
			return int(_resources_snapshot().get(item_id, 0))
		"account_consumable":
			return _global_item_quantity(item_id)
		_:
			return 0

func _input_display_name(input: Dictionary) -> String:
	var domain := str(input.get("domain", "")).strip_edges()
	var item_id := str(input.get("item_id", "")).strip_edges()
	if domain == "openworld_chest":
		return "%s (Bau do Bosque)" % model.item_display_name(item_id)
	if domain == "account_resource":
		return "%s (Conta/Ossario)" % _global_item_display_name(item_id)
	if domain == "account_consumable":
		return "%s (Pocoes globais)" % _global_item_display_name(item_id)
	return _global_item_display_name(item_id)

func _recipe_output_item(recipe: Dictionary) -> String:
	for output_variant: Variant in _as_array(recipe.get("outputs", [])):
		var output := _as_dictionary(output_variant)
		if str(output.get("domain", "")) == "account_consumable":
			return str(output.get("item_id", ""))
	return ""

func _global_item_quantity(item_id: String) -> int:
	var clean_id := item_id.strip_edges()
	if clean_id == "":
		return 0
	for item_variant: Variant in _as_array(_crafting_snapshot().get("inventory", [])):
		var item := _as_dictionary(item_variant)
		if str(item.get("item_id", "")) == clean_id:
			return int(item.get("quantity", 0))
	return 0

func _global_item_display_name(item_id: String) -> String:
	match item_id:
		"po_osso":
			return "Po de Osso"
		"pocao_vida":
			return "Pocao de Vida"
		"pocao_foco":
			return "Pocao de Foco"
		"pocao_resguardo":
			return "Pocao de Resguardo"
		_:
			return item_id.replace("_", " ").capitalize()

func _session_store() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().root.get_node_or_null("SessionStore")

func _crafting_snapshot() -> Dictionary:
	var session_store := _session_store()
	if session_store != null and session_store.has_method("crafting_snapshot"):
		return _as_dictionary(session_store.call("crafting_snapshot"))
	return {}

func _resources_snapshot() -> Dictionary:
	var session_store := _session_store()
	if session_store != null and session_store.has_method("resources_snapshot"):
		return _as_dictionary(session_store.call("resources_snapshot"))
	return {}

func _tab_title(tab_id: String) -> String:
	match tab_id:
		"pocket":
			return "Mochila - Bolso"
		"chest":
			return "Mochila - Bau"
		"craft":
			return "Mochila - Construcoes"
		"fogueira":
			return "Mochila - Fogueira"
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
			return "Constr."
		"fogueira":
			return "Fogueira"
		"session":
			return "Sessao"
		_:
			return tab_id

func _session_state_text() -> String:
	match session_state:
		"starting":
			return "Iniciando sessao online"
		"synced":
			return "Retomada pronta por ate 2h"
		"pending":
			return "Sincronizacao pendente"
		"resyncing":
			return "Resincronizando"
		"completed":
			return "Visita encerrada"
		"offline":
			return "Offline - preview sem recompensa"
		"blocked":
			return "Bloqueado - preview sem recompensa"
		_:
			return "Preview sem recompensa"

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _as_array(value: Variant) -> Array:
	return value if value is Array else []

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
