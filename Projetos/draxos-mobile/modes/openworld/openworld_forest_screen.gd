class_name OpenworldForestScreen
extends Control

signal close_requested

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const RulesetScript := preload("res://modes/openworld/openworld_forest_ruleset.gd")
const World2DScript := preload("res://modes/openworld/openworld_forest_world_2d.gd")
const JoystickScript := preload("res://modes/openworld/openworld_virtual_joystick.gd")
const InventorySheetScript := preload("res://modes/openworld/openworld_inventory_sheet.gd")

const WORLD_SIZE := Vector2(960, 1400)
const CHEST_POSITION := Vector2(220, 250)
const CHEST_RADIUS := 88.0
const PLAYER_INITIAL_POSITION := Vector2(220, 330)
const PLAYER_WORLD_MARGIN := 28.0
const EVENT_RETRY_SECONDS := 1.25
const KEYBOARD_ACTION_KEYS := {
	"openworld_move_left": [KEY_A, KEY_LEFT],
	"openworld_move_right": [KEY_D, KEY_RIGHT],
	"openworld_move_up": [KEY_W, KEY_UP],
	"openworld_move_down": [KEY_S, KEY_DOWN],
}
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
var _world_viewport_container: SubViewportContainer
var _world_viewport: SubViewport
var _joystick = null
var _sheet = null
var _hud_top: PanelContainer
var _actions: HBoxContainer
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
var _snapshot_revision := 0
var _server_synced := false
var _network_busy := false
var _pending_event_count := 0
var _event_queue: Array[Dictionary] = []
var _event_flush_active := false
var _event_retry_scheduled := false
var _pending_collected_nodes: Dictionary = {}
var _last_heartbeat_seconds := 0.0
var _walk_phase := 0.0
var _last_result_text := ""
var _last_pending_request_id := ""
var _active_collection_node_id := ""
var _free_pointer_active := false
var _free_pointer_index := -999
var _keyboard_action_down := {}

func _ready() -> void:
	name = "OpenworldForestScreen"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	set_process_input(true)
	_ensure_input_actions()
	_reset_keyboard_state()
	_spawn_resources()
	_build_ui()
	_update_labels()
	set_process(true)
	call_deferred("_grab_openworld_focus")
	if integration_mode == "integrated_alpha":
		call_deferred("_resume_or_start_integrated_session")

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_overlay()
	elif what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_reset_runtime_input()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if _handle_keyboard_event(event as InputEventKey):
			get_viewport().set_input_as_handled()
		return
	if _handle_pointer_event(event, true):
		get_viewport().set_input_as_handled()

func get_model() -> Variant:
	return model

func get_player_position() -> Vector2:
	if _world != null and _world.has_method("get_player_position"):
		_player_pos = _world.get_player_position()
	return _player_pos

func get_inventory_sheet() -> Variant:
	return _sheet

func get_openworld_world_2d() -> Variant:
	return _world

func get_joystick_vector_for_tests() -> Vector2:
	if _joystick == null:
		return Vector2.ZERO
	return _joystick.input_vector()

func is_free_joystick_active_for_tests() -> bool:
	return _free_pointer_active

func set_debug_joystick_vector(vector: Vector2) -> void:
	_debug_joystick_vector = vector.limit_length(1.0)

func set_player_position_for_tests(position: Vector2) -> void:
	_player_pos = position
	if _world != null and _world.has_method("set_player_position"):
		_world.set_player_position(position)

func begin_free_joystick_for_tests(screen_position: Vector2) -> void:
	_begin_free_joystick(screen_position, -2)

func drag_free_joystick_for_tests(screen_position: Vector2) -> void:
	_drag_free_joystick(screen_position, -2)

func end_free_joystick_for_tests() -> void:
	_end_free_joystick(-2)

func configure_integrated_alpha(client: Node, store: Node, token: String) -> void:
	supabase_client = client
	session_store = store
	access_token = token.strip_edges()
	if supabase_client != null and session_store != null and access_token != "":
		integration_mode = "integrated_alpha"

