class_name DraxosSurfaceActionFlow
extends RefCounted

const SessionStoreScript := preload("res://online/session_store.gd")
const PreparationActionContractScript := preload("res://modes/boot/flows/preparation_action_contract.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

const PRODUCT_ALPHA_DOUBLE_CONSTRUCTION_QUEUE := "alpha_double_construction_queue"

func _prepare_mutation(endpoint: String, action_id: String, payload: Dictionary = {}) -> Dictionary:
	var scope_prefix := endpoint.get_slice("/", 0)
	if endpoint.begins_with("build/"):
		scope_prefix = "build"
	elif endpoint.begins_with("monetization/"):
		scope_prefix = "monetization"
	elif endpoint.begins_with("social/"):
		scope_prefix = "social"
	elif endpoint.begins_with("crafting/"):
		scope_prefix = "crafting"
	return SessionStore.prepare_pending_mutation(
		endpoint,
		"%s:%s" % [scope_prefix, SessionStore.active_save_type],
		action_id,
		payload
	)

func _request_id(mutation: Dictionary) -> String:
	return str(mutation.get("request_id", ""))

func _request_hash(mutation: Dictionary) -> String:
	return str(mutation.get("request_hash", ""))

func _complete_mutation(mutation: Dictionary, result: Dictionary) -> void:
	SessionStore.complete_pending_mutation(_request_id(mutation), result)

func _fail_mutation(mutation: Dictionary, result: Dictionary) -> void:
	SessionStore.fail_pending_mutation(_request_id(mutation), result)

func _begin_cached_refresh(host: Node, surface: String, endpoint: String, message: String, render_method: String = "") -> Dictionary:
	var rendered_from_cache := SessionStore.has_surface_snapshot(surface)
	if render_method != "":
		host.call(render_method)
	var refresh_token: Dictionary = host.call("_begin_surface_refresh", surface, endpoint, message, rendered_from_cache)
	if render_method != "":
		if rendered_from_cache:
			host.call("_show_notice", "Dados em cache visiveis. Atualizando com o servidor...")
		else:
			host.call("_show_notice", "Superficie local visivel. Sincronizando com o servidor...")
	return refresh_token

func _finish_cached_refresh(host: Node, surface: String, token: Dictionary, result: Dictionary, message: String, render_method: String = "") -> bool:
	if not bool(host.call("_finish_surface_refresh", surface, token, result, message)):
		return false
	SessionStore.save_cache()
	if render_method != "":
		host.call(render_method)
	return true

func _fail_cached_refresh_or_error(host: Node, surface: String, token: Dictionary, result: Dictionary, fallback_message: String, render_method: String = "") -> bool:
	host.call("_fail_surface_refresh", surface, token, result)
	if SessionStore.has_surface_snapshot(surface):
		if render_method != "":
			host.call(render_method)
		host.call("_show_notice", fallback_message)
		return true
	host.call("_fail_with_error", result)
	return false

func _refresh_token_current(host: Node, surface: String, token: Dictionary) -> bool:
	return bool(host.call("_surface_refresh_current", surface, token))

func _session_refresh_token_current(surface: String, token: Dictionary) -> bool:
	if token.is_empty():
		return true
	return int(SessionStore.surface_refresh_snapshot(surface).get("refresh_version", 0)) == int(token.get("version", 0))

func show_base(host: Node) -> void:
	var target_screen := str(host.call("_base_surface_target_screen"))
	if SessionStore.is_progression_lab_local_only():
		host.call("_show_surface_screen", target_screen)
		host.call("_set_busy", false, "Snapshot local do Progression Lab carregado. Refugio em modo somente leitura; coletas e upgrades precisam de save seeded no Supabase local.")
		host.call("_render_base_state")
		return
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de atualizar o Refugio.")):
		return

	host.call("_show_surface_screen", target_screen)
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_BASE, "base/state", "Buscando Refugio...", "_render_base_state")
	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if not bool(base_result.get("ok", false)):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_BASE, refresh_token, base_result, "Refugio exibindo cache local; servidor nao respondeu agora.", "_render_base_state")
		return

	if not _refresh_token_current(host, SessionStore.SURFACE_BASE, refresh_token):
		return
	if not SessionStore.apply_base_result(base_result):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_BASE, refresh_token, {"error": SessionStore.last_error}, "Refugio exibindo cache local; resposta do servidor veio incompleta.", "_render_base_state")
		return

	_finish_cached_refresh(host, SessionStore.SURFACE_BASE, refresh_token, base_result, "Refugio recuperado.", "_render_base_state")

