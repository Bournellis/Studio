class_name FpsArenaRoot
extends Node3D

const PlayerController = preload("res://gameplay/player/fps_player_controller.gd")
const BotController = preload("res://gameplay/bot/basic_duel_bot.gd")
const ArenaHudScript = preload("res://presentation/hud/arena_hud.gd")
const FeedbackControllerScript = preload("res://presentation/feedback/fps_feedback_controller.gd")
const ArenaDuelPitLayoutBuilderScript = preload("res://modes/arena/arena_duel_pit_layout_builder.gd")
const ArenaRelayFoundryLayoutBuilderScript = preload("res://modes/arena/arena_relay_foundry_layout_builder.gd")
const ArenaCrossfireCrucibleLayoutBuilderScript = preload("res://modes/arena/arena_crossfire_crucible_layout_builder.gd")
const ArenaLayoutCatalogScript = preload("res://modes/arena/arena_layout_catalog.gd")
const ArenaHudSnapshotBuilderScript = preload("res://modes/arena/arena_hud_snapshot_builder.gd")
const ArenaCombatRulesScript = preload("res://gameplay/arena/arena_combat_rules.gd")
const ArenaCombatPipelineScript = preload("res://modes/arena/arena_combat_pipeline.gd")
const BotTacticalContextScript = preload("res://gameplay/bot/bot_tactical_context.gd")
const ArenaTelemetryRecorderScript = preload("res://gameplay/telemetry/arena_telemetry_recorder.gd")

const MENU_SCENE_PATH: String = "res://modes/menu/main_menu.tscn"
const PLAYER_VISUAL_MUZZLE_RIGHT_OFFSET: float = 0.34
const PLAYER_VISUAL_MUZZLE_DOWN_OFFSET: float = 0.24
const PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET: float = 0.82
const PLAYER_SHOT_KNOCKBACK_LIFT: float = 1.75
const PLAYER_PLASMA_KNOCKBACK_LIFT: float = 2.25
const BOT_SHOT_KNOCKBACK_LIFT: float = 1.12
const PLASMA_BOLT_TTL: float = 2.45
const PLASMA_BLAST_RADIUS: float = 1.65
const PLASMA_OVERCHARGE_BLAST_RADIUS: float = 2.25
const PLASMA_BLAST_DAMAGE_FRACTION: float = 0.46
const PLASMA_BLAST_MIN_DAMAGE_FRACTION: float = 0.22
const PLASMA_BLAST_KNOCKBACK_FRACTION: float = 0.36
const PLASMA_BLAST_KNOCKBACK_LIFT: float = 0.8
const PICKUP_RADIUS: float = 1.05
const HEALTH_PICKUP_AMOUNT: float = 28.0
const HEALTH_PICKUP_RESPAWN: float = 10.0
const OVERCHARGE_PICKUP_RESPAWN: float = 14.0
const JUMP_PAD_RADIUS: float = 1.25
const JUMP_PAD_COOLDOWN: float = 0.64
const JUMP_PAD_VERTICAL_SPEED: float = 8.4
const JUMP_PAD_FORWARD_SPEED: float = 5.8
const TELEMETRY_SAMPLE_INTERVAL: float = 0.2
const TELEMETRY_PICKUP_NEAR_DISTANCE: float = 2.4
const TELEMETRY_PICKUP_CONTEST_DISTANCE: float = 4.0
const TELEMETRY_PICKUP_EVENT_COOLDOWN: float = 1.0
const TELEMETRY_JUMP_PAD_SUCCESS_DISTANCE: float = 3.2
const SCORE_TO_WIN: int = 3
const ROUND_STATE_PLAYING: StringName = &"playing"
const ROUND_STATE_PLAYER_WIN: StringName = &"player_round_win"
const ROUND_STATE_BOT_WIN: StringName = &"bot_round_win"
const ROUND_STATE_MATCH_OVER: StringName = &"match_over"
const WINNER_PLAYER: StringName = &"player"
const WINNER_BOT: StringName = &"bot"
var player
var bot
var hud
var feedback
var round_status: String = ""
var round_ended: bool = false
var round_state: StringName = ROUND_STATE_PLAYING
var player_score: int = 0
var bot_score: int = 0
var round_index: int = 1
var last_round_winner: StringName = &""
var match_winner: StringName = &""
var menu_open: bool = false
var projectile_root: Node3D
var pickup_root: Node3D
var active_projectiles: Array[Dictionary] = []
var pickups: Dictionary = {}
var jump_pads: Array[Dictionary] = []
var flow_marker_count: int = 0
var high_platform_cover_count: int = 0
var jump_pad_trigger_count: int = 0
var last_jump_pad_id: StringName = &""
var active_layout_id: StringName = ArenaLayoutCatalogScript.get_default_layout_id()
var active_layout: Dictionary = {}
var map_name: String = "Duel Pit V2"
var floor_size: Vector3 = Vector3(30.0, 1.0, 30.0)
var wall_height: float = 3.6
var wall_thickness: float = 0.8
var player_spawn: Vector3 = Vector3(-10.8, 0.05, 8.6)
var bot_spawn: Vector3 = Vector3(10.8, 0.05, -8.6)
var health_pickup_position: Vector3 = Vector3(-7.6, 3.55, -8.6)
var overcharge_pickup_position: Vector3 = Vector3(7.6, 3.55, 8.6)
var bot_arena_half_extent: float = 11.2
var telemetry
var telemetry_sample_elapsed: float = 0.0
var telemetry_round_started_msec: int = 0
var telemetry_projectile_sequence: int = 0
var telemetry_jump_pad_flights: Dictionary = {}
var telemetry_pickup_event_cooldowns: Dictionary = {}
var telemetry_last_bot_snapshot: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_prepare_active_layout()
	_configure_world()
	_spawn_runtime()
	_initialize_telemetry()
	_record_telemetry_arena_setup()
	_record_telemetry_round_start(&"initial")
	_capture_mouse_if_playing()

func _process(_delta: float) -> void:
	if hud != null:
		hud.update_snapshot(_build_hud_snapshot())

func _physics_process(delta: float) -> void:
	if round_ended or menu_open:
		return
	_process_projectiles(delta)
	_process_pickups(delta)
	_process_jump_pads(delta)
	_update_bot_awareness()
	_update_telemetry_frame(delta)

func _exit_tree() -> void:
	if telemetry != null:
		telemetry.finish_session({
			"reason": "arena_exit",
			"round_state": round_state,
			"player_score": player_score,
			"bot_score": bot_score
		})

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_back"):
		_set_menu_open(not menu_open)
		get_viewport().set_input_as_handled()
		return
	if menu_open:
		return
	if event is InputEventMouseButton and event.is_pressed() and Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		_capture_mouse_if_playing()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("restart_round"):
		restart_round()
		get_viewport().set_input_as_handled()

func set_arena_layout(layout_id: StringName) -> void:
	active_layout_id = ArenaLayoutCatalogScript.normalize_layout_id(layout_id)

func restart_round() -> void:
	if round_state == ROUND_STATE_MATCH_OVER:
		start_new_match()
		return
	_set_menu_open(false)
	if round_ended:
		round_index += 1
		_record_telemetry_event(&"round_reset", {
			"reason": "next_round",
			"next_round_index": round_index
		})
	else:
		_record_telemetry_event(&"round_reset", {
			"reason": "manual_restart",
			"next_round_index": round_index
		})
	_start_round()

func start_new_match() -> void:
	_set_menu_open(false)
	_record_telemetry_event(&"match_reset", {
		"previous_player_score": player_score,
		"previous_bot_score": bot_score,
		"previous_round_index": round_index
	})
	player_score = 0
	bot_score = 0
	round_index = 1
	last_round_winner = &""
	match_winner = &""
	_start_round()

func _start_round() -> void:
	round_state = ROUND_STATE_PLAYING
	round_status = _build_playing_status()
	round_ended = false
	player.global_position = player_spawn
	player.rotation = Vector3.ZERO
	player.configure_for_round()
	bot.global_position = bot_spawn
	bot.rotation = Vector3.ZERO
	bot.arena_half_extent = bot_arena_half_extent
	bot.configure(player)
	if hud != null:
		hud.reset_feedback()
	if feedback != null:
		feedback.clear_effects()
	_clear_projectiles()
	_reset_pickups()
	_reset_vertical_hazards()
	_update_bot_awareness()
	_record_telemetry_round_start(&"round_start")
	_capture_mouse_if_playing()

func debug_get_player():
	return player

func debug_get_bot():
	return bot

