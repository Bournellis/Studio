class_name OpenworldForestScreen
extends Control

signal close_requested
signal shell_action_requested(action_id: String, entry_id: String)

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")
const World2DScript := preload("res://modes/openworld/openworld_forest_world_2d.gd")
const RuntimeStateScript := preload("res://modes/openworld/openworld_forest_runtime_state.gd")
const InputControllerScript := preload("res://modes/openworld/openworld_forest_input_controller.gd")
const HudControllerScript := preload("res://modes/openworld/openworld_forest_hud_controller.gd")
const InteractionControllerScript := preload("res://modes/openworld/openworld_forest_interaction_controller.gd")
const LauncherCatalogScript := preload("res://modes/openworld/openworld_forest_launcher_catalog.gd")
const LauncherControllerScript := preload("res://modes/openworld/openworld_forest_launcher_controller.gd")
const IntegratedSessionBridgeScript := preload("res://modes/openworld/openworld_integrated_session_bridge.gd")
const WorldContextScript := preload("res://modes/openworld/openworld_world_context.gd")

var model = ModelScript.new()
var integration_mode := "dev_local"

var _world = null
var _world_viewport_container: SubViewportContainer
var _world_viewport: SubViewport
var _runtime = RuntimeStateScript.new()
var _input_controller = InputControllerScript.new()
var _hud = HudControllerScript.new()
var _interaction = InteractionControllerScript.new()
var _launcher = LauncherControllerScript.new()
var _session_bridge = null
var _last_result_text := ""
var _abandon_confirm_pending := false
var _ready_completed := false
var _snapshot_revision := 0
var _pending_collected_nodes: Dictionary = {}
var _resource_nodes: Array = []
var _launcher_entries: Array[Dictionary] = []
var _pending_navigation_state: Dictionary = {}
var _external_navigation_pending := false
var _bootstrap_loading := false
var _shell_overlay_paused := false

func _ready() -> void:
	name = "OpenworldForestScreen"
	_ensure_session_bridge()
	_load_launcher_entries()
	_runtime.configure(RulesetScript.player_initial_position())
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	set_process_input(true)
	_spawn_resources()
	_build_world_viewport()
	_hud.build(self, model)
	_connect_hud()
	_configure_input_controller()
	_configure_interaction_controller()
	_input_controller.ensure_input_actions()
	_layout_overlay()
	_update_labels()
	set_process(true)
	_ready_completed = true
	_apply_pending_navigation_state()
	call_deferred("_grab_openworld_focus")
	if integration_mode == "integrated_alpha":
		_set_bootstrap_loading(true)
		call_deferred("_resume_or_start_integrated_session")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_overlay()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_input_controller.reset_runtime_input()

func _input(event: InputEvent) -> void:
	if _shell_overlay_paused:
		_input_controller.reset_runtime_input()
		get_viewport().set_input_as_handled()
		return
	if _input_controller.handle_input(event, true):
		get_viewport().set_input_as_handled()

func get_model() -> Variant:
	return model

func get_player_position() -> Vector2:
	if _world != null and _world.has_method("get_player_position"):
		_runtime.update_player_position(_world.get_player_position())
	return _runtime.player_position

func get_inventory_sheet() -> Variant:
	return _hud.sheet

func get_openworld_world_2d() -> Variant:
	return _world

func get_joystick_vector_for_tests() -> Vector2:
	return _input_controller.joystick_vector()

func is_free_joystick_active_for_tests() -> bool:
	return _input_controller.free_pointer_active

func set_debug_joystick_vector(vector: Vector2) -> void:
	_input_controller.set_debug_vector(vector)

func set_player_position_for_tests(position: Vector2) -> void:
	_runtime.update_player_position(position)
	if _world != null and _world.has_method("set_player_position"):
		_world.set_player_position(position)

func launcher_entries_for_tests() -> Array[Dictionary]:
	return _launcher.entries()

func should_use_local_navigation_cache() -> bool:
	return integration_mode != "integrated_alpha"

func navigation_state_snapshot() -> Dictionary:
	if _world != null and _world.has_method("get_player_position"):
		_runtime.update_player_position(_world.get_player_position())
	return {
		"schema_version": "openworld_forest_launcher_navigation_v1",
		"mode_id": ModelScript.MODE_ID,
		"slice_id": ModelScript.SLICE_ID,
		"integration_mode": integration_mode,
		"player_position": _runtime.position_payload(),
		"runtime": {
			"session_seconds": _runtime.session_seconds,
			"walk_phase": _runtime.walk_phase,
			"node_state": _runtime.node_state_snapshot(),
		},
		"model_snapshot": model.snapshot(),
	}

func apply_navigation_state_snapshot(state: Dictionary) -> void:
	_pending_navigation_state = state.duplicate(true)
	if _ready_completed:
		_apply_pending_navigation_state()

func begin_free_joystick_for_tests(screen_position: Vector2) -> void:
	_input_controller.begin_free_for_tests(screen_position)

