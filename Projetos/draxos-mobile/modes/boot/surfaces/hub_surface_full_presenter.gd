class_name BootHubSurfaceFullPresenter
extends RefCounted

const EntryPresenterScript := preload("res://modes/boot/surfaces/hub_surface_entry_presenter.gd")
const RefugeScenePresenterScript := preload("res://modes/boot/surfaces/hub_surface_refuge_scene_presenter.gd")
const RefugePopupPresenterScript := preload("res://modes/boot/surfaces/hub_surface_refuge_popup_presenter.gd")

static func render_entry(host: Node) -> void:
	EntryPresenterScript.render_entry(host)

static func render_refuge(host: Node) -> void:
	RefugeScenePresenterScript.render_refuge(host)

static func open_refuge_menu_popup(host: Node, menu_id: String) -> bool:
	return RefugePopupPresenterScript.open_refuge_menu_popup(host, menu_id)

static func refresh_open_refuge_menu_popup(host: Node) -> bool:
	return RefugePopupPresenterScript.refresh_open_refuge_menu_popup(host)

static func refuge_context_cta_data(host: Node) -> Dictionary:
	return RefugeScenePresenterScript.refuge_context_cta_data(host)
