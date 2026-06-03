class_name OpenworldForestScreen
extends Control

signal close_requested

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")
const World2DScript := preload("res://modes/openworld/openworld_forest_world_2d.gd")
const RuntimeStateScript := preload("res://modes/openworld/openworld_forest_runtime_state.gd")
const InputControllerScript := preload("res://modes/openworld/openworld_forest_input_controller.gd")
const HudControllerScript := preload("res://modes/openworld/openworld_forest_hud_controller.gd")
const InteractionControllerScript := preload("res://modes/openworld/openworld_forest_interaction_controller.gd")
const IntegratedSessionBridgeScript := preload("res://modes/openworld/openworld_integrated_session_bridge.gd")

var model = ModelScript.new()
var integration_mode := "dev_local"

var _world = null
var _world_viewport_container: SubViewportContainer
var _world_viewport: SubViewport
var _runtime: OpenworldForestRuntimeState = RuntimeStateScript.new()
var _input_controller = InputControllerScript.new()
var _hud = HudControllerScript.new()
var _interaction = InteractionControllerScript.new()
var _session_bridge = null
var _last_result_text := ""
var _abandon_confirm_pending := false
var _ready_completed := false

func _ready() -> void:
	name = "OpenworldForestScreen"
	_ensure_session_bridge()
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
	call_deferred("_grab_openworld_focus")
	if integration_mode == "integrated_alpha":
		call_deferred("_resume_or_start_integrated_session")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_overlay()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_input_controller.reset_runtime_input()

func _input(event: InputEvent) -> void:
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

func configure_integrated_alpha(client: Node, store: Node, token: String) -> void:
	var bridge = _ensure_session_bridge()
	bridge.configure(model, client, store, token, Callable(self, "_apply_remote_snapshot"))
	if bridge.is_active():
		integration_mode = "integrated_alpha"
		if is_inside_tree() and _ready_completed:
			call_deferred("_resume_or_start_integrated_session")

func _process(delta: float) -> void:
	_runtime.advance_time(delta)
	if _world != null and _world.has_method("get_player_position"):
		_runtime.update_player_position(_world.get_player_position())
	var movement := _input_controller.movement_vector()
	var moved := movement.length() > 0.05
	if _world != null and _world.has_method("set_movement_vector"):
		_world.set_movement_vector(movement, model.current_speed())
	if moved:
		_runtime.advance_walk_phase(delta)
	_interaction.tick_collection(delta, moved)
	if integration_mode == "integrated_alpha":
		_ensure_session_bridge().record_heartbeat_if_due(
			_runtime.session_seconds,
			RulesetScript.autosave_heartbeat_seconds(),
			_runtime.position_payload()
		)
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

func _on_session_bridge_state_changed() -> void:
	_abandon_confirm_pending = false if _session_state() != "synced" else _abandon_confirm_pending
	_update_labels()

func _build_world_viewport() -> void:
	_world_viewport_container = SubViewportContainer.new()
	_world_viewport_container.name = "OpenworldForestWorldView"
	_world_viewport_container.stretch = true
	_world_viewport_container.mouse_filter = Control.MOUSE_FILTER_STOP
	_world_viewport_container.gui_input.connect(_on_world_gui_input)
	_world_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
		RulesetScript.obstacles()
	)
	_world_viewport.add_child(_world)
	_runtime.update_player_position(_world.get_player_position())

func _connect_hud() -> void:
	_hud.deposit_requested.connect(_deposit_near_chest)
	_hud.craft_requested.connect(_craft_recipe)
	_hud.complete_requested.connect(_show_result)
	_hud.abandon_requested.connect(_handle_abandon_requested)
	_hud.back_requested.connect(_handle_back_requested)

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

func _near_chest() -> bool:
	if _world != null and _world.has_method("is_near_chest"):
		return _world.is_near_chest()
	return _runtime.player_position.distance_to(RulesetScript.chest_position()) <= RulesetScript.chest_radius()

func _deposit_near_chest() -> void:
	_interaction.deposit_near_chest()

func _craft_recipe(recipe_id: String) -> void:
	_interaction.craft_recipe(recipe_id)

func _update_labels() -> void:
	if _world == null:
		return
	if _world.has_method("get_player_position"):
		_runtime.update_player_position(_world.get_player_position())
	var nearest := _nearest_resource()
	var nearest_id := str(nearest.get("item_id", ""))
	var pocket_full := model.pocket_weight() >= model.capacity() - 0.001
	_world.set_state(_runtime.resource_nodes, nearest_id, model.collection_progress(), pocket_full, _runtime.walk_phase)
	_hud.update(_view_state(nearest_id))

