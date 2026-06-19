extends "res://addons/gut/test.gd"

const TelemetryReadoutAnalyzerScript = preload("res://gameplay/telemetry/telemetry_readout_analyzer.gd")

func test_readout_analyzes_healthy_session() -> void:
	var session_path := "user://telemetry_readout_test/healthy_session_%d" % Time.get_ticks_usec()
	var events := _build_healthy_events()
	var summary := _build_healthy_summary(events)
	_write_session(session_path, events, summary)

	var analyzer = TelemetryReadoutAnalyzerScript.new()
	var readout: Dictionary = analyzer.analyze_session(session_path)

	assert_true(bool(readout.get("ok", false)))
	assert_true(bool(readout.get("counts_match", false)))
	assert_eq(int(readout.get("events_line_count", 0)), events.size())
	assert_eq(int(readout.get("summary_events_recorded", 0)), events.size())
	assert_eq(String(readout.get("map_name", "")), "Duel Pit V2")
	assert_eq(int(readout.get("rounds_started", 0)), 3)
	assert_eq(int(readout.get("rounds_played", 0)), 1)
	assert_eq(int(readout.get("manual_restarts", 0)), 1)
	assert_eq(_as_array(readout.get("alerts", [])).size(), 0)

	var combat: Dictionary = readout.get("combat", {})
	assert_eq(int(combat.get("shot_fired_events", 0)), 3)
	assert_almost_eq(combat.get("damage_by_source", {}).get("player_rifle", 0.0), 44.0, 0.001)
	assert_eq(_as_array(combat.get("weapons", [])).size(), 3)

	var movement: Dictionary = readout.get("movement", {})
	assert_eq(int(movement.get("jump_pad_triggers", 0)), 1)
	assert_eq(int(movement.get("jump_pad_landings", 0)), 1)
	assert_almost_eq(float(movement.get("jump_pad_landing_rate", 0.0)), 1.0, 0.001)

	var report: String = analyzer.build_text_report(readout)
	assert_string_contains(report, "Telemetry Readout")
	assert_string_contains(report, "Integrity: OK")
	assert_string_contains(report, "player:rifle")
	assert_no_new_orphans()

func test_readout_flags_mismatched_summary_and_missing_landing() -> void:
	var session_path := "user://telemetry_readout_test/broken_session_%d" % Time.get_ticks_usec()
	var events := _build_healthy_events()
	events.append(_event("jump_pad_triggered", 2400, {"actor": "bot", "pad_id": "east_pad"}))
	var summary := _build_healthy_summary(events)
	summary["events_recorded"] = int(summary.get("events_recorded", 0)) - 1
	summary["event_counts"]["jump_pad_triggered"] = int(summary["event_counts"].get("jump_pad_triggered", 0)) - 1
	summary["movement"]["jump_pad_triggers"] = 2
	summary["movement"]["jump_pad_landings"] = 1
	_write_session(session_path, events, summary)

	var analyzer = TelemetryReadoutAnalyzerScript.new()
	var readout: Dictionary = analyzer.analyze_session(session_path)
	var alerts: Array = readout.get("alerts", [])

	assert_false(bool(readout.get("ok", true)))
	assert_false(bool(readout.get("counts_match", true)))
	assert_gt(alerts.size(), 0)
	assert_true(_contains_alert(alerts, "events.jsonl and summary.json are not synchronized"))
	assert_true(_contains_alert(alerts, "jump pad landings are lower than triggers"))
	assert_no_new_orphans()

func test_readout_finds_latest_session_under_custom_root() -> void:
	var root_path := "user://telemetry_readout_test/latest_root_%d" % Time.get_ticks_usec()
	var old_session := root_path.path_join("arena_old")
	var latest_session := root_path.path_join("arena_latest")
	_write_session(old_session, _build_healthy_events(), _build_healthy_summary(_build_healthy_events()))
	await get_tree().create_timer(0.02).timeout
	_write_session(latest_session, _build_healthy_events(), _build_healthy_summary(_build_healthy_events()))

	var analyzer = TelemetryReadoutAnalyzerScript.new()
	var found_path: String = analyzer.find_latest_session(root_path)
	var readout: Dictionary = analyzer.analyze_latest(root_path)

	assert_eq(found_path, latest_session)
	assert_eq(String(readout.get("session_path", "")), latest_session)
	assert_true(bool(readout.get("ok", false)))
	assert_no_new_orphans()

