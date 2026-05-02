class_name CombatFeedbackLayer
extends CanvasLayer

const HEALTH_PLATE_WIDTH: float = 132.0
const HEALTH_PLATE_BAR_HEIGHT: float = 11.0
const HEALTH_PLATE_WORLD_MARGIN: float = 0.4

var player
var bot
var game_context
var arena_camera: Camera3D
var entries: Array[Dictionary] = []
var combatant_nodes: Dictionary = {}
var health_plate_entries: Dictionary = {}
var floating_text_root: Control
var health_plate_root: Control

func _ready() -> void:
	_ensure_ui_roots()

func bind(next_player, next_bot, next_game_context, next_camera: Camera3D) -> void:
	if game_context != null and game_context.combat_event_logged.is_connected(_on_combat_event_logged):
		game_context.combat_event_logged.disconnect(_on_combat_event_logged)

	player = next_player
	bot = next_bot
	game_context = next_game_context
	arena_camera = next_camera
	clear_combatants()
	register_combatant(&"player", player)
	register_combatant(&"bot", bot)

	if game_context != null and not game_context.combat_event_logged.is_connected(_on_combat_event_logged):
		game_context.combat_event_logged.connect(_on_combat_event_logged)

func register_combatant(combatant_id: StringName, node: Node3D) -> void:
	if node == null:
		return
	_ensure_ui_roots()
	combatant_nodes[String(combatant_id)] = node
	if _should_show_health_plate(String(combatant_id), node):
		_register_health_plate(String(combatant_id), node)

func unregister_combatant(combatant_id: StringName) -> void:
	var combatant_key: String = String(combatant_id)
	combatant_nodes.erase(combatant_key)
	_clear_health_plate(combatant_key)

func clear_combatants() -> void:
	combatant_nodes.clear()
	for combatant_key: String in health_plate_entries.keys():
		_clear_health_plate(combatant_key)
	health_plate_entries.clear()

func _process(delta: float) -> void:
	_update_health_plates()
	for index: int in range(entries.size() - 1, -1, -1):
		var entry: Dictionary = entries[index]
		var label: Label = entry.get("label")
		var target = entry.get("target")
		if not is_instance_valid(label) or not is_instance_valid(target) or arena_camera == null:
			if is_instance_valid(label):
				label.queue_free()
			entries.remove_at(index)
			continue

		var age: float = float(entry.get("age", 0.0)) + delta
		var lifetime: float = float(entry.get("lifetime", 0.6))
		if age >= lifetime:
			label.queue_free()
			entries.remove_at(index)
			continue

		entry["age"] = age
		entries[index] = entry

		var progress: float = age / lifetime
		var target_node: Node3D = target
		var world_offset: Vector3 = entry.get("world_offset", Vector3(0.0, 2.1, 0.0))
		world_offset.y += float(entry.get("rise_height", 0.9)) * progress

		var label_size: Vector2 = label.get_combined_minimum_size()
		label.size = label_size
		label.position = arena_camera.unproject_position(target_node.global_position + world_offset) - label_size * 0.5

		var base_color: Color = entry.get("color", Color.WHITE)
		label.modulate = Color(base_color.r, base_color.g, base_color.b, 1.0 - progress)
		label.scale = Vector2.ONE * lerpf(1.0, 1.08, progress)

