extends Control

signal close_requested

const BattleLogPresenterScript := preload("res://ui/battle_log_presenter.gd")
const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")

const REQUEST_SCHEMA := "battle_lab_request_v1"
const RESPONSE_SCHEMA := "battle_lab_response_v1"
const REQUEST_PATH := "user://battle_lab_request.json"
const RESPONSE_PATH := "user://battle_lab_response.json"

const WEAPONS := [
	{"id": "varinha_cinzas", "label": "Varinha de Cinzas"},
	{"id": "grimorio_veu", "label": "Grimorio do Veu"},
	{"id": "athame_hematico", "label": "Athame Hematico"},
	{"id": "cajado_ossario", "label": "Cajado Ossario"},
	{"id": "orbe_tempestade", "label": "Orbe da Tempestade"},
	{"id": "selo_mare_fria", "label": "Selo da Mare Fria"},
	{"id": "idolo_pedra_viva", "label": "Idolo de Pedra Viva"},
	{"id": "cetro_braseiro_negro", "label": "Cetro do Braseiro Negro"},
]

const SPELLS := [
	{"id": "sussurro_medo", "label": "Sussurro do Medo", "unlock": 3},
	{"id": "terror_primordial", "label": "Terror Primordial", "unlock": 7},
	{"id": "labirinto_razao", "label": "Labirinto da Razao", "unlock": 7},
	{"id": "incisao_ritual", "label": "Incisao Ritual", "unlock": 7},
	{"id": "toxina_palida", "label": "Toxina Palida", "unlock": 7},
	{"id": "marca_brasa", "label": "Marca de Brasa", "unlock": 7},
	{"id": "mare_escura", "label": "Mare Escura", "unlock": 7},
	{"id": "geada_ossos", "label": "Geada nos Ossos", "unlock": 7},
	{"id": "lamina_vento", "label": "Lamina de Vento", "unlock": 7},
	{"id": "descarga_nervosa", "label": "Descarga Nervosa", "unlock": 7},
	{"id": "mandato_oculto", "label": "Mandato Oculto", "unlock": 15},
	{"id": "hemorragia_induzida", "label": "Hemorragia Induzida", "unlock": 15},
	{"id": "coagulo_negro", "label": "Coagulo Negro", "unlock": 15},
	{"id": "raizes_pedra", "label": "Raizes de Pedra", "unlock": 15},
	{"id": "coroa_cinzas", "label": "Coroa de Cinzas", "unlock": 25},
	{"id": "prisao_gelo", "label": "Prisao de Gelo", "unlock": 25},
	{"id": "putrefacao", "label": "Putrefacao", "unlock": 25},
	{"id": "marca_sepulcral", "label": "Marca Sepulcral", "unlock": 25},
	{"id": "erguer_ossos", "label": "Erguer Ossos", "unlock": 25},
	{"id": "invocar_brasa_faminta", "label": "Invocar Brasa Faminta", "unlock": 25},
]

const PASSIVES := [
	{"id": "doutrina_pavor", "label": "Doutrina do Pavor"},
	{"id": "mente_fria", "label": "Mente Fria"},
	{"id": "anatomista_profano", "label": "Anatomista Profano"},
	{"id": "sangue_obediente", "label": "Sangue Obediente"},
	{"id": "alquimia_toxica", "label": "Alquimia Toxica"},
	{"id": "cinza_viva", "label": "Cinza Viva"},
	{"id": "mare_silenciosa", "label": "Mare Silenciosa"},
	{"id": "pedra_interna", "label": "Pedra Interna"},
	{"id": "pulso_tempestade", "label": "Pulso de Tempestade"},
	{"id": "ossuario_interior", "label": "Ossuario Interior"},
	{"id": "pacto_familiar", "label": "Pacto Familiar"},
]

const PETS := [
	{"id": "corvo_pressagio", "label": "Corvo do Pressagio"},
	{"id": "sanguessuga_sacramental", "label": "Sanguessuga Sacramental"},
	{"id": "serpente_toxina", "label": "Serpente de Toxina"},
	{"id": "cao_cinzas", "label": "Cao de Cinzas"},
	{"id": "medusa_mare_fria", "label": "Medusa de Mare Fria"},
	{"id": "escaravelho_pedra", "label": "Escaravelho de Pedra"},
	{"id": "serpe_tempestade", "label": "Serpe de Tempestade"},
	{"id": "cranio_errante", "label": "Cranio Errante"},
	{"id": "olho_veu", "label": "Olho do Veu"},
]

var _status_label: Label
var _summary_label: Label
var _checks_label: Label
var _outliers_label: Label
var _history_label: Label
var _replay_title_label: Label
var _battle_visual: Control
var _tabs: TabContainer
var _run_id_edit: LineEdit
var _compare_edit: LineEdit
var _player_editor: Dictionary = {}
var _opponent_editor: Dictionary = {}
var _last_response: Dictionary = {}
var _last_replays: Array = []
var _custom_replays: Array = []
var _last_run_history_text := ""
var _active_replay: Dictionary = {}
var _replay_events: Array = []
var _replay_index := 0
var _replay_playing := false
var _replay_speed := 1.0
var _replay_accumulator := 0.0

