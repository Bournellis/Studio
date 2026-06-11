extends SceneTree

const PlayerAvatarScript = preload("res://gameplay/avatar/player_avatar_3d.gd")
const OUTPUT_PATH: String = "res://assets/characters/quaternius_ubc/animations/jdc_runtime_animation_library.res"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var avatar = PlayerAvatarScript.new()
	root.add_child(avatar)
	await process_frame
	if avatar.animation_player == null:
		printerr("[avatar-runtime-assets] animation player was not created")
		quit(1)
		return
	var library: AnimationLibrary = avatar.animation_player.get_animation_library("")
	if library == null:
		printerr("[avatar-runtime-assets] default animation library was not created")
		quit(1)
		return
	var save_error := ResourceSaver.save(library.duplicate(true), OUTPUT_PATH)
	avatar.queue_free()
	await process_frame
	if save_error != OK:
		printerr("[avatar-runtime-assets] failed to save %s: %s" % [OUTPUT_PATH, error_string(save_error)])
		quit(1)
		return
	print("[avatar-runtime-assets] saved %s with %d animations" % [OUTPUT_PATH, library.get_animation_list().size()])
	quit(0)