func _process(delta: float) -> void:
	_session_seconds += delta
	if _world != null and _world.has_method("get_player_position"):
		_player_pos = _world.get_player_position()
	var movement := _movement_vector()
	var moved := movement.length() > 0.05
	if _world != null and _world.has_method("set_movement_vector"):
		_world.set_movement_vector(movement, model.current_speed())
	if moved:
		_walk_phase += delta * 12.0
		if not model.active_collection.is_empty():
			model.advance_collection(0.0, true)
			_active_collection_node_id = ""
			_record_integrated_event_deferred("collect_cancel", {
				"reason": "moved",
				"position": _position_payload(),
				"session_seconds": int(_session_seconds),
			})
	else:
		_advance_nearby_collection(delta)
	if integration_mode == "integrated_alpha" and _server_session_id != "" and _server_synced:
		if _session_seconds - _last_heartbeat_seconds >= RulesetScript.autosave_heartbeat_seconds():
			_last_heartbeat_seconds = _session_seconds
			_record_integrated_event_deferred("move_heartbeat", {
				"position": _position_payload(),
				"session_seconds": int(_session_seconds),
			})
	_update_labels()

func _build_ui() -> void:
	_build_world_viewport()

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
	_joystick.visible = false
	add_child(_joystick)

	_actions = HBoxContainer.new()
	_actions.name = "OpenworldActionButtons"
	_actions.add_theme_constant_override("separation", 6)
	_actions.size_flags_horizontal = Control.SIZE_SHRINK_END
	add_child(_actions)

	_inventory_button = _action_button("Mochila")
	_inventory_button.name = "OpenworldInventoryButton"
	_inventory_button.pressed.connect(func() -> void:
		_sheet.open_sheet("pocket")
	)
	_actions.add_child(_inventory_button)

	_deposit_button = _action_button("Depositar")
	_deposit_button.name = "OpenworldDepositButton"
	_deposit_button.pressed.connect(_deposit_near_chest)
	_actions.add_child(_deposit_button)

	_complete_button = _action_button("Completar")
	_complete_button.name = "OpenworldCompleteButton"
	_complete_button.pressed.connect(_show_result)
	_actions.add_child(_complete_button)

	_back_button = _action_button("Voltar")
	_back_button.name = "OpenworldBackButton"
	_back_button.pressed.connect(func() -> void:
		close_requested.emit()
	)
	_actions.add_child(_back_button)

	_sheet = InventorySheetScript.new()
	_sheet.bind_model(model)
	_sheet.deposit_requested.connect(_deposit_near_chest)
	_sheet.craft_requested.connect(_craft_recipe)
	_sheet.complete_requested.connect(_show_result)
	add_child(_sheet)

	_layout_overlay()

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
	_world.configure(RulesetScript.world_size(), RulesetScript.chest_position(), _resource_fixtures(), RulesetScript.player_initial_position())
	_world_viewport.add_child(_world)
	_player_pos = _world.get_player_position()

func _layout_overlay() -> void:
	if _hud_top == null:
		return
	var screen_size := _screen_size()
	if _world_viewport_container != null:
		_world_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if _world != null and _world.has_method("set_viewport_size"):
		_world.set_viewport_size(screen_size)
	var safe_margin := 12.0
	var top_width := minf(screen_size.x - safe_margin * 2.0, 460.0)
	_hud_top.position = Vector2(safe_margin, safe_margin)
	_hud_top.size = Vector2(top_width, 92.0)
	if _joystick != null:
		_joystick.size = JoystickScript.BASE_SIZE
		if not _joystick.is_active():
			_joystick.visible = false
	if _actions != null:
		_actions.size = Vector2(minf(380.0, screen_size.x - 28.0), 48.0)
		_actions.position = Vector2(maxf(14.0, screen_size.x - _actions.size.x - 14.0), maxf(16.0, screen_size.y - 72.0))

func _screen_size() -> Vector2:
	var next_size := size
	if next_size.x <= 0.0 or next_size.y <= 0.0:
		next_size = get_viewport_rect().size
	return Vector2(maxf(1.0, next_size.x), maxf(1.0, next_size.y))

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
	for fixture: Dictionary in _resource_fixtures():
		_resource_nodes.append({
			"node_id": str(fixture.get("node_id", "")),
			"item_id": str(fixture.get("item_id", "")),
			"position": Vector2(fixture.get("position", Vector2.ZERO)),
			"quantity": maxi(1, int(fixture.get("quantity", 1))),
			"collected": false,
		})

func _resource_fixtures() -> Array[Dictionary]:
	var fixtures := RulesetScript.resource_fixtures()
	return fixtures if not fixtures.is_empty() else RESOURCE_FIXTURES.duplicate(true)

