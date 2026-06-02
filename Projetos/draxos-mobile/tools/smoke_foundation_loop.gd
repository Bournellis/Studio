extends SceneTree

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const SessionStoreScript := preload("res://online/session_store.gd")
const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()
var _store = null

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code := await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	root.size = Vector2i(390, 844)
	await process_frame
	var boot := _new_boot()
	if boot == null:
		return 1
	_store = root.get_node("/root/SessionStore")
	await process_frame

	_prepare_foundation_state()
	boot.call("_show_screen", "refuge", false)
	await process_frame
	_expect_cta(boot, "Ver recompensa", AppShellActionContractScript.ACTION_SHOW_LATEST_BATTLE)
	_expect_clean_refuge_shell(boot)

	_store.mark_battle_result_seen()
	boot.call("_show_screen", "refuge", false)
	await process_frame
	_expect_cta(boot, "Coletar", AppShellActionContractScript.ACTION_COLLECT_BASE)
	_expect_clean_refuge_shell(boot)

	_store.base_state = _base_state_without_collect()
	_remember_surface(SessionStoreScript.SURFACE_BASE)
	boot.call("_show_screen", "refuge", false)
	await process_frame
	_expect_cta(boot, "Evoluir", AppShellActionContractScript.upgrade_base_structure_action("nucleo_energia"))
	_expect_clean_refuge_shell(boot)

	_store.base_state = {}
	_store.surface_save_types.erase(SessionStoreScript.SURFACE_BASE)
	boot.call("_show_screen", "refuge", false)
	await process_frame
	_expect_cta(boot, "Arena PVE", AppShellActionContractScript.ACTION_OPEN_ARENA)
	_expect_clean_refuge_shell(boot)

	_prepare_foundation_state()
	boot.call("_show_screen", "battle_summary", false)
	await process_frame
	_expect(_find_button_by_text(boot, "Voltar e verificar base") != null, "battle summary returns to base loop")
	_expect_tree_contains(boot, "Proximo passo", "battle summary explains the next step")
	boot.call("_return_to_refuge")
	await process_frame
	_expect(_store.last_battle_result_seen, "return to Refugio marks reward as seen")
	_expect_cta(boot, "Coletar", AppShellActionContractScript.ACTION_COLLECT_BASE)
	_expect_clean_refuge_shell(boot)

	boot.queue_free()
	await process_frame
	if _failures.is_empty():
		print("[smoke-foundation-loop] OK")
		return 0
	for failure: String in _failures:
		printerr("[smoke-foundation-loop] %s" % failure)
	return 1

func _prepare_foundation_state() -> void:
	_store.clear_session()
	_store.access_token = "foundation-loop-token"
	_store.expires_at = int(Time.get_unix_time_from_system()) + 3600
	_store.player = {"id": "player-loop", "level": 8, "power": 120, "username": "loop_tester"}
	_store.resources = {"almas": 100, "energia": 200, "ossos": 3, "diamante": 160}
	_store.build = {"weapon_id": "varinha_cinzas"}
	_store.base_state = _base_state_fixture()
	_remember_surface(SessionStoreScript.SURFACE_ACCOUNT)
	_remember_surface(SessionStoreScript.SURFACE_BASE)
	var applied: bool = _store.apply_battle_result({
		"ok": true,
		"_client": {"save_type": _store.active_save_type},
		"battle_log": _battle_log_fixture(),
		"rewards": _battle_rewards_fixture(),
	})
	_expect(applied, "battle result fixture applies")
	_expect(_store.has_unseen_battle_result(), "fresh battle result is unseen")

func _remember_surface(surface: String) -> void:
	_store.surface_save_types[surface] = _store.active_save_type

func _expect_cta(root_node: Node, expected_text: String, expected_action_id: String) -> void:
	var cta := _find_node_by_name(root_node, "RefugeContextCta") as Button
	_expect(cta != null, "RefugeContextCta exists")
	if cta == null:
		return
	_expect(cta.text == expected_text, "CTA text expected '%s', got '%s'" % [expected_text, cta.text])
	var buttons := _as_dictionary(root_node.get("_action_buttons"))
	_expect(buttons.has(expected_action_id), "CTA action registered: %s" % expected_action_id)

