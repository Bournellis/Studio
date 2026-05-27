class_name BattleSymbolIcon
extends Control

const AssetIdsScript = preload("res://core/asset_ids.gd")

var symbol := "?"
var fill_color := Color("#5DD4C8")
var cooldown_ratio := 0.0
var count_text := ""
var asset_id := ""

var _label: Label
var _count_label: Label
var _texture: Texture2D
var _asset_ids_fallback: Node

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(42, 42)
	_ensure_labels()

func _exit_tree() -> void:
	_free_asset_ids_fallback()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		_free_asset_ids_fallback()

func _free_asset_ids_fallback() -> void:
	if _asset_ids_fallback != null:
		_asset_ids_fallback.free()
		_asset_ids_fallback = null

func configure(new_symbol: String, new_color: Color, new_tooltip: String = "", new_count_text: String = "", new_cooldown_ratio: float = 0.0, new_asset_id: String = "") -> void:
	_ensure_labels()
	symbol = new_symbol
	fill_color = new_color
	count_text = new_count_text
	cooldown_ratio = clampf(new_cooldown_ratio, 0.0, 1.0)
	asset_id = new_asset_id
	_texture = _load_texture(asset_id)
	tooltip_text = new_tooltip
	_label.text = symbol
	_label.visible = _texture == null
	_count_label.text = count_text
	queue_redraw()

func debug_has_texture() -> bool:
	return _texture != null

func debug_asset_id() -> String:
	return asset_id

func _ensure_labels() -> void:
	if _label != null:
		return
	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.add_theme_font_size_override("font_size", 13)
	_label.add_theme_color_override("font_color", Color("#F0EEE5"))
	add_child(_label)

	_count_label = Label.new()
	_count_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_count_label.offset_top = 22
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_count_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_label.add_theme_font_size_override("font_size", 9)
	_count_label.add_theme_color_override("font_color", Color("#F0EEE5"))
	add_child(_count_label)

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var radius: float = minf(size.x, size.y) * 0.5
	var center := rect.get_center()
	var bg: Color = fill_color.darkened(0.55)
	var border: Color = fill_color.lightened(0.12)
	draw_circle(center, radius - 1.0, bg)
	draw_arc(center, radius - 2.0, 0.0, TAU, 36, border, 2.0, true)
	if cooldown_ratio > 0.0:
		var sweep: float = TAU * cooldown_ratio
		draw_arc(center, radius - 6.0, -PI / 2.0, -PI / 2.0 + sweep, 32, Color("#080B10", 0.82), 7.0, true)
	if _texture != null:
		var inset: float = maxf(4.0, radius * 0.24)
		draw_texture_rect(_texture, rect.grow(-inset), false)
	else:
		draw_line(Vector2(center.x - radius * 0.5, center.y), Vector2(center.x + radius * 0.5, center.y), border.darkened(0.1), 1.0, true)

func _load_texture(new_asset_id: String) -> Texture2D:
	var asset_ids := _asset_ids()
	if new_asset_id == "" or not bool(asset_ids.call("has_asset_id", new_asset_id)):
		return null
	var texture: Variant = asset_ids.call("texture", new_asset_id)
	if texture is Texture2D:
		return texture
	return null

func _asset_ids() -> Node:
	if is_inside_tree():
		var singleton := get_tree().root.get_node_or_null("AssetIds")
		if singleton != null:
			return singleton
	if _asset_ids_fallback == null:
		_asset_ids_fallback = AssetIdsScript.new()
	return _asset_ids_fallback
