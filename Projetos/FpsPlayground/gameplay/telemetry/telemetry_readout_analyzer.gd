class_name TelemetryReadoutAnalyzer
extends RefCounted

const DEFAULT_TELEMETRY_ROOT: String = "user://telemetry"
const EVENTS_FILE: String = "events.jsonl"
const SUMMARY_FILE: String = "summary.json"

func find_latest_session(root_path: String = DEFAULT_TELEMETRY_ROOT) -> String:
	var directory := DirAccess.open(root_path)
	if directory == null:
		directory = DirAccess.open(ProjectSettings.globalize_path(root_path))
	if directory == null:
		return ""

	var latest_path := ""
	var latest_modified := -1
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if directory.current_is_dir() and not entry.begins_with("."):
			var session_path := root_path.path_join(entry)
			var modified := _session_modified_time(session_path)
			if modified > latest_modified:
				latest_modified = modified
				latest_path = session_path
		entry = directory.get_next()
	directory.list_dir_end()
	return latest_path

func analyze_latest(root_path: String = DEFAULT_TELEMETRY_ROOT) -> Dictionary:
	var session_path := find_latest_session(root_path)
	if session_path.is_empty():
		return {
			"ok": false,
			"session_path": "",
			"alerts": ["No telemetry sessions found under %s." % root_path]
		}
	return analyze_session(session_path)

func analyze_session(session_path: String) -> Dictionary:
	var events_path := session_path.path_join(EVENTS_FILE)
	var summary_path := session_path.path_join(SUMMARY_FILE)
	var events_file_exists := FileAccess.file_exists(events_path)
	var summary_file_exists := FileAccess.file_exists(summary_path)
	var events := _read_jsonl(events_path) if events_file_exists else []
	var summary := _read_json(summary_path) if summary_file_exists else {}
	var event_counts := _count_events(events)
	var summary_event_counts := _as_dictionary(summary.get("event_counts", {}))
	var count_mismatches := _compare_event_counts(event_counts, summary_event_counts)
	var lifecycle := _build_lifecycle(events)
	var manual_restart_sequences := _build_manual_restart_sequences(events)
	var resetless_round_starts := _find_resetless_round_starts(events)
	var important_counts := _build_important_counts(event_counts)
	var summary_events_recorded := int(summary.get("events_recorded", 0))
	var integrity_ok := events_file_exists and summary_file_exists and events.size() == summary_events_recorded and count_mismatches.is_empty()
	var alerts := _build_alerts(events, summary, event_counts, integrity_ok, count_mismatches, manual_restart_sequences, resetless_round_starts)

	return {
		"ok": integrity_ok and alerts.filter(func(alert: String) -> bool: return alert.begins_with("ERROR")).is_empty(),
		"session_path": session_path,
		"events_path": events_path,
		"summary_path": summary_path,
		"events_file_exists": events_file_exists,
		"summary_file_exists": summary_file_exists,
		"events_line_count": events.size(),
		"summary_events_recorded": summary_events_recorded,
		"counts_match": integrity_ok,
		"count_mismatches": count_mismatches,
		"first_event": String(events[0].get("event", "")) if not events.is_empty() else "",
		"last_event": String(events[events.size() - 1].get("event", "")) if not events.is_empty() else "",
		"last_reason": String(events[events.size() - 1].get("reason", "")) if not events.is_empty() else "",
		"map_id": String(summary.get("map_id", _first_event_value(events, "map_id"))),
		"map_name": String(summary.get("map_name", _first_event_value(events, "map_name"))),
		"rounds_started": int(summary.get("rounds_started", event_counts.get("round_start", 0))),
		"rounds_played": int(summary.get("rounds_played", event_counts.get("round_end", 0))),
		"match_resets": int(event_counts.get("match_reset", 0)),
		"manual_restarts": _count_manual_restarts(events),
		"manual_restart_sequences": manual_restart_sequences,
		"resetless_round_starts": resetless_round_starts,
		"lifecycle": lifecycle,
		"rounds": _summarize_rounds(summary),
		"combat": _summarize_combat(summary, event_counts),
		"plasma": _summarize_plasma(summary),
		"overcharge": _summarize_overcharge(summary),
		"pickups": _summarize_pickups(summary, event_counts),
		"bot": _summarize_bot(summary),
		"movement": _summarize_movement(summary),
		"important_event_counts": important_counts,
		"alerts": alerts
	}

