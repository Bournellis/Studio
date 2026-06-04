class_name BootHubSurfaceCommonPresenter
extends RefCounted

const TouchScrollContainerScript := preload("res://modes/boot/ui/touch_scroll_container.gd")

static func _forget_action_buttons_in_tree(host: Node, root: Node) -> void:
	var action_buttons := host.get("_action_buttons") as Dictionary
	for action_id: String in action_buttons.keys():
		var button := action_buttons.get(action_id) as Button
		if button != null and is_instance_valid(button) and _node_is_inside(button, root):
			action_buttons.erase(action_id)

static func _node_is_inside(node: Node, root: Node) -> bool:
	var cursor := node
	while cursor != null:
		if cursor == root:
			return true
		cursor = cursor.get_parent()
	return false

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

static func _popup_panel_style(compact: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_deep").lerp(UiTokens.color("accent_astral"), 0.07)
	style.bg_color.a = 1.0
	style.border_color = UiTokens.color("accent_astral")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10 if compact else 12)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style

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

static func _refuge_has_dev_tools(host: Node) -> bool:
	return bool(host.call("_battle_lab_available")) \
		or bool(host.call("_progression_lab_available")) \
		or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/dev_tools_enabled", false))

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

static func _short_account_status() -> String:
	if SessionStore.is_progression_lab_local_only() and SessionStore.has_account_state():
		return "Lab local: %s" % SessionStore.progression_lab_label()
	if SessionStore.has_account_state():
		return "%s | Nivel %s | Poder %s" % [
			SessionStore.player_display_name(),
			str(SessionStore.player_snapshot().get("level", 1)),
			str(SessionStore.player_snapshot().get("power", 0)),
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
