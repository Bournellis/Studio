class_name ArenaTelemetryEvents
extends RefCounted


static func build_context(
	round_index: int,
	round_state: StringName,
	map_id: StringName,
	map_name: String,
	player_score: int,
	bot_score: int,
	score_to_win: int,
	extra: Dictionary = {}
) -> Dictionary:
	var context := {
		"round_index": round_index,
		"round_state": round_state,
		"map_id": map_id,
		"map_name": map_name,
		"player_score": player_score,
		"bot_score": bot_score,
		"score_to_win": score_to_win
	}
	for key in extra.keys():
		context[key] = extra[key]
	return context


static func start_session(recorder, context: Dictionary, enable_file_output: bool) -> void:
	if recorder == null:
		return
	recorder.start_session(context, enable_file_output)


static func record_event(recorder, event_name: StringName, context: Dictionary, payload: Dictionary = {}) -> Dictionary:
	if recorder == null:
		return {}
	recorder.update_context(context)
	return recorder.record_event(event_name, payload)
