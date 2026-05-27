extends "res://tests/unit/draxos_test_base.gd"

const RoutePacingSimulatorScript = preload("res://tools/route_pacing_simulator.gd")
const SMOKE_SEED: int = 20260518
const METRIC_SCHEMA: PackedStringArray = [
	"class_id",
	"seed",
	"ok",
	"message",
	"map_count",
	"completed_maps",
	"estimated_turns",
	"hp_loss",
	"final_hp",
	"max_hp",
	"souls_earned",
	"souls_spent",
	"souls_left",
	"deck_size",
	"relic_count",
	"shop_usage",
	"deaths",
	"shop_actions"
]

func test_route_pacing_simulator_preserves_arcano_validation_smoke() -> void:
	var simulator = RoutePacingSimulatorScript.new()
	var metrics: Dictionary = simulator.simulate_route(RunSession, ContentLibrary.get_catalog(), "arcano", SMOKE_SEED)
	for field: String in METRIC_SCHEMA:
		assert_true(metrics.has(field), "Missing pacing metric field %s." % field)
	assert_true(bool(metrics.get("ok", false)), str(metrics.get("message", "")))
	assert_eq(str(metrics.get("class_id", "")), "arcano")
	assert_eq(int(metrics.get("seed", 0)), SMOKE_SEED)
	assert_eq(int(metrics.get("map_count", 0)), 29)
	assert_eq(int(metrics.get("completed_maps", 0)), 29)
	assert_eq(int(metrics.get("estimated_turns", 0)), 217)
	assert_eq(int(metrics.get("hp_loss", 0)), 116)
	assert_eq(int(metrics.get("final_hp", 0)), 13)
	assert_eq(int(metrics.get("max_hp", 0)), 46)
	assert_eq(int(metrics.get("souls_earned", 0)), 362)
	assert_eq(int(metrics.get("souls_spent", 0)), 291)
	assert_eq(int(metrics.get("souls_left", 0)), 71)
	assert_eq(int(metrics.get("deck_size", 0)), 38)
	assert_eq(int(metrics.get("relic_count", 0)), 6)
	assert_eq(int(metrics.get("shop_usage", 0)), 21)
	assert_eq(int(metrics.get("deaths", 0)), 0)
	assert_eq(Array(metrics.get("shop_actions", [])).size(), 21)
	var acceptance: Dictionary = simulator.acceptance_for(metrics)
	assert_true(bool(acceptance.get("ok", false)), str(acceptance.get("message", "")))
	assert_string_contains(simulator.format_metrics(metrics), "maps=29/29 turns_est=217")
	assert_false(RunSession.active)

func test_route_pacing_simulator_completes_all_track02_classes() -> void:
	var expectations: Dictionary = {
		"arcano": {"final_hp": 13, "max_hp": 46, "deck_size": 38},
		"invocador": {"final_hp": 16, "max_hp": 49, "deck_size": 37},
		"necromante": {"final_hp": 13, "max_hp": 46, "deck_size": 38}
	}
	var simulator = RoutePacingSimulatorScript.new()
	for class_id: String in expectations.keys():
		var metrics: Dictionary = simulator.simulate_route(RunSession, ContentLibrary.get_catalog(), class_id, SMOKE_SEED)
		var expected: Dictionary = Dictionary(expectations.get(class_id, {}))
		assert_true(bool(metrics.get("ok", false)), "%s failed: %s" % [class_id, str(metrics.get("message", ""))])
		assert_eq(int(metrics.get("completed_maps", 0)), 29)
		assert_eq(int(metrics.get("estimated_turns", 0)), 217)
		assert_eq(int(metrics.get("final_hp", 0)), int(expected.get("final_hp", 0)))
		assert_eq(int(metrics.get("max_hp", 0)), int(expected.get("max_hp", 0)))
		assert_eq(int(metrics.get("deck_size", 0)), int(expected.get("deck_size", 0)))
		assert_eq(int(metrics.get("relic_count", 0)), 6)
		assert_eq(int(metrics.get("shop_usage", 0)), 21)
		assert_eq(int(metrics.get("deaths", 0)), 0)
		assert_true(bool(simulator.acceptance_for(metrics).get("ok", false)))
