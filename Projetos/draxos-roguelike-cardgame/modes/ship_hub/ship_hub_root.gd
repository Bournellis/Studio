extends Control

const CLASS_ORDER: Array[String] = ["invocador", "arcano", "necromante"]
const ShipOverlayButtonScript = preload("res://ui/controls/ship_overlay_button.gd")

var state_label: Label
var class_message_label: Label
var class_modal: PanelContainer
var name_modal: PanelContainer
var name_line_edit: LineEdit
var name_message_label: Label
var esc_menu: PanelContainer
var overlay_layer: Control
var pending_class_id: String = ""

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	VisualAssets.ensure_loaded()
	_build_ui()
	if SaveManager.pending_new_game or not RunSession.has_selected_class():
		_open_class_modal()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		var viewport: Viewport = get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()
		if name_modal != null and name_modal.visible:
			return
		if class_modal != null and class_modal.visible:
			return
		_toggle_esc_menu()

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("ship_hub_background")
	background.name = "ShipHubVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "ShipHubVisualScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.18)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var title: Label = Label.new()
	title.name = "ShipHubTitle"
	title.text = "Nave Draxos"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title.anchor_left = 0.03
	title.anchor_top = 0.04
	title.anchor_right = 0.5
	title.anchor_bottom = 0.04
	title.offset_bottom = 42.0
	add_child(title)

	overlay_layer = Control.new()
	overlay_layer.name = "ShipHubSceneOverlays"
	overlay_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay_layer)
	_refresh_ship_overlays()

	_build_class_modal()
	_build_name_modal()
	_build_esc_menu()

func _refresh_ship_overlays() -> void:
	if overlay_layer == null:
		return
	for child: Node in overlay_layer.get_children():
		overlay_layer.remove_child(child)
		child.queue_free()
	_add_ship_overlay("souls", _open_souls)
	_add_ship_overlay("map", _open_map)
	_add_ship_overlay("deck", _open_deck)

func _add_ship_overlay(overlay_id: String, callback: Callable) -> void:
	var overlay = ShipOverlayButtonScript.new()
	overlay.name = "ShipHubOverlay_%s" % overlay_id
	_apply_ship_overlay_rect(overlay, overlay_id)
	var texture: Texture2D = VisualAssets.ship_overlay_texture(overlay_id, RunSession.selected_class_id)
	overlay.setup(
		overlay_id,
		texture,
		VisualAssets.ship_overlay_label(overlay_id),
		VisualAssets.ship_overlay_color(overlay_id)
	)
	overlay.pressed.connect(callback)
	overlay_layer.add_child(overlay)

func _apply_ship_overlay_rect(control: Control, overlay_id: String) -> void:
	var position: Vector2 = VisualAssets.ship_overlay_position(overlay_id)
	var overlay_size: Vector2 = VisualAssets.ship_overlay_size(overlay_id)
	control.anchor_left = clampf(position.x - overlay_size.x * 0.5, 0.0, 1.0)
	control.anchor_top = clampf(position.y - overlay_size.y * 0.5, 0.0, 1.0)
	control.anchor_right = clampf(position.x + overlay_size.x * 0.5, 0.0, 1.0)
	control.anchor_bottom = clampf(position.y + overlay_size.y * 0.5, 0.0, 1.0)
	control.offset_left = 0.0
	control.offset_top = 0.0
	control.offset_right = 0.0
	control.offset_bottom = 0.0

func _build_class_modal() -> void:
	class_modal = PanelContainer.new()
	class_modal.name = "ShipHubClassChoiceModal"
	class_modal.visible = false
	class_modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	class_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.015, 0.018, 0.024, 0.92), Color(0.68, 0.58, 0.38, 0.88)))
	add_child(class_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 46)
	margin.add_theme_constant_override("margin_top", 44)
	margin.add_theme_constant_override("margin_right", 46)
	margin.add_theme_constant_override("margin_bottom", 42)
	class_modal.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var title: Label = Label.new()
	title.name = "ShipHubClassChoiceTitle"
	title.text = "Escolha a Classe"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	class_message_label = Label.new()
	class_message_label.name = "ShipHubClassChoiceMessage"
	class_message_label.text = ""
	class_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	class_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	class_message_label.add_theme_font_size_override("font_size", 14)
	class_message_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.48, 0.95))
	box.add_child(class_message_label)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "ShipHubClassChoiceRow"
	row.add_theme_constant_override("separation", 18)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(row)

	for class_id: String in CLASS_ORDER:
		var class_option: Dictionary = ContentLibrary.find_class_option(class_id)
		if class_option.is_empty():
			continue
		row.add_child(_build_class_button(class_option))

