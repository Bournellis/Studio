class_name BattleVisualMockup
extends VBoxContainer

const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleStage2DScript := preload("res://ui/battle_stage_2d.gd")

const SIDE_PLAYER := "player"
const SIDE_OPPONENT := "opponent"
const SIDES := [SIDE_PLAYER, SIDE_OPPONENT]

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
var _battle_log: Dictionary = {}
var _rewards: Dictionary = {}
var _events: Array[Dictionary] = []
var _event_index := 0
var _side_state: Dictionary = {}
var _timeline_lines: PackedStringArray = PackedStringArray()
var _latest_event: Dictionary = {}

var _summary_label: Label
var _counts_label: Label
var _result_label: Label
var _event_icon_label: Label
var _event_title_label: Label
var _event_detail_label: Label
var _timeline_label: Label
var _stage_2d: Control
var _name_labels: Dictionary = {}
var _portrait_labels: Dictionary = {}
var _hp_bars: Dictionary = {}
var _meter_labels: Dictionary = {}
var _status_rows: Dictionary = {}
var _cooldown_rows: Dictionary = {}
var _summon_rows: Dictionary = {}

func _ready() -> void:
	_ensure_ui()

func load_battle_log(battle_log: Dictionary, rewards: Dictionary = {}) -> void:
	_ensure_ui()
	_battle_log = battle_log.duplicate(true)
	_rewards = rewards.duplicate(true)
	_events = BattleLogPresenterScript.sorted_events(_battle_log)
	_event_index = 0
	_latest_event = {}
	_side_state = _build_initial_side_state()
	_timeline_lines = PackedStringArray()
	_timeline_lines.append(BattleLogPresenterScript.format_summary(_battle_log, _rewards))
	_timeline_lines.append(_event_count_text())
	_render_all()

func show_empty_state(message: String) -> void:
	_ensure_ui()
	_battle_log = {}
	_rewards = {}
	_events = []
	_event_index = 0
	_latest_event = {}
	_side_state = _build_empty_side_state()
	_timeline_lines = PackedStringArray([message])
	_summary_label.text = message
	_counts_label.text = "0 eventos"
	_result_label.text = "Aguardando battle_log_v1"
	_render_dynamic_state()
	if _stage_2d != null and is_instance_valid(_stage_2d) and _stage_2d.has_method("show_empty_state"):
		_stage_2d.show_empty_state(message)
	_render_timeline()

func step_next_event() -> bool:
	_ensure_ui()
	if _event_index >= _events.size():
		return false
	_apply_event(_events[_event_index])
	_event_index += 1
	_render_dynamic_state(true)
	_render_timeline()
	return true

func apply_event(event: Dictionary) -> void:
	_ensure_ui()
	_apply_event(event)
	_event_index = mini(_event_index + 1, _events.size())
	_render_dynamic_state(true)
	_render_timeline()

func reveal_all() -> void:
	_ensure_ui()
	_event_index = 0
	_latest_event = {}
	_side_state = _build_initial_side_state()
	_timeline_lines = PackedStringArray()
	if _battle_log.is_empty():
		_timeline_lines.append("Nenhuma batalha carregada.")
	else:
		_timeline_lines.append(BattleLogPresenterScript.format_summary(_battle_log, _rewards))
		_timeline_lines.append(_event_count_text())
	for event: Dictionary in _events:
		_apply_event(event)
		_event_index += 1
	_render_dynamic_state()
	_render_timeline()

func get_timeline_text() -> String:
	return "\n".join(_timeline_lines)

func get_event_count() -> int:
	return _events.size()

func get_current_event_index() -> int:
	return _event_index

func debug_snapshot() -> Dictionary:
	return {
		"event_index": _event_index,
		"event_count": _events.size(),
		"latest_event_type": str(_latest_event.get("type", "")),
		"player": _as_dictionary(_side_state.get(SIDE_PLAYER, {})).duplicate(true),
		"opponent": _as_dictionary(_side_state.get(SIDE_OPPONENT, {})).duplicate(true),
		"stage": _stage_2d.debug_snapshot() if _stage_2d != null and _stage_2d.has_method("debug_snapshot") else {},
		"timeline": get_timeline_text(),
	}

