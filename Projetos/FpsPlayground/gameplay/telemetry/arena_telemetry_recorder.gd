class_name ArenaTelemetryRecorder
extends RefCounted

const SCHEMA_VERSION: int = 1
const DEFAULT_MEMORY_EVENT_LIMIT: int = 768

var session_id: String = ""
var output_dir: String = ""
var events_file_path: String = ""
var summary_file_path: String = ""
var file_output_enabled: bool = false
var is_active: bool = false
var memory_event_limit: int = DEFAULT_MEMORY_EVENT_LIMIT

var _events: Array[Dictionary] = []
var _summary: Dictionary = {}
var _context: Dictionary = {}
var _session_start_ticks_msec: int = 0
var _events_file: FileAccess = null

func start_session(context: Dictionary = {}, enable_file_output: bool = false, custom_output_dir: String = "") -> void:
	if is_active:
		finish_session({"reason": "restart"})
	session_id = String(context.get("session_id", _make_session_id()))
	output_dir = custom_output_dir if not custom_output_dir.is_empty() else "user://telemetry/%s" % session_id
	file_output_enabled = enable_file_output
	_context = _sanitize_dictionary(context)
	_context["session_id"] = session_id
	_session_start_ticks_msec = Time.get_ticks_msec()
	_events.clear()
	_summary = _build_empty_summary(_context)
	is_active = true
	if file_output_enabled:
		_open_output_files()
	record_event(&"session_start", context)

func finish_session(payload: Dictionary = {}) -> void:
	if not is_active:
		return
	record_event(&"session_end", payload)
	is_active = false
	flush_summary()
	if _events_file != null:
		_events_file.flush()
		_events_file = null

func update_context(next_context: Dictionary) -> void:
	var sanitized := _sanitize_dictionary(next_context)
	for key in sanitized.keys():
		_context[key] = sanitized[key]

func record_event(event_name: StringName, payload: Dictionary = {}) -> Dictionary:
	if not is_active:
		return {}
	var event := _context.duplicate(true)
	var sanitized_payload := _sanitize_dictionary(payload)
	for key in sanitized_payload.keys():
		event[key] = sanitized_payload[key]
	event["schema_version"] = SCHEMA_VERSION
	event["session_id"] = session_id
	event["event"] = String(event_name)
	event["time_msec"] = Time.get_ticks_msec() - _session_start_ticks_msec
	if not event.has("round_index"):
		event["round_index"] = int(_context.get("round_index", 0))
	if not event.has("map_id"):
		event["map_id"] = String(_context.get("map_id", ""))
	if not event.has("map_name"):
		event["map_name"] = String(_context.get("map_name", ""))
	_events.append(event)
	while _events.size() > memory_event_limit:
		_events.remove_at(0)
	_apply_event_to_summary(event)
	_write_event(event)
	return event

func flush_summary() -> void:
	if not file_output_enabled or summary_file_path.is_empty():
		return
	var file := FileAccess.open(summary_file_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_summary, "\t"))
	file.close()

func get_events() -> Array[Dictionary]:
	return _events.duplicate(true)

func get_summary() -> Dictionary:
	return _summary.duplicate(true)

func get_output_paths() -> Dictionary:
	return {
		"output_dir": output_dir,
		"events_file": events_file_path,
		"summary_file": summary_file_path,
		"file_output_enabled": file_output_enabled
	}

func get_event_count() -> int:
	return int(_summary.get("events_recorded", 0))

func _make_session_id() -> String:
	var timestamp := Time.get_datetime_string_from_system(false, false)
	timestamp = timestamp.replace(":", "").replace("-", "").replace("T", "_")
	return "arena_%s_%d" % [timestamp, Time.get_ticks_usec()]

