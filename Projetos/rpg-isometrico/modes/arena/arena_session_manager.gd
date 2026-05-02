class_name ArenaSessionManager
extends "res://modes/shared/local_mode_session_manager.gd"

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

func _init() -> void:
	configure(LocalModeCatalog.ARENA_MODE_ID, 0.8, 0.7)
