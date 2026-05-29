class_name BattleActorMarker
extends Control

const SIDE_PLAYER := "player"
const SIDE_OPPONENT := "opponent"

var side := SIDE_PLAYER
var display_name := "Draxos"
var tint := Color("#5DD4C8")
var hp := 100.0
var max_hp := 100.0
var mana := 20.0
var max_mana := 20.0
var barrier := 0.0
var status_count := 0
var summon_count := 0

var _flash_color := Color.WHITE
var _flash_strength := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(130, 190)

func configure(new_side: String, new_display_name: String, new_tint: Color) -> void:
	side = new_side
	display_name = new_display_name
	tint = new_tint
	_refresh_tooltip()
	queue_redraw()

func set_stats(new_hp: float, new_max_hp: float, new_mana: float, new_max_mana: float, new_barrier: float, new_status_count: int, new_summon_count: int) -> void:
	hp = max(0.0, new_hp)
	max_hp = max(1.0, new_max_hp)
	mana = max(0.0, new_mana)
	max_mana = max(1.0, new_max_mana)
	barrier = max(0.0, new_barrier)
	status_count = max(0, new_status_count)
	summon_count = max(0, new_summon_count)
	_refresh_tooltip()
	queue_redraw()

func pulse(color: Color) -> void:
	_flash_color = color
	_set_flash_strength(1.0)
	if not is_inside_tree():
		return
	var tween := create_tween()
	tween.tween_method(_set_flash_strength, 1.0, 0.0, 0.35)

func _set_flash_strength(value: float) -> void:
	_flash_strength = clampf(value, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var bounds := Rect2(Vector2.ZERO, size)
	var center := bounds.get_center()
	var floor_y := size.y - 22.0
	var direction := 1.0 if side == SIDE_PLAYER else -1.0
	var base_color := tint.lerp(_flash_color, _flash_strength * 0.65)
	var shadow_color := Color(0, 0, 0, 0.28)

	draw_rect(Rect2(center.x - 44.0, floor_y - 8.0, 88.0, 14.0), shadow_color, true)
	draw_line(Vector2(center.x - 30.0 * direction, floor_y - 92.0), Vector2(center.x + 42.0 * direction, floor_y - 102.0), base_color.lightened(0.2), 8.0, true)
	draw_line(Vector2(center.x - 24.0 * direction, floor_y - 48.0), Vector2(center.x + 38.0 * direction, floor_y - 28.0), base_color.darkened(0.1), 8.0, true)
	draw_line(Vector2(center.x + 6.0 * direction, floor_y - 48.0), Vector2(center.x + 48.0 * direction, floor_y - 30.0), base_color.darkened(0.2), 8.0, true)
	draw_rect(Rect2(center.x - 24.0, floor_y - 98.0, 48.0, 72.0), base_color.darkened(0.08), true)
	draw_rect(Rect2(center.x - 26.0, floor_y - 100.0, 52.0, 76.0), base_color.lightened(0.05), false, 2.0)
	draw_circle(Vector2(center.x, floor_y - 124.0), 20.0, base_color.lightened(0.08))
	draw_circle(Vector2(center.x + 7.0 * direction, floor_y - 128.0), 3.0, Color("#080B10"))

	var shoulder := Vector2(center.x + 28.0 * direction, floor_y - 96.0)
	var tip := Vector2(center.x + 56.0 * direction, floor_y - 105.0)
	var lower := Vector2(center.x + 36.0 * direction, floor_y - 82.0)
	draw_colored_polygon(PackedVector2Array([shoulder, tip, lower]), base_color.lightened(0.25))

	if barrier > 0.0:
		draw_arc(center + Vector2(0.0, -78.0), 62.0, -2.55, 2.55, 40, Color("#5DD4C8", 0.78), 3.0, true)

	_draw_bar(Vector2(14.0, 8.0), size.x - 28.0, 9.0, hp / max_hp, Color("#B95757"), "Vida")
	_draw_bar(Vector2(14.0, 22.0), size.x - 28.0, 7.0, mana / max_mana, Color("#5DD4C8"), "Mana")
	if barrier > 0.0:
		_draw_bar(Vector2(14.0, 33.0), size.x - 28.0, 5.0, min(1.0, barrier / max_hp), Color("#D6C08A"), "Barreira")

	var pip_y := floor_y - 14.0
	for index: int in range(min(status_count, 5)):
		draw_circle(Vector2(18.0 + index * 11.0, pip_y), 3.0, Color("#D6C08A"))
	for index: int in range(min(summon_count, 4)):
		draw_rect(Rect2(size.x - 20.0 - index * 11.0, pip_y - 3.0, 6.0, 6.0), Color("#A57BD8"), true)

func _draw_bar(origin: Vector2, width: float, height: float, ratio: float, color: Color, _label: String) -> void:
	var clamped := clampf(ratio, 0.0, 1.0)
	draw_rect(Rect2(origin, Vector2(width, height)), Color("#080B10", 0.88), true)
	draw_rect(Rect2(origin, Vector2(width * clamped, height)), color, true)
	draw_rect(Rect2(origin, Vector2(width, height)), Color("#F0EEE5", 0.22), false, 1.0)

func _refresh_tooltip() -> void:
	tooltip_text = "%s\nCombatente principal da luta. A leitura mostra vida, mana, barreira, efeitos e aliados conforme a batalha avanca.\nVida %s/%s | Mana %s/%s | Barreira %s\nEfeitos ativos %d | Aliados %d" % [
		display_name,
		_number_text(hp),
		_number_text(max_hp),
		_number_text(mana),
		_number_text(max_mana),
		_number_text(barrier),
		status_count,
		summon_count,
	]

func _number_text(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	return "%.1f" % value
