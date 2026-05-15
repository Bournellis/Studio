extends Control

var slot_buttons: Array[Button] = []
var message_label: Label
var new_game_button: Button
var continue_button: Button
var delete_button: Button
var delete_modal: PanelContainer
var delete_label: Label

func _ready() -> void:
	ContentLibrary.ensure_loaded()
	VisualAssets.ensure_loaded()
	SaveManager.select_slot(SaveManager.current_slot_index)
	_build_ui()
	_refresh()

func _build_ui() -> void:
	var background: Control = VisualAssets.build_surface_background("main_menu_background")
	background.name = "MainMenuVisualBackground"
	add_child(background)

	var scrim: ColorRect = ColorRect.new()
	scrim.name = "MainMenuScrim"
	scrim.color = Color(0.0, 0.0, 0.0, 0.30)
	scrim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scrim)

	var title: Label = Label.new()
	title.name = "MainMenuTitle"
	title.text = "Draxos: Invasão Elemental"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	title.anchor_left = 0.0
	title.anchor_top = 0.08
	title.anchor_right = 1.0
	title.anchor_bottom = 0.08
	title.offset_bottom = 58.0
	add_child(title)

	var panel: PanelContainer = PanelContainer.new()
	panel.name = "MainMenuSavePanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 1.0
	panel.anchor_right = 0.5
	panel.anchor_bottom = 1.0
	panel.offset_left = -430.0
	panel.offset_top = -250.0
	panel.offset_right = 430.0
	panel.offset_bottom = -30.0
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.04, 0.05, 0.06, 0.72), Color(0.54, 0.68, 0.74, 0.78)))
	add_child(panel)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var slot_row: HBoxContainer = HBoxContainer.new()
	slot_row.name = "MainMenuSlotRow"
	slot_row.add_theme_constant_override("separation", 10)
	box.add_child(slot_row)

	for index: int in range(1, SaveManager.SLOT_COUNT + 1):
		var button: Button = Button.new()
		button.name = "MainMenuSlot%d" % index
		button.custom_minimum_size = Vector2(260, 90)
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.pressed.connect(func() -> void:
			SaveManager.select_slot(index)
			_refresh()
		)
		slot_buttons.append(button)
		slot_row.add_child(button)

	var action_row: HBoxContainer = HBoxContainer.new()
	action_row.name = "MainMenuActions"
	action_row.add_theme_constant_override("separation", 10)
	box.add_child(action_row)

	new_game_button = _build_action_button("MainMenuNewGameButton", "Novo Jogo")
	new_game_button.pressed.connect(_on_new_game_pressed)
	action_row.add_child(new_game_button)

	continue_button = _build_action_button("MainMenuContinueButton", "Continuar")
	continue_button.pressed.connect(_on_continue_pressed)
	action_row.add_child(continue_button)

	delete_button = _build_action_button("MainMenuDeleteButton", "Deletar")
	delete_button.pressed.connect(_open_delete_modal)
	action_row.add_child(delete_button)

	message_label = Label.new()
	message_label.name = "MainMenuMessage"
	message_label.text = ""
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 13)
	message_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 0.86))
	box.add_child(message_label)

	_build_delete_modal()

func _build_delete_modal() -> void:
	delete_modal = PanelContainer.new()
	delete_modal.name = "MainMenuDeleteConfirmModal"
	delete_modal.visible = false
	delete_modal.anchor_left = 0.5
	delete_modal.anchor_top = 0.5
	delete_modal.anchor_right = 0.5
	delete_modal.anchor_bottom = 0.5
	delete_modal.offset_left = -190.0
	delete_modal.offset_top = -96.0
	delete_modal.offset_right = 190.0
	delete_modal.offset_bottom = 96.0
	delete_modal.add_theme_stylebox_override("panel", _panel_style(Color(0.05, 0.055, 0.065, 0.96), Color(0.82, 0.46, 0.40, 0.94)))
	add_child(delete_modal)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	delete_modal.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	delete_label = Label.new()
	delete_label.name = "MainMenuDeleteConfirmText"
	delete_label.text = ""
	delete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	delete_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	delete_label.add_theme_font_size_override("font_size", 16)
	delete_label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	box.add_child(delete_label)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)

	var confirm_button: Button = _build_action_button("MainMenuDeleteConfirmButton", "Confirmar")
	confirm_button.pressed.connect(func() -> void:
		var result: Dictionary = SaveManager.delete_slot(SaveManager.current_slot_index)
		message_label.text = str(result.get("message", ""))
		delete_modal.visible = false
		_refresh()
	)
	row.add_child(confirm_button)

	var cancel_button: Button = _build_action_button("MainMenuDeleteCancelButton", "Cancelar")
	cancel_button.pressed.connect(func() -> void:
		delete_modal.visible = false
	)
	row.add_child(cancel_button)

func _refresh() -> void:
	var slots: Array[Dictionary] = SaveManager.get_slots()
	for info: Dictionary in slots:
		var index: int = int(info.get("index", 1))
		var button: Button = slot_buttons[index - 1]
		button.text = "Save %d\n%s" % [index, str(info.get("summary", "Vazio"))]
		var selected: bool = bool(info.get("selected", false))
		button.add_theme_stylebox_override("normal", _slot_style(selected, false))
		button.add_theme_stylebox_override("hover", _slot_style(selected, true))
		button.add_theme_stylebox_override("pressed", _slot_style(true, true))
	var selected_info: Dictionary = slots[SaveManager.current_slot_index - 1]
	var has_save: bool = bool(selected_info.get("exists", false))
	var has_save_file: bool = bool(selected_info.get("has_file", has_save))
	new_game_button.disabled = has_save
	continue_button.disabled = not has_save
	delete_button.disabled = not has_save_file

func _on_new_game_pressed() -> void:
	var result: Dictionary = SaveManager.begin_new_game(SaveManager.current_slot_index)
	if not bool(result.get("ok", false)):
		message_label.text = str(result.get("message", ""))
		_refresh()
		return
	get_tree().change_scene_to_file("res://modes/ship_hub/ship_hub.tscn")

func _on_continue_pressed() -> void:
	var result: Dictionary = SaveManager.load_slot(SaveManager.current_slot_index)
	if not bool(result.get("ok", false)):
		message_label.text = str(result.get("message", ""))
		_refresh()
		return
	get_tree().change_scene_to_file("res://modes/ship_hub/ship_hub.tscn")

func _open_delete_modal() -> void:
	delete_label.text = "Deletar Save %d?" % SaveManager.current_slot_index
	delete_modal.visible = true

func _build_action_button(node_name: String, text: String) -> Button:
	var button: Button = Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(0, 44)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 16
	style.content_margin_top = 14
	style.content_margin_right = 16
	style.content_margin_bottom = 14
	return style

func _slot_style(selected: bool, hover: bool) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.07, 0.72 if not hover else 0.86)
	style.border_color = Color(0.86, 0.72, 0.38, 0.96) if selected else Color(0.42, 0.52, 0.58, 0.70)
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 10
	style.content_margin_top = 8
	style.content_margin_right = 10
	style.content_margin_bottom = 8
	return style
