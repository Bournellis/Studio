extends "res://addons/gut/test.gd"

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const BootRootScript = preload("res://modes/boot/boot_root.gd")
const BattleRootScript = preload("res://modes/battle/battle_root.gd")
const WorldRootScript = preload("res://modes/world/world_root.gd")
const CardTokenScript = preload("res://ui/controls/card_token.gd")

func before_all() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
	ContentLibrary.reload()

func before_each() -> void:
	GameSession.start_new_game()

func test_asset_ids_and_ui_tokens_are_available() -> void:
	assert_eq(AssetIds.path("ui_logo"), "res://assets/ui/ui_logo.png")
	assert_eq(AssetIds.card_art_id("escudeiro"), "card_art_escudeiro")
	assert_eq(UiTokens.type_display_name("criatura"), "Criatura")
	assert_eq(UiTokens.type_color("magia"), UiTokens.color("type_magia"))

func test_boot_exposes_named_art_placeholders() -> void:
	var root = BootRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(root, "bg_visual"))
	assert_not_null(_find_node_by_name(root, "ambiance_layer"))
	assert_not_null(_find_node_by_name(root, "logo_container"))
	assert_not_null(_find_node_by_name(root, "logo_rect"))
	root.free()

func test_world_exposes_named_art_placeholders() -> void:
	var root = WorldRootScript.new()
	add_child(root)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(root, "map_environment"))
	assert_not_null(_find_node_by_name(root, "marker_nodes"))
	assert_not_null(_find_node_by_name(root, "player_sprite"))
	assert_not_null(_find_node_by_name(root, "portrait_rect"))
	assert_not_null(_find_node_by_name(root, "emboscada_na_ponte"))
	root.free()

func test_battle_exposes_named_art_ready_nodes() -> void:
	var root = BattleRootScript.new()
	add_child(root)
	await get_tree().process_frame
	root.engine._enemy_ai_enabled = false

	assert_not_null(_find_node_by_name(root, "player_portrait_rect"))
	assert_not_null(_find_node_by_name(root, "enemy_portrait_rect"))
	assert_not_null(_find_node_by_name(root, "priority_dot"))
	assert_not_null(_find_node_by_name(root, "energy_pips"))
	assert_not_null(_find_node_by_name(root, "discard_bar"))
	assert_not_null(_find_node_by_name(root, "player_lane_panel"))
	assert_not_null(_find_node_by_name(root, "enemy_lane_panel"))
	root.free()

func test_card_token_exposes_art_pips_and_keyword_placeholders() -> void:
	var token = CardTokenScript.new()
	add_child(token)
	token.setup("arqueira_penhasco", "pool", 0)
	await get_tree().process_frame

	assert_not_null(_find_node_by_name(token, "art_rect"))
	assert_not_null(_find_node_by_name(token, "PipRowComponent"))
	assert_not_null(_find_node_by_name(token, "KeywordChipsComponent"))
	token.free()

func _find_node_by_name(node: Node, target_name: String):
	if node.name == target_name:
		return node
	for child: Node in node.get_children():
		var found = _find_node_by_name(child, target_name)
		if found != null:
			return found
	return null
