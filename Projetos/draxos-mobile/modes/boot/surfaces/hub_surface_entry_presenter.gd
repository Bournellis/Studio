class_name BootHubSurfaceEntryPresenter
extends "res://modes/boot/surfaces/hub_surface_common_presenter.gd"

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")

const UX_ENTRY_BACKGROUND := "res://assets/ux_overhaul/entry_necromante.png"

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

static func _entry_scene_background(_host: Node, _compact: bool) -> Control:
	var layer := Control.new()
	layer.name = "EntrySceneBackground"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_add_texture_layer(layer, UX_ENTRY_BACKGROUND, 0.64)
	_add_color_layer(layer, UiTokens.color("bg_void"), 0.62)
	_add_color_layer(layer, UiTokens.color("bg_blood_wash"), 0.18)
	return layer

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
