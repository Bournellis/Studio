class_name GameContext
extends Node

signal player_damaged(victim_id: StringName, amount: float, remaining_health: float)
signal player_died(victim_id: StringName)
signal round_ended(result: Dictionary)
signal combat_event_logged(event: Dictionary)

const MAX_RECENT_EVENTS: int = 14

var recent_events: Array[Dictionary] = []
var round_stats: Dictionary = {}

func _ready() -> void:
	reset_round()

func reset_round() -> void:
	recent_events.clear()
	round_stats.clear()
	round_stats["player"] = _create_stat_bucket()
	round_stats["bot"] = _create_stat_bucket()
	round_stats["boss"] = _create_stat_bucket()
	round_stats["enemy"] = _create_stat_bucket()

func register_action(actor_id: StringName, action_kind: String, action_label: String) -> void:
	var key: String = _stats_key_for(actor_id)
	var stats: Dictionary = Dictionary(round_stats.get(key, _create_stat_bucket()))
	stats["actions_used"] = int(stats.get("actions_used", 0)) + 1

	match action_kind:
		"basic_attack", "bot_attack", "enemy_attack":
			stats["basic_attacks"] = int(stats.get("basic_attacks", 0)) + 1
		"skill":
			stats["skills_used"] = int(stats.get("skills_used", 0)) + 1
		"potion":
			stats["potions_used"] = int(stats.get("potions_used", 0)) + 1
		"dash":
			stats["movement_abilities_used"] = int(stats.get("movement_abilities_used", 0)) + 1

	round_stats[key] = stats
	_append_event({
		"kind": "action",
		"actor_id": _event_key_for(actor_id),
		"action_kind": action_kind,
		"text": "%s: %s" % [_display_name(actor_id), action_label]
	})

func register_damage(source_id: StringName, victim_id: StringName, attempted_amount: float, health_damage: float, absorbed_amount: float, remaining_health: float) -> void:
	var victim_key: String = _stats_key_for(victim_id)
	var victim_stats: Dictionary = Dictionary(round_stats.get(victim_key, _create_stat_bucket()))
	victim_stats["damage_taken"] = float(victim_stats.get("damage_taken", 0.0)) + health_damage
	victim_stats["damage_blocked"] = float(victim_stats.get("damage_blocked", 0.0)) + absorbed_amount
	round_stats[victim_key] = victim_stats

	if source_id != &"":
		var source_key: String = _stats_key_for(source_id)
		var source_stats: Dictionary = Dictionary(round_stats.get(source_key, _create_stat_bucket()))
		source_stats["damage_dealt"] = float(source_stats.get("damage_dealt", 0.0)) + health_damage
		round_stats[source_key] = source_stats

	if health_damage > 0.0:
		_append_event({
			"kind": "damage",
			"actor_id": _event_key_for(source_id),
			"target_id": _event_key_for(victim_id),
			"amount": health_damage,
			"attempted_amount": attempted_amount,
			"remaining_health": remaining_health,
			"text": "%s causou %.0f em %s." % [_display_name(source_id), health_damage, _display_name(victim_id)]
		})
	elif absorbed_amount > 0.0:
		_append_event({
			"kind": "block",
			"actor_id": _event_key_for(victim_id),
			"source_id": _event_key_for(source_id),
			"amount": absorbed_amount,
			"remaining_health": remaining_health,
			"text": "%s absorveu %.0f de %s." % [_display_name(victim_id), absorbed_amount, _display_name(source_id)]
		})
	elif attempted_amount > 0.0:
		_append_event({
			"kind": "glance",
			"actor_id": _event_key_for(source_id),
			"target_id": _event_key_for(victim_id),
			"amount": attempted_amount,
			"text": "%s nao conseguiu conectar o golpe." % _display_name(source_id)
		})

	player_damaged.emit(victim_id, health_damage, remaining_health)

func register_heal(actor_id: StringName, amount: float, resulting_health: float) -> void:
	if amount <= 0.0:
		return

	var key: String = _stats_key_for(actor_id)
	var stats: Dictionary = Dictionary(round_stats.get(key, _create_stat_bucket()))
	stats["healing_done"] = float(stats.get("healing_done", 0.0)) + amount
	round_stats[key] = stats

	_append_event({
		"kind": "heal",
		"actor_id": _event_key_for(actor_id),
		"amount": amount,
		"text": "%s recuperou %.0f de vida." % [_display_name(actor_id), amount],
		"resulting_health": resulting_health
	})

func register_barrier(actor_id: StringName, amount: float, duration: float) -> void:
	if amount <= 0.0:
		return

	var key: String = _stats_key_for(actor_id)
	var stats: Dictionary = Dictionary(round_stats.get(key, _create_stat_bucket()))
	stats["barrier_applied"] = float(stats.get("barrier_applied", 0.0)) + amount
	round_stats[key] = stats

	_append_event({
		"kind": "barrier",
		"actor_id": _event_key_for(actor_id),
		"amount": amount,
		"duration": duration,
		"text": "%s ergueu %.0f de barreira por %.1fs." % [_display_name(actor_id), amount, duration]
	})

func emit_death(victim_id: StringName) -> void:
	_append_event({
		"kind": "death",
		"actor_id": _event_key_for(victim_id),
		"text_short": "CAIU",
		"text": "%s caiu." % _display_name(victim_id)
	})
	player_died.emit(victim_id)

func emit_round_end(result: Dictionary) -> void:
	round_ended.emit(result)

func get_recent_events(max_count: int = 4) -> Array[Dictionary]:
	if max_count <= 0:
		return []

	var start_index: int = maxi(0, recent_events.size() - max_count)
	var result: Array[Dictionary] = []
	for index: int in range(start_index, recent_events.size()):
		result.append(recent_events[index].duplicate(true))
	return result

func get_round_summary() -> Dictionary:
	return {
		"combatants": round_stats.duplicate(true),
		"recent_events": get_recent_events(6)
	}

func _append_event(event: Dictionary) -> void:
	var stored_event: Dictionary = event.duplicate(true)
	stored_event["index"] = recent_events.size()
	recent_events.append(stored_event)
	while recent_events.size() > MAX_RECENT_EVENTS:
		recent_events.remove_at(0)
	combat_event_logged.emit(stored_event)

func _create_stat_bucket() -> Dictionary:
	return {
		"damage_dealt": 0.0,
		"damage_taken": 0.0,
		"damage_blocked": 0.0,
		"healing_done": 0.0,
		"barrier_applied": 0.0,
		"actions_used": 0,
		"basic_attacks": 0,
		"skills_used": 0,
		"potions_used": 0,
		"movement_abilities_used": 0
	}

func _stats_key_for(actor_id: StringName) -> String:
	if actor_id == &"":
		return "system"
	var raw_id: String = str(actor_id)
	if raw_id == "boss" or raw_id.begins_with("boss_"):
		return "boss"
	if raw_id.begins_with("enemy_"):
		return "enemy"
	return raw_id

func _event_key_for(actor_id: StringName) -> String:
	if actor_id == &"":
		return "system"
	return str(actor_id)

func _display_name(actor_id: StringName) -> String:
	var raw_id: String = str(actor_id)
	if raw_id == "boss" or raw_id.begins_with("boss_"):
		return "Boss Troll"
	if raw_id.begins_with("enemy_") or raw_id == "enemy":
		return "Troll"
	match raw_id:
		"player":
			return "Jogador"
		"bot":
			return "Bot"
		"system":
			return "Sistema"
		_:
			return "Combate"
