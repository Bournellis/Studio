extends GutTest

const ContentGeneratorScript = preload("res://tools/content_generator.gd")

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
	assert_true(AssetIds.has_asset_id("icon_guest"))
	assert_eq(AssetIds.path("icon_guest"), "res://assets/ui/icon_guest.png")
	assert_true(AssetIds.has_asset_id("battle_icon_spell"))
	assert_eq(AssetIds.path("battle_icon_spell"), "res://assets/battle/icons/spell.png")
	assert_has(Array(AssetIds.missing_art_ids()), "icon_guest")

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
