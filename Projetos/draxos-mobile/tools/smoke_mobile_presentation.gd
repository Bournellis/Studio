extends SceneTree

const ProjectInfoScript = preload("res://core/project_info.gd")
const MobileUiContractScript = preload("res://modes/boot/ui/mobile_ui_contract.gd")
const TouchScrollContainerScript = preload("res://modes/boot/ui/touch_scroll_container.gd")
const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	print("[smoke-mobile-presentation] checking portrait app loop")
	await _check_portrait_app_loop()
	print("[smoke-mobile-presentation] checking wide portrait app loop")
	await _check_wide_portrait_app_loop()
	print("[smoke-mobile-presentation] checking battle fullscreen loop")
	await _check_battle_fullscreen_loop()

	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-mobile-presentation] %s" % failure)
		return 1
	print("[smoke-mobile-presentation] OK")
	return 0

func _check_portrait_app_loop() -> void:
	root.size = Vector2i(390, 844)
	await process_frame
	var boot: Control = _new_boot()
	await process_frame

	_expect(str(boot.get("_current_screen")) == "entry", "portrait opens on Entry")
	_expect(_get_first_screen_root(boot) != null and _get_first_screen_root(boot).visible, "portrait opens on first-screen Entry layer")
	_expect(_get_app_chrome_root(boot) != null and not _get_app_chrome_root(boot).visible, "portrait Entry hides app chrome")
	_expect(_label_tree_contains(boot, "Entrada"), "portrait Entry shows operational start page")
	_expect(_find_button_by_text(boot, "Entrar no Refugio") != null, "portrait Entry has Refugio CTA")
	_expect(_find_button_by_text(boot, "Save normal") != null, "portrait Entry has save selector")

	boot.call("_show_screen", "refuge")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "refuge", "Refugio route opens after Entry")
	_expect(_label_tree_contains(boot, "Altar do Mago"), "portrait Refugio shows mage altar")
	_expect(_find_button_by_text(boot, "Perfil") != null, "portrait Refugio has account hotspot")
	_expect(_find_button_by_text(boot, "Base") != null, "portrait Refugio has Base hotspot")
	var battle_hotspot := _find_button_by_text(boot, "Batalha")
	_expect(battle_hotspot != null, "portrait Refugio has Battle hotspot")
	_expect(battle_hotspot != null and battle_hotspot.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET, "portrait hotspots keep mobile touch target")
	_expect(_get_back_button(boot) != null and not _get_back_button(boot).visible, "portrait Refugio hides app chrome Back")

	boot.call("_show_screen", "account")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "account", "account route opens from Refugio")
	_expect(_get_first_screen_root(boot) != null and not _get_first_screen_root(boot).visible, "account hides first-screen Refugio layer")
	_expect(_get_app_chrome_root(boot) != null and _get_app_chrome_root(boot).visible, "account uses internal app shell")
	_expect(_get_back_button(boot) != null and _get_back_button(boot).visible, "account route exposes Back")
	_expect(boot.get("_auth_email_input") != null, "account route owns login fields")

	boot.call("_go_back")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "refuge", "Back returns to Refugio")
	_expect(_get_first_screen_root(boot) != null and _get_first_screen_root(boot).visible, "Back restores first-screen Refugio layer")
	_expect(_get_app_chrome_root(boot) != null and not _get_app_chrome_root(boot).visible, "Back hides app shell on Refugio root")
	boot.queue_free()
	await process_frame

func _check_wide_portrait_app_loop() -> void:
	root.size = Vector2i(1280, 720)
	await process_frame
	var boot: Control = _new_boot()
	await process_frame
	var session_store := _session_store()
	session_store.base_state = _base_state_fixture()
	session_store.social_state = _social_state_fixture()

	boot.call("_show_screen", "base")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "base_management", "wide viewport still opens Base management route")
	_expect(_get_back_button(boot) != null and _get_back_button(boot).visible, "wide internal route exposes Back")
	_expect(_get_content_scroll(boot) != null, "wide internal route uses touch scroll container")
	_expect(_get_content_scroll(boot) is TouchScrollContainerScript, "wide internal route reuses DraxosTouchScrollContainer")
	_expect(_label_tree_contains(boot, "Rotina da Base"), "wide Base keeps routine panel")

	var scroll := _get_content_scroll(boot)
	if scroll != null:
		_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS, "touch scroll policy keeps vertical scrollbar visible")
		_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "touch scroll policy disables horizontal drag")
		_expect(scroll.get_v_scroll_bar().custom_minimum_size.x >= MobileUiContractScript.TOUCH_SCROLLBAR_WIDTH, "touch scrollbar keeps minimum target width")
		scroll.scroll_vertical = 120
	boot.call("_show_screen", "social")
	await process_frame
	scroll = _get_content_scroll(boot)
	_expect(str(boot.get("_current_screen")) == "social", "wide Social route opens")
	_expect(scroll != null and scroll.scroll_vertical == 0, "route changes reset scroll position")
	_expect(_label_tree_contains(boot, "Refresh e Polling") or _label_tree_contains(boot, "Social server-authoritative"), "wide Social keeps readable state")
	boot.queue_free()
	await process_frame

