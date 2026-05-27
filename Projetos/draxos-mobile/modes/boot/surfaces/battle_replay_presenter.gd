extends RefCounted

const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")

const EMPTY_BATTLE_TEXT := "Nenhuma batalha carregada. Solicite uma batalha, carregue o historico ou busque o ultimo resultado."
const EMPTY_HISTORY_TEXT := "Historico recente vazio para este save."
const MAX_RENDERED_HISTORY_ENTRIES := 5

var _host: Node
var _visual: Control
var _timeline_label: Label
var _timeline_lines: PackedStringArray = PackedStringArray()

func clear() -> void:
	_host = null
	_visual = null
	_timeline_label = null
	_timeline_lines = PackedStringArray()

func render(
	host: Node,
	compact_layout: bool,
	battle_log: Dictionary,
	rewards: Dictionary,
	has_battle_log: bool,
	history_entries: Array[Dictionary] = []
) -> void:
	clear()
	_host = host
	_call_host("_add_body_text", ["Batalha server-authoritative: o cliente solicita a luta, recebe o log e apenas apresenta o replay."])
	_call_host("_add_action_button", ["Solicitar batalha", "request_battle"])
	_call_host("_add_action_button", ["Historico", "show_battle_history"])
	_call_host("_add_action_button", ["Ver resultado", "show_latest_battle"])
	_render_history_entries(history_entries)

	_visual = BattleVisualMockupScript.new()
	_visual.custom_minimum_size = Vector2(0, 560 if compact_layout else 720)
	_call_host("_add_content_control", [_visual])
	_timeline_label = _call_host("_add_output_label", [""]) as Label

	if has_battle_log:
		show_battle_log(battle_log, rewards)
	else:
		show_empty_state(EMPTY_BATTLE_TEXT)

func get_timeline_label() -> Label:
	return _timeline_label

func get_visual() -> Control:
	return _visual

func show_battle_log(battle_log: Dictionary, rewards: Dictionary) -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.load_battle_log(battle_log, rewards)
		_visual.reveal_all()
	_set_timeline_text(_visual.get_timeline_text() if _visual != null and is_instance_valid(_visual) else BattleLogPresenterScript.format_summary(battle_log, rewards))

func show_empty_state(message: String = EMPTY_BATTLE_TEXT) -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.show_empty_state(message)
	_set_timeline_text(message)

func begin_replay(battle_log: Dictionary, rewards: Dictionary) -> void:
	_timeline_lines = _initial_replay_lines(battle_log, rewards)
	if _visual != null and is_instance_valid(_visual):
		_visual.load_battle_log(battle_log, rewards)
		set_replay_time(0.0)
	_refresh_timeline()

func append_event(event: Dictionary) -> void:
	_timeline_lines.append(BattleLogPresenterScript.format_event(event))
	if _visual != null and is_instance_valid(_visual):
		_visual.step_next_event()
	_refresh_timeline()

func reveal_all_events(events: Array[Dictionary]) -> void:
	for event: Dictionary in events:
		var formatted := BattleLogPresenterScript.format_event(event)
		if not _timeline_lines.has(formatted):
			_timeline_lines.append(formatted)
	if _visual != null and is_instance_valid(_visual):
		_visual.reveal_all()
	_refresh_timeline()

func reveal_all() -> void:
	if _visual != null and is_instance_valid(_visual):
		_visual.reveal_all()

func set_replay_time(replay_time: float) -> void:
	if _visual != null and is_instance_valid(_visual) and _visual.has_method("set_replay_time"):
		_visual.set_replay_time(replay_time)

func sorted_events(battle_log: Dictionary) -> Array[Dictionary]:
	return BattleLogPresenterScript.sorted_events(battle_log)

func build_warning_text(battle_log: Dictionary, expected_mode: String) -> String:
	var battle_mode := str(battle_log.get("mode", ""))
	var spell_count := BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast")
	if BattleLogPresenterScript.has_unknown_events(battle_log):
		return "Aviso: replay contem evento desconhecido; exibindo fallback."
	if battle_mode != expected_mode:
		return "Aviso: replay em modo %s. O rework atual usa %s; gere uma nova batalha com as Edge Functions atualizadas." % [
			battle_mode,
			expected_mode,
		]
	if spell_count <= 0:
		return "Aviso: replay FIRST_SLICE_SIM sem spell_cast. Verifique build, bot e Supabase local atualizados."
	return ""

