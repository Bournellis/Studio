extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const SceneGeneratorScript = preload("res://tools/scene_generator.gd")

const OUTPUT_DIR: String = "res://../../builds/draxos-roguelike-cardgame/visual-screenshots"
const VIEWPORTS: Array[Dictionary] = [
	{"id": "1280x720", "size": Vector2i(1280, 720)},
	{"id": "960x540", "size": Vector2i(960, 540)}
]
const SURFACES: Array[Dictionary] = [
	{"id": "ship_hub", "scene": "res://modes/ship_hub/ship_hub.tscn", "setup": "ship"},
	{"id": "run_map", "scene": "res://modes/run_map/run_map.tscn", "setup": "map"},
	{"id": "shop_relic", "scene": "res://modes/souls/souls.tscn", "setup": "souls", "preview": "shop"},
	{"id": "enemy_intent", "scene": "res://modes/battle/battle.tscn", "setup": "battle"},
	{"id": "late_board_battle", "scene": "res://modes/battle/battle.tscn", "setup": "battle_late"},
	{"id": "keyword_tooltip", "scene": "res://modes/battle/battle.tscn", "setup": "battle", "preview": "card"},
	{"id": "reward_screen", "scene": "res://modes/battle/battle.tscn", "setup": "battle_reward", "preview": "reward_screen"},
	{"id": "reward_tooltip", "scene": "res://modes/battle/battle.tscn", "setup": "battle", "preview": "reward"},
	{"id": "souls_shop_tooltip", "scene": "res://modes/souls/souls.tscn", "setup": "souls", "preview": "shop"}
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(result.get("ok", false)):
		printerr("[screenshots] %s" % str(result.get("message", "Content generation failed.")))
		quit(1)
		return
	var scene_result: Dictionary = SceneGeneratorScript.new().generate_all()
	if not bool(scene_result.get("ok", false)):
		printerr("[screenshots] %s" % str(scene_result.get("message", "Scene generation failed.")))
		quit(1)
		return

	var output_dir: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(output_dir)

	for viewport: Dictionary in VIEWPORTS:
		var viewport_size: Vector2i = viewport.get("size", Vector2i(1280, 720))
		DisplayServer.window_set_size(viewport_size)
		root.size = viewport_size
		root.content_scale_size = viewport_size
		await process_frame
		await process_frame
		for surface: Dictionary in SURFACES:
			_prepare_session(str(surface.get("setup", "")))
			var packed_scene: PackedScene = load(str(surface.get("scene", "")))
			if packed_scene == null:
				printerr("[screenshots] failed to load %s" % str(surface.get("scene", "")))
				quit(1)
				return
			var instance: Node = packed_scene.instantiate()
			root.add_child(instance)
			if instance is Control:
				var control: Control = instance
				control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			await process_frame
			await process_frame
			_prepare_preview(instance, str(surface.get("preview", "")))
			await process_frame
			var image: Image = root.get_texture().get_image()
			if image.get_width() != viewport_size.x or image.get_height() != viewport_size.y:
				image = _crop_image(image, viewport_size)
			var output_path: String = output_dir.path_join("%s_%s.png" % [str(surface.get("id", "")), str(viewport.get("id", ""))])
			var save_result: Error = image.save_png(output_path)
			instance.queue_free()
			await process_frame
			if save_result != OK:
				printerr("[screenshots] failed to save %s" % output_path)
				quit(1)
				return
			print("[screenshots] saved %s" % output_path)
	quit(0)

func _crop_image(source: Image, target_size: Vector2i) -> Image:
	var crop_width: int = mini(source.get_width(), target_size.x)
	var crop_height: int = mini(source.get_height(), target_size.y)
	var cropped: Image = Image.create(target_size.x, target_size.y, false, source.get_format())
	cropped.fill(Color(0, 0, 0, 1))
	cropped.blit_rect(source, Rect2i(Vector2i.ZERO, Vector2i(crop_width, crop_height)), Vector2i.ZERO)
	return cropped

func _prepare_session(setup_id: String) -> void:
	var session = root.get_node_or_null("RunSession")
	if session == null:
		push_error("[screenshots] RunSession autoload is missing.")
		return
	session.reset()
	match setup_id:
		"ship":
			session.selected_class_id = "arcano"
		"map":
			session.start_class_run("arcano", 77)
			session.record_battle_result("n04_pouso_elemental", "vitoria", 14)
		"souls":
			session.start_class_run("arcano", 77)
			session.soul_total = 120
			session.current_health = 12
			session.record_battle_result("n01_tutorial_primeiro_contato", "vitoria", 12)
			session.add_relic_id("bolsa_de_cinzas")
		"battle":
			session.start_class_run("arcano", 77)
			session.max_mana = 4
			session.max_hand_size = 5
			session.current_health = session.max_health
			session.current_deck_ids.append_array(["arcano_barreira", "arcano_tempestade", "arcano_vortice", "arcano_acelerar"])
			session.select_node("n20_emboscada_nuvens")
		"battle_late":
			session.start_class_run("arcano", 77)
			session.max_mana = 6
			session.max_hand_size = 5
			session.max_health = 36
			session.current_health = 24
			session.soul_total = 84
			session.current_deck_ids.append_array(["arcano_barreira", "arcano_tempestade", "arcano_vortice", "arcano_acelerar", "arcano_bola_de_fogo", "arcano_espelho_arcano", "arcano_descarga"])
			session.relic_ids.clear()
			session.relic_ids.append_array(["bolsa_de_cinzas", "couro_astral", "forja_negra", "coracao_de_eter", "pacto_das_ruinas"])
			session.select_node("n29_dragao_primordial")
		"battle_reward":
			session.start_class_run("arcano", 77)
			session.max_mana = 4
			session.max_hand_size = 5
			session.soul_total = 42
			session.current_deck_ids.append_array(["arcano_barreira", "arcano_tempestade", "arcano_vortice"])
			session.select_node("n21_olho_da_tempestade")

func _prepare_preview(instance: Node, preview_id: String) -> void:
	match preview_id:
		"card":
			if instance.has_method("_show_preview_now") and instance.has_method("_card_preview_data"):
				instance.call("_show_preview_now", instance.call("_card_preview_data", "arcano_barreira", {}))
		"reward":
			if instance.has_method("_show_preview_now"):
				instance.call("_show_preview_now", {
					"title": "Recompensa: Barreira Arcana",
					"subtitle": "Carta / keyword",
					"body": _content_library().reward_choice_tooltip({
						"id": "new_card:arcano_barreira",
						"card_id": "arcano_barreira",
						"body": "Adiciona 3 copias ao deck."
					}),
					"state": "Tooltip de recompensa"
				})
		"reward_screen":
			if instance.has_method("_show_reward_modal"):
				instance.call("_show_reward_modal", {
					"node_id": "n21_olho_da_tempestade",
					"souls_gained": 11,
					"automatic_rewards": [],
					"choice_rewards": [],
					"next_node_id": "n22_primordial_ar"
				})
		"shop":
			if instance.has_method("_show_shop_preview"):
				instance.call("_show_shop_preview", "Bolsa de Cinzas", _content_library().shop_choice_tooltip({
					"id": "shop_relic:bolsa_de_cinzas",
					"relic_id": "bolsa_de_cinzas",
					"cost": 30,
					"body": "Compra esta reliquia."
				}))

func _content_library():
	var library = root.get_node_or_null("ContentLibrary")
	if library == null:
		push_error("[screenshots] ContentLibrary autoload is missing.")
	return library
