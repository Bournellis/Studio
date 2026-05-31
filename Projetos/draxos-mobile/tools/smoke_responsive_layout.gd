extends SceneTree

const MobileUiContractScript = preload("res://modes/boot/ui/mobile_ui_contract.gd")
const ProjectInfoScript = preload("res://core/project_info.gd")
const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	print("[smoke-responsive-layout] checking internal Entry tools")
	await _check_entry_dev_tools(Vector2i(390, 844))
	print("[smoke-responsive-layout] checking Refugio safe frames")
	await _check_refuge_layout(Vector2i(390, 844))
	await _check_refuge_layout(Vector2i(360, 800))
	await _check_refuge_layout(Vector2i(1280, 720))
	await _check_refuge_layout(Vector2i(1920, 1080))
	print("[smoke-responsive-layout] checking Battle request splash")
	await _check_battle_request_splash(Vector2i(390, 844))
	await _check_battle_request_splash(Vector2i(1280, 720))
	print("[smoke-responsive-layout] checking Battle safe frames")
	await _check_battle_layout(Vector2i(360, 800))
	await _check_battle_layout(Vector2i(390, 844))
	await _check_battle_layout(Vector2i(1280, 720))
	await _check_battle_layout(Vector2i(1920, 1080))
	print("[smoke-responsive-layout] checking Battle summary/log routes")
	for viewport_size: Vector2i in [Vector2i(360, 800), Vector2i(390, 844), Vector2i(1280, 720), Vector2i(1920, 1080)]:
		await _check_battle_summary_layout(viewport_size)
		await _check_battle_logs_layout(viewport_size)

	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-responsive-layout] %s" % failure)
		return 1
	print("[smoke-responsive-layout] OK")
	return 0

func _check_entry_dev_tools(viewport_size: Vector2i) -> void:
	_prepare_viewport(viewport_size)
	await process_frame
	ProjectSettings.set_setting("draxos_mobile/internal_alpha/dev_tools_enabled", true)
	ProjectSettings.set_setting("draxos_mobile/battle_lab/enabled", true)
	ProjectSettings.set_setting("draxos_mobile/progression_lab/enabled", true)
	var boot: Control = _new_boot()
	await process_frame
	await process_frame

	_expect_node_fits(boot, "EntryDevPanel", "Entry %s" % str(viewport_size), false)
	_expect(_find_button_by_text(boot, "Ferramentas internas") != null, "Entry exposes internal tools toggle at %s." % str(viewport_size))
	_expect(_find_button_by_text(boot, "Battle Lab") != null, "Entry exposes Battle Lab at %s." % str(viewport_size))
	_expect(_find_button_by_text(boot, "Progression Lab") != null, "Entry exposes Progression Lab at %s." % str(viewport_size))
	_expect(Dictionary(boot.get("_action_buttons")).has("open_battle_lab"), "Entry registers Battle Lab action.")
	_expect(Dictionary(boot.get("_action_buttons")).has("open_progression_lab"), "Entry registers Progression Lab action.")
	boot.queue_free()
	await process_frame

func _check_refuge_layout(viewport_size: Vector2i) -> void:
	_prepare_viewport(viewport_size)
	await process_frame
	var boot: Control = _new_boot()
	var store := _session_store()
	store.base_state = _base_state_fixture()
	store.resources = {"almas": 10, "energia": 25, "sangue": 3, "cristais": 4, "ossos": 2, "po_osso": 1, "diamante": 80}
	await process_frame
	boot.call("_show_screen", "refuge")
	await process_frame
	await process_frame

	var context := "Refugio %s" % str(viewport_size)
	for node_name: String in [
		"RefugeSceneBoard",
		"RefugeSafeFrame",
		"RefugeTopHud",
		"RefugeAltarStage",
		"RefugeLoopPanel",
		"RefugeContextCta",
		"RefugeIcon_Perfil",
		"RefugeIcon_LabsDev",
		"RefugeIcon_Arena PVE",
		"RefugeIcon_Refugio",
		"RefugeIcon_Social",
		"RefugeIcon_Loja",
		"RefugeIcon_Coletar",
		"RefugeIcon_Energia",
	]:
		_expect_node_fits(boot, node_name, context)
	_expect(_find_node_by_name(boot, "RefugeIcon_Batalha") == null, "%s hides legacy battle shortcut." % context)
	_expect(_find_node_by_name(boot, "RefugeIcon_Competicao") == null, "%s hides competition shortcut." % context)
	var safe_frame := _find_node_by_name(boot, "RefugeSafeFrame") as Control
	if safe_frame != null:
		_expect(safe_frame.size.x <= MobileUiContractScript.IMMERSIVE_SAFE_MAX_WIDTH + 1.0, "%s safe frame width is capped." % context)
	boot.queue_free()
	await process_frame

