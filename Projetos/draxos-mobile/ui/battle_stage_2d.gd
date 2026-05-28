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
const STAGE_TOOLTIP_META := "battle_stage_tooltip_text"

const EVENT_ASSET_IDS := {
	"weapon_attack": "battle_icon_weapon",
	"spell_cast": "battle_icon_spell",
	"dot_apply": "battle_icon_status",
	"dot_tick": "battle_icon_damage",
	"status_apply": "battle_icon_status",
	"status_expire": "battle_icon_status",
	"passive_apply": "battle_icon_buff",
	"barrier_gain": "battle_icon_buff",
	"barrier_absorb": "battle_icon_buff",
	"resistance_apply": "battle_icon_buff",
	"summon_spawn": "battle_icon_summon",
	"summon_attack": "battle_icon_summon",
	"summon_expire": "battle_icon_summon",
	"pet_attack": "battle_icon_pet",
	"heal": "battle_icon_heal",
	"anti_stall": "battle_icon_damage",
	"reward_preview": "battle_icon_reward",
	"battle_result": "battle_icon_result",
}

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
var _readout_panel: PanelContainer
var _readout_label: Label
var _empty_label: Label
var _tooltip_panel: PanelContainer
var _tooltip_label: Label
var _tooltip_source: Control
var _last_animated_key := ""
var _visual_replay_time := 0.0

func _ready() -> void:
	_ensure_ui()

func show_empty_state(message: String) -> void:
	_ensure_ui()
	_side_state = {}
	_latest_event = {}
	_event_index = 0
	_event_count = 0
	_visual_replay_time = 0.0
	_last_animated_key = ""
	_empty_label.text = message
	_empty_label.visible = true
	_event_label.text = "Aguardando battle_log_v1"
	_event_icon.configure("...", _token_color("placeholder"), "Palco de batalha vazio. Quando um replay carregar, este icone mostra o evento atual recebido do battle_log_v1.")
	_render_dynamic_state()

func render_snapshot(side_state: Dictionary, latest_event: Dictionary, event_index: int, event_count: int, animate_event: bool = false, replay_time: float = -1.0) -> void:
	_ensure_ui()
	_side_state = side_state.duplicate(true)
	_latest_event = latest_event.duplicate(true)
	_event_index = event_index
	_event_count = event_count
	_visual_replay_time = maxf(0.0, replay_time) if replay_time >= 0.0 else float(_latest_event.get("t", 0.0))
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
		"replay_time": _visual_replay_time,
		"readout": _readout_label.text if _readout_label != null else "",
		"readout_tooltip": _stage_tooltip_text(_readout_label) if _readout_label != null else "",
		"tooltips": debug_tooltip_samples(),
		"tooltip_node_ids": debug_tooltip_node_ids(),
		"cooldown_counts": debug_cooldown_counts(),
	}

func debug_event_feedback_text(event: Dictionary) -> String:
	return _effect_feedback_text(event)

func debug_tooltip_samples() -> Dictionary:
	var status_tooltips: Array[String] = []
	var cooldown_tooltips: Array[String] = []
	for side: String in SIDES:
		status_tooltips.append_array(_collect_tooltips(_status_rows.get(side)))
		cooldown_tooltips.append_array(_collect_tooltips(_cooldown_rows.get(side)))
	return {
		"event": _stage_tooltip_text(_event_icon) if _event_icon != null else "",
		"slots": _collect_tooltips(_slot_layer),
		"status": status_tooltips,
		"cooldowns": cooldown_tooltips,
	}

func debug_tooltip_node_ids() -> Dictionary:
	var status_ids: Array[String] = []
	var cooldown_ids: Array[String] = []
	for side: String in SIDES:
		status_ids.append_array(_collect_tooltip_node_ids(_status_rows.get(side)))
		cooldown_ids.append_array(_collect_tooltip_node_ids(_cooldown_rows.get(side)))
	return {
		"slots": _collect_tooltip_node_ids(_slot_layer),
		"status": status_ids,
		"cooldowns": cooldown_ids,
	}

func debug_has_native_tooltips() -> bool:
	return _has_native_tooltip(self)

func debug_native_tooltip_paths() -> Array[String]:
	var paths: Array[String] = []
	_collect_native_tooltip_paths(self, paths)
	return paths

func debug_cooldown_counts() -> Dictionary:
	var counts: Dictionary = {}
	for side: String in SIDES:
		counts[side] = _collect_symbol_counts(_cooldown_rows.get(side))
	return counts

