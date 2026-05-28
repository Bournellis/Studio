class_name BootShopSurfacePresenter
extends RefCounted

const AppShellActionContractScript := preload("res://modes/boot/ui/app_shell_action_contract.gd")

const RESOURCE_KEYS := ["almas", "energia", "sangue", "cristais", "ossos", "diamante"]

const SHOP_REDEEM_PRODUCTS := [
	{
		"id": "alpha_redeem_small",
		"label": "Redeem pequeno",
		"confirm": "Resgatar o pacote diario pequeno de Diamante neste save?",
		"tooltip": "Pacote diario pequeno: entrega Diamante para testar compras leves no save ativo. Reseta a meia-noite de Sao Paulo.",
	},
	{
		"id": "alpha_redeem_medium",
		"label": "Redeem medio",
		"confirm": "Resgatar o pacote diario medio de Diamante neste save?",
		"tooltip": "Pacote diario medio: entrega Diamante para comprar alguns recursos e acelerar um teste curto.",
	},
	{
		"id": "alpha_redeem_large",
		"label": "Redeem grande",
		"confirm": "Resgatar o pacote diario grande de Diamante neste save?",
		"tooltip": "Pacote diario grande: entrega Diamante para testar compras maiores sem resetar o save.",
	},
	{
		"id": "alpha_redeem_premium",
		"label": "Redeem premium",
		"confirm": "Resgatar o pacote diario premium de Diamante neste save?",
		"tooltip": "Pacote diario premium: entrega Diamante suficiente para Battle Pass, fila dupla e conveniencias alpha.",
	},
]

const SHOP_PURCHASE_PRODUCTS := [
	{
		"id": "alpha_battle_pass_premium",
		"label": "Comprar Battle Pass",
		"confirm": "Comprar a trilha premium do Battle Pass alpha com Diamante?",
		"tooltip": "Libera recompensas premium do Battle Pass neste save. Nao pode ser comprado duas vezes.",
	},
	{
		"id": "alpha_double_construction_queue",
		"label": "Comprar fila dupla",
		"confirm": "Comprar a fila dupla de construcao do Refugio com Diamante?",
		"tooltip": "Aumenta a fila do Refugio para dois upgrades ativos ao mesmo tempo neste save.",
	},
	{
		"id": "alpha_energy_pack_small",
		"label": "Comprar Energia",
		"confirm": "Gastar Diamante para comprar Energia no save ativo?",
		"tooltip": "Converte Diamante em Energia para continuar upgrades de predios.",
	},
	{
		"id": "alpha_resource_pack_medium",
		"label": "Comprar recursos",
		"confirm": "Gastar Diamante para comprar o pacote de recursos alpha?",
		"tooltip": "Converte Diamante em Almas, Energia, Sangue, Cristais e Ossos para simular progresso comprado.",
	},
]

static func render(host: Node) -> void:
	_add_body_text(host, "Loja alpha funcional: redeems diarios de Diamante, compras de progresso, Battle Pass e conveniencias por save.")
	var refresh_button := _add_action_button(host, "Atualizar loja", AppShellActionContractScript.ACTION_SHOW_SHOP)
	refresh_button.tooltip_text = "Busca saldo, produtos, resgates diarios e recompensas atuais no servidor."
	_add_section_label(host, "Redeems diarios")
	for spec: Dictionary in SHOP_REDEEM_PRODUCTS:
		var redeem_button := _add_action_button(
			host,
			str(spec.get("label", "")),
			AppShellActionContractScript.shop_purchase_action(str(spec.get("id", ""))),
			str(spec.get("confirm", ""))
		)
		redeem_button.tooltip_text = str(spec.get("tooltip", ""))
	_add_section_label(host, "Compras alpha")
	for spec: Dictionary in SHOP_PURCHASE_PRODUCTS:
		var product_button := _add_action_button(
			host,
			str(spec.get("label", "")),
			AppShellActionContractScript.shop_purchase_action(str(spec.get("id", ""))),
			str(spec.get("confirm", ""))
		)
		product_button.tooltip_text = str(spec.get("tooltip", ""))
	_add_section_label(host, "Recompensas")
	var daily_button := _add_action_button(
		host,
		"Claim coleta diaria",
		AppShellActionContractScript.claim_reward_action(AppShellActionContractScript.REWARD_DAILY_COLLECT_BASE),
		"Resgatar a recompensa diaria de coleta do Refugio?"
	)
	daily_button.tooltip_text = "Recompensa diaria server-authoritative ligada a XP, recursos e progresso de Battle Pass."
	host.set("_timeline_label", _add_output_label(host, ""))
	var shop_state_container := VBoxContainer.new()
	shop_state_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_state_container.add_theme_constant_override("separation", 10)
	_content_body(host).add_child(shop_state_container)
	host.set("_shop_state_container", shop_state_container)
	render_state(host)

