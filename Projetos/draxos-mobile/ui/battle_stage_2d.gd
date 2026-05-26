class_name BattleStage2D
extends Control

const BattleActorMarkerScript := preload("res://ui/battle_actor_marker.gd")
const BattleSymbolIconScript := preload("res://ui/battle_symbol_icon.gd")

const SIDE_PLAYER := "player"
const SIDE_OPPONENT := "opponent"
const SIDES := [SIDE_PLAYER, SIDE_OPPONENT]
const SLOT_FRONT := "front"
const SLOT_MIDDLE := "middle"
const SLOT_BACK := "back"
const SLOT_ORDER := [SLOT_FRONT, SLOT_MIDDLE, SLOT_BACK]

const DAMAGE_COLORS := {
	"arcano": Color("#5DD4C8"),
	"fisico": Color("#C0C5CC"),
	"fogo": Color("#E06A3B"),
	"agua": Color("#4EA1D3"),
	"gelo": Color("#9BDCF2"),
	"terra": Color("#A58D54"),
	"vento": Color("#8ED9A2"),
	"raio": Color("#F2D35C"),
	"veneno": Color("#7FBF5B"),
	"sangue": Color("#B95757"),
	"morte": Color("#A57BD8"),
	"mental": Color("#C98CE8"),
	"none": Color("#AEB7BF"),
}

const TOKEN_COLOR_FALLBACKS := {
	"bg_deep": Color("#080B10"),
	"bg_panel": Color("#151B22"),
	"bg_panel_alt": Color("#202832"),
	"border_default": Color("#405060"),
	"border_active": Color("#6FA6C8"),
	"text_primary": Color("#F0EEE5"),
	"text_secondary": Color("#AEB7BF"),
	"accent_astral": Color("#5DD4C8"),
	"accent_blood": Color("#B95757"),
	"accent_bone": Color("#D6C08A"),
	"status_success": Color("#66B56F"),
	"status_error": Color("#D86D6D"),
	"placeholder": Color("#2B3440"),
}

var _built := false
var _side_state: Dictionary = {}
var _latest_event: Dictionary = {}
var _event_index := 0
var _event_count := 0
var _actors: Dictionary = {}
var _name_labels: Dictionary = {}
var _status_rows: Dictionary = {}
var _cooldown_rows: Dictionary = {}
var _slot_layer: Control
var _effects_layer: Control
var _event_icon
var _event_label: Label
var _empty_label: Label
var _last_animated_key := ""

func _ready() -> void:
	_ensure_ui()

func show_empty_state(message: String) -> void:
	_ensure_ui()
	_side_state = {}
	_latest_event = {}
	_event_index = 0
	_event_count = 0
	_last_animated_key = ""
	_empty_label.text = message
	_empty_label.visible = true
	_event_label.text = "Aguardando battle_log_v1"
	_event_icon.configure("...", _token_color("placeholder"), "Palco procedural sem arte importada.")
	_render_dynamic_state()

func render_snapshot(side_state: Dictionary, latest_event: Dictionary, event_index: int, event_count: int, animate_event: bool = false) -> void:
	_ensure_ui()
	_side_state = side_state.duplicate(true)
	_latest_event = latest_event.duplicate(true)
	_event_index = event_index
	_event_count = event_count
	_empty_label.visible = false
	_render_dynamic_state()
	if animate_event and not _latest_event.is_empty():
		_animate_event(_latest_event)

func debug_snapshot() -> Dictionary:
	return {
		"event_index": _event_index,
		"event_count": _event_count,
		"latest_event_type": str(_latest_event.get("type", "")),
		"slot_count": _slot_layer.get_child_count() if _slot_layer != null else 0,
		"effect_count": _effects_layer.get_child_count() if _effects_layer != null else 0,
		"has_player_actor": _actors.has(SIDE_PLAYER),
		"has_opponent_actor": _actors.has(SIDE_OPPONENT),
	}