func drag_free_joystick_for_tests(screen_position: Vector2) -> void:
	_input_controller.drag_free_for_tests(screen_position)

func end_free_joystick_for_tests() -> void:
	_input_controller.end_free_for_tests()

func session_state_for_tests() -> String:
	return _session_state()

func abandon_confirm_pending_for_tests() -> bool:
	return _abandon_confirm_pending

func bootstrap_loading_for_tests() -> bool:
	return _bootstrap_loading

func shell_overlay_paused_for_tests() -> bool:
	return _shell_overlay_paused

func set_shell_overlay_paused(paused: bool) -> void:
	_shell_overlay_paused = paused
	_input_controller.reset_runtime_input()
	if _world != null and _world.has_method("set_movement_vector"):
		_world.set_movement_vector(Vector2.ZERO, 0.0)
	_update_labels()

func configure_integrated_alpha(client: Node, store: Node, token: String) -> void:
	var bridge = _ensure_session_bridge()
	bridge.configure(model, client, store, token, Callable(self, "_apply_remote_snapshot"))
	if bridge.is_active():
		integration_mode = "integrated_alpha"
		_set_bootstrap_loading(true)
		if is_inside_tree() and _ready_completed:
			call_deferred("_resume_or_start_integrated_session")

func _process(delta: float) -> void:
	if _shell_overlay_paused:
		if _world != null and _world.has_method("set_movement_vector"):
			_world.set_movement_vector(Vector2.ZERO, 0.0)
		_update_labels()
		return
	_runtime.advance_time(delta)
	if _world != null and _world.has_method("get_player_position"):
		_runtime.update_player_position(_world.get_player_position())
	var movement := _input_controller.movement_vector()
	var moved := movement.length() > 0.05
	if _world != null and _world.has_method("set_movement_vector"):
		_world.set_movement_vector(movement, model.current_speed())
	if moved:
		_runtime.advance_walk_phase(delta)
		_mark_guidance_step(1)
	_interaction.tick_collection(delta, moved)
	_update_labels()

func _ensure_session_bridge():
	if _session_bridge == null:
		_session_bridge = IntegratedSessionBridgeScript.new()
		_session_bridge.name = "OpenworldIntegratedSessionBridge"
		_session_bridge.configure(model, null, null, "", Callable(self, "_apply_remote_snapshot"))
		var callback := Callable(self, "_on_session_bridge_state_changed")
		if not _session_bridge.state_changed.is_connected(callback):
			_session_bridge.state_changed.connect(callback)
	if is_inside_tree() and _session_bridge.get_parent() == null:
		add_child(_session_bridge)
	return _session_bridge

func _session_store() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().root.get_node_or_null("SessionStore")

func _supabase_client() -> Node:
	if not is_inside_tree():
		return null
	return get_tree().root.get_node_or_null("SupabaseClient")

func _on_session_bridge_state_changed() -> void:
	_sync_session_bridge_debug_state()
	_abandon_confirm_pending = false if _session_state() != "synced" else _abandon_confirm_pending
	_update_labels()

func _build_world_viewport() -> void:
	_world_viewport_container = SubViewportContainer.new()
	_world_viewport_container.name = "OpenworldForestWorldView"
	_world_viewport_container.stretch = true
	_world_viewport_container.mouse_filter = Control.MOUSE_FILTER_STOP
	_world_viewport_container.gui_input.connect(_on_world_gui_input)
	_world_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_world_viewport_container.visible = not _bootstrap_loading
	add_child(_world_viewport_container)

	_world_viewport = SubViewport.new()
	_world_viewport.name = "OpenworldForestSubViewport"
	var initial_size := _screen_size()
	_world_viewport.size = Vector2i(maxi(1, int(initial_size.x)), maxi(1, int(initial_size.y)))
	_world_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_world_viewport_container.add_child(_world_viewport)

	_world = World2DScript.new()
	_world.configure(
		RulesetScript.world_size(),
		RulesetScript.chest_position(),
		_resource_fixtures(),
		RulesetScript.player_initial_position(),
		RulesetScript.obstacles(),
		RulesetScript.structures(),
		_launcher_entries
	)
	_world_viewport.add_child(_world)
	_runtime.update_player_position(_world.get_player_position())

func _connect_hud() -> void:
	_hud.deposit_requested.connect(_deposit_near_chest)
	_hud.craft_requested.connect(_craft_recipe)
	_hud.station_craft_requested.connect(_station_craft_recipe)
	_hud.complete_requested.connect(_show_result)
	_hud.abandon_requested.connect(_handle_abandon_requested)
	_hud.back_requested.connect(_handle_back_requested)
	_hud.guidance_next_requested.connect(_handle_guidance_next_requested)
	_hud.guidance_hide_requested.connect(_handle_guidance_hide_requested)
	_hud.guidance_reopen_requested.connect(_handle_guidance_reopen_requested)
	_hud.launcher_action_requested.connect(_handle_launcher_action_requested)
	_hud.sheet_tab_changed.connect(_handle_sheet_tab_changed)

