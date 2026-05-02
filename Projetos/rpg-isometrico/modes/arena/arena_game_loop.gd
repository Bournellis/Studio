class_name ArenaGameLoop
extends "res://modes/shared/local_mode_game_loop.gd"

const PlayerController = preload("res://gameplay/player/player_controller.gd")
const SimpleBotController = preload("res://gameplay/bot/simple_bot_controller.gd")
const GameContext = preload("res://gameplay/simulation/game_context.gd")
const ArenaSessionManager = preload("res://modes/arena/arena_session_manager.gd")

var player
var bot
var game_context

func _init() -> void:
	configure(LocalModeCatalog.ARENA_MODE_ID)

func bind(next_player, next_bot, context, manager) -> void:
	player = next_player
	bot = next_bot
	game_context = context
	bind_session_manager(manager)

func _process(delta: float) -> void:
	if not tick_runtime(delta):
		return

	if player == null or bot == null:
		return

	if player.is_dead:
		conclude(_build_result(false))
	elif bot.is_dead:
		conclude(_build_result(true))

func get_shell_snapshot() -> Dictionary:
	var snapshot: Dictionary = super.get_shell_snapshot()
	var bot_is_available: bool = bot != null and is_instance_valid(bot)
	var player_is_available: bool = player != null and is_instance_valid(player)
	var distance_to_bot: float = 0.0
	var bot_intent: String = "sem leitura"
	if player_is_available and bot_is_available:
		distance_to_bot = player.global_position.distance_to(bot.global_position)
		bot_intent = bot.get_intent_label()

	snapshot["module_title"] = "Arena Bot: treino de kit"
	snapshot["module_detail"] = "Simulacao local | distancia %.1fm | bot %s" % [distance_to_bot, bot_intent]
	snapshot["opponent_visible"] = bot_is_available
	snapshot["opponent_label"] = "Bot"
	snapshot["opponent_status_text"] = "" if not bot_is_available else "Bot: %s" % bot.get_intent_label()
	snapshot["opponent_health"] = 0.0 if not bot_is_available else bot.health
	snapshot["opponent_max_health"] = 1.0 if not bot_is_available else maxf(1.0, bot.max_health)
	return snapshot

func _build_round_summary() -> Dictionary:
	if game_context == null:
		return {}
	return game_context.get_round_summary()

func _build_result(player_victory: bool) -> Dictionary:
	var round_summary: Dictionary = _build_round_summary()
	round_summary["extra_mode"] = {
		"role": "Treino de kit",
		"framing": "Simulacao local contra bot",
		"result_focus": "mira, leitura e rotacao do kit",
		"grants_permanent_progress": false
	}
	var combatants: Dictionary = round_summary.get("combatants", {})
	var player_stats: Dictionary = combatants.get("player", {})
	var bot_stats: Dictionary = combatants.get("bot", {})
	var title: String = "Treino concluido!" if player_victory else "Treino interrompido"
	var summary_lines: Array[String] = []
	if player_victory:
		summary_lines.append("A simulacao contra bot terminou com o jogador em vantagem.")
	else:
		summary_lines.append("O bot encerrou a simulacao antes do dominio completo do kit.")
	summary_lines.append("Arena Bot registra leitura e execucao; progressao permanente continua na campanha.")
	summary_lines.append("Vida final - jogador %.0f / %.0f | bot %.0f / %.0f." % [
		0.0 if player == null else player.health,
		1.0 if player == null else player.max_health,
		0.0 if bot == null else bot.health,
		1.0 if bot == null else bot.max_health
	])
	summary_lines.append("Pressao ofensiva - jogador %.0f | bot %.0f." % [
		float(player_stats.get("damage_dealt", 0.0)),
		float(bot_stats.get("damage_dealt", 0.0))
	])
	return build_result_payload(
		player_victory,
		title,
		summary_lines,
		round_summary,
		{"winner": "player" if player_victory else "bot"}
	)
