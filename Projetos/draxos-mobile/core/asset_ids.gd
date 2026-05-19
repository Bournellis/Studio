extends Node

const PATHS: Dictionary = {
	"ui_logo": "res://assets/ui/ui_logo.png",
	"boot_background": "res://assets/ui/boot_background.png",
	"icon_guest": "res://assets/ui/icon_guest.png",
	"icon_battle": "res://assets/ui/icon_battle.png",
	"icon_result": "res://assets/ui/icon_result.png",
	"portrait_draxos_mage": "res://assets/portraits/portrait_draxos_mage.png",
	"portrait_training_bot": "res://assets/portraits/portrait_training_bot.png",
	"placeholder_card": "res://assets/ui/placeholder_card.png"
}

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
