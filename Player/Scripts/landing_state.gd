extends State

#TODO: calculate damage taken

@export var ground_state: State

var cooldown_time: float = 1.0  # 2 seconds
var time_passed: float = 0.0

func on_enter() -> void:
	time_passed = 0.0
	character.deceleration = ground_state.ground_deceleration

func state_process(delta: float) -> void:
	if time_passed < cooldown_time:
		time_passed += delta
	else:
		playback.travel("move")
		next_state = ground_state