func _check_battle_request_splash(viewport_size: Vector2i) -> void:
	_prepare_viewport(viewport_size)
	await process_frame
	var boot: Control = _new_boot()
	await process_frame
	boot.set("_battle_request_splash_active", true)
	boot.call("_show_screen", "battle")
	await process_frame
	await process_frame

	var context := "Battle request splash %s" % str(viewport_size)
	_expect_node_fits(boot, "BattleRequestSplash", context, false)
	_expect_node_fits(boot, "BattleRequestSplashArt", context, false)
	_expect(_find_node_by_name(boot, "BattleDuelVisual") == null, "%s does not render battle preview." % context)
	_expect(not Dictionary(boot.get("_action_buttons")).has("request_battle"), "%s does not expose duplicate request action." % context)
	boot.queue_free()
	await process_frame

func _check_battle_layout(viewport_size: Vector2i) -> void:
	_prepare_viewport(viewport_size)
	await process_frame
	var boot: Control = _new_boot()
	_prepare_battle_store()
	await process_frame
	boot.call("_show_screen", "battle_running")
	await process_frame
	await process_frame

	var context := "Battle %s" % str(viewport_size)
	for node_name: String in [
		"BattleFullscreenOverlay",
		"BattleSafeFrame",
		"BattleRunningStageFrame",
		"BattleDuelShellBand",
		"BattleDuelMatchupLabel",
		"BattleDuelProgressLabel",
		"BattleDuelStateLabel",
		"BattleDuelVisual",
		"BattleDuelStage",
		"BattleSkipButton",
	]:
		_expect_node_fits(boot, node_name, context)
	var safe_frame := _find_node_by_name(boot, "BattleSafeFrame") as Control
	if safe_frame != null:
		_expect(safe_frame.size.x <= MobileUiContractScript.IMMERSIVE_SAFE_MAX_WIDTH + 1.0, "%s safe frame width is capped." % context)
	boot.queue_free()
	await process_frame

func _check_battle_summary_layout(viewport_size: Vector2i) -> void:
	_prepare_viewport(viewport_size)
	await process_frame
	var boot: Control = _new_boot()
	_prepare_battle_store()
	await process_frame
	boot.call("_show_screen", "battle_summary")
	await process_frame
	await process_frame

	var context := "Battle summary %s" % str(viewport_size)
	for node_name: String in [
		"BattleFullscreenOverlay",
		"BattleSafeFrame",
		"BattleSummaryFrame",
		"BattleSummaryResult",
		"BattleSummaryOutcomeLabel",
	]:
		_expect_node_fits(boot, node_name, context)
	_expect(_find_button_by_text(boot, "Voltar e verificar base") != null, "%s exposes return-to-base CTA." % context)
	_expect(_find_button_by_text(boot, "Ver logs da batalha") != null, "%s exposes current logs CTA." % context)
	var safe_frame := _find_node_by_name(boot, "BattleSafeFrame") as Control
	if safe_frame != null:
		_expect(safe_frame.size.x <= MobileUiContractScript.IMMERSIVE_SAFE_MAX_WIDTH + 1.0, "%s safe frame width is capped." % context)
	boot.queue_free()
	await process_frame

func _check_battle_logs_layout(viewport_size: Vector2i) -> void:
	_prepare_viewport(viewport_size)
	await process_frame
	var boot: Control = _new_boot()
	_prepare_battle_store()
	await process_frame
	boot.call("_show_screen", "battle_logs")
	await process_frame
	await process_frame

	var context := "Battle logs %s" % str(viewport_size)
	for node_name: String in [
		"BattleFullscreenOverlay",
		"BattleSafeFrame",
		"BattleLogsFrame",
		"BattleLogsScroll",
	]:
		_expect_node_fits(boot, node_name, context)
	_expect_node_fits(boot, "BattleLogsList", context, false)
	_expect(_find_button_by_text(boot, "Voltar ao Resultado") != null, "%s exposes return-to-result CTA." % context)
	_expect(_find_button_by_text(boot, "Voltar ao Refugio") != null, "%s exposes return-to-refuge CTA." % context)
	var safe_frame := _find_node_by_name(boot, "BattleSafeFrame") as Control
	if safe_frame != null:
		_expect(safe_frame.size.x <= MobileUiContractScript.IMMERSIVE_SAFE_MAX_WIDTH + 1.0, "%s safe frame width is capped." % context)
	boot.queue_free()
	await process_frame

