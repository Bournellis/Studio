class_name DraxosModeShellOverlayHostContract
extends RefCounted

const METHOD_RENDER_ROUTE_CONTENTS := "_render_route_contents"
const METHOD_SYNC_STATUS_FROM_SESSION := "_sync_status_from_session"
const METHOD_ACTION_CONTEXT := "_action_context"
const METHOD_EMIT_CLIENT_EVENT := "_emit_client_event"
const METHOD_SYNC_SOCIAL_AUTO_SYNC_FOR_ROUTE := "_sync_social_auto_sync_for_route"
const METHOD_PUBLISH_WEB_DIAGNOSTICS_STATE := "_publish_web_diagnostics_state"
const METHOD_CLEAR_BATTLE_FULLSCREEN_OVERLAY := "_clear_battle_fullscreen_overlay"
const METHOD_CLEAR_SHELL_OVERLAY_TRANSIENT_BUSY := "_clear_shell_overlay_transient_busy"
const METHOD_PREPARE_TOUCH_BUTTON := "_prepare_touch_button"
const METHOD_APPLY_ACTION_BUTTON_STYLE := "_apply_action_button_style"
const METHOD_CLEAR_SHELL_OVERLAY_BUSY_EXCEPT_ROUTE := "_clear_shell_overlay_busy_except_route"
const METHOD_APPLY_ORIENTATION_FOR_ROUTE := "_apply_orientation_for_route"
const METHOD_CLEAR_CONTENT_BODY := "_clear_content_body"
const METHOD_SYNC_BUTTONS := "_sync_buttons"
const METHOD_ON_CONFIRMATION_CONFIRMED := "_on_confirmation_confirmed"

static func render_route_contents(host: Node, route_id: String) -> void:
	if host != null:
		host.call(METHOD_RENDER_ROUTE_CONTENTS, route_id)

static func sync_status_from_session(host: Node) -> void:
	if host != null:
		host.call(METHOD_SYNC_STATUS_FROM_SESSION)

static func action_context(host: Node) -> Dictionary:
	if host == null:
		return {}
	var value: Variant = host.call(METHOD_ACTION_CONTEXT)
	return Dictionary(value) if value is Dictionary else {}

static func emit_client_event(host: Node, event_type: String, payload: Dictionary) -> void:
	if host != null:
		host.call(METHOD_EMIT_CLIENT_EVENT, event_type, payload)

static func sync_social_auto_sync_for_route(host: Node) -> void:
	if host != null:
		host.call(METHOD_SYNC_SOCIAL_AUTO_SYNC_FOR_ROUTE)

static func publish_web_diagnostics(host: Node) -> void:
	if _has(host, METHOD_PUBLISH_WEB_DIAGNOSTICS_STATE):
		host.call(METHOD_PUBLISH_WEB_DIAGNOSTICS_STATE)

static func publish_web_diagnostics_deferred(host: Node) -> void:
	if _has(host, METHOD_PUBLISH_WEB_DIAGNOSTICS_STATE):
		host.call_deferred(METHOD_PUBLISH_WEB_DIAGNOSTICS_STATE)

static func clear_battle_fullscreen_overlay(host: Node) -> void:
	if host != null:
		host.call(METHOD_CLEAR_BATTLE_FULLSCREEN_OVERLAY)

static func clear_shell_overlay_transient_busy(host: Node) -> void:
	if _has(host, METHOD_CLEAR_SHELL_OVERLAY_TRANSIENT_BUSY):
		host.call(METHOD_CLEAR_SHELL_OVERLAY_TRANSIENT_BUSY)

static func prepare_touch_button(host: Node, button: Button) -> void:
	if _has(host, METHOD_PREPARE_TOUCH_BUTTON):
		host.call(METHOD_PREPARE_TOUCH_BUTTON, button)

static func apply_action_button_style(host: Node, button: Button, style_id: String) -> void:
	if _has(host, METHOD_APPLY_ACTION_BUTTON_STYLE):
		host.call(METHOD_APPLY_ACTION_BUTTON_STYLE, button, style_id)

static func clear_shell_overlay_busy_except_route(host: Node, route_id: String) -> void:
	if _has(host, METHOD_CLEAR_SHELL_OVERLAY_BUSY_EXCEPT_ROUTE):
		host.call(METHOD_CLEAR_SHELL_OVERLAY_BUSY_EXCEPT_ROUTE, route_id)

static func apply_orientation_for_mode_shell(host: Node, mode_shell_route: String) -> void:
	if host != null:
		host.call(METHOD_APPLY_ORIENTATION_FOR_ROUTE, mode_shell_route)

static func clear_content_body(host: Node) -> void:
	if host != null:
		host.call(METHOD_CLEAR_CONTENT_BODY)

static func sync_buttons(host: Node) -> void:
	if host != null:
		host.call(METHOD_SYNC_BUTTONS)

static func on_confirmation_confirmed(host: Node) -> void:
	if host != null:
		host.call(METHOD_ON_CONFIRMATION_CONFIRMED)

static func _has(host: Node, method_name: String) -> bool:
	return host != null and host.has_method(method_name)
