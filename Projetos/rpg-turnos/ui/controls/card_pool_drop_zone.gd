class_name CardPoolDropZone
extends FlowContainer

signal deck_card_returned(deck_index: int)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and str(data.get("kind", "")) == "card" and str(data.get("source", "")) == "deck"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	deck_card_returned.emit(int(data.get("source_index", -1)))
