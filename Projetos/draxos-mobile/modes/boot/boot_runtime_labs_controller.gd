extends "res://modes/boot/boot_runtime_status_controller.gd"

# Internal lab overlays, mode hub rendering, and mode ops/admin panel.
func _battle_lab_available() -> bool:
	if not _internal_dev_tools_enabled():
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/battle_lab/enabled", false)):
		return false
	return ResourceLoader.exists(BATTLE_LAB_SCREEN_PATH)
func _open_battle_lab_overlay() -> void:
	if not _battle_lab_available():
		_error_label.text = "Battle Lab dev indisponivel neste ambiente."
		return
	if _battle_lab_overlay != null and is_instance_valid(_battle_lab_overlay):
		return
	var script: Script = load(BATTLE_LAB_SCREEN_PATH)
	if script == null or not script.can_instantiate():
		_error_label.text = "Battle Lab dev nao pode ser carregado."
		return
	var overlay: Control = script.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", Callable(self, "_close_battle_lab_overlay"))
	add_child(overlay)
	_battle_lab_overlay = overlay
	_emit_client_event("battle_lab_opened", {
		"screen": _current_screen,
	})
func _close_battle_lab_overlay() -> void:
	if _battle_lab_overlay == null or not is_instance_valid(_battle_lab_overlay):
		_battle_lab_overlay = null
		return
	_battle_lab_overlay.queue_free()
	_battle_lab_overlay = null
	_emit_client_event("battle_lab_closed", {
		"screen": _current_screen,
	})
func _progression_lab_available() -> bool:
	if not _internal_dev_tools_enabled():
		return false
	if not bool(ProjectSettings.get_setting("draxos_mobile/progression_lab/enabled", false)):
		return false
	return ResourceLoader.exists(PROGRESSION_LAB_SCREEN_PATH)

func _openworld_mode_available() -> bool:
	if not _internal_dev_tools_enabled():
		return false
	return ModeShellRegistryScript.is_available(ModeShellRegistryScript.MODE_OPENWORLD)

func _internal_dev_tools_enabled() -> bool:
	return OS.has_feature("editor") or bool(ProjectSettings.get_setting("draxos_mobile/internal_alpha/dev_tools_enabled", false))

func _open_progression_lab_overlay() -> void:
	if not _progression_lab_available():
		_error_label.text = "Progression Lab dev indisponivel neste ambiente."
		return
	if _progression_lab_overlay != null and is_instance_valid(_progression_lab_overlay):
		return
	var script: Script = load(PROGRESSION_LAB_SCREEN_PATH)
	if script == null or not script.can_instantiate():
		_error_label.text = "Progression Lab dev nao pode ser carregado."
		return
	var overlay: Control = script.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	if overlay.has_signal("close_requested"):
		overlay.connect("close_requested", Callable(self, "_close_progression_lab_overlay"))
	add_child(overlay)
	_progression_lab_overlay = overlay
	_emit_client_event("progression_lab_opened", {
		"screen": _current_screen,
	})

func _close_progression_lab_overlay() -> void:
	if _progression_lab_overlay == null or not is_instance_valid(_progression_lab_overlay):
		_progression_lab_overlay = null
		return
	_progression_lab_overlay.queue_free()
	_progression_lab_overlay = null
	_emit_client_event("progression_lab_closed", {
		"screen": _current_screen,
	})

func _render_entry_screen() -> void:
	HubSurfacePresenterScript.render_entry(self)

func _render_refuge_screen() -> void:
	HubSurfacePresenterScript.render_refuge(self)
	call_deferred("_sync_refuge_state_if_needed")

func _render_account_screen() -> void:
	HubAccountSurfacePresenterScript.render_account_panel(self)

func _render_battle_screen() -> void:
	_battle_lifecycle_flow.render_entry(self)

func _render_battle_running_screen() -> void:
	_battle_lifecycle_flow.render_running(self)

func _render_battle_summary_screen() -> void:
	_battle_lifecycle_flow.render_summary(self)

func _render_battle_logs_screen() -> void:
	_battle_lifecycle_flow.render_logs(self)

func _render_arena_selection_screen() -> void:
	_arena_lifecycle_flow.render_selection(self)

func _render_arena_loadout_screen() -> void:
	_arena_lifecycle_flow.render_loadout(self)

func _render_arena_active_screen() -> void:
	_arena_lifecycle_flow.render_active(self)

func _render_arena_replay_screen() -> void:
	_arena_lifecycle_flow.render_replay(self)

func _render_arena_buff_choice_screen() -> void:
	_arena_lifecycle_flow.render_buff_choice(self)

func _render_arena_summary_screen() -> void:
	_arena_lifecycle_flow.render_summary(self)

func _render_base_screen() -> void:
	BaseSurfacePresenterScript.render(self)

func _render_social_screen() -> void:
	SocialSurfacePresenterScript.render(self)

