class_name BootHubSurfacePresenter
extends RefCounted

const HubAccountSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_account_surface_presenter.gd")
const TouchScrollContainerScript := preload("res://modes/boot/ui/touch_scroll_container.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")

class RefugeAltarView:
	extends Control

	var compact := false

	func _init(is_compact: bool = false) -> void:
		compact = is_compact
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(0, 230) if compact else Vector2(0, 320)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_flags_vertical = Control.SIZE_EXPAND_FILL

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(rect, UiTokens.color("bg_deep").lightened(0.02), true)
		var center := rect.get_center()
		var horizon_y := size.y * 0.42
		draw_rect(Rect2(Vector2(0, horizon_y), Vector2(size.x, size.y - horizon_y)), UiTokens.color("bg_panel").darkened(0.08), true)
		for index: int in range(6):
			var x := lerpf(0.0, size.x, float(index) / 5.0)
			draw_line(Vector2(x, horizon_y), Vector2(center.x, size.y * 0.82), UiTokens.color("border_default").darkened(0.15), 1.0)
		var altar_width := minf(size.x * 0.62, 290.0)
		var altar_height := minf(size.y * 0.25, 92.0)
		var base_y := size.y * 0.72
		var top_y := base_y - altar_height
		var platform := PackedVector2Array([
			Vector2(center.x - altar_width * 0.55, base_y),
			Vector2(center.x + altar_width * 0.55, base_y),
			Vector2(center.x + altar_width * 0.36, top_y),
			Vector2(center.x - altar_width * 0.36, top_y),
		])
		draw_polygon(platform, PackedColorArray([
			UiTokens.color("accent_bone").darkened(0.30),
			UiTokens.color("accent_bone").darkened(0.30),
			UiTokens.color("accent_bone").darkened(0.12),
			UiTokens.color("accent_bone").darkened(0.12),
		]))
		draw_arc(center + Vector2(0, -36), 54, 0, TAU, 72, UiTokens.color("accent_astral"), 4.0)
		draw_arc(center + Vector2(0, -36), 28, 0, TAU, 72, UiTokens.color("accent_blood").lightened(0.15), 3.0)
		draw_line(Vector2(center.x, top_y - 72.0), Vector2(center.x, top_y + 12.0), UiTokens.color("accent_astral").lightened(0.35), 5.0)
		draw_line(Vector2(center.x - 44.0, top_y - 28.0), Vector2(center.x + 44.0, top_y - 28.0), UiTokens.color("accent_blood"), 3.0)
		for index: int in range(5):
			var offset := float(index - 2) * 38.0
			draw_circle(Vector2(center.x + offset, top_y - 92.0 + absf(offset) * 0.18), 4.0, UiTokens.color("accent_astral").lightened(0.2))

static func render_entry(host: Node) -> void:
	var root := _first_screen_root(host)
	if root == null:
		return
	var compact := bool(host.get("_compact_layout"))
	var body := _screen_body(host, root, "EntryFirstScreenBody", compact)
	body.add_child(_title_label("DraxosMobile", 28 if compact else 34))
	body.add_child(_subtitle_label("Entrada", "Login, save e labs antes de abrir o Refugio."))
	body.add_child(_entry_status_panel(host, compact))
	body.add_child(_entry_account_panel(host, compact))
	body.add_child(_entry_save_panel(host, compact))
	body.add_child(_entry_dev_panel(host, compact))

static func render_refuge(host: Node) -> void:
	var root := _first_screen_root(host)
	if root == null:
		return
	var compact := bool(host.get("_compact_layout"))
	var body := _screen_body(host, root, "RefugeSceneBody", compact)
	body.add_child(_refuge_top_bar(host, compact))
	body.add_child(_refuge_scene_panel(host, compact))
	body.add_child(_refuge_hotspot_panel(host, compact))

static func _screen_body(host: Node, root: Control, body_name: String, compact: bool) -> VBoxContainer:
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

static func _entry_status_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntryStatusPanel", "bg_panel", "border_active")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Status alpha", compact))
	box.add_child(_body_label(HubAccountSurfacePresenterScript.home_account_summary_text(host), compact))
	_add_feedback_labels(host, box, compact)
	box.add_child(_entry_action_button(host, "Checar update", "check_update", compact))
	return panel

static func _entry_account_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntryAccountPanel", "bg_panel_alt", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Login / Criar conta", compact))
	box.add_child(_body_label("Use email/senha para o teste principal. Guest dev fica como atalho local.", compact))
	host.set("_auth_email_input", _entry_input(box, "Email", "tester@exemplo.com", SessionStore.auth_email, false, compact))
	host.set("_auth_password_input", _entry_input(box, "Senha", "Senha da conta alpha", "", true, compact))
	host.set("_auth_username_input", _entry_input(box, "Username", "draxos_tester", SessionStore.account_username, false, compact))
	host.set("_auth_invite_input", _entry_input(box, "Convite alpha", SessionStore.DEFAULT_INVITE_CODE, SessionStore.DEFAULT_INVITE_CODE, false, compact))
	var grid := _button_grid(compact)
	box.add_child(grid)
	grid.add_child(_entry_action_button(host, "Criar conta", "email_sign_up", compact))
	grid.add_child(_entry_action_button(host, "Entrar", "email_sign_in", compact))
	grid.add_child(_entry_action_button(host, "Guest dev", "enter_guest", compact))
	grid.add_child(_entry_action_button(host, "Reset local", "reset_session", compact, "Limpar apenas token/cache local desta maquina? O estado salvo no servidor nao sera apagado."))
	box.add_child(_entry_action_button(host, "Entrar no Refugio", "enter_refuge", compact, "", true))
	return panel