static func is_available() -> bool:
	return bool(ProjectSettings.get_setting("draxos_mobile/battle_lab/enabled", false)) and OS.has_feature("editor")

static func deno_invocation(settings_prefix: String, fallback_prefix: PackedStringArray) -> Dictionary:
	var command_text := str(ProjectSettings.get_setting("%s/deno_command" % settings_prefix, "npx")).strip_edges()
	if command_text == "":
		command_text = "npx"
	var command_tokens := _split_command_line(command_text)
	if command_tokens.is_empty():
		command_tokens.append("npx")

	var command := str(command_tokens[0])
	var args := PackedStringArray()
	if command_tokens.size() > 1:
		var inline_args := PackedStringArray()
		for index: int in range(1, command_tokens.size()):
			inline_args.append(command_tokens[index])
		args = clean_deno_prefix_args(inline_args, fallback_prefix)
	else:
		args = clean_deno_prefix_args(
			ProjectSettings.get_setting("%s/deno_prefix_args" % settings_prefix, fallback_prefix),
			fallback_prefix
		)
	return windows_safe_invocation(command, args)

static func windows_safe_invocation(command: String, args: PackedStringArray) -> Dictionary:
	var normalized_args := _normalize_runner_args_for_command(command, args)
	if OS.get_name() != "Windows" or not _should_wrap_windows_command(command):
		return {"command": command, "args": normalized_args}

	var shell_args := PackedStringArray(["/C", _resolve_windows_command_path(command)])
	for arg: String in normalized_args:
		shell_args.append(arg)
	return {"command": _windows_shell_command(), "args": shell_args}

static func clean_deno_prefix_args(configured: Variant, fallback: PackedStringArray) -> PackedStringArray:
	var raw := _variant_to_packed_string_array(configured, fallback)
	var cleaned := PackedStringArray()
	for token: String in raw:
		var value := token.strip_edges()
		if value == "":
			continue
		if _is_dynamic_runner_arg(value):
			break
		if cleaned.is_empty() and _is_npx_token(value):
			continue
		cleaned.append(value)
	if cleaned.is_empty():
		return PackedStringArray(fallback)
	return cleaned

static func max_spell_slots(level: int) -> int:
	if level >= 25:
		return 3
	if level >= 7:
		return 2
	if level >= 3:
		return 1
	return 0

static func allowed_spell_ids(level: int) -> Array[String]:
	var ids: Array[String] = []
	for spell: Dictionary in SPELLS:
		if int(spell.get("unlock", 999)) <= level:
			ids.append(str(spell.get("id", "")))
	return ids

static func calculate_power(build: Dictionary) -> int:
	var spell_total := 0
	var spell_levels := _as_dictionary_static(build.get("spellLevels", {}))
	for value: Variant in spell_levels.values():
		spell_total += int(value)
	return int(build.get("level", 1)) * 50 + int(build.get("weaponLevel", 1)) * 30 + spell_total * 20 + int(build.get("petLevel", 0)) * 15 + int(build.get("passiveLevel", 0)) * 10 + int(build.get("weaponQualityTier", 0)) * 25

