extends GutTest

const BattleLabScreenScript = preload("res://dev/battle_lab/battle_lab_screen.gd")

func test_battle_lab_power_formula_matches_contract() -> void:
	var build := {
		"id": "test",
		"displayName": "Test",
		"level": 10,
		"weaponLevel": 8,
		"weaponQualityTier": 2,
		"spellIds": ["raio_cosmico", "raio"],
		"spellLevels": {"raio_cosmico": 7, "raio": 6},
		"passiveId": "forca",
		"passiveLevel": 5,
	}
	assert_eq(BattleLabScreenScript.calculate_power(build), 1100)

func test_battle_lab_unlock_validation_rejects_locked_slots() -> void:
	var build := BattleLabScreenScript.default_build("player", 1)
	var errors: Array[String] = BattleLabScreenScript.validate_build(build)
	assert_gt(errors.size(), 0)
	assert_true("\n".join(errors).contains("spell"))
	assert_true("\n".join(errors).contains("passiva"))
	assert_true("\n".join(errors).contains("pet"))

func test_battle_lab_default_level_25_build_is_valid() -> void:
	var build := BattleLabScreenScript.default_build("player", 25)
	var errors: Array[String] = BattleLabScreenScript.validate_build(build)
	assert_eq(errors.size(), 0)
	assert_eq(BattleLabScreenScript.max_spell_slots(25), 3)
	assert_true(BattleLabScreenScript.allowed_spell_ids(25).has("odio"))