func _ensure_ui() -> void:
	if _built:
		return
	_built = true
	clip_contents = true
	custom_minimum_size = Vector2(760, 360)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	resized.connect(_layout_nodes)

	for side: String in SIDES:
		var actor = BattleActorMarkerScript.new()
		actor.name = "%sActor" % side.capitalize()
		actor.configure(side, _default_side_name(side), _side_color(side))
		add_child(actor)
		_actors[side] = actor

		var name_label := _stage_label(_default_side_name(side), 16, _token_color("text_primary"))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(name_label)
		_name_labels[side] = name_label

		var status_row := HBoxContainer.new()
		status_row.add_theme_constant_override("separation", 4)
		add_child(status_row)
		_status_rows[side] = status_row

		var cooldown_row := HBoxContainer.new()
		cooldown_row.add_theme_constant_override("separation", 4)
		add_child(cooldown_row)
		_cooldown_rows[side] = cooldown_row

	_slot_layer = Control.new()
	_slot_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_slot_layer)

	_effects_layer = Control.new()
	_effects_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_effects_layer)

	var event_panel := PanelContainer.new()
	event_panel.name = "EventPanel"
	event_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_active"))
	event_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(event_panel)

	var event_row := HBoxContainer.new()
	event_row.add_theme_constant_override("separation", 8)
	event_panel.add_child(event_row)
	_event_icon = BattleSymbolIconScript.new()
	_event_icon.custom_minimum_size = Vector2(42, 42)
	event_row.add_child(_event_icon)
	_event_label = _stage_label("Aguardando battle_log_v1", 13, _token_color("text_primary"))
	_event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_event_label.custom_minimum_size = Vector2(240, 42)
	event_row.add_child(_event_label)

	_empty_label = _stage_label("", 15, _token_color("text_secondary"))
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(_empty_label)

	_layout_nodes()
	show_empty_state("Nenhuma batalha carregada.")

func _layout_nodes() -> void:
	if not _built:
		return
	var stage_size := _stage_size()
	var actor_size := Vector2(138, min(210.0, max(176.0, stage_size.y * 0.56)))
	for side: String in SIDES:
		var center := _actor_center(side)
		var actor = _actors[side]
		actor.size = actor_size
		actor.position = center - actor_size * Vector2(0.5, 0.62)

		var name_label: Label = _name_labels[side]
		name_label.size = Vector2(210, 24)
		name_label.position = Vector2(center.x - 105.0, actor.position.y - 28.0)

		var status_row: Control = _status_rows[side]
		status_row.size = Vector2(260, 44)
		status_row.position = Vector2(center.x - 130.0, max(10.0, actor.position.y - 78.0))

		var cooldown_row: Control = _cooldown_rows[side]
		cooldown_row.size = Vector2(260, 44)
		cooldown_row.position = Vector2(center.x - 130.0, actor.position.y + actor_size.y + 8.0)

	_slot_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_effects_layer.set_anchors_preset(Control.PRESET_FULL_RECT)

	var event_panel := get_node_or_null("EventPanel") as Control
	if event_panel != null:
		event_panel.size = Vector2(min(360.0, stage_size.x - 32.0), 62.0)
		event_panel.position = Vector2((stage_size.x - event_panel.size.x) * 0.5, 12.0)

	_empty_label.size = Vector2(stage_size.x - 80.0, 60.0)
	_empty_label.position = Vector2(40.0, stage_size.y * 0.42)
	queue_redraw()

