extends "res://tests/unit/draxos_test_base.gd"

const BattleEffectSignatureScript = preload("res://tools/lab/battle_effect_signature.gd")
const BattlePolicyScript = preload("res://tools/lab/battle_policy.gd")
const BattleRunnerScript = preload("res://tools/lab/battle_runner.gd")
const CardImpactMatrixScript = preload("res://tools/lab/card_impact_matrix.gd")
const CardImpactPackLoaderScript = preload("res://tools/lab/card_impact_pack_loader.gd")
const CardImpactReporterScript = preload("res://tools/lab/card_impact_reporter.gd")
const CardImpactRunnerScript = preload("res://tools/lab/card_impact_runner.gd")

func test_card_impact_loader_loads_track02_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v1")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v1")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v1")

func test_card_impact_loader_loads_track02_v2_pack() -> void:
	var load_result: Dictionary = CardImpactPackLoaderScript.load_pack_result("track02_card_impact_v2")
	assert_true(bool(load_result.get("ok", false)), str(load_result.get("message", "")))
	var pack: Dictionary = Dictionary(load_result.get("pack", {}))
	assert_eq(str(pack.get("pack_id", "")), "track02_card_impact_v2")
	assert_eq(str(pack.get("simulation_mode", "")), "card_impact_v2")
	assert_true(bool(Dictionary(pack.get("effect_signatures", {})).get("enabled", false)))
	assert_eq(int(Dictionary(pack.get("effect_signatures", {})).get("schema_version", 0)), 2)

func test_card_impact_matrix_discovers_expected_cards() -> void:
	var pack: Dictionary = _pack()
	var discovery: Dictionary = CardImpactMatrixScript.discover_cards(ContentLibrary.get_catalog(), pack)
	assert_true(bool(discovery.get("ok", false)), "; ".join(Array(discovery.get("errors", []))))
	assert_eq(Array(discovery.get("player_cards", [])).size(), 54)
	assert_eq(Array(discovery.get("enemy_cards", [])).size(), 30)
	assert_eq(Array(discovery.get("legacy_inactive_cards", [])).size(), 15)

func test_card_impact_matrix_excludes_legacy_inactive_cards() -> void:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["all"]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	for case_data: Dictionary in Array(matrix.get("cases", [])):
		var card_id: String = str(Dictionary(case_data.get("card_under_test", {})).get("id", ""))
		assert_false(card_id.begins_with("elemental_"), "%s should stay legacy inactive." % card_id)
	var summary: Dictionary = Dictionary(matrix.get("summary", {}))
	assert_eq(int(summary.get("battle_cases", 0)), 84)
	assert_eq(int(summary.get("legacy_inactive_cards_total", 0)), 15)

func test_card_impact_matrix_fails_when_active_count_is_missing() -> void:
	var pack: Dictionary = _pack().duplicate(true)
	var card_sets: Dictionary = Dictionary(pack.get("card_sets", {})).duplicate(true)
	card_sets["expected_player_cards"] = 55
	pack["card_sets"] = card_sets
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), pack, PackedStringArray(["all"]))
	assert_false(bool(matrix.get("ok", true)))
	assert_string_contains("; ".join(Array(matrix.get("errors", []))), "Expected 55 player cards")

func test_card_focus_policy_prioritizes_target_when_legal() -> void:
	var case_data: Dictionary = _single_case("arcano_choque")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data, {"max_actions_per_turn": 1})
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_played", false)))
	var timeline: Array = Array(metrics.get("timeline", []))
	assert_gt(timeline.size(), 0)
	var played: Array = Array(Dictionary(timeline[0]).get("cards_played", []))
	assert_gt(played.size(), 0)
	assert_eq(str(Dictionary(played[0]).get("card_id", "")), "arcano_choque")
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))