func _prepare_battle_store() -> void:
	var store := _session_store()
	store.last_battle_log = _battle_log_fixture()
	store.last_battle_rewards = _battle_rewards_fixture()
	store.resources = {"almas": 7, "energia": 9, "diamante": 2}

func _prepare_viewport(viewport_size: Vector2i) -> void:
	root.size = viewport_size

func _new_boot() -> Control:
	var boot_script: Script = load(BOOT_SCREEN_PATH)
	if boot_script == null or not boot_script.can_instantiate():
		_failures.append("Boot screen script failed to load.")
		return null
	var boot: Control = boot_script.new()
	root.add_child(boot)
	return boot

func _expect_node_fits(root_node: Node, node_name: String, context: String, require_vertical_fit: bool = true) -> void:
	var node := _find_node_by_name(root_node, node_name) as Control
	if node == null:
		_failures.append("%s missing node %s." % [context, node_name])
		return
	if not node.is_visible_in_tree():
		return
	var viewport_size := node.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		viewport_size = Vector2(root.size)
	var rect := node.get_global_rect()
	var tolerance := 2.0
	var vertical_overflow := rect.position.y < -tolerance or rect.end.y > viewport_size.y + tolerance
	if rect.position.x < -tolerance or rect.end.x > viewport_size.x + tolerance or (require_vertical_fit and vertical_overflow):
		_failures.append("%s %s overflow: left=%.1f top=%.1f right=%.1f bottom=%.1f viewport=%.1fx%.1f." % [
			context,
			node_name,
			rect.position.x,
			rect.position.y,
			rect.end.x,
			rect.end.y,
			viewport_size.x,
			viewport_size.y,
		])

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _find_button_by_text(root_node: Node, text: String) -> Button:
	if root_node == null:
		return null
	if root_node is Button and (root_node as Button).is_visible_in_tree() and str((root_node as Button).text) == text:
		return root_node as Button
	for child: Node in root_node.get_children():
		var found := _find_button_by_text(child, text)
		if found != null:
			return found
	return null

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

func _battle_log_fixture() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "responsive-smoke-battle",
		"seed": "responsive-smoke-seed",
		"mode": ProjectInfoScript.FIRST_SLICE_MODE,
		"duration": 12.5,
		"participants": {
			"player": {"id": "player-1", "display_name": "Draxos"},
			"opponent": {"id": "bot-1", "display_name": "Treinador da Primeira Ruina", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 2.0, "seq": 2, "type": "weapon_attack", "source": "player", "target": "opponent", "damage": 31, "damage_type": "fisico", "hp_after": 97},
			{"t": 12.5, "seq": 3, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
	}

func _battle_rewards_fixture() -> Dictionary:
	return {
		"type": "FIRST_SLICE_SIM",
		"resources": {"xp": 10, "almas": 0.8, "ossos": 1},
	}

func _base_state_fixture() -> Dictionary:
	return {
		"construction_slots": 2,
		"structures": [
			{
				"structure_id": "nucleo_energia",
				"display_name": "Nucleo de Energia",
				"level": 2,
				"next_level": 3,
				"pending_collectable": 12,
				"upgrade_cost": {"energia": 20},
				"upgrade_duration_seconds": 120,
				"can_upgrade": true,
				"blocked_message": "Upgrade disponivel.",
			},
			{
				"structure_id": "altar_das_almas",
				"display_name": "Altar das Almas",
				"level": 1,
				"next_level": 2,
				"pending_collectable": 4,
				"upgrade_cost": {"energia": 10},
				"upgrade_duration_seconds": 60,
				"can_upgrade": false,
				"blocked_message": "Fila de construcao cheia.",
			},
		],
		"jobs": [{
			"status": "active",
			"structure_id": "altar_das_almas",
			"target_level": 2,
			"remaining_seconds": 90,
		}],
	}

func _session_store() -> Node:
	return root.get_node("/root/SessionStore")
