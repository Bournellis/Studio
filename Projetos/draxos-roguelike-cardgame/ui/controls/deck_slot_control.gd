class_name DeckSlotControl
extends PanelContainer

const CardTokenScript = preload("res://ui/controls/card_token.gd")

signal card_dropped(card_id: String, slot_index: int, source: String, source_index: int)
signal clear_requested(slot_index: int)

var slot_index: int = -1
var card_id: String = ""

func setup(new_slot_index: int, new_card_id: String) -> void:
	slot_index = new_slot_index
	card_id = new_card_id
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = Vector2(156, 124)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_theme_stylebox_override("panel", _panel_style())

	var box: VBoxContainer = VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(box)

	var header: Label = Label.new()
	header.text = "Slot %02d" % (slot_index + 1)
	box.add_child(header)

	if card_id == "":
		var empty: Label = Label.new()
		empty.text = "Arraste uma carta aqui"
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(empty)
	else:
		var token = CardTokenScript.new()
		token.setup(card_id, "deck", slot_index, true)
		token.card_dropped_on_token.connect(_on_card_dropped_on_token)
		box.add_child(token)

		var clear_button: Button = Button.new()
		clear_button.text = "Remover"
		clear_button.pressed.connect(func() -> void: clear_requested.emit(slot_index))
		box.add_child(clear_button)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and str(data.get("kind", "")) == "card"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	card_dropped.emit(str(data.get("card_id", "")), slot_index, str(data.get("source", "")), int(data.get("source_index", -1)))

func _on_card_dropped_on_token(data: Dictionary) -> void:
	card_dropped.emit(str(data.get("card_id", "")), slot_index, str(data.get("source", "")), int(data.get("source_index", -1)))

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.1, 0.12)
	style.border_color = Color(0.34, 0.36, 0.38)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	return style
