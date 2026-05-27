extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")
const BattleCardTokenScript = preload("res://ui/controls/battle_card_token.gd")
const CardTokenScript = preload("res://ui/controls/card_token.gd")
const TEST_SAVE_PREFIX: String = "user://gut_draxos_save_slot_"

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	assert_true(bool(scene_result.get("ok", false)), str(scene_result.get("message", "")))
	ContentLibrary.reload()
	VisualAssets.reload()

func before_each() -> void:
	SaveManager.save_path_prefix = TEST_SAVE_PREFIX
	_clear_test_saves()
	SaveManager.select_slot(1)
	SaveManager.pending_new_game = false
	RunSession.reset()

func after_each() -> void:
	_clear_test_saves()
	SaveManager.save_path_prefix = "user://draxos_save_slot_"
	SaveManager.select_slot(1)
	SaveManager.pending_new_game = false
	RunSession.reset()

func _instantiate_scene(path: String):
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	var node = packed.instantiate()
	add_child(node)
	await get_tree().process_frame
	return node

func _keyword_engine(mode: String = BattleEngine.MODE_SURVIVE_TURNS) -> BattleEngine:
	var engine: BattleEngine = BattleEngine.new()
	engine.start_battle(ContentLibrary.get_catalog(), [], {
		"encounter": {
			"id": "test_keywords",
			"display_name": "Teste Keywords",
			"mode": mode,
			"survive_turns": 99,
			"enemy_health": 20,
			"player_slots_count": 3,
			"enemy_slots_count": 3,
			"starting_enemy_slots": []
		},
		"mana_per_turn": 0,
		"max_hand_size": 0,
		"player_health": 20,
		"shuffle_deck": false
	})
	engine.outcome = ""
	engine.current_phase = BattleEngine.PHASE_MAIN
	return engine

func _keyword_card(card_id: String, attack: int, health: int, keywords: Array[String], effect: Dictionary = {}) -> CardDefinitionResource:
	var card: CardDefinitionResource = CardDefinitionResource.new()
	card.id = "test_%s" % card_id
	card.display_name = "Teste %s" % card_id
	card.card_type = "criatura"
	card.cost = 0
	card.attack = attack
	card.health = health
	card.keywords = PackedStringArray(keywords)
	card.effect = effect
	return card

func _start_class_run(class_id: String, seed: int = 0) -> void:
	var result: Dictionary = RunSession.start_class_run(class_id, seed)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func _count_children_with_prefix(node: Node, prefix: String) -> int:
	var count: int = 0
	for child: Node in node.get_children():
		if str(child.name).begins_with(prefix):
			count += 1
	return count

func _occupied_count(slots: Array) -> int:
	var count: int = 0
	for occupant: Variant in slots:
		if occupant != null:
			count += 1
	return count

func _enemy_board_has_card(slots: Array, card_id: String) -> bool:
	for occupant: Variant in slots:
		if occupant != null and str(Dictionary(occupant).get("card_id", "")) == card_id:
			return true
	return false

func _new_card_copies_for_rarity(rarity: String) -> int:
	match rarity:
		RunSession.REWARD_RARITY_RARE:
			return 4
		RunSession.REWARD_RARITY_ULTRA:
			return 5
		_:
			return 3

func _has_label_text(node: Node, text: String) -> bool:
	if node is Label and str((node as Label).text) == text:
		return true
	for child: Node in node.get_children():
		if _has_label_text(child, text):
			return true
	return false

func _assert_control_inside_viewport(control: Control) -> void:
	assert_not_null(control)
	if control == null:
		return
	var rect: Rect2 = control.get_global_rect()
	var viewport_size: Vector2 = control.get_viewport_rect().size
	assert_true(rect.position.x >= -1.0, "%s should not extend past the left edge." % str(control.name))
	assert_true(rect.position.y >= -1.0, "%s should not extend past the top edge." % str(control.name))
	assert_true(rect.position.x + rect.size.x <= viewport_size.x + 1.0, "%s should not extend past the right edge." % str(control.name))
	assert_true(rect.position.y + rect.size.y <= viewport_size.y + 1.0, "%s should not extend past the bottom edge." % str(control.name))

func _clear_test_saves() -> void:
	for index: int in range(1, SaveManager.SLOT_COUNT + 1):
		var path: String = "%s%d.json" % [TEST_SAVE_PREFIX, index]
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _write_test_save_file(index: int, payload: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://"))
	var path: String = "%s%d.json" % [TEST_SAVE_PREFIX, index]
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
