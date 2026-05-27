class_name BootBattleSurfacePresenter
extends RefCounted

const BattleVisualMockupScript := preload("res://ui/battle_visual_mockup.gd")

static func render(host: Node) -> void:
	_add_body_text(host, "Batalha server-authoritative: o cliente solicita a luta, recebe o log e apenas apresenta o replay.")
	_add_action_button(host, "Solicitar batalha", "request_battle")
	_add_action_button(host, "Ver resultado", "show_latest_battle")
	var battle_visual: Control = BattleVisualMockupScript.new()
	battle_visual.custom_minimum_size = Vector2(0, 560 if bool(host.get("_compact_layout")) else 720)
	_content_body(host).add_child(battle_visual)
	host.set("_battle_visual", battle_visual)
	var timeline_label := _add_output_label(host, "")
	host.set("_timeline_label", timeline_label)
	if SessionStore.has_battle_log():
		battle_visual.load_battle_log(SessionStore.last_battle_log, SessionStore.last_battle_rewards)
		battle_visual.reveal_all()
		timeline_label.text = battle_visual.get_timeline_text()
	else:
		battle_visual.show_empty_state("Nenhuma batalha carregada. Solicite uma batalha ou busque o ultimo resultado.")
		timeline_label.text = "Nenhuma batalha carregada. Solicite uma batalha ou busque o ultimo resultado."

static func _content_body(host: Node) -> VBoxContainer:
	return host.get("_content_body") as VBoxContainer

static func _add_body_text(host: Node, text: String) -> Label:
	return host.call("_add_body_text", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label

static func _add_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	return host.call("_add_action_button", text, action_id, confirm_message) as Button