func _configure_input_controller() -> void:
	_input_controller.configure(
		_hud.joystick,
		Callable(self, "_screen_size"),
		Callable(self, "_world_event_screen_position"),
		Callable(self, "_pointer_over_overlay"),
		Callable(self, "_grab_openworld_focus")
	)

func _configure_interaction_controller() -> void:
	_interaction.configure(
		model,
		_runtime,
		Callable(self, "_record_integrated_event_deferred"),
		Callable(self, "_uses_integrated_authority"),
		Callable(self, "_session_blocks_mutation"),
		Callable(self, "_near_chest"),
		Callable(self, "_ensure_session_bridge"),
		Callable(self, "_update_labels")
	)

func _layout_overlay() -> void:
	var screen_size := _screen_size()
	if _world_viewport_container != null:
		_world_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if _world != null and _world.has_method("set_viewport_size"):
		_world.set_viewport_size(screen_size)
	if _hud != null:
		_hud.layout(screen_size)

func _screen_size() -> Vector2:
	var next_size := size
	if next_size.x <= 0.0 or next_size.y <= 0.0:
		next_size = get_viewport_rect().size
	return Vector2(maxf(1.0, next_size.x), maxf(1.0, next_size.y))

func _spawn_resources() -> void:
	_runtime.reset_resources(_resource_fixtures())
	_sync_runtime_debug_state()

func _load_launcher_entries() -> void:
	_launcher_entries = LauncherCatalogScript.entries()
	_launcher.configure(_launcher_entries)

func _resource_fixtures() -> Array[Dictionary]:
	var fixtures := RulesetScript.resource_fixtures()
	if not fixtures.is_empty():
		return fixtures
	if _dev_resource_fallback_allowed():
		return RuntimeStateScript.dev_resource_fixtures()
	model.last_message = "Ruleset do Bosque indisponivel."
	return []

func _dev_resource_fallback_allowed() -> bool:
	return OS.has_feature("editor") \
		or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/openworld_dev_fixtures_enabled", false)) \
		or bool(ProjectSettings.get_setting("draxos_mobile/testing/openworld_dev_fixtures_enabled", false))

func _on_world_gui_input(event: InputEvent) -> void:
	if _handle_launcher_pointer_event(event):
		accept_event()
		return
	if _input_controller.handle_pointer_event(event, false):
		accept_event()

func _world_event_screen_position(local_position: Vector2) -> Vector2:
	if _world_viewport_container == null:
		return local_position
	return _world_viewport_container.position + local_position

func _pointer_over_overlay(screen_position: Vector2) -> bool:
	var global_position := get_global_rect().position + screen_position
	for node: Control in _hud.overlay_controls():
		if node == null:
			continue
		if not node.visible:
			continue
		if node.get_global_rect().has_point(global_position):
			return true
	return false

func _grab_openworld_focus() -> void:
	if is_inside_tree():
		grab_focus()

func _nearest_resource() -> Dictionary:
	return _runtime.nearest_resource(_ensure_session_bridge())

func _nearest_launcher_entry() -> Dictionary:
	if _world != null and _world.has_method("nearest_launcher"):
		var world_entry: Dictionary = _world.nearest_launcher(_runtime.player_position)
		if not world_entry.is_empty():
			return world_entry
	return _launcher.nearest_entry(_runtime.player_position)

func _near_chest() -> bool:
	if _world != null and _world.has_method("is_near_chest"):
		return _world.is_near_chest()
	return _runtime.player_position.distance_to(RulesetScript.chest_position()) <= RulesetScript.chest_radius()

func _near_fogueira() -> bool:
	if not model.has_upgrade("fogueira_estavel_1"):
		return false
	if _world != null and _world.has_method("is_near_structure"):
		return _world.is_near_structure("fogueira_estavel_1")
	return false

func _advance_nearby_collection(delta: float) -> void:
	_interaction.tick_collection(delta, false)
	_sync_runtime_debug_state()
	_sync_session_bridge_debug_state()

func _deposit_near_chest() -> void:
	if _shell_overlay_paused:
		return
	_interaction.deposit_near_chest()

func _craft_recipe(recipe_id: String) -> void:
	if _shell_overlay_paused:
		return
	_interaction.craft_recipe(recipe_id)

