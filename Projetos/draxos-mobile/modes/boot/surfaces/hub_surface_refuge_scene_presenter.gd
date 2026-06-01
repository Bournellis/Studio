class_name BootHubSurfaceRefugeScenePresenter
extends "res://modes/boot/surfaces/hub_surface_common_presenter.gd"

const BaseSurfacePresenterScript := preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const RefugePopupPresenterScript := preload("res://modes/boot/surfaces/hub_surface_refuge_popup_presenter.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const MobileUiContractScript := preload("res://modes/boot/ui/mobile_ui_contract.gd")
const ProgressionClarityPresenterScript := preload("res://modes/boot/surfaces/progression_clarity_presenter.gd")

const UX_REFUGE_BACKGROUND := "res://assets/ux_overhaul/refuge_ship_hub.png"

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
	_add_refuge_progression_panel(host, safe_frame, compact)
	_add_refuge_footer_bar(host, safe_frame, compact)
	_add_refuge_context_cta(host, safe_frame, compact)

	RefugePopupPresenterScript.create_refuge_menu_popup(host, root, compact)

	_add_refuge_icon_button(host, safe_frame, compact, "arena", "AR", "Arena PVE", "accent_blood", Vector2(0.50, 0.19), "Escolher Arena PVE e travar loadout.")
	_add_refuge_icon_button(host, safe_frame, compact, "preparation", "PP", "Preparacao", "accent_astral", Vector2(0.50, 0.32), "Revisar pocao e habilidades antes da Arena.")
	_add_refuge_icon_button(host, safe_frame, compact, "refuge", "RF", "Refugio", "accent_astral", Vector2(0.22, 0.37), "Coleta, energia e estruturas.")
	_add_refuge_icon_button(host, safe_frame, compact, "social", "SO", "Social", "status_success", Vector2(0.78, 0.37), "Amigos, guilda e chat.")
	_add_refuge_icon_button(host, safe_frame, compact, "modes", "MD", "Modos", "accent_bone", Vector2(0.22, 0.56), "Hub de modos oficiais.")
	_add_refuge_icon_button(host, safe_frame, compact, "shop", "LJ", "Loja", "accent_bone", Vector2(0.78, 0.56), "Recompensas e compras.")
	_add_refuge_icon_button(host, safe_frame, compact, "collect", "CL", "Coletar", "status_success", Vector2(0.28, 0.77), "Coletar producao do Refugio.", true)
	_add_refuge_icon_button(host, safe_frame, compact, "energy", "EN", "Energia", "accent_astral", Vector2(0.72, 0.77), "Comprar Energia.", true)
	if _refuge_has_dev_tools(host):
		_add_refuge_dev_button(host, safe_frame, compact)
	_add_refuge_profile_button(host, safe_frame, compact)

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
	var resources := _scene_label(_format_resources_short(SessionStore.resources_snapshot()), "text_secondary", 10 if compact else 12)
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
	button.text = str(cta.get("text", "Arena PVE"))
	button.tooltip_text = str(cta.get("detail", "Entrar na Arena PVE."))
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
	grid.add_child(_loop_status_label("Proximo\n%s" % str(state.get("next_text", "Arena PVE")), "text_primary", compact, "RefugeLoopNextLabel"))
	grid.add_child(_loop_status_label("Coleta\n%s" % str(state.get("collect_text", "Nada agora")), str(state.get("collect_color", "text_secondary")), compact, "RefugeLoopCollectLabel"))
	grid.add_child(_loop_status_label("Evolucao\n%s" % str(state.get("upgrade_text", "Sem upgrade")), str(state.get("upgrade_color", "text_secondary")), compact, "RefugeLoopUpgradeLabel"))

static func _add_refuge_progression_panel(host: Node, board: Control, compact: bool) -> void:
	var panel := PanelContainer.new()
	panel.name = "RefugeProgressionPanel"
	panel.anchor_left = 0.04
	panel.anchor_right = 0.96
	panel.anchor_top = 0.724
	panel.anchor_bottom = 0.825
	panel.add_theme_stylebox_override("panel", _hud_style("bg_panel", "accent_astral"))
	board.add_child(panel)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1 if compact else 2)
	panel.add_child(box)
	var title := _scene_label("Progresso", "text_primary", 10 if compact else 12)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	var line := _scene_label(ProgressionClarityPresenterScript.refuge_progress_line(SessionStore.combat_build_snapshot()), "text_secondary", 9 if compact else 11)
	line.name = "RefugeProgressionLine"
	line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	line.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	line.clip_text = true
	box.add_child(line)
	var first_session_hint := _scene_label(_first_session_hint_text(host), "text_secondary", 8 if compact else 10)
	first_session_hint.name = "RefugeFirstSessionHintLabel"
	first_session_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	first_session_hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	first_session_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	first_session_hint.clip_text = true
	box.add_child(first_session_hint)

