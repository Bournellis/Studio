extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_validation()
	quit(exit_code)

func _run_validation() -> int:
	print("[validate] generating DraxosMobile content catalog")
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[validate] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1

	print("[validate] checking project resources and autoloads")
	_check_project_setting(
		"application/run/main_scene",
		"res://modes/boot/boot.tscn"
	)
	_check_project_setting("autoload/UiTokens", "*res://core/ui_tokens.gd")
	_check_project_setting("autoload/AssetIds", "*res://core/asset_ids.gd")
	_check_project_setting("autoload/ContentLibrary", "*res://data/content_library.gd")
	_check_project_setting("autoload/SessionStore", "*res://online/session_store.gd")
	_check_project_setting("autoload/SupabaseClient", "*res://online/supabase_client.gd")
	_check_resource("res://modes/boot/boot.tscn")
	_check_resource("res://modes/boot/boot.gd")
	_check_resource("res://core/project_info.gd")
	_check_resource("res://core/ui_tokens.gd")
	_check_resource("res://core/asset_ids.gd")
	_check_resource("res://online/session_store.gd")
	_check_resource("res://online/supabase_client.gd")
	_check_resource("res://ui/battle_log_presenter.gd")
	_check_resource("res://tools/smoke_session_shell.gd")
	_check_resource("res://tools/smoke_battle_replay.gd")
	_check_resource("res://tools/smoke_exports.gd")
	_check_resource("res://export_presets.cfg")
	_check_resource("res://data/content_library.gd")
	_check_resource("res://data/resources/draxos_mobile_catalog.gd")
	_check_resource("res://data/generated/draxos_mobile_catalog.tres")
	_check_resource("res://addons/gut/plugin.cfg")
	_check_resource("res://.gutconfig.json")
	_check_resource("res://tests/client/test_project_info.gd")

	print("[validate] checking content contract")
	var contract_result: Dictionary = _validate_content_contract()
	if not bool(contract_result.get("ok", false)):
		_failures.append(str(contract_result.get("message", "Content contract failed.")))

	if _failures.is_empty():
		print("[validate] running GUT")
		var gut_exit_code: int = await _run_gut()
		if gut_exit_code != 0:
			printerr("[validate] GUT failed with exit code %d." % gut_exit_code)
			return gut_exit_code
		print("DraxosMobile validate: OK")
		return 0

	for failure in _failures:
		push_error(failure)
	return 1

func _check_project_setting(key: String, expected: Variant) -> void:
	var actual: Variant = ProjectSettings.get_setting(key)
	if actual != expected:
		_failures.append("%s expected %s, got %s" % [key, expected, actual])

func _check_resource(path: String) -> void:
	if not FileAccess.file_exists(path):
		_failures.append("Missing resource: %s" % path)

func _validate_content_contract() -> Dictionary:
	var catalog = load("res://data/generated/draxos_mobile_catalog.tres")
	if catalog == null:
		return {"ok": false, "message": "Missing generated DraxosMobile catalog."}
	if catalog.schema_version != 1:
		return {"ok": false, "message": "Generated catalog must use schema_version 1."}
	for collection_id: String in ContentGeneratorScript.new().expected_collection_ids():
		if catalog.get_collection(collection_id).is_empty():
			return {"ok": false, "message": "Generated catalog has empty collection %s." % collection_id}
	if not catalog.has_item("battle_fixtures", "mvp_training_battle"):
		return {"ok": false, "message": "MVP battle fixture is missing from generated catalog."}
	var fixture: Dictionary = catalog.find_item("battle_fixtures", "mvp_training_battle")
	if str(fixture.get("mode", "")) != ProjectInfo.MVP_MODE:
		return {"ok": false, "message": "MVP battle fixture must be marked MVP_ONLY."}
	return {"ok": true}

func _run_gut() -> int:
	var gut_config_script: Script = load("res://addons/gut/gut_config.gd")
	if gut_config_script == null or not gut_config_script.can_instantiate():
		printerr("[validate] GUT is not ready. Run a one-time headless editor import, then validate again.")
		return 1

	var gut_config = gut_config_script.new()
	var load_result: int = int(gut_config.load_options("res://.gutconfig.json"))
	if load_result == -1:
		printerr("[validate] Failed to load res://.gutconfig.json.")
		return 1

	gut_config.options.should_exit = false
	gut_config.options.should_exit_on_success = false

	var gut_script: Script = load("res://addons/gut/gut.gd")
	if gut_script == null or not gut_script.can_instantiate():
		printerr("[validate] Failed to instantiate GUT runner.")
		return 1

	var gut = gut_script.new()
	gut.name = "ValidationGut"
	root.add_child(gut)
	gut_config.apply_options(gut)
	gut.ignore_pause_before_teardown = true

	var completed: Array[bool] = [false]
	var exit_code: Array[int] = [0]
	gut.end_run.connect(func() -> void:
		exit_code[0] = 1 if gut.get_fail_count() > 0 else 0
		completed[0] = true
	)

	gut.test_scripts(gut.unit_test_name == "")
	while not completed[0]:
		await process_frame

	gut.queue_free()
	await process_frame
	return exit_code[0]
