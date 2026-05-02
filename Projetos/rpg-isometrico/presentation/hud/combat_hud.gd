class_name CombatHud
extends CanvasLayer

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

const SKILL_KEYS: PackedStringArray = ["Q", "E", "R", "F"]
const POTION_KEYS: PackedStringArray = ["1", "2"]
const COMBAT_ENTRY_HINT_DURATION: float = 4.0
const DEFAULT_HINT_TEXT: String = "WASD mover | Clique/Space atacar | Shift dash | Q E R F habilidades | 1 2 pocoes | Esc voltar"

var player
var session_manager
var game_context
var shell_source

var hud_panel: Control
var player_card: PanelContainer
var context_chip: PanelContainer
var opponent_card: PanelContainer
var action_rail: PanelContainer
var player_health_label: Label
var player_health_bar: ProgressBar
var status_label: Label
var mode_module_label: Label
var context_label: Label
var opponent_title_label: Label
var opponent_health_label: Label
var opponent_health_bar: ProgressBar
var opponent_status_label: Label
var opponent_detail_label: Label
var hint_panel: PanelContainer
var hint_label: Label
var action_slot_panels: Array[PanelContainer] = []
var action_slot_name_labels: Array[Label] = []
var action_slot_state_labels: Array[Label] = []
var action_slot_key_labels: Array[Label] = []
var highlighted_skill_index: int = -1
var highlighted_potion_index: int = -1
var combat_entry_hint_remaining: float = 0.0
var last_session_state: int = -1

func _ready() -> void:
	layer = 10
	_build_ui()

func bind(next_player, next_session_manager, next_game_context, next_shell_source = null) -> void:
	player = next_player
	session_manager = next_session_manager
	game_context = next_game_context
	shell_source = next_shell_source
	combat_entry_hint_remaining = 0.0
	last_session_state = -1

func _process(delta: float) -> void:
	if player == null:
		return

	var shell_snapshot: Dictionary = get_shell_snapshot()
	var player_health_ratio: float = 0.0 if player.max_health <= 0.0 else player.health / player.max_health

	_update_player_card(player_health_ratio)
	_update_context_chip(shell_snapshot)
	_update_opponent_card(shell_snapshot)
	_update_action_rail()
	_update_hint_panel(delta, shell_snapshot)

func set_skill_highlight(index: int) -> void:
	highlighted_skill_index = index
	highlighted_potion_index = -1

func set_potion_highlight(index: int) -> void:
	highlighted_potion_index = index
	highlighted_skill_index = -1

func clear_slot_highlights() -> void:
	highlighted_skill_index = -1
	highlighted_potion_index = -1

func get_shell_snapshot() -> Dictionary:
	if shell_source != null and is_instance_valid(shell_source) and shell_source.has_method("get_shell_snapshot"):
		var snapshot: Variant = shell_source.get_shell_snapshot()
		if snapshot is Dictionary:
			return Dictionary(snapshot)
	return _build_fallback_shell_snapshot()