static func validate_build(build: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var level := int(build.get("level", 0))
	var weapon_level := int(build.get("weaponLevel", 0))
	if level < 1 or level > 40:
		errors.append("level deve estar entre 1 e 40")
	if not _id_exists(WEAPONS, str(build.get("weaponId", "varinha_cinzas"))):
		errors.append("instrumento desconhecido: %s" % str(build.get("weaponId", "")))
	if weapon_level < 1 or weapon_level > level:
		errors.append("weaponLevel deve estar entre 1 e level")
	if int(build.get("weaponQualityTier", -1)) < 0 or int(build.get("weaponQualityTier", -1)) > 4:
		errors.append("weaponQualityTier deve estar entre 0 e 4")

	var spell_ids := _as_array_static(build.get("spellIds", []))
	if spell_ids.size() > max_spell_slots(level):
		errors.append("spells excedem slots liberados")
	var allowed := allowed_spell_ids(level)
	var seen := {}
	var spell_levels := _as_dictionary_static(build.get("spellLevels", {}))
	for spell_id_value: Variant in spell_ids:
		var spell_id := str(spell_id_value)
		if seen.has(spell_id):
			errors.append("spell duplicada: %s" % spell_id)
		seen[spell_id] = true
		if not allowed.has(spell_id):
			errors.append("spell travada neste level: %s" % spell_id)
		var spell_level := int(spell_levels.get(spell_id, 0))
		if spell_level < 1 or spell_level > level:
			errors.append("level invalido para spell: %s" % spell_id)

	var passive_id := str(build.get("passiveId", ""))
	if passive_id != "":
		if level < 10:
			errors.append("passiva libera no level 10")
		if not _id_exists(PASSIVES, passive_id):
			errors.append("passiva desconhecida: %s" % passive_id)
		var passive_level := int(build.get("passiveLevel", 0))
		if passive_level < 1 or passive_level > level:
			errors.append("passiveLevel deve estar entre 1 e level")

	var pet_id := str(build.get("petId", ""))
	if pet_id != "":
		if level < 15:
			errors.append("pet libera no level 15")
		if not _id_exists(PETS, pet_id):
			errors.append("pet desconhecido: %s" % pet_id)
		var pet_level := int(build.get("petLevel", 0))
		if pet_level < 1 or pet_level > level:
			errors.append("petLevel deve estar entre 1 e level")
	return errors

static func default_build(id_prefix: String, level: int = 25) -> Dictionary:
	var spell_ids := ["sussurro_medo", "marca_brasa", "geada_ossos"]
	var spell_levels := {}
	for spell_id: String in spell_ids:
		spell_levels[spell_id] = level
	return {
		"id": "%s_custom" % id_prefix,
		"displayName": "%s Custom" % id_prefix.capitalize(),
		"level": level,
		"weaponId": "varinha_cinzas",
		"weaponLevel": level,
		"weaponQualityTier": 2,
		"spellIds": spell_ids,
		"spellLevels": spell_levels,
		"passiveId": "doutrina_pavor",
		"passiveLevel": level,
		"petId": "corvo_pressagio",
		"petLevel": level,
	}

func _ready() -> void:
	set_process(true)
	_build_ui()
	_set_status("Battle Lab dev pronto. Use scratch para ensaios locais ou replay custom para ver uma build especifica.")

func _process(delta: float) -> void:
	if not _replay_playing:
		return
	_replay_accumulator += delta * _replay_speed
	if _replay_accumulator < 0.25:
		return
	_replay_accumulator = 0.0
	_step_replay()

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
	title.text = "Battle Lab Dev"
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

	_tabs = TabContainer.new()
	_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(_tabs)
	_tabs.add_child(_build_run_tab())
	_tabs.set_tab_title(0, "Run")
	_tabs.add_child(_build_builds_tab())
	_tabs.set_tab_title(1, "Builds")
	_tabs.add_child(_build_analytics_tab())
	_tabs.set_tab_title(2, "Analytics")
	_tabs.add_child(_build_replay_tab())
	_tabs.set_tab_title(3, "Replay")
	_tabs.add_child(_build_history_tab())
	_tabs.set_tab_title(4, "History")

func _build_run_tab() -> Control:
	var box := _scroll_vbox()
	box.add_child(_body_label("Scratch fica fora do Git. Run oficial grava em docs/battle-lab/runs somente quando marcada explicitamente."))
	_run_id_edit = LineEdit.new()
	_run_id_edit.placeholder_text = "run_id oficial ou scratch"
	_run_id_edit.text = "scratch_%s" % Time.get_datetime_string_from_system().replace(":", "-")
	box.add_child(_labeled_control("Run ID", _run_id_edit))
	_compare_edit = LineEdit.new()
	_compare_edit.placeholder_text = "run anterior para comparar, opcional"
	_compare_edit.text = "2026-05-21_archetype_source_tuning_v02"
	box.add_child(_labeled_control("Compare With", _compare_edit))

	var scratch_button := Button.new()
	scratch_button.text = "Gerar Scratch Run"
	scratch_button.pressed.connect(func() -> void:
		_generate_run(false)
	)
	box.add_child(scratch_button)

	var generated_button := Button.new()
	generated_button.text = "Atualizar Generated"
	generated_button.pressed.connect(func() -> void:
		_generate_generated()
	)
	box.add_child(generated_button)

	var official_button := Button.new()
	official_button.text = "Arquivar Run Oficial"
	official_button.pressed.connect(func() -> void:
		_generate_run(true)
	)
	box.add_child(official_button)

	_summary_label = _output_label("Nenhuma run carregada nesta sessao.")
	box.add_child(_summary_label.get_parent())
	return box.get_parent()

func _build_builds_tab() -> Control:
	var box := _scroll_vbox()
	box.add_child(_body_label("Monte builds livremente. O Lab valida unlocks antes de enviar para o simulador TypeScript."))
	var editors := HBoxContainer.new()
	editors.add_theme_constant_override("separation", 12)
	editors.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_child(editors)
	_player_editor = _create_build_editor("player", default_build("player", 25))
	_opponent_editor = _create_build_editor("opponent", default_build("opponent", 25))
	editors.add_child(_player_editor["root"])
	editors.add_child(_opponent_editor["root"])

	var replay_button := Button.new()
	replay_button.text = "Gerar Replay Custom"
	replay_button.pressed.connect(func() -> void:
		_generate_custom_replay()
	)
	box.add_child(replay_button)
	return box.get_parent()

func _build_analytics_tab() -> Control:
	var box := _scroll_vbox()
	_checks_label = _output_label("Checks aparecerao depois de uma run.")
	box.add_child(_checks_label.get_parent())
	_outliers_label = _output_label("Outliers aparecerao depois de uma run.")
	box.add_child(_outliers_label.get_parent())
	return box.get_parent()

func _build_replay_tab() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.add_child(_body_label("Replay debug 2D compartilhado: aplica somente os campos do battle_log_v1. Nao recalcula resultado."))

	_replay_title_label = Label.new()
	_replay_title_label.text = "Nenhum replay carregado."
	box.add_child(_replay_title_label)

	_battle_visual = BattleVisualMockupScript.new()
	_battle_visual.custom_minimum_size = Vector2(0, 380)
	_battle_visual.show_empty_state("Nenhuma amostra carregada. Gere uma run ou replay custom.")
	box.add_child(_battle_visual)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 8)
	box.add_child(controls)
	var load_sample := Button.new()
	load_sample.text = "Carregar Amostra"
	load_sample.pressed.connect(_load_first_sample_replay)
	controls.add_child(load_sample)
	var play_button := Button.new()
	play_button.text = "Play/Pause"
	play_button.pressed.connect(func() -> void:
		_replay_playing = not _replay_playing
	)
	controls.add_child(play_button)
	var step_button := Button.new()
	step_button.text = "Step"
	step_button.pressed.connect(_step_replay)
	controls.add_child(step_button)
	var reset_button := Button.new()
	reset_button.text = "Reset"
	reset_button.pressed.connect(_reset_replay)
	controls.add_child(reset_button)
	var speed := HSlider.new()
	speed.min_value = 0.5
	speed.max_value = 4.0
	speed.step = 0.5
	speed.value = 1.0
	speed.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	speed.value_changed.connect(func(value: float) -> void:
		_replay_speed = value
	)
	controls.add_child(speed)
	return box

