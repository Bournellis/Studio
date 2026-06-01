class_name OpenworldForestScreen
extends Control

signal close_requested

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const WorldViewScript := preload("res://modes/openworld/openworld_forest_world_view.gd")
const JoystickScript := preload("res://modes/openworld/openworld_virtual_joystick.gd")
const InventorySheetScript := preload("res://modes/openworld/openworld_inventory_sheet.gd")

const WORLD_SIZE := Vector2(960, 1400)
const CHEST_POSITION := Vector2(220, 250)
const CHEST_RADIUS := 88.0
const PLAYER_INITIAL_POSITION := Vector2(220, 330)
const PLAYER_WORLD_MARGIN := 28.0
const RESOURCE_FIXTURES := [
	{"item_id": "galho", "position": Vector2(330, 420)},
	{"item_id": "folha", "position": Vector2(410, 510)},
	{"item_id": "madeira", "position": Vector2(600, 440)},
	{"item_id": "pedra_pequena", "position": Vector2(260, 750)},
	{"item_id": "pedra", "position": Vector2(430, 900)},
	{"item_id": "cogumelo", "position": Vector2(690, 640)},
	{"item_id": "fungo", "position": Vector2(760, 820)},
	{"item_id": "inseto", "position": Vector2(530, 620)},
	{"item_id": "resina", "position": Vector2(620, 720)},
	{"item_id": "folha_seca", "position": Vector2(440, 1080)},
	{"item_id": "cinzas_preview", "position": Vector2(600, 1220)},
	{"item_id": "ossos_preview", "position": Vector2(710, 1260)},
	{"item_id": "po_osso_preview", "position": Vector2(790, 1160)},
]

var model = ModelScript.new()
var integration_mode := "dev_local"
var supabase_client: Node = null
var session_store: Node = null
var access_token := ""

var _world = null
var _joystick = null
var _sheet = null
var _hud_top: PanelContainer
var _weight_label: Label
var _status_label: Label
var _mode_label: Label
var _feedback_label: Label
var _inventory_button: Button
var _deposit_button: Button
var _complete_button: Button
var _back_button: Button
var _player_pos := PLAYER_INITIAL_POSITION
var _debug_joystick_vector := Vector2.ZERO
var _resource_nodes: Array[Dictionary] = []
var _session_seconds := 0.0
var _server_session_id := ""
var _network_busy := false
var _walk_phase := 0.0
var _last_result_text := ""
var _last_pending_request_id := ""

func _ready() -> void:
	name = "OpenworldForestScreen"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_spawn_resources()
	_build_ui()
	_update_labels()
	set_process(true)
	if integration_mode == "integrated_alpha":
		call_deferred("_start_integrated_session")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_overlay()

func get_model() -> Variant:
	return model

func get_player_position() -> Vector2:
	return _player_pos

func get_inventory_sheet() -> Variant:
	return _sheet

func set_debug_joystick_vector(vector: Vector2) -> void:
	_debug_joystick_vector = vector.limit_length(1.0)

func configure_integrated_alpha(client: Node, store: Node, token: String) -> void:
	supabase_client = client
	session_store = store
	access_token = token.strip_edges()
	if supabase_client != null and session_store != null and access_token != "":
		integration_mode = "integrated_alpha"

func _process(delta: float) -> void:
	_session_seconds += delta
	var movement := _movement_vector()
	var moved := movement.length() > 0.05
	if moved:
		_walk_phase += delta * 12.0
		_move_player(movement.normalized() * model.current_speed() * delta)
		model.advance_collection(0.0, true)
	else:
		_advance_nearby_collection(delta)
	_update_labels()