func _ensure_ui() -> void:
	if _built:
		return
	_built = true
	clip_contents = true
	custom_minimum_size = Vector2(360, 360)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	resized.connect(_layout_nodes)

	_slot_layer = Control.new()
	_slot_layer.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_slot_layer)

	for side: String in SIDES:
		var actor = BattleActorMarkerScript.new()
		actor.name = "%sActor" % side.capitalize()
		actor.configure(side, _default_side_name(side), _side_color(side))
		add_child(actor)
		_bind_stage_tooltip(actor)
		_actors[side] = actor

		var name_label := _stage_label(_default_side_name(side), 16, _token_color("text_primary"))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		add_child(name_label)
		_bind_stage_tooltip(name_label)
		_name_labels[side] = name_label

		var status_row := HBoxContainer.new()
		status_row.add_theme_constant_override("separation", 4)
		status_row.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(status_row)
		_status_rows[side] = status_row

		var cooldown_row := HBoxContainer.new()
		cooldown_row.add_theme_constant_override("separation", 4)
		cooldown_row.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(cooldown_row)
		_cooldown_rows[side] = cooldown_row

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
	_bind_stage_tooltip(_event_icon)
	_event_label = _stage_label("Aguardando battle_log_v1", 13, _token_color("text_primary"))
	_event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_event_label.custom_minimum_size = Vector2(240, 42)
	event_row.add_child(_event_label)
	_bind_stage_tooltip(_event_label)

	_readout_panel = PanelContainer.new()
	_readout_panel.name = "ReadoutPanel"
	_readout_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	_readout_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(_readout_panel)
	_bind_stage_tooltip(_readout_panel)
	_readout_label = _stage_label("Replay 0/0 | Tempo 0s", 12, _token_color("text_secondary"))
	_readout_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_readout_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_readout_panel.add_child(_readout_label)
	_bind_stage_tooltip(_readout_label)

	_empty_label = _stage_label("", 15, _token_color("text_secondary"))
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_empty_label)

	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.name = "BattleTooltip"
	_tooltip_panel.visible = false
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_active"))
	add_child(_tooltip_panel)
	_tooltip_label = _stage_label("", 12, _token_color("text_primary"))
	_tooltip_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tooltip_panel.add_child(_tooltip_label)

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
		name_label.position = Vector2(_clamped_stage_x(center.x - name_label.size.x * 0.5, name_label.size.x, stage_size.x), actor.position.y - 28.0)

		var status_row: Control = _status_rows[side]
		status_row.size = Vector2(260, 44)
		status_row.position = Vector2(_clamped_stage_x(center.x - status_row.size.x * 0.5, status_row.size.x, stage_size.x), max(10.0, actor.position.y - 78.0))

		var cooldown_row: Control = _cooldown_rows[side]
		cooldown_row.size = Vector2(260, 44)
		cooldown_row.position = Vector2(_clamped_stage_x(center.x - cooldown_row.size.x * 0.5, cooldown_row.size.x, stage_size.x), actor.position.y + actor_size.y + 8.0)

	_slot_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	_effects_layer.set_anchors_preset(Control.PRESET_FULL_RECT)

	var event_panel := get_node_or_null("EventPanel") as Control
	if event_panel != null:
		event_panel.size = Vector2(min(360.0, stage_size.x - 32.0), 62.0)
		event_panel.position = Vector2((stage_size.x - event_panel.size.x) * 0.5, 12.0)

	var readout_panel := get_node_or_null("ReadoutPanel") as Control
	if readout_panel != null:
		readout_panel.size = Vector2(min(560.0, stage_size.x - 32.0), 54.0)
		readout_panel.position = Vector2((stage_size.x - readout_panel.size.x) * 0.5, 82.0)
		if _readout_label != null:
			_readout_label.custom_minimum_size = Vector2(maxf(120.0, readout_panel.size.x - 18.0), 0.0)

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
		name_label.text = "%s  HP %s/%s (%s%%)" % [
			display_name,
			_number_text(float(side_data.get("hp", 0.0))),
			_number_text(float(side_data.get("max_hp", 1.0))),
			_hp_percent_text(side_data),
		]
		_set_stage_tooltip(actor, actor.tooltip_text)
		_set_stage_tooltip(name_label, _stage_tooltip_text(actor))
		_refresh_stage_tooltip(actor)
		_refresh_stage_tooltip(name_label)
		_render_icon_row(_status_rows[side], statuses, "status")
		_render_icon_row(_cooldown_rows[side], _as_dictionary(side_data.get("cooldowns", {})), "cooldown")

	_render_slots()
	_render_readout()
	_render_event_panel()
	if _tooltip_source != null:
		_refresh_stage_tooltip(_tooltip_source)
	queue_redraw()

func _render_icon_row(row: HBoxContainer, values: Dictionary, row_kind: String) -> void:
	var entries: Array[Dictionary] = []
	if values.is_empty():
		entries.append({
			"key": "empty",
			"symbol": "-",
			"color": _token_color("border_default"),
			"tooltip": _empty_row_tooltip(row_kind),
			"count": "",
			"cooldown_ratio": 0.0,
			"size": Vector2(34, 34),
		})
		_sync_symbol_icon_row(row, entries)
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
			var ready_at: float = _cooldown_ready_at(value)
			var remaining: float = _cooldown_remaining(value)
			count = "%ss" % _number_text(remaining)
			cooldown_ratio = _cooldown_ratio(value)
			tooltip = _cooldown_tooltip(str(key), ready_at, remaining)
		elif value is Dictionary:
			var stacks := int(Dictionary(value).get("stacks", 1))
			if stacks > 1:
				count = "x%d" % stacks
			tooltip = _status_tooltip(str(key), value)
		entries.append({
			"key": str(key),
			"symbol": symbol,
			"color": color,
			"tooltip": tooltip,
			"count": count,
			"cooldown_ratio": cooldown_ratio,
			"asset_id": _asset_id_for_icon_row(row_kind),
			"size": Vector2(36, 36),
		})
	_sync_symbol_icon_row(row, entries)

