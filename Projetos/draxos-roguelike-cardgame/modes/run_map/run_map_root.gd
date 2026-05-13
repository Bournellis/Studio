extends Control

const RunMapRouteLayerScript = preload("res://ui/controls/run_map_route_layer.gd")

var status_label: Label
var nodes_box: Control
var reward_box: VBoxContainer
var route_layer

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	if RunSession.active and RunSession.current_node_id == "":
		RunSession.select_next_available_node()
	_build_ui()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		var viewport: Viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		_return_to_ship()

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("mission_map_background")
	background.name = "RunMapVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "RunMapVisualScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.18)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var title_panel: PanelContainer = PanelContainer.new()
	title_panel.name = "RunMapTitlePanel"
	title_panel.anchor_left = 0.025
	title_panel.anchor_top = 0.035
	title_panel.anchor_right = 0.52
	title_panel.anchor_bottom = 0.035
	title_panel.offset_bottom = 78.0
	title_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", 0.50))
	add_child(title_panel)

	var title_box: VBoxContainer = VBoxContainer.new()
	title_box.add_theme_constant_override("separation", 2)
	title_panel.add_child(title_box)

	var title: Label = Label.new()
	title.name = "RunMapTitle"
	title.text = "Mapa de Missao - %s" % str(ContentLibrary.get_run_map().get("display_name", "Invasao Inicial"))
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title_box.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Rota de invasao projetada sobre o planeta elemental"
	subtitle.add_theme_font_size_override("font_size", 12)
	subtitle.add_theme_color_override("font_color", Color(0.84, 0.9, 0.94, 0.84))
	title_box.add_child(subtitle)

	var map_area: Control = Control.new()
	map_area.name = "RunMapRouteArea"
	map_area.anchor_left = 0.03
	map_area.anchor_top = 0.16
	map_area.anchor_right = 0.74
	map_area.anchor_bottom = 0.88
	map_area.offset_left = 0.0
	map_area.offset_top = 0.0
	map_area.offset_right = 0.0
	map_area.offset_bottom = 0.0
	add_child(map_area)

	route_layer = RunMapRouteLayerScript.new()
	route_layer.name = "RunMapRouteLines"
	route_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_area.add_child(route_layer)

	nodes_box = Control.new()
	nodes_box.name = "RunMapNodes"
	nodes_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	map_area.add_child(nodes_box)
	_rebuild_route_visuals()

	var side_panel: PanelContainer = PanelContainer.new()
	side_panel.name = "RunMapStatusPanel"
	side_panel.anchor_left = 1.0
	side_panel.anchor_top = 0.10
	side_panel.anchor_right = 1.0
	side_panel.anchor_bottom = 0.98
	side_panel.offset_left = -330.0
	side_panel.offset_right = -22.0
	side_panel.offset_bottom = -8.0
	side_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt", 0.72))
	add_child(side_panel)

	var side_box: VBoxContainer = VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 9)
	side_panel.add_child(side_box)

	var side_title: Label = Label.new()
	side_title.text = "Rota Atual"
	side_title.add_theme_font_size_override("font_size", 21)
	side_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	side_box.add_child(side_title)

	status_label = Label.new()
	status_label.name = "RunMapStatus"
	status_label.text = _status_text()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	status_label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	side_box.add_child(status_label)

	reward_box = VBoxContainer.new()
	reward_box.name = "RunMapRewardChoices"
	reward_box.add_theme_constant_override("separation", 8)
	side_box.add_child(reward_box)
	_rebuild_reward_choices()

	var future_battle_button: Button = Button.new()
	future_battle_button.name = "RunMapFutureBattleButton"
	future_battle_button.text = "Iniciar Encontro"
	future_battle_button.pressed.connect(func() -> void:
		if not RunSession.active:
			status_label.text = "Volte para a nave e inicie uma run antes de entrar em combate."
			return
		if RunSession.current_node_id == "":
			status_label.text = "Selecione um node disponivel antes de iniciar o encontro."
			return
		SaveManager.save_current_run()
		get_tree().change_scene_to_file("res://modes/battle/battle.tscn")
	)
	side_box.add_child(future_battle_button)

	var back_button: Button = Button.new()
	back_button.name = "RunMapBackToShipHubButton"
	back_button.text = "Voltar para Nave"
	back_button.pressed.connect(_return_to_ship)
	side_box.add_child(back_button)