func _build_history_tab() -> Control:
	var box := _scroll_vbox()
	_history_label = _output_label("Historico aparecera depois de uma run.")
	box.add_child(_history_label.get_parent())
	return box.get_parent()

func _create_build_editor(side: String, initial_build: Dictionary) -> Dictionary:
	var root := PanelContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	root.add_child(box)

	var title := Label.new()
	title.text = side.capitalize()
	title.add_theme_font_size_override("font_size", 18)
	box.add_child(title)

	var id_edit := LineEdit.new()
	id_edit.text = str(initial_build.get("id", "%s_custom" % side))
	box.add_child(_labeled_control("ID", id_edit))

	var name_edit := LineEdit.new()
	name_edit.text = str(initial_build.get("displayName", "%s Custom" % side.capitalize()))
	box.add_child(_labeled_control("Nome", name_edit))

	var level := _spin(1, 40, int(initial_build.get("level", 25)))
	box.add_child(_labeled_control("Level", level))
	var weapon_option := _option_from_items(WEAPONS)
	_select_option_metadata(weapon_option, str(initial_build.get("weaponId", "varinha_cinzas")))
	box.add_child(_labeled_control("Instrumento", weapon_option))
	var weapon_level := _spin(1, 40, int(initial_build.get("weaponLevel", 25)))
	box.add_child(_labeled_control("Arma Level", weapon_level))
	var quality := _spin(0, 4, int(initial_build.get("weaponQualityTier", 2)))
	box.add_child(_labeled_control("Qualidade", quality))

	var spell_options: Array[OptionButton] = []
	var spell_levels: Array[SpinBox] = []
	var initial_spells := _as_array(initial_build.get("spellIds", []))
	var initial_spell_levels := _as_dictionary(initial_build.get("spellLevels", {}))
	for slot in range(3):
		var option := _option_with_none(SPELLS)
		if slot < initial_spells.size():
			_select_option_metadata(option, str(initial_spells[slot]))
		var spell_level := _spin(1, 40, int(initial_spell_levels.get(str(initial_spells[slot]) if slot < initial_spells.size() else "", int(level.value))))
		spell_options.append(option)
		spell_levels.append(spell_level)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.add_child(option)
		row.add_child(spell_level)
		box.add_child(_labeled_control("Spell %d" % (slot + 1), row))

	var passive_option := _option_with_none(PASSIVES)
	_select_option_metadata(passive_option, str(initial_build.get("passiveId", "")))
	box.add_child(_labeled_control("Passiva", passive_option))
	var passive_level := _spin(1, 40, int(initial_build.get("passiveLevel", int(level.value))))
	box.add_child(_labeled_control("Passiva Level", passive_level))

	var pet_option := _option_with_none(PETS)
	_select_option_metadata(pet_option, str(initial_build.get("petId", "")))
	box.add_child(_labeled_control("Pet", pet_option))
	var pet_level := _spin(1, 40, int(initial_build.get("petLevel", int(level.value))))
	box.add_child(_labeled_control("Pet Level", pet_level))

	var power_label := Label.new()
	box.add_child(power_label)
	var editor := {
		"root": root,
		"id": id_edit,
		"name": name_edit,
		"level": level,
		"weapon_option": weapon_option,
		"weapon_level": weapon_level,
		"quality": quality,
		"spell_options": spell_options,
		"spell_levels": spell_levels,
		"passive_option": passive_option,
		"passive_level": passive_level,
		"pet_option": pet_option,
		"pet_level": pet_level,
		"power_label": power_label,
	}
	level.value_changed.connect(func(_value: float) -> void:
		_refresh_editor(editor)
	)
	for option: OptionButton in spell_options:
		option.item_selected.connect(func(_index: int) -> void:
			_refresh_editor(editor)
	)
	weapon_option.item_selected.connect(func(_index: int) -> void:
		_refresh_editor(editor)
	)
	for spin_box: SpinBox in [weapon_level, quality, passive_level, pet_level]:
		spin_box.value_changed.connect(func(_value: float) -> void:
			_refresh_editor(editor)
		)
	_refresh_editor(editor)
	return editor

