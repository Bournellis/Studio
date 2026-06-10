extends Node

const ACTIONS: Dictionary[String, Array] = {
	"move_forward": [{"kind": "key", "code": KEY_W}],
	"move_back": [{"kind": "key", "code": KEY_S}],
	"move_left": [{"kind": "key", "code": KEY_A}],
	"move_right": [{"kind": "key", "code": KEY_D}],
	"jump": [{"kind": "key", "code": KEY_SPACE}],
	"boost": [{"kind": "key", "code": KEY_SHIFT}],
	"arcade_dash": [{"kind": "key", "code": KEY_E}, {"kind": "key", "code": KEY_CTRL}],
	"shoot": [{"kind": "mouse", "code": MOUSE_BUTTON_LEFT}],
	"alt_fire": [{"kind": "mouse", "code": MOUSE_BUTTON_RIGHT}],
	"restart_round": [{"kind": "key", "code": KEY_R}],
	"ui_back": [{"kind": "key", "code": KEY_ESCAPE}]
}

func _ready() -> void:
	_ensure_input_map()

func _ensure_input_map() -> void:
	for action_name: String in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing: Array[InputEvent] = InputMap.action_get_events(action_name)
		if not existing.is_empty():
			continue

		for binding: Dictionary in ACTIONS[action_name]:
			if binding["kind"] == "key":
				var key_event := InputEventKey.new()
				var keycode: Key = int(binding["code"]) as Key
				key_event.physical_keycode = keycode
				InputMap.action_add_event(action_name, key_event)
				continue

			var mouse_event := InputEventMouseButton.new()
			var mouse_button: MouseButton = int(binding["code"]) as MouseButton
			mouse_event.button_index = mouse_button
			InputMap.action_add_event(action_name, mouse_event)
