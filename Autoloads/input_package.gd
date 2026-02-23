class_name InputPackageHandler
extends Node

# Enum for input mode
enum InputMode { HOLD, TOGGLE }

const GAME_ACTIONS = [
	"up",
	"down",
	"left",
	"right",
	"jump",
	"sprint",
	"guard",
	"light_attack"
]

const UI_ACTIONS = []

const TOGGLEABLE_ACTIONS = [
	"up",
	"down",
	"left",
	"right",
	"jump",
	"sprint",
	"guard",
	"light_attack"
]

const DEFAULT_MODES: Dictionary = {
	"up": InputMode.HOLD,
	"down": InputMode.HOLD,
	"left": InputMode.HOLD,
	"right": InputMode.HOLD,
	"jump": InputMode.HOLD,
	"sprint": InputMode.HOLD,
	"guard": InputMode.HOLD,
	"light_attack": InputMode.HOLD
}

var _game_actions_paused: bool = false
var _ui_actions_paused: bool = false
# --- Input State ---
var _states: Dictionary = {}
var _toggle_states: Dictionary = {}  # tracks toggle on/off per action
var _modes: Dictionary = {}  # InputMode per action


func _ready() -> void:
	process_priority = -100
	for action in TOGGLEABLE_ACTIONS:
		_states[action] = {"pressed": false, "held": false, "released": false}
		_toggle_states[action] = false
		_modes[action] = DEFAULT_MODES.get(action, InputMode.HOLD)


func _input(_event: InputEvent) -> void:
	for action in TOGGLEABLE_ACTIONS:
		if _game_actions_paused and action in GAME_ACTIONS:
			_clear_action_state(action)
			continue
		if _ui_actions_paused and action in UI_ACTIONS:
			_clear_action_state(action)
			continue
		
		var just_pressed = Input.is_action_just_pressed(action)
		var just_released = Input.is_action_just_released(action)
		var is_held = Input.is_action_pressed(action)

		var state = _states[action]

		if _modes[action] == InputMode.HOLD:
			state["pressed"]  = just_pressed
			state["held"]     = is_held
			state["released"] = just_released
		else:
			if just_pressed:
				_toggle_states[action] = !_toggle_states[action]
			state["pressed"]  = just_pressed
			state["held"]     = _toggle_states[action]
			state["released"] = just_released and not _toggle_states[action]


func _clear_action_state(action: String) -> void:
	if _states.has(action):
		_states[action] = {"pressed": false, "held": false, "released": false}
	if _toggle_states.has(action):
		_toggle_states[action] = false


# --- Public Accessors ---


func is_pressed(action: String) -> bool:
	return _states.get(action, {}).get("pressed", false)


func is_held(action: String) -> bool:
	return _states.get(action, {}).get("held", false)


func is_released(action: String) -> bool:
	return _states.get(action, {}).get("released", false)


# --- Mode Switching (call this from game settings) ---


func set_mode(action: String, mode: InputMode) -> void:
	if action in _modes:
		_modes[action] = mode
		_toggle_states[action] = false


func get_mode(action: String) -> InputMode:
	return _modes.get(action, InputMode.HOLD)


func toggle_mode(action: String) -> void:
	var current = get_mode(action)
	set_mode(action, InputMode.TOGGLE if current == InputMode.HOLD else InputMode.HOLD)


func pause_game_actions(should_pause: bool) -> void:
	_game_actions_paused = should_pause
	if should_pause:
		for action in GAME_ACTIONS:
			_clear_action_state(action)


func pause_ui_actions(should_pause: bool) -> void:
	_ui_actions_paused = should_pause
	if should_pause:
		for action in UI_ACTIONS:
			_clear_action_state(action)