func _build_from_editor(editor: Dictionary) -> Dictionary:
	var level_spin: SpinBox = editor["level"]
	var weapon_option: OptionButton = editor["weapon_option"]
	var weapon_spin: SpinBox = editor["weapon_level"]
	var quality_spin: SpinBox = editor["quality"]
	var id_edit: LineEdit = editor["id"]
	var name_edit: LineEdit = editor["name"]
	var passive_level_spin: SpinBox = editor["passive_level"]
	var pet_level_spin: SpinBox = editor["pet_level"]
	var level := int(level_spin.value)
	var spell_ids: Array[String] = []
	var spell_levels := {}
	var options: Array = editor["spell_options"]
	var levels: Array = editor["spell_levels"]
	for index in range(options.size()):
		var spell_id := _selected_metadata(options[index])
		if spell_id == "":
			continue
		var spell_level_spin: SpinBox = levels[index]
		spell_ids.append(spell_id)
		spell_levels[spell_id] = clampi(int(spell_level_spin.value), 1, level)
	var build := {
		"id": id_edit.text.strip_edges(),
		"displayName": name_edit.text.strip_edges(),
		"level": level,
		"weaponId": _selected_metadata(weapon_option),
		"weaponLevel": clampi(int(weapon_spin.value), 1, level),
		"weaponQualityTier": clampi(int(quality_spin.value), 0, 4),
		"spellIds": spell_ids,
		"spellLevels": spell_levels,
	}
	var passive_id := _selected_metadata(editor["passive_option"])
	if passive_id != "":
		build["passiveId"] = passive_id
		build["passiveLevel"] = clampi(int(passive_level_spin.value), 1, level)
	var pet_id := _selected_metadata(editor["pet_option"])
	if pet_id != "":
		build["petId"] = pet_id
		build["petLevel"] = clampi(int(pet_level_spin.value), 1, level)
	return build

func _refresh_editor(editor: Dictionary) -> void:
	var build := _build_from_editor(editor)
	var errors := validate_build(build)
	var suffix := "OK" if errors.is_empty() else "REVIEW: %s" % "; ".join(errors)
	var power_label: Label = editor["power_label"]
	power_label.text = "Poder %d | %s" % [calculate_power(build), suffix]

func _generate_generated() -> void:
	var request := {
		"schema_version": REQUEST_SCHEMA,
		"mode": "run",
		"compare_with_run_id": _compare_edit.text.strip_edges(),
	}
	_send_bridge_request(request)

func _generate_run(official: bool) -> void:
	var run_id := _run_id_edit.text.strip_edges()
	if run_id == "":
		_set_status("Informe um run_id.")
		return
	var request := {
		"schema_version": REQUEST_SCHEMA,
		"mode": "run",
		"compare_with_run_id": _compare_edit.text.strip_edges(),
	}
	if official:
		request["archive_run_id"] = run_id
	else:
		request["scratch_run_id"] = run_id
	_send_bridge_request(request)

func _generate_custom_replay() -> void:
	var player := _build_from_editor(_player_editor)
	var opponent := _build_from_editor(_opponent_editor)
	var errors := validate_build(player)
	errors.append_array(validate_build(opponent))
	if not errors.is_empty():
		_set_status("Build invalida: %s" % "; ".join(errors))
		return
	var request := {
		"schema_version": REQUEST_SCHEMA,
		"mode": "replay",
		"battle_id": "godot_custom_replay",
		"seed": "godot_custom_replay:%s:%s" % [player.get("id", "player"), opponent.get("id", "opponent")],
		"player_build": player,
		"opponent_build": opponent,
	}
	_send_bridge_request(request)