func _render_slots() -> void:
	var entries: Array[Dictionary] = []
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
				"symbol": "@",
				"asset_id": "battle_icon_pet",
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
				"symbol": "^",
				"asset_id": "battle_icon_summon",
			})
		var used_offsets: Dictionary = {}
		for entry: Dictionary in slot_entries:
			var slot := str(entry.get("slot", SLOT_MIDDLE))
			var offset_count := int(used_offsets.get(slot, 0))
			used_offsets[slot] = offset_count + 1
			var entry_color: Color = _token_color("accent_bone")
			if entry.get("color", null) is Color:
				entry_color = entry.get("color")
			var pos := _slot_position(side, slot)
			entries.append({
				"key": "%s:%s:%s" % [side, str(entry.get("kind", "objeto")), str(entry.get("id", ""))],
				"symbol": str(entry.get("symbol", "?")),
				"color": entry_color,
				"tooltip": _slot_entry_tooltip(entry, side, slot),
				"count": _slot_short(slot),
				"cooldown_ratio": 0.0,
				"asset_id": str(entry.get("asset_id", "")),
				"size": Vector2(46, 46),
				"position": pos - Vector2(46, 46) * 0.5 + Vector2(0, offset_count * 8.0),
			})
	_sync_slot_icons(entries)

func _render_event_panel() -> void:
	if _latest_event.is_empty():
		var empty_tooltip := "Replay aguardando o proximo evento do battle_log_v1."
		_event_icon.configure("...", _token_color("placeholder"), empty_tooltip)
		_set_stage_tooltip(_event_icon, empty_tooltip)
		_event_label.text = "Evento %d/%d | aguardando replay" % [_event_index, _event_count]
		_set_stage_tooltip(_event_label, empty_tooltip)
		_refresh_stage_tooltip(_event_icon)
		_refresh_stage_tooltip(_event_label)
		return
	var event_type := str(_latest_event.get("type", ""))
	var event_tooltip := _event_tooltip(_latest_event)
	_event_icon.configure(_event_code(event_type), _event_color(_latest_event), event_tooltip, "", 0.0, _asset_id_for_event(event_type))
	_set_stage_tooltip(_event_icon, event_tooltip)
	_event_label.text = "Evento %d/%d | %ss | %s" % [
		_event_index,
		_event_count,
		"%.1f" % float(_latest_event.get("t", 0.0)),
		_event_brief(_latest_event),
	]
	_set_stage_tooltip(_event_label, event_tooltip)
	_refresh_stage_tooltip(_event_icon)
	_refresh_stage_tooltip(_event_label)

func _render_readout() -> void:
	if _readout_label == null:
		return
	var readout_tooltip := "Resumo rapido da batalha\nMostra progresso do replay, tempo atual, vida percentual, status, cooldowns e aliados visiveis de cada lado.\nTodos os valores sao derivados do battle_log_v1 recebido; o cliente apresenta o replay e nao calcula resultado."
	if _side_state.is_empty() and _latest_event.is_empty():
		_readout_label.text = "Replay 0/0 | aguardando battle_log_v1\nHP, status, cooldowns e aliados aparecem quando uma batalha carregar."
		_set_stage_tooltip(_readout_label, readout_tooltip)
		_set_stage_tooltip(_readout_panel, readout_tooltip)
		_refresh_stage_tooltip(_readout_label)
		_refresh_stage_tooltip(_readout_panel)
		return
	var player_data := _as_dictionary(_side_state.get(SIDE_PLAYER, {}))
	var opponent_data := _as_dictionary(_side_state.get(SIDE_OPPONENT, {}))
	var readout_text := "Replay %d/%d | Tempo %ss | %s x %s\nStatus %d x %d | Cooldowns %d x %d | Aliados %d x %d" % [
		_event_index,
		_event_count,
		_number_text(_current_replay_time()),
		_side_hp_summary(player_data, SIDE_PLAYER),
		_side_hp_summary(opponent_data, SIDE_OPPONENT),
		_active_status_count(player_data),
		_active_status_count(opponent_data),
		_active_cooldown_count(player_data),
		_active_cooldown_count(opponent_data),
		_visible_ally_count(player_data),
		_visible_ally_count(opponent_data),
	]
	_readout_label.text = readout_text
	_set_stage_tooltip(_readout_label, readout_tooltip)
	_set_stage_tooltip(_readout_panel, readout_tooltip)
	_refresh_stage_tooltip(_readout_label)
	_refresh_stage_tooltip(_readout_panel)

func _side_hp_summary(side_data: Dictionary, side: String) -> String:
	var display_name := str(side_data.get("display_name", _default_side_name(side)))
	return "%s HP %s%%" % [display_name, _hp_percent_text(side_data)]

func _hp_percent_text(side_data: Dictionary) -> String:
	var max_hp := maxf(1.0, float(side_data.get("max_hp", 1.0)))
	var hp := clampf(float(side_data.get("hp", 0.0)), 0.0, max_hp)
	return _number_text((hp / max_hp) * 100.0)

