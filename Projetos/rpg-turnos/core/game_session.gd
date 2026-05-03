extends Node

signal reward_claimed(card_id: String)
signal encounter_completed()

const REQUIRED_DECK_SIZE: int = 10

var unlocked_card_ids: Array = []
var selected_deck_ids: Array = []
var has_npc_reward_card: bool = false
var is_encounter_completed: bool = false
var last_battle_result: String = ""
var last_battle_summary: String = ""

var _pre_combat_snapshot: Dictionary = {}

func start_new_game() -> void:
	ContentLibrary.ensure_loaded()
	unlocked_card_ids = ContentLibrary.get_starter_deck_ids()
	selected_deck_ids = unlocked_card_ids.duplicate()
	has_npc_reward_card = false
	is_encounter_completed = false
	last_battle_result = ""
	last_battle_summary = ""
	_pre_combat_snapshot = {}

func claim_npc_reward() -> String:
	if has_npc_reward_card:
		return ContentLibrary.get_reward_card_id()
	var reward_card_id: String = ContentLibrary.get_reward_card_id()
	if reward_card_id != "" and not unlocked_card_ids.has(reward_card_id):
		unlocked_card_ids.append(reward_card_id)
	has_npc_reward_card = true
	reward_claimed.emit(reward_card_id)
	return reward_card_id

func can_start_encounter() -> bool:
	return has_npc_reward_card and not is_encounter_completed

func is_deck_valid(deck_ids: Array) -> bool:
	return deck_ids.size() == REQUIRED_DECK_SIZE and _is_subset_of_unlocked(deck_ids)

func set_selected_deck(deck_ids: Array) -> bool:
	if not is_deck_valid(deck_ids):
		return false
	selected_deck_ids = deck_ids.duplicate()
	return true

func capture_pre_combat_snapshot() -> void:
	_pre_combat_snapshot = {
		"unlocked_card_ids": unlocked_card_ids.duplicate(),
		"selected_deck_ids": selected_deck_ids.duplicate(),
		"has_npc_reward_card": has_npc_reward_card,
		"is_encounter_completed": is_encounter_completed
	}

func restore_pre_combat_snapshot() -> void:
	if _pre_combat_snapshot.is_empty():
		return
	unlocked_card_ids = Array(_pre_combat_snapshot.get("unlocked_card_ids", [])).duplicate()
	selected_deck_ids = Array(_pre_combat_snapshot.get("selected_deck_ids", [])).duplicate()
	has_npc_reward_card = bool(_pre_combat_snapshot.get("has_npc_reward_card", false))
	is_encounter_completed = bool(_pre_combat_snapshot.get("is_encounter_completed", false))
	last_battle_result = ""
	last_battle_summary = ""

func complete_encounter(summary: String) -> void:
	is_encounter_completed = true
	last_battle_result = "victory"
	last_battle_summary = summary
	encounter_completed.emit()

func record_defeat(summary: String) -> void:
	last_battle_result = "defeat"
	last_battle_summary = summary

func _is_subset_of_unlocked(deck_ids: Array) -> bool:
	var remaining: Array = unlocked_card_ids.duplicate()
	for card_id: Variant in deck_ids:
		var index: int = remaining.find(str(card_id))
		if index == -1:
			return false
		remaining.remove_at(index)
	return true
