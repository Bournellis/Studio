class_name FpsAvatarAppearance
extends RefCounted

var skin_tone_id: StringName = &"tan"
var country_kit_id: StringName = &"brazil"

func _init(next_skin_tone_id: StringName = &"tan", next_country_kit_id: StringName = &"brazil") -> void:
	skin_tone_id = next_skin_tone_id
	country_kit_id = next_country_kit_id

func duplicate_appearance() -> FpsAvatarAppearance:
	return FpsAvatarAppearance.new(skin_tone_id, country_kit_id)