func sync_refuge_state_if_needed(host: Node) -> void:
	if str(host.get("_current_screen")) != AppShellRouteContractScript.ROUTE_REFUGE:
		return
	if bool(host.get("_is_busy")) or not SessionStore.base_state.is_empty():
		return
	if SessionStore.is_progression_lab_local_only():
		return
	if not SessionStore.has_valid_access_token():
		return
	await show_base(host)

func upgrade_base_structure(host: Node, structure_id: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de evoluir o Refugio.")):
		return
	var target_structure_id := structure_id.strip_edges()
	if target_structure_id == "":
		target_structure_id = str(host.get("_selected_base_structure_id"))
	host.set("_selected_base_structure_id", target_structure_id)

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Solicitando evolucao de %s..." % str(host.call("_structure_label", target_structure_id)))
	var mutation := _prepare_mutation("base/upgrade", AppShellActionContractScript.upgrade_base_structure_action(target_structure_id), {
		"structure_id": target_structure_id,
	})
	var base_result: Dictionary = await SupabaseClient.upgrade_base_structure(
		_request_id(mutation),
		target_structure_id,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(base_result.get("ok", false)):
		_fail_mutation(mutation, base_result)
		host.call("_fail_with_error", base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, base_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "Evolucao de %s iniciada no servidor." % str(host.call("_structure_label", target_structure_id)))
	host.call("_render_base_state")

func show_crafting(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Crafting.")):
		return

	host.call("_show_surface_screen", str(host.call("_base_surface_target_screen")))
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_CRAFTING, "crafting/state", "Buscando crafting...", "_render_base_state")
	var crafting_result: Dictionary = await SupabaseClient.fetch_crafting_state(SessionStore.access_token)
	if not bool(crafting_result.get("ok", false)):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_CRAFTING, refresh_token, crafting_result, "Crafting exibindo cache local; servidor nao respondeu agora.", "_render_base_state")
		return
	if not _refresh_token_current(host, SessionStore.SURFACE_CRAFTING, refresh_token):
		return
	if not SessionStore.apply_crafting_result(crafting_result):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_CRAFTING, refresh_token, {"error": SessionStore.last_error}, "Crafting exibindo cache local; resposta do servidor veio incompleta.", "_render_base_state")
		return

	_finish_cached_refresh(host, SessionStore.SURFACE_CRAFTING, refresh_token, crafting_result, "Crafting recuperado.", "_render_base_state")