func test_battle_effect_signature_detects_damage_and_summon() -> void:
	var before_damage: Dictionary = _effect_snapshot(40, 40, [], [_slot("enemy_terra_elemental_areia", 2, 4, 4)])
	var after_damage: Dictionary = _effect_snapshot(40, 36, [], [_slot("enemy_terra_elemental_areia", 2, 1, 4)])
	var damage_sample: Dictionary = BattleEffectSignatureScript.build_sample("arcano_choque", {"owner": "inimigo", "hero": true}, before_damage, after_damage)
	assert_eq(int(damage_sample.get("enemy_hero_damage", 0)), 4)
	assert_eq(int(damage_sample.get("enemy_slot_damage_total", 0)), 3)
	assert_true(Array(damage_sample.get("families", [])).has("damage"))

	var before_summon: Dictionary = _effect_snapshot(40, 40, [null], [])
	var after_summon: Dictionary = _effect_snapshot(40, 40, [_slot("necro_esqueleto", 1, 3, 3, ["ressurgir"])], [])
	var summon_sample: Dictionary = BattleEffectSignatureScript.build_sample("necro_esqueleto", {"owner": "jogador", "slot": 0}, before_summon, after_summon)
	assert_eq(int(summon_sample.get("summons_created", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_count", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_slot_count", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_keyword_count", 0)), 1)
	assert_eq(int(summon_sample.get("summoned_health_total", 0)), 3)
	assert_true(Array(summon_sample.get("families", [])).has("summon"))

func test_battle_effect_signature_detects_buff_control_and_economy() -> void:
	var before: Dictionary = _effect_snapshot(40, 40, [_slot("invocador_soldado", 2, 2, 2)], [_slot("enemy_terra_elemental_areia", 3, 4, 4)])
	var after: Dictionary = _effect_snapshot(40, 40, [_slot("invocador_soldado", 4, 4, 4, ["escudo"], 0, 0, 1, 0, 0)], [_slot("enemy_terra_elemental_areia", 2, 4, 4, [], 2, 1, 0, 2)], 14, 3, 4, 7, 2, 7)
	var sample: Dictionary = BattleEffectSignatureScript.build_sample("unit", {"owner": "jogador", "area": "board"}, before, after)
	assert_eq(int(sample.get("ally_attack_buff_total", 0)), 2)
	assert_eq(int(sample.get("ally_health_buff_total", 0)), 2)
	assert_eq(int(sample.get("shield_added_total", 0)), 1)
	assert_eq(int(sample.get("ally_keyword_gain_count", 0)), 1)
	assert_eq(int(sample.get("ally_shield_gain", 0)), 1)
	assert_eq(int(sample.get("enemy_attack_debuff_total", 0)), 1)
	assert_eq(int(sample.get("poison_added_total", 0)), 2)
	assert_eq(int(sample.get("enemy_poison_added", 0)), 2)
	assert_eq(int(sample.get("freeze_added_total", 0)), 1)
	assert_eq(int(sample.get("enemy_frozen_added", 0)), 1)
	assert_eq(int(sample.get("enemy_snared_added", 0)), 2)
	assert_eq(int(sample.get("mana_gained", 0)), 4)
	assert_eq(int(sample.get("ashes_gained", 0)), 3)
	assert_eq(int(sample.get("cards_drawn", 0)), 1)
	assert_eq(int(sample.get("deck_delta", 0)), -1)
	assert_eq(int(sample.get("hand_delta", 0)), 1)
	assert_eq(int(sample.get("discard_delta", 0)), 1)

func test_battle_effect_signature_aggregates_support_metadata() -> void:
	var sample: Dictionary = BattleEffectSignatureScript.build_sample(
		"invocador_promover",
		{"owner": "jogador", "slot": 0},
		_effect_snapshot(40, 40, [_slot("invocador_soldado", 2, 2, 2)], []),
		_effect_snapshot(40, 40, [_slot("invocador_soldado", 3, 3, 3)], [])
	)
	sample["focused_card_play_index"] = 1
	sample["support_cards_before_target"] = ["invocador_soldado"]
	sample["support_card_count_before_target"] = 1
	var signature: Dictionary = BattleEffectSignatureScript.aggregate("invocador_promover", [sample])
	assert_eq(str(signature.get("support_contamination_status", "")), "support_assisted")
	assert_eq(str(signature.get("signature_confidence", "")), "support_assisted")
	assert_eq(int(signature.get("support_card_count_before_target", 0)), 1)

func test_card_focus_policy_never_chooses_rejected_action() -> void:
	var case_data: Dictionary = _single_case("arcano_choque")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data, {"max_actions_per_turn": 8})
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_eq(Array(metrics.get("runner_warnings", [])).size(), 0)

func test_card_impact_runner_executes_player_case_and_records_card_under_test() -> void:
	var report: Dictionary = CardImpactRunnerScript.run_phase(ContentLibrary.get_catalog(), RunSession, _pack(), {
		"phase": "before",
		"components": PackedStringArray(["battle"]),
		"cards": PackedStringArray(["arcano_choque"]),
		"out": "user://card_impact/gut_player",
		"mode": "gate"
	})
	assert_true(bool(report.get("ok", false)), str(Dictionary(report.get("summary", {})).get("structural_errors", [])))
	var components: Array = Array(Dictionary(report.get("summary", {})).get("components", []))
	assert_eq(components.size(), 1)
	assert_eq(str(Dictionary(components[0]).get("status", "")), "PASS")

func test_card_impact_v2_runner_executes_player_case_and_records_effect_signature() -> void:
	var report: Dictionary = CardImpactRunnerScript.run_phase(ContentLibrary.get_catalog(), RunSession, _pack_v2(), {
		"phase": "before",
		"components": PackedStringArray(["battle"]),
		"cards": PackedStringArray(["arcano_choque"]),
		"out": "user://card_impact/gut_v2_player",
		"mode": "gate"
	})
	assert_true(bool(report.get("ok", false)), str(Dictionary(report.get("summary", {})).get("structural_errors", [])))
	var components: Array = Array(Dictionary(report.get("summary", {})).get("components", []))
	assert_eq(components.size(), 1)
	assert_eq(str(Dictionary(components[0]).get("status", "")), "PASS")
	var signature_quality: Dictionary = Dictionary(Dictionary(components[0]).get("signature_quality", {}))
	assert_eq(int(signature_quality.get("total", 0)), 1)

func test_card_impact_v2_runner_marks_support_assisted_signature() -> void:
	var case_data: Dictionary = _single_case_v2("invocador_promover")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_played", false)))
	assert_true(bool(metrics.get("card_effect_signature_present", false)), str(metrics.get("card_effect_signature_missing_reason", "")))
	assert_eq(str(metrics.get("support_contamination_status", "")), "support_assisted")
	assert_gt(int(metrics.get("support_card_count_before_target", 0)), 0)
	var signature: Dictionary = Dictionary(metrics.get("card_effect_signature", {}))
	assert_eq(str(signature.get("support_contamination_status", "")), "support_assisted")

func test_card_impact_runner_executes_enemy_case_and_records_participation() -> void:
	var case_data: Dictionary = _single_case("enemy_terra_elemental_areia")
	var metrics: Dictionary = BattleRunnerScript.run_case(ContentLibrary.get_catalog(), {"pack_id": "unit", "simulation_mode": "battle_engine_v1"}, case_data)
	assert_false(bool(metrics.get("policy_action_rejected", true)), str(metrics.get("runner_warnings", [])))
	assert_true(bool(metrics.get("card_under_test_seen", false)))
	assert_true(bool(metrics.get("card_under_test_participated", false)))

func test_card_impact_filters_player_enemy_and_id() -> void:
	var player_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["player"]))
	assert_eq(Array(player_matrix.get("player_cards", [])).size(), 54)
	assert_eq(Array(player_matrix.get("enemy_cards", [])).size(), 0)
	var enemy_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["enemy"]))
	assert_eq(Array(enemy_matrix.get("player_cards", [])).size(), 0)
	assert_eq(Array(enemy_matrix.get("enemy_cards", [])).size(), 30)
	var id_matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray(["arcano_choque"]))
	assert_eq(Array(id_matrix.get("player_cards", [])).size(), 1)
	assert_eq(Array(id_matrix.get("enemy_cards", [])).size(), 0)
	assert_eq(Array(id_matrix.get("cases", [])).size(), 1)

