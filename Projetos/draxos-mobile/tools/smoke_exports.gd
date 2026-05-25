extends SceneTree

const EXPECTED_PRESETS := {
	"Android Alpha": "Android",
	"PC Windows Alpha": "Windows Desktop",
	"PC Browser Alpha": "Web",
}
const EXPECTED_EXCLUDES := [
	"dev/**",
	"tools/battle_lab/**",
	"tools/progression_lab/**",
	"docs/battle-lab/**",
	"docs/progression-lab/**",
	".battle_lab_scratch/**",
	".progression_lab_scratch/**",
]

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	var config := ConfigFile.new()
	var error := config.load("res://export_presets.cfg")
	if error != OK:
		printerr("[smoke-exports] export_presets.cfg could not be loaded.")
		return 1

	_check_main_scene()
	_check_presets(config)

	if _failures.is_empty():
		print("[smoke-exports] OK Android Alpha, PC Windows Alpha, PC Browser Alpha")
		return 0

	for failure in _failures:
		printerr("[smoke-exports] %s" % failure)
	return 1

func _check_main_scene() -> void:
	var main_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene != "res://modes/boot/boot.tscn":
		_failures.append("application/run/main_scene must point to boot.tscn")
	if not FileAccess.file_exists(main_scene):
		_failures.append("main scene is missing: %s" % main_scene)

func _check_presets(config: ConfigFile) -> void:
	var found: Dictionary = {}
	var index := 0
	while config.has_section("preset.%d" % index):
		var section := "preset.%d" % index
		var name := str(config.get_value(section, "name", ""))
		var platform := str(config.get_value(section, "platform", ""))
		var export_path := str(config.get_value(section, "export_path", ""))
		if EXPECTED_PRESETS.has(name):
			found[name] = true
			var expected_platform := str(EXPECTED_PRESETS[name])
			if platform != expected_platform:
				_failures.append("%s expected platform %s, got %s" % [name, expected_platform, platform])
			if export_path == "":
				_failures.append("%s must define export_path" % name)
			var exclude_filter := str(config.get_value(section, "exclude_filter", ""))
			for expected_exclude: String in EXPECTED_EXCLUDES:
				if not exclude_filter.contains(expected_exclude):
					_failures.append("%s must exclude %s from packaged builds" % [name, expected_exclude])
		index += 1

	for expected_name: String in EXPECTED_PRESETS.keys():
		if not bool(found.get(expected_name, false)):
			_failures.append("missing export preset: %s" % expected_name)
