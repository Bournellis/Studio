class_name LoadoutData
extends Resource

const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")

@export var race: RaceDefinitionResource
@export var weapon: WeaponDefinitionResource
@export var skills: Array[SkillDefinitionResource] = []
@export var potions: Array[PotionDefinitionResource] = []

func is_valid() -> bool:
	return race != null and weapon != null and skills.size() == 4 and potions.size() == 2

func get_skill_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	for skill: SkillDefinitionResource in skills:
		if skill != null:
			ids.append(String(skill.id))
	return ids

func get_potion_ids() -> PackedStringArray:
	var ids: PackedStringArray = []
	for potion: PotionDefinitionResource in potions:
		if potion != null:
			ids.append(String(potion.id))
	return ids

func to_id_payload() -> Dictionary:
	return {
		"race_id": "" if race == null else String(race.id),
		"weapon_id": "" if weapon == null else String(weapon.id),
		"skill_ids": Array(get_skill_ids()),
		"potion_ids": Array(get_potion_ids())
	}
