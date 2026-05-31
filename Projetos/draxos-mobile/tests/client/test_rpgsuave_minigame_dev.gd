extends GutTest

const ModelScript := preload("res://dev/minigames/rpgsuave/rpgsuave_forest_model.gd")
const RegistryScript := preload("res://modes/boot/ui/minigame_shell_registry.gd")

func test_rpgsuave_registry_points_to_dev_screen() -> void:
	assert_true(RegistryScript.is_registered("rpgsuave"))
	assert_eq(RegistryScript.normalize_mode_id("rpgsuave_bosque"), "rpgsuave")
	assert_eq(RegistryScript.screen_path("rpgsuave"), "res://dev/minigames/rpgsuave/rpgsuave_forest_screen.gd")

func test_collection_cancels_when_player_moves() -> void:
	var model = ModelScript.new()
	var start := model.start_collection("galho")
	assert_true(bool(start.get("ok", false)))
	var cancel := model.advance_collection(0.2, true)
	assert_true(bool(cancel.get("cancelled", false)))
	assert_true(model.active_collection.is_empty())

func test_pocket_full_blocks_collection() -> void:
	var model = ModelScript.new()
	for _index in 20:
		model.add_to_pocket("pedra_pequena")
	assert_gt(model.pocket_weight(), model.capacity() - 0.1)
	var result := model.start_collection("pedra")
	assert_false(bool(result.get("ok", true)))
	assert_eq(result.get("reason"), "pocket_full")

func test_deposit_moves_pocket_to_chest() -> void:
	var model = ModelScript.new()
	model.add_to_pocket("galho", 2)
	model.add_to_pocket("folha", 3)
	var result := model.deposit_all()
	assert_true(bool(result.get("ok", false)))
	assert_true(model.pocket.is_empty())
	assert_eq(int(model.chest.get("galho", 0)), 2)
	assert_eq(int(model.chest.get("folha", 0)), 3)

func test_crafting_consumes_local_materials_and_sets_upgrade() -> void:
	var model = ModelScript.new()
	model.chest = {"galho": 4, "folha": 3, "resina": 1}
	assert_true(model.can_craft("bolsa_simples_1"))
	var result := model.craft("bolsa_simples_1")
	assert_true(bool(result.get("ok", false)))
	assert_true(model.has_upgrade("bolsa_simples_1"))
	assert_eq(model.capacity(), 25.0)
	assert_eq(int(model.chest.get("galho", 0)), 0)

func test_result_payload_is_preview_local_only() -> void:
	var model = ModelScript.new()
	model.chest = {"galho": 3, "cinzas_preview": 2}
	var payload := model.result_payload(12.5)
	assert_eq(payload.get("mode_id"), "rpgsuave")
	assert_eq(payload.get("ruleset_id"), "rpgsuave_forest_ruleset_v0")
	assert_true(int(payload.get("activity_score", 0)) > 0)
	assert_true(Dictionary(payload.get("deposited_items", {})).has("cinzas_preview"))