func _movement_vector() -> Vector2:
	var movement := _keyboard_vector() + _debug_joystick_vector
	if _joystick != null:
		movement += _joystick.input_vector()
	return movement.limit_length(1.0)

func _keyboard_vector() -> Vector2:
	return Vector2(
		_action_strength("openworld_move_right") - _action_strength("openworld_move_left"),
		_action_strength("openworld_move_down") - _action_strength("openworld_move_up")
	).limit_length(1.0)

func _ensure_input_actions() -> void:
	for action_name: String in KEYBOARD_ACTION_KEYS.keys():
		_ensure_key_action(action_name, KEYBOARD_ACTION_KEYS[action_name])

func _ensure_key_action(action_name: String, keycodes: Array) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name, 0.5)
	for keycode: int in keycodes:
		if not _input_action_has_key(action_name, keycode, true):
			var physical_event := InputEventKey.new()
			physical_event.physical_keycode = keycode
			InputMap.action_add_event(action_name, physical_event)
		if not _input_action_has_key(action_name, keycode, false):
			var key_event := InputEventKey.new()
			key_event.keycode = keycode
			InputMap.action_add_event(action_name, key_event)

func _input_action_has_key(action_name: String, keycode: int, physical: bool) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if not event is InputEventKey:
			continue
		var key_event := event as InputEventKey
		if physical and key_event.physical_keycode == keycode:
			return true
		if not physical and key_event.keycode == keycode:
			return true
	return false

func _on_world_gui_input(event: InputEvent) -> void:
	if _handle_pointer_event(event, false):
		accept_event()

func _world_event_screen_position(local_position: Vector2) -> Vector2:
	if _world_viewport_container == null:
		return local_position
	return _world_viewport_container.position + local_position

func _event_screen_position(event_position: Vector2, already_screen_position: bool) -> Vector2:
	if already_screen_position:
		return event_position
	return _world_event_screen_position(event_position)

func _handle_pointer_event(event: InputEvent, already_screen_position: bool) -> bool:
	if _joystick == null:
		return false
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		var touch_position := _event_screen_position(touch.position, already_screen_position)
		if touch.pressed:
			if _free_pointer_active or _pointer_over_overlay(touch_position):
				return false
			_begin_free_joystick(touch_position, touch.index)
			return true
		if _free_pointer_active and _free_pointer_index == touch.index:
			_end_free_joystick(touch.index)
			return true
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _free_pointer_active and _free_pointer_index == drag.index:
			_drag_free_joystick(_event_screen_position(drag.position, already_screen_position), drag.index)
			return true
	elif event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.button_index != MOUSE_BUTTON_LEFT:
			return false
		var mouse_position := _event_screen_position(mouse.position, already_screen_position)
		if mouse.pressed:
			if _free_pointer_active or _pointer_over_overlay(mouse_position):
				return false
			_begin_free_joystick(mouse_position, -2)
			return true
		if _free_pointer_active and _free_pointer_index == -2:
			_end_free_joystick(-2)
			return true
	elif event is InputEventMouseMotion and _free_pointer_active and _free_pointer_index == -2:
		_drag_free_joystick(_event_screen_position((event as InputEventMouseMotion).position, already_screen_position), -2)
		return true
	return false

func _begin_free_joystick(screen_position: Vector2, pointer_index: int) -> void:
	if _joystick == null:
		return
	_grab_openworld_focus()
	_free_pointer_active = true
	_free_pointer_index = pointer_index
	_joystick.begin_free(_clamp_joystick_screen_position(screen_position), pointer_index)

func _drag_free_joystick(screen_position: Vector2, pointer_index: int) -> void:
	if not _free_pointer_active or _free_pointer_index != pointer_index:
		return
	_joystick.drag_free(screen_position, pointer_index)

func _end_free_joystick(pointer_index: int) -> void:
	if not _free_pointer_active or _free_pointer_index != pointer_index:
		return
	_joystick.end_free(pointer_index)
	_free_pointer_active = false
	_free_pointer_index = -999

func _clamp_joystick_screen_position(screen_position: Vector2) -> Vector2:
	var half_size := JoystickScript.BASE_SIZE * 0.5
	var screen_size := _screen_size()
	return Vector2(
		clampf(screen_position.x, half_size.x, maxf(half_size.x, screen_size.x - half_size.x)),
		clampf(screen_position.y, half_size.y, maxf(half_size.y, screen_size.y - half_size.y))
	)

