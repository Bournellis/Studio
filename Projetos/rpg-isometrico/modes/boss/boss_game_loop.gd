class_name BossGameLoop
extends "res://modes/shared/local_mode_game_loop.gd"

const LocalModeLaunchRequest = preload("res://modes/shared/local_mode_launch_request.gd")

var launch_request: LocalModeLaunchRequest
var player
var boss
var game_context

func _init() -> void:
	configure(LocalModeCatalog.BOSS_MODE_ID)

func bind(next_launch_request: LocalModeLaunchRequest, next_player, next_boss, context, manager) -> void:
	launch_request = next_launch_request
	player = next_player
	boss = next_boss
	game_context = context
	bind_session_manager(manager)

func _process(delta: float) -> void:
	if not tick_runtime(delta):
		return

	if player == null or boss == null:
		return

	player.target = boss
	player.set_additional_targets([boss])

	if player.is_dead:
		conclude(_build_result(false))
	elif boss.is_dead:
		conclude(_build_result(true))

func get_hud_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}
	if boss != null and boss.has_method("get_runtime_snapshot"):
		snapshot = boss.get_runtime_snapshot()
	snapshot["duration_seconds"] = elapsed_seconds
	return snapshot

func get_shell_snapshot() -> Dictionary:
	var shared_snapshot: Dictionary = super.get_shell_snapshot()
	var boss_snapshot: Dictionary = get_hud_snapshot()
	var boss_name: String = str(boss_snapshot.get("boss_name", "Boss Troll"))
	var health_ratio: float = float(boss_snapshot.get("health_ratio", 0.0))
	var detail_parts: Array[String] = [str(boss_snapshot.get("intent_label", "observando"))]
	var attack_label: String = str(boss_snapshot.get("attack_label", "Observando"))
	if bool(boss_snapshot.get("invulnerable", false)):
		detail_parts.append("invulneravel")
	if bool(boss_snapshot.get("tremor_active", false)):
		detail_parts.append("tremor no chao")
	if attack_label != "Observando":
		detail_parts.append("ataque %s" % attack_label)
	var roar_cooldown_remaining: float = float(boss_snapshot.get("roar_cooldown_remaining", 0.0))
	detail_parts.append("rugido %s" % ("pronto" if roar_cooldown_remaining <= 0.0 else "%.1fs" % roar_cooldown_remaining))

	shared_snapshot["module_title"] = "%s: %s | vida %d%%" % [
		boss_name,
		str(boss_snapshot.get("phase_label", "Fase 1")),
		int(round(health_ratio * 100.0))
	]
	shared_snapshot["module_detail"] = "%s | raio do rugido %.1fm" % [" | ".join(detail_parts), float(boss_snapshot.get("roar_radius", 0.0))]
	shared_snapshot["opponent_visible"] = boss != null and is_instance_valid(boss)
	shared_snapshot["opponent_label"] = boss_name
	shared_snapshot["opponent_status_text"] = "Boss: %s" % str(boss_snapshot.get("intent_label", "observando"))
	shared_snapshot["opponent_health"] = float(boss_snapshot.get("health", 0.0))
	shared_snapshot["opponent_max_health"] = maxf(1.0, float(boss_snapshot.get("max_health", 1.0)))
	return shared_snapshot

func _build_result(player_victory: bool) -> Dictionary:
	var round_summary: Dictionary = {}
	if game_context != null:
		round_summary = game_context.get_round_summary()

	var boss_snapshot: Dictionary = get_hud_snapshot()
	round_summary["boss"] = {
		"boss_id": String(launch_request.get_boss_id()),
		"boss_name": str(boss_snapshot.get("boss_name", "Boss Troll")),
		"phase_number": int(boss_snapshot.get("phase_number", 1)),
		"phase_label": str(boss_snapshot.get("phase_label", "Fase 1")),
		"remaining_health": float(boss_snapshot.get("health", 0.0)),
		"max_health": float(boss_snapshot.get("max_health", 0.0)),
		"player_damage_taken": float(round_summary.get("combatants", {}).get("player", {}).get("damage_taken", 0.0))
	}
	round_summary["extra_mode"] = {
		"role": "Pratica de maestria",
		"framing": "Arena de execucao contra chefe",
		"result_focus": "leitura de perigo, janelas de dano e consistencia do kit",
		"grants_permanent_progress": false
	}

	var title: String = "Boss vencido!" if player_victory else "O Troll venceu"
	var summary_lines: Array[String] = []
	if player_victory:
		summary_lines.append("O Boss Troll caiu em uma pratica de maestria do kit.")
	else:
		summary_lines.append("O Boss Troll manteve a pressao e derrubou o jogador durante a pratica.")
	summary_lines.append("Boss registra execucao contra chefe; progressao permanente continua na campanha.")
	return build_result_payload(player_victory, title, summary_lines, round_summary)