func _ensure_ui() -> void:
	if _built:
		return
	_built = true
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 8)

	var header := PanelContainer.new()
	header.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(header)

	var header_box := VBoxContainer.new()
	header_box.add_theme_constant_override("separation", 4)
	header.add_child(header_box)

	_summary_label = _body_label("Nenhuma batalha carregada.")
	_summary_label.add_theme_color_override("font_color", _token_color("text_primary"))
	header_box.add_child(_summary_label)

	_counts_label = _body_label("0 eventos")
	header_box.add_child(_counts_label)

	_stage_2d = BattleStage2DScript.new()
	_stage_2d.custom_minimum_size = Vector2(0, 360)
	_stage_2d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_stage_2d.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_stage_2d)

	var arena := PanelContainer.new()
	arena.add_theme_stylebox_override("panel", _panel_style("bg_deep", "border_default"))
	arena.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	arena.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(arena)

	var arena_row := HBoxContainer.new()
	arena_row.add_theme_constant_override("separation", 10)
	arena.add_child(arena_row)

	arena_row.add_child(_build_side_card(SIDE_PLAYER))
	arena_row.add_child(_build_event_card())
	arena_row.add_child(_build_side_card(SIDE_OPPONENT))

	var timeline_panel := PanelContainer.new()
	timeline_panel.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_default"))
	timeline_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	timeline_panel.custom_minimum_size = Vector2(0, 140)
	add_child(timeline_panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	timeline_panel.add_child(scroll)

	_timeline_label = _body_label("")
	_timeline_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_timeline_label.custom_minimum_size = Vector2(360, 0)
	scroll.resized.connect(func() -> void:
		_timeline_label.custom_minimum_size.x = max(360.0, scroll.size.x - 24.0)
	)
	scroll.add_child(_timeline_label)

	_side_state = _build_empty_side_state()
	_render_dynamic_state()

func _build_side_card(side: String) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _panel_style("bg_panel_alt", "border_default"))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)

	var name_label := Label.new()
	name_label.text = side.capitalize()
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", _token_color("text_primary"))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(name_label)
	_name_labels[side] = name_label

	var portrait_panel := PanelContainer.new()
	portrait_panel.add_theme_stylebox_override("panel", _panel_style("placeholder", "border_active"))
	portrait_panel.custom_minimum_size = Vector2(0, 112)
	portrait_panel.tooltip_text = _actor_asset_hint(side)
	box.add_child(portrait_panel)

	var portrait := Label.new()
	portrait.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	portrait.add_theme_font_size_override("font_size", 30)
	portrait.add_theme_color_override("font_color", _token_color("text_primary"))
	portrait_panel.add_child(portrait)
	_portrait_labels[side] = portrait

	var hp := ProgressBar.new()
	hp.custom_minimum_size = Vector2(0, 28)
	hp.show_percentage = false
	hp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hp.add_theme_stylebox_override("fill", _progress_fill_style(side))
	box.add_child(hp)
	_hp_bars[side] = hp

	var meter := _body_label("HP - | Mana - | Barreira -")
	box.add_child(meter)
	_meter_labels[side] = meter

	box.add_child(_small_caption("Status/Buffs"))
	var status_row := HFlowContainer.new()
	status_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_row.add_theme_constant_override("h_separation", 4)
	status_row.add_theme_constant_override("v_separation", 4)
	box.add_child(status_row)
	_status_rows[side] = status_row

	box.add_child(_small_caption("Spells/Cooldowns"))
	var cooldown_row := HFlowContainer.new()
	cooldown_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cooldown_row.add_theme_constant_override("h_separation", 4)
	cooldown_row.add_theme_constant_override("v_separation", 4)
	box.add_child(cooldown_row)
	_cooldown_rows[side] = cooldown_row

	box.add_child(_small_caption("Familiares/Summons"))
	var summon_row := HFlowContainer.new()
	summon_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summon_row.add_theme_constant_override("h_separation", 4)
	summon_row.add_theme_constant_override("v_separation", 4)
	box.add_child(summon_row)
	_summon_rows[side] = summon_row

	return card

