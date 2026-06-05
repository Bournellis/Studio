class_name DraxosArenaSurfaceText
extends RefCounted

static func duel_progress_text(attempt: Dictionary) -> String:
	var duels_won := clampi(int(attempt.get("duels_won", attempt.get("current_step_index", 0))), 0, 99)
	var duel_index := int(attempt.get("duel_index", duels_won))
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", 1))))
	var state := attempt_state(attempt)
	var current_duel := clampi(duel_index + 1, 1, duels_total)
	if state in ["completed", "claimed"]:
		current_duel = duels_total
	var nodes := PackedStringArray()
	for index in range(1, duels_total + 1):
		if index <= duels_won:
			nodes.append("[%d ganho]" % index)
		elif state in ["completed", "claimed"] and index <= duels_total:
			nodes.append("[%d ganho]" % index)
		elif state == "failed" and index == current_duel:
			nodes.append("[%d queda]" % index)
		elif index == current_duel:
			nodes.append("[%d agora]" % index)
		else:
			nodes.append("[%d espera]" % index)
	return "Progresso dos duelos\n%s\nVencidos: %d/%d" % [
		" -> ".join(nodes),
		clampi(duels_won, 0, duels_total),
		duels_total,
	]

static func duel_progress_step_tooltip(index: int, step_state: String) -> String:
	match step_state:
		"won":
			return "Duelo %d vencido" % index
		"failed":
			return "Duelo %d encerrou a tentativa" % index
		"current":
			return "Duelo %d pronto" % index
	return "Duelo %d aguardando" % index

static func buff_effect_text(choice: Dictionary) -> String:
	var description := str(choice.get("description", "")).strip_edges()
	if description != "":
		return description
	var modifiers := as_array(choice.get("stat_modifiers", []))
	if not modifiers.is_empty():
		var parts := PackedStringArray()
		for modifier_variant: Variant in modifiers:
			var modifier := as_dictionary(modifier_variant)
			var stat := humanize_id(str(modifier.get("stat", modifier.get("stat_id", ""))))
			var amount := str(modifier.get("amount", modifier.get("value", ""))).strip_edges()
			if stat != "" and amount != "":
				parts.append("%s %s" % [stat, amount])
		if not parts.is_empty():
			return ", ".join(parts)
	return "Melhora um atributo da Arena."

static func loadout_locked_summary_text(attempt: Dictionary) -> String:
	var locked_hash := str(attempt.get("locked_loadout_hash", "")).strip_edges()
	var loadout := as_dictionary(attempt.get("loadout_summary", {}))
	return "Resumo: %s\nTravado: %s" % [
		str(loadout.get("label", "Instrumento, habilidades, doutrina, familiar e pocao atuais.")),
		"sim" if locked_hash != "" else "pendente",
	]

static func loadout_details_text(attempt: Dictionary) -> String:
	var loadout := as_dictionary(attempt.get("loadout_summary", {}))
	var lines := PackedStringArray()
	lines.append("Detalhes somente leitura")
	lines.append("- Resumo: %s" % str(loadout.get("label", "Loadout travado no servidor.")))
	for spec in [
		["instrument", "Instrumento"],
		["weapon", "Instrumento"],
		["spells", "Habilidades"],
		["doctrine", "Doutrina"],
		["familiar", "Familiar"],
		["potion", "Pocao"],
		["behavior", "Comportamento"],
	]:
		var key := str(spec[0])
		if not loadout.has(key):
			continue
		lines.append("- %s: %s" % [str(spec[1]), loadout_value_text(loadout.get(key))])
	return "\n".join(lines)

static func loadout_value_text(value: Variant) -> String:
	if value is Array:
		var parts := PackedStringArray()
		for entry: Variant in Array(value):
			var label := loadout_value_text(entry)
			if label != "":
				parts.append(label)
		return ", ".join(parts)
	if value is Dictionary:
		var data := Dictionary(value)
		for key in ["display_name", "name", "label", "item_name", "spell_name"]:
			var label := str(data.get(key, "")).strip_edges()
			if label != "":
				return label
		for key in ["id", "item_id", "spell_id", "potion_id", "weapon_id", "instrument_id", "doctrine_id", "familiar_id"]:
			var id_value := str(data.get(key, "")).strip_edges()
			if id_value != "":
				return humanize_id(id_value)
		return "configurado"
	return humanize_id(str(value))

