extends "res://addons/gut/test.gd"

const SimpleBotController = preload("res://gameplay/bot/simple_bot_controller.gd")

class DummyTarget extends Node3D:
	var is_dead: bool = false

func test_bot_intent_reports_chase_windup_and_reposition_states() -> void:
	var bot: SimpleBotController = add_child_autofree(SimpleBotController.new())
	var target: DummyTarget = add_child_autofree(DummyTarget.new())
	target.position = Vector3(5.0, 0.0, 0.0)
	bot.position = Vector3.ZERO
	bot.configure(null, target)

	assert_eq(bot.get_intent_label(), "perseguindo")

	bot.attack_windup_remaining = 0.2
	assert_string_contains(bot.get_intent_label(), "golpe em")

	bot.attack_windup_remaining = 0.0
	target.position = Vector3(1.3, 0.0, 0.0)
	bot.reposition_time_remaining = 0.4
	assert_eq(bot.get_intent_label(), "reposicionando")
