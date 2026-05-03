class_name BattleSlotControl
extends PanelContainer

signal card_dropped(data: Dictionary, owner: String, slot_index: int)

var slot_owner: String = "player"
var slot_index: int = -1
var occupant: Variant = null

func setup(new_owner: String, new_slot_index: int, new_occupant: Variant) -> void:
	slot_owner = new_owner
	slot_index = new_slot_index
	occupant = new_occupant
	_rebuild()

func _rebuild() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
	custom_minimum_size = Vector2(172, 112)
	add_theme_stylebox_override("panel", _panel_style())

	var box: VBoxContainer = VBoxContainer.new()
	add_child(box)

	var label: Label = Label.new()
	label.text = "%s%d" % ["P" if slot_owner == "player" else "E", slot_index + 1]
	box.add_child(label)

	if occupant == null:
		var empty: Label = Label.new()
		empty.text = "Livre"
		box.add_child(empty)
	else:
		var data: Dictionary = occupant
		var name_label: Label = Label.new()
		name_label.text = str(data.get("name", "Carta"))
		name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(name_label)

		var stats: Label = Label.new()
		stats.text = "%d/%d %s" % [
			int(data.get("attack", 0)),
			int(data.get("health", 0)),
			"Pronta" if bool(data.get("ready", false)) else "Preparando"
		]
		box.add_child(stats)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or str(data.get("kind", "")) != "battle_card":
		return false
	var card = ContentLibrary.get_card(str(data.get("card_id", "")))
	if card == null:
		return false
	if slot_owner == "player":
		return card.occupies_slot() or card.is_buff_command()
	return card.is_damage_spell()

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	card_dropped.emit(Dictionary(data), slot_owner, slot_index)

func _panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.12, 0.13) if slot_owner == "player" else Color(0.15, 0.1, 0.11)
	style.border_color = Color(0.32, 0.5, 0.48) if slot_owner == "player" else Color(0.56, 0.32, 0.34)
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
