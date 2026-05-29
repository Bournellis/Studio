extends GutTest

const BattleVisualMockupScript = preload("res://ui/battle_visual_mockup.gd")

func test_battle_visual_mockup_steps_rich_battle_feedback() -> void:
	var visual = BattleVisualMockupScript.new()
	add_child_autofree(visual)
	visual.load_battle_log(_rich_battle_log(), {
		"type": ProjectInfo.FIRST_SLICE_MODE,
		"resources": {"xp": 25, "almas": 3},
	})

	assert_eq(visual.get_event_count(), 16)
	assert_eq(visual.get_current_event_index(), 0)
	assert_string_contains(visual.get_timeline_text(), "Lances:")

	assert_true(visual.step_next_event())
	assert_eq(visual.get_current_event_index(), 1)
	assert_eq(str(visual.debug_snapshot().get("latest_event_type", "")), "battle_start")

	visual.reveal_all()
	var snapshot := visual.debug_snapshot()
	assert_eq(int(snapshot.get("event_index", 0)), visual.get_event_count())
	assert_string_contains(str(snapshot.get("timeline", "")), "conjurou Marca Brasa")
	assert_string_contains(str(snapshot.get("timeline", "")), "usou Pocao de Vida no slot 1: cura gradual por 5s, 4% por pulso")
	assert_string_contains(str(snapshot.get("timeline", "")), "recuperou 8 de vida com Pocao de Vida")
	assert_string_contains(str(snapshot.get("timeline", "")), "Limite da luta")
	var stage := Dictionary(snapshot.get("stage", {}))
	assert_eq(str(stage.get("latest_event_type", "")), "battle_result")
	assert_true(bool(stage.get("has_player_actor", false)))
	var stage_tooltips := Dictionary(stage.get("tooltips", {}))
	assert_string_contains(str(stage_tooltips.get("event", "")), "Resultado")
	assert_false(str(stage_tooltips).to_lower().contains("placeholder"))
	assert_false(visual.debug_has_native_tooltips())

	var player := Dictionary(snapshot.get("player", {}))
	var opponent := Dictionary(snapshot.get("opponent", {}))
	assert_eq(str(player.get("familiar", "")), "corvo_pressagio")
	assert_true(Dictionary(player.get("summons", {})).has("player_brasa_faminta"))
	assert_true(Dictionary(player.get("statuses", {})).has("barreira"))
	assert_true(Dictionary(opponent.get("statuses", {})).has("queimando"))

func test_battle_visual_mockup_empty_state_is_stable() -> void:
	var visual = BattleVisualMockupScript.new()
	add_child_autofree(visual)
	visual.show_empty_state("Nenhuma batalha carregada.")

	assert_eq(visual.get_event_count(), 0)
	assert_eq(visual.get_current_event_index(), 0)
	assert_string_contains(visual.get_timeline_text(), "Nenhuma batalha")

func test_battle_visual_mockup_stage_only_keeps_replay_state_without_outer_panels() -> void:
	var visual = BattleVisualMockupScript.new()
	add_child_autofree(visual)
	visual.set_stage_only_mode(true)
	visual.load_battle_log(_rich_battle_log())

	assert_true(visual.is_stage_only_mode())
	assert_not_null(visual.get_stage_control())
	var header := _find_node_by_name(visual, "BattleVisualHeader") as Control
	var arena_cards := _find_node_by_name(visual, "BattleVisualArenaCards") as Control
	var timeline := _find_node_by_name(visual, "BattleVisualTimelinePanel") as Control
	assert_not_null(header)
	assert_not_null(arena_cards)
	assert_not_null(timeline)
	assert_false(header.visible)
	assert_false(arena_cards.visible)
	assert_false(timeline.visible)
	assert_true(visual.step_next_event())
	assert_string_contains(visual.get_timeline_text(), "Batalha iniciada")
	var snapshot := visual.debug_snapshot()
	var stage := Dictionary(snapshot.get("stage", {}))
	assert_true(bool(stage.get("has_player_actor", false)))