func debug_get_round_state() -> StringName:
	return round_state

func debug_get_round_index() -> int:
	return round_index

func debug_get_score_to_win() -> int:
	return SCORE_TO_WIN

func debug_get_player_score() -> int:
	return player_score

func debug_get_bot_score() -> int:
	return bot_score

func debug_get_last_round_winner() -> StringName:
	return last_round_winner

func debug_get_match_winner() -> StringName:
	return match_winner

func debug_get_hud_snapshot() -> Dictionary:
	return _build_hud_snapshot()

func debug_force_round_result(player_won: bool) -> void:
	_finish_round(player_won)

func debug_start_new_match() -> void:
	start_new_match()

func debug_get_player_visual_muzzle_origin(origin: Vector3, direction: Vector3) -> Vector3:
	return _get_player_visual_muzzle_origin(origin, direction)

func debug_get_player_spawn() -> Vector3:
	return player_spawn

func debug_get_bot_spawn() -> Vector3:
	return bot_spawn

func debug_get_active_layout_id() -> StringName:
	return active_layout_id

func debug_get_active_layout_name() -> String:
	return map_name

func debug_get_available_layout_ids() -> Array[StringName]:
	return ArenaLayoutCatalogScript.get_layout_ids()

func debug_get_bot_reposition_points() -> Array[Vector3]:
	var points: Array[Vector3] = []
	for point: Dictionary in _get_active_tactical_points(false):
		points.append(point.get("position", Vector3.ZERO))
	return points

func debug_get_bot_tactical_point_count() -> int:
	return _get_active_tactical_points(true).size()

func debug_get_bot_tactical_roles() -> Array[StringName]:
	var roles: Array[StringName] = []
	for point: Dictionary in _get_active_tactical_points(true):
		var role: StringName = point.get("role", &"")
		if not roles.has(role):
			roles.append(role)
	return roles

func debug_get_active_projectile_count() -> int:
	return active_projectiles.size()

func debug_get_telemetry_events() -> Array[Dictionary]:
	if telemetry == null:
		return []
	return telemetry.get_events()

func debug_get_telemetry_summary() -> Dictionary:
	if telemetry == null:
		return {}
	return telemetry.get_summary()

func debug_get_telemetry_output_paths() -> Dictionary:
	if telemetry == null:
		return {}
	return telemetry.get_output_paths()

func debug_get_plasma_blast_radius(overcharged: bool) -> float:
	return PLASMA_OVERCHARGE_BLAST_RADIUS if overcharged else PLASMA_BLAST_RADIUS

func debug_get_plasma_blast_damage_fraction() -> float:
	return PLASMA_BLAST_DAMAGE_FRACTION

func debug_get_plasma_blast_min_damage_fraction() -> float:
	return PLASMA_BLAST_MIN_DAMAGE_FRACTION

func debug_get_jump_pad_count() -> int:
	return jump_pads.size()

func debug_get_jump_pad_position(index: int = 0) -> Vector3:
	if index < 0 or index >= jump_pads.size():
		return Vector3.ZERO
	var pad: Dictionary = jump_pads[index]
	return pad.get("position", Vector3.ZERO)

func debug_get_jump_pad_target(index: int = 0) -> Vector3:
	if index < 0 or index >= jump_pads.size():
		return Vector3.ZERO
	var pad: Dictionary = jump_pads[index]
	return pad.get("target", Vector3.ZERO)

func debug_get_jump_pad_trigger_count() -> int:
	return jump_pad_trigger_count

func debug_get_last_jump_pad_id() -> StringName:
	return last_jump_pad_id

func debug_get_flow_marker_count() -> int:
	return flow_marker_count

func debug_has_high_platform_cover() -> bool:
	return high_platform_cover_count >= 2

func debug_get_pickup_jump_target_distance(pickup_kind: StringName) -> float:
	var pickup_position := debug_get_pickup_position(pickup_kind)
	var target_position := _get_nearest_jump_pad_target(pickup_position)
	pickup_position.y = 0.0
	target_position.y = 0.0
	return pickup_position.distance_to(target_position)

func debug_get_pickup_position(pickup_kind: StringName) -> Vector3:
	var entry: Dictionary = pickups.get(pickup_kind, {})
	return entry.get("position", Vector3.ZERO)

func debug_is_pickup_available(pickup_kind: StringName) -> bool:
	var entry: Dictionary = pickups.get(pickup_kind, {})
	return bool(entry.get("available", false))

func debug_force_pickup_available(pickup_kind: StringName, available: bool) -> void:
	if not pickups.has(pickup_kind):
		return
	var entry: Dictionary = pickups[pickup_kind]
	entry["available"] = available
	entry["respawn_remaining"] = 0.0 if available else 9999.0
	var node := entry.get("node", null) as Node3D
	if node != null:
		node.visible = available
	pickups[pickup_kind] = entry
	_update_bot_awareness()

func _prepare_active_layout() -> void:
	active_layout_id = ArenaLayoutCatalogScript.normalize_layout_id(active_layout_id)
	active_layout = ArenaLayoutCatalogScript.build_layout_spec(active_layout_id)
	active_layout_id = active_layout.get("id", active_layout_id)
	map_name = String(active_layout.get("map_name", "Arena Shooter"))
	round_status = _build_playing_status()
	floor_size = active_layout.get("floor_size", floor_size)
	wall_height = float(active_layout.get("wall_height", wall_height))
	wall_thickness = float(active_layout.get("wall_thickness", wall_thickness))
	player_spawn = active_layout.get("player_spawn", player_spawn)
	bot_spawn = active_layout.get("bot_spawn", bot_spawn)
	health_pickup_position = active_layout.get("health_pickup_position", health_pickup_position)
	overcharge_pickup_position = active_layout.get("overcharge_pickup_position", overcharge_pickup_position)
	bot_arena_half_extent = float(active_layout.get("bot_arena_half_extent", bot_arena_half_extent))

func _configure_world() -> void:
	var environment := WorldEnvironment.new()
	environment.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.045, 0.06, 0.085, 1.0)
	env.ambient_light_color = Color(0.7, 0.82, 0.95, 1.0)
	env.ambient_light_energy = 0.82
	environment.environment = env
	add_child(environment)

	var key_light := DirectionalLight3D.new()
	key_light.name = "KeyLight"
	key_light.rotation_degrees = Vector3(-58.0, -38.0, 0.0)
	key_light.light_energy = 2.6
	key_light.shadow_enabled = true
	add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.name = "DraxosFillLight"
	fill_light.position = Vector3(0.0, 6.0, 0.0)
	fill_light.light_color = Color(0.42, 0.86, 1.0, 1.0)
	fill_light.light_energy = 1.4
	fill_light.omni_range = 32.0
	add_child(fill_light)

	_build_active_layout()

func _build_active_layout() -> void:
	jump_pads.clear()
	flow_marker_count = 0
	high_platform_cover_count = 0
	var layout_result: Dictionary = {}
	match active_layout.get("builder", active_layout_id):
		ArenaLayoutCatalogScript.DUEL_PIT_ID:
			layout_result = ArenaDuelPitLayoutBuilderScript.build(self, active_layout)
		ArenaLayoutCatalogScript.RELAY_FOUNDRY_ID:
			layout_result = ArenaRelayFoundryLayoutBuilderScript.build(self, active_layout)
		ArenaLayoutCatalogScript.CROSSFIRE_CRUCIBLE_ID:
			layout_result = ArenaCrossfireCrucibleLayoutBuilderScript.build(self, active_layout)
		_:
			layout_result = ArenaDuelPitLayoutBuilderScript.build(self, active_layout)
	for pad: Dictionary in layout_result.get("jump_pads", []):
		jump_pads.append(pad)
	flow_marker_count = int(layout_result.get("flow_marker_count", 0))
	high_platform_cover_count = int(layout_result.get("high_platform_cover_count", 0))