func _grab_openworld_focus() -> void:
	if is_inside_tree():
		grab_focus()

func _reset_runtime_input() -> void:
	_reset_keyboard_state()
	if _joystick != null:
		_joystick.end_free(-999)
	_free_pointer_active = false
	_free_pointer_index = -999

func _reset_keyboard_state() -> void:
	_keyboard_action_down.clear()
	for action_name: String in KEYBOARD_ACTION_KEYS.keys():
		_keyboard_action_down[action_name] = false

func _action_strength(action_name: String) -> float:
	var input_strength := Input.get_action_strength(action_name)
	var manual_strength := 1.0 if bool(_keyboard_action_down.get(action_name, false)) else 0.0
	return maxf(input_strength, manual_strength)

func _handle_keyboard_event(event: InputEventKey) -> bool:
	if event.echo:
		return false
	var action_name := _keyboard_action_for_event(event)
	if action_name == "":
		return false
	_keyboard_action_down[action_name] = event.pressed
	return true

func _keyboard_action_for_event(event: InputEventKey) -> String:
	for action_name: String in KEYBOARD_ACTION_KEYS.keys():
		for keycode: int in KEYBOARD_ACTION_KEYS[action_name]:
			if _key_event_has_key(event, keycode):
				return action_name
	return ""

func _key_event_has_key(event: InputEventKey, keycode: int) -> bool:
	return event.keycode == keycode or event.physical_keycode == keycode or event.key_label == keycode

func _pointer_over_overlay(screen_position: Vector2) -> bool:
	var global_position := get_global_rect().position + screen_position
	for node: Control in [_hud_top, _actions, _sheet, _joystick]:
		if node == null:
			continue
		if not node.visible:
			continue
		if node.get_global_rect().has_point(global_position):
			return true
	return false

func _move_player(delta: Vector2) -> void:
	_player_pos += delta
	var world_size := RulesetScript.world_size()
	var margin := RulesetScript.player_margin()
	_player_pos.x = clampf(_player_pos.x, margin, world_size.x - margin)
	_player_pos.y = clampf(_player_pos.y, margin, world_size.y - margin)

func _advance_nearby_collection(delta: float) -> void:
	var nearest := _nearest_resource()
	if nearest.is_empty():
		if not model.active_collection.is_empty():
			model.cancel_collection("distance")
			_active_collection_node_id = ""
			_record_integrated_event_deferred("collect_cancel", {
				"reason": "distance",
				"position": _position_payload(),
				"session_seconds": int(_session_seconds),
			})
		return
	var item_id := str(nearest.get("item_id", ""))
	var node_id := str(nearest.get("node_id", ""))
	var distance := _player_pos.distance_to(Vector2(nearest.get("position", Vector2.ZERO)))
	if model.active_collection.is_empty():
		model.start_collection(item_id)
		_active_collection_node_id = node_id
		_record_integrated_event_deferred("collect_start", {
			"node_id": node_id,
			"item_id": item_id,
			"position": _position_payload(),
			"session_seconds": int(_session_seconds),
		})
	var active_item := str(model.active_collection.get("item_id", ""))
	if active_item != item_id or _active_collection_node_id != node_id:
		model.cancel_collection("target_changed")
		_record_integrated_event_deferred("collect_cancel", {
			"reason": "target_changed",
			"position": _position_payload(),
			"session_seconds": int(_session_seconds),
		})
		model.start_collection(item_id)
		_active_collection_node_id = node_id
		_record_integrated_event_deferred("collect_start", {
			"node_id": node_id,
			"item_id": item_id,
			"position": _position_payload(),
			"session_seconds": int(_session_seconds),
		})
	var authoritative_online := _uses_integrated_authority()
	var result: Dictionary = model.advance_collection(delta, false, distance, not authoritative_online)
	if bool(result.get("completed", false)):
		nearest["collected"] = true
		if authoritative_online:
			_pending_collected_nodes[node_id] = true
		_active_collection_node_id = ""
		_record_integrated_event_deferred("collect_complete", {
			"node_id": node_id,
			"item_id": item_id,
			"position": _position_payload(),
			"session_seconds": int(_session_seconds),
		})

