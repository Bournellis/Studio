extends "res://modes/boot/boot_runtime_status_controller.gd"

# Internal lab overlays and mode hub rendering.
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

func _bosque_mode_available() -> bool:
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

func _render_mode_shell_screen() -> void:
	_mode_shell_launcher.render(self)
