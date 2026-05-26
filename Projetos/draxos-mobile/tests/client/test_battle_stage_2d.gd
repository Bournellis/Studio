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
