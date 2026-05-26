extends Control

signal close_requested

const SessionStoreScript := preload("res://online/session_store.gd")

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
const SESSION_LATEST_PATH := "res://.progression_lab_scratch/session_latest.json"
const BATTLE_PASS_ID := "bp_s1_01"
const SEASON_ID := "season_001"

var _profile_option: OptionButton
var _milestone_option: OptionButton
var _status_label: Label
var _summary_label: Label
var _checklist_label: Label
var _fallback_session_store = null

static func is_available() -> bool:
	return bool(ProjectSettings.get_setting("draxos_mobile/progression_lab/enabled", false)) and OS.has_feature("editor")

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
		_generate_report()
	))
	buttons.add_child(_button("Preparar Save Local", func() -> void:
		_prepare_local_save()
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
	checklist_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_checklist_label = Label.new()
	_checklist_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_checklist_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_checklist_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_checklist_label.custom_minimum_size = Vector2(520, 0)
	checklist_scroll.resized.connect(func() -> void:
		_checklist_label.custom_minimum_size.x = max(360.0, checklist_scroll.size.x - 24.0)
	)
	checklist_scroll.add_child(_checklist_label)
	split.add_child(checklist_scroll)

func _generate_report() -> void:
	_set_status("Gerando outputs do Progression Lab...")
	var script_path := ProjectSettings.globalize_path("res://tools/progression_lab/generate.ts")
	var invocation := deno_invocation(
		"draxos_mobile/progression_lab",
		PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "--allow-env", "--allow-net"])
	)
	var command := str(invocation.get("command", "npx"))
	var args := PackedStringArray(invocation.get("args", PackedStringArray()))
	args.append(script_path)
	var output: Array = []
	var exit_code := OS.execute(command, args, output, true, false)
	if exit_code != 0:
		_set_status(_process_failure_message("Progression Lab", command, args, output))
		return
	_set_status("Relatorio gerado em docs/progression-lab/generated/progression_report.html")
	_refresh_checklist()

func _prepare_local_save() -> void:
	_set_status("Preparando save local no Supabase...")
	if OS.get_environment("SUPABASE_SERVICE_ROLE_KEY").strip_edges() == "":
		var save := _selected_healthy_save()
		if save.is_empty():
			_set_status("Healthy save nao encontrado. Gere o relatorio primeiro.")
			return
		var cache := session_cache_from_save(save)
		_write_selected_cache(cache)
		_set_status("Save local offline preparado. Use Carregar Save para aplicar no SessionStore.")
		_summary_label.text = _session_summary(cache)
		return
	var script_path := ProjectSettings.globalize_path("res://tools/progression_lab/seed_supabase.ts")
	var invocation := deno_invocation(
		"draxos_mobile/progression_lab",
		PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "--allow-env", "--allow-net"])
	)
	var command := str(invocation.get("command", "npx"))
	var args := PackedStringArray(invocation.get("args", PackedStringArray()))
	args.append(script_path)
	args.append("--profile")
	args.append(_selected_profile())
	args.append("--milestone")
	args.append(_selected_milestone())
	var output: Array = []
	var exit_code := OS.execute(command, args, output, true, false)
	if exit_code != 0:
		_set_status(_process_failure_message("Seeder", command, args, output))
		return
	_set_status("Save local preparado. Use Carregar Save para aplicar o cache.")
	_summary_label.text = "\n".join(output)

func _load_selected_save() -> void:
	var path := SESSION_PATH_TEMPLATE % [_selected_profile(), _selected_milestone()]
	var global_path := ProjectSettings.globalize_path(path)
	if not FileAccess.file_exists(global_path):
		var save := _selected_healthy_save()
		if save.is_empty():
			_set_status("Cache nao encontrado e healthy save indisponivel: %s" % global_path)
			return
		_write_selected_cache(session_cache_from_save(save))
	var cache := _read_json(global_path)
	if cache.is_empty():
		_set_status("Cache invalido: %s" % global_path)
		return
	var session_store = _session_store()
	if not session_store.apply_snapshot_cache(cache):
		_set_status("SessionStore recusou o cache: %s" % str(session_store.last_error.get("message", "erro desconhecido")))
		return
	session_store.save_cache()
	_set_status("Save carregado no SessionStore. Feche o overlay e jogue a partir do Refugio.")
	_summary_label.text = _session_summary(cache)

func _session_store():
	var session_store = get_node_or_null("/root/SessionStore")
	if session_store != null:
		return session_store
	if _fallback_session_store == null:
		_fallback_session_store = SessionStoreScript.new()
	return _fallback_session_store

