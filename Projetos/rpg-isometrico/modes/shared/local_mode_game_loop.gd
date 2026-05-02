class_name LocalModeGameLoop
extends Node

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

signal match_concluded(result: Dictionary)

var mode_id: StringName = &""
var session_manager
var elapsed_seconds: float = 0.0
var has_concluded: bool = false

func configure(next_mode_id: StringName) -> void:
	mode_id = next_mode_id
	reset_loop()

func bind_session_manager(next_session_manager) -> void:
	session_manager = next_session_manager
	reset_loop()

func reset_loop() -> void:
	elapsed_seconds = 0.0
	has_concluded = false

func tick_runtime(delta: float) -> bool:
	if has_concluded or session_manager == null or not session_manager.is_in_progress():
		return false
	elapsed_seconds += delta
	return true

func conclude(result: Dictionary) -> void:
	if has_concluded:
		return

	has_concluded = true
	var stored: Dictionary = result.duplicate(true)
	stored["mode_id"] = String(mode_id)
	if not stored.has("duration_seconds"):
		stored["duration_seconds"] = elapsed_seconds
	match_concluded.emit(stored)

func get_shell_snapshot() -> Dictionary:
	return {
		"mode_id": String(mode_id),
		"context_text": "Tempo: %s" % _format_duration(elapsed_seconds),
		"module_title": LocalModeCatalog.get_display_name(mode_id),
		"module_detail": "",
		"opponent_visible": false,
		"opponent_label": "",
		"opponent_status_text": "",
		"opponent_health": 0.0,
		"opponent_max_health": 1.0
	}

func build_result_payload(
	player_victory: bool,
	title: String,
	summary_lines: Array[String],
	round_summary: Dictionary,
	extra: Dictionary = {}
) -> Dictionary:
	var stored: Dictionary = {
		"player_victory": player_victory,
		"title": title,
		"summary_lines": summary_lines,
		"round_summary": round_summary
	}
	for key: Variant in extra.keys():
		stored[String(key)] = extra[key]
	return stored

func _format_duration(total_seconds: float) -> String:
	var clamped_seconds: float = maxf(0.0, total_seconds)
	var minutes: int = int(floor(clamped_seconds / 60.0))
	var seconds: int = int(floor(fmod(clamped_seconds, 60.0)))
	return "%02d:%02d" % [minutes, seconds]
