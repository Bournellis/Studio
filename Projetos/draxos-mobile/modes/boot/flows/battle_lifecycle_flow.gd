class_name DraxosBattleLifecycleFlow
extends RefCounted

const ProjectInfoScript := preload("res://core/project_info.gd")
const SessionStoreScript := preload("res://online/session_store.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

const BATTLE_REPLAY_TICK_SECONDS := 0.05

func render_entry(host: Node) -> void:
	var presenter = host.get("_battle_replay_presenter")
	if bool(host.get("_battle_request_splash_active")):
		presenter.render_request_splash(host, bool(host.get("_compact_layout")))
	else:
		presenter.render(
			host,
			bool(host.get("_compact_layout")),
			SessionStore.last_battle_log,
			SessionStore.last_battle_rewards,
			SessionStore.has_battle_log(),
			battle_history_for_active_save(host)
		)
	_sync_presenter_refs(host, presenter)

func render_running(host: Node) -> void:
	var overlay := host.call("_create_battle_fullscreen_overlay") as Control
	var presenter = host.get("_battle_replay_presenter")
	presenter.render_fullscreen_replay(
		host,
		overlay,
		bool(host.get("_compact_layout")),
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards
	)
	_sync_presenter_refs(host, presenter)

func render_summary(host: Node) -> void:
	var overlay := host.call("_create_battle_fullscreen_overlay") as Control
	var presenter = host.get("_battle_replay_presenter")
	presenter.render_fullscreen_summary(
		host,
		overlay,
		bool(host.get("_compact_layout")),
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards,
		SessionStore.resources,
		bool(host.get("_battle_summary_skipped"))
	)
	_sync_presenter_refs(host, presenter)

func render_logs(host: Node) -> void:
	var overlay := host.call("_create_battle_fullscreen_overlay") as Control
	var presenter = host.get("_battle_replay_presenter")
	presenter.render_fullscreen_logs(
		host,
		overlay,
		bool(host.get("_compact_layout")),
		SessionStore.last_battle_log,
		SessionStore.last_battle_rewards
	)
	_sync_presenter_refs(host, presenter)

func request_battle(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email antes de solicitar batalha.")):
		return

	host.set("_battle_request_splash_active", true)
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_ENTRY, false)
	host.call("_set_busy", true, "Solicitando batalha...")
	var mutation := SessionStore.prepare_pending_mutation(
		"battle/request",
		"battle:%s" % SessionStore.active_save_type,
		"request_battle",
		{"mode": ProjectInfoScript.DEFAULT_BATTLE_MODE}
	)
	var battle_result: Dictionary = await SupabaseClient.request_battle(
		str(mutation.get("request_id", "")),
		SessionStore.access_token,
		ProjectInfoScript.DEFAULT_BATTLE_MODE,
		"",
		str(mutation.get("request_hash", ""))
	)
	host.set("_battle_request_splash_active", false)
	if not bool(battle_result.get("ok", false)):
		SessionStore.fail_pending_mutation(str(mutation.get("request_id", "")), battle_result)
		host.call("_fail_with_error", battle_result)
		return

	if not SessionStore.apply_battle_result(battle_result):
		SessionStore.fail_pending_mutation(str(mutation.get("request_id", "")), {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.complete_pending_mutation(str(mutation.get("request_id", "")), battle_result)
	SessionStore.save_cache()
	var recovered := bool(await host.call("_recover_session_state"))
	if not recovered:
		return
	await play_battle_log(host, SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func show_latest_battle(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de ver resultado.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_ENTRY, false)
	host.call("_set_busy", true, "Buscando ultimo resultado...")
	var latest_result: Dictionary = await SupabaseClient.fetch_latest_battle(SessionStore.access_token)
	if not bool(latest_result.get("ok", false)):
		host.call("_fail_with_error", latest_result)
		return

	var body := _as_dictionary(latest_result.get("body", {}))
	if body.get("battle_log", null) == null:
		host.call("_set_busy", false, "Nenhuma batalha registrada.")
		host.get("_battle_replay_presenter").show_empty_state("Solicite uma batalha para gerar a primeira luta.")
		return

	if not SessionStore.apply_battle_result(latest_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Ultimo resultado recuperado.")
	await play_battle_log(host, SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func skip_current_replay(host: Node) -> void:
	if not bool(host.get("_replay_running")):
		return
	host.set("_skip_replay", true)
	host.call("_show_notice", "Pulando para o resultado final...")
	host.call("_sync_buttons")

func return_to_refuge(host: Node) -> void:
	host.set("_replay_running", false)
	host.set("_skip_replay", false)
	host.set("_battle_summary_skipped", false)
	if SessionStore.has_battle_log():
		SessionStore.mark_battle_result_seen()
		SessionStore.save_cache()
	host.call("_show_screen", AppShellRouteContractScript.clear_for_refuge_return(_screen_history(host)), false)
	host.call("_show_notice", "Recompensa registrada. Verifique coleta e evolucao da base.")

func show_current_battle_logs(host: Node) -> void:
	if not SessionStore.has_battle_log():
		_set_error_text(host, "Nenhum log de batalha carregado.")
		return
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_LOGS)

func return_to_battle_summary(host: Node) -> void:
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_SUMMARY, false)

func replay_latest_battle_from_summary(host: Node) -> void:
	if not SessionStore.has_battle_log():
		_set_error_text(host, "Nenhuma batalha carregada para rever.")
		return
	await play_battle_log(host, SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func show_battle_history(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir o historico.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_ENTRY, false)
	host.call("_set_busy", true, "Buscando historico de batalhas...")
	var history_result: Dictionary = await SupabaseClient.fetch_battle_history(SessionStore.access_token)
	if not bool(history_result.get("ok", false)):
		host.call("_fail_with_error", history_result)
		return

	var body := _as_dictionary(history_result.get("body", {}))
	var history_entries := _as_dictionary_array(body.get("history", []))
	host.set("_battle_history_entries", history_entries)
	host.set("_battle_history_save_type", SessionStore.active_save_type)
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_ENTRY, false)
	host.call("_set_busy", false, "Historico atualizado: %d batalhas recentes." % history_entries.size())

func show_battle_replay(host: Node, battle_id: String) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de reproduzir historico.")):
		return

	var requested_battle_id := battle_id.strip_edges()
	if requested_battle_id == "":
		_set_error_text(host, "BATTLE_ID_MISSING: batalha invalida no historico.")
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_ENTRY, false)
	host.call("_set_busy", true, "Carregando batalha salva...")
	var replay_result: Dictionary = await SupabaseClient.fetch_battle_replay(
		requested_battle_id,
		SessionStore.access_token
	)
	if not bool(replay_result.get("ok", false)):
		host.call("_fail_with_error", replay_result)
		return

	if not SessionStore.apply_battle_result(replay_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Batalha salva recuperada.")
	await play_battle_log(host, SessionStore.last_battle_log, SessionStore.last_battle_rewards)

func play_battle_log(host: Node, battle_log: Dictionary, rewards: Dictionary) -> void:
	var schema_version := str(battle_log.get("schema_version", ""))
	if schema_version != "battle_log_v1":
		_set_error_text(host, "Nao foi possivel abrir esta batalha. Solicite uma nova luta.")
		host.call("_sync_status_from_session")
		return

	_set_error_text(host, "")
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_BATTLE_RUNNING, false)
	host.set("_replay_running", true)
	host.set("_skip_replay", false)
	host.call("_set_busy", false, "Apresentando batalha...")
	host.call("_sync_buttons")
	host.call("_emit_client_event", "replay_start", {
		"battle_id": str(battle_log.get("battle_id", "")),
		"mode": str(battle_log.get("mode", "")),
	})

	var presenter = host.get("_battle_replay_presenter")
	presenter.begin_replay(battle_log, rewards)
	_sync_presenter_refs(host, presenter)

	var events: Array[Dictionary] = presenter.sorted_events(battle_log)
	var warning_text := str(presenter.build_warning_text(battle_log, ProjectInfoScript.DEFAULT_BATTLE_MODE))
	if not warning_text.is_empty():
		_set_error_text(host, warning_text)

	var replay_time := 0.0
	for event: Dictionary in events:
		if bool(host.get("_skip_replay")):
			break
		var event_time := maxf(replay_time, float(event.get("t", replay_time)))
		while replay_time + 0.001 < event_time:
			if bool(host.get("_skip_replay")):
				break
			var tick := minf(BATTLE_REPLAY_TICK_SECONDS, event_time - replay_time)
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
		host.call("_emit_client_event", "replay_skip", {
			"battle_id": str(battle_log.get("battle_id", "")),
			"events": events.size(),
		})
		presenter.reveal_all_events(events)

	presenter.reveal_all()

	var skipped := bool(host.get("_skip_replay"))
	host.set("_replay_running", false)
	host.set("_skip_replay", false)
	host.set("_battle_summary_skipped", skipped)
	host.call("_emit_client_event", "replay_end", {
		"battle_id": str(battle_log.get("battle_id", "")),
		"events": events.size(),
		"skipped": skipped,
	})
	host.call("_show_screen", AppShellRouteContractScript.summary_route_for(AppShellRouteContractScript.ROUTE_BATTLE_RUNNING), false)
	host.call("_set_busy", false, "Batalha concluida.")
	host.call("_sync_buttons")

func battle_history_for_active_save(host: Node) -> Array[Dictionary]:
	if str(host.get("_battle_history_save_type")) != SessionStore.active_save_type:
		clear_battle_history(host)
	return _as_dictionary_array(host.get("_battle_history_entries"))

func clear_battle_history(host: Node) -> void:
	host.set("_battle_history_entries", [])
	host.set("_battle_history_save_type", SessionStore.active_save_type)

func _sync_presenter_refs(host: Node, presenter: RefCounted) -> void:
	host.set("_timeline_label", presenter.get_timeline_label())
	host.set("_battle_visual", presenter.get_visual())

func _screen_history(host: Node) -> Array[String]:
	var history: Array[String] = []
	for value in _as_array(host.get("_screen_history")):
		history.append(str(value))
	host.set("_screen_history", history)
	return history

func _set_error_text(host: Node, text: String) -> void:
	var label := host.get("_error_label") as Label
	if label != null:
		label.text = text

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return value
	return []

static func _as_dictionary_array(value: Variant) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	for item in _as_array(value):
		if item is Dictionary:
			output.append(item)
	return output