func _draw() -> void:
	var stage_size := _stage_size()
	var bg_rect := Rect2(Vector2.ZERO, stage_size)
	draw_rect(bg_rect, _token_color("bg_deep"), true)
	draw_rect(Rect2(Vector2.ZERO, Vector2(stage_size.x, stage_size.y * 0.58)), Color("#101923"), true)
	draw_rect(Rect2(Vector2(0, stage_size.y * 0.58), Vector2(stage_size.x, stage_size.y * 0.42)), Color("#11100E"), true)

	var horizon_y := stage_size.y * 0.58
	draw_line(Vector2(0, horizon_y), Vector2(stage_size.x, horizon_y), _token_color("border_active").darkened(0.15), 2.0, true)
	for index: int in range(8):
		var y := horizon_y + index * 24.0
		draw_line(Vector2(0, y), Vector2(stage_size.x, y), Color("#405060", 0.12), 1.0)
	for index: int in range(7):
		var x := stage_size.x * (float(index) / 6.0)
		draw_line(Vector2(x, horizon_y), Vector2(stage_size.x * 0.5, stage_size.y - 10.0), Color("#405060", 0.16), 1.0)

	draw_line(Vector2(stage_size.x * 0.5, horizon_y - 28.0), Vector2(stage_size.x * 0.5, stage_size.y - 16.0), Color("#D6C08A", 0.25), 1.0, true)
	for side: String in SIDES:
		for slot: String in SLOT_ORDER:
			var pos := _slot_position(side, slot)
			draw_circle(pos, 24.0, Color("#202832", 0.46))
			draw_arc(pos, 24.0, 0.0, TAU, 28, _slot_color(slot), 1.5, true)
			var front_marker := Vector2(10.0 if side == SIDE_PLAYER else -10.0, 0.0)
			if slot == SLOT_FRONT:
				draw_line(pos - front_marker, pos + front_marker, _slot_color(slot), 2.0, true)

func _render_dynamic_state() -> void:
	_layout_nodes()
	for side: String in SIDES:
		var side_data := _as_dictionary(_side_state.get(side, {}))
		var display_name := str(side_data.get("display_name", _default_side_name(side)))
		var statuses := _as_dictionary(side_data.get("statuses", {}))
		var summons := _as_dictionary(side_data.get("summons", {}))
		var familiar := str(side_data.get("familiar", ""))
		var actor: Control = _actors[side]
		actor.configure(side, display_name, _side_color(side))
		actor.set_stats(
			float(side_data.get("hp", 100.0)),
			float(side_data.get("max_hp", 100.0)),
			float(side_data.get("mana", 0.0)),
			float(side_data.get("max_mana", 20.0)),
			float(side_data.get("barrier", 0.0)),
			statuses.size(),
			summons.size() + (1 if familiar != "" else 0)
		)
		var name_label: Label = _name_labels[side]
		name_label.text = "%s  HP %s/%s" % [
			display_name,
			_number_text(float(side_data.get("hp", 0.0))),
			_number_text(float(side_data.get("max_hp", 1.0))),
		]
		name_label.tooltip_text = actor.tooltip_text
		_render_icon_row(_status_rows[side], statuses, "status")
		_render_icon_row(_cooldown_rows[side], _as_dictionary(side_data.get("cooldowns", {})), "cooldown")

	_render_slots()
	_render_event_panel()
	queue_redraw()

func _render_icon_row(row: HBoxContainer, values: Dictionary, row_kind: String) -> void:
	_clear_children(row)
	if values.is_empty():
		var empty_icon = BattleSymbolIconScript.new()
		empty_icon.custom_minimum_size = Vector2(34, 34)
		empty_icon.configure("-", _token_color("border_default"), "Nenhum %s ativo." % row_kind)
		row.add_child(empty_icon)
		return
	var keys := values.keys()
	keys.sort()
	var visible_keys := keys.slice(0, min(keys.size(), 5))
	for key: Variant in visible_keys:
		var value: Variant = values[key]
		var color := _status_color(str(key))
		var symbol := _symbol_for_id(str(key))
		var count := ""
		var tooltip := "%s: %s" % [row_kind.capitalize(), str(key)]
		var cooldown_ratio := 0.0
		if row_kind == "cooldown":
			var ready_at := float(value)
			count = "%.1fs" % ready_at
			cooldown_ratio = 0.72
			tooltip = "Cooldown placeholder de spell: %s pronto em %.1fs. Futuro: battle_icon_spell." % [str(key), ready_at]
		elif value is Dictionary:
			var stacks := int(Dictionary(value).get("stacks", 1))
			if stacks > 1:
				count = "x%d" % stacks
			tooltip = "Status/Buff placeholder: %s. Futuro: battle_icon_status ou battle_icon_buff." % str(key)
		var icon = BattleSymbolIconScript.new()
		icon.custom_minimum_size = Vector2(36, 36)
		icon.configure(symbol, color, tooltip, count, cooldown_ratio)
		row.add_child(icon)

