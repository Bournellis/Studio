class_name BootHubSurfacePresenter
extends RefCounted

const HubAccountSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_account_surface_presenter.gd")
const BaseSurfacePresenterScript := preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const TouchScrollContainerScript := preload("res://modes/boot/ui/touch_scroll_container.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")

const UX_ENTRY_BACKGROUND := "res://assets/ux_overhaul/entry_necromante.png"
const UX_REFUGE_BACKGROUND := "res://assets/ux_overhaul/refuge_ship_hub.png"

static func render_entry(host: Node) -> void:
	var root := _first_screen_root(host)
	if root == null:
		return
	var compact := bool(host.get("_compact_layout"))
	root.add_child(_entry_scene_background(host, compact))
	var body := _screen_body(host, root, "EntryFirstScreenBody", compact)
	body.add_child(_entry_account_panel(host, compact))
	body.add_child(_entry_save_panel(host, compact))
	if _entry_should_show_continue():
		body.add_child(_entry_footer_panel(host, compact))
	body.add_child(_entry_dev_panel(host, compact))
	body.add_child(_entry_reset_panel(host, compact))

static func render_refuge(host: Node) -> void:
	var root := _first_screen_root(host)
	if root == null:
		return
	var compact := bool(host.get("_compact_layout"))
	_refuge_scene_board(host, root, compact)

static func _refuge_scene_board(host: Node, root: Control, compact: bool) -> void:
	var board := Control.new()
	board.name = "RefugeSceneBoard"
	board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	board.mouse_filter = Control.MOUSE_FILTER_PASS
	board.clip_contents = true
	root.add_child(board)

	board.add_child(_refuge_scene_background(host, compact))
	var safe_frame := _refuge_safe_frame(board, compact)
	_add_refuge_altar_stage(host, safe_frame, compact)
	_add_refuge_status_bar(host, safe_frame, compact)
	_add_refuge_loop_panel(host, safe_frame, compact)
	_add_refuge_footer_bar(host, safe_frame, compact)
	_add_refuge_context_cta(host, safe_frame, compact)

	var popup_data := _create_refuge_menu_popup(host, root, compact)
	var popup := popup_data["popup"] as PopupPanel
	var title_label := popup_data["title_label"] as Label
	var body := popup_data["body"] as VBoxContainer

	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "battle", "BT", "Batalha", "accent_blood", Vector2(0.50, 0.19), "Pedir batalha e ver resultado.")
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "preparation", "PP", "Preparacao", "accent_astral", Vector2(0.50, 0.32), "Revisar pocao e habilidades antes da batalha.")
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "refuge", "RF", "Refugio", "accent_astral", Vector2(0.22, 0.37), "Coleta, energia e estruturas.")
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "social", "SO", "Social", "status_success", Vector2(0.78, 0.37), "Amigos, guilda e chat.")
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "competition", "CP", "Competicao", "status_warning", Vector2(0.22, 0.56), "Fila de oponentes e ranking.")
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "shop", "LJ", "Loja", "accent_bone", Vector2(0.78, 0.56), "Recompensas e compras.")
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "collect", "CL", "Coletar", "status_success", Vector2(0.28, 0.77), "Coletar producao do Refugio.", true)
	_add_refuge_icon_button(host, safe_frame, popup, title_label, body, compact, "energy", "EN", "Energia", "accent_astral", Vector2(0.72, 0.77), "Comprar Energia.", true)
	if _refuge_has_dev_tools(host):
		_add_refuge_dev_button(host, safe_frame, popup, title_label, body, compact)
	_add_refuge_profile_button(host, safe_frame, popup, title_label, body, compact)

static func _refuge_safe_frame(board: Control, compact: bool) -> Control:
	var frame := Control.new()
	frame.name = "RefugeSafeFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	board.add_child(frame)
	var sync_frame := func() -> void:
		var viewport_size := board.get_viewport_rect().size
		if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
			viewport_size = board.size
		if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
			var parent := board.get_parent() as Control
			if parent != null and parent.size.x > 0.0 and parent.size.y > 0.0:
				viewport_size = parent.size
		if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
			viewport_size = Vector2(390, 844)
		var safe_rect := MobileUiContractScript.immersive_safe_rect(viewport_size, compact)
		frame.position = safe_rect.position
		frame.size = safe_rect.size
	sync_frame.call()
	board.resized.connect(sync_frame)
	return frame

static func _refuge_scene_background(_host: Node, _compact: bool) -> Control:
	var layer := Control.new()
	layer.name = "RefugeSceneBackground"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_add_texture_layer(layer, UX_REFUGE_BACKGROUND, 0.82)
	_add_color_layer(layer, UiTokens.color("bg_void"), 0.30)
	_add_color_layer(layer, UiTokens.color("bg_blood_wash"), 0.20)
	return layer

static func _entry_scene_background(_host: Node, _compact: bool) -> Control:
	var layer := Control.new()
	layer.name = "EntrySceneBackground"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_texture_layer(layer, UX_ENTRY_BACKGROUND, 0.64)
	_add_color_layer(layer, UiTokens.color("bg_void"), 0.62)
	_add_color_layer(layer, UiTokens.color("bg_blood_wash"), 0.18)
	return layer

static func _add_refuge_altar_stage(_host: Node, board: Control, compact: bool) -> void:
	var stage := Control.new()
	stage.name = "RefugeAltarStage"
	stage.anchor_left = 0.16
	stage.anchor_right = 0.84
	stage.anchor_top = 0.25
	stage.anchor_bottom = 0.63
	board.add_child(stage)

	var glow := PanelContainer.new()
	glow.name = "RefugeAltarGlow"
	glow.anchor_left = 0.12
	glow.anchor_right = 0.88
	glow.anchor_top = 0.12
	glow.anchor_bottom = 0.88
	glow.add_theme_stylebox_override("panel", _refuge_glow_style())
	stage.add_child(glow)

	var altar := PanelContainer.new()
	altar.name = "RefugeAltarCore"
	altar.anchor_left = 0.22
	altar.anchor_right = 0.78
	altar.anchor_top = 0.25
	altar.anchor_bottom = 0.82
	altar.add_theme_stylebox_override("panel", _refuge_altar_style())
	stage.add_child(altar)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 3 if compact else 5)
	altar.add_child(box)
	var sigil := _scene_label("ALTAR", "text_primary", 20 if compact else 24)
	sigil.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sigil)
	var subtitle := _scene_label("Refugio do Mago", "text_secondary", 11 if compact else 13)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

static func _add_refuge_status_bar(_host: Node, board: Control, compact: bool) -> void:
	var panel := PanelContainer.new()
	panel.name = "RefugeTopHud"
	panel.anchor_left = 0.04
	panel.anchor_right = 0.96
	panel.anchor_top = 0.018
	panel.anchor_bottom = 0.095 if compact else 0.088
	panel.add_theme_stylebox_override("panel", _hud_style("bg_panel", "border_default"))
	board.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)
	var title := _scene_label("Refugio", "text_primary", 17 if compact else 21)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var resources := _scene_label(_format_resources_short(SessionStore.resources), "text_secondary", 10 if compact else 12)
	resources.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resources.autowrap_mode = TextServer.AUTOWRAP_OFF
	resources.clip_text = true
	box.add_child(resources)

