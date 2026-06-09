class_name DraxosArenaLifecycleFlow
extends RefCounted

const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const ArenaDevFixtureProviderScript := preload("res://modes/boot/flows/arena_dev_fixture_provider.gd")

const ARENA_REPLAY_TICK_SECONDS := 0.05
const TUTORIAL_ARENA_ID := "arena_tutorial_cinzas"
const EARLY_ARENA_ID := "arena_cinzas_curta"
const TUTORIAL_DIFFICULTY_TIER := 0
const EARLY_DIFFICULTY_TIER := 0

func render_selection(host: Node) -> void:
	host.get("_arena_surface_presenter").render_selection(host)

func render_loading_selection(host: Node) -> void:
	_render_selection_loading_shell(host)

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

	var push_from_mode_shell := str(host.get("_current_screen")) == AppShellRouteContractScript.ROUTE_MODE_SHELL
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, push_from_mode_shell)
	var rendered_from_cache := SessionStore.has_surface_snapshot(SessionStore.SURFACE_ARENA)
	if rendered_from_cache:
		render_selection(host)
		host.call("_show_notice", "Arena em cache visivel. Atualizando com o servidor...")
	else:
		_render_selection_loading_shell(host)
	var refresh_token: Dictionary = host.call(
		"_begin_surface_refresh",
		SessionStore.SURFACE_ARENA,
		"arena/pve/state",
		"Carregando Arena PVE...",
		rendered_from_cache
	)
	if not rendered_from_cache:
		host.call("_show_notice", "Arena local visivel. Sincronizando com o servidor...")
	var state_result: Dictionary = await SupabaseClient.fetch_arena_state(SessionStore.access_token)
	state_result = ArenaDevFixtureProviderScript.state_fallback_result(state_result, SessionStore.active_save_type)
	if not bool(state_result.get("ok", false)):
		host.call("_fail_surface_refresh", SessionStore.SURFACE_ARENA, refresh_token, state_result)
		if rendered_from_cache:
			render_selection(host)
			host.call("_show_notice", "Arena exibindo cache local; servidor nao respondeu agora.")
			return
		host.call("_fail_with_error", state_result)
		return
	if not bool(host.call("_surface_refresh_current", SessionStore.SURFACE_ARENA, refresh_token)):
		host.call("_ignore_stale_surface_refresh", SessionStore.SURFACE_ARENA, refresh_token, "Resposta antiga da Arena ignorada.")
		return
	if not SessionStore.apply_arena_result(state_result):
		host.call("_fail_surface_refresh", SessionStore.SURFACE_ARENA, refresh_token, {"error": SessionStore.last_error})
		if rendered_from_cache:
			render_selection(host)
			host.call("_show_notice", "Arena exibindo cache local; resposta do servidor veio incompleta.")
			return
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return
	SessionStore.save_cache()
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	host.call("_finish_surface_refresh", SessionStore.SURFACE_ARENA, refresh_token, state_result, "Arena PVE carregada.")

func _render_selection_loading_shell(host: Node) -> void:
	host.call("_clear_content_body")
	host.call("_reset_action_group")
	var action_buttons: Dictionary = host.get("_action_buttons")
	action_buttons.clear()
	host.get("_arena_surface_presenter").render_loading_selection(host)

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

func resume_attempt(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre antes de retomar a Arena PVE.")):
		return
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
		host.call("_show_notice", "Nenhuma tentativa ativa encontrada. Escolha uma Arena PVE.")
		return
	if _attempt_needs_recovery(attempt):
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
		host.call("_show_notice", "Esta tentativa ficou aberta antes do update. Encerre a tentativa antiga para liberar uma nova run.")
		return
	if not _pending_buff_choices(attempt).is_empty():
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_BUFF_CHOICE, false)
		host.call("_show_notice", "Buff pendente carregado. Escolha uma opcao para seguir.")
		return
	var status := _attempt_state(attempt)
	if status in ["completed", "failed", "claimed", "abandoned"]:
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SUMMARY, false)
		return
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, false)
	host.call("_show_notice", "Tentativa de Arena retomada.")