func _render_slots() -> void:
	_clear_children(_slot_layer)
	for side: String in SIDES:
		var side_data := _as_dictionary(_side_state.get(side, {}))
		var slot_entries: Array[Dictionary] = []
		var familiar := str(side_data.get("familiar", ""))
		if familiar != "":
			slot_entries.append({
				"id": familiar,
				"kind": "familiar",
				"slot": SLOT_BACK,
				"color": DAMAGE_COLORS["morte"],
				"symbol": "PET",
			})
		var summons := _as_dictionary(side_data.get("summons", {}))
		var keys := summons.keys()
		keys.sort()
		for index: int in range(keys.size()):
			var summon_id := str(keys[index])
			var summon := _as_dictionary(summons[summon_id])
			slot_entries.append({
				"id": summon_id,
				"kind": "summon",
				"slot": str(summon.get("slot", SLOT_ORDER[index % SLOT_ORDER.size()])),
				"color": _damage_color(str(summon.get("damage_type", "fogo"))),
				"symbol": "SUM",
			})
		var used_offsets: Dictionary = {}
		for entry: Dictionary in slot_entries:
			var slot := str(entry.get("slot", SLOT_MIDDLE))
			var offset_count := int(used_offsets.get(slot, 0))
			used_offsets[slot] = offset_count + 1
			var icon = BattleSymbolIconScript.new()
			icon.custom_minimum_size = Vector2(46, 46)
			var entry_color: Color = _token_color("accent_bone")
			if entry.get("color", null) is Color:
				entry_color = entry.get("color")
			icon.configure(
				str(entry.get("symbol", "?")),
				entry_color,
				"%s %s no slot %s de %s. Futuro: sprite/animacao propria." % [
					str(entry.get("kind", "objeto")).capitalize(),
					str(entry.get("id", "")),
					_slot_label(slot),
					_default_side_name(side),
				],
				_slot_short(slot)
			)
			var pos := _slot_position(side, slot)
			icon.position = pos - icon.custom_minimum_size * 0.5 + Vector2(0, offset_count * 8.0)
			icon.size = icon.custom_minimum_size
			_slot_layer.add_child(icon)

func _render_event_panel() -> void:
	if _latest_event.is_empty():
		_event_icon.configure("...", _token_color("placeholder"), "Aguardando evento do battle_log_v1.")
		_event_label.text = "Evento %d/%d | aguardando replay" % [_event_index, _event_count]
		return
	var event_type := str(_latest_event.get("type", ""))
	_event_icon.configure(_event_code(event_type), _event_color(_latest_event), "Evento procedural: %s. Futuro: asset por evento/fonte." % event_type)
	_event_label.text = "Evento %d/%d | %ss | %s" % [
		_event_index,
		_event_count,
		"%.1f" % float(_latest_event.get("t", 0.0)),
		_event_brief(_latest_event),
	]

