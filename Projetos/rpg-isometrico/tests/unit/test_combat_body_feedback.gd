extends "res://addons/gut/test.gd"

const CombatBody3D = preload("res://gameplay/combat/combat_body_3d.gd")

func test_combat_body_emits_impact_feedback_and_motion_pause_on_damage() -> void:
	var body: CombatBody3D = add_child_autofree(CombatBody3D.new())
	body.configure_base(null, 100.0, 5.0)

	var impact_payloads: Array[Dictionary] = []
	body.impact_registered.connect(func(health_damage: float, absorbed_amount: float, is_lethal: bool) -> void:
		impact_payloads.append({
			"health_damage": health_damage,
			"absorbed_amount": absorbed_amount,
			"is_lethal": is_lethal
		})
	)

	body.request_motion_pause(0.03)
	assert_true(body.is_motion_paused())

	body.take_damage(18.0, &"bot")

	assert_true(body.damage_flash_remaining > 0.0)
	assert_true(body.impact_pulse_remaining > 0.0)
	assert_eq(impact_payloads.size(), 1)
	assert_eq(float(impact_payloads[0].get("health_damage", 0.0)), 18.0)
	assert_false(bool(impact_payloads[0].get("is_lethal", true)))
	assert_not_null(body.get_node_or_null("ImpactHalo"))