func _build_event_card() -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _panel_style("bg_panel", "border_active"))
	card.custom_minimum_size = Vector2(230, 0)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	card.add_child(box)

	_event_icon_label = Label.new()
	_event_icon_label.text = "..."
	_event_icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_event_icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_event_icon_label.custom_minimum_size = Vector2(86, 64)
	_event_icon_label.add_theme_font_size_override("font_size", 22)
	_event_icon_label.add_theme_color_override("font_color", _token_color("text_primary"))
	_event_icon_label.add_theme_stylebox_override("normal", _badge_style(_token_color("placeholder")))
	box.add_child(_event_icon_label)

	_event_title_label = _body_label("Aguardando replay")
	_event_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_event_title_label.add_theme_color_override("font_color", _token_color("text_primary"))
	box.add_child(_event_title_label)

	_event_detail_label = _body_label("O visual usa apenas eventos recebidos.")
	_event_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(_event_detail_label)

	_result_label = _body_label("Resultado pendente")
	_result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_label.add_theme_color_override("font_color", _token_color("accent_bone"))
	box.add_child(_result_label)

	return card

func _build_initial_side_state() -> Dictionary:
	var state := _build_empty_side_state()
	var participants := _as_dictionary(_battle_log.get("participants", {}))
	for side: String in SIDES:
		var participant := _as_dictionary(participants.get(side, {}))
		var side_data := _as_dictionary(state.get(side, {}))
		side_data["display_name"] = str(participant.get("display_name", _default_side_name(side)))
		side_data["id"] = str(participant.get("id", side))
		side_data["max_hp"] = _infer_max_hp(side, participant)
		side_data["hp"] = float(side_data.get("max_hp", 100.0))
		side_data["max_mana"] = _infer_max_mana(side)
		side_data["mana"] = float(side_data.get("max_mana", 0.0))
		state[side] = side_data
	return state

func _build_empty_side_state() -> Dictionary:
	return {
		SIDE_PLAYER: {
			"id": SIDE_PLAYER,
			"display_name": "Draxos",
			"max_hp": 100.0,
			"hp": 100.0,
			"max_mana": 20.0,
			"mana": 20.0,
			"barrier": 0.0,
			"statuses": {},
			"cooldowns": {},
			"summons": {},
			"familiar": "",
			"last_event": "",
		},
		SIDE_OPPONENT: {
			"id": SIDE_OPPONENT,
			"display_name": "Oponente",
			"max_hp": 100.0,
			"hp": 100.0,
			"max_mana": 20.0,
			"mana": 20.0,
			"barrier": 0.0,
			"statuses": {},
			"cooldowns": {},
			"summons": {},
			"familiar": "",
			"last_event": "",
		},
	}

func _infer_max_hp(side: String, participant: Dictionary) -> float:
	var maximum: float = max(1.0, float(participant.get("max_hp", participant.get("hp", 100.0))))
	for event: Dictionary in _events:
		var event_type := str(event.get("type", ""))
		if event_type == "anti_stall":
			var key := "%s_hp_after" % side
			if event.has(key):
				maximum = max(maximum, float(event.get(key, 1.0)))
			continue
		if _side_from_actor(str(event.get("target", ""))) != side:
			continue
		if not event.has("hp_after"):
			continue
		var hp_after := float(event.get("hp_after", 1.0))
		var before_hp := hp_after
		if _event_is_damage(event_type):
			before_hp += max(0.0, float(event.get("damage", 0.0)))
			before_hp += max(0.0, float(event.get("absorbed", 0.0)))
		maximum = max(maximum, max(hp_after, before_hp))
	return ceil(maximum)

func _infer_max_mana(side: String) -> float:
	var maximum := 20.0
	for event: Dictionary in _events:
		if str(event.get("type", "")) != "mana_change":
			continue
		var event_side := _side_from_actor(str(event.get("target", event.get("source", ""))))
		if event_side == side:
			maximum = max(maximum, float(event.get("mana_after", 0.0)))
	return maximum

func _render_all() -> void:
	_summary_label.text = BattleLogPresenterScript.format_summary(_battle_log, _rewards)
	_counts_label.text = _event_count_text()
	var result := _as_dictionary(_battle_log.get("result", {}))
	_result_label.text = "Resultado: %s (%s)" % [
		str(result.get("winner", "pendente")),
		str(result.get("reason", "sem_motivo")),
	]
	_render_dynamic_state()
	_render_timeline()