func _build_empty_summary(context: Dictionary) -> Dictionary:
	return {
		"schema_version": SCHEMA_VERSION,
		"session_id": session_id,
		"started_at": Time.get_datetime_string_from_system(false, true),
		"ended_at": "",
		"map_id": String(context.get("map_id", "")),
		"map_name": String(context.get("map_name", "")),
		"score_to_win": int(context.get("score_to_win", 0)),
		"events_recorded": 0,
		"event_counts": {},
		"rounds_started": 0,
		"rounds_played": 0,
		"round_results": [],
		"winner_counts": {"player": 0, "bot": 0},
		"damage_by_actor": {},
		"damage_by_source": {},
		"shots_by_weapon": {},
		"plasma": {
			"spawned": 0,
			"direct_hits": 0,
			"world_impacts": 0,
			"blast_hits": 0,
			"blast_misses": 0,
			"expired": 0,
			"direct_damage": 0.0,
			"blast_damage": 0.0
		},
		"overcharge": {
			"pickups": 0,
			"shots_consumed": 0,
			"useful_damage": 0.0,
			"misses": 0
		},
		"pickups": {},
		"bot": {
			"states": {},
			"routes": {},
			"decisions": {},
			"windups": 0,
			"shots_resolved": 0,
			"line_of_sight_samples": 0,
			"line_of_sight_true_samples": 0
		},
		"movement": {
			"samples": 0,
			"distance_sum": 0.0,
			"average_distance": 0.0,
			"player_airborne_samples": 0,
			"bot_airborne_samples": 0,
			"player_speed_sum": 0.0,
			"bot_speed_sum": 0.0,
			"player_average_speed": 0.0,
			"bot_average_speed": 0.0,
			"jump_pad_triggers": 0,
			"jump_pad_landings": 0,
			"jump_pad_successes": 0
		},
		"output_dir": output_dir
	}

func _open_output_files() -> void:
	var absolute_dir := ProjectSettings.globalize_path(output_dir)
	DirAccess.make_dir_recursive_absolute(absolute_dir)
	events_file_path = output_dir.path_join("events.jsonl")
	summary_file_path = output_dir.path_join("summary.json")
	_events_file = FileAccess.open(events_file_path, FileAccess.WRITE)
	if _events_file == null:
		file_output_enabled = false

func _write_event(event: Dictionary) -> void:
	if not file_output_enabled or _events_file == null:
		return
	_events_file.store_line(JSON.stringify(event))
	_events_file.flush()

func _apply_event_to_summary(event: Dictionary) -> void:
	var event_name := String(event.get("event", ""))
	_summary["events_recorded"] = int(_summary.get("events_recorded", 0)) + 1
	_increment_count("event_counts", event_name)
	match event_name:
		"session_end":
			_summary["ended_at"] = Time.get_datetime_string_from_system(false, true)
		"round_start":
			_summary["rounds_started"] = int(_summary.get("rounds_started", 0)) + 1
		"round_end":
			_apply_round_end(event)
		"shot_fired":
			_apply_shot_fired(event)
		"shot_hit":
			_apply_shot_result(event, true)
		"shot_miss":
			_apply_shot_result(event, false)
		"damage_applied":
			_apply_damage(event)
		"plasma_spawned":
			_increment_nested_int("plasma", "spawned")
		"plasma_direct_hit":
			_increment_nested_int("plasma", "direct_hits")
		"plasma_world_impact":
			_increment_nested_int("plasma", "world_impacts")
		"plasma_blast":
			_apply_plasma_blast(event)
		"plasma_expired":
			_increment_nested_int("plasma", "expired")
		"pickup_collected":
			_apply_pickup_collected(event)
		"pickup_respawned":
			_apply_pickup_counter(event, "respawned")
		"pickup_nearby_ignored":
			_apply_pickup_counter(event, "nearby_ignored")
		"pickup_contested":
			_apply_pickup_counter(event, "contested")
		"bot_state_changed":
			_apply_bot_state(event)
		"bot_route_changed", "bot_decision":
			_apply_bot_route(event)
		"bot_windup_started":
			_increment_nested_int("bot", "windups")
		"bot_shot_resolved":
			_increment_nested_int("bot", "shots_resolved")
		"movement_sample":
			_apply_movement_sample(event)
		"jump_pad_triggered":
			_increment_nested_int("movement", "jump_pad_triggers")
		"jump_pad_landing":
			_apply_jump_pad_landing(event)

func _apply_round_end(event: Dictionary) -> void:
	_summary["rounds_played"] = int(_summary.get("rounds_played", 0)) + 1
	var winner := String(event.get("winner", ""))
	if winner == "player" or winner == "bot":
		var winners: Dictionary = _summary.get("winner_counts", {})
		winners[winner] = int(winners.get(winner, 0)) + 1
		_summary["winner_counts"] = winners
	var results: Array = _summary.get("round_results", [])
	results.append({
		"round_index": int(event.get("round_index", 0)),
		"winner": winner,
		"duration_msec": int(event.get("duration_msec", 0)),
		"player_score": int(event.get("player_score", 0)),
		"bot_score": int(event.get("bot_score", 0)),
		"player_health": float(event.get("player_health", 0.0)),
		"bot_health": float(event.get("bot_health", 0.0))
	})
	_summary["round_results"] = results

