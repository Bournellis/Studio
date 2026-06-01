extends GutTest

const ModelScript := preload("res://modes/openworld/openworld_forest_model.gd")
const ScreenScript := preload("res://modes/openworld/openworld_forest_screen.gd")
const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")
const RouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")

func test_openworld_registry_points_to_official_screen() -> void:
	assert_true(RegistryScript.is_registered("openworld"))
	assert_eq(RegistryScript.normalize_mode_id("openworld_bosque"), "openworld")
	assert_eq(RegistryScript.screen_path("openworld"), "res://modes/openworld/openworld_forest_screen.gd")

func test_mode_shell_is_fullscreen_without_app_chrome() -> void:
	assert_true(RouteContractScript.is_fullscreen_gameplay("mode_shell"))
	assert_false(RouteContractScript.shows_app_chrome("mode_shell"))

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
	assert_eq(payload.get("mode_id"), "openworld")
	assert_eq(payload.get("ruleset_id"), "openworld_forest_ruleset_v0")
	assert_true(int(payload.get("activity_score", 0)) > 0)
	assert_true(Dictionary(payload.get("deposited_items", {})).has("cinzas_preview"))

func test_visual_screen_instantiates_fullscreen_with_joystick_hud_and_sheet() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	assert_eq(screen.name, "OpenworldForestScreen")
	assert_not_null(screen.find_child("OpenworldForestWorldView", true, false))
	assert_not_null(screen.find_child("OpenworldVirtualJoystick", true, false))
	assert_not_null(screen.find_child("OpenworldHudTop", true, false))
	assert_not_null(screen.find_child("OpenworldInventoryButton", true, false))
	assert_not_null(screen.find_child("OpenworldBackButton", true, false))
	assert_null(screen.find_child("OpenworldForestBoard", true, false))

func test_visual_screen_debug_joystick_moves_player_for_smoke_tests() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var before := screen.get_player_position()
	screen.set_debug_joystick_vector(Vector2.RIGHT)
	await wait_seconds(0.12)
	screen.set_debug_joystick_vector(Vector2.ZERO)
	assert_gt(screen.get_player_position().x, before.x)

func test_technical_details_start_hidden_in_inventory_sheet() -> void:
	var screen = ScreenScript.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	var inventory := screen.find_child("OpenworldInventoryButton", true, false) as Button
	assert_not_null(inventory)
	inventory.pressed.emit()
	await get_tree().process_frame
	assert_not_null(screen.find_child("OpenworldInventorySheet", true, false))
	assert_null(screen.find_child("OpenworldTechnicalDetails", true, false))
