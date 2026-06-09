extends "res://addons/gut/test.gd"

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")
const CombatantScript = preload("res://gameplay/combat/combatant_3d.gd")

const EXPECTED_ACTIONS: PackedStringArray = [
	"move_forward",
	"move_back",
	"move_left",
	"move_right",
	"jump",
	"shoot",
	"restart_round",
	"ui_back"
]

func before_all() -> void:
	var result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	assert_true(bool(result.get("ok", false)), str(result.get("message", "")))

func after_each() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func test_input_actions_are_bootstrapped() -> void:
	for action_name: String in EXPECTED_ACTIONS:
		assert_true(InputMap.has_action(action_name), "Missing input action %s" % action_name)
		assert_gt(InputMap.action_get_events(action_name).size(), 0, "Input action %s has no binding" % action_name)

func test_arena_scene_boots_with_player_bot_camera_and_hud() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	assert_not_null(arena_scene)
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	assert_not_null(arena.get_node_or_null("WorldEnvironment"))
	assert_not_null(arena.get_node_or_null("KeyLight"))
	assert_not_null(arena.get_node_or_null("ArenaFloor"))
	assert_not_null(arena.get_node_or_null("NorthWall"))
	assert_not_null(arena.get_node_or_null("LowCoverA"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Player"))
	assert_not_null(arena.get_node_or_null("RuntimeRoot/Bot"))
	assert_not_null(arena.get_node_or_null("ArenaHud"))

	var player = arena.get_node("RuntimeRoot/Player")
	assert_not_null(player.get_node_or_null("Head/Camera3D"))
	assert_true((player.get_node("Head/Camera3D") as Camera3D).current)
	assert_not_null(arena.get_node("ArenaHud").get_node_or_null("HudRoot/StatusPanel/StatusBox/PlayerLabel"))
	assert_no_new_orphans()

func test_combatant_damage_and_knockback_contract() -> void:
	var combatant = CombatantScript.new()
	add_child_autofree(combatant)
	combatant.configure_combatant(&"probe", 50.0, Color.WHITE)
	combatant.take_damage(12.0, &"test")
	assert_eq(combatant.health, 38.0)
	combatant.apply_knockback(Vector3.FORWARD, 4.0)
	assert_gt(combatant.knockback_velocity.length(), 0.1)
	combatant.take_damage(80.0, &"test")
	assert_true(combatant.is_dead)
	assert_no_new_orphans()

func test_bot_force_fire_damages_player() -> void:
	var arena_scene := load("res://modes/arena/arena.tscn") as PackedScene
	var arena := arena_scene.instantiate()
	add_child_autofree(arena)
	await get_tree().process_frame
	await get_tree().physics_frame

	var player = arena.debug_get_player()
	var bot = arena.debug_get_bot()
	var before: float = player.health
	bot.force_fire()
	assert_lt(player.health, before)
	assert_gt(player.knockback_velocity.length(), 0.1)
	assert_no_new_orphans()