func _send_bridge_request(request: Dictionary) -> Dictionary:
	_set_status("Chamando Battle Lab Deno...")
	var request_path := ProjectSettings.globalize_path(REQUEST_PATH)
	var response_path := ProjectSettings.globalize_path(RESPONSE_PATH)
	_write_json(request_path, request)
	_clear_file(response_path)

	var script_path := ProjectSettings.globalize_path("res://tools/battle_lab/generate.ts")
	var invocation := deno_invocation(
		"draxos_mobile/battle_lab",
		PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write"])
	)
	var command := str(invocation.get("command", "npx"))
	var args := PackedStringArray(invocation.get("args", PackedStringArray()))
	args.append(script_path)
	args.append("--request")
	args.append(request_path)
	args.append("--response")
	args.append(response_path)
	var output: Array = []
	var exit_code := OS.execute(command, args, output, true, false)
	if exit_code != 0:
		_set_status(_process_failure_message("Battle Lab", command, args, output))
		return {"ok": false}
	var response := _read_json(response_path)
	_last_response = response
	if not bool(response.get("ok", false)):
		var error := _as_dictionary(response.get("error", {}))
		_set_status("Battle Lab erro: %s" % str(error.get("message", "erro desconhecido")))
		return response
	_set_status("Battle Lab OK: %s" % str(response.get("status", "PASS")))
	_refresh_from_response(response)
	return response

func _refresh_from_response(response: Dictionary) -> void:
	if response.get("mode", "") == "run":
		_render_run_response(response)
		var output_dir := str(response.get("output_dir", ""))
		_load_replays_from_output(output_dir)
	elif response.get("mode", "") == "replay":
		_render_replay_response(response)

func _render_run_response(response: Dictionary) -> void:
	var summary := _as_dictionary(response.get("summary", {}))
	_summary_label.text = "Status %s | batalhas %s | media %ss | curtas %s%% | longas %s%% | anti-stall %s%%\nReport: %s" % [
		str(response.get("status", "")),
		str(summary.get("total_battles", "?")),
		str(summary.get("avg_duration", "?")),
		str(summary.get("short_rate_percent", "?")),
		str(summary.get("long_rate_percent", "?")),
		str(summary.get("anti_stall_rate_percent", "?")),
		str(response.get("report_path", "")),
	]

	var check_lines: PackedStringArray = PackedStringArray()
	for item: Variant in _as_array(response.get("checks", [])):
		var check := _as_dictionary(item)
		check_lines.append("%s | %s | %s / %s" % [
			str(check.get("status", "")),
			str(check.get("id", "")),
			str(check.get("observed", "")),
			str(check.get("target", "")),
		])
	_checks_label.text = "\n".join(check_lines) if not check_lines.is_empty() else "Sem checks."

	var outlier_lines: PackedStringArray = PackedStringArray()
	for item: Variant in _as_array(response.get("outliers", [])):
		var outlier := _as_dictionary(item)
		outlier_lines.append("%s | %s | %ss | %s vs %s" % [
			str(outlier.get("severity", "")),
			str(outlier.get("matchup_id", "")),
			str(outlier.get("duration", "")),
			str(outlier.get("player_build_id", "")),
			str(outlier.get("opponent_build_id", "")),
		])
	_outliers_label.text = "\n".join(outlier_lines) if not outlier_lines.is_empty() else "Sem outliers."

	var history_lines := PackedStringArray()
	history_lines.append("Ultima run: %s" % str(response.get("status", "")))
	history_lines.append("Output: %s" % str(response.get("output_dir", "")))
	if response.get("compare", null) is Array:
		history_lines.append("Compare rows: %d" % _as_array(response.get("compare", [])).size())
	_last_run_history_text = "\n".join(history_lines)
	_render_history()

func _render_replay_response(response: Dictionary) -> void:
	var replay := _as_dictionary(response.get("replay", {}))
	if replay.is_empty():
		_set_status("Battle Lab custom replay nao retornou replay.")
		return
	_register_custom_replay(replay)
	_load_replay(replay)
	_select_tab(3)
	_set_status("Battle Lab custom replay OK: aberto na aba Replay e registrado no History.")

func _register_custom_replay(replay: Dictionary) -> void:
	_last_replays.push_front(replay)
	_custom_replays.push_front(replay)
	while _custom_replays.size() > 8:
		_custom_replays.pop_back()
	while _last_replays.size() > 24:
		_last_replays.pop_back()
	_render_history()

