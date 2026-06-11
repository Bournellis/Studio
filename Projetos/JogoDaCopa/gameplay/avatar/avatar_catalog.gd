class_name FpsAvatarCatalog
extends RefCounted

const AvatarAppearanceScript = preload("res://gameplay/avatar/avatar_appearance.gd")

const DEFAULT_SKIN_TONE_ID: StringName = &"tan"
const DEFAULT_COUNTRY_KIT_ID: StringName = &"brazil"
const DEFAULT_HAIR_STYLE_ID: StringName = &"simple_parted"
const DEFAULT_HAIR_COLOR_ID: StringName = &"dark_brown"
const BOT_HAIR_STYLE_ID: StringName = &"buns"
const BOT_HAIR_COLOR_ID: StringName = &"black"

const SKIN_TONES: Array[Dictionary] = [
	{"id": &"light", "label": "Pele clara", "color": Color(0.96, 0.76, 0.58, 1.0)},
	{"id": &"tan", "label": "Pele bronze", "color": Color(0.77, 0.50, 0.32, 1.0)},
	{"id": &"brown", "label": "Pele morena", "color": Color(0.50, 0.30, 0.18, 1.0)},
	{"id": &"dark", "label": "Pele escura", "color": Color(0.25, 0.15, 0.10, 1.0)},
]

const COUNTRY_KITS: Array[Dictionary] = [
	{
		"id": &"brazil",
		"label": "Brasil inspirado",
		"shirt_primary": Color(1.0, 0.86, 0.12, 1.0),
		"shirt_secondary": Color(0.06, 0.52, 0.22, 1.0),
		"shorts": Color(0.05, 0.20, 0.70, 1.0),
		"socks": Color(0.96, 0.96, 0.92, 1.0),
	},
	{
		"id": &"argentina",
		"label": "Argentina inspirado",
		"shirt_primary": Color(0.82, 0.94, 1.0, 1.0),
		"shirt_secondary": Color(0.25, 0.66, 0.95, 1.0),
		"shorts": Color(0.08, 0.12, 0.18, 1.0),
		"socks": Color(0.94, 0.97, 1.0, 1.0),
	},
	{
		"id": &"france",
		"label": "Franca inspirado",
		"shirt_primary": Color(0.06, 0.16, 0.56, 1.0),
		"shirt_secondary": Color(0.94, 0.96, 1.0, 1.0),
		"shorts": Color(0.90, 0.08, 0.12, 1.0),
		"socks": Color(0.07, 0.12, 0.34, 1.0),
	},
	{
		"id": &"japan",
		"label": "Japao inspirado",
		"shirt_primary": Color(0.98, 0.98, 0.95, 1.0),
		"shirt_secondary": Color(0.05, 0.18, 0.76, 1.0),
		"shorts": Color(0.05, 0.08, 0.18, 1.0),
		"socks": Color(0.86, 0.04, 0.10, 1.0),
	},
	{
		"id": &"portugal",
		"label": "Portugal inspirado",
		"shirt_primary": Color(0.72, 0.04, 0.08, 1.0),
		"shirt_secondary": Color(0.05, 0.44, 0.18, 1.0),
		"shorts": Color(0.12, 0.34, 0.14, 1.0),
		"socks": Color(0.72, 0.04, 0.08, 1.0),
	},
	{
		"id": &"germany",
		"label": "Alemanha inspirado",
		"shirt_primary": Color(0.96, 0.94, 0.88, 1.0),
		"shirt_secondary": Color(0.08, 0.08, 0.08, 1.0),
		"shorts": Color(0.10, 0.10, 0.12, 1.0),
		"socks": Color(0.90, 0.18, 0.08, 1.0),
	},
]

const HAIR_STYLES: Array[Dictionary] = [
	{"id": &"simple_parted", "label": "Repartido", "path": "res://assets/characters/quaternius_ubc/hair/Hair_SimpleParted.gltf"},
	{"id": &"buzzed", "label": "Raspado", "path": "res://assets/characters/quaternius_ubc/hair/Hair_Buzzed.gltf"},
	{"id": &"buzzed_female", "label": "Raspado feminino", "path": "res://assets/characters/quaternius_ubc/hair/Hair_BuzzedFemale.gltf"},
	{"id": &"long", "label": "Longo", "path": "res://assets/characters/quaternius_ubc/hair/Hair_Long.gltf"},
	{"id": &"buns", "label": "Coques", "path": "res://assets/characters/quaternius_ubc/hair/Hair_Buns.gltf"},
	{"id": &"beard", "label": "Barba", "path": "res://assets/characters/quaternius_ubc/hair/Hair_Beard.gltf"},
]

const HAIR_COLORS: Array[Dictionary] = [
	{"id": &"black", "label": "Preto", "color": Color(0.025, 0.020, 0.018, 1.0)},
	{"id": &"dark_brown", "label": "Castanho escuro", "color": Color(0.16, 0.09, 0.045, 1.0)},
	{"id": &"brown", "label": "Castanho", "color": Color(0.34, 0.18, 0.08, 1.0)},
	{"id": &"blonde", "label": "Loiro", "color": Color(0.86, 0.62, 0.24, 1.0)},
	{"id": &"red", "label": "Ruivo", "color": Color(0.58, 0.14, 0.055, 1.0)},
]

static func get_default_appearance():
	return AvatarAppearanceScript.new(DEFAULT_SKIN_TONE_ID, DEFAULT_COUNTRY_KIT_ID, DEFAULT_HAIR_STYLE_ID, DEFAULT_HAIR_COLOR_ID)

