extends Node

const LoadoutData = preload("res://gameplay/loadouts/loadout_data.gd")
const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")
const LocalModeLaunchRequest = preload("res://modes/shared/local_mode_launch_request.gd")

var pending_launch_request: LocalModeLaunchRequest

func set_pending_mode_launch(mode_id: StringName, loadout: LoadoutData, parameters: Dictionary = {}) -> Dictionary:
	var request := LocalModeLaunchRequest.new()
	var result: Dictionary = request.configure(mode_id, loadout, parameters)
	if not bool(result.get("ok", false)):
		return result

	pending_launch_request = request
	return result

func consume_pending_mode_launch() -> LocalModeLaunchRequest:
	var consumed: LocalModeLaunchRequest = pending_launch_request
	pending_launch_request = null
	return consumed

func peek_pending_mode_launch() -> LocalModeLaunchRequest:
	return pending_launch_request

func clear_pending_mode_launch() -> void:
	pending_launch_request = null

func has_pending_mode_launch(expected_mode_id: StringName = &"") -> bool:
	if pending_launch_request == null or not pending_launch_request.is_valid():
		return false
	return expected_mode_id == &"" or pending_launch_request.mode_id == LocalModeCatalog.normalize_mode_id(expected_mode_id)

func set_pending_loadout(loadout: LoadoutData) -> void:
	if loadout == null:
		clear_pending_mode_launch()
		return
	set_pending_mode_launch(LocalModeCatalog.ARENA_MODE_ID, loadout)

func consume_pending_loadout() -> LoadoutData:
	var consumed: LocalModeLaunchRequest = consume_pending_mode_launch()
	if consumed == null:
		return null
	return consumed.loadout

func has_pending_loadout() -> bool:
	return has_pending_mode_launch()