static func _add_refuge_footer_bar(host: Node, board: Control, compact: bool) -> void:
	var panel := PanelContainer.new()
	panel.name = "RefugeFooterPanel"
	panel.anchor_left = 0.03
	panel.anchor_right = 0.97
	panel.anchor_top = 0.83
	panel.anchor_bottom = 0.885
	panel.visible = false
	panel.add_theme_stylebox_override("panel", _hud_style("bg_panel", "border_default"))
	board.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	panel.add_child(box)
	var status := _scene_label("", "text_secondary", 9 if compact else 11)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_OFF
	status.clip_text = true
	status.visible = false
	box.add_child(status)
	_add_refuge_feedback_labels(host, panel, box, compact, status)

static func _add_refuge_context_cta(host: Node, board: Control, compact: bool) -> void:
	var cta := _refuge_context_cta_data(host)
	var button := Button.new()
	button.name = "RefugeContextCta"
	button.text = str(cta.get("text", "Batalhar"))
	button.tooltip_text = str(cta.get("detail", "Pedir a proxima batalha."))
	button.anchor_left = 0.13 if compact else 0.24
	button.anchor_right = 0.87 if compact else 0.76
	button.anchor_top = 0.905
	button.anchor_bottom = 0.972
	button.offset_left = 0
	button.offset_right = 0
	button.offset_top = 0
	button.offset_bottom = 0
	button.custom_minimum_size = Vector2(0, 58 if compact else 66)
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_font_size_override("font_size", 15 if compact else 17)
	button.add_theme_stylebox_override("normal", _hotspot_style(str(cta.get("color_token", "accent_blood")), true))
	button.add_theme_stylebox_override("hover", _hotspot_style(str(cta.get("color_token", "accent_blood")), true))
	button.add_theme_stylebox_override("pressed", _hotspot_style(str(cta.get("color_token", "accent_blood")), true))
	host.call("_prepare_touch_button", button)
	var action_id := str(cta.get("action_id", AppShellActionContractScript.ACTION_REQUEST_BATTLE))
	var confirm_message := str(cta.get("confirm", ""))
	button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id, confirm_message)
	)
	var action_buttons := host.get("_action_buttons") as Dictionary
	action_buttons[action_id] = button
	board.add_child(button)

static func _add_refuge_loop_panel(host: Node, board: Control, compact: bool) -> void:
	var state := _refuge_loop_state(host)
	var panel := PanelContainer.new()
	panel.name = "RefugeLoopPanel"
	panel.anchor_left = 0.04
	panel.anchor_right = 0.96
	panel.anchor_top = 0.635
	panel.anchor_bottom = 0.715
	panel.add_theme_stylebox_override("panel", _hud_style("bg_panel", "border_active"))
	board.add_child(panel)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6 if compact else 8)
	panel.add_child(grid)
	grid.add_child(_loop_status_label("Proximo\n%s" % str(state.get("next_text", "Batalhar")), "text_primary", compact, "RefugeLoopNextLabel"))
	grid.add_child(_loop_status_label("Coleta\n%s" % str(state.get("collect_text", "Nada agora")), str(state.get("collect_color", "text_secondary")), compact, "RefugeLoopCollectLabel"))
	grid.add_child(_loop_status_label("Evolucao\n%s" % str(state.get("upgrade_text", "Sem upgrade")), str(state.get("upgrade_color", "text_secondary")), compact, "RefugeLoopUpgradeLabel"))

static func _loop_status_label(text: String, color_token: String, compact: bool, node_name: String) -> Label:
	var label := _scene_label(text, color_token, 9 if compact else 11)
	label.name = node_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	return label

static func _add_refuge_profile_button(host: Node, board: Control, popup: PopupPanel, title_label: Label, body: VBoxContainer, compact: bool) -> void:
	var button := Button.new()
	button.name = "RefugeIcon_Perfil"
	button.text = "Perfil"
	button.tooltip_text = "Perfil e ajustes."
	button.anchor_left = 0.76 if compact else 0.82
	button.anchor_right = 0.96
	button.anchor_top = 0.105
	button.anchor_bottom = 0.158
	button.custom_minimum_size = Vector2(76, 42)
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_font_size_override("font_size", 10 if compact else 11)
	button.add_theme_stylebox_override("normal", _refuge_icon_style("border_active", false, true))
	button.add_theme_stylebox_override("hover", _refuge_icon_style("border_active", true, true))
	button.add_theme_stylebox_override("pressed", _refuge_icon_style("border_active", true, true))
	host.call("_prepare_touch_button", button)
	button.pressed.connect(func() -> void:
		_open_refuge_menu_popup(host, popup, title_label, body, "profile", compact)
	)
	board.add_child(button)

static func _add_refuge_dev_button(host: Node, board: Control, popup: PopupPanel, title_label: Label, body: VBoxContainer, compact: bool) -> void:
	var button := Button.new()
	button.name = "RefugeIcon_LabsDev"
	button.text = "Labs\nDev"
	button.tooltip_text = "Ferramentas internas de desenvolvimento."
	button.anchor_left = 0.04
	button.anchor_right = 0.24 if compact else 0.18
	button.anchor_top = 0.105
	button.anchor_bottom = 0.158
	button.custom_minimum_size = Vector2(76, 42)
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_font_size_override("font_size", 10 if compact else 11)
	button.add_theme_stylebox_override("normal", _refuge_icon_style("accent_astral", false, true))
	button.add_theme_stylebox_override("hover", _refuge_icon_style("accent_astral", true, true))
	button.add_theme_stylebox_override("pressed", _refuge_icon_style("accent_astral", true, true))
	host.call("_prepare_touch_button", button)
	button.pressed.connect(func() -> void:
		_open_refuge_menu_popup(host, popup, title_label, body, "dev", compact)
	)
	board.add_child(button)

static func _add_refuge_icon_button(host: Node, board: Control, popup: PopupPanel, title_label: Label, body: VBoxContainer, compact: bool, menu_id: String, symbol: String, title: String, color_token: String, anchor: Vector2, detail: String, quick: bool = false) -> void:
	var button := Button.new()
	button.name = "RefugeIcon_%s" % title
	button.text = "%s\n%s" % [symbol, title]
	button.tooltip_text = detail
	button.anchor_left = anchor.x
	button.anchor_right = anchor.x
	button.anchor_top = anchor.y
	button.anchor_bottom = anchor.y
	var icon_size := Vector2(74, 58) if quick else Vector2(92, 82)
	if not compact:
		icon_size = Vector2(90, 64) if quick else Vector2(108, 94)
	button.offset_left = -icon_size.x * 0.5
	button.offset_right = icon_size.x * 0.5
	button.offset_top = -icon_size.y * 0.5
	button.offset_bottom = icon_size.y * 0.5
	button.custom_minimum_size = icon_size
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_font_size_override("font_size", 11 if compact else 12)
	button.add_theme_stylebox_override("normal", _refuge_icon_style(color_token, false, quick))
	button.add_theme_stylebox_override("hover", _refuge_icon_style(color_token, true, quick))
	button.add_theme_stylebox_override("pressed", _refuge_icon_style(color_token, true, quick))
	_apply_optional_icon_texture(button, _asset_id_for_menu(menu_id))
	host.call("_prepare_touch_button", button)
	button.pressed.connect(func() -> void:
		_open_refuge_menu_popup(host, popup, title_label, body, menu_id, compact)
	)
	board.add_child(button)