func _spawn_runtime() -> void:
	var runtime_root := Node3D.new()
	runtime_root.name = "RuntimeRoot"
	add_child(runtime_root)

	player = PlayerController.new()
	player.name = "Player"
	player.position = player_spawn
	runtime_root.add_child(player)
	player.shoot_requested.connect(_on_player_shot)
	player.alt_fire_requested.connect(_on_player_alt_fire)

	bot = BotController.new()
	bot.name = "Bot"
	bot.position = bot_spawn
	bot.arena_half_extent = bot_arena_half_extent
	runtime_root.add_child(bot)
	bot.set_tactical_context(_create_bot_tactical_context(runtime_root))
	bot.configure(player)
	bot.shot_windup_started.connect(_on_bot_shot_windup_started)
	bot.shot_feedback_requested.connect(_on_bot_shot_feedback_requested)
	bot.shot_resolution_requested.connect(_on_bot_shot_resolution_requested)

	projectile_root = Node3D.new()
	projectile_root.name = "Projectiles"
	runtime_root.add_child(projectile_root)

	pickup_root = Node3D.new()
	pickup_root.name = "Pickups"
	runtime_root.add_child(pickup_root)
	_build_pickups()
	_update_bot_awareness()

	feedback = FeedbackControllerScript.new()
	feedback.name = "FeedbackController"
	add_child(feedback)

	player.damaged.connect(_on_player_damaged)
	player.died.connect(_on_player_died)
	bot.died.connect(_on_bot_died)

	hud = ArenaHudScript.new()
	hud.name = "ArenaHud"
	add_child(hud)
	hud.sensitivity_changed.connect(_on_sensitivity_changed)
	hud.resume_requested.connect(func() -> void:
		_set_menu_open(false)
	)
	hud.main_menu_requested.connect(_return_to_main_menu)
	hud.new_match_requested.connect(start_new_match)
	hud.set_sensitivity_value(player.mouse_sensitivity)

