extends SceneTree

const BattleLabScreenScript = preload("res://dev/battle_lab/battle_lab_screen.gd")
const ProgressionLabScreenScript = preload("res://dev/progression_lab/progression_lab_screen.gd")

const BATTLE_REQUEST_PATH := "user://battle_lab_smoke_request.json"
const BATTLE_RESPONSE_PATH := "user://battle_lab_smoke_response.json"
const PROGRESSION_SUMMARY_PATH := "res://docs/progression-lab/generated/progression_summary.json"

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	_run_battle_lab_bridge()
	_run_progression_lab_generate()

	if _failures.is_empty():
		print("[smoke-dev-labs] OK Battle Lab bridge + Progression Lab generate")
		return 0

	for failure: String in _failures:
		printerr("[smoke-dev-labs] %s" % failure)
	return 1

func _run_battle_lab_bridge() -> void:
	var request_path := ProjectSettings.globalize_path(BATTLE_REQUEST_PATH)
	var response_path := ProjectSettings.globalize_path(BATTLE_RESPONSE_PATH)
	_write_json(request_path, _battle_lab_request())
	_clear_file(response_path)

	var script_path := ProjectSettings.globalize_path("res://tools/battle_lab/generate.ts")
	var invocation: Dictionary = BattleLabScreenScript.deno_invocation(
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
	if not _run_process("Battle Lab bridge", command, args):
		return

	var response := _read_json(response_path)
	if not bool(response.get("ok", false)):
		_failures.append("Battle Lab bridge returned not ok: %s" % str(response.get("error", response)))
		return
	var replay := _as_dictionary(response.get("replay", {}))
	var battle_log := _as_dictionary(replay.get("battle_log", {}))
	var events := _as_array(battle_log.get("events", []))
	if events.is_empty():
		_failures.append("Battle Lab bridge response has no battle log events.")
		return
	if not _has_event_type(events, "spell_cast"):
		_failures.append("Battle Lab bridge replay did not cast spells.")
	if not _has_any_event_type(events, PackedStringArray(["dot_apply", "status_apply", "barrier_gain", "pet_attack"])):
		_failures.append("Battle Lab bridge replay did not exercise spell/pet effects.")

func _run_progression_lab_generate() -> void:
	var script_path := ProjectSettings.globalize_path("res://tools/progression_lab/generate.ts")
	var invocation: Dictionary = ProgressionLabScreenScript.deno_invocation(
		"draxos_mobile/progression_lab",
		PackedStringArray(["-y", "deno", "run", "--allow-read", "--allow-write", "--allow-env", "--allow-net"])
	)
	var command := str(invocation.get("command", "npx"))
	var args := PackedStringArray(invocation.get("args", PackedStringArray()))
	args.append(script_path)
	if not _run_process("Progression Lab generate", command, args):
		return

	var summary := _read_json(ProjectSettings.globalize_path(PROGRESSION_SUMMARY_PATH))
	var saves := _as_array(summary.get("saves", []))
	var bots := _as_array(summary.get("bot_pool", []))
	if not bool(summary.get("ok", true)):
		_failures.append("Progression Lab summary returned not ok.")
	if saves.size() != 25:
		_failures.append("Progression Lab expected 25 healthy saves, got %d." % saves.size())
	if bots.size() != 75:
		_failures.append("Progression Lab expected 75 bots, got %d." % bots.size())

func _run_process(label: String, command: String, args: PackedStringArray) -> bool:
	var output: Array = []
	var exit_code := OS.execute(command, args, output, true, false)
	if exit_code != 0:
		_failures.append("%s failed (%d): %s %s\n%s" % [
			label,
			exit_code,
			command,
			" ".join(args),
			_output_text(output),
		])
		return false
	return true

func _battle_lab_request() -> Dictionary:
	return {
		"schema_version": "battle_lab_request_v1",
		"mode": "replay",
		"battle_id": "godot_dev_labs_smoke",
		"seed": "godot_dev_labs_smoke:blood_vs_ice",
		"player_build": {
			"id": "smoke_blood_body",
			"displayName": "Smoke Blood Body",
			"level": 25,
			"weaponId": "athame_hematico",
			"weaponLevel": 20,
			"weaponQualityTier": 1,
			"spellIds": ["hemorragia_induzida", "incisao_ritual", "coagulo_negro"],
			"spellLevels": {
				"hemorragia_induzida": 20,
				"incisao_ritual": 18,
				"coagulo_negro": 16,
			},
			"passiveId": "anatomista_profano",
			"passiveLevel": 15,
			"petId": "sanguessuga_sacramental",
			"petLevel": 15,
		},
		"opponent_build": {
			"id": "smoke_ice_control",
			"displayName": "Smoke Ice Control",
			"level": 25,
			"weaponId": "selo_mare_fria",
			"weaponLevel": 20,
			"weaponQualityTier": 1,
			"spellIds": ["geada_ossos", "prisao_gelo", "mare_escura"],
			"spellLevels": {
				"geada_ossos": 20,
				"prisao_gelo": 18,
				"mare_escura": 16,
			},
			"passiveId": "mente_fria",
			"passiveLevel": 15,
			"petId": "medusa_mare_fria",
			"petLevel": 15,
		},
	}

func _write_json(path: String, payload: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_failures.append("Could not write JSON: %s" % path)
		return
	file.store_string(JSON.stringify(payload, "\t"))

func _clear_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string("")

func _read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		_failures.append("Missing JSON output: %s" % path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_failures.append("Could not read JSON: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return Dictionary(parsed)
	_failures.append("Invalid JSON output: %s" % path)
	return {}

func _has_event_type(events: Array, event_type: String) -> bool:
	for item: Variant in events:
		var event := _as_dictionary(item)
		if str(event.get("type", "")) == event_type:
			return true
	return false

func _has_any_event_type(events: Array, event_types: PackedStringArray) -> bool:
	for event_type: String in event_types:
		if _has_event_type(events, event_type):
			return true
	return false

func _output_text(output: Array) -> String:
	var lines := PackedStringArray()
	for item: Variant in output:
		lines.append(str(item))
	return "\n".join(lines)

func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