func _nearest_resource() -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry: Dictionary in _resource_nodes:
		if bool(entry.get("collected", false)):
			continue
		if bool(_pending_collected_nodes.get(str(entry.get("node_id", "")), false)):
			continue
		var distance := _player_pos.distance_to(Vector2(entry.get("position", Vector2.ZERO)))
		if distance <= RulesetScript.collection_radius() and distance < best_distance:
			best = entry
			best_distance = distance
	return best

func _near_chest() -> bool:
	if _world != null and _world.has_method("is_near_chest"):
		return _world.is_near_chest()
	return _player_pos.distance_to(RulesetScript.chest_position()) <= RulesetScript.chest_radius()

func _deposit_near_chest() -> void:
	if not _near_chest():
		model.last_message = "Aproxime-se do bau para depositar."
		_update_labels()
		return
	if _uses_integrated_authority():
		model.last_message = "Depositando no servidor..."
		_record_integrated_event_deferred("deposit_all", {
			"position": _position_payload(),
			"session_seconds": int(_session_seconds),
		})
		_update_labels()
		return
	model.deposit_all()
	_record_integrated_event_deferred("deposit_all", {
		"position": _position_payload(),
		"session_seconds": int(_session_seconds),
	})
	_update_labels()

func _craft_recipe(recipe_id: String) -> void:
	if _uses_integrated_authority():
		if not model.can_craft(recipe_id):
			model.last_message = "Materiais insuficientes ou upgrade ja ativo."
			_update_labels()
			return
		model.last_message = "Craft aguardando servidor..."
		_record_integrated_event_deferred("craft", {
			"recipe_id": recipe_id,
			"position": _position_payload(),
			"session_seconds": int(_session_seconds),
		})
		_update_labels()
		return
	model.craft(recipe_id)
	_record_integrated_event_deferred("craft", {
		"recipe_id": recipe_id,
		"position": _position_payload(),
		"session_seconds": int(_session_seconds),
	})
	_update_labels()

func _update_labels() -> void:
	if _world == null:
		return
	if _world.has_method("get_player_position"):
		_player_pos = _world.get_player_position()
	var nearest := _nearest_resource()
	var nearest_id := str(nearest.get("item_id", ""))
	var pocket_full := model.pocket_weight() >= model.capacity() - 0.001
	_world.set_state(_resource_nodes, nearest_id, model.collection_progress(), pocket_full, _walk_phase)
	if _weight_label != null:
		_weight_label.text = "Bolso %.1f / %.1f" % [model.pocket_weight(), model.capacity()]
	if _mode_label != null:
		_mode_label.text = "Bosque" if integration_mode == "integrated_alpha" and _server_session_id != "" else "Preview"
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
		_deposit_button.disabled = not _near_chest() or _network_busy or _has_pending_integrated_events()
		_deposit_button.tooltip_text = "Sincronizacao em andamento." if _has_pending_integrated_events() else ("Depositar bolso no bau." if _near_chest() else "Aproxime-se do bau.")
	if _complete_button != null:
		_complete_button.text = "Completar" if integration_mode == "integrated_alpha" else "Preview"
		_complete_button.disabled = _network_busy or (integration_mode == "integrated_alpha" and not _can_complete_integrated())
	if _sheet != null:
		_sheet.render(
			integration_mode,
			_server_session_id,
			_network_busy or _has_pending_integrated_events(),
			_pending_summary_text(),
			_last_result_text,
			model.result_payload(_session_seconds)
		)
		_sheet.set_deposit_available(_near_chest() and not _has_pending_integrated_events())

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

func _resume_or_start_integrated_session() -> void:
	if _network_busy or integration_mode != "integrated_alpha" or _server_session_id != "":
		return
	if supabase_client == null or session_store == null or access_token == "":
		model.last_message = "Preview sem recompensa."
		_server_synced = false
		_update_labels()
		return
	_network_busy = true
	_update_labels()
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, access_token)
	_network_busy = false
	if bool(state_result.get("ok", false)):
		var body := _response_body(state_result)
		var active_session := _as_dictionary(body.get("active_session", {}))
		if not active_session.is_empty() and _hydrate_integrated_session(active_session):
			_last_result_text = "Bosque retomado."
			model.last_message = "Bosque retomado."
			_update_labels()
			return
	elif not _is_network_error(state_result):
		model.last_message = "Preview sem recompensa."
	_update_labels()
	await _start_integrated_session()

