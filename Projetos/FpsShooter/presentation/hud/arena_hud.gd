class_name ArenaHud
extends CanvasLayer

var status_label: Label
var player_label: Label
var bot_label: Label
var hint_label: Label
var crosshair_label: Label
var hit_flash_time: float = 0.0

func _ready() -> void:
	_build_ui()

func _process(delta: float) -> void:
	if hit_flash_time > 0.0:
		hit_flash_time = maxf(0.0, hit_flash_time - delta)
		crosshair_label.modulate = Color(0.45, 1.0, 0.78, 1.0)
	else:
		crosshair_label.modulate = Color(0.9, 0.96, 1.0, 0.92)

func update_snapshot(snapshot: Dictionary) -> void:
	status_label.text = str(snapshot.get("status", "FpsShooter"))
	player_label.text = "Player %.0f / %.0f" % [
		float(snapshot.get("player_health", 0.0)),
		float(snapshot.get("player_max_health", 1.0))
	]
	bot_label.text = "Bot %.0f / %.0f" % [
		float(snapshot.get("bot_health", 0.0)),
		float(snapshot.get("bot_max_health", 1.0))
	]
	hint_label.text = str(snapshot.get("hint", "WASD move | Mouse look | LMB shoot | Space jump | R restart | Esc mouse"))

func flash_hit() -> void:
	hit_flash_time = 0.12

func _build_ui() -> void:
	var root := Control.new()
	root.name = "HudRoot"
	_ignore_mouse(root)
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var panel := PanelContainer.new()
	panel.name = "StatusPanel"
	_ignore_mouse(panel)
	panel.position = Vector2(18.0, 18.0)
	panel.custom_minimum_size = Vector2(360.0, 94.0)
	root.add_child(panel)

	var box := VBoxContainer.new()
	box.name = "StatusBox"
	_ignore_mouse(box)
	panel.add_child(box)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	_ignore_mouse(status_label)
	status_label.text = "FpsShooter"
	box.add_child(status_label)

	player_label = Label.new()
	player_label.name = "PlayerLabel"
	_ignore_mouse(player_label)
	box.add_child(player_label)

	bot_label = Label.new()
	bot_label.name = "BotLabel"
	_ignore_mouse(bot_label)
	box.add_child(bot_label)

	hint_label = Label.new()
	hint_label.name = "HintLabel"
	_ignore_mouse(hint_label)
	hint_label.position = Vector2(18.0, 118.0)
	hint_label.text = "Click captures mouse | WASD move | Mouse look | LMB shoot | Space jump | R restart | Esc mouse"
	root.add_child(hint_label)

	crosshair_label = Label.new()
	crosshair_label.name = "Crosshair"
	_ignore_mouse(crosshair_label)
	crosshair_label.text = "+"
	crosshair_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair_label.set_anchors_preset(Control.PRESET_CENTER)
	crosshair_label.position = Vector2(-8.0, -14.0)
	crosshair_label.add_theme_font_size_override("font_size", 28)
	root.add_child(crosshair_label)

func _ignore_mouse(control: Control) -> void:
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