func _build_ui() -> void:
	_world = WorldViewScript.new()
	_world.configure(WORLD_SIZE, CHEST_POSITION)
	_world.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_world)

	_hud_top = PanelContainer.new()
	_hud_top.name = "OpenworldHudTop"
	_hud_top.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.052, 0.045, 0.82), Color(0.74, 0.64, 0.42, 0.36)))
	add_child(_hud_top)

	var hud_margin := MarginContainer.new()
	hud_margin.add_theme_constant_override("margin_left", 10)
	hud_margin.add_theme_constant_override("margin_right", 10)
	hud_margin.add_theme_constant_override("margin_top", 8)
	hud_margin.add_theme_constant_override("margin_bottom", 8)
	_hud_top.add_child(hud_margin)

	var hud_column := VBoxContainer.new()
	hud_column.add_theme_constant_override("separation", 2)
	hud_margin.add_child(hud_column)

	var hud_row := HBoxContainer.new()
	hud_row.add_theme_constant_override("separation", 8)
	hud_column.add_child(hud_row)

	_weight_label = _hud_label("")
	_weight_label.name = "OpenworldPocketWeight"
	_weight_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hud_row.add_child(_weight_label)

	_mode_label = _hud_label("")
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hud_row.add_child(_mode_label)

	_status_label = _hud_label("")
	_status_label.name = "OpenworldCollectState"
	hud_column.add_child(_status_label)

	_feedback_label = _hud_label("")
	_feedback_label.name = "OpenworldFeedback"
	_feedback_label.add_theme_color_override("font_color", Color(0.96, 0.86, 0.58))
	hud_column.add_child(_feedback_label)

	_joystick = JoystickScript.new()
	_joystick.name = "OpenworldVirtualJoystick"
	add_child(_joystick)

	var actions := HBoxContainer.new()
	actions.name = "OpenworldActionButtons"
	actions.add_theme_constant_override("separation", 6)
	actions.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(actions)

	_inventory_button = _action_button("Mochila")
	_inventory_button.name = "OpenworldInventoryButton"
	_inventory_button.pressed.connect(func() -> void:
		_sheet.open_sheet("pocket")
	)
	actions.add_child(_inventory_button)

	_deposit_button = _action_button("Depositar")
	_deposit_button.name = "OpenworldDepositButton"
	_deposit_button.pressed.connect(_deposit_near_chest)
	actions.add_child(_deposit_button)

	_complete_button = _action_button("Completar")
	_complete_button.name = "OpenworldCompleteButton"
	_complete_button.pressed.connect(_show_result)
	actions.add_child(_complete_button)

	_back_button = _action_button("Voltar")
	_back_button.name = "OpenworldBackButton"
	_back_button.pressed.connect(func() -> void:
		close_requested.emit()
	)
	actions.add_child(_back_button)

	_sheet = InventorySheetScript.new()
	_sheet.bind_model(model)
	_sheet.deposit_requested.connect(_deposit_near_chest)
	_sheet.craft_requested.connect(_craft_recipe)
	_sheet.complete_requested.connect(_show_result)
	add_child(_sheet)

	_layout_overlay()

func _layout_overlay() -> void:
	if _hud_top == null:
		return
	var safe_margin := 12.0
	var top_width := minf(size.x - safe_margin * 2.0, 460.0)
	_hud_top.position = Vector2(safe_margin, safe_margin)
	_hud_top.size = Vector2(top_width, 92.0)
	if _joystick != null:
		_joystick.size = JoystickScript.BASE_SIZE
		_joystick.position = Vector2(18.0, maxf(18.0, size.y - JoystickScript.BASE_SIZE.y - 24.0))
	var actions := get_node_or_null("OpenworldActionButtons") as HBoxContainer
	if actions != null:
		actions.size = Vector2(minf(380.0, size.x - 28.0), 48.0)
		actions.position = Vector2(maxf(14.0, size.x - actions.size.x - 14.0), maxf(16.0, size.y - 72.0))

func _hud_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.clip_text = true
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.94, 0.91, 0.80))
	return label

func _action_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(76, 48)
	button.tooltip_text = text
	return button

func _spawn_resources() -> void:
	_resource_nodes.clear()
	for fixture: Dictionary in RESOURCE_FIXTURES:
		_resource_nodes.append({
			"item_id": str(fixture.get("item_id", "")),
			"position": Vector2(fixture.get("position", Vector2.ZERO)),
			"collected": false,
		})

func _movement_vector() -> Vector2:
	if _debug_joystick_vector.length() > 0.01:
		return _debug_joystick_vector
	if _joystick == null:
		return Vector2.ZERO
	return _joystick.input_vector()

func _move_player(delta: Vector2) -> void:
	_player_pos += delta
	_player_pos.x = clampf(_player_pos.x, PLAYER_WORLD_MARGIN, WORLD_SIZE.x - PLAYER_WORLD_MARGIN)
	_player_pos.y = clampf(_player_pos.y, PLAYER_WORLD_MARGIN, WORLD_SIZE.y - PLAYER_WORLD_MARGIN)

func _advance_nearby_collection(delta: float) -> void:
	var nearest := _nearest_resource()
	if nearest.is_empty():
		if not model.active_collection.is_empty():
			model.cancel_collection("distance")
		return
	var item_id := str(nearest.get("item_id", ""))
	var distance := _player_pos.distance_to(Vector2(nearest.get("position", Vector2.ZERO)))
	if model.active_collection.is_empty():
		model.start_collection(item_id)
	var active_item := str(model.active_collection.get("item_id", ""))
	if active_item != item_id:
		model.cancel_collection("target_changed")
		model.start_collection(item_id)
	var result: Dictionary = model.advance_collection(delta, false, distance)
	if bool(result.get("completed", false)):
		nearest["collected"] = true

func _nearest_resource() -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry: Dictionary in _resource_nodes:
		if bool(entry.get("collected", false)):
			continue
		var distance := _player_pos.distance_to(Vector2(entry.get("position", Vector2.ZERO)))
		if distance <= ModelScript.COLLECTION_RADIUS and distance < best_distance:
			best = entry
			best_distance = distance
	return best

func _near_chest() -> bool:
	return _player_pos.distance_to(CHEST_POSITION) <= CHEST_RADIUS

func _deposit_near_chest() -> void:
	if not _near_chest():
		model.last_message = "Aproxime-se do bau para depositar."
		_update_labels()
		return
	model.deposit_all()
	_update_labels()

func _craft_recipe(recipe_id: String) -> void:
	model.craft(recipe_id)
	_update_labels()