func test_card_impact_compare_same_same_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_same"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_eq(Array(summary.get("metric_changes", [])).size(), 0)

func test_card_impact_compare_new_fail_is_not_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_fail"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "FAIL", 12)])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_false(bool(summary.get("gate_ok", true)))
	assert_eq(int(summary.get("new_failure_count", 0)), 1)

func test_card_impact_compare_metric_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12)])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 7)])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_gt(Array(summary.get("metric_changes", [])).size(), 0)

func test_card_impact_compare_effect_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_effect_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12, _effect_signature("arcano_choque", 3))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_arcano_choque", "PASS", 12, _effect_signature("arcano_choque", 4))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)
	assert_gt(Array(summary.get("top_effect_delta_cards", [])).size(), 0)

func test_card_impact_compare_non_damage_effect_delta_keeps_gate_ok() -> void:
	var out_dir: String = "user://card_impact/gut_compare_non_damage_effect_delta"
	_write_battle_payload("%s/before/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_esqueleto", "PASS", 12, _summon_effect_signature("necro_esqueleto", 2))])
	_write_battle_payload("%s/after/battle" % out_dir, [_fake_battle_record("card_impact_player_necro_esqueleto", "PASS", 12, _summon_effect_signature("necro_esqueleto", 4))])
	var report: Dictionary = CardImpactRunnerScript.compare_phase(_pack_v2(), {"out": out_dir, "components": PackedStringArray(["battle"]), "command": "unit"})
	var summary: Dictionary = Dictionary(report.get("summary", {}))
	assert_true(bool(summary.get("gate_ok", false)), str(summary.get("blocking_changes", [])))
	assert_gt(Array(summary.get("effect_changes", [])).size(), 0)
	assert_true(Dictionary(summary.get("by_effect_family", {})).has("summon"))

