extends "res://addons/gut/test.gd"

const RaceDefinitionResource = preload("res://gameplay/content/race_definition_resource.gd")
const WeaponDefinitionResource = preload("res://gameplay/content/weapon_definition_resource.gd")
const SkillDefinitionResource = preload("res://gameplay/content/skill_definition_resource.gd")
const PotionDefinitionResource = preload("res://gameplay/content/potion_definition_resource.gd")
const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const LoadoutValidator = preload("res://gameplay/loadouts/loadout_validator.gd")

func test_canonical_loadout_respects_shared_contract() -> void:
	var race: RaceDefinitionResource = RaceDefinitionResource.new()
	race.id = &"heroic"
	race.display_name = "Heroico"

	var weapon: WeaponDefinitionResource = WeaponDefinitionResource.new()
	weapon.id = &"heroic_hammer"
	weapon.race_id = race.id
	weapon.display_name = "Martelo Heroico"

	var skill_a: SkillDefinitionResource = SkillDefinitionResource.new()
	skill_a.id = &"hammer_impact"
	skill_a.race_id = race.id
	skill_a.weapon_id = weapon.id

	var skill_b: SkillDefinitionResource = SkillDefinitionResource.new()
	skill_b.id = &"heroic_rally"
	skill_b.race_id = race.id
	skill_b.weapon_id = weapon.id

	var skill_c: SkillDefinitionResource = SkillDefinitionResource.new()
	skill_c.id = &"seismic_ring"
	skill_c.race_id = race.id
	skill_c.weapon_id = weapon.id

	var skill_d: SkillDefinitionResource = SkillDefinitionResource.new()
	skill_d.id = &"breaker_leap"
	skill_d.race_id = race.id
	skill_d.weapon_id = weapon.id

	var potion_a: PotionDefinitionResource = PotionDefinitionResource.new()
	potion_a.id = &"vital_flask"
	potion_a.race_id = race.id

	var potion_b: PotionDefinitionResource = PotionDefinitionResource.new()
	potion_b.id = &"bastion_tonic"
	potion_b.race_id = race.id

	var loadout: LoadoutData = LoadoutData.new()
	loadout.race = race
	loadout.weapon = weapon
	loadout.skills = [skill_a, skill_b, skill_c, skill_d]
	loadout.potions = [potion_a, potion_b]

	var result: Dictionary = LoadoutValidator.new().validate(loadout)
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func test_loadout_validator_rejects_missing_skill_slot() -> void:
	var loadout: LoadoutData = LoadoutData.new()
	loadout.race = RaceDefinitionResource.new()
	loadout.race.id = &"heroic"

	loadout.weapon = WeaponDefinitionResource.new()
	loadout.weapon.race_id = loadout.race.id

	var result: Dictionary = LoadoutValidator.new().validate(loadout)
	assert_false(bool(result.get("ok", false)))
	assert_eq(str(result.get("message", "")), "Selecione exatamente 4 habilidades para fechar o kit livre.")
