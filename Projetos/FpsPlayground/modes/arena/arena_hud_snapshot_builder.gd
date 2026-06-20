class_name ArenaHudSnapshotBuilder
extends RefCounted

const ROUND_STATE_PLAYING: StringName = &"playing"
const ROUND_STATE_MATCH_OVER: StringName = &"match_over"
const WINNER_PLAYER: StringName = &"player"

static func build_snapshot(context: Dictionary) -> Dictionary:
	var player = context.get("player", null)
	var bot = context.get("bot", null)
	var round_state: StringName = context.get("round_state", ROUND_STATE_PLAYING)
	var score_to_win := int(context.get("score_to_win", 3))
	var last_round_winner: StringName = context.get("last_round_winner", &"")
	return {
		"status": str(context.get("status", "")),
		"map_name": str(context.get("map_name", "")),
		"round_state": round_state,
		"round_index": int(context.get("round_index", 1)),
		"score_to_win": score_to_win,
		"player_score": int(context.get("player_score", 0)),
		"bot_score": int(context.get("bot_score", 0)),
		"last_round_winner": last_round_winner,
		"match_winner": context.get("match_winner", &""),
		"result_text": build_result_text(round_state, last_round_winner, score_to_win),
		"player_health": 0.0 if player == null else player.health,
		"player_max_health": 1.0 if player == null else player.max_health,
		"bot_health": 0.0 if bot == null else bot.health,
		"bot_max_health": 1.0 if bot == null else bot.max_health,
		"alt_fire_cooldown_fraction": 0.0 if player == null else player.get_alt_fire_cooldown_fraction(),
		"alt_fire_ready": true if player == null else player.alt_fire_cooldown_remaining <= 0.0,
		"player_overcharge": false if player == null else player.has_overcharge_charge(),
		"bot_overcharge": false if bot == null else bot.has_overcharge_charge(),
		"health_pickup_available": bool(context.get("health_pickup_available", false)),
		"health_pickup_respawn": float(context.get("health_pickup_respawn", 0.0)),
		"overcharge_pickup_available": bool(context.get("overcharge_pickup_available", false)),
		"overcharge_pickup_respawn": float(context.get("overcharge_pickup_respawn", 0.0)),
		"bot_state": &"none" if bot == null else bot.debug_get_state(),
		"bot_route_label": &"none" if bot == null else bot.debug_get_route_label(),
		"bot_has_line_of_sight": false if bot == null else bot.debug_has_line_of_sight(),
		"last_jump_pad_id": context.get("last_jump_pad_id", &""),
		"hint": build_hint(round_state, bool(context.get("round_ended", false)))
	}

static func build_playing_status(map_name: String, round_index: int, player_score: int, bot_score: int) -> String:
	return "%s | Round %d | Player %d x %d Bot" % [map_name, round_index, player_score, bot_score]

static func build_result_status(
	round_state: StringName,
	last_round_winner: StringName,
	player_score: int,
	bot_score: int,
	round_index: int
) -> String:
	var winner_name := _get_winner_name(last_round_winner)
	if round_state == ROUND_STATE_MATCH_OVER:
		return "%s venceu o duelo %d x %d. Aperte R para novo duelo." % [winner_name, player_score, bot_score]
	return "%s venceu o round %d. Aperte R para proximo round." % [winner_name, round_index]

static func build_result_text(round_state: StringName, last_round_winner: StringName, score_to_win: int) -> String:
	if round_state == ROUND_STATE_PLAYING:
		return "First to %d" % score_to_win
	var winner_name := _get_winner_name(last_round_winner)
	if round_state == ROUND_STATE_MATCH_OVER:
		return "%s venceu o duelo" % winner_name
	return "%s venceu o round" % winner_name

static func build_hint(round_state: StringName, round_ended: bool) -> String:
	if round_state == ROUND_STATE_MATCH_OVER:
		return "R novo duelo | Esc menu"
	if round_ended:
		return "R proximo round | Esc menu"
	return "Click captures mouse | WASD move | LMB rifle | RMB plasma | Pads launch | R reset round | Esc"

static func _get_winner_name(last_round_winner: StringName) -> String:
	return "Player" if last_round_winner == WINNER_PLAYER else "Bot"