func _station_craft_recipe(recipe_id: String) -> void:
	if _shell_overlay_paused:
		return
	if recipe_id.strip_edges() == "":
		return
	if not model.has_upgrade("fogueira_estavel_1"):
		model.last_message = "Construa Fogueira estavel I antes de preparar pocoes."
		_update_labels()
		return
	if not _near_fogueira():
		model.last_message = "Aproxime-se da Fogueira para preparar pocoes."
		_update_labels()
		return
	var session_store := _session_store()
	var supabase_client := _supabase_client()
	if integration_mode != "integrated_alpha" or session_store == null or supabase_client == null or str(session_store.get("access_token")).strip_edges() == "":
		model.last_message = "Preparar pocoes exige sessao online."
		_update_labels()
		return
	var bridge = _ensure_session_bridge()
	if bridge.server_session_id() == "":
		await _resume_or_start_integrated_session()
	if bridge.server_session_id() == "":
		model.last_message = "Sessao online do Bosque indisponivel."
		_update_labels()
		return
	if _session_blocks_mutation():
		model.last_message = "Visita encerrada; reentre no Bosque para preparar pocoes."
		_update_labels()
		return
	if session_store.has_method("runtime_allows_gameplay_mutation") and not session_store.runtime_allows_gameplay_mutation():
		model.last_message = str(session_store.runtime_mutation_block_reason())
		_update_labels()
		return
	if bridge.has_pending_events():
		model.last_message = "Salvando Fogueira antes de preparar..." if model.has_upgrade("fogueira_estavel_1") else "Salvando Bosque antes de preparar..."
		_update_labels()
		var checkpoint_result: Dictionary = await _flush_pending_checkpoint_with_wait(bridge)
		if not bool(checkpoint_result.get("ok", false)):
			model.last_message = "Salve o checkpoint para preparar pocao."
			_update_labels()
			return
	if bridge.has_pending_events():
		model.last_message = "Checkpoint pendente; tente preparar novamente em instantes."
		_update_labels()
		return
	var station_context := {
		"mode_id": ModelScript.MODE_ID,
		"slice_id": ModelScript.SLICE_ID,
		"session_id": bridge.server_session_id(),
		"station_id": "fogueira_estavel_1",
		"expected_progress_revision": bridge.durable_progress_revision(),
	}
	var payload := {
		"recipe_id": recipe_id.strip_edges(),
		"quantity": 1,
		"station_context": station_context.duplicate(true),
	}
	var request: Dictionary = session_store.prepare_pending_mutation(
		"crafting/station-craft",
		"crafting:station:%s" % str(session_store.get("active_save_type")),
		"openworld_fogueira:forest",
		payload
	)
	model.last_message = "Preparando pocao..."
	_update_labels()
	var result: Dictionary = await supabase_client.station_craft_item(
		str(request.get("request_id", "")),
		recipe_id.strip_edges(),
		1,
		station_context,
		str(session_store.get("access_token")),
		str(request.get("request_hash", ""))
	)
	if not bool(result.get("ok", false)):
		session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", result)))
		model.last_message = _station_craft_error_text(result)
		_update_labels()
		return
	if not session_store.apply_crafting_result(result):
		session_store.fail_pending_mutation(str(request.get("request_id", "")), {"error": str(session_store.get("last_error"))})
		model.last_message = "Pocao preparada, mas o cache local precisa atualizar."
		_update_labels()
		return
	session_store.complete_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", result)))
	session_store.save_cache()
	bridge.apply_station_craft_ack(_as_dictionary(result.get("body", result)))
	model.last_message = "Pocao preparada."
	_update_labels()

func _update_labels() -> void:
	if _world == null:
		return
	if _world.has_method("get_player_position"):
		_runtime.update_player_position(_world.get_player_position())
	var nearest := _nearest_resource()
	var launcher_entry := _nearest_launcher_entry()
	var nearest_id := str(nearest.get("item_id", ""))
	var nearest_node_id := str(nearest.get("node_id", ""))
	var pocket_full := model.pocket_weight() >= model.capacity() - 0.001
	_world.set_state(
		_runtime.resource_nodes,
		nearest_node_id,
		model.collection_progress(),
		pocket_full,
		_runtime.walk_phase,
		model.upgrades,
		str(launcher_entry.get("entry_id", ""))
	)
	_hud.update(_view_state(nearest_id, launcher_entry))

