extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const DeckSetupRootScript = preload("res://modes/battle/deck_setup_root.gd")
const DeckSlotControlScript = preload("res://ui/controls/deck_slot_control.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()

func test_drop_over_occupied_deck_card_reaches_slot() -> void:
	var slot = DeckSlotControlScript.new()
	add_child(slot)
	slot.setup(0, "escudeiro")

	var dropped: Array = []
	slot.card_dropped.connect(func(card_id: String, slot_index: int, source: String, source_index: int) -> void:
		dropped.append([card_id, slot_index, source, source_index])
	)

	var token = _find_drop_enabled_card_token(slot)
	assert_not_null(token)

	var payload: Dictionary = {
		"kind": "card",
		"card_id": "golpe_preciso",
		"source": "pool",
		"source_index": 0
	}
	assert_true(bool(token._can_drop_data(Vector2.ZERO, payload)))
	token._drop_data(Vector2.ZERO, payload)

	assert_eq(dropped, [["golpe_preciso", 0, "pool", 0]])
	slot.free()

func test_setup_screen_populates_available_cards_and_deck_slots() -> void:
	GameSession.start_new_game()
	GameSession.claim_npc_reward()

	var root = DeckSetupRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_eq(root.slot_grid.get_child_count(), GameSession.REQUIRED_DECK_SIZE)
	assert_gt(root.pool_container.get_child_count(), 0)
	assert_eq(root.slot_grid.get_parent().custom_minimum_size.y, 320.0)
	assert_true(root.deck_summary_label.text.contains("20/20"))
	assert_true(root.pool_summary_label.text.contains("Disponiveis"))
	assert_eq(root.start_button.text, "Iniciar encontro")
	root.free()

func test_setup_screen_supports_clear_and_auto_fill_buttons() -> void:
	GameSession.start_new_game()
	GameSession.claim_npc_reward()

	var root = DeckSetupRootScript.new()
	add_child(root)
	await get_tree().process_frame

	root._clear_deck()
	assert_eq(root._compact_deck().size(), 0)
	assert_true(root.start_button.disabled)

	root._auto_fill_deck()
	assert_eq(root._compact_deck().size(), GameSession.REQUIRED_DECK_SIZE)
	assert_false(root.start_button.disabled)
	root.free()

func _find_drop_enabled_card_token(node: Node):
	if node.has_signal("card_dropped_on_token"):
		return node
	for child: Node in node.get_children():
		var found = _find_drop_enabled_card_token(child)
		if found != null:
			return found
	return null