static func session_cache_from_save(save: Dictionary) -> Dictionary:
	var now_unix := int(Time.get_unix_time_from_system())
	var now_text := Time.get_datetime_string_from_system(true)
	var save_id := str(save.get("id", "progression_lab_save"))
	var player_id := "local_%s" % save_id
	var player := _as_dictionary_static(save.get("player", {}))
	var resources := _as_dictionary_static(save.get("resources", {}))
	var build := _as_dictionary_static(save.get("build", {}))
	var base := _as_dictionary_static(save.get("base", {}))
	var monetization := _as_dictionary_static(save.get("monetization", {}))
	var resource_cache := resources.duplicate(true)
	resource_cache["player_id"] = player_id
	resource_cache["diamante"] = int(round(float(resources.get("diamante", 0))))
	resource_cache["updated_at"] = now_text

	return {
		"cache_version": 1,
		"auth": {
			"access_token": "progression_lab_local_only",
			"refresh_token": "progression_lab_local_only",
			"expires_at": now_unix + 86400,
			"user_id": "auth_%s" % save_id,
		},
		"session_id": SessionStoreScript.create_request_id(),
		"guest_request_id": SessionStoreScript.create_request_id(),
		"player": {
			"id": player_id,
			"username": str(player.get("username", "plab_local_%s" % save_id)),
			"account_type": "progression_lab_local",
			"level": int(player.get("level", 1)),
			"xp": int(round(float(player.get("xp", 0)))),
			"power": int(player.get("power", 0)),
			"created_at": now_text,
			"updated_at": now_text,
		},
		"resources": resource_cache,
		"build": {
			"player_id": player_id,
			"weapon_type": str(build.get("weapon_type", "")),
			"weapon_quality": str(build.get("weapon_quality", "starter")),
			"weapon_level": int(build.get("weapon_level", 1)),
			"spell_slots": _as_array_static(build.get("spell_slots", [])).duplicate(true),
			"spells_unlocked": _as_array_static(build.get("spells_unlocked", [])).duplicate(true),
			"pet_id": _nullable_text(str(build.get("pet_id", ""))),
			"pet_level": int(build.get("pet_level", 0)),
			"passive_id": _nullable_text(str(build.get("passive_id", ""))),
			"passive_level": int(build.get("passive_level", 0)),
			"updated_at": now_text,
		},
		"base_state": {
			"construction_slots": int(base.get("construction_slots", 1)),
			"structures": _base_structures_from_save(base, now_text),
			"jobs": _base_jobs_from_save(base, now_text),
		},
		"social_state": {},
		"competition_state": {
			"ranking": {
				"season": {
					"id": SEASON_ID,
					"display_name": "Season 1 Alpha",
				},
				"self": {
					"arena_points": max(0, int(round(float(player.get("power", 0)) / 20.0))),
					"wins": 0,
					"losses": 0,
				},
				"bots_included": false,
			},
		},
		"monetization_state": {
			"battle_pass": {
				"pass": {
					"id": BATTLE_PASS_ID,
					"display_name": "Battle Pass Alpha 01",
				},
				"progress": {
					"player_id": player_id,
					"pass_id": BATTLE_PASS_ID,
					"pass_xp": int(monetization.get("battle_pass_xp", 0)),
					"premium_unlocked": bool(monetization.get("premium_unlocked", false)),
				},
			},
			"daily_rewards": [],
			"alpha_products": [],
		},
		"last_battle_id": null,
		"last_battle_log": {},
		"last_battle_rewards": {},
		"offline": false,
		"last_error": {},
		"progression_lab": {
			"save_id": save_id,
			"profile_id": str(save.get("profile_id", "")),
			"milestone_id": str(save.get("milestone_id", "")),
			"local_only": true,
			"manual_checklist": _as_array_static(save.get("manual_checklist", [])).duplicate(true),
		},
	}

static func _base_structures_from_save(base: Dictionary, now_text: String) -> Array:
	var structures: Array = []
	for item: Variant in _as_array_static(base.get("structures", [])):
		var structure := _as_dictionary_static(item)
		var level := int(structure.get("level", 1))
		structures.append({
			"structure_id": str(structure.get("structure_id", "")),
			"display_name": str(structure.get("structure_id", "")).capitalize(),
			"level": level,
			"pending_collectable": 0,
			"storage_cap": max(100, level * 100),
			"last_collected_at": now_text,
		})
	return structures

static func _base_jobs_from_save(base: Dictionary, now_text: String) -> Array:
	var active_job := _as_dictionary_static(base.get("active_job", {}))
	if active_job.is_empty():
		return []
	return [{
		"structure_id": str(active_job.get("structure_id", "")),
		"target_level": int(active_job.get("target_level", 1)),
		"status": "active",
		"completes_at": now_text,
	}]

static func _nullable_text(value: String) -> Variant:
	var normalized := value.strip_edges()
	return null if normalized == "" else normalized

func _write_selected_cache(cache: Dictionary) -> void:
	_write_json(ProjectSettings.globalize_path(SESSION_PATH_TEMPLATE % [_selected_profile(), _selected_milestone()]), cache)
	_write_json(ProjectSettings.globalize_path(SESSION_LATEST_PATH), cache)

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
	label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	panel.add_child(label)
	return label

func _write_json(path: String, payload: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(payload, "\t"))

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

static func _as_dictionary_static(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func _as_array_static(value: Variant) -> Array:
	return value if value is Array else []