func test_card_impact_reporter_markdown_contains_impact_matrix() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 84,
				"covered_active_cards": 84,
				"expected_player_cards": 54,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"filtered_player_cards": 54,
				"filtered_enemy_cards": 30,
				"player_cards_total": 54,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"top_impacted_cards": [{"card_id": "arcano_choque", "change_count": 1, "metric_change_count": 1, "status_change_count": 0}],
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Impact Matrix")
	assert_string_contains(markdown, "Top Impacted Cards")
	assert_string_contains(markdown, "arcano_choque")

func test_card_impact_reporter_markdown_contains_effect_delta_sections() -> void:
	var report: Dictionary = {
		"phase": "compare",
		"pack_id": "unit_v2",
		"summary": {
			"gate_ok": true,
			"coverage": {
				"expected_active_cards": 84,
				"covered_active_cards": 84,
				"expected_player_cards": 54,
				"expected_enemy_cards": 30,
				"expected_legacy_inactive_cards": 15,
				"filtered_player_cards": 54,
				"filtered_enemy_cards": 30,
				"player_cards_total": 54,
				"enemy_cards_total": 30,
				"legacy_inactive_cards_total": 15
			},
			"structural_errors": [],
			"components": [{"component": "battle", "status": "PASS", "pass_count": 1, "warn_count": 0, "fail_count": 0}],
			"top_impacted_cards": [],
			"top_effect_delta_cards": [{"card_id": "arcano_choque", "change_count": 1}],
			"by_effect_family": {"damage": {"change_count": 1, "fields": {"enemy_hero_damage": 1}}},
			"effect_changes": [{"id": "card_impact_player_arcano_choque", "field": "effect.enemy_hero_damage", "before": 3, "after": 4, "delta": 1}],
			"missing_signatures": [],
			"status_changes": [],
			"metric_changes": [],
			"blocking_changes": []
		}
	}
	var markdown: String = CardImpactReporterScript.markdown(report, {"command": "unit"})
	assert_string_contains(markdown, "Player Effect Deltas")
	assert_string_contains(markdown, "Effect Family Matrix")
	assert_string_contains(markdown, "Non-Damage Coverage Matrix")
	assert_string_contains(markdown, "Support Contamination")
	assert_string_contains(markdown, "Top Effect Delta Cards")

