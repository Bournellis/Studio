class_name DraxosArenaLifecycleFlow
extends RefCounted

const ProjectInfoScript := preload("res://core/project_info.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

const ARENA_REPLAY_TICK_SECONDS := 0.05
const TUTORIAL_ARENA_ID := "arena_tutorial_cinzas"
const EARLY_ARENA_ID := "arena_cinzas_curta"
const TUTORIAL_DIFFICULTY_TIER := 0
const EARLY_DIFFICULTY_TIER := 1

func render_selection(host: Node) -> void:
	host.get("_arena_surface_presenter").render_selection(host)

func render_loadout(host: Node) -> void:
	host.get("_arena_surface_presenter").render_loadout(host)

func render_active(host: Node) -> void:
	host.get("_arena_surface_presenter").render_active(host)

func render_replay(host: Node) -> void:
	var overlay := host.call("_create_battle_fullscreen_overlay") as Control
	var last_duel := _as_dictionary(SessionStore.arena_snapshot().get("last_duel", {}))
	var battle_log := _as_dictionary(last_duel.get("battle_log", {}))
	var rewards := _as_dictionary(last_duel.get("rewards", {}))
	host.get("_arena_surface_presenter").render_replay(
		host,
		overlay,
		bool(host.get("_compact_layout")),
		battle_log,
		rewards
	)

func render_buff_choice(host: Node) -> void:
	host.get("_arena_surface_presenter").render_buff_choice(host)

func render_summary(host: Node) -> void:
	host.get("_arena_surface_presenter").render_summary(host)

func open_arena(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre antes de abrir a Arena PVE.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	host.call("_set_busy", true, "Carregando Arena PVE...")
	var state_result: Dictionary = await SupabaseClient.fetch_arena_state(SessionStore.access_token)
	if not bool(state_result.get("ok", false)) and _dev_fixtures_enabled():
		state_result = _fixture_result(_base_arena_state())
	if not bool(state_result.get("ok", false)):
		host.call("_fail_with_error", state_result)
		return
	if not SessionStore.apply_arena_result(state_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return
	SessionStore.save_cache()
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	host.call("_set_busy", false, "Arena PVE carregada.")

func start_tutorial(host: Node) -> void:
	await _start_attempt(host, TUTORIAL_ARENA_ID, "s1_d00_intro", TUTORIAL_DIFFICULTY_TIER)

func start_early(host: Node) -> void:
	await _start_attempt(host, EARLY_ARENA_ID, "s1_d00_intro", EARLY_DIFFICULTY_TIER)

func start_arena(host: Node, arena_id: String, difficulty_id: String = "") -> void:
	var normalized_id := arena_id.strip_edges()
	if normalized_id == "":
		_set_error_text(host, "Arena invalida.")
		return
	var arena := SessionStore.arena_by_id(normalized_id)
	if arena.is_empty():
		_set_error_text(host, "Arena nao encontrada no estado atual.")
		return
	if not _arena_is_unlocked(arena):
		_set_error_text(host, "Arena bloqueada: %s" % _arena_locked_reason(arena))
		return
	var difficulty := SessionStore.arena_difficulty_by_id(normalized_id, difficulty_id)
	if difficulty.is_empty():
		_set_error_text(host, "Dificuldade de Arena nao encontrada.")
		return
	if not _arena_is_unlocked(difficulty):
		_set_error_text(host, "Dificuldade bloqueada: %s" % _arena_locked_reason(difficulty))
		return
	var normalized_difficulty_id := str(difficulty.get("difficulty_id", difficulty.get("id", ""))).strip_edges()
	var difficulty_tier := int(difficulty.get("difficulty_tier", difficulty.get("difficulty_rank", arena.get("difficulty_tier", 0))))
	await _start_attempt(
		host,
		normalized_id,
		normalized_difficulty_id,
		difficulty_tier,
		AppShellActionContractScript.arena_start_action(normalized_id, normalized_difficulty_id)
	)

func lock_loadout(host: Node) -> void:
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		_set_error_text(host, "Nenhuma tentativa de Arena carregada.")
		return
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, false)
	host.call("_show_notice", "Loadout ja foi travado ao iniciar a tentativa.")

func resolve_duel(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre antes de resolver duelo da Arena.")):
		return
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		_set_error_text(host, "Nenhuma tentativa de Arena carregada.")
		return
	var duel_index := int(attempt.get("current_step_index", attempt.get("duel_index", 0))) + 1

	host.call("_set_busy", true, "Resolvendo duelo...")
	var mutation := SessionStore.prepare_pending_mutation(
		"arena/pve/duel/request",
		"arena:%s" % SessionStore.active_save_type,
		AppShellActionContractScript.ACTION_ARENA_RESOLVE_DUEL,
		{"attempt_id": attempt_id}
	)
	var result: Dictionary = await SupabaseClient.resolve_arena_duel(
		str(mutation.get("request_id", "")),
		attempt_id,
		SessionStore.access_token,
		str(mutation.get("request_hash", ""))
	)
	if not bool(result.get("ok", false)) and _dev_fixtures_enabled():
		result = _fixture_result(_fixture_resolve_duel(attempt, duel_index))
	if not await _complete_arena_mutation(host, mutation, result, "", "Duelo resolvido."):
		return
	var last_duel := _as_dictionary(SessionStore.arena_snapshot().get("last_duel", {}))
	await play_arena_replay(host, _as_dictionary(last_duel.get("battle_log", {})), _as_dictionary(last_duel.get("rewards", {})))

func choose_buff(host: Node, buff_id: String) -> void:
	if not bool(host.call("_require_account", "Entre antes de escolher buff da Arena.")):
		return
	var normalized_buff := buff_id.strip_edges()
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "" or normalized_buff == "":
		_set_error_text(host, "Buff ou tentativa invalida.")
		return

	host.call("_set_busy", true, "Aplicando buff temporario...")
	var step_index := _current_offer_step_index(attempt)
	var mutation := SessionStore.prepare_pending_mutation(
		"arena/pve/buff/select",
		"arena:%s" % SessionStore.active_save_type,
		AppShellActionContractScript.arena_choose_buff_action(normalized_buff),
		{"attempt_id": attempt_id, "step_index": step_index, "buff_id": normalized_buff}
	)
	var result: Dictionary = await SupabaseClient.choose_arena_buff(
		str(mutation.get("request_id", "")),
		attempt_id,
		step_index,
		normalized_buff,
		SessionStore.access_token,
		str(mutation.get("request_hash", ""))
	)
	if not bool(result.get("ok", false)) and _dev_fixtures_enabled():
		result = _fixture_result(_fixture_choose_buff(attempt, normalized_buff))
	await _complete_arena_mutation(host, mutation, result, AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, "Buff aplicado.")

func claim_summary(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre antes de receber recompensa da Arena.")):
		return
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		_set_error_text(host, "Nenhuma tentativa de Arena para concluir.")
		return

	host.call("_set_busy", true, "Recebendo recompensa...")
	var mutation := SessionStore.prepare_pending_mutation(
		"arena/pve/claim",
		"arena:%s" % SessionStore.active_save_type,
		AppShellActionContractScript.ACTION_ARENA_CLAIM_SUMMARY,
		{"attempt_id": attempt_id}
	)
	var result: Dictionary = await SupabaseClient.claim_arena_summary(
		str(mutation.get("request_id", "")),
		attempt_id,
		SessionStore.access_token,
		str(mutation.get("request_hash", ""))
	)
	if not bool(result.get("ok", false)) and _dev_fixtures_enabled():
		result = _fixture_result(_fixture_claim_summary(attempt))
	if not await _complete_arena_mutation(host, mutation, result, "", "Recompensa recebida."):
		return
	host.call("_show_refuge_root", "Arena PVE concluida. Use recursos para evoluir base e build.")

func play_arena_replay(host: Node, battle_log: Dictionary, rewards: Dictionary) -> void:
	if str(battle_log.get("schema_version", "")) != "battle_log_v1":
		_set_error_text(host, "Arena PVE nao retornou replay valido.")
		host.call("_show_screen", _next_arena_route_after_replay(), false)
		return

	_set_error_text(host, "")
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_REPLAY, false)
	host.set("_replay_running", true)
	host.set("_skip_replay", false)
	host.call("_set_busy", false, "Apresentando duelo da Arena...")
	host.call("_sync_buttons")

	var presenter = host.get("_battle_replay_presenter")
	presenter.begin_replay(battle_log, rewards)
	var events: Array[Dictionary] = presenter.sorted_events(battle_log)
	var replay_time := 0.0
	for event: Dictionary in events:
		if bool(host.get("_skip_replay")):
			break
		var event_time := maxf(replay_time, float(event.get("t", replay_time)))
		while replay_time + 0.001 < event_time:
			if bool(host.get("_skip_replay")):
				break
			var tick := minf(ARENA_REPLAY_TICK_SECONDS, event_time - replay_time)
			replay_time += tick
			presenter.set_replay_time(replay_time)
			await host.get_tree().create_timer(tick).timeout
		if bool(host.get("_skip_replay")):
			break
		presenter.set_replay_time(event_time)
		presenter.append_event(event)
		replay_time = event_time
		await host.get_tree().process_frame

	if bool(host.get("_skip_replay")):
		presenter.reveal_all_events(events)
	presenter.reveal_all()
	host.set("_replay_running", false)
	host.set("_skip_replay", false)
	host.call("_show_screen", _next_arena_route_after_replay(), false)
	host.call("_set_busy", false, "Duelo da Arena concluido.")
	host.call("_sync_buttons")

func _start_attempt(host: Node, arena_id: String, difficulty_id: String, difficulty_tier: int, action_id: String = "") -> void:
	if not bool(host.call("_require_account", "Entre antes de iniciar a Arena PVE.")):
		return
	host.call("_set_busy", true, "Iniciando Arena PVE...")
	var start_action_id := action_id.strip_edges()
	if start_action_id == "":
		start_action_id = AppShellActionContractScript.ACTION_ARENA_START_TUTORIAL if arena_id == TUTORIAL_ARENA_ID else AppShellActionContractScript.ACTION_ARENA_START_EARLY
	var mutation := SessionStore.prepare_pending_mutation(
		"arena/pve/start",
		"arena:%s" % SessionStore.active_save_type,
		start_action_id,
		{"arena_id": arena_id, "difficulty_id": difficulty_id, "difficulty_tier": difficulty_tier}
	)
	var result: Dictionary = await SupabaseClient.start_arena_attempt(
		str(mutation.get("request_id", "")),
		arena_id,
		difficulty_id,
		difficulty_tier,
		SessionStore.access_token,
		str(mutation.get("request_hash", ""))
	)
	if not bool(result.get("ok", false)) and _dev_fixtures_enabled():
		result = _fixture_attempt_result(_fixture_start_attempt(arena_id, difficulty_id, difficulty_tier))
	await _complete_arena_mutation(host, mutation, result, AppShellRouteContractScript.ROUTE_ARENA_LOADOUT, "Arena iniciada.")

func _complete_arena_mutation(host: Node, mutation: Dictionary, result: Dictionary, route_after_success: String, success_text: String) -> bool:
	if not bool(result.get("ok", false)):
		SessionStore.fail_pending_mutation(str(mutation.get("request_id", "")), result)
		host.call("_fail_with_error", result)
		return false
	if not SessionStore.apply_arena_result(result):
		SessionStore.fail_pending_mutation(str(mutation.get("request_id", "")), {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return false
	SessionStore.complete_pending_mutation(str(mutation.get("request_id", "")), result)
	SessionStore.save_cache()
	if route_after_success != "":
		host.call("_show_screen", route_after_success, false)
	host.call("_set_busy", false, success_text)
	return true

func _next_arena_route_after_replay() -> String:
	var attempt := SessionStore.active_arena_attempt()
	if not _pending_buff_choices(attempt).is_empty():
		return AppShellRouteContractScript.ROUTE_ARENA_BUFF_CHOICE
	var status := _attempt_state(attempt)
	if status in ["completed", "failed", "claimed", "abandoned"]:
		return AppShellRouteContractScript.ROUTE_ARENA_SUMMARY
	return AppShellRouteContractScript.ROUTE_ARENA_ACTIVE

func _dev_fixtures_enabled() -> bool:
	return OS.has_feature("editor") or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/dev_tools_enabled", false))

func _base_arena_state() -> Dictionary:
	return {
		"ok": true,
		"schema_version": "pve_arena_state_v1",
		"dev_fixture": true,
		"arenas": [
			{"id": TUTORIAL_ARENA_ID, "display_name": "Tutorial: Cinzas Do Refugio", "difficulty_tier": 0, "duel_count": 1, "enabled": true, "unlocked": true},
			{"id": EARLY_ARENA_ID, "display_name": "Arena Curta Das Cinzas", "difficulty_tier": 1, "duel_count": 3, "enabled": true, "unlocked": true},
		],
		"active_attempt": null,
		"records": [],
		"reward_limits": {"daily_key": "dev", "weekly_key": "dev"},
		"summary": {},
	}

func _fixture_start_attempt(arena_id: String, difficulty_id: String, difficulty_tier: int) -> Dictionary:
	var duels_total := 1 if arena_id == TUTORIAL_ARENA_ID else 3
	return {
		"attempt_id": "dev-%s-%d" % [arena_id, difficulty_tier],
		"arena_id": arena_id,
		"difficulty_id": difficulty_id,
		"difficulty_tier": difficulty_tier,
		"current_step_index": 0,
		"duel_index": 0,
		"duel_count": duels_total,
		"state": "active",
		"locked_loadout_hash": "sha256:dev-loadout",
		"next_enemy_id": _enemy_id_for_duel(1),
		"duels_won": 0,
		"loadout_summary": {"label": _current_loadout_label()},
		"next_enemy": _enemy_for_duel(1),
		"temporary_buffs": [],
		"buff_offer": {},
	}

func _fixture_lock_loadout(attempt: Dictionary) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	next_attempt["state"] = "active"
	if not next_attempt.has("loadout_summary"):
		next_attempt["loadout_summary"] = {"label": _current_loadout_label()}
	state["active_attempt"] = next_attempt
	return state

func _fixture_resolve_duel(attempt: Dictionary, duel_index: int) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	var duels_total := maxi(1, int(next_attempt.get("duel_count", next_attempt.get("duels_total", 1))))
	var won := mini(duel_index, duels_total)
	next_attempt["duels_won"] = won
	next_attempt["current_step_index"] = won
	next_attempt["last_completed_duel_index"] = duel_index
	next_attempt["duel_index"] = won
	next_attempt["next_enemy_id"] = _enemy_id_for_duel(mini(won + 1, duels_total))
	next_attempt["next_enemy"] = _enemy_for_duel(mini(won + 1, duels_total))
	if won >= duels_total:
		next_attempt["state"] = "completed"
		next_attempt["buff_offer"] = {}
		next_attempt["summary"] = _summary_for_attempt(next_attempt, 1.0)
	else:
		next_attempt["state"] = "awaiting_buff"
		next_attempt["buff_offer"] = _buff_offer_for_duel(duel_index)
	state["active_attempt"] = next_attempt
	state["last_duel"] = {
		"duel_index": duel_index,
		"battle_log": _fixture_battle_log(next_attempt, duel_index),
		"rewards": {"type": "ARENA_PVE_DEV_FIXTURE", "resources": {"xp": 12, "ossos": 2}},
	}
	state["summary"] = _as_dictionary(next_attempt.get("summary", {}))
	return state

func _fixture_choose_buff(attempt: Dictionary, buff_id: String) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	var buffs := _as_array(next_attempt.get("temporary_buffs", []))
	var chosen := _buff_by_id(_pending_buff_choices(next_attempt), buff_id)
	if chosen.is_empty():
		chosen = {"id": buff_id, "display_name": buff_id}
	buffs.append(chosen)
	next_attempt["temporary_buffs"] = buffs
	next_attempt["buff_offer"] = {}
	next_attempt["state"] = "active"
	next_attempt["next_enemy"] = _enemy_for_duel(int(next_attempt.get("current_step_index", next_attempt.get("duel_index", 0))) + 1)
	state["active_attempt"] = next_attempt
	return state

func _fixture_claim_summary(attempt: Dictionary) -> Dictionary:
	var state := _base_arena_state()
	var next_attempt := attempt.duplicate(true)
	next_attempt["state"] = "claimed"
	var summary := _summary_for_attempt(next_attempt, 1.0)
	summary["claimed"] = true
	summary["reward_already_applied"] = true
	summary["mutates_economy"] = false
	next_attempt["summary"] = summary
	state["active_attempt"] = next_attempt
	state["summary"] = summary
	return state

func _fixture_result(state: Dictionary) -> Dictionary:
	return {
		"ok": true,
		"_client": {"save_type": SessionStore.active_save_type},
		"body": {
			"ok": true,
			"arena_state": state,
			"dev_fixture": true,
		},
	}

func _fixture_attempt_result(attempt: Dictionary) -> Dictionary:
	return {
		"ok": true,
		"_client": {"save_type": SessionStore.active_save_type},
		"body": {
			"ok": true,
			"schema_version": "pve_arena_attempt_v1",
			"attempt": attempt,
			"dev_fixture": true,
		},
	}

func _fixture_battle_log(attempt: Dictionary, duel_index: int) -> Dictionary:
	var enemy := _enemy_for_duel(duel_index)
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "%s-duel-%d" % [str(attempt.get("attempt_id", "arena-dev")), duel_index],
		"seed": "arena-dev-%d" % duel_index,
		"mode": ProjectInfoScript.FIRST_SLICE_MODE,
		"duration": 12.0,
		"participants": {
			"player": {"id": "player", "display_name": SessionStore.player_display_name()},
			"opponent": {"id": str(enemy.get("id", "arena_enemy")), "display_name": str(enemy.get("display_name", "Inimigo PVE")), "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 1.0, "seq": 2, "type": "weapon_attack", "source": "player", "target": "opponent", "damage": 12, "hp_after": 34},
			{"t": 2.0, "seq": 3, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
		"metadata": {
			"mode": "PVE_ARENA_V1",
			"attempt_id": str(attempt.get("attempt_id", "")),
			"arena_id": str(attempt.get("arena_id", "")),
			"difficulty_tier": int(attempt.get("difficulty_tier", 0)),
			"duel_index": duel_index,
			"duel_count": int(attempt.get("duel_count", attempt.get("duels_total", 1))),
			"enemy_id": str(enemy.get("id", "pve_aprendiz_cinzas")),
			"temporary_buffs": _as_array(attempt.get("temporary_buffs", [])),
			"locked_loadout_hash": str(attempt.get("locked_loadout_hash", "sha256:dev-loadout")),
			"hp_reset": true,
		},
	}

func _current_loadout_label() -> String:
	var combat := SessionStore.combat_build_snapshot()
	if combat.is_empty():
		return "Build atual do save ativo."
	return "%s | %s spells | pocao %s" % [
		str(combat.get("weapon_id", combat.get("weapon_type", "Instrumento"))),
		_as_array(combat.get("spell_slots", combat.get("spellIds", []))).size(),
		"equipada" if not _as_array(combat.get("potion_slots", [])).is_empty() else "pendente",
	]

func _enemy_for_duel(duel_index: int) -> Dictionary:
	var enemies := [
		{"id": "pve_aprendiz_cinzas", "display_name": "Aprendiz Das Cinzas", "archetype": "starter_instrument"},
		{"id": "pve_guardiao_barreira", "display_name": "Guardiao De Barreira", "archetype": "defensive_occultist"},
		{"id": "pve_sussurrador_veu", "display_name": "Sussurrador Do Veu", "archetype": "mental_controller"},
	]
	return Dictionary(enemies[clampi(duel_index - 1, 0, enemies.size() - 1)]).duplicate(true)

func _enemy_id_for_duel(duel_index: int) -> String:
	return str(_enemy_for_duel(duel_index).get("id", "pve_aprendiz_cinzas"))

func _buff_offer_for_duel(duel_index: int) -> Dictionary:
	return {
		"offer_id": "dev-offer-%d" % duel_index,
		"after_duel_index": duel_index,
		"choices": [
			{"id": "arena_buff_vitalidade_menor", "display_name": "Vitalidade Menor", "description": "+4% HP maximo"},
			{"id": "arena_buff_potencia_menor", "display_name": "Potencia Ritual Menor", "description": "+4% Potencia Ritual"},
			{"id": "arena_buff_guarda_menor", "display_name": "Guarda Menor", "description": "+4% Guarda"},
		],
	}

func _buff_by_id(choices: Array, buff_id: String) -> Dictionary:
	for choice_variant: Variant in choices:
		var choice := _as_dictionary(choice_variant)
		if str(choice.get("id", "")) == buff_id:
			return choice.duplicate(true)
	return {}

func _summary_for_attempt(attempt: Dictionary, clear_rate: float) -> Dictionary:
	return {
		"status": _attempt_state(attempt),
		"duels_won": int(attempt.get("duels_won", 0)),
		"duels_total": int(attempt.get("duel_count", attempt.get("duels_total", 1))),
		"clear_rate": clear_rate,
		"repeat_factor": 0.65,
		"reward_label": "XP, Ossos e recursos calibraveis da Arena PVE",
		"reward_already_applied": true,
		"mutates_economy": false,
	}

func _attempt_state(attempt: Dictionary) -> String:
	var state := str(attempt.get("state", attempt.get("status", ""))).strip_edges()
	return "active" if state == "" else state

func _attempt_id(attempt: Dictionary) -> String:
	return str(attempt.get("attempt_id", attempt.get("id", ""))).strip_edges()

func _current_offer_step_index(attempt: Dictionary) -> int:
	var offer := _as_dictionary(attempt.get("buff_offer", {}))
	return maxi(1, int(offer.get("step_index", offer.get("after_duel_index", attempt.get("current_step_index", 1)))))

func _pending_buff_choices(attempt: Dictionary) -> Array:
	var offer := _as_dictionary(attempt.get("buff_offer", {}))
	return _as_array(offer.get("choices", attempt.get("pending_buff_choices", [])))

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

func _set_error_text(host: Node, text: String) -> void:
	var label := host.get("_error_label") as Label
	if label != null:
		label.text = text

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
