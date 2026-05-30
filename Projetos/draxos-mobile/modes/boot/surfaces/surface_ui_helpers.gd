class_name DraxosSurfaceUiHelpers
extends RefCounted

const SessionStoreScript := preload("res://online/session_store.gd")
const BaseSurfacePresenterScript := preload("res://modes/boot/surfaces/base_surface_presenter.gd")
const SocialSurfacePresenterScript := preload("res://modes/boot/surfaces/social_surface_presenter.gd")
const CompetitionSurfacePresenterScript := preload("res://modes/boot/surfaces/competition_surface_presenter.gd")
const ShopSurfacePresenterScript := preload("res://modes/boot/surfaces/shop_surface_presenter.gd")

static func render_base_state(host: Node, collected: Dictionary = {}) -> void:
	BaseSurfacePresenterScript.render_state(host, collected)

static func render_base_playable_panels(host: Node, structures: Array, base: Dictionary, collected: Dictionary) -> void:
	BaseSurfacePresenterScript._render_playable_panels(host, structures, base, collected)

static func base_summary_panel(host: Node, base: Dictionary, collected: Dictionary) -> Control:
	return BaseSurfacePresenterScript._base_summary_panel(host, base, collected)

static func base_map_panel(host: Node, structures: Array) -> Control:
	return BaseSurfacePresenterScript._base_map_panel(host, structures)

static func base_detail_panel(host: Node, structures: Array) -> Control:
	return BaseSurfacePresenterScript._base_detail_panel(host, structures)

static func base_structure_button(host: Node, structure: Dictionary) -> Button:
	return BaseSurfacePresenterScript._base_structure_button(host, structure)

static func select_base_structure(host: Node, structure_id: String) -> void:
	BaseSurfacePresenterScript.select_structure(host, structure_id)

static func ensure_selected_base_structure(host: Node, structures: Array) -> void:
	BaseSurfacePresenterScript._ensure_selected_base_structure(host, structures)

static func base_structure_by_id(structures: Array, structure_id: String) -> Dictionary:
	return BaseSurfacePresenterScript._base_structure_by_id(structures, structure_id)

static func base_panel(host: Node) -> PanelContainer:
	return BaseSurfacePresenterScript._base_panel(host)

static func base_info_panel(host: Node, title_text: String, body_text: String) -> Control:
	return BaseSurfacePresenterScript._base_info_panel(host, title_text, body_text)

static func base_label(host: Node, text: String, color_token: String = "text_secondary", font_size: int = 0) -> Label:
	return BaseSurfacePresenterScript._base_label(host, text, color_token, font_size)

static func base_structure_card_style(structure_id: String, selected: bool) -> StyleBoxFlat:
	return BaseSurfacePresenterScript._base_structure_card_style(structure_id, selected)

static func base_structure_color(structure_id: String) -> Color:
	return BaseSurfacePresenterScript._base_structure_color(structure_id)

static func base_structure_symbol(structure_id: String) -> String:
	return BaseSurfacePresenterScript._base_structure_symbol(structure_id)

static func base_structure_short_label(structure_id: String) -> String:
	return BaseSurfacePresenterScript._base_structure_short_label(structure_id)

