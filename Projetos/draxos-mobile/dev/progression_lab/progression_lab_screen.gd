extends Control

signal close_requested

const PROFILE_IDS := [
	"free_50_rewards",
	"free_100_rewards",
	"freemium_basic",
	"spender_light",
	"max_spender",
]
const MILESTONE_IDS := ["2h", "5h", "10h", "15h", "20h"]
const HEALTHY_SAVES_PATH := "res://docs/progression-lab/generated/healthy_saves.json"
const SESSION_PATH_TEMPLATE := "res://.progression_lab_scratch/session_%s_%s.json"

var _profile_option: OptionButton
var _milestone_option: OptionButton
var _status_label: Label
var _summary_label: Label
var _checklist_label: Label

static func is_available() -> bool:
	return bool(ProjectSettings.get_setting("draxos_mobile/progression_lab/enabled", false)) and OS.has_feature("editor")

func _ready() -> void:
	_build_ui()
	_set_status("Progression Lab Dev pronto. Selecione um perfil e milestone.")
	_refresh_checklist()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Color(0.035, 0.04, 0.055, 1.0)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 14
	root.offset_top = 12
	root.offset_right = -14
	root.offset_bottom = -12
	root.add_theme_constant_override("separation", 10)
	add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	root.add_child(header)

	var title := Label.new()
	title.text = "Progression Lab Dev"
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var close_button := Button.new()
	close_button.text = "Fechar"
	close_button.custom_minimum_size = Vector2(120, 40)
	close_button.pressed.connect(func() -> void:
		close_requested.emit()
	)
	header.add_child(close_button)

	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(_status_label)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	root.add_child(controls)

	_profile_option = OptionButton.new()
	for profile_id: String in PROFILE_IDS:
		_profile_option.add_item(profile_id)
		_profile_option.set_item_metadata(_profile_option.item_count - 1, profile_id)
	_profile_option.item_selected.connect(func(_index: int) -> void:
		_refresh_checklist()
	)
	controls.add_child(_labeled_control("Perfil", _profile_option))

	_milestone_option = OptionButton.new()
	for milestone_id: String in MILESTONE_IDS:
		_milestone_option.add_item(milestone_id)
		_milestone_option.set_item_metadata(_milestone_option.item_count - 1, milestone_id)
	_milestone_option.select(2)
	_milestone_option.item_selected.connect(func(_index: int) -> void:
		_refresh_checklist()
	)
	controls.add_child(_labeled_control("Milestone", _milestone_option))

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 8)
	root.add_child(buttons)
	buttons.add_child(_button("Gerar Relatorio", func() -> void:
		await _generate_report()
	))
	buttons.add_child(_button("Preparar Save Local", func() -> void:
		await _prepare_local_save()
	))
	buttons.add_child(_button("Carregar Save", _load_selected_save))
	buttons.add_child(_button("Abrir Checklist", _refresh_checklist))

	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(split)

	_summary_label = _output_label("Nenhum save carregado nesta sessao.")
	split.add_child(_summary_label.get_parent())

	var checklist_scroll := ScrollContainer.new()
	checklist_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	checklist_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_checklist_label = Label.new()
	_checklist_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	checklist_scroll.add_child(_checklist_label)
	split.add_child(checklist_scroll)

func _generate_report() -> void:
	_set_status("Gerando outputs do Progression Lab...")
	var script_path := ProjectSettings.globalize_path("res://tools/progression_lab/generate.ts")
	var command := str(ProjectSettings.get_setting("draxos_mobile/progression_lab/deno_command", "npx"))
	var args := _deno_prefix_args()
	args.append(script_path)
	var output: Array = []
	var exit_code := OS.execute(command, args, output, true, false)
	if exit_code != 0:
		_set_status("Progression Lab falhou: %s" % "\n".join(output))
		return
	_set_status("Relatorio gerado em docs/progression-lab/generated/progression_report.html")
	_refresh_checklist()

func _prepare_local_save() -> void:
	_set_status("Preparando save local no Supabase...")
	var script_path := ProjectSettings.globalize_path("res://tools/progression_lab/seed_supabase.ts")
	var command := str(ProjectSettings.get_setting("draxos_mobile/progression_lab/deno_command", "npx"))
	var args := _deno_prefix_args()
	args.append(script_path)
	args.append("--profile")
	args.append(_selected_profile())
	args.append("--milestone")
	args.append(_selected_milestone())
	var output: Array = []
	var exit_code := OS.execute(command, args, output, true, false)
	if exit_code != 0:
		_set_status("Seeder falhou: %s" % "\n".join(output))
		return
	_set_status("Save local preparado. Use Carregar Save para aplicar o cache.")
	_summary_label.text = "\n".join(output)