func _view_state(nearest_id: String, launcher_entry: Dictionary = {}) -> Dictionary:
	var network_busy := _network_busy()
	var pending := _has_pending_integrated_events()
	var integrated := integration_mode == "integrated_alpha"
	var completed := _session_blocks_mutation()
	var can_complete := _can_complete_integrated()
	var near_chest := _near_chest()
	var has_pocket_items: bool = not model.pocket.is_empty()
	var deposit_available: bool = near_chest and has_pocket_items and not completed
	var deposit_tooltip := _deposit_tooltip(completed, pending, network_busy, near_chest, has_pocket_items)
	var complete_tooltip := _complete_tooltip(can_complete, pending, completed)
	var station_nearby := _near_fogueira()
	return {
		"integration_mode": integration_mode,
		"server_session_id": _server_session_id(),
		"session_state": _session_state(),
		"session_message": _session_message(),
		"network_busy": network_busy,
		"pending_summary": _pending_summary_text(),
		"result_text": _result_text(),
		"payload_preview": model.result_payload(_runtime.session_seconds),
		"can_complete": can_complete,
		"abandon_available": integrated and _server_session_id() != "" and not completed,
		"abandon_confirm_pending": _abandon_confirm_pending,
		"station_nearby": station_nearby,
		"crafting": _crafting_signature(),
		"resources": _resources_signature(),
		"world_context": WorldContextScript.build(model, _session_store(), _session_bridge, _session_state(), station_nearby),
		"mode_label": _mode_label(),
		"status_text": _status_text(nearest_id, completed, launcher_entry),
		"feedback_text": model.last_message,
		"launcher_entry": launcher_entry.duplicate(true),
		"pocket_weight": model.pocket_weight(),
		"capacity": model.capacity(),
		"deposit_available": deposit_available,
		"deposit_disabled": not deposit_available,
		"deposit_tooltip": deposit_tooltip,
		"complete_text": "Encerrar visita",
		"complete_disabled": network_busy or (integrated and not can_complete),
		"complete_tooltip": complete_tooltip,
		"guidance_visible": model.guidance_visible(),
		"guidance_text": model.guidance_text(),
		"guidance_step_text": _guidance_step_text(),
	}

func _mode_label() -> String:
	var state := _session_state()
	if integration_mode == "integrated_alpha" and state in ["starting", "synced", "pending", "resyncing", "completed"]:
		return "Bosque"
	return "Preview"

func _status_text(nearest_id: String, completed: bool, launcher_entry: Dictionary = {}) -> String:
	if completed:
		return "Visita encerrada"
	if not model.active_collection.is_empty():
		return "Coletando %s" % model.item_display_name(str(model.active_collection.get("item_id", "")))
	if model.pocket_weight() >= model.capacity() - 0.001:
		return "Bolso cheio; volte ao bau"
	if _near_chest() and not model.pocket.is_empty():
		return "Bau proximo; deposito pronto"
	if _session_state() in ["pending", "resyncing"]:
		var pending_text := _pending_summary_text()
		return pending_text if pending_text != "" else "Alteracoes locais pendentes"
	if _near_fogueira():
		return "Fogueira pronta"
	var first_craft := model.first_available_recipe_name()
	if first_craft != "":
		return "%s pronto no craft" % first_craft
	if nearest_id != "":
		return "Pare para coletar %s" % model.item_display_name(nearest_id)
	if _near_chest():
		return "Bau proximo"
	if not launcher_entry.is_empty():
		return "Entrada proxima: %s" % str(launcher_entry.get("label", "menu"))
	if model.pocket_load_ratio() >= ModelScript.LOAD_PENALTY_START_RATIO:
		return model.pocket_status_text()
	return "Explore o bosque"

func _session_message() -> String:
	match _session_state():
		"synced":
			return "Bosque salvo no servidor."
		"pending":
			return "Alteracoes locais pendentes; aguardando confirmacao do servidor."
		"resyncing":
			return "Recuperando checkpoint do Bosque."
		"completed":
			return "Visita encerrada. O resumo fica abaixo."
		"offline":
			return "Preview jogavel offline. Nenhuma recompensa sera aplicada."
		"blocked":
			return "Preview jogavel; a sessao online esta indisponivel agora."
		_:
			return "Preview jogavel; nenhuma recompensa sera aplicada."

func _deposit_tooltip(completed: bool, pending: bool, network_busy: bool, near_chest: bool, has_pocket_items: bool) -> String:
	if completed:
		return "Visita ja encerrada."
	if not near_chest:
		return "Aproxime-se do bau."
	if not has_pocket_items:
		return "Bolso vazio; colete algo antes."
	if network_busy:
		return "Depositar agora e manter salvamento em fila."
	if pending:
		return "Depositar agora; o Bosque confirma em ordem no servidor."
	return "Depositar tudo que esta no bolso."

func _complete_tooltip(can_complete: bool, pending: bool, completed: bool) -> String:
	if completed:
		return "Visita ja encerrada."
	if pending:
		return "Salve o checkpoint para encerrar com recompensa."
	if integration_mode == "integrated_alpha" and not can_complete:
		return "A sessao online ainda nao esta pronta."
	return "Encerrar visita e mostrar resumo."

func _show_result() -> void:
	if integration_mode == "integrated_alpha":
		await _complete_integrated_session()
		return
	_show_local_result()

func _show_local_result() -> void:
	_last_result_text = model.visit_summary_text(_runtime.session_seconds, "Sem recompensa.")
	model.last_message = "Visita encerrada em preview sem recompensa."
	_update_labels()

func _resume_or_start_integrated_session() -> void:
	if integration_mode != "integrated_alpha":
		return
	_set_bootstrap_loading(true)
	await _ensure_session_bridge().resume_or_start_session()
	_set_bootstrap_loading(false)
	_sync_session_bridge_debug_state()
	_update_labels()