static func _entry_save_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "EntrySavePanel", "bg_panel", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Save antes de entrar", compact))
	box.add_child(_body_label("Escolha Normal para jogar ou Progression Lab para testes isolados.", compact))
	var grid := _button_grid(compact)
	box.add_child(grid)
	grid.add_child(_entry_action_button(host, "Save normal", "select_save_normal", compact))
	grid.add_child(_entry_action_button(host, "Save Lab", "select_save_progression_lab", compact))
	grid.add_child(_entry_action_button(host, "Sincronizar", "refresh_session", compact))
	grid.add_child(_entry_action_button(
		host,
		"Reset save",
		"reset_active_save",
		compact,
		"Resetar apenas o save %s no servidor? O outro save e a sessao local serao preservados." % SessionStore.active_save_label()
	))
	return panel

static func _entry_dev_panel(host: Node, compact: bool) -> PanelContainer:
	var battle_lab := bool(host.call("_battle_lab_available"))
	var progression_lab := bool(host.call("_progression_lab_available"))
	var panel := _panel(host, "EntryDevPanel", "bg_panel_alt", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Labs Dev", compact))
	if not battle_lab and not progression_lab:
		box.add_child(_body_label("Labs internos aparecem aqui apenas no editor/dev tools.", compact))
		return panel
	box.add_child(_body_label("Ferramentas internas para preparar saves e conferir batalhas sem virar feature publica.", compact))
	var grid := _button_grid(compact, 2)
	box.add_child(grid)
	if battle_lab:
		grid.add_child(_entry_action_button(host, "Battle Lab", "open_battle_lab", compact))
	if progression_lab:
		grid.add_child(_entry_action_button(host, "Progression Lab", "open_progression_lab", compact))
	return panel

static func _refuge_top_bar(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "RefugeTopBar", "bg_panel", "border_active")
	var box := _panel_box(panel, compact)
	box.add_child(_title_label("Refugio", 24 if compact else 30))
	box.add_child(_body_label("Recursos: %s" % _format_resources(SessionStore.resources), compact))
	box.add_child(_body_label(_short_account_status(), compact))
	_add_feedback_labels(host, box, compact)
	return panel

static func _refuge_scene_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "RefugeAltarPanel", "bg_deep", "border_active")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Altar do Mago", compact))
	box.add_child(_body_label("O centro do Refugio: daqui voce abre batalha, rotina da Base, social, competicao e loja.", compact))
	box.add_child(RefugeAltarView.new(compact))
	return panel

static func _refuge_hotspot_panel(host: Node, compact: bool) -> PanelContainer:
	var panel := _panel(host, "RefugeHotspotPanel", "bg_panel_alt", "border_default")
	var box := _panel_box(panel, compact)
	box.add_child(_section_label("Caminhos do Refugio", compact))
	var grid := _button_grid(compact)
	box.add_child(grid)
	_add_route_hotspot(host, grid, compact, "Batalha", "battle_entry", "Pedir batalha e ver replay server-authoritative.", "accent_blood")
	_add_action_hotspot(host, grid, compact, "Base", "show_base", "Coletar, evoluir estruturas e acompanhar rotina.", "accent_astral")
	_add_action_hotspot(host, grid, compact, "Social", "show_social", "Amigos, guilda e chat por polling.", "status_success")
	_add_action_hotspot(host, grid, compact, "Competicao", "show_matchmaking", "Preview de matchmaking e ranking alpha.", "status_warning")
	_add_action_hotspot(host, grid, compact, "Loja", "show_shop", "Redeems, recompensas e compras alpha.", "accent_bone")
	_add_route_hotspot(host, grid, compact, "Perfil", "account", "Conta, updates e detalhes do save.", "border_active")
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

static func _entry_action_button(host: Node, text: String, action_id: String, compact: bool, confirm_message: String = "", primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.tooltip_text = text
	button.custom_minimum_size = Vector2(0, 58 if primary else 50)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_stylebox_override("normal", _hotspot_style("accent_astral" if primary else "border_default", primary))
	button.add_theme_stylebox_override("hover", _hotspot_style("accent_astral" if primary else "border_active", true))
	button.add_theme_stylebox_override("pressed", _hotspot_style("accent_astral" if primary else "border_active", true))
	host.call("_prepare_touch_button", button)
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
	box.add_child(status)
	box.add_child(detail)
	box.add_child(error)
	host.set("_immersive_status_label", status)
	host.set("_immersive_detail_label", detail)
	host.set("_immersive_error_label", error)
	if host.has_method("_sync_immersive_feedback"):
		host.call("_sync_immersive_feedback")

static func _short_account_status() -> String:
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		return "Lab local: %s" % SessionStore.progression_lab_label()
	if SessionStore.has_account_state():
		return "%s | Level %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player.get("level", 1)),
			str(SessionStore.player.get("power", 0)),
		]
	if SessionStore.has_valid_access_token():
		return "Sessao auth pronta; sincronize o save se necessario."
	return "Sem sessao. Volte para Entrada para login ou guest dev."

static func _format_resources(resources: Dictionary) -> String:
	if resources.is_empty():
		return "sem snapshot"
	var parts: PackedStringArray = PackedStringArray()
	for key in ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]:
		parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	return " | ".join(parts)

static func _hotspot_style(color_token: String, active: bool) -> StyleBoxFlat:
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
