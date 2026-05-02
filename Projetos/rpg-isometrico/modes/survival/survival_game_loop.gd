class_name SurvivalGameLoop
extends "res://modes/shared/local_mode_game_loop.gd"

const LocalModeLaunchRequest = preload("res://modes/shared/local_mode_launch_request.gd")

var launch_request: LocalModeLaunchRequest
var game_context
var player
var wave_manager
var spawn_controller
var runtime_started: bool = false
var initial_wave: int = 1

func _init() -> void:
	configure(LocalModeCatalog.SURVIVAL_MODE_ID)

func bind(next_launch_request: LocalModeLaunchRequest, next_player, context, manager, next_wave_manager, next_spawn_controller) -> void:
	launch_request = next_launch_request
	player = next_player
	game_context = context
	wave_manager = next_wave_manager
	spawn_controller = next_spawn_controller
	bind_session_manager(manager)
	runtime_started = false
	initial_wave = launch_request.get_survival_start_wave()

func _process(delta: float) -> void:
	if session_manager == null:
		return
	if not runtime_started and session_manager.is_in_progress():
		runtime_started = true
		wave_manager.start(initial_wave)
	if not tick_runtime(delta):
		return

	_refresh_player_targeting()
	if player == null:
		return

	if player.is_dead:
		conclude(_build_result(false))
		return

	if wave_manager != null:
		wave_manager.tick(delta)
		if wave_manager.has_session_completed():
			conclude(_build_result(true))

func get_hud_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	if wave_manager != null:
		snapshot = wave_manager.get_hud_snapshot()
	snapshot["duration_seconds"] = elapsed_seconds
	return snapshot

func get_shell_snapshot() -> Dictionary:
	var shared_snapshot: Dictionary = super.get_shell_snapshot()
	var survival_snapshot: Dictionary = get_hud_snapshot()
	var wave_number: int = maxi(1, int(survival_snapshot.get("wave_number", 0)))
	var target_wave: int = int(survival_snapshot.get("target_wave", 0))
	var completed_waves: int = int(survival_snapshot.get("completed_waves", 0))
	var enemies_alive: int = int(survival_snapshot.get("enemies_alive", 0))
	var pending_spawns: int = int(survival_snapshot.get("pending_spawns", 0))
	var enemy_defeated_count: int = int(survival_snapshot.get("enemy_defeated_count", 0))
	var rest_remaining: float = float(survival_snapshot.get("rest_remaining", 0.0))
	if rest_remaining > 0.0:
		shared_snapshot["module_title"] = "Survival: intervalo antes da onda %d" % (wave_number + 1)
		shared_snapshot["module_detail"] = "Folego %.1fs | concluidas %d/%d | trolls derrotados %d" % [
			rest_remaining,
			completed_waves,
			target_wave,
			enemy_defeated_count
		]
	else:
		shared_snapshot["module_title"] = "Survival: onda %d de %d" % [wave_number, target_wave]
		shared_snapshot["module_detail"] = "%s | trolls ativos %d | reforcos %d | derrotados %d" % [
			str(survival_snapshot.get("state_label", "onda ativa")),
			enemies_alive,
			pending_spawns,
			enemy_defeated_count
		]
	return shared_snapshot

func _refresh_player_targeting() -> void:
	if player == null or spawn_controller == null:
		return

	var enemies: Array = spawn_controller.get_active_enemies()
	player.set_additional_targets(enemies)
	player.target = _pick_primary_enemy(enemies)

func _pick_primary_enemy(enemies: Array):
	var selected_enemy = null
	var selected_distance: float = INF
	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy) or enemy.is_dead:
			continue
		var distance_to_enemy: float = player.global_position.distance_to(enemy.global_position)
		if distance_to_enemy >= selected_distance:
			continue
		selected_enemy = enemy
		selected_distance = distance_to_enemy
	return selected_enemy

func _build_result(player_victory: bool) -> Dictionary:
	var survival_snapshot: Dictionary = get_hud_snapshot()
	var round_summary: Dictionary = {}
	if game_context != null:
		round_summary = game_context.get_round_summary()
	round_summary["survival"] = {
		"waves_completed": int(survival_snapshot.get("completed_waves", 0)),
		"highest_wave_reached": int(survival_snapshot.get("highest_wave_reached", 0)),
		"target_wave": int(survival_snapshot.get("target_wave", 0)),
		"enemies_defeated": int(survival_snapshot.get("enemy_defeated_count", 0))
	}
	round_summary["extra_mode"] = {
		"role": "Prova de resistencia",
		"framing": "Desafio de ondas da forja",
		"result_focus": "ondas concluidas, folego e controle de pressao",
		"grants_permanent_progress": false
	}

	var title: String = "Resistencia provada!" if player_victory else "A horda venceu"
	var summary_lines: Array[String] = []
	if player_victory:
		summary_lines.append("A ultima onda caiu e a linha da forja foi mantida ate o fim.")
	else:
		summary_lines.append("A horda venceu antes do encerramento das ondas.")
	summary_lines.append("Survival mede resistencia e dominio do kit; nao gera novos unlocks permanentes.")
	return build_result_payload(player_victory, title, summary_lines, round_summary)

func mark_runtime_started_from_resume() -> void:
	runtime_started = true
