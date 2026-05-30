class_name BootHubSurfacePresenter
extends RefCounted

const HubSurfaceFullPresenterScript := preload("res://modes/boot/surfaces/hub_surface_full_presenter.gd")

static func render_entry(host: Node) -> void:
	HubSurfaceFullPresenterScript.render_entry(host)

static func render_refuge(host: Node) -> void:
	HubSurfaceFullPresenterScript.render_refuge(host)

static func open_refuge_menu_popup(host: Node, menu_id: String) -> bool:
	return HubSurfaceFullPresenterScript.open_refuge_menu_popup(host, menu_id)

static func refresh_open_refuge_menu_popup(host: Node) -> bool:
	return HubSurfaceFullPresenterScript.refresh_open_refuge_menu_popup(host)

static func _refuge_context_cta_data(host: Node) -> Dictionary:
	return HubSurfaceFullPresenterScript.refuge_context_cta_data(host)
