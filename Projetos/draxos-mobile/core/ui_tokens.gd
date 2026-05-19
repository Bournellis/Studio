extends Node

const COLORS: Dictionary = {
	"bg_deep": Color("#080B10"),
	"bg_panel": Color("#151B22"),
	"bg_panel_alt": Color("#202832"),
	"border_default": Color("#405060"),
	"border_active": Color("#6FA6C8"),
	"text_primary": Color("#F0EEE5"),
	"text_secondary": Color("#AEB7BF"),
	"accent_astral": Color("#5DD4C8"),
	"accent_blood": Color("#B95757"),
	"accent_bone": Color("#D6C08A"),
	"rarity_mvp": Color("#C8B15A"),
	"status_success": Color("#66B56F"),
	"status_warning": Color("#D6A84F"),
	"status_error": Color("#D86D6D"),
	"placeholder": Color("#2B3440")
}

const TEXT_STYLES: Dictionary = {
	"title": {"font_size": 28, "color": "text_primary"},
	"section": {"font_size": 20, "color": "text_primary"},
	"body": {"font_size": 16, "color": "text_secondary"},
	"button": {"font_size": 16, "color": "text_primary"}
}

func color(token: String, fallback: Color = Color.WHITE) -> Color:
	return Color(COLORS.get(token, fallback))

func has_color(token: String) -> bool:
	return COLORS.has(token)

func text_style(style_id: String) -> Dictionary:
	return Dictionary(TEXT_STYLES.get(style_id, TEXT_STYLES.get("body", {}))).duplicate(true)

func mode_badge_color(mode_id: String) -> Color:
	if mode_id == ProjectInfo.MVP_MODE:
		return color("rarity_mvp")
	return color("border_default")
