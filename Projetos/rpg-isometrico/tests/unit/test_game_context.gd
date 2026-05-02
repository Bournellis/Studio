extends "res://addons/gut/test.gd"

const GameContext = preload("res://gameplay/simulation/game_context.gd")

func test_game_context_tracks_actions_damage_and_support_stats() -> void:
	var context: GameContext = autofree(GameContext.new())
	context.reset_round()

	context.register_action(&"player", "basic_attack", "Ataque basico")
	context.register_action(&"player", "skill", "Impacto do Martelo")
	context.register_damage(&"player", &"bot", 18.0, 18.0, 0.0, 117.0)
	context.register_heal(&"player", 14.0, 128.0)
	context.register_barrier(&"player", 20.0, 3.0)
	context.emit_death(&"bot")

	var summary: Dictionary = context.get_round_summary()
	var combatants: Dictionary = summary.get("combatants", {})
	var player_stats: Dictionary = combatants.get("player", {})
	var bot_stats: Dictionary = combatants.get("bot", {})

	assert_eq(int(player_stats.get("actions_used", 0)), 2)
	assert_eq(int(player_stats.get("basic_attacks", 0)), 1)
	assert_eq(int(player_stats.get("skills_used", 0)), 1)
	assert_eq(float(player_stats.get("damage_dealt", 0.0)), 18.0)
	assert_eq(float(player_stats.get("healing_done", 0.0)), 14.0)
	assert_eq(float(player_stats.get("barrier_applied", 0.0)), 20.0)
	assert_eq(float(bot_stats.get("damage_taken", 0.0)), 18.0)

	var recent_events: Array[Dictionary] = summary.get("recent_events", [])
	assert_true(recent_events.size() >= 4)
	assert_eq(str(recent_events[recent_events.size() - 1].get("text", "")), "Bot caiu.")

func test_game_context_tracks_absorbed_damage_without_health_loss() -> void:
	var context: GameContext = autofree(GameContext.new())
	context.reset_round()

	context.register_damage(&"bot", &"player", 22.0, 0.0, 22.0, 150.0)
	var summary: Dictionary = context.get_round_summary()
	var player_stats: Dictionary = summary.get("combatants", {}).get("player", {})
	var bot_stats: Dictionary = summary.get("combatants", {}).get("bot", {})
	var recent_events: Array[Dictionary] = summary.get("recent_events", [])

	assert_eq(float(player_stats.get("damage_taken", 0.0)), 0.0)
	assert_eq(float(player_stats.get("damage_blocked", 0.0)), 22.0)
	assert_eq(float(bot_stats.get("damage_dealt", 0.0)), 0.0)
	assert_eq(str(recent_events[0].get("kind", "")), "block")