func _start_integrated_session() -> void:
	if _network_busy or integration_mode != "integrated_alpha" or _server_session_id != "":
		return
	if supabase_client == null or session_store == null or access_token == "":
		model.last_message = "Preview sem recompensa."
		_server_synced = false
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
		_hydrate_integrated_session(_as_dictionary(body.get("session", {})))
		_last_pending_request_id = ""
		_last_result_text = "Bosque iniciado."
		model.last_message = "Bosque pronto."
	else:
		_server_synced = false
		_last_result_text = "Preview sem recompensa."
		model.last_message = "Preview sem recompensa."
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_update_labels()

func _complete_integrated_session() -> void:
	if _network_busy:
		return
	if _server_session_id == "":
		await _resume_or_start_integrated_session()
	if _server_session_id == "":
		_show_local_result()
		return
	if not _can_complete_integrated():
		_last_result_text = "Sincronize o Bosque antes de completar."
		model.last_message = "Sincronizacao pendente."
		_update_labels()
		return
	var payload: Dictionary = model.result_payload(maxf(_session_seconds, 5.0))
	payload["session_id"] = _server_session_id
	payload["expected_revision"] = _snapshot_revision
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
		_server_synced = true
	else:
		_server_synced = false
		_last_result_text = "Preview preservado. Recompensa bloqueada ate resync."
		model.last_message = "Sincronizacao pendente."
		if not _is_network_error(result):
			session_store.fail_pending_mutation(str(request.get("request_id", "")), _as_dictionary(result.get("body", {})))
	_update_labels()

func _hydrate_integrated_session(session: Dictionary) -> bool:
	var session_id := str(session.get("id", "")).strip_edges()
	if session_id == "":
		return false
	_server_session_id = session_id
	_snapshot_revision = int(session.get("snapshot_revision", 0))
	var snapshot_payload := _as_dictionary(session.get("snapshot_payload", session.get("snapshot", {})))
	if not snapshot_payload.is_empty():
		_apply_remote_snapshot(snapshot_payload)
	_server_synced = true
	_pending_event_count = 0
	_pending_collected_nodes = {}
	return true

func _apply_remote_snapshot(snapshot_payload: Dictionary) -> void:
	model.apply_snapshot(snapshot_payload)
	_session_seconds = float(snapshot_payload.get("session_seconds", _session_seconds))
	var position := _as_dictionary(snapshot_payload.get("player_position", snapshot_payload.get("position", {})))
	if not position.is_empty():
		set_player_position_for_tests(Vector2(float(position.get("x", _player_pos.x)), float(position.get("y", _player_pos.y))))
	_apply_collected_nodes(_as_dictionary(snapshot_payload.get("collected_nodes", {})))
	_update_labels()

func _apply_collected_nodes(collected_nodes: Dictionary) -> void:
	for index in range(_resource_nodes.size()):
		var node := _resource_nodes[index]
		var node_id := str(node.get("node_id", ""))
		node["collected"] = bool(collected_nodes.get(node_id, false))
		_resource_nodes[index] = node

func _record_integrated_event_deferred(event_type: String, event_payload: Dictionary) -> void:
	if integration_mode != "integrated_alpha" or _server_session_id == "":
		return
	_event_queue.append({
		"event_type": event_type,
		"event_payload": event_payload.duplicate(true),
	})
	_pending_event_count = _event_queue.size() + (1 if _event_flush_active else 0)
	_server_synced = false
	if model.last_message.strip_edges() == "":
		model.last_message = "Sincronizando Bosque..."
	_update_labels()
	call_deferred("_flush_integrated_event_queue")

