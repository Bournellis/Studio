class_name JogoDaCopaGameSettings
extends Node

signal volume_changed(bus_name: StringName, value: float)
signal fullscreen_changed(enabled: bool)
signal quality_changed(quality_id: StringName)
signal mouse_sensitivity_changed(value: float)
signal settings_changed()

const RenderProfileScript = preload("res://autoloads/render_profile.gd")

const CONFIG_PATH: String = "user://jogodacopa_settings.cfg"
const BUS_MASTER: StringName = &"Master"
const BUS_SFX: StringName = &"SFX"
const BUS_UI: StringName = &"UI"
const BUS_AMBIENCE: StringName = &"Ambience"
const AUDIO_BUSES: Array[StringName] = [BUS_MASTER, BUS_SFX, BUS_UI, BUS_AMBIENCE]
const DEFAULT_VOLUMES: Dictionary = {
	BUS_MASTER: 0.82,
	BUS_SFX: 0.86,
	BUS_UI: 0.9,
	BUS_AMBIENCE: 0.78,
}
const DEFAULT_FULLSCREEN_ENABLED: bool = false
const DEFAULT_QUALITY_ID: StringName = RenderProfileScript.QUALITY_HIGH
const DEFAULT_MOUSE_SENSITIVITY: float = 0.0018
const MIN_MOUSE_SENSITIVITY: float = 0.0008
const MAX_MOUSE_SENSITIVITY: float = 0.0032
const WEB_AUDIO_UNLOCK_POLL_MSEC: int = 500

var _config_path: String = CONFIG_PATH
var _volumes: Dictionary = {}
var _fullscreen_enabled: bool = DEFAULT_FULLSCREEN_ENABLED
var _quality_id: StringName = DEFAULT_QUALITY_ID
var _mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
var _web_audio_unlocked: bool = false
var _web_audio_next_unlock_poll_msec: int = 0

func _init() -> void:
	_apply_default_values()

func _ready() -> void:
	if _uses_validation_defaults():
		reset_to_defaults(false, true)
		return
	load_settings()
	apply_all(false)

func set_config_path_for_tests(path: String, reset_before_load: bool = true) -> void:
	_config_path = path
	if reset_before_load:
		reset_to_defaults(false, false)

func get_config_path() -> String:
	return _config_path

func reset_to_defaults(save_to_disk: bool = false, apply_now: bool = true) -> void:
	_apply_default_values()
	RenderProfileScript.set_quality_id(_quality_id)
	if apply_now:
		apply_all(false)
	if save_to_disk:
		save_settings()
	_emit_all_changed()