static func base_benefit_text(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_benefit_text(structure)

static func base_pending_text(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_pending_text(structure)

static func base_upgrade_text(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_upgrade_text(structure)

static func base_next_level_text(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_next_level_text(structure)

static func base_short_status(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_short_status(structure)

static func base_status_color_token(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_status_color_token(structure)

static func base_structure_tooltip(structure: Dictionary) -> String:
	return BaseSurfacePresenterScript._base_structure_tooltip(structure)

static func can_upgrade_base_structure(host: Node, structure_id: String) -> bool:
	return BaseSurfacePresenterScript.can_upgrade_structure(host, structure_id)

static func active_base_jobs(jobs: Array) -> Array:
	return BaseSurfacePresenterScript._active_base_jobs(jobs)

static func format_cost(cost: Dictionary) -> String:
	return BaseSurfacePresenterScript._format_cost(cost)

static func format_duration(total_seconds: int) -> String:
	return BaseSurfacePresenterScript._format_duration(total_seconds)

static func format_number(value: float) -> String:
	return BaseSurfacePresenterScript._format_number(value)

static func format_resources(resources: Dictionary, include_diamond: bool = true) -> String:
	return BaseSurfacePresenterScript._format_resources(resources, include_diamond)

static func resource_total(resources: Dictionary) -> float:
	return BaseSurfacePresenterScript._resource_total(resources)

static func structure_label(structure_id: String, fallback: String = "") -> String:
	return BaseSurfacePresenterScript._structure_label(structure_id, fallback)

static func render_social_state(host: Node) -> void:
	SocialSurfacePresenterScript.render_state(host)

static func social_identity_panel(host: Node, identity: Dictionary, social_player: Dictionary, active_player: Dictionary) -> Control:
	return SocialSurfacePresenterScript._social_identity_panel(host, identity, social_player, active_player)

static func social_friends_panel(host: Node, friends: Array) -> Control:
	return SocialSurfacePresenterScript._social_friends_panel(host, friends)

static func social_guild_panel(host: Node, guild: Dictionary, members: Array, structures: Array) -> Control:
	return SocialSurfacePresenterScript._social_guild_panel(host, guild, members, structures)

static func social_chat_panel(host: Node, messages: Array) -> Control:
	return SocialSurfacePresenterScript._social_chat_panel(host, messages, true)

static func social_input_text(input: LineEdit, fallback: String = "") -> String:
	if input == null:
		return fallback.strip_edges()
	var text := input.text.strip_edges()
	if text == "":
		return fallback.strip_edges()
	return text

static func default_social_guild_text(host: Node) -> String:
	var last_name := str(host.get("_last_social_guild_name")).strip_edges()
	if last_name != "":
		return last_name
	var guild := _as_dictionary(SessionStore.social_snapshot().get("guild", {}))
	if not guild.is_empty():
		return str(guild.get("name", "")).strip_edges()
	return str(host.call("_default_guild_name"))

static func social_username_text(profile: Dictionary) -> String:
	return SocialSurfacePresenterScript._social_username_text(profile)

static func social_save_badge_text(badge: String) -> String:
	return SocialSurfacePresenterScript._social_save_badge_text(badge)

static func guild_structure_label(structure_id: String) -> String:
	return SocialSurfacePresenterScript._guild_structure_label(structure_id)

static func render_competition_state(host: Node) -> void:
	CompetitionSurfacePresenterScript.render_state(host)

static func render_competition_panels(host: Node, last_battle: Dictionary, matchmaking: Dictionary, ranking: Dictionary) -> void:
	CompetitionSurfacePresenterScript._render_competition_panels(host, last_battle, matchmaking, ranking)

static func competition_last_battle_panel(host: Node, last_battle: Dictionary) -> Control:
	return CompetitionSurfacePresenterScript._competition_last_battle_panel(host, last_battle)

static func competition_matchmaking_panel(host: Node, matchmaking: Dictionary) -> Control:
	return CompetitionSurfacePresenterScript._competition_matchmaking_panel(host, matchmaking)

static func competition_ranking_panel(host: Node, ranking: Dictionary) -> Control:
	return CompetitionSurfacePresenterScript._competition_ranking_panel(host, ranking)

static func competition_entry_name(entry: Dictionary) -> String:
	return CompetitionSurfacePresenterScript._competition_entry_name(entry)

static func competition_result_text(result: String) -> String:
	return CompetitionSurfacePresenterScript._competition_result_text(result)

static func competition_scoring_model_text(model: String) -> String:
	return CompetitionSurfacePresenterScript._competition_scoring_model_text(model)

static func render_monetization_state(host: Node) -> void:
	ShopSurfacePresenterScript.render_state(host)

static func render_shop_panels(host: Node, monetization: Dictionary) -> void:
	ShopSurfacePresenterScript._render_shop_panels(host, monetization)

static func shop_summary_panel(host: Node, summary: Dictionary) -> Control:
	return ShopSurfacePresenterScript._shop_summary_panel(host, summary)

static func shop_product_group_panel(host: Node, title_text: String, products: Array) -> Control:
	return ShopSurfacePresenterScript._shop_product_group_panel(host, title_text, products)

static func shop_reward_group_panel(host: Node, title_text: String, rewards: Array) -> Control:
	return ShopSurfacePresenterScript._shop_reward_group_panel(host, title_text, rewards)

static func shop_product_status_text(product: Dictionary) -> String:
	return ShopSurfacePresenterScript._shop_product_status_text(product)

static func shop_product_status_color(product: Dictionary) -> String:
	return ShopSurfacePresenterScript._shop_product_status_color(product)

static func shop_locked_reason_text(reason: String) -> String:
	return ShopSurfacePresenterScript._shop_locked_reason_text(reason)

static func shop_effect_text(effect: Dictionary) -> String:
	return ShopSurfacePresenterScript._shop_effect_text(effect)

static func format_shop_delta(delta: Dictionary, empty_text: String) -> String:
	return ShopSurfacePresenterScript._format_shop_delta(delta, empty_text)

static func shop_product_by_id(product_id: String) -> Dictionary:
	return ShopSurfacePresenterScript.product_by_id(product_id)

static func shop_reward_by_id(reward_id: String) -> Dictionary:
	return ShopSurfacePresenterScript.reward_by_id(reward_id)

static func shop_purchase_message(product_id: String, body: Dictionary) -> String:
	return ShopSurfacePresenterScript.purchase_message(product_id, body)

static func _as_dictionary(value: Variant) -> Dictionary:
	if value is Dictionary:
		return value
	return {}
