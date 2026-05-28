extends SceneTree

const AppShellRouteContractScript = preload("res://modes/boot/ui/app_shell_route_contract.gd")
const MobileUiContractScript = preload("res://modes/boot/ui/mobile_ui_contract.gd")
const SessionStoreScript = preload("res://online/session_store.gd")
const SupabaseClientScript = preload("res://online/supabase_client.gd")
const TouchScrollContainerScript = preload("res://modes/boot/ui/touch_scroll_container.gd")
const BOOT_SCREEN_PATH := "res://modes/boot/boot.gd"

var _failures: PackedStringArray = PackedStringArray()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = await _run_smoke()
	quit(exit_code)

func _run_smoke() -> int:
	print("[smoke-foundation-hardening] checking route contract")
	_check_route_contract()
	print("[smoke-foundation-hardening] checking mobile UI contract")
	_check_mobile_ui_contract()
	print("[smoke-foundation-hardening] checking session/save boundary")
	_check_session_save_boundary()
	print("[smoke-foundation-hardening] checking battle mode contract")
	await _check_battle_mode_contract()

	if not _failures.is_empty():
		for failure: String in _failures:
			printerr("[smoke-foundation-hardening] %s" % failure)
		return 1
	print("[smoke-foundation-hardening] OK")
	return 0

func _check_route_contract() -> void:
	var history: Array[String] = []
	var current := AppShellRouteContractScript.ROUTE_REFUGE_HOME
	_expect(AppShellRouteContractScript.normalize("hub") == AppShellRouteContractScript.ROUTE_REFUGE_HOME, "legacy hub alias returns Refugio root")
	_expect(AppShellRouteContractScript.normalize("monetization") == AppShellRouteContractScript.ROUTE_SHOP, "legacy monetization alias returns shop route")
	_expect(not AppShellRouteContractScript.supports_back(current), "Refugio root does not expose Back")
	_expect(AppShellRouteContractScript.is_first_screen(current), "Refugio root is the first-screen route")
	_expect(not AppShellRouteContractScript.shows_app_chrome(current), "Refugio first screen hides app chrome")

	current = AppShellRouteContractScript.push_route(history, current, "base", true)
	_expect(current == AppShellRouteContractScript.ROUTE_BASE, "base route normalizes through route contract")
	_expect(history.size() == 1 and history[0] == AppShellRouteContractScript.ROUTE_REFUGE_HOME, "push_route records root history")
	current = AppShellRouteContractScript.push_route(history, current, "social", true)
	_expect(current == AppShellRouteContractScript.ROUTE_SOCIAL, "social route pushes from base")
	_expect(AppShellRouteContractScript.pop_back_or_root(history) == AppShellRouteContractScript.ROUTE_BASE, "back stack pops to previous internal screen")
	_expect(AppShellRouteContractScript.clear_for_root_return(history) == AppShellRouteContractScript.ROUTE_REFUGE_HOME, "root return clears history")
	_expect(history.is_empty(), "root return leaves empty history")

func _check_mobile_ui_contract() -> void:
	var button := Button.new()
	button.custom_minimum_size = Vector2(20, 20)
	MobileUiContractScript.apply_touch_button(button)
	_expect(button.custom_minimum_size.y >= MobileUiContractScript.MIN_TOUCH_TARGET, "touch button reaches minimum height")
	_expect(button.mouse_filter == Control.MOUSE_FILTER_PASS, "touch button keeps drag pass-through")
	button.free()

	var scroll := TouchScrollContainerScript.new()
	MobileUiContractScript.apply_touch_scroll_policy(scroll)
	_expect(scroll.drag_threshold == MobileUiContractScript.TOUCH_DRAG_THRESHOLD, "touch scroll uses shared drag threshold")
	_expect(scroll.vertical_scroll_mode == ScrollContainer.SCROLL_MODE_SHOW_ALWAYS, "touch scroll keeps visible vertical scrollbar")
	_expect(scroll.horizontal_scroll_mode == ScrollContainer.SCROLL_MODE_DISABLED, "touch scroll disables horizontal scroll")
	_expect(scroll.get_v_scroll_bar().custom_minimum_size.x >= MobileUiContractScript.TOUCH_SCROLLBAR_WIDTH, "touch scrollbar keeps wide target")
	scroll.free()

	var portrait := MobileUiContractScript.layout_summary_for_size(Vector2(390, 844), true)
	var landscape := MobileUiContractScript.layout_summary_for_size(Vector2(1280, 720), true)
	_expect(str(portrait.get("orientation", "")) == "portrait", "portrait layout summary detects portrait")
	_expect(int(portrait.get("surface_columns", 0)) == 1, "portrait surface layout stays single-column")
	_expect(str(landscape.get("orientation", "")) == "landscape", "landscape layout summary detects landscape")
	_expect(int(landscape.get("base_map_columns", 0)) >= 3, "landscape base map keeps dense columns")

