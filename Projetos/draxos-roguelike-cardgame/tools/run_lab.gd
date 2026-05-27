extends SceneTree

const ContentGeneratorScript = preload("res://tools/content_generator.gd")
const DEFAULT_CLASSES: PackedStringArray = ["arcano", "invocador", "necromante"]
const DEFAULT_SEEDS: PackedInt64Array = [20260518]
const DEFAULT_OUTPUT_DIR: String = "user://run_lab"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var exit_code: int = _run_lab()
	quit(exit_code)

func _run_lab() -> int:
	var options: Dictionary = _parse_options()
	var content_result: Dictionary = ContentGeneratorScript.new().generate_all()
	if not bool(content_result.get("ok", false)):
		printerr("[run_lab] %s" % str(content_result.get("message", "Content generation failed.")))
		return 1
	var content_library = root.get_node_or_null("ContentLibrary")
	if content_library == null:
		printerr("[run_lab] ContentLibrary autoload is missing.")
		return 1
	content_library.reload()
	var catalog = content_library.get_catalog()
	if catalog == null:
		printerr("[run_lab] Missing generated slice catalog.")
		return 1
	var session = root.get_node_or_null("RunSession")
	if session == null:
		printerr("[run_lab] RunSession autoload is missing.")
		return 1

	var results: Array[Dictionary] = []
	for class_id: String in Array(options.get("classes", DEFAULT_CLASSES)):
		for seed: int in Array(options.get("seeds", DEFAULT_SEEDS)):
			var result: Dictionary = _simulate_route(session, catalog, class_id, seed)
			results.append(result)
			print("[run_lab] %s seed=%d maps=%d/%d turns_est=%d hp=%d/%d deaths=%d deck=%d relics=%d shop=%d" % [
				class_id,
				seed,
				int(result.get("completed_maps", 0)),
				int(result.get("map_count", 0)),
				int(result.get("estimated_turns", 0)),
				int(result.get("final_hp", 0)),
				int(result.get("max_hp", 0)),
				int(result.get("deaths", 0)),
				int(result.get("deck_size", 0)),
				int(result.get("relic_count", 0)),
				int(result.get("shop_usage", 0))
			])
	var output_dir: String = str(options.get("out", DEFAULT_OUTPUT_DIR))
	var write_result: Dictionary = _write_outputs(output_dir, results)
	if not bool(write_result.get("ok", false)):
		printerr("[run_lab] %s" % str(write_result.get("message", "Failed to write outputs.")))
		return 1
	print("[run_lab] wrote %s and %s" % [str(write_result.get("json_path", "")), str(write_result.get("csv_path", ""))])
	return 0

func _parse_options() -> Dictionary:
	var options: Dictionary = {
		"classes": DEFAULT_CLASSES,
		"seeds": DEFAULT_SEEDS,
		"out": DEFAULT_OUTPUT_DIR
	}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--class="):
			options["classes"] = PackedStringArray([arg.trim_prefix("--class=")])
		elif arg.begins_with("--classes="):
			options["classes"] = PackedStringArray(arg.trim_prefix("--classes=").split(",", false))
		elif arg.begins_with("--seed="):
			options["seeds"] = PackedInt64Array([int(arg.trim_prefix("--seed="))])
		elif arg.begins_with("--seeds="):
			var seeds: PackedInt64Array = PackedInt64Array()
			for seed_text: String in arg.trim_prefix("--seeds=").split(",", false):
				seeds.append(int(seed_text))
			options["seeds"] = seeds
		elif arg.begins_with("--out="):
			options["out"] = arg.trim_prefix("--out=")
	return options

