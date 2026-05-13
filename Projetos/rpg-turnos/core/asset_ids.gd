extends Node

const PATHS: Dictionary = {
	"ui_logo": "res://assets/ui/ui_logo.png",
	"menu_background": "res://assets/ui/menu_background.png",
	"result_bg_victory": "res://assets/ui/result_bg_victory.png",
	"result_bg_defeat": "res://assets/ui/result_bg_defeat.png",
	"icon_victory": "res://assets/ui/icon_victory.png",
	"icon_defeat": "res://assets/ui/icon_defeat.png",
	"map_environment": "res://assets/world/map_environment.png",
	"marker_npc": "res://assets/world/marker_npc.png",
	"marker_encounter_active": "res://assets/world/marker_encounter_active.png",
	"marker_encounter_done": "res://assets/world/marker_encounter_done.png",
	"player_token": "res://assets/world/player_token.png",
	"portrait_npc_viajante": "res://assets/portraits/portrait_npc_viajante.png",
	"portrait_hero_aprendiz": "res://assets/portraits/portrait_hero_aprendiz.png",
	"portrait_hero_guardiao_elemental": "res://assets/portraits/portrait_hero_guardiao_elemental.png",
	"card_frame_criatura": "res://assets/cards/frames/card_frame_criatura.png",
	"card_frame_magia": "res://assets/cards/frames/card_frame_magia.png",
	"card_frame_magia_de_tabuleiro": "res://assets/cards/frames/card_frame_magia_de_tabuleiro.png",
	"card_frame_estrutura": "res://assets/cards/frames/card_frame_estrutura.png",
	"card_frame_permanente": "res://assets/cards/frames/card_frame_permanente.png",
	"card_frame_comando": "res://assets/cards/frames/card_frame_comando.png",
	"card_back": "res://assets/cards/frames/card_back.png"
}

func path(asset_id: String) -> String:
	return str(PATHS.get(asset_id, ""))

func has_art(asset_id: String) -> bool:
	var asset_path: String = path(asset_id)
	return asset_path != "" and ResourceLoader.exists(asset_path)

func texture(asset_id: String) -> Texture2D:
	if not has_art(asset_id):
		return null
	return load(path(asset_id))

func card_art_id(card_id: String) -> String:
	return "card_art_%s" % card_id

func card_art_path(card_id: String) -> String:
	return "res://assets/cards/art/%s.png" % card_art_id(card_id)

func has_card_art(card_id: String) -> bool:
	return ResourceLoader.exists(card_art_path(card_id))

func card_art_texture(card_id: String) -> Texture2D:
	if not has_card_art(card_id):
		return null
	return load(card_art_path(card_id))