static func history_entry_title(entry: Dictionary, index: int = 0) -> String:
	var battle_id := str(entry.get("battle_id", ""))
	var label_id := battle_id.substr(0, 8) if battle_id.length() >= 8 else battle_id
	var result := _winner_text(_as_dictionary(entry.get("result", {})))
	var mode := str(entry.get("mode", "MVP_ONLY"))
	return "#%d %s | %s | %s" % [index + 1, label_id, mode, result]

static func history_entry_detail(entry: Dictionary) -> String:
	var opponent := _as_dictionary(entry.get("opponent", {}))
	var rewards := _as_dictionary(entry.get("rewards", {}))
	var created_at := str(entry.get("created_at", ""))
	var opponent_name := str(opponent.get("display_name", opponent.get("id", "oponente")))
	var event_count := int(entry.get("event_count", 0))
	return "%s | %s eventos | %.1fs | recompensa %s | vs %s" % [
		created_at if created_at != "" else "sem data",
		str(event_count),
		float(entry.get("duration", 0.0)),
		_reward_text(rewards),
		opponent_name,
	]

func _initial_replay_lines(battle_log: Dictionary, rewards: Dictionary) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append(BattleLogPresenterScript.format_summary(battle_log, rewards))
	var spell_count := BattleLogPresenterScript.count_events_of_type(battle_log, "spell_cast")
	var weapon_count := BattleLogPresenterScript.count_events_of_type(battle_log, "weapon_attack")
	var pet_count := BattleLogPresenterScript.count_events_of_type(battle_log, "pet_attack")
	var summon_count := BattleLogPresenterScript.count_events_of_type(battle_log, "summon_attack")
	lines.append("Eventos: %d spells | %d ataques | %d familiares | %d summons" % [
		spell_count,
		weapon_count,
		pet_count,
		summon_count,
	])
	return lines

func _render_history_entries(history_entries: Array[Dictionary]) -> void:
	_call_host("_add_section_label", ["Historico recente"])
	if history_entries.is_empty():
		_call_host("_add_body_text", [EMPTY_HISTORY_TEXT])
		return

	var count := mini(history_entries.size(), MAX_RENDERED_HISTORY_ENTRIES)
	for index in range(count):
		var entry := history_entries[index]
		var battle_id := str(entry.get("battle_id", "")).strip_edges()
		if battle_id == "":
			continue
		_call_host("_add_body_text", [
			"%s\n%s" % [history_entry_title(entry, index), history_entry_detail(entry)],
		])
		_call_host("_add_action_button", [
			"Replay %d" % (index + 1),
			"battle_replay:%s" % battle_id,
		])

static func _winner_text(result: Dictionary) -> String:
	match str(result.get("winner", "")):
		"player":
			return "vitoria"
		"opponent":
			return "derrota"
		"draw":
			return "empate"
		_:
			return "resultado"

static func _reward_text(rewards: Dictionary) -> String:
	var reward_type := str(rewards.get("type", "MVP_ONLY"))
	var resources := _as_dictionary(rewards.get("resources", {}))
	if resources.is_empty():
		return reward_type
	var parts: PackedStringArray = PackedStringArray()
	for key in ["xp", "almas", "energia", "sangue", "ossos"]:
		if not resources.has(key):
			continue
		parts.append("%s=%s" % [key, str(resources.get(key, 0))])
	return "%s %s" % [reward_type, ", ".join(parts)]

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

func _refresh_timeline() -> void:
	_set_timeline_text("\n".join(_timeline_lines))

func _set_timeline_text(text: String) -> void:
	if _timeline_label != null and is_instance_valid(_timeline_label):
		_timeline_label.text = text

func _call_host(method_name: StringName, args: Array = []) -> Variant:
	if _host == null or not is_instance_valid(_host) or not _host.has_method(method_name):
		push_error("BattleReplayPresenter host missing method: %s" % str(method_name))
		return null
	return _host.callv(method_name, args)