func _complete_integrated_session() -> void:
	var bridge = _ensure_session_bridge()
	if bridge.network_busy() or bridge.is_completed():
		return
	if bridge.server_session_id() == "":
		await _resume_or_start_integrated_session()
	if bridge.server_session_id() == "":
		_show_local_result()
		return
	await bridge.complete_session(model.result_payload(maxf(_runtime.session_seconds, 5.0)))
	_abandon_confirm_pending = false
	_update_labels()

func _handle_abandon_requested() -> void:
	if integration_mode != "integrated_alpha" or _server_session_id() == "" or _session_blocks_mutation():
		return
	if not _abandon_confirm_pending:
		_abandon_confirm_pending = true
		model.last_message = "Confirme para descartar esta sessao online."
		_update_labels()
		return
	var result: Dictionary = await _ensure_session_bridge().abandon_session("player_abandoned")
	_abandon_confirm_pending = false
	if bool(result.get("ok", false)):
		model.reset()
		_spawn_resources()
		set_player_position_for_tests(RulesetScript.player_initial_position())
	_update_labels()

func _handle_back_requested() -> void:
	if integration_mode == "integrated_alpha" and _has_pending_integrated_events():
		model.last_message = "Salvando Bosque antes de sair..."
		_update_labels()
		var bridge = _ensure_session_bridge()
		var checkpoint_result: Dictionary = await _flush_pending_checkpoint_with_wait(bridge)
		if not bool(checkpoint_result.get("ok", true)) or _has_pending_integrated_events():
			model.last_message = "Alteracoes pendentes preservadas; o Bosque tentara sincronizar ao voltar."
			if _server_session_id() != "":
				bridge.record_exit_preserved()
			_update_labels()
			close_requested.emit()
			return
	if integration_mode == "integrated_alpha" and _server_session_id() != "" and not _session_blocks_mutation():
		model.last_message = "Sessao preservada por ate 2h para retomada."
		_ensure_session_bridge().record_exit_preserved()
	close_requested.emit()

func _handle_launcher_action_requested(action_id: String, entry_id: String) -> void:
	if _shell_overlay_paused:
		return
	var clean_action := action_id.strip_edges()
	var clean_entry := entry_id.strip_edges()
	if clean_action == "" or clean_entry == "":
		return
	if _external_navigation_pending:
		return
	var entry := _launcher.entry_by_id(clean_entry)
	if entry.is_empty() or str(entry.get("action_id", "")) != clean_action:
		return
	_external_navigation_pending = true
	await _prepare_launcher_navigation(entry)
	shell_action_requested.emit(clean_action, clean_entry)
	_external_navigation_pending = false

func _prepare_launcher_navigation(entry: Dictionary) -> void:
	var label := str(entry.get("label", entry.get("display_name", "menu"))).strip_edges()
	if label == "":
		label = "menu"
	if integration_mode == "integrated_alpha" and _has_pending_integrated_events():
		model.last_message = "Salvando Bosque antes de abrir %s..." % label
		_update_labels()
		var bridge = _ensure_session_bridge()
		var checkpoint_result: Dictionary = await _flush_pending_checkpoint_with_wait(bridge)
		if not bool(checkpoint_result.get("ok", true)) or _has_pending_integrated_events():
			model.last_message = "Alteracoes pendentes preservadas; abrindo %s." % label
			if _server_session_id() != "":
				bridge.record_exit_preserved()
			_update_labels()
			return
	if integration_mode == "integrated_alpha" and _server_session_id() != "" and not _session_blocks_mutation():
		_ensure_session_bridge().record_exit_preserved()
	model.last_message = "Abrindo %s..." % label
	_update_labels()

func _handle_launcher_pointer_event(event: InputEvent) -> bool:
	if _shell_overlay_paused:
		return true
	var local_position := Vector2.ZERO
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return false
		local_position = mouse_event.position
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if not touch_event.pressed:
			return false
		local_position = touch_event.position
	else:
		return false
	if _world == null or not _world.has_method("world_position_from_viewport_point"):
		return false
	var world_position: Vector2 = _world.world_position_from_viewport_point(local_position)
	var entry := _launcher.entry_at_world_position(world_position)
	if entry.is_empty():
		return false
	_handle_launcher_action_requested(str(entry.get("action_id", "")), str(entry.get("entry_id", "")))
	return true

func _flush_pending_checkpoint_with_wait(bridge: Variant, max_frames := 180) -> Dictionary:
	var checkpoint_result: Dictionary = {"ok": true}
	var wait_frames := 0
	while bridge != null and bridge.has_method("has_pending_events") and bridge.has_pending_events() and wait_frames < max_frames:
		var bridge_snapshot := Dictionary(bridge.debug_snapshot()) if bridge.has_method("debug_snapshot") else {}
		if bool(bridge_snapshot.get("checkpoint_in_flight", false)):
			await get_tree().process_frame
		else:
			checkpoint_result = await bridge.flush_checkpoint(true)
			if not bool(checkpoint_result.get("ok", false)) and not bool(checkpoint_result.get("busy", false)):
				break
			await get_tree().process_frame
		wait_frames += 1
	if bridge != null and bridge.has_method("has_pending_events") and bridge.has_pending_events() and bool(checkpoint_result.get("ok", true)):
		checkpoint_result = {"ok": false, "busy": true}
	return checkpoint_result

