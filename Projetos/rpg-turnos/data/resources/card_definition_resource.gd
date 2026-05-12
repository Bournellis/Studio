class_name CardDefinitionResource
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var card_type: String = ""
@export var cost: int = 0
@export var command_cost: int = 0
@export var speed: String = "normal"
@export var attack: int = 0
@export var health: int = 0
@export var text: String = ""
@export var keywords: PackedStringArray = PackedStringArray()
@export var effect: Dictionary = {}

func occupies_slot() -> bool:
	return card_type in ["criatura", "estrutura", "permanente", "unit", "structure", "support"]

func has_keyword(keyword: String) -> bool:
	return keywords.has(keyword)

func is_damage_spell() -> bool:
	return card_type in ["magia", "spell"] and (str(effect.get("action", "")) == "damage" or effect.has("damage") or effect.has("amount"))

func is_board_spell() -> bool:
	return card_type == "magia_de_tabuleiro"

func is_buff_command() -> bool:
	return card_type in ["comando", "command"] and str(effect.get("action", "")) == "buff_health"

func is_stat_buff_spell() -> bool:
	return card_type in ["magia", "spell"] and str(effect.get("action", "")) == "gain_stats"
