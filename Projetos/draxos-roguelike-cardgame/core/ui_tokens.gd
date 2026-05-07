extends Node

const COLORS: Dictionary = {
	"bg_deep": Color("#0B0D0F"),
	"bg_panel": Color("#181C1F"),
	"bg_panel_alt": Color("#14191C"),
	"border_default": Color("#3D484F"),
	"border_active": Color("#5A7080"),
	"text_primary": Color("#E0E0D8"),
	"type_criatura": Color("#4A7A5A"),
	"type_estrutura": Color("#5A6A7A"),
	"type_permanente": Color("#7A6A3A"),
	"type_magia": Color("#6A4A7A"),
	"type_magia_de_tabuleiro": Color("#8A5A9A"),
	"type_comando": Color("#7A4A4A"),
	"hp_player": Color("#4A7A5A"),
	"hp_enemy": Color("#7A4A4A"),
	"energy": Color("#D9AD4A"),
	"placeholder": Color("#263038")
}

const TYPE_DISPLAY_NAMES: Dictionary = {
	"criatura": "Criatura",
	"estrutura": "Estrutura",
	"permanente": "Permanente",
	"magia": "Magia",
	"magia_de_tabuleiro": "Magia de tabuleiro",
	"comando": "Comando"
}

func color(token: String, fallback: Color = Color.WHITE) -> Color:
	return Color(COLORS.get(token, fallback))

func type_color(card_type: String) -> Color:
	return color("type_%s" % card_type, color("border_default"))

func type_display_name(card_type: String) -> String:
	return str(TYPE_DISPLAY_NAMES.get(card_type, card_type.capitalize()))
