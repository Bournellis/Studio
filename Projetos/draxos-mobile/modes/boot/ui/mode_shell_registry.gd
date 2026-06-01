class_name DraxosMinigameShellRegistry
extends RefCounted

const MODE_RPGSUAVE := "rpgsuave"
const SLICE_RPGSUAVE_FOREST := "forest"
const RPGSUAVE_SCREEN_PATH := "res://dev/minigames/rpgsuave/rpgsuave_forest_screen.gd"
const RPGSUAVE_ENABLED_SETTING := "draxos_mobile/minigames/rpgsuave/enabled"

const _ENTRIES := {
	MODE_RPGSUAVE: {
		"mode_id": MODE_RPGSUAVE,
		"slice_id": SLICE_RPGSUAVE_FOREST,
		"display_name": "Rpgsuave Bosque",
		"status": "dev_only",
		"release_channel": "dev_only",
		"screen_path": RPGSUAVE_SCREEN_PATH,
		"enabled_setting": RPGSUAVE_ENABLED_SETTING,
	},
}

static func entry(mode_id: String) -> Dictionary:
	var normalized := normalize_mode_id(mode_id)
	return _as_dictionary(_ENTRIES.get(normalized, {})).duplicate(true)

static func display_name(mode_id: String) -> String:
	return str(entry(mode_id).get("display_name", "Minigame"))

static func screen_path(mode_id: String) -> String:
	return str(entry(mode_id).get("screen_path", ""))

static func is_registered(mode_id: String) -> bool:
	return not entry(mode_id).is_empty()

static func is_available(mode_id: String) -> bool:
	var data := entry(mode_id)
	if data.is_empty():
		return false
	var setting := str(data.get("enabled_setting", "")).strip_edges()
	if setting != "" and not bool(ProjectSettings.get_setting(setting, false)):
		return false
	var path := str(data.get("screen_path", "")).strip_edges()
	return path != "" and ResourceLoader.exists(path)

static func normalize_mode_id(mode_id: String) -> String:
	var normalized := mode_id.strip_edges().to_lower()
	if normalized == "rpgsuave_bosque":
		return MODE_RPGSUAVE
	return normalized

static func registered_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for key: String in _ENTRIES.keys():
		ids.append(key)
	return ids

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
