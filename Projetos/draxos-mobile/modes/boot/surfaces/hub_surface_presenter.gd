class_name BootHubSurfacePresenter
extends RefCounted

const HubAccountSurfacePresenterScript := preload("res://modes/boot/surfaces/hub_account_surface_presenter.gd")

static func render(host: Node) -> void:
	HubAccountSurfacePresenterScript.render_login(host)
	HubAccountSurfacePresenterScript.render_quick_test(host)
	HubAccountSurfacePresenterScript.render_active_save(host)
	HubAccountSurfacePresenterScript.render_session_status(host)
	HubAccountSurfacePresenterScript.render_update_gate(host)
	HubAccountSurfacePresenterScript.render_screen_links(host)
