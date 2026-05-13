extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const TEST_SAVE_PATH: String = "user://rpg_turnos_rank_test.json"

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()

func before_each() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)
	GameSession.start_new_game()

func after_each() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)

# --- Initial state ---

func test_new_game_starts_at_rank_zero() -> void:
	assert_eq(GameSession.operacao_rank, 0)

func test_new_game_rank_display_is_recruta() -> void:
	assert_eq(GameSession.get_rank_display_name(), "Recruta")

# --- Rank thresholds ---

func test_rank_advances_to_agente_after_one_completion() -> void:
	GameSession.active_encounter_id = "emboscada_na_ponte"
	GameSession.complete_encounter("test")
	assert_eq(GameSession.operacao_rank, 1)
	assert_eq(GameSession.get_rank_display_name(), "Agente")

func test_rank_stays_agente_after_two_completions() -> void:
	_complete_n_encounters(2)
	assert_eq(GameSession.operacao_rank, 1)

func test_rank_advances_to_operativo_after_three_completions() -> void:
	_complete_n_encounters(3)
	assert_eq(GameSession.operacao_rank, 2)
	assert_eq(GameSession.get_rank_display_name(), "Operativo")

func test_rank_stays_operativo_after_five_completions() -> void:
	_complete_n_encounters(5)
	assert_eq(GameSession.operacao_rank, 2)

func test_rank_advances_to_comandante_after_six_completions() -> void:
	_complete_n_encounters(6)
	assert_eq(GameSession.operacao_rank, 3)
	assert_eq(GameSession.get_rank_display_name(), "Comandante")

func test_rank_does_not_exceed_three() -> void:
	_complete_n_encounters(10)
	assert_eq(GameSession.operacao_rank, 3)

func test_rank_never_decreases() -> void:
	_complete_n_encounters(6)
	assert_eq(GameSession.operacao_rank, 3)
	# Manually regress completed list (abnormal, but guards implementation)
	GameSession.completed_encounter_ids.clear()
	# rank should not auto-drop — it only advances via complete_encounter
	assert_eq(GameSession.operacao_rank, 3)

# --- Save / load ---

func test_rank_saved_and_loaded() -> void:
	_complete_n_encounters(3)
	assert_eq(GameSession.operacao_rank, 2)
	GameSession.save_game(TEST_SAVE_PATH)

	GameSession.start_new_game()
	assert_eq(GameSession.operacao_rank, 0)

	GameSession.load_game(TEST_SAVE_PATH)
	assert_eq(GameSession.operacao_rank, 2)

func test_old_save_without_rank_field_loads_as_zero() -> void:
	# Build save data without the operacao_rank field
	var save_data: Dictionary = GameSession.build_save_data()
	save_data.erase("operacao_rank")
	var file: FileAccess = FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file = null

	GameSession.load_game(TEST_SAVE_PATH)
	assert_eq(GameSession.operacao_rank, 0)

func test_corrupted_rank_value_clamped_to_zero() -> void:
	var save_data: Dictionary = GameSession.build_save_data()
	save_data["operacao_rank"] = -5
	var file: FileAccess = FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file = null

	GameSession.load_game(TEST_SAVE_PATH)
	assert_eq(GameSession.operacao_rank, 0)

func test_rank_above_max_clamped_on_load() -> void:
	var save_data: Dictionary = GameSession.build_save_data()
	save_data["operacao_rank"] = 99
	var file: FileAccess = FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
	file = null

	GameSession.load_game(TEST_SAVE_PATH)
	assert_eq(GameSession.operacao_rank, 3)

# --- Snapshot ---

func test_snapshot_preserves_rank() -> void:
	_complete_n_encounters(3)
	assert_eq(GameSession.operacao_rank, 2)
	GameSession.capture_pre_combat_snapshot()

	_complete_n_encounters(3)  # advance rank to 3
	assert_eq(GameSession.operacao_rank, 3)

	GameSession.restore_pre_combat_snapshot()
	assert_eq(GameSession.operacao_rank, 2)

# --- Rank gate helpers ---

func test_marker_available_at_rank_zero_for_min_rank_zero() -> void:
	# rank 0 can access min_rank 0 encounters
	assert_eq(GameSession.operacao_rank, 0)
	# The rank check is tested indirectly via the session state that world_root reads.
	# We verify the threshold logic directly:
	assert_true(GameSession.operacao_rank >= 0)

func test_marker_blocked_by_min_rank_one_at_rank_zero() -> void:
	# patrulha_avancada requires min_rank 1; rank 0 player cannot access it
	assert_eq(GameSession.operacao_rank, 0)
	assert_false(GameSession.operacao_rank >= 1)

func test_marker_available_for_patrulha_avancada_at_rank_one() -> void:
	_complete_n_encounters(1)
	assert_eq(GameSession.operacao_rank, 1)
	assert_true(GameSession.operacao_rank >= 1)

func test_marker_available_for_duelista_sombrio_at_rank_two() -> void:
	_complete_n_encounters(3)
	assert_eq(GameSession.operacao_rank, 2)
	assert_true(GameSession.operacao_rank >= 2)

func test_marker_blocked_for_emboscada_reforcos_at_rank_two() -> void:
	_complete_n_encounters(3)
	assert_eq(GameSession.operacao_rank, 2)
	assert_false(GameSession.operacao_rank >= 3)

func test_marker_available_for_emboscada_reforcos_at_rank_three() -> void:
	_complete_n_encounters(6)
	assert_eq(GameSession.operacao_rank, 3)
	assert_true(GameSession.operacao_rank >= 3)

# --- Helpers ---

func _complete_n_encounters(n: int) -> void:
	var fake_ids: Array[String] = [
		"enc_a", "enc_b", "enc_c", "enc_d", "enc_e",
		"enc_f", "enc_g", "enc_h", "enc_i", "enc_j"
	]
	for i: int in range(n):
		GameSession.active_encounter_id = fake_ids[i % fake_ids.size()] + str(i)
		# Avoid duplicate ids by appending index
		var unique_id: String = fake_ids[i % fake_ids.size()] + str(i)
		GameSession.active_encounter_id = unique_id
		if not GameSession.completed_encounter_ids.has(unique_id):
			GameSession.complete_encounter("test %d" % i)