static func render_state(host: Node) -> void:
	var timeline := _timeline_label(host)
	if timeline == null:
		return
	var container := _shop_state_container(host)
	if container != null:
		_clear_node_children(container)
	var monetization := SessionStore.monetization_state
	if monetization.is_empty():
		timeline.text = "Loja alpha ainda nao carregada. Use Atualizar loja."
		if container != null:
			container.add_child(_shop_info_panel(
				host,
				"Loja nao carregada",
				"Atualize a Loja para ver saldo de Diamante, produtos, resgates diarios e recompensas disponiveis."
			))
		return

	var lines := PackedStringArray()
	var summary := _as_dictionary(monetization.get("shop_summary", {}))
	lines.append("Loja alpha server-authoritative")
	lines.append("Recursos: %s" % _format_resources(SessionStore.resources))
	if not summary.is_empty():
		lines.append("Diamante: %s | Premium: %s | Redeems hoje: %s/%s" % [
			str(summary.get("diamond_balance", SessionStore.resources.get("diamante", 0))),
			"ativo" if bool(summary.get("premium_unlocked", false)) else "inativo",
			str(summary.get("daily_redeems_claimed", 0)),
			str(summary.get("daily_redeems_total", 0)),
		])
		lines.append("Reset diario: %s (%s)" % [
			str(summary.get("daily_redeem_period_key", "")),
			str(summary.get("reset_timezone", "America/Sao_Paulo")),
		])
	var battle_pass := _as_dictionary(monetization.get("battle_pass", {}))
	var pass_config := _as_dictionary(battle_pass.get("pass", {}))
	var progress := _as_dictionary(battle_pass.get("progress", {}))
	lines.append("Battle Pass: %s | XP %s | premium=%s" % [
		str(pass_config.get("display_name", pass_config.get("id", ""))),
		str(progress.get("pass_xp", 0)),
		str(progress.get("premium_unlocked", false)),
	])
	var daily_rewards := _as_array(monetization.get("daily_rewards", []))
	var products := _as_array(monetization.get("alpha_products", []))
	lines.append("Produtos alpha: %d | Recompensas diarias: %d" % [products.size(), daily_rewards.size()])
	timeline.text = "\n".join(lines)
	if container != null:
		_render_shop_panels(host, monetization)
	host.call("_sync_buttons")

static func product_by_id(product_id: String) -> Dictionary:
	var monetization := SessionStore.monetization_state
	for item: Variant in _as_array(monetization.get("alpha_products", [])):
		var product := _as_dictionary(item)
		if str(product.get("id", "")) == product_id:
			return product
	return {}

static func reward_by_id(reward_id: String) -> Dictionary:
	var monetization := SessionStore.monetization_state
	for group_key: String in ["daily_rewards", "weekly_rewards"]:
		for item: Variant in _as_array(monetization.get(group_key, [])):
			var reward := _as_dictionary(item)
			if str(reward.get("id", "")) == reward_id:
				return reward
	var battle_pass := _as_dictionary(monetization.get("battle_pass", {}))
	for item: Variant in _as_array(battle_pass.get("rewards", [])):
		var reward := _as_dictionary(item)
		if str(reward.get("id", "")) == reward_id:
			return reward
	return {}

static func purchase_message(product_id: String, body: Dictionary) -> String:
	if bool(body.get("already_redeemed", false)):
		return "Redeem diario ja havia sido resgatado neste save."
	if bool(body.get("already_owned", false)):
		return "Produto ja estava ativo neste save."
	var purchase := _as_dictionary(body.get("purchase", {}))
	var label := str(purchase.get("label", product_id))
	var delta := _as_dictionary(purchase.get("delta", {}))
	if delta.is_empty():
		return "%s aplicado." % label
	return "%s aplicado: %s." % [label, _format_shop_delta(delta, "sem mudanca de recurso")]