func _build_healthy_events() -> Array[Dictionary]:
	return [
		_event("session_start", 0, {}),
		_event("arena_setup", 1, {"jump_pad_count": 2}),
		_event("round_start", 10, {"reason": "initial"}),
		_event("shot_fired", 100, {"actor": "player", "target": "bot", "weapon": "rifle", "overcharged": false}),
		_event("shot_hit", 120, {"actor": "player", "target": "bot", "weapon": "rifle", "overcharged": false}),
		_event("damage_applied", 121, {"actor": "player", "target": "bot", "weapon": "rifle", "source": "player_rifle", "damage": 44.0}),
		_event("shot_fired", 400, {"actor": "bot", "target": "player", "weapon": "bot_shot", "overcharged": false}),
		_event("shot_hit", 430, {"actor": "bot", "target": "player", "weapon": "bot_shot", "overcharged": false}),
		_event("damage_applied", 431, {"actor": "bot", "target": "player", "weapon": "bot_shot", "source": "bot_shot", "damage": 20.0}),
		_event("shot_fired", 700, {"actor": "player", "target": "bot", "weapon": "plasma_direct", "overcharged": true}),
		_event("shot_miss", 760, {"actor": "player", "target": "bot", "weapon": "plasma_direct", "overcharged": true}),
		_event("pickup_spawned", 800, {"pickup_kind": "health"}),
		_event("pickup_spawned", 900, {"pickup_kind": "overcharge"}),
		_event("pickup_collected", 950, {"actor": "player", "pickup_kind": "health", "healing_applied": 16.0, "healing_wasted": 4.0}),
		_event("bot_state_changed", 1000, {"state": "pressure"}),
		_event("bot_route_changed", 1100, {"route_label": "overcharge", "decision_reason": "item_priority"}),
		_event("bot_decision", 1200, {"route_label": "overcharge", "decision_reason": "item_priority"}),
		_event("movement_sample", 1300, {
			"distance_between": 9.5,
			"player_speed": 7.2,
			"bot_speed": 5.4,
			"player_airborne": false,
			"bot_airborne": true,
			"bot_has_line_of_sight": true
		}),
		_event("jump_pad_triggered", 1400, {"actor": "bot", "pad_id": "east_pad"}),
		_event("jump_pad_landing", 1800, {"actor": "bot", "pad_id": "east_pad", "success": true}),
		_event("round_end", 2000, {
			"winner": "player",
			"duration_msec": 1990,
			"player_score": 1,
			"bot_score": 0,
			"player_health": 80.0,
			"bot_health": 0.0
		}),
		_event("round_reset", 2100, {"reason": "next_round", "next_round_index": 2}),
		_event("round_start", 2101, {"reason": "round_start", "round_index": 2}),
		_event("round_reset", 2200, {"reason": "manual_restart", "round_index": 2, "next_round_index": 2}),
		_event("round_start", 2201, {"reason": "round_start", "round_index": 2}),
		_event("match_reset", 2300, {}),
		_event("session_end", 2400, {"reason": "arena_exit"})
	]

func _build_healthy_summary(events: Array[Dictionary]) -> Dictionary:
	return {
		"schema_version": 1,
		"session_id": "readout_unit",
		"map_id": "duel_pit_v2",
		"map_name": "Duel Pit V2",
		"events_recorded": events.size(),
		"event_counts": _count_events(events),
		"rounds_started": 3,
		"rounds_played": 1,
		"round_results": [{
			"round_index": 1,
			"winner": "player",
			"duration_msec": 1990,
			"player_score": 1,
			"bot_score": 0,
			"player_health": 80.0,
			"bot_health": 0.0
		}],
		"winner_counts": {"player": 1, "bot": 0},
		"damage_by_actor": {"player": 44.0, "bot": 20.0},
		"damage_by_source": {"player_rifle": 44.0, "bot_shot": 20.0, "player_plasma": 16.0},
		"shots_by_weapon": {
			"bot:bot_shot": {"fired": 1, "hits": 1, "misses": 0, "accuracy": 1.0, "damage": 20.0},
			"player:plasma_direct": {"fired": 1, "hits": 0, "misses": 1, "accuracy": 0.0, "damage": 0.0},
			"player:rifle": {"fired": 1, "hits": 1, "misses": 0, "accuracy": 1.0, "damage": 44.0}
		},
		"plasma": {
			"spawned": 1,
			"direct_hits": 0,
			"world_impacts": 1,
			"blast_hits": 1,
			"blast_misses": 0,
			"expired": 0,
			"direct_damage": 0.0,
			"blast_damage": 16.0
		},
		"overcharge": {
			"pickups": 1,
			"shots_consumed": 1,
			"useful_damage": 16.0,
			"misses": 1
		},
		"pickups": {
			"health": {
				"collected": 1,
				"respawned": 0,
				"nearby_ignored": 0,
				"contested": 0,
				"effective_healing": 16.0,
				"wasted_healing": 4.0,
				"by_actor": {"player": 1}
			}
		},
		"bot": {
			"states": {"pressure": 1},
			"routes": {"overcharge": 2},
			"decisions": {"item_priority": 2},
			"windups": 0,
			"shots_resolved": 0,
			"line_of_sight_samples": 1,
			"line_of_sight_true_samples": 1
		},
		"movement": {
			"samples": 1,
			"average_distance": 9.5,
			"player_airborne_samples": 0,
			"bot_airborne_samples": 1,
			"player_average_speed": 7.2,
			"bot_average_speed": 5.4,
			"jump_pad_triggers": 1,
			"jump_pad_landings": 1,
			"jump_pad_successes": 1
		}
	}

func _event(event_name: String, time_msec: int, payload: Dictionary) -> Dictionary:
	var event := {
		"schema_version": 1,
		"session_id": "readout_unit",
		"event": event_name,
		"time_msec": time_msec,
		"round_index": int(payload.get("round_index", 1)),
		"map_id": "duel_pit_v2",
		"map_name": "Duel Pit V2"
	}
	for key in payload.keys():
		event[key] = payload[key]
	return event

func _write_session(session_path: String, events: Array[Dictionary], summary: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(session_path))
	var events_file := FileAccess.open(session_path.path_join("events.jsonl"), FileAccess.WRITE)
	for event: Dictionary in events:
		events_file.store_line(JSON.stringify(event))
	events_file.close()
	var summary_file := FileAccess.open(session_path.path_join("summary.json"), FileAccess.WRITE)
	summary_file.store_string(JSON.stringify(summary, "\t"))
	summary_file.close()

func _count_events(events: Array[Dictionary]) -> Dictionary:
	var counts: Dictionary = {}
	for event: Dictionary in events:
		var event_name := String(event.get("event", ""))
		counts[event_name] = int(counts.get(event_name, 0)) + 1
	return counts

func _contains_alert(alerts: Array, needle: String) -> bool:
	for alert in alerts:
		if String(alert).contains(needle):
			return true
	return false

func _as_array(value: Variant) -> Array:
	return value if value is Array else []