func _animate_event(event: Dictionary) -> void:
	var key := "%s:%s:%s" % [str(event.get("seq", "")), str(event.get("t", "")), str(event.get("type", ""))]
	if key == _last_animated_key:
		return
	_last_animated_key = key

	var event_type := str(event.get("type", ""))
	var color := _event_color(event)
	var source_side := _side_from_actor(str(event.get("source", "")))
	var target_side := _side_from_actor(str(event.get("target", "")))
	if target_side == "" and event_type in ["barrier_gain", "passive_apply", "cooldown_start", "mana_change"]:
		target_side = source_side

	if event_type in ["weapon_attack", "spell_cast", "summon_attack", "pet_attack", "dot_tick"]:
		var from_pos := _source_position_for_event(event, source_side)
		var to_pos := _target_position_for_event(event, target_side)
		_spawn_projectile(from_pos, to_pos, color, _event_code(event_type))
		_spawn_float_text(_damage_text(event), to_pos + Vector2(0, -70), color)
		_pulse_actor(target_side, color)
	elif event_type in ["heal"]:
		var heal_target := target_side if target_side != "" else source_side
		_spawn_float_text("+%s" % _number_text(float(event.get("amount", event.get("healing", 0.0)))), _actor_center(heal_target) + Vector2(0, -92), _token_color("status_success"))
		_pulse_actor(heal_target, _token_color("status_success"))
	elif event_type in ["dot_apply", "status_apply", "status_expire", "passive_apply", "resistance_apply", "barrier_gain", "barrier_absorb", "cooldown_start", "cooldown_ready", "mana_change"]:
		var side := target_side if target_side != "" else source_side
		_spawn_float_text(_event_code(event_type), _actor_center(side) + Vector2(0, -108), color)
		_pulse_actor(side, color)
	elif event_type == "summon_spawn":
		var slot_side := source_side if source_side != "" else SIDE_PLAYER
		var slot := str(event.get("slot", SLOT_FRONT))
		_spawn_impact(_slot_position(slot_side, slot), color, 54.0)
		_spawn_float_text("SUM", _slot_position(slot_side, slot) + Vector2(0, -54), color)
	elif event_type == "anti_stall":
		_spawn_float_text("ANTI", _stage_size() * Vector2(0.5, 0.42), _token_color("status_error"), 28)
		_pulse_actor(SIDE_PLAYER, _token_color("status_error"))
		_pulse_actor(SIDE_OPPONENT, _token_color("status_error"))
	elif event_type == "battle_result":
		_spawn_float_text("WIN %s" % str(event.get("winner", "?")).to_upper(), _stage_size() * Vector2(0.5, 0.36), _token_color("accent_bone"), 28)

func _source_position_for_event(event: Dictionary, source_side: String) -> Vector2:
	var event_type := str(event.get("type", ""))
	if event_type == "summon_attack":
		var source_id := str(event.get("source", ""))
		for side: String in SIDES:
			var side_data := _as_dictionary(_side_state.get(side, {}))
			var summons := _as_dictionary(side_data.get("summons", {}))
			if summons.has(source_id):
				var summon := _as_dictionary(summons[source_id])
				return _slot_position(side, str(summon.get("slot", SLOT_FRONT)))
	if event_type == "pet_attack" and source_side != "":
		return _slot_position(source_side, SLOT_BACK)
	if source_side != "":
		return _actor_center(source_side)
	return _stage_size() * Vector2(0.5, 0.45)

func _target_position_for_event(_event: Dictionary, target_side: String) -> Vector2:
	if target_side != "":
		return _actor_center(target_side)
	return _stage_size() * Vector2(0.5, 0.45)

func _spawn_projectile(from_pos: Vector2, to_pos: Vector2, color: Color, symbol: String) -> void:
	var dot = BattleSymbolIconScript.new()
	dot.custom_minimum_size = Vector2(32, 32)
	dot.size = dot.custom_minimum_size
	dot.position = from_pos - dot.size * 0.5
	dot.configure(symbol, color, "Efeito procedural temporario. Futuro: battle_fx_hit/spell.")
	_effects_layer.add_child(dot)
	var tween := create_tween()
	tween.tween_property(dot, "position", to_pos - dot.size * 0.5, 0.22)
	tween.tween_callback(func() -> void:
		_spawn_impact(to_pos, color, 46.0)
		if is_instance_valid(dot):
			dot.queue_free()
	)

