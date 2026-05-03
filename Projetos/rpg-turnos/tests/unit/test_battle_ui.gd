extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleRootScript = preload("res://modes/battle/battle_root.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()

func before_each() -> void:
	GameSession.start_new_game()

func test_playing_first_card_from_ui_refreshes_battle_without_locking() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_eq(root.engine.hand[0], "line_guard")
	root._on_card_dropped_on_slot(
		{"kind": "battle_card", "card_id": "line_guard", "hand_index": 0},
		"player",
		0
	)
	await get_tree().process_frame

	assert_true(root.engine.player_slots[0] != null)
	assert_eq(root.engine.hand.size(), 2)
	assert_eq(root.engine.outcome, "")
	assert_eq(root.hand_box.get_child_count(), 2)
	assert_eq(root.player_slots_box.get_child_count(), 3)
	root.free()