func crush_bones(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de triturar Ossos.")):
		return

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Triturando Ossos...")
	var mutation := _prepare_mutation("crafting/crush-bones", AppShellActionContractScript.ACTION_CRUSH_BONES, {
		"amount": 1,
	})
	var crafting_result: Dictionary = await SupabaseClient.crush_bones(
		_request_id(mutation),
		1,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(crafting_result.get("ok", false)):
		_fail_mutation(mutation, crafting_result)
		host.call("_fail_with_error", crafting_result)
		return
	if not SessionStore.apply_crafting_result(crafting_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, crafting_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "1 Osso triturado em 1 Po de Osso.")
	host.call("_render_base_state")

func craft_health_potion(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de criar Pocao de Vida.")):
		return

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Criando Pocao de Vida...")
	var mutation := _prepare_mutation("crafting/craft", AppShellActionContractScript.ACTION_CRAFT_HEALTH_POTION, {
		"recipe_id": AppShellActionContractScript.RECIPE_HEALTH_POTION,
		"quantity": 1,
	})
	var crafting_result: Dictionary = await SupabaseClient.craft_item(
		_request_id(mutation),
		AppShellActionContractScript.RECIPE_HEALTH_POTION,
		1,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(crafting_result.get("ok", false)):
		_fail_mutation(mutation, crafting_result)
		host.call("_fail_with_error", crafting_result)
		return
	if not SessionStore.apply_crafting_result(crafting_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, crafting_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "Pocao de Vida criada.")
	host.call("_render_base_state")

func show_preparation(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Preparacao.")):
		return

	host.set_meta("preparation_feedback_message", "")
	var target_route := _preparation_target_route(host)
	if target_route == AppShellRouteContractScript.ROUTE_ARENA_ACTIVE:
		host.set_meta("arena_active_preparation_open", true)
	host.call("_show_surface_screen", target_route)
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_BUILD, "build/state", "Preparando suas escolhas de batalha...")
	var build_result: Dictionary = await SupabaseClient.fetch_build_state(SessionStore.access_token)
	if not bool(build_result.get("ok", false)):
		host.call("_fail_surface_refresh", SessionStore.SURFACE_BUILD, refresh_token, build_result)
		if SessionStore.has_build_state():
			host.call("_show_notice", "Preparacao exibindo cache local; servidor nao respondeu agora.")
			_render_preparation_for_route(host, target_route)
			return
		_fail_preparation_action(host, build_result, "Nao foi possivel carregar a preparacao.")
		return
	if not _refresh_token_current(host, SessionStore.SURFACE_BUILD, refresh_token):
		return
	if not SessionStore.apply_build_result(build_result):
		host.call("_fail_surface_refresh", SessionStore.SURFACE_BUILD, refresh_token, {"error": SessionStore.last_error})
		if SessionStore.has_build_state():
			host.call("_show_notice", "Preparacao exibindo cache local; resposta do servidor veio incompleta.")
			_render_preparation_for_route(host, target_route)
			return
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel carregar a preparacao.")
		return

	host.call("_finish_surface_refresh", SessionStore.SURFACE_BUILD, refresh_token, build_result, "Preparacao de batalha pronta.")
	SessionStore.save_cache()
	_render_preparation_for_route(host, target_route)

func equip_health_potion(host: Node) -> void:
	if _preparation_loadout_locked(host):
		_block_locked_loadout_action(host)
		return
	await _update_potion_equip(host, AppShellActionContractScript.ITEM_HEALTH_POTION, "Pocao de Vida equipada para a proxima batalha.")

func unequip_potion(host: Node) -> void:
	if _preparation_loadout_locked(host):
		_block_locked_loadout_action(host)
		return
	await _update_potion_equip(host, null, "Pocao removida da proxima batalha.")

func enable_potion_default(host: Node) -> void:
	await _update_potion_behavior(host, PreparationActionContractScript.default_potion_behavior(), "Pocao de Vida sera usada quando a Vida ficar abaixo de 40%.")

func disable_potion(host: Node) -> void:
	var behavior := PreparationActionContractScript.default_potion_behavior()
	behavior["enabled"] = false
	await _update_potion_behavior(host, behavior, "Uso automatico da pocao pausado.")

func enable_spell_behavior(host: Node, spell_id: String) -> void:
	await _update_spell_behavior(host, spell_id, PreparationActionContractScript.default_spell_behavior(true), "Magia ativada para a proxima batalha.")

func disable_spell_behavior(host: Node, spell_id: String) -> void:
	await _update_spell_behavior(host, spell_id, PreparationActionContractScript.default_spell_behavior(false), "Magia pausada para a proxima batalha.")

func handle_build_equip_action(host: Node, action_id: String) -> void:
	if _preparation_loadout_locked(host):
		_block_locked_loadout_action(host)
		return
	var payload := {}
	var message := "Preparacao atualizada."
	if AppShellActionContractScript.is_equip_instrument(action_id):
		var instrument_id := AppShellActionContractScript.action_value(action_id)
		if instrument_id == "":
			_set_error_text(host, "Instrumento invalido.")
			return
		payload["weapon"] = {"type": instrument_id}
		message = "Instrumento Ritual equipado."
	elif AppShellActionContractScript.is_equip_spell_position(action_id):
		var position := int(AppShellActionContractScript.action_value(action_id))
		var spell_id := AppShellActionContractScript.action_value_at(action_id, 2)
		if position <= 0 or spell_id == "":
			_set_error_text(host, "Habilidade invalida.")
			return
		payload["spell_slots"] = [{"slot_index": position, "spell_id": spell_id}]
		message = "Habilidade equipada para a proxima batalha."
	elif AppShellActionContractScript.is_remove_spell_position(action_id):
		var position := int(AppShellActionContractScript.action_value(action_id))
		if position <= 0:
			_set_error_text(host, "Habilidade invalida.")
			return
		payload["spell_slots"] = [{"slot_index": position, "spell_id": null}]
		message = "Habilidade removida da proxima batalha."
	elif AppShellActionContractScript.is_equip_doctrine(action_id):
		var doctrine_id := AppShellActionContractScript.action_value(action_id)
		if doctrine_id == "":
			_set_error_text(host, "Doutrina invalida.")
			return
		payload["passive_id"] = doctrine_id
		message = "Doutrina equipada."
	elif AppShellActionContractScript.is_remove_doctrine(action_id):
		payload["passive_id"] = null
		message = "Doutrina removida."
	elif AppShellActionContractScript.is_equip_familiar(action_id):
		var familiar_id := AppShellActionContractScript.action_value(action_id)
		if familiar_id == "":
			_set_error_text(host, "Familiar invalido.")
			return
		payload["pet_id"] = familiar_id
		message = "Familiar equipado."
	elif AppShellActionContractScript.is_remove_familiar(action_id):
		payload["pet_id"] = null
		message = "Familiar removido."
	else:
		_set_error_text(host, "Escolha de preparacao invalida.")
		return
	await _update_build_equip(host, payload, message)

func show_social(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Social.")):
		return

	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_SOCIAL)
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_SOCIAL, "social/state", "Buscando Social...", "_render_social_state")
	var social_result: Dictionary = await SupabaseClient.fetch_social_state(SessionStore.access_token)
	if not bool(social_result.get("ok", false)):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_SOCIAL, refresh_token, social_result, "Social exibindo cache local; servidor nao respondeu agora.", "_render_social_state")
		return
	if not _refresh_token_current(host, SessionStore.SURFACE_SOCIAL, refresh_token):
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_SOCIAL, refresh_token, {"error": SessionStore.last_error}, "Social exibindo cache local; resposta do servidor veio incompleta.", "_render_social_state")
		return

	_finish_cached_refresh(host, SessionStore.SURFACE_SOCIAL, refresh_token, social_result, "Social recuperado.", "_render_social_state")
	_mark_social_sync_success(host)

func add_friend(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de adicionar amigo.")):
		return

	var username := _input_text(host, "_social_friend_input")
	host.set("_last_social_friend_username", username)
	if username == "":
		_set_error_text(host, "Informe o username do amigo.")
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SOCIAL, false)
	host.call("_set_busy", true, "Adicionando amigo...")
	var mutation := _prepare_mutation("social/friends/add", AppShellActionContractScript.ACTION_ADD_FRIEND, {
		"username": username,
	})
	var social_result: Dictionary = await SupabaseClient.add_friend(
		_request_id(mutation),
		username,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(social_result.get("ok", false)):
		_fail_mutation(mutation, social_result)
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, social_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "Amigo adicionado.")
	host.call("_render_social_state")
	_mark_social_sync_success(host)

func create_guild(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de criar guilda.")):
		return

	var guild_name := _input_text(host, "_social_guild_input", str(host.call("_default_guild_name")))
	host.set("_last_social_guild_name", guild_name)
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SOCIAL, false)
	host.call("_set_busy", true, "Criando guilda...")
	var mutation := _prepare_mutation("social/guild/create", AppShellActionContractScript.ACTION_CREATE_GUILD, {
		"name": guild_name,
	})
	var social_result: Dictionary = await SupabaseClient.create_guild(
		_request_id(mutation),
		guild_name,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(social_result.get("ok", false)):
		_fail_mutation(mutation, social_result)
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, social_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "Guilda criada no servidor.")
	host.call("_render_social_state")
	_mark_social_sync_success(host)

func join_guild(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de entrar em guilda.")):
		return

	var guild_name := _input_text(host, "_social_guild_input")
	host.set("_last_social_guild_name", guild_name)
	if guild_name == "":
		_set_error_text(host, "Informe o nome da guilda.")
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SOCIAL, false)
	host.call("_set_busy", true, "Entrando na guilda...")
	var mutation := _prepare_mutation("social/guild/join", AppShellActionContractScript.ACTION_JOIN_GUILD, {
		"name": guild_name,
	})
	var social_result: Dictionary = await SupabaseClient.join_guild(
		_request_id(mutation),
		guild_name,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(social_result.get("ok", false)):
		_fail_mutation(mutation, social_result)
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, social_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "Guilda sincronizada.")
	host.call("_render_social_state")
	_mark_social_sync_success(host)

func send_guild_chat(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de usar chat.")):
		return

	var message := _input_text(host, "_social_chat_input", str(host.get("_last_social_chat_message")))
	host.set("_last_social_chat_message", message)
	if message == "":
		_set_error_text(host, "Digite uma mensagem para o chat da guilda.")
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SOCIAL, false)
	host.call("_set_busy", true, "Enviando mensagem de guilda...")
	var mutation := _prepare_mutation("social/chat/send", AppShellActionContractScript.ACTION_SEND_GUILD_CHAT, {
		"content": message,
	})
	var social_result: Dictionary = await SupabaseClient.send_guild_chat(
		_request_id(mutation),
		message,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(social_result.get("ok", false)):
		_fail_mutation(mutation, social_result)
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, social_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, "Mensagem registrada no servidor.")
	host.call("_render_social_state")
	_mark_social_sync_success(host)

func auto_sync_social(host: Node) -> void:
	var refresh_token := SessionStore.begin_surface_refresh(SessionStore.SURFACE_SOCIAL, "social_auto_sync", "social/state", SessionStore.has_surface_snapshot(SessionStore.SURFACE_SOCIAL))
	var social_result: Dictionary = await SupabaseClient.fetch_social_state(SessionStore.access_token)
	host.set("_social_auto_sync_in_flight", false)
	if str(host.get("_current_screen")) != AppShellRouteContractScript.ROUTE_SOCIAL:
		SessionStore.complete_surface_refresh(SessionStore.SURFACE_SOCIAL, social_result, refresh_token)
		host.call("_sync_social_auto_sync_for_route")
		return
	if not bool(social_result.get("ok", false)):
		SessionStore.fail_surface_refresh(SessionStore.SURFACE_SOCIAL, social_result, refresh_token)
		host.call("_handle_social_auto_sync_error", social_result)
		return
	if not _session_refresh_token_current(SessionStore.SURFACE_SOCIAL, refresh_token):
		host.call("_sync_social_auto_sync_for_route")
		return
	if not SessionStore.apply_social_result(social_result):
		SessionStore.fail_surface_refresh(SessionStore.SURFACE_SOCIAL, {"error": SessionStore.last_error}, refresh_token)
		host.call("_handle_social_auto_sync_error", {"error": SessionStore.last_error})
		return
	SessionStore.complete_surface_refresh(SessionStore.SURFACE_SOCIAL, social_result, refresh_token)
	SessionStore.save_cache()
	host.call("_render_social_state")
	_mark_social_sync_success(host)

func _mark_social_sync_success(host: Node) -> void:
	host.set("_social_auto_sync_last_text", Time.get_time_string_from_system())
	host.set("_social_auto_sync_last_error", "")
	host.call("_restart_social_auto_sync")

func show_matchmaking(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir matchmaking.")):
		return

	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_COMPETITION)
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_COMPETITION, "competition/matchmaking/preview", "Buscando matchmaking...", "_render_competition_state")
	var competition_result: Dictionary = await SupabaseClient.fetch_matchmaking_preview(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_COMPETITION, refresh_token, competition_result, "Competicao exibindo cache local; servidor nao respondeu agora.", "_render_competition_state")
		return
	if not _refresh_token_current(host, SessionStore.SURFACE_COMPETITION, refresh_token):
		return
	if not SessionStore.apply_competition_result(competition_result):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_COMPETITION, refresh_token, {"error": SessionStore.last_error}, "Competicao exibindo cache local; resposta do servidor veio incompleta.", "_render_competition_state")
		return

	_finish_cached_refresh(host, SessionStore.SURFACE_COMPETITION, refresh_token, competition_result, "Matchmaking recuperado.", "_render_competition_state")

