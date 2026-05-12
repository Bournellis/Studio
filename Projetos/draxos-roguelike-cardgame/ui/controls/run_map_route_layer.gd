class_name RunMapRouteLayer
extends Control

var connections: Array[Dictionary] = []

func setup(new_connections: Array[Dictionary]) -> void:
	connections = new_connections
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

func _ready() -> void:
	resized.connect(func() -> void:
		queue_redraw()
	)

func _draw() -> void:
	for connection: Dictionary in connections:
		var from_position: Vector2 = connection.get("from", Vector2.ZERO)
		var to_position: Vector2 = connection.get("to", Vector2.ZERO)
		var state: String = str(connection.get("state", "locked"))
		var from_point: Vector2 = Vector2(from_position.x * size.x, from_position.y * size.y)
		var to_point: Vector2 = Vector2(to_position.x * size.x, to_position.y * size.y)
		var color: Color = _state_color(state)
		draw_line(from_point, to_point, Color(0.0, 0.0, 0.0, 0.50), 8.0, true)
		draw_line(from_point, to_point, color, 3.0, true)

func _state_color(state: String) -> Color:
	match state:
		"completed":
			return Color(0.55, 0.95, 0.78, 0.90)
		"available":
			return Color(0.95, 0.78, 0.34, 0.90)
		"selected":
			return Color(0.62, 0.88, 1.0, 0.96)
	return Color(0.45, 0.52, 0.58, 0.48)
