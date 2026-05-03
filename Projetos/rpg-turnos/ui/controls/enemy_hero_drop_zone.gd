class_name EnemyHeroDropZone
extends PanelContainer

signal card_dropped(data: Dictionary)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or str(data.get("kind", "")) != "battle_card":
		return false
	var card = ContentLibrary.get_card(str(data.get("card_id", "")))
	return card != null and card.is_damage_spell()

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	card_dropped.emit(Dictionary(data))