func _build_class_button(class_option: Dictionary) -> Button:
	var class_id: String = str(class_option.get("id", ""))
	var button: Button = Button.new()
	button.name = "ShipHubClass_%s" % class_id
	button.text = ""
	button.tooltip_text = "%s\n%s" % [str(class_option.get("role_text", "")), str(class_option.get("active_text", ""))]
	button.custom_minimum_size = Vector2(260, 480)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.clip_contents = true
	var texture: Texture2D = VisualAssets.class_portrait_texture(class_id)
	var margin: MarginContainer = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 12)
	button.add_child(margin)
	var box: VBoxContainer = VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)
	var portrait: TextureRect = TextureRect.new()
	portrait.name = "ShipHubClassPortrait_%s" % class_id
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.custom_minimum_size = Vector2(0, 360)
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.size_flags_vertical = Control.SIZE_EXPAND_FILL
	portrait.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if texture != null:
		portrait.texture = texture
	box.add_child(portrait)
	var label: Label = Label.new()
	label.name = "ShipHubClassName_%s" % class_id
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = str(class_option.get("display_name", class_id))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(label)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_stylebox_override("normal", _button_style(VisualAssets.class_portrait_color(class_id), false))
	button.add_theme_stylebox_override("hover", _button_style(VisualAssets.class_portrait_color(class_id), true))
	button.add_theme_stylebox_override("pressed", _button_style(VisualAssets.class_portrait_color(class_id), true))
	button.pressed.connect(func() -> void:
		_open_name_modal(class_id)
	)
	return button

func _build_name_modal() -> void:
	name_modal = PanelContainer.new()
	name_modal.name = "ShipHubPlayerNameModal"
	name_modal.visible = false
	name_modal.anchor_left = 0.5
	name_modal.anchor_top = 0.5
	name_modal.anchor_right = 0.5
	name_modal.anchor_bottom = 0.5
	name_modal.offset_left = -220.0
	name_modal.offset_top = -122.0
	name_modal.offset_right = 220.0
	name_modal.offset_bottom = 122.0
	name_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.04, 0.052, 0.98), Color(0.68, 0.58, 0.38, 0.95)))
	add_child(name_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 14)
	name_modal.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	var title: Label = Label.new()
	title.name = "ShipHubPlayerNameTitle"
	title.text = "Nome do Jogador"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	name_line_edit = LineEdit.new()
	name_line_edit.name = "ShipHubPlayerNameInput"
	name_line_edit.placeholder_text = RunSession.DEFAULT_PLAYER_NAME
	name_line_edit.max_length = RunSession.MAX_PLAYER_NAME_LENGTH
	name_line_edit.text_submitted.connect(func(_text: String) -> void:
		_confirm_player_name()
	)
	box.add_child(name_line_edit)

	name_message_label = Label.new()
	name_message_label.name = "ShipHubPlayerNameMessage"
	name_message_label.text = ""
	name_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_message_label.add_theme_font_size_override("font_size", 13)
	name_message_label.add_theme_color_override("font_color", Color(0.92, 0.78, 0.48, 0.95))
	box.add_child(name_message_label)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)

	var confirm_button: Button = _build_menu_button("ShipHubPlayerNameConfirm", "Confirmar")
	confirm_button.pressed.connect(_confirm_player_name)
	row.add_child(confirm_button)

	var back_button: Button = _build_menu_button("ShipHubPlayerNameBack", "Voltar")
	back_button.pressed.connect(func() -> void:
		name_modal.visible = false
		pending_class_id = ""
	)
	row.add_child(back_button)

