extends GutTest

const BattleLabScreenScript = preload("res://dev/battle_lab/battle_lab_screen.gd")

func test_battle_lab_power_formula_matches_contract() -> void:
	var build := {
		"id": "test",
		"displayName": "Test",
		"level": 10,
		"weaponId": "varinha_cinzas",
		"weaponLevel": 8,
		"weaponQualityTier": 2,
		"spellIds": ["sussurro_medo", "descarga_nervosa"],
		"spellLevels": {"sussurro_medo": 7, "descarga_nervosa": 6},
		"passiveId": "anatomista_profano",
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
	assert_true(BattleLabScreenScript.allowed_spell_ids(25).has("marca_sepulcral"))

func test_battle_lab_deno_invocation_sanitizes_project_settings() -> void:
	var settings_prefix := "draxos_mobile/battle_lab"
	var command_path := "%s/deno_command" % settings_prefix
	var args_path := "%s/deno_prefix_args" % settings_prefix
	var original_command: Variant = ProjectSettings.get_setting(command_path)
	var original_args: Variant = ProjectSettings.get_setting(args_path)
	var fallback := PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write"])

	ProjectSettings.set_setting(command_path, "npx -y deno run --allow-read --allow-write D:/tmp/generate.ts --request stale")
	var inline_invocation := BattleLabScreenScript.deno_invocation(settings_prefix, fallback)
	var inline_args := PackedStringArray(inline_invocation.get("args", PackedStringArray()))
	assert_eq(str(inline_invocation.get("command", "")), "npx")
	assert_eq(" ".join(inline_args), "-y deno run --allow-read --allow-write")

	ProjectSettings.set_setting(command_path, "npx")
	ProjectSettings.set_setting(args_path, PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "D:/tmp/generate.ts", "--request", "stale"]))
	var prefix_invocation := BattleLabScreenScript.deno_invocation(settings_prefix, fallback)
	var prefix_args := PackedStringArray(prefix_invocation.get("args", PackedStringArray()))
	prefix_args.append("mutated-locally")
	var repeated_invocation := BattleLabScreenScript.deno_invocation(settings_prefix, fallback)
	var repeated_args := PackedStringArray(repeated_invocation.get("args", PackedStringArray()))
	assert_eq(" ".join(repeated_args), "-y deno run --allow-read --allow-write")
	assert_false(repeated_args.has("mutated-locally"))

	ProjectSettings.set_setting(command_path, original_command)
	ProjectSettings.set_setting(args_path, original_args)
