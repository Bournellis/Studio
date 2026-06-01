extends GutTest

const RegistryScript := preload("res://modes/boot/ui/mode_shell_registry.gd")

const MODE_IDS := [
	"basebuilder",
	"autobattler",
	"openworld",
	"towerdefense",
	"cardgame",
]

func test_registry_loads_mode_descriptors_and_nonplayable_placeholders() -> void:
	for mode_id: String in MODE_IDS:
		var entry := RegistryScript.entry(mode_id)
		assert_false(entry.is_empty())
		assert_true(str(entry.get("descriptor_path", "")).ends_with("/%s/metadata.json" % mode_id))
		assert_true(str(entry.get("placeholder_path", "")).ends_with("/%s/placeholder.json" % mode_id))

		var descriptor := RegistryScript.descriptor(mode_id)
		assert_eq(descriptor.get("schema_version"), "mode_descriptor_v1")
		assert_eq(descriptor.get("mode_id"), mode_id)
		assert_eq(descriptor.get("display_name"), entry.get("display_name"))
		assert_eq(descriptor.get("status"), entry.get("status"))
		assert_eq(descriptor.get("default_slice_id"), entry.get("slice_id"))

		var docs := Dictionary(descriptor.get("docs", {}))
		assert_true(FileAccess.file_exists("res://%s" % str(docs.get("mode_doc", ""))))

		var placeholder := RegistryScript.placeholder(mode_id)
		assert_eq(placeholder.get("schema_version"), "mode_placeholder_v1")
		assert_eq(placeholder.get("mode_id"), mode_id)
		assert_false(bool(placeholder.get("playable", true)))
		assert_false(bool(placeholder.get("launchable", true)))
		assert_false(bool(placeholder.get("reward_enabled", true)))
		assert_true(RegistryScript.has_nonplayable_placeholder(mode_id))

func test_staged_mode_descriptors_do_not_launch_or_reward() -> void:
	for mode_id: String in ["towerdefense", "cardgame"]:
		var descriptor := RegistryScript.descriptor(mode_id)
		var entry := Dictionary(descriptor.get("entry", {}))
		var ownership := Dictionary(descriptor.get("ownership", {}))
		assert_eq(descriptor.get("status"), "planned_disabled")
		assert_false(bool(descriptor.get("public_cta", true)))
		assert_eq(entry.get("route_id"), "")
		assert_eq(entry.get("client_screen_path"), "")
		assert_eq(ownership.get("reward_bridge"), "none")
		assert_false(RegistryScript.can_launch(mode_id))
