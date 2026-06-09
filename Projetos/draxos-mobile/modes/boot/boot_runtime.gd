extends "res://modes/boot/boot_runtime_action_dispatcher.gd"

# Scene-facing orchestrator: boot lifecycle and input only; helpers live in budgeted modules.
func _ready() -> void:
	_clear_existing_scene()
	_build_ui()
	_ensure_social_auto_sync_timer()
	SessionStore.session_changed.connect(_sync_status_from_session)
	var cache_loaded := SessionStore.load_cache()
	SessionStore.ensure_session_id()
	SupabaseClient.configure_save_type(SessionStore.active_save_type)
	_update_gate = ProjectInfoScript.unchecked_update_status(SupabaseClient.manifest_url())
	if not cache_loaded:
		SessionStore.save_cache()
	_show_screen(SCREEN_HUB, false)
	_sync_status_from_session()
	call_deferred("_check_runtime_config")
	call_deferred("_check_update_manifest")
	if SessionStore.has_valid_access_token() and not SessionStore.is_progression_lab_local_only():
		call_deferred("_recover_session_state")

func _input(event: InputEvent) -> void:
	if _handle_shell_overlay_input(event):
		return
	_handle_cancel_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if _handle_shell_overlay_input(event):
		return
	_handle_cancel_input(event)

func _handle_shell_overlay_input(event: InputEvent) -> bool:
	if not _shell_overlay_is_open():
		return false
	if _mode_shell_overlay_controller.handle_input(self, event):
		get_viewport().set_input_as_handled()
		return true
	return false

func _handle_cancel_input(event: InputEvent) -> void:
	if not _is_cancel_input(event):
		return
	get_viewport().set_input_as_handled()
	if _create_account_dialog != null and _create_account_dialog.visible:
		_create_account_dialog.hide()
		return
	if _confirm_dialog != null and _confirm_dialog.visible:
		_confirm_dialog.hide()
		return
	if _close_refuge_menu_popup_if_open():
		return
	if _battle_lab_overlay != null and is_instance_valid(_battle_lab_overlay):
		_close_battle_lab_overlay()
		return
	if _progression_lab_overlay != null and is_instance_valid(_progression_lab_overlay):
		_close_progression_lab_overlay()
		return
	if _shell_overlay_is_open():
		_go_back()
		return
	if _replay_running:
		_skip_current_replay()
		return
	if _current_screen != SCREEN_HUB:
		_go_back()

func _is_cancel_input(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_cancel"):
		return true
	var key_event := event as InputEventKey
	if key_event == null:
		return false
	if not key_event.pressed or key_event.echo:
		return false
	return key_event.keycode == KEY_ESCAPE or key_event.physical_keycode == KEY_ESCAPE

func _clear_existing_scene() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.free()
func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if size.x <= 0.0 or size.y <= 0.0:
		size = get_viewport_rect().size
	_compact_layout = _should_use_compact_layout()
	ShellSurfacePresenterScript.render(self)
	_render_create_account_dialog()
