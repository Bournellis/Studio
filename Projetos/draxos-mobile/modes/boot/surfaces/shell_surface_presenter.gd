class_name BootShellSurfacePresenter
extends RefCounted

const ProjectInfoScript := preload("res://core/project_info.gd")
const TouchScrollContainerScript := preload("res://modes/boot/ui/touch_scroll_container.gd")

static func render(host: Control) -> void:
	var compact := bool(host.get("_compact_layout"))
	var background := ColorRect.new()
	background.color = UiTokens.color("bg_deep")
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(background)

	var root := VBoxContainer.new()
	root.name = "AppShellChromeRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 8 if compact else 16
	root.offset_top = 8 if compact else 12
	root.offset_right = -8 if compact else -16
	root.offset_bottom = -8 if compact else -12
	root.add_theme_constant_override("separation", 6 if compact else 10)
	host.add_child(root)
	host.set("_app_chrome_root", root)

	_render_header(host, root, compact)
	_render_content_shell(host, root, compact)
	_render_confirmation_dialog(host)

static func _render_header(host: Control, root: VBoxContainer, compact: bool) -> void:
	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", _panel_style(host, "bg_panel", "border_default"))
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(header)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 5 if compact else 8)
	header.add_child(header_box)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8 if compact else 10)
	header_box.add_child(title_row)

	var title_stack := VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title_stack)

	var title := Label.new()
	title.text = "DraxosMobile"
	title.add_theme_font_size_override("font_size", 20 if compact else 24)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title_stack.add_child(title)

	var status_label := Label.new()
	status_label.text = "%s - primeiro slice" % ProjectInfoScript.PROJECT_NAME
	status_label.autowrap_mode = TextServer.AUTOWRAP_OFF if compact else TextServer.AUTOWRAP_WORD_SMART
	if compact:
		status_label.clip_text = true
		status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	title_stack.add_child(status_label)
	host.set("_status_label", status_label)

	var back_button := Button.new()
	back_button.text = "<" if compact else "Voltar"
	back_button.tooltip_text = "Voltar para a tela anterior."
	back_button.custom_minimum_size = Vector2(64, 48) if compact else Vector2(110, 42)
	host.call("_prepare_touch_button", back_button)
	back_button.pressed.connect(Callable(host, "_go_back"))
	title_row.add_child(back_button)
	host.set("_back_button", back_button)

static func _render_content_shell(host: Control, root: VBoxContainer, compact: bool) -> void:
	var content_panel := PanelContainer.new()
	content_panel.add_theme_stylebox_override("panel", _panel_style(host, "bg_panel_alt", "border_default"))
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(content_panel)

	var content_stack := VBoxContainer.new()
	content_stack.add_theme_constant_override("separation", 6 if compact else 8)
	content_panel.add_child(content_stack)

	var content_title := Label.new()
	content_title.add_theme_font_size_override("font_size", 18 if compact else 22)
	content_title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	content_stack.add_child(content_title)
	host.set("_content_title", content_title)

	var detail_label := Label.new()
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if compact:
		detail_label.add_theme_font_size_override("font_size", 13)
	detail_label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	content_stack.add_child(detail_label)
	host.set("_detail_label", detail_label)

	var error_label := Label.new()
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if compact:
		error_label.add_theme_font_size_override("font_size", 13)
	error_label.add_theme_color_override("font_color", UiTokens.color("status_error"))
	content_stack.add_child(error_label)
	host.set("_error_label", error_label)

	content_stack.add_child(HSeparator.new())

	var scroll := TouchScrollContainerScript.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_stack.add_child(scroll)
	host.set("_content_scroll", scroll)

	var content_body := VBoxContainer.new()
	content_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_body.add_theme_constant_override("separation", 8 if compact else 10)
	scroll.add_child(content_body)
	host.set("_content_body", content_body)

static func _render_confirmation_dialog(host: Control) -> void:
	var confirm_dialog := ConfirmationDialog.new()
	confirm_dialog.title = "Confirmar acao"
	confirm_dialog.dialog_text = ""
	confirm_dialog.confirmed.connect(Callable(host, "_on_confirmation_confirmed"))
	host.add_child(confirm_dialog)
	confirm_dialog.get_ok_button().text = "Confirmar"
	confirm_dialog.get_cancel_button().text = "Voltar"
	host.set("_confirm_dialog", confirm_dialog)

static func _panel_style(host: Control, background_token: String, border_token: String) -> StyleBoxFlat:
	return host.call("_panel_style", background_token, border_token) as StyleBoxFlat