func _spawn_impact(center: Vector2, color: Color, diameter: float) -> void:
	var impact := PanelContainer.new()
	impact.mouse_filter = Control.MOUSE_FILTER_IGNORE
	impact.size = Vector2(diameter, diameter)
	impact.position = center - impact.size * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = color.lightened(0.18)
	style.border_color = Color.WHITE
	style.set_border_width_all(2)
	style.set_corner_radius_all(int(diameter * 0.5))
	impact.add_theme_stylebox_override("panel", style)
	impact.modulate.a = 0.78
	_effects_layer.add_child(impact)
	var tween := create_tween()
	tween.parallel().tween_property(impact, "scale", Vector2(1.8, 1.8), 0.28)
	tween.parallel().tween_property(impact, "modulate:a", 0.0, 0.28)
	tween.tween_callback(func() -> void:
		if is_instance_valid(impact):
			impact.queue_free()
	)

func _spawn_float_text(text: String, origin: Vector2, color: Color, font_size: int = 18) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color("#080B10"))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.size = Vector2(150, 34)
	label.position = origin - label.size * 0.5
	label.tooltip_text = "Numero/feedback temporario gerado pelo log."
	_effects_layer.add_child(label)
	var tween := create_tween()
	tween.parallel().tween_property(label, "position", label.position + Vector2(0, -42), 0.72)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.72)
	tween.tween_callback(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
	)

func _pulse_actor(side: String, color: Color) -> void:
	if side == "" or not _actors.has(side):
		return
	var actor = _actors[side]
	actor.pulse(color)

func _actor_center(side: String) -> Vector2:
	var stage_size := _stage_size()
	var x := stage_size.x * 0.25 if side == SIDE_PLAYER else stage_size.x * 0.75
	var y := stage_size.y * 0.68
	return Vector2(x, y)

func _slot_position(side: String, slot: String) -> Vector2:
	var center := _actor_center(side)
	var direction := 1.0 if side == SIDE_PLAYER else -1.0
	match slot:
		SLOT_FRONT:
			return center + Vector2(124.0 * direction, -4.0)
		SLOT_MIDDLE:
			return center + Vector2(38.0 * direction, -66.0)
		SLOT_BACK:
			return center + Vector2(-92.0 * direction, -16.0)
	return center

func _stage_size() -> Vector2:
	var resolved := size
	if resolved.x < 10.0:
		resolved.x = max(custom_minimum_size.x, 760.0)
	if resolved.y < 10.0:
		resolved.y = max(custom_minimum_size.y, 360.0)
	return resolved

func _event_brief(event: Dictionary) -> String:
	var event_type := str(event.get("type", ""))
	match event_type:
		"weapon_attack":
			return "%s -> %s | dano %s" % [event.get("source", ""), event.get("target", ""), _number_text(float(event.get("damage", 0.0)))]
		"spell_cast":
			return "%s | %s dano %s" % [event.get("spell_id", "spell"), event.get("target", ""), _number_text(float(event.get("damage", 0.0)))]
		"dot_tick":
			return "%s tick %s" % [event.get("status_id", "dot"), _number_text(float(event.get("damage", 0.0)))]
		"pet_attack":
			return "%s ataca %s" % [event.get("pet_id", "familiar"), event.get("target", "")]
		"summon_spawn":
			return "%s aparece" % str(event.get("target", "summon"))
		"battle_result":
			return "vencedor %s" % str(event.get("winner", "?"))
	return event_type

func _damage_text(event: Dictionary) -> String:
	var damage := float(event.get("damage", 0.0))
	var absorbed := float(event.get("absorbed", 0.0))
	if damage <= 0.0 and absorbed <= 0.0:
		return _event_code(str(event.get("type", "")))
	if absorbed > 0.0:
		return "-%s (%s)" % [_number_text(damage), _number_text(absorbed)]
	return "-%s" % _number_text(damage)

