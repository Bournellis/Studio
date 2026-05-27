class_name BootHubSurfacePresenter
extends RefCounted

const HubAccountSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_account_surface_presenter.gd")

class RefugeAltarView:
	extends Control

	var compact := false

	func _init(is_compact: bool = false) -> void:
		compact = is_compact
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		custom_minimum_size = Vector2(260, 170) if compact else Vector2(420, 250)
		size_flags_horizontal = Control.SIZE_EXPAND_FILL

	func _draw() -> void:
		var rect := Rect2(Vector2.ZERO, size)
		draw_rect(rect, UiTokens.color("bg_deep").lightened(0.02), true)
		var center := rect.get_center()
		var altar_width := minf(size.x * 0.58, 280.0)
		var altar_height := minf(size.y * 0.32, 86.0)
		var base_y := size.y * 0.72
		var top_y := base_y - altar_height
		var base_color := UiTokens.color("accent_bone").darkened(0.25)
		var blood_color := UiTokens.color("accent_blood").darkened(0.2)
		var astral_color := UiTokens.color("accent_astral")
		var platform := PackedVector2Array([
			Vector2(center.x - altar_width * 0.52, base_y),
			Vector2(center.x + altar_width * 0.52, base_y),
			Vector2(center.x + altar_width * 0.36, top_y),
			Vector2(center.x - altar_width * 0.36, top_y),
		])
		draw_polygon(platform, PackedColorArray([base_color, base_color, base_color.lightened(0.08), base_color.lightened(0.08)]))
		draw_line(Vector2(center.x - altar_width * 0.42, top_y), Vector2(center.x + altar_width * 0.42, top_y), UiTokens.color("accent_astral"), 3.0)
		draw_line(Vector2(center.x - altar_width * 0.20, base_y), Vector2(center.x, top_y - 38.0), blood_color, 3.0)
		draw_line(Vector2(center.x + altar_width * 0.20, base_y), Vector2(center.x, top_y - 38.0), blood_color, 3.0)
		draw_line(Vector2(center.x, top_y - 54.0), Vector2(center.x, top_y - 8.0), astral_color.lightened(0.2), 5.0)
		draw_line(Vector2(center.x - 36.0, top_y - 22.0), Vector2(center.x + 36.0, top_y - 22.0), astral_color.darkened(0.1), 3.0)
		for index: int in range(5):
			var x := lerpf(center.x - altar_width * 0.44, center.x + altar_width * 0.44, float(index) / 4.0)
			draw_line(Vector2(x, base_y + 12.0), Vector2(center.x, top_y - 30.0), UiTokens.color("border_default").lightened(0.08), 1.2)

static func render(host: Node) -> void:
	var compact := bool(host.get("_compact_layout"))
	_render_refuge_scene(host, compact)
	_render_home_status(host)
	_render_hotspots(host, compact)
	_render_dev_labs(host, compact)

static func _render_refuge_scene(host: Node, compact: bool) -> void:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(host, "bg_deep", "border_active"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6 if compact else 8)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(box)

	var title := Label.new()
	title.text = "Altar do Refugio"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20 if compact else 26)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "O centro vivo da conta: entre, escolha uma rota e volte sempre para este ponto."
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13 if compact else 15)
	subtitle.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	box.add_child(subtitle)

	box.add_child(RefugeAltarView.new(compact))
	host.call("_add_content_control", panel)

static func _render_home_status(host: Node) -> void:
	_add_section_label(host, "Estado do Refugio")
	_add_output_label(host, HubAccountSurfacePresenterScript.home_account_summary_text(host))

static func _render_hotspots(host: Node, compact: bool) -> void:
	_add_section_label(host, "Hotspots")
	var grid := _hotspot_grid(host, compact)
	_add_route_hotspot(host, grid, compact, "Batalha", "Pedir batalha e ver replay server-authoritative.", "battle_entry", "accent_blood")
	_add_route_hotspot(host, grid, compact, "Base", "Coletar, evoluir estruturas e acompanhar rotina.", "base", "accent_astral")
	_add_route_hotspot(host, grid, compact, "Social", "Amigos, guilda e chat por polling.", "social", "status_success")
	_add_route_hotspot(host, grid, compact, "Competicao", "Preview de matchmaking e ranking alpha.", "competition", "status_warning")
	_add_route_hotspot(host, grid, compact, "Loja", "Redeems, recompensas e compras alpha.", "shop", "accent_bone")
	_add_route_hotspot(host, grid, compact, "Perfil/Conta", "Login, registro, saves, guest dev e updates.", "account", "border_active")
	host.call("_add_content_control", grid)

static func _render_dev_labs(host: Node, compact: bool) -> void:
	var battle_lab := bool(host.call("_battle_lab_available"))
	var progression_lab := bool(host.call("_progression_lab_available"))
	if not battle_lab and not progression_lab:
		return
	_add_section_label(host, "Labs dev")
	var grid := _hotspot_grid(host, compact)
	if battle_lab:
		_add_action_hotspot(host, grid, compact, "Battle Lab", "Abrir o laboratorio interno de batalha.", "open_battle_lab", "accent_blood")
	if progression_lab:
		_add_action_hotspot(host, grid, compact, "Progression Lab", "Abrir o laboratorio interno de progressao.", "open_progression_lab", "accent_astral")
	host.call("_add_content_control", grid)

static func _hotspot_grid(host: Node, compact: bool) -> GridContainer:
	var grid := GridContainer.new()
	var viewport_size := (host as Control).get_viewport_rect().size if host is Control else Vector2.ZERO
	grid.columns = 3 if (not compact or viewport_size.x >= 900.0) else 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8 if compact else 10)
	grid.add_theme_constant_override("v_separation", 8 if compact else 10)
	return grid

static func _add_route_hotspot(host: Node, grid: GridContainer, compact: bool, title: String, detail: String, route_id: String, color_token: String) -> void:
	var button := _hotspot_button(host, compact, title, detail, color_token)
	var target_route := str(host.call("_normalize_route", route_id))
	button.pressed.connect(func() -> void:
		host.call("_show_screen", target_route)
	)
	grid.add_child(button)

static func _add_action_hotspot(host: Node, grid: GridContainer, compact: bool, title: String, detail: String, action_id: String, color_token: String) -> void:
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
	button.custom_minimum_size = Vector2(132, 68) if compact else Vector2(170, 82)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	button.add_theme_stylebox_override("normal", _hotspot_style(color_token, false))
	button.add_theme_stylebox_override("hover", _hotspot_style(color_token, true))
	button.add_theme_stylebox_override("pressed", _hotspot_style(color_token, true))
	host.call("_prepare_touch_button", button)
	return button

static func _hotspot_style(color_token: String, active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color("bg_panel").lerp(UiTokens.color(color_token), 0.16 if active else 0.08)
	style.border_color = UiTokens.color(color_token)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

static func _panel_style(host: Node, bg_token: String, border_token: String) -> StyleBoxFlat:
	return host.call("_panel_style", bg_token, border_token) as StyleBoxFlat

static func _add_section_label(host: Node, text: String) -> Label:
	return host.call("_add_section_label", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label
