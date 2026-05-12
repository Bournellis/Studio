extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const DeckRulesScript = preload("res://systems/deck/deck_rules.gd")
const TEST_SAVE_FILENAME: String = "rpg_turnos_session_test_save.json"
const TEST_SAVE_PATH: String = "user://%s" % TEST_SAVE_FILENAME

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()

func before_each() -> void:
	_delete_test_save()
	GameSession.start_new_game()

func after_each() -> void:
	_delete_test_save()

func test_catalog_contains_starter_deck_and_reward() -> void:
	var catalog = ContentLibrary.get_catalog()
	assert_not_null(catalog)
	assert_eq(catalog.starter_deck_ids.size(), 20)
	assert_eq(catalog.first_npc_reward_card_id, "golpe_preciso")
	assert_eq(catalog.reward_card_id, "golpe_preciso")
	assert_eq(catalog.npc_reward_choices.size(), 3)
	assert_not_null(catalog.find_card(catalog.first_npc_reward_card_id))
	assert_null(catalog.find_card("manter_linha"))
	assert_false(catalog.find_encounter("emboscada_na_ponte").is_empty())
	assert_false(catalog.find_encounter("duelista_bandido").is_empty())

func test_catalog_exposes_class_definitions_and_starter_decks() -> void:
	var catalog = ContentLibrary.get_catalog()
	assert_not_null(catalog)
	assert_eq(catalog.classes.size(), 5)
	assert_eq(ContentLibrary.get_all_classes().size(), 5)

	var expected_class_ids: Array[String] = [
		"assaltante",
		"arquiteto",
		"dominador",
		"tecelao",
		"vinculador"
	]
	for class_id: String in expected_class_ids:
		var class_data: Dictionary = ContentLibrary.get_class_definition(class_id)
		assert_false(class_data.is_empty(), "Class %s should exist." % class_id)
		assert_eq(str(class_data.get("id", "")), class_id)

		var hero: Dictionary = ContentLibrary.get_class_hero(class_id)
		assert_false(hero.is_empty(), "Class %s should expose hero metadata." % class_id)
		assert_false(str(hero.get("id", "")) == "", "Class %s should expose a hero id." % class_id)

		var hero_power: Dictionary = ContentLibrary.get_class_hero_power(class_id)
		assert_false(hero_power.is_empty(), "Class %s should expose hero power metadata." % class_id)
		assert_false(str(hero_power.get("id", "")) == "", "Class %s should expose a hero power id." % class_id)

		var starter_deck: Array = ContentLibrary.get_class_starter_deck_ids(class_id)
		assert_eq(starter_deck.size(), 20, "Class %s should have a 20-card starter deck." % class_id)
		for card_id: Variant in starter_deck:
			assert_not_null(catalog.find_card(str(card_id)), "Class %s starter card %s should exist." % [class_id, str(card_id)])

	assert_true(ContentLibrary.get_class_definition("classe_inexistente").is_empty())
	assert_true(ContentLibrary.get_class_hero("classe_inexistente").is_empty())
	assert_true(ContentLibrary.get_class_hero_power("classe_inexistente").is_empty())
	assert_true(ContentLibrary.get_class_starter_deck_ids("classe_inexistente").is_empty())

func test_npc_reward_unlocks_one_extra_card_once() -> void:
	assert_false(GameSession.has_npc_reward_card)
	assert_eq(GameSession.unlocked_card_ids.size(), 20)

	var reward_id: String = GameSession.claim_npc_reward()
	assert_eq(reward_id, "golpe_preciso")
	assert_true(GameSession.has_npc_reward_card)
	assert_eq(GameSession.unlocked_card_ids.size(), 21)

	GameSession.claim_npc_reward()
	assert_eq(GameSession.unlocked_card_ids.size(), 21)

func test_npc_progressive_rewards_follow_completed_encounters() -> void:
	GameSession.claim_npc_reward()
	GameSession.completed_encounter_ids.append("emboscada_na_ponte")

	var reward_id: String = GameSession.claim_npc_progressive_reward()

	assert_eq(reward_id, "corvo_batedor")
	assert_true(GameSession.unlocked_card_ids.has("corvo_batedor"))
	assert_eq(GameSession.npc_reward_index, 1)

func test_deck_rules_require_exactly_twenty_unlocked_cards() -> void:
	var rules = DeckRulesScript.new()
	var valid: Dictionary = rules.validate(GameSession.selected_deck_ids, GameSession.unlocked_card_ids)
	assert_true(bool(valid.get("ok", false)))

	var short_deck: Array = GameSession.selected_deck_ids.slice(0, 19)
	var invalid_size: Dictionary = rules.validate(short_deck, GameSession.unlocked_card_ids)
	assert_false(bool(invalid_size.get("ok", false)))

	var locked_deck: Array = GameSession.selected_deck_ids.duplicate()
	locked_deck[0] = "golpe_preciso"
	var invalid_locked: Dictionary = rules.validate(locked_deck, GameSession.unlocked_card_ids)
	assert_false(bool(invalid_locked.get("ok", false)))

