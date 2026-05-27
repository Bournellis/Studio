extends GutTest

const BattleSymbolIconScript = preload("res://ui/battle_symbol_icon.gd")
const ContentGeneratorScript = preload("res://tools/content_generator.gd")

const EXPECTED_ASSET_PACK_01_IDS: Array[String] = [
	"battle_icon_buff",
	"battle_icon_damage",
	"battle_icon_event",
	"battle_icon_heal",
	"battle_icon_pet",
	"battle_icon_result",
	"battle_icon_reward",
	"battle_icon_spell",
	"battle_icon_status",
	"battle_icon_summon",
	"battle_icon_weapon",
	"icon_battle",
	"icon_guest",
	"icon_result",
	"portrait_draxos_mage",
	"portrait_training_bot"
]

const EXPECTED_OPTIONAL_MISSING_ART_IDS: Array[String] = [
	"battle_character_opponent",
	"battle_character_player",
	"battle_fx_buff",
	"battle_fx_hit",
	"battle_fx_spell",
	"boot_background",
	"placeholder_card",
	"ui_logo"
]

const EXPECTED_ASSET_PATHS: Dictionary = {
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

const EXPECTED_ASSET_CATEGORIES: Dictionary = {
	"ui": [
		"boot_background",
		"icon_battle",
		"icon_guest",
		"icon_result",
		"placeholder_card",
		"ui_logo"
	],
	"portraits": [
		"portrait_draxos_mage",
		"portrait_training_bot"
	],
	"battle_characters": [
		"battle_character_opponent",
		"battle_character_player"
	],
	"battle_icons": [
		"battle_icon_buff",
		"battle_icon_damage",
		"battle_icon_event",
		"battle_icon_heal",
		"battle_icon_pet",
		"battle_icon_result",
		"battle_icon_reward",
		"battle_icon_spell",
		"battle_icon_status",
		"battle_icon_summon",
		"battle_icon_weapon"
	],
	"battle_fx": [
		"battle_fx_buff",
		"battle_fx_hit",
		"battle_fx_spell"
	]
}

func before_each() -> void:
	ContentLibrary.reload()

func test_foundation_autoloads_are_available() -> void:
	assert_not_null(UiTokens)
	assert_not_null(AssetIds)
	assert_not_null(ContentLibrary)

func test_ui_tokens_expose_mvp_colors() -> void:
	assert_true(UiTokens.has_color("accent_astral"))
	assert_eq(UiTokens.mode_badge_color(ProjectInfo.MVP_MODE), UiTokens.color("rarity_mvp"))
	assert_eq(int(UiTokens.text_style("button").get("font_size", 0)), 16)

func test_asset_ids_are_registered_without_requiring_art_yet() -> void:
	var all_ids: Array = Array(AssetIds.all_ids())
	assert_eq(all_ids.size(), EXPECTED_ASSET_PATHS.size())

	for asset_id_variant: Variant in EXPECTED_ASSET_PATHS.keys():
		var asset_id: String = str(asset_id_variant)
		assert_true(AssetIds.has_asset_id(asset_id), "Asset id should be registered: %s" % asset_id)
		assert_eq(AssetIds.path(asset_id), str(EXPECTED_ASSET_PATHS[asset_id]))
		assert_ne(AssetIds.category(asset_id), "", "Asset id should have a category: %s" % asset_id)
		assert_has(all_ids, asset_id)

func test_asset_ids_keep_category_groups_stable() -> void:
	var categories: Array = Array(AssetIds.categories())
	assert_eq(categories.size(), EXPECTED_ASSET_CATEGORIES.size())

	for category_id_variant: Variant in EXPECTED_ASSET_CATEGORIES.keys():
		var category_id: String = str(category_id_variant)
		assert_has(categories, category_id)
		assert_eq(Array(AssetIds.ids_for_category(category_id)), EXPECTED_ASSET_CATEGORIES[category_id])
		for asset_id: String in EXPECTED_ASSET_CATEGORIES[category_id]:
			assert_eq(AssetIds.category(asset_id), category_id)

func test_asset_ids_allow_missing_art_fallback() -> void:
	assert_eq(AssetIds.path("__missing_art_probe__"), "")
	assert_false(AssetIds.has_art("__missing_art_probe__"))
	assert_null(AssetIds.texture("__missing_art_probe__"))
	assert_has(Array(AssetIds.missing_art_ids(PackedStringArray(["__missing_art_probe__"]))), "__missing_art_probe__")
	assert_has(Array(AssetIds.missing_art_ids()), "boot_background")

func test_asset_ids_keep_optional_missing_art_contract_stable() -> void:
	assert_eq(Array(AssetIds.missing_art_ids()), EXPECTED_OPTIONAL_MISSING_ART_IDS)
	for asset_id: String in EXPECTED_OPTIONAL_MISSING_ART_IDS:
		assert_true(AssetIds.has_asset_id(asset_id), "Optional missing id should stay registered: %s" % asset_id)
		assert_false(AssetIds.has_art(asset_id), "Optional missing id should not require final art yet: %s" % asset_id)
		assert_null(AssetIds.texture(asset_id), "Optional missing id should return null texture: %s" % asset_id)
		assert_false(Array(AssetIds.pack_01_safe_ids()).has(asset_id), "Optional missing id should not be part of installed Pack 01: %s" % asset_id)

func test_asset_pack_01_safe_art_is_loadable_without_making_all_art_required() -> void:
	assert_eq(Array(AssetIds.pack_01_safe_ids()), EXPECTED_ASSET_PACK_01_IDS)
	for asset_id: String in EXPECTED_ASSET_PACK_01_IDS:
		assert_true(AssetIds.has_art(asset_id), "Pack 01 art should exist: %s" % asset_id)
		var texture := AssetIds.texture(asset_id)
		assert_not_null(texture, "Pack 01 texture should load: %s" % asset_id)
		assert_true(texture.get_width() <= 128, "Pack 01 texture should stay lightweight: %s" % asset_id)
		assert_true(texture.get_height() <= 128, "Pack 01 texture should stay lightweight: %s" % asset_id)

	for optional_id: String in ["ui_logo", "boot_background", "placeholder_card", "battle_fx_hit"]:
		assert_true(AssetIds.has_asset_id(optional_id), "Optional id should remain registered: %s" % optional_id)
		assert_false(AssetIds.has_art(optional_id), "Optional art should still be allowed to be missing: %s" % optional_id)
		assert_null(AssetIds.texture(optional_id), "Optional missing texture should fall back to null: %s" % optional_id)

func test_battle_symbol_icon_uses_pack_texture_and_keeps_missing_art_fallback() -> void:
	var icon = BattleSymbolIconScript.new()
	add_child_autofree(icon)

	icon.configure("SP", Color("#5DD4C8"), "Spell icon", "", 0.0, "battle_icon_spell")
	assert_true(icon.debug_has_texture())
	assert_eq(icon.debug_asset_id(), "battle_icon_spell")

	icon.configure("FX", Color("#5DD4C8"), "Missing fx fallback", "", 0.0, "battle_fx_hit")
	assert_false(icon.debug_has_texture())
	assert_eq(icon.debug_asset_id(), "battle_fx_hit")

func test_generated_catalog_loads_expected_collections() -> void:
	var catalog = ContentLibrary.get_catalog()
	assert_not_null(catalog)
	assert_gt(catalog.total_count(), 0)
	for collection_id: String in ContentGeneratorScript.new().expected_collection_ids():
		assert_false(catalog.get_collection(collection_id).is_empty(), "Collection should not be empty: %s" % collection_id)

func test_mvp_training_fixture_is_server_authoritative_input_only() -> void:
	var fixture: Dictionary = ContentLibrary.get_item("battle_fixtures", "mvp_training_battle")
	assert_false(fixture.is_empty())
	assert_eq(str(fixture.get("mode", "")), ProjectInfo.MVP_MODE)
	assert_eq(str(Dictionary(fixture.get("opponent_fixture", {})).get("id", "")), "mvp_training_bot")
	assert_has(Array(Dictionary(fixture.get("player_fixture", {})).get("spell_ids", [])), "sussurro_medo")

func test_catalog_validation_reports_success() -> void:
	var result: Dictionary = ContentLibrary.validate_catalog()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))