static func _create_refuge_menu_popup(host: Node, root: Control, compact: bool) -> Dictionary:
	var popup := PopupPanel.new()
	popup.name = "RefugeMenuPopup"
	root.add_child(popup)
	host.set("_refuge_menu_popup", popup)

	var margin := MarginContainer.new()
	var edge := 10 if compact else 14
	margin.add_theme_constant_override("margin_left", edge)
	margin.add_theme_constant_override("margin_top", edge)
	margin.add_theme_constant_override("margin_right", edge)
	margin.add_theme_constant_override("margin_bottom", edge)
	popup.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8 if compact else 10)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var title_label := _scene_label("Menu", "text_primary", 18 if compact else 21)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	var close_button := Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(52, 44)
	host.call("_prepare_touch_button", close_button)
	close_button.pressed.connect(func() -> void:
		popup.hide()
	)
	header.add_child(close_button)

	var scroll := TouchScrollContainerScript.new()
	scroll.name = "RefugeMenuScroll"
	scroll.configure_subtle_scrollbar()
	scroll.custom_minimum_size = Vector2(0, 420 if compact else 500)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)

	var body := VBoxContainer.new()
	body.name = "RefugeMenuBody"
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8 if compact else 10)
	scroll.add_child(body)
	return {
		"popup": popup,
		"title_label": title_label,
		"body": body,
	}

static func _open_refuge_menu_popup(host: Node, popup: PopupPanel, title_label: Label, body: VBoxContainer, menu_id: String, compact: bool) -> void:
	if popup == null or body == null or title_label == null:
		return
	_clear_node_children(body)
	title_label.text = _menu_title(menu_id)
	_populate_refuge_menu(host, popup, body, menu_id, compact)
	var viewport_size := _host_viewport_size(host)
	var popup_width := clampi(int(viewport_size.x - 28.0), 300, 412)
	var popup_height := clampi(int(viewport_size.y - 88.0), 360, 620)
	popup.popup_centered(Vector2i(popup_width, popup_height))

static func _populate_refuge_menu(host: Node, popup: PopupPanel, body: VBoxContainer, menu_id: String, compact: bool) -> void:
	match menu_id:
		"battle":
			body.add_child(_popup_hint("Pedir batalha, rever resultado ou abrir historico.", compact))
			body.add_child(_popup_action_button(host, popup, "Pedir batalha", AppShellActionContractScript.ACTION_REQUEST_BATTLE, "", true))
			body.add_child(_popup_action_button(host, popup, "Historico", AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY))
			body.add_child(_popup_action_button(host, popup, "Ver resultado", AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE))
		"preparation":
			body.add_child(_popup_hint("Revise o que Draxos leva para a proxima batalha.", compact))
			if SessionStore.combat_build_state.is_empty():
				body.add_child(_popup_action_button(host, popup, "Atualizar preparacao", AppShellActionContractScript.ACTION_SHOW_PREPARATION, "", true))
			else:
				body.add_child(_preparation_panel(host, compact))
		"refuge":
			body.add_child(_popup_hint("Coleta, energia, estruturas e upgrades do Refugio.", compact))
			BaseSurfacePresenterScript.render_refuge_embedded(host, body)
		"social":
			body.add_child(_popup_hint("Amigos, guilda e chat em um painel leve.", compact))
			body.add_child(_popup_action_button(host, popup, "Abrir Social", AppShellActionContractScript.ACTION_SHOW_SOCIAL, "", true))
		"competition":
			body.add_child(_popup_hint("Fila de oponentes, arena e ranking.", compact))
			body.add_child(_popup_action_button(host, popup, "Matchmaking", AppShellActionContractScript.ACTION_SHOW_MATCHMAKING, "", true))
			body.add_child(_popup_action_button(host, popup, "Ranking", AppShellActionContractScript.ACTION_SHOW_RANKING))
		"shop":
			body.add_child(_popup_hint("Recompensas, resgates e compras.", compact))
			body.add_child(_popup_action_button(host, popup, "Abrir Loja", AppShellActionContractScript.ACTION_SHOW_SHOP, "", true))
			body.add_child(_popup_action_button(host, popup, "Recompensa diaria", AppShellActionContractScript.ACTION_CLAIM_DAILY_REWARD))
		"profile":
			body.add_child(_popup_hint(_short_account_status(), compact))
			body.add_child(_popup_route_button(host, popup, "Abrir Perfil", "account", true))
			_add_dev_tool_actions(host, popup, body)
			body.add_child(_popup_action_button(host, popup, "Checar atualizacao", AppShellActionContractScript.ACTION_CHECK_UPDATE))
		"dev":
			body.add_child(_popup_hint("Ferramentas internas para validar batalha e progressao do prototipo.", compact))
			_add_dev_tool_actions(host, popup, body, true)
		"collect":
			body.add_child(_popup_hint("Receber a producao acumulada do Refugio.", compact))
			body.add_child(_popup_action_button(host, popup, "Coletar agora", AppShellActionContractScript.ACTION_COLLECT_BASE, "", true))
		"energy":
			body.add_child(_popup_hint("Comprar pacote de Energia no save ativo.", compact))
			body.add_child(_popup_action_button(host, popup, "Comprar Energia", AppShellActionContractScript.ACTION_BUY_ENERGY_PACK_ALPHA, "Gastar 80 Diamantes para comprar 80 Energia no save ativo?", true))
		_:
			body.add_child(_popup_hint("Menu indisponivel.", compact))

static func _popup_action_button(host: Node, popup: PopupPanel, text: String, action_id: String, confirm_message: String = "", primary: bool = false) -> Button:
	var button := _drawer_button(host, text, primary, action_id, "refuge")
	button.pressed.connect(func() -> void:
		popup.hide()
		host.call("_trigger_action", action_id, confirm_message)
	)
	var action_buttons := host.get("_action_buttons") as Dictionary
	action_buttons[action_id] = button
	return button

static func _popup_route_button(host: Node, popup: PopupPanel, text: String, route_id: String, primary: bool = false) -> Button:
	var target_route := str(host.call("_normalize_route", route_id))
	var button := _drawer_button(host, text, primary, "screen:%s" % target_route, target_route)
	button.pressed.connect(func() -> void:
		popup.hide()
		host.call("_show_screen", target_route)
	)
	return button