func _render_dynamic_state(animate_stage_event: bool = false) -> void:
	for side: String in SIDES:
		var side_data := _as_dictionary(_side_state.get(side, {}))
		var display_name := str(side_data.get("display_name", _default_side_name(side)))
		var hp: float = max(0.0, float(side_data.get("hp", 0.0)))
		var max_hp: float = max(1.0, float(side_data.get("max_hp", 1.0)))
		var mana: float = max(0.0, float(side_data.get("mana", 0.0)))
		var max_mana: float = max(0.0, float(side_data.get("max_mana", 0.0)))
		var barrier: float = max(0.0, float(side_data.get("barrier", 0.0)))

		_name_labels[side].text = display_name
		_portrait_labels[side].text = _portrait_initial(display_name, side)
		_hp_bars[side].max_value = max_hp
		_hp_bars[side].value = clampf(hp, 0.0, max_hp)
		_meter_labels[side].text = "HP %s/%s | Mana %s/%s | Barreira %s" % [
			_number_text(hp),
			_number_text(max_hp),
			_number_text(mana),
			_number_text(max_mana),
			_number_text(barrier),
		]
		_render_status_row(side, _as_dictionary(side_data.get("statuses", {})))
		_render_cooldown_row(side, _as_dictionary(side_data.get("cooldowns", {})))
		_render_summon_row(side, side_data)

	if _latest_event.is_empty():
		_event_icon_label.text = "..."
		_event_icon_label.tooltip_text = "Replay aguardando evento do battle_log_v1. Ataques, spells, buffs e resultado aparecem aqui conforme o log avanca."
		_event_icon_label.add_theme_stylebox_override("normal", _badge_style(_token_color("placeholder")))
		_event_title_label.text = "Aguardando evento"
		_event_detail_label.text = "Ataques, spells, buffs, dano, efeitos e icons entram aqui."
	else:
		var event_type := str(_latest_event.get("type", ""))
		_event_icon_label.text = _event_code(event_type)
		_event_icon_label.tooltip_text = _event_tooltip(_latest_event)
		_event_icon_label.add_theme_stylebox_override("normal", _badge_style(_event_color(_latest_event)))
		_event_title_label.text = "%ss | %s" % [
			"%.1f" % float(_latest_event.get("t", 0.0)),
			event_type,
		]
		_event_detail_label.text = BattleLogPresenterScript.format_event(_latest_event)
	if _stage_2d != null and is_instance_valid(_stage_2d) and _stage_2d.has_method("render_snapshot"):
		_stage_2d.render_snapshot(_side_state, _latest_event, _event_index, _events.size(), animate_stage_event)

func _render_status_row(side: String, statuses: Dictionary) -> void:
	var row: HFlowContainer = _status_rows[side]
	var entries: Array[Dictionary] = []
	if statuses.is_empty():
		entries.append({
			"key": "empty",
			"text": "OK",
			"color": _token_color("border_default"),
			"tooltip": "Sem status ativo neste lado. Buffs, debuffs, DoTs e resistencias aparecem aqui quando o log aplicar um efeito.",
		})
		_sync_badge_row(row, entries)
		return
	var keys := statuses.keys()
	keys.sort()
	for key: Variant in keys:
		var status := _as_dictionary(statuses[key])
		var label := str(key)
		var stacks := int(status.get("stacks", 0))
		if stacks > 1:
			label = "%s x%d" % [label, stacks]
		entries.append({
			"key": str(key),
			"text": label,
			"color": _status_color(label),
			"tooltip": _status_tooltip(str(key), status),
		})
	_sync_badge_row(row, entries)

func _render_cooldown_row(side: String, cooldowns: Dictionary) -> void:
	var row: HFlowContainer = _cooldown_rows[side]
	var entries: Array[Dictionary] = []
	if cooldowns.is_empty():
		entries.append({
			"key": "empty",
			"text": "Livre",
			"color": _token_color("border_default"),
			"tooltip": "Nenhum cooldown ativo. Quando uma spell entrar em recarga, o icone mostra o ready_at recebido do servidor.",
		})
		_sync_badge_row(row, entries)
		return
	var keys := cooldowns.keys()
	keys.sort()
	for key: Variant in keys:
		var ready_at := float(cooldowns[key])
		entries.append({
			"key": str(key),
			"text": "%s %.1fs" % [str(key), ready_at],
			"color": DAMAGE_COLORS["arcano"],
			"tooltip": _cooldown_tooltip(str(key), ready_at),
		})
	_sync_badge_row(row, entries)

