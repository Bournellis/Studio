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
	custom_minimum_size = Vector2(130, 196)

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
	var unit := maxf(0.72, minf(size.x / 164.0, size.y / 230.0))
	var floor_y := size.y - 18.0 * unit
	var direction := 1.0 if side == SIDE_PLAYER else -1.0
	var base_color := tint.lerp(_flash_color, _flash_strength * 0.65)
	var shadow_color := Color(0, 0, 0, 0.34)
	var aura_color := base_color.lightened(0.2)
	aura_color.a = 0.16 + _flash_strength * 0.18
	var aura_center := Vector2(center.x, floor_y - 98.0 * unit)

	draw_circle(aura_center, 58.0 * unit, aura_color)
	draw_rect(Rect2(center.x - 58.0 * unit, floor_y - 9.0 * unit, 116.0 * unit, 14.0 * unit), shadow_color, true)

	var robe_color := base_color.darkened(0.08)
	var robe_edge := base_color.lightened(0.10)
	var robe := PackedVector2Array([
		Vector2(center.x - 28.0 * unit, floor_y - 126.0 * unit),
		Vector2(center.x + 26.0 * unit, floor_y - 126.0 * unit),
		Vector2(center.x + 48.0 * unit, floor_y - 18.0 * unit),
		Vector2(center.x + 15.0 * unit, floor_y - 7.0 * unit),
		Vector2(center.x - 14.0 * unit, floor_y - 7.0 * unit),
		Vector2(center.x - 48.0 * unit, floor_y - 18.0 * unit),
	])
	draw_colored_polygon(robe, robe_color)
	for index: int in range(robe.size()):
		draw_line(robe[index], robe[(index + 1) % robe.size()], robe_edge, 2.0 * unit, true)

	var hood := PackedVector2Array([
		Vector2(center.x - 31.0 * unit, floor_y - 143.0 * unit),
		Vector2(center.x, floor_y - 166.0 * unit),
		Vector2(center.x + 31.0 * unit, floor_y - 143.0 * unit),
		Vector2(center.x + 22.0 * unit, floor_y - 115.0 * unit),
		Vector2(center.x - 22.0 * unit, floor_y - 115.0 * unit),
	])
	draw_colored_polygon(hood, base_color.darkened(0.18))
	draw_line(hood[0], hood[1], robe_edge, 2.0 * unit, true)
	draw_line(hood[1], hood[2], robe_edge, 2.0 * unit, true)
	draw_circle(Vector2(center.x, floor_y - 132.0 * unit), 16.0 * unit, base_color.lightened(0.18))
	draw_circle(Vector2(center.x + 6.0 * direction * unit, floor_y - 137.0 * unit), 2.4 * unit, Color("#080B10"))

	var staff_bottom := Vector2(center.x + 36.0 * direction * unit, floor_y - 13.0 * unit)
	var staff_top := Vector2(center.x + 58.0 * direction * unit, floor_y - 164.0 * unit)
	draw_line(staff_bottom, staff_top, Color("#D6C08A", 0.92), 3.0 * unit, true)
	draw_circle(staff_top, 8.0 * unit, base_color.lightened(0.35))
	draw_circle(staff_top, 3.5 * unit, Color("#F0EEE5", 0.84))

	draw_line(Vector2(center.x - 22.0 * direction * unit, floor_y - 101.0 * unit), Vector2(center.x + 31.0 * direction * unit, floor_y - 105.0 * unit), base_color.lightened(0.08), 7.0 * unit, true)
	draw_line(Vector2(center.x - 18.0 * unit, floor_y - 52.0 * unit), Vector2(center.x - 34.0 * unit, floor_y - 15.0 * unit), base_color.darkened(0.18), 6.0 * unit, true)
	draw_line(Vector2(center.x + 18.0 * unit, floor_y - 52.0 * unit), Vector2(center.x + 34.0 * unit, floor_y - 15.0 * unit), base_color.darkened(0.18), 6.0 * unit, true)

	if barrier > 0.0:
		draw_arc(center + Vector2(0.0, -82.0 * unit), 66.0 * unit, -2.55, 2.55, 40, Color("#5DD4C8", 0.78), 3.0 * unit, true)

	_draw_bar(Vector2(14.0 * unit, 8.0 * unit), size.x - 28.0 * unit, 10.0 * unit, hp / max_hp, Color("#B95757"), "Vida")
	_draw_bar(Vector2(14.0 * unit, 24.0 * unit), size.x - 28.0 * unit, 7.0 * unit, mana / max_mana, Color("#5DD4C8"), "Mana")
	if barrier > 0.0:
		_draw_bar(Vector2(14.0 * unit, 36.0 * unit), size.x - 28.0 * unit, 5.0 * unit, min(1.0, barrier / max_hp), Color("#D6C08A"), "Barreira")

	var pip_y := floor_y - 13.0 * unit
	for index: int in range(min(status_count, 5)):
		draw_circle(Vector2(18.0 * unit + index * 11.0 * unit, pip_y), 3.0 * unit, Color("#D6C08A"))
	for index: int in range(min(summon_count, 4)):
		draw_rect(Rect2(size.x - 20.0 * unit - index * 11.0 * unit, pip_y - 3.0 * unit, 6.0 * unit, 6.0 * unit), Color("#A57BD8"), true)

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
