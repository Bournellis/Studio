extends RefCounted

const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")

const EMPTY_BATTLE_TEXT := "Nenhuma batalha carregada. Solicite uma batalha ou busque o ultimo resultado."

var _host: Node
var _visual: Control
var _timeline_label: Label
var _timeline_lines: PackedStringArray = PackedStringArray()

func clear() -> void:
	_host = null
	_visual = null
	_timeline_label = null
	_timeline_lines = PackedStringArray()

func render(host: Node, compact_layout: bool, battle_log: Dictionary, rewards: Dictionary, has_battle_log: bool) -> void:
	clear()
	_host = host
	_call_host("_add_body_text", ["Batalha server-authoritative: o cliente solicita a luta, recebe o log e apenas apresenta o replay."])
	_call_host("_add_action_button", ["Solicitar batalha", "request_battle"])
	_call_host("_add_action_button", ["Ver resultado", "show_latest_battle"])

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
