class_name SliceCatalogResource
extends Resource

@export var player_hero: Resource
@export var enemy_hero: Resource
@export var cards: Array[Resource] = []
@export var starter_deck_ids: PackedStringArray = PackedStringArray()
@export var class_options: Array[Dictionary] = []
@export var first_npc_reward_card_id: String = ""
@export var reward_card_id: String = ""
@export var npc_reward_choices: PackedStringArray = PackedStringArray()
@export var enemy_script: Array[Dictionary] = []
@export var default_encounter_id: String = "pouso_elemental"
@export var boards: Array[Dictionary] = []
@export var encounters: Array[Dictionary] = []
@export var run_map: Dictionary = {}
@export var track_contract: Dictionary = {}
@export var definition_hash: String = ""

func find_card(card_id: String):
	for card in cards:
		if card.id == card_id:
			return card
	return null

func find_class_option(class_id: String) -> Dictionary:
	for class_option: Dictionary in class_options:
		if str(class_option.get("id", "")) == class_id:
			return class_option
	return {}

func card_name(card_id: String) -> String:
	var card = find_card(card_id)
	if card == null:
		return card_id
	return card.display_name

func find_board(board_id: String) -> Dictionary:
	for board: Dictionary in boards:
		if str(board.get("id", "")) == board_id:
			return board
	return {}

func find_encounter(encounter_id: String) -> Dictionary:
	for encounter: Dictionary in encounters:
		if str(encounter.get("id", "")) == encounter_id:
			return encounter
	return {}

func all_encounters() -> Array[Dictionary]:
	return encounters.duplicate()

func all_class_options() -> Array[Dictionary]:
	return class_options.duplicate()