func _active_status_count(side_data: Dictionary) -> int:
	return _as_dictionary(side_data.get("statuses", {})).size()

func _active_cooldown_count(side_data: Dictionary) -> int:
	return _as_dictionary(side_data.get("cooldowns", {})).size()

func _visible_ally_count(side_data: Dictionary) -> int:
	var total := _as_dictionary(side_data.get("summons", {})).size()
	if str(side_data.get("familiar", "")) != "":
		total += 1
	return total

func _empty_row_tooltip(row_kind: String) -> String:
	match row_kind:
		"cooldown":
			return "Cooldowns\nNenhuma spell esta em recarga agora. Quando o simulador emitir cooldown_start, o icone mostra o tempo restante ate ready_at."
		"status":
			return "Status e buffs\nNenhum buff, debuff, DoT ou resistencia esta ativo neste lado da batalha."
	return "Nenhum marcador ativo nesta linha."

func _status_tooltip(status_id: String, value: Variant) -> String:
	var stacks := 1
	var details := PackedStringArray()
	if value is Dictionary:
		var status := _as_dictionary(value)
		stacks = maxi(1, int(status.get("stacks", 1)))
		if status.has("duration"):
			details.append("Duracao informada: %ss." % _number_text(float(status.get("duration", 0.0))))
		if status.has("source"):
			details.append("Fonte: %s." % str(status.get("source", "")))
	details.append("Stacks: %d." % stacks)
	details.append("O cliente mostra o estado atual; aplicacao, expiracao e efeito real vem do simulador autoritativo.")
	return "Status ativo: %s\n%s" % [_humanize_id(status_id), "\n".join(details)]

func _cooldown_tooltip(spell_id: String, ready_at: float, remaining: float) -> String:
	return "Cooldown de spell: %s\nA spell foi usada e fica indisponivel ate o tempo do replay chegar ao ready_at.\nTempo atual do replay: %ss.\nRestante: %ss.\nPronta em: %ss.\nO aro escuro mostra a recarga visual; a regra real vem do battle_log_v1." % [
		_humanize_id(spell_id),
		_number_text(_current_replay_time()),
		_number_text(remaining),
		_number_text(ready_at),
	]

func _current_replay_time() -> float:
	return _visual_replay_time

func _cooldown_ready_at(value: Variant) -> float:
	if value is Dictionary:
		var data := _as_dictionary(value)
		return float(data.get("ready_at", 0.0))
	return float(value)

func _cooldown_started_at(value: Variant) -> float:
	if value is Dictionary:
		var data := _as_dictionary(value)
		if data.has("started_at"):
			return float(data.get("started_at", 0.0))
	return 0.0

func _cooldown_remaining(value: Variant) -> float:
	var ready_at: float = _cooldown_ready_at(value)
	return maxf(0.0, ready_at - _current_replay_time())

func _cooldown_ratio(value: Variant) -> float:
	var ready_at: float = _cooldown_ready_at(value)
	var started_at: float = _cooldown_started_at(value)
	var total: float = maxf(0.1, ready_at - started_at)
	return clampf(_cooldown_remaining(value) / total, 0.0, 1.0)

func _slot_entry_tooltip(entry: Dictionary, side: String, slot: String) -> String:
	var kind := str(entry.get("kind", "objeto"))
	var title := "Objeto"
	var behavior := "Marcador auxiliar do lado da batalha."
	if kind == "familiar":
		title = "Familiar"
		behavior = "Companheiro equipado do combatente. Ele aparece atras e anima quando o log receber pet_attack."
	elif kind == "summon":
		title = "Summon"
		behavior = "Criatura invocada por spell. Ela ocupa frente, meio ou tras e anima quando o log receber summon_attack."
	return "%s: %s\nLado: %s | Posicao: %s\n%s\nO cliente nao calcula ataques; ele apenas apresenta eventos recebidos." % [
		title,
		str(entry.get("id", "")),
		_default_side_name(side),
		_slot_label(slot),
		behavior,
	]