func show_ranking(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir ranking.")):
		return

	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_COMPETITION)
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_COMPETITION, "competition/ranking/current", "Buscando ranking...", "_render_competition_state")
	var competition_result: Dictionary = await SupabaseClient.fetch_ranking_current(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_COMPETITION, refresh_token, competition_result, "Competicao exibindo cache local; servidor nao respondeu agora.", "_render_competition_state")
		return
	if not _refresh_token_current(host, SessionStore.SURFACE_COMPETITION, refresh_token):
		return
	if not SessionStore.apply_competition_result(competition_result):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_COMPETITION, refresh_token, {"error": SessionStore.last_error}, "Competicao exibindo cache local; resposta do servidor veio incompleta.", "_render_competition_state")
		return

	_finish_cached_refresh(host, SessionStore.SURFACE_COMPETITION, refresh_token, competition_result, "Ranking recuperado.", "_render_competition_state")

func show_shop(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Loja.")):
		return

	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_SHOP)
	var refresh_token: Dictionary = _begin_cached_refresh(host, SessionStore.SURFACE_MONETIZATION, "monetization/state", "Buscando loja...", "_render_monetization_state")
	var monetization_result: Dictionary = await SupabaseClient.fetch_monetization_state(SessionStore.access_token)
	if not bool(monetization_result.get("ok", false)):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_MONETIZATION, refresh_token, monetization_result, "Loja exibindo cache local; servidor nao respondeu agora.", "_render_monetization_state")
		return
	if not _refresh_token_current(host, SessionStore.SURFACE_MONETIZATION, refresh_token):
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_cached_refresh_or_error(host, SessionStore.SURFACE_MONETIZATION, refresh_token, {"error": SessionStore.last_error}, "Loja exibindo cache local; resposta do servidor veio incompleta.", "_render_monetization_state")
		return

	_finish_cached_refresh(host, SessionStore.SURFACE_MONETIZATION, refresh_token, monetization_result, "Loja recuperada.", "_render_monetization_state")

