extends Node

const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")
const RaceCatalogResource = preload("res://gameplay/content/race_catalog_resource.gd")
const WeaponCatalogResource = preload("res://gameplay/content/weapon_catalog_resource.gd")
const SkillCatalogResource = preload("res://gameplay/content/skill_catalog_resource.gd")
const PotionCatalogResource = preload("res://gameplay/content/potion_catalog_resource.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")

const RACE_CATALOG_PATH: String = "res://resources/generated/catalogs/race_catalog.tres"
const WEAPON_CATALOG_PATH: String = "res://resources/generated/catalogs/weapon_catalog.tres"
const SKILL_CATALOG_PATH: String = "res://resources/generated/catalogs/skill_catalog.tres"
const POTION_CATALOG_PATH: String = "res://resources/generated/catalogs/potion_catalog.tres"

var _loaded: bool = false
var _races: Array[RaceDefinitionResource] = []
var _weapons: Array[WeaponDefinitionResource] = []
var _skills: Array[SkillDefinitionResource] = []
var _potions: Array[PotionDefinitionResource] = []

var _race_by_id: Dictionary[StringName, RaceDefinitionResource] = {}
var _weapon_by_id: Dictionary[StringName, WeaponDefinitionResource] = {}
var _skill_by_id: Dictionary[StringName, SkillDefinitionResource] = {}
var _potion_by_id: Dictionary[StringName, PotionDefinitionResource] = {}

func ensure_loaded() -> void:
	if _loaded:
		return

	_load_catalogs()
	_loaded = true

func reload() -> void:
	unload()
	ensure_loaded()

func unload() -> void:
	_loaded = false
	_races.clear()
	_weapons.clear()
	_skills.clear()
	_potions.clear()
	_race_by_id.clear()
	_weapon_by_id.clear()
	_skill_by_id.clear()
	_potion_by_id.clear()

func get_races() -> Array[RaceDefinitionResource]:
	ensure_loaded()
	return _races.duplicate()

func get_weapons_for_race(race_id: StringName) -> Array[WeaponDefinitionResource]:
	ensure_loaded()
	var result: Array[WeaponDefinitionResource] = []
	for weapon: WeaponDefinitionResource in _weapons:
		if weapon.race_id == race_id:
			result.append(weapon)
	return result

func get_skills_for_weapon(race_id: StringName, weapon_id: StringName) -> Array[SkillDefinitionResource]:
	ensure_loaded()
	var result: Array[SkillDefinitionResource] = []
	var race: RaceDefinitionResource = get_race(race_id)
	var allowed_skill_ids: Dictionary = {}
	if race != null:
		for skill_id: String in race.skill_ids:
			allowed_skill_ids[StringName(skill_id)] = true
	for skill: SkillDefinitionResource in _skills:
		if skill.race_id != race_id:
			continue
		if skill.weapon_id != &"" and skill.weapon_id != weapon_id:
			continue
		if not allowed_skill_ids.is_empty() and not allowed_skill_ids.has(skill.id):
			continue
		result.append(skill)
	return result

func get_potions_for_race(race_id: StringName) -> Array[PotionDefinitionResource]:
	ensure_loaded()
	var result: Array[PotionDefinitionResource] = []
	var race: RaceDefinitionResource = get_race(race_id)
	var allowed_potion_ids: Dictionary = {}
	if race != null:
		for potion_id: String in race.potion_ids:
			allowed_potion_ids[StringName(potion_id)] = true
	for potion: PotionDefinitionResource in _potions:
		if potion.race_id == &"" or potion.race_id == race_id:
			if not allowed_potion_ids.is_empty() and not allowed_potion_ids.has(potion.id):
				continue
			result.append(potion)
	return result

func get_race(race_id: StringName) -> RaceDefinitionResource:
	ensure_loaded()
	return _race_by_id.get(race_id)

func get_weapon(weapon_id: StringName) -> WeaponDefinitionResource:
	ensure_loaded()
	return _weapon_by_id.get(weapon_id)

func get_skill(skill_id: StringName) -> SkillDefinitionResource:
	ensure_loaded()
	return _skill_by_id.get(skill_id)

func get_potion(potion_id: StringName) -> PotionDefinitionResource:
	ensure_loaded()
	return _potion_by_id.get(potion_id)

func build_loadout_from_ids(race_id: StringName, weapon_id: StringName, skill_ids: PackedStringArray, potion_ids: PackedStringArray) -> LoadoutData:
	ensure_loaded()
	var loadout: LoadoutData = LoadoutData.new()
	loadout.race = get_race(race_id)
	loadout.weapon = get_weapon(weapon_id)
	loadout.skills = []
	loadout.potions = []

	for skill_id: String in skill_ids:
		var skill: SkillDefinitionResource = get_skill(StringName(skill_id))
		if skill != null:
			loadout.skills.append(skill)

	for potion_id: String in potion_ids:
		var potion: PotionDefinitionResource = get_potion(StringName(potion_id))
		if potion != null:
			loadout.potions.append(potion)

	return loadout

func _load_catalogs() -> void:
	var race_catalog: RaceCatalogResource = load(RACE_CATALOG_PATH)
	var weapon_catalog: WeaponCatalogResource = load(WEAPON_CATALOG_PATH)
	var skill_catalog: SkillCatalogResource = load(SKILL_CATALOG_PATH)
	var potion_catalog: PotionCatalogResource = load(POTION_CATALOG_PATH)

	if race_catalog == null or weapon_catalog == null or skill_catalog == null or potion_catalog == null:
		push_warning("Generated content catalogs are missing. Run tools/validate.gd to generate them.")
		return

	_races = race_catalog.entries.duplicate()
	_weapons = weapon_catalog.entries.duplicate()
	_skills = skill_catalog.entries.duplicate()
	_potions = potion_catalog.entries.duplicate()

	for race: RaceDefinitionResource in _races:
		_race_by_id[race.id] = race
	for weapon: WeaponDefinitionResource in _weapons:
		_weapon_by_id[weapon.id] = weapon
	for skill: SkillDefinitionResource in _skills:
		_skill_by_id[skill.id] = skill
	for potion: PotionDefinitionResource in _potions:
		_potion_by_id[potion.id] = potion