func _rebuild_route_visuals() -> void:
	_rebuild_route_lines()
	_rebuild_nodes()

func _rebuild_route_lines() -> void:
	if route_layer == null:
		return
	route_layer.setup(_route_connections())

func _route_connections() -> Array[Dictionary]:
	var connections: Array[Dictionary] = []
	var nodes: Array = Array(ContentLibrary.get_run_map().get("nodes", []))
	for node: Dictionary in nodes:
		var from_id: String = str(node.get("id", ""))
		for unlock_id: String in Array(node.get("unlocks", [])):
			var to_node: Dictionary = _find_run_node(nodes, unlock_id)
			if to_node.is_empty():
				continue
			connections.append({
				"from": VisualAssets.node_position(from_id),
				"to": VisualAssets.node_position(unlock_id),
				"state": _connection_state(node, to_node)
			})
	return connections

func _connection_state(from_node: Dictionary, to_node: Dictionary) -> String:
	var from_id: String = str(from_node.get("id", ""))
	var to_id: String = str(to_node.get("id", ""))
	if RunSession.current_node_id == to_id:
		return "selected"
	if RunSession.completed_node_ids.has(from_id) and RunSession.completed_node_ids.has(to_id):
		return "completed"
	if RunSession.is_node_available(to_node):
		return "available"
	return "locked"

func _rebuild_nodes() -> void:
	for child: Node in nodes_box.get_children():
		child.queue_free()
	var run_map: Dictionary = ContentLibrary.get_run_map()
	for node: Dictionary in Array(run_map.get("nodes", [])):
		nodes_box.add_child(_build_node_button(node))

func _build_node_button(node: Dictionary) -> Button:
	var encounter: Dictionary = ContentLibrary.get_catalog().find_encounter(str(node.get("encounter_id", "")))
	var node_id: String = str(node.get("id", "unknown"))
	var state: String = _node_state(node)
	var button: Button = Button.new()
	button.name = "RunMapNode_%s" % node_id
	button.text = "%s %s" % [_node_icon(node, state), VisualAssets.node_label(node_id)]
	button.tooltip_text = "%s\n%s" % [str(encounter.get("display_name", node.get("encounter_id", ""))), _node_status_text(node, state)]
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = Vector2(132, 44)
	var position: Vector2 = VisualAssets.node_position(node_id)
	button.anchor_left = position.x
	button.anchor_top = position.y
	button.anchor_right = position.x
	button.anchor_bottom = position.y
	button.offset_left = -66.0
	button.offset_top = -22.0
	button.offset_right = 66.0
	button.offset_bottom = 22.0
	button.disabled = state == "completed" or state == "locked"
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_disabled_color", Color(0.82, 0.88, 0.84, 0.82))
	button.add_theme_stylebox_override("normal", _node_style(state, false))
	button.add_theme_stylebox_override("hover", _node_style(state, true))
	button.add_theme_stylebox_override("pressed", _node_style("selected", true))
	button.add_theme_stylebox_override("disabled", _node_style(state, false))
	button.pressed.connect(func() -> void:
		_select_node(node)
	)
	return button

func _select_node(node: Dictionary) -> void:
	RunSession.select_node(str(node.get("id", "")))
	if RunSession.active and RunSession.has_selected_class():
		SaveManager.save_current_run()
	status_label.text = _status_text()
	_rebuild_route_visuals()

func _node_state(node: Dictionary) -> String:
	var node_id: String = str(node.get("id", ""))
	if RunSession.completed_node_ids.has(node_id):
		return "completed"
	if RunSession.current_node_id == node_id:
		return "selected"
	if RunSession.is_node_available(node):
		return "available"
	return "locked"

func _node_icon(node: Dictionary, state: String) -> String:
	if state == "completed":
		return "OK"
	if state == "selected":
		return ">>"
	match str(node.get("kind", "")):
		"sidequest":
			return "+"
		"mainline":
			return "*"
	return "-"

func _node_status_text(node: Dictionary, state: String) -> String:
	match state:
		"completed":
			return "Concluido"
		"selected":
			return "Selecionado"
		"available":
			return "Disponivel"
	return "Bloqueado: conclua os requisitos anteriores."