func _render_summon_row(side: String, side_data: Dictionary) -> void:
	var row: HFlowContainer = _summon_rows[side]
	var entries: Array[Dictionary] = []
	var familiar := str(side_data.get("familiar", ""))
	if familiar != "":
		entries.append({
			"key": "familiar:%s" % familiar,
			"text": familiar,
			"color": DAMAGE_COLORS["morte"],
			"tooltip": _summon_tooltip("familiar", familiar, side, "tras"),
		})
	var summons := _as_dictionary(side_data.get("summons", {}))
	var keys := summons.keys()
	keys.sort()
	for key: Variant in keys:
		var summon := _as_dictionary(summons[key])
		entries.append({
			"key": "summon:%s" % str(key),
			"text": str(key),
			"color": DAMAGE_COLORS["fogo"],
			"tooltip": _summon_tooltip("summon", str(key), side, str(summon.get("slot", "frente"))),
		})
	if familiar == "" and summons.is_empty():
		entries.append({
			"key": "empty",
			"text": "Nenhum",
			"color": _token_color("border_default"),
			"tooltip": "Nenhum familiar ou summon visivel neste lado. Familiares aparecem atras; summons ocupam frente, meio ou tras.",
		})
	_sync_badge_row(row, entries)

func _render_timeline() -> void:
	_timeline_label.text = "\n".join(_timeline_lines)

func _apply_event(event: Dictionary) -> void:
	_latest_event = event.duplicate(true)
	_timeline_lines.append(BattleLogPresenterScript.format_event(event))
	var event_type := str(event.get("type", ""))
	var source_side := _side_from_actor(str(event.get("source", "")))
	var target_side := _side_from_actor(str(event.get("target", "")))

	if event_type == "anti_stall":
		_apply_anti_stall(event)
		return
	if event_type == "battle_result":
		_result_label.text = "Resultado: %s (%s)" % [
			str(event.get("winner", "desconhecido")),
			str(event.get("reason", "sem_motivo")),
		]
		return

	if event.has("hp_after") and target_side != "":
		_set_side_number(target_side, "hp", float(event.get("hp_after", 0.0)))
	if event.has("barrier_after") and target_side != "":
		_set_side_number(target_side, "barrier", float(event.get("barrier_after", 0.0)))

	match event_type:
		"mana_change":
			var mana_side := target_side if target_side != "" else source_side
			if mana_side != "":
				var mana_after := float(event.get("mana_after", 0.0))
				_set_side_number(mana_side, "mana", mana_after)
				_set_side_number(mana_side, "max_mana", max(mana_after, float(_as_dictionary(_side_state[mana_side]).get("max_mana", 0.0))))
		"cooldown_start":
			_set_cooldown(source_side, str(event.get("spell_id", "spell")), float(event.get("ready_at", 0.0)))
		"cooldown_ready":
			_clear_cooldown(source_side, str(event.get("spell_id", "spell")))
		"passive_apply":
			_set_status(source_side, str(event.get("passive_id", "doutrina")), int(event.get("passive_level", 1)))
		"dot_apply", "status_apply", "resistance_apply":
			_set_status(target_side, str(event.get("status_id", event.get("spell_id", event_type))), int(event.get("stacks", 1)))
		"status_expire":
			_clear_status(target_side, str(event.get("status_id", "status")))
		"barrier_gain":
			var barrier_side := target_side if target_side != "" else source_side
			var barrier_after := float(event.get("barrier_after", event.get("amount", 0.0)))
			_set_side_number(barrier_side, "barrier", barrier_after)
			_set_status(barrier_side, "barreira", 1)
		"barrier_absorb":
			if target_side != "":
				_set_side_number(target_side, "barrier", float(event.get("barrier_after", 0.0)))
		"summon_spawn":
			_set_summon(source_side, str(event.get("target", "summon")), event)
		"summon_expire":
			_clear_summon(source_side, str(event.get("source", event.get("target", "summon"))))
		"pet_attack":
			_set_familiar(source_side, str(event.get("pet_id", "familiar")))
		"heal":
			if target_side != "":
				_set_side_number(target_side, "hp", float(event.get("hp_after", 0.0)))
		"reward_preview":
			_result_label.text = "Recompensa: %s" % str(event.get("reward_type", "desconhecida"))