func _load_selected_save() -> void:
	var path := SESSION_PATH_TEMPLATE % [_selected_profile(), _selected_milestone()]
	var global_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(global_path):
		_set_status("Cache nao encontrado. Use Preparar Save Local primeiro: %s" % global_path)
		return
	var cache := _read_json(global_path)
	if cache.is_empty():
		_set_status("Cache invalido: %s" % global_path)
		return
	if not SessionStore.apply_snapshot_cache(cache):
		_set_status("SessionStore recusou o cache: %s" % str(SessionStore.last_error.get("message", "erro desconhecido")))
		return
	SessionStore.save_cache()
	_set_status("Save carregado no SessionStore. Feche o overlay e jogue a partir do Refugio.")
	_summary_label.text = _session_summary(cache)

func _refresh_checklist() -> void:
	var save := _selected_healthy_save()
	if save.is_empty():
		_checklist_label.text = "Gere os outputs do Progression Lab antes de abrir o checklist."
		return
	var lines := PackedStringArray()
	var player := _as_dictionary(save.get("player", {}))
	var resources := _as_dictionary(save.get("resources", {}))
	var monetization := _as_dictionary(save.get("monetization", {}))
	lines.append("%s | Level %s | Poder %s | Status %s" % [
		str(save.get("id", "")),
		str(player.get("level", "")),
		str(player.get("power", "")),
		str(save.get("status", "")),
	])
	lines.append("Recursos: %s" % _format_resources(resources))
	lines.append("Premium: %s | spend simulado %s" % [
		str(monetization.get("premium_unlocked", false)),
		str(monetization.get("simulated_store_spend", 0)),
	])
	lines.append("")
	lines.append("Checklist manual:")
	for item: Variant in _as_array(save.get("manual_checklist", [])):
		lines.append("- %s" % str(item))
	_checklist_label.text = "\n".join(lines)

func _selected_healthy_save() -> Dictionary:
	var doc := _read_json(ProjectSettings.globalize_path(HEALTHY_SAVES_PATH))
	for item: Variant in _as_array(doc.get("saves", [])):
		var save := _as_dictionary(item)
		if str(save.get("profile_id", "")) == _selected_profile() and str(save.get("milestone_id", "")) == _selected_milestone():
			return save
	return {}

func _selected_profile() -> String:
	if _profile_option.selected < 0:
		return PROFILE_IDS[0]
	return str(_profile_option.get_item_metadata(_profile_option.selected))

func _selected_milestone() -> String:
	if _milestone_option.selected < 0:
		return MILESTONE_IDS[0]
	return str(_milestone_option.get_item_metadata(_milestone_option.selected))

func _deno_prefix_args() -> PackedStringArray:
	var fallback := PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "--allow-env", "--allow-net"])
	var configured: Variant = ProjectSettings.get_setting("draxos_mobile/progression_lab/deno_prefix_args", fallback)
	if configured is PackedStringArray:
		return configured
	if configured is Array:
		return PackedStringArray(configured)
	if configured is String:
		return PackedStringArray(str(configured).split(" ", false))
	return fallback

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(180, 40)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	return button

func _labeled_control(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(80, 0)
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return row

func _output_label(text: String) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_child(label)
	return label

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return _as_dictionary(parsed)

func _session_summary(cache: Dictionary) -> String:
	var player := _as_dictionary(cache.get("player", {}))
	var resources := _as_dictionary(cache.get("resources", {}))
	var progression := _as_dictionary(cache.get("progression_lab", {}))
	return "Save %s carregado\nConta: %s | Level %s | Poder %s\nRecursos: %s" % [
		str(progression.get("save_id", "")),
		str(player.get("username", "")),
		str(player.get("level", "")),
		str(player.get("power", "")),
		_format_resources(resources),
	]

func _format_resources(resources: Dictionary) -> String:
	var parts := PackedStringArray()
	for key: String in ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]:
		parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	return " | ".join(parts)

func _set_status(message: String) -> void:
	if _status_label != null:
		_status_label.text = message

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _as_array(value: Variant) -> Array:
	return value if value is Array else []
