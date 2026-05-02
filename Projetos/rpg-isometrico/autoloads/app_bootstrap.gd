extends Node

const ACTIONS: Dictionary[String, Array] = {
	"move_up": [{"kind": "key", "code": KEY_W}],
	"move_down": [{"kind": "key", "code": KEY_S}],
	"move_left": [{"kind": "key", "code": KEY_A}],
	"move_right": [{"kind": "key", "code": KEY_D}],
	"basic_attack": [{"kind": "mouse", "code": MOUSE_BUTTON_LEFT}, {"kind": "key", "code": KEY_SPACE}],
	"dash": [{"kind": "key", "code": KEY_SHIFT}],
	"skill_1": [{"kind": "key", "code": KEY_Q}],
	"skill_2": [{"kind": "key", "code": KEY_E}],
	"skill_3": [{"kind": "key", "code": KEY_R}],
	"skill_4": [{"kind": "key", "code": KEY_F}],
	"potion_1": [{"kind": "key", "code": KEY_1}],
	"potion_2": [{"kind": "key", "code": KEY_2}],
	"ui_back": [{"kind": "key", "code": KEY_ESCAPE}]
}

func _ready() -> void:
	_ensure_input_map()
	get_node("/root/ContentLibrary").ensure_loaded()
	get_node("/root/ProfileStore").load_profile()

func _ensure_input_map() -> void:
	for action_name: String in ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		var existing: Array[InputEvent] = InputMap.action_get_events(action_name)
		if not existing.is_empty():
			continue

		for binding: Dictionary in ACTIONS[action_name]:
			if binding["kind"] == "key":
				var key_event: InputEventKey = InputEventKey.new()
				key_event.physical_keycode = int(binding["code"])
				InputMap.action_add_event(action_name, key_event)
				continue

			var mouse_event: InputEventMouseButton = InputEventMouseButton.new()
			mouse_event.button_index = int(binding["code"])
			InputMap.action_add_event(action_name, mouse_event)
