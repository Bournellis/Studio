extends "res://addons/gut/test.gd"

const CombatBody3D = preload("res://gameplay/combat/combat_body_3d.gd")
const CombatFeedbackLayer = preload("res://presentation/feedback/combat_feedback_layer.gd")

func test_feedback_layer_shows_enemy_health_plate_with_bar_and_counter() -> void:
	var layer: CombatFeedbackLayer = add_child_autofree(CombatFeedbackLayer.new())
	var player: CombatBody3D = add_child_autofree(CombatBody3D.new())
	var enemy: CombatBody3D = add_child_autofree(CombatBody3D.new())
	var camera: Camera3D = add_child_autofree(Camera3D.new())

	player.configure_base(null, 100.0, 5.0)
	enemy.configure_base(null, 80.0, 3.0)
	player.global_position = Vector3.ZERO
	enemy.global_position = Vector3(2.0, 0.0, 0.0)
	camera.position = Vector3(8.0, 10.0, 8.0)
	camera.look_at(Vector3.ZERO, Vector3.UP)

	layer.bind(player, null, null, camera)
	layer.register_combatant(&"enemy", enemy)
	await get_tree().process_frame

	assert_not_null(layer.get_node_or_null("HealthPlateRoot"))
	assert_null(layer.get_node_or_null("HealthPlateRoot/HealthPlate_player"))

	var enemy_plate: PanelContainer = layer.get_node_or_null("HealthPlateRoot/HealthPlate_enemy") as PanelContainer
	assert_not_null(enemy_plate)
	assert_true(enemy_plate.visible)

	var health_bar: ProgressBar = enemy_plate.find_child("HealthBar", true, false) as ProgressBar
	var value_label: Label = enemy_plate.find_child("HealthValueLabel", true, false) as Label
	assert_not_null(health_bar)
	assert_not_null(value_label)
	assert_eq(value_label.text, "80 / 80")
	assert_eq(health_bar.max_value, 80.0)
	assert_eq(health_bar.value, 80.0)

	enemy.take_damage(23.0, &"test")
	await get_tree().process_frame

	assert_eq(value_label.text, "57 / 80")
	assert_eq(health_bar.value, 57.0)

	layer.unregister_combatant(&"enemy")
	await get_tree().process_frame
	assert_null(layer.get_node_or_null("HealthPlateRoot/HealthPlate_enemy"))
	assert_no_new_orphans()
