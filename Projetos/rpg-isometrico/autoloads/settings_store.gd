extends Node

const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

const SAVE_PATH: String = "user://saved_loadout.json"
const SAVE_VERSION: int = 2

func save_selected_loadout(loadout: LoadoutData, mode_id: StringName = &"") -> void:
	if loadout == null or not loadout.is_valid():
		return

	var payload: Dictionary = {
		"save_version": SAVE_VERSION,
		"race_id": String(loadout.race.id),
		"weapon_id": String(loadout.weapon.id),
		"skill_ids": loadout.get_skill_ids(),
		"potion_ids": loadout.get_potion_ids(),
		"saved_at_unix": int(Time.get_unix_time_from_system())
	}
	if LocalModeCatalog.is_supported_mode(mode_id):
		payload["mode_id"] = String(mode_id)

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("Could not write saved loadout to %s" % SAVE_PATH)
		return

	file.store_string(JSON.stringify(payload, "\t"))

func load_saved_selection() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	return _sanitize_saved_selection_payload(parsed)

func _sanitize_saved_selection_payload(parsed: Dictionary) -> Dictionary:
	var race_id: String = str(parsed.get("race_id", ""))
	var weapon_id: String = str(parsed.get("weapon_id", ""))
	var skill_ids: Array[String] = _extract_string_array(parsed.get("skill_ids", []))
	var potion_ids: Array[String] = _extract_string_array(parsed.get("potion_ids", []))
	if race_id == "" or weapon_id == "":
		return {}
	if skill_ids.is_empty() and potion_ids.is_empty():
		return {}

	var payload: Dictionary = {
		"save_version": int(parsed.get("save_version", 1)),
		"race_id": race_id,
		"weapon_id": weapon_id,
		"skill_ids": skill_ids,
		"potion_ids": potion_ids
	}

	var saved_at_unix: int = int(parsed.get("saved_at_unix", 0))
	if saved_at_unix > 0:
		payload["saved_at_unix"] = saved_at_unix

	var mode_id: StringName = StringName(str(parsed.get("mode_id", "")))
	if LocalModeCatalog.is_supported_mode(mode_id):
		payload["mode_id"] = String(mode_id)

	return payload

func _extract_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result
