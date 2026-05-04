extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const DeckRulesScript = preload("res://systems/deck/deck_rules.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()

func before_each() -> void:
	GameSession.start_new_game()

func test_catalog_contains_starter_deck_and_reward() -> void:
	var catalog = ContentLibrary.get_catalog()
	assert_not_null(catalog)
	assert_eq(catalog.starter_deck_ids.size(), 20)
	assert_eq(catalog.reward_card_id, "golpe_preciso")
	assert_not_null(catalog.find_card(catalog.reward_card_id))
	assert_false(catalog.find_encounter("emboscada_na_ponte").is_empty())
	assert_false(catalog.find_encounter("duelista_bandido").is_empty())

func test_npc_reward_unlocks_one_extra_card_once() -> void:
	assert_false(GameSession.has_npc_reward_card)
	assert_eq(GameSession.unlocked_card_ids.size(), 20)

	var reward_id: String = GameSession.claim_npc_reward()
	assert_eq(reward_id, "golpe_preciso")
	assert_true(GameSession.has_npc_reward_card)
	assert_eq(GameSession.unlocked_card_ids.size(), 21)

	GameSession.claim_npc_reward()
	assert_eq(GameSession.unlocked_card_ids.size(), 21)

func test_deck_rules_require_exactly_twenty_unlocked_cards_and_command_limit() -> void:
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

	var command_heavy: Array = GameSession.selected_deck_ids.duplicate()
	GameSession.unlocked_card_ids.append_array(["manter_linha", "manter_linha", "manter_linha", "manter_linha", "manter_linha"])
	for index: int in range(5):
		command_heavy[index] = "manter_linha"
	var invalid_command: Dictionary = rules.validate(command_heavy, GameSession.unlocked_card_ids)
	assert_false(bool(invalid_command.get("ok", false)))

func test_defeat_restores_pre_combat_snapshot_without_penalty() -> void:
	GameSession.claim_npc_reward()
	GameSession.capture_pre_combat_snapshot()
	GameSession.record_defeat("Teste de derrota.")
	GameSession.is_encounter_completed = true
	GameSession.unlocked_card_ids.clear()

	GameSession.restore_pre_combat_snapshot()

	assert_true(GameSession.has_npc_reward_card)
	assert_false(GameSession.is_encounter_completed)
	assert_eq(GameSession.unlocked_card_ids.size(), 21)
	assert_eq(GameSession.last_battle_result, "")