func _check_battle_fullscreen_loop() -> void:
	root.size = Vector2i(1280, 720)
	await process_frame
	var boot: Control = _new_boot()
	var session_store := _session_store()
	session_store.last_battle_log = _battle_log_fixture()
	session_store.last_battle_rewards = _battle_rewards_fixture()
	session_store.resources = {"almas": 7, "energia": 9, "diamante": 2}
	await process_frame

	boot.call("_show_screen", "battle_running")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "battle_running", "battle_running route opens")
	_expect(not bool(boot.call("_route_prefers_landscape", "battle_running")), "battle_running stays portrait")
	_expect(boot.get("_battle_fullscreen_overlay") != null, "battle_running creates fullscreen overlay")
	_expect(_find_button_by_text(boot, "Pular") != null, "battle_running exposes fixed skip action")
	_expect(_label_tree_contains(boot, "Autobattler"), "battle_running labels gameplay frame")

	boot.set("_battle_summary_skipped", true)
	boot.call("_show_screen", "battle_summary")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "battle_summary", "battle_summary route opens")
	_expect(_label_tree_contains(boot, "Resumo da batalha"), "battle_summary shows result title")
	_expect(_label_tree_contains(boot, "Voltar ao Refugio"), "battle_summary can return to Refugio")
	_expect(_find_button_by_text(boot, "Historico") != null, "battle_summary can open history")
	boot.queue_free()
	await process_frame

func _new_boot() -> Control:
	var boot_script: Script = load(BOOT_SCREEN_PATH)
	if boot_script == null or not boot_script.can_instantiate():
		_failures.append("Boot screen script failed to load")
		return null
	var boot: Control = boot_script.new()
	root.add_child(boot)
	return boot

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _get_back_button(boot: Control) -> Button:
	var value: Variant = boot.get("_back_button")
	if value is Button:
		return value as Button
	return null

func _get_first_screen_root(boot: Control) -> Control:
	var value: Variant = boot.get("_first_screen_root")
	if value is Control:
		return value as Control
	return null

func _get_app_chrome_root(boot: Control) -> Control:
	var value: Variant = boot.get("_app_chrome_root")
	if value is Control:
		return value as Control
	return null

func _get_content_scroll(boot: Control) -> ScrollContainer:
	var value: Variant = boot.get("_content_scroll")
	if value is ScrollContainer:
		return value as ScrollContainer
	return null

func _label_tree_contains(root_node: Node, needle: String) -> bool:
	if root_node == null:
		return false
	if root_node is Label and str((root_node as Label).text).contains(needle):
		return true
	if root_node is Button and str((root_node as Button).text).contains(needle):
		return true
	for child: Node in root_node.get_children():
		if _label_tree_contains(child, needle):
			return true
	return false

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

func _battle_log_fixture() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "presentation-smoke-battle",
		"seed": "presentation-smoke-seed",
		"mode": ProjectInfoScript.FIRST_SLICE_MODE,
		"duration": 12.5,
		"participants": {
			"player": {"id": "player-1", "display_name": "Draxos"},
			"opponent": {"id": "bot-1", "display_name": "Treinador da Primeira Ruina", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 12.5, "seq": 2, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
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

func _social_state_fixture() -> Dictionary:
	return {
		"identity": {"viewer_badge": "normal"},
		"player": {"username": "fabio", "save_badge": "normal"},
		"active_player": {"username": "fabio", "save_badge": "normal"},
		"friends": [],
		"guild": null,
		"guild_members": [],
		"guild_structures": [],
		"guild_chat": [],
	}

func _session_store() -> Node:
	return root.get_node("/root/SessionStore")