static func get_bot_default_appearance():
	return AvatarAppearanceScript.new(&"brown", &"france", BOT_HAIR_STYLE_ID, BOT_HAIR_COLOR_ID)

static func get_skin_tone_count() -> int:
	return SKIN_TONES.size()

static func get_country_kit_count() -> int:
	return COUNTRY_KITS.size()

static func get_hair_style_count() -> int:
	return HAIR_STYLES.size()

static func get_hair_color_count() -> int:
	return HAIR_COLORS.size()

static func get_skin_tone(skin_tone_id: StringName) -> Dictionary:
	return _entry_by_id(SKIN_TONES, skin_tone_id, DEFAULT_SKIN_TONE_ID)

static func get_country_kit(country_kit_id: StringName) -> Dictionary:
	return _entry_by_id(COUNTRY_KITS, country_kit_id, DEFAULT_COUNTRY_KIT_ID)

static func get_hair_style(hair_style_id: StringName) -> Dictionary:
	return _entry_by_id(HAIR_STYLES, hair_style_id, DEFAULT_HAIR_STYLE_ID)

static func get_hair_color(hair_color_id: StringName) -> Dictionary:
	return _entry_by_id(HAIR_COLORS, hair_color_id, DEFAULT_HAIR_COLOR_ID)

static func get_skin_label(skin_tone_id: StringName) -> String:
	return str(get_skin_tone(skin_tone_id).get("label", "Pele"))

static func get_country_kit_label(country_kit_id: StringName) -> String:
	return str(get_country_kit(country_kit_id).get("label", "Camisa"))

static func get_hair_style_label(hair_style_id: StringName) -> String:
	return str(get_hair_style(hair_style_id).get("label", "Cabelo"))

static func get_hair_color_label(hair_color_id: StringName) -> String:
	return str(get_hair_color(hair_color_id).get("label", "Cor do cabelo"))

static func get_skin_color(skin_tone_id: StringName) -> Color:
	return get_skin_tone(skin_tone_id).get("color", Color.WHITE)

static func get_kit_primary_color(country_kit_id: StringName) -> Color:
	return get_country_kit(country_kit_id).get("shirt_primary", Color.WHITE)

static func get_kit_secondary_color(country_kit_id: StringName) -> Color:
	return get_country_kit(country_kit_id).get("shirt_secondary", Color.WHITE)

static func get_kit_shorts_color(country_kit_id: StringName) -> Color:
	return get_country_kit(country_kit_id).get("shorts", Color.DARK_BLUE)

static func get_kit_socks_color(country_kit_id: StringName) -> Color:
	return get_country_kit(country_kit_id).get("socks", Color.WHITE)

static func get_hair_style_path(hair_style_id: StringName) -> String:
	return str(get_hair_style(hair_style_id).get("path", ""))

static func get_hair_color_value(hair_color_id: StringName) -> Color:
	return get_hair_color(hair_color_id).get("color", Color(0.16, 0.09, 0.045, 1.0))

static func get_skin_tone_id_at(index: int) -> StringName:
	return SKIN_TONES[wrapi(index, 0, SKIN_TONES.size())].get("id", DEFAULT_SKIN_TONE_ID)

static func get_country_kit_id_at(index: int) -> StringName:
	return COUNTRY_KITS[wrapi(index, 0, COUNTRY_KITS.size())].get("id", DEFAULT_COUNTRY_KIT_ID)

static func get_hair_style_id_at(index: int) -> StringName:
	return HAIR_STYLES[wrapi(index, 0, HAIR_STYLES.size())].get("id", DEFAULT_HAIR_STYLE_ID)

static func get_hair_color_id_at(index: int) -> StringName:
	return HAIR_COLORS[wrapi(index, 0, HAIR_COLORS.size())].get("id", DEFAULT_HAIR_COLOR_ID)

static func get_next_skin_tone_id(current_id: StringName, step: int = 1) -> StringName:
	return get_skin_tone_id_at(_find_index(SKIN_TONES, current_id, DEFAULT_SKIN_TONE_ID) + step)

static func get_next_country_kit_id(current_id: StringName, step: int = 1) -> StringName:
	return get_country_kit_id_at(_find_index(COUNTRY_KITS, current_id, DEFAULT_COUNTRY_KIT_ID) + step)

static func get_next_hair_style_id(current_id: StringName, step: int = 1) -> StringName:
	return get_hair_style_id_at(_find_index(HAIR_STYLES, current_id, DEFAULT_HAIR_STYLE_ID) + step)

static func get_next_hair_color_id(current_id: StringName, step: int = 1) -> StringName:
	return get_hair_color_id_at(_find_index(HAIR_COLORS, current_id, DEFAULT_HAIR_COLOR_ID) + step)

static func _entry_by_id(entries: Array[Dictionary], entry_id: StringName, fallback_id: StringName) -> Dictionary:
	for entry: Dictionary in entries:
		if entry.get("id", &"") == entry_id:
			return entry
	for entry: Dictionary in entries:
		if entry.get("id", &"") == fallback_id:
			return entry
	return entries[0] if not entries.is_empty() else {}

static func _find_index(entries: Array[Dictionary], entry_id: StringName, fallback_id: StringName) -> int:
	for index: int in range(entries.size()):
		if entries[index].get("id", &"") == entry_id:
			return index
	for index: int in range(entries.size()):
		if entries[index].get("id", &"") == fallback_id:
			return index
	return 0