func _render_competition_screen() -> void:
	CompetitionSurfacePresenterScript.render(self)

func _render_shop_screen() -> void:
	ShopSurfacePresenterScript.render(self)

func _render_mode_hub_screen() -> void:
	ModeHubSurfacePresenterScript.render(self)
	_emit_client_event("mode_hub_shown", {
		"mode_count": ModeShellRegistryScript.registered_ids().size(),
		"entry_surface": "refuge",
	})

func _render_modes_ops_screen() -> void:
	_add_section_label("Labs Dev Ops")
	_add_body_text("Painel interno para investigar registry, analytics e disable/enable de modos. Dados sensiveis aparecem apenas para usuarios com role em admin_roles.")
	_modes_ops_state_container = VBoxContainer.new()
	_modes_ops_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_modes_ops_state_container.add_theme_constant_override("separation", 8)
	_add_content_control(_modes_ops_state_container)
	_add_modes_ops_button("Atualizar Ops", Callable(self, "_load_modes_ops_panel"))
	_add_modes_ops_button("Desabilitar Openworld", Callable(self, "_admin_disable_openworld"))
	_add_modes_ops_button("Habilitar Openworld", Callable(self, "_admin_enable_openworld"))
	call_deferred("_load_modes_ops_panel")

func _add_modes_ops_button(text: String, target: Callable) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = _button_min_size()
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_prepare_touch_button(button)
	_apply_action_button_style(button, "modes_ops", "refuge")
	button.pressed.connect(target)
	_add_content_control(button)

func _load_modes_ops_panel() -> void:
	if _modes_ops_state_container == null or not is_instance_valid(_modes_ops_state_container):
		return
	for child: Node in _modes_ops_state_container.get_children():
		child.queue_free()
	if not SessionStore.has_valid_access_token():
		_modes_ops_state_container.add_child(_modes_ops_label("Entre com uma conta alpha para consultar Ops."))
		return
	var admin_result: Dictionary = await SupabaseClient.get_mode_admin_me(SessionStore.access_token)
	if not bool(admin_result.get("ok", false)):
		_modes_ops_state_container.add_child(_modes_ops_label("Sem role admin ativa. O painel nao exibira dados sensiveis nem acoes."))
		return
	var body := _as_dictionary(admin_result.get("body", admin_result))
	if _as_dictionary(body.get("admin", {})).is_empty():
		_modes_ops_state_container.add_child(_modes_ops_label("Sem role admin ativa."))
		return
	_modes_ops_state_container.add_child(_modes_ops_label("Admin ativo: %s" % str(_as_dictionary(body.get("admin", {})).get("role", "mode_ops"))))
	var registry: Dictionary = await SupabaseClient.get_mode_registry(SessionStore.access_token)
	if bool(registry.get("ok", false)):
		var registry_body := _as_dictionary(registry.get("body", registry))
		_modes_ops_state_container.add_child(_modes_ops_label("Registry: %d modos" % _as_array(registry_body.get("modes", [])).size()))
	var analytics: Dictionary = await SupabaseClient.get_mode_analytics_summary("openworld", SessionStore.access_token)
	if bool(analytics.get("ok", false)):
		var analytics_body := _as_dictionary(analytics.get("body", analytics))
		var funnel := _as_dictionary(analytics_body.get("funnel", {}))
		_modes_ops_state_container.add_child(_modes_ops_label("Openworld: %s sessoes, %s completadas, %s claims" % [
			str(funnel.get("sessions", 0)),
			str(funnel.get("completed", 0)),
			str(funnel.get("reward_claims", 0)),
		]))

func _admin_disable_openworld() -> void:
	await _admin_toggle_openworld(false)

func _admin_enable_openworld() -> void:
	await _admin_toggle_openworld(true)

func _admin_toggle_openworld(enable: bool) -> void:
	if not SessionStore.has_valid_access_token():
		_show_notice("Ops exige conta autenticada.")
		return
	var request_id := SessionStoreScript.create_request_id()
	var result: Dictionary
	if enable:
		result = await SupabaseClient.admin_enable_mode(request_id, "openworld", "internal_alpha", "V1 ops manual enable from Labs Dev Ops.", SessionStore.access_token)
	else:
		result = await SupabaseClient.admin_disable_mode(request_id, "openworld", "V1 ops manual disable from Labs Dev Ops.", SessionStore.access_token)
	if not bool(result.get("ok", false)):
		var error_payload := _extract_error(result)
		_error_label.text = _friendly_error_message(str(error_payload.get("code", "MODE_OPS_FAILED")), str(error_payload.get("message", "")))
	else:
		_show_notice("Ops aplicado em Openworld.")
	await _load_modes_ops_panel()

func _modes_ops_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color("text_secondary"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _render_mode_shell_screen() -> void:
	_mode_shell_launcher.render(self)