func _build_esc_menu() -> void:
	esc_menu = PanelContainer.new()
	esc_menu.name = "ShipHubEscMenu"
	esc_menu.visible = false
	esc_menu.anchor_left = 0.5
	esc_menu.anchor_top = 0.5
	esc_menu.anchor_right = 0.5
	esc_menu.anchor_bottom = 0.5
	esc_menu.offset_left = -170.0
	esc_menu.offset_top = -114.0
	esc_menu.offset_right = 170.0
	esc_menu.offset_bottom = 114.0
	esc_menu.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.045, 0.052, 0.96), Color(0.68, 0.58, 0.38, 0.95)))
	add_child(esc_menu)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	esc_menu.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var title: Label = Label.new()
	title.text = "Pausa"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(title)

	var menu_button: Button = _build_menu_button("ShipHubEscMainMenuButton", "Menu Principal")
	menu_button.pressed.connect(func() -> void:
		_autosave()
		get_tree().change_scene_to_file("res://modes/boot/boot.tscn")
	)
	box.add_child(menu_button)

	var quit_button: Button = _build_menu_button("ShipHubEscQuitButton", "Fechar Jogo")
	quit_button.pressed.connect(func() -> void:
		_autosave()
		get_tree().quit()
	)
	box.add_child(quit_button)

	var cancel_button: Button = _build_menu_button("ShipHubEscCancelButton", "Cancelar")
	cancel_button.pressed.connect(func() -> void:
		esc_menu.visible = false
	)
	box.add_child(cancel_button)

func _open_class_modal() -> void:
	if class_message_label != null:
		class_message_label.text = ""
	class_modal.visible = true

func _open_name_modal(class_id: String) -> void:
	pending_class_id = class_id
	if name_message_label != null:
		name_message_label.text = ""
	if name_line_edit != null:
		name_line_edit.text = ""
	if name_modal != null:
		name_modal.visible = true
		name_line_edit.grab_focus()

func _confirm_player_name() -> void:
	if pending_class_id == "":
		return
	var requested_name: String = name_line_edit.text if name_line_edit != null else ""
	var validation: Dictionary = RunSession.validate_player_name(requested_name)
	if not bool(validation.get("ok", false)):
		if name_message_label != null:
			name_message_label.text = str(validation.get("message", "Nome invalido."))
		return
	_start_class_run(pending_class_id, str(validation.get("name", "")))

func _start_class_run(class_id: String, player_name: String) -> void:
	var result: Dictionary = RunSession.start_class_run(class_id, SaveManager.random_run_seed(), player_name)
	if not bool(result.get("ok", false)):
		if name_message_label != null:
			name_message_label.text = str(result.get("message", ""))
		return
	SaveManager.pending_new_game = false
	var save_result: Dictionary = SaveManager.save_current_run()
	if not bool(save_result.get("ok", false)):
		if name_message_label != null:
			name_message_label.text = str(save_result.get("message", ""))
		elif class_message_label != null:
			class_message_label.text = str(save_result.get("message", ""))
		return
	pending_class_id = ""
	if name_modal != null:
		name_modal.visible = false
	class_modal.visible = false
	_refresh_ship_overlays()

func _open_deck() -> void:
	_autosave()
	get_tree().change_scene_to_file("res://modes/deck/deck.tscn")

func _open_map() -> void:
	if RunSession.active and RunSession.current_node_id == "":
		RunSession.select_next_available_node()
	_autosave()
	get_tree().change_scene_to_file("res://modes/run_map/run_map.tscn")

func _open_souls() -> void:
	_autosave()
	get_tree().change_scene_to_file("res://modes/souls/souls.tscn")

func _toggle_esc_menu() -> void:
	if esc_menu != null:
		esc_menu.visible = not esc_menu.visible

func _refresh_state() -> void:
	return
	if not RunSession.active:
		state_label.text = "Classe: -\nMapa: -\nHP: -\nMana: -\nMão: -\nAlmas: -"
		return
	state_label.text = "Classe: %s\nMapa: %s\nHP: %d/%d\nMana: %d\nMão: %d\nAlmas: %d" % [
		RunSession.selected_class_display_name,
		RunSession.current_node_display_name(),
		RunSession.current_health,
		RunSession.max_health,
		RunSession.max_mana,
		RunSession.max_hand_size,
		RunSession.soul_total
	]

func _autosave() -> void:
	if RunSession.active and RunSession.has_selected_class():
		SaveManager.save_current_run()

func _build_menu_button(node_name: String, text: String) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(0, 40)
	return button

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_top = 10
	style.content_margin_right = 10
	style.content_margin_bottom = 10
	return style

func _button_style(base: Color, hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(base.r * 0.35, base.g * 0.35, base.b * 0.35, 0.58 if not hover else 0.78)
	style.border_color = Color(base.r, base.g, base.b, 0.78 if not hover else 1.0)
	style.set_border_width_all(1 if not hover else 2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_top = 10
	style.content_margin_right = 12
	style.content_margin_bottom = 10
	return style
