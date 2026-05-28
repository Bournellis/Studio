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

func color(token: String, fallback: Color = Color.WHITE) -> Color:
	return Color(COLORS.get(token, fallback))

func has_color(token: String) -> bool:
	return COLORS.has(token)

func text_style(style_id: String) -> Dictionary:
	return Dictionary(TEXT_STYLES.get(style_id, TEXT_STYLES.get("body", {}))).duplicate(true)

func panel_style(style_id: String = "default", compact: bool = false) -> StyleBoxFlat:
	var data := Dictionary(PANEL_STYLES.get(style_id, PANEL_STYLES.get("default", {})))
	var style := StyleBoxFlat.new()
	style.bg_color = color(str(data.get("background", "bg_panel")))
	style.border_color = color(str(data.get("border", "border_default")))
	style.set_border_width_all(int(data.get("border_width", 1)))
	style.set_corner_radius_all(int(data.get("radius", 8)))
	var margin := int(data.get("compact_margin", 10) if compact else data.get("regular_margin", 14))
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = max(8, margin - 2)
	style.content_margin_bottom = max(8, margin - 2)
	return style

func button_style(style_id: String = "secondary", state: String = "normal") -> StyleBoxFlat:
	var data := Dictionary(BUTTON_STYLES.get(style_id, BUTTON_STYLES.get("secondary", {})))
	var style := StyleBoxFlat.new()
	style.bg_color = color(str(data.get(state, data.get("normal", "bg_panel"))))
	style.border_color = color(str(data.get("border_focus", data.get("border", "border_default"))) if state != "normal" else str(data.get("border", "border_default")))
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func mode_badge_color(mode_id: String) -> Color:
	if mode_id == ProjectInfo.MVP_MODE:
		return color("rarity_mvp")
	return color("border_default")