func _on_player_shot(origin: Vector3, direction: Vector3, damage: float, knockback: float) -> void:
	if round_ended or menu_open:
		return
	var shot_direction := direction.normalized()
	var shot_end := origin + shot_direction * 96.0
	var visual_origin := _get_player_visual_muzzle_origin(origin, shot_direction)
	var shot_id := _next_telemetry_id("player_rifle")
	var overcharged := ArenaCombatPipelineScript.is_overcharged_damage(damage, player.shot_damage)
	_record_telemetry_event(&"shot_fired", ArenaCombatPipelineScript.build_player_rifle_fired(shot_id, origin, shot_direction, damage, knockback, overcharged))
	if hud != null:
		hud.show_player_shot()
	if feedback != null:
		feedback.play_player_shot(visual_origin, shot_direction)

	var query := PhysicsRayQueryParameters3D.create(origin, shot_end)
	query.exclude = [player.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		_record_telemetry_event(&"shot_miss", ArenaCombatPipelineScript.build_player_rifle_miss(shot_id, shot_end, origin.distance_to(shot_end), overcharged))
		if hud != null:
			hud.show_miss()
		if feedback != null:
			feedback.play_miss(visual_origin, shot_end)
		return
	var impact_position: Vector3 = result.get("position", shot_end)
	var collider: Object = result.get("collider", null)
	if collider != null and collider.has_method("take_damage"):
		var target_id := _get_combatant_id(collider)
		collider.take_damage(damage, &"player")
		if collider.has_method("apply_knockback"):
			collider.apply_knockback(shot_direction, knockback, PLAYER_SHOT_KNOCKBACK_LIFT)
		var target_health := float(collider.get("health")) if collider.get("health") != null else 0.0
		_record_telemetry_event(&"shot_hit", ArenaCombatPipelineScript.build_player_rifle_hit(shot_id, target_id, impact_position, origin.distance_to(impact_position), overcharged))
		_record_telemetry_event(&"damage_applied", ArenaCombatPipelineScript.build_damage_applied(shot_id, "player", target_id, "rifle", "player_rifle", overcharged, damage, target_health))
		_record_telemetry_event(&"knockback_applied", ArenaCombatPipelineScript.build_knockback_applied(shot_id, "player", target_id, "rifle", knockback, PLAYER_SHOT_KNOCKBACK_LIFT))
		if hud != null:
			var killed: bool = collider.get("is_dead") == true
			hud.show_hit_confirm(killed)
		if feedback != null:
			feedback.play_hit(visual_origin, impact_position)
			var knockback_position := impact_position
			if collider.has_method("get_body_center"):
				knockback_position = collider.get_body_center()
			feedback.play_knockback(knockback_position, shot_direction, knockback, true)
		return
	_record_telemetry_event(&"shot_miss", ArenaCombatPipelineScript.build_player_rifle_miss(shot_id, impact_position, origin.distance_to(impact_position), overcharged))
	if hud != null:
		hud.show_miss()
	if feedback != null:
		feedback.play_miss(visual_origin, impact_position)

func _on_player_alt_fire(origin: Vector3, direction: Vector3, damage: float, knockback: float, speed: float, radius: float, overcharged: bool) -> void:
	if round_ended or menu_open:
		return
	var shot_direction := direction.normalized()
	if shot_direction.length_squared() <= 0.0001:
		return
	var visual_origin := _get_player_visual_muzzle_origin(origin, shot_direction)
	var aim_point := _resolve_player_aim_point(origin, shot_direction)
	var projectile_direction := ArenaCombatRulesScript.build_projectile_direction(visual_origin, aim_point, shot_direction)
	var projectile_id := _next_telemetry_id("player_plasma")
	_record_telemetry_event(&"shot_fired", ArenaCombatPipelineScript.build_player_plasma_fired(projectile_id, origin, visual_origin, projectile_direction, damage, knockback, speed, radius, overcharged))
	if hud != null:
		hud.show_player_alt_fire(overcharged)
	if feedback != null:
		feedback.play_plasma_shot(visual_origin, projectile_direction, overcharged)
	_spawn_player_plasma_bolt(visual_origin, projectile_direction, damage, knockback, speed, radius, overcharged, projectile_id)

func _spawn_player_plasma_bolt(origin: Vector3, direction: Vector3, damage: float, knockback: float, speed: float, radius: float, overcharged: bool, projectile_id: String = "") -> void:
	if projectile_root == null:
		return
	var bolt := Node3D.new()
	bolt.name = "PlayerPlasmaBolt"
	projectile_root.add_child(bolt)
	bolt.global_position = origin

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PlasmaBoltMesh"
	var mesh := SphereMesh.new()
	mesh.radius = radius * (1.12 if overcharged else 1.0)
	mesh.height = mesh.radius * 2.0
	mesh.radial_segments = 16
	mesh.rings = 8
	mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_plasma_material(overcharged)
	bolt.add_child(mesh_instance)

	var light := OmniLight3D.new()
	light.name = "PlasmaBoltLight"
	light.light_color = Color(0.78, 0.46, 1.0, 1.0) if overcharged else Color(0.38, 0.98, 1.0, 1.0)
	light.light_energy = 2.5 if overcharged else 1.8
	light.omni_range = 2.8
	bolt.add_child(light)

	active_projectiles.append({
		"node": bolt,
		"velocity": direction.normalized() * maxf(1.0, speed),
		"damage": damage,
		"knockback": knockback,
		"radius": radius * (1.12 if overcharged else 1.0),
		"ttl": PLASMA_BOLT_TTL,
		"source": &"player",
		"overcharged": overcharged,
		"projectile_id": projectile_id
	})
	_record_telemetry_event(&"plasma_spawned", ArenaCombatPipelineScript.build_player_plasma_spawned(projectile_id, origin, direction, damage, knockback, speed, radius, PLASMA_BOLT_TTL, overcharged))
	_update_bot_awareness()

func _process_projectiles(delta: float) -> void:
	for index in range(active_projectiles.size() - 1, -1, -1):
		var entry := active_projectiles[index]
		var bolt := entry.get("node", null) as Node3D
		if bolt == null or not is_instance_valid(bolt):
			active_projectiles.remove_at(index)
			continue
		var ttl := float(entry.get("ttl", 0.0)) - delta
		var velocity: Vector3 = entry.get("velocity", Vector3.ZERO)
		var start_position := bolt.global_position
		var end_position := start_position + velocity * delta
		var result := _query_player_projectile_impact(start_position, end_position, float(entry.get("radius", 0.0)))
		if not result.is_empty():
			var impact_position: Vector3 = result.get("position", end_position)
			var collider: Object = result.get("collider", null)
			_resolve_player_projectile_hit(entry, impact_position, collider)
			_remove_projectile(index)
			continue
		bolt.global_position = end_position
		if ttl <= 0.0:
			var projectile_id := String(entry.get("projectile_id", ""))
			var overcharged := bool(entry.get("overcharged", false))
			_record_telemetry_event(&"plasma_expired", ArenaCombatPipelineScript.build_player_plasma_expired(projectile_id, end_position, overcharged))
			_record_telemetry_event(&"shot_miss", ArenaCombatPipelineScript.build_player_plasma_miss(projectile_id, end_position, overcharged))
			if hud != null:
				hud.show_miss()
			if feedback != null:
				feedback.play_plasma_miss(end_position, bool(entry.get("overcharged", false)))
			_remove_projectile(index)
			continue
		entry["ttl"] = ttl
		active_projectiles[index] = entry
	_update_bot_awareness()

func _resolve_player_projectile_hit(entry: Dictionary, impact_position: Vector3, collider: Object) -> void:
	var velocity: Vector3 = entry.get("velocity", Vector3.FORWARD)
	var shot_direction := velocity.normalized()
	var overcharged := bool(entry.get("overcharged", false))
	var projectile_id := String(entry.get("projectile_id", ""))
	if collider != null and collider.has_method("take_damage"):
		var damage := float(entry.get("damage", 0.0))
		var knockback := float(entry.get("knockback", 0.0))
		var target_id := _get_combatant_id(collider)
		collider.take_damage(damage, &"player")
		if collider.has_method("apply_knockback"):
			collider.apply_knockback(shot_direction, knockback, PLAYER_PLASMA_KNOCKBACK_LIFT)
		var target_health := float(collider.get("health")) if collider.get("health") != null else 0.0
		_record_telemetry_event(&"plasma_direct_hit", ArenaCombatPipelineScript.build_player_plasma_direct_hit(projectile_id, target_id, impact_position, damage, knockback, overcharged))
		_record_telemetry_event(&"shot_hit", ArenaCombatPipelineScript.build_player_plasma_direct_shot_hit(projectile_id, target_id, impact_position, overcharged))
		_record_telemetry_event(&"damage_applied", ArenaCombatPipelineScript.build_damage_applied(projectile_id, "player", target_id, "plasma_direct", "player_plasma", overcharged, damage, target_health))
		_record_telemetry_event(&"knockback_applied", ArenaCombatPipelineScript.build_knockback_applied(projectile_id, "player", target_id, "plasma_direct", knockback, PLAYER_PLASMA_KNOCKBACK_LIFT))
		var killed: bool = collider.get("is_dead") == true
		if hud != null:
			hud.show_plasma_hit(overcharged, killed)
		if feedback != null:
			feedback.play_plasma_hit(impact_position, overcharged)
			var knockback_position := impact_position
			if collider.has_method("get_body_center"):
				knockback_position = collider.get_body_center()
			feedback.play_knockback(knockback_position, shot_direction, knockback, true)
		return
	_record_telemetry_event(&"plasma_world_impact", ArenaCombatPipelineScript.build_player_plasma_world_impact(projectile_id, impact_position, overcharged))
	_resolve_player_projectile_blast(entry, impact_position, shot_direction)

func _resolve_player_projectile_blast(entry: Dictionary, impact_position: Vector3, shot_direction: Vector3) -> void:
	var overcharged := bool(entry.get("overcharged", false))
	var projectile_id := String(entry.get("projectile_id", ""))
	var blast_radius := PLASMA_OVERCHARGE_BLAST_RADIUS if overcharged else PLASMA_BLAST_RADIUS
	var damaged_target := false
	var killed_target := false
	var target_position := Vector3.ZERO
	var falloff := 0.0
	var blast_damage := 0.0
	if bot != null and bot.get("is_dead") != true:
		target_position = bot.get_body_center()
		var blast_result := ArenaCombatPipelineScript.calculate_player_plasma_blast(
			impact_position,
			target_position,
			shot_direction,
			float(entry.get("damage", 0.0)),
			float(entry.get("knockback", 0.0)),
			blast_radius,
			PLASMA_BLAST_DAMAGE_FRACTION,
			PLASMA_BLAST_MIN_DAMAGE_FRACTION,
			PLASMA_BLAST_KNOCKBACK_FRACTION
		)
		blast_damage = float(blast_result.get("damage", 0.0))
		if blast_damage > 0.0:
			falloff = float(blast_result.get("falloff", 0.0))
			var blast_direction: Vector3 = blast_result.get("direction", shot_direction)
			bot.take_damage(blast_damage, &"player")
			if bot.has_method("apply_knockback"):
				var blast_knockback := float(blast_result.get("knockback", 0.0))
				bot.apply_knockback(blast_direction, blast_knockback, PLASMA_BLAST_KNOCKBACK_LIFT)
				_record_telemetry_event(&"knockback_applied", ArenaCombatPipelineScript.build_knockback_applied(projectile_id, "player", "bot", "plasma_blast", blast_knockback, PLASMA_BLAST_KNOCKBACK_LIFT, falloff, true))
			damaged_target = true
			killed_target = bot.get("is_dead") == true
			_record_telemetry_event(&"shot_hit", ArenaCombatPipelineScript.build_player_plasma_blast_shot_hit(projectile_id, impact_position, target_position, falloff, overcharged))
			_record_telemetry_event(&"damage_applied", ArenaCombatPipelineScript.build_damage_applied(projectile_id, "player", "bot", "plasma_blast", "player_plasma_blast", overcharged, blast_damage, bot.health, falloff, true))
			if feedback != null:
				feedback.play_knockback(target_position, blast_direction, float(entry.get("knockback", 0.0)) * PLASMA_BLAST_KNOCKBACK_FRACTION, true)
	_record_telemetry_event(&"plasma_blast", ArenaCombatPipelineScript.build_player_plasma_blast_summary(projectile_id, impact_position, target_position, blast_radius, falloff, blast_damage, damaged_target, killed_target, overcharged))
	if not damaged_target:
		_record_telemetry_event(&"shot_miss", ArenaCombatPipelineScript.build_player_plasma_blast_miss(projectile_id, impact_position, overcharged))
	if hud != null:
		if damaged_target:
			hud.show_plasma_blast(overcharged, killed_target)
		else:
			hud.show_miss()
	if feedback != null:
		feedback.play_plasma_blast(impact_position, blast_radius, overcharged, damaged_target)

func _resolve_player_aim_point(origin: Vector3, direction: Vector3) -> Vector3:
	var aim_end := origin + direction.normalized() * 96.0
	var query := PhysicsRayQueryParameters3D.create(origin, aim_end)
	if player != null:
		query.exclude = [player.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return aim_end
	return result.get("position", aim_end)

func _query_player_projectile_impact(start_position: Vector3, end_position: Vector3, radius: float) -> Dictionary:
	var exclusions: Array[RID] = []
	if player != null:
		exclusions.append(player.get_rid())

	var ray_query := PhysicsRayQueryParameters3D.create(start_position, end_position)
	ray_query.exclude = exclusions
	var ray_result := get_world_3d().direct_space_state.intersect_ray(ray_query)
	if not ray_result.is_empty():
		return ray_result

	var sphere := SphereShape3D.new()
	sphere.radius = maxf(0.05, radius)
	var shape_query := PhysicsShapeQueryParameters3D.new()
	shape_query.shape = sphere
	shape_query.transform = Transform3D(Basis(), end_position)
	shape_query.exclude = exclusions
	var overlaps := get_world_3d().direct_space_state.intersect_shape(shape_query, 8)
	if overlaps.is_empty():
		return {}
	for overlap: Dictionary in overlaps:
		var collider: Object = overlap.get("collider", null)
		if collider != null and collider.has_method("take_damage"):
			overlap["position"] = end_position
			return overlap
	var first_overlap: Dictionary = overlaps[0]
	first_overlap["position"] = end_position
	return first_overlap

func _remove_projectile(index: int) -> void:
	if index < 0 or index >= active_projectiles.size():
		return
	var entry := active_projectiles[index]
	var bolt := entry.get("node", null) as Node3D
	if bolt != null and is_instance_valid(bolt):
		bolt.queue_free()
	active_projectiles.remove_at(index)
	_update_bot_awareness()

func _clear_projectiles() -> void:
	for entry: Dictionary in active_projectiles:
		var bolt := entry.get("node", null) as Node3D
		if bolt != null and is_instance_valid(bolt):
			bolt.queue_free()
	active_projectiles.clear()

func _on_player_damaged(amount: float, remaining_health: float) -> void:
	if hud != null and player != null:
		hud.show_player_damage(amount, remaining_health / maxf(1.0, player.max_health))
	if feedback != null and player != null:
		feedback.play_player_damage(amount, player.health_fraction(), player.get_body_center())

func _on_bot_shot_windup_started(origin: Vector3, target_position: Vector3, duration: float) -> void:
	if round_ended or menu_open:
		return
	_record_telemetry_event(&"bot_windup_started", {
		"actor": "bot",
		"weapon": "bot_shot",
		"origin": origin,
		"target_position": target_position,
		"duration": duration,
		"state": bot.debug_get_state() if bot != null else &"",
		"route_label": bot.debug_get_route_label() if bot != null else &"",
		"active_route_key": bot.debug_get_active_route_key() if bot != null else &"",
		"decision_reason": bot.debug_get_decision_reason() if bot != null else &""
	})
	if hud != null:
		hud.show_bot_tell(duration)
	if feedback != null:
		feedback.play_bot_tell(origin, target_position, duration)

func _on_bot_shot_feedback_requested(origin: Vector3, target_position: Vector3) -> void:
	if round_ended or menu_open:
		return
	if feedback != null:
		feedback.play_bot_shot(origin, target_position)

func _on_bot_shot_resolution_requested(origin: Vector3, direction: Vector3, damage: float, knockback: float) -> void:
	if round_ended or menu_open or player == null or bot == null:
		return
	var shot_direction := direction.normalized()
	if shot_direction.length_squared() <= 0.0001:
		return
	var shot_id := _next_telemetry_id("bot_shot")
	var overcharged := ArenaCombatPipelineScript.is_overcharged_damage(damage, bot.shoot_damage)
	var fired_payload := ArenaCombatPipelineScript.build_bot_shot_fired(shot_id, origin, shot_direction, damage, knockback, overcharged)
	_record_telemetry_event(&"shot_fired", fired_payload)
	_record_telemetry_event(&"bot_shot_resolved", fired_payload)
	var shot_end := origin + shot_direction * maxf(1.0, bot.shoot_range)
	var query := PhysicsRayQueryParameters3D.create(origin, shot_end)
	query.exclude = [bot.get_rid()]
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		_record_telemetry_event(&"shot_miss", ArenaCombatPipelineScript.build_bot_shot_miss(shot_id, shot_end, origin.distance_to(shot_end), overcharged))
		if feedback != null:
			feedback.play_bot_miss(origin, shot_end)
		return

	var impact_position: Vector3 = result.get("position", shot_end)
	var collider: Object = result.get("collider", null)
	if collider == player:
		if feedback != null:
			feedback.play_bot_shot(origin, impact_position)
		player.take_damage(damage, &"bot")
		player.apply_knockback(shot_direction, knockback, BOT_SHOT_KNOCKBACK_LIFT)
		_record_telemetry_event(&"shot_hit", ArenaCombatPipelineScript.build_bot_shot_hit(shot_id, impact_position, origin.distance_to(impact_position), overcharged))
		_record_telemetry_event(&"damage_applied", ArenaCombatPipelineScript.build_damage_applied(shot_id, "bot", "player", "bot_shot", "bot_shot", overcharged, damage, player.health))
		_record_telemetry_event(&"knockback_applied", ArenaCombatPipelineScript.build_knockback_applied(shot_id, "bot", "player", "bot_shot", knockback, BOT_SHOT_KNOCKBACK_LIFT))
		if feedback != null:
			feedback.play_knockback(player.get_body_center(), shot_direction, knockback, false)
		return
	_record_telemetry_event(&"shot_miss", ArenaCombatPipelineScript.build_bot_shot_miss(shot_id, impact_position, origin.distance_to(impact_position), overcharged))
	if feedback != null:
		feedback.play_bot_miss(origin, impact_position)

func _on_player_died() -> void:
	_finish_round(false)

func _on_bot_died() -> void:
	_finish_round(true)

func _finish_round(player_won: bool) -> void:
	if round_ended:
		return
	_set_menu_open(false)
	round_ended = true
	last_round_winner = WINNER_PLAYER if player_won else WINNER_BOT
	if player_won:
		player_score += 1
	else:
		bot_score += 1
	var winner_reached_target := player_score >= SCORE_TO_WIN if player_won else bot_score >= SCORE_TO_WIN
	if winner_reached_target:
		round_state = ROUND_STATE_MATCH_OVER
		match_winner = last_round_winner
	else:
		round_state = ROUND_STATE_PLAYER_WIN if player_won else ROUND_STATE_BOT_WIN
		match_winner = &""
	round_status = _build_result_status()
	if hud != null:
		hud.show_round_end(player_won)
	if feedback != null:
		feedback.play_round_end(player_won)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_record_telemetry_round_end(last_round_winner)

func _build_hud_snapshot() -> Dictionary:
	return ArenaHudSnapshotBuilderScript.build_snapshot({
		"status": round_status,
		"map_name": map_name,
		"round_state": round_state,
		"round_index": round_index,
		"score_to_win": SCORE_TO_WIN,
		"player_score": player_score,
		"bot_score": bot_score,
		"last_round_winner": last_round_winner,
		"match_winner": match_winner,
		"player": player,
		"bot": bot,
		"health_pickup_available": debug_is_pickup_available(&"health"),
		"health_pickup_respawn": _get_pickup_respawn_remaining(&"health"),
		"overcharge_pickup_available": debug_is_pickup_available(&"overcharge"),
		"overcharge_pickup_respawn": _get_pickup_respawn_remaining(&"overcharge"),
		"last_jump_pad_id": last_jump_pad_id,
		"round_ended": round_ended
	})

func _build_playing_status() -> String:
	return ArenaHudSnapshotBuilderScript.build_playing_status(map_name, round_index, player_score, bot_score)

func _build_result_status() -> String:
	return ArenaHudSnapshotBuilderScript.build_result_status(
		round_state,
		last_round_winner,
		player_score,
		bot_score,
		round_index
	)

func _build_pickups() -> void:
	pickups.clear()
	_create_pickup(&"health", health_pickup_position, Color(0.38, 1.0, 0.52, 1.0))
	_create_pickup(&"overcharge", overcharge_pickup_position, Color(0.78, 0.46, 1.0, 1.0))

func _create_pickup(pickup_kind: StringName, pickup_position: Vector3, color: Color) -> void:
	if pickup_root == null:
		return
	var pickup := Node3D.new()
	pickup.name = "HealthShard" if pickup_kind == &"health" else "Overcharge"
	pickup_root.add_child(pickup)
	pickup.global_position = pickup_position

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PickupMesh"
	if pickup_kind == &"health":
		var mesh := SphereMesh.new()
		mesh.radius = 0.32
		mesh.height = 0.64
		mesh.radial_segments = 12
		mesh.rings = 6
		mesh_instance.mesh = mesh
	else:
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.52, 0.52, 0.52)
		mesh_instance.mesh = mesh
	mesh_instance.material_override = _build_pickup_material(color)
	pickup.add_child(mesh_instance)
	_add_pickup_readability_beacon(pickup, pickup_kind, color)

	var light := OmniLight3D.new()
	light.name = "PickupLight"
	light.light_color = color
	light.light_energy = 1.55
	light.omni_range = 2.6
	pickup.add_child(light)

	pickups[pickup_kind] = {
		"node": pickup,
		"position": pickup_position,
		"available": true,
		"respawn_remaining": 0.0
	}

func _add_pickup_readability_beacon(pickup: Node3D, pickup_kind: StringName, color: Color) -> void:
	var halo := MeshInstance3D.new()
	halo.name = "ReadabilityHalo"
	var halo_mesh := CylinderMesh.new()
	halo_mesh.top_radius = 0.72 if pickup_kind == &"health" else 0.82
	halo_mesh.bottom_radius = halo_mesh.top_radius
	halo_mesh.height = 0.035
	halo_mesh.radial_segments = 24
	halo.mesh = halo_mesh
	halo.position = Vector3(0.0, -0.32, 0.0)
	halo.material_override = _build_pickup_material(Color(color.r, color.g, color.b, 0.82))
	pickup.add_child(halo)

	var beacon := MeshInstance3D.new()
	beacon.name = "ReadabilityBeacon"
	var beacon_mesh := BoxMesh.new()
	beacon_mesh.size = Vector3(0.08, 1.15, 0.08)
	beacon.mesh = beacon_mesh
	beacon.position = Vector3(0.0, 0.85, 0.0)
	beacon.material_override = _build_pickup_material(Color(color.r, color.g, color.b, 0.68))
	pickup.add_child(beacon)

func _process_pickups(delta: float) -> void:
	_update_telemetry_pickup_cooldowns(delta)
	for pickup_kind in pickups.keys():
		var entry: Dictionary = pickups[pickup_kind]
		var pickup_node := entry.get("node", null) as Node3D
		if pickup_node != null and bool(entry.get("available", false)):
			pickup_node.rotate_y(delta * 1.8)
		if not bool(entry.get("available", false)):
			var remaining := maxf(0.0, float(entry.get("respawn_remaining", 0.0)) - delta)
			entry["respawn_remaining"] = remaining
			if remaining <= 0.0:
				entry["available"] = true
				if pickup_node != null:
					pickup_node.visible = true
				_record_telemetry_event(&"pickup_respawned", {
					"pickup_kind": pickup_kind,
					"position": entry.get("position", Vector3.ZERO)
				})
			pickups[pickup_kind] = entry
			continue
		if player != null and _try_consume_pickup(pickup_kind, player):
			continue
		if bot != null:
			if _try_consume_pickup(pickup_kind, bot):
				continue
		_maybe_record_pickup_nearby_ignored(pickup_kind, player)
		_maybe_record_pickup_nearby_ignored(pickup_kind, bot)
		_maybe_record_pickup_contested(pickup_kind)

func _process_jump_pads(delta: float) -> void:
	for index in range(jump_pads.size()):
		var pad: Dictionary = jump_pads[index]
		pad["player_cooldown"] = maxf(0.0, float(pad.get("player_cooldown", 0.0)) - delta)
		pad["bot_cooldown"] = maxf(0.0, float(pad.get("bot_cooldown", 0.0)) - delta)
		if _try_trigger_jump_pad(pad, player, &"player"):
			pad["player_cooldown"] = JUMP_PAD_COOLDOWN
		if _try_trigger_jump_pad(pad, bot, &"bot"):
			pad["bot_cooldown"] = JUMP_PAD_COOLDOWN
		jump_pads[index] = pad

func _try_trigger_jump_pad(pad: Dictionary, combatant, actor_id: StringName) -> bool:
	if combatant == null or combatant.get("is_dead") == true:
		return false
	var cooldown_key := "player_cooldown" if actor_id == &"player" else "bot_cooldown"
	if float(pad.get(cooldown_key, 0.0)) > 0.0:
		return false
	var pad_position: Vector3 = pad.get("position", Vector3.ZERO)
	var flat_delta: Vector3 = combatant.global_position - pad_position
	flat_delta.y = 0.0
	if flat_delta.length() > JUMP_PAD_RADIUS:
		return false
	if combatant.global_position.y > pad_position.y + 1.1:
		return false
	var launch_velocity := _build_jump_pad_launch_velocity(pad)
	if combatant.has_method("apply_jump_pad_launch"):
		combatant.apply_jump_pad_launch(launch_velocity)
	else:
		combatant.apply_knockback(launch_velocity.normalized(), launch_velocity.length(), JUMP_PAD_VERTICAL_SPEED)
	jump_pad_trigger_count += 1
	last_jump_pad_id = pad.get("id", &"")
	if hud != null and actor_id == &"player":
		hud.show_jump_pad()
	if feedback != null:
		feedback.play_jump_pad(pad_position, launch_velocity)
	_record_telemetry_event(&"jump_pad_triggered", {
		"actor": actor_id,
		"pad_id": pad.get("id", &""),
		"position": pad_position,
		"target": pad.get("target", Vector3.ZERO),
		"launch_velocity": launch_velocity
	})
	telemetry_jump_pad_flights[String(actor_id)] = {
		"pad_id": String(pad.get("id", &"")),
		"target": pad.get("target", Vector3.ZERO),
		"started_at": Time.get_ticks_msec()
	}
	return true

func _build_jump_pad_launch_velocity(pad: Dictionary) -> Vector3:
	var pad_position: Vector3 = pad.get("position", Vector3.ZERO)
	var target_position: Vector3 = pad.get("target", pad_position + Vector3.FORWARD)
	var flat := target_position - pad_position
	flat.y = 0.0
	if flat.length_squared() <= 0.0001:
		flat = Vector3.FORWARD
	return flat.normalized() * JUMP_PAD_FORWARD_SPEED + Vector3.UP * JUMP_PAD_VERTICAL_SPEED

func _try_consume_pickup(pickup_kind: StringName, combatant) -> bool:
	if not pickups.has(pickup_kind) or combatant == null:
		return false
	if combatant.get("is_dead") == true:
		return false
	var entry: Dictionary = pickups[pickup_kind]
	if not bool(entry.get("available", false)):
		return false
	var pickup_position: Vector3 = entry.get("position", Vector3.ZERO)
	if combatant.get_body_center().distance_to(pickup_position) > PICKUP_RADIUS:
		return false
	var actor_id := _get_combatant_id(combatant)
	var health_before := float(combatant.get("health")) if combatant.get("health") != null else 0.0
	var max_health := float(combatant.get("max_health")) if combatant.get("max_health") != null else 1.0
	var healing_applied := 0.0
	var healing_wasted := 0.0
	match pickup_kind:
		&"health":
			if not combatant.has_method("heal"):
				return false
			healing_applied = combatant.heal(HEALTH_PICKUP_AMOUNT)
			healing_wasted = maxf(0.0, HEALTH_PICKUP_AMOUNT - healing_applied)
			if healing_applied <= 0.0:
				return false
		&"overcharge":
			if not combatant.has_method("grant_overcharge"):
				return false
			if combatant.has_method("has_overcharge_charge") and combatant.has_overcharge_charge():
				return false
			combatant.grant_overcharge()
		_:
			return false
	_set_pickup_available(pickup_kind, false)
	if hud != null and combatant == player:
		hud.show_pickup(pickup_kind)
	if feedback != null:
		feedback.play_pickup(pickup_position, pickup_kind)
	_record_telemetry_event(&"pickup_collected", {
		"actor": actor_id,
		"pickup_kind": pickup_kind,
		"position": pickup_position,
		"health_before": health_before,
		"health_after": float(combatant.get("health")) if combatant.get("health") != null else health_before,
		"max_health": max_health,
		"healing_applied": healing_applied,
		"healing_wasted": healing_wasted,
		"has_overcharge": combatant.has_method("has_overcharge_charge") and combatant.has_overcharge_charge()
	})
	_update_bot_awareness()
	return true

func _set_pickup_available(pickup_kind: StringName, available: bool) -> void:
	if not pickups.has(pickup_kind):
		return
	var entry: Dictionary = pickups[pickup_kind]
	entry["available"] = available
	entry["respawn_remaining"] = 0.0 if available else _get_pickup_respawn_duration(pickup_kind)
	var pickup_node := entry.get("node", null) as Node3D
	if pickup_node != null:
		pickup_node.visible = available
	pickups[pickup_kind] = entry

func _reset_pickups() -> void:
	for pickup_kind in pickups.keys():
		_set_pickup_available(pickup_kind, true)

func _reset_vertical_hazards() -> void:
	jump_pad_trigger_count = 0
	last_jump_pad_id = &""
	for index in range(jump_pads.size()):
		var pad: Dictionary = jump_pads[index]
		pad["player_cooldown"] = 0.0
		pad["bot_cooldown"] = 0.0
		jump_pads[index] = pad

func _get_pickup_respawn_duration(pickup_kind: StringName) -> float:
	return ArenaCombatRulesScript.get_pickup_respawn_duration(pickup_kind, HEALTH_PICKUP_RESPAWN, OVERCHARGE_PICKUP_RESPAWN)

func _get_pickup_respawn_remaining(pickup_kind: StringName) -> float:
	var entry: Dictionary = pickups.get(pickup_kind, {})
	return float(entry.get("respawn_remaining", 0.0))

func _update_bot_awareness() -> void:
	if bot == null:
		return
	bot.set_tactical_context(_get_bot_tactical_context())
	bot.set_pickup_awareness(
		debug_get_pickup_position(&"health"),
		debug_is_pickup_available(&"health"),
		debug_get_pickup_position(&"overcharge"),
		debug_is_pickup_available(&"overcharge")
	)
	var threat := _get_nearest_player_projectile_to_bot()
	if threat.is_empty():
		bot.set_projectile_threat(Vector3.ZERO, Vector3.ZERO, false)
		return
	var threat_node := threat.get("node", null) as Node3D
	if threat_node == null:
		bot.set_projectile_threat(Vector3.ZERO, Vector3.ZERO, false)
		return
	bot.set_projectile_threat(threat_node.global_position, threat.get("velocity", Vector3.ZERO), true)

func _get_nearest_player_projectile_to_bot() -> Dictionary:
	if bot == null:
		return {}
	var best_entry: Dictionary = {}
	var best_distance := 1000000.0
	for entry: Dictionary in active_projectiles:
		if entry.get("source", &"") != &"player":
			continue
		var threat_node := entry.get("node", null) as Node3D
		if threat_node == null or not is_instance_valid(threat_node):
			continue
		var distance := threat_node.global_position.distance_to(bot.get_body_center())
		if distance < best_distance:
			best_distance = distance
			best_entry = entry
	if best_distance > bot.projectile_dodge_radius * 1.7:
		return {}
	return best_entry

func _get_jump_pad_routes() -> Array[Dictionary]:
	var routes: Array[Dictionary] = []
	for route: Dictionary in active_layout.get("jump_pad_routes", []):
		routes.append(route.duplicate(true))
	if not routes.is_empty():
		return routes
	for pad: Dictionary in jump_pads:
		var pad_id: StringName = pad.get("id", &"")
		routes.append(BotTacticalContextScript.make_jump_pad_route(
			pad_id,
			pad.get("position", Vector3.ZERO),
			pad.get("target", Vector3.ZERO),
			[BotTacticalContextScript.ROLE_JUMP_PAD_ENTRY, BotTacticalContextScript.ROLE_HIGH_GROUND]
		))
	return routes

func _get_nearest_jump_pad_target(reference_position: Vector3) -> Vector3:
	var best_target := reference_position
	var best_distance := 1000000.0
	for route: Dictionary in _get_jump_pad_routes():
		var target_position: Vector3 = route.get("target", reference_position)
		var flat_reference := reference_position
		var flat_target := target_position
		flat_reference.y = 0.0
		flat_target.y = 0.0
		var distance := flat_reference.distance_to(flat_target)
		if distance < best_distance:
			best_distance = distance
			best_target = target_position
	return best_target

func _get_player_visual_muzzle_origin(origin: Vector3, direction: Vector3) -> Vector3:
	var shot_direction := direction.normalized()
	var camera: Camera3D = null
	if player == null or not player.has_method("get_camera"):
		return ArenaCombatRulesScript.build_visual_muzzle_origin(
			origin,
			shot_direction,
			camera,
			PLAYER_VISUAL_MUZZLE_RIGHT_OFFSET,
			PLAYER_VISUAL_MUZZLE_DOWN_OFFSET,
			PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET
		)
	camera = player.get_camera()
	return ArenaCombatRulesScript.build_visual_muzzle_origin(
		origin,
		shot_direction,
		camera,
		PLAYER_VISUAL_MUZZLE_RIGHT_OFFSET,
		PLAYER_VISUAL_MUZZLE_DOWN_OFFSET,
		PLAYER_VISUAL_MUZZLE_FORWARD_OFFSET
	)

func _create_bot_tactical_context(parent: Node3D) -> Dictionary:
	var marker_root := Node3D.new()
	marker_root.name = "BotTacticalPoints"
	parent.add_child(marker_root)
	var points := _get_active_tactical_points(true)
	for index in range(points.size()):
		var entry: Dictionary = points[index]
		var point: Vector3 = entry.get("position", Vector3.ZERO)
		var role: StringName = entry.get("role", BotTacticalContextScript.ROLE_FALLBACK)
		var marker := Marker3D.new()
		marker.name = "BotTacticalPoint%02d_%s" % [index, String(role)]
		marker.position = point
		marker_root.add_child(marker)
	return _get_bot_tactical_context()

func _get_bot_tactical_context() -> Dictionary:
	return BotTacticalContextScript.make_context(
		active_layout_id,
		_get_active_tactical_points(true),
		_get_jump_pad_routes()
	)

func _get_active_tactical_points(include_objectives: bool) -> Array:
	var points: Array = []
	for point: Dictionary in active_layout.get("tactical_points", []):
		points.append(point.duplicate(true))
	if include_objectives:
		points.append(BotTacticalContextScript.make_point(
			health_pickup_position,
			BotTacticalContextScript.ROLE_HEALTH,
			1.45,
			&"health_objective",
			debug_is_pickup_available(&"health")
		))
		points.append(BotTacticalContextScript.make_point(
			overcharge_pickup_position,
			BotTacticalContextScript.ROLE_OVERCHARGE,
			1.28,
			&"overcharge_objective",
			debug_is_pickup_available(&"overcharge")
		))
	return points

func _initialize_telemetry() -> void:
	telemetry = ArenaTelemetryRecorderScript.new()
	var enable_file_output := not DisplayServer.get_name().to_lower().contains("headless")
	telemetry.start_session(_build_telemetry_context({
		"score_to_win": SCORE_TO_WIN,
		"player_spawn": player_spawn,
		"bot_spawn": bot_spawn
	}), enable_file_output)

func _record_telemetry_event(event_name: StringName, payload: Dictionary = {}) -> void:
	if telemetry == null:
		return
	telemetry.update_context(_build_telemetry_context())
	telemetry.record_event(event_name, payload)

func _build_telemetry_context(extra: Dictionary = {}) -> Dictionary:
	var context := {
		"round_index": round_index,
		"round_state": round_state,
		"map_id": active_layout_id,
		"map_name": map_name,
		"player_score": player_score,
		"bot_score": bot_score,
		"score_to_win": SCORE_TO_WIN
	}
	for key in extra.keys():
		context[key] = extra[key]
	return context

func _record_telemetry_arena_setup() -> void:
	var pickup_specs: Array = []
	for pickup_kind in pickups.keys():
		pickup_specs.append({
			"pickup_kind": pickup_kind,
			"position": debug_get_pickup_position(pickup_kind),
			"available": debug_is_pickup_available(pickup_kind)
		})
	var jump_pad_specs: Array = []
	for pad: Dictionary in jump_pads:
		jump_pad_specs.append({
			"pad_id": pad.get("id", &""),
			"position": pad.get("position", Vector3.ZERO),
			"target": pad.get("target", Vector3.ZERO)
		})
	_record_telemetry_event(&"arena_setup", {
		"floor_size": floor_size,
		"player_spawn": player_spawn,
		"bot_spawn": bot_spawn,
		"pickup_count": pickup_specs.size(),
		"pickups": pickup_specs,
		"jump_pad_count": jump_pad_specs.size(),
		"jump_pads": jump_pad_specs,
		"tactical_point_count": debug_get_bot_tactical_point_count()
	})
	for pickup: Dictionary in pickup_specs:
		_record_telemetry_event(&"pickup_spawned", pickup)

func _record_telemetry_round_start(reason: StringName) -> void:
	telemetry_round_started_msec = Time.get_ticks_msec()
	telemetry_sample_elapsed = 0.0
	telemetry_jump_pad_flights.clear()
	telemetry_pickup_event_cooldowns.clear()
	telemetry_last_bot_snapshot.clear()
	_record_telemetry_event(&"round_start", {
		"reason": reason,
		"player_position": player.global_position if player != null else Vector3.ZERO,
		"bot_position": bot.global_position if bot != null else Vector3.ZERO,
		"player_health": player.health if player != null else 0.0,
		"bot_health": bot.health if bot != null else 0.0
	})
	_record_telemetry_bot_snapshot()

func _record_telemetry_round_end(winner: StringName) -> void:
	var duration_msec: int = maxi(0, Time.get_ticks_msec() - telemetry_round_started_msec)
	_record_telemetry_event(&"round_end", {
		"winner": winner,
		"duration_msec": duration_msec,
		"player_score": player_score,
		"bot_score": bot_score,
		"match_winner": match_winner,
		"round_state": round_state,
		"player_health": player.health if player != null else 0.0,
		"bot_health": bot.health if bot != null else 0.0,
		"player_position": player.global_position if player != null else Vector3.ZERO,
		"bot_position": bot.global_position if bot != null else Vector3.ZERO
	})
	if telemetry != null:
		telemetry.flush_summary()

func _update_telemetry_frame(delta: float) -> void:
	if telemetry == null:
		return
	_record_telemetry_bot_snapshot()
	_record_telemetry_jump_pad_landings()
	telemetry_sample_elapsed += delta
	if telemetry_sample_elapsed < TELEMETRY_SAMPLE_INTERVAL:
		return
	telemetry_sample_elapsed = 0.0
	_record_telemetry_movement_sample()

func _record_telemetry_movement_sample() -> void:
	if player == null or bot == null:
		return
	var player_velocity: Vector3 = player.velocity
	var bot_velocity: Vector3 = bot.velocity
	var player_flat_speed := Vector3(player_velocity.x, 0.0, player_velocity.z).length()
	var bot_flat_speed := Vector3(bot_velocity.x, 0.0, bot_velocity.z).length()
	_record_telemetry_event(&"movement_sample", {
		"player_position": player.global_position,
		"bot_position": bot.global_position,
		"player_health": player.health,
		"bot_health": bot.health,
		"distance_between": player.global_position.distance_to(bot.global_position),
		"player_speed": player_flat_speed,
		"bot_speed": bot_flat_speed,
		"player_airborne": not player.is_on_floor(),
		"bot_airborne": not bot.is_on_floor(),
		"player_jump_count": player.debug_get_jump_pad_launch_count(),
		"bot_jump_count": bot.debug_get_jump_count(),
		"bot_jump_pad_launch_count": bot.debug_get_jump_pad_launch_count(),
		"bot_state": bot.debug_get_state(),
		"bot_route_label": bot.debug_get_route_label(),
		"bot_active_route_key": bot.debug_get_active_route_key(),
		"bot_decision_reason": bot.debug_get_decision_reason(),
		"bot_has_line_of_sight": bool(bot.get("last_has_line_of_sight")),
		"bot_combat_overlay": bot.debug_is_combat_overlay_active(),
		"bot_jump_pad_commitment": bot.debug_is_jump_pad_commitment_active()
	})

func _record_telemetry_bot_snapshot() -> void:
	if bot == null:
		return
	var snapshot := _build_bot_telemetry_snapshot()
	if telemetry_last_bot_snapshot.is_empty():
		telemetry_last_bot_snapshot = snapshot
		_record_telemetry_event(&"bot_state_changed", snapshot)
		_record_telemetry_event(&"bot_route_changed", snapshot)
		return
	if snapshot.get("state", "") != telemetry_last_bot_snapshot.get("state", ""):
		_record_telemetry_event(&"bot_state_changed", snapshot)
	if snapshot.get("route_label", "") != telemetry_last_bot_snapshot.get("route_label", "") or snapshot.get("active_route_key", "") != telemetry_last_bot_snapshot.get("active_route_key", ""):
		_record_telemetry_event(&"bot_route_changed", snapshot)
	if snapshot.get("decision_reason", "") != telemetry_last_bot_snapshot.get("decision_reason", ""):
		_record_telemetry_event(&"bot_decision", snapshot)
	telemetry_last_bot_snapshot = snapshot

func _build_bot_telemetry_snapshot() -> Dictionary:
	return {
		"actor": "bot",
		"state": bot.debug_get_state(),
		"route_label": bot.debug_get_route_label(),
		"active_route_key": bot.debug_get_active_route_key(),
		"decision_reason": bot.debug_get_decision_reason(),
		"has_line_of_sight": bool(bot.get("last_has_line_of_sight")),
		"combat_overlay": bot.debug_is_combat_overlay_active(),
		"jump_pad_commitment": bot.debug_is_jump_pad_commitment_active(),
		"reposition_destination": bot.debug_get_reposition_destination(),
		"last_navigation_target": bot.debug_get_last_navigation_target(),
		"last_reposition_score": bot.debug_get_last_reposition_score(),
		"health_fraction": bot.health_fraction()
	}

func _record_telemetry_jump_pad_landings() -> void:
	for actor_id in telemetry_jump_pad_flights.keys():
		var combatant = player if String(actor_id) == "player" else bot
		if combatant == null:
			continue
		var flight: Dictionary = telemetry_jump_pad_flights[actor_id]
		if Time.get_ticks_msec() - int(flight.get("started_at", 0)) < 160:
			continue
		if not combatant.is_on_floor():
			continue
		var target: Vector3 = flight.get("target", combatant.global_position)
		var flat_distance := _flat_distance_between(combatant.global_position, target)
		_record_telemetry_event(&"jump_pad_landing", {
			"actor": actor_id,
			"pad_id": flight.get("pad_id", ""),
			"target": target,
			"landing_position": combatant.global_position,
			"flat_distance_to_target": flat_distance,
			"success": flat_distance <= TELEMETRY_JUMP_PAD_SUCCESS_DISTANCE
		})
		telemetry_jump_pad_flights.erase(actor_id)

func _update_telemetry_pickup_cooldowns(delta: float) -> void:
	var expired_keys: Array = []
	for key in telemetry_pickup_event_cooldowns.keys():
		var remaining := maxf(0.0, float(telemetry_pickup_event_cooldowns.get(key, 0.0)) - delta)
		if remaining <= 0.0:
			expired_keys.append(key)
		else:
			telemetry_pickup_event_cooldowns[key] = remaining
	for key in expired_keys:
		telemetry_pickup_event_cooldowns.erase(key)

func _maybe_record_pickup_nearby_ignored(pickup_kind: StringName, combatant) -> void:
	if combatant == null or combatant.get("is_dead") == true:
		return
	if not pickups.has(pickup_kind):
		return
	var entry: Dictionary = pickups[pickup_kind]
	if not bool(entry.get("available", false)):
		return
	var pickup_position: Vector3 = entry.get("position", Vector3.ZERO)
	var distance: float = combatant.get_body_center().distance_to(pickup_position)
	if distance > TELEMETRY_PICKUP_NEAR_DISTANCE:
		return
	var actor_id := _get_combatant_id(combatant)
	var key := "%s:%s:ignored" % [actor_id, String(pickup_kind)]
	if not _can_emit_pickup_attention_event(key):
		return
	var reason := "nearby_not_collected"
	if pickup_kind == &"health" and combatant.has_method("health_fraction") and combatant.health_fraction() >= 0.98:
		reason = "health_full"
	elif pickup_kind == &"overcharge" and combatant.has_method("has_overcharge_charge") and combatant.has_overcharge_charge():
		reason = "already_overcharged"
	_record_telemetry_event(&"pickup_nearby_ignored", {
		"actor": actor_id,
		"pickup_kind": pickup_kind,
		"position": pickup_position,
		"distance": distance,
		"reason": reason
	})

func _maybe_record_pickup_contested(pickup_kind: StringName) -> void:
	if player == null or bot == null or not pickups.has(pickup_kind):
		return
	var entry: Dictionary = pickups[pickup_kind]
	if not bool(entry.get("available", false)):
		return
	var pickup_position: Vector3 = entry.get("position", Vector3.ZERO)
	var player_distance: float = player.get_body_center().distance_to(pickup_position)
	var bot_distance: float = bot.get_body_center().distance_to(pickup_position)
	if player_distance > TELEMETRY_PICKUP_CONTEST_DISTANCE or bot_distance > TELEMETRY_PICKUP_CONTEST_DISTANCE:
		return
	var key := "contest:%s" % String(pickup_kind)
	if not _can_emit_pickup_attention_event(key):
		return
	_record_telemetry_event(&"pickup_contested", {
		"pickup_kind": pickup_kind,
		"position": pickup_position,
		"player_distance": player_distance,
		"bot_distance": bot_distance
	})

func _can_emit_pickup_attention_event(key: String) -> bool:
	if float(telemetry_pickup_event_cooldowns.get(key, 0.0)) > 0.0:
		return false
	telemetry_pickup_event_cooldowns[key] = TELEMETRY_PICKUP_EVENT_COOLDOWN
	return true

func _next_telemetry_id(prefix: String) -> String:
	telemetry_projectile_sequence += 1
	return "%s_%04d" % [prefix, telemetry_projectile_sequence]

func _get_combatant_id(combatant) -> String:
	if combatant == player:
		return "player"
	if combatant == bot:
		return "bot"
	if combatant != null and combatant.get("combatant_id") != null:
		return String(combatant.get("combatant_id"))
	return "unknown"

func _flat_distance_between(first_position: Vector3, second_position: Vector3) -> float:
	var delta := first_position - second_position
	delta.y = 0.0
	return delta.length()

func _build_plasma_material(overcharged: bool) -> StandardMaterial3D:
	var color := Color(0.78, 0.46, 1.0, 1.0) if overcharged else Color(0.38, 0.98, 1.0, 1.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.22
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.3 if overcharged else 1.8
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _build_pickup_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.3
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.35
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material

func _capture_mouse_if_playing() -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		return
	if menu_open or round_ended:
		return
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _set_menu_open(is_open: bool) -> void:
	menu_open = is_open
	get_tree().paused = menu_open
	if hud != null:
		hud.set_pause_menu_visible(menu_open, player.mouse_sensitivity)
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		_capture_mouse_if_playing()

func _return_to_main_menu() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(MENU_SCENE_PATH)

func _on_sensitivity_changed(value: float) -> void:
	if player != null:
		player.set_mouse_sensitivity(value)
	if hud != null:
		hud.set_sensitivity_value(player.mouse_sensitivity)