func _event_tooltip(event: Dictionary) -> String:
	var event_type := str(event.get("type", ""))
	var lines := PackedStringArray()
	lines.append("%s (%s)" % [_event_title(event_type), event_type])
	lines.append("Evento %d/%d em %ss do battle_log_v1." % [
		_event_index,
		_event_count,
		_number_text(float(event.get("t", 0.0))),
	])
	var source := str(event.get("source", ""))
	var target := str(event.get("target", ""))
	if source != "":
		lines.append("Fonte: %s." % _humanize_id(source))
	if target != "" and target != "none":
		lines.append("Alvo: %s." % _humanize_id(target))
	lines.append("Leitura rapida: %s." % _effect_feedback_text(event))
	match event_type:
		"weapon_attack":
			lines.append("Ataque basico do combatente. Mostra dano e HP final recebidos do servidor.")
		"spell_cast":
			lines.append("Spell conjurada: %s. O icone resume dano, tipo e alvo do cast." % str(event.get("spell_id", "spell")))
		"dot_apply", "status_apply", "resistance_apply":
			lines.append("Aplica status/buff/debuff: %s." % str(event.get("status_id", event.get("spell_id", event_type))))
		"dot_tick":
			lines.append("Tick de dano ao longo do tempo: %s." % str(event.get("status_id", "dot")))
		"cooldown_start":
			var ready_at: float = float(event.get("ready_at", 0.0))
			var remaining: float = maxf(0.0, ready_at - float(event.get("t", _current_replay_time())))
			lines.append("Inicia recarga da spell %s: restante %ss, pronta em %ss." % [_humanize_id(str(event.get("spell_id", "spell"))), _number_text(remaining), _number_text(ready_at)])
		"cooldown_ready":
			lines.append("A spell %s voltou a ficar pronta." % _humanize_id(str(event.get("spell_id", "spell"))))
		"pet_attack":
			lines.append("Familiar ataca. O familiar e visual; resultado ja veio do simulador.")
		"summon_spawn":
			lines.append("Summon aparece no slot visual de seu lado da arena.")
		"summon_attack":
			lines.append("Summon ataca a partir do slot onde esta representado.")
		"heal":
			lines.append("Cura aplicada ao alvo, com HP final informado no evento.")
		"barrier_gain", "barrier_absorb", "passive_apply":
			lines.append("Feedback defensivo/passivo: mostra escudo, absorcao ou passiva ativa.")
		"anti_stall":
			lines.append("Regra anti-stall do simulador para encerrar lutas longas.")
		"battle_result":
			lines.append("Resultado final da batalha.")
	if event.has("damage"):
		lines.append("Dano: %s %s." % [_number_text(float(event.get("damage", 0.0))), str(event.get("damage_type", "none"))])
	if event.has("absorbed"):
		lines.append("Absorvido por barreira: %s." % _number_text(float(event.get("absorbed", 0.0))))
	if event.has("hp_after"):
		lines.append("HP apos evento: %s." % _number_text(float(event.get("hp_after", 0.0))))
	if event.has("barrier_after"):
		lines.append("Barreira apos evento: %s." % _number_text(float(event.get("barrier_after", 0.0))))
	if event.has("winner"):
		lines.append("Vencedor: %s." % str(event.get("winner", "")))
	lines.append("Trocar asset futuro: %s." % _asset_id_for_event(event_type))
	return "\n".join(lines)

func _event_title(event_type: String) -> String:
	match event_type:
		"weapon_attack":
			return "Ataque basico"
		"spell_cast":
			return "Spell conjurada"
		"dot_apply":
			return "DoT aplicado"
		"dot_tick":
			return "Dano periodico"
		"status_apply":
			return "Status aplicado"
		"status_expire":
			return "Status expirou"
		"passive_apply":
			return "Passiva ativada"
		"barrier_gain":
			return "Barreira ganhou carga"
		"barrier_absorb":
			return "Barreira absorveu dano"
		"resistance_apply":
			return "Resistencia aplicada"
		"summon_spawn":
			return "Summon invocado"
		"summon_attack":
			return "Summon atacou"
		"summon_expire":
			return "Summon saiu"
		"pet_attack":
			return "Familiar atacou"
		"heal":
			return "Cura"
		"battle_start":
			return "Inicio da batalha"
		"cooldown_start":
			return "Cooldown iniciado"
		"cooldown_ready":
			return "Spell pronta"
		"mana_change":
			return "Mana alterada"
		"anti_stall":
			return "Anti-stall"
		"reward_preview":
			return "Previa de recompensa"
		"battle_result":
			return "Resultado"
	return "Evento"

func _asset_id_for_event(event_type: String) -> String:
	return str(EVENT_ASSET_IDS.get(event_type, "battle_icon_event"))

func _asset_id_for_icon_row(row_kind: String) -> String:
	match row_kind:
		"status":
			return "battle_icon_status"
		"cooldown":
			return "battle_icon_spell"
	return ""

func _sync_symbol_icon_row(row: HBoxContainer, entries: Array[Dictionary]) -> void:
	var existing := _children_by_render_key(row)
	var wanted: Dictionary = {}
	for index: int in range(entries.size()):
		var entry := entries[index]
		var key := str(entry.get("key", ""))
		wanted[key] = true
		var icon := existing.get(key, null) as BattleSymbolIcon
		if icon == null:
			icon = BattleSymbolIconScript.new()
			icon.set_meta("render_key", key)
			row.add_child(icon)
			_bind_stage_tooltip(icon)
		_configure_symbol_icon(icon, entry)
		if icon.get_index() != index:
			row.move_child(icon, index)
		_refresh_stage_tooltip(icon)
	_remove_unwanted_children(row, wanted)

func _sync_slot_icons(entries: Array[Dictionary]) -> void:
	var existing := _children_by_render_key(_slot_layer)
	var wanted: Dictionary = {}
	for index: int in range(entries.size()):
		var entry := entries[index]
		var key := str(entry.get("key", ""))
		wanted[key] = true
		var icon := existing.get(key, null) as BattleSymbolIcon
		if icon == null:
			icon = BattleSymbolIconScript.new()
			icon.set_meta("render_key", key)
			_slot_layer.add_child(icon)
			_bind_stage_tooltip(icon)
		_configure_symbol_icon(icon, entry)
		var icon_position: Vector2 = Vector2(entry.get("position", icon.position))
		icon.position = icon_position
		if icon.get_index() != index:
			_slot_layer.move_child(icon, index)
		_refresh_stage_tooltip(icon)
	_remove_unwanted_children(_slot_layer, wanted)

