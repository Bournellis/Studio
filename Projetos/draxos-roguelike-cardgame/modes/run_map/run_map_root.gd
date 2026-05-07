extends Control

var status_label: Label
var nodes_box: VBoxContainer

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_ui()

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.name = "RunMapBackground"
	background.color = UiTokens.color("bg_deep", Color(0.045, 0.05, 0.055))
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "RunMapLayout"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 36)
	root_margin.add_theme_constant_override("margin_top", 28)
	root_margin.add_theme_constant_override("margin_right", 36)
	root_margin.add_theme_constant_override("margin_bottom", 28)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 18)
	root_margin.add_child(main_box)

	var title: Label = Label.new()
	title.name = "RunMapTitle"
	title.text = "Mapa de Missao - %s" % str(ContentLibrary.get_run_map().get("display_name", "Invasao Inicial"))
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	main_box.add_child(title)

	var content: HBoxContainer = HBoxContainer.new()
	content.name = "RunMapContent"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	main_box.add_child(content)

	var route_panel: PanelContainer = PanelContainer.new()
	route_panel.name = "RunMapRoutePanel"
	route_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	route_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel"))
	content.add_child(route_panel)

	nodes_box = VBoxContainer.new()
	nodes_box.name = "RunMapNodes"
	nodes_box.add_theme_constant_override("separation", 10)
	route_panel.add_child(nodes_box)
	_rebuild_nodes()

	var side_panel: PanelContainer = PanelContainer.new()
	side_panel.name = "RunMapStatusPanel"
	side_panel.custom_minimum_size = Vector2(330, 0)
	side_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt"))
	content.add_child(side_panel)

	var side_box: VBoxContainer = VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 14)
	side_panel.add_child(side_box)

	var side_title: Label = Label.new()
	side_title.text = "Rota Atual"
	side_title.add_theme_font_size_override("font_size", 22)
	side_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	side_box.add_child(side_title)

	status_label = Label.new()
	status_label.name = "RunMapStatus"
	status_label.text = _status_text()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_box.add_child(status_label)

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
		get_tree().change_scene_to_file("res://modes/battle/battle.tscn")
	)
	side_box.add_child(future_battle_button)

	var back_button: Button = Button.new()
	back_button.name = "RunMapBackToShipHubButton"
	back_button.text = "Voltar para Nave"
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/ship_hub/ship_hub.tscn")
	)
	side_box.add_child(back_button)

func _rebuild_nodes() -> void:
	for child: Node in nodes_box.get_children():
		child.queue_free()
	var run_map: Dictionary = ContentLibrary.get_run_map()
	for node: Dictionary in Array(run_map.get("nodes", [])):
		nodes_box.add_child(_build_node_button(node))

func _build_node_button(node: Dictionary) -> Button:
	var encounter: Dictionary = ContentLibrary.get_catalog().find_encounter(str(node.get("encounter_id", "")))
	var button: Button = Button.new()
	button.name = "RunMapNode_%s" % str(node.get("id", "unknown"))
	button.text = _node_button_text(node, encounter)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(0, 84)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = not RunSession.is_node_available(node)
	button.add_theme_stylebox_override("normal", _panel_style("bg_panel_alt"))
	button.add_theme_stylebox_override("hover", _panel_style("placeholder"))
	button.pressed.connect(func() -> void:
		_select_node(node)
	)
	return button

func _select_node(node: Dictionary) -> void:
	RunSession.select_node(str(node.get("id", "")))
	status_label.text = _status_text()
	_rebuild_nodes()

func _node_button_text(node: Dictionary, encounter: Dictionary) -> String:
	var node_id: String = str(node.get("id", ""))
	var kind: String = str(node.get("kind", ""))
	var encounter_name: String = str(encounter.get("display_name", node.get("encounter_id", "")))
	var tier: String = str(encounter.get("tier", ""))
	var reward: Dictionary = Dictionary(encounter.get("soul_reward", {}))
	var availability: String = "disponivel" if RunSession.is_node_available(node) else "bloqueado"
	if RunSession.current_node_id == node_id:
		availability = "selecionado"
	return "%s [%s]\n%s - tier %s - almas %d-%d - %s" % [
		encounter_name,
		kind,
		node_id,
		tier,
		int(reward.get("min", 0)),
		int(reward.get("max", 0)),
		availability
	]

func _status_text() -> String:
	if not RunSession.active:
		return "Nenhuma run ativa. Volte para a nave, escolha uma Classe placeholder e inicie a run."
	if RunSession.current_node_id == "":
		return "Classe: %s\n\nNenhum node selecionado. Escolha o primeiro encontro disponivel para preparar a rota." % RunSession.selected_class_display_name
	return "Classe: %s\nNode selecionado: %s\n\nA batalha ainda e placeholder; esta etapa prova selecao e navegacao do mapa." % [
		RunSession.selected_class_display_name,
		RunSession.current_node_id
	]

func _panel_style(color_token: String) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = UiTokens.color(color_token, Color(0.1, 0.11, 0.12))
	style.border_color = UiTokens.color("border_default", Color(0.25, 0.3, 0.34))
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	return style