func _view_state(nearest_id: String) -> Dictionary:
	var network_busy := _network_busy()
	var pending := _has_pending_integrated_events()
	var integrated := integration_mode == "integrated_alpha"
	var completed := _session_blocks_mutation()
	var can_complete := _can_complete_integrated()
	var near_chest := _near_chest()
	var deposit_available := near_chest and not network_busy and not pending and not completed
	var deposit_tooltip := "Sessao concluida." if completed else ("Sincronizacao em andamento." if pending else ("Depositar bolso no bau." if near_chest else "Aproxime-se do bau."))
	var complete_tooltip := _complete_tooltip(can_complete, pending, completed)
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
		"mode_label": _mode_label(),
		"status_text": _status_text(nearest_id, completed),
		"feedback_text": model.last_message,
		"pocket_weight": model.pocket_weight(),
		"capacity": model.capacity(),
		"deposit_available": deposit_available,
		"deposit_disabled": not deposit_available,
		"deposit_tooltip": deposit_tooltip,
		"complete_text": "Completar" if integrated else "Resultado preview",
		"complete_disabled": network_busy or (integrated and not can_complete),
		"complete_tooltip": complete_tooltip,
	}

func _mode_label() -> String:
	var state := _session_state()
	if integration_mode == "integrated_alpha" and state in ["starting", "synced", "pending", "resyncing", "completed"]:
		return "Bosque"
	return "Preview"

func _status_text(nearest_id: String, completed: bool) -> String:
	if completed:
		return "Sessao concluida"
	if _session_state() in ["pending", "resyncing"]:
		return "Sincronizando Bosque"
	if not model.active_collection.is_empty():
		return "Coletando %s" % model.item_display_name(str(model.active_collection.get("item_id", "")))
	if nearest_id != "":
		return "Pare para coletar %s" % model.item_display_name(nearest_id)
	if _near_chest():
		return "Bau proximo"
	return "Explore o bosque"

func _session_message() -> String:
	match _session_state():
		"synced":
			return "Voce pode voltar ao Refugio e retomar esta sessao por ate 2h."
		"pending":
			return "Aguarde a sincronizacao antes de completar."
		"resyncing":
			return "Resincronizando com o servidor."
		"completed":
			return "Resultado fechado para esta sessao."
		"offline":
			return "Preview jogavel; nenhuma recompensa sera aplicada."
		"blocked":
			return "Preview jogavel; sessao online indisponivel."
		_:
			return "Preview jogavel; nenhuma recompensa sera aplicada."

func _complete_tooltip(can_complete: bool, pending: bool, completed: bool) -> String:
	if completed:
		return "Sessao ja concluida."
	if pending:
		return "Aguarde a sincronizacao do Bosque."
	if integration_mode == "integrated_alpha" and not can_complete:
		return "A sessao online ainda nao esta pronta."
	return "Gerar resultado do Bosque."

func _show_result() -> void:
	if integration_mode == "integrated_alpha":
		await _complete_integrated_session()
		return
	_show_local_result()

func _show_local_result() -> void:
	var payload: Dictionary = model.result_payload(_runtime.session_seconds)
	_last_result_text = "Resultado preview: score=%s, items=%s. Sem recompensa." % [
		str(payload.get("activity_score", 0)),
		JSON.stringify(payload.get("deposited_items", {})),
	]
	model.last_message = "Resultado preview gerado sem recompensa."
	_update_labels()

func _resume_or_start_integrated_session() -> void:
	if integration_mode != "integrated_alpha":
		return
	await _ensure_session_bridge().resume_or_start_session()
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
		model.last_message = "Toque Confirmar abandono para descartar a sessao online."
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
	if integration_mode == "integrated_alpha" and _server_session_id() != "" and not _session_blocks_mutation():
		model.last_message = "Sessao preservada por ate 2h para retomada."
		_ensure_session_bridge().record_exit_preserved()
	close_requested.emit()

func _apply_remote_snapshot(snapshot_payload: Dictionary) -> void:
	model.apply_snapshot(snapshot_payload)
	_runtime.session_seconds = float(snapshot_payload.get("session_seconds", _runtime.session_seconds))
	var position := _as_dictionary(snapshot_payload.get("player_position", snapshot_payload.get("position", {})))
	if not position.is_empty():
		set_player_position_for_tests(Vector2(float(position.get("x", _runtime.player_position.x)), float(position.get("y", _runtime.player_position.y))))
	_runtime.apply_collected_nodes(RulesetScript.collected_nodes_from_snapshot(snapshot_payload))
	_update_labels()

func _record_integrated_event_deferred(event_type: String, event_payload: Dictionary) -> void:
	if integration_mode != "integrated_alpha":
		return
	_ensure_session_bridge().record_event_deferred(event_type, event_payload)

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

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}
