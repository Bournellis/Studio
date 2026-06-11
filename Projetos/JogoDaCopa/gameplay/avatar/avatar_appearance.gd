class_name FpsAvatarAppearance
extends RefCounted

var skin_tone_id: StringName = &"tan"
var country_kit_id: StringName = &"brazil"
var hair_style_id: StringName = &""
var hair_color_id: StringName = &""

func _init(next_skin_tone_id: StringName = &"tan", next_country_kit_id: StringName = &"brazil", next_hair_style_id: StringName = &"", next_hair_color_id: StringName = &"") -> void:
	skin_tone_id = next_skin_tone_id
	country_kit_id = next_country_kit_id
	hair_style_id = next_hair_style_id
	hair_color_id = next_hair_color_id

func duplicate_appearance():
	return get_script().new(skin_tone_id, country_kit_id, hair_style_id, hair_color_id)