func _pack() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v1")

func _pack_v2() -> Dictionary:
	return CardImpactPackLoaderScript.load_pack("track02_card_impact_v2")

func _single_case(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _single_case_v2(card_id: String) -> Dictionary:
	var matrix: Dictionary = CardImpactMatrixScript.build_matrix(ContentLibrary.get_catalog(), _pack_v2(), PackedStringArray([card_id]))
	assert_true(bool(matrix.get("ok", false)), "; ".join(Array(matrix.get("errors", []))))
	var cases: Array = Array(matrix.get("cases", []))
	assert_eq(cases.size(), 1)
	return Dictionary(cases[0])

func _fake_battle_record(case_id: String, status: String, enemy_hp: int, effect_signature: Dictionary = {}) -> Dictionary:
	return {
		"schema_version": 1,
		"tool": "gameplay_battle_lab",
		"case": {
			"id": case_id,
			"name": case_id
		},
		"result": {
			"case_id": case_id,
			"outcome": "",
			"terminated": false,
			"turn_count": 1,
			"combat_cycles": 1,
			"player_hp": 40,
			"enemy_hp": enemy_hp,
			"cards_played": 1,
			"player_units_alive": 1,
			"enemy_units_alive": 1,
			"damage_to_enemy_hero": 0,
			"damage_to_player_hero": 0,
			"card_effect_signature": effect_signature
		},
		"timeline": [],
		"expectations": [],
		"warnings": [],
		"tags": ["card_impact", "card_under_test"],
		"status": status
	}

func _write_battle_payload(dir_path: String, records: Array) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))
	var file: FileAccess = FileAccess.open("%s/battle_results.json" % dir_path, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(JSON.stringify({"records": records}, "\t"))
	file.close()

func _effect_snapshot(player_hp: int, enemy_hp: int, player_slots: Array, enemy_slots: Array, mana: int = 10, ashes: int = 0, hand_size: int = 3, deck_size: int = 8, discard_size: int = 1, log_count: int = 3) -> Dictionary:
	return {
		"player_health": player_hp,
		"enemy_health": enemy_hp,
		"mana": mana,
		"ashes": ashes,
		"hand_size": hand_size,
		"deck_size": deck_size,
		"discard_size": discard_size,
		"pending_choice_count": 0,
		"log_count": log_count,
		"visual_event_count": 0,
		"player_slots": player_slots,
		"enemy_slots": enemy_slots
	}

func _slot(card_id: String, attack: int, health: int, max_health: int, keywords: Array = [], poison: int = 0, frozen: int = 0, shield: int = 0, slow: int = 0, resistance: int = 0) -> Dictionary:
	return {
		"card_id": card_id,
		"name": card_id,
		"attack": attack,
		"health": health,
		"max_health": max_health,
		"keywords": keywords,
		"poison_amount": poison,
		"frozen_turns": frozen,
		"shield_charges": shield,
		"slow_turns": slow,
		"resistance_amount": resistance,
		"resistance_remaining": resistance
	}

func _effect_signature(card_id: String, enemy_hero_damage: int) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"enemy_hero_damage": enemy_hero_damage,
		"families": ["damage"],
		"keywords_added": {},
		"keywords_removed": {}
	}

func _summon_effect_signature(card_id: String, summoned_attack_total: int) -> Dictionary:
	return {
		"card_id": card_id,
		"present": true,
		"sample_count": 1,
		"summons_created": 1,
		"summoned_count": 1,
		"summoned_attack_total": summoned_attack_total,
		"families": ["summon"],
		"keywords_added": {},
		"keywords_removed": {}
	}