func _expect_clean_refuge_shell(root_node: Node) -> void:
	_expect(_find_node_by_name(root_node, "RefugeAltarStage") == null, "Refugio has no altar stage")
	_expect(_find_node_by_name(root_node, "RefugeLoopPanel") == null, "Refugio has no persistent loop panel")
	_expect(_find_node_by_name(root_node, "RefugeProgressionPanel") == null, "Refugio has no persistent progression panel")
	_expect(_find_node_by_name(root_node, "RefugeFooterPanel") != null, "Refugio keeps hidden feedback footer")

func _expect_tree_contains(root_node: Node, expected: String, message: String) -> void:
	_expect(_text_tree_contains(root_node, expected), "%s: '%s'" % [message, expected])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _new_boot() -> Control:
	var boot_script: Script = load(BOOT_SCREEN_PATH)
	if boot_script == null or not boot_script.can_instantiate():
		_failures.append("Boot screen script failed to load")
		return null
	var boot: Control = boot_script.new()
	root.add_child(boot)
	return boot

func _find_node_by_name(root_node: Node, node_name: String) -> Node:
	if root_node == null:
		return null
	if root_node.name == node_name:
		return root_node
	for child: Node in root_node.get_children():
		var found := _find_node_by_name(child, node_name)
		if found != null:
			return found
	return null

func _find_button_by_text(root_node: Node, text: String) -> Button:
	if root_node == null:
		return null
	if root_node is Button and str((root_node as Button).text) == text:
		return root_node as Button
	for child: Node in root_node.get_children():
		var found := _find_button_by_text(child, text)
		if found != null:
			return found
	return null

func _text_tree_contains(root_node: Node, text: String) -> bool:
	if root_node == null:
		return false
	if root_node is Label and str((root_node as Label).text).contains(text):
		return true
	if root_node is Button and str((root_node as Button).text).contains(text):
		return true
	for child: Node in root_node.get_children():
		if _text_tree_contains(child, text):
			return true
	return false

func _base_state_without_collect() -> Dictionary:
	var base := _base_state_fixture()
	var structures := Array(base.get("structures", []))
	for index in range(structures.size()):
		var structure := Dictionary(structures[index])
		structure["pending_collectable"] = 0
		structures[index] = structure
	base["structures"] = structures
	return base

func _base_state_fixture() -> Dictionary:
	return {
		"construction_slots": 2,
		"structures": [
			{
				"structure_id": "nucleo_energia",
				"display_name": "Nucleo de Energia",
				"level": 2,
				"max_level": 40,
				"next_level": 3,
				"description": "Gera Energia para upgrades.",
				"produces": "energia",
				"daily_production": 40,
				"pending_collectable": 12,
				"storage_cap": 80,
				"upgrade_cost": {"energia": 20},
				"upgrade_duration_seconds": 120,
				"can_upgrade": true,
				"blocked_message": "Upgrade disponivel.",
			},
			{
				"structure_id": "altar_das_almas",
				"display_name": "Altar das Almas",
				"level": 1,
				"max_level": 40,
				"next_level": 2,
				"description": "Gera Almas.",
				"produces": "almas",
				"daily_production": 20,
				"pending_collectable": 4,
				"storage_cap": 50,
				"upgrade_cost": {"energia": 10},
				"upgrade_duration_seconds": 60,
				"can_upgrade": false,
				"blocked_message": "Fila de construcao cheia.",
			},
		],
		"jobs": [
			{
				"status": "active",
				"structure_id": "altar_das_almas",
				"target_level": 2,
				"remaining_seconds": 90,
			},
		],
	}

func _battle_log_fixture() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "foundation-loop-battle",
		"seed": "foundation-loop-seed",
		"mode": "MVP_ONLY",
		"duration": 9.5,
		"participants": {
			"player": {"id": "player-loop", "display_name": "Draxos"},
			"opponent": {"id": "bot-loop", "display_name": "Treinador", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 9.5, "seq": 2, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
	}

func _battle_rewards_fixture() -> Dictionary:
	return {
		"type": "FIRST_SLICE_SIM",
		"resources": {"xp": 10, "almas": 1, "ossos": 1},
	}

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}
