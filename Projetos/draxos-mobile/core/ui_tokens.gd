extends Node

const COLORS: Dictionary = {
	"bg_deep": Color("#080B10"),
	"bg_void": Color("#040507"),
	"bg_shell": Color("#0B0D12"),
	"bg_panel": Color("#151B22"),
	"bg_panel_alt": Color("#202832"),
	"bg_elevated": Color("#1A2028"),
	"bg_pressed": Color("#242C36"),
	"bg_blood_wash": Color("#26070B"),
	"border_default": Color("#405060"),
	"border_active": Color("#6FA6C8"),
	"border_subtle": Color("#26313D"),
	"border_blood": Color("#6D1D25"),
	"border_gold": Color("#806B36"),
	"text_primary": Color("#F0EEE5"),
	"text_secondary": Color("#AEB7BF"),
	"text_muted": Color("#77818A"),
	"text_on_accent": Color("#FFF6EA"),
	"accent_astral": Color("#5DD4C8"),
	"accent_blood": Color("#B95757"),
	"accent_crimson": Color("#D53F4A"),
	"accent_ritual": Color("#A76DFF"),
	"accent_bone": Color("#D6C08A"),
	"accent_ember": Color("#E08442"),
	"accent_refuge": Color("#5DD4C8"),
	"accent_battle": Color("#B95757"),
	"accent_social": Color("#6FBF88"),
	"accent_competition": Color("#D6A84F"),
	"accent_shop": Color("#D6C08A"),
	"accent_account": Color("#6FA6C8"),
	"rarity_mvp": Color("#C8B15A"),
	"status_success": Color("#66B56F"),
	"status_warning": Color("#D6A84F"),
	"status_error": Color("#D86D6D"),
	"placeholder": Color("#2B3440")
}

const TEXT_STYLES: Dictionary = {
	"title": {"font_size": 28, "color": "text_primary"},
	"app_title": {"font_size": 26, "color": "text_primary"},
	"section": {"font_size": 20, "color": "text_primary"},
	"body": {"font_size": 16, "color": "text_secondary"},
	"caption": {"font_size": 13, "color": "text_muted"},
	"button": {"font_size": 17, "color": "text_primary"},
	"cta": {"font_size": 18, "color": "text_on_accent"}
}

const PANEL_STYLES: Dictionary = {
	"default": {
		"background": "bg_panel",
		"border": "border_default",
		"radius": 8,
		"border_width": 1,
		"compact_margin": 12,
		"regular_margin": 16
	},
	"shell_header": {
		"background": "bg_panel",
		"border": "border_blood",
		"radius": 8,
		"border_width": 1,
		"compact_margin": 12,
		"regular_margin": 16
	},
	"shell_content": {
		"background": "bg_panel_alt",
		"border": "border_subtle",
		"radius": 8,
		"border_width": 1,
		"compact_margin": 10,
		"regular_margin": 14
	},
	"elevated": {
		"background": "bg_elevated",
		"border": "border_active",
		"radius": 8,
		"border_width": 1,
		"compact_margin": 12,
		"regular_margin": 16
	},
	"blood": {
		"background": "bg_blood_wash",
		"border": "border_blood",
		"radius": 8,
		"border_width": 1,
		"compact_margin": 12,
		"regular_margin": 16
	}
}

const BUTTON_STYLES: Dictionary = {
	"secondary": {
		"normal": "bg_panel",
		"hover": "bg_elevated",
		"pressed": "bg_pressed",
		"border": "border_default",
		"border_focus": "border_active",
		"font": "text_primary"
	},
	"cta": {
		"normal": "accent_blood",
		"hover": "accent_crimson",
		"pressed": "border_blood",
		"border": "border_gold",
		"border_focus": "accent_bone",
		"font": "text_on_accent"
	}
}

