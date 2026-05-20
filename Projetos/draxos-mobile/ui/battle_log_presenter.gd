class_name BattleLogPresenter
extends RefCounted

const KNOWN_EVENT_TYPES := {
	"battle_start": true,
	"weapon_attack": true,
	"spell_cast": true,
	"reward_preview": true,
	"battle_result": true,
}

static func sorted_events(battle_log: Dictionary) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for event: Variant in Array(battle_log.get("events", [])):
		if event is Dictionary:
			events.append(Dictionary(event).duplicate(true))

	events.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		var left_time := float(left.get("t", 0.0))
		var right_time := float(right.get("t", 0.0))
		if not is_equal_approx(left_time, right_time):
			return left_time < right_time
		return int(left.get("seq", 0)) < int(right.get("seq", 0))
	)
	return events

static func format_event(event: Dictionary) -> String:
	var timestamp := "%.1fs" % float(event.get("t", 0.0))
	var event_type := str(event.get("type", "unknown"))
	match event_type:
		"battle_start":
			return "%s - Batalha iniciada" % timestamp
		"weapon_attack":
			return "%s - %s atacou %s: %s %s, alvo HP %s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("hp_after", "?")),
			]
		"spell_cast":
			return "%s - %s conjurou %s em %s: %s %s, alvo HP %s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("spell_id", "spell_desconhecida")),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("hp_after", "?")),
			]
		"reward_preview":
			return "%s - Recompensa recebida: %s" % [timestamp, str(event.get("reward_type", "desconhecida"))]
		"battle_result":
			return "%s - Resultado: %s (%s)" % [
				timestamp,
				str(event.get("winner", "desconhecido")),
				str(event.get("reason", "sem_motivo")),
			]
		_:
			return "%s - Evento desconhecido: %s" % [timestamp, event_type]

static func format_summary(battle_log: Dictionary, rewards: Dictionary = {}) -> String:
	if battle_log.is_empty():
		return "Nenhuma batalha registrada."

	var result := Dictionary(battle_log.get("result", {}))
	var participants := Dictionary(battle_log.get("participants", {}))
	var opponent := Dictionary(participants.get("opponent", {}))
	var reward_type := str(rewards.get("type", "MVP_ONLY"))
	return "Resultado: %s contra %s | motivo: %s | recompensa: %s" % [
		str(result.get("winner", "desconhecido")),
		str(opponent.get("display_name", "oponente")),
		str(result.get("reason", "sem_motivo")),
		reward_type,
	]

static func has_unknown_events(battle_log: Dictionary) -> bool:
	for event: Dictionary in sorted_events(battle_log):
		if not KNOWN_EVENT_TYPES.has(str(event.get("type", ""))):
			return true
	return false

static func _source_label(source: String) -> String:
	if source == "player":
		return "Draxos"
	if source == "opponent":
		return "Oponente"
	if source == "system":
		return "Sistema"
	return source

static func _target_label(target: String) -> String:
	if target == "player":
		return "Draxos"
	if target == "opponent":
		return "oponente"
	if target == "none":
		return "nenhum"
	return target
