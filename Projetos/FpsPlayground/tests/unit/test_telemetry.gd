extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const ArenaTelemetryRecorderScript = preload("res://gameplay/telemetry/arena_telemetry_recorder.gd")

func before_all() -> void:
	var result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func after_each() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func test_telemetry_recorder_builds_schema_and_summary() -> void:
	var recorder = ArenaTelemetryRecorderScript.new()
	recorder.start_session({
		"session_id": "unit_session",
		"map_id": &"duel_pit_v2",
		"map_name": "Duel Pit V2",
		"round_index": 1,
		"score_to_win": 3
	}, false)
	recorder.record_event(&"round_start", {"reason": &"unit"})
	recorder.record_event(&"shot_fired", {"actor": "player", "weapon": "rifle", "overcharged": false})
	recorder.record_event(&"shot_hit", {"actor": "player", "target": "bot", "weapon": "rifle"})
	recorder.record_event(&"damage_applied", {
		"actor": "player",
		"target": "bot",
		"weapon": "rifle",
		"source": "player_rifle",
		"damage": 22.0
	})
	recorder.record_event(&"pickup_collected", {
		"actor": "player",
		"pickup_kind": &"health",
		"healing_applied": 10.0,
		"healing_wasted": 18.0
	})
	recorder.record_event(&"movement_sample", {
		"distance_between": 8.0,
		"player_speed": 7.8,
		"bot_speed": 4.7,
		"player_airborne": false,
		"bot_airborne": true,
		"bot_has_line_of_sight": true
	})
	recorder.record_event(&"round_end", {
		"winner": &"player",
		"duration_msec": 12000,
		"player_score": 1,
		"bot_score": 0,
		"player_health": 72.0,
		"bot_health": 0.0
	})

	var events: Array[Dictionary] = recorder.get_events()
	var summary: Dictionary = recorder.get_summary()
	assert_gt(events.size(), 0)
	assert_eq(events[0].get("schema_version", 0), 1)
	assert_eq(events[0].get("session_id", ""), "unit_session")
	assert_eq(summary.get("rounds_played", 0), 1)
	assert_eq(summary.get("winner_counts", {}).get("player", 0), 1)
	assert_almost_eq(summary.get("damage_by_source", {}).get("player_rifle", 0.0), 22.0, 0.001)
	assert_eq(summary.get("shots_by_weapon", {}).get("player:rifle", {}).get("fired", 0), 1)
	assert_eq(summary.get("shots_by_weapon", {}).get("player:rifle", {}).get("hits", 0), 1)
	assert_almost_eq(summary.get("pickups", {}).get("health", {}).get("effective_healing", 0.0), 10.0, 0.001)
	assert_eq(summary.get("movement", {}).get("samples", 0), 1)
	assert_eq(summary.get("movement", {}).get("bot_airborne_samples", 0), 1)
	assert_eq(summary.get("bot", {}).get("line_of_sight_true_samples", 0), 1)
	assert_no_new_orphans()

func test_telemetry_recorder_can_write_local_files() -> void:
	var recorder = ArenaTelemetryRecorderScript.new()
	var output_dir := "user://telemetry_test/%d" % Time.get_ticks_usec()
	recorder.start_session({
		"session_id": "file_session",
		"map_id": &"duel_pit_v2",
		"map_name": "Duel Pit V2",
		"round_index": 1
	}, true, output_dir)
	recorder.record_event(&"round_start", {"reason": &"file_test"})
	recorder.finish_session({"reason": &"unit_done"})

	var paths: Dictionary = recorder.get_output_paths()
	assert_true(bool(paths.get("file_output_enabled", false)))
	assert_true(FileAccess.file_exists(str(paths.get("events_file", ""))))
	assert_true(FileAccess.file_exists(str(paths.get("summary_file", ""))))
	assert_no_new_orphans()