func resolve_duel(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre antes de resolver duelo da Arena.")):
		return
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		_set_error_text(host, "Nenhuma tentativa de Arena carregada.")
		return
	if _attempt_needs_recovery(attempt):
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
		_set_error_text(host, "Tentativa antiga detectada. Encerre esta tentativa para liberar a Arena.")
		return
	var duel_index := int(attempt.get("current_step_index", attempt.get("duel_index", 0))) + 1

	host.call("_set_busy", true, "Resolvendo duelo no servidor...")
	host.call("_show_notice", "Aguardando resultado autoritativo do servidor para iniciar o replay.")
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
	result = ArenaDevFixtureProviderScript.resolve_duel_fallback_result(result, attempt, duel_index, SessionStore)
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
	result = ArenaDevFixtureProviderScript.choose_buff_fallback_result(result, attempt, normalized_buff, SessionStore)
	await _complete_arena_mutation(host, mutation, result, AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, "Buff aplicado.")

func abandon_attempt(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre antes de encerrar tentativa da Arena.")):
		return
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		_set_error_text(host, "Nenhuma tentativa de Arena para encerrar.")
		return

	host.call("_set_busy", true, "Encerrando tentativa da Arena...")
	var mutation := SessionStore.prepare_pending_mutation(
		"arena/pve/abandon",
		"arena:%s" % SessionStore.active_save_type,
		AppShellActionContractScript.ACTION_ARENA_ABANDON_ATTEMPT,
		{"attempt_id": attempt_id}
	)
	var result: Dictionary = await SupabaseClient.abandon_arena_attempt(
		str(mutation.get("request_id", "")),
		attempt_id,
		SessionStore.access_token,
		str(mutation.get("request_hash", ""))
	)
	result = ArenaDevFixtureProviderScript.abandon_attempt_fallback_result(result, attempt, SessionStore)
	if not await _complete_arena_mutation(host, mutation, result, AppShellRouteContractScript.ROUTE_ARENA_SELECTION, "Tentativa encerrada. Arena liberada."):
		return
	host.call("_show_notice", "Tentativa antiga encerrada. Voce ja pode iniciar uma nova Arena.")

func claim_summary(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre antes de continuar a Arena.")):
		return
	var attempt := SessionStore.active_arena_attempt()
	var attempt_id := _attempt_id(attempt)
	if attempt_id == "":
		_set_error_text(host, "Nenhuma tentativa de Arena para concluir.")
		return

	host.call("_set_busy", true, "Confirmando resumo...")
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
	result = ArenaDevFixtureProviderScript.claim_summary_fallback_result(result, attempt, SessionStore)
	if not await _complete_arena_mutation(host, mutation, result, "", "Resumo confirmado."):
		return
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
	host.call("_set_busy", false, "Arena atualizada. Proximo desafio pronto.")

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
	var active_attempt := SessionStore.active_arena_attempt()
	if _attempt_blocks_new_start(active_attempt):
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)
		_set_error_text(host, "Existe uma tentativa ativa. Retome ou encerre a tentativa antes de iniciar outra.")
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
	result = ArenaDevFixtureProviderScript.start_attempt_fallback_result(result, arena_id, difficulty_id, difficulty_tier, SessionStore)
	await _complete_arena_mutation(host, mutation, result, AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, "Arena iniciada. Loadout travado.")

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
	if _attempt_needs_recovery(attempt):
		return AppShellRouteContractScript.ROUTE_ARENA_SELECTION
	var status := _attempt_state(attempt)
	if status in ["completed", "failed", "claimed", "abandoned"]:
		return AppShellRouteContractScript.ROUTE_ARENA_SUMMARY
	return AppShellRouteContractScript.ROUTE_ARENA_ACTIVE

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

func _attempt_blocks_new_start(attempt: Dictionary) -> bool:
	if attempt.is_empty():
		return false
	var status := _attempt_state(attempt)
	return status in ["active", "awaiting_buff"] or _attempt_needs_recovery(attempt)

func _attempt_needs_recovery(attempt: Dictionary) -> bool:
	if attempt.is_empty():
		return false
	var status := _attempt_state(attempt)
	if status in ["completed", "failed", "claimed", "abandoned"]:
		return false
	if status not in ["active", "awaiting_buff", "active_incompatible"]:
		return false
	if _attempt_id(attempt) == "":
		return true
	if status == "active_incompatible":
		return true
	if not _pending_buff_choices(attempt).is_empty():
		return false
	if status == "awaiting_buff":
		return true
	var total := maxi(0, int(attempt.get("duel_count", attempt.get("duels_total", attempt.get("max_steps", 0)))))
	var current := maxi(
		int(attempt.get("current_step_index", 0)),
		int(attempt.get("duels_won", attempt.get("duel_index", 0)))
	)
	return total <= 0 or current >= total

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
