extends State

@export var ground_state: State
@export var landing_state: State
@export var heavly_landing_threshold: float = 500
@export var jump_cut_factor: float = 0.75
@export var speed: float = 300.0
@export var air_acceleration: float = 100.0
@export var air_deceleration: float = 2.0

var last_frame_velocity: Vector2 = Vector2.ZERO


func on_enter() -> void:
	character.speed = speed
	character.acceleration = air_acceleration
	character.deceleration = air_deceleration


@warning_ignore("unused_parameter")
func state_process(_delta: float) -> void:
	if character.velocity.y > 0.0:
		playback.start("jump_end")
	else:
		_handle_jump_cut()

	if character.is_on_floor():

		_handle_landing()

	last_frame_velocity = character.velocity


func _handle_landing() -> void:
	if heavly_landing_threshold <= last_frame_velocity.y:
		playback.travel("heavy_landing")
		next_state = landing_state
	else:
		playback.travel("move")
		next_state = ground_state


func _handle_jump_cut() -> void:
	if InputPackage.is_released("jump") or character.is_on_ceiling():
		character.velocity.y *= jump_cut_factor