static func _drawer_button(host: Node, text: String, primary: bool, action_id: String = "", surface_id: String = "refuge") -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.custom_minimum_size = Vector2(0, 58 if primary else 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.call("_prepare_touch_button", button)
	host.call("_apply_action_button_style", button, action_id, surface_id)
	return button

static func _popup_hint(text: String, compact: bool) -> Label:
	return _body_label(text, compact)

static func _menu_title(menu_id: String) -> String:
	match menu_id:
		"battle":
			return "Batalha"
		"preparation":
			return "Preparacao"
		"refuge":
			return "Refugio"
		"social":
			return "Social"
		"competition":
			return "Competicao"
		"shop":
			return "Loja"
		"profile":
			return "Perfil"
		"dev":
			return "Labs Dev"
		"collect":
			return "Coletar"
		"energy":
			return "Energia"
	return "Menu"

static func _refuge_has_dev_tools(host: Node) -> bool:
	return bool(host.call("_battle_lab_available")) or bool(host.call("_progression_lab_available"))

static func _add_dev_tool_actions(host: Node, popup: PopupPanel, body: VBoxContainer, primary: bool = false) -> void:
	if bool(host.call("_battle_lab_available")):
		body.add_child(_popup_action_button(host, popup, "Battle Lab", AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB, "", primary))
	if bool(host.call("_progression_lab_available")):
		body.add_child(_popup_action_button(host, popup, "Progression Lab", AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB, "", primary))

static func _add_texture_layer(parent: Control, texture_path: String, alpha: float) -> void:
	if parent == null or not ResourceLoader.exists(texture_path):
		return
	var loaded_texture := load(texture_path)
	if not loaded_texture is Texture2D:
		return
	var art := TextureRect.new()
	art.texture = loaded_texture as Texture2D
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	art.modulate = Color(1, 1, 1, alpha)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(art)

static func _add_color_layer(parent: Control, color: Color, alpha: float) -> void:
	if parent == null:
		return
	var layer := ColorRect.new()
	layer.color = color
	layer.color.a = alpha
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(layer)

static func _scene_label(text: String, color_token: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	label.add_theme_font_size_override("font_size", font_size)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _refuge_scene_style(_host: Node, _compact: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_deep").lerp(UiTokens.color("accent_astral"), 0.08)
	style.border_color = UiTokens.color("border_default")
	style.set_border_width_all(1)
	style.set_corner_radius_all(0)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style

static func _refuge_glow_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("accent_astral").lerp(Color.TRANSPARENT, 0.58)
	style.border_color = UiTokens.color("border_active")
	style.set_border_width_all(2)
	style.set_corner_radius_all(120)
	return style

static func _refuge_altar_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel_alt").lerp(UiTokens.color("accent_astral"), 0.16)
	style.border_color = UiTokens.color("accent_astral")
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func _hud_style(bg_token: String, border_token: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var resolved_border := UiTokens.surface_accent_token("refuge", border_token) if border_token == "border_default" else border_token
	style.bg_color = UiTokens.color(bg_token).lerp(UiTokens.color(resolved_border), 0.06).lerp(Color.TRANSPARENT, 0.12)
	style.border_color = UiTokens.color(resolved_border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style

static func _refuge_icon_style(color_token: String, active: bool, quick: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel").lerp(UiTokens.color(color_token), 0.28 if active else 0.16)
	style.border_color = UiTokens.color(color_token)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14 if quick else 18)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

static func _asset_id_for_menu(menu_id: String) -> String:
	match menu_id:
		"battle":
			return "icon_battle"
		"profile":
			return "icon_guest"
		"shop":
			return "battle_icon_reward"
	return ""

static func _apply_optional_icon_texture(_button: Button, _asset_id: String) -> void:
	pass

static func _format_resources_short(resources: Dictionary) -> String:
	if resources.is_empty():
		return "Sem recursos carregados"
	return "Almas %s | Energia %s | Ossos %s | Po %s" % [
		_format_resource_amount(resources.get("almas", 0)),
		_format_resource_amount(resources.get("energia", 0)),
		_format_resource_amount(resources.get("ossos", 0)),
		_format_resource_amount(resources.get("po_osso", 0)),
	]

static func _format_resource_amount(amount: Variant) -> String:
	if amount is int:
		return str(amount)
	if amount is float:
		var numeric_amount := float(amount)
		if is_equal_approx(numeric_amount, roundf(numeric_amount)):
			return str(int(roundf(numeric_amount)))
		return "%.1f" % numeric_amount
	return str(amount)

static func _refuge_context_cta_data(host: Node) -> Dictionary:
	if SessionStore.has_unseen_battle_result():
		return {
			"text": "Ver recompensa",
			"detail": "Abrir o resultado e receber a recompensa da batalha mais recente.",
			"action_id": AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE,
			"color_token": "accent_blood",
		}
	var base := SessionStore.base_state
	if not base.is_empty():
		var routine := BaseSurfacePresenterScript.routine_summary(base)
		if bool(routine.get("has_collect_ready", false)):
			return {
				"text": "Coletar",
				"detail": "Receber a producao acumulada do Refugio.",
				"action_id": AppShellActionContractScript.ACTION_COLLECT_BASE,
				"color_token": "status_success",
			}
		if bool(routine.get("next_upgrade_ready", false)):
			var structure_id := str(routine.get("next_upgrade_id", ""))
			if structure_id != "":
				return {
					"text": "Evoluir",
					"detail": str(routine.get("next_upgrade_text", "Iniciar evolucao pronta.")),
					"action_id": AppShellActionContractScript.upgrade_base_structure_action(structure_id),
					"confirm": "Iniciar evolucao no Refugio?",
					"color_token": "accent_astral",
				}
	return {
		"text": "Batalhar",
		"detail": "Pedir a proxima batalha.",
		"action_id": AppShellActionContractScript.ACTION_REQUEST_BATTLE,
		"color_token": "accent_blood",
	}

static func _refuge_loop_state(host: Node) -> Dictionary:
	var cta := _refuge_context_cta_data(host)
	var collect_text := "Sincronizar"
	var collect_color := "text_secondary"
	var upgrade_text := "Sem dados"
	var upgrade_color := "text_secondary"
	var base := SessionStore.base_state
	if not base.is_empty():
		var routine := BaseSurfacePresenterScript.routine_summary(base)
		collect_text = "Pronta" if bool(routine.get("has_collect_ready", false)) else "Nada agora"
		collect_color = "status_success" if bool(routine.get("has_collect_ready", false)) else "text_secondary"
		if bool(routine.get("next_upgrade_ready", false)):
			upgrade_text = _short_loop_text(str(routine.get("next_upgrade_text", "Pronta")))
			upgrade_color = "status_success"
		else:
			upgrade_text = "Sem upgrade"
	return {
		"next_text": str(cta.get("text", "Batalhar")),
		"collect_text": collect_text,
		"collect_color": collect_color,
		"upgrade_text": upgrade_text,
		"upgrade_color": upgrade_color,
	}

static func _short_loop_text(text: String) -> String:
	var shortened := text.strip_edges()
	var separator_index := shortened.find(" | ")
	if separator_index >= 0:
		shortened = shortened.substr(0, separator_index).strip_edges()
	if shortened.length() > 22:
		shortened = "%s..." % shortened.substr(0, 19)
	return shortened

static func _host_viewport_size(host: Node) -> Vector2:
	var first_root := _first_screen_root(host)
	if first_root != null and first_root.size.x > 0 and first_root.size.y > 0:
		return first_root.size
	if host is Control:
		var host_size := (host as Control).size
		if host_size.x > 0 and host_size.y > 0:
			return host_size
	if host != null and host.get_viewport() != null:
		var viewport_size := host.get_viewport().get_visible_rect().size
		if viewport_size.x > 0 and viewport_size.y > 0:
			return viewport_size
	if host != null and host.get_tree() != null and host.get_tree().root != null:
		var window_size := host.get_tree().root.size
		if window_size.x > 0 and window_size.y > 0:
			return Vector2(window_size)
	return Vector2(390, 844)

static func _clear_node_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

static func _screen_body(_host: Node, root: Control, body_name: String, compact: bool) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.name = "%sFrame" % body_name
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	var edge := 10 if compact else 16
	margin.add_theme_constant_override("margin_left", edge)
	margin.add_theme_constant_override("margin_top", edge)
	margin.add_theme_constant_override("margin_right", edge)
	margin.add_theme_constant_override("margin_bottom", edge)
	root.add_child(margin)

	var scroll := TouchScrollContainerScript.new()
	scroll.name = "%sScroll" % body_name
	scroll.configure_subtle_scrollbar()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(scroll)

	var body := VBoxContainer.new()
	body.name = body_name
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 10 if compact else 14)
	scroll.add_child(body)
	return body

static func _entry_account_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntryAccountPanel", "bg_panel_alt", "border_default")
	var box := _panel_box(panel, compact)
	var title := _title_label("DraxosMobile", 24 if compact else 30)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	box.add_child(title)
	box.add_child(_body_label("Entre e siga direto para o Refugio.", compact))
	box.add_child(_section_label("Entrar", compact))
	host.set("_auth_email_input", _entry_input(box, "Email", "tester@exemplo.com", SessionStore.auth_email, false, compact))
	host.set("_auth_password_input", _entry_input(box, "Senha", "Senha da conta", "", true, compact))
	host.set("_auth_username_input", null)
	host.set("_auth_invite_input", null)
	box.add_child(_entry_action_button(host, "Entrar", AppShellActionContractScript.ACTION_EMAIL_SIGN_IN, compact, "", true))
	box.add_child(_entry_action_button(host, "Criar conta", AppShellActionContractScript.ACTION_OPEN_CREATE_ACCOUNT, compact))
	_add_feedback_labels(host, box, compact)
	return panel

static func _entry_save_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntrySavePanel", "bg_panel", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Escolha seu save", compact))
	box.add_child(_body_label("Normal e o caminho principal. Lab fica separado.", compact))
	var grid := _button_grid(compact, 2)
	box.add_child(grid)
	grid.add_child(_entry_action_button(host, "Normal", AppShellActionContractScript.ACTION_SELECT_SAVE_NORMAL, compact, "", true))
	grid.add_child(_entry_action_button(host, "Lab", AppShellActionContractScript.ACTION_SELECT_SAVE_PROGRESSION_LAB, compact))
	box.add_child(_body_label("Save atual: %s" % SessionStore.active_save_label(), compact))
	return panel

static func _entry_dev_panel(host: Node, compact: bool) -> PanelContainer:
	var battle_lab := bool(host.call("_battle_lab_available"))
	var progression_lab := bool(host.call("_progression_lab_available"))
	var dev_tools_visible := battle_lab or progression_lab or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/dev_tools_enabled", false))
	var panel := _panel(host, "EntryDevPanel", "bg_panel_alt", "border_default")
	var box := _panel_box(panel, compact)
	var toggle := CheckButton.new()
	toggle.text = "Ferramentas internas"
	toggle.tooltip_text = "Mostrar guest e ferramentas de validacao."
	toggle.button_pressed = dev_tools_visible
	toggle.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	host.call("_prepare_touch_button", toggle)
	box.add_child(toggle)

	var dev_body := VBoxContainer.new()
	dev_body.visible = dev_tools_visible
	dev_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dev_body.add_theme_constant_override("separation", 8 if compact else 10)
	box.add_child(dev_body)
	toggle.toggled.connect(func(pressed: bool) -> void:
		dev_body.visible = pressed
	)

	dev_body.add_child(_section_label("Labs Dev", compact))
	dev_body.add_child(_body_label("Use estas opcoes apenas para entrar como guest ou validar fluxo interno.", compact))
	var grid := _button_grid(compact, 2)
	dev_body.add_child(grid)
	grid.add_child(_entry_action_button(host, "Guest", AppShellActionContractScript.ACTION_ENTER_GUEST, compact))
	if battle_lab:
		grid.add_child(_entry_action_button(host, "Battle Lab", AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB, compact))
	if progression_lab:
		grid.add_child(_entry_action_button(host, "Progression Lab", AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB, compact))
	return panel

static func _entry_reset_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntryResetPanel", "bg_blood_wash", "border_blood")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Area de risco", compact))
	box.add_child(_body_label("Use somente quando precisar limpar esta maquina ou recomecar o save ativo.", compact))
	var grid := _button_grid(compact, 2)
	box.add_child(grid)
	grid.add_child(_entry_action_button(host, "Reset local", AppShellActionContractScript.ACTION_RESET_SESSION, compact, "Limpar apenas os dados locais desta maquina? O save da conta nao sera apagado."))
	grid.add_child(_entry_action_button(host, "Sincronizar", AppShellActionContractScript.ACTION_REFRESH_SESSION, compact))
	grid.add_child(_entry_action_button(
		host,
		"Reset save",
		AppShellActionContractScript.ACTION_RESET_ACTIVE_SAVE,
		compact,
		"Resetar apenas o save %s? O outro save e a sessao local serao preservados." % SessionStore.active_save_label()
	))
	return panel