static func _render_shop_panels(host: Node, monetization: Dictionary) -> void:
	var container := _shop_state_container(host)
	if container == null:
		return
	var panels: Array = []
	var summary := _as_dictionary(monetization.get("shop_summary", {}))
	if not summary.is_empty():
		panels.append(_shop_summary_panel(host, summary))

	var redeem_products: Array = []
	var purchase_products: Array = []
	for item: Variant in _as_array(monetization.get("alpha_products", [])):
		var product := _as_dictionary(item)
		if product.is_empty():
			continue
		if bool(product.get("daily_redeem", false)):
			redeem_products.append(product)
		else:
			purchase_products.append(product)
	panels.append(_shop_product_group_panel(host, "Redeems diarios de Diamante", redeem_products))
	panels.append(_shop_product_group_panel(host, "Compras e conveniencias", purchase_products))
	panels.append(_shop_reward_group_panel(host, "Recompensas diarias", _as_array(monetization.get("daily_rewards", []))))

	var battle_pass := _as_dictionary(monetization.get("battle_pass", {}))
	panels.append(_shop_reward_group_panel(host, "Battle Pass", _as_array(battle_pass.get("rewards", []))))
	host.call("_add_responsive_panel_layout", container, panels, 2)

static func _shop_summary_panel(host: Node, summary: Dictionary) -> Control:
	var panel := _shop_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_shop_label(host, "Resumo da Loja", "text_primary", 17))
	box.add_child(_shop_label(host, "Diamante: %s | Moeda principal do alpha: %s" % [
		str(summary.get("diamond_balance", 0)),
		str(summary.get("currency", "diamante")).capitalize(),
	], "text_secondary"))
	box.add_child(_shop_label(host, "Premium: %s | Redeems hoje: %s/%s | Reset: meia-noite America/Sao_Paulo" % [
		"ativo" if bool(summary.get("premium_unlocked", false)) else "inativo",
		str(summary.get("daily_redeems_claimed", 0)),
		str(summary.get("daily_redeems_total", 0)),
	], "text_secondary"))
	var owned := _as_array(summary.get("convenience_owned", []))
	if owned.is_empty():
		box.add_child(_shop_label(host, "Conveniencias ativas: nenhuma.", "text_secondary"))
	else:
		var owned_ids := PackedStringArray()
		for item: Variant in owned:
			owned_ids.append(str(item))
		box.add_child(_shop_label(host, "Conveniencias ativas: %s" % ", ".join(owned_ids), "status_success"))
	return panel

static func _shop_product_group_panel(host: Node, title_text: String, products: Array) -> Control:
	var panel := _shop_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_shop_label(host, title_text, "text_primary", 17))
	if products.is_empty():
		box.add_child(_shop_label(host, "Nenhum produto retornado pelo servidor.", "text_secondary"))
		return panel
	for item: Variant in products:
		var product := _as_dictionary(item)
		if product.is_empty():
			continue
		box.add_child(_shop_label(host, "%s | %s" % [
			str(product.get("label", product.get("id", ""))),
			_shop_product_status_text(product),
		], _shop_product_status_color(product)))
		box.add_child(_shop_label(host, "Custo: %s | Recebe: %s | Efeito: %s" % [
			_format_shop_delta(_as_dictionary(product.get("cost", {})), "gratis"),
			_format_shop_delta(_as_dictionary(product.get("resources", {})), "nenhum recurso direto"),
			_shop_effect_text(_as_dictionary(product.get("effect", {}))),
		], "text_secondary"))
		var description := str(product.get("description", ""))
		if description != "":
			box.add_child(_shop_label(host, description, "text_secondary"))
	return panel

static func _shop_reward_group_panel(host: Node, title_text: String, rewards: Array) -> Control:
	var panel := _shop_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	box.add_child(_shop_label(host, title_text, "text_primary", 17))
	if rewards.is_empty():
		box.add_child(_shop_label(host, "Nenhuma recompensa retornada pelo servidor.", "text_secondary"))
		return panel
	for item: Variant in rewards:
		var reward := _as_dictionary(item)
		if reward.is_empty():
			continue
		var status_text := "resgatada" if bool(reward.get("claimed", false)) else "disponivel"
		var color_token := "status_success" if not bool(reward.get("claimed", false)) else "text_secondary"
		if bool(reward.get("premium_required", false)):
			status_text += " | premium"
		box.add_child(_shop_label(host, "%s | XP %s | %s" % [
			str(reward.get("label", reward.get("id", ""))),
			str(reward.get("xp", 0)),
			status_text,
		], color_token))
		box.add_child(_shop_label(host, "Recursos: %s | Periodo: %s" % [
			_format_shop_delta(_as_dictionary(reward.get("resources", {})), "nenhum recurso"),
			str(reward.get("period_key", "")),
		], "text_secondary"))
	return panel