func test_defeat_restores_pre_combat_snapshot_without_penalty() -> void:
	GameSession.claim_npc_reward()
	GameSession.capture_pre_combat_snapshot()
	GameSession.record_defeat("Teste de derrota.")
	GameSession.is_encounter_completed = true
	GameSession.completed_encounter_ids.append("emboscada_na_ponte")
	GameSession.unlocked_card_ids.clear()

	GameSession.restore_pre_combat_snapshot()

	assert_true(GameSession.has_npc_reward_card)
	assert_false(GameSession.is_encounter_completed)
	assert_false(GameSession.completed_encounter_ids.has("emboscada_na_ponte"))
	assert_eq(GameSession.unlocked_card_ids.size(), 21)
	assert_eq(GameSession.last_battle_result, "")

func test_encounter_rewards_claim_once_and_allow_practice() -> void:
	GameSession.claim_npc_reward()
	GameSession.set_active_encounter("emboscada_na_ponte")

	GameSession.complete_encounter("Teste.")

	assert_true(GameSession.has_completed_encounter("emboscada_na_ponte"))
	assert_true(GameSession.claimed_encounter_reward_ids.has("emboscada_na_ponte"))
	assert_true(GameSession.unlocked_card_ids.has("lobo_alfa"))
	assert_eq(GameSession.last_reward_card_ids, ["lobo_alfa"])

	var unlocked_count: int = GameSession.unlocked_card_ids.size()
	var repeat: Array[String] = GameSession.claim_encounter_reward("emboscada_na_ponte")

	assert_true(repeat.is_empty())
	assert_eq(GameSession.unlocked_card_ids.size(), unlocked_count)

func test_save_game_writes_and_loads_progression_state() -> void:
	GameSession.claim_npc_reward()
	GameSession.set_active_encounter("emboscada_na_ponte")
	GameSession.complete_encounter("Teste.")
	var reversed_deck: Array = GameSession.selected_deck_ids.duplicate()
	reversed_deck.reverse()
	assert_true(GameSession.set_selected_deck(reversed_deck))

	var expected_unlocked: Array = GameSession.unlocked_card_ids.duplicate()
	var expected_deck: Array = GameSession.selected_deck_ids.duplicate()
	var expected_completed: Array = GameSession.completed_encounter_ids.duplicate()
	var expected_claimed: Array = GameSession.claimed_encounter_reward_ids.duplicate()

	assert_true(GameSession.save_game(TEST_SAVE_PATH))
	assert_true(FileAccess.file_exists(TEST_SAVE_PATH))

	GameSession.start_new_game()
	assert_false(GameSession.unlocked_card_ids.has("lobo_alfa"))

	assert_true(GameSession.load_game(TEST_SAVE_PATH))
	assert_eq(GameSession.unlocked_card_ids, expected_unlocked)
	assert_eq(GameSession.selected_deck_ids, expected_deck)
	assert_eq(GameSession.completed_encounter_ids, expected_completed)
	assert_eq(GameSession.claimed_encounter_reward_ids, expected_claimed)
	assert_eq(GameSession.active_encounter_id, "emboscada_na_ponte")
	assert_true(GameSession.is_encounter_completed)
	assert_eq(GameSession.last_battle_result, "")

func test_missing_save_falls_back_to_new_game() -> void:
	GameSession.claim_npc_reward()

	assert_false(GameSession.load_game(TEST_SAVE_PATH))

	assert_false(GameSession.has_npc_reward_card)
	assert_eq(GameSession.unlocked_card_ids.size(), 20)
	assert_eq(GameSession.selected_deck_ids.size(), 20)

func test_corrupt_save_falls_back_to_new_game() -> void:
	var file: FileAccess = FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string("{not valid json")
	file = null
	GameSession.claim_npc_reward()

	assert_false(GameSession.load_game(TEST_SAVE_PATH))

	assert_false(GameSession.has_npc_reward_card)
	assert_eq(GameSession.unlocked_card_ids.size(), 20)
	assert_eq(GameSession.completed_encounter_ids.size(), 0)

func _delete_test_save() -> void:
	if not FileAccess.file_exists(TEST_SAVE_PATH):
		return
	var user_dir: DirAccess = DirAccess.open("user://")
	if user_dir != null:
		user_dir.remove(TEST_SAVE_FILENAME)