func _on_combat_event_logged(event: Dictionary) -> void:
	var kind: String = str(event.get("kind", ""))
	match kind:
		"damage":
			var target_id: String = str(event.get("target_id", ""))
			var target_node: Node3D = _node_for_combatant(target_id)
			if target_node != null:
				_spawn_text("-%d" % int(round(float(event.get("amount", 0.0)))), Color(1.0, 0.68, 0.4, 1.0), target_node, Vector3(0.0, 2.2, 0.0), 0.65, 22)
		"heal":
			var heal_node: Node3D = _node_for_combatant(str(event.get("actor_id", "")))
			if heal_node != null:
				_spawn_text("+%d" % int(round(float(event.get("amount", 0.0)))), Color(0.46, 1.0, 0.62, 1.0), heal_node, Vector3(0.0, 2.3, 0.0), 0.72, 20)
		"barrier":
			var barrier_node: Node3D = _node_for_combatant(str(event.get("actor_id", "")))
			if barrier_node != null:
				_spawn_text("ESCUDO +%d" % int(round(float(event.get("amount", 0.0)))), Color(0.6, 0.92, 1.0, 1.0), barrier_node, Vector3(0.0, 2.4, 0.0), 0.78, 16)
		"block":
			var block_node: Node3D = _node_for_combatant(str(event.get("actor_id", "")))
			if block_node != null:
				_spawn_text("BLOQ %.0f" % float(event.get("amount", 0.0)), Color(0.68, 0.94, 1.0, 1.0), block_node, Vector3(0.0, 2.15, 0.0), 0.75, 16)
		"death":
			var death_node: Node3D = _node_for_combatant(str(event.get("actor_id", "")))
			if death_node != null:
				_spawn_text("CAIU", Color(1.0, 0.56, 0.52, 1.0), death_node, Vector3(0.0, 2.5, 0.0), 0.9, 22)

func _spawn_text(text: String, color: Color, target_node: Node3D, world_offset: Vector3, lifetime: float, font_size: int) -> void:
	_ensure_ui_roots()
	var label: Label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.06, 0.96))
	label.add_theme_constant_override("outline_size", 8)
	label.z_index = 20
	floating_text_root.add_child(label)

	entries.append({
		"label": label,
		"target": target_node,
		"age": 0.0,
		"lifetime": lifetime,
		"world_offset": world_offset,
		"rise_height": 0.9,
		"color": color
	})

func _node_for_combatant(combatant_id: String) -> Node3D:
	var node: Node3D = combatant_nodes.get(combatant_id)
	if node != null and is_instance_valid(node):
		return node
	if combatant_nodes.has(combatant_id):
		combatant_nodes.erase(combatant_id)
	_clear_health_plate(combatant_id)
	return null

func _ensure_ui_roots() -> void:
	if floating_text_root == null:
		floating_text_root = Control.new()
		floating_text_root.name = "FloatingTextRoot"
		floating_text_root.set_anchors_preset(Control.PRESET_FULL_RECT)
		floating_text_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		floating_text_root.z_index = 30
		add_child(floating_text_root)
	if health_plate_root == null:
		health_plate_root = Control.new()
		health_plate_root.name = "HealthPlateRoot"
		health_plate_root.set_anchors_preset(Control.PRESET_FULL_RECT)
		health_plate_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		health_plate_root.z_index = 20
		add_child(health_plate_root)

func _should_show_health_plate(combatant_id: String, node: Node3D) -> bool:
	return combatant_id != "player" and node != null

func _register_health_plate(combatant_id: String, node: Node3D) -> void:
	if health_plate_entries.has(combatant_id):
		var existing_entry: Dictionary = Dictionary(health_plate_entries.get(combatant_id, {}))
		existing_entry["target"] = node
		health_plate_entries[combatant_id] = existing_entry
		return

	var plate: PanelContainer = PanelContainer.new()
	plate.name = "HealthPlate_%s" % _sanitize_combatant_id(combatant_id)
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.custom_minimum_size = Vector2(HEALTH_PLATE_WIDTH, 0.0)
	plate.add_theme_stylebox_override("panel", _build_health_plate_panel_style())
	health_plate_root.add_child(plate)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	plate.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	margin.add_child(column)

	var bar: ProgressBar = ProgressBar.new()
	bar.name = "HealthBar"
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(HEALTH_PLATE_WIDTH - 16.0, HEALTH_PLATE_BAR_HEIGHT)
	bar.add_theme_stylebox_override("background", _build_health_bar_background_style())
	bar.add_theme_stylebox_override("fill", _build_health_bar_fill_style())
	column.add_child(bar)

	var value_label: Label = Label.new()
	value_label.name = "HealthValueLabel"
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_font_size_override("font_size", 11)
	value_label.add_theme_color_override("font_color", Color(0.96, 0.95, 0.92, 1.0))
	value_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 0.96))
	value_label.add_theme_constant_override("outline_size", 6)
	column.add_child(value_label)

	health_plate_entries[combatant_id] = {
		"plate": plate,
		"bar": bar,
		"value_label": value_label,
		"target": node
	}

