class_name BattleLogPresenter
extends RefCounted

const KNOWN_EVENT_TYPES := {
	"battle_start": true,
	"weapon_attack": true,
	"mana_change": true,
	"cooldown_start": true,
	"cooldown_ready": true,
	"passive_apply": true,
	"spell_cast": true,
	"dot_apply": true,
	"dot_tick": true,
	"status_apply": true,
	"status_expire": true,
	"barrier_gain": true,
	"barrier_absorb": true,
	"resistance_apply": true,
	"summon_spawn": true,
	"summon_attack": true,
	"summon_expire": true,
	"pet_attack": true,
	"heal": true,
	"anti_stall": true,
	"reward_preview": true,
	"battle_result": true,
}

static func sorted_events(battle_log: Dictionary) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	for event: Variant in _as_array(battle_log.get("events", [])):
		if event is Dictionary:
			events.append(_as_dictionary(event).duplicate(true))

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
			return "%s - %s atacou %s: %s %s, alvo HP %s%s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"mana_change":
			return "%s - %s mana: %s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("mana_after", "?")),
			]
		"cooldown_start":
			return "%s - %s entrou em recarga ate %.1fs" % [
				timestamp,
				str(event.get("spell_id", "spell_desconhecida")),
				float(event.get("ready_at", 0.0)),
			]
		"cooldown_ready":
			return "%s - %s pronto novamente" % [
				timestamp,
				str(event.get("spell_id", "spell_desconhecida")),
			]
		"passive_apply":
			return "%s - %s ativou passiva %s nv.%s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("passive_id", "passiva_desconhecida")),
				str(event.get("passive_level", "?")),
			]
		"spell_cast":
			return "%s - %s conjurou %s em %s: %s %s, alvo HP %s%s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("spell_id", "spell_desconhecida")),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"dot_apply":
			return "%s - %s aplicou %s em %s (%s stacks)" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("status_id", "dot")),
				_target_label(str(event.get("target", ""))),
				str(event.get("stacks", "1")),
			]
		"dot_tick":
			return "%s - %s causou %s %s em %s, alvo HP %s%s" % [
				timestamp,
				str(event.get("status_id", "dot")),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				_target_label(str(event.get("target", ""))),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"status_apply":
			return "%s - %s aplicou status %s em %s (%s stacks)" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("status_id", "status")),
				_target_label(str(event.get("target", ""))),
				str(event.get("stacks", "1")),
			]
		"status_expire":
			return "%s - %s expirou em %s" % [
				timestamp,
				str(event.get("status_id", "status")),
				_target_label(str(event.get("target", ""))),
			]
		"barrier_gain":
			return "%s - %s ganhou barreira %s (barreira %s)" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("amount", "?")),
				str(event.get("barrier_after", "?")),
			]
		"barrier_absorb":
			return "%s - Barreira de %s absorveu %s %s (barreira %s)" % [
				timestamp,
				_target_label(str(event.get("target", ""))),
				str(event.get("amount", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("barrier_after", "?")),
			]
		"resistance_apply":
			return "%s - %s ganhou resistencia %.1f%%" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				float(event.get("amount", 0.0)) * 100.0,
			]
		"summon_spawn":
			return "%s - %s invocou %s (%s HP)" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("target", "summon")),
				str(event.get("hp", "?")),
			]
		"summon_attack":
			return "%s - %s atacou %s: %s %s, alvo HP %s%s" % [
				timestamp,
				str(event.get("source", "summon")),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"summon_expire":
			return "%s - %s desapareceu" % [
				timestamp,
				str(event.get("source", "summon")),
			]
		"pet_attack":
			return "%s - Pet %s atacou %s: %s %s, alvo HP %s%s" % [
				timestamp,
				str(event.get("pet_id", "pet")),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				str(event.get("damage_type", "dano")),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"heal":
			return "%s - %s curou %s, HP %s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("amount", "?")),
				str(event.get("hp_after", "?")),
			]
		"anti_stall":
			return "%s - Anti-stall ativado: Draxos HP %s, oponente HP %s" % [
				timestamp,
				str(event.get("player_hp_after", "?")),
				str(event.get("opponent_hp_after", "?")),
			]
		"reward_preview":
			return "%s - Recompensa recebida: %s" % [
				timestamp,
				str(event.get("reward_type", "desconhecida")),
			]
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

	var result := _as_dictionary(battle_log.get("result", {}))
	var participants := _as_dictionary(battle_log.get("participants", {}))
	var opponent := _as_dictionary(participants.get("opponent", {}))
	var reward_type := str(rewards.get("type", "MVP_ONLY"))
	return "Modo: %s | Resultado: %s contra %s | motivo: %s | recompensa: %s%s" % [
		str(battle_log.get("mode", "MVP_ONLY")),
		str(result.get("winner", "desconhecido")),
		str(opponent.get("display_name", "oponente")),
		str(result.get("reason", "sem_motivo")),
		reward_type,
		_format_resource_suffix(_as_dictionary(rewards.get("resources", {}))),
	]

static func has_unknown_events(battle_log: Dictionary) -> bool:
	for event: Dictionary in sorted_events(battle_log):
		if not KNOWN_EVENT_TYPES.has(str(event.get("type", ""))):
			return true
	return false

static func count_events_of_type(battle_log: Dictionary, event_type: String) -> int:
	var count := 0
	for event: Dictionary in sorted_events(battle_log):
		if str(event.get("type", "")) == event_type:
			count += 1
	return count

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

static func _absorb_suffix(event: Dictionary) -> String:
	var absorbed := float(event.get("absorbed", 0.0))
	if absorbed <= 0.0:
		return ""
	return " (barreira absorveu %s)" % str(event.get("absorbed", 0))

static func _format_resource_suffix(resources: Dictionary) -> String:
	if resources.is_empty():
		return ""
	var parts: PackedStringArray = PackedStringArray()
	for key: String in resources.keys():
		parts.append("%s %s" % [str(resources[key]), key])
	if parts.is_empty():
		return ""
	return " [%s]" % ", ".join(parts)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
