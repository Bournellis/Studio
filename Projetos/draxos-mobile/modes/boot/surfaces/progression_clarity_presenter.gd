class_name DraxosProgressionClarityPresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

static func account_line(combat_build: Dictionary = {}) -> String:
	var parts := PackedStringArray()
	var level := _current_level()
	if level > 0:
		parts.append("Nivel %d" % level)
	var power := _current_power(combat_build)
	if power > 0:
		parts.append("Poder %d" % power)
	if parts.is_empty():
		return "Progresso ainda nao carregado"
	return " | ".join(parts)

static func refuge_progress_line(combat_build: Dictionary = {}) -> String:
	var objective := next_objective_text(combat_build)
	var account := account_line(combat_build)
	if objective == "":
		return account
	return "%s | %s" % [account, objective]

static func preparation_progress_lines(combat_build: Dictionary = {}, max_count: int = 3) -> PackedStringArray:
	return unlock_lines(combat_build, max_count)

static func battle_summary_text(rewards: Dictionary = {}, combat_build: Dictionary = {}) -> String:
	var lines := PackedStringArray()
	lines.append(account_line(combat_build))
	var xp_text := _battle_xp_text(rewards)
	if xp_text != "":
		lines.append(xp_text)
	var unlocks := unlock_lines(combat_build, 1)
	if not unlocks.is_empty():
		lines.append(str(unlocks[0]))
	else:
		lines.append("Volte ao Refugio para planejar o proximo passo.")
	return "\n".join(lines)

static func next_objective_text(combat_build: Dictionary = {}) -> String:
	if SessionStore.has_unseen_battle_result():
		return "Abra a recompensa da ultima batalha."
	if combat_build.is_empty() and SessionStore.combat_build_state.is_empty():
		return "Atualize a preparacao para ver os proximos marcos."
	var lines := unlock_lines(combat_build, 1)
	if not lines.is_empty():
		return str(lines[0])
	if not SessionStore.base_state.is_empty():
		return "Evolua o Refugio para sustentar batalhas mais fortes."
	return "Venca batalhas e ajuste a preparacao para aumentar seu poder."

static func unlock_lines(combat_build: Dictionary = {}, max_count: int = 3) -> PackedStringArray:
	var state := combat_build if not combat_build.is_empty() else SessionStore.combat_build_state
	var current_level := _current_level()
	var candidates := _unlock_candidates_from_state(state)
	for fallback: Dictionary in _fallback_unlock_candidates():
		candidates.append(fallback)
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var level_a := int(a.get("level", 0))
		var level_b := int(b.get("level", 0))
		if level_a == level_b:
			return str(a.get("label", "")) < str(b.get("label", ""))
		return level_a < level_b
	)

	var seen := {}
	var lines := PackedStringArray()
	for candidate_variant: Variant in candidates:
		var candidate := _as_dictionary(candidate_variant)
		var level := int(candidate.get("level", 0))
		if level <= current_level:
			continue
		var label := str(candidate.get("label", "")).strip_edges()
		if label == "":
			continue
		var key := "%d:%s" % [level, label.to_lower()]
		if bool(seen.get(key, false)):
			continue
		seen[key] = true
		lines.append("Nivel %d: %s." % [level, label])
		if lines.size() >= max_count:
			return lines
	if lines.is_empty() and current_level > 0:
		lines.append("Todos os marcos visiveis estao liberados.")
	return lines

static func _unlock_candidates_from_state(combat_build: Dictionary) -> Array:
	var candidates := []
	for slot_variant: Variant in _as_array(combat_build.get("spell_slots", [])):
		var slot := _as_dictionary(slot_variant)
		var unlock_level := int(slot.get("unlock_level", 0))
		if unlock_level <= 0:
			continue
		if bool(slot.get("unlocked", false)):
			continue
		var position := int(slot.get("slot_index", 0))
		var label := "nova habilidade"
		if position > 0:
			label = "habilidade %d da preparacao" % position
		candidates.append({"level": unlock_level, "label": label})

	var options := _as_dictionary(combat_build.get("equipment_options", {}))
	_collect_locked_option_candidates(candidates, _as_array(options.get("spells", [])), "habilidade")
	_collect_locked_option_candidates(candidates, _as_array(options.get("doutrines", [])), "doutrina")
	_collect_locked_option_candidates(candidates, _as_array(options.get("familiars", [])), "familiar")
	return candidates

static func _collect_locked_option_candidates(candidates: Array, options: Array, fallback_label: String) -> void:
	for option_variant: Variant in options:
		var option := _as_dictionary(option_variant)
		if option.is_empty() or bool(option.get("unlocked", true)):
			continue
		var level := int(option.get("unlock_level", 0))
		if level <= 0:
			level = _first_positive_int(str(option.get("locked_reason", "")))
		if level <= 0:
			continue
		var label := str(option.get("display_name", "")).strip_edges()
		if label == "":
			label = _humanize_id(str(option.get("id", fallback_label)))
		candidates.append({"level": level, "label": label})

static func _fallback_unlock_candidates() -> Array:
	return [
		{"level": 3, "label": "primeira habilidade ritual"},
		{"level": 7, "label": "segunda habilidade ritual"},
		{"level": 10, "label": "doutrina de combate"},
		{"level": 15, "label": "familiar de batalha"},
		{"level": 25, "label": "terceira habilidade ritual"},
	]

static func _battle_xp_text(rewards: Dictionary) -> String:
	var resources := _as_dictionary(rewards.get("resources", {}))
	if not resources.has("xp"):
		return ""
	var xp := float(resources.get("xp", 0.0))
	if xp <= 0.0:
		return ""
	if is_equal_approx(xp, roundf(xp)):
		return "Esta batalha somou XP +%d." % int(roundf(xp))
	return "Esta batalha somou XP +%.1f." % xp

static func _current_level() -> int:
	var level := int(SessionStore.player.get("level", 0))
	if level > 0:
		return level
	level = int(SessionStore.combat_build_state.get("level", 0))
	if level > 0:
		return level
	return int(SessionStore.build.get("level", 0))

static func _current_power(combat_build: Dictionary = {}) -> int:
	var power := int(combat_build.get("power", 0))
	if power > 0:
		return power
	power = int(SessionStore.combat_build_state.get("power", 0))
	if power > 0:
		return power
	return int(SessionStore.player.get("power", 0))

static func _first_positive_int(text: String) -> int:
	var digits := ""
	for index in range(text.length()):
		var character := text.substr(index, 1)
		if character >= "0" and character <= "9":
			digits += character
		elif digits != "":
			break
	if digits == "":
		return 0
	return int(digits)

static func _humanize_id(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned == "":
		return ""
	if cleaned == AppShellActionContractScript.ITEM_HEALTH_POTION:
		return "Pocao de Vida"
	cleaned = cleaned.replace("-", " ")
	cleaned = cleaned.replace("_", " ")
	return cleaned.capitalize()

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