func _apply_remote_snapshot(snapshot_payload: Dictionary, apply_remote_position := true) -> void:
	_sync_runtime_server_time(snapshot_payload)
	if apply_remote_position:
		model.apply_snapshot(snapshot_payload)
	else:
		model.apply_authoritative_patch(snapshot_payload, true)
	_runtime.session_seconds = float(snapshot_payload.get("session_seconds", _runtime.session_seconds))
	var position := _as_dictionary(snapshot_payload.get("player_position", snapshot_payload.get("position", {})))
	if apply_remote_position and not position.is_empty():
		set_player_position_for_tests(Vector2(float(position.get("x", _runtime.player_position.x)), float(position.get("y", _runtime.player_position.y))))
	var node_state := _as_dictionary(snapshot_payload.get("node_state", {}))
	if node_state.is_empty():
		var durable_progress := _as_dictionary(snapshot_payload.get("durable_progress", snapshot_payload.get("durable_base", {})))
		node_state = _as_dictionary(durable_progress.get("node_state", {}))
	if not node_state.is_empty():
		_runtime.apply_node_state(node_state, _runtime.current_server_unix())
	else:
		_runtime.apply_collected_nodes(RulesetScript.collected_nodes_from_snapshot(snapshot_payload))
	_sync_runtime_debug_state()
	_update_labels()

func _apply_pending_navigation_state() -> void:
	if _pending_navigation_state.is_empty():
		return
	var state := _pending_navigation_state.duplicate(true)
	_pending_navigation_state = {}
	if str(state.get("schema_version", "")) != "openworld_forest_launcher_navigation_v1":
		return
	if str(state.get("mode_id", "")) != ModelScript.MODE_ID:
		return
	var model_snapshot := _as_dictionary(state.get("model_snapshot", {}))
	if not model_snapshot.is_empty():
		model.apply_snapshot(model_snapshot)
	var runtime_snapshot := _as_dictionary(state.get("runtime", {}))
	_runtime.session_seconds = float(runtime_snapshot.get("session_seconds", _runtime.session_seconds))
	_runtime.walk_phase = float(runtime_snapshot.get("walk_phase", _runtime.walk_phase))
	var node_state := _as_dictionary(runtime_snapshot.get("node_state", {}))
	if not node_state.is_empty():
		_runtime.apply_node_state(node_state, _runtime.current_server_unix())
	var position := _as_dictionary(state.get("player_position", {}))
	if not position.is_empty():
		set_player_position_for_tests(Vector2(float(position.get("x", _runtime.player_position.x)), float(position.get("y", _runtime.player_position.y))))
	if model.last_message.strip_edges() == "":
		model.last_message = "Bosque retomado."
	_sync_runtime_debug_state()
	_update_labels()

func _hydrate_integrated_session(session: Dictionary, apply_remote_position := true) -> bool:
	var hydrated: bool = _ensure_session_bridge().hydrate_session(session, apply_remote_position)
	_sync_session_bridge_debug_state()
	return hydrated

func _record_integrated_event_deferred(event_type: String, event_payload: Dictionary) -> void:
	_handle_guidance_action_for_event(event_type)
	if integration_mode != "integrated_alpha":
		return
	if event_type == "collect_start" or event_type == "collect_cancel":
		_sync_session_bridge_debug_state()
		return
	var payload := event_payload.duplicate(true)
	payload["client_position_revision"] = _runtime.local_position_revision
	_ensure_session_bridge().record_event_deferred(event_type, payload)
	_sync_session_bridge_debug_state()

func _handle_guidance_next_requested() -> void:
	if model.advance_guidance():
		_sync_guidance_update()
	_update_labels()

func _handle_guidance_hide_requested() -> void:
	if model.dismiss_guidance():
		_sync_guidance_update()
	_update_labels()

func _handle_guidance_reopen_requested() -> void:
	model.reopen_guidance()
	_sync_guidance_update()
	_update_labels()

func _handle_sheet_tab_changed(tab_id: String) -> void:
	if tab_id == "craft" or tab_id == "fogueira":
		_mark_guidance_step(5)
	elif tab_id == "session":
		_mark_guidance_step(6)

func _handle_guidance_action_for_event(event_type: String) -> void:
	match event_type:
		"collect_start":
			_mark_guidance_step(2)
		"collect_complete":
			_mark_guidance_step(3)
		"deposit_all":
			_mark_guidance_step(4)
		"craft":
			_mark_guidance_step(5)

