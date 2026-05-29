class_name DraxosSurfaceActionFlow
extends RefCounted

const SessionStoreScript := preload("res://online/session_store.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const HubSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_surface_presenter.gd")

const PRODUCT_ALPHA_DOUBLE_CONSTRUCTION_QUEUE := "alpha_double_construction_queue"
const PREPARATION_NETWORK_ERROR_CODES := {
	"NETWORK_UNAVAILABLE": true,
	"REQUEST_NOT_STARTED": true,
	"CLIENT_MISCONFIGURED": true,
	"INVALID_JSON": true,
}

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
	host.call("_set_busy", true, "Buscando Refugio...")
	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if not bool(base_result.get("ok", false)):
		host.call("_fail_with_error", base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Refugio recuperado.")
	host.call("_render_base_state")

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

func collect_base(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de coletar o Refugio.")):
		return

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Coletando producao offline...")
	var base_result: Dictionary = await SupabaseClient.collect_base(
		SessionStoreScript.create_request_id(),
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		host.call("_fail_with_error", base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	var body := _as_dictionary(base_result.get("body", {}))
	var collected := _as_dictionary(body.get("collected", {}))
	var message := "Coleta registrada no servidor."
	if _resource_total(collected) <= 0.0:
		message = "Nada para coletar agora."
	SessionStore.save_cache()
	host.call("_set_busy", false, message)
	host.call("_render_base_state", collected)

func buy_energy_pack_alpha(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de comprar Energia.")):
		return

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Comprando pacote de Energia...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		AppShellActionContractScript.PRODUCT_ALPHA_ENERGY_PACK,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		host.call("_fail_with_error", monetization_result)
		return

	if not SessionStore.apply_monetization_result(monetization_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
	if bool(base_result.get("ok", false)):
		SessionStore.apply_base_result(base_result)

	SessionStore.save_cache()
	host.call("_set_busy", false, "Energia comprada. O Refugio foi atualizado com o novo saldo.")
	host.call("_render_base_state")

func upgrade_base_structure(host: Node, structure_id: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de evoluir o Refugio.")):
		return
	var target_structure_id := structure_id.strip_edges()
	if target_structure_id == "":
		target_structure_id = str(host.get("_selected_base_structure_id"))
	host.set("_selected_base_structure_id", target_structure_id)

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Solicitando evolucao de %s..." % str(host.call("_structure_label", target_structure_id)))
	var base_result: Dictionary = await SupabaseClient.upgrade_base_structure(
		SessionStoreScript.create_request_id(),
		target_structure_id,
		SessionStore.access_token
	)
	if not bool(base_result.get("ok", false)):
		host.call("_fail_with_error", base_result)
		return

	if not SessionStore.apply_base_result(base_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Evolucao de %s iniciada no servidor." % str(host.call("_structure_label", target_structure_id)))
	host.call("_render_base_state")

func show_crafting(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Crafting.")):
		return

	host.call("_show_surface_screen", str(host.call("_base_surface_target_screen")))
	host.call("_set_busy", true, "Buscando crafting...")
	var crafting_result: Dictionary = await SupabaseClient.fetch_crafting_state(SessionStore.access_token)
	if not bool(crafting_result.get("ok", false)):
		host.call("_fail_with_error", crafting_result)
		return
	if not SessionStore.apply_crafting_result(crafting_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Crafting recuperado.")
	host.call("_render_base_state")

func crush_bones(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de triturar Ossos.")):
		return

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Triturando Ossos...")
	var crafting_result: Dictionary = await SupabaseClient.crush_bones(
		SessionStoreScript.create_request_id(),
		1,
		SessionStore.access_token
	)
	if not bool(crafting_result.get("ok", false)):
		host.call("_fail_with_error", crafting_result)
		return
	if not SessionStore.apply_crafting_result(crafting_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "1 Osso triturado em 1 Po de Osso.")
	host.call("_render_base_state")

func craft_health_potion(host: Node) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de criar Pocao de Vida.")):
		return

	host.call("_show_screen", str(host.call("_base_surface_target_screen")), false)
	host.call("_set_busy", true, "Criando Pocao de Vida...")
	var crafting_result: Dictionary = await SupabaseClient.craft_item(
		SessionStoreScript.create_request_id(),
		AppShellActionContractScript.RECIPE_HEALTH_POTION,
		1,
		SessionStore.access_token
	)
	if not bool(crafting_result.get("ok", false)):
		host.call("_fail_with_error", crafting_result)
		return
	if not SessionStore.apply_crafting_result(crafting_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Pocao de Vida criada.")
	host.call("_render_base_state")

func show_preparation(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Preparacao.")):
		return

	host.set_meta("preparation_feedback_message", "")
	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_REFUGE)
	host.call("_set_busy", true, "Preparando suas escolhas de batalha...")
	var build_result: Dictionary = await SupabaseClient.fetch_build_state(SessionStore.access_token)
	if not bool(build_result.get("ok", false)):
		_fail_preparation_action(host, build_result, "Nao foi possivel carregar a preparacao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel carregar a preparacao.")
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Preparacao de batalha pronta.")
	_render_refuge_preparation(host)

func equip_health_potion(host: Node) -> void:
	await _update_potion_equip(host, AppShellActionContractScript.ITEM_HEALTH_POTION, "Pocao de Vida equipada para a proxima batalha.")

func unequip_potion(host: Node) -> void:
	await _update_potion_equip(host, null, "Pocao removida da proxima batalha.")

func enable_potion_default(host: Node) -> void:
	await _update_potion_behavior(host, _default_potion_behavior(), "Pocao de Vida sera usada quando a Vida ficar abaixo de 40%.")

func disable_potion(host: Node) -> void:
	var behavior := _default_potion_behavior()
	behavior["enabled"] = false
	await _update_potion_behavior(host, behavior, "Uso automatico da pocao pausado.")

func enable_spell_behavior(host: Node, spell_id: String) -> void:
	await _update_spell_behavior(host, spell_id, _default_spell_behavior(true), "Magia ativada para a proxima batalha.")

func disable_spell_behavior(host: Node, spell_id: String) -> void:
	await _update_spell_behavior(host, spell_id, _default_spell_behavior(false), "Magia pausada para a proxima batalha.")

func handle_build_equip_action(host: Node, action_id: String) -> void:
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
	host.call("_set_busy", true, "Buscando Social...")
	var social_result: Dictionary = await SupabaseClient.fetch_social_state(SessionStore.access_token)
	if not bool(social_result.get("ok", false)):
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Social recuperado.")
	host.call("_render_social_state")
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
	var social_result: Dictionary = await SupabaseClient.add_friend(
		SessionStoreScript.create_request_id(),
		username,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

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
	var social_result: Dictionary = await SupabaseClient.create_guild(
		SessionStoreScript.create_request_id(),
		guild_name,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

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
	var social_result: Dictionary = await SupabaseClient.join_guild(
		SessionStoreScript.create_request_id(),
		guild_name,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

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
	var social_result: Dictionary = await SupabaseClient.send_guild_chat(
		SessionStoreScript.create_request_id(),
		message,
		SessionStore.access_token
	)
	if not bool(social_result.get("ok", false)):
		host.call("_fail_with_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Mensagem registrada no servidor.")
	host.call("_render_social_state")
	_mark_social_sync_success(host)

func auto_sync_social(host: Node) -> void:
	var social_result: Dictionary = await SupabaseClient.fetch_social_state(SessionStore.access_token)
	host.set("_social_auto_sync_in_flight", false)
	if str(host.get("_current_screen")) != AppShellRouteContractScript.ROUTE_SOCIAL:
		host.call("_sync_social_auto_sync_for_route")
		return
	if not bool(social_result.get("ok", false)):
		host.call("_handle_social_auto_sync_error", social_result)
		return
	if not SessionStore.apply_social_result(social_result):
		host.call("_handle_social_auto_sync_error", {"error": SessionStore.last_error})
		return
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
	host.call("_set_busy", true, "Buscando matchmaking...")
	var competition_result: Dictionary = await SupabaseClient.fetch_matchmaking_preview(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		host.call("_fail_with_error", competition_result)
		return
	if not SessionStore.apply_competition_result(competition_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Matchmaking recuperado.")
	host.call("_render_competition_state")

func show_ranking(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir ranking.")):
		return

	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_COMPETITION)
	host.call("_set_busy", true, "Buscando ranking...")
	var competition_result: Dictionary = await SupabaseClient.fetch_ranking_current(SessionStore.access_token)
	if not bool(competition_result.get("ok", false)):
		host.call("_fail_with_error", competition_result)
		return
	if not SessionStore.apply_competition_result(competition_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Ranking recuperado.")
	host.call("_render_competition_state")

func show_shop(host: Node) -> void:
	if not bool(host.call("_require_session", "Entre com email ou use guest dev antes de abrir Loja.")):
		return

	host.call("_show_surface_screen", AppShellRouteContractScript.ROUTE_SHOP)
	host.call("_set_busy", true, "Buscando loja...")
	var monetization_result: Dictionary = await SupabaseClient.fetch_monetization_state(SessionStore.access_token)
	if not bool(monetization_result.get("ok", false)):
		host.call("_fail_with_error", monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	SessionStore.save_cache()
	host.call("_set_busy", false, "Loja recuperada.")
	host.call("_render_monetization_state")

func buy_shop_product(host: Node, product_id: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de comprar na Loja.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SHOP, false)
	host.call("_set_busy", true, "Processando produto...")
	var monetization_result: Dictionary = await SupabaseClient.alpha_purchase(
		SessionStoreScript.create_request_id(),
		product_id,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		host.call("_fail_with_error", monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	if product_id == AppShellActionContractScript.PRODUCT_ALPHA_ENERGY_PACK or product_id == PRODUCT_ALPHA_DOUBLE_CONSTRUCTION_QUEUE:
		var base_result: Dictionary = await SupabaseClient.fetch_base_state(SessionStore.access_token)
		if bool(base_result.get("ok", false)):
			SessionStore.apply_base_result(base_result)

	SessionStore.save_cache()
	host.call("_set_busy", false, str(host.call("_shop_purchase_message", product_id, _as_dictionary(monetization_result.get("body", {})))))
	host.call("_render_monetization_state")

func claim_shop_reward(host: Node, reward_id: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de resgatar recompensa.")):
		return

	host.call("_show_screen", AppShellRouteContractScript.ROUTE_SHOP, false)
	host.call("_set_busy", true, "Resgatando recompensa...")
	var monetization_result: Dictionary = await SupabaseClient.claim_reward(
		SessionStoreScript.create_request_id(),
		reward_id,
		SessionStore.access_token
	)
	if not bool(monetization_result.get("ok", false)):
		host.call("_fail_with_error", monetization_result)
		return
	if not SessionStore.apply_monetization_result(monetization_result):
		host.call("_fail_with_error", {"error": SessionStore.last_error})
		return

	var body := _as_dictionary(monetization_result.get("body", {}))
	var message := "Recompensa registrada no servidor."
	if bool(body.get("already_claimed", false)):
		message = "Recompensa ja havia sido resgatada neste periodo."
	SessionStore.save_cache()
	host.call("_set_busy", false, message)
	host.call("_render_monetization_state")

func _input_text(host: Node, property_name: String, fallback: String = "") -> String:
	return str(host.call("_social_input_text", host.get(property_name), fallback))

func _set_error_text(host: Node, text: String) -> void:
	var label := host.get("_error_label") as Label
	if label != null:
		label.text = text

func _resource_total(resources: Dictionary) -> float:
	var total := 0.0
	for value in resources.values():
		if value is int or value is float:
			total += float(value)
	return total

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}

func _update_build_equip(host: Node, payload: Dictionary, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de preparar a batalha.")):
		return
	if payload.is_empty():
		_set_error_text(host, "Escolha de preparacao invalida.")
		return

	host.call("_set_busy", true, "Salvando preparacao...")
	var build_result: Dictionary = await SupabaseClient.equip_build(
		SessionStoreScript.create_request_id(),
		payload,
		SessionStore.access_token
	)
	if not bool(build_result.get("ok", false)):
		_fail_preparation_action(host, build_result, "Nao foi possivel salvar a preparacao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel salvar a preparacao.")
		return

	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_refuge_preparation(host)

func _update_potion_equip(host: Node, item_id: Variant, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de equipar pocao.")):
		return

	host.call("_set_busy", true, "Ajustando Pocao de Vida...")
	var build_result: Dictionary = await SupabaseClient.equip_potion(
		SessionStoreScript.create_request_id(),
		item_id,
		SessionStore.access_token
	)
	if not bool(build_result.get("ok", false)):
		_fail_preparation_action(host, build_result, "Nao foi possivel ajustar a pocao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel ajustar a pocao.")
		return

	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_refuge_preparation(host)

func _update_potion_behavior(host: Node, behavior: Dictionary, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de configurar pocao.")):
		return

	host.call("_set_busy", true, "Ajustando uso da Pocao de Vida...")
	var build_result: Dictionary = await SupabaseClient.update_potion_behavior(
		SessionStoreScript.create_request_id(),
		behavior,
		SessionStore.access_token
	)
	if not bool(build_result.get("ok", false)):
		_fail_preparation_action(host, build_result, "Nao foi possivel ajustar a pocao.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel ajustar a pocao.")
		return

	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_refuge_preparation(host)

func _update_spell_behavior(host: Node, spell_id: String, behavior: Dictionary, message: String) -> void:
	if not bool(host.call("_require_account", "Entre com email ou use guest dev antes de ajustar magia.")):
		return
	if spell_id.strip_edges() == "":
		_set_error_text(host, "Magia invalida.")
		return

	host.call("_set_busy", true, "Ajustando magia...")
	var build_result: Dictionary = await SupabaseClient.update_spell_behavior(
		SessionStoreScript.create_request_id(),
		spell_id.strip_edges(),
		behavior,
		SessionStore.access_token
	)
	if not bool(build_result.get("ok", false)):
		_fail_preparation_action(host, build_result, "Nao foi possivel ajustar a magia.")
		return
	if not SessionStore.apply_build_result(build_result):
		_fail_preparation_action(host, {"error": SessionStore.last_error}, "Nao foi possivel ajustar a magia.")
		return

	SessionStore.save_cache()
	host.set_meta("preparation_feedback_message", message)
	host.call("_set_busy", false, message)
	_render_refuge_preparation(host)

func _render_refuge_preparation(host: Node) -> void:
	if str(host.get("_current_screen")) != AppShellRouteContractScript.ROUTE_REFUGE:
		host.call("_show_screen", AppShellRouteContractScript.ROUTE_REFUGE, false)
	else:
		host.call("_render_refuge_screen")
	HubSurfacePresenterScript.open_refuge_menu_popup(host, "preparation")

func _fail_preparation_action(host: Node, result: Dictionary, detail: String) -> void:
	var error_payload := _preparation_error_payload(result)
	var code := str(error_payload.get("code", "REQUEST_FAILED"))
	var is_network := _is_preparation_network_error(code)
	if is_network:
		SessionStore.mark_offline(error_payload)
	else:
		SessionStore.offline = false
		SessionStore.last_error = error_payload
		SessionStore.session_changed.emit()
	host.call("_set_busy", false, detail)
	var public_message := _preparation_error_message(code)
	host.set_meta("preparation_feedback_message", public_message)
	_set_error_text(host, public_message)
	HubSurfacePresenterScript.refresh_open_refuge_menu_popup(host)
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

static func _preparation_error_payload(result: Dictionary) -> Dictionary:
	var error_payload := _as_dictionary(result.get("error", {}))
	if error_payload.is_empty():
		var body := _as_dictionary(result.get("body", {}))
		error_payload = _as_dictionary(body.get("error", {}))
	if error_payload.is_empty():
		error_payload = {
			"code": "REQUEST_FAILED",
			"message": "Acao nao concluida.",
		}
	return error_payload

static func _preparation_error_message(code: String) -> String:
	match code.strip_edges():
		"UNAUTHENTICATED", "AUTH_REQUIRES_EMAIL":
			return "Entre com email ou use guest dev para preparar a batalha."
		"POTION_NOT_OWNED":
			return "Voce ainda nao tem essa Pocao de Vida. Crie uma no Refugio primeiro."
		"INVALID_POTION":
			return "Essa pocao ainda nao pode ser usada na preparacao."
		"INVALID_WEAPON", "INVALID_WEAPON_QUALITY":
			return "Esse Instrumento Ritual ainda nao pode ser usado na preparacao."
		"WEAPON_LOCKED":
			return "Esse Instrumento Ritual ainda esta bloqueado para seu nivel."
		"SPELL_NOT_EQUIPPED":
			return "Essa magia nao esta equipada para batalha."
		"INVALID_SPELL":
			return "Magia invalida para esta preparacao."
		"SPELL_LOCKED", "SPELL_SLOT_LOCKED":
			return "Essa habilidade ainda esta bloqueada para seu nivel."
		"DUPLICATE_SPELL":
			return "A mesma habilidade nao pode ocupar dois espacos."
		"INVALID_DOCTRINE":
			return "Doutrina invalida para esta preparacao."
		"DOCTRINE_LOCKED":
			return "Essa Doutrina ainda esta bloqueada para seu nivel."
		"INVALID_FAMILIAR":
			return "Familiar invalido para esta preparacao."
		"FAMILIAR_LOCKED":
			return "Esse Familiar ainda esta bloqueado para seu nivel."
		"BEHAVIOR_UPDATE_FAILED", "POTION_EQUIP_FAILED", "BUILD_EQUIP_FAILED", "POWER_UPDATE_FAILED":
			return "Nao foi possivel salvar essa escolha agora. Tente novamente."
		"BUILD_NOT_FOUND", "INVALID_SLOT", "INVALID_SPELL_SLOT", "INVALID_BEHAVIOR", "INVALID_BEHAVIOR_PERCENT", "INVALID_REQUEST_ID", "INVALID_SAVE_TYPE":
			return "Preparacao indisponivel agora. Tente novamente em instantes."
		"NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED", "INVALID_JSON":
			return "Sem conexao para carregar a preparacao. Verifique a internet e tente de novo."
		_:
			return "Nao foi possivel atualizar a preparacao. Tente novamente."

static func _is_preparation_network_error(code: String) -> bool:
	return bool(PREPARATION_NETWORK_ERROR_CODES.get(code.strip_edges(), false))

static func _default_potion_behavior() -> Dictionary:
	return {
		"enabled": true,
		"hp": {"mode": "below", "percent": 40},
		"mana": {"mode": "ignore", "percent": 0},
	}

static func _default_spell_behavior(enabled: bool) -> Dictionary:
	return {
		"enabled": enabled,
		"hp": {"mode": "ignore", "percent": 0},
		"mana": {"mode": "ignore", "percent": 0},
	}