func _apply_anti_stall(event: Dictionary) -> void:
	if event.has("player_hp_after"):
		_set_side_number(SIDE_PLAYER, "hp", float(event.get("player_hp_after", 0.0)))
	if event.has("opponent_hp_after"):
		_set_side_number(SIDE_OPPONENT, "hp", float(event.get("opponent_hp_after", 0.0)))
	_set_status(SIDE_PLAYER, "anti_stall", 1)
	_set_status(SIDE_OPPONENT, "anti_stall", 1)

func _set_side_number(side: String, key: String, value: float) -> void:
	if side == "" or not _side_state.has(side):
		return
	var data := _as_dictionary(_side_state[side])
	data[key] = value
	_side_state[side] = data

func _set_status(side: String, status_id: String, stacks: int) -> void:
	if side == "" or not _side_state.has(side) or status_id == "":
		return
	var data := _as_dictionary(_side_state[side])
	var statuses := _as_dictionary(data.get("statuses", {}))
	statuses[status_id] = {"stacks": max(1, stacks)}
	data["statuses"] = statuses
	_side_state[side] = data

func _clear_status(side: String, status_id: String) -> void:
	if side == "" or not _side_state.has(side):
		return
	var data := _as_dictionary(_side_state[side])
	var statuses := _as_dictionary(data.get("statuses", {}))
	statuses.erase(status_id)
	data["statuses"] = statuses
	_side_state[side] = data

func _set_cooldown(side: String, spell_id: String, ready_at: float) -> void:
	if side == "" or not _side_state.has(side) or spell_id == "":
		return
	var data := _as_dictionary(_side_state[side])
	var cooldowns := _as_dictionary(data.get("cooldowns", {}))
	cooldowns[spell_id] = ready_at
	data["cooldowns"] = cooldowns
	_side_state[side] = data

func _clear_cooldown(side: String, spell_id: String) -> void:
	if side == "" or not _side_state.has(side):
		return
	var data := _as_dictionary(_side_state[side])
	var cooldowns := _as_dictionary(data.get("cooldowns", {}))
	cooldowns.erase(spell_id)
	data["cooldowns"] = cooldowns
	_side_state[side] = data

func _set_summon(side: String, summon_id: String, event: Dictionary) -> void:
	if side == "" or not _side_state.has(side) or summon_id == "":
		return
	var data := _as_dictionary(_side_state[side])
	var summons := _as_dictionary(data.get("summons", {}))
	summons[summon_id] = {
		"hp": event.get("hp", 0),
		"damage_type": event.get("damage_type", ""),
		"slot": str(event.get("slot", _next_summon_slot(summons.size()))),
	}
	data["summons"] = summons
	_side_state[side] = data

func _next_summon_slot(existing_count: int) -> String:
	match existing_count % 3:
		0:
			return "front"
		1:
			return "middle"
	return "back"

func _clear_summon(side: String, summon_id: String) -> void:
	for candidate_side: String in SIDES:
		if side != "" and candidate_side != side:
			continue
		var data := _as_dictionary(_side_state[candidate_side])
		var summons := _as_dictionary(data.get("summons", {}))
		summons.erase(summon_id)
		data["summons"] = summons
		_side_state[candidate_side] = data

func _set_familiar(side: String, familiar_id: String) -> void:
	if side == "" or not _side_state.has(side):
		return
	var data := _as_dictionary(_side_state[side])
	data["familiar"] = familiar_id
	_side_state[side] = data

func _event_count_text() -> String:
	if _battle_log.is_empty():
		return "0 eventos"
	var weapon_count := BattleLogPresenterScript.count_events_of_type(_battle_log, "weapon_attack")
	var spell_count := BattleLogPresenterScript.count_events_of_type(_battle_log, "spell_cast")
	var dot_count := BattleLogPresenterScript.count_events_of_type(_battle_log, "dot_tick")
	var status_count := BattleLogPresenterScript.count_events_of_type(_battle_log, "status_apply")
	var summon_count := BattleLogPresenterScript.count_events_of_type(_battle_log, "summon_attack")
	var pet_count := BattleLogPresenterScript.count_events_of_type(_battle_log, "pet_attack")
	return "Eventos: %d total | %d ATK | %d SP | %d DoT | %d status | %d summon | %d familiar" % [
		_events.size(),
		weapon_count,
		spell_count,
		dot_count,
		status_count,
		summon_count,
		pet_count,
	]

