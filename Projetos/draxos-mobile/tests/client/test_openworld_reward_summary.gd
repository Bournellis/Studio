extends GutTest

const RewardSummary := preload("res://modes/openworld/openworld_reward_summary.gd")

class VisitSummaryModel:
	extends RefCounted

	func visit_summary_text(seconds: float, reward_text: String) -> String:
		return "Resumo %.1fs | %s" % [seconds, reward_text]

func test_summary_formats_sorted_resource_delta_with_model_copy() -> void:
	var text := RewardSummary.summary(
		{"session": {"session_seconds": 12}},
		{"resource_delta": {"wood": 2, "bone_dust": 1}},
		VisitSummaryModel.new(),
		0.0
	)

	assert_string_contains(text, "Resumo 12.0s")
	assert_string_contains(text, "Madeira +2")
	assert_string_contains(text, "Po de Osso +1")

func test_summary_handles_cap_zero_and_empty_reward_without_model() -> void:
	assert_eq(
		RewardSummary.summary({"cap_zero": true}, {}, null, 9.0),
		"Visita encerrada. Limite diario atingido; sem recompensa nova."
	)
	assert_eq(
		RewardSummary.summary({}, {}, null, 9.0),
		"Visita encerrada. Nenhuma recompensa nova."
	)

func test_status_and_period_key_prefer_body_before_reward_payload() -> void:
	assert_eq(RewardSummary.status({"reward_status": "cap_zero"}, {"reward_status": "applied"}), "cap_zero")
	assert_eq(RewardSummary.period_key({"period_key": "daily-a"}, {"period_key": "daily-b"}), "daily-a")
	assert_true(RewardSummary.is_cap_zero_completion({}, {"reward_status": "cap_zero"}))