func _status_text() -> String:
	if not RunSession.active:
		return "Nenhuma run ativa. Volte para a nave, escolha uma Classe e inicie a run."
	var completed_text: String = _completed_nodes_text()
	var health_text: String = "Vida: %d/%d" % [RunSession.current_health, RunSession.max_health]
	var economy_text: String = "\nMana: %d\nMao: %d\nAlmas: %d" % [RunSession.max_mana, RunSession.max_hand_size, RunSession.soul_total]
	var last_result_text: String = ""
	if RunSession.last_completed_node_id != "":
		last_result_text = "\nUltimo encontro concluido: %s" % RunSession.last_completed_node_id
	var reward_text: String = "\nRecompensas automaticas aplicadas: %d" % RunSession.automatic_reward_ids.size()
	if RunSession.current_node_id == "":
		return "Nome: %s\nClasse: %s\n%s%s%s%s\nConcluidos: %s\n\nSelecione o proximo encontro disponivel no planeta." % [
			RunSession.player_display_name(),
			RunSession.selected_class_display_name,
			health_text,
			economy_text,
			last_result_text,
			reward_text,
			completed_text
		]
	return "Nome: %s\nClasse: %s\n%s%s%s%s\nConcluidos: %s\nNode selecionado: %s\n\nUse Iniciar Encontro para entrar na batalha atual." % [
		RunSession.player_display_name(),
		RunSession.selected_class_display_name,
		health_text,
		economy_text,
		last_result_text,
		reward_text,
		completed_text,
		RunSession.current_node_id
	]

func _completed_nodes_text() -> String:
	if RunSession.completed_node_ids.is_empty():
		return "nenhum"
	return ", ".join(RunSession.completed_node_ids)

func _rebuild_reward_choices() -> void:
	for child: Node in reward_box.get_children():
		child.queue_free()
	var label: Label = Label.new()
	label.name = "RunMapAutomaticRewards"
	label.text = "Recompensas fixas sao aplicadas automaticamente: mana, limite de mao, passiva e spell."
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	reward_box.add_child(label)

func _apply_placeholder_reward(reward_id: String) -> void:
	var result: Dictionary = RunSession.apply_placeholder_reward(reward_id)
	status_label.text = "%s\n\n%s" % [str(result.get("message", "")), _status_text()]
	_rebuild_reward_choices()

func _return_to_ship() -> void:
	if RunSession.active and RunSession.has_selected_class():
		SaveManager.save_current_run()
	get_tree().change_scene_to_file("res://modes/ship_hub/ship_hub.tscn")

func _find_run_node(nodes: Array, node_id: String) -> Dictionary:
	for node: Variant in nodes:
		if typeof(node) == TYPE_DICTIONARY and str(Dictionary(node).get("id", "")) == node_id:
			return Dictionary(node)
	return {}

func _panel_style(color_token: String, alpha: float = 0.72) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var bg_color: Color = UiTokens.color(color_token, Color(0.1, 0.11, 0.12))
	style.bg_color = Color(bg_color.r, bg_color.g, bg_color.b, alpha)
	var border_color: Color = UiTokens.color("border_default", Color(0.25, 0.3, 0.34))
	style.border_color = Color(border_color.r, border_color.g, border_color.b, 0.76)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_top = 12
	style.content_margin_right = 14
	style.content_margin_bottom = 12
	return style

func _node_style(state: String, is_hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	var fill: Color = Color(0.06, 0.075, 0.085, 0.52)
	var border: Color = Color(0.45, 0.52, 0.58, 0.62)
	match state:
		"completed":
			fill = Color(0.05, 0.15, 0.10, 0.58)
			border = Color(0.55, 0.95, 0.78, 0.90)
		"available":
			fill = Color(0.16, 0.12, 0.05, 0.60)
			border = Color(0.95, 0.78, 0.34, 0.90)
		"selected":
			fill = Color(0.06, 0.12, 0.18, 0.68)
			border = Color(0.62, 0.88, 1.0, 0.96)
		"locked":
			fill = Color(0.04, 0.045, 0.05, 0.42)
			border = Color(0.36, 0.40, 0.44, 0.42)
	if is_hover and state != "locked":
		fill.a = min(fill.a + 0.16, 0.86)
		border.a = 1.0
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1 if not is_hover else 2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_top = 5
	style.content_margin_right = 8
	style.content_margin_bottom = 5
	return style