func _event_code(event_type: String) -> String:
	match event_type:
		"weapon_attack":
			return "ATK"
		"spell_cast":
			return "SP"
		"dot_apply", "dot_tick":
			return "DOT"
		"status_apply", "status_expire":
			return "STS"
		"passive_apply", "barrier_gain", "barrier_absorb", "resistance_apply":
			return "BUF"
		"summon_spawn", "summon_attack", "summon_expire":
			return "SUM"
		"pet_attack":
			return "PET"
		"heal":
			return "HEAL"
		"anti_stall":
			return "ANTI"
		"reward_preview":
			return "RW"
		"battle_result":
			return "END"
	return "EVT"

func _event_color(event: Dictionary) -> Color:
	var event_type := str(event.get("type", ""))
	if event_type == "heal":
		return _token_color("status_success")
	if event_type == "anti_stall":
		return _token_color("status_error")
	if event_type in ["battle_result", "reward_preview"]:
		return _token_color("accent_bone")
	return _damage_color(str(event.get("damage_type", "none")).to_lower())

func _damage_color(damage_type: String) -> Color:
	return Color(DAMAGE_COLORS.get(damage_type, _token_color("accent_astral")))

func _status_color(status_id: String) -> Color:
	var lowered := status_id.to_lower()
	if lowered.contains("barreira") or lowered.contains("fort"):
		return _token_color("accent_astral")
	if lowered.contains("sang") or lowered.contains("bleed"):
		return DAMAGE_COLORS["sangue"]
	if lowered.contains("queim") or lowered.contains("brasa") or lowered.contains("cinza"):
		return DAMAGE_COLORS["fogo"]
	if lowered.contains("gelo") or lowered.contains("lento") or lowered.contains("resfri"):
		return DAMAGE_COLORS["gelo"]
	if lowered.contains("anti"):
		return _token_color("status_error")
	if lowered.contains("medo") or lowered.contains("inquiet") or lowered.contains("terror"):
		return DAMAGE_COLORS["mental"]
	return _token_color("accent_bone")

func _symbol_for_id(value: String) -> String:
	var parts := value.split("_", false)
	if parts.is_empty():
		return "?"
	var first := str(parts[0]).substr(0, min(3, str(parts[0]).length())).to_upper()
	return first if first != "" else "?"

func _side_color(side: String) -> Color:
	return _token_color("accent_astral") if side == SIDE_PLAYER else _token_color("accent_blood")

func _slot_color(slot: String) -> Color:
	match slot:
		SLOT_FRONT:
			return Color("#E06A3B")
		SLOT_MIDDLE:
			return Color("#5DD4C8")
		SLOT_BACK:
			return Color("#A57BD8")
	return _token_color("border_default")

func _slot_label(slot: String) -> String:
	match slot:
		SLOT_FRONT:
			return "frente"
		SLOT_MIDDLE:
			return "meio"
		SLOT_BACK:
			return "tras"
	return slot

func _slot_short(slot: String) -> String:
	match slot:
		SLOT_FRONT:
			return "F"
		SLOT_MIDDLE:
			return "M"
		SLOT_BACK:
			return "T"
	return "?"

func _side_from_actor(actor: String) -> String:
	if actor == SIDE_PLAYER or actor.begins_with("player_"):
		return SIDE_PLAYER
	if actor == SIDE_OPPONENT or actor.begins_with("opponent_"):
		return SIDE_OPPONENT
	return ""

func _default_side_name(side: String) -> String:
	return "Draxos" if side == SIDE_PLAYER else "Oponente"

func _stage_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_PASS
	return label

func _panel_style(bg_token: String, border_token: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _token_color(bg_token)
	style.border_color = _token_color(border_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _token_color(token: String, fallback: Color = Color.WHITE) -> Color:
	if is_inside_tree():
		var ui_tokens: Node = get_tree().root.get_node_or_null("UiTokens")
		if ui_tokens != null and ui_tokens.has_method("color"):
			return ui_tokens.color(token, fallback)
	return Color(TOKEN_COLOR_FALLBACKS.get(token, fallback))

func _number_text(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	return "%.1f" % value

func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.free()

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
