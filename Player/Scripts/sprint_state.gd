extends State

@export var ground_state: State
@export var air_state: State
@export var jump_power: float = -900.0
@export var sprint_speed: float = 600.0
@export var sprint_acceleration: float = 100.0

func on_enter() -> void:
	character.speed = sprint_speed
	character.acceleration = sprint_acceleration
	character.deceleration = ground_state.ground_deceleration


func state_process(_delta: float) -> void:
	if character.is_on_floor():
		if not InputPackage.is_held("sprint"):
			next_state = ground_state
			playback.travel("move")

		if InputPackage.is_pressed("jump"):
			character.velocity.y = jump_power
			next_state = air_state
			playback.travel("sprint_jump_start")
	else:
		next_state = air_state
