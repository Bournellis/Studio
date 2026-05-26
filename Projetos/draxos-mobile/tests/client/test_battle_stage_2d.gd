extends GutTest

const BattleStage2DScript = preload("res://ui/battle_stage_2d.gd")

func test_battle_stage_2d_renders_procedural_actor_slots() -> void:
	var stage = BattleStage2DScript.new()
	stage.custom_minimum_size = Vector2(820, 380)
	add_child_autofree(stage)
	stage.render_snapshot(_side_state(), {"type": "spell_cast", "source": "player", "target": "opponent", "damage": 27, "damage_type": "fogo", "seq": 1, "t": 1.0}, 1, 4, false)

	var snapshot: Dictionary = stage.debug_snapshot()
	assert_eq(str(snapshot.get("latest_event_type", "")), "spell_cast")
	assert_eq(int(snapshot.get("slot_count", 0)), 3)
	assert_true(bool(snapshot.get("has_player_actor", false)))
	assert_true(bool(snapshot.get("has_opponent_actor", false)))

func test_battle_stage_2d_tooltips_remain_available_during_effects() -> void:
	var stage = BattleStage2DScript.new()
	stage.size = Vector2(360, 380)
	add_child_autofree(stage)
	stage.render_snapshot(_side_state(), {"type": "spell_cast", "source": "player", "target": "opponent", "spell_id": "marca_brasa", "damage": 27, "damage_type": "fogo", "hp_after": 117, "seq": 2, "t": 1.4}, 2, 8, true)

	var snapshot: Dictionary = stage.debug_snapshot()
	var tooltips := Dictionary(snapshot.get("tooltips", {}))
	assert_true(stage.custom_minimum_size.x <= 360.0)
	assert_true(int(snapshot.get("effect_count", 0)) > 0)
	assert_string_contains(str(tooltips.get("event", "")), "Spell conjurada")
	assert_string_contains(_joined_tooltips(Array(tooltips.get("slots", []))), "Familiar")
	assert_string_contains(_joined_tooltips(Array(tooltips.get("slots", []))), "Summon")
	assert_string_contains(_joined_tooltips(Array(tooltips.get("status", []))), "Status ativo")
	assert_string_contains(_joined_tooltips(Array(tooltips.get("cooldowns", []))), "Cooldown de spell")
	assert_false(str(tooltips).to_lower().contains("placeholder"))

func test_battle_stage_2d_keeps_tooltip_nodes_stable_between_replay_steps() -> void:
	var stage = BattleStage2DScript.new()
	stage.custom_minimum_size = Vector2(820, 380)
	add_child_autofree(stage)
	stage.render_snapshot(_side_state(), {"type": "spell_cast", "source": "player", "target": "opponent", "spell_id": "marca_brasa", "damage": 27, "damage_type": "fogo", "seq": 1, "t": 1.0}, 1, 4, false)
	var before_ids := Dictionary(stage.debug_snapshot().get("tooltip_node_ids", {}))

	stage.render_snapshot(_side_state(), {"type": "dot_tick", "source": "player", "target": "opponent", "status_id": "queimando", "damage": 6, "damage_type": "fogo", "seq": 2, "t": 1.5}, 2, 4, false)
	var after_ids := Dictionary(stage.debug_snapshot().get("tooltip_node_ids", {}))

	assert_eq(Array(before_ids.get("slots", [])), Array(after_ids.get("slots", [])))
	assert_eq(Array(before_ids.get("status", [])), Array(after_ids.get("status", [])))
	assert_eq(Array(before_ids.get("cooldowns", [])), Array(after_ids.get("cooldowns", [])))

