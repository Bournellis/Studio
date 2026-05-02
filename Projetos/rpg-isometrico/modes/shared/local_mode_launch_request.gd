class_name LocalModeLaunchRequest
extends RefCounted

const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

var mode_id: StringName = &""
var scene_path: String = ""
var return_scene_path: String = LocalModeCatalog.FRONTEND_SCENE_PATH
var loadout: LoadoutData
var parameters: Dictionary = {}

func configure(next_mode_id: StringName, next_loadout: LoadoutData, next_parameters: Dictionary = {}) -> Dictionary:
	var resolved_mode_id: StringName = LocalModeCatalog.normalize_mode_id(next_mode_id)
	if not LocalModeCatalog.is_supported_mode(resolved_mode_id):
		return {"ok": false, "message": "O modo local solicitado nao existe."}
	if next_loadout == null or not next_loadout.is_valid():
		return {"ok": false, "message": "O kit precisa estar valido antes do lancamento."}

	mode_id = resolved_mode_id
	scene_path = LocalModeCatalog.get_scene_path(mode_id)
	return_scene_path = LocalModeCatalog.FRONTEND_SCENE_PATH
	loadout = next_loadout
	parameters = LocalModeCatalog.build_launch_parameters(mode_id, next_parameters)
	return {"ok": true, "scene_path": scene_path, "mode_id": String(mode_id)}

func is_valid() -> bool:
	return mode_id != &"" and scene_path != "" and loadout != null and loadout.is_valid()

func get_mode_display_name() -> String:
	return LocalModeCatalog.get_display_name(mode_id)

func get_parameter(key: StringName, fallback: Variant = null) -> Variant:
	return parameters.get(String(key), fallback)

func get_arena_opponent_id() -> StringName:
	return StringName(str(parameters.get("opponent_id", "bot")))

func get_campaign_id() -> StringName:
	return StringName(str(parameters.get("campaign_id", "blacksmith_campaign")))

func get_campaign_difficulty_id() -> StringName:
	return StringName(str(parameters.get("difficulty_id", "easy")))

func get_survival_start_wave() -> int:
	return maxi(1, int(parameters.get("start_wave", 1)))

func get_boss_id() -> StringName:
	return StringName(str(parameters.get("boss_id", "boss_troll")))

func should_resume_suspended_run() -> bool:
	return bool(parameters.get("resume_suspended_run", false))
