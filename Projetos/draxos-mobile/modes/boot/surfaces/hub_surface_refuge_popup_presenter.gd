class_name BootHubSurfaceRefugePopupPresenter
extends "res://modes/boot/surfaces/hub_surface_common_presenter.gd"

const BaseSurfacePresenterScript := preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

static func create_refuge_menu_popup(host: Node, root: Control, compact: bool) -> Dictionary:
	var popup := PopupPanel.new()
	popup.name = "RefugeMenuPopup"
	popup.add_theme_stylebox_override("panel", _popup_panel_style(compact))
	root.add_child(popup)
	host.set("_refuge_menu_popup", popup)
	popup.set_meta("refuge_menu_compact", compact)
	popup.set_meta("refuge_menu_active_id", "")

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
		popup.set_meta("refuge_menu_active_id", "")
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
	popup.set_meta("refuge_menu_title_label", title_label)
	popup.set_meta("refuge_menu_body", body)
	return {
		"popup": popup,
		"title_label": title_label,
		"body": body,
	}

static func _open_refuge_menu_popup(host: Node, popup: PopupPanel, title_label: Label, body: VBoxContainer, menu_id: String, compact: bool) -> void:
	if popup == null or body == null or title_label == null:
		return
	_forget_action_buttons_in_tree(host, body)
	_clear_node_children(body)
	title_label.text = _menu_title(menu_id)
	_populate_refuge_menu(host, popup, body, menu_id, compact)
	popup.set_meta("refuge_menu_active_id", menu_id)
	var viewport_size := _host_viewport_size(host)
	var popup_width := clampi(int(viewport_size.x - 20.0), 312, 468 if compact else 560)
	var vertical_padding := 16 if compact else 72
	var popup_height := clampi(int(viewport_size.y - float(vertical_padding)), 420, 820 if compact else 700)
	popup.popup_centered(Vector2i(popup_width, popup_height))

static func open_refuge_menu_popup(host: Node, menu_id: String) -> bool:
	var popup := host.get("_refuge_menu_popup") as PopupPanel
	if popup == null or not is_instance_valid(popup):
		return false
	var title_label := popup.get_meta("refuge_menu_title_label", null) as Label
	var body := popup.get_meta("refuge_menu_body", null) as VBoxContainer
	if popup == null or title_label == null or body == null:
		return false
	var compact := bool(popup.get_meta("refuge_menu_compact", false))
	_open_refuge_menu_popup(host, popup, title_label, body, menu_id, compact)
	return true

static func refresh_open_refuge_menu_popup(host: Node) -> bool:
	var popup := host.get("_refuge_menu_popup") as PopupPanel
	if popup == null or not is_instance_valid(popup):
		return false
	if not popup.visible:
		return false
	var menu_id := str(popup.get_meta("refuge_menu_active_id", "")).strip_edges()
	if menu_id == "":
		return false
	return open_refuge_menu_popup(host, menu_id)

static func _populate_refuge_menu(host: Node, popup: PopupPanel, body: VBoxContainer, menu_id: String, compact: bool) -> void:
	match menu_id:
		"arena":
			body.add_child(_popup_hint("Tutorial de 1 duelo e primeiras arenas de 3 duelos com buffs temporarios.", compact))
			body.add_child(_popup_action_button(host, popup, "Abrir Arena PVE", AppShellActionContractScript.ACTION_OPEN_ARENA, "", true))
		"battle":
			body.add_child(_popup_hint("Batalha legada para validacao interna. O caminho principal do jogo e Arena PVE.", compact))
			body.add_child(_popup_action_button(host, popup, "Pedir batalha legada", AppShellActionContractScript.ACTION_REQUEST_BATTLE, "", true))
			body.add_child(_popup_action_button(host, popup, "Historico", AppShellActionContractScript.ACTION_SHOW_BATTLE_HISTORY))
			body.add_child(_popup_action_button(host, popup, "Ver resultado", AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE))
		"refuge":
			body.add_child(_popup_hint("Estruturas, crafting, producao pendente e upgrades do Refugio.", compact))
			BaseSurfacePresenterScript.render_refuge_embedded(host, body)
		"social":
			body.add_child(_popup_hint("Amigos, guilda e chat em um painel leve.", compact))
			body.add_child(_popup_action_button(host, popup, "Abrir Social", AppShellActionContractScript.ACTION_SHOW_SOCIAL, "", true))
		"competition":
			body.add_child(_popup_hint("Competicao PVP fica fora do core inicial e deve ser usada apenas para validacao interna.", compact))
			body.add_child(_popup_action_button(host, popup, "Matchmaking", AppShellActionContractScript.ACTION_SHOW_MATCHMAKING, "", true))
			body.add_child(_popup_action_button(host, popup, "Ranking", AppShellActionContractScript.ACTION_SHOW_RANKING))
		"shop":
			body.add_child(_popup_hint("Recompensas, resgates e compras.", compact))
			body.add_child(_popup_action_button(host, popup, "Abrir Loja", AppShellActionContractScript.ACTION_SHOW_SHOP, "", true))
			body.add_child(_popup_action_button(host, popup, "Recompensa diaria", AppShellActionContractScript.ACTION_CLAIM_DAILY_REWARD))
		"profile":
			body.add_child(_popup_hint(_short_account_status(), compact))
			body.add_child(_popup_action_button(host, popup, "Abrir Perfil", AppShellActionContractScript.ACTION_SHOW_ACCOUNT, "", true))
			_add_dev_tool_actions(host, popup, body)
			body.add_child(_popup_action_button(host, popup, "Checar atualizacao", AppShellActionContractScript.ACTION_CHECK_UPDATE))
		"dev":
			body.add_child(_popup_hint("Ferramentas internas para validar batalha e progressao do prototipo.", compact))
			_add_dev_tool_actions(host, popup, body, true)
		_:
			body.add_child(_popup_hint("Menu indisponivel.", compact))

static func _menu_title(menu_id: String) -> String:
	match menu_id:
		"arena":
			return "Arena PVE"
		"battle":
			return "Batalha Legada"
		"refuge":
			return "Refugio"
		"social":
			return "Social"
		"competition":
			return "Competicao Dev"
		"shop":
			return "Loja"
		"profile":
			return "Perfil"
		"dev":
			return "Labs Dev"
	return "Menu"

static func _add_dev_tool_actions(host: Node, popup: PopupPanel, body: VBoxContainer, primary: bool = false) -> void:
	if bool(host.call("_battle_lab_available")):
		body.add_child(_popup_action_button(host, popup, "Battle Lab", AppShellActionContractScript.ACTION_OPEN_BATTLE_LAB, "", primary))
	if bool(host.call("_progression_lab_available")):
		body.add_child(_popup_action_button(host, popup, "Progression Lab", AppShellActionContractScript.ACTION_OPEN_PROGRESSION_LAB, "", primary))
	if bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/dev_tools_enabled", false)):
		body.add_child(_popup_action_button(host, popup, "Batalha legada", AppShellActionContractScript.ACTION_REQUEST_BATTLE))
		body.add_child(_popup_action_button(host, popup, "Competicao dev", AppShellActionContractScript.ACTION_SHOW_MATCHMAKING))