func _render_history() -> void:
	if _history_label == null:
		return
	var lines := PackedStringArray()
	if _last_run_history_text != "":
		lines.append(_last_run_history_text)
	if not _custom_replays.is_empty():
		if not lines.is_empty():
			lines.append("")
		lines.append("Custom replays desta sessao:")
		for item: Variant in _custom_replays:
			var replay := _as_dictionary(item)
			lines.append("- %s | %s vs %s | %ss | winner %s" % [
				str(replay.get("matchup_id", "")),
				str(replay.get("player_build_id", "")),
				str(replay.get("opponent_build_id", "")),
				str(replay.get("duration", "")),
				str(replay.get("winner", "")),
			])
	if lines.is_empty():
		_history_label.text = "Historico aparecera depois de uma run ou replay custom."
	else:
		_history_label.text = "\n".join(lines)

func _select_tab(index: int) -> void:
	if _tabs == null:
		return
	if index >= 0 and index < _tabs.get_tab_count():
		_tabs.current_tab = index

func _load_replays_from_output(output_dir: String) -> void:
	if output_dir == "":
		return
	var path := output_dir.path_join("battle_lab_replays.json")
	var replays_doc := _read_json(path)
	_last_replays = _as_array(replays_doc.get("replays", []))
	if not _last_replays.is_empty():
		_load_replay(_preferred_replay(_last_replays))

func _load_first_sample_replay() -> void:
	if _last_replays.is_empty():
		_set_status("Nenhuma amostra carregada. Gere uma run primeiro.")
		return
	_load_replay(_preferred_replay(_last_replays))

func _preferred_replay(replays: Array) -> Dictionary:
	for item: Variant in replays:
		var replay := _as_dictionary(item)
		var tag := str(replay.get("tag", ""))
		var player_archetype := str(replay.get("player_archetype_id", ""))
		var opponent_archetype := str(replay.get("opponent_archetype_id", ""))
		if tag.contains("representative") and player_archetype != "starter_instrument" and opponent_archetype != "starter_instrument":
			return replay
	for fallback_item: Variant in replays:
		var fallback_replay := _as_dictionary(fallback_item)
		var fallback_player_archetype := str(fallback_replay.get("player_archetype_id", ""))
		var fallback_opponent_archetype := str(fallback_replay.get("opponent_archetype_id", ""))
		if fallback_player_archetype != "starter_instrument" and fallback_opponent_archetype != "starter_instrument":
			return fallback_replay
	return _as_dictionary(replays[0])

func _load_replay(replay: Dictionary) -> void:
	_active_replay = replay
	var battle_log := _as_dictionary(replay.get("battle_log", {}))
	_replay_events = BattleLogPresenterScript.sorted_events(battle_log)
	_replay_index = 0
	_replay_playing = false
	_replay_accumulator = 0.0
	_reset_replay()
	_replay_title_label.text = "%s | %s vs %s | %ss | winner %s" % [
		str(replay.get("matchup_id", "")),
		str(replay.get("player_build_id", "")),
		str(replay.get("opponent_build_id", "")),
		str(replay.get("duration", "")),
		str(replay.get("winner", "")),
	]

func _reset_replay() -> void:
	_replay_index = 0
	_replay_playing = false
	if _battle_visual == null or not is_instance_valid(_battle_visual):
		return
	if _active_replay.is_empty():
		_battle_visual.show_empty_state("Nenhum replay carregado.")
		return
	_battle_visual.load_battle_log(
		_as_dictionary(_active_replay.get("battle_log", {})),
		_as_dictionary(_active_replay.get("rewards", {}))
	)

func _step_replay() -> void:
	if _replay_index >= _replay_events.size():
		_replay_playing = false
		return
	var event := _as_dictionary(_replay_events[_replay_index])
	_replay_index += 1
	_apply_replay_event(event)

func _apply_replay_event(event: Dictionary) -> void:
	if _battle_visual != null and is_instance_valid(_battle_visual):
		_battle_visual.apply_event(event)

static func _variant_to_packed_string_array(configured: Variant, fallback: PackedStringArray) -> PackedStringArray:
	if configured is PackedStringArray:
		return PackedStringArray(configured)
	if configured is Array:
		return PackedStringArray(configured)
	if configured is String:
		return _split_command_line(str(configured))
	return PackedStringArray(fallback)

static func _split_command_line(command_line: String) -> PackedStringArray:
	var tokens := PackedStringArray()
	var current := ""
	var in_quotes := false
	for index: int in range(command_line.length()):
		var character := command_line.substr(index, 1)
		if character == "\"":
			in_quotes = not in_quotes
			continue
		if character == " " and not in_quotes:
			if current != "":
				tokens.append(current)
				current = ""
			continue
		current += character
	if current != "":
		tokens.append(current)
	return tokens

static func _is_dynamic_runner_arg(token: String) -> bool:
	if token.ends_with(".ts"):
		return true
	return token in ["--request", "--response", "--profile", "--milestone"]

static func _is_npx_token(token: String) -> bool:
	var normalized := token.get_file().to_lower()
	return normalized in ["npx", "npx.cmd", "npx.exe"]

