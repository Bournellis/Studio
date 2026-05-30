extends GutTest

const SessionStoreScript = preload("res://online/session_store.gd")
const ProgressionLabScreenScript = preload("res://dev/progression_lab/progression_lab_screen.gd")

func test_progression_lab_screen_profiles_and_milestones_match_model() -> void:
	var model := _read_json("res://tools/progression_lab/model.v1.json")
	var model_profiles := PackedStringArray()
	for profile: Variant in _as_array(model.get("profiles", [])):
		model_profiles.append(str(_as_dictionary(profile).get("id", "")))
	var model_milestones := PackedStringArray()
	for milestone: Variant in _as_array(model.get("milestones", [])):
		model_milestones.append(str(_as_dictionary(milestone).get("id", "")))
	assert_eq(PackedStringArray(ProgressionLabScreenScript.PROFILE_IDS), model_profiles)
	assert_eq(PackedStringArray(ProgressionLabScreenScript.MILESTONE_IDS), model_milestones)

func test_progression_lab_generated_saves_cover_manual_smoke_milestones() -> void:
	var doc := _read_json("res://docs/progression-lab/generated/healthy_saves.json")
	var saves := _as_array(doc.get("saves", []))
	var ids := {}
	for item: Variant in saves:
		var save := _as_dictionary(item)
		ids[str(save.get("id", ""))] = true
	assert_true(bool(ids.get("free_100_rewards_2h", false)))
	assert_true(bool(ids.get("free_100_rewards_10h", false)))
	assert_true(bool(ids.get("free_100_rewards_20h", false)))
	assert_eq(saves.size(), 25)

func test_session_store_accepts_progression_lab_snapshot_cache() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	var applied := store.apply_snapshot_cache({
		"cache_version": 1,
		"auth": {
			"access_token": "token",
			"refresh_token": "refresh",
			"expires_at": now + 3600,
			"user_id": "auth-user",
		},
		"session_id": "11111111-1111-4111-8111-111111111111",
		"guest_request_id": "22222222-2222-4222-8222-222222222222",
		"player": {
			"id": "player-1",
			"username": "plab_free_100_rewards_10h",
			"level": 14,
			"power": 1517,
		},
		"resources": {
			"player_id": "player-1",
			"almas": 194,
			"energia": 115,
			"sangue": 145,
			"cristais": 11,
			"ossos": 33,
			"diamante": 1,
		},
		"build": {
			"player_id": "player-1",
			"weapon_type": "varinha_cinzas",
			"weapon_quality": "starter",
			"weapon_level": 11,
			"spell_slots": ["descarga_nervosa", "sussurro_medo"],
			"spells_unlocked": ["sussurro_medo", "descarga_nervosa"],
			"pet_id": null,
			"pet_level": 0,
			"passive_id": "anatomista_profano",
			"passive_level": 1,
		},
		"progression_lab": {
			"save_id": "free_100_rewards_10h",
			"profile_id": "free_100_rewards",
			"milestone_id": "10h",
		},
	})
	assert_true(applied)
	assert_true(store.has_valid_access_token(now))
	assert_false(store.is_progression_lab_local_only())
	assert_true(store.has_account_state())
	assert_eq(str(store.player.get("username", "")), "plab_free_100_rewards_10h")
	assert_eq(int(store.resources.get("energia", 0)), 115)
	store.free()

func test_progression_lab_builds_local_snapshot_cache_from_healthy_save() -> void:
	var doc := _read_json("res://docs/progression-lab/generated/healthy_saves.json")
	var save := _as_dictionary(_as_array(doc.get("saves", []))[0])
	var cache := ProgressionLabScreenScript.session_cache_from_save(save)
	var store = SessionStoreScript.new()
	var auth := _as_dictionary(cache.get("auth", {}))
	assert_eq(str(auth.get("access_token", "")), "")
	assert_eq(int(auth.get("expires_at", -1)), 0)
	assert_true(store.apply_snapshot_cache(cache))
	assert_false(store.has_valid_access_token())
	assert_true(store.is_progression_lab_local_only())
	assert_true(store.has_account_state())
	assert_eq(str(store.player.get("username", "")), str(_as_dictionary(save.get("player", {})).get("username", "")))
	assert_eq(str(_as_dictionary(cache.get("progression_lab", {})).get("save_id", "")), str(save.get("id", "")))
	assert_eq(store.progression_lab_label(), "%s/%s" % [str(save.get("profile_id", "")), str(save.get("milestone_id", ""))])
	assert_eq(str(store.build.get("weapon_type", "")), str(_as_dictionary(save.get("build", {})).get("weapon_type", "")))
	var build_state := _as_dictionary(cache.get("build_state", {}))
	var combat_build := _as_dictionary(build_state.get("combat_build", {}))
	assert_true(build_state.has("potion_slots"))
	assert_true(build_state.has("inventory"))
	assert_true(combat_build.has("spellBehaviors"))
	store.free()

func test_progression_lab_deno_invocation_sanitizes_project_settings() -> void:
	var settings_prefix := "draxos_mobile/progression_lab"
	var command_path := "%s/deno_command" % settings_prefix
	var args_path := "%s/deno_prefix_args" % settings_prefix
	var original_command: Variant = ProjectSettings.get_setting(command_path)
	var original_args: Variant = ProjectSettings.get_setting(args_path)
	var fallback := PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "--allow-env", "--allow-net"])

	ProjectSettings.set_setting(command_path, "npx -y deno run --allow-read --allow-write --allow-env --allow-net D:/tmp/generate.ts")
	var inline_invocation := ProgressionLabScreenScript.deno_invocation(settings_prefix, fallback)
	var inline_args := _runner_args(inline_invocation, ["npx", "npx.cmd"])
	assert_eq(" ".join(inline_args), "-y deno run --allow-read --allow-write --allow-env --allow-net")

	ProjectSettings.set_setting(command_path, "npx")
	ProjectSettings.set_setting(args_path, PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "--allow-env", "--allow-net", "D:/tmp/generate.ts", "--profile", "old"]))
	var prefix_invocation := ProgressionLabScreenScript.deno_invocation(settings_prefix, fallback)
	var prefix_args := _runner_args(prefix_invocation, ["npx", "npx.cmd"])
	prefix_args.append("mutated-locally")
	var repeated_invocation := ProgressionLabScreenScript.deno_invocation(settings_prefix, fallback)
	var repeated_args := _runner_args(repeated_invocation, ["npx", "npx.cmd"])
	assert_eq(" ".join(repeated_args), "-y deno run --allow-read --allow-write --allow-env --allow-net")
	assert_false(repeated_args.has("mutated-locally"))

	ProjectSettings.set_setting(command_path, original_command)
	ProjectSettings.set_setting(args_path, original_args)

func _runner_args(invocation: Dictionary, expected_windows_runner: Array[String]) -> PackedStringArray:
	var command := str(invocation.get("command", ""))
	var args := PackedStringArray(invocation.get("args", PackedStringArray()))
	if OS.get_name() != "Windows":
		assert_true(expected_windows_runner.has(command.get_file().to_lower()))
		return args

	assert_eq(command.get_file().to_lower(), "cmd.exe")
	assert_gte(args.size(), 2)
	assert_eq(args[0], "/C")
	assert_true(expected_windows_runner.has(str(args[1]).get_file().to_lower()))
	var runner_args := PackedStringArray()
	for index: int in range(2, args.size()):
		runner_args.append(args[index])
	return runner_args

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return _as_dictionary(parsed)

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _as_array(value: Variant) -> Array:
	return value if value is Array else []