func _simulate_route(session, catalog, class_id: String, seed: int) -> Dictionary:
	session.reset()
	var start_result: Dictionary = session.start_class_run(class_id, seed, "Comandante Draxos")
	var nodes: Array = Array(catalog.run_map.get("nodes", []))
	var metrics: Dictionary = {
		"class_id": class_id,
		"seed": seed,
		"ok": bool(start_result.get("ok", false)),
		"message": str(start_result.get("message", "")),
		"map_count": nodes.size(),
		"completed_maps": 0,
		"estimated_turns": 0,
		"hp_loss": 0,
		"final_hp": 0,
		"max_hp": 0,
		"souls_earned": 0,
		"souls_spent": 0,
		"souls_left": 0,
		"deck_size": 0,
		"relic_count": 0,
		"shop_usage": 0,
		"deaths": 0,
		"shop_actions": []
	}
	if not bool(start_result.get("ok", false)):
		session.reset()
		return metrics
	for node: Dictionary in nodes:
		var node_id: String = str(node.get("id", ""))
		var map_index: int = int(node.get("map_index", 0))
		if session.current_node_id != node_id:
			if not session.is_node_available(node):
				metrics["ok"] = false
				metrics["message"] = "Route blocked before map %d (%s)." % [map_index, node_id]
				break
			session.select_node(node_id)
		var encounter: Dictionary = catalog.find_encounter(str(node.get("encounter_id", "")))
		if encounter.is_empty():
			metrics["ok"] = false
			metrics["message"] = "Missing encounter for map %d (%s)." % [map_index, node_id]
			break
		_apply_pre_battle_shop(session, metrics)
		metrics["estimated_turns"] = int(metrics.get("estimated_turns", 0)) + _estimated_turns_for_encounter(encounter)
		var hp_loss: int = _estimated_hp_loss_for_encounter(encounter, map_index)
		var remaining_health: int = session.current_health - hp_loss
		if remaining_health <= 0:
			metrics["deaths"] = int(metrics.get("deaths", 0)) + 1
			remaining_health = 1
		metrics["hp_loss"] = int(metrics.get("hp_loss", 0)) + maxi(0, session.current_health - remaining_health)
		var summary: Dictionary = session.record_battle_result(node_id, "vitoria", remaining_health)
		if not bool(summary.get("ok", false)):
			metrics["ok"] = false
			metrics["message"] = "Could not record map %d (%s)." % [map_index, node_id]
			break
		metrics["souls_earned"] = int(metrics.get("souls_earned", 0)) + int(summary.get("souls_gained", 0))
		if not _apply_all_pending_rewards(session):
			metrics["ok"] = false
			metrics["message"] = "Could not resolve reward choices after map %d." % map_index
			break
		_apply_post_reward_shop(session, metrics, map_index)
		metrics["completed_maps"] = int(metrics.get("completed_maps", 0)) + 1
	metrics["final_hp"] = session.current_health
	metrics["max_hp"] = session.max_health
	metrics["souls_left"] = session.soul_total
	metrics["deck_size"] = session.current_deck_ids.size()
	metrics["relic_count"] = session.relic_ids.size()
	if bool(metrics.get("ok", false)) and int(metrics.get("completed_maps", 0)) != nodes.size():
		metrics["ok"] = false
		metrics["message"] = "Completed %d/%d maps." % [int(metrics.get("completed_maps", 0)), nodes.size()]
	session.reset()
	return metrics

func _apply_all_pending_rewards(session) -> bool:
	var guard: int = 0
	while session.has_pending_reward():
		guard += 1
		if guard > 12:
			return false
		var choices: Array[Dictionary] = session.pending_reward_choices()
		if choices.is_empty():
			return false
		var selected: Dictionary = _preferred_reward_choice(choices)
		var result: Dictionary = session.apply_reward_choice(str(selected.get("id", "")))
		if not bool(result.get("ok", false)):
			return false
	return true

func _preferred_reward_choice(choices: Array[Dictionary]) -> Dictionary:
	for choice: Dictionary in choices:
		if str(choice.get("utility", "")) == "remove_card":
			return choice
	for choice: Dictionary in choices:
		if str(choice.get("rarity", "")) in ["ultra_rara", "ultra_rare"]:
			return choice
	for choice: Dictionary in choices:
		if str(choice.get("rarity", "")) in ["rara", "rare"]:
			return choice
	return choices[0] if not choices.is_empty() else {}

func _apply_pre_battle_shop(session, metrics: Dictionary) -> void:
	while session.can_buy_heal() and session.current_health <= maxi(8, int(session.max_health * 0.45)):
		var souls_before: int = session.soul_total
		_record_shop_purchase(session, metrics, "heal", session.buy_paid_heal(), souls_before)