const SURFACE_ACCENTS: Dictionary = {
	"entry": "accent_blood",
	"refuge": "accent_refuge",
	"base": "accent_refuge",
	"base_management": "accent_refuge",
	"account": "accent_account",
	"social": "accent_social",
	"competition": "accent_competition",
	"shop": "accent_shop",
	"battle_entry": "accent_battle",
	"battle_running": "accent_battle",
	"battle_summary": "accent_bone",
	"battle_logs": "accent_battle",
	"battle_lab": "accent_battle",
	"progression_lab": "accent_ritual"
}

const ACTION_ACCENTS: Dictionary = {
	"enter_refuge": "accent_refuge",
	"show_base": "accent_refuge",
	"collect_base": "accent_refuge",
	"buy_energy_pack_alpha": "accent_refuge",
	"show_crafting": "accent_refuge",
	"crush_bones": "accent_refuge",
	"craft_health_potion": "accent_refuge",
	"show_preparation": "accent_refuge",
	"equip_health_potion": "accent_refuge",
	"unequip_potion": "accent_refuge",
	"enable_potion_default": "accent_refuge",
	"disable_potion": "accent_refuge",
	"open_arena": "accent_blood",
	"arena_start_tutorial": "accent_blood",
	"arena_start_early": "accent_blood",
	"arena_lock_loadout": "accent_refuge",
	"arena_resolve_duel": "accent_battle",
	"arena_claim_summary": "accent_bone",
	"request_battle": "accent_battle",
	"show_latest_battle": "accent_battle",
	"show_battle_history": "accent_battle",
	"skip_battle_replay": "accent_battle",
	"replay_latest_battle": "accent_battle",
	"show_current_battle_logs": "accent_battle",
	"return_battle_summary": "accent_battle",
	"return_refuge": "accent_refuge",
	"show_social": "accent_social",
	"copy_social_username": "accent_social",
	"add_friend": "accent_social",
	"create_guild": "accent_social",
	"join_guild": "accent_social",
	"send_guild_chat": "accent_social",
	"show_matchmaking": "accent_competition",
	"show_ranking": "accent_competition",
	"show_shop": "accent_shop",
	"buy_premium_alpha": "accent_shop",
	"grant_diamond_alpha": "accent_shop",
	"claim_daily_reward": "accent_shop",
	"email_sign_in": "accent_account",
	"email_sign_up": "accent_account",
	"open_create_account": "accent_account",
	"refresh_session": "accent_account",
	"enter_guest": "accent_account",
	"open_battle_lab": "accent_battle",
	"open_progression_lab": "accent_ritual",
	"reset_session": "accent_blood",
	"reset_active_save": "accent_blood"
}

const ACTION_ACCENT_PREFIXES: Dictionary = {
	"select_base_structure:": "accent_refuge",
	"upgrade_base_structure:": "accent_refuge",
	"shop_purchase:": "accent_shop",
	"claim_reward:": "accent_shop",
	"enable_spell_behavior:": "accent_refuge",
	"disable_spell_behavior:": "accent_refuge",
	"arena_choose_buff:": "accent_ritual",
	"battle_replay:": "accent_battle"
}

const CTA_ACTIONS: Dictionary = {
	"enter_refuge": true,
	"email_sign_in": true,
	"open_arena": true,
	"request_battle": true,
	"show_latest_battle": true,
	"return_refuge": true,
	"collect_base": true,
	"send_guild_chat": true
}

const CTA_ACTION_PREFIXES: Dictionary = {
	"upgrade_base_structure:": true,
	"shop_purchase:": true,
	"claim_reward:": true
}

func color(token: String, fallback: Color = Color.WHITE) -> Color:
	return Color(COLORS.get(token, fallback))

func has_color(token: String) -> bool:
	return COLORS.has(token)

func text_style(style_id: String) -> Dictionary:
	return Dictionary(TEXT_STYLES.get(style_id, TEXT_STYLES.get("body", {}))).duplicate(true)

