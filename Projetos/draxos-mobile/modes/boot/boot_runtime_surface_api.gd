extends "res://modes/boot/boot_runtime_state.gd"

# Presenter-facing UI helpers and SurfaceUiHelpers facade methods.
func _close_refuge_menu_popup_if_open() -> bool:
	if _refuge_menu_popup == null or not is_instance_valid(_refuge_menu_popup):
		return false
	if not _refuge_menu_popup.visible:
		return false
	_refuge_menu_popup.hide()
	return true
func _render_create_account_dialog() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = "Criar conta"
	dialog.confirmed.connect(Callable(self, "_on_create_account_confirmed"))
	add_child(dialog)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	dialog.add_child(box)
	var intro := Label.new()
	intro.text = "Crie a conta com email, senha e username."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(intro)
	_signup_email_input = _dialog_line_edit(box, "Email", "tester@exemplo.com", false)
	_signup_password_input = _dialog_line_edit(box, "Senha", "Minimo 6 caracteres", true)
	_signup_username_input = _dialog_line_edit(box, "Username", "draxos_tester", false)
	dialog.get_ok_button().text = "Criar conta"
	dialog.get_cancel_button().text = "Voltar"
	_create_account_dialog = dialog
func _dialog_line_edit(parent: VBoxContainer, label_text: String, placeholder: String, secret: bool) -> LineEdit:
	var label := Label.new()
	label.text = label_text
	parent.add_child(label)
	var input := LineEdit.new()
	input.placeholder_text = placeholder
	input.secret = secret
	input.custom_minimum_size = MobileUiContractScript.input_min_size(true)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(input)
	return input
func _should_use_compact_layout() -> bool:
	if bool(ProjectSettings.get_setting("draxos_mobile/ui/force_compact_layout", false)):
		return true
	if OS.get_name() == "Android":
		return true
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= MobileUiContractScript.COMPACT_WIDTH_BREAKPOINT:
		return true
	return viewport_size.y <= 620.0 and viewport_size.x > viewport_size.y
func _manifest_url() -> String:
	return SupabaseClient.manifest_url()
func _button_min_size() -> Vector2:
	return MobileUiContractScript.button_min_size(_compact_layout)
func _action_button_columns() -> int:
	return action_button_columns_for_size(get_viewport_rect().size, _compact_layout)
func _surface_columns(max_columns: int = 2) -> int:
	return surface_columns_for_size(get_viewport_rect().size, max_columns)
static func action_button_columns_for_size(viewport_size: Vector2, compact: bool) -> int:
	return MobileUiContractScript.action_button_columns_for_size(viewport_size, compact)
static func surface_columns_for_size(viewport_size: Vector2, max_columns: int = 2) -> int:
	return MobileUiContractScript.surface_columns_for_size(viewport_size, max_columns)
func _base_map_columns() -> int:
	return MobileUiContractScript.base_map_columns_for_size(get_viewport_rect().size, _compact_layout)
func _reset_action_group() -> void:
	_current_action_grid = null
func _ensure_action_grid() -> GridContainer:
	if _current_action_grid != null and is_instance_valid(_current_action_grid):
		return _current_action_grid
	var grid := GridContainer.new()
	grid.columns = _action_button_columns()
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8 if _compact_layout else 10)
	grid.add_theme_constant_override("v_separation", 8)
	_content_body.add_child(grid)
	_current_action_grid = grid
	return grid

func _clear_content_body() -> void:
	for child: Node in _content_body.get_children():
		_content_body.remove_child(child)
		child.queue_free()

func _clear_first_screen_root() -> void:
	if _first_screen_root == null or not is_instance_valid(_first_screen_root):
		return
	for child: Node in _first_screen_root.get_children():
		_first_screen_root.remove_child(child)
		child.queue_free()

func _clear_node_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _clear_battle_fullscreen_overlay() -> void:
	if _battle_fullscreen_overlay == null:
		return
	if is_instance_valid(_battle_fullscreen_overlay):
		_battle_fullscreen_overlay.queue_free()
	_battle_fullscreen_overlay = null

func _clear_mode_fullscreen_overlay() -> void:
	if _mode_fullscreen_overlay == null:
		return
	if is_instance_valid(_mode_fullscreen_overlay):
		_mode_fullscreen_overlay.queue_free()
	_mode_fullscreen_overlay = null

func _create_battle_fullscreen_overlay() -> Control:
	var overlay := Control.new()
	overlay.name = "BattleFullscreenOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.position = Vector2.ZERO
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var parent: Control = _shell_overlay_fullscreen_parent()
	if parent == null:
		parent = self
	parent.add_child(overlay)
	_battle_fullscreen_overlay = overlay
	return overlay

