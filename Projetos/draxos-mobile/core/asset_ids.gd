extends Node

const CATEGORY_IDS: Dictionary = {
	"ui": [
		"ui_logo",
		"boot_background",
		"icon_guest",
		"icon_battle",
		"icon_result",
		"placeholder_card"
	],
	"portraits": [
		"portrait_draxos_mage",
		"portrait_training_bot"
	],
	"battle_characters": [
		"battle_character_player",
		"battle_character_opponent"
	],
	"battle_icons": [
		"battle_icon_event",
		"battle_icon_weapon",
		"battle_icon_spell",
		"battle_icon_status",
		"battle_icon_buff",
		"battle_icon_damage",
		"battle_icon_summon",
		"battle_icon_pet",
		"battle_icon_heal",
		"battle_icon_reward",
		"battle_icon_result"
	],
	"battle_fx": [
		"battle_fx_hit",
		"battle_fx_spell",
		"battle_fx_buff"
	]
}

const PACK_01_SAFE_IDS: Array[String] = [
	"icon_guest",
	"icon_battle",
	"icon_result",
	"portrait_draxos_mage",
	"portrait_training_bot",
	"battle_icon_event",
	"battle_icon_weapon",
	"battle_icon_spell",
	"battle_icon_status",
	"battle_icon_buff",
	"battle_icon_damage",
	"battle_icon_summon",
	"battle_icon_pet",
	"battle_icon_heal",
	"battle_icon_reward",
	"battle_icon_result"
]

const PATHS: Dictionary = {
	"ui_logo": "res://assets/ui/ui_logo.png",
	"boot_background": "res://assets/ui/boot_background.png",
	"icon_guest": "res://assets/ui/icon_guest.png",
	"icon_battle": "res://assets/ui/icon_battle.png",
	"icon_result": "res://assets/ui/icon_result.png",
	"portrait_draxos_mage": "res://assets/portraits/portrait_draxos_mage.png",
	"portrait_training_bot": "res://assets/portraits/portrait_training_bot.png",
	"placeholder_card": "res://assets/ui/placeholder_card.png",
	"battle_character_player": "res://assets/battle/characters/player_draxos.png",
	"battle_character_opponent": "res://assets/battle/characters/opponent_placeholder.png",
	"battle_icon_event": "res://assets/battle/icons/event.png",
	"battle_icon_weapon": "res://assets/battle/icons/weapon.png",
	"battle_icon_spell": "res://assets/battle/icons/spell.png",
	"battle_icon_status": "res://assets/battle/icons/status.png",
	"battle_icon_buff": "res://assets/battle/icons/buff.png",
	"battle_icon_damage": "res://assets/battle/icons/damage.png",
	"battle_icon_summon": "res://assets/battle/icons/summon.png",
	"battle_icon_pet": "res://assets/battle/icons/familiar.png",
	"battle_icon_heal": "res://assets/battle/icons/heal.png",
	"battle_icon_reward": "res://assets/battle/icons/reward.png",
	"battle_icon_result": "res://assets/battle/icons/result.png",
	"battle_fx_hit": "res://assets/battle/fx/hit.png",
	"battle_fx_spell": "res://assets/battle/fx/spell.png",
	"battle_fx_buff": "res://assets/battle/fx/buff.png"
}

func categories() -> PackedStringArray:
	var category_ids: Array[String] = []
	for category_id: Variant in CATEGORY_IDS.keys():
		category_ids.append(str(category_id))
	category_ids.sort()
	return PackedStringArray(category_ids)

func ids_for_category(category_id: String) -> PackedStringArray:
	var ids: Array[String] = []
	for asset_id: Variant in Array(CATEGORY_IDS.get(category_id, [])):
		ids.append(str(asset_id))
	ids.sort()
	return PackedStringArray(ids)

func category(asset_id: String) -> String:
	for category_id: Variant in CATEGORY_IDS.keys():
		for category_asset_id: Variant in Array(CATEGORY_IDS.get(category_id, [])):
			if str(category_asset_id) == asset_id:
				return str(category_id)
	return ""

func all_ids() -> PackedStringArray:
	var ids: Array[String] = []
	for asset_id: Variant in PATHS.keys():
		ids.append(str(asset_id))
	ids.sort()
	return PackedStringArray(ids)

func pack_01_safe_ids() -> PackedStringArray:
	var ids: Array[String] = PACK_01_SAFE_IDS.duplicate()
	ids.sort()
	return PackedStringArray(ids)

func path(asset_id: String) -> String:
	return str(PATHS.get(asset_id, ""))

func has_asset_id(asset_id: String) -> bool:
	return PATHS.has(asset_id)

func has_art(asset_id: String) -> bool:
	var asset_path: String = path(asset_id)
	return asset_path != "" and ResourceLoader.exists(asset_path)

func texture(asset_id: String) -> Texture2D:
	if not has_art(asset_id):
		return null
	return load(path(asset_id))

func missing_art_ids(asset_ids: PackedStringArray = PackedStringArray()) -> PackedStringArray:
	var ids: Array[String] = []
	if asset_ids.is_empty():
		for asset_id: Variant in PATHS.keys():
			ids.append(str(asset_id))
	else:
		for asset_id: String in asset_ids:
			ids.append(asset_id)

	var missing: Array[String] = []
	for asset_id: String in ids:
		if not has_art(asset_id):
			missing.append(asset_id)
	missing.sort()
	return PackedStringArray(missing)
