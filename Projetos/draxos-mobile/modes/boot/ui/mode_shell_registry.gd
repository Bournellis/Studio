class_name DraxosModeShellRegistry
extends RefCounted

const MODE_BASEBUILDER := "basebuilder"
const MODE_AUTOBATTLER := "autobattler"
const MODE_TOWERDEFENSE := "towerdefense"
const MODE_CARDGAME := "cardgame"
const MODE_OPENWORLD := "openworld"

const SLICE_BASEBUILDER_REFUGIO := "refugio"
const SLICE_AUTOBATTLER_PVE_ARENA := "pve_arena"
const SLICE_OPENWORLD_FOREST := "forest"
const SLICE_TBD := "tbd"

const OPENWORLD_SCREEN_PATH := "res://modes/openworld/openworld_forest_screen.gd"
const OPENWORLD_ENABLED_SETTING := "draxos_mobile/modes/openworld/enabled"

const _ENTRIES := {
	MODE_BASEBUILDER: {
		"mode_id": MODE_BASEBUILDER,
		"slice_id": SLICE_BASEBUILDER_REFUGIO,
		"display_name": "Basebuilder",
		"status": "active",
		"release_channel": "internal_alpha",
		"route_id": "refuge",
		"fullscreen": false,
		"public_cta": true,
		"enabled_setting": "",
	},
	MODE_AUTOBATTLER: {
		"mode_id": MODE_AUTOBATTLER,
		"slice_id": SLICE_AUTOBATTLER_PVE_ARENA,
		"display_name": "Autobattler",
		"status": "active",
		"release_channel": "internal_alpha",
		"route_id": "arena_selection",
		"fullscreen": false,
		"public_cta": true,
		"enabled_setting": "",
	},
	MODE_OPENWORLD: {
		"mode_id": MODE_OPENWORLD,
		"slice_id": SLICE_OPENWORLD_FOREST,
		"display_name": "Openworld",
		"status": "internal_alpha",
		"release_channel": "internal_alpha",
		"screen_path": OPENWORLD_SCREEN_PATH,
		"route_id": "mode_shell",
		"fullscreen": true,
		"public_cta": true,
		"enabled_setting": OPENWORLD_ENABLED_SETTING,
	},
	MODE_TOWERDEFENSE: {
		"mode_id": MODE_TOWERDEFENSE,
		"slice_id": SLICE_TBD,
		"display_name": "Towerdefense",
		"status": "planned_disabled",
		"release_channel": "staged",
		"route_id": "",
		"fullscreen": true,
		"public_cta": false,
		"enabled_setting": "",
	},
	MODE_CARDGAME: {
		"mode_id": MODE_CARDGAME,
		"slice_id": SLICE_TBD,
		"display_name": "Cardgame",
		"status": "planned_disabled",
		"release_channel": "staged",
		"route_id": "",
		"fullscreen": false,
		"public_cta": false,
		"enabled_setting": "",
	},
}

static func entry(mode_id: String) -> Dictionary:
	var normalized := normalize_mode_id(mode_id)
	return _as_dictionary(_ENTRIES.get(normalized, {})).duplicate(true)

static func display_name(mode_id: String) -> String:
	return str(entry(mode_id).get("display_name", "Mode"))

static func screen_path(mode_id: String) -> String:
	return str(entry(mode_id).get("screen_path", ""))

static func route_id(mode_id: String) -> String:
	return str(entry(mode_id).get("route_id", ""))

static func status(mode_id: String) -> String:
	return str(entry(mode_id).get("status", "unknown"))

static func is_enabled_for_hub(mode_id: String) -> bool:
	var data := entry(mode_id)
	if data.is_empty():
		return false
	var setting := str(data.get("enabled_setting", "")).strip_edges()
	if setting != "" and not bool(ProjectSettings.get_setting(setting, false)):
		return false
	return true

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

static func can_launch(mode_id: String) -> bool:
	var normalized := normalize_mode_id(mode_id)
	match normalized:
		MODE_BASEBUILDER, MODE_AUTOBATTLER:
			return true
		MODE_OPENWORLD:
			return is_available(normalized)
		_:
			return false

static func normalize_mode_id(mode_id: String) -> String:
	var normalized := mode_id.strip_edges().to_lower()
	if normalized == "openworld_bosque":
		return MODE_OPENWORLD
	return normalized

static func registered_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for key: String in _ENTRIES.keys():
		ids.append(key)
	return ids

static func hub_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for mode_id: String in [
		MODE_BASEBUILDER,
		MODE_AUTOBATTLER,
		MODE_OPENWORLD,
		MODE_TOWERDEFENSE,
		MODE_CARDGAME,
	]:
		entries.append(entry(mode_id))
	return entries

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