func _configure_symbol_icon(icon: BattleSymbolIcon, entry: Dictionary) -> void:
	var icon_size: Vector2 = Vector2(entry.get("size", Vector2(36, 36)))
	var icon_color: Color = _token_color("accent_bone")
	if entry.get("color", null) is Color:
		icon_color = entry.get("color")
	icon.custom_minimum_size = icon_size
	icon.size = icon_size
	icon.configure(
		str(entry.get("symbol", "?")),
		icon_color,
		str(entry.get("tooltip", "")),
		str(entry.get("count", "")),
		float(entry.get("cooldown_ratio", 0.0)),
		str(entry.get("asset_id", ""))
	)
	_set_stage_tooltip(icon, str(entry.get("tooltip", "")))

func _children_by_render_key(parent: Node) -> Dictionary:
	var existing: Dictionary = {}
	for child: Node in parent.get_children():
		var key := str(child.get_meta("render_key", ""))
		if key != "":
			existing[key] = child
	return existing

func _remove_unwanted_children(parent: Node, wanted: Dictionary) -> void:
	for child: Node in parent.get_children():
		var key := str(child.get_meta("render_key", ""))
		if key == "" or wanted.has(key):
			continue
		if _tooltip_source == child:
			_hide_stage_tooltip()
		parent.remove_child(child)
		child.free()

func _bind_stage_tooltip(control: Control) -> void:
	if control == null or control.has_meta("battle_tooltip_bound"):
		return
	if control.tooltip_text.strip_edges() != "":
		_set_stage_tooltip(control, control.tooltip_text)
	control.set_meta("battle_tooltip_bound", true)
	control.mouse_entered.connect(func() -> void:
		_show_stage_tooltip(control)
	)
	control.mouse_exited.connect(func() -> void:
		if _tooltip_source == control:
			_hide_stage_tooltip()
	)
	control.gui_input.connect(func(event: InputEvent) -> void:
		if event is InputEventMouseMotion and _tooltip_source == control:
			_position_stage_tooltip()
	)

func _show_stage_tooltip(control: Control) -> void:
	if control == null:
		_hide_stage_tooltip()
		return
	var text := _stage_tooltip_text(control)
	if text == "":
		_hide_stage_tooltip()
		return
	_tooltip_source = control
	_tooltip_label.text = text
	_tooltip_panel.visible = true
	_position_stage_tooltip()

func _refresh_stage_tooltip(control: Control) -> void:
	if _tooltip_source == control:
		_show_stage_tooltip(control)

func _set_stage_tooltip(control: Control, text: String) -> void:
	if control == null:
		return
	var normalized := text.strip_edges()
	control.set_meta(STAGE_TOOLTIP_META, normalized)
	control.tooltip_text = ""

func _stage_tooltip_text(control: Control) -> String:
	if control == null:
		return ""
	if control.has_meta(STAGE_TOOLTIP_META):
		return str(control.get_meta(STAGE_TOOLTIP_META)).strip_edges()
	return control.tooltip_text.strip_edges()

func _hide_stage_tooltip() -> void:
	_tooltip_source = null
	if _tooltip_panel != null:
		_tooltip_panel.visible = false

func _position_stage_tooltip() -> void:
	if _tooltip_panel == null or not _tooltip_panel.visible:
		return
	var stage_size := _stage_size()
	var tooltip_width: float = min(340.0, max(220.0, stage_size.x - 24.0))
	_tooltip_label.custom_minimum_size = Vector2(max(160.0, tooltip_width - 20.0), 0.0)
	_tooltip_panel.size = Vector2(tooltip_width, 0.0)
	_tooltip_panel.reset_size()
	var panel_size := _tooltip_panel.size
	var tooltip_position := get_local_mouse_position() + Vector2(14.0, 14.0)
	tooltip_position.x = clampf(tooltip_position.x, 8.0, max(8.0, stage_size.x - panel_size.x - 8.0))
	tooltip_position.y = clampf(tooltip_position.y, 8.0, max(8.0, stage_size.y - panel_size.y - 8.0))
	_tooltip_panel.position = tooltip_position
	_tooltip_panel.move_to_front()

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
		_spawn_float_text(_effect_feedback_text(event), to_pos + Vector2(0, -70), color)
		_pulse_actor(target_side, color)
	elif event_type in ["heal"]:
		var heal_target := target_side if target_side != "" else source_side
		_spawn_float_text(_effect_feedback_text(event), _actor_center(heal_target) + Vector2(0, -92), _token_color("status_success"))
		_pulse_actor(heal_target, _token_color("status_success"))
	elif event_type in ["dot_apply", "status_apply", "status_expire", "passive_apply", "resistance_apply", "barrier_gain", "barrier_absorb", "cooldown_start", "cooldown_ready", "mana_change"]:
		var side := target_side if target_side != "" else source_side
		_spawn_float_text(_effect_feedback_text(event), _actor_center(side) + Vector2(0, -108), color)
		_pulse_actor(side, color)
	elif event_type == "summon_spawn":
		var slot_side := source_side if source_side != "" else SIDE_PLAYER
		var summon_id := str(event.get("target", "summon"))
		var slot := _summon_slot_for_event(slot_side, summon_id, str(event.get("slot", SLOT_FRONT)))
		_spawn_impact(_slot_position(slot_side, slot), color, 54.0)
		_spawn_float_text(_effect_feedback_text(event), _slot_position(slot_side, slot) + Vector2(0, -54), color)
	elif event_type == "anti_stall":
		_spawn_float_text(_effect_feedback_text(event), _stage_size() * Vector2(0.5, 0.42), _token_color("status_error"), 28)
		_pulse_actor(SIDE_PLAYER, _token_color("status_error"))
		_pulse_actor(SIDE_OPPONENT, _token_color("status_error"))
	elif event_type == "battle_result":
		_spawn_float_text(_effect_feedback_text(event), _stage_size() * Vector2(0.5, 0.36), _token_color("accent_bone"), 28)

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

