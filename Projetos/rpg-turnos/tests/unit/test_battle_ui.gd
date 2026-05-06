extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BattleRootScript = preload("res://modes/battle/battle_root.gd")
const BattleSlotControlScript = preload("res://ui/controls/battle_slot_control.gd")
const ResultRootScript = preload("res://modes/battle/result_root.gd")

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
	root.engine._enemy_ai_enabled = false

	assert_eq(root.engine.hand[0], "escudeiro")
	root._on_card_dropped_on_slot(
		{"kind": "battle_card", "card_id": "escudeiro", "hand_index": 0},
		"player",
		0
	)
	await get_tree().process_frame

	assert_true(root.engine.player_slots[0] != null)
	assert_eq(root.engine.hand.size(), 4)
	assert_eq(root.engine.outcome, "")
	assert_eq(root.hand_box.get_child_count(), 4)
	assert_eq(root.player_slots_box.get_child_count(), 3)
	root.free()

func test_battle_hand_exposes_button_actions_and_feedback() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame
	root.engine._enemy_ai_enabled = false

	assert_eq(root.hand_box.get_child_count(), 5)
	assert_eq(root.energy_pips_box.get_child_count(), 3)
	assert_true(root.hand_limit_label.text.contains("Mao 5/5"))
	assert_true(root.discard_counter_label.text.contains("inativo"))
	assert_eq(root.player_hp_bar.value, 25.0)
	var first_card_box: VBoxContainer = root.hand_box.get_child(0)
	assert_gt(first_card_box.get_child_count(), 1)
	var first_token = first_card_box.get_child(0)
	assert_not_null(first_token.type_stripe)

	root._play_hand_card_to_player_slot(0, 0)
	await get_tree().process_frame

	assert_eq(root.feedback_label.text, "Carta jogada.")
	assert_true(root.engine.player_slots[0] != null)
	assert_eq(root.hand_box.get_child_count(), 4)
	root.free()

func test_battle_slot_exposes_visual_state_chips() -> void:
	var slot = BattleSlotControlScript.new()
	add_child(slot)
	slot.setup("player", 0, null, {
		"label": "P1",
		"attack_status": "Livre",
		"is_attack_source": false,
		"is_attack_target": true,
		"is_empty": true
	})
	await get_tree().process_frame

	assert_eq(slot.visual_state.get("is_attack_target"), true)
	assert_true(slot.get_child_count() > 0)
	slot.free()

func test_result_screen_shows_reward_feedback() -> void:
	GameSession.last_battle_result = "victory"
	GameSession.last_battle_summary = "Teste."
	GameSession.last_reward_card_ids = ["lobo_alfa"]

	assert_true(ResultRootScript.reward_text_for_card_ids(GameSession.last_reward_card_ids).contains("Lobo-Alfa"))

func test_end_turn_button_stays_visible_and_advances_round() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame
	root.engine._enemy_ai_enabled = false

	assert_eq(root.phase_label.text, "Fase: Fase principal")
	assert_true(root.priority_label.text.contains("Prioridade: voce"))
	assert_eq(root.end_turn_button.text, "Passar prioridade")
	assert_false(root.end_turn_button.disabled)

	root._on_end_turn_pressed()
	await get_tree().process_frame

	assert_eq(root.engine.turno, 1)
	assert_eq(root.engine.current_phase, "descarte")
	assert_eq(root.engine.active_player_id, "jogador")
	assert_true(root.priority_label.text.contains("Descarte: voce"))
	assert_eq(root.end_turn_button.text, "Encerrar descarte")

	root._on_end_turn_pressed()
	await get_tree().process_frame

	assert_eq(root.engine.turno, 2)
	assert_eq(root.engine.active_player_id, "inimigo")
	assert_true(root.priority_label.text.contains("Prioridade: voce"))
	assert_eq(root.end_turn_button.text, "Passar prioridade")
	root.free()