func _create_mode_fullscreen_overlay() -> Control:
	var overlay := Control.new()
	overlay.name = "ModeFullscreenOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.position = Vector2.ZERO
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	_mode_fullscreen_overlay = overlay
	return overlay

func _add_section_label(text: String) -> Label:
	_reset_action_group()
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16 if _compact_layout else 18)
	label.add_theme_color_override("font_color", UiTokens.surface_accent_color(_active_route_for_context(), "text_primary"))
	_content_body.add_child(label)
	return label

func _add_body_text(text: String) -> Label:
	_reset_action_group()
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _compact_layout:
		label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(label)
	return label

func _add_output_label(text: String) -> Label:
	_reset_action_group()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiTokens.surface_panel_style(_active_route_for_context(), _compact_layout, "bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(panel)

	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _compact_layout:
		label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(label)
	return label

func _add_content_control(control: Control) -> void:
	_reset_action_group()
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(control)

func _add_responsive_panel_layout(container: VBoxContainer, panels: Array, max_columns: int = 2) -> void:
	if container == null:
		return
	var column_count := _surface_columns(max_columns)
	if column_count <= 1 or panels.size() <= 1:
		for panel: Variant in panels:
			if panel is Control:
				container.add_child(panel as Control)
		return

	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 8 if _compact_layout else 10)
	container.add_child(row)

	var columns: Array = []
	for index in range(column_count):
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		column.add_theme_constant_override("separation", 8 if _compact_layout else 10)
		row.add_child(column)
		columns.append(column)

	for index in range(panels.size()):
		var panel: Variant = panels[index]
		if panel is Control:
			var column := columns[index % column_count] as VBoxContainer
			if column != null:
				column.add_child(panel as Control)

func _add_action_button(
	text: String,
	action_id: String,
	confirm_message: String = "",
	force_disabled: bool = false,
	disabled_reason: String = ""
) -> Button:
	var button := Button.new()
	button.name = "ActionButton_%s" % _control_name_fragment(action_id)
	button.text = text
	button.set_meta("action_id", action_id)
	button.custom_minimum_size = _button_min_size()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = disabled_reason if disabled_reason.strip_edges() != "" else text
	button.disabled = force_disabled
	button.set_meta("force_disabled", force_disabled)
	button.set_meta("disabled_reason", disabled_reason.strip_edges())
	_prepare_touch_button(button)
	_apply_action_button_style(button, action_id)
	button.pressed.connect(func() -> void:
		call("_trigger_action", action_id, confirm_message)
	)
	_ensure_action_grid().add_child(button)
	_action_buttons[action_id] = button
	return button

func _add_social_input(label_text: String, placeholder: String, initial_text: String, input_tooltip: String) -> LineEdit:
	_reset_action_group()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_body.add_child(box)

	var label := Label.new()
	label.text = label_text
	label.add_theme_color_override("font_color", UiTokens.surface_accent_color(_active_route_for_context(), "text_secondary"))
	box.add_child(label)

	var input := LineEdit.new()
	input.name = "SocialInput_%s" % _control_name_fragment(label_text)
	input.placeholder_text = placeholder
	input.text = initial_text
	input.tooltip_text = input_tooltip
	input.set_meta("control_role", "social_input")
	var bind_property := _social_input_bind_property(label_text)
	if bind_property != "":
		input.set_meta("bind_property", bind_property)
	input.custom_minimum_size = MobileUiContractScript.input_min_size(_compact_layout)
	input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(input)
	return input

func _add_screen_button(text: String, screen_id: String) -> Button:
	var target_screen := AppShellRouteContractScript.normalize(screen_id)
	var button := Button.new()
	button.name = "ScreenButton_%s" % _control_name_fragment(target_screen)
	button.text = text
	button.set_meta("route_id", target_screen)
	button.set_meta("action_id", "screen:%s" % target_screen)
	button.custom_minimum_size = _button_min_size()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = "Abrir %s." % _screen_title(screen_id)
	_prepare_touch_button(button)
	_apply_action_button_style(button, "screen:%s" % target_screen, target_screen)
	button.pressed.connect(func() -> void:
		call("_show_screen", target_screen)
	)
	_ensure_action_grid().add_child(button)
	return button