func _summon_slot_for_event(side: String, summon_id: String, fallback: String) -> String:
	var side_data := _as_dictionary(_side_state.get(side, {}))
	var summons := _as_dictionary(side_data.get("summons", {}))
	if summons.has(summon_id):
		var summon := _as_dictionary(summons[summon_id])
		return str(summon.get("slot", fallback))
	return fallback

func _target_position_for_event(_event: Dictionary, target_side: String) -> Vector2:
	if target_side != "":
		return _actor_center(target_side)
	return _stage_size() * Vector2(0.5, 0.45)

func _spawn_projectile(from_pos: Vector2, to_pos: Vector2, color: Color, symbol: String) -> void:
	var dot = BattleSymbolIconScript.new()
	dot.custom_minimum_size = Vector2(32, 32)
	dot.size = dot.custom_minimum_size
	dot.position = from_pos - dot.size * 0.5
	dot.configure(symbol, color)
	_effects_layer.add_child(dot)
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var max_width: float = maxf(180.0, _stage_size().x - 24.0)
	var text_width: float = clampf(150.0 + float(text.length()) * 6.5, 190.0, minf(360.0, max_width))
	var text_height: float = 42.0 if font_size <= 20 else 58.0
	label.size = Vector2(text_width, text_height)
	label.position = origin - label.size * 0.5
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	var stage_width := _stage_size().x
	var front_offset := clampf(stage_width * 0.16, 58.0, 124.0)
	var middle_offset := clampf(stage_width * 0.05, 22.0, 38.0)
	var back_offset := clampf(stage_width * 0.12, 46.0, 92.0)
	match slot:
		SLOT_FRONT:
			return center + Vector2(front_offset * direction, -4.0)
		SLOT_MIDDLE:
			return center + Vector2(middle_offset * direction, -66.0)
		SLOT_BACK:
			return center + Vector2(-back_offset * direction, -16.0)
	return center

func _stage_size() -> Vector2:
	var resolved := size
	if resolved.x < 10.0:
		resolved.x = max(custom_minimum_size.x, 360.0)
	if resolved.y < 10.0:
		resolved.y = max(custom_minimum_size.y, 360.0)
	return resolved

func _clamped_stage_x(value: float, width: float, stage_width: float) -> float:
	var margin := 8.0
	if width >= stage_width - margin * 2.0:
		return margin
	return clampf(value, margin, maxf(margin, stage_width - width - margin))

func _event_brief(event: Dictionary) -> String:
	return _effect_feedback_text(event)

func _damage_text(event: Dictionary) -> String:
	return _effect_feedback_text(event)