func _apply_shot_fired(event: Dictionary) -> void:
	var stats := _get_weapon_stats(event)
	stats["fired"] = int(stats.get("fired", 0)) + 1
	if bool(event.get("overcharged", false)):
		var overcharge := _get_nested_summary("overcharge")
		overcharge["shots_consumed"] = int(overcharge.get("shots_consumed", 0)) + 1

func _apply_shot_result(event: Dictionary, hit: bool) -> void:
	var stats := _get_weapon_stats(event)
	var key := "hits" if hit else "misses"
	stats[key] = int(stats.get(key, 0)) + 1
	if not hit and bool(event.get("overcharged", false)):
		var overcharge := _get_nested_summary("overcharge")
		overcharge["misses"] = int(overcharge.get("misses", 0)) + 1
	var fired: int = maxi(1, int(stats.get("fired", 0)))
	stats["accuracy"] = float(stats.get("hits", 0)) / float(fired)

func _apply_damage(event: Dictionary) -> void:
	var damage := float(event.get("damage", 0.0))
	var actor := String(event.get("actor", "unknown"))
	var source := String(event.get("source", String(event.get("weapon", "unknown"))))
	_add_float_to_dictionary("damage_by_actor", actor, damage)
	_add_float_to_dictionary("damage_by_source", source, damage)
	var stats := _get_weapon_stats(event)
	stats["damage"] = float(stats.get("damage", 0.0)) + damage
	if bool(event.get("overcharged", false)):
		var overcharge := _get_nested_summary("overcharge")
		overcharge["useful_damage"] = float(overcharge.get("useful_damage", 0.0)) + damage
	var weapon := String(event.get("weapon", ""))
	var plasma := _get_nested_summary("plasma")
	if weapon == "plasma_direct":
		plasma["direct_damage"] = float(plasma.get("direct_damage", 0.0)) + damage
	elif weapon == "plasma_blast":
		plasma["blast_damage"] = float(plasma.get("blast_damage", 0.0)) + damage

func _apply_plasma_blast(event: Dictionary) -> void:
	var plasma := _get_nested_summary("plasma")
	if bool(event.get("damaged_target", false)):
		plasma["blast_hits"] = int(plasma.get("blast_hits", 0)) + 1
	else:
		plasma["blast_misses"] = int(plasma.get("blast_misses", 0)) + 1

func _apply_pickup_collected(event: Dictionary) -> void:
	var pickup_stats := _get_pickup_stats(String(event.get("pickup_kind", "unknown")))
	pickup_stats["collected"] = int(pickup_stats.get("collected", 0)) + 1
	var actor := String(event.get("actor", "unknown"))
	var by_actor: Dictionary = pickup_stats.get("by_actor", {})
	by_actor[actor] = int(by_actor.get(actor, 0)) + 1
	pickup_stats["by_actor"] = by_actor
	pickup_stats["effective_healing"] = float(pickup_stats.get("effective_healing", 0.0)) + float(event.get("healing_applied", 0.0))
	pickup_stats["wasted_healing"] = float(pickup_stats.get("wasted_healing", 0.0)) + float(event.get("healing_wasted", 0.0))
	if String(event.get("pickup_kind", "")) == "overcharge":
		var overcharge := _get_nested_summary("overcharge")
		overcharge["pickups"] = int(overcharge.get("pickups", 0)) + 1

func _apply_pickup_counter(event: Dictionary, counter_name: String) -> void:
	var pickup_stats := _get_pickup_stats(String(event.get("pickup_kind", "unknown")))
	pickup_stats[counter_name] = int(pickup_stats.get(counter_name, 0)) + 1

func _apply_bot_state(event: Dictionary) -> void:
	var bot_summary := _get_nested_summary("bot")
	var states: Dictionary = bot_summary.get("states", {})
	var state := String(event.get("state", "unknown"))
	states[state] = int(states.get(state, 0)) + 1
	bot_summary["states"] = states

func _apply_bot_route(event: Dictionary) -> void:
	var bot_summary := _get_nested_summary("bot")
	var routes: Dictionary = bot_summary.get("routes", {})
	var route := String(event.get("route_label", "unknown"))
	routes[route] = int(routes.get(route, 0)) + 1
	bot_summary["routes"] = routes
	var decisions: Dictionary = bot_summary.get("decisions", {})
	var decision := String(event.get("decision_reason", "unknown"))
	decisions[decision] = int(decisions.get(decision, 0)) + 1
	bot_summary["decisions"] = decisions