func load_settings() -> bool:
	_apply_default_values()
	var config := ConfigFile.new()
	var error := config.load(_config_path)
	if error != OK:
		RenderProfileScript.set_quality_id(_quality_id)
		return error == ERR_FILE_NOT_FOUND

	for bus_name: StringName in AUDIO_BUSES:
		_volumes[bus_name] = clampf(float(config.get_value("audio", str(bus_name).to_lower(), _get_default_volume(bus_name))), 0.0, 1.0)
	_fullscreen_enabled = bool(config.get_value("video", "fullscreen", DEFAULT_FULLSCREEN_ENABLED))
	_quality_id = RenderProfileScript.normalize_quality_id(StringName(str(config.get_value("video", "quality", str(DEFAULT_QUALITY_ID)))))
	_mouse_sensitivity = clampf(float(config.get_value("controls", "mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)), MIN_MOUSE_SENSITIVITY, MAX_MOUSE_SENSITIVITY)
	RenderProfileScript.set_quality_id(_quality_id)
	return true

func save_settings() -> bool:
	if _uses_validation_defaults():
		return true
	var config := ConfigFile.new()
	for bus_name: StringName in AUDIO_BUSES:
		config.set_value("audio", str(bus_name).to_lower(), get_volume(bus_name))
	config.set_value("video", "fullscreen", _fullscreen_enabled)
	config.set_value("video", "quality", str(_quality_id))
	config.set_value("controls", "mouse_sensitivity", _mouse_sensitivity)
	var error := config.save(_config_path)
	if error != OK:
		push_error("GameSettings failed to save %s: %s" % [_config_path, error_string(error)])
		return false
	return true

func apply_all(from_user_gesture: bool = false) -> void:
	apply_audio_settings(from_user_gesture)
	apply_quality_settings()
	apply_fullscreen_setting(from_user_gesture)

func apply_audio_settings(from_user_gesture: bool = false) -> bool:
	if not _can_touch_audio_server(from_user_gesture):
		return false
	_ensure_audio_buses()
	for bus_name: StringName in AUDIO_BUSES:
		_apply_bus_volume(bus_name, get_volume(bus_name))
	return true

func apply_quality_settings() -> void:
	RenderProfileScript.set_quality_id(_quality_id)

func apply_fullscreen_setting(from_user_gesture: bool = false) -> void:
	if RenderProfileScript.is_web_platform() and not from_user_gesture:
		if _fullscreen_enabled:
			push_warning("GameSettings fullscreen is saved, but Web fullscreen needs a user gesture.")
		return
	var target_mode := DisplayServer.WINDOW_MODE_FULLSCREEN if _fullscreen_enabled else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != target_mode:
		DisplayServer.window_set_mode(target_mode)

func get_volume(bus_name: StringName) -> float:
	return clampf(float(_volumes.get(_normalize_bus_name(bus_name), _get_default_volume(bus_name))), 0.0, 1.0)

func set_volume(bus_name: StringName, value: float, save_to_disk: bool = true, from_user_gesture: bool = false) -> void:
	var normalized_bus := _normalize_bus_name(bus_name)
	var clamped_value := clampf(value, 0.0, 1.0)
	if is_equal_approx(get_volume(normalized_bus), clamped_value):
		if from_user_gesture:
			apply_audio_settings(true)
		return
	_volumes[normalized_bus] = clamped_value
	apply_audio_settings(from_user_gesture)
	if save_to_disk:
		save_settings()
	volume_changed.emit(normalized_bus, clamped_value)
	settings_changed.emit()

func get_fullscreen_enabled() -> bool:
	return _fullscreen_enabled

func set_fullscreen_enabled(enabled: bool, save_to_disk: bool = true, from_user_gesture: bool = true) -> void:
	if _fullscreen_enabled == enabled:
		apply_fullscreen_setting(from_user_gesture)
		return
	_fullscreen_enabled = enabled
	apply_fullscreen_setting(from_user_gesture)
	if save_to_disk:
		save_settings()
	fullscreen_changed.emit(_fullscreen_enabled)
	settings_changed.emit()

func get_quality_id() -> StringName:
	return _quality_id

func get_quality_label() -> String:
	return RenderProfileScript.get_quality_label(_quality_id)

func set_quality_id(quality_id: StringName, save_to_disk: bool = true) -> void:
	var normalized_quality := RenderProfileScript.normalize_quality_id(quality_id)
	if _quality_id == normalized_quality:
		apply_quality_settings()
		return
	_quality_id = normalized_quality
	apply_quality_settings()
	if save_to_disk:
		save_settings()
	quality_changed.emit(_quality_id)
	settings_changed.emit()

func get_mouse_sensitivity() -> float:
	return _mouse_sensitivity

func set_mouse_sensitivity(value: float, save_to_disk: bool = true) -> void:
	var clamped_value := clampf(value, MIN_MOUSE_SENSITIVITY, MAX_MOUSE_SENSITIVITY)
	if is_equal_approx(_mouse_sensitivity, clamped_value):
		return
	_mouse_sensitivity = clamped_value
	if save_to_disk:
		save_settings()
	mouse_sensitivity_changed.emit(_mouse_sensitivity)
	settings_changed.emit()

func _apply_default_values() -> void:
	_volumes.clear()
	for bus_name: StringName in AUDIO_BUSES:
		_volumes[bus_name] = _get_default_volume(bus_name)
	_fullscreen_enabled = DEFAULT_FULLSCREEN_ENABLED
	_quality_id = DEFAULT_QUALITY_ID
	_mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY

func _emit_all_changed() -> void:
	for bus_name: StringName in AUDIO_BUSES:
		volume_changed.emit(bus_name, get_volume(bus_name))
	fullscreen_changed.emit(_fullscreen_enabled)
	quality_changed.emit(_quality_id)
	mouse_sensitivity_changed.emit(_mouse_sensitivity)
	settings_changed.emit()

func _get_default_volume(bus_name: StringName) -> float:
	return float(DEFAULT_VOLUMES.get(_normalize_bus_name(bus_name), 1.0))

func _normalize_bus_name(bus_name: StringName) -> StringName:
	var name := str(bus_name).strip_edges()
	match name.to_lower():
		"master":
			return BUS_MASTER
		"sfx":
			return BUS_SFX
		"ui":
			return BUS_UI
		"ambience", "ambiente":
			return BUS_AMBIENCE
		_:
			return bus_name

func _can_touch_audio_server(from_user_gesture: bool = false) -> bool:
	if not RenderProfileScript.is_web_platform():
		return true
	if _web_audio_unlocked:
		return true
	if not from_user_gesture:
		return false
	var now_msec := Time.get_ticks_msec()
	if now_msec < _web_audio_next_unlock_poll_msec:
		return false
	_web_audio_next_unlock_poll_msec = now_msec + WEB_AUDIO_UNLOCK_POLL_MSEC
	var state := str(JavaScriptBridge.eval("navigator.userActivation && navigator.userActivation.hasBeenActive ? '1' : '0'", true))
	_web_audio_unlocked = state == "1"
	return _web_audio_unlocked

func _ensure_audio_buses() -> void:
	for bus_name: StringName in AUDIO_BUSES:
		_ensure_audio_bus(bus_name)

func _ensure_audio_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(str(bus_name)) >= 0:
		return
	AudioServer.add_bus(AudioServer.get_bus_count())
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, str(bus_name))
	if bus_name != BUS_MASTER:
		AudioServer.set_bus_send(bus_index, str(BUS_MASTER))

func _apply_bus_volume(bus_name: StringName, value: float) -> void:
	_ensure_audio_bus(bus_name)
	var bus_index := AudioServer.get_bus_index(str(bus_name))
	if bus_index < 0:
		push_error("GameSettings missing audio bus: %s" % str(bus_name))
		return
	var clamped_value := clampf(value, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, clamped_value <= 0.001)
	AudioServer.set_bus_volume_db(bus_index, -80.0 if clamped_value <= 0.001 else linear_to_db(clamped_value))

func _uses_validation_defaults() -> bool:
	if _config_path != CONFIG_PATH:
		return false
	for arg: String in _collect_command_line_args():
		if arg.contains("tools/validate.gd") or arg.contains("addons/gut"):
			return true
	return false

func _collect_command_line_args() -> Array[String]:
	var args: Array[String] = []
	for arg: String in OS.get_cmdline_args():
		args.append(arg)
	for arg: String in OS.get_cmdline_user_args():
		args.append(arg)
	return args
