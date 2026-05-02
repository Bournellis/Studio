class_name SurvivalSessionManager
extends "res://modes/shared/local_mode_session_manager.gd"

const LocalModeCatalog = preload("res://modes/shared/local_mode_catalog.gd")

func _init() -> void:
	configure(LocalModeCatalog.SURVIVAL_MODE_ID, 0.5, 0.45)
