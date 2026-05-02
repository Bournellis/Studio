class_name LocalModeSessionManager
extends Node

enum SessionState {
	LOADING,
	PRE_MATCH,
	IN_PROGRESS,
	POST_MATCH,
	SESSION_END
}

signal session_started()
signal session_ended(result: Dictionary)

var mode_id: StringName = &""
var pre_match_duration: float = 0.8
var post_match_duration: float = 0.7
var game_context
var game_loop
var state: SessionState = SessionState.LOADING
var state_remaining: float = 0.0
var pending_result: Dictionary = {}

func configure(next_mode_id: StringName, next_pre_match_duration: float = 0.8, next_post_match_duration: float = 0.7) -> void:
	mode_id = next_mode_id
	pre_match_duration = maxf(0.0, next_pre_match_duration)
	post_match_duration = maxf(0.0, next_post_match_duration)

func bind(context, next_game_loop) -> void:
	game_context = context
	game_loop = next_game_loop
	if game_loop != null and not game_loop.match_concluded.is_connected(_on_match_concluded):
		game_loop.match_concluded.connect(_on_match_concluded)

func _process(delta: float) -> void:
	if state == SessionState.PRE_MATCH:
		state_remaining = maxf(0.0, state_remaining - delta)
		if state_remaining == 0.0:
			state = SessionState.IN_PROGRESS
			session_started.emit()
	elif state == SessionState.POST_MATCH:
		state_remaining = maxf(0.0, state_remaining - delta)
		if state_remaining == 0.0:
			state = SessionState.SESSION_END
			if game_context != null:
				game_context.emit_round_end(pending_result)
			session_ended.emit(pending_result)
			pending_result = {}

func start_session() -> void:
	state = SessionState.PRE_MATCH
	state_remaining = pre_match_duration
	pending_result = {}

func end_session(result: Dictionary) -> void:
	if state == SessionState.POST_MATCH or state == SessionState.SESSION_END:
		return
	state = SessionState.POST_MATCH
	state_remaining = post_match_duration
	pending_result = _build_session_result(result)

func is_in_progress() -> bool:
	return state == SessionState.IN_PROGRESS

func get_state_remaining_seconds() -> float:
	return state_remaining

func _build_session_result(result: Dictionary) -> Dictionary:
	var stored: Dictionary = result.duplicate(true)
	stored["mode_id"] = String(mode_id)
	return stored

func _on_match_concluded(result: Dictionary) -> void:
	end_session(result)
