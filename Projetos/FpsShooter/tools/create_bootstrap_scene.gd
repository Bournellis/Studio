extends SceneTree

const BootstrapSceneGeneratorScript = preload("res://tools/bootstrap_scene_generator.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var result: Dictionary = BootstrapSceneGeneratorScript.new().generate_all()
	if bool(result.get("ok", false)):
		print("[scene-generator] %s" % str(result.get("message", "OK")))
		quit(0)
		return
	printerr("[scene-generator] %s" % str(result.get("message", "Failed.")))
	quit(1)