static func _entry_footer_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntryFooterPanel", "bg_panel", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_entry_action_button(host, "Continuar", AppShellActionContractScript.ACTION_ENTER_REFUGE, compact, "", true))
	return panel

static func _entry_should_show_continue() -> bool:
	return SessionStore.has_valid_access_token() or (SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state())

static func _refuge_hotspot_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "RefugeHotspotPanel", "bg_panel_alt", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Caminhos do Refugio", compact))
	var grid := _button_grid(compact, 1 if compact else 2)
	grid.name = "RefugePathGrid"
	box.add_child(grid)
	_add_route_hotspot(host, grid, compact, "Batalha", "battle_entry", "Pedir batalha e ver replay.", "accent_blood")
	_add_action_hotspot(host, grid, compact, "Preparacao", AppShellActionContractScript.ACTION_SHOW_PREPARATION, "Pocao e habilidades antes da batalha.", "accent_astral")
	_add_action_hotspot(host, grid, compact, "Social", AppShellActionContractScript.ACTION_SHOW_SOCIAL, "Amigos, guilda e chat.", "status_success")
	_add_action_hotspot(host, grid, compact, "Competicao", AppShellActionContractScript.ACTION_SHOW_MATCHMAKING, "Fila de oponentes e ranking.", "status_warning")
	_add_action_hotspot(host, grid, compact, "Loja", AppShellActionContractScript.ACTION_SHOW_SHOP, "Resgates, recompensas e compras.", "accent_bone")
	_add_route_hotspot(host, grid, compact, "Perfil", "account", "Conta, updates e detalhes do save.", "border_active")
	if not SessionStore.combat_build_state.is_empty():
		box.add_child(_preparation_panel(host, compact))
	BaseSurfacePresenterScript.render_refuge_embedded(host, box)
	return panel