func _control_name_fragment(value: String) -> String:
	var text := value.strip_edges().to_lower()
	var output := PackedStringArray()
	for index in range(text.length()):
		var character := text.substr(index, 1)
		var code := character.unicode_at(0)
		var valid := (code >= 48 and code <= 57) or (code >= 97 and code <= 122)
		output.append(character if valid else "_")
	var result := "".join(output)
	while result.contains("__"):
		result = result.replace("__", "_")
	result = result.strip_edges()
	while result.begins_with("_"):
		result = result.substr(1)
	while result.ends_with("_"):
		result = result.substr(0, result.length() - 1)
	return result if result != "" else "control"

func _social_input_bind_property(label_text: String) -> String:
	var text := label_text.strip_edges().to_lower()
	if text.contains("amigo"):
		return "_last_social_friend_username"
	if text.contains("guilda"):
		return "_last_social_guild_name"
	if text.contains("mensagem"):
		return "_last_social_chat_message"
	return ""

func _prepare_touch_button(button: Button) -> void:
	MobileUiContractScript.apply_touch_button(button)

func _apply_action_button_style(button: Button, action_id: String, surface_id: String = "") -> void:
	if button == null:
		return
	var style_id := UiTokens.action_button_style_id(action_id)
	var resolved_surface := surface_id.strip_edges()
	if resolved_surface == "":
		resolved_surface = _active_route_for_context()
	var accent_token := UiTokens.action_accent_token(action_id, resolved_surface)
	button.add_theme_color_override("font_color", UiTokens.color("text_on_accent" if style_id == "cta" else "text_primary"))
	button.add_theme_stylebox_override("normal", UiTokens.button_style(style_id, "normal", accent_token))
	button.add_theme_stylebox_override("hover", UiTokens.button_style(style_id, "hover", accent_token))
	button.add_theme_stylebox_override("pressed", UiTokens.button_style(style_id, "pressed", accent_token))
	button.add_theme_stylebox_override("focus", UiTokens.button_style(style_id, "hover", accent_token))


func _render_base_state(collected: Dictionary = {}) -> void:
	SurfaceUiHelpersScript.render_base_state(self, collected)
func _render_base_playable_panels(structures: Array, base: Dictionary, collected: Dictionary) -> void:
	SurfaceUiHelpersScript.render_base_playable_panels(self, structures, base, collected)
func _base_summary_panel(base: Dictionary, collected: Dictionary) -> Control:
	return SurfaceUiHelpersScript.base_summary_panel(self, base, collected)
func _base_map_panel(structures: Array) -> Control:
	return SurfaceUiHelpersScript.base_map_panel(self, structures)
func _base_detail_panel(structures: Array) -> Control:
	return SurfaceUiHelpersScript.base_detail_panel(self, structures)
func _base_structure_button(structure: Dictionary) -> Button:
	return SurfaceUiHelpersScript.base_structure_button(self, structure)
func _select_base_structure(structure_id: String) -> void:
	SurfaceUiHelpersScript.select_base_structure(self, structure_id)
func _ensure_selected_base_structure(structures: Array) -> void:
	SurfaceUiHelpersScript.ensure_selected_base_structure(self, structures)
func _base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	return SurfaceUiHelpersScript.base_structure_by_id(structures, structure_id)
func _base_panel() -> PanelContainer:
	return SurfaceUiHelpersScript.base_panel(self)
func _base_info_panel(title_text: String, body_text: String) -> Control:
	return SurfaceUiHelpersScript.base_info_panel(self, title_text, body_text)
