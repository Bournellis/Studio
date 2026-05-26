extends SceneTree

const BattleLabScreenScript = preload("res://dev/battle_lab/battle_lab_screen.gd")
const ProgressionLabScreenScript = preload("res://dev/progression_lab/progression_lab_screen.gd")

const OUTPUT_DIR := "user://dev_lab_visual_smoke"
const VIEWPORT_SIZE := Vector2i(1280, 720)

var _failures: Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	root.size = VIEWPORT_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	await _capture_battle_lab()
	await _capture_progression_lab()

	if _failures.is_empty():
		print("[smoke-dev-lab-ui] OK screenshots in %s" % ProjectSettings.globalize_path(OUTPUT_DIR))
		return 0

	for failure: String in _failures:
		printerr("[smoke-dev-lab-ui] %s" % failure)
	return 1

func _capture_battle_lab() -> void:
	var screen = BattleLabScreenScript.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(screen)
	await process_frame
	screen._tabs.current_tab = 1
	await _capture("battle_builds.png")
	screen._refresh_from_response(_custom_replay_response())
	await process_frame
	if screen._tabs.current_tab != 3:
		_failures.append("Battle Lab custom replay did not switch to Replay tab.")
	if screen._last_replays.is_empty():
		_failures.append("Battle Lab custom replay was not registered as a sample.")
	if not screen._history_label.text.contains("Custom replays"):
		_failures.append("Battle Lab custom replay was not registered in History.")
	await _capture("battle_custom_replay.png")
	screen._tabs.current_tab = 4
	await _capture("battle_history.png")
	screen.queue_free()
	await process_frame

func _capture_progression_lab() -> void:
	var screen = ProgressionLabScreenScript.new()
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(screen)
	await process_frame
	screen._prepare_local_save()
	screen._load_selected_save()
	await process_frame
	if not screen._status_label.text.contains("Save carregado"):
		_failures.append("Progression Lab local cache did not load into SessionStore.")
	if not screen._summary_label.text.contains("Save"):
		_failures.append("Progression Lab did not render a loaded save summary.")
	await _capture("progression_loaded_save.png")
	screen.queue_free()
	await process_frame

func _capture(file_name: String) -> void:
	await process_frame
	await process_frame
	if DisplayServer.get_name().to_lower().contains("headless"):
		print("[smoke-dev-lab-ui] screenshot skipped on headless renderer: %s" % file_name)
		return
	var texture := root.get_texture()
	if texture == null:
		print("[smoke-dev-lab-ui] screenshot skipped on renderer without viewport texture: %s" % file_name)
		return
	var image := texture.get_image()
	if image == null or image.is_empty():
		_failures.append("Screenshot is empty: %s" % file_name)
		return
	var path := ProjectSettings.globalize_path(OUTPUT_DIR.path_join(file_name))
	var error := image.save_png(path)
	if error != OK:
		_failures.append("Could not save screenshot %s: %s" % [file_name, str(error)])

func _custom_replay_response() -> Dictionary:
	return {
		"schema_version": "battle_lab_response_v1",
		"ok": true,
		"mode": "replay",
		"status": "PASS",
		"replay": {
			"tag": "custom",
			"matchup_id": "godot_custom_replay",
			"seed": "visual_smoke",
			"level": 25,
			"player_build_id": "smoke_blood_body",
			"opponent_build_id": "smoke_ice_control",
			"player_archetype_id": "custom",
			"opponent_archetype_id": "custom",
			"player_power": 3200,
			"opponent_power": 3100,
			"duration": 18.5,
			"winner": "player",
			"reason": "defeated",
			"battle_log": {
				"schema_version": "battle_log_v1",
				"battle_id": "godot_custom_replay",
				"duration": 18.5,
				"events": [
					{"t": 1.0, "seq": 1, "type": "spell_cast", "source": "player", "target": "opponent", "spell_id": "hemorragia_induzida", "damage": 42, "hp_after": 258},
					{"t": 1.1, "seq": 2, "type": "dot_apply", "source": "player", "target": "opponent", "status_id": "bleed", "hp_after": 258},
					{"t": 2.0, "seq": 3, "type": "pet_attack", "source": "player", "target": "opponent", "pet_id": "sanguessuga_sacramental", "damage": 18, "hp_after": 240},
				],
			},
			"rewards": {},
		},
	}