func buy_shop_product(host: Node, product_id: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de comprar na Loja.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SHOP, false)
	host.call("_set_busy", true, "Processando produto...")
	var mutation := _prepare_mutation("monetization/alpha-purchase", AppShellActionContractScript.shop_purchase_action(product_id), {
		"product_id": product_id,
	})
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		_request_id(mutation),
		product_id,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_mutation(mutation, monetization_result)
		host.call("_fail_with_error", monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	_complete_mutation(mutation, monetization_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, str(host.call("_shop_purchase_message", product_id, _as_dictionary(monetization_result.get("body", {})))))
	host.call("_render_monetization_state")

func claim_shop_reward(host: Node, reward_id: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de resgatar recompensa.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SHOP, false)
	host.call("_set_busy", true, "Resgatando recompensa...")
	var mutation := _prepare_mutation("monetization/rewards/claim", AppShellActionContractScript.claim_reward_action(reward_id), {
		"reward_id": reward_id,
	})
	var monetization_result: Dictionary = await SupabaseClient.claim_reward(
		_request_id(mutation),
		reward_id,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(monetization_result.get("ok", false)):
		_fail_mutation(mutation, monetization_result)
		host.call("_fail_with_error", monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	var body := _as_dictionary(monetization_result.get("body", {}))
	var message := "Recompensa registrada no servidor."
	if bool(body.get("already_claimed", false)):
		message = "Recompensa ja havia sido resgatada neste periodo."
	_complete_mutation(mutation, monetization_result)
	SessionStore.save_cache()
	host.call("_set_busy", false, message)
	host.call("_render_monetization_state")

func _input_text(host: Node, property_name: String, fallback: String = "") -> String:
	return str(host.call("_social_input_text", host.get(property_name), fallback))

func _set_error_text(host: Node, text: String) -> void:
	var label := host.get("_error_label") as Label
	if label != null:
		label.text = text

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}

func _update_build_equip(host: Node, payload: Dictionary, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de preparar a batalha.")):
		return
	if _preparation_loadout_locked(host):
		_block_locked_loadout_action(host)
		return
	if payload.is_empty():
		_set_error_text(host, "Escolha de preparacao invalida.")
		return

	host.call("_set_busy", true, "Salvando preparacao...")
	var mutation := _prepare_mutation("build/equip", str(host.get("_active_action_id")), payload)
	var build_result: Dictionary = await SupabaseClient.equip_build(
		_request_id(mutation),
		payload,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(build_result.get("ok", false)):
		_fail_mutation(mutation, build_result)
		_fail_preparation_action(host, build_result, "Nao foi possivel salvar a preparacao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel salvar a preparacao.")
		return

	_complete_mutation(mutation, build_result)
	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_preparation_for_route(host, _preparation_target_route(host))

func _update_potion_equip(host: Node, item_id: Variant, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de equipar pocao.")):
		return
	if _preparation_loadout_locked(host):
		_block_locked_loadout_action(host)
		return

	host.call("_set_busy", true, "Ajustando Pocao de Vida...")
	var mutation := _prepare_mutation("build/potion/equip", str(host.get("_active_action_id")), {
		"slot_index": 1,
		"item_id": item_id,
	})
	var build_result: Dictionary = await SupabaseClient.equip_potion(
		_request_id(mutation),
		item_id,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(build_result.get("ok", false)):
		_fail_mutation(mutation, build_result)
		_fail_preparation_action(host, build_result, "Nao foi possivel ajustar a pocao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel ajustar a pocao.")
		return

	_complete_mutation(mutation, build_result)
	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_preparation_for_route(host, _preparation_target_route(host))

func _update_potion_behavior(host: Node, behavior: Dictionary, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de configurar pocao.")):
		return

	host.call("_set_busy", true, "Ajustando uso da Pocao de Vida...")
	var mutation := _prepare_mutation("build/potion-behavior", str(host.get("_active_action_id")), {
		"slot_index": 1,
		"behavior": behavior,
	})
	var build_result: Dictionary = await SupabaseClient.update_potion_behavior(
		_request_id(mutation),
		behavior,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(build_result.get("ok", false)):
		_fail_mutation(mutation, build_result)
		_fail_preparation_action(host, build_result, "Nao foi possivel ajustar a pocao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel ajustar a pocao.")
		return

	_complete_mutation(mutation, build_result)
	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_preparation_for_route(host, _preparation_target_route(host))

func _update_spell_behavior(host: Node, spell_id: String, behavior: Dictionary, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de ajustar magia.")):
		return
	if spell_id.strip_edges() == "":
		_set_error_text(host, "Magia invalida.")
		return

	host.call("_set_busy", true, "Ajustando magia...")
	var mutation := _prepare_mutation("build/spell-behavior", str(host.get("_active_action_id")), {
		"spell_id": spell_id.strip_edges(),
		"behavior": behavior,
	})
	var build_result: Dictionary = await SupabaseClient.update_spell_behavior(
		_request_id(mutation),
		spell_id.strip_edges(),
		behavior,
		SessionStore.access_token,
		_request_hash(mutation)
	)
	if not bool(build_result.get("ok", false)):
		_fail_mutation(mutation, build_result)
		_fail_preparation_action(host, build_result, "Nao foi possivel ajustar a magia.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_mutation(mutation, {"error": SessionStore.last_error})
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel ajustar a magia.")
		return

	_complete_mutation(mutation, build_result)
	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_preparation_for_route(host, _preparation_target_route(host))

func _preparation_target_route(host: Node) -> String:
	var current_route := AppShellRouteContractScript.normalize(str(host.get("_current_screen")))
	if current_route == AppShellRouteContractScript.ROUTE_ARENA_ACTIVE:
		return AppShellRouteContractScript.ROUTE_ARENA_ACTIVE
	return AppShellRouteContractScript.ROUTE_ARENA_SELECTION

func _render_preparation_for_route(host: Node, route_id: String) -> void:
	var target_route := AppShellRouteContractScript.normalize(route_id)
	if target_route == AppShellRouteContractScript.ROUTE_ARENA_ACTIVE:
		host.set_meta("arena_active_preparation_open", true)
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_ACTIVE, false)
		return
	host.set_meta("arena_active_preparation_open", false)
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_ARENA_SELECTION, false)

func _preparation_loadout_locked(host: Node) -> bool:
	return AppShellRouteContractScript.normalize(str(host.get("_current_screen"))) == AppShellRouteContractScript.ROUTE_ARENA_ACTIVE

func _block_locked_loadout_action(host: Node) -> void:
	var message := "Loadout travado nesta tentativa. Entre duelos, ajuste apenas comportamento."
	host.call("_set_busy", false, message)
	_set_error_text(host, message)
	host.set_meta("preparation_feedback_message", message)

func _fail_preparation_action(host: Node, result: Dictionary, detail: String) -> void:
	var error_payload := PreparationActionContractScript.error_payload(result)
	var code := str(error_payload.get("code", "REQUEST_FAILED"))
	var is_network := PreparationActionContractScript.is_network_error(code)
	if is_network:
		SessionStore.mark_offline(error_payload)
	else:
		SessionStore.offline = false
		SessionStore.last_error = error_payload
		SessionStore.session_changed.emit()
	host.call("_set_busy", false, detail)
	var public_message := PreparationActionContractScript.error_message(code)
	host.set_meta("preparation_feedback_message", public_message)
	_set_error_text(host, public_message)
	host.call("_sync_immersive_feedback")
	host.call("_emit_client_event", "action_failure", {
		"action_id": str(host.get("_active_action_id")),
		"screen": str(host.get("_current_screen")),
		"code": code,
		"message": str(error_payload.get("message", "")),
		"network": is_network,
	})
	if is_network:
		host.call("_emit_client_event", "network_failure", {
			"action_id": str(host.get("_active_action_id")),
			"screen": str(host.get("_current_screen")),
			"code": code,
		})
	host.call("_sync_social_auto_sync_for_route")
