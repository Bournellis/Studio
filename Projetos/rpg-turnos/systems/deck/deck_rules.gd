class_name DeckRules
extends RefCounted

const REQUIRED_DECK_SIZE: int = 10

func validate(deck_ids: Array, unlocked_card_ids: Array) -> Dictionary:
	if deck_ids.size() != REQUIRED_DECK_SIZE:
		return {
			"ok": false,
			"message": "O deck precisa ter exatamente %d cartas." % REQUIRED_DECK_SIZE
		}

	var remaining: Array = unlocked_card_ids.duplicate()
	for card_id: Variant in deck_ids:
		var index: int = remaining.find(str(card_id))
		if index == -1:
			return {
				"ok": false,
				"message": "O deck contem uma carta nao desbloqueada: %s." % str(card_id)
			}
		remaining.remove_at(index)

	return {"ok": true, "message": "Deck valido."}