func _effect_feedback_text(event: Dictionary) -> String:
	var event_type := str(event.get("type", ""))
	match event_type:
		"weapon_attack":
			return _feedback_with_suffix("Ataque basico", _damage_suffix(event))
		"spell_cast":
			return _feedback_with_suffix("Spell: %s" % _humanize_id(str(event.get("spell_id", "spell"))), _damage_suffix(event))
		"dot_tick":
			return _feedback_with_suffix("Dano periodico: %s" % _humanize_id(str(event.get("status_id", "dot"))), _damage_suffix(event))
		"summon_attack":
			return _feedback_with_suffix("Summon: %s" % _humanize_id(str(event.get("source", "summon"))), _damage_suffix(event))
		"pet_attack":
			return _feedback_with_suffix("Familiar: %s" % _humanize_id(str(event.get("pet_id", "familiar"))), _damage_suffix(event))
		"heal":
			return "Cura +%s" % _number_text(float(event.get("amount", event.get("healing", 0.0))))
		"dot_apply":
			return "DoT aplicado: %s" % _humanize_id(str(event.get("status_id", event.get("spell_id", "dot"))))
		"status_apply":
			return "Status aplicado: %s" % _humanize_id(str(event.get("status_id", "status")))
		"status_expire":
			return "Status expirou: %s" % _humanize_id(str(event.get("status_id", "status")))
		"passive_apply":
			return "Doutrina: %s" % _humanize_id(str(event.get("passive_id", "passiva")))
		"resistance_apply":
			return "Resistencia: %s" % _humanize_id(str(event.get("status_id", event.get("spell_id", "resistencia"))))
		"barrier_gain":
			return "Barreira +%s" % _number_text(float(event.get("amount", event.get("barrier_after", 0.0))))
		"barrier_absorb":
			return "Barreira absorveu %s" % _number_text(float(event.get("absorbed", event.get("amount", 0.0))))
		"cooldown_start":
			var ready_at: float = float(event.get("ready_at", 0.0))
			var remaining: float = maxf(0.0, ready_at - float(event.get("t", _current_replay_time())))
			return "Cooldown: %s (%ss)" % [_humanize_id(str(event.get("spell_id", "spell"))), _number_text(remaining)]
		"cooldown_ready":
			return "Spell pronta: %s" % _humanize_id(str(event.get("spell_id", "spell")))
		"mana_change":
			return "Mana: %s" % _number_text(float(event.get("mana_after", 0.0)))
		"summon_spawn":
			return "Summon invocado: %s" % _humanize_id(str(event.get("target", "summon")))
		"summon_expire":
			return "Summon saiu: %s" % _humanize_id(str(event.get("source", event.get("target", "summon"))))
		"anti_stall":
			return "Anti-stall"
		"reward_preview":
			return "Recompensa: %s" % _humanize_id(str(event.get("reward_type", "recompensa")))
		"battle_result":
			return "Vencedor: %s" % _humanize_id(str(event.get("winner", "?")))
	return _event_title(event_type)

func _feedback_with_suffix(title: String, suffix: String) -> String:
	if suffix == "":
		return title
	return "%s %s" % [title, suffix]

func _damage_suffix(event: Dictionary) -> String:
	var damage := float(event.get("damage", 0.0))
	var absorbed := float(event.get("absorbed", 0.0))
	if damage <= 0.0 and absorbed <= 0.0:
		return ""
	if absorbed > 0.0:
		return "-%s (%s absorvido)" % [_number_text(damage), _number_text(absorbed)]
	return "-%s" % _number_text(damage)

func _humanize_id(value: String) -> String:
	var cleaned := value.strip_edges()
	if cleaned == "":
		return ""
	if cleaned == SIDE_PLAYER:
		return _default_side_name(SIDE_PLAYER)
	if cleaned == SIDE_OPPONENT:
		return _default_side_name(SIDE_OPPONENT)
	for prefix: String in ["player_", "opponent_"]:
		if cleaned.begins_with(prefix):
			cleaned = cleaned.substr(prefix.length())
	cleaned = cleaned.replace("_", " ")
	return cleaned.capitalize()

func _event_code(event_type: String) -> String:
	match event_type:
		"weapon_attack":
			return "/"
		"spell_cast":
			return "*"
		"dot_apply", "dot_tick":
			return "~"
		"status_apply", "status_expire":
			return "~"
		"passive_apply", "barrier_gain", "barrier_absorb", "resistance_apply":
			return "+"
		"summon_spawn", "summon_attack", "summon_expire":
			return "^"
		"pet_attack":
			return "@"
		"heal":
			return "+"
		"anti_stall":
			return "!"
		"reward_preview":
			return "$"
		"battle_result":
			return "#"
		"battle_start":
			return "."
		"cooldown_start", "cooldown_ready":
			return "o"
		"mana_change":
			return "%"
	return "?"

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
		if _tooltip_source == child:
			_hide_stage_tooltip()
		node.remove_child(child)
		child.free()

func _collect_tooltips(root: Variant) -> Array[String]:
	var values: Array[String] = []
	var node := root as Node
	if node == null:
		return values
	if node is Control:
		var control := node as Control
		var tooltip := _stage_tooltip_text(control)
		if tooltip != "":
			values.append(tooltip)
	for child: Node in node.get_children():
		values.append_array(_collect_tooltips(child))
	return values

func _collect_symbol_counts(root: Variant) -> Array[String]:
	var values: Array[String] = []
	var node := root as Node
	if node == null:
		return values
	for child: Node in node.get_children():
		var icon := child as BattleSymbolIcon
		if icon != null:
			values.append(str(icon.count_text))
	return values

func _collect_tooltip_node_ids(root: Variant) -> Array[String]:
	var values: Array[String] = []
	var node := root as Node
	if node == null:
		return values
	if node is Control:
		var control := node as Control
		if _stage_tooltip_text(control) != "":
			values.append(str(control.get_instance_id()))
	for child: Node in node.get_children():
		values.append_array(_collect_tooltip_node_ids(child))
	return values

func _has_native_tooltip(node: Node) -> bool:
	if node is Control:
		var control := node as Control
		if control.tooltip_text.strip_edges() != "":
			return true
	for child: Node in node.get_children():
		if _has_native_tooltip(child):
			return true
	return false

func _collect_native_tooltip_paths(node: Node, paths: Array[String]) -> void:
	if node is Control:
		var control := node as Control
		if control.tooltip_text.strip_edges() != "":
			paths.append("%s=%s" % [str(control.get_path()), control.tooltip_text.strip_edges()])
	for child: Node in node.get_children():
		_collect_native_tooltip_paths(child, paths)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