static func humanize_id(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned == "" or cleaned == "<null>" or cleaned.to_lower() == "null":
		return "Nao definido"
	cleaned = cleaned.replace("-", " ")
	cleaned = cleaned.replace("_", " ")
	return cleaned.capitalize()

static func next_enemy_label(attempt: Dictionary) -> String:
	var next_enemy := as_dictionary(attempt.get("next_enemy", {}))
	for value: Variant in [
		next_enemy.get("display_name", ""),
		next_enemy.get("name", ""),
		next_enemy.get("id", ""),
		attempt.get("next_enemy_id", ""),
	]:
		var label := str(value).strip_edges()
		if label != "":
			return label
	return "proximo bot da Arena"

static func summary_text(attempt: Dictionary, summary: Dictionary) -> String:
	var duels_won := int(summary.get("duels_won", attempt.get("duels_won", 0)))
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", summary.get("duels_total", 1)))))
	return "Estado: %s\nDuelos vencidos: %d/%d\nRecompensa: %s\nProximo passo: continuar na Arena ou voltar ao Refugio para evoluir." % [
		friendly_attempt_state(str(attempt.get("status", summary.get("status", "completed")))),
		clampi(duels_won, 0, duels_total),
		duels_total,
		str(summary.get("reward_label", "recompensa da Arena PVE")),
	]

static func arena_button_label(arena: Dictionary, difficulty: Dictionary = {}) -> String:
	var tier := difficulty if not difficulty.is_empty() else arena
	return "%s | %s duelo%s | %s" % [
		short_arena_label(arena),
		str(tier.get("max_steps", arena.get("duel_count", 1))),
		"" if int(tier.get("max_steps", arena.get("duel_count", 1))) == 1 else "s",
		difficulty_label(tier),
	]

static func short_arena_label(arena: Dictionary) -> String:
	var arena_id := str(arena.get("id", "")).strip_edges()
	var display_name := str(arena.get("display_name", arena_id)).strip_edges()
	match arena_id:
		"arena_tutorial_cinzas":
			return "Tutorial"
		"arena_cinzas_curta":
			return "Cinzas"
		"arena_veu_curta":
			return "Veu"
		"arena_ossos_media":
			return "Ossos"
		"arena_abismo_longa":
			return "Abismo"
	return display_name

static func difficulty_label(difficulty: Dictionary) -> String:
	var display_name := str(difficulty.get("display_name", "")).strip_edges()
	if display_name != "":
		return display_name
	var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", "default"))).strip_edges()
	match difficulty_id:
		"s1_d00_intro":
			return "Intro"
		"s1_d01_aprendiz":
			return "Aprendiz"
		"s1_d02_iniciado":
			return "Iniciado"
		"s1_d03_adepto":
			return "Adepto"
		"s1_d04_veterano":
			return "Veterano"
	if difficulty_id.begins_with("s1_d"):
		return difficulty_id.get_slice("_", difficulty_id.get_slice_count("_") - 1).capitalize()
	return difficulty_id

static func friendly_attempt_state(state: String) -> String:
	match state:
		"active":
			return "em andamento"
		"active_incompatible":
			return "precisa encerrar"
		"awaiting_buff":
			return "aguardando buff"
		"completed", "claimed":
			return "concluida"
		"failed":
			return "derrotada"
		"abandoned":
			return "abandonada"
	return state if state != "" else "em andamento"

static func level_range_text(difficulty: Dictionary) -> String:
	var min_level := int(difficulty.get("recommended_level_min", 0))
	var max_level := int(difficulty.get("recommended_level_max", 0))
	if min_level <= 0 and max_level <= 0:
		return "?"
	if min_level == max_level:
		return str(min_level)
	return "%d-%d" % [min_level, max_level]

static func power_range_text(difficulty: Dictionary) -> String:
	var min_power := int(difficulty.get("recommended_power_min", 0))
	var max_power := int(difficulty.get("recommended_power_max", 0))
	if min_power <= 0 and max_power <= 0:
		return "?"
	if min_power == max_power:
		return str(min_power)
	return "%d-%d" % [min_power, max_power]

static func arena_locked_reason(arena: Dictionary) -> String:
	for key: String in ["locked_reason", "unlock_reason", "blocked_message", "blocked_reason"]:
		var reason := str(arena.get(key, "")).strip_edges()
		if reason != "":
			return reason
	return "Bloqueada."

static func attempt_state(attempt: Dictionary) -> String:
	var state := str(attempt.get("state", attempt.get("status", ""))).strip_edges()
	return "active" if state == "" else state

static func as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
