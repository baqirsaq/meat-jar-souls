extends State

@export var jump_power: float = -400.0
@export var run_speed: float = 400.0
@export var ground_acceleration: float = 200.0
@export var ground_decceleration: float = 100.0
@export var air_state: State

func state_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_jump()


func _jump() -> void:
	character.velocity.y = jump_power
	next_state = air_state
	playback.travel("jump_start")
