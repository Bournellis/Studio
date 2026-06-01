class_name BootModeHubSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const ModeShellRegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")

static func render(host: Node) -> void:
	host.call("_add_section_label", "Modes")
	host.call("_add_body_text", "Hub interno dos cinco modos oficiais do DraxosMobile. Modos staged aparecem para orientar visao, sem iniciar gameplay.")
	var grid := host.call("_ensure_action_grid") as GridContainer
	if grid != null:
		grid.columns = int(host.call("_surface_columns", 2))
	for entry: Dictionary in ModeShellRegistryScript.hub_entries():
		_add_hub_route_button(host, entry)

static func add_popup_cards(host: Node, popup: PopupPanel, body: VBoxContainer, compact: bool) -> void:
	for entry: Dictionary in ModeShellRegistryScript.hub_entries():
		body.add_child(_mode_card(host, popup, entry, compact))

static func _add_hub_route_button(host: Node, entry: Dictionary) -> void:
	var mode_id := str(entry.get("mode_id", ""))
	var title := str(entry.get("display_name", mode_id.capitalize()))
	match mode_id:
		ModeShellRegistryScript.MODE_BASEBUILDER:
			host.call("_add_action_button", "%s\nActive" % title, AppShellActionContractScript.ACTION_SHOW_BASE)
		ModeShellRegistryScript.MODE_AUTOBATTLER:
			host.call("_add_action_button", "%s\nActive" % title, AppShellActionContractScript.ACTION_OPEN_ARENA)
		ModeShellRegistryScript.MODE_OPENWORLD:
			host.call("_add_action_button", "%s Bosque\nInternal Alpha" % title, AppShellActionContractScript.open_mode_shell_action(mode_id))
		_:
			host.call(
				"_add_action_button",
				"%s\nStaged" % title,
				AppShellActionContractScript.mode_disabled_action(mode_id),
				"",
				true,
				"Modo staged/disabled ate contrato proprio."
			)

static func _mode_card(host: Node, popup: PopupPanel, entry: Dictionary, compact: bool) -> Control:
	var panel := PanelContainer.new()
	panel.name = "ModeCard_%s" % str(entry.get("mode_id", "unknown"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _mode_card_style(entry))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5 if compact else 7)
	panel.add_child(box)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)
	var title := _scene_label(str(entry.get("display_name", "Mode")), "text_primary", 15 if compact else 17)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var status := _scene_label(_mode_status_label(str(entry.get("status", ""))), _mode_status_color(str(entry.get("status", ""))), 10 if compact else 11)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(status)

	var mode_id := str(entry.get("mode_id", ""))
	box.add_child(_body_label(_mode_card_detail(mode_id), compact))
	var launch := _mode_launch_button(host, popup, mode_id)
	box.add_child(launch)
	return panel

static func _mode_launch_button(host: Node, popup: PopupPanel, mode_id: String) -> Button:
	match mode_id:
		ModeShellRegistryScript.MODE_BASEBUILDER:
			return _popup_action_button(host, popup, "Abrir Basebuilder", AppShellActionContractScript.ACTION_SHOW_BASE, true)
		ModeShellRegistryScript.MODE_AUTOBATTLER:
			return _popup_action_button(host, popup, "Abrir Autobattler", AppShellActionContractScript.ACTION_OPEN_ARENA, true)
		ModeShellRegistryScript.MODE_OPENWORLD:
			return _popup_action_button(host, popup, "Abrir Openworld Bosque", AppShellActionContractScript.open_mode_shell_action(mode_id), true)
		_:
			var action_id := AppShellActionContractScript.mode_disabled_action(mode_id)
			var button := _drawer_button(host, "Staged", false, action_id, "refuge")
			button.disabled = true
			button.set_meta("force_disabled", true)
			button.set_meta("disabled_reason", "Modo visivel no Hub, mas bloqueado ate contrato proprio.")
			button.tooltip_text = "Modo visivel no Hub, mas bloqueado ate contrato proprio."
			var action_buttons := host.get("_action_buttons") as Dictionary
			action_buttons[action_id] = button
			return button

static func _popup_action_button(host: Node, popup: PopupPanel, text: String, action_id: String, primary: bool = false) -> Button:
	var button := _drawer_button(host, text, primary, action_id, "refuge")
	button.pressed.connect(func() -> void:
		popup.hide()
		host.call("_trigger_action", action_id, "")
	)
	var action_buttons := host.get("_action_buttons") as Dictionary
	action_buttons[action_id] = button
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

static func _mode_card_detail(mode_id: String) -> String:
	match mode_id:
		ModeShellRegistryScript.MODE_BASEBUILDER:
			return "Refugio/Base atuais: coleta, estruturas, recursos e crafting de base."
		ModeShellRegistryScript.MODE_AUTOBATTLER:
			return "Arena PVE atual: build de Instrumento, Doutrina, Familiar, spells e potions."
		ModeShellRegistryScript.MODE_OPENWORLD:
			return "Openworld Bosque em Internal Alpha: joystick, coleta, bau, craft e reward bridge limitado."
		ModeShellRegistryScript.MODE_TOWERDEFENSE:
			return "Futuro heroi/mago em torre central, spells, pets e upgrades contra hordas."
		ModeShellRegistryScript.MODE_CARDGAME:
			return "Cardgame futuro do DraxosMobile; compartilha lore, nao mecanica do projeto Steam."
	return "Modo registrado."

static func _mode_status_label(status: String) -> String:
	match status:
		"active":
			return "Active"
		"internal_alpha":
			return "Alpha"
		"planned_disabled":
			return "Staged"
		_:
			return status.capitalize()

static func _mode_status_color(status: String) -> String:
	match status:
		"active":
			return "status_success"
		"internal_alpha":
			return "accent_astral"
		"planned_disabled":
			return "text_secondary"
		_:
			return "text_secondary"

static func _mode_card_style(entry: Dictionary) -> StyleBoxFlat:
	var status := str(entry.get("status", ""))
	var color_token := _mode_status_color(status)
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel").lerp(UiTokens.color(color_token), 0.06)
	style.border_color = UiTokens.color(color_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func _scene_label(text: String, color_token: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	label.add_theme_font_size_override("font_size", font_size)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _body_label(text: String, compact: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	label.add_theme_font_size_override("font_size", 11 if compact else 12)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label
