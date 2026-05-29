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
	"consumable_use": true,
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
				_humanize_id(str(event.get("damage_type", "dano"))),
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
			return "%s - %s entra em espera ate %.1fs" % [
				timestamp,
				_humanize_id(str(event.get("spell_id", "spell_desconhecida"))),
				float(event.get("ready_at", 0.0)),
			]
		"cooldown_ready":
			return "%s - %s pronto novamente" % [
				timestamp,
				_humanize_id(str(event.get("spell_id", "spell_desconhecida"))),
			]
		"passive_apply":
			return "%s - %s ativou Doutrina %s nv.%s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_humanize_id(str(event.get("passive_id", "doutrina_desconhecida"))),
				str(event.get("passive_level", "?")),
			]
		"spell_cast":
			return "%s - %s conjurou %s em %s: %s %s, alvo HP %s%s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_humanize_id(str(event.get("spell_id", "spell_desconhecida"))),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				_humanize_id(str(event.get("damage_type", "dano"))),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"dot_apply":
			return "%s - %s aplicou %s em %s (%s stacks)" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_humanize_id(str(event.get("status_id", "dot"))),
				_target_label(str(event.get("target", ""))),
				str(event.get("stacks", "1")),
			]
		"dot_tick":
			return "%s - %s causou %s %s em %s, alvo HP %s%s" % [
				timestamp,
				_humanize_id(str(event.get("status_id", "dot"))),
				str(event.get("damage", "?")),
				_humanize_id(str(event.get("damage_type", "dano"))),
				_target_label(str(event.get("target", ""))),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"status_apply":
			return "%s - %s aplicou status %s em %s (%s stacks)" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_humanize_id(str(event.get("status_id", "status"))),
				_target_label(str(event.get("target", ""))),
				str(event.get("stacks", "1")),
			]
		"status_expire":
			return "%s - %s expirou em %s" % [
				timestamp,
				_humanize_id(str(event.get("status_id", "status"))),
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
				_humanize_id(str(event.get("damage_type", "dano"))),
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
				_humanize_id(str(event.get("target", "summon"))),
				str(event.get("hp", "?")),
			]
		"summon_attack":
			return "%s - %s atacou %s: %s %s, alvo HP %s%s" % [
				timestamp,
				_humanize_id(str(event.get("source", "summon"))),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				_humanize_id(str(event.get("damage_type", "dano"))),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"summon_expire":
			return "%s - %s desapareceu" % [
				timestamp,
				_humanize_id(str(event.get("source", "summon"))),
			]
		"pet_attack":
			return "%s - Familiar %s atacou %s: %s %s, alvo HP %s%s" % [
				timestamp,
				_humanize_id(str(event.get("pet_id", "pet"))),
				_target_label(str(event.get("target", ""))),
				str(event.get("damage", "?")),
				_humanize_id(str(event.get("damage_type", "dano"))),
				str(event.get("hp_after", "?")),
				_absorb_suffix(event),
			]
		"consumable_use":
			return "%s - %s usou %s%s: %s por %s%s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				_item_label(str(event.get("item_id", "item"))),
				_slot_suffix(event),
				_effect_label(str(event.get("effect_id", event.get("effect", "efeito")))),
				_duration_text(event),
				_tick_suffix(event),
			]
		"heal":
			return "%s - %s recuperou %s de HP com %s, HP %s" % [
				timestamp,
				_source_label(str(event.get("source", ""))),
				str(event.get("amount", "?")),
				_item_label(str(event.get("item_id", "cura"))),
				str(event.get("hp_after", "?")),
			]
		"anti_stall":
			return "%s - Limite da luta ativado: Draxos HP %s, oponente HP %s" % [
				timestamp,
				str(event.get("player_hp_after", "?")),
				str(event.get("opponent_hp_after", "?")),
			]
		"reward_preview":
			return "%s - Recompensa recebida: %s" % [
				timestamp,
				_humanize_id(str(event.get("reward_type", "desconhecida"))),
			]
		"battle_result":
			return "%s - Resultado: %s (%s)" % [
				timestamp,
				_humanize_id(str(event.get("winner", "desconhecido"))),
				_humanize_id(str(event.get("reason", "sem_motivo"))),
			]
		_:
			return "%s - Evento desconhecido: %s" % [timestamp, event_type]

static func format_summary(battle_log: Dictionary, rewards: Dictionary = {}) -> String:
	if battle_log.is_empty():
		return "Nenhuma batalha registrada."

	var result := _as_dictionary(battle_log.get("result", {}))
	var participants := _as_dictionary(battle_log.get("participants", {}))
	var opponent := _as_dictionary(participants.get("opponent", {}))
	var reward_text := _format_resource_suffix(_as_dictionary(rewards.get("resources", {})))
	if reward_text == "":
		reward_text = "sem recompensa registrada"
	return "Resultado: %s contra %s | motivo: %s | recompensa: %s" % [
		_humanize_id(str(result.get("winner", "desconhecido"))),
		str(opponent.get("display_name", "oponente")),
		_humanize_id(str(result.get("reason", "sem_motivo"))),
		reward_text,
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
		return "Batalha"
	return _humanize_id(source)

static func _target_label(target: String) -> String:
	if target == "player":
		return "Draxos"
	if target == "opponent":
		return "oponente"
	if target == "none":
		return "nenhum"
	return _humanize_id(target)

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
		parts.append("%s +%s" % [_resource_label(key), str(resources[key])])
	if parts.is_empty():
		return ""
	return ", ".join(parts)

static func _item_label(item_id: String) -> String:
	match item_id:
		"pocao_vida":
			return "Pocao de Vida"
		_:
			return _humanize_id(item_id)

static func _effect_label(effect_id: String) -> String:
	match effect_id:
		"heal_over_time":
			return "cura gradual"
		_:
			return _humanize_id(effect_id)

static func _duration_text(event: Dictionary) -> String:
	var duration: Variant = event.get("duration", event.get("duration_seconds", "?"))
	if duration is float or duration is int:
		return "%ss" % _number_text(float(duration))
	return str(duration)

static func _tick_suffix(event: Dictionary) -> String:
	if not event.has("tick_percent"):
		return ""
	return ", %s%% por pulso" % _number_text(float(event.get("tick_percent", 0.0)))

static func _slot_suffix(event: Dictionary) -> String:
	if not event.has("slot_index"):
		return ""
	return " no slot %s" % str(event.get("slot_index", "?"))

static func _resource_label(resource_id: String) -> String:
	match resource_id:
		"xp":
			return "XP"
		"almas":
			return "Almas"
		"ossos":
			return "Ossos"
		"po_osso":
			return "Po de Osso"
		_:
			return _humanize_id(resource_id)

static func _humanize_id(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned == "":
		return ""
	match cleaned:
		"player":
			return "Draxos"
		"opponent":
			return "Oponente"
		"system":
			return "Batalha"
		"combatant_defeated", "opponent_defeated":
			return "oponente derrotado"
		"player_defeated":
			return "Draxos derrotado"
		"timeout":
			return "tempo esgotado"
		"heal_over_time":
			return "cura gradual"
	for prefix: String in ["player_", "opponent_"]:
		if cleaned.begins_with(prefix):
			cleaned = cleaned.substr(prefix.length())
	cleaned = cleaned.replace("-", " ")
	cleaned = cleaned.replace("_", " ")
	return cleaned.capitalize()

static func _number_text(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	return "%.1f" % value

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
