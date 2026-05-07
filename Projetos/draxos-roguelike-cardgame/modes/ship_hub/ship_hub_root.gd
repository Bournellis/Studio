extends Control

const REGION_SPECS: Array[Dictionary] = [
	{
		"id": "command_station",
		"title": "Comando",
		"body": "Comandante Draxos: escolha de Classe e estado da run.",
		"status": "Classes pendentes de sessao de design."
	},
	{
		"id": "grand_master_channel",
		"title": "Grande Mestre",
		"body": "Canal ancestral: ordens estrategicas para a invasao.",
		"status": "Comunicacao placeholder ativa."
	},
	{
		"id": "subordinate_station",
		"title": "Subordinados",
		"body": "Equipe da nave: ofertas podem variar por Classe.",
		"status": "NPCs fixos, ofertas futuras."
	},
	{
		"id": "mission_map_console",
		"title": "Mapa",
		"body": "Mapa de navegacao focado no planeta elemental.",
		"status": "Proximo passo: RunMap placeholder."
	},
	{
		"id": "deck_system",
		"title": "Deck",
		"body": "Preparacao de cartas, upgrades e recompensas da run.",
		"status": "Regras finais ainda pendentes."
	},
	{
		"id": "soul_engine",
		"title": "Almas",
		"body": "Moeda da nave para cura e upgrades entre missoes.",
		"status": "Economia placeholder."
	}
]

var status_label: Label

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	_build_ui()

func get_region_ids() -> Array[String]:
	var ids: Array[String] = []
	for spec: Dictionary in REGION_SPECS:
		ids.append(str(spec.get("id", "")))
	return ids

func _build_ui() -> void:
	var background: ColorRect = ColorRect.new()
	background.name = "EtherShipBackground"
	background.color = UiTokens.color("bg_deep", Color(0.045, 0.05, 0.055))
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root_margin: MarginContainer = MarginContainer.new()
	root_margin.name = "ShipHubLayout"
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 36)
	root_margin.add_theme_constant_override("margin_top", 28)
	root_margin.add_theme_constant_override("margin_right", 36)
	root_margin.add_theme_constant_override("margin_bottom", 28)
	add_child(root_margin)

	var main_box: VBoxContainer = VBoxContainer.new()
	main_box.add_theme_constant_override("separation", 20)
	root_margin.add_child(main_box)

	var header: VBoxContainer = VBoxContainer.new()
	header.name = "ShipHubHeader"
	header.add_theme_constant_override("separation", 6)
	main_box.add_child(header)

	var title: Label = Label.new()
	title.name = "ShipHubTitle"
	title.text = "Nave Draxos - Ponte de Comando"
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	header.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.name = "ShipHubSubtitle"
	subtitle.text = "Comandante Draxos em campanha no planeta elemental"
	subtitle.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	header.add_child(subtitle)

	var content: HBoxContainer = HBoxContainer.new()
	content.name = "ShipHubContent"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	main_box.add_child(content)

	var grid: GridContainer = GridContainer.new()
	grid.name = "ShipHubRegions"
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)

	for spec: Dictionary in REGION_SPECS:
		grid.add_child(_build_region_button(spec))

	var side_panel: PanelContainer = PanelContainer.new()
	side_panel.name = "ShipHubStatusPanel"
	side_panel.custom_minimum_size = Vector2(320, 0)
	side_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel"))
	content.add_child(side_panel)

	var side_box: VBoxContainer = VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 14)
	side_panel.add_child(side_box)

	var side_title: Label = Label.new()
	side_title.text = "Estado da Nave"
	side_title.add_theme_font_size_override("font_size", 22)
	side_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	side_box.add_child(side_title)

	status_label = Label.new()
	status_label.name = "ShipHubStatus"
	status_label.text = "Selecione uma regiao da nave."
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	status_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_box.add_child(status_label)

	var run_button: Button = Button.new()
	run_button.name = "ShipHubStartRunButton"
	run_button.text = "Iniciar Run Vazia"
	run_button.pressed.connect(_on_start_run_pressed)
	side_box.add_child(run_button)

	var map_button: Button = Button.new()
	map_button.name = "ShipHubOpenRunMapButton"
	map_button.text = "Abrir Mapa de Missao"
	map_button.pressed.connect(func() -> void:
		if not RunSession.active:
			RunSession.start_empty_run()
		get_tree().change_scene_to_file("res://modes/run_map/run_map.tscn")
	)
	side_box.add_child(map_button)

	var back_button: Button = Button.new()
	back_button.name = "ShipHubBackToBootButton"
	back_button.text = "Voltar ao Boot"
	back_button.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://modes/boot/boot.tscn")
	)
	side_box.add_child(back_button)

func _build_region_button(spec: Dictionary) -> Button:
	var button: Button = Button.new()
	button.name = "Region_%s" % str(spec.get("id", "unknown"))
	button.text = "%s\n%s" % [str(spec.get("title", "")), str(spec.get("body", ""))]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(210, 130)
	button.add_theme_stylebox_override("normal", _panel_style("bg_panel_alt"))
	button.add_theme_stylebox_override("hover", _panel_style("placeholder"))
	button.pressed.connect(func() -> void:
		_select_region(spec)
	)
	return button

func _select_region(spec: Dictionary) -> void:
	status_label.text = "%s\n\n%s" % [str(spec.get("body", "")), str(spec.get("status", ""))]

func _on_start_run_pressed() -> void:
	RunSession.start_empty_run()
	status_label.text = "RunSession vazia criada pela ponte de comando. Abra o mapa de missao para selecionar o primeiro node."

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
