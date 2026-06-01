extends GutTest

const OperationStateScript := preload("res://modes/boot/ui/operation_state.gd")
const AppShellActionRouterScript := preload("res://modes/boot/ui/app_shell_action_router.gd")
const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

func test_operation_state_tracks_busy_by_scope() -> void:
	var state = OperationStateScript.new()
	assert_false(state.any_busy())

	var account_token := state.begin_busy("account", AppShellActionContractScript.ACTION_REFRESH_SESSION)
	var battle_token := state.begin_busy("battle", AppShellActionContractScript.ACTION_REQUEST_BATTLE)

	assert_true(state.any_busy())
	assert_true(state.is_busy("account"))
	assert_true(state.is_busy("battle"))
	assert_false(state.is_busy("shop"))
	assert_eq(state.busy_action("account"), AppShellActionContractScript.ACTION_REFRESH_SESSION)
	assert_eq(Array(state.busy_scopes()), ["account", "battle"])

	assert_true(state.complete_busy("account", account_token))
	assert_false(state.is_busy("account"))
	assert_true(state.is_busy("battle"))
	assert_true(state.complete_busy("battle", battle_token))
	assert_false(state.any_busy())

func test_operation_state_lifecycle_tokens_reject_stale_completion() -> void:
	var state = OperationStateScript.new()
	var old_token := state.begin_busy("surface", AppShellActionContractScript.ACTION_SHOW_BASE)
	var current_token := state.begin_busy("surface", AppShellActionContractScript.ACTION_SHOW_SOCIAL)

	assert_false(state.is_current_lifecycle_token(old_token))
	assert_true(state.is_current_lifecycle_token(current_token))
	assert_false(state.complete_busy("surface", old_token))
	assert_true(state.is_busy("surface"))
	assert_true(state.complete_busy("surface", current_token))
	assert_false(state.is_busy("surface"))

func test_operation_state_stores_errors_by_action_without_shared_mutation() -> void:
	var state = OperationStateScript.new()
	var stored := state.set_action_error(AppShellActionContractScript.ACTION_SHOW_SHOP, {
		"code": "NETWORK_UNAVAILABLE",
		"message": "Offline.",
	})
	stored["code"] = "MUTATED"

	assert_true(state.has_action_error(AppShellActionContractScript.ACTION_SHOW_SHOP))
	assert_eq(
		state.action_error(AppShellActionContractScript.ACTION_SHOW_SHOP).get("code"),
		"NETWORK_UNAVAILABLE"
	)
	assert_eq(
		state.action_error(AppShellActionContractScript.ACTION_SHOW_SHOP).get("action_id"),
		AppShellActionContractScript.ACTION_SHOW_SHOP
	)
	assert_true(state.clear_action_error(" show_shop "))
	assert_false(state.has_action_error(AppShellActionContractScript.ACTION_SHOW_SHOP))

func test_action_router_wraps_contract_payload_and_update_gate() -> void:
	var context := {
		"screen": "refuge",
		"save_type": "normal",
		"has_account": true,
		"offline": false,
		"update_gate": {"block_online": true},
		"replay_running": false,
	}

	var shop_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.ACTION_SHOW_SHOP,
		context
	)
	assert_eq(shop_route.get("category"), AppShellActionRouterScript.CATEGORY_SHOP)
	assert_eq(shop_route.get("scope_id"), "monetization:normal")
	assert_eq(shop_route.get("mutation_endpoint"), "")
	assert_false(bool(shop_route.get("requires_idempotent_retry", true)))
	assert_true(bool(shop_route.get("blocked_by_update", false)))
	assert_eq(Dictionary(shop_route.get("payload", {})), {
		"action_id": AppShellActionContractScript.ACTION_SHOW_SHOP,
		"screen": "refuge",
		"save_type": "normal",
		"has_account": true,
		"offline": false,
	})

	var update_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.ACTION_CHECK_UPDATE,
		context
	)
	assert_eq(update_route.get("category"), AppShellActionRouterScript.CATEGORY_SESSION)
	assert_false(bool(update_route.get("blocked_by_update", true)))

func test_action_router_classifies_dynamic_contract_actions() -> void:
	var select_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.select_base_structure_action("nucleo_energia"),
		{"update_gate": {"block_online": true}}
	)
	assert_eq(select_route.get("category"), AppShellActionRouterScript.CATEGORY_BASE)
	assert_eq(select_route.get("value"), "nucleo_energia")
	assert_false(bool(select_route.get("blocked_by_update", true)))

	var equip_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.equip_spell_position_action(2, "incisao_ritual")
	)
	assert_eq(equip_route.get("category"), AppShellActionRouterScript.CATEGORY_PREPARATION)
	assert_eq(equip_route.get("value"), "2")
	assert_eq(equip_route.get("secondary_value"), "incisao_ritual")
	assert_true(bool(equip_route.get("build_equip", false)))

	var replay_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.battle_replay_action("battle-123")
	)
	assert_eq(replay_route.get("category"), AppShellActionRouterScript.CATEGORY_BATTLE)
	assert_true(bool(replay_route.get("read_only_battle", false)))
	assert_true(AppShellActionRouterScript.can_route(replay_route.get("action_id")))
	assert_false(AppShellActionRouterScript.can_route("unknown_action"))

func test_action_router_exposes_mutation_scope_and_minigame_placeholder() -> void:
	var battle_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.ACTION_REQUEST_BATTLE,
		{"save_type": "progression_lab"}
	)
	assert_eq(battle_route.get("scope_id"), "battle:progression_lab")
	assert_eq(battle_route.get("mutation_endpoint"), "battle/request")
	assert_true(bool(battle_route.get("requires_idempotent_retry", false)))

	var minigame_route := AppShellActionRouterScript.route_action(
		AppShellActionContractScript.open_minigame_shell_action("rpgsuave"),
		{"save_type": "normal"}
	)
	assert_eq(minigame_route.get("category"), AppShellActionRouterScript.CATEGORY_MINIGAME)
	assert_eq(minigame_route.get("scope_id"), "minigame:rpgsuave:normal")
	assert_eq(minigame_route.get("mutation_endpoint"), "")
	assert_false(bool(minigame_route.get("blocked_by_update", true)))