func _apply_post_reward_shop(session, metrics: Dictionary, map_index: int) -> void:
	if map_index == 10 or map_index == 16:
		_record_shop_purchase(session, metrics, "max_hp", session.buy_shop_max_health(), session.soul_total)
	if map_index == 12 or map_index == 20:
		var remove_choices: Array[Dictionary] = session.shop_remove_card_choices()
		if not remove_choices.is_empty():
			_record_shop_purchase(session, metrics, "remove", session.buy_shop_remove_card(str(remove_choices[0].get("card_id", ""))), session.soul_total)
	if map_index == 18:
		var duplicate_choices: Array[Dictionary] = session.shop_duplicate_card_choices()
		if not duplicate_choices.is_empty():
			_record_shop_purchase(session, metrics, "duplicate", session.buy_shop_duplicate_card(str(duplicate_choices[0].get("card_id", ""))), session.soul_total)
	if map_index == 21 or map_index == 28:
		var relic_choices: Array[Dictionary] = session.shop_relic_choices()
		if not relic_choices.is_empty():
			_record_shop_purchase(session, metrics, "relic", session.buy_shop_relic(str(relic_choices[0].get("relic_id", ""))), session.soul_total)

func _record_shop_purchase(session, metrics: Dictionary, action_id: String, result: Dictionary, souls_before: int) -> void:
	if not bool(result.get("ok", false)):
		return
	var actions: Array = Array(metrics.get("shop_actions", []))
	actions.append(action_id)
	metrics["shop_actions"] = actions
	metrics["shop_usage"] = int(metrics.get("shop_usage", 0)) + 1
	metrics["souls_spent"] = int(metrics.get("souls_spent", 0)) + maxi(0, souls_before - session.soul_total)

func _estimated_turns_for_encounter(encounter: Dictionary) -> int:
	var turns: int = 4
	match str(encounter.get("tier", "")):
		"tutorial":
			turns = 3
		"small":
			turns = 4
		"medium":
			turns = 5
		"elite_optional":
			turns = 7
		"boss":
			turns = 10
	match str(encounter.get("mode", "")):
		"ondas":
			turns += 2
		"defesa_posicao":
			turns = maxi(turns, int(encounter.get("defense_turns", 5)))
		"sobreviver_turnos":
			turns = maxi(turns, int(encounter.get("survive_turns", 5)))
		"chefe_summoner":
			turns += 2
		"emboscada", "escolta", "invasao":
			turns += 1
	if maxi(int(encounter.get("player_slots_count", 0)), int(encounter.get("enemy_slots_count", 0))) >= 6:
		turns += 1
	return turns

func _estimated_hp_loss_for_encounter(encounter: Dictionary, map_index: int) -> int:
	var loss: int = 0
	match str(encounter.get("tier", "")):
		"tutorial":
			loss = 0 if map_index == 1 else 1
		"small":
			loss = 1
		"medium":
			loss = 2
		"elite_optional":
			loss = 3
		"boss":
			loss = 4
	match str(encounter.get("element", "")):
		"gelo":
			loss += 1
		"ar":
			loss += 1
		"fogo":
			loss += 2
	if str(encounter.get("mode", "")) in ["duelo", "invasao", "chefe_summoner"]:
		loss += 1
	if map_index >= 28:
		loss += 1
	return loss

func _write_outputs(output_dir: String, results: Array[Dictionary]) -> Dictionary:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	var json_path: String = "%s/run_lab_metrics.json" % output_dir
	var csv_path: String = "%s/run_lab_metrics.csv" % output_dir
	var json_file := FileAccess.open(json_path, FileAccess.WRITE)
	if json_file == null:
		return {"ok": false, "message": "Could not write %s." % json_path}
	json_file.store_string(JSON.stringify({"runs": results}, "\t"))
	var csv_file := FileAccess.open(csv_path, FileAccess.WRITE)
	if csv_file == null:
		return {"ok": false, "message": "Could not write %s." % csv_path}
	var headers: PackedStringArray = ["class_id", "seed", "ok", "completed_maps", "map_count", "estimated_turns", "hp_loss", "final_hp", "max_hp", "deck_size", "relic_count", "souls_earned", "souls_spent", "souls_left", "shop_usage", "deaths", "shop_actions", "message"]
	csv_file.store_line(",".join(headers))
	for result: Dictionary in results:
		var row: PackedStringArray = PackedStringArray()
		for header: String in headers:
			if header == "shop_actions":
				row.append(_csv_escape(";".join(Array(result.get(header, [])))))
			else:
				row.append(_csv_escape(str(result.get(header, ""))))
		csv_file.store_line(",".join(row))
	return {"ok": true, "json_path": json_path, "csv_path": csv_path}

func _csv_escape(value: String) -> String:
	if value.find(",") >= 0 or value.find("\"") >= 0 or value.find("\n") >= 0:
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value
