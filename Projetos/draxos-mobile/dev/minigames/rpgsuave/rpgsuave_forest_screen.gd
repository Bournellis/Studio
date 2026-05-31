class_name RpgsuaveForestScreen
extends Control

signal close_requested

const ModelScript := preload("res://dev/minigames/rpgsuave/rpgsuave_forest_model.gd")

const BOARD_SIZE := Vector2(680, 420)
const PLAYER_SIZE := Vector2(24, 24)
const RESOURCE_SIZE := Vector2(36, 36)
const RESOURCE_COLORS := {
	"madeira": Color(0.42, 0.25, 0.12),
	"galho": Color(0.50, 0.33, 0.16),
	"folha": Color(0.25, 0.52, 0.28),
	"folha_seca": Color(0.58, 0.45, 0.23),
	"pedra": Color(0.45, 0.48, 0.50),
	"pedra_pequena": Color(0.60, 0.62, 0.63),
	"cogumelo": Color(0.63, 0.20, 0.28),
	"fungo": Color(0.40, 0.22, 0.52),
	"inseto": Color(0.18, 0.16, 0.13),
	"resina": Color(0.84, 0.55, 0.18),
	"cinzas_preview": Color(0.64, 0.64, 0.60),
	"ossos_preview": Color(0.78, 0.72, 0.58),
	"po_osso_preview": Color(0.86, 0.84, 0.72),
}

var model = ModelScript.new()
var integration_mode := "dev_local"
var supabase_client: Node = null
var session_store: Node = null
var access_token := ""
var _board: Control
var _player_marker: ColorRect
var _hint_label: Label
var _status_label: Label
var _pocket_label: Label
var _chest_label: Label
var _upgrade_label: Label
var _progress: ProgressBar
var _result_label: Label
var _finish_button: Button
var _craft_buttons: Dictionary = {}
var _resource_nodes: Array[Dictionary] = []
var _player_pos := Vector2(120, 210)
var _target_pos := Vector2.INF
var _session_seconds := 0.0
var _server_session_id := ""
var _network_busy := false

func _ready() -> void:
	name = "RpgsuaveForestScreen"
	_build_ui()
	_spawn_resources()
	_update_player_marker()
	_update_labels()
	set_process(true)
	if integration_mode == "integrated_alpha":
		call_deferred("_start_integrated_session")

func get_model() -> Variant:
	return model

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
		_move_player(movement.normalized() * model.current_speed() * delta)
		model.advance_collection(0.0, true)
	else:
		_advance_nearby_collection(delta)
	_update_player_marker()
	_update_labels()

func _build_ui() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	var title := Label.new()
	title.text = "Rpgsuave Bosque"
	title.add_theme_font_size_override("font_size", 20)
	root.add_child(title)

	_hint_label = Label.new()
	_hint_label.text = "Dev-only: ande, pare perto de recursos, espere a coleta, volte ao bau e craft upgrades locais."
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_hint_label)

	var split := HBoxContainer.new()
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_theme_constant_override("separation", 10)
	root.add_child(split)

	var board_panel := PanelContainer.new()
	board_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(board_panel)

	_board = Control.new()
	_board.name = "RpgsuaveForestBoard"
	_board.custom_minimum_size = BOARD_SIZE
	_board.clip_contents = true
	_board.gui_input.connect(_on_board_input)
	board_panel.add_child(_board)

	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.16, 0.11)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_board.add_child(bg)

	_add_zone(Vector2(24, 24), Vector2(160, 120), Color(0.18, 0.12, 0.08), "Bau")
	_add_zone(Vector2(420, 250), Vector2(210, 130), Color(0.13, 0.13, 0.13), "Cemiterio preview")

	_player_marker = ColorRect.new()
	_player_marker.name = "RpgsuavePlayer"
	_player_marker.color = Color(0.78, 0.13, 0.13)
	_player_marker.custom_minimum_size = PLAYER_SIZE
	_board.add_child(_player_marker)

	var side := VBoxContainer.new()
	side.custom_minimum_size.x = 260
	side.size_flags_horizontal = Control.SIZE_FILL
	side.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side.add_theme_constant_override("separation", 8)
	split.add_child(side)

	_status_label = _side_label(side, "")
	_progress = ProgressBar.new()
	_progress.min_value = 0.0
	_progress.max_value = 1.0
	side.add_child(_progress)
	_pocket_label = _side_label(side, "")
	_chest_label = _side_label(side, "")
	_upgrade_label = _side_label(side, "")

	var deposit := Button.new()
	deposit.text = "Depositar no Bau"
	deposit.pressed.connect(func() -> void:
		model.deposit_all()
		_update_labels()
	)
	side.add_child(deposit)

	for recipe_id: String in ModelScript.RECIPES.keys():
		var button := Button.new()
		button.text = str(ModelScript.RECIPES[recipe_id].get("display_name", recipe_id))
		button.pressed.connect(func(id := recipe_id) -> void:
			model.craft(id)
			_update_labels()
		)
		side.add_child(button)
		_craft_buttons[recipe_id] = button

	_finish_button = Button.new()
	_finish_button.text = "Gerar resultado local"
	_finish_button.pressed.connect(_show_result)
	side.add_child(_finish_button)

	var close := Button.new()
	close.text = "Voltar"
	close.pressed.connect(func() -> void:
		close_requested.emit()
	)
	side.add_child(close)

	_result_label = _side_label(side, "")