func _side_from_actor(actor: String) -> String:
	if actor == SIDE_PLAYER or actor.begins_with("player_"):
		return SIDE_PLAYER
	if actor == SIDE_OPPONENT or actor.begins_with("opponent_"):
		return SIDE_OPPONENT
	return ""

func _event_is_damage(event_type: String) -> bool:
	return event_type in ["weapon_attack", "spell_cast", "dot_tick", "summon_attack", "pet_attack"]

func _status_tooltip(status_id: String, status: Dictionary) -> String:
	var stacks: int = maxi(1, int(status.get("stacks", 1)))
	var lines := PackedStringArray()
	lines.append("Status ativo: %s." % status_id)
	lines.append("Stacks: %d." % stacks)
	lines.append("Pode representar buff, debuff, DoT ou resistencia. O efeito real e a expiracao vem do battle_log_v1.")
	lines.append("Asset futuro: battle_icon_status ou battle_icon_buff.")
	return "\n".join(lines)

func _cooldown_tooltip(spell_id: String, ready_at: float) -> String:
	return "Cooldown de spell: %s\nA spell ja foi usada e fica indisponivel ate ready_at %ss no replay.\nO cliente mostra o timer; o servidor decide quando ela pode ser usada de novo.\nAsset futuro: battle_icon_spell." % [
		spell_id,
		_number_text(ready_at),
	]

func _summon_tooltip(kind: String, entity_id: String, side: String, slot: String) -> String:
	if kind == "familiar":
		return "Familiar: %s\nCompanheiro equipado de %s. Fica atras do personagem e anima quando o log recebe pet_attack.\nAsset futuro: battle_icon_pet ou sprite de familiar." % [
			entity_id,
			_default_side_name(side),
		]
	return "Summon: %s\nCriatura invocada por spell de %s. Ocupa a posicao %s para leitura espacial e anima em summon_attack.\nAsset futuro: battle_icon_summon ou sprite proprio." % [
		entity_id,
		_default_side_name(side),
		_slot_label(slot),
	]

func _event_tooltip(event: Dictionary) -> String:
	var event_type := str(event.get("type", ""))
	var lines := PackedStringArray()
	lines.append("%s (%s)." % [_event_title(event_type), event_type])
	lines.append("Evento %d/%d em %ss do battle_log_v1." % [
		_event_index,
		_events.size(),
		_number_text(float(event.get("t", 0.0))),
	])
	if event.has("source"):
		lines.append("Fonte: %s." % str(event.get("source", "")))
	if event.has("target") and str(event.get("target", "")) != "none":
		lines.append("Alvo: %s." % str(event.get("target", "")))
	match event_type:
		"weapon_attack":
			lines.append("Ataque basico com dano e HP final recebidos do servidor.")
		"spell_cast":
			lines.append("Spell conjurada: %s." % str(event.get("spell_id", "spell")))
		"dot_apply", "status_apply", "resistance_apply":
			lines.append("Aplica efeito: %s." % str(event.get("status_id", event.get("spell_id", event_type))))
		"dot_tick":
			lines.append("Tick de dano ao longo do tempo.")
		"cooldown_start":
			lines.append("Inicia recarga de %s ate ready_at %ss." % [str(event.get("spell_id", "spell")), _number_text(float(event.get("ready_at", 0.0)))])
		"summon_spawn":
			lines.append("Summon entra no palco no lado de quem conjurou.")
		"summon_attack":
			lines.append("Summon ataca a partir de sua posicao visual.")
		"pet_attack":
			lines.append("Familiar ataca; o resultado ja veio calculado.")
		"anti_stall":
			lines.append("Regra de seguranca para encerrar lutas longas.")
		"battle_result":
			lines.append("Resultado final do confronto.")
	if event.has("damage"):
		lines.append("Dano: %s %s." % [_number_text(float(event.get("damage", 0.0))), str(event.get("damage_type", "none"))])
	if event.has("hp_after"):
		lines.append("HP apos evento: %s." % _number_text(float(event.get("hp_after", 0.0))))
	if event.has("winner"):
		lines.append("Vencedor: %s." % str(event.get("winner", "")))
	lines.append("Asset futuro: %s." % _asset_id_for_event(event_type))
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
		"anti_stall":
			return "Anti-stall"
		"reward_preview":
			return "Previa de recompensa"
		"battle_result":
			return "Resultado"
	return "Evento"

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