static func _preparation_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "PreparationPanel", "bg_panel", "border_active")
	var box := _panel_box(panel, compact)
	var combat_build := SessionStore.combat_build_state
	var account_build := SessionStore.build
	var options := _as_dictionary(combat_build.get("equipment_options", {}))
	var inventory := _as_array(combat_build.get("inventory", []))
	var potion_slots := _as_array(combat_build.get("potion_slots", []))
	var spell_slots := _preparation_spell_slots(combat_build)

	box.add_child(_section_label("Pronto para batalha", compact))
	box.add_child(_body_label("Escolha o que Draxos leva para a proxima luta.", compact))
	var level_text := _preparation_account_power_text(combat_build)
	if level_text != "":
		box.add_child(_body_label(level_text, compact))

	var instrument_id := _first_non_empty_string(combat_build, ["weapon_type", "weapon_id", "instrument_id", "ritual_instrument_id"])
	if instrument_id == "":
		instrument_id = _first_non_empty_string(account_build, ["weapon_type", "weapon_id", "instrument_id", "ritual_instrument_id"])
	var familiar_id := _first_non_empty_string(combat_build, ["pet_id", "familiar_id"])
	if familiar_id == "":
		familiar_id = _first_non_empty_string(account_build, ["pet_id", "familiar_id"])
	var doctrine_id := _first_non_empty_string(combat_build, ["passive_id", "doctrine_id", "doutrina_id"])
	if doctrine_id == "":
		doctrine_id = _first_non_empty_string(account_build, ["passive_id", "doctrine_id", "doutrina_id"])

	box.add_child(_body_label("Resumo: %s | %s | %s | %s" % [
		_preparation_item_label(instrument_id),
		_preparation_spell_summary(spell_slots),
		_preparation_item_label(doctrine_id) if doctrine_id != "" else "Sem Doutrina",
		_preparation_item_label(familiar_id) if familiar_id != "" else "Sem Familiar",
	], compact))
	var cta_grid := _button_grid(compact, 1)
	box.add_child(cta_grid)
	cta_grid.add_child(_entry_action_button(host, "Pedir batalha", AppShellActionContractScript.ACTION_REQUEST_BATTLE, compact, "", true))

	box.add_child(_section_label("Instrumento Ritual", compact))
	if instrument_id != "":
		box.add_child(_body_label("Em uso: %s%s" % [
			_preparation_item_label(instrument_id),
			_preparation_level_suffix_with_fallback(combat_build, account_build, ["weapon_level", "instrument_level"]),
		], compact))
	_render_preparation_options(
		host,
		box,
		compact,
		_as_array(options.get("weapons", [])),
		instrument_id,
		"instrument",
		false
	)

	box.add_child(_section_label("Habilidades", compact))
	if spell_slots.is_empty():
		box.add_child(_body_label("Nenhuma habilidade equipada.", compact))
	else:
		for slot: Dictionary in spell_slots:
			var position := int(slot.get("slot_index", 1))
			var spell_id := str(slot.get("spell_id", "")).strip_edges()
			var unlocked := bool(slot.get("unlocked", true))
			if not unlocked:
				box.add_child(_body_label("Habilidade %d: desbloqueia no nivel %d." % [position, int(slot.get("unlock_level", 1))], compact))
				continue
			if spell_id == "" or spell_id == "<null>" or spell_id.to_lower() == "null":
				box.add_child(_body_label("Habilidade %d: vazia." % position, compact))
				continue
			box.add_child(_body_label("Habilidade %d: %s | %s" % [
				position,
				_preparation_item_label(spell_id),
				_spell_timing_text(_as_dictionary(slot.get("behavior", {}))),
			], compact))
			var remove_spell_actions := _button_grid(compact, 2)
			box.add_child(remove_spell_actions)
			remove_spell_actions.add_child(_entry_action_button(host, "Usar na batalha", AppShellActionContractScript.enable_spell_behavior_action(spell_id), compact))
			remove_spell_actions.add_child(_entry_action_button(host, "Pausar", AppShellActionContractScript.disable_spell_behavior_action(spell_id), compact))
			remove_spell_actions.add_child(_entry_action_button(host, "Remover", AppShellActionContractScript.remove_spell_position_action(position), compact))
	_render_spell_options(host, box, compact, _as_array(options.get("spells", [])), spell_slots)

	box.add_child(_section_label("Doutrina", compact))
	var doctrine_text := _preparation_item_label(doctrine_id) if doctrine_id != "" else "Nenhuma Doutrina equipada"
	if doctrine_id != "":
		doctrine_text += _preparation_level_suffix_with_fallback(combat_build, account_build, ["passive_level", "doctrine_level", "doutrina_level"])
	box.add_child(_body_label("Em uso: %s" % doctrine_text, compact))
	_render_preparation_options(
		host,
		box,
		compact,
		_as_array(options.get("doutrines", [])),
		doctrine_id,
		"doctrine",
		true,
		AppShellActionContractScript.remove_doctrine_action()
	)

	box.add_child(_section_label("Familiar", compact))
	var familiar_text := _preparation_item_label(familiar_id) if familiar_id != "" else "Nenhum Familiar equipado"
	if familiar_id != "":
		familiar_text += _preparation_level_suffix_with_fallback(combat_build, account_build, ["pet_level", "familiar_level"])
	box.add_child(_body_label("Em uso: %s" % familiar_text, compact))
	_render_preparation_options(
		host,
		box,
		compact,
		_as_array(options.get("familiars", [])),
		familiar_id,
		"familiar",
		true,
		AppShellActionContractScript.remove_familiar_action()
	)

	var stock := _inventory_quantity(inventory, AppShellActionContractScript.ITEM_HEALTH_POTION)
	var potion_slot := _first_dictionary(potion_slots)
	var potion_id := str(potion_slot.get("potion_id", ""))
	var potion_behavior := _as_dictionary(potion_slot.get("behavior", {}))
	box.add_child(_section_label("Pocao", compact))
	box.add_child(_body_label(_potion_status_text(potion_id), compact))
	box.add_child(_body_label("Estoque: %d" % stock, compact))
	var potion_timing_text := _potion_timing_text(potion_id, potion_behavior)
	if potion_timing_text != "":
		box.add_child(_body_label(potion_timing_text, compact))

	var potion_actions := _button_grid(compact, 2)
	box.add_child(potion_actions)
	potion_actions.add_child(_entry_action_button(host, "Equipar Pocao de Vida", AppShellActionContractScript.ACTION_EQUIP_HEALTH_POTION, compact))
	potion_actions.add_child(_entry_action_button(host, "Remover pocao", AppShellActionContractScript.ACTION_UNEQUIP_POTION, compact))
	potion_actions.add_child(_entry_action_button(host, "Usar com vida baixa", AppShellActionContractScript.ACTION_ENABLE_POTION_DEFAULT, compact))
	potion_actions.add_child(_entry_action_button(host, "Pausar pocao", AppShellActionContractScript.ACTION_DISABLE_POTION, compact))
	return panel

static func _refuge_footer_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "RefugeFooterPanel", "bg_panel", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_body_label("Recursos: %s" % _format_resources(SessionStore.resources), compact))
	box.add_child(_body_label(_short_account_status(), compact))
	_add_feedback_labels(host, box, compact)
	return panel

static func _entry_input(parent: VBoxContainer, label_text: String, placeholder: String, initial_text: String, secret: bool, compact: bool) -> LineEdit:
	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	parent.add_child(label)
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.text = initial_text
	input.secret = secret
	input.custom_minimum_size = MobileUiContractScript.input_min_size(compact)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(input)
	return input

static func _entry_action_button(host: Node, text: String, action_id: String, _compact: bool, confirm_message: String = "", primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.custom_minimum_size = Vector2(0, 58 if primary else 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	host.call("_prepare_touch_button", button)
	host.call("_apply_action_button_style", button, action_id, "entry")
	button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id, confirm_message)
	)
	var action_buttons := host.get("_action_buttons") as Dictionary
	action_buttons[action_id] = button
	return button

static func _add_route_hotspot(host: Node, grid: GridContainer, compact: bool, title: String, route_id: String, detail: String, color_token: String) -> void:
	var button := _hotspot_button(host, compact, title, detail, color_token)
	var target_route := str(host.call("_normalize_route", route_id))
	button.pressed.connect(func() -> void:
		host.call("_show_screen", target_route)
	)
	grid.add_child(button)

static func _add_action_hotspot(host: Node, grid: GridContainer, compact: bool, title: String, action_id: String, detail: String, color_token: String) -> void:
	var button := _hotspot_button(host, compact, title, detail, color_token)
	button.pressed.connect(func() -> void:
		host.call("_trigger_action", action_id)
	)
	var action_buttons := host.get("_action_buttons") as Dictionary
	action_buttons[action_id] = button
	grid.add_child(button)

static func _hotspot_button(host: Node, compact: bool, title: String, detail: String, color_token: String) -> Button:
	var button := Button.new()
	button.text = title
	button.tooltip_text = detail
	button.custom_minimum_size = Vector2(0, 72 if compact else 82)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_stylebox_override("normal", _hotspot_style(color_token, false))
	button.add_theme_stylebox_override("hover", _hotspot_style(color_token, true))
	button.add_theme_stylebox_override("pressed", _hotspot_style(color_token, true))
	host.call("_prepare_touch_button", button)
	return button

static func _button_grid(compact: bool, columns: int = 1) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = maxi(1, columns)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8 if compact else 10)
	grid.add_theme_constant_override("v_separation", 8 if compact else 10)
	return grid