func test_battle_visual_mockup_updates_cooldown_against_continuous_replay_time() -> void:
	var visual = BattleVisualMockupScript.new()
	add_child_autofree(visual)
	visual.load_battle_log(_rich_battle_log())

	assert_true(visual.step_next_event())
	assert_true(visual.step_next_event())
	assert_true(visual.step_next_event())
	visual.set_replay_time(3.5)

	var snapshot := Dictionary(visual.debug_snapshot())
	var stage := Dictionary(snapshot.get("stage", {}))
	var cooldown_counts := Dictionary(stage.get("cooldown_counts", {}))
	var tooltips := Dictionary(stage.get("tooltips", {}))
	var cooldown_tooltip_text := _joined_tooltips(Array(tooltips.get("cooldowns", [])))
	assert_eq(float(snapshot.get("replay_time", 0.0)), 3.5)
	assert_true(Array(cooldown_counts.get("player", [])).has("4s"))
	assert_string_contains(cooldown_tooltip_text, "Tempo da luta: 3.5s")
	assert_string_contains(cooldown_tooltip_text, "Restante: 4s")

func _rich_battle_log() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "visual-test",
		"seed": "visual-test-seed",
		"mode": ProjectInfo.FIRST_SLICE_MODE,
		"duration": 31.0,
		"participants": {
			"player": {"id": "player-test", "display_name": "Draxos Teste"},
			"opponent": {"id": "bot-test", "display_name": "Bot Teste", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "combatant_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 0.2, "seq": 2, "type": "mana_change", "source": "player", "target": "player", "mana_after": 18},
			{"t": 0.3, "seq": 3, "type": "cooldown_start", "source": "player", "target": "player", "spell_id": "marca_brasa", "ready_at": 7.5},
			{"t": 0.4, "seq": 4, "type": "weapon_attack", "source": "opponent", "target": "player", "damage": 12, "damage_type": "terra", "hp_after": 188},
			{"t": 0.6, "seq": 5, "type": "spell_cast", "source": "player", "target": "opponent", "spell_id": "marca_brasa", "damage": 28, "damage_type": "fogo", "hp_after": 172},
			{"t": 0.7, "seq": 6, "type": "dot_apply", "source": "player", "target": "opponent", "status_id": "queimando", "stacks": 1, "duration": 5},
			{"t": 1.5, "seq": 7, "type": "dot_tick", "source": "player", "target": "opponent", "status_id": "queimando", "damage": 6, "damage_type": "fogo", "hp_after": 166},
			{"t": 2.0, "seq": 8, "type": "status_apply", "source": "opponent", "target": "player", "status_id": "lento", "stacks": 1, "duration": 4},
			{"t": 2.5, "seq": 9, "type": "barrier_gain", "source": "player", "target": "player", "spell_id": "coagulo_negro", "amount": 24, "barrier_after": 24},
			{"t": 3.0, "seq": 10, "type": "summon_spawn", "source": "player", "target": "player_brasa_faminta", "spell_id": "invocar_brasa_faminta", "hp": 50, "damage_type": "fogo"},
			{"t": 4.0, "seq": 11, "type": "summon_attack", "source": "player_brasa_faminta", "target": "opponent", "damage": 9, "damage_type": "fogo", "hp_after": 157},
			{"t": 5.0, "seq": 12, "type": "pet_attack", "source": "player", "target": "opponent", "pet_id": "corvo_pressagio", "damage": 13, "damage_type": "morte", "hp_after": 144},
			{"t": 5.25, "seq": 13, "type": "consumable_use", "source": "player", "target": "player", "item_id": "pocao_vida", "slot_index": 1, "effect_id": "heal_over_time", "duration": 5, "tick_percent": 4},
			{"t": 5.5, "seq": 14, "type": "heal", "source": "player", "target": "player", "item_id": "pocao_vida", "effect_id": "heal_over_time", "amount": 8, "hp_after": 196, "max_hp": 200, "ticks_remaining": 4},
			{"t": 30.0, "seq": 15, "type": "anti_stall", "source": "system", "target": "none", "player_hp_after": 90, "opponent_hp_after": 42},
			{"t": 31.0, "seq": 16, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "combatant_defeated"},
		],
	}

func _joined_tooltips(values: Array) -> String:
	var lines := PackedStringArray()
	for value: Variant in values:
		lines.append(str(value))
	return "\n".join(lines)

func _find_node_by_name(root: Node, node_name: String) -> Node:
	if root == null:
		return null
	if root.name == node_name:
		return root
	for child: Node in root.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null