static func _loop_status_label(text: String, color_token: String, compact: bool, node_name: String) -> Label:
	var label := _scene_label(text, color_token, 9 if compact else 11)
	label.name = node_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	return label

static func _add_refuge_profile_button(host: Node, board: Control, compact: bool) -> void:
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
		RefugePopupPresenterScript.open_refuge_menu_popup(host, "profile")
	)
	board.add_child(button)

static func _add_refuge_dev_button(host: Node, board: Control, compact: bool) -> void:
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
		RefugePopupPresenterScript.open_refuge_menu_popup(host, "dev")
	)
	board.add_child(button)

static func _add_refuge_icon_button(host: Node, board: Control, compact: bool, menu_id: String, symbol: String, title: String, color_token: String, anchor: Vector2, detail: String, quick: bool = false) -> void:
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
		RefugePopupPresenterScript.open_refuge_menu_popup(host, menu_id)
	)
	board.add_child(button)

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

static func refuge_context_cta_data(host: Node) -> Dictionary:
	return _refuge_context_cta_data(host)

static func _refuge_context_cta_data(_host: Node) -> Dictionary:
	if SessionStore.has_unseen_battle_result():
		return {
			"text": "Ver recompensa",
			"detail": "Abrir a recompensa e voltar para conferir a base atualizada.",
			"action_id": AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE,
			"color_token": "accent_blood",
		}
	var base := SessionStore.base_snapshot()
	if not base.is_empty():
		var routine := BaseSurfacePresenterScript.routine_summary(base)
		if bool(routine.get("has_collect_ready", false)):
			return {
				"text": "Coletar",
				"detail": "Primeiro passo do ciclo: receber recursos acumulados do Refugio.",
				"action_id": AppShellActionContractScript.ACTION_COLLECT_BASE,
				"color_token": "status_success",
			}
		if bool(routine.get("next_upgrade_ready", false)):
			var structure_id := str(routine.get("next_upgrade_id", ""))
			if structure_id != "":
				return {
					"text": "Evoluir",
					"detail": "Usar recursos para evoluir a base antes da proxima Arena.",
					"action_id": AppShellActionContractScript.upgrade_base_structure_action(structure_id),
					"confirm": "Iniciar evolucao no Refugio?",
					"color_token": "accent_astral",
				}
	return {
		"text": "Arena PVE",
		"detail": "Entrar na arena inicial, travar loadout e resolver duelos.",
		"action_id": AppShellActionContractScript.ACTION_OPEN_ARENA,
		"color_token": "accent_blood",
	}

static func _refuge_loop_state(host: Node) -> Dictionary:
	var cta := _refuge_context_cta_data(host)
	var collect_text := "Sincronizar"
	var collect_color := "text_secondary"
	var upgrade_text := "Sem dados"
	var upgrade_color := "text_secondary"
	var base := SessionStore.base_snapshot()
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
		"next_text": str(cta.get("text", "Arena PVE")),
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

static func _first_session_hint_text(host: Node) -> String:
	if SessionStore.has_unseen_battle_result():
		return "Primeira sessao: abra a recompensa e volte para conferir a base."
	var base := SessionStore.base_snapshot()
	if not base.is_empty():
		var routine := BaseSurfacePresenterScript.routine_summary(base)
		if bool(routine.get("has_collect_ready", false)):
			return "Primeira sessao: comece coletando recursos do Refugio."
		if bool(routine.get("next_upgrade_ready", false)):
			return "Primeira sessao: evolua uma estrutura antes da proxima Arena."
		if SessionStore.combat_build_snapshot().is_empty():
			return "Primeira sessao: abra Preparacao e confirme sua preparacao."
		if not SessionStore.has_battle_log():
			return "Primeira sessao: base pronta; abra a Arena PVE."
	if host != null and host.has_method("_battle_lab_available") and bool(host.call("_battle_lab_available")) and not SessionStore.has_valid_access_token():
		return "Primeira sessao: entre, escolha o save e siga o proximo passo."
	return "Primeira sessao: siga o proximo passo e mantenha a base evoluindo."