func build_text_report(readout: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("Telemetry Readout")
	lines.append("=================")
	lines.append("Session: %s" % String(readout.get("session_path", "")))
	lines.append("Map: %s (%s)" % [String(readout.get("map_name", "")), String(readout.get("map_id", ""))])
	lines.append("Integrity: %s | events=%d | summary=%d" % [
		"OK" if bool(readout.get("counts_match", false)) else "CHECK",
		int(readout.get("events_line_count", 0)),
		int(readout.get("summary_events_recorded", 0))
	])
	lines.append("Lifecycle: rounds_started=%d | rounds_played=%d | match_resets=%d | manual_restarts=%d | last=%s/%s" % [
		int(readout.get("rounds_started", 0)),
		int(readout.get("rounds_played", 0)),
		int(readout.get("match_resets", 0)),
		int(readout.get("manual_restarts", 0)),
		String(readout.get("last_event", "")),
		String(readout.get("last_reason", ""))
	])
	lines.append("")
	lines.append("Rounds")
	lines.append("------")
	var rounds: Dictionary = _as_dictionary(readout.get("rounds", {}))
	lines.append("Winners: %s | average_duration=%.2fs" % [
		_format_map(_as_dictionary(rounds.get("winner_counts", {}))),
		float(rounds.get("average_duration_sec", 0.0))
	])
	for result: Dictionary in _as_array_of_dictionaries(rounds.get("results", [])):
		lines.append("- round %d: winner=%s duration=%.2fs score=%d-%d health=%.1f/%.1f" % [
			int(result.get("round_index", 0)),
			String(result.get("winner", "")),
			float(result.get("duration_msec", 0)) / 1000.0,
			int(result.get("player_score", 0)),
			int(result.get("bot_score", 0)),
			float(result.get("player_health", 0.0)),
			float(result.get("bot_health", 0.0))
		])
	lines.append("")
	lines.append("Combat")
	lines.append("------")
	var combat: Dictionary = _as_dictionary(readout.get("combat", {}))
	lines.append("Damage by actor: %s" % _format_map(_as_dictionary(combat.get("damage_by_actor", {}))))
	lines.append("Damage by source: %s" % _format_map(_as_dictionary(combat.get("damage_by_source", {}))))
	for weapon: Dictionary in _as_array_of_dictionaries(combat.get("weapons", [])):
		lines.append("- %s fired=%d hits=%d misses=%d accuracy=%.1f%% damage=%.1f" % [
			String(weapon.get("key", "")),
			int(weapon.get("fired", 0)),
			int(weapon.get("hits", 0)),
			int(weapon.get("misses", 0)),
			float(weapon.get("accuracy", 0.0)) * 100.0,
			float(weapon.get("damage", 0.0))
		])
	lines.append("")
	lines.append("Plasma And Overcharge")
	lines.append("---------------------")
	lines.append("Plasma: %s" % _format_map(_as_dictionary(readout.get("plasma", {}))))
	lines.append("Overcharge: %s" % _format_map(_as_dictionary(readout.get("overcharge", {}))))
	lines.append("")
	lines.append("Pickups")
	lines.append("-------")
	var pickups: Dictionary = _as_dictionary(readout.get("pickups", {}))
	lines.append("spawned=%d collected=%d" % [int(pickups.get("spawned_events", 0)), int(pickups.get("collected_events", 0))])
	for key: String in _sorted_keys(_as_dictionary(pickups.get("by_kind", {}))):
		lines.append("- %s: %s" % [key, _format_map(_as_dictionary(pickups.get("by_kind", {}).get(key, {})))])
	lines.append("")
	lines.append("Bot")
	lines.append("---")
	var bot: Dictionary = _as_dictionary(readout.get("bot", {}))
	lines.append("states=%s" % _format_map(_as_dictionary(bot.get("states", {}))))
	lines.append("routes=%s | diversity=%d" % [_format_map(_as_dictionary(bot.get("routes", {}))), int(bot.get("route_diversity", 0))])
	lines.append("decisions=%s" % _format_map(_as_dictionary(bot.get("decisions", {}))))
	lines.append("line_of_sight=%.1f%%" % [float(bot.get("line_of_sight_ratio", 0.0)) * 100.0])
	lines.append("")
	lines.append("Movement")
	lines.append("--------")
	var movement: Dictionary = _as_dictionary(readout.get("movement", {}))
	lines.append("samples=%d average_distance=%.2f player_avg_speed=%.2f bot_avg_speed=%.2f" % [
		int(movement.get("samples", 0)),
		float(movement.get("average_distance", 0.0)),
		float(movement.get("player_average_speed", 0.0)),
		float(movement.get("bot_average_speed", 0.0))
	])
	lines.append("airborne_samples player=%d bot=%d | jump_pads triggered=%d landings=%d successes=%d landing_rate=%.1f%%" % [
		int(movement.get("player_airborne_samples", 0)),
		int(movement.get("bot_airborne_samples", 0)),
		int(movement.get("jump_pad_triggers", 0)),
		int(movement.get("jump_pad_landings", 0)),
		int(movement.get("jump_pad_successes", 0)),
		float(movement.get("jump_pad_landing_rate", 0.0)) * 100.0
	])
	lines.append("")
	lines.append("Alerts")
	lines.append("------")
	var alerts: Array = readout.get("alerts", [])
	if alerts.is_empty():
		lines.append("- none")
	else:
		for alert: String in alerts:
			lines.append("- %s" % alert)
	return "\n".join(lines)

func _read_jsonl(path: String) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return events
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var parsed: Variant = JSON.parse_string(line)
		if parsed is Dictionary:
			events.append(parsed as Dictionary)
	file.close()
	return events

func _read_json(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	return parsed as Dictionary if parsed is Dictionary else {}

func _count_events(events: Array[Dictionary]) -> Dictionary:
	var counts: Dictionary = {}
	for event: Dictionary in events:
		var event_name := String(event.get("event", ""))
		counts[event_name] = int(counts.get(event_name, 0)) + 1
	return counts

func _compare_event_counts(event_counts: Dictionary, summary_counts: Dictionary) -> Array[Dictionary]:
	var mismatches: Array[Dictionary] = []
	var keys: Array[String] = []
	for key in event_counts.keys():
		keys.append(String(key))
	for key in summary_counts.keys():
		if not keys.has(String(key)):
			keys.append(String(key))
	keys.sort()
	for key: String in keys:
		var events_value := int(event_counts.get(key, 0))
		var summary_value := int(summary_counts.get(key, 0))
		if events_value != summary_value:
			mismatches.append({"event": key, "events_jsonl": events_value, "summary_json": summary_value})
	return mismatches

func _build_lifecycle(events: Array[Dictionary]) -> Array[Dictionary]:
	var lifecycle: Array[Dictionary] = []
	for event: Dictionary in events:
		var event_name := String(event.get("event", ""))
		if event_name in ["round_start", "round_reset", "round_end", "match_reset", "session_end"]:
			lifecycle.append({
				"time_msec": int(event.get("time_msec", 0)),
				"event": event_name,
				"round_index": int(event.get("round_index", 0)),
				"reason": String(event.get("reason", "")),
				"winner": String(event.get("winner", "")),
				"player_score": int(event.get("player_score", 0)),
				"bot_score": int(event.get("bot_score", 0))
			})
	return lifecycle

func _build_manual_restart_sequences(events: Array[Dictionary]) -> Array[Dictionary]:
	var sequences: Array[Dictionary] = []
	for event: Dictionary in events:
		if String(event.get("event", "")) != "round_reset" or String(event.get("reason", "")) != "manual_restart":
			continue
		var next_start: Dictionary = {}
		for candidate: Dictionary in events:
			if int(candidate.get("time_msec", 0)) >= int(event.get("time_msec", 0)) and String(candidate.get("event", "")) == "round_start":
				next_start = candidate
				break
		sequences.append({
			"reset_time_msec": int(event.get("time_msec", 0)),
			"reset_round_index": int(event.get("round_index", 0)),
			"next_round_start_time_msec": int(next_start.get("time_msec", -1)) if not next_start.is_empty() else -1,
			"next_round_index": int(next_start.get("round_index", 0)) if not next_start.is_empty() else 0,
			"delta_msec": int(next_start.get("time_msec", 0)) - int(event.get("time_msec", 0)) if not next_start.is_empty() else -1
		})
	return sequences

func _find_resetless_round_starts(events: Array[Dictionary]) -> Array[Dictionary]:
	var resetless: Array[Dictionary] = []
	var seen_first_start := false
	for index in range(events.size()):
		var event: Dictionary = events[index]
		if String(event.get("event", "")) != "round_start":
			continue
		if not seen_first_start:
			seen_first_start = true
			continue
		var has_near_reset := false
		for back_index in range(maxi(0, index - 3), index):
			var previous: Dictionary = events[back_index]
			if String(previous.get("event", "")) in ["round_reset", "match_reset"]:
				has_near_reset = true
				break
		if not has_near_reset:
			resetless.append({
				"time_msec": int(event.get("time_msec", 0)),
				"round_index": int(event.get("round_index", 0)),
				"reason": String(event.get("reason", ""))
			})
	return resetless

func _summarize_rounds(summary: Dictionary) -> Dictionary:
	var results := _as_array_of_dictionaries(summary.get("round_results", []))
	var duration_sum := 0.0
	for result: Dictionary in results:
		duration_sum += float(result.get("duration_msec", 0))
	return {
		"winner_counts": _as_dictionary(summary.get("winner_counts", {})),
		"results": results,
		"average_duration_sec": duration_sum / float(maxi(1, results.size())) / 1000.0
	}

func _summarize_combat(summary: Dictionary, event_counts: Dictionary) -> Dictionary:
	var weapons: Array[Dictionary] = []
	var shots_by_weapon := _as_dictionary(summary.get("shots_by_weapon", {}))
	for key: String in _sorted_keys(shots_by_weapon):
		var stats := _as_dictionary(shots_by_weapon.get(key, {}))
		weapons.append({
			"key": key,
			"fired": int(stats.get("fired", 0)),
			"hits": int(stats.get("hits", 0)),
			"misses": int(stats.get("misses", 0)),
			"accuracy": float(stats.get("accuracy", 0.0)),
			"damage": float(stats.get("damage", 0.0))
		})
	return {
		"shot_fired_events": int(event_counts.get("shot_fired", 0)),
		"shot_hit_events": int(event_counts.get("shot_hit", 0)),
		"shot_miss_events": int(event_counts.get("shot_miss", 0)),
		"damage_applied_events": int(event_counts.get("damage_applied", 0)),
		"damage_by_actor": _as_dictionary(summary.get("damage_by_actor", {})),
		"damage_by_source": _as_dictionary(summary.get("damage_by_source", {})),
		"weapons": weapons,
		"dominant_damage_source": _dominant_key(_as_dictionary(summary.get("damage_by_source", {})))
	}

func _summarize_plasma(summary: Dictionary) -> Dictionary:
	return _as_dictionary(summary.get("plasma", {}))

func _summarize_overcharge(summary: Dictionary) -> Dictionary:
	return _as_dictionary(summary.get("overcharge", {}))

func _summarize_pickups(summary: Dictionary, event_counts: Dictionary) -> Dictionary:
	return {
		"spawned_events": int(event_counts.get("pickup_spawned", 0)),
		"collected_events": int(event_counts.get("pickup_collected", 0)),
		"respawned_events": int(event_counts.get("pickup_respawned", 0)),
		"nearby_ignored_events": int(event_counts.get("pickup_nearby_ignored", 0)),
		"contested_events": int(event_counts.get("pickup_contested", 0)),
		"by_kind": _as_dictionary(summary.get("pickups", {}))
	}

func _summarize_bot(summary: Dictionary) -> Dictionary:
	var bot := _as_dictionary(summary.get("bot", {}))
	var los_samples := int(bot.get("line_of_sight_samples", 0))
	var los_true := int(bot.get("line_of_sight_true_samples", 0))
	var routes := _as_dictionary(bot.get("routes", {}))
	return {
		"states": _as_dictionary(bot.get("states", {})),
		"routes": routes,
		"route_diversity": routes.keys().size(),
		"decisions": _as_dictionary(bot.get("decisions", {})),
		"windups": int(bot.get("windups", 0)),
		"shots_resolved": int(bot.get("shots_resolved", 0)),
		"line_of_sight_samples": los_samples,
		"line_of_sight_true_samples": los_true,
		"line_of_sight_ratio": float(los_true) / float(maxi(1, los_samples))
	}

func _summarize_movement(summary: Dictionary) -> Dictionary:
	var movement := _as_dictionary(summary.get("movement", {}))
	var triggers := int(movement.get("jump_pad_triggers", 0))
	var landings := int(movement.get("jump_pad_landings", 0))
	movement["jump_pad_landing_rate"] = float(landings) / float(maxi(1, triggers))
	return movement

func _build_important_counts(event_counts: Dictionary) -> Dictionary:
	var names := [
		"session_start", "arena_setup", "round_start", "round_end", "round_reset", "match_reset", "session_end",
		"shot_fired", "shot_hit", "shot_miss", "damage_applied", "plasma_spawned", "plasma_blast",
		"pickup_spawned", "pickup_collected", "movement_sample", "jump_pad_triggered", "jump_pad_landing",
		"bot_state_changed", "bot_route_changed", "bot_decision"
	]
	var result: Dictionary = {}
	for name: String in names:
		result[name] = int(event_counts.get(name, 0))
	return result

func _build_alerts(events: Array[Dictionary], summary: Dictionary, event_counts: Dictionary, integrity_ok: bool, count_mismatches: Array[Dictionary], manual_restart_sequences: Array[Dictionary], resetless_round_starts: Array[Dictionary]) -> Array[String]:
	var alerts: Array[String] = []
	if events.is_empty():
		alerts.append("ERROR: events.jsonl has no readable events.")
	if summary.is_empty():
		alerts.append("ERROR: summary.json is missing or unreadable.")
	if not integrity_ok:
		alerts.append("ERROR: events.jsonl and summary.json are not synchronized.")
	for mismatch: Dictionary in count_mismatches:
		alerts.append("ERROR: event count mismatch for %s (%d vs %d)." % [
			String(mismatch.get("event", "")),
			int(mismatch.get("events_jsonl", 0)),
			int(mismatch.get("summary_json", 0))
		])
	if not events.is_empty() and String(events[events.size() - 1].get("event", "")) != "session_end":
		alerts.append("WARN: session did not end with session_end.")
	for sequence: Dictionary in manual_restart_sequences:
		if int(sequence.get("next_round_start_time_msec", -1)) < 0:
			alerts.append("ERROR: manual restart at %dms has no following round_start." % int(sequence.get("reset_time_msec", 0)))
	if not resetless_round_starts.is_empty():
		alerts.append("WARN: %d round_start events had no nearby round_reset or match_reset." % resetless_round_starts.size())
	var rounds_played := int(summary.get("rounds_played", 0))
	var damage_by_actor := _as_dictionary(summary.get("damage_by_actor", {}))
	if rounds_played > 0 and float(damage_by_actor.get("bot", 0.0)) <= 0.0:
		alerts.append("WARN: bot caused no damage in a session with completed rounds.")
	var movement := _as_dictionary(summary.get("movement", {}))
	var jump_triggers := int(movement.get("jump_pad_triggers", 0))
	var jump_landings := int(movement.get("jump_pad_landings", 0))
	if jump_triggers > 0 and jump_landings < jump_triggers:
		alerts.append("WARN: jump pad landings are lower than triggers (%d/%d)." % [jump_landings, jump_triggers])
	var dominant := _dominant_key(_as_dictionary(summary.get("damage_by_source", {})))
	if float(dominant.get("share", 0.0)) >= 0.75 and float(dominant.get("amount", 0.0)) > 0.0:
		alerts.append("WATCH: %s dealt %.1f%% of total damage." % [String(dominant.get("key", "")), float(dominant.get("share", 0.0)) * 100.0])
	if int(event_counts.get("pickup_spawned", 0)) > 0 and int(event_counts.get("pickup_collected", 0)) == 0:
		alerts.append("WATCH: pickups spawned but none were collected.")
	return alerts

func _count_manual_restarts(events: Array[Dictionary]) -> int:
	var count := 0
	for event: Dictionary in events:
		if String(event.get("event", "")) == "round_reset" and String(event.get("reason", "")) == "manual_restart":
			count += 1
	return count

func _first_event_value(events: Array[Dictionary], key: String) -> Variant:
	for event: Dictionary in events:
		if event.has(key):
			return event[key]
	return ""

func _session_modified_time(session_path: String) -> int:
	var events_path := session_path.path_join(EVENTS_FILE)
	var summary_path := session_path.path_join(SUMMARY_FILE)
	return maxi(int(FileAccess.get_modified_time(events_path)), int(FileAccess.get_modified_time(summary_path)))

func _dominant_key(values: Dictionary) -> Dictionary:
	var total := 0.0
	var best_key := ""
	var best_amount := 0.0
	for key in values.keys():
		var amount := float(values.get(key, 0.0))
		total += amount
		if amount > best_amount:
			best_amount = amount
			best_key = String(key)
	return {
		"key": best_key,
		"amount": best_amount,
		"share": best_amount / maxf(1.0, total)
	}

func _as_dictionary(value: Variant) -> Dictionary:
	return value as Dictionary if value is Dictionary else {}

func _as_array_of_dictionaries(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not value is Array:
		return result
	for item in value:
		if item is Dictionary:
			result.append(item as Dictionary)
	return result

func _sorted_keys(source: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	for key in source.keys():
		keys.append(String(key))
	keys.sort()
	return keys

func _format_map(source: Dictionary) -> String:
	if source.is_empty():
		return "{}"
	var parts: Array[String] = []
	for key: String in _sorted_keys(source):
		var value: Variant = source.get(key)
		if value is float:
			parts.append("%s=%.2f" % [key, float(value)])
		else:
			parts.append("%s=%s" % [key, str(value)])
	return ", ".join(parts)