func _update_labels() -> void:
	if _world == null:
		return
	var nearest := _nearest_resource()
	var nearest_id := str(nearest.get("item_id", ""))
	var pocket_full := model.pocket_weight() >= model.capacity() - 0.001
	_world.set_state(_player_pos, _resource_nodes, nearest_id, model.collection_progress(), pocket_full, _walk_phase)
	if _weight_label != null:
		_weight_label.text = "Bolso %.1f / %.1f" % [model.pocket_weight(), model.capacity()]
	if _mode_label != null:
		var online := "online" if integration_mode == "integrated_alpha" and _server_session_id != "" else integration_mode
		_mode_label.text = online
	if _status_label != null:
		if not model.active_collection.is_empty():
			_status_label.text = "Coletando %s" % model.item_display_name(str(model.active_collection.get("item_id", "")))
		elif nearest_id != "":
			_status_label.text = "Pare para coletar %s" % model.item_display_name(nearest_id)
		elif _near_chest():
			_status_label.text = "Bau proximo"
		else:
			_status_label.text = "Explore o bosque"
	if _feedback_label != null:
		_feedback_label.text = model.last_message
	if _deposit_button != null:
		_deposit_button.disabled = not _near_chest()
		_deposit_button.tooltip_text = "Depositar bolso no bau." if _near_chest() else "Aproxime-se do bau."
	if _complete_button != null:
		_complete_button.text = "Completar" if integration_mode == "integrated_alpha" else "Preview"
		_complete_button.disabled = _network_busy
	if _sheet != null:
		_sheet.render(
			integration_mode,
			_server_session_id,
			_network_busy,
			_last_pending_request_id,
			_last_result_text,
			model.result_payload(_session_seconds)
		)
		_sheet.set_deposit_available(_near_chest())

func _show_result() -> void:
	if integration_mode == "integrated_alpha":
		await _complete_integrated_session()
		return
	_show_local_result()

func _show_local_result() -> void:
	var payload: Dictionary = model.result_payload(_session_seconds)
	_last_result_text = "Resultado preview local: score=%s, items=%s" % [
		str(payload.get("activity_score", 0)),
		JSON.stringify(payload.get("deposited_items", {})),
	]
	model.last_message = "Resultado local gerado."
	_update_labels()

func _start_integrated_session() -> void:
	if _network_busy or integration_mode != "integrated_alpha" or _server_session_id != "":
		return
	if supabase_client == null or session_store == null or access_token == "":
		return
	_network_busy = true
	_update_labels()
	var request: Dictionary = session_store.prepare_pending_mutation(
		"modes/session/start",
		"mode:openworld:%s" % str(session_store.get("active_save_type")),
		"open_mode_shell:openworld",
		{
			"mode_id": ModelScript.MODE_ID,
			"slice_id": ModelScript.SLICE_ID,
		}
	)
	_last_pending_request_id = str(request.get("request_id", ""))
	var result: Dictionary = await supabase_client.start_mode_session(
		str(request.get("request_id", "")),
		ModelScript.MODE_ID,
		ModelScript.SLICE_ID,
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	var body := _response_body(result)
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		_server_session_id = str(_as_dictionary(body.get("session", {})).get("id", ""))
		_last_pending_request_id = ""
		_last_result_text = "Sessao integrada iniciada."
		model.last_message = "Sessao online pronta."
	else:
		_last_result_text = "Rede indisponivel: jogando local, start ficou pendente."
		model.last_message = "Modo local preservado."
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_update_labels()

func _complete_integrated_session() -> void:
	if _network_busy:
		return
	if _server_session_id == "":
		await _start_integrated_session()
	if _server_session_id == "":
		_show_local_result()
		return
	var payload: Dictionary = model.result_payload(maxf(_session_seconds, 5.0))
	payload["session_id"] = _server_session_id
	var request: Dictionary = session_store.prepare_pending_mutation(
		"modes/session/complete",
		"mode:openworld:%s" % str(session_store.get("active_save_type")),
		"open_mode_shell:openworld",
		payload
	)
	_last_pending_request_id = str(request.get("request_id", ""))
	_network_busy = true
	_update_labels()
	var result: Dictionary = await supabase_client.complete_mode_session(
		str(request.get("request_id", "")),
		_server_session_id,
		ModelScript.MODE_ID,
		payload,
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
		var body := _response_body(result)
		var reward := _as_dictionary(body.get("reward", {}))
		_last_pending_request_id = ""
		_last_result_text = "Recompensa aplicada: %s" % JSON.stringify(reward.get("resource_delta", {}))
		model.last_message = "Recompensa integrada aplicada."
	else:
		_last_result_text = "Resultado local preservado. Mutacao pendente: %s" % str(request.get("request_id", ""))
		model.last_message = "Resultado pendente para retry."
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_update_labels()

func _response_body(result: Dictionary) -> Dictionary:
	return _as_dictionary(result.get("body", result))

func _is_network_error(result: Dictionary) -> bool:
	var body := _response_body(result)
	var error := _as_dictionary(body.get("error", body))
	var code := str(error.get("code", result.get("code", "")))
	return code in ["NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED"]

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	return style
