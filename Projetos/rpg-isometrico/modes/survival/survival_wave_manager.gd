class_name SurvivalWaveManager
extends Node

signal wave_started(wave_number: int, wave_spec: Dictionary)
signal wave_cleared(wave_number: int)
signal rest_started(duration_seconds: float)
signal session_completed()

enum WaveState {
	IDLE,
	WAVE_ACTIVE,
	REST,
	COMPLETE
}

const QUICK_SESSION_TARGET_WAVE: int = 7
const AUTHORED_WAVES: Array = [
	{
		"enemy_count": 3,
		"rest_window": 8.0,
		"spawn_stagger": 0.9,
		"enemy_config": {
			"max_health": 62.0,
			"move_speed": 3.2,
			"attack_damage": 12.0,
			"attack_range": 1.8,
			"attack_windup": 0.56,
			"attack_cooldown": 1.15,
			"body_scale": 1.08
		}
	},
	{
		"enemy_count": 4,
		"rest_window": 7.0,
		"spawn_stagger": 0.84,
		"enemy_config": {
			"max_health": 66.0,
			"move_speed": 3.24,
			"attack_damage": 13.0,
			"attack_range": 1.82,
			"attack_windup": 0.54,
			"attack_cooldown": 1.12,
			"body_scale": 1.1
		}
	},
	{
		"enemy_count": 5,
		"rest_window": 6.0,
		"spawn_stagger": 0.78,
		"enemy_config": {
			"max_health": 70.0,
			"move_speed": 3.28,
			"attack_damage": 14.0,
			"attack_range": 1.85,
			"attack_windup": 0.52,
			"attack_cooldown": 1.08,
			"body_scale": 1.12
		}
	},
	{
		"enemy_count": 6,
		"rest_window": 5.8,
		"spawn_stagger": 0.72,
		"enemy_config": {
			"max_health": 74.0,
			"move_speed": 3.34,
			"attack_damage": 15.0,
			"attack_range": 1.88,
			"attack_windup": 0.5,
			"attack_cooldown": 1.06,
			"body_scale": 1.14
		}
	},
	{
		"enemy_count": 7,
		"rest_window": 5.2,
		"spawn_stagger": 0.68,
		"enemy_config": {
			"max_health": 78.0,
			"move_speed": 3.4,
			"attack_damage": 16.0,
			"attack_range": 1.92,
			"attack_windup": 0.48,
			"attack_cooldown": 1.02,
			"body_scale": 1.16
		}
	},
	{
		"enemy_count": 8,
		"rest_window": 4.8,
		"spawn_stagger": 0.64,
		"enemy_config": {
			"max_health": 82.0,
			"move_speed": 3.48,
			"attack_damage": 17.0,
			"attack_range": 1.96,
			"attack_windup": 0.47,
			"attack_cooldown": 0.98,
			"body_scale": 1.18
		}
	},
	{
		"enemy_count": 10,
		"rest_window": 4.4,
		"spawn_stagger": 0.58,
		"enemy_config": {
			"max_health": 86.0,
			"move_speed": 3.56,
			"attack_damage": 18.0,
			"attack_range": 2.0,
			"attack_windup": 0.46,
			"attack_cooldown": 0.95,
			"body_scale": 1.2
		}
	}
]

var spawn_controller
var state: WaveState = WaveState.IDLE
var current_wave: int = 0
var completed_waves: int = 0
var highest_wave_reached: int = 0
var rest_time_remaining: float = 0.0
var enemy_defeated_count: int = 0
var current_wave_spec: Dictionary = {}

func bind(next_spawn_controller) -> void:
	if spawn_controller != null and spawn_controller.enemy_defeated.is_connected(_on_enemy_defeated):
		spawn_controller.enemy_defeated.disconnect(_on_enemy_defeated)
	spawn_controller = next_spawn_controller
	if spawn_controller != null and not spawn_controller.enemy_defeated.is_connected(_on_enemy_defeated):
		spawn_controller.enemy_defeated.connect(_on_enemy_defeated)

func reset() -> void:
	state = WaveState.IDLE
	current_wave = 0
	completed_waves = 0
	highest_wave_reached = 0
	rest_time_remaining = 0.0
	enemy_defeated_count = 0
	current_wave_spec = {}

func start(start_wave: int = 1) -> void:
	reset()
	_start_wave(maxi(1, start_wave))

func tick(delta: float) -> void:
	if spawn_controller == null:
		return

	match state:
		WaveState.WAVE_ACTIVE:
			spawn_controller.tick(delta)
			if not spawn_controller.has_pending_spawns() and spawn_controller.get_enemy_count() == 0:
				completed_waves = maxi(completed_waves, current_wave)
				wave_cleared.emit(current_wave)
				if current_wave >= QUICK_SESSION_TARGET_WAVE:
					state = WaveState.COMPLETE
					session_completed.emit()
				else:
					state = WaveState.REST
					rest_time_remaining = float(current_wave_spec.get("rest_window", 4.0))
					rest_started.emit(rest_time_remaining)
		WaveState.REST:
			rest_time_remaining = maxf(0.0, rest_time_remaining - delta)
			if rest_time_remaining == 0.0:
				_start_wave(current_wave + 1)