func _build_ui() -> void:
	hud_panel = Control.new()
	hud_panel.name = "HudPanel"
	hud_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hud_panel)

	player_card = _build_compact_card("PlayerCard", Vector2(228.0, 0.0))
	player_card.set_anchors_preset(Control.PRESET_TOP_LEFT)
	player_card.position = Vector2(14.0, 14.0)
	player_card.size = Vector2(228.0, 76.0)
	hud_panel.add_child(player_card)
	var player_column: VBoxContainer = _build_card_column(player_card)
	player_health_label = _build_card_label(18, Color(0.97, 0.98, 1.0, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	player_column.add_child(player_health_label)
	player_health_bar = _build_health_bar("PlayerHealthBar")
	player_column.add_child(player_health_bar)
	status_label = _build_card_label(12, Color(0.82, 0.9, 1.0, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	status_label.visible = false
	player_column.add_child(status_label)

	context_chip = _build_compact_card("ContextChip", Vector2(356.0, 0.0))
	context_chip.anchor_left = 0.5
	context_chip.anchor_top = 0.0
	context_chip.anchor_right = 0.5
	context_chip.anchor_bottom = 0.0
	context_chip.position = Vector2(-178.0, 14.0)
	context_chip.size = Vector2(356.0, 76.0)
	hud_panel.add_child(context_chip)
	var context_column: VBoxContainer = _build_card_column(context_chip)
	mode_module_label = _build_card_label(18, Color(0.98, 0.92, 0.82, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	context_column.add_child(mode_module_label)
	context_label = _build_card_label(12, Color(0.84, 0.88, 0.94, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	context_column.add_child(context_label)

	opponent_card = _build_compact_card("OpponentCard", Vector2(248.0, 0.0))
	opponent_card.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	opponent_card.position = Vector2(-262.0, 14.0)
	opponent_card.size = Vector2(248.0, 116.0)
	opponent_card.visible = false
	hud_panel.add_child(opponent_card)
	var opponent_column: VBoxContainer = _build_card_column(opponent_card)
	opponent_title_label = _build_card_label(16, Color(1.0, 0.9, 0.84, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	opponent_column.add_child(opponent_title_label)
	opponent_health_label = _build_card_label(14, Color(0.98, 0.92, 0.88, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	opponent_column.add_child(opponent_health_label)
	opponent_health_bar = _build_health_bar("OpponentHealthBar")
	opponent_column.add_child(opponent_health_bar)
	opponent_status_label = _build_card_label(12, Color(1.0, 0.78, 0.66, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	opponent_column.add_child(opponent_status_label)
	opponent_detail_label = _build_card_label(11, Color(0.9, 0.86, 0.8, 1.0), HORIZONTAL_ALIGNMENT_LEFT)
	opponent_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opponent_detail_label.visible = false
	opponent_column.add_child(opponent_detail_label)

	action_rail = _build_compact_card("ActionRail", Vector2(474.0, 0.0))
	action_rail.anchor_left = 0.5
	action_rail.anchor_top = 1.0
	action_rail.anchor_right = 0.5
	action_rail.anchor_bottom = 1.0
	action_rail.position = Vector2(-237.0, -90.0)
	action_rail.size = Vector2(474.0, 68.0)
	hud_panel.add_child(action_rail)

	var rail_margin: MarginContainer = MarginContainer.new()
	rail_margin.add_theme_constant_override("margin_left", 8)
	rail_margin.add_theme_constant_override("margin_top", 6)
	rail_margin.add_theme_constant_override("margin_right", 8)
	rail_margin.add_theme_constant_override("margin_bottom", 6)
	action_rail.add_child(rail_margin)

	var rail_row: HBoxContainer = HBoxContainer.new()
	rail_row.name = "ActionRailRow"
	rail_row.alignment = BoxContainer.ALIGNMENT_CENTER
	rail_row.add_theme_constant_override("separation", 6)
	rail_margin.add_child(rail_row)

	for key_label: String in SKILL_KEYS:
		_register_action_slot(rail_row, key_label)
	for key_label: String in POTION_KEYS:
		_register_action_slot(rail_row, key_label)

	hint_panel = _build_compact_card("HintPanel", Vector2(548.0, 0.0))
	hint_panel.anchor_left = 0.5
	hint_panel.anchor_top = 1.0
	hint_panel.anchor_right = 0.5
	hint_panel.anchor_bottom = 1.0
	hint_panel.position = Vector2(-274.0, -152.0)
	hint_panel.size = Vector2(548.0, 46.0)
	hint_panel.visible = false
	add_child(hint_panel)

	var hint_margin: MarginContainer = MarginContainer.new()
	hint_margin.add_theme_constant_override("margin_left", 12)
	hint_margin.add_theme_constant_override("margin_top", 8)
	hint_margin.add_theme_constant_override("margin_right", 12)
	hint_margin.add_theme_constant_override("margin_bottom", 8)
	hint_panel.add_child(hint_margin)

	hint_label = _build_card_label(12, Color(0.86, 0.88, 0.94, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	hint_label.name = "HintLabel"
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_margin.add_child(hint_label)

func _build_compact_card(node_name: String, minimum_size: Vector2) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = node_name
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.custom_minimum_size = minimum_size
	card.add_theme_stylebox_override("panel", _build_card_style())
	return card

func _build_card_column(parent: PanelContainer) -> VBoxContainer:
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 10)
	parent.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	margin.add_child(column)
	return column

func _build_card_label(font_size: int, font_color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color(0.03, 0.03, 0.05, 0.92))
	label.add_theme_constant_override("outline_size", 6)
	label.horizontal_alignment = alignment
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _build_health_bar(node_name: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = node_name
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0.0, 12.0)
	_apply_bar_style(bar)
	return bar

func _register_action_slot(parent: HBoxContainer, key_label: String) -> void:
	var slot_panel := PanelContainer.new()
	slot_panel.name = "ActionSlot_%s" % key_label
	slot_panel.custom_minimum_size = Vector2(68.0, 48.0)
	parent.add_child(slot_panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	slot_panel.add_child(margin)

	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 1)
	margin.add_child(column)

	var key_node: Label = _build_card_label(9, Color(0.98, 0.84, 0.6, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	key_node.name = "SlotKeyLabel"
	key_node.text = key_label
	column.add_child(key_node)

	var name_node: Label = _build_card_label(11, Color(0.96, 0.96, 0.98, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	name_node.name = "SlotNameLabel"
	column.add_child(name_node)

	var state_node: Label = _build_card_label(9, Color(0.82, 0.88, 0.96, 1.0), HORIZONTAL_ALIGNMENT_CENTER)
	state_node.name = "SlotStateLabel"
	column.add_child(state_node)

	action_slot_panels.append(slot_panel)
	action_slot_key_labels.append(key_node)
	action_slot_name_labels.append(name_node)
	action_slot_state_labels.append(state_node)

func _update_player_card(player_health_ratio: float) -> void:
	player_health_label.text = "%.0f / %.0f" % [player.health, player.max_health]
	player_health_bar.max_value = maxf(1.0, player.max_health)
	player_health_bar.value = clampf(player.health, 0.0, player.max_health)
	player_health_bar.modulate = _resolve_health_bar_color(player_health_ratio)

	var player_status: String = _format_player_status()
	status_label.text = player_status
	status_label.visible = player_status != ""
	status_label.modulate = _resolve_player_status_color(player_status, player_health_ratio)

func _update_context_chip(snapshot: Dictionary) -> void:
	mode_module_label.text = str(snapshot.get("module_title", ""))
	context_label.text = str(snapshot.get("context_text", ""))

func _update_opponent_card(snapshot: Dictionary) -> void:
	var opponent_visible: bool = bool(snapshot.get("opponent_visible", false))
	opponent_card.visible = opponent_visible
	if not opponent_visible:
		opponent_title_label.text = ""
		opponent_health_label.text = ""
		opponent_health_bar.value = 0.0
		opponent_health_bar.max_value = 1.0
		opponent_status_label.text = ""
		opponent_detail_label.text = ""
		opponent_detail_label.visible = false
		return

	var opponent_health: float = float(snapshot.get("opponent_health", 0.0))
	var opponent_max_health: float = maxf(1.0, float(snapshot.get("opponent_max_health", 1.0)))
	var opponent_health_ratio: float = clampf(opponent_health / opponent_max_health, 0.0, 1.0)
	var mode_id: StringName = StringName(str(snapshot.get("mode_id", "")))
	var opponent_detail: String = ""
	if mode_id == LocalModeCatalog.ARENA_MODE_ID or mode_id == LocalModeCatalog.BOSS_MODE_ID:
		opponent_detail = _compact_detail_text(str(snapshot.get("module_detail", "")))

	opponent_title_label.text = str(snapshot.get("opponent_label", "Oponente"))
	opponent_health_label.text = "%.0f / %.0f" % [opponent_health, opponent_max_health]
	opponent_health_bar.max_value = opponent_max_health
	opponent_health_bar.value = clampf(opponent_health, 0.0, opponent_max_health)
	opponent_health_bar.modulate = _resolve_opponent_bar_color(opponent_health_ratio)
	opponent_status_label.text = str(snapshot.get("opponent_status_text", ""))
	opponent_detail_label.text = opponent_detail
	opponent_detail_label.visible = opponent_detail != ""

func _update_action_rail() -> void:
	for index: int in range(action_slot_panels.size()):
		var is_potion_slot: bool = index >= SKILL_KEYS.size()
		var local_index: int = index - SKILL_KEYS.size() if is_potion_slot else index
		var slot_panel: PanelContainer = action_slot_panels[index]
		var slot_name: Label = action_slot_name_labels[index]
		var slot_state: Label = action_slot_state_labels[index]

		var is_available: bool = player.has_potion_slot(local_index) if is_potion_slot else player.has_skill_slot(local_index)
		var label_text: String = player.get_potion_slot_label(local_index) if is_potion_slot else player.get_skill_slot_label(local_index)
		var cooldown_value: float = player.get_potion_cooldown(local_index) if is_potion_slot else player.get_skill_cooldown(local_index)
		var is_highlighted: bool = (
			highlighted_potion_index == local_index if is_potion_slot else highlighted_skill_index == local_index
		)

		slot_name.text = _compact_slot_label(label_text, is_available)
		slot_state.text = _compact_slot_state(cooldown_value, is_available)
		slot_panel.add_theme_stylebox_override(
			"panel",
			_build_action_slot_style(is_potion_slot, is_available, is_highlighted)
		)
		slot_name.modulate = _resolve_action_slot_name_color(is_available, is_highlighted)
		slot_state.modulate = _resolve_action_slot_state_color(is_available, is_highlighted)
		action_slot_key_labels[index].modulate = (
			Color(1.0, 0.86, 0.66, 1.0)
			if is_highlighted
			else (Color(0.82, 0.88, 0.98, 1.0) if is_available else Color(0.58, 0.62, 0.72, 1.0))
		)

func _update_hint_panel(delta: float, snapshot: Dictionary) -> void:
	var session_state: int = _get_session_state()
	if session_state != last_session_state:
		if session_state == 2:
			combat_entry_hint_remaining = COMBAT_ENTRY_HINT_DURATION
		elif session_state != 1:
			combat_entry_hint_remaining = 0.0
		last_session_state = session_state

	if session_state == 2 and combat_entry_hint_remaining > 0.0:
		combat_entry_hint_remaining = maxf(0.0, combat_entry_hint_remaining - delta)

	var should_show_hint: bool = _has_slot_highlight() or session_state == 1 or combat_entry_hint_remaining > 0.0
	hint_panel.visible = should_show_hint
	if not should_show_hint:
		hint_label.text = ""
		return

	var mode_id: StringName = StringName(str(snapshot.get("mode_id", "")))
	hint_label.text = _resolve_hint_text(mode_id)

func _get_session_state() -> int:
	return -1 if session_manager == null else int(session_manager.state)

func _has_slot_highlight() -> bool:
	return highlighted_skill_index >= 0 or highlighted_potion_index >= 0

func _resolve_hint_text(mode_id: StringName) -> String:
	if highlighted_skill_index >= 0:
		return _build_slot_hint_text(false, highlighted_skill_index)
	if highlighted_potion_index >= 0:
		return _build_slot_hint_text(true, highlighted_potion_index)
	if mode_id != &"":
		return LocalModeCatalog.get_controls_hint(mode_id)
	return DEFAULT_HINT_TEXT

func _build_slot_hint_text(is_potion_slot: bool, slot_index: int) -> String:
	var key_label: String = POTION_KEYS[slot_index] if is_potion_slot else SKILL_KEYS[slot_index]
	var slot_label: String = (
		player.get_potion_slot_label(slot_index)
		if is_potion_slot
		else player.get_skill_slot_label(slot_index)
	)
	var is_available: bool = (
		player.has_potion_slot(slot_index)
		if is_potion_slot
		else player.has_skill_slot(slot_index)
	)
	if not is_available:
		return "Use %s para continuar." % key_label
	return (
		"Use %s para beber %s."
		if is_potion_slot
		else "Use %s para ativar %s."
	) % [key_label, slot_label]

func _format_cd(value: float) -> String:
	if value <= 0.0:
		return "pronto"
	return "%.1fs" % value

func _format_player_status() -> String:
	if player.get_barrier_amount() > 0.0:
		return "Barreira %.0f" % player.get_barrier_amount()
	if player.get_buff_time_remaining() > 0.0:
		return "Buff %.1fs" % player.get_buff_time_remaining()
	var health_ratio: float = 0.0 if player.max_health <= 0.0 else player.health / player.max_health
	if health_ratio <= 0.35:
		return "Vida critica"
	if health_ratio <= 0.65:
		return "Sob pressao"
	return ""

func _resolve_player_status_color(player_status: String, health_ratio: float) -> Color:
	if player_status.begins_with("Barreira"):
		return Color(0.72, 0.94, 1.0, 1.0)
	if player_status.begins_with("Buff"):
		return Color(0.74, 0.98, 0.82, 1.0)
	if health_ratio <= 0.35:
		return Color(1.0, 0.72, 0.68, 1.0)
	if health_ratio <= 0.65:
		return Color(0.98, 0.86, 0.66, 1.0)
	return Color(0.82, 0.9, 1.0, 1.0)

func _compact_slot_label(label: String, is_available: bool) -> String:
	if not is_available or label.to_lower() == "bloqueada":
		return "Bloq"
	var words: PackedStringArray = label.split(" ", false)
	if words.size() > 0 and String(words[0]).length() <= 10:
		return String(words[0])
	if label.length() <= 10:
		return label
	return "%s..." % label.substr(0, 7)

func _compact_slot_state(cooldown_value: float, is_available: bool) -> String:
	if not is_available:
		return ""
	return _format_cd(cooldown_value)

func _compact_detail_text(text: String) -> String:
	if text.length() <= 58:
		return text
	return "%s..." % text.substr(0, 55)

func _build_fallback_shell_snapshot() -> Dictionary:
	return {
		"mode_id": "",
		"context_text": "",
		"module_title": "",
		"module_detail": "",
		"opponent_visible": false,
		"opponent_label": "",
		"opponent_status_text": "",
		"opponent_health": 0.0,
		"opponent_max_health": 1.0
	}

func _format_event_feed() -> String:
	if game_context == null:
		return "Eventos recentes:\n- aguardando contexto."

	var events: Array[Dictionary] = game_context.get_recent_events(3)
	if events.is_empty():
		return "Eventos recentes:\n- aguardando a primeira troca."

	var lines: Array[String] = ["Eventos recentes:"]
	for index: int in range(events.size() - 1, -1, -1):
		var event: Dictionary = events[index]
		lines.append("- %s" % str(event.get("text", "")))
	return "\n".join(lines)

func _build_root_panel_style() -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	style_box.border_width_left = 0
	style_box.border_width_top = 0
	style_box.border_width_right = 0
	style_box.border_width_bottom = 0
	return style_box

func _build_card_style() -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = Color(0.06, 0.08, 0.11, 0.84)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = Color(0.84, 0.48, 0.24, 0.32)
	style_box.corner_radius_top_left = 14
	style_box.corner_radius_top_right = 14
	style_box.corner_radius_bottom_left = 14
	style_box.corner_radius_bottom_right = 14
	return style_box

func _build_action_slot_style(is_potion_slot: bool, is_available: bool, is_highlighted: bool) -> StyleBoxFlat:
	var style_box := StyleBoxFlat.new()
	var accent_color: Color = Color(0.62, 0.96, 0.78, 1.0) if is_potion_slot else Color(0.74, 0.88, 1.0, 1.0)
	style_box.bg_color = (
		Color(accent_color.r, accent_color.g, accent_color.b, 0.18)
		if is_available
		else Color(0.08, 0.09, 0.12, 0.78)
	)
	style_box.border_width_left = 1
	style_box.border_width_top = 1
	style_box.border_width_right = 1
	style_box.border_width_bottom = 1
	style_box.border_color = (
		Color(1.0, 0.84, 0.58, 0.94)
		if is_highlighted
		else (
			Color(accent_color.r, accent_color.g, accent_color.b, 0.38)
			if is_available
			else Color(0.34, 0.38, 0.46, 0.24)
		)
	)
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12
	return style_box

func _resolve_action_slot_name_color(is_available: bool, is_highlighted: bool) -> Color:
	if is_highlighted:
		return Color(1.0, 0.96, 0.86, 1.0)
	if is_available:
		return Color(0.96, 0.97, 0.99, 1.0)
	return Color(0.56, 0.6, 0.68, 1.0)

func _resolve_action_slot_state_color(is_available: bool, is_highlighted: bool) -> Color:
	if is_highlighted:
		return Color(1.0, 0.88, 0.66, 1.0)
	if is_available:
		return Color(0.82, 0.88, 0.96, 1.0)
	return Color(0.48, 0.52, 0.6, 1.0)

func _apply_bar_style(bar: ProgressBar) -> void:
	var background_style := StyleBoxFlat.new()
	background_style.bg_color = Color(0.13, 0.14, 0.18, 0.94)
	background_style.corner_radius_top_left = 8
	background_style.corner_radius_top_right = 8
	background_style.corner_radius_bottom_left = 8
	background_style.corner_radius_bottom_right = 8
	bar.add_theme_stylebox_override("background", background_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(0.82, 0.58, 0.34, 1.0)
	fill_style.corner_radius_top_left = 8
	fill_style.corner_radius_top_right = 8
	fill_style.corner_radius_bottom_left = 8
	fill_style.corner_radius_bottom_right = 8
	bar.add_theme_stylebox_override("fill", fill_style)

func _resolve_health_bar_color(health_ratio: float) -> Color:
	if health_ratio <= 0.35:
		return Color(0.98, 0.46, 0.42, 1.0)
	if health_ratio <= 0.65:
		return Color(0.98, 0.74, 0.4, 1.0)
	return Color(0.5, 0.9, 0.62, 1.0)

func _resolve_opponent_bar_color(health_ratio: float) -> Color:
	if health_ratio <= 0.35:
		return Color(1.0, 0.52, 0.48, 1.0)
	if health_ratio <= 0.65:
		return Color(0.98, 0.7, 0.42, 1.0)
	return Color(0.96, 0.58, 0.46, 1.0)