func _base_label(text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	return SurfaceUiHelpersScript.base_label(self, text, color_token, font_size)
func _base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	return SurfaceUiHelpersScript.base_structure_card_style(structure_id, selected)
func _base_structure_color(structure_id: String) -> Color:
	return SurfaceUiHelpersScript.base_structure_color(structure_id)
func _base_structure_symbol(structure_id: String) -> String:
	return SurfaceUiHelpersScript.base_structure_symbol(structure_id)
func _base_structure_short_label(structure_id: String) -> String:
	return SurfaceUiHelpersScript.base_structure_short_label(structure_id)
func _base_benefit_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_benefit_text(structure)
func _base_pending_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_pending_text(structure)
func _base_upgrade_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_upgrade_text(structure)
func _base_next_level_text(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_next_level_text(structure)
func _base_short_status(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_short_status(structure)
func _base_status_color_token(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_status_color_token(structure)
func _base_structure_tooltip(structure: Dictionary) -> String:
	return SurfaceUiHelpersScript.base_structure_tooltip(structure)
func _can_upgrade_base_structure(structure_id: String) -> bool:
	return SurfaceUiHelpersScript.can_upgrade_base_structure(self, structure_id)
func _active_base_jobs(jobs: Array) -> Array:
	return SurfaceUiHelpersScript.active_base_jobs(jobs)
func _format_cost(cost: Dictionary) -> String:
	return SurfaceUiHelpersScript.format_cost(cost)
func _format_duration(total_seconds: int) -> String:
	return SurfaceUiHelpersScript.format_duration(total_seconds)
func _format_number(value: float) -> String:
	return SurfaceUiHelpersScript.format_number(value)
func _render_social_state() -> void:
	SurfaceUiHelpersScript.render_social_state(self)
func _social_identity_panel(identity: Dictionary, social_player: Dictionary, active_player: Dictionary) -> Control:
	return SurfaceUiHelpersScript.social_identity_panel(self, identity, social_player, active_player)
func _social_friends_panel(friends: Array) -> Control:
	return SurfaceUiHelpersScript.social_friends_panel(self, friends)
func _social_guild_panel(guild: Dictionary, members: Array, structures: Array) -> Control:
	return SurfaceUiHelpersScript.social_guild_panel(self, guild, members, structures)
func _social_chat_panel(messages: Array) -> Control:
	return SurfaceUiHelpersScript.social_chat_panel(self, messages)
func _social_input_text(input: LineEdit, fallback: String = "") -> String:
	return SurfaceUiHelpersScript.social_input_text(input, fallback)
func _default_social_guild_text() -> String:
	return SurfaceUiHelpersScript.default_social_guild_text(self)
func _social_username_text(profile: Dictionary) -> String:
	return SurfaceUiHelpersScript.social_username_text(profile)
func _social_save_badge_text(badge: String) -> String:
	return SurfaceUiHelpersScript.social_save_badge_text(badge)
func _guild_structure_label(structure_id: String) -> String:
	return SurfaceUiHelpersScript.guild_structure_label(structure_id)
func _render_competition_state() -> void:
	SurfaceUiHelpersScript.render_competition_state(self)
func _render_competition_panels(last_battle: Dictionary, matchmaking: Dictionary, ranking: Dictionary) -> void:
	SurfaceUiHelpersScript.render_competition_panels(self, last_battle, matchmaking, ranking)
func _competition_last_battle_panel(last_battle: Dictionary) -> Control:
	return SurfaceUiHelpersScript.competition_last_battle_panel(self, last_battle)
func _competition_matchmaking_panel(matchmaking: Dictionary) -> Control:
	return SurfaceUiHelpersScript.competition_matchmaking_panel(self, matchmaking)
func _competition_ranking_panel(ranking: Dictionary) -> Control:
	return SurfaceUiHelpersScript.competition_ranking_panel(self, ranking)
func _competition_entry_name(entry: Dictionary) -> String:
	return SurfaceUiHelpersScript.competition_entry_name(entry)
func _competition_result_text(result: String) -> String:
	return SurfaceUiHelpersScript.competition_result_text(result)
func _competition_scoring_model_text(model: String) -> String:
	return SurfaceUiHelpersScript.competition_scoring_model_text(model)
func _render_monetization_state() -> void:
	SurfaceUiHelpersScript.render_monetization_state(self)
func _render_shop_panels(monetization: Dictionary) -> void:
	SurfaceUiHelpersScript.render_shop_panels(self, monetization)
func _shop_summary_panel(summary: Dictionary) -> Control:
	return SurfaceUiHelpersScript.shop_summary_panel(self, summary)
func _shop_product_group_panel(title_text: String, products: Array) -> Control:
	return SurfaceUiHelpersScript.shop_product_group_panel(self, title_text, products)
func _shop_reward_group_panel(title_text: String, rewards: Array) -> Control:
	return SurfaceUiHelpersScript.shop_reward_group_panel(self, title_text, rewards)
func _shop_product_status_text(product: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_product_status_text(product)
func _shop_product_status_color(product: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_product_status_color(product)
func _shop_locked_reason_text(reason: String) -> String:
	return SurfaceUiHelpersScript.shop_locked_reason_text(reason)
func _shop_effect_text(effect: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_effect_text(effect)
func _format_shop_delta(delta: Dictionary, empty_text: String) -> String:
	return SurfaceUiHelpersScript.format_shop_delta(delta, empty_text)
func _shop_product_by_id(product_id: String) -> Dictionary:
	return SurfaceUiHelpersScript.shop_product_by_id(product_id)
func _shop_reward_by_id(reward_id: String) -> Dictionary:
	return SurfaceUiHelpersScript.shop_reward_by_id(reward_id)
func _shop_purchase_message(product_id: String, body: Dictionary) -> String:
	return SurfaceUiHelpersScript.shop_purchase_message(product_id, body)