func get_hud_snapshot() -> Dictionary:
	return {
		"wave_number": current_wave,
		"completed_waves": completed_waves,
		"highest_wave_reached": highest_wave_reached,
		"target_wave": QUICK_SESSION_TARGET_WAVE,
		"enemies_alive": 0 if spawn_controller == null else spawn_controller.get_enemy_count(),
		"pending_spawns": 0 if spawn_controller == null else spawn_controller.get_pending_spawn_count(),
		"rest_remaining": rest_time_remaining,
		"enemy_defeated_count": enemy_defeated_count,
		"state": int(state),
		"state_label": _format_state_label()
	}

func has_session_completed() -> bool:
	return state == WaveState.COMPLETE

func get_completed_waves() -> int:
	return completed_waves

func get_highest_wave_reached() -> int:
	return highest_wave_reached

func get_enemy_defeated_count() -> int:
	return enemy_defeated_count

func get_target_wave() -> int:
	return QUICK_SESSION_TARGET_WAVE

func get_runtime_snapshot() -> Dictionary:
	return {
		"state": int(state),
		"current_wave": current_wave,
		"completed_waves": completed_waves,
		"highest_wave_reached": highest_wave_reached,
		"rest_time_remaining": rest_time_remaining,
		"enemy_defeated_count": enemy_defeated_count,
		"current_wave_spec": var_to_str(current_wave_spec)
	}

func restore_runtime_snapshot(snapshot: Dictionary) -> void:
	if snapshot.is_empty():
		return

	state = clampi(int(snapshot.get("state", int(WaveState.IDLE))), int(WaveState.IDLE), int(WaveState.COMPLETE))
	current_wave = maxi(0, int(snapshot.get("current_wave", 0)))
	completed_waves = maxi(0, int(snapshot.get("completed_waves", 0)))
	highest_wave_reached = maxi(0, int(snapshot.get("highest_wave_reached", 0)))
	rest_time_remaining = maxf(0.0, float(snapshot.get("rest_time_remaining", 0.0)))
	enemy_defeated_count = maxi(0, int(snapshot.get("enemy_defeated_count", 0)))
	current_wave_spec = _deserialize_wave_spec(snapshot.get("current_wave_spec", ""))
	if current_wave > 0 and current_wave_spec.is_empty():
		current_wave_spec = _build_wave_spec(current_wave)

func _start_wave(wave_number: int) -> void:
	if spawn_controller == null:
		return

	current_wave = maxi(1, wave_number)
	highest_wave_reached = maxi(highest_wave_reached, current_wave)
	current_wave_spec = _build_wave_spec(current_wave)
	state = WaveState.WAVE_ACTIVE
	spawn_controller.begin_wave(current_wave_spec)
	wave_started.emit(current_wave, current_wave_spec)

func _build_wave_spec(wave_number: int) -> Dictionary:
	if wave_number > 0 and wave_number <= AUTHORED_WAVES.size():
		var authored: Dictionary = Dictionary(AUTHORED_WAVES[wave_number - 1]).duplicate(true)
		authored["wave_number"] = wave_number
		return authored

	var extra_wave_index: int = wave_number - AUTHORED_WAVES.size()
	var fallback: Dictionary = Dictionary(AUTHORED_WAVES[AUTHORED_WAVES.size() - 1]).duplicate(true)
	var enemy_config: Dictionary = Dictionary(fallback.get("enemy_config", {})).duplicate(true)
	enemy_config["max_health"] = float(enemy_config.get("max_health", 86.0)) + extra_wave_index * 4.0
	enemy_config["move_speed"] = minf(4.2, float(enemy_config.get("move_speed", 3.56)) + extra_wave_index * 0.06)
	enemy_config["attack_damage"] = float(enemy_config.get("attack_damage", 18.0)) + extra_wave_index * 1.2
	fallback["wave_number"] = wave_number
	fallback["enemy_count"] = int(fallback.get("enemy_count", 10)) + extra_wave_index * 2
	fallback["rest_window"] = maxf(3.5, float(fallback.get("rest_window", 4.4)) - extra_wave_index * 0.2)
	fallback["spawn_stagger"] = maxf(0.42, float(fallback.get("spawn_stagger", 0.58)) - extra_wave_index * 0.02)
	fallback["enemy_config"] = enemy_config
	return fallback

func _on_enemy_defeated(_enemy_id: StringName, _enemy) -> void:
	enemy_defeated_count += 1

func _format_state_label() -> String:
	match state:
		WaveState.IDLE:
			return "aguardando"
		WaveState.WAVE_ACTIVE:
			return "onda ativa"
		WaveState.REST:
			return "intervalo %.1fs" % rest_time_remaining
		WaveState.COMPLETE:
			return "objetivo concluido"
		_:
			return "desconhecido"

func _deserialize_wave_spec(value: Variant) -> Dictionary:
	if value is String and str(value) != "":
		var parsed: Variant = str_to_var(str(value))
		if parsed is Dictionary:
			return Dictionary(parsed).duplicate(true)
	return {}