static func _panel(host: Node, name: String, bg_token: String, border_token: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = name
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _panel_style(host, bg_token, border_token))
	return panel

static func _panel_box(panel: PanelContainer, compact: bool) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 7 if compact else 10)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(box)
	return box

static func _title_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _subtitle_label(title: String, text: String) -> Label:
	var label := _body_label("%s: %s" % [title, text], false)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label

static func _section_label(text: String, compact: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 17 if compact else 19)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _body_label(text: String, compact: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12 if compact else 14)
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _add_feedback_labels(host: Node, box: VBoxContainer, compact: bool) -> void:
	var status := _body_label("", compact)
	status.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	var detail := _body_label("", compact)
	var error := _body_label("", compact)
	error.add_theme_color_override("font_color", UiTokens.color("status_error"))
	status.visible = false
	detail.visible = false
	error.visible = false
	box.add_child(status)
	box.add_child(detail)
	box.add_child(error)
	host.set("_immersive_status_label", status)
	host.set("_immersive_detail_label", detail)
	host.set("_immersive_error_label", error)
	if host.has_method("_sync_immersive_feedback"):
		host.call("_sync_immersive_feedback")

static func _add_refuge_feedback_labels(host: Node, panel: Control, box: VBoxContainer, compact: bool, status: Label) -> void:
	var detail := _scene_label("", "text_secondary", 9 if compact else 10)
	detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail.autowrap_mode = TextServer.AUTOWRAP_OFF
	detail.clip_text = true
	detail.visible = false
	box.add_child(detail)
	var error := _scene_label("", "status_error", 9 if compact else 10)
	error.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	error.autowrap_mode = TextServer.AUTOWRAP_OFF
	error.clip_text = true
	error.visible = false
	box.add_child(error)
	host.set("_immersive_feedback_panel", panel)
	host.set("_immersive_status_label", status)
	host.set("_immersive_detail_label", detail)
	host.set("_immersive_error_label", error)
	if host.has_method("_sync_immersive_feedback"):
		host.call("_sync_immersive_feedback")

static func _entry_status_text(host: Node) -> String:
	var update_gate := {}
	var update_value: Variant = host.get("_update_gate")
	if update_value is Dictionary:
		update_gate = Dictionary(update_value)
	var auth_text := "sem sessao"
	if SessionStore.is_progression_lab_local_only():
		auth_text = "lab local"
	elif SessionStore.has_valid_access_token():
		auth_text = SessionStore.auth_method
	var update_text := str(update_gate.get("summary", "update nao checado"))
	return "Save: %s | Auth: %s | %s" % [
		SessionStore.active_save_label(),
		auth_text,
		update_text,
	]

static func _short_account_status() -> String:
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		return "Lab local: %s" % SessionStore.progression_lab_label()
	if SessionStore.has_account_state():
		return "%s | Nivel %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
		]
	if SessionStore.has_valid_access_token():
		return "Sessao auth pronta; sincronize o save se necessario."
	return "Sem sessao. Volte para Entrada para login ou guest dev."

static func _format_resources(resources: Dictionary) -> String:
	if resources.is_empty():
		return "sem recursos carregados"
	var parts: PackedStringArray = PackedStringArray()
	for key in ["almas", "energia", "sangue", "cristais", "ossos", "po_osso", "diamante"]:
		parts.append("%s %s" % [_resource_label(key), str(resources.get(key, 0))])
	return " | ".join(parts)

static func _resource_label(key: String) -> String:
	match key:
		"po_osso":
			return "Po de Osso"
		"almas":
			return "Almas"
		"energia":
			return "Energia"
		"sangue":
			return "Sangue"
		"cristais":
			return "Cristais"
		"ossos":
			return "Ossos"
		"diamante":
			return "Diamante"
		_:
			return key.capitalize()

static func _potion_status_text(potion_id: String) -> String:
	var cleaned := potion_id.strip_edges()
	if cleaned == AppShellActionContractScript.ITEM_HEALTH_POTION:
		return "Pocao de Vida equipada"
	if cleaned == "" or cleaned == "<null>" or cleaned.to_lower() == "null":
		return "Nenhuma pocao equipada"
	return "%s equipada" % _preparation_item_label(cleaned)

static func _potion_timing_text(potion_id: String, behavior: Dictionary) -> String:
	if potion_id.strip_edges() != AppShellActionContractScript.ITEM_HEALTH_POTION:
		return ""
	if not bool(behavior.get("enabled", true)):
		return "Pocao pausada"
	return "Usa automaticamente com vida baixa"

static func _spell_timing_text(behavior: Dictionary) -> String:
	if behavior.is_empty():
		return "Usa quando estiver pronta"
	if not bool(behavior.get("enabled", true)):
		return "Pausada para batalha"
	var condition_text := _condition_text(behavior)
	if condition_text == "":
		return "Usa quando estiver pronta"
	return "Usa quando estiver pronta; %s" % condition_text

static func _condition_text(behavior: Dictionary) -> String:
	var hp := _as_dictionary(behavior.get("hp", {}))
	var mana := _as_dictionary(behavior.get("mana", {}))
	var parts := PackedStringArray()
	if str(hp.get("mode", "ignore")) != "ignore":
		parts.append("Vida %s %d%%" % [
			"abaixo de" if str(hp.get("mode", "")) == "below" else "acima de",
			int(hp.get("percent", 0)),
		])
	if str(mana.get("mode", "ignore")) != "ignore":
		parts.append("Mana %s %d%%" % [
			"abaixo de" if str(mana.get("mode", "")) == "below" else "acima de",
			int(mana.get("percent", 0)),
		])
	if parts.is_empty():
		return ""
	return "entra melhor com %s" % " e ".join(parts)

static func _preparation_item_label(item_id: String) -> String:
	var cleaned := item_id.strip_edges()
	if cleaned == AppShellActionContractScript.ITEM_HEALTH_POTION:
		return "Pocao de Vida"
	match cleaned:
		"varinha_cinzas":
			return "Varinha de Cinzas"
		"athame_hematico":
			return "Athame Hematico"
		"cajado_ossario":
			return "Cajado Ossario"
		"orbe_tempestade":
			return "Orbe da Tempestade"
		"grimorio_veu":
			return "Grimorio do Veu"
		"idolo_pedra_viva":
			return "Idolo de Pedra Viva"
		"doutrina_pavor":
			return "Doutrina do Pavor"
		"pacto_familiar":
			return "Pacto Familiar"
		"corvo_pressagio":
			return "Corvo de Pressagio"
		"incisao_ritual":
			return "Incisao Ritual"
		"sussurro_medo":
			return "Sussurro do Medo"
	if cleaned == "":
		return "Nao definido"
	return _humanize_id(cleaned)

static func _preparation_spell_slots(combat_build: Dictionary) -> Array:
	var direct_slots := _as_array(combat_build.get("spell_slots", []))
	if not direct_slots.is_empty():
		var normalized := []
		for slot_variant: Variant in direct_slots:
			var slot := _as_dictionary(slot_variant)
			if not slot.is_empty():
				normalized.append(slot)
		return normalized

	var equipped := _as_array(combat_build.get("equipped_spells", []))
	if equipped.is_empty():
		return []

	var fallback := []
	for index in range(equipped.size()):
		var equipped_spell := _as_dictionary(equipped[index])
		var spell_id := str(equipped_spell.get("spell_id", "")).strip_edges()
		if spell_id == "":
			continue
		fallback.append({
			"slot_index": index + 1,
			"unlock_level": 1,
			"unlocked": true,
			"spell_id": spell_id,
			"behavior": _as_dictionary(equipped_spell.get("behavior", {})),
		})
	return fallback

