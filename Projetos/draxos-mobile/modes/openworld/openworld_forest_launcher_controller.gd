class_name OpenworldForestLauncherController
extends RefCounted

var _entries: Array[Dictionary] = []

func configure(entries: Array[Dictionary]) -> void:
	_entries = []
	for entry: Dictionary in entries:
		if str(entry.get("entry_id", "")).strip_edges() == "":
			continue
		if str(entry.get("action_id", "")).strip_edges() == "":
			continue
		_entries.append(entry.duplicate(true))

func entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry: Dictionary in _entries:
		result.append(entry.duplicate(true))
	return result

func entry_count() -> int:
	return _entries.size()

func nearest_entry(player_position: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry: Dictionary in _entries:
		var position := Vector2(entry.get("position", Vector2.ZERO))
		var radius := float(entry.get("interaction_radius", 0.0))
		var distance := player_position.distance_to(position)
		if radius > 0.0 and distance <= radius and distance < best_distance:
			best = entry
			best_distance = distance
	return best.duplicate(true)

func entry_at_world_position(world_position: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var best_distance := INF
	for entry: Dictionary in _entries:
		var position := Vector2(entry.get("position", Vector2.ZERO))
		var radius := maxf(float(entry.get("interaction_radius", 0.0)), _visual_radius(entry))
		var distance := world_position.distance_to(position)
		if radius > 0.0 and distance <= radius and distance < best_distance:
			best = entry
			best_distance = distance
	return best.duplicate(true)

func entry_by_id(entry_id: String) -> Dictionary:
	var normalized := entry_id.strip_edges()
	for entry: Dictionary in _entries:
		if str(entry.get("entry_id", "")) == normalized:
			return entry.duplicate(true)
	return {}

func _visual_radius(entry: Dictionary) -> float:
	var size := Vector2(entry.get("visual_size", Vector2(64, 64)))
	return maxf(size.x, size.y) * 0.65
