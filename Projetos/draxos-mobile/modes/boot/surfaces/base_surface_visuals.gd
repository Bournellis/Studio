class_name BootBaseSurfaceVisuals
extends RefCounted

static func base_panel(host: Node) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", panel_style(host, "bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return panel

static func base_info_panel(host: Node, title_text: String, body_text: String) -> Control:
	var panel := base_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(base_label(host, title_text, "text_primary", 17))
	box.add_child(base_label(host, body_text, "text_secondary"))
	return panel

static func base_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	if font_size > 0:
		label.add_theme_font_size_override("font_size", max(12, font_size - 1) if compact_layout(host) else font_size)
	elif compact_layout(host):
		label.add_theme_font_size_override("font_size", 13)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = structure_color(structure_id).darkened(0.25 if selected else 0.45)
	style.border_color = UiTokens.color("status_success") if selected else UiTokens.color("border_default")
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func structure_color(structure_id: String) -> Color:
	match structure_id:
		"altar_das_almas":
			return Color(0.45, 0.35, 0.78)
		"nucleo_energia":
			return Color(0.25, 0.58, 0.86)
		"pocos_sangue":
			return Color(0.70, 0.20, 0.26)
		"minas_cristal":
			return Color(0.22, 0.66, 0.62)
		"estrutura_stats":
			return Color(0.58, 0.58, 0.50)
		"ossario":
			return Color(0.72, 0.66, 0.54)
	return UiTokens.color("bg_panel_alt")

static func structure_symbol(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "Almas"
		"nucleo_energia":
			return "Energia"
		"pocos_sangue":
			return "Sangue"
		"minas_cristal":
			return "Cristais"
		"estrutura_stats":
			return "Poder"
		"ossario":
			return "Ossos"
	return "Refugio"

static func structure_short_label(structure_id: String) -> String:
	match structure_id:
		"altar_das_almas":
			return "Altar"
		"nucleo_energia":
			return "Nucleo"
		"pocos_sangue":
			return "Pocos"
		"minas_cristal":
			return "Minas"
		"estrutura_stats":
			return "Stats"
		"ossario":
			return "Ossario"
	return structure_id

static func panel_style(host: Node, bg_token: String, border_token: String) -> StyleBoxFlat:
	var surface_id := str(host.get("_current_screen"))
	return UiTokens.panel_style_from_tokens(
		bg_token,
		border_token,
		compact_layout(host),
		UiTokens.surface_accent_token(surface_id, border_token),
		1,
		6
	)

static func compact_layout(host: Node) -> bool:
	return bool(host.get("_compact_layout"))
