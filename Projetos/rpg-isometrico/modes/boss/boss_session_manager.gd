class_name BossSessionManager
extends "res://modes/shared/local_mode_session_manager.gd"

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

func _init() -> void:
	configure(LocalModeCatalog.BOSS_MODE_ID, 0.55, 0.45)