func test_battle_stage_2d_cooldown_timer_uses_remaining_replay_time() -> void:
	var stage = BattleStage2DScript.new()
	stage.custom_minimum_size = Vector2(820, 380)
	add_child_autofree(stage)
	stage.render_snapshot(_side_state(), {"type": "dot_tick", "source": "player", "target": "opponent", "status_id": "queimando", "damage": 6, "damage_type": "fogo", "seq": 3, "t": 2.5}, 3, 8, false)

	var snapshot := Dictionary(stage.debug_snapshot())
	var cooldown_counts := Dictionary(snapshot.get("cooldown_counts", {}))
	var tooltips := Dictionary(snapshot.get("tooltips", {}))
	var cooldown_tooltip_text := _joined_tooltips(Array(tooltips.get("cooldowns", [])))
	assert_true(Array(cooldown_counts.get("player", [])).has("5s"))
	assert_string_contains(cooldown_tooltip_text, "Restante: 5s")
	assert_string_contains(cooldown_tooltip_text, "Pronta em: 7.5s")

	stage.render_snapshot(_side_state(), {"type": "dot_tick", "source": "player", "target": "opponent", "status_id": "queimando", "damage": 6, "damage_type": "fogo", "seq": 3, "t": 2.5}, 3, 8, false, 3.5)
	snapshot = Dictionary(stage.debug_snapshot())
	cooldown_counts = Dictionary(snapshot.get("cooldown_counts", {}))
	tooltips = Dictionary(snapshot.get("tooltips", {}))
	cooldown_tooltip_text = _joined_tooltips(Array(tooltips.get("cooldowns", [])))
	assert_eq(float(snapshot.get("replay_time", 0.0)), 3.5)
	assert_true(Array(cooldown_counts.get("player", [])).has("4s"))
	assert_string_contains(cooldown_tooltip_text, "Tempo atual do replay: 3.5s")
	assert_string_contains(cooldown_tooltip_text, "Restante: 4s")

func test_battle_stage_2d_effect_feedback_uses_full_names() -> void:
	var stage = BattleStage2DScript.new()
	add_child_autofree(stage)

	var spell_text := stage.debug_event_feedback_text({"type": "spell_cast", "spell_id": "marca_brasa", "damage": 27})
	var status_text := stage.debug_event_feedback_text({"type": "status_apply", "status_id": "lento"})
	var mana_text := stage.debug_event_feedback_text({"type": "mana_change", "mana_after": 12})

	assert_string_contains(spell_text, "Marca Brasa")
	assert_string_contains(spell_text, "-27")
	assert_eq(status_text, "Status aplicado: Lento")
	assert_eq(mana_text, "Mana: 12")
	assert_false(spell_text.contains("SP"))
	assert_false(status_text.contains("STS"))
	assert_false(mana_text.contains("EVT"))

func test_battle_stage_2d_empty_state_is_stable() -> void:
	var stage = BattleStage2DScript.new()
	add_child_autofree(stage)
	stage.show_empty_state("Sem replay.")

	var snapshot: Dictionary = stage.debug_snapshot()
	assert_eq(int(snapshot.get("event_count", -1)), 0)
	assert_eq(str(snapshot.get("latest_event_type", "x")), "")

func _side_state() -> Dictionary:
	return {
		"player": {
			"display_name": "Draxos Teste",
			"hp": 180,
			"max_hp": 200,
			"mana": 14,
			"max_mana": 20,
			"barrier": 18,
			"statuses": {"barreira": {"stacks": 1}},
			"cooldowns": {"marca_brasa": 7.5},
			"familiar": "corvo_pressagio",
			"summons": {
				"player_brasa_faminta": {"slot": "front", "damage_type": "fogo"},
				"player_ossos": {"slot": "middle", "damage_type": "morte"},
			},
		},
		"opponent": {
			"display_name": "Bot Teste",
			"hp": 144,
			"max_hp": 200,
			"mana": 9,
			"max_mana": 20,
			"barrier": 0,
			"statuses": {"queimando": {"stacks": 2}},
			"cooldowns": {},
			"familiar": "",
			"summons": {},
		},
	}

func _joined_tooltips(values: Array) -> String:
	var lines := PackedStringArray()
	for value: Variant in values:
		lines.append(str(value))
	return "\n".join(lines)