static func _is_deno_token(token: String) -> bool:
	var normalized := token.get_file().to_lower()
	return normalized in ["deno", "deno.exe"]

static func _normalize_runner_args_for_command(command: String, args: PackedStringArray) -> PackedStringArray:
	var normalized := PackedStringArray(args)
	if not _is_deno_token(command):
		return normalized
	if normalized.size() >= 2 and normalized[0] == "-y" and normalized[1] == "deno":
		var direct_deno_args := PackedStringArray()
		for index: int in range(2, normalized.size()):
			direct_deno_args.append(normalized[index])
		return direct_deno_args
	if normalized.size() >= 1 and normalized[0] == "deno":
		var args_without_deno := PackedStringArray()
		for index: int in range(1, normalized.size()):
			args_without_deno.append(normalized[index])
		return args_without_deno
	return normalized

static func _should_wrap_windows_command(command: String) -> bool:
	var executable := command.get_file().to_lower()
	if executable in ["cmd.exe", "powershell.exe", "pwsh.exe"]:
		return false
	return executable.get_extension().to_lower() != "exe"

static func _windows_shell_command() -> String:
	var comspec := OS.get_environment("COMSPEC").strip_edges()
	return comspec if comspec != "" else "cmd.exe"

static func _resolve_windows_command_path(command: String) -> String:
	if command.is_absolute_path() and FileAccess.file_exists(command):
		return command
	var extensions := PackedStringArray([".cmd", ".exe", ".bat", ""])
	var search_dirs := _windows_path_dirs()
	for directory: String in search_dirs:
		for extension: String in extensions:
			var candidate := directory.path_join(command)
			if candidate.get_extension() == "" and extension != "":
				candidate += extension
			if FileAccess.file_exists(candidate):
				return candidate
	return command

static func _windows_path_dirs() -> PackedStringArray:
	var dirs := PackedStringArray()
	for item: String in OS.get_environment("PATH").split(";", false):
		var directory := item.strip_edges()
		if directory != "":
			dirs.append(directory)
	for common: String in PackedStringArray(["C:/Program Files/nodejs", "C:/Program Files (x86)/nodejs"]):
		if not dirs.has(common):
			dirs.append(common)
	return dirs

func _process_failure_message(tool_name: String, command: String, args: PackedStringArray, output: Array) -> String:
	var output_text := _output_text(output)
	if output_text != "":
		return "%s falhou: %s" % [tool_name, output_text]
	return "%s falhou ao iniciar processo.\nExecutavel: %s\nArgs: %s" % [
		tool_name,
		command,
		" ".join(args),
	]

func _output_text(output: Array) -> String:
	var lines := PackedStringArray()
	for item: Variant in output:
		lines.append(str(item))
	return "\n".join(lines)

func _scroll_vbox() -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 8)
	scroll.add_child(box)
	return box

func _body_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	return label

func _output_label(text: String) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var label := _body_label(text)
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	panel.add_child(label)
	return label

func _labeled_control(label_text: String, control: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(120, 0)
	row.add_child(label)
	control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(control)
	return row

func _spin(minimum: int, maximum: int, value: int) -> SpinBox:
	var spin := SpinBox.new()
	spin.min_value = minimum
	spin.max_value = maximum
	spin.step = 1
	spin.value = value
	spin.custom_minimum_size = Vector2(84, 0)
	return spin

func _option_with_none(items: Array) -> OptionButton:
	var option := OptionButton.new()
	option.add_item("Nenhum")
	option.set_item_metadata(0, "")
	for item: Dictionary in items:
		option.add_item(str(item.get("label", item.get("id", ""))))
		option.set_item_metadata(option.item_count - 1, str(item.get("id", "")))
	return option

func _option_from_items(items: Array) -> OptionButton:
	var option := OptionButton.new()
	for item: Dictionary in items:
		option.add_item(str(item.get("label", item.get("id", ""))))
		option.set_item_metadata(option.item_count - 1, str(item.get("id", "")))
	return option

func _select_option_metadata(option: OptionButton, value: String) -> void:
	for index in range(option.item_count):
		if str(option.get_item_metadata(index)) == value:
			option.select(index)
			return
	option.select(0)

func _selected_metadata(option: OptionButton) -> String:
	if option.selected < 0:
		return ""
	return str(option.get_item_metadata(option.selected))

func _write_json(path: String, payload: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload, "\t"))

func _clear_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string("")

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return _as_dictionary(parsed)

func _set_status(message: String) -> void:
	if _status_label != null:
		_status_label.text = message

func _as_dictionary(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

func _as_array(value: Variant) -> Array:
	return value if value is Array else []

static func _as_dictionary_static(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func _as_array_static(value: Variant) -> Array:
	return value if value is Array else []

static func _id_exists(items: Array, id: String) -> bool:
	for item: Dictionary in items:
		if str(item.get("id", "")) == id:
			return true
	return false