static func _preparation_spell_summary(spell_slots: Array) -> String:
	var count := 0
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id != "" and spell_id != "<null>" and spell_id.to_lower() != "null":
			count += 1
	if count <= 0:
		return "Sem habilidades"
	if count == 1:
		return "1 habilidade"
	return "%d habilidades" % count

static func _render_preparation_options(
	host: Node,
	box: VBoxContainer,
	compact: bool,
	options: Array,
	current_id: String,
	action_kind: String,
	allow_remove: bool,
	remove_action: String = ""
) -> void:
	var rendered := false
	var visible_count := mini(options.size(), 8)
	for index in range(visible_count):
		var option := _as_dictionary(options[index])
		var item_id := str(option.get("id", "")).strip_edges()
		if item_id == "":
			continue
		rendered = true
		var name := str(option.get("display_name", "")).strip_edges()
		if name == "":
			name = _preparation_item_label(item_id)
		var equipped := bool(option.get("equipped", false)) or item_id == current_id
		var unlocked := bool(option.get("unlocked", true))
		var detail := "Em uso" if equipped else "Disponivel"
		if not unlocked:
			detail = str(option.get("locked_reason", "")).strip_edges()
			if detail == "":
				detail = "Bloqueado por nivel."
		box.add_child(_body_label("%s: %s" % [name, detail], compact))
		if unlocked and not equipped:
			var grid := _button_grid(compact, 1)
			box.add_child(grid)
			grid.add_child(_entry_action_button(host, "Equipar", _preparation_equip_action(action_kind, item_id), compact))

	if options.size() > visible_count:
		box.add_child(_body_label("Mais escolhas aparecem conforme o catalogo cresce.", compact))
	if not rendered:
		box.add_child(_body_label("Nenhuma escolha disponivel agora.", compact))
	if allow_remove and current_id != "" and remove_action != "":
		var remove_grid := _button_grid(compact, 1)
		box.add_child(remove_grid)
		remove_grid.add_child(_entry_action_button(host, "Remover", remove_action, compact))

static func _render_spell_options(host: Node, box: VBoxContainer, compact: bool, options: Array, spell_slots: Array) -> void:
	var equipped_ids := _equipped_spell_ids(spell_slots)
	var rendered := false
	var visible_count := mini(options.size(), 10)
	for index in range(visible_count):
		var option := _as_dictionary(options[index])
		var spell_id := str(option.get("id", "")).strip_edges()
		if spell_id == "":
			continue
		rendered = true
		var name := str(option.get("display_name", "")).strip_edges()
		if name == "":
			name = _preparation_item_label(spell_id)
		var equipped := bool(option.get("equipped", false)) or bool(equipped_ids.get(spell_id, false))
		var unlocked := bool(option.get("unlocked", true))
		var detail := "Em uso" if equipped else "Disponivel"
		if not unlocked:
			detail = str(option.get("locked_reason", "")).strip_edges()
			if detail == "":
				detail = "Bloqueada por nivel."
		box.add_child(_body_label("%s: %s" % [name, detail], compact))
		if unlocked and not equipped:
			var position := _first_open_spell_position(spell_slots)
			if position <= 0:
				position = _first_unlocked_spell_position(spell_slots)
			if position > 0:
				var grid := _button_grid(compact, 1)
				box.add_child(grid)
				grid.add_child(_entry_action_button(
					host,
					"Equipar na habilidade %d" % position,
					AppShellActionContractScript.equip_spell_position_action(position, spell_id),
					compact
				))
	if options.size() > visible_count:
		box.add_child(_body_label("Mais habilidades aparecem conforme o catalogo cresce.", compact))
	if not rendered:
		box.add_child(_body_label("Nenhuma habilidade disponivel agora.", compact))

static func _preparation_equip_action(action_kind: String, item_id: String) -> String:
	match action_kind:
		"instrument":
			return AppShellActionContractScript.equip_instrument_action(item_id)
		"doctrine":
			return AppShellActionContractScript.equip_doctrine_action(item_id)
		"familiar":
			return AppShellActionContractScript.equip_familiar_action(item_id)
		_:
			return ""

static func _equipped_spell_ids(spell_slots: Array) -> Dictionary:
	var equipped := {}
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id != "" and spell_id != "<null>" and spell_id.to_lower() != "null":
			equipped[spell_id] = true
	return equipped

static func _first_open_spell_position(spell_slots: Array) -> int:
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		if not bool(slot.get("unlocked", true)):
			continue
		var spell_id := str(slot.get("spell_id", "")).strip_edges()
		if spell_id == "" or spell_id == "<null>" or spell_id.to_lower() == "null":
			return int(slot.get("slot_index", 1))
	return 0

static func _first_unlocked_spell_position(spell_slots: Array) -> int:
	for slot_variant: Variant in spell_slots:
		var slot := _as_dictionary(slot_variant)
		if bool(slot.get("unlocked", true)):
			return int(slot.get("slot_index", 1))
	return 0

static func _humanize_id(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned == "":
		return ""
	cleaned = cleaned.replace("-", " ")
	cleaned = cleaned.replace("_", " ")
	return cleaned.capitalize()

static func _preparation_level_suffix(data: Dictionary, keys: Array) -> String:
	for key_variant: Variant in keys:
		var key := str(key_variant)
		if data.has(key):
			var level := int(data.get(key, 0))
			if level > 0:
				return " L%d" % level
	return ""

static func _preparation_level_suffix_with_fallback(primary: Dictionary, fallback: Dictionary, keys: Array) -> String:
	var suffix := _preparation_level_suffix(primary, keys)
	if suffix != "":
		return suffix
	return _preparation_level_suffix(fallback, keys)

static func _preparation_account_power_text(combat_build: Dictionary = {}) -> String:
	var parts := PackedStringArray()
	var level := int(SessionStore.player.get("level", 0))
	if level > 0:
		parts.append("Nivel %d" % level)
	var power := int(combat_build.get("power", SessionStore.player.get("power", 0)))
	if power > 0:
		parts.append("Poder %d" % power)
	return " | ".join(parts)

static func _first_non_empty_string(data: Dictionary, keys: Array) -> String:
	for key_variant: Variant in keys:
		var key := str(key_variant)
		var value := str(data.get(key, "")).strip_edges()
		if value != "" and value != "<null>" and value.to_lower() != "null":
			return value
	return ""

static func _inventory_quantity(inventory: Array, item_id: String) -> int:
	for item_variant: Variant in inventory:
		var item := _as_dictionary(item_variant)
		if str(item.get("item_id", "")) == item_id:
			return int(item.get("quantity", 0))
	return 0

static func _first_dictionary(items: Array) -> Dictionary:
	for item: Variant in items:
		if item is Dictionary:
			return Dictionary(item)
	return {}

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []

static func _hotspot_style(color_token: String, active: bool) -> StyleBoxFlat:
	if color_token == "border_default":
		color_token = UiTokens.surface_accent_token("refuge", "border_default")
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel").lerp(UiTokens.color(color_token), 0.18 if active else 0.08)
	style.border_color = UiTokens.color(color_token)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func _first_screen_root(host: Node) -> Control:
	var value: Variant = host.get("_first_screen_root")
	return value as Control if value is Control else null

static func _panel_style(host: Node, bg_token: String, border_token: String) -> StyleBoxFlat:
	return host.call("_panel_style", bg_token, border_token) as StyleBoxFlat
