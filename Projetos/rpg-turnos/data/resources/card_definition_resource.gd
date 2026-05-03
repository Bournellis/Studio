class_name CardDefinitionResource
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var card_type: String = ""
@export var cost: int = 0
@export var attack: int = 0
@export var health: int = 0
@export var text: String = ""
@export var keywords: PackedStringArray = PackedStringArray()
@export var effect: Dictionary = {}

func occupies_slot() -> bool:
	return card_type == "unit" or card_type == "structure" or card_type == "support"

func has_keyword(keyword: String) -> bool:
	return keywords.has(keyword)

func is_damage_spell() -> bool:
	return card_type == "spell" and str(effect.get("action", "")) == "damage"

func is_buff_command() -> bool:
	return card_type == "command" and str(effect.get("action", "")) == "buff_health"
