class_name SliceCatalogResource
extends Resource

@export var player_hero: Resource
@export var enemy_hero: Resource
@export var cards: Array[Resource] = []
@export var starter_deck_ids: PackedStringArray = PackedStringArray()
@export var first_npc_reward_card_id: String = ""
@export var reward_card_id: String = ""
@export var npc_reward_choices: PackedStringArray = PackedStringArray()
@export var enemy_script: Array[Dictionary] = []
@export var default_encounter_id: String = "operacao_pouso"
@export var boards: Array[Dictionary] = []
@export var encounters: Array[Dictionary] = []
@export var classes: Array[Dictionary] = []

func find_card(card_id: String):
	for card in cards:
		if card.id == card_id:
			return card
	return null

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

func find_class(class_id: String) -> Dictionary:
	for class_data: Dictionary in classes:
		if str(class_data.get("id", "")) == class_id:
			return class_data
	return {}