static func _shop_product_status_text(product: Dictionary) -> String:
	if bool(product.get("already_redeemed", false)):
		return "resgatado hoje"
	if bool(product.get("already_owned", false)):
		return "ja ativo"
	if bool(product.get("can_purchase", true)):
		return "disponivel"
	return _shop_locked_reason_text(str(product.get("locked_reason", "")))

static func _shop_product_status_color(product: Dictionary) -> String:
	if bool(product.get("can_purchase", true)):
		return "status_success"
	if bool(product.get("already_redeemed", false)) or bool(product.get("already_owned", false)):
		return "text_secondary"
	return "status_warning"

static func _shop_locked_reason_text(reason: String) -> String:
	match reason:
		"DAILY_REDEEM_ALREADY_CLAIMED":
			return "resgatado hoje"
		"ALREADY_OWNED":
			return "ja ativo"
		"INSUFFICIENT_RESOURCES":
			return "Diamante insuficiente"
		"":
			return "indisponivel"
	return reason

static func _shop_effect_text(effect: Dictionary) -> String:
	if effect.is_empty():
		return "nenhum efeito persistente"
	match str(effect.get("type", "")):
		"construction_slots":
			return "fila do Refugio: %s slots" % str(effect.get("value", 0))
	return str(effect)

static func _format_shop_delta(delta: Dictionary, empty_text: String) -> String:
	if delta.is_empty():
		return empty_text
	return _format_cost(delta)

static func _format_cost(cost: Dictionary) -> String:
	if cost.is_empty():
		return "-"
	var parts := PackedStringArray()
	for key: String in cost.keys():
		parts.append("%s %s" % [str(key).capitalize(), _format_number(float(cost.get(key, 0.0)))])
	return " | ".join(parts)

static func _format_number(value: float) -> String:
	if abs(value - round(value)) < 0.005:
		return str(int(round(value)))
	return "%.2f" % value

static func _format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	var parts := PackedStringArray()
	for key: String in RESOURCE_KEYS:
		if key == "diamante" and not include_diamond:
			continue
		parts.append("%s %s" % [key.capitalize(), str(resources.get(key, 0))])
	return " | ".join(parts)

static func _shop_panel(host: Node) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _panel_style(host, "bg_panel", "border_default"))
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return panel

static func _shop_info_panel(host: Node, title_text: String, body_text: String) -> Control:
	var panel := _shop_panel(host)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	panel.add_child(box)
	box.add_child(_shop_label(host, title_text, "text_primary", 17))
	box.add_child(_shop_label(host, body_text, "text_secondary"))
	return panel

static func _shop_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", UiTokens.color(color_token))
	if font_size > 0:
		label.add_theme_font_size_override("font_size", max(12, font_size - 1) if _compact_layout(host) else font_size)
	elif _compact_layout(host):
		label.add_theme_font_size_override("font_size", 13)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

static func _content_body(host: Node) -> VBoxContainer:
	return host.get("_content_body") as VBoxContainer

static func _timeline_label(host: Node) -> Label:
	return host.get("_timeline_label") as Label

static func _shop_state_container(host: Node) -> VBoxContainer:
	return host.get("_shop_state_container") as VBoxContainer

static func _compact_layout(host: Node) -> bool:
	return bool(host.get("_compact_layout"))

static func _add_section_label(host: Node, text: String) -> Label:
	return host.call("_add_section_label", text) as Label

static func _add_body_text(host: Node, text: String) -> Label:
	return host.call("_add_body_text", text) as Label

static func _add_output_label(host: Node, text: String) -> Label:
	return host.call("_add_output_label", text) as Label

static func _add_action_button(host: Node, text: String, action_id: String, confirm_message: String = "") -> Button:
	return host.call("_add_action_button", text, action_id, confirm_message) as Button

static func _clear_node_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

static func _panel_style(host: Node, bg_token: String, border_token: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UiTokens.color(bg_token)
	style.border_color = UiTokens.color(border_token)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10 if _compact_layout(host) else 14
	style.content_margin_right = 10 if _compact_layout(host) else 14
	style.content_margin_top = 8 if _compact_layout(host) else 12
	style.content_margin_bottom = 8 if _compact_layout(host) else 12
	return style

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return Dictionary(value)
	return {}

static func _as_array(value: Variant) -> Array:
	if value is Array:
		return Array(value)
	return []