func _flush_integrated_event_queue() -> void:
	if integration_mode != "integrated_alpha" or _server_session_id == "":
		return
	if _event_flush_active:
		return
	if supabase_client == null or session_store == null or access_token == "":
		_server_synced = false
		return
	_event_flush_active = true
	while not _event_queue.is_empty():
		var job := _as_dictionary(_event_queue.front())
		var event_type := str(job.get("event_type", "")).strip_edges()
		var event_payload := _as_dictionary(job.get("event_payload", {}))
		if event_type == "":
			_event_queue.pop_front()
			continue
		var request_payload := event_payload.duplicate(true)
		request_payload["event_type"] = event_type
		request_payload["session_id"] = _server_session_id
		request_payload["expected_revision"] = _snapshot_revision
		var request: Dictionary = session_store.prepare_pending_mutation(
			"modes/session/event",
			"mode:openworld:%s" % str(session_store.get("active_save_type")),
			"open_mode_shell:openworld",
			request_payload
		)
		_last_pending_request_id = str(request.get("request_id", ""))
		_pending_event_count = _event_queue.size() + 1
		_server_synced = false
		_update_labels()
		var result: Dictionary = await supabase_client.record_mode_session_event(
			_last_pending_request_id,
			_server_session_id,
			ModelScript.MODE_ID,
			ModelScript.SLICE_ID,
			event_type,
			_snapshot_revision,
			event_payload,
			access_token,
			str(request.get("request_hash", ""))
		)
		var body := _response_body(result)
		if bool(result.get("ok", false)) and session_store.apply_mode_result(result):
			_event_queue.pop_front()
			_hydrate_integrated_session(_as_dictionary(body.get("session", {})))
			model.last_message = str(_as_dictionary(body.get("event", {})).get("message", model.last_message))
			continue
		_server_synced = false
		var error_code := _error_code(result)
		model.last_message = "Sincronizacao pendente."
		if not _is_network_error(result):
			session_store.fail_pending_mutation(_last_pending_request_id, body)
			_event_queue.pop_front()
			if error_code == "MODE_SESSION_REVISION_STALE":
				await _resync_integrated_session("Bosque resincronizado. Repita a ultima acao se ela nao apareceu.")
			else:
				await _resync_integrated_session("Bosque resincronizado apos erro do servidor.")
			_event_queue.clear()
		else:
			model.last_message = "Sincronizacao pendente. Tentando novamente..."
			_schedule_integrated_event_retry()
		break
	_event_flush_active = false
	_pending_event_count = _event_queue.size()
	if _event_queue.is_empty():
		_last_pending_request_id = ""
		if _server_session_id != "":
			_server_synced = true
	_update_labels()

func _schedule_integrated_event_retry() -> void:
	if _event_retry_scheduled:
		return
	_event_retry_scheduled = true
	call_deferred("_retry_integrated_event_queue")

func _retry_integrated_event_queue() -> void:
	if is_inside_tree():
		await get_tree().create_timer(EVENT_RETRY_SECONDS).timeout
	_event_retry_scheduled = false
	_flush_integrated_event_queue()

func _resync_integrated_session(success_message: String) -> bool:
	if supabase_client == null or session_store == null or access_token == "":
		return false
	var state_result: Dictionary = await supabase_client.get_mode_state(ModelScript.MODE_ID, access_token)
	if not bool(state_result.get("ok", false)):
		return false
	var body := _response_body(state_result)
	var active_session := _as_dictionary(body.get("active_session", {}))
	if active_session.is_empty():
		var sessions := _as_array(body.get("sessions", []))
		for session_variant: Variant in sessions:
			var candidate := _as_dictionary(session_variant)
			if str(candidate.get("status", "")) == "started":
				active_session = candidate
				break
	if active_session.is_empty() or not _hydrate_integrated_session(active_session):
		return false
	model.last_message = success_message
	return true

func _can_complete_integrated() -> bool:
	if integration_mode != "integrated_alpha":
		return true
	return _server_session_id != "" and _server_synced and not _has_pending_integrated_events()

func _uses_integrated_authority() -> bool:
	return integration_mode == "integrated_alpha" and _server_session_id != "" and supabase_client != null and session_store != null and access_token != ""

func _has_pending_integrated_events() -> bool:
	return _event_flush_active or not _event_queue.is_empty() or _pending_event_count > 0

func _pending_summary_text() -> String:
	if _last_pending_request_id != "":
		return _last_pending_request_id
	if _has_pending_integrated_events():
		return "fila:%d" % (_event_queue.size() + (1 if _event_flush_active else 0))
	return ""

func _position_payload() -> Dictionary:
	return {
		"x": snappedf(_player_pos.x, 0.01),
		"y": snappedf(_player_pos.y, 0.01),
	}

func _response_body(result: Dictionary) -> Dictionary:
	return _as_dictionary(result.get("body", result))

func _error_code(result: Dictionary) -> String:
	var body := _response_body(result)
	var error := _as_dictionary(body.get("error", body))
	return str(error.get("code", result.get("code", "")))

func _is_network_error(result: Dictionary) -> bool:
	var code := _error_code(result)
	return code in ["NETWORK_UNAVAILABLE", "REQUEST_NOT_STARTED", "CLIENT_MISCONFIGURED"]

func _as_array(value: Variant) -> Array:
	return value if value is Array else []

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
