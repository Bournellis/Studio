class_name DraxosModeShellLauncher
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")
const AppShellRouteContractScript := preload("res://modes/boot/ui/app_shell_route_contract.gd")
const ModeShellRegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")

func open(host: Node, mode_id: String = "") -> void:
	host.set("_active_mode_id", ModeShellRegistryScript.normalize_mode_id(mode_id))
	host.call("_show_screen", AppShellRouteContractScript.ROUTE_MODE_SHELL)

func render(host: Node) -> void:
	var mode_id := ModeShellRegistryScript.normalize_mode_id(str(host.get("_active_mode_id")))
	var content_title := host.get("_content_title") as Label
	if content_title != null:
		content_title.text = ModeShellRegistryScript.display_name(mode_id)
	var status_label := host.get("_status_label") as Label
	if status_label != null:
		status_label.text = str(host.call("_session_status_text"))
	var detail_label := host.get("_detail_label") as Label
	if detail_label != null:
		detail_label.text = "Dev-only: progresso local do modo. Recompensas reais so entram pelo Reward Bridge."
	if bool(host.call("_route_shows_app_chrome", str(host.get("_current_screen")))):
		_render_content_body(host, mode_id)
		return
	_render_fullscreen(host, mode_id)

func _render_content_body(host: Node, mode_id: String) -> void:
	var screen := _instantiate_mode_screen(host, mode_id)
	if screen != null:
		screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
		host.call("_add_content_control", screen)
		return
	_set_error_text(host, "Mode dev indisponivel nesta build.")
	host.call("_add_body_text", "Area reservada para desenvolvimento interno. Recompensas desativadas.")
	host.call("_add_action_button", "Voltar ao Refugio", AppShellActionContractScript.ACTION_RETURN_REFUGE)

func _render_fullscreen(host: Node, mode_id: String) -> void:
	var overlay := host.call("_create_mode_fullscreen_overlay") as Control
	if overlay == null:
		return
	var screen := _instantiate_mode_screen(host, mode_id)
	if screen != null:
		screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		screen.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		screen.size_flags_vertical = Control.SIZE_EXPAND_FILL
		overlay.add_child(screen)
		return
	overlay.add_child(_fullscreen_fallback(host))

func _instantiate_mode_screen(host: Node, mode_id: String) -> Control:
	if not ModeShellRegistryScript.is_available(mode_id):
		return null
	var script: Script = load(ModeShellRegistryScript.screen_path(mode_id))
	if script == null or not script.can_instantiate():
		return null
	var screen: Control = script.new()
	_configure_integrated_alpha(host, mode_id, screen)
	if screen.has_signal("close_requested"):
		screen.connect("close_requested", Callable(host, "_return_to_refuge"))
	return screen

func _configure_integrated_alpha(host: Node, mode_id: String, screen: Control) -> void:
	if not bool(host.call("_openworld_integrated_alpha_enabled", mode_id)):
		return
	if not screen.has_method("configure_integrated_alpha"):
		return
	screen.call("configure_integrated_alpha", SupabaseClient, SessionStore, SessionStore.access_token)

func _fullscreen_fallback(host: Node) -> Control:
	var fallback := VBoxContainer.new()
	fallback.name = "ModeUnavailableFallback"
	fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fallback.alignment = BoxContainer.ALIGNMENT_CENTER
	fallback.add_theme_constant_override("separation", 12)
	var label := Label.new()
	label.text = "Mode dev indisponivel nesta build."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", UiTokens.color("text_primary"))
	fallback.add_child(label)
	var back := Button.new()
	back.text = "Voltar ao Refugio"
	back.pressed.connect(Callable(host, "_return_to_refuge"))
	if host.has_method("_prepare_touch_button"):
		host.call("_prepare_touch_button", back)
	if host.has_method("_apply_action_button_style"):
		host.call("_apply_action_button_style", back, AppShellActionContractScript.ACTION_RETURN_REFUGE, "refuge")
	fallback.add_child(back)
	return fallback

func _set_error_text(host: Node, message: String) -> void:
	var error_label := host.get("_error_label") as Label
	if error_label != null:
		error_label.text = message
