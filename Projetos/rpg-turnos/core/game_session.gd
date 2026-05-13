extends Node

signal reward_claimed(card_id: String)
signal encounter_completed()

const REQUIRED_DECK_SIZE: int = 20
const ACTIVE_ENCOUNTER_ID: String = "operacao_pouso"
const SAVE_VERSION: int = 2
const DEFAULT_SAVE_PATH: String = "user://rpg_turnos_save.json"
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
var selected_class: String = ""
var operacao_rank: int = 0

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
	selected_class = ""
	operacao_rank = 0
	_pre_combat_snapshot = {}

func build_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"unlocked_card_ids": _string_array(unlocked_card_ids),
		"selected_deck_ids": _string_array(selected_deck_ids),
		"active_encounter_id": active_encounter_id,
		"has_npc_reward_card": has_npc_reward_card,
		"completed_encounter_ids": _string_array(completed_encounter_ids),
		"claimed_encounter_reward_ids": _string_array(claimed_encounter_reward_ids),
		"npc_reward_index": npc_reward_index,
		"selected_class": selected_class,
		"operacao_rank": operacao_rank
	}

func apply_save_data(save_data: Dictionary) -> bool:
	ContentLibrary.ensure_loaded()
	var file_version: int = int(save_data.get("version", 0))
	if file_version != SAVE_VERSION and file_version != 1:
		return false
	# Migrate v1 saves: encounter IDs changed in P20 (technical ID migration)
	if file_version == 1:
		save_data = _migrate_save_v1_to_v2(save_data)

	var loaded_unlocked: Array = _ensure_starter_cards(_string_array(save_data.get("unlocked_card_ids", [])))
	unlocked_card_ids = loaded_unlocked

	selected_deck_ids = _string_array(save_data.get("selected_deck_ids", []))
	if not is_deck_valid(selected_deck_ids):
		selected_deck_ids = ContentLibrary.get_starter_deck_ids()

	active_encounter_id = _valid_encounter_id(str(save_data.get("active_encounter_id", ACTIVE_ENCOUNTER_ID)))
	has_npc_reward_card = bool(save_data.get("has_npc_reward_card", false))
	completed_encounter_ids = _unique_string_array(save_data.get("completed_encounter_ids", []))
	claimed_encounter_reward_ids = _unique_string_array(save_data.get("claimed_encounter_reward_ids", []))
	npc_reward_index = max(0, int(save_data.get("npc_reward_index", 0)))
	is_encounter_completed = has_completed_encounter(active_encounter_id)
	# selected_class is optional — old saves without it default to "" (no class selected)
	var raw_class: String = str(save_data.get("selected_class", ""))
	if raw_class != "" and not ContentLibrary.get_class_definition(raw_class).is_empty():
		selected_class = raw_class
	else:
		selected_class = ""
	# operacao_rank is optional — old saves without it default to 0 (Recruta)
	var raw_rank: int = int(save_data.get("operacao_rank", 0))
	operacao_rank = clampi(raw_rank, 0, 3)
	last_reward_card_ids = []
	last_battle_result = ""
	last_battle_summary = ""
	_pre_combat_snapshot = {}
	return true

func save_game(save_path: String = DEFAULT_SAVE_PATH) -> bool:
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: %s" % save_path)
		return false
	file.store_string(JSON.stringify(build_save_data(), "\t"))
	return true

func load_game(save_path: String = DEFAULT_SAVE_PATH) -> bool:
	if not FileAccess.file_exists(save_path):
		start_new_game()
		return false
	var file_text: String = FileAccess.get_file_as_string(save_path)
	var parser: JSON = JSON.new()
	if parser.parse(file_text) != OK:
		start_new_game()
		return false
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		start_new_game()
		return false
	if not apply_save_data(Dictionary(parsed)):
		start_new_game()
		return false
	return true

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
	var config: Dictionary = {"encontro": active_encounter_id}
	if has_selected_class():
		config["class_id"] = selected_class
	return config

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
		"last_reward_card_ids": last_reward_card_ids.duplicate(),
		"selected_class": selected_class,
		"operacao_rank": operacao_rank
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
	selected_class = str(_pre_combat_snapshot.get("selected_class", ""))
	operacao_rank = clampi(int(_pre_combat_snapshot.get("operacao_rank", 0)), 0, 3)
	last_battle_result = ""
	last_battle_summary = ""

func complete_encounter(summary: String) -> void:
	if not completed_encounter_ids.has(active_encounter_id):
		completed_encounter_ids.append(active_encounter_id)
	is_encounter_completed = true
	_check_rank_advancement()
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

func _string_array(values: Variant) -> Array:
	var result: Array = []
	if not values is Array:
		return result
	for value: Variant in values:
		var item: String = str(value)
		if item != "":
			result.append(item)
	return result

func _unique_string_array(values: Variant) -> Array:
	var result: Array = []
	for item: String in _string_array(values):
		if not result.has(item):
			result.append(item)
	return result

func _ensure_starter_cards(card_ids: Array) -> Array:
	var result: Array = card_ids.duplicate()
	var remaining: Array = result.duplicate()
	for starter_card_id: Variant in ContentLibrary.get_starter_deck_ids():
		var starter_id: String = str(starter_card_id)
		var index: int = remaining.find(starter_id)
		if index == -1:
			result.append(starter_id)
		else:
			remaining.remove_at(index)
	return result

func _valid_encounter_id(encounter_id: String) -> String:
	var catalog = ContentLibrary.get_catalog()
	if catalog != null and not catalog.find_encounter(encounter_id).is_empty():
		return encounter_id
	return ACTIVE_ENCOUNTER_ID

# --- Operacao rank ---

func _check_rank_advancement() -> void:
	var count: int = completed_encounter_ids.size()
	var new_rank: int = 0
	if count >= 6:
		new_rank = 3
	elif count >= 3:
		new_rank = 2
	elif count >= 1:
		new_rank = 1
	if new_rank > operacao_rank:
		operacao_rank = new_rank

func get_rank_display_name() -> String:
	match operacao_rank:
		1: return "Agente"
		2: return "Operativo"
		3: return "Comandante"
		_: return "Recruta"

# --- Class selection ---

func select_class(class_id: String) -> bool:
	ContentLibrary.ensure_loaded()
	if class_id == "":
		return false
	if ContentLibrary.get_class_definition(class_id).is_empty():
		return false
	selected_class = class_id
	return true

func has_selected_class() -> bool:
	return selected_class != ""

func get_class_deck_ids() -> Array:
	if has_selected_class():
		var deck: Array = ContentLibrary.get_class_starter_deck_ids(selected_class)
		if not deck.is_empty():
			return deck
	# Fallback: generic starter deck for saves without a selected class
	return ContentLibrary.get_starter_deck_ids()

func initialize_deck_for_class() -> void:
	if not has_selected