func _mark_guidance_step(step: int) -> void:
	if model.mark_guidance_step(step):
		_sync_guidance_update()

func _sync_guidance_update() -> void:
	if integration_mode != "integrated_alpha" or not _uses_integrated_authority():
		return
	var payload := {
		"guidance": model.guidance_state(),
		"position": _runtime.position_payload(),
		"session_seconds": int(_runtime.session_seconds),
		"client_position_revision": _runtime.local_position_revision,
	}
	_ensure_session_bridge().record_event_deferred("guidance_update", payload)
	_sync_session_bridge_debug_state()

func _guidance_step_text() -> String:
	var state := model.guidance_state()
	var current_step := int(state.get("current_step", 1))
	if current_step > ModelScript.GUIDANCE_STEPS.size():
		return "Dicas do Bosque"
	return "Dica %d/%d" % [current_step, ModelScript.GUIDANCE_STEPS.size()]

func _format_seconds(seconds: float) -> String:
	var total := maxi(0, int(round(seconds)))
	var minutes := total / 60
	var remainder := total % 60
	if minutes <= 0:
		return "%ds" % remainder
	return "%dm%02ds" % [minutes, remainder]

func _can_complete_integrated() -> bool:
	if integration_mode != "integrated_alpha":
		return true
	return _ensure_session_bridge().can_complete()

func _uses_integrated_authority() -> bool:
	return integration_mode == "integrated_alpha" and _ensure_session_bridge().uses_authority()

func _session_blocks_mutation() -> bool:
	return _session_bridge != null and _session_bridge.has_method("is_completed") and _session_bridge.is_completed()

func _has_pending_integrated_events() -> bool:
	return _session_bridge != null and _session_bridge.has_pending_events()

func _pending_summary_text() -> String:
	return _ensure_session_bridge().pending_summary_text()

func _server_session_id() -> String:
	return _ensure_session_bridge().server_session_id()

func _network_busy() -> bool:
	return _session_bridge != null and _session_bridge.network_busy()

func _session_state() -> String:
	if integration_mode != "integrated_alpha":
		return "preview"
	return _ensure_session_bridge().session_state()

func _result_text() -> String:
	if integration_mode == "integrated_alpha":
		return _ensure_session_bridge().last_result_text
	return _last_result_text

func _sync_runtime_debug_state() -> void:
	_resource_nodes = _runtime.resource_nodes.duplicate(true)

func _sync_session_bridge_debug_state() -> void:
	if _session_bridge == null:
		_snapshot_revision = 0
		_pending_collected_nodes = {}
		return
	_sync_runtime_server_time()
	if _session_bridge.has_method("debug_snapshot"):
		var snapshot: Dictionary = _session_bridge.debug_snapshot()
		_snapshot_revision = int(snapshot.get("snapshot_revision", _snapshot_revision))
	if _session_bridge.has_method("pending_collected_nodes_for_tests"):
		_pending_collected_nodes = _session_bridge.pending_collected_nodes_for_tests()

func _set_bootstrap_loading(active: bool) -> void:
	_bootstrap_loading = active
	if _world_viewport_container != null:
		_world_viewport_container.visible = not active
	if active:
		model.last_message = "Carregando Bosque..."

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _sync_runtime_server_time(snapshot_payload: Dictionary = {}) -> void:
	if not snapshot_payload.is_empty() and snapshot_payload.has("server_time"):
		_runtime.sync_server_time(snapshot_payload.get("server_time"))
		return
	if _session_bridge != null and _session_bridge.has_method("server_now_unix"):
		_runtime.sync_server_time(_session_bridge.server_now_unix())

func _crafting_signature() -> Dictionary:
	var session_store := _session_store()
	if session_store != null and session_store.has_method("crafting_snapshot"):
		return _as_dictionary(session_store.call("crafting_snapshot"))
	return {}

func _resources_signature() -> Dictionary:
	var session_store := _session_store()
	if session_store != null and session_store.has_method("resources_snapshot"):
		return _as_dictionary(session_store.call("resources_snapshot"))
	return {}

func _station_craft_error_text(result: Dictionary) -> String:
	var body := _as_dictionary(result.get("body", result))
	var error := _as_dictionary(body.get("error", result.get("error", {})))
	var code := str(error.get("code", "")).strip_edges()
	match code:
		"STATION_NOT_BUILT":
			return "Construa Fogueira estavel I antes de preparar pocoes."
		"PROGRESS_REVISION_MISMATCH", "MODE_CHECKPOINT_REQUIRED":
			return "Bosque precisa salvar o checkpoint antes de preparar."
		"INSUFFICIENT_OPENWORLD_MATERIALS":
			return "Materiais insuficientes no Bau."
		"INSUFFICIENT_RESOURCES":
			return "Po de Osso insuficiente."
		"NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED":
			return "Sem conexao para preparar pocao agora."
		_:
			return str(error.get("message", "Nao foi possivel preparar a pocao."))
