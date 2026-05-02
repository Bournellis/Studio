class_name SurvivalSpawnController
extends Node

const TrollEnemy = preload("res://gameplay/enemies/troll_enemy.gd")

signal enemy_spawned(enemy)
signal enemy_defeated(enemy_id: StringName, enemy)

var runtime_root: Node3D
var game_context
var player
var spawn_points: Array[Vector3] = []
var pending_spawn_queue: Array[Dictionary] = []
var active_enemies: Dictionary = {}
var spawn_timer_remaining: float = 0.0
var enemy_serial: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func configure(next_runtime_root: Node3D, context, next_player, next_spawn_points: Array[Vector3]) -> void:
	runtime_root = next_runtime_root
	game_context = context
	player = next_player
	spawn_points = next_spawn_points.duplicate()
	pending_spawn_queue.clear()
	active_enemies.clear()
	spawn_timer_remaining = 0.0

func set_player(next_player) -> void:
	player = next_player
	for enemy in get_active_enemies():
		enemy.set_target(player)

func begin_wave(wave_spec: Dictionary) -> void:
	pending_spawn_queue.clear()
	spawn_timer_remaining = 0.0
	if spawn_points.is_empty():
		return

	var enemy_count: int = maxi(0, int(wave_spec.get("enemy_count", 0)))
	if enemy_count == 0:
		return

	var shuffled_points: Array[Vector3] = _build_shuffled_spawn_points()
	var enemy_config: Dictionary = Dictionary(wave_spec.get("enemy_config", {})).duplicate(true)
	var spawn_stagger: float = maxf(0.0, float(wave_spec.get("spawn_stagger", 0.7)))
	for index: int in range(enemy_count):
		pending_spawn_queue.append({
			"spawn_point": shuffled_points[index % shuffled_points.size()],
			"spawn_stagger": spawn_stagger,
			"enemy_config": enemy_config
		})

func tick(delta: float) -> void:
	_cleanup_stale_enemies()
	if pending_spawn_queue.is_empty():
		return

	spawn_timer_remaining = maxf(0.0, spawn_timer_remaining - delta)
	if spawn_timer_remaining > 0.0:
		return

	var entry: Dictionary = pending_spawn_queue[0]
	pending_spawn_queue.remove_at(0)
	_spawn_enemy(entry)
	if not pending_spawn_queue.is_empty():
		spawn_timer_remaining = float(entry.get("spawn_stagger", 0.0))

func get_active_enemies() -> Array:
	_cleanup_stale_enemies()
	var enemies: Array = []
	for enemy: Variant in active_enemies.values():
		if is_instance_valid(enemy) and not enemy.is_dead:
			enemies.append(enemy)
	return enemies

func get_enemy_count() -> int:
	return get_active_enemies().size()

func get_pending_spawn_count() -> int:
	return pending_spawn_queue.size()

func has_pending_spawns() -> bool:
	return not pending_spawn_queue.is_empty()

func get_runtime_snapshot() -> Dictionary:
	var active_enemy_snapshots: Array[Dictionary] = []
	for enemy in get_active_enemies():
		if enemy != null and is_instance_valid(enemy) and enemy.has_method("get_runtime_snapshot"):
			active_enemy_snapshots.append(enemy.get_runtime_snapshot())
	return {
		"pending_spawn_queue": var_to_str(pending_spawn_queue),
		"spawn_timer_remaining": spawn_timer_remaining,
		"enemy_serial": enemy_serial,
		"active_enemies": active_enemy_snapshots
	}

func restore_runtime_snapshot(snapshot: Dictionary) -> void:
	clear_wave_runtime()
	pending_spawn_queue = _deserialize_spawn_queue(snapshot.get("pending_spawn_queue", ""))
	spawn_timer_remaining = maxf(0.0, float(snapshot.get("spawn_timer_remaining", 0.0)))
	enemy_serial = maxi(0, int(snapshot.get("enemy_serial", 0)))

	var enemy_snapshots: Variant = snapshot.get("active_enemies", [])
	if enemy_snapshots is Array:
		for enemy_snapshot_value: Variant in enemy_snapshots:
			if not enemy_snapshot_value is Dictionary:
				continue
			_restore_enemy_from_snapshot(Dictionary(enemy_snapshot_value))

func clear_wave_runtime() -> void:
	pending_spawn_queue.clear()
	spawn_timer_remaining = 0.0
	for enemy in get_active_enemies():
		if is_instance_valid(enemy):
			enemy.queue_free()
	active_enemies.clear()

func _spawn_enemy(entry: Dictionary) -> void:
	if runtime_root == null:
		return

	enemy_serial += 1
	var enemy_id: StringName = StringName("enemy_%d" % enemy_serial)
	var enemy := TrollEnemy.new()
	enemy.name = "TrollEnemy%d" % enemy_serial
	runtime_root.add_child(enemy)
	enemy.global_position = entry.get("spawn_point", Vector3.ZERO)
	enemy.configure(enemy_id, game_context, player, Dictionary(entry.get("enemy_config", {})))
	enemy.died.connect(_on_enemy_died.bind(enemy_id, enemy))
	active_enemies[String(enemy_id)] = enemy
	enemy_spawned.emit(enemy)

func _on_enemy_died(enemy_id: StringName, enemy) -> void:
	active_enemies.erase(String(enemy_id))
	enemy_defeated.emit(enemy_id, enemy)
	if is_instance_valid(enemy):
		enemy.queue_free()

func _cleanup_stale_enemies() -> void:
	var stale_keys: Array[String] = []
	for key: Variant in active_enemies.keys():
		var enemy = active_enemies[key]
		if not is_instance_valid(enemy) or enemy.is_dead:
			stale_keys.append(str(key))
	for key: String in stale_keys:
		active_enemies.erase(key)

func _build_shuffled_spawn_points() -> Array[Vector3]:
	var shuffled: Array[Vector3] = spawn_points.duplicate()
	for index: int in range(shuffled.size() - 1, 0, -1):
		var swap_index: int = rng.randi_range(0, index)
		var cached: Vector3 = shuffled[index]
		shuffled[index] = shuffled[swap_index]
		shuffled[swap_index] = cached
	return shuffled

func _restore_enemy_from_snapshot(snapshot: Dictionary) -> void:
	if runtime_root == null:
		return

	var enemy_id: StringName = StringName(str(snapshot.get("enemy_id", "")))
	if enemy_id == &"":
		return

	var config: Dictionary = _deserialize_config(snapshot.get("config", ""))
	var enemy := TrollEnemy.new()
	enemy.name = "TrollEnemy%s" % str(enemy_id).trim_prefix("enemy_")
	runtime_root.add_child(enemy)
	enemy.configure(enemy_id, game_context, player, config)
	enemy.restore_runtime_snapshot(snapshot)
	enemy.died.connect(_on_enemy_died.bind(enemy_id, enemy))
	active_enemies[String(enemy_id)] = enemy
	enemy_spawned.emit(enemy)

func _deserialize_spawn_queue(value: Variant) -> Array[Dictionary]:
	if value is String and str(value) != "":
		var parsed: Variant = str_to_var(str(value))
		if parsed is Array:
			var result: Array[Dictionary] = []
			for entry: Variant in parsed:
				if entry is Dictionary:
					result.append(Dictionary(entry).duplicate(true))
			return result
	return []

func _deserialize_config(value: Variant) -> Dictionary:
	if value is String and str(value) != "":
		var parsed: Variant = str_to_var(str(value))
		if parsed is Dictionary:
			return Dictionary(parsed).duplicate(true)
	return {}