func _clear_health_plate(combatant_id: String) -> void:
	if not health_plate_entries.has(combatant_id):
		return
	var entry: Dictionary = Dictionary(health_plate_entries.get(combatant_id, {}))
	var plate: PanelContainer = entry.get("plate")
	if is_instance_valid(plate):
		plate.queue_free()
	health_plate_entries.erase(combatant_id)

func _update_health_plates() -> void:
	for combatant_key: String in health_plate_entries.keys():
		var entry: Dictionary = Dictionary(health_plate_entries.get(combatant_key, {}))
		var plate: PanelContainer = entry.get("plate")
		var bar: ProgressBar = entry.get("bar")
		var value_label: Label = entry.get("value_label")
		var target: Node3D = entry.get("target")
		if not is_instance_valid(plate) or not is_instance_valid(bar) or not is_instance_valid(value_label) or not is_instance_valid(target) or arena_camera == null:
			_clear_health_plate(combatant_key)
			continue

		var world_anchor: Vector3 = _get_health_plate_world_anchor(target)
		if arena_camera.is_position_behind(world_anchor):
			plate.visible = false
			continue

		plate.visible = true
		var screen_position: Vector2 = arena_camera.unproject_position(world_anchor)
		var plate_size: Vector2 = plate.get_combined_minimum_size()
		plate.size = plate_size
		plate.position = screen_position - Vector2(plate_size.x * 0.5, plate_size.y)

		var current_health: float = maxf(0.0, float(target.get("health")))
		var max_health: float = maxf(1.0, float(target.get("max_health")))
		bar.max_value = max_health
		bar.value = current_health
		value_label.text = "%d / %d" % [int(round(current_health)), int(round(max_health))]

func _get_health_plate_world_anchor(target: Node3D) -> Vector3:
	return target.global_position + Vector3(0.0, _estimate_combatant_top_offset(target) + HEALTH_PLATE_WORLD_MARGIN, 0.0)

func _estimate_combatant_top_offset(target: Node3D) -> float:
	if target == null or not is_instance_valid(target):
		return 2.0
	var collision_shape: CollisionShape3D = target.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision_shape == null or collision_shape.shape == null:
		return 2.0
	var vertical_scale: float = target.global_transform.basis.y.length()
	var local_top: float = collision_shape.position.y
	var shape: Shape3D = collision_shape.shape
	if shape is CapsuleShape3D:
		var capsule: CapsuleShape3D = shape as CapsuleShape3D
		local_top += capsule.height * 0.5 + capsule.radius
	elif shape is CylinderShape3D:
		var cylinder: CylinderShape3D = shape as CylinderShape3D
		local_top += cylinder.height * 0.5
	elif shape is SphereShape3D:
		var sphere: SphereShape3D = shape as SphereShape3D
		local_top += sphere.radius
	elif shape is BoxShape3D:
		var box: BoxShape3D = shape as BoxShape3D
		local_top += box.size.y * 0.5
	else:
		local_top += 1.8
	return local_top * vertical_scale

func _sanitize_combatant_id(combatant_id: String) -> String:
	return combatant_id.replace(":", "_").replace("/", "_").replace(" ", "_")

func _build_health_plate_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.08, 0.86)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.92, 0.58, 0.34, 0.34)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	return style

func _build_health_bar_background_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.18, 0.22, 0.94)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style

func _build_health_bar_fill_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.88, 0.24, 0.18, 0.96)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style
