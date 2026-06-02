class_name DraxosArenaSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

func render_selection(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	_call_host(host, "_add_body_text", ["Escolha uma lista de duelos. O loadout trava ao iniciar; buffs e comportamento ficam entre vitorias."])
	if _has_remote_arena_state(arena):
		var arenas := _as_array(arena.get("arenas", []))
		_render_recommended_arena(host, arenas)
		_render_available_arenas(host, arenas)
	else:
		_render_dev_fallback_arenas(host)
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_loadout(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	_call_host(host, "_add_body_text", ["Loadout travado para esta tentativa. Instrumento, habilidades, doutrina, familiar e pocao nao trocam ate a tentativa acabar."])
	_call_host(host, "_add_output_label", [_loadout_summary_text(attempt)])
	_call_host(host, "_add_action_button", ["Continuar com loadout travado", AppShellActionContractScript.ACTION_ARENA_LOCK_LOADOUT])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_active(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	_call_host(host, "_add_body_text", ["Tentativa em andamento. Cada duelo comeca com HP cheio; o loadout segue travado, mas comportamento simples e uso de pocao ainda podem ser ajustados antes do proximo duelo."])
	_call_host(host, "_add_output_label", [_active_attempt_text(attempt)])
	if not _pending_buff_choices(attempt).is_empty():
		_call_host(host, "_add_action_button", ["Escolher buff", AppShellActionContractScript.arena_choose_buff_action(_first_buff_id(attempt))])
	else:
		_call_host(host, "_add_action_button", ["Resolver duelo", AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL])
	_call_host(host, "_add_action_button", ["Ajustar comportamento", AppShellActionContractScript.ACTION_SHOW_PREPARATION])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_buff_choice(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	var choices := _pending_buff_choices(attempt)
	_call_host(host, "_add_body_text", ["Escolha 1 buff temporario para os proximos duelos desta tentativa."])
	if choices.is_empty():
		_call_host(host, "_add_output_label", ["Nenhum buff pendente. Volte para a tentativa ativa."])
		_call_host(host, "_add_action_button", ["Continuar tentativa", AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL])
		return
	_call_host(host, "_add_output_label", [_buff_choices_text(choices)])
	for choice_variant: Variant in choices:
		var choice := _as_dictionary(choice_variant)
		var buff_id := str(choice.get("id", "")).strip_edges()
		if buff_id == "":
			continue
		var label := str(choice.get("display_name", buff_id)).strip_edges()
		_call_host(host, "_add_action_button", ["Escolher %s" % label, AppShellActionContractScript.arena_choose_buff_action(buff_id)])

func render_summary(host: Node) -> void:
	var arena := SessionStore.arena_snapshot()
	var attempt := SessionStore.active_arena_attempt()
	var summary := _as_dictionary(arena.get("summary", attempt.get("summary", {})))
	_call_host(host, "_add_body_text", ["Tentativa encerrada. Quando houve clear, a recompensa ja foi aplicada pelo ultimo duelo; este passo apenas atualiza a Arena."])
	_call_host(host, "_add_output_label", [_summary_text(attempt, summary)])
	_call_host(host, "_add_action_button", ["Continuar na Arena", AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY])
	_call_host(host, "_add_action_button", ["Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE])

func render_replay(host: Node, overlay: Control, compact_layout: bool, battle_log: Dictionary, rewards: Dictionary) -> void:
	var presenter = host.get("_battle_replay_presenter")
	presenter.render_fullscreen_replay(host, overlay, compact_layout, battle_log, rewards)

func _render_available_arenas(host: Node, arenas: Array) -> void:
	if arenas.is_empty():
		_render_dev_fallback_arenas(host)
		return
	var lines := PackedStringArray()
	lines.append("Outras opcoes")
	for arena_variant: Variant in arenas:
		var arena := _as_dictionary(arena_variant)
		var arena_id := str(arena.get("id", "")).strip_edges()
		if arena_id == "":
			continue
		var difficulties := _as_array(arena.get("difficulties", []))
		if difficulties.is_empty():
			difficulties = [arena]
		for difficulty_variant: Variant in difficulties:
			var difficulty := _as_dictionary(difficulty_variant)
			var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
			var label := _arena_button_label(arena, difficulty)
			var action_id := AppShellActionContractScript.arena_start_action(arena_id, difficulty_id)
			var unlocked := _arena_is_unlocked(difficulty) and _arena_is_unlocked(arena)
			var locked_reason := _arena_locked_reason(difficulty if not _arena_is_unlocked(difficulty) else arena)
			if not unlocked:
				label = "%s | bloqueada" % label
			lines.append("- %s: %s duelos | %s | Lv %s | %s" % [
				_short_arena_label(arena),
				str(difficulty.get("max_steps", arena.get("duel_count", 1))),
				_difficulty_label(difficulty),
				_level_range_text(difficulty),
				"disponivel" if unlocked else "bloqueada: %s" % locked_reason,
			])
			_call_host(host, "_add_action_button", [label, action_id, "", not unlocked, locked_reason])
	_call_host(host, "_add_output_label", ["\n".join(lines)])

func _render_recommended_arena(host: Node, arenas: Array) -> void:
	var recommendation := _recommended_arena_option(arenas)
	if recommendation.is_empty():
		return
	var arena := _as_dictionary(recommendation.get("arena", {}))
	var difficulty := _as_dictionary(recommendation.get("difficulty", {}))
	var arena_id := str(arena.get("id", "")).strip_edges()
	var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
	if arena_id == "":
		return
	var label := "Comecar"
	var action_id := AppShellActionContractScript.arena_start_action(arena_id, difficulty_id)
	_call_host(host, "_add_output_label", ["Proximo desafio\n%s\n%s duelo%s | %s | Lv %s | Poder %s" % [
		str(arena.get("display_name", arena_id)),
		str(difficulty.get("max_steps", arena.get("duel_count", 1))),
		"" if int(difficulty.get("max_steps", arena.get("duel_count", 1))) == 1 else "s",
		_difficulty_label(difficulty),
		_level_range_text(difficulty),
		_power_range_text(difficulty),
	]])
	_call_host(host, "_add_action_button", [label, action_id])

func _recommended_arena_option(arenas: Array) -> Dictionary:
	var progress := _as_dictionary(SessionStore.arena_snapshot().get("progress", {}))
	var first_unlocked := {}
	for arena_variant: Variant in arenas:
		var arena := _as_dictionary(arena_variant)
		if not _arena_is_unlocked(arena):
			continue
		var arena_id := str(arena.get("id", "")).strip_edges()
		if arena_id == "":
			continue
		var difficulties := _as_array(arena.get("difficulties", []))
		if difficulties.is_empty():
			difficulties = [arena]
		for difficulty_variant: Variant in difficulties:
			var difficulty := _as_dictionary(difficulty_variant)
			if not _arena_is_unlocked(difficulty):
				continue
			var difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
			var option := {"arena": arena, "difficulty": difficulty}
			if first_unlocked.is_empty():
				first_unlocked = option
			if not _tier_completed(arena_id, difficulty_id, progress):
				return option
	return first_unlocked

func _render_dev_fallback_arenas(host: Node) -> void:
	_call_host(host, "_add_output_label", ["Estado remoto da Arena indisponivel. Fallback dev local: tutorial e arena curta."])
	_call_host(host, "_add_action_button", ["Tutorial 1 duelo", AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL])
	_call_host(host, "_add_action_button", ["Arena inicial 3 duelos", AppShellActionContractScript.ACTION_ARENA_START_EARLY])

func _loadout_summary_text(attempt: Dictionary) -> String:
	var loadout := _as_dictionary(attempt.get("loadout_summary", {}))
	var locked_hash := str(attempt.get("locked_loadout_hash", "")).strip_edges()
	return "Tentativa: %s\nEstado: %s\nLoadout atual: %s\nTravado: %s" % [
		str(attempt.get("attempt_id", "dev")),
		_friendly_attempt_state(_attempt_state(attempt)),
		str(loadout.get("label", "Instrumento, spells, doutrina, familiar e pocao atuais.")),
		"sim" if locked_hash != "" else "pendente",
	]

func _active_attempt_text(attempt: Dictionary) -> String:
	var duels_won := int(attempt.get("duels_won", attempt.get("current_step_index", 0)))
	var next_duel := int(attempt.get("duel_index", duels_won)) + 1
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", 1))))
	var next_enemy := _as_dictionary(attempt.get("next_enemy", {}))
	var buffs := _as_array(attempt.get("temporary_buffs", []))
	var locked_hash := str(attempt.get("locked_loadout_hash", "")).strip_edges()
	var loadout := _as_dictionary(attempt.get("loadout_summary", {}))
	return "Duelo: %d/%d\nEstado: %s\nProximo inimigo: %s\nLoadout: %s\nComportamento: ajustavel entre duelos\nBuffs ativos: %d\nHP: cheio no inicio de cada duelo" % [
		clampi(next_duel, 1, duels_total),
		duels_total,
		_friendly_attempt_state(_attempt_state(attempt)),
		str(next_enemy.get("display_name", attempt.get("next_enemy_id", "pve_aprendiz_cinzas"))),
		str(loadout.get("label", "travado")) if locked_hash != "" else "pendente",
		buffs.size(),
	]

func _buff_choices_text(choices: Array) -> String:
	var lines := PackedStringArray()
	lines.append("Escolhas disponiveis")
	for choice_variant: Variant in choices:
		var choice := _as_dictionary(choice_variant)
		var label := str(choice.get("display_name", choice.get("id", "Buff"))).strip_edges()
		var description := str(choice.get("description", "")).strip_edges()
		if description != "":
			lines.append("- %s: %s" % [label, description])
		else:
			lines.append("- %s" % label)
	return "\n".join(lines)

func _summary_text(attempt: Dictionary, summary: Dictionary) -> String:
	var duels_won := int(summary.get("duels_won", attempt.get("duels_won", 0)))
	var duels_total := maxi(1, int(attempt.get("duel_count", attempt.get("duels_total", summary.get("duels_total", 1)))))
	return "Estado: %s\nDuelos vencidos: %d/%d\nRecompensa: %s\nProximo passo: continuar na Arena ou voltar ao Refugio para evoluir." % [
		_friendly_attempt_state(str(attempt.get("status", summary.get("status", "completed")))),
		clampi(duels_won, 0, duels_total),
		duels_total,
		str(summary.get("reward_label", "recompensa da Arena PVE")),
	]

func _has_remote_arena_state(arena: Dictionary) -> bool:
	return not bool(arena.get("dev_fixture", false)) and not _as_array(arena.get("arenas", [])).is_empty()

func _arena_button_label(arena: Dictionary, difficulty: Dictionary = {}) -> String:
	var tier := difficulty if not difficulty.is_empty() else arena
	return "%s | %s duelo%s | %s" % [
		_short_arena_label(arena),
		str(tier.get("max_steps", arena.get("duel_count", 1))),
		"" if int(tier.get("max_steps", arena.get("duel_count", 1))) == 1 else "s",
		_difficulty_label(tier),
	]

func _short_arena_label(arena: Dictionary) -> String:
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

func _difficulty_label(difficulty: Dictionary) -> String:
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

func _friendly_attempt_state(state: String) -> String:
	match state:
		"active":
			return "em andamento"
		"awaiting_buff":
			return "aguardando buff"
		"completed", "claimed":
			return "concluida"
		"failed":
			return "derrotada"
		"abandoned":
			return "abandonada"
	return state if state != "" else "em andamento"

func _tier_completed(arena_id: String, difficulty_id: String, progress: Dictionary) -> bool:
	if arena_id == "arena_tutorial_cinzas" and bool(progress.get("tutorial_completed", false)):
		return true
	var metadata := _as_dictionary(progress.get("metadata", {}))
	var completed_tiers := _as_dictionary(metadata.get("completed_tiers", {}))
	if difficulty_id != "" and bool(completed_tiers.get("%s:%s" % [arena_id, difficulty_id], false)):
		return true
	if difficulty_id != "":
		return false
	var completed_arenas := _as_dictionary(metadata.get("completed_arenas", {}))
	return bool(completed_arenas.get(arena_id, false))

func _level_range_text(difficulty: Dictionary) -> String:
	var min_level := int(difficulty.get("recommended_level_min", 0))
	var max_level := int(difficulty.get("recommended_level_max", 0))
	if min_level <= 0 and max_level <= 0:
		return "?"
	if min_level == max_level:
		return str(min_level)
	return "%d-%d" % [min_level, max_level]

func _power_range_text(difficulty: Dictionary) -> String:
	var min_power := int(difficulty.get("recommended_power_min", 0))
	var max_power := int(difficulty.get("recommended_power_max", 0))
	if min_power <= 0 and max_power <= 0:
		return "?"
	if min_power == max_power:
		return str(min_power)
	return "%d-%d" % [min_power, max_power]

func _arena_is_unlocked(arena: Dictionary) -> bool:
	if arena.has("unlocked"):
		return bool(arena.get("unlocked", false))
	return bool(arena.get("enabled", true))

func _arena_locked_reason(arena: Dictionary) -> String:
	for key: String in ["locked_reason", "unlock_reason", "blocked_message", "blocked_reason"]:
		var reason := str(arena.get(key, "")).strip_edges()
		if reason != "":
			return reason
	return "Bloqueada."

func _first_buff_id(attempt: Dictionary) -> String:
	for choice_variant: Variant in _pending_buff_choices(attempt):
		var choice := _as_dictionary(choice_variant)
		var buff_id := str(choice.get("id", "")).strip_edges()
		if buff_id != "":
			return buff_id
	return ""

func _attempt_state(attempt: Dictionary) -> String:
	var state := str(attempt.get("state", attempt.get("status", ""))).strip_edges()
	return "active" if state == "" else state

func _pending_buff_choices(attempt: Dictionary) -> Array:
	var offer := _as_dictionary(attempt.get("buff_offer", {}))
	return _as_array(offer.get("choices", attempt.get("pending_buff_choices", [])))

func _call_host(host: Node, method: String, args: Array = []) -> Variant:
	if host == null or not host.has_method(method):
		return null
	return host.callv(method, args)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