func _side_label(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _add_zone(position: Vector2, zone_size: Vector2, color: Color, label_text: String) -> void:
	var zone := ColorRect.new()
	zone.color = color
	zone.position = position
	zone.size = zone_size
	zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(zone)
	var label := Label.new()
	label.text = label_text
	label.position = position + Vector2(8, 8)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_board.add_child(label)

func _spawn_resources() -> void:
	var fixtures := [
		{"item_id": "galho", "position": Vector2(230, 72)},
		{"item_id": "folha", "position": Vector2(275, 116)},
		{"item_id": "madeira", "position": Vector2(335, 82)},
		{"item_id": "pedra_pequena", "position": Vector2(225, 250)},
		{"item_id": "pedra", "position": Vector2(302, 302)},
		{"item_id": "cogumelo", "position": Vector2(430, 108)},
		{"item_id": "fungo", "position": Vector2(510, 150)},
		{"item_id": "inseto", "position": Vector2(565, 82)},
		{"item_id": "resina", "position": Vector2(378, 208)},
		{"item_id": "folha_seca", "position": Vector2(470, 285)},
		{"item_id": "cinzas_preview", "position": Vector2(510, 315)},
		{"item_id": "ossos_preview", "position": Vector2(580, 312)},
		{"item_id": "po_osso_preview", "position": Vector2(610, 262)},
	]
	for fixture: Dictionary in fixtures:
		var item_id := str(fixture.get("item_id", ""))
		var node := Button.new()
		node.text = item_id.left(2)
		node.tooltip_text = model.item_display_name(item_id)
		node.position = fixture.get("position", Vector2.ZERO)
		node.size = RESOURCE_SIZE
		node.custom_minimum_size = RESOURCE_SIZE
		node.add_theme_color_override("font_color", Color.WHITE)
		var color := RESOURCE_COLORS.get(item_id, Color(0.4, 0.4, 0.4)) as Color
		node.add_theme_stylebox_override("normal", _resource_style(color, false))
		node.add_theme_stylebox_override("hover", _resource_style(color, true))
		node.add_theme_stylebox_override("pressed", _resource_style(color, true))
		node.pressed.connect(func(pos := Vector2(fixture.get("position", Vector2.ZERO))) -> void:
			_target_pos = pos
		)
		_board.add_child(node)
		_resource_nodes.append({"item_id": item_id, "position": fixture.get("position", Vector2.ZERO), "button": node, "collected": false})

func _resource_style(color: Color, hover: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color.lightened(0.14 if hover else 0.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.90, 0.82, 0.62, 0.75)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func _movement_vector() -> Vector2:
	var movement := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		movement.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		movement.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		movement.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		movement.y += 1.0
	if movement.length() > 0.05:
		_target_pos = Vector2.INF
		return movement
	if _target_pos != Vector2.INF:
		var delta := _target_pos - _player_pos
		if delta.length() <= 5.0:
			_target_pos = Vector2.INF
			return Vector2.ZERO
		return delta.normalized()
	return Vector2.ZERO

func _move_player(delta: Vector2) -> void:
	var board_size := _board.size
	if board_size.x <= 0.0 or board_size.y <= 0.0:
		board_size = BOARD_SIZE
	_player_pos += delta
	_player_pos.x = clampf(_player_pos.x, PLAYER_SIZE.x * 0.5, board_size.x - PLAYER_SIZE.x * 0.5)
	_player_pos.y = clampf(_player_pos.y, PLAYER_SIZE.y * 0.5, board_size.y - PLAYER_SIZE.y * 0.5)

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
		var button := nearest.get("button") as Button
		if button != null:
			button.visible = false

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

func _update_player_marker() -> void:
	if _player_marker == null:
		return
	_player_marker.position = _player_pos - PLAYER_SIZE * 0.5
	_player_marker.size = PLAYER_SIZE

func _update_labels() -> void:
	if _status_label == null:
		return
	if _hint_label != null:
		_hint_label.text = "Integrated Alpha: sessao server-authoritative; resultado local fica pendente se a rede cair." if integration_mode == "integrated_alpha" else "Dev-only: ande, pare perto de recursos, espere a coleta, volte ao bau e craft upgrades locais."
	if _finish_button != null:
		_finish_button.text = "Completar sessao" if integration_mode == "integrated_alpha" else "Gerar resultado local"
		_finish_button.disabled = _network_busy
	_status_label.text = model.last_message
	_progress.value = model.collection_progress()
	_pocket_label.text = "Bolso: %.1f / %.1f\n%s" % [model.pocket_weight(), model.capacity(), _inventory_lines(model.pocket)]
	_chest_label.text = "Bau local:\n%s" % _inventory_lines(model.chest)
	_upgrade_label.text = "Upgrades locais:\n%s" % _upgrade_lines()
	for recipe_id: String in _craft_buttons.keys():
		var button := _craft_buttons[recipe_id] as Button
		if button != null:
			button.disabled = not model.can_craft(recipe_id)

func _inventory_lines(source: Dictionary) -> String:
	if source.is_empty():
		return "-"
	var lines := PackedStringArray()
	var keys := PackedStringArray()
	for key: String in source.keys():
		keys.append(key)
	keys.sort()
	for key: String in keys:
		lines.append("%s x%d" % [model.item_display_name(key), int(source.get(key, 0))])
	return "\n".join(lines)

func _upgrade_lines() -> String:
	var active := PackedStringArray()
	for key: String in model.upgrades.keys():
		if bool(model.upgrades.get(key, false)):
			active.append(key)
	return "-" if active.is_empty() else "\n".join(active)

func _show_result() -> void:
	if integration_mode == "integrated_alpha":
		await _complete_integrated_session()
		return
	_show_local_result()

func _show_local_result() -> void:
	var payload: Dictionary = model.result_payload(_session_seconds)
	_result_label.text = "Resultado preview local:\nscore=%s\nitems=%s" % [
		str(payload.get("activity_score", 0)),
		JSON.stringify(payload.get("deposited_items", {})),
	]

func _start_integrated_session() -> void:
	if _network_busy or integration_mode != "integrated_alpha" or _server_session_id != "":
		return
	if supabase_client == null or session_store == null or access_token == "":
		return
	_network_busy = true
	_update_labels()
	var request: Dictionary = session_store.prepare_pending_mutation(
		"minigames/session/start",
		"minigame:rpgsuave:%s" % str(session_store.get("active_save_type")),
		"open_minigame_shell:rpgsuave",
		{
			"mode_id": ModelScript.MODE_ID,
			"slice_id": ModelScript.SLICE_ID,
		}
	)
	var result: Dictionary = await supabase_client.start_minigame_session(
		str(request.get("request_id", "")),
		ModelScript.MODE_ID,
		ModelScript.SLICE_ID,
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	var body := _response_body(result)
	if bool(result.get("ok", false)) and session_store.apply_minigame_result(result):
		_server_session_id = str(_as_dictionary(body.get("session", {})).get("id", ""))
		_result_label.text = "Sessao integrada iniciada."
	else:
		_result_label.text = "Rede indisponivel: jogando local, start ficou pendente."
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
		"minigames/session/complete",
		"minigame:rpgsuave:%s" % str(session_store.get("active_save_type")),
		"open_minigame_shell:rpgsuave",
		payload
	)
	_network_busy = true
	_update_labels()
	var result: Dictionary = await supabase_client.complete_minigame_session(
		str(request.get("request_id", "")),
		_server_session_id,
		ModelScript.MODE_ID,
		payload,
		access_token,
		str(request.get("request_hash", ""))
	)
	_network_busy = false
	if bool(result.get("ok", false)) and session_store.apply_minigame_result(result):
		var body := _response_body(result)
		var reward := _as_dictionary(body.get("reward", {}))
		_result_label.text = "Recompensa aplicada:\n%s" % JSON.stringify(reward.get("resource_delta", {}))
	else:
		_result_label.text = "Resultado local preservado. Mutacao pendente para retry:\n%s" % str(request.get("request_id", ""))
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

func _on_board_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			_target_pos = mouse.position