func _check_session_save_boundary() -> void:
	var store = SessionStoreScript.new()
	var now := int(Time.get_unix_time_from_system())
	_expect(store.runtime_config_is_fallback(), "SessionStore starts with runtime config fallback")
	_expect(store.apply_auth_session({
		"access_token": "foundation-access-secret",
		"refresh_token": "foundation-refresh-secret",
		"expires_at": now + 3600,
		"user_id": "auth-foundation",
		"auth_method": "email",
		"email": "foundation@example.com",
	}), "auth session applies")
	_expect(store.apply_server_state({
		"ok": true,
		"_client": {"save_type": "normal"},
		"player": {"id": "player-normal", "username": "foundation", "save_type": "normal"},
		"resources": {"almas": 4, "energia": 8},
		"build": {"weapon_type": "varinha_cinzas"},
	}), "normal account snapshot applies")
	_expect(store.apply_base_result({
		"ok": true,
		"_client": {"save_type": "normal"},
		"resources": {"energia": 8},
		"base": {
			"construction_slots": 1,
			"structures": [{"structure_id": "nucleo_energia", "level": 1}],
			"jobs": [],
		},
	}), "normal base snapshot applies")
	var diagnostics := _as_dictionary(store.diagnostics_snapshot())
	var surfaces := _as_dictionary(diagnostics.get("surfaces", {}))
	_expect(str(_as_dictionary(surfaces.get("account", {})).get("save_type", "")) == "normal", "diagnostics records account save type")
	_expect(str(_as_dictionary(surfaces.get("base", {})).get("save_type", "")) == "normal", "diagnostics records base save type")
	_expect(not str(diagnostics).contains("foundation-access-secret"), "SessionStore diagnostics do not expose access token value")
	_expect(not str(diagnostics).contains("foundation-refresh-secret"), "SessionStore diagnostics do not expose refresh token value")

	_expect(store.set_active_save_type(SessionStoreScript.SAVE_TYPE_PROGRESSION_LAB), "switch to progression lab save succeeds")
	_expect(not store.has_account_state(), "save switch clears account snapshot")
	_expect(not store.has_base_state(), "save switch clears base snapshot")
	_expect(not store.apply_base_result({
		"ok": true,
		"_client": {"save_type": "normal"},
		"base": {"structures": [{"structure_id": "stale"}], "jobs": []},
	}), "stale normal payload is rejected while lab save is active")
	_expect(str(store.last_error.get("code", "")) == "STALE_SAVE_RESPONSE", "stale payload records explicit error")

	var local_only = SessionStoreScript.new()
	_expect(local_only.apply_snapshot_cache({
		"cache_version": 1,
		"auth": {
			"access_token": "progression_lab_local_only",
			"refresh_token": "progression_lab_local_only",
			"expires_at": now + 3600,
			"user_id": "auth_progression_lab",
		},
		"session_id": "11111111-1111-4111-8111-111111111111",
		"player": {"id": "player-local", "username": "plab"},
		"resources": {"energia": 115},
		"build": {"weapon_type": "varinha_cinzas"},
		"progression_lab": {
			"save_id": "free_100_rewards_20h",
			"profile_id": "free_100_rewards",
			"milestone_id": "20h",
			"local_only": true,
		},
	}), "progression lab local-only cache applies")
	_expect(local_only.is_progression_lab_local_only(), "local-only cache is flagged")
	_expect(not local_only.has_valid_access_token(now), "local-only cache never keeps a valid token")
	_expect(local_only.access_token == "" and local_only.refresh_token == "", "local-only cache strips tokens")
	store.free()
	local_only.free()

	var client = SupabaseClientScript.new()
	client.configure("https://example.supabase.co/", "sb_publishable_example")
	client.configure_save_type("progression_lab")
	var client_diagnostics := _as_dictionary(client.diagnostics_snapshot())
	_expect(not client_diagnostics.has("publishable_key"), "SupabaseClient diagnostics omit publishable key field")
	_expect(not str(client_diagnostics).contains("sb_publishable_example"), "SupabaseClient diagnostics do not expose publishable key value")
	_expect(str(_as_dictionary(client_diagnostics.get("save_context", {})).get("active_save_type", "")) == "progression_lab", "SupabaseClient diagnostics exposes save context only")
	client.free()

