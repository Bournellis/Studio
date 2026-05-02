class_name CampaignGameLoop
extends "res://modes/shared/local_mode_game_loop.gd"

const LocalModeLaunchRequest = preload("res://modes/shared/local_mode_launch_request.gd")

var launch_request: LocalModeLaunchRequest
var player
var game_context
var stage_manager
var boss_was_unlocked_at_start: bool = false

func _init() -> void:
	configure(LocalModeCatalog.CAMPAIGN_MODE_ID)

func bind(
	next_launch_request: LocalModeLaunchRequest,
	next_player,
	context,
	manager,
	next_stage_manager,
	next_boss_was_unlocked_at_start: bool = false
) -> void:
	launch_request = next_launch_request
	player = next_player
	game_context = context
	stage_manager = next_stage_manager
	boss_was_unlocked_at_start = next_boss_was_unlocked_at_start
	bind_session_manager(manager)

func _process(delta: float) -> void:
	if session_manager == null:
		return
	if not tick_runtime(delta):
		return

	if stage_manager != null:
		stage_manager.tick(delta)
	_refresh_player_targeting()
	if player != null and player.is_dead:
		conclude(build_outcome_result(false))

func get_hud_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	if stage_manager != null:
		snapshot = stage_manager.get_hud_snapshot()
	snapshot["duration_seconds"] = elapsed_seconds
	return snapshot

func get_shell_snapshot() -> Dictionary:
	var shared_snapshot: Dictionary = super.get_shell_snapshot()
	var campaign_snapshot: Dictionary = get_hud_snapshot()
	var campaign_name: String = str(campaign_snapshot.get("campaign_name", "Campanha do Troll"))
	var stage_name: String = str(campaign_snapshot.get("stage_name", "Mapa"))
	var stage_number: int = int(campaign_snapshot.get("stage_number", 1))
	var target_stage_count: int = int(campaign_snapshot.get("target_stage_count", 1))
	var enemy_defeated_count: int = int(campaign_snapshot.get("enemy_defeated_count", 0))
	var enemies_alive: int = int(campaign_snapshot.get("enemies_alive", 0))
	var difficulty_label: String = str(campaign_snapshot.get("difficulty_label", "Classic - Easy"))
	var objective_text: String = str(campaign_snapshot.get("objective_text", "Avance pela campanha."))
	shared_snapshot["module_title"] = "%s: %s (%d/%d)" % [
		campaign_name,
		stage_name,
		stage_number,
		target_stage_count
	]
	shared_snapshot["module_detail"] = "%s | objetivo: %s | trolls ativos %d | abatidos %d" % [
		difficulty_label,
		objective_text,
		enemies_alive,
		enemy_defeated_count
	]
	return shared_snapshot

func build_outcome_result(player_victory: bool, extra_summary_lines: Array[String] = []) -> Dictionary:
	var round_summary: Dictionary = {}
	if game_context != null:
		round_summary = game_context.get_round_summary()

	var campaign_snapshot: Dictionary = get_hud_snapshot()
	round_summary["campaign"] = {
		"campaign_id": String(launch_request.get_campaign_id()),
		"campaign_name": str(campaign_snapshot.get("campaign_name", "Campanha do Troll")),
		"difficulty_id": String(launch_request.get_campaign_difficulty_id()),
		"difficulty_label": str(campaign_snapshot.get("difficulty_label", "Classic - Easy")),
		"stages_completed": int(campaign_snapshot.get("stage_number", 1)) if player_victory else maxi(0, int(campaign_snapshot.get("stage_number", 1)) - 1),
		"target_stages": int(campaign_snapshot.get("target_stage_count", 0)),
		"enemies_defeated": int(campaign_snapshot.get("enemy_defeated_count", 0))
	}

	var campaign_name: String = str(campaign_snapshot.get("campaign_name", "Campanha do Troll"))
	var difficulty_label: String = str(campaign_snapshot.get("difficulty_label", "Classic - Easy"))
	var difficulty_id: StringName = launch_request.get_campaign_difficulty_id()
	var is_free_replay: bool = difficulty_id == &"free"
	var title: String = (
		("Campanha Livre concluida!" if is_free_replay else "Campanha Classica concluida!")
		if player_victory
		else ("O replay livre caiu" if is_free_replay else "A jornada caiu")
	)
	var summary_lines: Array[String] = []
	if player_victory:
		if is_free_replay:
			summary_lines.append("%s foi revisitada do inicio ao chefe em %s com o kit preparado." % [campaign_name, difficulty_label])
			summary_lines.append("Campanha Livre nao gera novos unlocks permanentes; ela existe para replay e buildcraft.")
		else:
			summary_lines.append("%s foi concluida do inicio ao chefe em %s." % [campaign_name, difficulty_label])
		if boss_was_unlocked_at_start:
			summary_lines.append("Boss ja estava liberado e continua como extra de maestria no menu.")
		elif not is_free_replay:
			summary_lines.append("Boss abriu como extra de maestria depois da jornada principal.")
	else:
		if is_free_replay:
			summary_lines.append("%s caiu durante o replay livre." % campaign_name)
			summary_lines.append("A proxima tentativa volta para o Mapa 1 com o kit livre escolhido no menu.")
		else:
			summary_lines.append("%s caiu antes do confronto final." % campaign_name)
			summary_lines.append("A derrota reseta a rota Classic; a proxima tentativa volta para a Missao 1.")
	for line: String in extra_summary_lines:
		summary_lines.append(line)
	return build_result_payload(player_victory, title, summary_lines, round_summary)

func _refresh_player_targeting() -> void:
	if player == null or stage_manager == null:
		return

	var enemies: Array = stage_manager.get_active_enemies()
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
