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

func test_battle_hand_exposes_button_actions_and_feedback() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_eq(root.hand_box.get_child_count(), 3)
	var first_card_box: VBoxContainer = root.hand_box.get_child(0)
	assert_gt(first_card_box.get_child_count(), 1)

	root._play_hand_card_to_player_slot(0, 0)
	await get_tree().process_frame

	assert_eq(root.feedback_label.text, "Carta jogada.")
	assert_true(root.engine.player_slots[0] != null)
	assert_eq(root.hand_box.get_child_count(), 2)
	root.free()

func test_end_turn_button_stays_visible_and_advances_round() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_eq(root.phase_label.text, "Fase: Fase principal 1")
	assert_eq(root.end_turn_button.text, "Ir para combate")
	assert_false(root.end_turn_button.disabled)

	root._play_hand_card_to_player_slot(0, 0)
	await get_tree().process_frame

	assert_eq(root.engine.energy, 0)
	assert_false(root.end_turn_button.disabled)

	root._on_end_turn_pressed()
	assert_eq(root.engine.current_phase, "combat")
	assert_eq(root.end_turn_button.text, "Resolver combate")

	root._on_end_turn_pressed()
	assert_eq(root.engine.current_phase, "main_2")
	assert_eq(root.end_turn_button.text, "Encerrar turno")

	root._on_end_turn_pressed()

	assert_eq(root.engine.round_number, 2)
	assert_eq(root.engine.energy, 2)
	assert_eq(root.feedback_label.text, "Turno encerrado.")
	root.free()

func test_hero_power_button_draws_and_disables_for_round() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_false(root.hero_power_button.disabled)

	root._on_hero_power_pressed()
	await get_tree().process_frame

	assert_eq(root.feedback_label.text, "Poder heroico comprou 1 carta.")
	assert_true(root.hero_power_button.disabled)
	assert_eq(root.engine.hand.size(), 4)

	root._on_end_turn_pressed()
	assert_true(root.hero_power_button.disabled)
	root._on_end_turn_pressed()
	assert_true(root.hero_power_button.disabled)
	root._on_end_turn_pressed()
	assert_false(root.hero_power_button.disabled)
	root.free()

func test_battle_layout_keeps_hand_actions_inside_debug_viewport() -> void:
	var debug_viewport_size: Vector2 = Vector2(1152, 648)
	var root = BattleRootScript.new()
	root.size = debug_viewport_size
	add_child(root)
	await get_tree().process_frame
	root.size = debug_viewport_size
	await get_tree().process_frame

	var viewport_bottom: float = debug_viewport_size.y - 12.0
	assert_lte(root.hand_box.get_global_rect().end.y, viewport_bottom)
	for card_box: Control in root.hand_box.get_children():
		assert_lte(card_box.get_global_rect().end.y, viewport_bottom)
		for child: Control in card_box.get_children():
			assert_lte(child.get_global_rect().end.y, viewport_bottom)
	root.free()
