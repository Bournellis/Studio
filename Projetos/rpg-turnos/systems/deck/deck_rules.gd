class_name DeckRules
extends RefCounted

const REQUIRED_DECK_SIZE: int = 20
const COMMAND_DECK_LIMIT: int = 4
const CATALOG_PATH: String = "res://data/generated/slice_catalog.tres"

func validate(deck_ids: Array, unlocked_card_ids: Array) -> Dictionary:
	if deck_ids.size() != REQUIRED_DECK_SIZE:
		return {
			"ok": false,
			"message": "O deck precisa ter exatamente %d cartas." % REQUIRED_DECK_SIZE
		}

	var remaining: Array = unlocked_card_ids.duplicate()
	var command_count: int = 0
	for card_id: Variant in deck_ids:
		var normalized_id: String = str(card_id)
		var index: int = remaining.find(normalized_id)
		if index == -1:
			return {
				"ok": false,
				"message": "O deck contem uma carta nao desbloqueada: %s." % normalized_id
			}
		remaining.remove_at(index)
		var card = _find_card(normalized_id)
		if card != null and str(card.card_type) == "comando":
			command_count += 1

	if command_count > COMMAND_DECK_LIMIT:
		return {
			"ok": false,
			"message": "O deck pode ter no maximo %d cartas de comando." % COMMAND_DECK_LIMIT
		}

	return {"ok": true, "message": "Deck valido."}

func _find_card(card_id: String):
	var catalog = load(CATALOG_PATH)
	if catalog == null:
		return null
	return catalog.find_card(card_id)