func panel_style(style_id: String = "default", compact: bool = false) -> StyleBoxFlat:
	var data := Dictionary(PANEL_STYLES.get(style_id, PANEL_STYLES.get("default", {})))
	var margin := int(data.get("compact_margin", 10) if compact else data.get("regular_margin", 14))
	return panel_style_from_tokens(
		str(data.get("background", "bg_panel")),
		str(data.get("border", "border_default")),
		compact,
		"",
		int(data.get("border_width", 1)),
		int(data.get("radius", 8)),
		margin
	)

func panel_style_from_tokens(
	background_token: String,
	border_token: String,
	compact: bool = false,
	accent_token: String = "",
	border_width: int = 1,
	radius: int = 8,
	margin_override: int = -1
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var resolved_border := border_token
	if resolved_border == "border_default" and accent_token != "" and has_color(accent_token):
		resolved_border = accent_token
	style.bg_color = color(background_token)
	if accent_token != "" and has_color(accent_token):
		style.bg_color = style.bg_color.lerp(color(accent_token), 0.035)
	style.border_color = color(resolved_border)
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	var margin := margin_override
	if margin < 0:
		margin = 10 if compact else 14
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = max(8, margin - 2)
	style.content_margin_bottom = max(8, margin - 2)
	return style

func surface_panel_style(surface_id: String, compact: bool = false, background_token: String = "bg_panel", border_token: String = "border_default") -> StyleBoxFlat:
	return panel_style_from_tokens(background_token, border_token, compact, surface_accent_token(surface_id, border_token))

func button_style(style_id: String = "secondary", state: String = "normal", accent_token: String = "") -> StyleBoxFlat:
	var data := Dictionary(BUTTON_STYLES.get(style_id, BUTTON_STYLES.get("secondary", {})))
	var style := StyleBoxFlat.new()
	style.bg_color = color(str(data.get(state, data.get("normal", "bg_panel"))))
	style.border_color = color(str(data.get("border_focus", data.get("border", "border_default"))) if state != "normal" else str(data.get("border", "border_default")))
	if accent_token != "" and has_color(accent_token):
		var accent_color := color(accent_token)
		style.border_color = accent_color.lightened(0.16 if style_id == "cta" else 0.0)
		if style_id == "cta":
			match state:
				"pressed":
					style.bg_color = accent_color.darkened(0.42)
				"hover":
					style.bg_color = accent_color.darkened(0.18)
				_:
					style.bg_color = accent_color.darkened(0.30)
		elif state != "normal":
			style.bg_color = style.bg_color.lerp(accent_color, 0.14)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func surface_accent_token(surface_id: String, fallback: String = "border_default") -> String:
	var normalized := surface_id.strip_edges()
	if normalized == "":
		return fallback
	return str(SURFACE_ACCENTS.get(normalized, fallback))

func surface_accent_color(surface_id: String, fallback: String = "border_default") -> Color:
	return color(surface_accent_token(surface_id, fallback))

func action_accent_token(action_id: String, surface_id: String = "", fallback: String = "border_default") -> String:
	var normalized := action_id.strip_edges()
	if ACTION_ACCENTS.has(normalized):
		return str(ACTION_ACCENTS.get(normalized, fallback))
	for prefix_variant: Variant in ACTION_ACCENT_PREFIXES.keys():
		var prefix := str(prefix_variant)
		if normalized.begins_with(prefix):
			return str(ACTION_ACCENT_PREFIXES.get(prefix, fallback))
	return surface_accent_token(surface_id, fallback)

func action_button_style_id(action_id: String) -> String:
	var normalized := action_id.strip_edges()
	if bool(CTA_ACTIONS.get(normalized, false)):
		return "cta"
	for prefix_variant: Variant in CTA_ACTION_PREFIXES.keys():
		var prefix := str(prefix_variant)
		if normalized.begins_with(prefix):
			return "cta"
	return "secondary"

func mode_badge_color(mode_id: String) -> Color:
	if mode_id == ProjectInfo.MVP_MODE:
		return color("rarity_mvp")
	return color("border_default")