func _apply_movement_sample(event: Dictionary) -> void:
	var movement := _get_nested_summary("movement")
	var samples := int(movement.get("samples", 0)) + 1
	movement["samples"] = samples
	movement["distance_sum"] = float(movement.get("distance_sum", 0.0)) + float(event.get("distance_between", 0.0))
	movement["average_distance"] = float(movement.get("distance_sum", 0.0)) / float(max(1, samples))
	movement["player_speed_sum"] = float(movement.get("player_speed_sum", 0.0)) + float(event.get("player_speed", 0.0))
	movement["bot_speed_sum"] = float(movement.get("bot_speed_sum", 0.0)) + float(event.get("bot_speed", 0.0))
	movement["player_average_speed"] = float(movement.get("player_speed_sum", 0.0)) / float(max(1, samples))
	movement["bot_average_speed"] = float(movement.get("bot_speed_sum", 0.0)) / float(max(1, samples))
	if bool(event.get("player_airborne", false)):
		movement["player_airborne_samples"] = int(movement.get("player_airborne_samples", 0)) + 1
	if bool(event.get("bot_airborne", false)):
		movement["bot_airborne_samples"] = int(movement.get("bot_airborne_samples", 0)) + 1
	var bot_summary := _get_nested_summary("bot")
	bot_summary["line_of_sight_samples"] = int(bot_summary.get("line_of_sight_samples", 0)) + 1
	if bool(event.get("bot_has_line_of_sight", false)):
		bot_summary["line_of_sight_true_samples"] = int(bot_summary.get("line_of_sight_true_samples", 0)) + 1

func _apply_jump_pad_landing(event: Dictionary) -> void:
	var movement := _get_nested_summary("movement")
	movement["jump_pad_landings"] = int(movement.get("jump_pad_landings", 0)) + 1
	if bool(event.get("success", false)):
		movement["jump_pad_successes"] = int(movement.get("jump_pad_successes", 0)) + 1

func _get_weapon_stats(event: Dictionary) -> Dictionary:
	var key := "%s:%s" % [String(event.get("actor", "unknown")), String(event.get("weapon", "unknown"))]
	var root: Dictionary = _summary.get("shots_by_weapon", {})
	if not root.has(key):
		root[key] = {
			"fired": 0,
			"hits": 0,
			"misses": 0,
			"accuracy": 0.0,
			"damage": 0.0
		}
		_summary["shots_by_weapon"] = root
	return root[key]

func _get_pickup_stats(pickup_kind: String) -> Dictionary:
	var root: Dictionary = _summary.get("pickups", {})
	if not root.has(pickup_kind):
		root[pickup_kind] = {
			"collected": 0,
			"respawned": 0,
			"nearby_ignored": 0,
			"contested": 0,
			"effective_healing": 0.0,
			"wasted_healing": 0.0,
			"by_actor": {}
		}
		_summary["pickups"] = root
	return root[pickup_kind]

func _get_nested_summary(key: String) -> Dictionary:
	var nested: Dictionary = _summary.get(key, {})
	_summary[key] = nested
	return nested

func _increment_count(root_key: String, key: String) -> void:
	var root: Dictionary = _summary.get(root_key, {})
	root[key] = int(root.get(key, 0)) + 1
	_summary[root_key] = root

func _increment_nested_int(root_key: String, key: String) -> void:
	var root := _get_nested_summary(root_key)
	root[key] = int(root.get(key, 0)) + 1

func _add_float_to_dictionary(root_key: String, key: String, amount: float) -> void:
	var root: Dictionary = _summary.get(root_key, {})
	root[key] = float(root.get(key, 0.0)) + amount
	_summary[root_key] = root

func _sanitize_dictionary(source: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key in source.keys():
		result[String(key)] = _sanitize_value(source[key])
	return result

func _sanitize_value(value: Variant) -> Variant:
	match typeof(value):
		TYPE_STRING_NAME:
			return String(value)
		TYPE_VECTOR2:
			var vector2: Vector2 = value
			return {"x": vector2.x, "y": vector2.y}
		TYPE_VECTOR3:
			var vector3: Vector3 = value
			return {"x": vector3.x, "y": vector3.y, "z": vector3.z}
		TYPE_COLOR:
			var color: Color = value
			return {"r": color.r, "g": color.g, "b": color.b, "a": color.a}
		TYPE_ARRAY:
			var output: Array = []
			for item in value:
				output.append(_sanitize_value(item))
			return output
		TYPE_DICTIONARY:
			return _sanitize_dictionary(value)
		_:
			return value