func _asset_id_for_event(event_type: String) -> String:
	return str(EVENT_ASSET_IDS.get(event_type, "battle_icon_event"))

func _event_color(event: Dictionary) -> Color:
	var event_type := str(event.get("type", ""))
	if event_type == "heal":
		return _token_color("status_success")
	if event_type == "anti_stall":
		return _token_color("status_error")
	if event_type in ["battle_result", "reward_preview"]:
		return _token_color("accent_bone")
	var damage_type := str(event.get("damage_type", "none")).to_lower()
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

func _portrait_initial(display_name: String, side: String) -> String:
	var fallback := "D" if side == SIDE_PLAYER else "O"
	if display_name.strip_edges() == "":
		return fallback
	return display_name.substr(0, 1).to_upper()

func _default_side_name(side: String) -> String:
	return "Draxos" if side == SIDE_PLAYER else "Oponente"

func _actor_asset_hint(side: String) -> String:
	return "Combatente principal: %s\nRepresentacao procedural do personagem parado no palco 2D. HP, mana, barreira, status e summons vem do battle_log_v1.\nAsset futuro: %s" % [
		_default_side_name(side),
		"battle_character_player" if side == SIDE_PLAYER else "battle_character_opponent",
	]

func _slot_label(slot: String) -> String:
	match slot:
		"front":
			return "frente"
		"middle":
			return "meio"
		"back":
			return "tras"
		"frente", "meio", "tras":
			return slot
	return slot

func _number_text(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	return "%.1f" % value

func _body_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", _token_color("text_secondary"))
	return label

func _small_caption(text: String) -> Label:
	var label := _body_label(text)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", _token_color("text_secondary"))
	return label

func _sync_badge_row(row: HFlowContainer, entries: Array[Dictionary]) -> void:
	var existing: Dictionary = {}
	for child: Node in row.get_children():
		var key := str(child.get_meta("render_key", ""))
		if key != "":
			existing[key] = child
	var wanted: Dictionary = {}
	for index: int in range(entries.size()):
		var entry := entries[index]
		var key := str(entry.get("key", ""))
		wanted[key] = true
		var label := existing.get(key, null) as Label
		if label == null:
			label = Label.new()
			label.set_meta("render_key", key)
			row.add_child(label)
		var color: Color = _token_color("border_default")
		if entry.get("color", null) is Color:
			color = entry.get("color")
		_configure_badge(label, str(entry.get("text", "")), color, str(entry.get("tooltip", "")))
		if label.get_index() != index:
			row.move_child(label, index)
	for child: Node in row.get_children():
		var key := str(child.get_meta("render_key", ""))
		if key == "" or wanted.has(key):
			continue
		row.remove_child(child)
		child.free()

func _badge(text: String, color: Color, tooltip: String = "") -> Label:
	var label := Label.new()
	_configure_badge(label, text, color, tooltip)
	return label

func _configure_badge(label: Label, text: String, color: Color, tooltip: String = "") -> void:
	label.text = text
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.custom_minimum_size = Vector2(66, 24)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_STOP
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", _token_color("text_primary"))
	label.add_theme_stylebox_override("normal", _badge_style(color))
	label.tooltip_text = tooltip

func _panel_style(bg_token: String, border_token: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _token_color(bg_token)
	style.border_color = _token_color(border_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _badge_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color.darkened(0.45)
	style.border_color = color.lightened(0.15)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style

func _progress_fill_style(side: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = _token_color("accent_astral") if side == SIDE_PLAYER else _token_color("accent_blood")
	style.set_corner_radius_all(3)
	return style

func _token_color(token: String, fallback: Color = Color.WHITE) -> Color:
	if is_inside_tree():
		var ui_tokens: Node = get_tree().root.get_node_or_null("UiTokens")
		if ui_tokens != null and ui_tokens.has_method("color"):
			return ui_tokens.color(token, fallback)
	return Color(TOKEN_COLOR_FALLBACKS.get(token, fallback))

func _clear_children(node: Node) -> void:
	for child: Node in node.get_children():
		node.remove_child(child)
		child.free()

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
