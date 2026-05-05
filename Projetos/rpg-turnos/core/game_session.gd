extends Node

signal reward_claimed(card_id: String)
signal encounter_completed()

const REQUIRED_DECK_SIZE: int = 20
const ACTIVE_ENCOUNTER_ID: String = "emboscada_na_ponte"
const DeckRulesScript = preload("res://systems/deck/deck_rules.gd")

var unlocked_card_ids: Array = []
var selected_deck_ids: Array = []
var active_encounter_id: String = ACTIVE_ENCOUNTER_ID
var has_npc_reward_card: bool = false
var is_encounter_completed: bool = false
var completed_encounter_ids: Array = []
var claimed_encounter_reward_ids: Array = []
var npc_reward_index: int = 0
var last_reward_card_ids: Array = []
var last_battle_result: String = ""
var last_battle_summary: String = ""

var _pre_combat_snapshot: Dictionary = {}

func start_new_game() -> void:
	ContentLibrary.ensure_loaded()
	unlocked_card_ids = ContentLibrary.get_starter_deck_ids()
	selected_deck_ids = unlocked_card_ids.duplicate()
	active_encounter_id = ACTIVE_ENCOUNTER_ID
	has_npc_reward_card = false
	is_encounter_completed = false
	completed_encounter_ids = []
	claimed_encounter_reward_ids = []
	npc_reward_index = 0
	last_reward_card_ids = []
	last_battle_result = ""
	last_battle_summary = ""
	_pre_combat_snapshot = {}

func claim_first_npc_reward() -> String:
	if has_npc_reward_card:
		return ContentLibrary.get_first_npc_reward_card_id()
	var reward_card_id: String = ContentLibrary.get_first_npc_reward_card_id()
	if reward_card_id != "" and not unlocked_card_ids.has(reward_card_id):
		unlocked_card_ids.append(reward_card_id)
	has_npc_reward_card = true
	reward_claimed.emit(reward_card_id)
	return reward_card_id

func claim_npc_reward() -> String:
	return claim_first_npc_reward()

func claim_npc_progressive_reward() -> String:
	var choices: Array = ContentLibrary.get_npc_reward_choices()
	if npc_reward_index >= choices.size():
		return ""
	var reward_card_id: String = str(choices[npc_reward_index])
	npc_reward_index += 1
	if reward_card_id != "" and not unlocked_card_ids.has(reward_card_id):
		unlocked_card_ids.append(reward_card_id)
		reward_claimed.emit(reward_card_id)
		return reward_card_id
	return ""

func can_start_encounter() -> bool:
	return has_npc_reward_card

func is_deck_valid(deck_ids: Array) -> bool:
	return bool(DeckRulesScript.new().validate(deck_ids, unlocked_card_ids).get("ok", false))

func set_selected_deck(deck_ids: Array) -> bool:
	if not is_deck_valid(deck_ids):
		return false
	selected_deck_ids = deck_ids.duplicate()
	return true

func get_battle_config() -> Dictionary:
	return {"encontro": active_encounter_id}

func set_active_encounter(encounter_id: String) -> void:
	active_encounter_id = encounter_id
	is_encounter_completed = has_completed_encounter(encounter_id)

func has_completed_encounter(encounter_id: String) -> bool:
	return completed_encounter_ids.has(encounter_id)

func claim_encounter_reward(encounter_id: String) -> Array[String]:
	if claimed_encounter_reward_ids.has(encounter_id):
		return []
	var claimed: Array[String] = []
	for reward_id: Variant in ContentLibrary.get_encounter_reward_cards(encounter_id):
		var card_id: String = str(reward_id)
		if card_id == "" or unlocked_card_ids.has(card_id):
			continue
		unlocked_card_ids.append(card_id)
		claimed.append(card_id)
	if not claimed_encounter_reward_ids.has(encounter_id):
		claimed_encounter_reward_ids.append(encounter_id)
	last_reward_card_ids = claimed.duplicate()
	return claimed

func capture_pre_combat_snapshot() -> void:
	_pre_combat_snapshot = {
		"unlocked_card_ids": unlocked_card_ids.duplicate(),
		"selected_deck_ids": selected_deck_ids.duplicate(),
		"active_encounter_id": active_encounter_id,
		"has_npc_reward_card": has_npc_reward_card,
		"is_encounter_completed": is_encounter_completed,
		"completed_encounter_ids": completed_encounter_ids.duplicate(),
		"claimed_encounter_reward_ids": claimed_encounter_reward_ids.duplicate(),
		"npc_reward_index": npc_reward_index,
		"last_reward_card_ids": last_reward_card_ids.duplicate()
	}

func restore_pre_combat_snapshot() -> void:
	if _pre_combat_snapshot.is_empty():
		return
	unlocked_card_ids = Array(_pre_combat_snapshot.get("unlocked_card_ids", [])).duplicate()
	selected_deck_ids = Array(_pre_combat_snapshot.get("selected_deck_ids", [])).duplicate()
	active_encounter_id = str(_pre_combat_snapshot.get("active_encounter_id", ACTIVE_ENCOUNTER_ID))
	has_npc_reward_card = bool(_pre_combat_snapshot.get("has_npc_reward_card", false))
	is_encounter_completed = bool(_pre_combat_snapshot.get("is_encounter_completed", false))
	completed_encounter_ids = Array(_pre_combat_snapshot.get("completed_encounter_ids", [])).duplicate()
	claimed_encounter_reward_ids = Array(_pre_combat_snapshot.get("claimed_encounter_reward_ids", [])).duplicate()
	npc_reward_index = int(_pre_combat_snapshot.get("npc_reward_index", 0))
	last_reward_card_ids = Array(_pre_combat_snapshot.get("last_reward_card_ids", [])).duplicate()
	last_battle_result = ""
	last_battle_summary = ""

func complete_encounter(summary: String) -> void:
	if not completed_encounter_ids.has(active_encounter_id):
		completed_encounter_ids.append(active_encounter_id)
	is_encounter_completed = true
	var claimed: Array[String] = claim_encounter_reward(active_encounter_id)
	last_battle_result = "victory"
	last_battle_summary = summary
	if not claimed.is_empty():
		var names: Array[String] = []
		for card_id: String in claimed:
			names.append(ContentLibrary.get_card_name(card_id))
		last_battle_summary += " Cartas obtidas: %s." % ", ".join(names)
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