func test_hero_power_button_draws_and_disables_for_round() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame
	root.engine._enemy_ai_enabled = false

	assert_false(root.hero_power_button.disabled)

	root._on_hero_power_pressed()
	await get_tree().process_frame

	assert_eq(root.feedback_label.text, "Preparar Defesa concedeu 2 de armadura.")
	assert_true(root.hero_power_button.disabled)
	assert_eq(root.engine.player_armor, 2)
	assert_eq(root.engine.hand.size(), 5)

	root._on_end_turn_pressed()
	await get_tree().process_frame
	root._on_end_turn_pressed()
	assert_true(root.hero_power_button.disabled)
	root._on_end_turn_pressed()
	assert_false(root.hero_power_button.disabled)
	root.free()

func test_enemy_turn_is_automatic_and_visual_events_are_available() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame

	root._on_hero_power_pressed()
	await get_tree().process_frame

	assert_eq(root.engine.priority_owner_id, "jogador")
	assert_gt(root.engine.eventos_visuais.size(), 0)
	assert_true(root.feedback_label.text.contains("Preparar Defesa"))
	root.free()

func test_generated_battle_scene_root_expands_to_viewport() -> void:
	var packed_scene: PackedScene = load("res://modes/battle/battle.tscn")
	var root = packed_scene.instantiate()
	add_child(root)
	await get_tree().process_frame

	var viewport_size: Vector2 = root.get_viewport_rect().size
	assert_gte(root.size.x, viewport_size.x - 1.0)
	assert_gte(root.size.y, viewport_size.y - 1.0)
	root.free()

func test_battle_layout_keeps_hand_actions_inside_debug_viewport() -> void:
	var debug_viewport_size: Vector2 = Vector2(1100, 619)
	var root = BattleRootScript.new()
	root.size = debug_viewport_size
	add_child(root)
	await get_tree().process_frame
	root.engine._enemy_ai_enabled = false
	root.size = debug_viewport_size
	await get_tree().process_frame

	_assert_control_inside(root.hero_power_button, debug_viewport_size)
	_assert_control_inside(root.end_turn_button, debug_viewport_size)
	_assert_control_inside(root.feedback_label, debug_viewport_size)
	_assert_control_inside(root.hand_box, debug_viewport_size)
	for card_box: Control in root.hand_box.get_children():
		_assert_control_inside(card_box, debug_viewport_size)
		for child: Control in card_box.get_children():
			_assert_control_inside(child, debug_viewport_size)
	root.free()

func test_battle_layout_keeps_priority_action_visible_after_c1_state_changes() -> void:
	var debug_viewport_size: Vector2 = Vector2(1100, 619)
	var root = BattleRootScript.new()
	root.size = debug_viewport_size
	add_child(root)
	await get_tree().process_frame
	root.engine._enemy_ai_enabled = false
	root.size = debug_viewport_size
	await get_tree().process_frame

	root._play_hand_card_to_player_slot(0, 1)
	await get_tree().process_frame

	assert_true(root.priority_label.text.contains("Prioridade: voce"))
	assert_eq(root.end_turn_button.text, "Passar prioridade")
	_assert_control_inside(root.hero_power_button, debug_viewport_size)
	_assert_control_inside(root.end_turn_button, debug_viewport_size)
	_assert_control_inside(root.priority_label, debug_viewport_size)

	root._on_end_turn_pressed()
	await get_tree().process_frame

	assert_true(root.priority_label.text.contains("Descarte: voce"))
	assert_eq(root.end_turn_button.text, "Encerrar descarte")
	_assert_control_inside(root.hero_power_button, debug_viewport_size)
	_assert_control_inside(root.end_turn_button, debug_viewport_size)
	root.free()

func _assert_control_inside(control: Control, viewport_size: Vector2) -> void:
	var rect: Rect2 = control.get_global_rect()
	assert_gte(rect.position.x, 0.0, "%s left edge" % control.name)
	assert_gte(rect.position.y, 0.0, "%s top edge" % control.name)
	assert_lte(rect.end.x, viewport_size.x, "%s right edge" % control.name)
	assert_lte(rect.end.y, viewport_size.y, "%s bottom edge" % control.name)

func _find_node_by_name(node: Node, target_name: String):
	if node.name == target_name:
		return node
	for child: Node in node.get_children():
		var found = _find_node_by_name(child, target_name)
		if found != null:
			return found
	return null