func _check_battle_mode_contract() -> void:
	_expect(AppShellRouteContractScript.is_battle_mode("battle"), "battle entry is a battle mode")
	_expect(AppShellRouteContractScript.is_battle_mode("battle_running"), "battle running is a battle mode")
	_expect(AppShellRouteContractScript.is_fullscreen_gameplay("battle_running"), "battle running is fullscreen gameplay")
	_expect(AppShellRouteContractScript.is_fullscreen_gameplay("battle_summary"), "battle summary is fullscreen gameplay")
	_expect(AppShellRouteContractScript.prefers_landscape("battle_running"), "battle running prefers landscape")
	_expect(not AppShellRouteContractScript.shows_app_chrome("battle_running"), "battle running hides app chrome")
	_expect(not AppShellRouteContractScript.shows_app_chrome("battle_summary"), "battle summary hides app chrome")
	_expect(AppShellRouteContractScript.is_safe_replay_action("skip_battle_replay"), "skip is replay-safe action")
	_expect(not AppShellRouteContractScript.is_safe_replay_action("request_battle"), "request battle is not replay-safe")
	_expect(AppShellRouteContractScript.is_read_only_battle_action("show_battle_history"), "battle history action is read-only")
	_expect(AppShellRouteContractScript.summary_route_for("battle_running") == "battle_summary", "battle running resolves to summary route")

	root.size = Vector2i(1280, 720)
	await process_frame
	var session_store := _session_store()
	session_store.clear_session()
	var boot: Control = _new_boot()
	await process_frame
	if boot == null:
		return
	session_store.last_battle_log = _battle_log_fixture()
	session_store.last_battle_rewards = {"type": "FIRST_SLICE_SIM", "resources": {"xp": 5, "ossos": 1}}
	session_store.resources = {"almas": 2, "energia": 3}

	boot.call("_show_screen", "battle_running")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "battle_running", "Boot enters battle_running route")
	_expect(not bool(boot.call("_route_shows_app_chrome", "battle_running")), "Boot battle_running hides app chrome")
	_expect(boot.get("_battle_fullscreen_overlay") != null, "Boot creates battle fullscreen overlay")
	_expect(_find_button_by_text(boot, "Pular") != null, "Boot battle fullscreen exposes Pular")

	boot.set("_replay_running", true)
	boot.call("_skip_current_replay")
	await process_frame
	_expect(bool(boot.get("_skip_replay")), "Skip only marks replay for safe completion")
	boot.set("_replay_running", false)
	boot.set("_skip_replay", false)
	boot.call("_show_screen", "battle_summary")
	await process_frame
	_expect(_label_tree_contains(boot, "Resumo da batalha"), "Battle summary renders title")
	_expect(_find_button_by_text(boot, "Voltar ao Refugio") != null, "Battle summary exposes return to Refugio")
	boot.call("_return_to_refuge")
	await process_frame
	_expect(str(boot.get("_current_screen")) == "refuge_home", "Return to Refugio clears battle route")
	var first_screen := _get_control(boot, "_first_screen_root")
	var app_chrome := _get_control(boot, "_app_chrome_root")
	_expect(first_screen != null and first_screen.visible, "Return to Refugio restores first-screen layer")
	_expect(app_chrome != null and not app_chrome.visible, "Return to Refugio keeps app chrome hidden")
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

func _session_store() -> Node:
	return root.get_node("/root/SessionStore")

func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)

func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

func _get_control(root_node: Node, property_name: String) -> Control:
	if root_node == null:
		return null
	var value: Variant = root_node.get(property_name)
	if value is Control:
		return value as Control
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

func _battle_log_fixture() -> Dictionary:
	return {
		"schema_version": "battle_log_v1",
		"battle_id": "foundation-hardening-battle",
		"seed": "foundation-hardening-seed",
		"duration": 9.5,
		"participants": {
			"player": {"id": "player-1", "display_name": "Draxos"},
			"opponent": {"id": "bot-1", "display_name": "Guardiao", "is_bot": true},
		},
		"result": {"winner": "player", "reason": "opponent_defeated"},
		"events": [
			{"t": 0.0, "seq": 1, "type": "battle_start", "source": "system", "target": "none"},
			{"t": 9.5, "seq": 2, "type": "battle_result", "source": "system", "target": "none", "winner": "player", "reason": "opponent_defeated"},
		],
	}
