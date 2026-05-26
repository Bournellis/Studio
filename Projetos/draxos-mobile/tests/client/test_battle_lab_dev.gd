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

func test_battle_lab_replay_response_registers_custom_replay() -> void:
	var screen = BattleLabScreenScript.new()
	add_child_autofree(screen)
	screen._refresh_from_response({
		"schema_version": "battle_lab_response_v1",
		"ok": true,
		"mode": "replay",
		"status": "PASS",
		"replay": {
			"tag": "custom",
			"matchup_id": "godot_custom_replay",
			"player_build_id": "player_custom",
			"opponent_build_id": "opponent_custom",
			"duration": 12.5,
			"winner": "player",
			"battle_log": {
				"schema_version": "battle_log_v1",
				"events": [
					{"t": 1.0, "seq": 1, "type": "spell_cast", "source": "player", "target": "opponent", "hp_after": 10},
				],
			},
			"rewards": {},
		},
	})
	assert_eq(screen._last_replays.size(), 1)
	assert_eq(screen._custom_replays.size(), 1)
	assert_true(screen._replay_title_label.text.contains("godot_custom_replay"))
	assert_true(screen._history_label.text.contains("Custom replays"))
	assert_eq(screen._tabs.current_tab, 3)
	assert_not_null(screen._battle_visual)
	assert_eq(screen._battle_visual.get_event_count(), 1)
	assert_true(screen._tabs.get_child(3) is ScrollContainer)
	assert_eq(screen._replay_speed_label.text, "100% do tempo normal")
	screen._set_replay_speed(2.5)
	assert_eq(screen._replay_speed_label.text, "250% do tempo normal")

func test_battle_lab_autoplay_tracks_battle_log_time_for_cooldowns() -> void:
	var screen = BattleLabScreenScript.new()
	add_child_autofree(screen)
	screen._refresh_from_response({
		"schema_version": "battle_lab_response_v1",
		"ok": true,
		"mode": "replay",
		"status": "PASS",
		"replay": {
			"tag": "custom",
			"matchup_id": "godot_timed_replay",
			"player_build_id": "player_custom",
			"opponent_build_id": "opponent_custom",
			"duration": 4.0,
			"winner": "player",
			"battle_log": {
				"schema_version": "battle_log_v1",
				"events": [
					{"t": 0.5, "seq": 1, "type": "cooldown_start", "source": "player", "target": "player", "spell_id": "marca_brasa", "ready_at": 4.0},
					{"t": 1.0, "seq": 2, "type": "spell_cast", "source": "player", "target": "opponent", "hp_after": 10},
					{"t": 4.0, "seq": 3, "type": "cooldown_ready", "source": "player", "target": "player", "spell_id": "marca_brasa"},
				],
			},
			"rewards": {},
		},
	})

	screen._replay_playing = true
	screen._process(1.5)

	var snapshot := Dictionary(screen._battle_visual.debug_snapshot())
	var stage := Dictionary(snapshot.get("stage", {}))
	var cooldown_counts := Dictionary(stage.get("cooldown_counts", {}))
	assert_eq(screen._replay_index, 2)
	assert_eq(float(snapshot.get("replay_time", 0.0)), 1.5)
	assert_true(Array(cooldown_counts.get("player", [])).has("2.5s"))

	screen._process(2.5)
	snapshot = Dictionary(screen._battle_visual.debug_snapshot())
	stage = Dictionary(snapshot.get("stage", {}))
	cooldown_counts = Dictionary(stage.get("cooldown_counts", {}))
	assert_eq(screen._replay_index, 3)
	assert_false(screen._replay_playing)
	assert_true(Array(cooldown_counts.get("player", [])).has(""))

func test_battle_lab_deno_invocation_sanitizes_project_settings() -> void:
	var settings_prefix := "draxos_mobile/battle_lab"
	var command_path := "%s/deno_command" % settings_prefix
	var args_path := "%s/deno_prefix_args" % settings_prefix
	var original_command: Variant = ProjectSettings.get_setting(command_path)
	var original_args: Variant = ProjectSettings.get_setting(args_path)
	var fallback := PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write"])

	ProjectSettings.set_setting(command_path, "npx -y deno run --allow-read --allow-write D:/tmp/generate.ts --request stale")
	var inline_invocation := BattleLabScreenScript.deno_invocation(settings_prefix, fallback)
	var inline_args := _runner_args(inline_invocation, ["npx", "npx.cmd"])
	assert_eq(" ".join(inline_args), "-y deno run --allow-read --allow-write")

	ProjectSettings.set_setting(command_path, "npx")
	ProjectSettings.set_setting(args_path, PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "D:/tmp/generate.ts", "--request", "stale"]))
	var prefix_invocation := BattleLabScreenScript.deno_invocation(settings_prefix, fallback)
	var prefix_args := _runner_args(prefix_invocation, ["npx", "npx.cmd"])
	prefix_args.append("mutated-locally")
	var repeated_invocation := BattleLabScreenScript.deno_invocation(settings_prefix, fallback)
	var repeated_args := _runner_args(repeated_invocation, ["npx", "npx.cmd"])
	assert_eq(" ".join(repeated_args), "-y deno run --allow-read --allow-write")
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
