extends Control

signal pressed

var overlay_id: String = ""
var hover_label: String = ""
var fallback_color: Color = Color(0.20, 0.26, 0.29)

var _hovered: bool = false
var _has_texture: bool = false
var _label: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setup(id: String, texture: Texture2D, label_text: String, color: Color) -> void:
	overlay_id = id
	hover_label = label_text
	fallback_color = color
	_has_texture = texture != null
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()

	if texture != null:
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.name = "ShipOverlayTexture_%s" % id
		texture_rect.texture = texture
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(texture_rect)

	_label = Label.new()
	_label.name = "ShipOverlayLabel_%s" % id
	_label.text = label_text
	_label.visible = false
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.84, 1.0))
	var label_style: StyleBoxFlat = StyleBoxFlat.new()
	label_style.bg_color = Color(0.02, 0.025, 0.03, 0.78)
	label_style.border_color = Color(fallback_color.r, fallback_color.g, fallback_color.b, 0.85)
	label_style.set_border_width_all(1)
	label_style.set_corner_radius_all(6)
	label_style.content_margin_left = 10
	label_style.content_margin_right = 10
	label_style.content_margin_top = 4
	label_style.content_margin_bottom = 4
	_label.add_theme_stylebox_override("normal", label_style)
	_label.anchor_left = 0.0
	_label.anchor_top = 1.0
	_label.anchor_right = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = 6.0
	_label.offset_top = -34.0
	_label.offset_right = -6.0
	_label.offset_bottom = -6.0
	add_child(_label)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			accept_event()
			pressed.emit()

func _draw() -> void:
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	var accent: Color = Color(fallback_color.r, fallback_color.g, fallback_color.b, 0.78)
	if _hovered:
		draw_rect(rect.grow(3.0), Color(fallback_color.r, fallback_color.g, fallback_color.b, 0.12), true)
		draw_rect(rect.grow(3.0), accent, false, 2.0)
	elif not _has_texture:
		draw_rect(rect.grow(1.0), Color(fallback_color.r, fallback_color.g, fallback_color.b, 0.16), false, 1.0)

func _on_mouse_entered() -> void:
	_hovered = true
	if _label != null:
		_label.visible = hover_label != ""
	queue_redraw()

func _on_mouse_exited() -> void:
	_hovered = false
	if _label != null:
		_label.visible = false
	queue_redraw()