func test_telemetry_recorder_keeps_plasma_blast_out_of_weapon_accuracy() -> void:
	var recorder = ArenaTelemetryRecorderScript.new()
	recorder.start_session({
		"session_id": "blast_metrics_session",
		"map_id": &"relay_foundry_v1",
		"map_name": "Relay Foundry V1",
		"round_index": 1
	}, false)
	recorder.record_event(&"shot_fired", {
		"actor": "player",
		"weapon": "plasma_direct",
		"overcharged": true
	})
	recorder.record_event(&"shot_hit", {
		"actor": "player",
		"target": "bot",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"overcharged": true
	})
	recorder.record_event(&"damage_applied", {
		"actor": "player",
		"target": "bot",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"damage": 12.0,
		"overcharged": true
	})
	recorder.record_event(&"plasma_blast", {
		"actor": "player",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"damaged_target": true
	})
	recorder.record_event(&"shot_miss", {
		"actor": "player",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"overcharged": true
	})
	recorder.record_event(&"plasma_blast", {
		"actor": "player",
		"weapon": "plasma_blast",
		"source": "player_plasma_blast",
		"damaged_target": false
	})

	var summary: Dictionary = recorder.get_summary()
	var shots: Dictionary = summary.get("shots_by_weapon", {})
	var plasma: Dictionary = summary.get("plasma", {})
	assert_true(shots.has("player:plasma_direct"))
	assert_false(shots.has("player:plasma_blast"))
	assert_eq(shots.get("player:plasma_direct", {}).get("fired", 0), 1)
	assert_eq(plasma.get("blast_hits", 0), 1)
	assert_eq(plasma.get("blast_misses", 0), 1)
	assert_almost_eq(plasma.get("blast_damage", 0.0), 12.0, 0.001)
	assert_almost_eq(summary.get("damage_by_source", {}).get("player_plasma_blast", 0.0), 12.0, 0.001)
	assert_eq(summary.get("overcharge", {}).get("misses", 0), 1)
	assert_no_new_orphans()

func test_arena_telemetry_records_round_combat_pickup_and_movement() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	player.global_position = Vector3(-9.0, 0.05, 0.0)
	bot.global_position = Vector3(-9.0, 0.05, -7.0)
	await get_tree().physics_frame

	var direction: Vector3 = (bot.get_body_center() - player.get_shot_origin()).normalized()
	arena._on_player_shot(player.get_shot_origin(), direction, player.shot_damage, player.shot_knockback)

	player.take_damage(35.0)
	var health_position: Vector3 = arena.debug_get_pickup_position(&"health")
	player.global_position += health_position - player.get_body_center()
	assert_true(arena._try_consume_pickup(&"health", player))

	for _index in range(16):
		await get_tree().physics_frame

	arena.debug_force_round_result(true)
	var summary: Dictionary = arena.debug_get_telemetry_summary()
	var events: Array[Dictionary] = arena.debug_get_telemetry_events()
	assert_gt(events.size(), 0)
	assert_gte(summary.get("event_counts", {}).get("session_start", 0), 1)
	assert_gte(summary.get("event_counts", {}).get("arena_setup", 0), 1)
	assert_gte(summary.get("event_counts", {}).get("round_start", 0), 1)
	assert_gte(summary.get("event_counts", {}).get("shot_fired", 0), 1)
	assert_gte(summary.get("event_counts", {}).get("damage_applied", 0), 1)
	assert_gte(summary.get("event_counts", {}).get("pickup_collected", 0), 1)
	assert_gte(summary.get("event_counts", {}).get("movement_sample", 0), 1)
	assert_eq(summary.get("rounds_played", 0), 1)
	assert_eq(summary.get("winner_counts", {}).get("player", 0), 1)
	assert_gt(summary.get("damage_by_source", {}).get("player_rifle", 0.0), 0.0)
	assert_gt(summary.get("pickups", {}).get("health", {}).get("collected", 0), 0)
	assert_false(bool(arena.debug_get_telemetry_output_paths().get("file_output_enabled", true)))
	assert_no_new_orphans()

func test_arena_telemetry_preserves_track10_gameplay_values() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	assert_almost_eq(player.move_speed, 7.8, 0.001)
	assert_almost_eq(player.jump_velocity, 5.6, 0.001)
	assert_almost_eq(player.air_control, 0.72, 0.001)
	assert_almost_eq(player.shot_damage, 22.0, 0.001)
	assert_almost_eq(player.shot_cooldown, 0.18, 0.001)
	assert_almost_eq(player.alt_fire_damage, 24.0, 0.001)
	assert_almost_eq(player.alt_fire_cooldown, 0.9, 0.001)
	assert_almost_eq(arena._build_jump_pad_launch_velocity({
		"position": Vector3.ZERO,
		"target": Vector3.FORWARD * 10.0
	}).y, 8.4, 0.001)
	assert_almost_eq(bot.shoot_damage, 9.0, 0.001)
	assert_almost_eq(bot.shoot_cooldown, 0.76, 0.001)
	assert_no_new_orphans()
